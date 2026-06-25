# Compare two or more fitted MFRM models

Produce a side-by-side comparison of multiple
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
results using information criteria, log-likelihood, and parameter
counts. When exactly two models are supplied and the current
conservative nesting review passes, a likelihood-ratio test is included.

## Usage

``` r
compare_mfrm(..., labels = NULL, warn_constraints = TRUE, nested = FALSE)
```

## Arguments

- ...:

  Two or more `mfrm_fit` objects to compare.

- labels:

  Optional character vector of labels for each model. If `NULL`, labels
  are generated from model/method combinations.

- warn_constraints:

  Logical. If `TRUE` (the default), emit a warning when models use
  different centering constraints (`noncenter_facet` or `dummy_facets`),
  which can make information-criterion comparisons misleading.

- nested:

  Logical. Set to `TRUE` only when the supplied models are known to be
  nested and fitted with the same likelihood basis on the same
  observations. The default is `FALSE`, in which case no
  likelihood-ratio test is reported. When `TRUE`, the function still
  runs a conservative structural nesting review and computes the LRT
  only for supported nesting patterns.

## Value

An object of class `mfrm_comparison` (named list) with:

- `table`: data.frame of model-level statistics (LogLik, AIC, BIC,
  Delta_AIC, AkaikeWeight, Delta_BIC, BICWeight, npar, nobs, WeightedN,
  ICSampleSize, ICSampleSizeBasis, Model, Method, Converged,
  ICComparable).

- `lrt`: data.frame with likelihood-ratio test result (only when two
  models are supplied and `nested = TRUE`). Contains `ChiSq`, `df`,
  `p_value`.

- `evidence_ratios`: data.frame of pairwise Akaike-weight ratios
  (Model1, Model2, EvidenceRatio). `NULL` when weights cannot be
  computed.

- `preferred`: named list with the preferred model label by each
  criterion.

- `comparison_basis`: list describing whether IC and LRT comparisons
  were considered comparable. Includes a conservative `nesting_review`
  plus `lrt_status` / `lrt_reason` so withheld LRTs are explicit rather
  than silently absent.

## Details

Models should be fit to the **same data** (same rows, same person/facet
columns) for the comparison to be meaningful. The function checks that
observation counts match and warns otherwise.

Information-criterion ranking is reported only when all candidate models
use the package's `MML` estimation path, analyze the same observations,
and converge successfully. Raw `AIC` and `BIC` values are still shown
for each model, but `Delta_*`, weights, and preferred-model summaries
are suppressed when the likelihood basis is not comparable enough for
primary reporting. The comparison table records both row count (`nobs`)
and the sample-size basis used for the BIC penalty (`ICSampleSize`,
`ICSampleSizeBasis`); for weighted fits this is the sum of weights
rather than the number of rows.

**Nesting**: Two models are *nested* when one is a special case of the
other obtained by imposing equality constraints. The most common nesting
in MFRM is RSM (shared thresholds) inside PCM (item-specific
thresholds). Models that differ only in estimation method (MML vs JML)
on the same specification are not nested in the usual sense—use
information criteria rather than LRT for that comparison.

In the **current `mfrmr` model space**, the automatic nesting review is
intentionally conservative. It currently supports two fixed-effect
restrictions under shared data and shared constraints:

- `RSM` nested inside `PCM` when the `PCM` fit has an explicit
  `step_facet`;

- same-family additive-vs-interaction comparisons when the smaller fit's
  `facet_interactions` set is a subset of the larger fit's set.

Cross-method comparisons, comparisons that change
anchors/dummying/centering, and same-family comparisons that do not add
fixed interaction terms are not automatically promoted to LRT claims.

The **likelihood-ratio test (LRT)** is reported only when exactly two
models are supplied, `nested = TRUE`, the structural nesting review
passes, and the difference in the number of parameters is positive:

\$\$\Lambda = -2 (\ell\_{\mathrm{restricted}} - \ell\_{\mathrm{full}})
\sim \chi^2\_{\Delta p}\$\$

The LRT is asymptotically valid when models are nested and the data are
independent. With small samples or boundary conditions (e.g., variance
components near zero), treat p-values as approximate.

