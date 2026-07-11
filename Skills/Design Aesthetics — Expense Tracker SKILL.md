---
name: design-aesthetics
description: Use this skill whenever creating, editing, or reviewing any Flutter UI component, screen, widget, or custom painter in Expense Tracker. Covers glassmorphism specs, color system, typography, custom canvas animation, layout hierarchy, and micro-interactions. Trigger on any request touching lib/screens, lib/widgets, lib/theme, or any .dart file that builds visual UI.
---

# Design Aesthetics — Expense Tracker

Expense Tracker is a premium, portfolio-grade finance app. Every screen must look
deliberate, not templated. Nothing in this skill is optional polish, it is the
baseline bar for anything shipped in this codebase.

## Glassmorphism Spec

All elevated surfaces (cards, sheets, dialogs, the speedometer container) use this
exact recipe. Do not invent a new blur/opacity combination per screen.

- Backdrop blur: `sigmaX: 12, sigmaY: 12` via `BackdropFilter` + `ImageFilter.blur`
- Surface fill: `Colors.white.withOpacity(0.08)` on dark backgrounds,
  `Colors.white.withOpacity(0.55)` on light backgrounds
- Border: `1px`, `Colors.white.withOpacity(0.15)` (dark) or
  `Colors.black.withOpacity(0.06)` (light)
- Corner radius: `20.0` for cards, `28.0` for bottom sheets and modals, `999.0`
  (full pill) for chips and small badges
- Shadow: soft, never sharp. `BoxShadow(blurRadius: 24, spreadRadius: -4, color:
  Colors.black.withOpacity(0.25), offset: Offset(0, 8))`

Implement this once as a reusable `GlassContainer` widget in
`lib/widgets/common/glass_container.dart`. Never re-implement the blur/opacity
stack inline in a screen file. If a screen needs glass, it imports this widget.

## Color System

Colors are defined in HSL, not hardcoded hex, so gradients and dark/light variants
derive from a small set of base hues instead of drifting into inconsistent shades
across screens.

- Base palette lives in `lib/theme/app_colors.dart` as `HSLColor` constants
- Primary accent, success (income/under-budget), warning (near-limit), and danger
  (over-budget) each get a single base hue with lightness variants generated
  programmatically (`.withLightness(x)`), not four separate hardcoded colors
- Dark mode background: gradient from `hsl(230, 25%, 8%)` to `hsl(250, 30%, 12%)`
- Light mode background: gradient from `hsl(230, 40%, 97%)` to `hsl(250, 35%, 94%)`
- Never introduce a raw `Color(0xFF...)` literal directly in a screen file. Add it
  to `app_colors.dart` first, even if it is only used once.

## Typography

- Font families: `Outfit` for headings and numeric displays (amounts, the
  speedometer center value), `Inter` for body text, labels, and form fields
- Load both via `google_fonts` package, already a dependency, do not add a second
  font-loading mechanism
- Type scale (define once in `lib/theme/app_text_styles.dart`):
  - Display (speedometer amount): 48px, Outfit, weight 700
  - Headline (screen titles): 24px, Outfit, weight 600
  - Title (card headers): 16px, Outfit, weight 600
  - Body: 14px, Inter, weight 400
  - Caption (timestamps, metadata): 12px, Inter, weight 400, opacity 0.6
- Numeric values (currency amounts) always use tabular figures where the font
  supports it, so amounts in a list align vertically

## Custom Canvas Widgets (Speedometer and similar)

- Use `CustomPainter` with `shouldRepaint` correctly implemented, comparing actual
  field values, not always returning `true`. A speedometer that repaints every
  frame regardless of state change will visibly stutter on low-end devices.
- Animate value changes with `AnimationController` + `Tween<double>`, duration
  600-800ms, curve `Curves.easeOutCubic`. Never snap the needle/arc instantly to
  a new value.
- Gauge arc colors transition through the danger/warning/success hues from the
  color system as the value crosses thresholds, do not hardcode a fixed arc color.
- Any new custom-painted widget goes in `lib/widgets/canvas/`, one file per
  widget, with the painter class and its wrapping widget in the same file.

## Layout Hierarchy and Spacing

- Spacing scale is 4px-based: 4, 8, 12, 16, 24, 32, 48. No arbitrary padding
  values like `17.0` or `23.0`.
- Screen-level horizontal padding: 20px, consistent across every screen
- Card internal padding: 16px
- Vertical rhythm between sections on a screen: 24px minimum
- Respect `SafeArea` and account for the system status bar on every top-level
  screen, glass surfaces look broken when they bleed under system UI incorrectly

## Micro-interactions

- Every tappable element gets a pressed state, either `InkWell` with a subtle
  splash tuned to the glass aesthetic (low opacity, matches surface tint) or a
  scale-down animation to `0.97` on tap-down, reversing on tap-up
- List item insertion/removal (new transaction added) animates in with
  `AnimatedList` or a fade + slide, never appears instantly
- Success actions (transaction saved, budget goal met) get a brief, tasteful
  animation, not a full-screen celebration. A checkmark morph or a soft pulse on
  the affected widget is enough. Do not add confetti or anything that looks like
  a mobile game.

## Before Marking Any UI Task Complete

- Confirm the widget uses `GlassContainer`, `app_colors.dart`, and
  `app_text_styles.dart` rather than inline styling
- Confirm dark and light mode both render correctly, this app supports both
- Confirm no hardcoded spacing values outside the 4px scale
- Confirm any new animation has an explicit duration and curve, not framework
  defaults left unset
