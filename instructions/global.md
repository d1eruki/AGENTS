# Global Agent Instructions

These instructions apply to every task, regardless of the current repository.

## Plan Before File Changes

Before editing, deleting, renaming, formatting, generating, or otherwise changing files:

1. Confirm that the resolved Git root is the repository intended for the task; if it differs, resolve the target before changing files. Inspect the current worktree state and treat existing changes as user-owned.
2. Inspect enough relevant context to produce an evidence-based plan.
3. Present a plan of at most five short bullets that states:
   - every file that will be changed;
   - every file that will be deleted, or that no files will be deleted;
   - what will change in each file and why;
   - the material advantages and disadvantages of the approach, without inventing a disadvantage when none is supported by the inspected context.
4. Wait for the user's explicit approval of that plan before making any file change.

Read-only inspection is allowed before approval. A general request to implement something is not approval of a plan that has not yet been shown. If the file list, deletions, or material scope changes after approval, stop and request approval for an updated plan. Implementation details within the approved files and intent do not require another approval; state that work continues under the approved plan.

After approval, change only the approved files and preserve unrelated user-owned worktree changes. Do not overwrite, delete, rename, or format unrelated files. Approval of this workflow does not authorize unrelated external actions.

## Route To Relevant Guidance

Before performing specialized work, read the matching router or skill below. Read only the relevant branch; do not load every instruction file.

- Frontend applications, websites, browser UI, frontend dependencies, or frontend testing: read `/Users/dieruki/.codex/agent-guidance/instructions/frontend.md`.
- Figma design, wireframes, design systems, page structure, or Figma-to-code work: read `/Users/dieruki/.codex/agent-guidance/instructions/figma.md`.
- Native macOS interface design or implementation: read `/Users/dieruki/.codex/agent-guidance/design-macos-apps/SKILL.md`.
- Timeweb shared-hosting deployment, DNS, mail, SSL, or migration: read `/Users/dieruki/.codex/agent-guidance/timeweb-deployment/SKILL.md`.
- Job application or cover-letter writing: read `/Users/dieruki/.codex/agent-guidance/job-application-writer/SKILL.md`.

Follow a routed file only while it remains relevant to the user's request. The user's explicit instructions take precedence over reusable guidance.

## Keep The Skill Registry Synchronized

When adding, deleting, renaming, or moving a skill directory in `/Users/dieruki/Projects/skills`:

1. Include the affected skill files and registry synchronization in the change plan.
2. After approval and the repository edit, run `/Users/dieruki/.codex/agent-guidance/scripts/sync-skills.sh`.
3. Do not finish until `/Users/dieruki/.codex/agent-guidance/scripts/sync-skills.sh --check` succeeds.

The synchronizer may manage only symlinks in `~/.agents/skills` whose targets are inside `/Users/dieruki/Projects/skills`. It must never overwrite regular files, regular directories, or symlinks owned by another repository.

## Keep Documentation And Instructions Aligned

- When adding a dependency, update the repository's relevant setup, usage, or dependency documentation. Use a repository-specific documentation target when one is named.
- Add or change a repository instruction only for a recurring, repository-specific requirement not already covered by higher-level instructions, reusable skills, or project tooling. Before doing so, inspect the applicable instruction set for overlaps and conflicts; clarify an existing rule when possible.
- Keep repository-specific rules local. Put reusable workflows in shared skills only when that skill change is part of the approved scope. Do not duplicate behavior already enforced by formatters, linters, tests, or other tooling. Include any material instruction conflict in the change plan and resolve it within the approved scope.

## Verification And Communication

- Run checks that are relevant and proportional to the approved change.
- Report failed or skipped checks accurately; do not claim unperformed verification.
- Do not claim visual appearance has been verified when visual review belongs to the user.
- Keep routine progress updates to two sentences and send another only when the state materially changes or work exceeds 60 seconds. Keep final handoffs to five short lines unless a risk, failure, or blocker requires more detail.
- Present one coherent approach after inspection. Change it only when new evidence or a changed requirement invalidates it, and explain why. Do not narrate individual tool calls or repeat reported results.
- Clearly distinguish confirmed facts from unverified hypotheses.
