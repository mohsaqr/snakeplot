# Shared source block for roxygen (not exported) --------------------------
# All three datasets derive from:
#   Neubauer, A. B., & Schmiedek, F. (2024). Approaching academic adjustment
#   on multiple time scales. Zeitschrift fuer Erziehungswissenschaft, 27(1),
#   147-168. doi:10.1007/s11618-023-01182-8
#   Data: https://osf.io/bhq3p  Codebook: https://osf.io/csfwg
#   Code: https://osf.io/84kdr/files  License: CC-BY 4.0

#' EMA Emotion Ratings (Person-Level)
#'
#' Person-level mean emotion ratings (rounded to integers) from a 14-day
#' experience sampling study of 280 university students. Ten emotion items
#' measured on a 1--7 Likert scale. Ready to pass directly to
#' \code{\link{survey_snake}}.
#'
#' @format A data.frame with 280 rows and 10 columns (integers 1--7):
#'   Happy, Afraid, Sad, Balanced, Exhausted, Cheerful, Worried, Lively,
#'   Angry, Relaxed.
#'
#' @source
#' Neubauer, A. B., & Schmiedek, F. (2024). Approaching academic adjustment
#' on multiple time scales. \emph{Zeitschrift fuer Erziehungswissenschaft},
#' \emph{27}(1), 147--168. \doi{10.1007/s11618-023-01182-8}
#'
#' Data: \url{https://osf.io/bhq3p} |
#' Codebook: \url{https://osf.io/csfwg} |
#' Code: \url{https://osf.io/84kdr/files} |
#' License: CC-BY 4.0
#'
#' @examples
#' survey_snake(ema_emotions, tick_shape = "bar", sort_by = "mean")
"ema_emotions"

#' Student Survey (Cross-Sectional, Multi-Construct)
#'
#' Person-level mean scores (rounded to integers) from a 14-day experience
#' sampling study of 280 university students. Contains 34 items across four
#' construct groups, each on a 1--7 Likert scale. Column name prefixes
#' enable automatic faceting with
#' \code{survey_snake(student_survey, facet = TRUE)}.
#'
#' \describe{
#'   \item{\code{Emo_}}{10 emotion items: Happy, Afraid, Sad, Balanced,
#'     Exhausted, Cheerful, Worried, Lively, Angry, Relaxed.}
#'   \item{\code{Mot_}}{8 study motivation items: Disappointed, FeltBad,
#'     Important, Interesting, Compulsory, Proving, Understanding, Enjoyment.}
#'   \item{\code{Reg_}}{5 emotion regulation items: SeeGood, FocusGood,
#'     Suppression, ChangedFeeling, Rumination.}
#'   \item{\code{Eng_}}{11 study engagement items: Enjoy, WearingDown,
#'     Satisfied, DifficultReconcile, Interesting, Exhausted, OnlyNecessary,
#'     Energy, Identification, Expectations, ConsiderQuitting.}
#' }
#'
#' @format A data.frame with 280 rows and 34 integer columns (values 1--7).
#'
#' @source
#' Neubauer, A. B., & Schmiedek, F. (2024). Approaching academic adjustment
#' on multiple time scales. \emph{Zeitschrift fuer Erziehungswissenschaft},
#' \emph{27}(1), 147--168. \doi{10.1007/s11618-023-01182-8}
#'
#' Data: \url{https://osf.io/bhq3p} |
#' Codebook: \url{https://osf.io/csfwg} |
#' Code: \url{https://osf.io/84kdr/files} |
#' License: CC-BY 4.0
#'
#' @examples
#' survey_snake(student_survey, facet = TRUE, tick_shape = "bar",
#'              sort_by = "mean", facet_ncol = 2L)
"student_survey"

#' EMA Beep-Level Data (Daily Emotions)
#'
#' All 11 474 experience-sampling beeps from a 14-day study of 321
#' university students. Each row is one beep with the participant's emotion
#' ratings and a timestamp. Use with the \code{var}/\code{day}/\code{timestamp}
#' interface of \code{\link{survey_snake}} for daily snake plots.
#'
#' \describe{
#'   \item{\code{id}}{Character. Anonymised participant identifier.}
#'   \item{\code{day}}{Integer 1--14. Study day.}
#'   \item{\code{start_time}}{POSIXct. Timestamp of the beep.}
#'   \item{\code{happy}}{Integer 1--7. Self-reported happiness.}
#'   \item{\code{angry}}{Integer 1--7. Self-reported anger.}
#' }
#'
#' @format A data.frame with 11 474 rows and 5 columns.
#'
#' @source
#' Neubauer, A. B., & Schmiedek, F. (2024). Approaching academic adjustment
#' on multiple time scales. \emph{Zeitschrift fuer Erziehungswissenschaft},
#' \emph{27}(1), 147--168. \doi{10.1007/s11618-023-01182-8}
#'
#' Data: \url{https://osf.io/bhq3p} |
#' Codebook: \url{https://osf.io/csfwg} |
#' Code: \url{https://osf.io/84kdr/files} |
#' License: CC-BY 4.0
#'
#' @examples
#' # Anger over 14 days, ticks by time-of-day
#' survey_snake(ema_beeps, var = "angry", day = "day",
#'              timestamp = "start_time")
#'
#' # Happiness over 14 days, distribution bars
#' survey_snake(ema_beeps, var = "happy", day = "day",
#'              tick_shape = "bar")
"ema_beeps"
