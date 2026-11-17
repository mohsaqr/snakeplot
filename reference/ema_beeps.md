# Prompt-level happiness and anger ratings from an experience-sampling study

`ema_beeps` is a dataset of all 11,474 answered prompts ("beeps") from a
14-day experience-sampling study of 321 university students (Neubauer &
Schmiedek, 2024). Each row is one prompt with the participant, the study
day, the time of the prompt and the ratings of happiness and anger,
rescaled from 1-7 to 1-5 by `round(1 + (x - 1) * 4 / 6)`. Participants
answered between 1 and 69 prompts; the 14 study days of one participant
need not be consecutive calendar days.

The data are in long format. With the `var`, `day` and `timestamp`
arguments of
[`survey_snake()`](https://pak.dynasite.org/Snakeplot/reference/survey_snake.md)
each study day becomes a band and each rating is placed at its time of
day; the prompt times of one participant can be shown with
[`activity_snake()`](https://pak.dynasite.org/Snakeplot/reference/activity_snake.md).

## Usage

``` r
ema_beeps
```

## Format

A data frame with 11,474 rows (prompts) and 5 columns:

- `id`:

  Character. Anonymised participant identifier.

- `day`:

  Integer 1-14. Study day.

- `start_time`:

  POSIXct (UTC). Time of the prompt, between April and July 2021.

- `happy`:

  Integer 1-5. Rated happiness.

- `angry`:

  Integer 1-5. Rated anger.

## Source

Neubauer, A. B., & Schmiedek, F. (2024). Approaching academic adjustment
on multiple time scales. *Zeitschrift fuer Erziehungswissenschaft*,
*27*(1), 147–168.
[doi:10.1007/s11618-023-01182-8](https://doi.org/10.1007/s11618-023-01182-8)

Data: <https://osf.io/bhq3p> \| Codebook: <https://osf.io/csfwg> \|
Code: <https://osf.io/84kdr/files> \| License: CC-BY 4.0

## See also

[ema_emotions](https://pak.dynasite.org/Snakeplot/reference/ema_emotions.md)
and
[student_survey](https://pak.dynasite.org/Snakeplot/reference/student_survey.md)
for person-level ratings;
[`survey_snake()`](https://pak.dynasite.org/Snakeplot/reference/survey_snake.md);
[`activity_snake()`](https://pak.dynasite.org/Snakeplot/reference/activity_snake.md).

## Examples

``` r
# Anger over the 14 study days, each rating at its time of day
survey_snake(ema_beeps, var = "angry", day = "day",
             timestamp = "start_time")


# Happiness per study day as stacked bars
survey_snake(ema_beeps, var = "happy", day = "day", tick_shape = "bar")


# When one participant answered the prompts
activity_snake(subset(ema_beeps, id == "xcVDLRQOwn", select = start_time),
               show_total = FALSE, show_count = TRUE)
```
