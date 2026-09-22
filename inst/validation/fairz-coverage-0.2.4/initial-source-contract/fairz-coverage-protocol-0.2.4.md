# Fixed-reference FairZ coverage confirmation

Date: 2026-09-10. Frozen before the new preflight/confirmation outcomes.
This is the fixed-reference continuation of the
[Fair Score protocol](fair-score-refit-protocol-0.2.4.md), following the
[eight-cell numerical/refit audit](interval-drf-preflight-record-0.2.4.md).
It adds no public inference eligibility or release approval.

## Question, generation and estimands

When the declared response model and fixed population are correct, do the
joint-covariance FairZ SEs describe repeated-calibration variation and do
their 95% intervals cover the fixed-reference true expected scores?

Reuse `mml_coverage_cells()` and `mml_information_fixture()` without changing
their generation or constraints: RSM then PCM, within each N=80/320 and
3/6 ratings per Person; three raters, two criteria, categories 0:2, unit
weights, fixed independent N(0,1) Persons. Three-rating assignments use the
existing alternating pattern; six-rating assignments are fully crossed.
Keep all generated extreme responses. Rater effects (0.3,-0.1,-0.2),
criterion effects (0.4,-0.4), RSM steps (-0.6,0.6), PCM criterion steps
(-0.7,0.7) and (-0.2,0.2) already obey the fitted location constraints.
This independent fixture therefore does not inherit the uncentered-facet
issue found in the separate public-generator DRF execution cases.

The five targets in **every** cell are FairZ for R1, R2, R3, C1 and C2.
Other-facet/Person reference values are fixed at zero. Criterion targets use
their own threshold profile; rater targets use the mean threshold profile.
Truth and analytic gradients reuse the independently mapped softmax
`fair_reference()` from the earlier pilot. Do not average category
probabilities across criteria instead of averaging the declared thresholds.
No target is removed in response to the earlier RSM R3 coverage of 16/20.
Person/FairM, DRF/interactions, anchors, estimated populations, weights,
GPCM/JML, paired changes and boundary-stress qualification are separate studies.

## Methods and numerical checks

