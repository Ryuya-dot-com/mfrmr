# Differential facet functioning analysis

Compares observed-minus-expected scores between groups, or describes
linked subgroup facet estimates after refitting. Residual differences do
not isolate differential functioning and are returned without tests or
classifications.

`analyze_dif()` is retained for compatibility with earlier package
versions. In many-facet workflows, prefer `analyze_dff()` as the primary
entry point.

## Usage

``` r
analyze_dff(
  fit,
  diagnostics,
  facet,
  group,
  data = NULL,
  focal = NULL,
  method = c("residual", "refit"),
  min_obs = 10,
  p_adjust = "holm",
  comparison_review = NULL
)

analyze_dif(...)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).
  With `method = "refit"`, it must match `fit`; see
  [mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_compatibility_layer.md)
  for saved-diagnostic migration. The residual method does not use this
  argument.

- facet:

  Character scalar naming the facet whose elements are tested for
  differential functioning (for example, `"Criterion"` or `"Rater"`).

- group:

  Character scalar naming the column in the data that defines the
  grouping variable (e.g., `"Gender"`, `"Site"`).

- data:

  Optional data frame containing at least the group column and the same
  person/facet/score columns used to fit the model. If `NULL` (default),
  mfrmr tries to recover the data from `fit$prep$data`. That slot only
  holds the columns that
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  actually modelled; if the grouping column was not among them (common
  for DIF screening), pass the original data frame via `data = <df>`
  explicitly. The same applies when the fit object has been serialized
  without the prep slot. Residual analyses also require the fitted
  weight column when one was used. See the response-matching contract
  below for subsets and repeated rows.

- focal:

  Optional character vector of group levels to treat as focal. If `NULL`
  (default), all pairwise group comparisons are performed.

- method:

  Analysis method: `"residual"` (default) uses the fitted model's
  residuals without re-estimation; `"refit"` re-estimates the model
  within each group subset. The residual method is faster and avoids
  additional subgroup fits; neither method establishes adequate sample
  size.

- min_obs:

  Minimum number of observations per cell (facet-level x group). Cells
  below this threshold are flagged as sparse. Residual contrasts/scaled
  residuals and refit screening statistics are withheld; actual refit
  point estimates and contrasts remain available. Default `10`.

- p_adjust:

  Adjustment for refit screening tail areas; default `"holm"`. Retained
  but unused for residual comparisons, which return no p-values.

- comparison_review:

  Optional result of
  [`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md)
  with `comparisons` specified, or its `$comparison_review` component.
  The retained response rows, origin groups, facet and score coding must
  match this request. If `focal` is supplied it must equal the review's
  first group. The prospective interaction states are retained
  separately; they do not classify the residual/refit contrasts as
  identified, change estimates, or permit an otherwise refused fit.

- ...:

  Passed directly to `analyze_dff()`.

## Value

An object of class `mfrm_dff` (with compatibility class `mfrm_dif`)
with:

- `dif_table`: data.frame of differential-functioning contrasts. Refit
  rows include `Fixed1` and `Fixed2`; fixed-target rows have
  `ReportingUse = "not_applicable_fixed_target"` and no contrast or
  test.

- `cell_table`: (residual method) per-cell detail table.

- `summary`: counts by method-appropriate screening classification.

- `group_fits`: (refit method) per-group facet estimates.

- `gpcm_boundary`: for `GPCM` fits, a capability-boundary table.

- `config`: list with facet, group, method, min_obs, p_adjust settings.

## Details

**Differential facet functioning (DFF)** occurs when the difficulty or
severity of a facet element differs across subgroups of the population,
after controlling for overall ability. In an MFRM context this
generalises classical DIF (which applies to items) to any facet: raters,
criteria, tasks, etc.

Differential functioning is a threat to measurement fairness: if
Criterion 1 is harder for Group A than Group B at the same ability
level, the measurement scale is no longer group-invariant.

Differences between group ability distributions are not themselves DFF.
Residual screens inherit the fitted model's ability and population
assumptions. With fixed-standard-normal RSM/PCM MML, subgroup refits
retain that population assumption; linking anchors do not estimate
subgroup ability distributions. A residual difference can therefore
reflect an inadequately represented group difference as well as
differential facet functioning. For MML, observation expectations are
evaluated at each Person's EAP ability, rather than integrated over the
conditional ability distribution. This nonlinear substitution can
produce different mean residuals across groups even under a correctly
specified no-DFF model. A zero mean-residual contrast and absence of
differential functioning are therefore distinct null hypotheses;
correcting the SE alone does not make them equivalent.

Two methods are available:

