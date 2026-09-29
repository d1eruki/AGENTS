---
name: figma-layout-structure
description: Build and adapt Figma page layouts on a variable-driven grid, where every block spans the full canvas width and its content lives in a single centred container capped by a breakpoint variable. Use when the user asks to create a page block or screen in Figma, port an existing layout to another width (1920, 1440, tablet, mobile), set up or apply grid variables, or clean up a layout so blocks, margins and content columns follow one rule. Do not use for icon or illustration work, for component/variant library construction, or for one-off frames that carry no page grid.
---

# Figma Layout Structure

Give every block in a Figma page the same skeleton: a full-width shell, a single centred container capped by the file's breakpoint variable, and backgrounds that bleed past the container. A layout built this way survives a breakpoint switch without manual repositioning.

## Required Skills And Tools

- Use the available Figma MCP write tool:
  - Codex/OpenAI: load `figma:figma-use` before every `use_figma` write call.
  - Claude Code: use the configured Figma MCP write tool equivalent to `use_figma`.
- If no Figma MCP write tool is available, ask the user to connect Figma MCP instead of producing a non-Figma artifact.
- Work in the open or user-provided file. Never create a new Figma file unless explicitly asked.
- Read `references/structure-api.md` only when writing JavaScript for the write tool. It holds the API traps that break this structure.

## Runtime Support

Supports Codex/OpenAI and Claude Code. The structure contract, workflow and `references/structure-api.md` are shared. `agents/openai.yaml` is OpenAI/Codex UI metadata only; Claude Code reads the YAML frontmatter above.

## The Structure Contract

Every block, without exception:

1. **Block** — width spans the whole canvas (1920, 1440, 744, 393 — whatever the frame is). Auto layout. No left/right padding. Horizontal alignment centred. Vertical alignment chosen per block (top, centre or bottom).
2. **Container** — exactly one per content group, a direct child of the block:
   - `layoutSizingHorizontal = "FILL"`
   - `maxWidth` bound to the grid breakpoint variable
   - `paddingLeft` / `paddingRight` bound to the grid margin variable
3. **Content** — lives inside the container. Flow children when the block is a normal stack; absolutely positioned children when the block is a composition on a canvas, keeping the coordinates of the base design.
4. **Backgrounds, patterns, art** — absolutely positioned at block level (`layoutPositioning = "ABSOLUTE"`), free to bleed past the container to the full canvas width.

Consequences that are part of the contract, not suggestions:

- **One level of nesting.** A block holds containers, not a wrapper that holds a container. If an intermediate frame exists only to be a shell, remove it.
- **No empty containers.** If a frame in the layout already sits where the container belongs, bind the variables to that frame instead of creating a new one.
- **No hardcoded side padding.** Values like 60, 120, 240 in a block's `paddingLeft` mean the layout will not follow a breakpoint change. The only place a number is allowed is a variable's value.
- **Column width comes from the variables,** never from the canvas width. On a 1920 canvas with a 1440 breakpoint and 60 margin, the working column is 1320 and the rest is empty margin. That is correct, not a bug to fill.

## Grid Variables

Before touching geometry, read the file's variable collections and reuse what is there. A typical set, in a collection with one mode per breakpoint:

| Variable | desktop | tablet | mobile |
| --- | --- | --- | --- |
| `layout/grid/breakpoint` | 1440 | 744 | 393 |
| `layout/grid/margin` | 60 | 24 | 12 |
| `layout/grid/gutter` | 20 | 10 | 12 |
| `layout/grid/columns` | 12 | 8 | 4 |

Rules:

- Names, values and mode names come from the file. The table above is a shape, not a standard to impose.
- If the collection does not exist, propose it and wait for confirmation before creating variables.
- A wider canvas does not need a new mode. A 1920 page still runs on the desktop mode; the container simply stops at the breakpoint.
- Scope the variables when creating them: `WIDTH_HEIGHT` for the breakpoint, `GAP` for margin and gutter.

## Building A New Block

1. Read a neighbouring block first and copy its conventions: naming, alignment, vertical rhythm, which frames already carry variables.
2. Create the block shell: full width, auto layout, padding 0, centred.
3. Create one container, set it to FILL, bind `maxWidth` and the two paddings.
4. Put the content inside the container. Text nodes hug; related elements go into nested auto layouts; fixed sizes only where the design demands them.
5. Put the background art in the block as an absolute child, sized to cover the full canvas width.
6. Screenshot the block and check: content inside the column, art bleeding, nothing clipped, no horizontal overflow.

## Porting A Layout To Another Width

When an existing page must be reproduced at a different canvas width:

1. Duplicate the page frame and set the new width. Do not rescale the copy as a whole.
2. Work **one block at a time**, verifying each with a screenshot before moving on. A single generic transform applied to every block will break compositions where elements are visually related.
3. For each block:
   - shell to the new width, height per the design's screen height for that breakpoint;
   - content into the container at its original coordinates — the container is as wide as the base design's canvas, so the coordinates carry over unchanged;
   - background art scaled to cover the new width uniformly (see `references/structure-api.md`), never stretched on one axis;
   - clusters that belong together (an arrow next to a speaker, a caption under an image) move as one, never element by element.
4. Do not rescale typography, buttons, form controls or component instances. In most files the type ramp is identical across breakpoints; the headline simply wraps onto more lines.
5. Hidden alternates in the file (`… (скрыто)`, variant frames parked off-canvas) get the same treatment, so they are correct when switched on.

## Verification

- After each block: screenshot it, and confirm content sits inside the column and art bleeds correctly.
- After the page: audit every text node's left/right edge against the expected column bounds and report the ones outside it. Nodes inside hidden frames are not errors — check visibility before flagging.
- Report block sizes and the bound variables, not just "done".

## Guardrails

- "Look at it", "study this", "I made edits" means **read-only**. Inspect, report, and wait. Do not fix anything you noticed until the user says so.
- Never overwrite a user's manual edits. When rebuilding a block from a source, re-apply their overrides or ask first.
- Keep the source design untouched when producing an adapted copy; verify at the end that it was not modified.
- Do not commit or push anything in the repository unless the user asks.
