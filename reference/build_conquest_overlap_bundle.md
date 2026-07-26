# Build a scoped ConQuest-overlap bundle

Build a scoped ConQuest-overlap bundle

## Usage

``` r
build_conquest_overlap_bundle(
  fit = NULL,
  case = c("synthetic_latent_regression"),
  output_dir = NULL,
  prefix = "conquest_overlap",
  overwrite = FALSE,
  quad_points = 7L,
  maxit = 40L,
  reltol = 1e-09
)
```

## Arguments

- fit:

  Optional output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  or
  [`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md).
  When omitted, the helper builds the package's
  `"synthetic_latent_regression"` overlap case.

- case:

  Overlap case used when `fit = NULL`. Currently only
  `"synthetic_latent_regression"` is supported.

- output_dir:

  Optional directory where the bundle files should be written. When
  `NULL`, the helper returns the in-memory bundle only.

- prefix:

  File-name prefix used when writing the bundle to disk.

- overwrite:

  If `FALSE`, refuse to overwrite existing files.

- quad_points:

  Quadrature points used when `fit = NULL` and the overlap case is fit
  on the fly.

- maxit:

  Maximum optimizer iterations used when `fit = NULL`. The fitted
  object's actual value is recorded in the returned summary and
  settings.

- reltol:

  Relative convergence tolerance used when `fit = NULL`. Default `1e-9`.
  The fitted object's actual value is recorded in the returned summary
  and settings.

## Value

A named list with class `mfrm_conquest_overlap_bundle`.

## Details

This helper prepares a narrow ConQuest comparison bundle for an `RSM` /
`PCM` latent-regression `MML` fit and records the `mfrmr`-side tables to
compare after an external ConQuest run. The supported overlap is
intentionally narrow:

- ordered-response `RSM` / `PCM` only;

- binary responses only;

- exactly one non-person facet, treated as the item facet;

- active latent-regression `MML`;

- exactly one numeric person covariate beyond the intercept;

- complete person-by-item rectangular data.

The returned bundle standardizes the responses to `{0, 1}`, pivots them
to a one-row-per-person wide CSV, stores the corresponding person
covariates, and records the `mfrmr` estimates that should be compared
externally. It also records the actual `mfrmr` optimizer controls, MML
engine, terminal gradient, convergence status and severity, and
inference-readiness decision. A fit that is not inference-ready remains
available for convergence review, but its estimates should not be used
for inferential comparison with ConQuest until the convergence issue is
resolved and the model is refit.

The `conquest_command` component is a conservative starting template,
not a guaranteed version-invariant automation. The
`conquest_output_contract` component records which requested external
output should feed each normalized review table. Use
[`normalize_conquest_overlap_exports()`](https://ryuya-dot-com.github.io/mfrmr/reference/normalize_conquest_overlap_exports.md)
for the four CSV files requested by the generated command.
[`normalize_conquest_overlap_files()`](https://ryuya-dot-com.github.io/mfrmr/reference/normalize_conquest_overlap_files.md)
and
[`normalize_conquest_overlap_tables()`](https://ryuya-dot-com.github.io/mfrmr/reference/normalize_conquest_overlap_tables.md)
remain available for already-extracted custom tables. Then use
[`review_conquest_overlap()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_conquest_overlap.md)
only after the matching ConQuest run has been executed externally. The
bundle and command template alone are not external validation evidence.

This is a controlled analysis bundle, not a deidentified or
automatically shareable export. Response files contain person
identifiers and responses; the person-data file contains identifiers and
covariates; and case-EAP files contain identifiers and person-level
estimates. When files are written, the helper emits a warning and writes
an artifact-level privacy notice. Apply the study's data-handling policy
before sharing or moving any bundle file.

## Comparison targets

- regression slope: compare after confirming identical covariate coding
  and population-model parameterization;

- residual variance `sigma2`: compare after confirming the same
  latent-scale and variance parameterization;

- item estimates: compare after centering because the Rasch location
  origin remains constraint-dependent;

- case EAP estimates: compare as posterior summaries under the fitted
  population model.

## Output

The returned object has class `mfrm_conquest_overlap_bundle` and
includes:

- `summary`: one-row scope summary with posterior-basis,
  population-model, optimizer-control, and convergence-review fields

- `comparison_targets`: comparison rules for the exported tables

- `conquest_output_contract`: requested ConQuest outputs and review
  handoff

- `response_long`: long-format binary response data used by the bundle

- `response_wide`: wide CSV-ready response matrix for the ConQuest
  template

- `person_data`: one-row-per-person covariate table

- `item_map`: mapping from exported response columns to original item
  levels

- `mfrmr_population`: fitted population-model coefficients plus `sigma2`

- `mfrmr_item_estimates`: fitted item estimates with centered values

- `mfrmr_case_eap`: posterior EAP summaries for the fitted persons

