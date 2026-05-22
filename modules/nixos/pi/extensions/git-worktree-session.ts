/**
 * Git Worktree Session Extension
 *
 * Records the git worktree associated with each Pi session. When Pi exits from
 * or clears a session linked to a worktree, asks whether to remove or keep that
 * worktree.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const ENTRY_TYPE = "git-worktree-session";

type WorktreeSessionState = {
	worktreePath: string;
	mainWorktreePath: string;
	branch?: string;
	recordedAt: string;
};

async function git(
	pi: ExtensionAPI,
	args: string[],
	options?: { cwd?: string },
): Promise<{ stdout: string; stderr: string; code: number }> {
	return await pi.exec("git", args, options);
}

async function currentWorktreeState(pi: ExtensionAPI, cwd: string): Promise<WorktreeSessionState | undefined> {
	const topLevel = await git(pi, ["rev-parse", "--show-toplevel"], { cwd });
	if (topLevel.code !== 0) return undefined;

	const worktreePath = topLevel.stdout.trim();
	if (!worktreePath) return undefined;

	const list = await git(pi, ["worktree", "list", "--porcelain"], { cwd: worktreePath });
	if (list.code !== 0) return undefined;

	let mainWorktreePath = worktreePath;
	let branch: string | undefined;
	let currentBlockPath: string | undefined;

	for (const line of list.stdout.split("\n")) {
		if (line.startsWith("worktree ")) {
			currentBlockPath = line.slice("worktree ".length);
			if (mainWorktreePath === worktreePath) mainWorktreePath = currentBlockPath;
			continue;
		}

		if (currentBlockPath === worktreePath && line.startsWith("branch ")) {
			branch = line.slice("branch ".length).replace(/^refs\/heads\//, "");
		}
	}

	return {
		worktreePath,
		mainWorktreePath,
		branch,
		recordedAt: new Date().toISOString(),
	};
}

function latestRecordedState(ctx: { sessionManager: { getEntries(): Array<any> } }): WorktreeSessionState | undefined {
	let state: WorktreeSessionState | undefined;

	for (const entry of ctx.sessionManager.getEntries()) {
		if (entry.type === "custom" && entry.customType === ENTRY_TYPE && entry.data) {
			const data = entry.data as Partial<WorktreeSessionState>;
			if (typeof data.worktreePath === "string" && typeof data.mainWorktreePath === "string") {
				state = data as WorktreeSessionState;
			}
		}
	}

	return state;
}

function isLinkedWorktree(state: WorktreeSessionState): boolean {
	return state.worktreePath !== state.mainWorktreePath;
}

function shouldPromptForPreservation(reason: string): boolean {
	return reason === "quit" || reason === "new";
}

export default function (pi: ExtensionAPI) {
	let state: WorktreeSessionState | undefined;
	let recordedThisRuntime = false;

	pi.on("session_start", async (_event, ctx) => {
		state = latestRecordedState(ctx);

		const detected = await currentWorktreeState(pi, ctx.cwd);
		if (!detected) return;

		state = detected;
		if (!recordedThisRuntime) {
			pi.appendEntry(ENTRY_TYPE, detected);
			recordedThisRuntime = true;
		}
	});

	pi.on("session_shutdown", async (event, ctx) => {
		if (!shouldPromptForPreservation(event.reason)) return;

		const tracked = state ?? latestRecordedState(ctx);
		if (!tracked || !isLinkedWorktree(tracked)) return;

		if (!ctx.hasUI) {
			ctx.ui.notify(`Keeping git worktree ${tracked.worktreePath} (no interactive UI)`, "info");
			return;
		}

		const status = await git(pi, ["status", "--porcelain"], { cwd: tracked.worktreePath });
		const dirty = status.code === 0 && status.stdout.trim().length > 0;
		const branch = tracked.branch ? ` (${tracked.branch})` : "";
		const dirtyNote = dirty ? "\n\nThis worktree has uncommitted changes; removal may fail unless it is clean." : "";
		const action = event.reason === "new" ? "cleared context from" : "used";

		const choice = await ctx.ui.select(
			`Pi session ${action} git worktree:\n${tracked.worktreePath}${branch}${dirtyNote}\n\nRemove it now or keep it?`,
			[
				"Remove worktree",
				"Keep worktree",
			],
		);

		if (!choice?.startsWith("Remove")) {
			ctx.ui.notify(`Kept git worktree ${tracked.worktreePath}`, "info");
			return;
		}

		const remove = await git(pi, ["worktree", "remove", tracked.worktreePath], { cwd: tracked.mainWorktreePath });
		if (remove.code === 0) {
			ctx.ui.notify(`Removed git worktree ${tracked.worktreePath}`, "info");
		} else {
			const message = remove.stderr.trim() || remove.stdout.trim() || "unknown error";
			ctx.ui.notify(`Failed to remove git worktree; keeping it. ${message}`, "error");
		}
	});
}
