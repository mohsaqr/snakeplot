# Implementation notes removed from `?multi_snake` (2026-11-17)

Still true of R/multi_snake.R; kept for maintainers.

- **input**: a data frame is converted with `as.matrix()`; storage mode is
  set to character. `states = NULL` uses `unique(as.vector(sequences))`
  without NA, i.e. first appearance reading column by column.
- **colours**: `resolve_state_colors()` (R/sequence_snake.R). Default
  palette (Set2-like): `#66C2A5 #FC8D62 #8DA0CB #E78AC3 #A6D854 #FFD92F
  #E5C494 #FB8072 #E41A1C #377EB8 #4DAF4A #984EA3`, recycled. States
  missing from a named `colors` vector are drawn `#CCCCCC`.
- **missing cells**: NA cells are not counted in distribution bars; in the
  index display their tick gets colour NA (not drawn).
- **sort_by**: `order()` on a factor with levels `states`, so ties keep
  input order. `"freq"` uses each row's modal state (`which.max` of the
  table; first state in `states` order wins ties). `"entropy"` uses
  natural-log Shannon entropy, ascending.
- **rows**: `max(1, ceiling(n_time / 11))`.
- **allocation of time points to the path**: time points are allocated to
  the interleaved band/arc segments in proportion to path length
  (`allocate_blocks()`, largest-remainder method; each segment gets at least
  one when there are enough points). In `multi_snake()` arc segments are
  then drawn as a neutral `#E0E0E0` polygon and the time points allocated to
  them are **not drawn**. Example: a 50 x 30 matrix with 3 rows draws time
  points 1-9, 12-20, 23-30; points 10, 11, 21, 22 are not shown (verified by
  tracing `draw_multi_band_blocks()` on 2026-11-17). The old help page said
  time points flow "through bands and arcs". The new page documents the
  code's behaviour; this is likely a bug (sequence_snake() draws blocks in
  the arcs).
- **index display**: each block has a `#F5F5F5` background and one tick per
  sequence of width `block width / n_seq`.
- **distribution display**: percentages (white, cex 0.4, bold) are printed
  in segments wider than 12% of the block.
- **end caps**: `#E8E8E8`.
- **band labels**: `"<first>-<last>"` time labels of the band (column names
  if present, else positions), cex 0.55, `#555555`.
- **legend**: one swatch per state plus `"n = <n> sequences"` at the right.
- **margins**: the legend adds 15 to the bottom margin; a title adds 18 to
  the top.
- **no orientation/start_from arguments**: always horizontal, first band
  from the left.
