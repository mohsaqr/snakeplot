# Student Survey (Cross-Sectional, Multi-Construct)

Person-level mean scores (rounded to integers) from a 14-day experience
sampling study of 280 university students. Contains 34 items across four
construct groups, rescaled to a 1–5 Likert scale (original 1–7). Column
name prefixes enable automatic faceting with
`survey_snake(student_survey, facet = TRUE)`.

## Usage

``` r
student_survey
```

## Format

A data.frame with 280 rows and 34 integer columns (values 1–5).

## Source

Neubauer, A. B., & Schmiedek, F. (2024). Approaching academic adjustment
on multiple time scales. *Zeitschrift fuer Erziehungswissenschaft*,
*27*(1), 147–168.
[doi:10.1007/s11618-023-01182-8](https://doi.org/10.1007/s11618-023-01182-8)

Data: <https://osf.io/bhq3p> \| Codebook: <https://osf.io/csfwg> \|
Code: <https://osf.io/84kdr/files> \| License: CC-BY 4.0

## Details

- `Emo_`:

  10 emotion items: Happy, Afraid, Sad, Balanced, Exhausted, Cheerful,
  Worried, Lively, Angry, Relaxed.

- `Mot_`:

  8 study motivation items: Disappointed, FeltBad, Important,
  Interesting, Compulsory, Proving, Understanding, Enjoyment.

- `Reg_`:

  5 emotion regulation items: SeeGood, FocusGood, Suppression,
  ChangedFeeling, Rumination.

- `Eng_`:

  11 study engagement items: Enjoy, WearingDown, Satisfied,
  DifficultReconcile, Interesting, Exhausted, OnlyNecessary, Energy,
  Identification, Expectations, ConsiderQuitting.

## Examples

``` r
survey_snake(student_survey, facet = TRUE, tick_shape = "bar",
             sort_by = "mean", facet_ncol = 2L)
```