**Residual method** (`method = "residual"`): Uses the existing fitted
model's observation-level residuals. For each facet-level \\\times\\
group cell, the observed and expected score sums are aggregated and a
standardized residual is computed as: \$\$z = \frac{\sum (X\_{obs} -
E\_{exp})}{\sqrt{\sum \mathrm{Var}}}\$\$ Pairwise contrasts compare the
mean observed-minus-expected score in Group1 minus that in Group2.
Positive values mean higher residual scores in Group1, not greater rater
leniency for that group. Differences use score units. `StdResidual` is a
descriptive scaling by model response variance, not a t-statistic. No
residual-contrast SE, confidence interval, p-value or positive/negative
classification is provided. Compatibility columns `SE`, `t`, `df`,
`p_value` and `p_adjusted` contain `NA`.

**Refit method** (`method = "refit"`): Subsets the data by group, refits
the MFRM model within each subset, anchors all non-target facets back to
the baseline calibration when possible, and compares the resulting
facet-level estimates. When linking, convergence, model-based MML
precision, finite positive SEs, disjoint Person rosters and cell-count
screens all pass, a conditional plug-in Welch statistic is also shown:
\$\$t = \frac{\hat{\delta}\_1 - \hat{\delta}\_2} {\sqrt{SE_1^2 +
SE_2^2}}\$\$ This provides group-specific point estimates on a common
scale when linking anchors are available. However, the plug-in standard
error conditions on the baseline anchors and omits baseline-anchor
uncertainty and cross-refit covariance. Refit statistics therefore
remain screening evidence and set `FormalInferenceEligible`,
`SupportsFormalInference`, `PrimaryReportingEligible`, and
`ETS_Eligible` to `FALSE`. The Welch degrees of freedom use a
response-count approximation, not independently estimated degrees of
freedom for model-based SEs. Disjoint Person IDs do not establish
independence or valid matching.

`N_Group1` / `N_Group2` count retained responses for the particular
target level in each group; `N_Subgroup1` / `N_Subgroup2` count all
retained subgroup responses. Failed or skipped fits have unknown
retained counts (`NA`), not zero; `$group_fits[[group]]$N_Input` retains
the input count. An absent target in a successfully prepared subgroup
has a known count of zero. All baseline target levels remain in the
result. Failed/skipped fits and absent levels have missing estimates and
contrasts, with `ComparisonStatus` and `ComparisonReason`; they never
inherit the baseline estimate. Finite estimates from sparse cells or
incomplete diagnostics are retained, while `ConditionalScreenReason`
explains withheld screening uncertainty. `NPersons_Group1` /
`NPersons_Group2` count Persons in each target cell, and
`NPersons_Overlap` counts shared Persons across the entire two subgroup
fits. Any overlap withholds the independent-subgroup screen.

`ContrastDirection` describes the location parameter only:
`larger_location_in_group1`, `smaller_location_in_group1`, or
`equal_locations`. Translating this into higher/lower expected scores
requires the facet orientation and the remaining response parameters.
Subgroup step ladders or slopes can differ; a location difference alone
does not order their entire response curves. The subgroup fits replay
the baseline response family, resolved score range, step/slope facets,
weighting, repeated-rating independence declaration, optimizer, MML
engine, and numerical controls; the non-target anchors are the
intentional linking change. Direct anchors on the target facet and JML
Person anchors from the baseline are preserved. A target fixed by
constraints in either subgroup keeps its point estimates, with `Fixed1`
/ `Fixed2` identifying the fixed values; its contrast, SE and screening
tests are unavailable. Equal supplied anchors do not demonstrate absence
of differential functioning. Use residual DFF to describe response
departures, or explicitly fit a baseline with different target
constraints before requesting free-parameter comparisons. Saved refit
results created before this preservation rule require rerunning
`analyze_dff()` from the baseline fit; loading an old result does not
repair its subgroup estimates. Refit analysis fails closed when the
baseline uses a user-specified active latent-regression population
model, facet interactions, or group-anchor constraints, because those
structures do not yet have a complete subgroup-replay and linking
contract. The automatically generated intercept-only population model
used for default GPCM-MML scale identification is replayed and is not
treated as a substantive covariate model.

When `facet` refers to an item-like facet (for example `Criterion`),
this recovers the familiar DIF case. When `facet` refers to raters or
prompts/tasks, the same machinery supports DRF/DPF-style analyses.

Refit contrasts are not assigned ETS A/B/C labels. Even when subgroup
point estimates share a linked logit scale, a validated joint,
bootstrap, or replicate covariance contract is required before formal
refit inference.

