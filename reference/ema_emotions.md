# Person-level emotion ratings from an experience-sampling study

`ema_emotions` is a dataset of the mean ratings of ten emotions for 280
university students who took part in a 14-day experience-sampling study
(Neubauer & Schmiedek, 2024). Each value is a student's mean rating of
one emotion over all prompts, rounded to a whole number and rescaled
from the original 1-7 scale to 1-5 by `round(1 + (x - 1) * 4 / 6)`.
Students without a mean on every item of
[student_survey](https://pak.dynasite.org/Snakeplot/reference/student_survey.md)
were excluded.

The data have one row per student and one column per emotion, the raw
response format read by
[`survey_snake()`](https://pak.dynasite.org/Snakeplot/reference/survey_snake.md),
[`survey_sequence()`](https://pak.dynasite.org/Snakeplot/reference/survey_sequence.md)
and
[`sequential_dist()`](https://pak.dynasite.org/Snakeplot/reference/sequential_dist.md).
Because the rows keep each student's answers together, correlations
between items can be shown with
`survey_snake(arc_fill = "correlation")`. The same values form the
`Emo_` columns of
[student_survey](https://pak.dynasite.org/Snakeplot/reference/student_survey.md).

## Usage

``` r
ema_emotions
```

## Format

A data frame with 280 rows (students) and 10 integer columns with values
1-5: `Happy`, `Afraid`, `Sad`, `Balanced`, `Exhausted`, `Cheerful`,
`Worried`, `Lively`, `Angry`, `Relaxed`.

## Source

Neubauer, A. B., & Schmiedek, F. (2024). Approaching academic adjustment
on multiple time scales. *Zeitschrift fuer Erziehungswissenschaft*,
*27*(1), 147–168.
[doi:10.1007/s11618-023-01182-8](https://doi.org/10.1007/s11618-023-01182-8)

Data: <https://osf.io/bhq3p> \| Codebook: <https://osf.io/csfwg> \|
Code: <https://osf.io/84kdr/files> \| License: CC-BY 4.0

## See also

[student_survey](https://pak.dynasite.org/Snakeplot/reference/student_survey.md)
for all 34 items;
[ema_beeps](https://pak.dynasite.org/Snakeplot/reference/ema_beeps.md)
for the prompt-level data;
[`survey_snake()`](https://pak.dynasite.org/Snakeplot/reference/survey_snake.md).

## Examples

``` r
survey_snake(ema_emotions, tick_shape = "bar", sort_by = "mean")

survey_snake(ema_emotions, arc_fill = "correlation")
```
