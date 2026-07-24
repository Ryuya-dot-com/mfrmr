# First-use workflow stress record for mfrmr 0.2.2

## Purpose and scope

This repository-only record checks the public
data -> describe -> fit -> summary -> plot route under conditions that a new
user may encounter. It is a software-behavior regression check, not evidence
that every fitted model is substantively adequate and not a Monte Carlo study
of estimator operating characteristics.

The executable protocol is `first-use-workflow-stress.R`. It is excluded from
the CRAN source package because the full tier deliberately takes longer than a
routine package check. Small representative contracts remain in testthat.

## Recorded run

- Date: 2026-07-24
- Package version: 0.2.2 development source
- R: 4.6.1 (2026-06-24)
- Platform: aarch64-apple-darwin23, Darwin 25.5.0 arm64
- Seeds: 20260724, 20260725, and 20260726
- Initial fit controls: public MML defaults unless the scenario explicitly
  changes the model, step/slope facet, missing-code policy, or row weights
- Core matrix: 10 scenarios x 3 seeds = 30 fits
- Executable cross-surface matrix: 10 named contracts for each fitted
  condition = 300 checks

## Scenario results

All 30 fits completed, all 30 passed the common numerical-readiness gate, and
all 30 matched their declared Data, Design, Stability, Reporting, and plot
contracts. The maximum terminal-gradient norm in every scenario remained
below the package review threshold of 1e-4.

| Scenario | Runs ready / runs | Contract passes | Maximum terminal gradient | Median fit seconds | Intended stress |
| --- | ---: | ---: | ---: | ---: | --- |
| Balanced RSM | 3 / 3 | 3 / 3 | 2.449931e-05 | 0.368 | Recommended connected MML/RSM route |
| Sparse linked RSM | 3 / 3 | 3 / 3 | 6.204738e-05 | 0.153 | Incomplete but linked rater assignment |
| Disconnected RSM | 3 / 3 | 3 / 3 | 2.814784e-05 | 0.138 | Two components retained as a Design hold |
| Shared-criterion link | 3 / 3 | 3 / 3 | 6.258190e-05 | 0.144 | Overall graph linked through a shared criterion |
| PCM varying steps | 3 / 3 | 3 / 3 | 2.837449e-05 | 0.203 | Criterion-specific threshold ladders |
| Bounded GPCM slopes | 3 / 3 | 3 / 3 | 2.981400e-05 | 0.292 | Positive bounded discrimination route |
| Skewed extreme scores | 3 / 3 | 3 / 3 | 8.461460e-05 | 0.147 | Difficult score distribution without a software failure |
| Separated raters | 3 / 3 | 3 / 3 | 2.278341e-05 | 0.203 | Numerical pass retained separately from a Stability hold |
| Sentinel score codes | 3 / 3 | 3 / 3 | 3.885833e-05 | 0.161 | Declared sentinels removed without changing identifiers |
| Weighted rows | 3 / 3 | 3 / 3 | 8.770242e-05 | 0.143 | Row retention and weighted-likelihood provenance |

The expected non-numerical states were reproduced in every seed:

- disconnected RSM: two subsets, Design hold, review-only plots;
- separated raters: boundary-separation Stability hold, review-only plots;
- sentinel and weighted cases: Data review, review-only plots; and
- shared-criterion link: one overall connected subset despite separate rater
  groups.

## Cross-surface checks

For every scenario and seed, the executable protocol checked 10 named
contracts:

1. the declared numerical pass-or-review contract, with `fail` and `error`
   never accepted as a permitted review;
2. all six readiness domains in `summary(fit, profile = "facets")`;
3. Data-state agreement;
4. Design-state agreement;
5. Stability-state agreement;
6. Reporting-state agreement;
7. the native Wright map with mfrmr uncertainty;
8. the FACETS-style asterisk ruler with facet rows, exact step rows, and the
   optional mfrmr confidence-interval overlay;
9. the Infit pathway with both facet levels and 1-12 selected person rows; and
10. consistent interpretation readiness across all three plot surfaces.

All 300 executable checks passed. Review-only status propagated consistently
from the fit and summary into each plot surface.

## Interpretation boundary

`InferenceReady = TRUE` means that the numerical optimization gate passed. It
does not override a disconnected-design, data-quality, or separation hold.
Likewise, a status requiring diagnostic follow-up is not an optimization
failure and is not manuscript readiness. The protocol therefore records
upstream reporting holds, diagnostic review requirements, and pending
diagnostic follow-up separately instead of collapsing them into a single
"report ready" flag.

Large-data memory profiling, real graphics-device rendering, cross-platform
font behavior, recovery performance, and external-software numerical overlap
remain separate release checks.