Refit screening tail areas are adjusted using Holm's step-down procedure
by default, jointly across the returned facet-level/group-pair rows in
this call. Holm's family-wise error control requires valid unadjusted
p-values; the approximate screening tail areas here have not been shown
to meet that requirement. Adjustment therefore does not establish an
error-rate guarantee or formal inference eligibility. Alternative
adjustments can be specified via `p_adjust`; see
[`stats::p.adjust()`](https://rdrr.io/r/stats/p.adjust.html) for their
assumptions.

## Response matching for residual analyses

`data` selects fitted response rows using Person, all fitted facets, the
observed score and fitted weight. Source column names, identifier
trimming, the saved original/internal category map and the saved
missing-code policy are respected. A changed score does not inherit a
residual from another response with the same Person and facets. Rows
with missing groups, invalid responses or no fitted match are excluded
with reasons in `$cases`; unmatched complete rows also produce a
message. Requesting more copies of a response than were fitted is an
error. No requested match is an error.

Repeated identical response rows are matched by their multiplicities,
with a canonical group order. They must have identical fitted
expectations and variances. `FitRow` then identifies an exchangeable
fitted copy for this calculation, not a recovered occasion/event
identity. This permits descriptive repeated-rating summaries without
first-row group assignment or replication of unselected rows. It does
not supply cluster-adjusted inference.

`$cases` contains `InputRow` (row of supplied data, or `fit$prep$data`
when `data = NULL`), `FitRow` (row of `fit$prep$data`), `GroupValue`,
`Included` and `Reason`. Preserve the data and fit alongside this audit.
`N` and `N_Group1`/`N_Group2` count retained response rows; `NPersons`
and `NPersons_Group1`/`NPersons_Group2` count distinct Persons. The same
Person may occur in multiple groups. Neither count establishes
independence. Aggregates remain unweighted row summaries even when
fitting used weights. Subsetting data retains the original model's
fitted expectations; it does not recalibrate the model on the subset.

## Choosing a method

Use `method = "residual"` to describe group differences in model
residuals without fitting subgroup models. This does not test
differential functioning. Use `method = "refit"` when you specifically
want group-specific parameter estimates and can tolerate extra
computation. Agreement between methods is not guaranteed by a universal
per-group sample-size threshold: stability and detection depend jointly
on effect size, category support, response-pattern overlap, linking
strength, slope heterogeneity, and estimator behavior. `min_obs` is only
a cell-computability/sparsity guard; it is not evidence of power,
parameter stability, or sample-size adequacy.

## Comparing with MH or ordinal logistic DIF

[`mantel_haenszel_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/mantel_haenszel_table.md)
supplies a separate binary conditional comparison with explicit matching
strata and one response per Person-target cell.
[`ordinal_logistic_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/ordinal_logistic_table.md)
supplies a separate cumulative-logit comparison with uniform/nonuniform
terms and a proportional-odds diagnostic. Neither is a `method` of this
function. A comparison needs the same persons, target response, group
orientation and defensible matching variable. With a common binary Rasch
item set and invariant other items, the total including the studied item
removes the ability distribution from the conditional item response; a
rest score generally does not. This result does not justify pooling
different rater/task plans at the same raw total.

Ordinary MH targets a common conditional odds ratio and can miss
opposing effects across matching strata. Ordinal logistic models
distinguish group and matching-by-group terms, but their cumulative
proportional-odds assumption is not generally implied by RSM/PCM.
Repeated ratings from one Person cannot be counted as independent
persons for either ordinary method. Agreement or disagreement with these
procedures does not by itself validate a DFF conclusion. See the
linking-and-DFF vignette for the comparison scope and primary
references.

## Interpreting output

- `$dif_table`: one row per facet-level x group-pair with contrast, a
  residual mean difference or linked subgroup difference. Residual rows
  have no SE, test or binary classification. Includes `Method`,
  `N_Group1`, `N_Group2`, `EffectMetric`, `ClassificationSystem`,
  `ContrastBasis`, `SEBasis`, `StatisticLabel`, `ProbabilityMetric`,
  `DFBasis`, `ReportingUse`, `PrimaryReportingEligible`, and `sparse`
  columns.

- `$cell_table`: (residual method only) per-cell detail with N,
  NPersons, ObsScore, ExpScore, ObsExpAvg, StdResidual and an
  interpretation note.

- `$cases`: (residual method only) requested-row matching and exclusion
  audit, also retained by
  [`summary()`](https://rdrr.io/r/base/summary.html).

- `$summary`: available/unavailable residual comparisons or linked-
  screening, insufficient-linking, fixed-target and unavailable rows
  (`method = "refit"`).

- `$group_fits`: (refit method only) list of per-group facet estimates
  and subgroup linking diagnostics, with `EstimateStatus` /
  `EstimateReason` and cell, subgroup and input counts.

- `$gpcm_boundary`: for `GPCM` fits, a capability-boundary table marking
  the DFF/DIF output as caveated screening evidence.

- `$comparison_review`: when supplied, the separate prospective
  interaction question, weights, counts, assumptions and identification
  states. Preserved by
  [`summary()`](https://rdrr.io/r/base/summary.html),
  [`dif_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/dif_report.md)
  and both DFF plot views. Its model can differ from the fitted
  screening model; read its `fit_arguments` and `notes`.

## GPCM boundary

For `GPCM`, DFF/DIF rows are available as slope-aware screening evidence
over the fitted expected-score and residual scale. Keep residual-method
contrasts and interaction cells in screening language. Refit contrasts
require explicit subgroup linking and precision support for conditional
screening, but remain in screening language.

## Saved results

Residual results, summaries and reports saved by earlier versions must
be recomputed with this function using the fitted model and original
data. This does not require refitting the model. Previously exported
tables and figures should also be regenerated. Refit results created
before the subgroup availability/cell-count checks must instead be
recomputed with `method = "refit"`. This reruns the subgroup fits from
the saved baseline fit and original data. Reading an old result cannot
repair borrowed estimates, dropped target levels or incorrect counts;
summary, report and plotting methods reject these earlier refit objects.

## Typical workflow

1.  Fit a model with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).
    For `RSM` / `PCM` fairness review, prefer `method = "MML"`.

2.  Run
    [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
    and, for `RSM` / `PCM`, prefer `diagnostic_mode = "both"` so legacy
    and strict marginal screens remain visible together.

3.  Run
    `analyze_dff(fit, diagnostics, facet = "Criterion", group = "Gender", data = my_data)`.

4.  Inspect `$dif_table` for contrasts and their reporting status, and
    `$summary` for method-specific counts. Residual rows have no flags.

5.  Use
    [`dif_interaction_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/dif_interaction_table.md)
    when you need cell-level diagnostics.

6.  Use [plot(x, type =
    "heatmap")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_dif.md)
    or
    [`dif_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/dif_report.md)
    for communication.

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md),
[`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md),
[`dif_interaction_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/dif_interaction_table.md),
[plot(x, type =
"heatmap")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_dif.md),
[`dif_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/dif_report.md),
[`subset_connectivity_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/subset_connectivity_report.md),
[mfrmr_linking_and_dff](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_linking_and_dff.md)

## Examples

``` r
toy <- load_mfrmr_data("example_bias")

fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                 method = "MML", model = "RSM", quad_points = 7, maxit = 30)
diag <- diagnose_mfrm(fit, residual_pca = "none", diagnostic_mode = "both")
dff <- analyze_dff(fit, diag, facet = "Rater", group = "Group", data = toy)
dff$summary
#> # A tibble: 2 × 2
#>   Classification    Count
#>   <chr>             <int>
#> 1 Residual contrast     4
#> 2 Unavailable           0
# Read the residual mean difference and the number of observations per group.
head(dff$dif_table[, c("Level", "Group1", "Group2", "Contrast",
                       "N_Group1", "N_Group2")])
#> # A tibble: 4 × 6
#>   Level Group1 Group2 Contrast N_Group1 N_Group2
#>   <chr> <chr>  <chr>     <dbl>    <int>    <int>
#> 1 R01   A      B       0.146         48       48
#> 2 R02   A      B      -0.152         48       48
#> 3 R03   A      B      -0.164         48       48
#> 4 R04   A      B       0.00347       48       48
# The residual contrast is an observed-minus-expected average contrast
# between groups. It is useful for screening, but it is not an ETS
# A/B/C logit-delta classification.
dff_refit <- analyze_dff(fit, diag, facet = "Rater", group = "Group",
                         data = toy, method = "refit")
unique(dff_refit$dif_table$ClassificationSystem)
#> [1] "descriptive"
# Look for: "descriptive". Linked refit contrasts remain screening-only
#   because their plug-in uncertainty omits anchor uncertainty and
#   cross-refit covariance.
sc <- subset_connectivity_report(fit, diagnostics = diag)
plot(sc, type = "design_matrix", draw = FALSE)
if ("ScaleLinkStatus" %in% names(dff_refit$dif_table)) {
  unique(dff_refit$dif_table$ScaleLinkStatus)
}
#> [1] "weak_link"
# Look for: "linked" in `ScaleLinkStatus` confirms the focal and
#   reference groups share enough common elements for a comparable
#   contrast; "demoted_*" rows lose linking under the refit branch
#   and should be read as exploratory.
```
