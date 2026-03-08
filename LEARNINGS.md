# Learnings

### 2026-03-08
- [ESM auto-pivot] When building a wide data.frame from ESM data, `coerce_survey_input()` may not recognize it as raw responses due to the shape heuristic (`nrow > unique_values * 2`). Safer to tabulate directly into a counts matrix within the ESM pivot block.
- [ESM time positioning] `esm_time_info[[k]]$time_frac` is NULL when no timestamp column is provided. Must guard the ESM tick positioning branch to only activate when `time_frac` is not NULL, otherwise fall through to standard proportional zone rendering.
- [arc_fill "none" opacity] Using `alpha_col()` with `arc_opacity = 0.80` in two-tone arc mode creates visible three-color artifacts where the semi-transparent halves overlap or contrast against the background. Full opacity (no alpha) makes arcs match band colors seamlessly.
- [correlation arc coloring] Purely absolute `abs(r)` scaling saturates when all correlations are high (e.g., 0.89 vs 0.97 look identical). Purely relative scaling exaggerates tiny differences. Blended formula `0.85 * abs(r) + 0.15 * relative_rank` provides good differentiation while maintaining absolute meaning.
- [facet via par(mfrow)] `survey_snake()` calls `plot.new()` internally, which naturally advances to the next panel in a `par(mfrow)` grid. Use `match.call()` manipulation for recursive dispatch. `cl[["x"]] <- NULL` fails on non-existent list elements — must guard with `if ("x" %in% names(cl))`.
- [base R color complement] RGB complement: `255 - col2rgb(color)` gives the complementary color for negative correlation tinting.
