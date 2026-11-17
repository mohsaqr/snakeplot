# Implementation notes removed from `?survey_sequence` (2026-11-17)

Still true of R/survey_sequence.R; kept for maintainers.

- **input**: as for `survey_snake()` (`coerce_survey_input()`), including
  the raw-vs-counts heuristic (all columns categorical or whole numbers with
  <= 20 distinct values, and more than twice as many rows as distinct
  values). For raw responses, `levels` must match the data values; it
  cannot relabel them.
- **colours**: default `diverging_palette(k)` (anchors `#d4502a #e8967a
  #b8b8b8 #7ab0d4 #2c6faa`); `colors` indexed by level position.
- **sorting**: mean and net score as in `survey_snake()`.
- **segments** are always drawn from the left edge of the band, lowest level
  first, whatever the band's reading direction, unless `reverse_rtl = TRUE`
  and the band reads right to left.
- **percent labels**: rounded percentages, shown when the segment is at
  least `min_segment` plot units wide and the percentage is above 0; text
  white on dark segments (luminance < 0.5), `#333333` otherwise; cex 0.6.
- **arc_style = "gradient"**: midpoint of `colorRampPalette(c(end, start))`
  between the last level of the band before the U-turn and the first level
  of the next (reversed on right-to-left bands when `reverse_rtl`), at
  `arc_opacity`. `"neutral"`: `#999999` at `arc_opacity`.
- **end caps**: first level colour at the start of the first band, last
  level colour at the end of the last band, opacity 0.85.
- **legend**: square swatches, cex 0.7 (not adjustable); adds 15 to the
  bottom margin. A title adds 18 to the top margin.
