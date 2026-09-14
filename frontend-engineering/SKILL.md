---
name: frontend-engineering
description: Plan or diagnose cross-cutting frontend systems whose behavior spans application state, browser runtime behavior, styling, or shared interface conventions. Use for multi-layer incidents and system-wide interface changes; do not use for ordinary framework, Tailwind, or verification work covered by specialized skills.
---

# Frontend Engineering

## Apply Cross-Cutting Scope

Use this skill when no technology-specific skill alone owns the task or when the requested outcome spans multiple frontend concerns. Keep framework-specific implementation, styling-tool usage, and verification in their specialized skills.

Use a technology-specific skill alongside this one only when the task independently requires both sets of guidance. Do not load another skill solely because this skill is active.

## Reuse Before Inventing

Before introducing or changing any interface element, search the active project for an equivalent or closely related pattern. Inspect components, nearby templates, shared styles, design tokens, icons, assets, and existing interaction states. This check is required for controls, links, cards, navigation, typography, spacing, responsive behavior, animation, hover and focus behavior, and other visible or interactive conventions.

When a suitable pattern exists:

- Reuse the complete relevant pattern, including its markup, dimensions, tokens, iconography, states, transitions, accessibility behavior, and responsive rules.
- Extend or compose the existing implementation when multiple consumers should share ownership. Do not create a parallel visual or behavioral variant merely for convenience.
- Adapt only the properties required by the new context, such as contrast, available space, or semantic labeling. Preserve the established interaction contract and explain any material deviation.

Create a new pattern only after the project search shows that no existing implementation satisfies the requirement or that reusing one would break a concrete constraint. Identify that missing capability before designing the replacement. Do not improvise new icons, motion, control behavior, component shapes, or layout conventions while a project equivalent is available.

## Diagnose Active Runtime Behavior

When observed behavior contradicts the expected code path, confirm the active runtime source instead of relying on static inspection alone. Treat visually similar CSS, browser, and JavaScript effects as separate hypotheses.

Where practical, verify:

- Active state classes, attributes, media-query results, and feature-detection results.
- Activated conditional branches and dynamic imports.
- The code or stylesheet controlling the relevant DOM property, CSS variable, inline style, or computed style.
- Whether the behavior is owned by a library, the browser, or project code.

For capability-gated behavior, trace the path from detection through resolved application state and initialization to the final observable result. Keep independent causes separate during diagnosis, while making consumers depend on one resolved state when they require identical behavior. Clearly distinguish confirmed causes from unverified hypotheses.

## Reuse Existing Application Mechanics

Before creating state flow, persistence, routing, data loading, or another shared mechanic, search for an equivalent helper, state module, service, or established lifecycle and reuse or extend it when its contract fits.

Identify the smallest existing property or mechanism that directly controls the requested result and change that first. Expand the structure, state, or implementation scope only after confirming that the smaller adjustment cannot satisfy the requirement.

Do not duplicate state synchronization, persistence, routing, data loading, or other shared behavior when an existing mechanism can own the same contract and lifecycle. Reuse or extract equivalent multi-line logic, but do not introduce an abstraction solely to eliminate intentionally similar declarative markup or data.

## Build Deliberate Typography Systems

Before assigning font sizes, identify the text roles that actually exist in the design and define one coherent semantic typography system for them. Do not give individual elements one-off sizes when they share the same role.

Use heading roles from H1 through H5 only when the interface needs those hierarchy levels. Heading semantics do not by themselves require either different or identical visual sizes: follow the design when deciding whether two levels share a size.

Define non-heading roles only when they are present, such as body text, lead text, labels, button text, captions, or overlines. Keep the set reasonably small, but do not impose an arbitrary maximum when the design has a justified additional role.

When a semantic typography system exists, make components consume its roles or tokens instead of raw size values. Change shared sizes centrally. If text does not fit, inspect the grid, container width, spacing, and wrapping before changing the font size or adding another typography role.

## Manage Cross-Cutting Changes