## Information-criterion diagnostics

In addition to raw AIC and BIC values, the function computes:

- **Delta_AIC / Delta_BIC**: difference from the best (minimum) value. A
  Delta \< 2 is typically considered negligible; 4–7 suggests moderate
  evidence; \> 10 indicates strong evidence against the higher-scoring
  model (Burnham & Anderson, 2002).

- **AkaikeWeight / BICWeight**: model probabilities derived from
  `exp(-0.5 * Delta)`, normalised across the candidate set. An Akaike
  weight of 0.90 means the model has a 90\\ being the best in the
  candidate set.

- **Evidence ratios**: pairwise ratios of Akaike weights, quantifying
  the relative evidence for one model over another (e.g., an evidence
  ratio of 5 means the preferred model is 5 times more likely).

AIC penalises complexity less than BIC; when they disagree, AIC favours
the more complex model and BIC the simpler one.

## What this comparison means

`compare_mfrm()` is a same-basis model-comparison helper. Its strongest
claims apply only when the models were fit to the same response data,
under a compatible likelihood basis, and with compatible constraint
structure.

## What this comparison does not justify

- Do not treat AIC/BIC differences as primary evidence when
  `table$ICComparable` is `FALSE`.

- Do not interpret the LRT unless `nested = TRUE` and the structural
  nesting review in `comparison_basis$nesting_review` passes.

- Same-family additive-vs-interaction fits are considered nested only
  when all other structural settings match and the smaller model's
  `facet_interactions` set is a subset of the larger model's set.

- Do not assume that `nested = TRUE` overrides the package's
  conservative nesting boundary; unsupported relations remain
  unsupported.

- Do not compare models fit to different datasets, different score
  codings, or materially different constraint systems as if they were
  commensurate.

## Interpreting output

- Lower AIC/BIC values indicate better parsimony-accuracy trade-off only
  when `table$ICComparable` is `TRUE`.

- A significant LRT p-value suggests the more complex model provides a
  meaningfully better fit only when the nesting assumption truly holds.

- `preferred` indicates the model preferred by each criterion.

- `evidence_ratios` gives pairwise Akaike-weight ratios (returned only
  when Akaike weights can be computed for at least two models).

- When comparing more than two models, interpret evidence ratios
  cautiously—they do not adjust for multiple comparisons.

## How to read the main outputs

- `table`: first-pass comparison table; start with `ICComparable`,
  `Model`, `Method`, `AIC`, and `BIC`.

- `comparison_basis`: records whether IC and LRT claims are defensible
  for the supplied models. Inspect
  `comparison_basis$nesting_review$relation` and `reason` before reading
  any LRT output.

- `lrt`: nested-model test summary, present only when the requested and
  reviewed conditions are met.

- `preferred`: candidate preferred by each criterion when those
  summaries are available.

## Recommended next step

Inspect `comparison_basis` before writing conclusions. If comparability
is weak, treat the result as descriptive and revise the model setup (for
example, explicit `step_facet`, common data, or common constraints)
before using IC or LRT results in reporting.

## Typical workflow

1.  Fit two models with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
    (e.g., RSM and PCM).

2.  Compare with `compare_mfrm(fit_rsm, fit_pcm)`.

3.  Inspect `summary(comparison)` for AIC/BIC diagnostics and, when
    appropriate, an LRT.

## References

- Burnham, K. P., & Anderson, D. R. (2002). *Model selection and
  multimodel inference: A practical information-theoretic approach* (2nd
  ed.). Springer.

- Akaike, H. (1974). A new look at the statistical model identification.
  *IEEE Transactions on Automatic Control, 19*(6), 716-723.

- Schwarz, G. (1978). Estimating the dimension of a model. *Annals of
  Statistics, 6*(2), 461-464.

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)

## Examples

``` r
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")

fit_rsm <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                     method = "MML", model = "RSM", quad_points = 7, maxit = 30)
fit_pcm <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                     method = "MML", model = "PCM",
                     step_facet = "Criterion", quad_points = 7, maxit = 30)
comp <- compare_mfrm(fit_rsm, fit_pcm, labels = c("RSM", "PCM"))
comp$table
comp$evidence_ratios
} # }
```
