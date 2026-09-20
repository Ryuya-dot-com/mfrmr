# RSM/PCM structural uncertainty: applicability to current source

Date: 2026-09-20. Numerical continuity is verified for the recorded replay
panel. Historical sampling results retain their original source and interval
availability; this is not a rerun of their coverage or whole C05 closure.

## Question and release consequence

Can the existing structural-SE evidence still inform 0.2.4 after the
Gauss–Hermite repair and subsequent reporting/readiness changes? The relevant
user result is the uncertainty of constrained facet and threshold estimates,
not Person posterior SD, reliability, a fit-adjusted band or an arbitrary
downstream test.

The [original 20,000-dataset study](mml-structural-coverage-record-0.2.4.md)
and [fresh 30,000-dataset confirmation](mml-structural-bias-confirmation-record-0.2.4.md)
used direct, fixed-q61 RSM/PCM MML with a correctly specified standard-normal
Person distribution, unit weights, no anchors/interactions, three Raters,
two Criteria and categories 0–2. They evaluated linked assignments with 80 or
320 Persons and three or six ratings per Person; the fresh study retained
three of those cells. They are separate studies with their original cell-wise
criteria and denominators, not 50,000 replications per condition.

The current structural-SE implementation retains its numerical support in the
replayed conditions. The sampling studies can remain evidence within their
original scope, accompanied by this numerical continuity check. Their exact
availability and conditional-coverage percentages must not be relabelled as
current-source results: 15 of 18 formerly unavailable fits now return success.
No public calculation or acceptance threshold needs changing to make those
old results pass. Nonzero optimizer codes remain subject to the existing
review restriction.

## Source reconstruction and relevant differences

The archived base commit `df609a30a2dc8ec226d6acdca2fbf963fe502ee6`, its saved
working diff and the archived helper texts reconstruct **all 88 original
payload files byte for byte**. Both sampling studies used this same production
payload. The two native source files are unchanged. Parsed R comparisons
ignore comment/format changes; the static dependency trace is supplemented by
reading the relevant branches, since it also reaches inactive diagnostic and
other-model paths.

| Change | Consequence for the original sampling target |
| --- | --- |
| Standard-normal Gauss–Hermite nodes/weights | Active numerical change. The old q61 rule loses four representable tail weights; current weights use the repaired recurrence, with symmetrized nodes. Replayed explicitly below. |
| Adaptive-integration branches | Inactive for the original fixed-integration calls; fixed remains the default. The old sampling studies do not qualify adaptive interval coverage. |
| Nonrepresentable population-variance trial guard | Inactive with a fixed standard-normal population; no estimated variance coordinate exists in these studies. |
| Input IDs converted to UTF-8 | Original ASCII Person/Rater/Criterion IDs and data order are retained. |
| Non-unit-weight readiness restriction | Original unit-weight cases remain within scope; numerical weighted-likelihood agreement does not supply a sampling covariance. |
| Regularized/fallback SE restrictions and output labels | Original accepted intervals required an unregularized covariance and finite positive SE. Restrictions now remain explicit through reports; they do not change these accepted SE formulas. |
| Readiness version and supplied-diagnostics checks | Old fits are not silently promoted to current eligibility. Current eligibility is examined on actual current refits, using unchanged numerical acceptance rules. |

The parameter sizes and slices, initial-value builder, observation indexing,
fixed-grid cached likelihood/gradient, information inversion, zero-sum
Jacobians, covariance-to-SE mapping and facet-SE builder are unchanged parsed
functions. The structural-step builder adds eligibility metadata; its SE and
normal-interval arithmetic is unchanged. The covariance builder adds only an
adaptive branch, which is inactive here. The optimizer now protects additional
invalid trial proposals; the original target has neither free slopes nor
estimated population variance, and its retained numerical-readiness rule is
unchanged.

## Saved independent-information fixtures

All 13 fixtures from the [independent-information record](mml-independent-information-conditions-record-0.2.4.md)
were reused at their original parameter vectors, data and fixed q61 settings.
They cover RSM/PCM, baseline, direct/group anchors, interactions, population
regression, non-unit weights and a four-category PCM. Current covariance and
expanded/pair SEs were compared against the already saved independent
whole-line-integration references. No model was refitted and no independent
reference Hessian was regenerated.

All retain the original numerical criteria. Maximum current/reference
discrepancies are:

| Quantity | Maximum |
| --- | ---: |
| Negative log-likelihood discrepancy bound | 4.945e-7 |
| Score difference | 7.663e-6 |
| Hessian difference normalized by overall information scale | 1.467e-7 |
| Covariance entry difference scaled by reference marginal SDs | 3.960e-7 |
| Relative expanded facet/step SE difference | 1.170e-7 |
| Relative pair-contrast SE difference | 1.170e-7 |

