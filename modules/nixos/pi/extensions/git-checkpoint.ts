/**
 * Git Checkpoint Extension
 *
 * Creates lightweight git stash checkpoints during agent turns. When a Pi
 * session is forked, optionally restores the worktree to the checkpoint for
 * the selected conversation entry.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

type Checkpoint = {
	ref: string;
	cwd: string;
};

async function isGitWorkTree(pi: ExtensionAPI): Promise<boolean> {
	try {
		const { stdout } = await pi.exec("git", ["rev-parse", "--is-inside-work-tree"]);
		return stdout.trim() === "true";
	} catch {
		return false;
	}
}

async function createCheckpoint(pi: ExtensionAPI): Promise<string | undefined> {
	try {
		const { stdout } = await pi.exec("git", ["stash", "create"]);
		return stdout.trim() || undefined;
	} catch {
		return undefined;
	}
}

export default function (pi: ExtensionAPI) {
	const checkpoints = new Map<string, Checkpoint>();
	let currentEntryId: string | undefined;

	// Keep track of the latest session leaf so checkpoints can be associated
	// with the conversation entry that /fork may later target.
	pi.on("tool_result", async (_event, ctx) => {
		const leaf = ctx.sessionManager.getLeafEntry();
		if (leaf) currentEntryId = leaf.id;
	});

	pi.on("turn_start", async (_event, ctx) => {
		if (!currentEntryId) {
			const leaf = ctx.sessionManager.getLeafEntry();
			if (leaf) currentEntryId = leaf.id;
		}

		if (!currentEntryId || !(await isGitWorkTree(pi))) return;

		const ref = await createCheckpoint(pi);
		if (ref) checkpoints.set(currentEntryId, { ref, cwd: ctx.cwd });
	});

	pi.on("session_before_fork", async (event, ctx) => {
		const checkpoint = checkpoints.get(event.entryId);
		if (!checkpoint) return;

		if (!ctx.hasUI) {
			// In non-interactive mode, never mutate the worktree implicitly.
			return;
		}

		const choice = await ctx.ui.select(
			"Restore git worktree to the checkpoint for this conversation entry?",
			[
				"Yes, restore code to that checkpoint",
				"No, keep current code",
			],
		);

		if (!choice?.startsWith("Yes")) return;

		try {
			await pi.exec("git", ["stash", "apply", checkpoint.ref], { cwd: checkpoint.cwd });
			ctx.ui.notify("Git worktree restored to checkpoint", "info");
		} catch (error) {
			ctx.ui.notify(`Failed to restore git checkpoint: ${error instanceof Error ? error.message : String(error)}`, "error");
		}
	});

	pi.on("agent_end", async () => {
		checkpoints.clear();
		currentEntryId = undefined;
	});
}
