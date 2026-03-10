# Learnings

### 2026-03-10
- [flow parameter naming] `flow="snake"` = boustrophedon (alternating direction). `flow="natural"` = all bands same direction (like a folded ribbon laid flat, consistent reading order). Same meaning in EVERY function — no special cases per function. Do NOT reverse these meanings.
- [flow defaults] Only `timeline_snake()` and `sequence_snake()` default to `flow="natural"`. All other functions (`activity_snake`, `survey_snake`, `line_snake`, `survey_sequence`, `multi_snake`) default to `flow="snake"`. All functions accept both values.
- [direction vs read_direction] `bands$direction` controls arc geometry (always alternates). `bands$read_direction` controls content/block ordering within bands. In snake mode they're the same; in natural mode `read_direction` is uniform while `direction` still alternates. End caps follow `direction`, content follows `read_direction`.

### 2026-03-09
- [cor zero-SD] `stats::cor()` warns when standard deviation is zero (constant data). Guard with `sd() > 0` check before calling `cor()`. Add `sd` to `@importFrom stats`.
- [vignette fig.height] User strongly dislikes tall/thick plots. Default fig.height=5 (from setup chunk) is fine for most. Don't increase unless explicitly asked. Activity plots use fig.height=6.
- [parse_time year validation] `strptime` with `%Y/%m/%d` on "15/01/2024" happily treats "15" as year 0015. Must validate parsed years are in 1900-2100 range before accepting a format match.
- [parse_time YYYY-MM] `strptime` cannot handle `%Y-%m` without a day. Must pre-process "2024-01" → "2024-01-01" before the format loop.
- [numeric start column] `coerce_activity_input()` must NOT parse numeric `start` columns as Unix timestamps — they represent minutes-from-midnight in activity_snake context. Only parse character columns via `parse_time()`.
- [coerce_sequence_input NA] Changed from hard error on NAs to warning + drop. This is more user-friendly for messy data. Updated existing test from `expect_error` to `expect_warning`.
- [timeline label overlap] State labels inside bands must skip drawing when the run is too narrow (check `strwidth`). Transition labels go at bottom edge of band (28% from bottom), not centered — avoids overlap with state names. Band year labels go centered in the gap between bands. `timeline_snake` needs `band_gap = 30` (not 18) to fit year labels.
- [vignette short examples] Users hate snake plots with only 1-2 rows — "they are not snakes". All vignette examples must have enough data for 3+ rows.
- [rug style] Dark ribbon background (`draw_ribbon()`) creates thick visible border on rug ticks — user strongly dislikes. Use light `#F5F5F5` band background + `#EBEBEB` arcs/end caps instead.
- [rug jitter] High jitter (0.8) makes rug look like a distribution/scatter plot. Subtle (0.3) is better but user still prefers no jitter. Best for ~100 events; at 1000 events block style is cleaner.
- [proportional distribution] No new function needed — just sort input by frequency before calling `sequence_snake()`. User explicitly rejected `multi_snake()` as unnecessary.
- [multi_snake rejection] User's reasoning: for single sequences use `sequence_snake()`, for proportional distribution of multiple sequences use `survey_sequence()` with tabulated counts. No need for a hybrid.

### 2026-03-08
- [ESM auto-pivot] When building a wide data.frame from ESM data, `coerce_survey_input()` may not recognize it as raw responses due to the shape heuristic (`nrow > unique_values * 2`). Safer to tabulate directly into a counts matrix within the ESM pivot block.
- [ESM time positioning] `esm_time_info[[k]]$time_frac` is NULL when no timestamp column is provided. Must guard the ESM tick positioning branch to only activate when `time_frac` is not NULL, otherwise fall through to standard proportional zone rendering.
- [arc_fill "none" opacity] Using `alpha_col()` with `arc_opacity = 0.80` in two-tone arc mode creates visible three-color artifacts where the semi-transparent halves overlap or contrast against the background. Full opacity (no alpha) makes arcs match band colors seamlessly.
- [correlation arc coloring] Purely absolute `abs(r)` scaling saturates when all correlations are high (e.g., 0.89 vs 0.97 look identical). Purely relative scaling exaggerates tiny differences. Blended formula `0.85 * abs(r) + 0.15 * relative_rank` provides good differentiation while maintaining absolute meaning.
- [facet via par(mfrow)] `survey_snake()` calls `plot.new()` internally, which naturally advances to the next panel in a `par(mfrow)` grid. Use `match.call()` manipulation for recursive dispatch. `cl[["x"]] <- NULL` fails on non-existent list elements — must guard with `if ("x" %in% names(cl))`.
- [base R color complement] RGB complement: `255 - col2rgb(color)` gives the complementary color for negative correlation tinting.
