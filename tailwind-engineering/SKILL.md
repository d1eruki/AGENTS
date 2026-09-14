---
name: tailwind-engineering
description: Implement, review, or diagnose Tailwind CSS styling, including utilities, variants, theme tokens, responsive behavior, dynamic classes, and justified custom CSS. Use only when the target project actually uses Tailwind CSS.
---

# Tailwind Engineering

## Establish the Active Tailwind Setup

Inspect the installed Tailwind version, CSS entrypoints, configuration, plugins, theme definitions, and nearby templates before editing. Follow the project's active configuration style and do not assume that syntax or defaults from another Tailwind release apply.

## Prefer Utilities and Existing Tokens

Prefer built-in utilities, project theme tokens, CSS variables, and variants over custom CSS or hardcoded values. Use canonical utilities when Tailwind directly covers the requirement, and do not duplicate framework defaults for breakpoints, spacing, colors, typography, shadows, radii, transitions, or stacking values.

Implement layout, spacing, sizing, colors, typography, responsive behavior, borders, and shadows with utilities in templates when that is the established project approach. Use normal sizing, padding, flex, and grid before introducing complex arbitrary calculations.

Prefer whole numeric values in authored utilities and theme tokens. Avoid fractional values when whole values can express the intended design without meaningful loss. When a fractional value is genuinely necessary, use no more than one digit after the decimal point.

Treat color utilities as foreground/background pairs. Before replacing or consolidating a semantic color token, inspect every consumer and its default and variant-driven surfaces. Preserve WCAG AA contrast: 4.5:1 for normal text, 3:1 for large text, and 3:1 for meaningful controls, focus indicators, icons, and graphical boundaries. Resolve opacity modifiers such as `text-*/70` against the computed surface, and ensure child colors change with parent `hover:`, `focus:`, `active:`, `selected`, or dark-mode backgrounds when needed.

For text over images or gradients, use an overlay or local surface strong enough to guarantee the required contrast across the entire text area. Do not assume a utility is accessible merely because it uses a semantic token.

When the project has a semantic color-token layer, consume its established utilities instead of raw palette classes or lower-level values. Keep state styling in the component through supported variants when possible.

## Centralize Semantic Typography

When a Tailwind project has a defined typography system, expose its actual semantic roles as theme variables and utilities, such as `--text-h1` with `text-h1` or `--text-body` with `text-body`. Derive the names and number of roles from the design instead of requiring a fixed list.

Use values from the active Tailwind type scale when they match the design. Keep responsive font-size changes in the shared token or theme layer so component markup consumes one semantic class rather than repeating combinations such as `text-*`, `sm:text-*`, and `wide:text-*`.

Once semantic typography utilities exist, use them throughout components instead of direct size utilities. Change a shared size centrally. Do not create a new token or shrink text merely to compensate for an incorrect grid, container width, spacing, or wrapping behavior.

## Keep Classes Discoverable

Use complete class names in source or explicit mappings recognized by the project's Tailwind build. Do not construct class fragments dynamically when that prevents the compiler from discovering the resulting utilities; use an established safelist only when explicit mappings are insufficient.

## Justify Custom Extensions

Add an arbitrary value, custom utility, theme token, plugin, or component-specific selector only when built-in utilities and existing project tokens cannot express the requirement. Identify the missing Tailwind capability, keep the exception local, and avoid extending custom CSS when variants or utilities already cover the affected state.
