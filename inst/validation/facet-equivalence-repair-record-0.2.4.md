# 0.2.4 facet-equivalence repair and revalidation

Date: 2026-09-09. Status: reproduced calculation and output defects repaired;
statistical validation and release review remain open.

Follow-up: the [additional independent information checks](mml-independent-information-conditions-record-0.2.4.md)
found a remaining singular-contrast admission under a PCM direct anchor.
That successor repair adds an explicit constraint-rank check and requires
its record in saved bundles. The full-package result below predates this
follow-up; its exact source identity is retained rather than presented as a
check of the newer source.

This record follows the [initial public-claim audit](public-claim-evidence-review-0.2.4.md).
Its original runtime and covariance CSVs remain unchanged. This work changes
production code on base commit `df609a30a2dc8ec226d6acdca2fbf963fe502ee6`;
the fixes and documentation are uncommitted working-tree changes.

## Question and correction

Can a facet-equivalence result respect the source fit's inference restrictions
and use the joint uncertainty of the effects it compares?

`analyze_facet_equivalence()` now requires an inference-ready MML fit and
unregularized observed-information covariance. It reuses the existing native
diagnostic-identity validator and checks supplied facet-level SEs and
eligibility. All calculations use the actual fit's estimates and covariance;
supplied diagnostics cannot make an ineligible fit eligible or replace its SEs.

The existing constraint Jacobian expands free-parameter covariance. Pair SEs
include the covariance term, and a joint contrast Wald test replaces the
diagonal-only heterogeneity calculation. All target levels must be retained;
singular joint contrast covariance is rejected rather than dropping levels or
assigning an arbitrary pseudoinverse-based test. Thus some anchored/group-
constrained target facets have no equivalence result. This is an explicit
restriction, not a validation of every possible anchor structure.

Grand-mean proximity now uses the equally weighted facet mean and the full
covariance of each deviation from that mean. Marginal `Measure`/`SE`/CI columns
remain available; forest plots use the separate deviation intervals around
zero. The ROPE chart is descriptive and no longer adds evidence-strength
threshold colors. The unsupported BF heuristic is unavailable (`BF01 = NA`);
a Wald statistic does not supply the fitted likelihood comparison it needs.

