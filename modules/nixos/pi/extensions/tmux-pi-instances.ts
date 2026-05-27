import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import { randomUUID } from "node:crypto";
import { appendFileSync, existsSync, mkdirSync, readFileSync, unlinkSync } from "node:fs";
import { createConnection, createServer, type Server } from "node:net";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";

const DEFAULT_WAIT_TIMEOUT_SECONDS = 900;
const IPC_WRITE_TIMEOUT_MS = 1000;
const TERMINAL_EVENT_TYPES = new Set(["agent_end", "session_shutdown", "spawn_failed"]);

type SpawnInstanceParams = {
	prompt: string;
};

type ReadEventsParams = {
	eventFile: string;
};

type WaitInstanceParams = {
	eventFile?: string;
	jobId?: string;
	until?: string;
	timeoutSeconds?: number;
};

type BridgeEvent = {
	jobId: string;
	type: string;
	timestamp: string;
	[key: string]: unknown;
};

type ChildJobState = {
	jobId: string;
	eventFile?: string;
	outputPath?: string;
	tmuxSession?: string;
	tmuxWindow?: string;
	events: BridgeEvent[];
	seenEventKeys: Set<string>;
	latest?: BridgeEvent;
	terminal?: BridgeEvent;
};

type EventWaiter = {
	jobId?: string;
	eventFile?: string;
	until: string;
	onEvent: (event: BridgeEvent) => void;
	resolve: (event: BridgeEvent) => void;
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

async function sendBridgeEventToParent(event: BridgeEvent): Promise<void> {
	const endpoint = process.env.PI_PARENT_IPC_ENDPOINT;
	if (!endpoint) return;

	await new Promise<void>((resolve) => {
		let settled = false;
		let timeout: ReturnType<typeof setTimeout> | undefined;
		const finish = () => {
			if (settled) return;
			settled = true;
			if (timeout) clearTimeout(timeout);
			resolve();
		};

		try {
			const socket = createConnection(endpoint);
			timeout = setTimeout(() => {
				socket.destroy();
				finish();
			}, IPC_WRITE_TIMEOUT_MS);
			socket.on("error", finish);
			socket.on("close", finish);
			socket.on("connect", () => {
				socket.end(`${JSON.stringify(event)}\n`, finish);
			});
		} catch {
			finish();
		}
	});
}

async function reportChildEvent(type: string, data: Record<string, unknown> = {}) {
	const eventFile = process.env.PI_PARENT_EVENT_FILE;
	const event = makeBridgeEvent(type, data);
	if (!eventFile || !event) return;

	try {
		appendBridgeEvent(eventFile, event);
	} catch {
		// Child reporting must never break the child Pi task.
	}

	await sendBridgeEventToParent(event);
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

function parseBridgeEvent(value: Record<string, unknown>): BridgeEvent | undefined {
	if (typeof value.jobId !== "string" || typeof value.type !== "string" || typeof value.timestamp !== "string") {
		return undefined;
	}
	return value as BridgeEvent;
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

function isTerminalEvent(event: BridgeEvent, until: string): boolean {
	if (event.type === "spawn_failed") return true;
	if (until === "any_terminal") return TERMINAL_EVENT_TYPES.has(event.type);
	return event.type === until;
}

function bridgeEventKey(event: BridgeEvent): string {
	return [event.jobId, event.timestamp, event.type, String(event.toolCallId ?? ""), String(event.outputPath ?? "")].join("\0");
}

const parentSessionId = randomUUID();
const childJobs = new Map<string, ChildJobState>();
const waiters = new Set<EventWaiter>();
let parentIpcEndpoint: string | undefined;
let parentIpcServer: Server | undefined;

function observeBridgeEvent(event: BridgeEvent) {
	let state = childJobs.get(event.jobId);
	if (!state) {
		state = { jobId: event.jobId, events: [], seenEventKeys: new Set() };
		childJobs.set(event.jobId, state);
	}

	const eventKey = bridgeEventKey(event);
	const isDuplicate = state.seenEventKeys.has(eventKey);
	state.latest = event;
	if (typeof event.eventFile === "string") state.eventFile = event.eventFile;
	if (typeof event.outputPath === "string") state.outputPath = event.outputPath;
	if (typeof event.tmuxSession === "string") state.tmuxSession = event.tmuxSession;
	if (typeof event.tmuxWindow === "string") state.tmuxWindow = event.tmuxWindow;
	if (TERMINAL_EVENT_TYPES.has(event.type)) state.terminal = event;
	if (isDuplicate) return;
	state.seenEventKeys.add(eventKey);
	state.events.push(event);

	for (const waiter of [...waiters]) {
		if (waiter.jobId && waiter.jobId !== event.jobId) continue;
		if (waiter.eventFile && state.eventFile !== waiter.eventFile) continue;
		waiter.onEvent(event);
		if (isTerminalEvent(event, waiter.until)) {
			waiters.delete(waiter);
			waiter.resolve(event);
		}
	}
}

function replayEventFile(eventFile: string) {
	for (const event of readJsonl(eventFile).map(parseBridgeEvent).filter((event): event is BridgeEvent => Boolean(event))) {
		observeBridgeEvent({ ...event, eventFile: event.eventFile ?? eventFile });
	}
}

function findObservedEvent(jobId: string | undefined, eventFile: string | undefined, until: string): BridgeEvent | undefined {
	const states = jobId ? [childJobs.get(jobId)].filter((state): state is ChildJobState => Boolean(state)) : [...childJobs.values()];
	for (const state of states) {
		if (eventFile && state.eventFile !== eventFile) continue;
		const event = state.events.find((candidate) => isTerminalEvent(candidate, until));
		if (event) return event;
	}
	return undefined;
}

function startParentIpcServer(): string | undefined {
	if (process.env.PI_PARENT_JOB_ID) return undefined;
	if (parentIpcEndpoint) return parentIpcEndpoint;

	const ipcDir = join(process.env.XDG_RUNTIME_DIR || tmpdir(), "pi-instances", parentSessionId);
	mkdirSync(ipcDir, { recursive: true });
	parentIpcEndpoint = join(ipcDir, "events.sock");

	if (existsSync(parentIpcEndpoint)) {
		try {
			unlinkSync(parentIpcEndpoint);
		} catch {
			return undefined;
		}
	}

	try {
		parentIpcServer = createServer((socket) => {
			let buffer = "";
			socket.on("data", (chunk) => {
				buffer += chunk.toString("utf8");
				const lines = buffer.split(/\r?\n/);
				buffer = lines.pop() || "";
				for (const line of lines) {
					if (!line.trim()) continue;
					try {
						const event = parseBridgeEvent(JSON.parse(line) as Record<string, unknown>);
						if (event) observeBridgeEvent(event);
					} catch {
						// Ignore malformed IPC messages; JSONL remains the replay source.
					}
				}
			});
			socket.on("end", () => {
				if (!buffer.trim()) return;
				try {
					const event = parseBridgeEvent(JSON.parse(buffer) as Record<string, unknown>);
					if (event) observeBridgeEvent(event);
				} catch {
					// Ignore malformed IPC messages; JSONL remains the replay source.
				}
			});
		});
		parentIpcServer.on("error", () => {
			parentIpcServer = undefined;
			parentIpcEndpoint = undefined;
		});
		parentIpcServer.listen(parentIpcEndpoint);
		return parentIpcEndpoint;
	} catch {
		parentIpcEndpoint = undefined;
		parentIpcServer = undefined;
		return undefined;
	}
}

function stopParentIpcServer() {
	parentIpcServer?.close();
	parentIpcServer = undefined;
	if (parentIpcEndpoint && existsSync(parentIpcEndpoint)) {
		try {
			unlinkSync(parentIpcEndpoint);
		} catch {
			// Best-effort cleanup only.
		}
	}
	parentIpcEndpoint = undefined;
}

export default function (pi: ExtensionAPI) {
	// When this same extension is loaded in a child Pi process, these environment
	// variables connect it back to the parent via JSONL plus optional IPC events.
	void reportChildEvent("extension_loaded", {
		pid: process.pid,
		outputFile: process.env.PI_PARENT_OUTPUT_FILE,
	});

	pi.on("session_start", async (_event, ctx) => {
		startParentIpcServer();
		await reportChildEvent("session_start", {
			cwd: ctx.cwd,
			outputFile: process.env.PI_PARENT_OUTPUT_FILE,
		});
	});

	pi.on("tool_execution_start", async (event) => {
		await reportChildEvent("tool_execution_start", {
			toolCallId: event.toolCallId,
			toolName: event.toolName,
		});
	});

	pi.on("tool_execution_end", async (event) => {
		await reportChildEvent("tool_execution_end", {
			toolCallId: event.toolCallId,
			toolName: event.toolName,
			isError: event.isError,
		});
	});

	pi.on("agent_end", async (event) => {
		const lastAssistant = [...event.messages].reverse().find((message) => message.role === "assistant");
		await reportChildEvent("agent_end", {
			messageCount: event.messages.length,
			lastAssistantText: textFromContent(lastAssistant?.content),
		});
	});

	pi.on("session_shutdown", async (event) => {
		await reportChildEvent("session_shutdown", {
			reason: event.reason,
			outputFile: process.env.PI_PARENT_OUTPUT_FILE,
		});
		stopParentIpcServer();
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
			"Use wait_pi_instance for live event-driven waiting, or read_pi_instance_events/read the output file before relying on child results.",
			"Do not infer child completion from transport events alone; require an explicit final child status/report before summarizing delegated work.",
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

			const ipcEndpoint = startParentIpcServer();
			const jobId = randomUUID();
			const bridgeDir = join(process.env.XDG_RUNTIME_DIR || tmpdir(), "pi-instances", jobId);
			const eventFile = join(bridgeDir, "events.jsonl");
			mkdirSync(bridgeDir, { recursive: true });
			const spawnRequestedEvent: BridgeEvent = {
				jobId,
				type: "spawn_requested",
				timestamp: new Date().toISOString(),
				cwd: ctx.cwd,
				eventFile,
				ipcEndpoint,
			};
			appendBridgeEvent(eventFile, spawnRequestedEvent);
			observeBridgeEvent(spawnRequestedEvent);

			onUpdate?.({
				content: [
					{
						type: "text" as const,
						text: ipcEndpoint
							? "Spawning child Pi instance in a tmux window with JSONL replay and live IPC events..."
							: "Spawning child Pi instance in a tmux window with JSONL bridge; live IPC listener unavailable.",
					},
				],
			});

			try {
				const commandParts = [
					`PI_PARENT_SESSION_ID=${shellQuote(parentSessionId)}`,
					`PI_PARENT_JOB_ID=${shellQuote(jobId)}`,
					`PI_PARENT_EVENT_FILE=${shellQuote(eventFile)}`,
				];
				if (ipcEndpoint) commandParts.push(`PI_PARENT_IPC_ENDPOINT=${shellQuote(ipcEndpoint)}`);
				commandParts.push("pi-instance", '"$1"');

				const result = await pi.exec("bash", ["-lc", commandParts.join(" "), "pi-spawn", params.prompt], { cwd: ctx.cwd });
				const { outputPath, tmuxSession, tmuxWindow } = parseSpawnOutput(result.stdout);
				const spawnedEvent: BridgeEvent = {
					jobId,
					type: "spawned",
					timestamp: new Date().toISOString(),
					eventFile,
					outputPath,
					tmuxSession,
					tmuxWindow,
					ipcEndpoint,
				};

				appendBridgeEvent(eventFile, spawnedEvent);
				observeBridgeEvent(spawnedEvent);

				return {
					content: [
						{
							type: "text" as const,
							text: outputPath
								? `Spawned child Pi instance in tmux session${tmuxSession ? ` ${tmuxSession}` : ""}${tmuxWindow ? ` window ${tmuxWindow}` : ""}. Output file: ${outputPath}\nJSONL event file: ${eventFile}\nLive IPC endpoint: ${ipcEndpoint ?? "unavailable"}\nJob ID: ${jobId}`
								: `Spawned child Pi instance in tmux window.\nJSONL event file: ${eventFile}\nLive IPC endpoint: ${ipcEndpoint ?? "unavailable"}\nJob ID: ${jobId}\n\n${result.stdout}`,
						},
					],
					details: {
						jobId,
						eventFile,
						ipcEndpoint,
						outputPath,
						tmuxSession,
						tmuxWindow,
						stdout: result.stdout,
						stderr: result.stderr,
					},
				};
			} catch (error) {
				const spawnFailedEvent: BridgeEvent = {
					jobId,
					type: "spawn_failed",
					timestamp: new Date().toISOString(),
					eventFile,
					ipcEndpoint,
					error: error instanceof Error ? error.message : String(error),
				};
				appendBridgeEvent(eventFile, spawnFailedEvent);
				observeBridgeEvent(spawnFailedEvent);

				return {
					isError: true,
					content: [
						{
							type: "text" as const,
							text: `Failed to spawn child Pi instance tmux window: ${error instanceof Error ? error.message : String(error)}\nJSONL event file: ${eventFile}`,
						},
					],
					details: { jobId, eventFile, ipcEndpoint, error: error instanceof Error ? error.message : String(error) },
				};
			}
		},
	});

	pi.registerTool({
		name: "wait_pi_instance",
		label: "Wait Pi Instance",
		description: "Wait for live child Pi IPC events, replaying the JSONL event file first when provided.",
		promptSnippet: "Wait for live child Pi instance events without repeatedly polling output files.",
		promptGuidelines: [
			"Use wait_pi_instance with the eventFile or jobId returned by spawn_pi_instance to wait for child progress or shutdown using live IPC events.",
			"Do not infer child completion from wait_pi_instance alone; read the explicit final child report from output/events before relying on the child result.",
		],
		parameters: Type.Object({
			eventFile: Type.Optional(Type.String({ description: "Path to the events.jsonl file returned by spawn_pi_instance." })),
			jobId: Type.Optional(Type.String({ description: "Job ID returned by spawn_pi_instance." })),
			until: Type.Optional(
				Type.String({
					description: "Event type to wait for. Defaults to session_shutdown. Use any_terminal for agent_end, session_shutdown, or spawn_failed.",
				}),
			),
			timeoutSeconds: Type.Optional(
				Type.Number({ description: `Maximum seconds to wait. Defaults to ${DEFAULT_WAIT_TIMEOUT_SECONDS}.` }),
			),
		}),
		async execute(_toolCallId, params: WaitInstanceParams, _signal, onUpdate) {
			const until = params.until || "session_shutdown";
			const timeoutSeconds = Math.max(1, params.timeoutSeconds ?? DEFAULT_WAIT_TIMEOUT_SECONDS);
			if (!params.eventFile && !params.jobId) {
				return {
					isError: true,
					content: [{ type: "text" as const, text: "wait_pi_instance requires either eventFile or jobId." }],
				};
			}

			startParentIpcServer();
			if (params.eventFile) {
				try {
					replayEventFile(params.eventFile);
				} catch (error) {
					return {
						isError: true,
						content: [
							{
								type: "text" as const,
								text: `Failed to replay child Pi event file before waiting: ${error instanceof Error ? error.message : String(error)}`,
							},
						],
						details: { eventFile: params.eventFile, error: error instanceof Error ? error.message : String(error) },
					};
				}
			}

			const alreadyObserved = findObservedEvent(params.jobId, params.eventFile, until);
			if (alreadyObserved) {
				return {
					content: [
						{
							type: "text" as const,
							text: `Observed child Pi event ${alreadyObserved.type} for job ${alreadyObserved.jobId}. Read the child output for its explicit final report before relying on the result.`,
						},
					],
					details: { event: alreadyObserved, source: "replay-or-memory" },
				};
			}

			onUpdate?.({
				content: [
					{
						type: "text" as const,
						text: `Waiting up to ${timeoutSeconds}s for child Pi event ${until}${params.jobId ? ` on job ${params.jobId}` : ""}...`,
					},
				],
			});

			const event = await new Promise<BridgeEvent | undefined>((resolve) => {
				const timeout = setTimeout(() => {
					waiters.delete(waiter);
					resolve(undefined);
				}, timeoutSeconds * 1000);
				const waiter: EventWaiter = {
					jobId: params.jobId,
					eventFile: params.eventFile,
					until,
					onEvent: (event) => {
						onUpdate?.({
							content: [
								{
									type: "text" as const,
									text: `Child Pi job ${event.jobId}: observed ${event.type} at ${event.timestamp}`,
								},
							],
						});
					},
					resolve: (event) => {
						clearTimeout(timeout);
						resolve(event);
					},
				};
				waiters.add(waiter);
			});

			if (!event) {
				if (params.eventFile) {
					try {
						replayEventFile(params.eventFile);
						const replayedEvent = findObservedEvent(params.jobId, params.eventFile, until);
						if (replayedEvent) {
							return {
								content: [
									{
										type: "text" as const,
										text: `Observed child Pi event ${replayedEvent.type} for job ${replayedEvent.jobId} after final JSONL replay. Read the child output for its explicit final report before relying on the result.`,
									},
								],
								details: { event: replayedEvent, source: "final-jsonl-replay" },
							};
						}
					} catch {
						// Fall through to timeout; the initial replay already reported readable-file failures.
					}
				}

				return {
					isError: true,
					content: [
						{
							type: "text" as const,
							text: `Timed out waiting for child Pi event ${until}. JSONL replay remains available via read_pi_instance_events.`,
						},
					],
					details: { eventFile: params.eventFile, jobId: params.jobId, until, timeoutSeconds },
				};
			}

			return {
				content: [
					{
						type: "text" as const,
						text: `Observed child Pi event ${event.type} for job ${event.jobId}. Read the child output for its explicit final report before relying on the result.`,
					},
				],
				details: { event, source: "live-ipc" },
			};
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
				for (const event of events.map(parseBridgeEvent).filter((event): event is BridgeEvent => Boolean(event))) {
					observeBridgeEvent({ ...event, eventFile: event.eventFile ?? params.eventFile });
				}
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
