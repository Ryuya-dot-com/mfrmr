# Fresh structural-bias confirmation: execution record

Date: 2026-09-09. Status: complete. All three fresh conditions and all 37
primary coordinate checks are supported under the fixed criteria. The three
prespecified secondary mechanism targets are also supported. Release review
remains open beyond this bounded result.

The [fixed protocol](mml-structural-bias-confirmation-protocol-0.2.4.md)
retains original cells 1, 5 and 7, all 37 coordinate checks and the original
conditional primary criteria. Each cell has 10,000 fresh datasets. The
score/curvature decomposition is a separate, prespecified secondary measure;
it cannot replace available-only bias or override a primary review/concern.
The [runner](mml-structural-bias-confirmation-0.2.4.R) reuses the frozen fitting,
uncertainty and performance-summary functions, with an explicit seed offset.

## Preflight and computational basis

Fifteen excluded preflight datasets completed without fitting errors,
secondary-calculation errors or numerical conflicts. All 15 were inference
ready, and fast seed replay matched the original generator exactly. Existing
public diagnostic and pair-SE comparisons passed. After tightening the
secondary summary's missing-value handling and checking named scalar inputs,
the same 15 seeds were replayed with the final source; their outcomes remain
preflight only. The protocol and production formulas were unchanged.

The secondary approximation MCSE was checked against leave-one-out jackknife
calculation on 2,000 deterministic skewed errors with correlated remainders.
The influence MCSE was 0.001085675 and jackknife MCSE 0.001089857, a ratio
within the stated 2% check tolerance. A negative-direction counterexample
produces concern, and a missing estimate cannot produce a complete mechanism
conclusion. The existing primary-summary self-check also passed.

| Original cell | Model / Persons / ratings | Final preflight ready | Core pipeline mean (s) | Conservative combined mean (s) |
| --- | --- | ---: | ---: | ---: |
| 1 | RSM / 80 / 3 | 5/5 | 0.5086 | 0.5532 |
| 5 | PCM / 80 / 3 | 5/5 | 0.3082 | 0.3230 |
| 7 | PCM / 320 / 3 | 5/5 | 0.6982 | 0.7648 |

Core timing excludes the preflight-only public diagnostic comparisons.
The conservative combined time adds the secondary computation and its
preflight-only generator identity check, with initial compilation/warmup
especially affecting cell 1. The resulting three-process projection is
about 91 minutes, before workload imbalance. This is a forecast, not measured
confirmation runtime. Ten fixed blocks of 1,000 per cell are rotated across
three workers. All results are checkpointed; no statistical early stop or
favorable-result replacement is allowed.

## Execution and integrity

The fixed confirmation ran from 21:20:35 to 22:42:54 JST on 2026-09-09,
about 82 minutes 19 seconds. The three workers completed in approximately
74.58, 75.34 and 82.29 minutes and all exited successfully. Every planned
block contains its 1,000 assigned datasets; no resource ceiling, statistical
early stop, added replication or replacement seed was used.

Aggregation verified the 30 block identities, all 30,000 sequential
cell/replication identities, the exact seed formula and distinct seeds. The
15 final-source preflight seeds are separate from the new and old confirmation
seeds. The production source, helpers, protocol and both old evidence archives
match the frozen fingerprints. Expanded parameter names, truth coordinates
and response-pattern counts also agree. CSV files and the RDS archive were
read back and checked against the assembled results.

The [evidence archive](mml-structural-bias-confirmation-evidence-0.2.4.rds)
contains all estimates, SEs, availability flags, warnings, numerical checks,
pattern counts and first-order displacements, plus the final preflight,
source/protocol identities, helper texts, block fingerprints, worker logs,
finalizer, source diff and R session. It is 8,515,496 bytes. The underlying
source is the unchanged 0.2.4.9000 validation payload based on commit
`df609a30a2dc8ec226d6acdca2fbf963fe502ee6` and the archived local source diff.

## Primary answer: the three conditions meet the retained criteria

The [coordinate summary](mml-structural-bias-confirmation-summary-0.2.4.csv)
retains every original target, including constrained and proportional copies.
The [run summary](mml-structural-bias-confirmation-runs-0.2.4.csv) separates
availability and failures from conditional performance. Coverage and SE ratios
below are ranges across all coordinates in a cell; they are not pooled across
coordinates or cells. SE ratio means RMS reported SE / empirical error SD.

| Original cell | Model / Persons / ratings | Available / assigned | Coverage range | SE-ratio range | Largest absolute standardized bias | Supported rows |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| 1 | RSM / 80 / 3 | 9,998 / 10,000 | 94.669--95.199% | 0.99158--1.00423 | 0.07214 | 11 / 11 |
| 5 | PCM / 80 / 3 | 9,999 / 10,000 | 94.839--95.650% | 0.98283--1.00738 | 0.05587 | 13 / 13 |
| 7 | PCM / 320 / 3 | 9,991 / 10,000 | 94.795--95.176% | 0.99154--1.00153 | 0.02907 | 13 / 13 |

