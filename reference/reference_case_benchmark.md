# Benchmark packaged reference cases

Benchmark packaged reference cases

## Usage

``` r
reference_case_benchmark(
  cases = c("synthetic_truth", "synthetic_latent_regression", "synthetic_bias_contract",
    "study1_itercal_pair", "study2_itercal_pair", "combined_itercal_pair"),
  method = "MML",
  model = "RSM",
  quad_points = 7,
  maxit = 40,
  reltol = 1e-06,
  mml_engine = c("direct", "em", "hybrid")
)
```

## Arguments

- cases:

  Reference cases to run. Defaults to the standard `RSM`-compatible
  reference suite. Specialized `GPCM` and ConQuest-overlap package-side
  cases can be requested explicitly.

- method:

  Estimation method passed to
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).
  Defaults to `"MML"`.

- model:

  Model family passed to
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).
  Defaults to `"RSM"`.

- quad_points:

  Quadrature points for `method = "MML"`.

- maxit:

  Maximum optimizer iterations passed to
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- reltol:

  Convergence tolerance passed to
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- mml_engine:

  MML optimization engine passed to
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).
  Applies only when `method = "MML"`.

## Value

An object of class `mfrm_reference_benchmark`.

## Details

This function checks `mfrmr` against the package's curated reference
case families:

- `synthetic_truth`: checks whether recovered facet measures align with
  the known generating values from the package's synthetic design.

- `synthetic_latent_regression`: checks whether the latent-regression
  `MML` branch recovers known population coefficients, residual latent
  variance, criterion ordering, and posterior-shift direction from a
  synthetic overlap case.

- `synthetic_latent_regression_omit`: checks whether the
  population-model complete-case omission policy is reflected in the
  fitted metadata, response-row review, active person estimates, and
  replay provenance.

- `synthetic_conquest_overlap_dry_run`: builds the narrow
  ConQuest-overlap bundle for the latent-regression synthetic case,
  round-trips package tables through the normalization/review helpers,
  and confirms the package-side workflow without claiming that ConQuest
  itself was executed.

- `synthetic_gpcm`: checks whether the bounded `GPCM` branch recovers
  known criterion-specific slopes, row-centered step parameters, and
  criterion ordering from a synthetic overlap case. This case currently
  requires `model = "GPCM"` and is intended for `method = "MML"`.

- `synthetic_bias_contract`: checks whether package bias tables and
  pairwise local comparisons satisfy the identities documented in the
  bias help workflow.

- `*_itercal_pair`: compares a baseline packaged dataset with its
  iterative recalibration counterpart to review fit stability,
  facet-measure alignment, and linking coverage together.

The resulting object is intended as a reference-case check for package
behavior. It does not by itself establish external validity against
FACETS, ConQuest, or published calibration studies, and it does not
assume any familiarity with external table numbering or printer layouts.
When specialized latent-regression omission or ConQuest-overlap
package-side cases are requested, `summary(bench)` prints preview rows
from `population_policy_checks` and `conquest_overlap_checks` alongside
the reference notes so the package-versus-external validation boundary
remains visible.

## Interpreting output

- `overview`: one-row reference-case summary.

- `case_summary`: pass/warn/fail triage by reference case.

- `fit_runs`: fitted-run metadata (fit, precision tier, convergence, and
  latent-regression population-model/posterior-basis fields, including
  categorical-coding details when present).

- `design_checks`: exact design recovery checks for each dataset.

- `recovery_checks`: known-truth recovery metrics for the synthetic
  cases, including the latent-regression reference case.

- `bias_checks`: source-backed bias/local-measure identity checks.

- `pair_checks`: paired-dataset stability screens for the iterated
  cases.

- `linking_checks`: common-element reviews for paired calibration
  datasets.

- `conquest_overlap_checks`: package-side checks for the
  ConQuest-overlap bundle/normalization/review workflow; this remains a
  package-side check until actual ConQuest output tables are supplied.

