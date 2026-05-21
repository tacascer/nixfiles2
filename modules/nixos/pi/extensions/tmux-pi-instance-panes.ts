import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import { randomUUID } from "node:crypto";
import { appendFileSync, mkdirSync, readFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";

type SpawnPaneParams = {
	prompt: string;
};

type ReadEventsParams = {
	eventFile: string;
};

type BridgeEvent = {
	jobId: string;
	type: string;
	timestamp: string;
	[key: string]: unknown;
};

function shellQuote(value: string): string {
	return `'${value.replace(/'/g, `'"'"'`)}'`;
}

function appendBridgeEvent(eventFile: string, event: BridgeEvent) {
	mkdirSync(dirname(eventFile), { recursive: true });
	appendFileSync(eventFile, `${JSON.stringify(event)}\n`, "utf8");
}

function makeBridgeEvent(type: string, data: Record<string, unknown> = {}): BridgeEvent | undefined {
	const jobId = process.env.PI_PARENT_JOB_ID;
	if (!jobId) return undefined;

	return {
		jobId,
		type,
		timestamp: new Date().toISOString(),
		...data,
	};
}

function reportChildEvent(type: string, data: Record<string, unknown> = {}) {
	const eventFile = process.env.PI_PARENT_EVENT_FILE;
	const event = makeBridgeEvent(type, data);
	if (!eventFile || !event) return;

	try {
		appendBridgeEvent(eventFile, event);
	} catch {
		// Child reporting must never break the child Pi task.
	}
}

function textFromContent(content: unknown): string | undefined {
	if (typeof content === "string") return content;
	if (!Array.isArray(content)) return undefined;

	const text = content
		.map((part) => {
			if (part && typeof part === "object" && "text" in part && typeof part.text === "string") return part.text;
			return undefined;
		})
		.filter(Boolean)
		.join("\n");

	return text || undefined;
}

function readJsonl(path: string): Array<Record<string, unknown>> {
	const raw = readFileSync(path, "utf8");
	return raw
		.split(/\r?\n/)
		.filter(Boolean)
		.map((line) => {
			try {
				return JSON.parse(line) as Record<string, unknown>;
			} catch (error) {
				return { type: "parse_error", line, error: error instanceof Error ? error.message : String(error) };
			}
		});
}

export default function (pi: ExtensionAPI) {
	// When this same extension is loaded in a child Pi process, these environment
	// variables connect it back to the parent via an append-only JSONL file.
	reportChildEvent("extension_loaded", {
		pid: process.pid,
		outputFile: process.env.PI_PARENT_OUTPUT_FILE,
	});

	pi.on("session_start", async (_event, ctx) => {
		reportChildEvent("session_start", {
			cwd: ctx.cwd,
			outputFile: process.env.PI_PARENT_OUTPUT_FILE,
		});
	});

	pi.on("tool_execution_start", async (event) => {
		reportChildEvent("tool_execution_start", {
			toolCallId: event.toolCallId,
			toolName: event.toolName,
		});
	});

	pi.on("tool_execution_end", async (event) => {
		reportChildEvent("tool_execution_end", {
			toolCallId: event.toolCallId,
			toolName: event.toolName,
			isError: event.isError,
		});
	});

	pi.on("agent_end", async (event) => {
		const lastAssistant = [...event.messages].reverse().find((message) => message.role === "assistant");
		reportChildEvent("agent_end", {
			messageCount: event.messages.length,
			lastAssistantText: textFromContent(lastAssistant?.content),
		});
	});

	pi.on("session_shutdown", async (event) => {
		reportChildEvent("session_shutdown", {
			reason: event.reason,
			outputFile: process.env.PI_PARENT_OUTPUT_FILE,
		});
	});

	pi.registerTool({
		name: "spawn_pi_instance_pane",
		label: "Spawn Pi Instance Pane",
		description: "Start an independent Pi agent in a visible tmux pane for parallel/background work and return child output and JSONL event paths.",
		promptSnippet: "Spawn an independent Pi agent in a visible tmux pane for parallel/background work with JSONL status events.",
		promptGuidelines: [
			"Use spawn_pi_instance_pane when work can be parallelized, delegated, or run in the background and the session is inside tmux.",
			"Give spawn_pi_instance_pane a self-contained task prompt, then continue other work and read the returned JSONL event file or output file when the result is needed.",
			"Use read_pi_instance_pane_events to inspect structured child status from the returned eventFile.",
			"Do not use spawn_pi_instance_pane when not inside tmux; use normal available background-work mechanisms instead.",
		],
		parameters: Type.Object({
			prompt: Type.String({
				description: "Self-contained task prompt for the child Pi instance.",
				minLength: 1,
			}),
		}),
		async execute(_toolCallId, params: SpawnPaneParams, _signal, onUpdate, ctx) {
			if (!process.env.TMUX) {
				return {
					isError: true,
					content: [
						{
							type: "text" as const,
							text: "Not inside tmux; spawn_pi_instance_pane is unavailable in this session.",
						},
					],
					details: { tmux: false },
				};
			}

			const jobId = randomUUID();
			const bridgeDir = join(process.env.XDG_RUNTIME_DIR || tmpdir(), "pi-instance-panes", jobId);
			const eventFile = join(bridgeDir, "events.jsonl");
			mkdirSync(bridgeDir, { recursive: true });
			appendBridgeEvent(eventFile, {
				jobId,
				type: "spawn_requested",
				timestamp: new Date().toISOString(),
				cwd: ctx.cwd,
			});

			onUpdate?.({
				content: [{ type: "text" as const, text: "Spawning child Pi instance in a tmux pane with JSONL bridge..." }],
			});

			try {
				const command = [
					`PI_PARENT_JOB_ID=${shellQuote(jobId)}`,
					`PI_PARENT_EVENT_FILE=${shellQuote(eventFile)}`,
					"pi-instance-pane",
					'"$1"',
				].join(" ");
				const result = await pi.exec("bash", ["-lc", command, "pi-spawn", params.prompt], { cwd: ctx.cwd });
				const outputPath = result.stdout.trim().split(/\r?\n/).filter(Boolean).at(-1);

				appendBridgeEvent(eventFile, {
					jobId,
					type: "spawned",
					timestamp: new Date().toISOString(),
					outputPath,
				});

				return {
					content: [
						{
							type: "text" as const,
							text: outputPath
								? `Spawned child Pi instance pane. Output file: ${outputPath}\nJSONL event file: ${eventFile}\nJob ID: ${jobId}`
								: `Spawned child Pi instance pane.\nJSONL event file: ${eventFile}\nJob ID: ${jobId}\n\n${result.stdout}`,
						},
					],
					details: {
						jobId,
						eventFile,
						outputPath,
						stdout: result.stdout,
						stderr: result.stderr,
					},
				};
			} catch (error) {
				appendBridgeEvent(eventFile, {
					jobId,
					type: "spawn_failed",
					timestamp: new Date().toISOString(),
					error: error instanceof Error ? error.message : String(error),
				});

				return {
					isError: true,
					content: [
						{
							type: "text" as const,
							text: `Failed to spawn child Pi instance pane: ${error instanceof Error ? error.message : String(error)}\nJSONL event file: ${eventFile}`,
						},
					],
					details: { jobId, eventFile, error: error instanceof Error ? error.message : String(error) },
				};
			}
		},
	});

	pi.registerTool({
		name: "read_pi_instance_pane_events",
		label: "Read Pi Instance Pane Events",
		description: "Read structured JSONL status events emitted by a child Pi instance pane.",
		promptSnippet: "Read structured JSONL status events from a spawned child Pi instance pane.",
		promptGuidelines: [
			"Use read_pi_instance_pane_events with the eventFile returned by spawn_pi_instance_pane to check child progress or completion.",
		],
		parameters: Type.Object({
			eventFile: Type.String({ description: "Path to the events.jsonl file returned by spawn_pi_instance_pane." }),
		}),
		async execute(_toolCallId, params: ReadEventsParams) {
			try {
				const events = readJsonl(params.eventFile);
				const latest = events.at(-1);
				return {
					content: [
						{
							type: "text" as const,
							text: `Read ${events.length} child Pi event(s). Latest: ${latest?.type ?? "none"}`,
						},
					],
					details: { eventFile: params.eventFile, latest, events },
				};
			} catch (error) {
				return {
					isError: true,
					content: [
						{
							type: "text" as const,
							text: `Failed to read child Pi event file: ${error instanceof Error ? error.message : String(error)}`,
						},
					],
					details: { eventFile: params.eventFile, error: error instanceof Error ? error.message : String(error) },
				};
			}
		},
	});
}