The first entry uses the triangle inequality: the saved old/reference absolute
discrepancy plus current/old objective movement. Current versus original
package covariance changes by at most 3.632e-13 on the same scaled metric;
expanded SE changes relatively by at most 1.815e-13. Fixed-coordinate SEs
remain zero. Stored fit objects are unchanged. Their obsolete readiness
records are not reclassified as current formal-inference support.

These are numerical fixtures. Their anchored, weighted and population cases
do not extend the sampling study's empirical coverage claims.

## Exact-data replay and the availability finding

Before replay, the selection and tolerances were fixed in
`validation-results/structural-source-applicability-20260920/replay-plan.md`:
all 40 original preflight datasets, all 15 later preflight datasets, and every
interval-unavailable confirmation dataset (six original, twelve later).
The 73 recorded seeds, truths, unchanged generator and fixed q61 settings were
verified. Each dataset was fitted under current code with the original
maxit 200 and reltol 1e-10. No seeds were added to a sampling study, replaced,
or selected by current results; no historical summary was overwritten.

All 73 numerical comparisons pass the frozen replay criteria:

| Quantity | Maximum |
| --- | ---: |
| Current/original coordinate movement divided by original SE | 1.801e-6 |
| Relative current/original SE movement | 3.449e-8 |
| Old/new q61 objective difference at the original parameters | 3.070e-12 |
| Old/new q61 score difference at the original parameters | 5.658e-13 |
| Current q61/q121 objective difference at the fitted parameters | 4.868e-9 |
| Current q61/q121 relative SE change | 7.967e-10 |
| Current q121 Newton displacement divided by q61 SE | 1.090e-5 |

All 55 preflight datasets retain available intervals. Of the 18 originally
unavailable fits, 15 now become available and three remain unavailable. The
old warning records identify optimizer code 52 despite small terminal
gradients. Current versions of the 15 changed fits return code zero. The
change is not a relaxed gradient tolerance or an overwritten readiness flag.

To attribute this finding, a separate diagnostic replay of all 18 cases
temporarily replaced only the current quadrature function with its archived
definition inside an isolated R process. **Every original point estimate, SE
and availability decision then matched exactly**, including all 18 unavailable
states. Thus the quadrature change is sufficient to explain the transitions
in this panel. The old rule was not restored to the package, and these
counterfactual results are not current calibration artifacts.

Tiny objective differences can change an optimizer's termination result even
when estimates and SEs barely move. Keep the returned warning/success state;
do not force old and new availability to agree. This replay does not establish
that all formerly available confirmation datasets remain available: those
datasets were not exhaustively refitted. The old conditional-coverage and
available-and-covered denominators therefore retain their historical identity.

## Scope to retain for 0.2.4

| Result or workflow | Release treatment supported by this review |
| --- | --- |
| Unregularized structural facet/threshold SEs under the original fixed-normal, unit-weight additive RSM/PCM conditions | Retain the existing implementation and bounded historical sampling evidence, with current numerical continuity documented. Do not advertise the old percentages as a newly completed current-source coverage study. |
| Default q31 or adaptive integration | Retain existing implementation/numerical evidence and same-data integration review. The q61 sampling results are not automatic validation of another integration rule. |
| Direct/group anchors and interactions | Retain compatible implementations and existing identification restrictions. Saved independent covariance agreement is numerical evidence; finite-sample coverage in these designs remains a separate claim. |
| Non-unit row weights or estimated populations | Keep their existing inference restrictions. Powered-likelihood curvature and population-coordinate agreement do not establish their sampling covariance or interval coverage. |
| Person posterior intervals, fit-adjusted SEs, reliability/separation, TOST and multiple comparisons | Keep separate targets and evidence. Structural-parameter normal-interval coverage does not qualify these quantities or their decision error rates. |
| JML and GPCM | Keep their existing estimator-specific uncertainty restrictions; no support is transferred from the RSM/PCM study. |

The reproduced source-applicability question now has a concrete answer, rather
than a blanket instruction to rerun all prior studies. Stronger claims outside
these conditions remain restricted or need their own stated evidence. This
review does not launch a new large sampling study, remove existing restrictions,
or declare all uncertainty questions necessary prerequisites to a bounded
0.2.4 release. Final integrated workflow and platform checks still belong to
the eventual release candidate.

## Evidence identity and reproduction

Artifacts are in `validation-results/structural-source-applicability-20260920/`:
the restored-source manifest, AST comparisons, original selection, all replayed
fits, covariance matrices, CSV summaries, counterfactual attribution and logs.
The replay scripts are repository-only and excluded from package archives.

Current production code is unchanged from the checked archive
`09b0f07db2ade6e79e7c5656aa1429e1c6e8c8a2c51dd10214118b59b0fc8bdb`
over working-tree base `ff0675b8d54aa51f4f24ffc6948a460f1d7261a1`.
This follow-up changes maintainer evidence and sequencing only; it adds no
public status labels, NEWS claim, package function or dependency. The earlier
package-check result is reused, not reported as a new full-suite or platform
test. Both source and historical runs use the recorded local R 4.6.1 runtime;
current source/session hashes are retained with the replay.
