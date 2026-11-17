# Implementation notes removed from `?sequence_snake` (2026-11-17)

Still true of R/sequence_snake.R and R/utils.R; kept for maintainers.

- **input coercion** (`coerce_sequence_input()`): a single string
  containing a comma is split on `",\\s*"` and trimmed; a data frame uses
  its first character or factor column with the message
  `Using column '<name>' as sequence` (error if there is none); a list is
  unlisted; everything is converted with `as.character()`. NA values are
  dropped with a warning `Dropped <n> NA values from sequence`; an empty
  result is an error.
- **validation**: states in `sequence` but not in `states` are an error
  listing them. `block_labels` must have `length(sequence)` elements;
  `band_labels` must have `rows` elements. All errors are unclassed.
- **colours**: default palette (Set2-like) `#66C2A5 #FC8D62 #8DA0CB
  #E78AC3 #A6D854 #FFD92F #E5C494 #FB8072 #E41A1C #377EB8 #4DAF4A
  #984EA3`, recycled; states missing from a named `colors` vector are drawn
  `#CCCCCC`.
- **rows**: `max(1, ceiling(n / 11))`.
- **allocation**: positions are allocated to the interleaved band and arc
  segments in proportion to path length (largest remainder; each segment
  gets at least one block when there are enough positions). Blocks in arcs
  are drawn as wedge sectors of the arc.
- **block_labels**: switch on `show_numbers` unless ruler ticks are on;
  with block-boundary ticks (no `tick_labels`) the labels are drawn below
  each block.
- **transition labels**: without `transition_pos`, placed at the
  boundaries of runs (`rle()`), the first `min(n_changes, n_labels)`
  changes. With `transition_pos`, placed at interpolated fractional block
  positions along the path, first `min(length(transition_pos),
  length(transition_labels))`.
- **ruler ticks**: with `tick_labels`, `length(tick_labels)` equal
  intervals per band, internal boundaries ticked above and below, labels
  centred under each interval, `lwd = 0.6`. Without, ticks at internal block
  boundaries, `lwd = 0.8`.
- **band labels**: centred in the gap below each band (last band: half a
  gap below), drawn with `tick_size` and `tick_color`.
- **rug style**: band background `#F5F5F5`, arcs and end caps `#EBEBEB`,
  range labels `#999999`. `band_color` is not used anywhere (rug bands are
  always `#F5F5F5`). Jitter uses `runif()` with no seed handling.
- **block style**: arcs underlaid `#E0E0E0`; end caps take the colour of the
  first/last state.
- **orientation**: not checked with `match.arg()`. With `"vertical"` the
  layout turns bands into columns, but `band_block_x()` divides each column
  along x, so blocks become vertical stripes across the column rather than
  stacking along it (checked visually on 2026-11-17). The help page
  recommends horizontal.
- **title**: drawn at `margin["top"] / 2`, cex 1.2.
- **return**: `invisible(NULL)`.