Pairwise TOST remains a normal-approximation procedure at alpha 0.05, with
unadjusted pairwise p-values and 90% intervals. The selected display `ci_level`
does not change that test. The distinction between pairwise, joint, and
multiplicity-adjusted tests is also described in the primary
[emmeans documentation](https://rvlenth.github.io/emmeans/articles/confidence-intervals.html).
The package adds no dependency on emmeans.

`summary()`, `print()`, and both plotting routes reject old equivalence bundles
without the current inference/covariance basis. Documentation, examples, the
interval guide, cheatsheet and NEWS describe the changed behavior. Direct
access to previously saved raw tables is naturally still possible; they must
not be read as recomputed results.

## Numerical and restriction results

The [same six-fit replay](facet-equivalence-repair-runtime-0.2.4.csv) uses the
initial audit's one dataset, models, estimators, integration settings and two
practical bounds. No independent recovery replications were added.

| Observation | Before | After |
| --- | --- | --- |
| MML GPCM and JML RSM/PCM/GPCM, at bound 0.5 | Each declared 2 of 6 pairs equivalent despite unavailable ordinary inference | All four calls stop with an inference-eligibility error |
| Same four fits, at diagnostic bound 5 | Each declared all 6 pairs equivalent | All four calls stop |
| MML RSM/PCM pair SEs | 12.708%--13.996% below covariance-aware calculation | All 12 pair discrepancies are zero in the replay |
| MML RSM/PCM pair decisions | 2 of 6 at bound 0.5; 6 of 6 at bound 5 | Same counts in this dataset; no claim that every correction changes a decision |

The [pair-level numeric record](facet-equivalence-repair-covariance-0.2.4.csv)
retains the calculations. For PCM R02 minus R04, the repaired SE is 0.136746,
versus the previous 0.117607. No warnings were emitted by the six-fit replay.

Independent analytic regressions in `tests/testthat/test-facet-equivalence.R`
go beyond agreement with the package's covariance helper:

- With four centered independent normal errors of variance 0.02, every pair
  has SE 0.2. For a zero observed difference and bound 0.3, the correct TOST
  p-value is about 0.0668, so equivalence is not established. The previous
  marginal-only formula incorrectly gave a positive decision.
- A known fixed anchor and three independent errors verify uncertainty in
  the estimated mean: deviation variances are `(3, 11, 11, 11) * 0.02 / 16`.
  The fixed level is retained, and all six pair contrasts are checked.
- Negative cases cover unavailable/regularized/singular covariance,
  ineligible fits, changed/partial/ineligible supplied diagnostics, and legacy
  or ineligible bundles through summary, print and plots.

## Checks and reproduction

The [focused test result](facet-equivalence-repair-tests-0.2.4.csv) has 78 test
cases across 12 files: 1,036 passed expectations, no failures/errors/skips and
five expected category-support/GPCM-review/IC-suppression warnings. The first
broader run caught missing explicit `quad_points` in the new MML help examples;
the examples were corrected to 31 and the focused run then passed. Both help
examples were executed separately, and forest/ROPE plots were visually checked.

The current-source runner now asserts the repaired restrictions and contrast
calculation. Save its output separately from the historical audit CSVs:

```sh
Rscript inst/validation/public-claim-evidence-audit-0.2.4.R /tmp/mfrmr-equivalence-repair
```

The final working-tree source package completed `R CMD check --no-manual
--as-cran` with `NOT_CRAN=true`: **0 errors, 0 check warnings, 2 NOTEs**.
The [check log](facet-equivalence-package-check-0.2.4.log) records all completed
stages, including ordinary examples (18 seconds), `donttest` examples (128
seconds), package tests (1,076 seconds) and vignette rebuilding (37 seconds).
The exhaustive `NOT_CRAN=true` workload is not the CRAN-light test workload.

Package tests reported **16,546 passed expectations, 0 failures, 40 warning
conditions and 45 skips**. The [skip accounting](facet-equivalence-package-tests-0.2.4.txt)
preserves the reasons: 32 require excluded repository validation artifacts,
12 require source help/documentation/package files, and one fresh-process
calibration check requires its installed-package execution context. Skips are
not passes. Warning conditions were 35 category-support notices, three
GPCM review-only displays and two suppressed-IC notices. The two check NOTEs
concern unavailable remote time verification and compiler-created `xcrun_db`
temporary-directory contents. Neither is reclassified as a clean check.

The source-dependent `documentation-terminology` and `api-s3-consistency`
files were then run from the working source: 432 expectations passed, with
no failures, warnings or skips. This supplies a separate execution for the
12 source-file-dependent skips; it does not rewrite the package test result.
The public/internal roadmap checks also passed 54 expectations.

The checked tarball's SHA-256 is
`0f79b7f326fcb2d3faec07241fbd27a1c943de42447ad404d5f9137bae6b9e00`.
All nine modified package files were byte-compared with the final working
source. The repository-only audit/pilot files are excluded from that tarball
and were executed separately. The earlier check was stopped after the help
example correction; no completed result is claimed for that preceding build.

## What remains open

This closes the reproduced C09 implementation defects. It does not establish
the independent accuracy of the MML information matrix, frequentist SE/CI
calibration, finite-sample TOST behavior, or validity under misspecification.
The normal-reference tests validate contrast calculations, not the estimation
procedure that supplies a real fit's covariance. Known-anchor results exclude
anchor estimation uncertainty.

A separate [first RSM information pilot](mml-independent-rsm-information-record-0.2.4.md)
has now begun C05 with an independent calculation in one balanced fixture.
Next extend that check to PCM and the remaining claim conditions, followed by
the prespecified SE-versus-SD, interval coverage, availability and false-ready
evaluation. Full-model GPCM, estimator-specific JML and remaining secondary-
route reviews retain their separate requirements. No release, submission,
tagging, or inferential support promotion is performed here.
