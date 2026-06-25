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
#>  FlaggedGroups
#>             10
#>                                                                               InterpretationBoundary
#>  Descriptive response-time screening; not a joint speed-accuracy model and not a fit/pass-fail rule.
#> 
#> Thresholds:
#>  Threshold Value         Basis TimeUnit
#>      rapid  16.2 quantile_0.05  seconds
#>       slow  32.6 quantile_0.95  seconds
#> 
#> Flagged groups:
#>  Source Group                     Flag   Rate  N ThresholdRate
#>  person  P001 high_rapid_response_rate 0.7500 16          0.25
#>  person  P002 high_rapid_response_rate 0.5000 16          0.25
#>  person  P003 high_rapid_response_rate 0.6250 16          0.25
#>  person  P005 high_rapid_response_rate 0.2500 16          0.25
#>  person  P006 high_rapid_response_rate 0.4375 16          0.25
#>  person  P008 high_rapid_response_rate 0.5000 16          0.25
#>  person  P042  high_slow_response_rate 0.2500 16          0.25
#>  person  P044  high_slow_response_rate 0.7500 16          0.25
#>  person  P047  high_slow_response_rate 0.5625 16          0.25
#>  person  P048  high_slow_response_rate 0.8125 16          0.25
#> 
#> Notes:
#> - Response-time review is descriptive; it does not change fit_mfrm estimates.
#> - Score-level summaries are descriptive and should not be read as response-time model parameters.
plot_response_time_review(rt, draw = FALSE)
```
