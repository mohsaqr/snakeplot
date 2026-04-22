# EMA Emotion Ratings (Person-Level)

Person-level mean emotion ratings (rounded to integers) from a 14-day
experience sampling study of 280 university students. Ten emotion items
rescaled to a 1–5 Likert scale (original study used 1–7; rescaled via
linear transformation for simplicity). Ready to pass directly to
[`survey_snake`](https://saqr.me/Snakeplot/reference/survey_snake.md).

## Usage

``` r
ema_emotions
```

## Format

A data.frame with 280 rows and 10 columns (integers 1–5): Happy, Afraid,
Sad, Balanced, Exhausted, Cheerful, Worried, Lively, Angry, Relaxed.

## Source

Neubauer, A. B., & Schmiedek, F. (2024). Approaching academic adjustment
on multiple time scales. *Zeitschrift fuer Erziehungswissenschaft*,
*27*(1), 147–168.
[doi:10.1007/s11618-023-01182-8](https://doi.org/10.1007/s11618-023-01182-8)

Data: <https://osf.io/bhq3p> \| Codebook: <https://osf.io/csfwg> \|
Code: <https://osf.io/84kdr/files> \| License: CC-BY 4.0

## Examples

``` r
survey_snake(ema_emotions, tick_shape = "bar", sort_by = "mean")
```