- `conquest_command`: conservative ConQuest command template

- `written_files`: file inventory when `output_dir` is supplied

- `privacy_notice`: artifact-level sensitive-data inventory

- `settings`: bundle settings, including the actual `mfrmr` fit controls
  and convergence state

- `notes`: interpretation notes

## See also

[`normalize_conquest_overlap_files()`](https://ryuya-dot-com.github.io/mfrmr/reference/normalize_conquest_overlap_files.md),
[`normalize_conquest_overlap_tables()`](https://ryuya-dot-com.github.io/mfrmr/reference/normalize_conquest_overlap_tables.md),
[`review_conquest_overlap()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_conquest_overlap.md),
[`reference_case_benchmark()`](https://ryuya-dot-com.github.io/mfrmr/reference/reference_case_benchmark.md),
[`build_mfrm_replay_script()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_replay_script.md),
[`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md)

## Examples

``` r
# \donttest{
bundle <- build_conquest_overlap_bundle(quad_points = 3, maxit = 30)
bundle$summary[, c("Case", "Facet", "Covariate", "Persons", "Items")]
#>                          Case     Facet Covariate Persons Items
#> 1 synthetic_latent_regression Criterion         X      60     6
summary(bundle)$mfrmr_fit_status
#>                           Item     Value
#> 1              MML engine used    direct
#> 2           Maximum iterations        30
#> 3           Relative tolerance     1e-09
#> 4                  Convergence Converged
#> 5                     Severity      Pass
#> 6 Terminal gradient (sup-norm)  9.59e-05
#> 7              Inference ready       Yes
summary(bundle)$conquest_command_scope
#>                                   Area              Status
#> 1            ConQuest command template       template only
#> 2               Command-comment syntax      block comments
#> 3 Official command-reference alignment explicit CSV widths
#> 4                  Overlap model scope narrow overlap only
#> 5         External output requirements           requested
#> 6            External comparison scope         not claimed
#>                                                                 Evidence
#> 1                                                bundle$conquest_command
#> 2                         command text starts with /* and closes with */
#> 3                                    pidwidth and keepswidth are present
#> 4                      binary Criterion facet with numeric covariate `X`
#> 5    parameters, reg_coefficients, covariance, and cases EAP CSV outputs
#> 6 requires external ConQuest execution and extracted output-table review
#>                                                                                                      Interpretation
#> 1                  Use the command text as a starting point for a local ConQuest run, not as an executed benchmark.
#> 2 Generated comments follow the documented ConQuest block-comment style rather than FACETS-style leading asterisks.
#> 3                                 CSV input with PID/keeps variables needs explicit widths in the command template.
#> 4                               The bundle does not generalize to full many-facet or polytomous ConQuest workflows.
#> 5                 Review and combine external parameter, beta, sigma, and case outputs before review normalization.
#> 6              External comparison remains scoped until external outputs are reviewed and tolerances are justified.
summary(bundle)$conquest_output_contract
#>                                      ExternalFile
#> 1        conquest_overlap_conquest_parameters.csv
#> 2  conquest_overlap_conquest_reg_coefficients.csv
#> 3        conquest_overlap_conquest_covariance.csv
#> 4         conquest_overlap_conquest_cases_eap.csv
#> 5 conquest_overlap_conquest_parameters_review.txt
#>                                            ConQuestCommand
#> 1                         export parameters ! filetype=csv
#> 2                   export reg_coefficients ! filetype=csv
#> 3                         export covariance ! filetype=csv
#> 4 show cases ! estimates=eap, filetype=csv, regressors=yes
#> 5          show parameters ! tables=1:2:3:4, estimates=eap
#>                                                                       ReviewHandoff
#> 1          Pass to normalize_conquest_overlap_exports() as the item-parameter file.
#> 2              Pass to normalize_conquest_overlap_exports() as the regression file.
#> 3              Pass to normalize_conquest_overlap_exports() as the covariance file.
#> 4                Pass to normalize_conquest_overlap_exports() as the case-EAP file.
#> 5 Human-readable review only; do not treat this text file as a parsed review table.
#>                                                                                   DataHandling
#> 1                                     Review item labels and analysis metadata before sharing.
#> 2                                Review covariate labels and analysis metadata before sharing.
#> 3                              Review covariance results and analysis metadata before sharing.
#> 4 Contains person identifiers and person-level EAP estimates; restricted handling is required.
#> 5                                Review parameter labels and analysis metadata before sharing.
#>   RequiredForReview
#> 1              TRUE
#> 2              TRUE
#> 3              TRUE
#> 4              TRUE
#> 5             FALSE
cat(substr(bundle$conquest_command, 1, 120))
#> /*
#> Generated by mfrmr::build_conquest_overlap_bundle()
#> Scope: ordered-response RSM/PCM, operationalized here as binary i
# }
```
