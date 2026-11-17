#' @description
#' `snakeplot` draws serpentine ("snake") plots: displays in which a long
#' ordered axis (days, time points, positions in a sequence or items of a
#' questionnaire) is folded into parallel bands joined by U-turns. The whole
#' axis fits in one panel, its order is kept, and neighbouring bands can be
#' compared directly. All plots are drawn with base R graphics.
#'
#' The package covers three kinds of data: event times and continuous
#' measurements within days, categorical state sequences, and responses to
#' rating items, including experience-sampling data collected several times
#' a day. Each plot function draws on the current graphics device; the
#' value it returns invisibly is described on its help page.
#'
#' @details
#' Every plot shares the same layout. Bands are stacked from top to bottom;
#' with `flow = "snake"` they alternate direction so that the axis runs on
#' through each U-turn, and with `flow = "natural"` every band reads in the
#' same direction, like lines of text. `start_from` chooses the side of the
#' first band. Most functions default to `"snake"`; [sequence_snake()] and
#' [timeline_snake()] default to `"natural"`.
#'
#' A serpentine changes the reading of distances. Positions at the ends of
#' adjacent bands are close on the page but far apart on the axis. In
#' [activity_snake()] and [line_snake()], points above one another in
#' adjacent bands share a time of day only when the bands read in the same
#' direction (`flow = "natural"`). Band labels and U-turn labels give the
#' position on the axis.
#'
#' @section Time within days:
#' [activity_snake()] shows event times, one band per day, as ticks or
#' blocks of their duration. [line_snake()] draws a continuous series as a
#' line through the days. [facet_snake()] draws one panel per group.
#'
#' @section Sequences:
#' [sequence_snake()] shows one long categorical sequence as colored blocks
#' along the path. [timeline_snake()] builds a monthly sequence from phases
#' with start and end dates, such as the positions in a career.
#' [multi_snake()] shows many sequences as a sequence index or state
#' distribution display (Gabadinho et al., 2011).
#'
#' @section Survey and experience-sampling data:
#' [survey_snake()] shows every response to each item as a tick, with the
#' item mean, optional correlations between adjacent items, and a mode for
#' experience-sampling data with one band per day. [survey_sequence()] and
#' [sequential_dist()] show one 100% stacked bar per item, with diverging
#' or single-hue colors (see Heiberger & Robbins, 2014, on stacked bars for
#' rating scales). [snake_palette()] and [snake_palettes] provide colors for
#' response levels.
#'
#' @section Data:
#' [ema_emotions], [student_survey] and [ema_beeps] come from a 14-day
#' experience-sampling study of university students (Neubauer & Schmiedek,
#' 2024).
#'
#' @references
#' Gabadinho, A., Ritschard, G., \enc{Müller}{Muller}, N. S., & Studer, M. (2011).
#' Analyzing and visualizing state sequences in R with TraMineR.
#' *Journal of Statistical Software*, 40(4), 1-37.
#' \doi{10.18637/jss.v040.i04}
#'
#' Heiberger, R. M., & Robbins, N. B. (2014). Design of diverging stacked bar
#' charts for Likert scales and other applications. *Journal of Statistical
#' Software*, 57(5), 1-32. \doi{10.18637/jss.v057.i05}
#'
#' Neubauer, A. B., & Schmiedek, F. (2024). Approaching academic adjustment
#' on multiple time scales. *Zeitschrift fuer Erziehungswissenschaft*,
#' *27*(1), 147-168. \doi{10.1007/s11618-023-01182-8}
#'
#' @keywords internal
#' @importFrom graphics lines par plot.new plot.window points polygon rect
#'   segments strwidth text
#' @importFrom grDevices col2rgb dev.off hsv pdf rgb
#' @importFrom stats cor median na.omit runif sd weighted.mean
"_PACKAGE"

## usethis namespace: start
## usethis namespace: end
NULL
