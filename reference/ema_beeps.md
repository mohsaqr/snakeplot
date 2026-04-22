# EMA Beep-Level Data (Daily Emotions)

All 11 474 experience-sampling beeps from a 14-day study of 321
university students. Each row is one beep with the participant's emotion
ratings and a timestamp. Use with the `var`/`day`/`timestamp` interface
of [`survey_snake`](https://saqr.me/Snakeplot/reference/survey_snake.md)
for daily snake plots.

## Usage

``` r
ema_beeps
```

## Format

A data.frame with 11 474 rows and 5 columns.

## Source

Neubauer, A. B., & Schmiedek, F. (2024). Approaching academic adjustment
on multiple time scales. *Zeitschrift fuer Erziehungswissenschaft*,
*27*(1), 147–168.
[doi:10.1007/s11618-023-01182-8](https://doi.org/10.1007/s11618-023-01182-8)

Data: <https://osf.io/bhq3p> \| Codebook: <https://osf.io/csfwg> \|
Code: <https://osf.io/84kdr/files> \| License: CC-BY 4.0

## Details

- `id`:

  Character. Anonymised participant identifier.

- `day`:

  Integer 1–14. Study day.

- `start_time`:

  POSIXct. Timestamp of the beep.

- `happy`:

  Integer 1–5. Self-reported happiness (rescaled from original 1–7).

- `angry`:

  Integer 1–5. Self-reported anger (rescaled from original 1–7).

## Examples

``` r
# Anger over 14 days, ticks by time-of-day
survey_snake(ema_beeps, var = "angry", day = "day",
             timestamp = "start_time")


# Happiness over 14 days, distribution bars
survey_snake(ema_beeps, var = "happy", day = "day",
             tick_shape = "bar")
```