- `population_policy_checks`: complete-case omission checks for
  population model reference data.

- `source_profile`: source-backed rules used by the reference checks.

## Examples

``` r
# \donttest{
bench <- reference_case_benchmark(
  cases = "synthetic_truth",
  method = "JML",
  maxit = 30
)
summary(bench)
#> mfrmr Reference Case Check Summary 
#>   Class: mfrm_reference_benchmark
#>   Components: 15
#> 
#> Case check summary
#>             Case       CaseType Status Fits DesignChecks RecoveryChecks
#>  synthetic_truth truth_recovery   Fail    1            7              3
#>  BiasChecks LinkingChecks ConQuestOverlapChecks PopulationPolicyChecks
#>           0             0                     0                      0
#>  StabilityChecks                        KeySignal
#>                0 Min recovery correlation = 0.992
#> 
#> Reference-case fit runs: fit_runs
#>             Case         Dataset Method Model Rows Persons Raters Criteria
#>  synthetic_truth synthetic_truth    JML   RSM 1296      36      3        3
#>  Tasks Converged OptimizerCodeZero ConvergenceSeverity    LogLik
#>      4     FALSE             FALSE                fail -1205.199
#>  MMLEngineRequested MMLEngineUsed EMIterations PosteriorBasis
#>                <NA>          <NA>           NA     legacy_mml
#>  PopulationModelActive PopulationFormula PopulationPolicy
#>                  FALSE              <NA>             <NA>
#>  PopulationDesignColumns PopulationXlevelVariables PopulationContrastVariables
#>                                                                               
#>  PopulationCoefficientCount PopulationResidualVariance
#>                           0                         NA
#>  PopulationIncludedPersons PopulationOmittedPersons
#>                          0                        0
#>  PopulationResponseRowsRetained PopulationResponseRowsOmitted Infit Outfit
#>                            1296                             0 0.992  0.955
#>  PrecisionTier SupportsFormalInference
#>    exploratory                   FALSE
#> 
#> Validation scope
#>                                 Area        Status
#>              Package reference check        active
#>    Latent-regression omission policy not requested
#>  ConQuest-overlap package-side check not requested
#>         External ConQuest validation  not assessed
#>                                                                 Evidence
#>                                  case_summary and component check tables
#>                               request `synthetic_latent_regression_omit`
#>                             request `synthetic_conquest_overlap_dry_run`
#>  Use review_conquest_overlap() with output from an external ConQuest run
#>                                                                               Interpretation
#>                                                            Use as a package reference check.
#>        Complete-case omission behavior is reviewed only when the omission case is requested.
#>               The check covers package-side export, normalization, and review plumbing only.
#>  The package reference benchmark is not a substitute for reviewing external ConQuest output.
#> 
#> Settings
#>              Setting                        Value
#>                cases              synthetic_truth
#>               method                          JML
#>                model                          RSM
#>           mml_engine                           NA
#>         intended_use packaged_reference_benchmark
#>  external_validation                        FALSE
#>          quad_points                           NA
#>                maxit                           30
#>               reltol                        1e-06
#> 
#> Notes
#>  - Synthetic truth checks compare recovered facet measures against known
#>    generating values from the package simulation design.
#>  - ConQuest-overlap package-side checks cover only export/normalization/review
#>    preparation; actual external ConQuest output is still required for external
#>    validation.
#>  - Bias checks review package identities for observed-minus-expected averages,
#>    local measures, and pairwise Rasch-Welch contrasts.
#>  - Pair stability checks review baseline and iterative-calibration packaged
#>    datasets using facet-measure alignment, fit deltas, reliability deltas, and
#>    common-element linking coverage.
#>  - Use this reference check as package evidence, not as a substitute for
#>    external validation against commercial software or published studies.
#>  - Non-MML benchmark runs remain useful for stability review, but
#>    formal-inference expectations should be interpreted more conservatively.
# }
```
