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
  reltol = 1e-06
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

  Maximum optimizer iterations used when `fit = NULL`.

- reltol:

  Relative convergence tolerance used when `fit = NULL`.

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
externally.

The `conquest_command` component is a conservative starting template,
not a guaranteed version-invariant automation. The
`conquest_output_contract` component records which requested external
output should feed each normalized review table. Use
[`normalize_conquest_overlap_files()`](https://ryuya-dot-com.github.io/mfrmr/reference/normalize_conquest_overlap_files.md)
or
[`normalize_conquest_overlap_tables()`](https://ryuya-dot-com.github.io/mfrmr/reference/normalize_conquest_overlap_tables.md)
and then
[`review_conquest_overlap()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_conquest_overlap.md)
only after the matching ConQuest run has been executed externally and
the relevant output tables have been extracted. The bundle and command
template alone are not external validation evidence.

## Comparison targets

- regression slope: compare directly;

- residual variance `sigma2`: compare directly;

- item estimates: compare after centering because the Rasch location
  origin remains constraint-dependent;

- case EAP estimates: compare as posterior summaries under the fitted
  population model.

## Output

The returned object has class `mfrm_conquest_overlap_bundle` and
includes:

- `summary`: one-row scope summary with posterior-basis and
  population-model review fields

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

- `settings`: bundle settings

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
if (FALSE) { # \dontrun{
bundle <- build_conquest_overlap_bundle(quad_points = 3, maxit = 30)
bundle$summary[, c("Case", "Facet", "Covariate", "Persons", "Items")]
summary(bundle)$conquest_command_scope
summary(bundle)$conquest_output_contract
cat(substr(bundle$conquest_command, 1, 120))
} # }
```
