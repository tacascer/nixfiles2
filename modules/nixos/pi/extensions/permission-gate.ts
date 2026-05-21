/**
 * Permission Gate Extension
 *
 * Prompts for confirmation before running potentially dangerous bash commands.
 * Blocks dangerous commands by default when no interactive UI is available.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { isToolCallEventType } from "@earendil-works/pi-coding-agent";

type DangerousRule = {
	name: string;
	pattern: RegExp;
};

const dangerousRules: DangerousRule[] = [
	{ name: "recursive removal", pattern: /\brm\s+(?:[^\n;&|]*\s)?-(?:[^\n;&|]*[rR][^\n;&|]*[fF]|[^\n;&|]*[fF][^\n;&|]*[rR])\b/ },
	{ name: "recursive removal", pattern: /\brm\b[^\n;&|]*\s--recursive\b/i },
	{ name: "privileged command", pattern: /\bsudo\b/i },
	{ name: "world-writable permissions", pattern: /\bchmod\b[^\n;&|]*(?:777|a\+w|ugo\+w)\b/i },
	{ name: "ownership change", pattern: /\bchown\b/i },
	{ name: "disk formatting", pattern: /\b(?:mkfs|fdisk|parted|dd)\b/i },
	{ name: "NixOS activation", pattern: /\bnixos-rebuild\b[^\n;&|]*\b(?:switch|boot)\b/i },
];

function findDangerousRule(command: string): DangerousRule | undefined {
	return dangerousRules.find((rule) => rule.pattern.test(command));
}

export default function (pi: ExtensionAPI) {
	pi.on("tool_call", async (event, ctx) => {
		if (!isToolCallEventType("bash", event)) return undefined;

		const command = event.input.command;
		const rule = findDangerousRule(command);
		if (!rule) return undefined;

		if (!ctx.hasUI) {
			return {
				block: true,
				reason: `Dangerous command blocked (${rule.name}; no UI for confirmation)`,
			};
		}

		const choice = await ctx.ui.select(
			`⚠️ Dangerous command (${rule.name}):\n\n  ${command}\n\nAllow?`,
			["Allow once", "Block"],
		);

		if (choice !== "Allow once") {
			return { block: true, reason: `Blocked by user (${rule.name})` };
		}

		return undefined;
	});
}