All 37 coverage MC intervals lie inside [0.93, 0.97], all SE-ratio MC intervals
inside [0.90, 1.10], and all standardized-bias MC intervals inside [-0.10, 0.10].
The most distant bias MC endpoint has magnitude 0.09179. Exact availability
lower bounds are 0.999278, 0.999443 and 0.998292, each above 0.99. With zero
ready numerical conflicts, each exact upper rate bound is 0.00036882, below
0.002. Thus no primary row is review or concern in this fresh study.

For the three directions selected before this run, the conditional bias
results are:

| Cell / coordinate | All-estimate mean error | Available-only mean error | Available-only standardized bias | 95% bias MC interval |
| --- | ---: | ---: | ---: | ---: |
| 1 / shared Step 2 | 0.0105068 | 0.0104700 | 0.07214 | [0.05250, 0.09179] |
| 5 / C1 Step 2 | 0.0098742 | 0.0098517 | 0.04912 | [0.02949, 0.06875] |
| 7 / Criterion C1 | 0.0015650 | 0.0015344 | 0.02907 | [0.00946, 0.04868] |

In cell 5 the largest standardized bias belongs to the Criterion contrast
direction (0.05587; MC interval [0.03633, 0.07542]), not its Step 2 mechanism
target. All original coordinates were retained so this distinction does not
change the decision. Pointwise intervals and sign/proportional copies do not
provide independent replications or simultaneous 95% confidence.

## Secondary answer: small curvature bias reproduces on fresh data

The [mechanism summary](mml-structural-bias-confirmation-mechanism-0.2.4.csv)
uses all 10,000 finite estimates per cell. Let L be the displacement from the
score at the true parameters and R be estimate minus truth minus L. Its
coefficient is fixed at one, and the known unconditional expectation of L is
zero. The following are Monte Carlo means, in the original coordinate units:

| Cell / target | Raw mean error | Mean L | Mean R [95% MC interval] | Frozen curvature prediction | Mean-L Z |
| --- | ---: | ---: | ---: | ---: | ---: |
| 1 / shared Step 2 | 0.0105068 | 0.0017198 | 0.0087869 [0.0085983, 0.0089756] | 0.0087120 | 1.197 |
| 5 / C1 Step 2 | 0.0098742 | 0.0021270 | 0.0077472 [0.0074979, 0.0079965] | 0.0076479 | 1.078 |
| 7 / Criterion C1 | 0.0015650 | 0.0003469 | 0.0012181 [0.0011850, 0.0012512] | 0.0011879 | 0.664 |

All three remainders are positive with their MC intervals above zero. All
mean-L Z statistics remain inside the prespecified +/-3.29053 review bound.
The standardized difference D between the mean remainder and the frozen
order-1/N prediction has the following 95% MC intervals:

- Cell 1: [-0.000785, 0.001818].
- Cell 5: [-0.000750, 0.001740].
- Cell 7: [-0.000052, 0.001196].

Each interval lies well inside the prespecified explanatory tolerance of
[-0.01, 0.01] sampling SD. The fresh results therefore reproduce a small
positive finite-sample component consistent with likelihood curvature,
with ordinary Monte Carlo variation adding to the raw mean errors. Bias has
not disappeared. Its magnitude meets the retained primary practical margin
in these conditions. The unconditional decomposition neither estimates
available-only bias nor supplies a correction to public estimates or CIs.
This study also does not independently repeat the full N-scaling diagnostic.

## Numerical checks, warnings and availability

All 30,000 q61-to-q121 numerical checks passed. Maximum objective change was
3.153e-9, maximum relative expanded-SE change 2.776e-9, and maximum scaled
Newton displacement 2.114e-5; each is below its frozen bound. There were no
fitting or secondary-calculation errors. All estimates were finite.

Twelve fits emitted the existing convergence warning with optimizer code 52
and `terminal_gradient_review`: two in cell 1, one in cell 5 and nine in
cell 7. Their terminal gradients were within the review tolerance, but the
nonzero optimizer code prevented inference readiness. All twelve also passed
the q121 numerical checks. They retain their original unavailable status;
numerical agreement does not retroactively admit their intervals. Their seeds
are preserved explicitly:

- Cell 1: 62017040, 62017175.
- Cell 5: 62058239.
- Cell 7: 62072097, 62072166, 62072302, 62072609, 62074715, 62074872,
  62077553, 62077997, 62078428.

They remain in all-attempt availability denominators and the unconditional
mechanism analysis. The primary coverage, SE scale and standardized bias use
only the original available fits, as planned. The coordinate CSV also keeps
available-and-covered / assigned separately from conditional coverage.

## Disposition and remaining work

This fresh, fixed-size study resolves the selected bias uncertainty for its
three tested conditions under the original primary criteria. The original
20,000-dataset study remains five supported cells and three review cells in
its own record; no historical judgment was overwritten and no results were
pooled. The new evidence supports the three repeated cells separately.

The scope is q61 direct RSM/PCM MML, three balanced ratings per Person, the
specified parameter values and categories, unit weights and a correctly
specified fixed standard-normal population. It does not validate default q31,
arbitrary sparse/long-response designs, estimated population parameters,
weighted-objective sampling covariance, anchors, Person-score uncertainty,
or the calibration of joint Wald/equivalence decisions. Those retained public
claims need their own evidence or enforced restrictions. Full GPCM,
estimator-specific JML, output restrictions and final release-source checks
remain separate work under the controlling roadmap. No release or new bias
correction is authorized by this result.