When replacing a shared mechanism or changing coupled behavior, first confirm that a direct local adjustment is insufficient. Then map only the affected path before proposing edits: current baseline, target contract, responsible mechanism, inputs and lifecycle, consumers and interactions, invariants, relevant states or environments, and observable acceptance checks.

Give each behavior one responsible mechanism. Do not let old and new implementations control the same outcome simultaneously unless an explicitly approved migration requires it. Keep connected changes atomic when splitting them would create an invalid intermediate state.

If the same acceptance check remains broken after two local fixes, or a fix regresses another mapped behavior, stop symptom-level patching and return to read-only diagnosis. Update the behavior map before changing the responsible mechanism, files, or scope.

## Derive Responsive Layouts

Derive responsive behavior from layout topology rather than treating each breakpoint as an isolated design.

When cards share a horizontal row:

- Keep outer heights equal when the design calls for a uniform row.
- Align corresponding headings, prices, dividers, lists, and actions.
- Let flexible content regions absorb differences in content length.

When cards stack vertically:

- Size each card by its own content.
- Remove equal-height constraints and unnecessary empty space.
- Preserve consistent external spacing.

Equal outer heights are insufficient when corresponding internal sections remain misaligned.

## Calculate Nested Corners

Calculate an inner radius as `max(0, outer radius - distance between contours)`. When horizontal and vertical insets differ, calculate each radius axis separately. Include padding, gap, and border thickness in the contour distance. Use an existing radius token when it exactly matches the result.

## Prefer Framework and Library Primitives

Use a framework's documented APIs and established project patterns before custom workarounds.

Reimplement or bypass baseline library behavior only when it is insufficient for the requirement and explain the concrete limitation before introducing the workaround.

## Maintain Layered Color Systems

Treat a color change as a change to one connected system. When the project uses layered color tokens, audit the affected path with these columns before proposing a cross-cutting change:

```text
role | light | dark | semantic token | component token | utility | consumers | states | background
```

Trace affected values from palette primitives through semantic and component tokens to their consumers. Check supported themes and existing default, hover, active, focus, and disabled states. Mark unverified assumptions and identify direct primitives, layer bypasses, mixed terminology, stale aliases, unused tokens, and colors evaluated against the wrong background.

Keep dependencies layered:

- Define semantic tokens from palette primitives.
- Name semantic tokens for reusable visual roles rather than concrete colors or page locations.
- Define component tokens from semantic tokens when a component-specific role is needed.
- Consume established component tokens instead of bypassing them with lower-level values.
- Keep reusable component states inside the component; expose a prop or variant when a parent must select them.

Use one vocabulary across the chain. Paired colors should describe a surface and its content. Reserve `muted` for enabled low-priority content and `disabled` for unavailable controls or content. Do not bypass an established semantic token layer with raw palette values in application code.

## Preserve Color Contrast

Treat foreground and background colors as a paired contract. Before reusing, replacing, or removing a shared color token, trace every consumer against its actual surface and interaction states; a color that passes on a light surface may fail on a dark, branded, image, gradient, or translucent surface.

Meet WCAG AA contrast at minimum: 4.5:1 for normal text, 3:1 for large text, and 3:1 for meaningful controls, focus indicators, icons, and graphical boundaries. Resolve transparent colors against the effective rendered background rather than comparing raw token values. For text over images or gradients, provide a sufficiently strong overlay or local surface that guarantees contrast across the complete content area.

Check default, hover, active, focus, selected, disabled, and open states. When a parent changes its background on interaction, update every child foreground that no longer passes. Decorative low-contrast text or graphics must be excluded from accessibility semantics and must not carry required information.

## Preserve Accessibility and Localization

Add appropriate accessibility attributes to icons and SVGs, including `aria-hidden` and `focusable` for decorative graphics. Give icon-only or ambiguous controls an accessible name, and keep image alternatives accurate.

Write toggle labels as the action or alternative state applied after activation rather than merely repeating the current state.

Keep equivalent interface copy consistent across locales unless a language-specific convention requires a difference. When adding or changing a localization key or variable, update every supported locale in the same change.
