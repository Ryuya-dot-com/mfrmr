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
  reltol = 1e-09,
  conquest_control = list()
)
```

## Arguments

- fit:

  Optional output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md)
  or
  [`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/run_mfrm_facets.md).
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

- conquest_control:

  Named list of external calculation controls: `nodes = 31L`,
  `minnode = -6`, `maxnode = 6`, `p_nodes = 2000L`, `seed = 2L`,
  `convergence = 1e-8`, `deviance_change = 1e-10`, and
  `iterations = 2000L`. These do not change the native fit. Nodes/range
  control calibration; `p_nodes` and `seed` control posterior
  approximation.

## Value

A named list with class `mfrm_conquest_overlap_bundle`.

## Details

This helper prepares a narrow ConQuest comparison bundle for an `RSM` /
`PCM` latent-regression `MML` fit and records the `mfrmr`-side tables to
compare after an external ConQuest run. The supported overlap is
intentionally narrow:

- ordered-response `RSM` / `PCM` only;

- binary responses only;

- exactly one difficulty-oriented non-person facet, treated as the item
  facet, with unanchored sum-to-zero locations and default binary steps;

- active latent-regression `MML` with estimated residual variance; an
  explicitly fixed `population_sd` requires a separately matched model;

- exactly one numeric person covariate beyond the intercept;

- complete person-by-item rectangular data with unit weights;

- no group anchors, dummy facets, interactions or shrinkage.

Unsupported settings are rejected before export; they are not silently
converted to the template's model. Retained category support must be
binary, even if a polytomous fit happens to have only two observed score
values.

The returned bundle standardizes the responses to `{0, 1}`, pivots them
to a one-row-per-person wide CSV, stores the corresponding person
covariates, and records the `mfrmr` estimates that should be compared
externally. The wide CSV uses safe person aliases and the covariate
alias `X`. `person_map` and `covariate_map` preserve original labels and
are exported alongside the data. `PersonDataVariable` and `CaseVariable`
record the covariate columns in `person_data` and `mfrmr_case_eap`;
`PopulationParameter` records its coefficient label in
`mfrmr_population`. Suffixes avoid overwriting identifier, estimate or
variance fields. Keep the bundle for reverse mapping of ConQuest
exports. Aliases do not deidentify the bundle, which includes original
person data. Older bundles without maps retain their original-ID
convention. It also records the actual `mfrmr` optimizer controls, MML
engine, terminal gradient, convergence status and severity, and
inference-readiness decision. A fit that is not inference-ready remains
available for descriptive numerical review. Inspect the source fit's
readiness checks and supported inferential scope: lack of readiness need
not mean optimizer failure, and convergence alone does not establish
readiness. The comparison does not validate standard errors or
confidence intervals. The generated ConQuest benchmark template defaults
its parameter-change criterion at `1e-8`, deviance-change criterion at
`1e-10`, and iteration ceiling at `2000`; these controls are written
into the command, summary, and settings so a default stopping rule
cannot masquerade as an objective discrepancy. External integration
controls are independent of native `quad_points`: equal counts do not
imply equal quadrature rules or precision. Check calibration refinement
and range sensitivity separately from posterior scoring. Neither 31
nodes nor a fixed seed guarantees accuracy.

The `conquest_command` component is a conservative starting template,
not a guaranteed version-invariant automation. The
`conquest_output_contract` component records which requested external
output should feed each normalized review table. Use
[`normalize_conquest_overlap_exports()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/normalize_conquest_overlap_exports.md)
for the parameter, regression, covariance, and case-EAP CSV files
requested by the generated command. The additional matrixout history CSV
retains the objective trajectory and an independent estimated-parameter
dimension for release verification; it is not parsed as a free-form
report.
[`normalize_conquest_overlap_files()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/normalize_conquest_overlap_files.md)
and
[`normalize_conquest_overlap_tables()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/normalize_conquest_overlap_tables.md)
remain available for already-extracted custom tables. Then use
[`review_conquest_overlap()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/review_conquest_overlap.md)
only after the matching ConQuest run has been executed externally. The
bundle and command template alone are not external validation evidence.

This is a controlled analysis bundle, not a deidentified or
automatically shareable export. Response files contain person
identifiers and responses; the person-data file contains identifiers and
covariates; and case-EAP files contain identifiers and person-level
estimates. When files are written, the helper emits a warning and writes
an artifact-level privacy notice. Apply the study's data-handling policy
before sharing or moving any bundle file.

## Running ConQuest locally

This function writes inputs; it does not launch or install ConQuest.
Open the generated `.cqc` file in your local ConQuest installation and
use its containing directory as the working directory, so the relative
CSV paths resolve. A native command-line installation can also read that
command file as standard input from the same directory. Check the
ConQuest console for successful estimation and the requested exports
before normalizing them. ConQuest is optional and is not needed for the
package's examples or tests.

ConQuest's EAP calculation uses Monte Carlo posterior integration with
separate `p_nodes` and `seed` controls. The `estimate` command's
quadrature node count does not set this posterior simulation budget.
Record both controls when comparing Person scores; close calibration
estimates do not imply identical EAPs. See the [ConQuest command
reference](https://conquestmanual.acer.org/s4-00.html), `set` and
`show`. The template defaults to `p_nodes=2000` and `seed=2`; these give
reproducibility, not a guarantee of adequate scoring precision. Use
`conquest_control` to increase the posterior integration budget when
checking score accuracy, and retain the command with its outputs. The
command begins with `reset;`, then sets `lconstraints=items` and
`exit_on_error=yes`. Run it in a fresh ConQuest session: reset clears
prior analysis settings and the output buffer. It fixes response codes
to 0/1. The template uses `fit=no` and `stderr=quick`; it does not
compare fit or full parameter-estimate covariance. `export covariance`
contains the population variance, not parameter-estimate sampling
covariance.

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

- `person_map`: original Person labels and safe ConQuest PID aliases

- `covariate_map`: original covariate name and safe ConQuest variable
  alias

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

[`normalize_conquest_overlap_files()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/normalize_conquest_overlap_files.md),
[`normalize_conquest_overlap_tables()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/normalize_conquest_overlap_tables.md),
[`review_conquest_overlap()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/review_conquest_overlap.md),
[`reference_case_benchmark()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/reference_case_benchmark.md),
[`build_mfrm_replay_script()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/build_mfrm_replay_script.md),
[`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/export_mfrm_bundle.md)

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("build_conquest_overlap_bundle", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Synthetic latent-regression fit; the full regeneration recipe is
# examples/measurement-fits.R in the package (31 nodes, maxit = 2000).
fit <- readRDS(system.file("examples", "measurement-fits.rds",
  package = "mfrmr", mustWork = TRUE))$conquest
bundle <- build_conquest_overlap_bundle(fit = fit)
bundle$summary[, c("Case", "Facet", "Covariate", "Persons", "Items")]
summary(bundle)$mfrmr_fit_status
summary(bundle)$conquest_command_scope
summary(bundle)$conquest_output_contract
cat(substr(bundle$conquest_command, 1, 120))
} # }
```
