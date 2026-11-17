# Implementation notes removed from `?snake_palette` and `?snake_palettes` (2026-11-17)

Still true of R/colors.R; kept for maintainers.

- Unknown `name`: `stop("Unknown palette '<name>'. Available: ...")`,
  unclassed, with the call.
- `n == 7` returns the anchors unchanged; any other `n` uses
  `grDevices::colorRampPalette(anchors)(n)`. `n` is not validated.
- Palette descriptions (old help): classic diverging red-to-blue (Likert
  default); earth brown-to-teal; ocean coral-to-navy; sunset
  orange-to-indigo; berry rose-to-green; blues, greens, grays light-to-dark;
  warm cream-to-dark red; viridis yellow-green-blue-purple (seven colours
  from the viridis scale). By inspection of the hex codes (not checked
  against a source), the diverging anchors look like ColorBrewer RdBu,
  BrBG, RdYlBu, PuOr and PiYG with a grey midpoint, and blues/greens/grays
  like ColorBrewer Blues, Greens and Greys.
- None of the palettes is the Okabe-Ito palette; the plot functions'
  defaults (`diverging_palette()`, `sequential_palette()`, the Set2-like
  state palette and `timeline_palette()`) are separate from
  `snake_palettes`.
