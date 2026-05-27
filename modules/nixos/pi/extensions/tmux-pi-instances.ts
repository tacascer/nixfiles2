import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import { randomUUID } from "node:crypto";
import { appendFileSync, mkdirSync, readFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";

type SpawnInstanceParams = {
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

function parseSpawnOutput(stdout: string): { outputPath?: string; tmuxSession?: string; tmuxWindow?: string } {
	const details: { outputPath?: string; tmuxSession?: string; tmuxWindow?: string } = {};

	for (const line of stdout.split(/\r?\n/)) {
		if (line.startsWith("output=")) details.outputPath = line.slice("output=".length);
		if (line.startsWith("session=")) details.tmuxSession = line.slice("session=".length);
		if (line.startsWith("window=")) details.tmuxWindow = line.slice("window=".length);
	}

	return details;
}

const parentSessionId = randomUUID();

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
		name: "spawn_pi_instance",
		label: "Spawn Pi Instance",
		description: "Start an independent Pi agent in a tmux window within the session scoped to this parent Pi session, and return child output and JSONL event paths.",
		promptSnippet: "Spawn an independent Pi agent in a new tmux window within this parent Pi session's tmux session, with JSONL status events.",
		promptGuidelines: [
			"Use spawn_pi_instance when work can be parallelized, delegated, run in the background, or isolated from the main context as a well-defined subtask and the parent session is inside tmux.",
			"Use context-isolated child instances for bounded subtasks whose detailed exploration, logs, or intermediate reasoning would unnecessarily pollute the parent conversation.",
			"Good candidates include focused research, inspection, validation, or implementation subtasks with clear success criteria.",
			"Give spawn_pi_instance a self-contained, bounded task prompt; include all necessary context because the child instance should not depend on the parent conversation.",
			"Avoid spawning child instances for vague tasks, tasks requiring ongoing user interaction, or tasks tightly coupled to the parent agent's current reasoning.",
			"Use read_pi_instance_events or read the returned output file before relying on child results.",
			"Do not use spawn_pi_instance when not inside tmux; use normal available mechanisms instead.",
		],
		parameters: Type.Object({
			prompt: Type.String({
				description: "Self-contained task prompt for the child Pi instance.",
				minLength: 1,
			}),
		}),
		async execute(_toolCallId, params: SpawnInstanceParams, _signal, onUpdate, ctx) {
			if (!process.env.TMUX) {
				return {
					isError: true,
					content: [
						{
							type: "text" as const,
							text: "Not inside tmux; spawn_pi_instance is unavailable in this session.",
						},
					],
					details: { tmux: false },
				};
			}

			const jobId = randomUUID();
			const bridgeDir = join(process.env.XDG_RUNTIME_DIR || tmpdir(), "pi-instances", jobId);
			const eventFile = join(bridgeDir, "events.jsonl");
			mkdirSync(bridgeDir, { recursive: true });
			appendBridgeEvent(eventFile, {
				jobId,
				type: "spawn_requested",
				timestamp: new Date().toISOString(),
				cwd: ctx.cwd,
			});

			onUpdate?.({
				content: [{ type: "text" as const, text: "Spawning child Pi instance in a tmux window with JSONL bridge..." }],
			});

			try {
				const command = [
					`PI_PARENT_SESSION_ID=${shellQuote(parentSessionId)}`,
					`PI_PARENT_JOB_ID=${shellQuote(jobId)}`,
					`PI_PARENT_EVENT_FILE=${shellQuote(eventFile)}`,
					"pi-instance",
					'"$1"',
				].join(" ");
				const result = await pi.exec("bash", ["-lc", command, "pi-spawn", params.prompt], { cwd: ctx.cwd });
				const { outputPath, tmuxSession, tmuxWindow } = parseSpawnOutput(result.stdout);

				appendBridgeEvent(eventFile, {
					jobId,
					type: "spawned",
					timestamp: new Date().toISOString(),
					outputPath,
					tmuxSession,
					tmuxWindow,
				});

				return {
					content: [
						{
							type: "text" as const,
							text: outputPath
								? `Spawned child Pi instance in tmux session${tmuxSession ? ` ${tmuxSession}` : ""}${tmuxWindow ? ` window ${tmuxWindow}` : ""}. Output file: ${outputPath}\nJSONL event file: ${eventFile}\nJob ID: ${jobId}`
								: `Spawned child Pi instance in tmux window.\nJSONL event file: ${eventFile}\nJob ID: ${jobId}\n\n${result.stdout}`,
						},
					],
					details: {
						jobId,
						eventFile,
						outputPath,
						tmuxSession,
						tmuxWindow,
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
							text: `Failed to spawn child Pi instance tmux window: ${error instanceof Error ? error.message : String(error)}\nJSONL event file: ${eventFile}`,
						},
					],
					details: { jobId, eventFile, error: error instanceof Error ? error.message : String(error) },
				};
			}
		},
	});

	pi.registerTool({
		name: "read_pi_instance_events",
		label: "Read Pi Instance Events",
		description: "Read structured JSONL status events emitted by a child Pi instance.",
		promptSnippet: "Read structured JSONL status events from a spawned child Pi instance.",
		promptGuidelines: [
			"Use read_pi_instance_events with the eventFile returned by spawn_pi_instance to check child progress or completion.",
		],
		parameters: Type.Object({
			eventFile: Type.String({ description: "Path to the events.jsonl file returned by spawn_pi_instance." }),
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
