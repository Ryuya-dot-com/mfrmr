# Review response-time patterns outside the MFRM likelihood

Build a descriptive response-time review table from the same long-format
rating-event data used by
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).
This helper does not fit a joint response-time model and does not change
MFRM estimates. It summarizes response-time distributions,
distributional rapid/slow flags, and person / facet / score-level
response-time patterns for screening and reporting context.

## Usage

``` r
response_time_review(
  data,
  person,
  facets = NULL,
  time,
  score = NULL,
  time_unit = "seconds",
  min_time = 0,
  rapid_threshold = NULL,
  slow_threshold = NULL,
  rapid_quantile = 0.05,
  slow_quantile = 0.95,
  rapid_rate_warn = 0.25,
  slow_rate_warn = 0.25,
  min_n_flag = 3L
)
```

## Arguments

- data:

  A data.frame in long format with one row per observed rating event.

- person:

  Column name for the person identifier.

- facets:

  Optional character vector of facet columns to summarize.

- time:

  Column name containing positive response times.

- score:

  Optional ordered-score column. When supplied, score-level
  response-time summaries are returned.

- time_unit:

  Label for the response-time unit, such as `"seconds"`.

- min_time:

  Minimum valid response time. Values must be strictly greater than this
  threshold; default 0.

- rapid_threshold:

  Optional numeric response-time cutoff for rapid responses. When
  `NULL`, it is estimated from `rapid_quantile`.

- slow_threshold:

  Optional numeric response-time cutoff for slow responses. When `NULL`,
  it is estimated from `slow_quantile`.

- rapid_quantile:

  Quantile used when `rapid_threshold = NULL`.

- slow_quantile:

  Quantile used when `slow_threshold = NULL`.

- rapid_rate_warn:

  Group-level rapid-response rate that creates a descriptive flag;
  default 0.25.

- slow_rate_warn:

  Group-level slow-response rate that creates a descriptive flag;
  default 0.25.

- min_n_flag:

  Minimum group size before rapid/slow rates are flagged; default 3.

## Value

An object of class `mfrm_response_time_review`, a list with `overview`,
`thresholds`, `observations`, `person_summary`, `facet_summary`,
`score_summary`, `flags`, and `notes`.

## Details

Supply one row per timed event. A respondent's production time must not
be repeated for every rater or criterion that scores that response;
rater scoring time is a different observation. This helper does not
model repeated events, censoring or a speed-accuracy relationship.

Numeric factor labels are interpreted as times, not factor codes. Group
summaries retain `InputRows`, valid timed rows (`N`) and `ExcludedRows`.
Rates describe valid rows only; groups with no valid times remain
present with unavailable statistics. Missing facet or score labels are
omitted from that grouping. Sample quantiles and user-specified cutoffs
are descriptive; they do not diagnose rapid guessing, effort or rater
quality. Equal cutoffs can flag the same event in both tails when times
are tied. `FlaggedGroups` counts distinct groups, while `Flags` counts
rapid/slow rule crossings. Recreate older reviews from the original
timing data before summary or plotting; no MFRM refit is needed.

## See also

[`plot_response_time_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_response_time_review.md),
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md),
[`mfrmr_output_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_output_guide.md)

## Examples

``` r
toy <- load_mfrmr_data("example_core")
toy$ResponseTime <- 12 + as.numeric(factor(toy$Person)) * 0.4 +
  as.numeric(toy$Score)
rt <- response_time_review(
  toy,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  time = "ResponseTime"
)
summary(rt)
#> mfrmr response-time review
#> 
#>  Rows ValidRows DroppedRows Persons Facets   TimeColumn ScoreColumn TimeUnit
#>   768       768           0      48      2 ResponseTime       Score  seconds
#>  MedianTime MeanLogTime RapidThreshold SlowThreshold  RapidRate  SlowRate
#>        24.7     3.16429           16.2          32.6 0.06901042 0.0546875
#>  FlaggedGroups Flags UnassessedPersons
#>             10    10                 0
#>                                                                               InterpretationBoundary
#>  Descriptive response-time screening; not a joint speed-accuracy model and not a fit/pass-fail rule.
#> 
#> Thresholds:
#>  Threshold Value                  Basis TimeUnit
#>      rapid  16.2 Observed quantile 0.05  seconds
#>       slow  32.6 Observed quantile 0.95  seconds
#> 
#> Flagged groups:
#>  Source Group                                   Flag   Rate  N ThresholdRate
#>  person  P001 High fraction at or below rapid cutoff 0.7500 16          0.25
#>  person  P002 High fraction at or below rapid cutoff 0.5000 16          0.25
#>  person  P003 High fraction at or below rapid cutoff 0.6250 16          0.25
#>  person  P005 High fraction at or below rapid cutoff 0.2500 16          0.25
#>  person  P006 High fraction at or below rapid cutoff 0.4375 16          0.25
#>  person  P008 High fraction at or below rapid cutoff 0.5000 16          0.25
#>  person  P042  High fraction at or above slow cutoff 0.2500 16          0.25
#>  person  P044  High fraction at or above slow cutoff 0.7500 16          0.25
#>  person  P047  High fraction at or above slow cutoff 0.5625 16          0.25
#>  person  P048  High fraction at or above slow cutoff 0.8125 16          0.25
#> 
#> Notes:
#> - Response-time review is descriptive; it does not change fit_mfrm estimates.
#> - Each row must represent one timed event. Do not duplicate one response-production time across its raters or criteria; rater scoring time is a different event.
#> - Rates describe valid timed rows only; each group retains input and excluded counts. A group without valid times is unassessed.
#> - Sample quantiles describe the observed distribution, not validated rapid-guessing, low-effort or speed cutoffs. Missing times and censoring are not modeled.
#> - Score-level summaries are descriptive and should not be read as response-time model parameters.
plot_response_time_review(rt, draw = FALSE)
```
