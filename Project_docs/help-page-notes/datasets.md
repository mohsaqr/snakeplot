# Implementation notes removed from `?ema_emotions`, `?student_survey` and `?ema_beeps` (2026-11-17)

From data-raw/esm_survey.R; kept for maintainers.

- Source: openESM dataset `0062_neubauer` (Neubauer & Schmiedek, 2024),
  CC-BY 4.0. Values of -1 ("not applicable") set to NA.
- **ema_emotions / student_survey**: person-level means of each of the 34
  items over all beeps, rounded to integers on the original 1-7 scale; only
  persons with a non-missing mean on all 34 items kept (280 of 321); then
  rescaled with `round(1 + (x - 1) * 4 / 6)`. `ema_emotions` is identical
  to the ten `Emo_` columns of `student_survey` with the prefix removed
  (checked 2026-11-17).
- **ema_beeps**: beeps with complete `id`, `day`, `start_time`, `happy`,
  `angry`; sorted by day and time; `day` recoded to consecutive integers
  1-14; `happy` and `angry` rescaled as above (beep level, no rounding of
  means). 11,474 rows, 321 participants, 1-69 beeps per participant.
  Timestamps are UTC and fall between 2021-04-12 and 2021-07-18; `day` is
  the study day, and one participant's 14 study days need not be
  consecutive calendar days (participant `xcVDLRQOwn`: 7 days in April,
  7 days from 31 May).
