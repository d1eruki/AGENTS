# Figma Layout Structure — API Notes

Load this reference only when writing JavaScript for the Figma MCP write tool. Every item below is a failure that was hit in practice while building this structure.

## Binding The Container

`maxWidth` only exists for a child of an auto-layout frame, and only bites when that child is `FILL`. Order matters:

```js
const box = figma.createFrame();
box.name = "Container";
box.layoutMode = "VERTICAL";
box.fills = [];
box.clipsContent = false;
block.appendChild(box);                 // parent first
box.layoutSizingHorizontal = "FILL";    // then sizing
box.layoutSizingVertical = "FILL";
box.setBoundVariable("maxWidth", bpVar);       // then the variables
box.setBoundVariable("paddingLeft", mgVar);
box.setBoundVariable("paddingRight", mgVar);
```

Reading the variables:

```js
const cols = await figma.variables.getLocalVariableCollectionsAsync();
const grid = cols.find(c => c.modes.some(m => /desktop|tablet|mobile/i.test(m.name)));
const byName = {};
for (const id of grid.variableIds) {
  const v = await figma.variables.getVariableByIdAsync(id);
  if (v) byName[v.name] = v;
}
const bpVar = byName["layout/grid/breakpoint"];
const mgVar = byName["layout/grid/margin"];
```

`setBoundVariable` takes the variable object or its id. A silent no-op (the property stays `null` afterwards) means the node was not a FILL child of an auto-layout frame at that moment — fix the order rather than retrying.

## Measure Before Resize

Classifying children as "full-bleed" or "column content" must use the width the frame had **before** it was resized:

```js
const oldW = frame.width;          // capture first
frame.resize(newW, frame.height);  // then resize
for (const c of frame.children) {
  const fullBleed = c.width >= oldW * 0.95;   // compare against oldW, not frame.width
}
```

Comparing against the new width silently reclassifies every child and scatters the layout.

## Reparenting Stretches Children

Appending a node into an auto-layout frame makes it a flow child immediately: it can be stretched to the parent's cross size before the next line of code runs. Capture the size, then restore it:

```js
const w = node.width, h = node.height;
box.appendChild(node);
node.layoutPositioning = "ABSOLUTE";   // leave the flow
node.layoutSizingHorizontal = "FIXED";
node.layoutSizingVertical = "FIXED";
node.resize(w, h);                      // undo the stretch
node.x = x; node.y = y;                 // coordinates are relative to the new parent
```

Reparenting does not preserve the absolute position on canvas — always set `x`/`y` explicitly afterwards.

## Absolute Decor And Cover Scaling

Background art keeps its aspect ratio. Scale the art frame uniformly and centre the overflow, instead of resizing it to the block's proportions:

```js
const setScale = (n) => {
  if (n.type === "GROUP") { for (const c of n.children) setScale(c); return; }  // GROUP has no constraints
  try { n.constraints = { horizontal: "SCALE", vertical: "SCALE" }; } catch (e) {}
};
for (const c of art.children) setScale(c);
art.clipsContent = true;
const k = newW / oldW;
art.resize(Math.round(art.width * k), Math.round(art.height * k));
art.layoutPositioning = "ABSOLUTE";
art.x = 0;
art.y = Math.round((blockHeight - art.height) / 2);   // crop equally top and bottom
```

Stretching `1440 × 900` into `1920 × 1080` distorts by 11% on one axis — visible on faces, speaker cabinets and circles. Uniform scale plus clipping does not.

UI that lives inside an art frame (a CTA row, a caption) scales with it. Either accept it when the art is a photographic composition, or lift that node out to the container and place it by hand.

## Node Lookup Traps

- `findOne(n => n.name === "Container")` will happily return a node with that name inside a component instance elsewhere in the block. Search direct children instead:

```js
const box = block.children.find(c => c.name === "Container" && c.parent.id === block.id);
```

- Inside an instance, position cannot be overridden: setting `x` throws `This property cannot be overridden in an instance: relative-transform`. Move the instance itself, or restructure its master.
- `GROUP` nodes have no `constraints` property; recurse into their children.
- `node.resize()` resets sizing modes to `FIXED`, so call it **before** setting `layoutSizing*`.
- `layoutSizingVertical = "AUTO"` is invalid; the enum is `FIXED | HUG | FILL`, while frames themselves take `primaryAxisSizingMode = FIXED | AUTO`.

## Auto-Layout Blocks Without A Container

When a block already has a frame in the container's place, bind the variables to that frame and set the block's own padding to 0:

```js
block.paddingLeft = 0;
block.paddingRight = 0;
block.counterAxisAlignItems = "CENTER";      // vertical stack: centres horizontally
// block.primaryAxisAlignItems = "CENTER";   // horizontal stack: centres horizontally
for (const c of block.children) {
  if (c.layoutPositioning === "ABSOLUTE") continue;          // decor stays free
  if (!c.findOne(n => n.type === "TEXT")) continue;          // pure background stays full-bleed
  c.layoutSizingHorizontal = "FILL";
  c.setBoundVariable("maxWidth", bpVar);
  if (!(c.boundVariables || {}).paddingLeft) {
    c.setBoundVariable("paddingLeft", mgVar);
    c.setBoundVariable("paddingRight", mgVar);
  }
}
```

Instances that must stay capped (a footer, a header) take the breakpoint on `width` instead, with the page centring them:

```js
footer.layoutSizingHorizontal = "FIXED";
footer.setBoundVariable("width", bpVar);
page.counterAxisAlignItems = "CENTER";
```

A full-width header keeps its own inner container: the shell spans the canvas, the inner row is FILL with `maxWidth` and margin paddings.

## Auditing A Finished Page

```js
const rows = [];
for (const b of page.children) {
  const pb = b.absoluteBoundingBox;
  const bad = [];
  for (const t of b.findAll(n => n.type === "TEXT" && n.visible)) {
    const r = t.absoluteBoundingBox; if (!r) continue;
    const l = Math.round(r.x - pb.x), rr = Math.round(r.x + r.width - pb.x);
    if (l < colLeft - 4 || rr > colRight + 4) bad.push([t.characters.slice(0, 16), l, rr]);
  }
  rows.push({ n: b.name, w: Math.round(b.width), bad });
}
return rows;
```

`n.visible` is true for a node inside a hidden frame, so walk up the parents before calling a finding an error. Off-canvas carousel slides (`x` far beyond the canvas) are parked on purpose — report them, do not "fix" them.

## Screenshots

- Screenshot the block, not an inner frame: panels styled with low-opacity white fills are invisible against the transparent checkerboard of an isolated render.
- Screenshots include overlapping siblings by default; pass `contentsOnly: true` when a neighbouring block bleeds into the frame.
- One screenshot after the block is composed, one after a fix. Do not re-shoot an unchanged frame.
