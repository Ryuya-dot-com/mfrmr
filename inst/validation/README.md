# Research validation and reproducibility

The public package interface and its supported scope are described in
[the reference help](https://ryuya-dot-com.github.io/mfrmr/reference/index.html),
[the tutorials](https://ryuya-dot-com.github.io/mfrmr/articles/index.html), and
[ROADMAP](../../ROADMAP.md). This directory contains research protocols,
reference calculations and dated evidence. A successful calculation in a
restricted case does not establish support for every model or design.

## Reading the evidence

Start with the question, model, estimator and interval target in each record.
Check which source version, inputs and software produced its results. Distinguish
an algebraic identity, agreement of numerical calculations, repeated-sampling
performance and usefulness in an actual assessment. Failed and unavailable
results belong in the denominators described by the protocol.

## Evidence available in this checkout

The following sources are included, so the links do not require a separate
workspace archive. Test success checks implementation and numerical agreement;
it does not estimate a repeated-sampling coverage rate.

| Question | Reproducible source | What it establishes and does not establish |
| --- | --- | --- |
| Does new-Person posterior integration agree with an independent calculation? | [posterior scoring tests](../../tests/testthat/test-posterior-scoring.R) | Independent adaptive integration, C++/R agreement, no/one/many responses, RSM/PCM/GPCM, and high-discrimination prediction. Ability and predictive precision have separate checks. These are deterministic numerical cases, not Bayesian calibration experiments. |
| Does a direct exported model match the intended response equation? | [model specification tests](../../tests/testthat/test-model-export-spec.R) | Fit/specification equivalence, basis constraints and JSON transfer. Ordinary RSM/PCM export retains fixed N(0,1); native estimated-population fits are rejected. |
| Do actual sampling, reload and scoring execute? | [required live gate](../../scripts/check-stan-live.R) | Short-chain CmdStan execution, source-file identity and zero skips. This does not establish adequate MCMC precision or posterior coverage in an assessment. |
| Which model and precision conditions govern an inference flag? | [fit help](../../man/fit_mfrm.Rd), [technical details](../../man/fit_mfrm_technical_details.Rd), [extractors](../../man/mfrm_fit_extractors.Rd) | Model-specific restrictions, numerical readiness and interval eligibility; a `Yes` flag is not empirical validation of a dataset's assumptions. |
| What has been checked for G-theory planning and saved calibration? | [G-theory tutorial](../../vignettes/mfrmr-gtheory.Rmd), [portable calibration](../../vignettes/articles/mfrmr-portable-calibration.Rmd) | Declared score targets, design assumptions and saved-result reuse. Neither establishes arbitrary-design or post-selection guarantees. |

### Historical numerical evidence with explicit source identity

These results predate the current implementation. They are not a check of the
current release candidate. The small evidence files below preserve the original
numbers; no simulation was rerun to prepare this guide.

- **Adaptive MML, 2026-09-14, development 0.2.4.9000:** ten deterministic
  eight-Person conditions covering RSM/PCM/GPCM, fractional frequency weights,
  sparse anchored PCM, interactions and population regression, at Q31/Q61 on
  macOS/Linux (40 fits). All returned optimizer code zero. The maximum
  log-likelihood discrepancy against continuous integration was 4.55e-13;
  the largest Person EAP/SD discrepancies were 1.81e-13/9.87e-13. Inspect the
  [40 result rows](evidence-20261031/adaptive-fitting-0.2.4-results.csv) and
  [original SHA256 source manifest](evidence-20261031/adaptive-fitting-0.2.4-source.csv).
  The full old fit archive is not bundled here: these files permit inspection
  of outcomes and source identity, not full independent replay from this checkout.
  They provide no coverage estimate.
- **Estimated-population interval preflight, 2026-09-10:** eight cells cross
  RSM/PCM, 80/320 Persons and 3/6 ratings. The generator uses
  `theta = 0.2 + 0.5*x + sqrt(0.7)*Z`, with fixed `x` evenly spaced on [-1,1],
  three raters, two criteria and categories 0--2. Targets are the intercept,
  regression slope, log residual variance and natural residual variance.
  Five datasets per cell (40 distinct datasets, not 160 independent samples)
  returned numerically computable intervals; none qualified for production
  inference. The planned main coverage study is **not established by these
  preflight results**. Inspect [run counts](evidence-20261031/population-coverage-preflight-runs-0.2.4.csv),
  [target summaries, including MC uncertainty](evidence-20261031/population-coverage-preflight-summary-0.2.4.csv)
  and [all 160 dataset/target rows](evidence-20261031/population-preflight-replicates.csv).
  The [source bundle](evidence-20261031/population-preflight-source.rds) contains
  the 90 original scientific source/protocol files, their MD5 manifest and
  the original R session. All 90 reconstructed files were checked against
  the retained hashes. The five-per-cell fractions are exploratory, not
  calibrated coverage estimates; no larger planned repetition count is reported
  as executed.

To inspect the historical source bundle without modifying the current source:

```r
saved <- readRDS("inst/validation/evidence-20261031/population-preflight-source.rds")
names(saved$Source)
cat(saved$Source[["inst/validation/population-coverage-protocol-0.2.4.md"]], sep = "\n")
saved$Payload  # named original source MD5 values
saved$Session
```

The archived runner, independent generator and interval calculation are included
as text in `saved$Source`. Restore them only into a separate directory with the
recorded dependencies if replay is needed. No frozen source should be overwritten
with the current package. The source snapshot is not an installable source
package and does not include the original dependency binaries.

Other historical studies (including TAM/ConQuest and assigned-score imputation)
remain in separately retained archives. Their absence from this checkout is a
reproduction limit, not evidence that they were never run. Do not use archive
references as accessible evidence or claim that those old results validate the
current source. Before a broader performance claim, provide its matching
protocol, code/source identity and results, including attempted fits, failures,
interval availability, conditional coverage, available-and-covered frequency
and Monte Carlo uncertainty. A new broad simulation is not required merely to
repair a numerical regression or document a model restriction.

## Reproducing calculations

Run the package tests using the commands in [CONTRIBUTING](../../CONTRIBUTING.md).
Research scripts in this directory can require optional software, retained
inputs and frozen source versions beyond the source package. Read the script's
input and execution contract before running it. If those inputs are unavailable,
that reproduction is unavailable; a skipped calculation is not confirming
evidence. Keep original result files and manifests unchanged.

Some archived manifests record absolute paths from the machine that generated
them. Readers that relocate such inputs recognize the suffix
`/mfrmr/development/` and resolve the remaining path from the package root.
They still verify the original content digests. Relocation must not replace a
source or result with a merely similar file, or bypass a failed digest check.
Use the frozen original script when a manifest requires its exact source hash;
portable reader edits do not make a new implementation interchangeable with it.

Some historical scripts also bind or copy the protocol used before their
experiment. Those paths describe archived inputs, not a current planning
document to supply from this checkout. Reproduce them from the matching frozen
source and protocol bundle. Substituting a current work plan changes the
experiment's provenance, even if a filename happens to match. Interpret the
results using the scientific conditions and original protocol digests in the
dated records. A historical source reference is not a link to a current work plan.

For the split-centering reference script's `prepare` operation, set
`MFRMR_SPLIT_CENTERING_REFERENCE_PDF` to the reference PDF you have obtained.
Its digest is recorded with the experiment inputs; no personal library location
is assumed and no document is downloaded automatically.

The source package excludes this research directory. Public research evidence
and code remain here for inspection; private execution queues and maintainer
planning are not package documentation.
