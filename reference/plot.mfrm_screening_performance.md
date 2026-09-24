# Plot screening performance and unresolved outcomes

Plot screening performance and unresolved outcomes

## Usage

``` r
# S3 method for class 'mfrm_screening_performance'
plot(
  x,
  scope = c("family", "target"),
  metric = c("false_flags", "detection"),
  condition = NULL,
  draw = TRUE,
  ...
)
```

## Arguments

- x:

  Output from
  [`mfrm_screening_performance()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_screening_performance.md).

- scope:

  `"family"` (default) shows any-flag events once per replication;
  `"target"` shows each individual target separately.

- metric:

  `"false_flags"` (default) or `"detection"`.

- condition:

  Optional condition labels to include, matched exactly.

- draw:

  Logical; `FALSE` returns exact plot data without opening a device.

- ...:

  Unused.

## Value

Invisibly, an `mfrm_plot_data` object. Use
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
for custom graphics; automatic
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
conversion is unavailable.

## Details

Blue points and whiskers show conditional rates and their exact binomial
Monte Carlo intervals. Gray segments bound the realized all-trial
proportion by assigning unresolved outcomes negative or positive; these
are not confidence intervals. A row with no known outcomes has no point
estimate. Right-hand counts show available/planned events. No model is
fitted and no threshold is selected by this plot.
