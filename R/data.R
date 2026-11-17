# Shared source block for roxygen (not exported) --------------------------
# All three datasets derive from:
#   Neubauer, A. B., & Schmiedek, F. (2024). Approaching academic adjustment
#   on multiple time scales. Zeitschrift fuer Erziehungswissenschaft, 27(1),
#   147-168. doi:10.1007/s11618-023-01182-8
#   Data: https://osf.io/bhq3p  Codebook: https://osf.io/csfwg
#   Code: https://osf.io/84kdr/files  License: CC-BY 4.0

#' Person-level emotion ratings from an experience-sampling study
#'
#' @description
#' Mean ratings of ten emotions for 280 university students who took part in
#' a 14-day experience-sampling study (Neubauer & Schmiedek, 2024). Each
#' value is a student's mean rating of one emotion over all prompts, rounded
#' to a whole number and rescaled from the original 1-7 scale to 1-5 by
#' `round(1 + (x - 1) * 4 / 6)`. Students without a mean on every item of
#' [student_survey] were excluded.
#'
#' The data have one row per student and one column per emotion, the raw
#' response format read by [survey_snake()], [survey_sequence()] and
#' [sequential_dist()]. Because the rows keep each student's answers
#' together, correlations between items can be shown with
#' `survey_snake(arc_fill = "correlation")`. The same values form the `Emo_`
#' columns of [student_survey].
#'
#' @format A data frame with 280 rows (students) and 10 integer columns with
#'   values 1-5: `Happy`, `Afraid`, `Sad`, `Balanced`, `Exhausted`,
#'   `Cheerful`, `Worried`, `Lively`, `Angry`, `Relaxed`.
#'
#' @source
#' Neubauer, A. B., & Schmiedek, F. (2024). Approaching academic adjustment
#' on multiple time scales. *Zeitschrift fuer Erziehungswissenschaft*,
#' *27*(1), 147--168. \doi{10.1007/s11618-023-01182-8}
#'
#' Data: <https://osf.io/bhq3p> |
#' Codebook: <https://osf.io/csfwg> |
#' Code: <https://osf.io/84kdr/files> |
#' License: CC-BY 4.0
#'
#' @seealso [student_survey] for all 34 items; [ema_beeps] for the
#'   prompt-level data; [survey_snake()].
#'
#' @examples
#' survey_snake(ema_emotions, tick_shape = "bar", sort_by = "mean")
#' survey_snake(ema_emotions, arc_fill = "correlation")
"ema_emotions"

#' Person-level ratings of emotion, motivation, regulation and engagement
#'
#' @description
#' Mean ratings of 34 items for the 280 university students of
#' [ema_emotions], from the same 14-day experience-sampling study (Neubauer &
#' Schmiedek, 2024). Each value is a student's mean rating of one item over
#' all prompts, rounded to a whole number and rescaled from 1-7 to 1-5 by
#' `round(1 + (x - 1) * 4 / 6)`.
#'
#' The items belong to four constructs, marked by a column-name prefix, so
#' that `survey_snake(student_survey, facet = TRUE)` draws one panel per
#' construct:
#'
#' * `Emo_`: 10 emotion items: Happy, Afraid, Sad, Balanced, Exhausted,
#'   Cheerful, Worried, Lively, Angry, Relaxed.
#' * `Mot_`: 8 study motivation items: Disappointed, FeltBad, Important,
#'   Interesting, Compulsory, Proving, Understanding, Enjoyment.
#' * `Reg_`: 5 emotion regulation items: SeeGood, FocusGood, Suppression,
#'   ChangedFeeling, Rumination.
#' * `Eng_`: 11 study engagement items: Enjoy, WearingDown, Satisfied,
#'   DifficultReconcile, Interesting, Exhausted, OnlyNecessary, Energy,
#'   Identification, Expectations, ConsiderQuitting.
#'
#' @format A data frame with 280 rows (students) and 34 integer columns with
#'   values 1-5, named `<prefix>_<item>` as listed above.
#'
#' @source
#' Neubauer, A. B., & Schmiedek, F. (2024). Approaching academic adjustment
#' on multiple time scales. *Zeitschrift fuer Erziehungswissenschaft*,
#' *27*(1), 147--168. \doi{10.1007/s11618-023-01182-8}
#'
#' Data: <https://osf.io/bhq3p> |
#' Codebook: <https://osf.io/csfwg> |
#' Code: <https://osf.io/84kdr/files> |
#' License: CC-BY 4.0
#'
#' @seealso [ema_emotions] for the emotion items alone; [ema_beeps] for the
#'   prompt-level data; [survey_snake()] and its `facet` argument.
#'
#' @examples
#' survey_snake(student_survey, facet = TRUE, tick_shape = "bar",
#'              sort_by = "mean", facet_ncol = 2L)
"student_survey"

#' Prompt-level happiness and anger ratings from an experience-sampling study
#'
#' @description
#' All 11,474 answered prompts ("beeps") from a 14-day experience-sampling
#' study of 321 university students (Neubauer & Schmiedek, 2024). Each row is
#' one prompt with the participant, the study day, the time of the prompt and
#' the ratings of happiness and anger, rescaled from 1-7 to 1-5 by
#' `round(1 + (x - 1) * 4 / 6)`. Participants answered between 1 and 69
#' prompts; the 14 study days of one participant need not be consecutive
#' calendar days.
#'
#' The data are in long format. With the `var`, `day` and `timestamp`
#' arguments of [survey_snake()] each study day becomes a band and each
#' rating is placed at its time of day; the prompt times of one participant
#' can be shown with [activity_snake()].
#'
#' @format A data frame with 11,474 rows (prompts) and 5 columns:
#'   \describe{
#'     \item{`id`}{Character. Anonymised participant identifier.}
#'     \item{`day`}{Integer 1-14. Study day.}
#'     \item{`start_time`}{POSIXct (UTC). Time of the prompt, between April
#'       and July 2021.}
#'     \item{`happy`}{Integer 1-5. Rated happiness.}
#'     \item{`angry`}{Integer 1-5. Rated anger.}
#'   }
#'
#' @source
#' Neubauer, A. B., & Schmiedek, F. (2024). Approaching academic adjustment
#' on multiple time scales. *Zeitschrift fuer Erziehungswissenschaft*,
#' *27*(1), 147--168. \doi{10.1007/s11618-023-01182-8}
#'
#' Data: <https://osf.io/bhq3p> |
#' Codebook: <https://osf.io/csfwg> |
#' Code: <https://osf.io/84kdr/files> |
#' License: CC-BY 4.0
#'
#' @seealso [ema_emotions] and [student_survey] for person-level ratings;
#'   [survey_snake()]; [activity_snake()].
#'
#' @examples
#' # Anger over the 14 study days, each rating at its time of day
#' survey_snake(ema_beeps, var = "angry", day = "day",
#'              timestamp = "start_time")
#'
#' # Happiness per study day as stacked bars
#' survey_snake(ema_beeps, var = "happy", day = "day", tick_shape = "bar")
#'
#' # When one participant answered the prompts
#' activity_snake(subset(ema_beeps, id == "xcVDLRQOwn", select = start_time),
#'                show_total = FALSE, show_count = TRUE)
"ema_beeps"
