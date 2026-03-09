# Learnings

### 2026-03-09
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