Each independent dataset receives a fresh complete public `fit_mfrm()` fit:
direct MML, q61, maxit=200, reltol=1e-10, including Person rescoring.
The primary method is `joint_structural_candidate`, with SE sqrt(g' V g)
using every free effect/threshold coordinate and the unregularized q61
observed-information covariance. The secondary `conditional_measure`
comparator uses Var(score) times the focal measure SE, holding thresholds
and other parameters fixed. Both methods use the same fitted FairZ and data.
They are paired comparisons, not independent replications.

Both intervals are normal 95% intervals clipped to [0,2]. Store both clipped
and unclipped endpoints. With truth in [0,2], clipping preserves coverage,
but changes width; verify this identity and compute width from actual
endpoints. Report clipping frequency. Missing/nonfinite estimates or SEs,
nonpositive SEs, nonready q61 fits and unavailable/regularized q61 covariance
produce unavailable intervals. Preserve finite point estimates separately.
Numerical q121 disagreement does **not** remove an otherwise available
interval from coverage. Public `FairCIEligible` remains false for both methods.

For every dataset, evaluate q121 information, objective and gradient at the
q61 fitted parameters. Require unregularized covariance at both grids,
objective change <=1e-6, maximum relative target SE change <=0.001 (both
methods), and maximum q121 Newton displacement/q61 parameter SE <=0.001.
Any inference-ready fit that fails these checks is a numerical conflict.
This evaluation is not a higher-grid refit and never replaces the q61 fit.

For the first preflight dataset in each cell, additionally check analytic
against numerical gradients (<1e-7), public FairZ (<1e-9), and public
conditional plot SEs (<1e-8). Reoptimize the entire model at q121 from scratch
and rescore Persons: require both-grid readiness/covariance, target score and
clipped endpoint changes <=1e-5 and relative SE changes <=0.001. Record all
parameter, objective and Person EAP changes without inventing new cutoffs
for them. These eight extra fits are numerical checks, not extra replicates.

## Sample size, metrics and decisions

Confirmation is fixed at **2,500 independent datasets per cell; 20,000 total**.
At true coverage 0.95, planning MCSE is sqrt(.95*.05/2500)=0.00436; the
approximate 95% half-width is 0.00854. This is a coverage precision choice,
not a promise that every bias/SE-ratio interval will resolve. An inconclusive
result remains review; do not extend the run until it passes.

Reuse `mml_coverage_coordinate()` and its existing performance MC intervals
from the [structural protocol](mml-structural-coverage-protocol-0.2.4.md).
Report finite-estimate bias/RMSE and their MCSE; on each method's available
subset report empirical SD, RMS SE, RMS-SE/SD, standardized bias, coverage,
actual clipped width and MC uncertainty. Denominators remain separate:
assigned, attempted, finite estimates, available intervals, covered intervals.
Available-and-covered / assigned is a joint usability rate, not coverage.
Store every target/method row even when unavailable; no pooling across
targets/cells and no treating the five targets as independent repetitions.

For a target/method to be supported within its cell, require all original
rules: the exact 95% coverage MC interval wholly inside [0.93,0.97];
RMS-SE/SD MC interval inside [0.90,1.10]; standardized-bias MC interval
inside [-0.10,0.10]; exact availability lower bound >=0.99; zero observed
ready numerical conflicts with exact upper rate bound <=0.002. At 0/2500
the latter is about 0.00147, not zero. A wholly adverse performance interval
is concern, boundary overlap is review, and unfinished cells are incomplete.
Use the same subsets and influence-function MCSEs as the structural protocol.
Monte Carlo intervals are coordinatewise; they are not simultaneous bands.

The primary cell decision requires all five joint-covariance targets to pass.
The comparator is reported separately and cannot substitute for or veto the
primary candidate's target-specific evidence. Also report paired changes in
coverage and width, with MCSEs on the common-available datasets. Different
availability sets are explicit. Preflight results are always `preflight_only`,
never supported/concern statistical conclusions at five replications.

## Preflight, source identity and resources

Use five fresh datasets per cell for preflight (40 total), excluded from
confirmation. For cell IDs 1:8 in the above order:

* Preflight seed = 76000000 + 10000*cell + replicate, replicate 1:5.
* Confirmation seed = 77000000 + 10000*cell + replicate, replicate 1:2500.

These ranges are disjoint from previous Fair Score, structural, DRF and
population studies. Freeze every R source file, DESCRIPTION/NAMESPACE, the
runner, this protocol and transitive repository helper/protocol sources.
Keep source snapshots and hashes; recheck on checkpoint/resume. Refuse mixed
stage/source/plan, duplicate or out-of-order seeds, and corrupt result shapes.
Confirmation execution requires all eight matching-source preflight cells to
be complete and pass their execution/numerical checks. This is a computational
prerequisite, not a new human-approval step or a statistical preflight gate.

Reuse per-cell RDS checkpoints with atomic rename, every 50 main datasets
and every preflight dataset. Results, warnings/errors, readiness, covariance
status, seed and all target values are retained; save complete fit/data details
for preflight and adverse runs. Generation errors also retain their assigned
identity. Resume only the identical payload, without replacing failed seeds.
The four-hour per-invocation ceiling leaves explicit incomplete results and
can be resumed. No coverage-driven stopping, new optimizer/grid retry or
favorable-result regeneration is permitted. A demonstrated implementation
defect triggers review of source applicability, preserving the old evidence.

Measure generation, q61 fitting, covariance/score computation, q121 evaluation
and additional preflight verification separately. Project the exact main
procedure using per-cell preflight core times, reporting their range and
checkpoint overhead. At most three local R processes may use disjoint cell
sets; there is no agent delegation or external computation. Do not infer a
parallel speedup from serial timings alone. Execution preparation and the
40-dataset preflight are the current bounded increment; the main run remains
unrun until the resulting protocol/source/timing review is recorded.
