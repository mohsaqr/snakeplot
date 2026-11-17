# snakeplot: Serpentine Plots for Long Timeline, Sequential and Survey Data

snakeplot draws serpentine ("snake") plots: displays in which a long
ordered axis (days, time points, positions in a sequence or items of a
questionnaire) is folded into parallel bands joined by U-turns. The
whole axis fits in one panel, its order is kept, and neighbouring bands
can be compared directly. All plots are drawn with base R graphics.

The package covers three kinds of data: event times and continuous
measurements within days, categorical state sequences, and responses to
rating items, including experience-sampling data collected several times
a day. Each plot function draws on the current graphics device; the
value it returns invisibly is described on its help page.

## Details

Every plot shares the same layout. Bands are stacked from top to bottom;
with `flow = "snake"` they alternate direction so that the axis runs on
through each U-turn, and with `flow = "natural"` every band reads in the
same direction, like lines of text. `start_from` chooses the side of the
first band. Most functions default to `"snake"`;
[`sequence_snake()`](https://pak.dynasite.org/Snakeplot/reference/sequence_snake.md)
and
[`timeline_snake()`](https://pak.dynasite.org/Snakeplot/reference/timeline_snake.md)
default to `"natural"`.

A serpentine changes the reading of distances. Positions at the ends of
adjacent bands are close on the page but far apart on the axis. In
[`activity_snake()`](https://pak.dynasite.org/Snakeplot/reference/activity_snake.md)
and
[`line_snake()`](https://pak.dynasite.org/Snakeplot/reference/line_snake.md),
points above one another in adjacent bands share a time of day only when
the bands read in the same direction (`flow = "natural"`). Band labels
and U-turn labels give the position on the axis.

## Time within days

[`activity_snake()`](https://pak.dynasite.org/Snakeplot/reference/activity_snake.md)
shows event times, one band per day, as ticks or blocks of their
duration.
[`line_snake()`](https://pak.dynasite.org/Snakeplot/reference/line_snake.md)
draws a continuous series as a line through the days.
[`facet_snake()`](https://pak.dynasite.org/Snakeplot/reference/facet_snake.md)
draws one panel per group.

## Sequences

[`sequence_snake()`](https://pak.dynasite.org/Snakeplot/reference/sequence_snake.md)
shows one long categorical sequence as colored blocks along the path.
[`timeline_snake()`](https://pak.dynasite.org/Snakeplot/reference/timeline_snake.md)
builds a monthly sequence from phases with start and end dates, such as
the positions in a career.
[`multi_snake()`](https://pak.dynasite.org/Snakeplot/reference/multi_snake.md)
shows many sequences as a sequence index or state distribution display
(Gabadinho et al., 2011).

## Survey and experience-sampling data

[`survey_snake()`](https://pak.dynasite.org/Snakeplot/reference/survey_snake.md)
shows every response to each item as a tick, with the item mean,
optional correlations between adjacent items, and a mode for
experience-sampling data with one band per day.
[`survey_sequence()`](https://pak.dynasite.org/Snakeplot/reference/survey_sequence.md)
and
[`sequential_dist()`](https://pak.dynasite.org/Snakeplot/reference/sequential_dist.md)
show one 100% stacked bar per item, with diverging or single-hue colors
(see Heiberger & Robbins, 2014, on stacked bars for rating scales).
[`snake_palette()`](https://pak.dynasite.org/Snakeplot/reference/snake_palette.md)
and
[snake_palettes](https://pak.dynasite.org/Snakeplot/reference/snake_palettes.md)
provide colors for response levels.

## Data

[ema_emotions](https://pak.dynasite.org/Snakeplot/reference/ema_emotions.md),
[student_survey](https://pak.dynasite.org/Snakeplot/reference/student_survey.md)
and
[ema_beeps](https://pak.dynasite.org/Snakeplot/reference/ema_beeps.md)
come from a 14-day experience-sampling study of university students
(Neubauer & Schmiedek, 2024).

## References

Gabadinho, A., Ritschard, G., Müller, N. S., & Studer, M. (2011).
Analyzing and visualizing state sequences in R with TraMineR. *Journal
of Statistical Software*, 40(4), 1-37.
[doi:10.18637/jss.v040.i04](https://doi.org/10.18637/jss.v040.i04)

Heiberger, R. M., & Robbins, N. B. (2014). Design of diverging stacked
bar charts for Likert scales and other applications. *Journal of
Statistical Software*, 57(5), 1-32.
[doi:10.18637/jss.v057.i05](https://doi.org/10.18637/jss.v057.i05)

Neubauer, A. B., & Schmiedek, F. (2024). Approaching academic adjustment
on multiple time scales. *Zeitschrift fuer Erziehungswissenschaft*,
*27*(1), 147-168.
[doi:10.1007/s11618-023-01182-8](https://doi.org/10.1007/s11618-023-01182-8)

## See also

Useful links:

- <https://github.com/mohsaqr/snakeplot>

- <https://pak.dynasite.org/Snakeplot/>

- Report bugs at <https://github.com/mohsaqr/snakeplot/issues>

## Author

**Maintainer**: Mohammed Saqr <saqr@saqr.me> \[copyright holder\]

Authors:

- Mohammed Saqr <saqr@saqr.me> \[copyright holder\]

- Sonsoles Lopez-Pernas
