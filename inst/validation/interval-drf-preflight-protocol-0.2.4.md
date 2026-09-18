# Interval contract and DRF execution preflight — 2026-09-10

Repository-only bounded follow-up to priorities 0–2 in the active internal
roadmap. This protocol is written before running the cases below. It does not
replace the earlier Fair Score pilot or authorize a coverage confirmation.

## September 18 addendum: null statistic and existing likelihood route

Before another error-rate study, check whether the residual statistic is
centered under a no-DRF model. Enumerate all 64 binary response patterns for
one Person rated by three raters (-0.4, 0, 0.4) on two criteria (-0.3, 0.3).
Steps are zero, weights one and responses conditionally independent. Both
groups share every response parameter; abilities follow N(0,1) and N(0.6,1).
Treat calibration and both population distributions as known to isolate the
EAP substitution from parameter-estimation error. Integrate over the real
line with base R `integrate()` (relative tolerance 1e-10, absolute 1e-12).
Calculate exact-pattern-weighted residual means, Person-level covariance and
the variance proxy used by the current residual screen. Contrast evaluation
at posterior mean ability with posterior integration of expected scores.
Check pattern probabilities sum to one and the integrated residual means
are zero within 1e-9. Report either result for the EAP substitution; this is
a deterministic reference calculation, not an empirical false-positive rate.

Then reuse the four saved final RSM/PCM `group_mean_only` and `drf` datasets
without resampling. Fit nested joint MML models with `population_formula =
~ Group`, `dummy_facets = "Group"`, and respectively no interaction versus
`facet_interactions = "Rater:Group"`. Both fits retain the same facets,
scores, population regression and common estimated variance. All nuisance
parameters are reestimated in both models. The joint null is zero rater-by-
group interaction; the full 3-by-2 interaction adds two free coordinates.
Use q61/maxit200/reltol1e-10 and existing public `compare_mfrm(nested = TRUE)`
without overriding readiness or comparison restrictions. Check likelihoods
by independent continuous integration at retained estimates (absolute NLL
difference <=1e-5), nesting and parameter counts. Retain all errors and
unavailable outputs; no favorable p-value is a pass criterion. This is an
existing-workflow feasibility check, not qualification of finite-sample
chi-square calibration or a new per-rater decision API.

## September 18 follow-up: information at the joint null

The fitted alternative's local rank does not establish regularity at zero
interaction. Reuse the four saved joint-fit pairs from the preceding addendum;
do not generate data or refit. Embed each null vector in the alternative by
matching the complete coordinate maps and setting only the two interaction
coordinates to zero. Check likelihood equality within 1e-8 and retain the
existing public comparison decisions and every unmet comparison condition.

At these four embedded-null points enumerate the two complete six-rating,
three-category group designs. Independently implement the constrained RSM/PCM
probabilities and normal integration, using total-score sufficiency to reuse
the 13 integrals per group. Central-difference the log pattern probabilities
at absolute steps 1e-4 and 5e-5. Check probability sums (1e-9), expected scores
(1e-7), step agreement (1e-7), and agreement with the existing q61 all-pattern
information (absolute entry discrepancy 1e-5); retain any failures unchanged.
Report unscaled rank at relative tolerances 1e-12, 1e-10 and 1e-8, and the
two eigenvalues of interaction information adjusted for all nuisance
coordinates. Positive information is a retained-point regularity diagnostic,
not global identification, a boundary certificate or finite-sample LRT
calibration. No p-values or inference-readiness promotion are authorized by
this check. A warning-only repair may replay the saved comparisons; its
regression check must preserve withheld results and numerical values.

## Questions and design

1. Does the fixed-reference, non-Person FairZ joint-delta calculation retain
   its meaning across sample sizes and exposure, numerical differentiation,
   changes of coordinates, full higher-grid refits and output routes?
   Use RSM/PCM × N 80/320 × 3/6 ratings per Person, one fresh dataset per cell,
   reusing the independent information fixture and Fair Score analytic oracle.
   Seeds are 73000000 + 10000 × model index + 100 × N + exposure (RSM=1,
   PCM=2). Refit every dataset at q61 and q121, maxit 200, reltol 1e-10.
   Reestimate every free structural coordinate and rescore Persons. Population
   remains fixed N(0,1), unit weights, scores 0:2, no anchors or interactions.
   Score agreement <1e-9; analytic/numerical gradient difference <1e-7;
   invertible-coordinate SE difference <1e-10; q121 score/endpoint change
   <=1e-5 and relative SE change <=0.001. Record full-vs-diagonal covariance
   contributions without requiring a direction. Use the complete unregularized
   joint covariance only. Candidate intervals are normal 95% intervals clipped
   to [0,2]; retain unclipped endpoints too. All remain diagnostic candidates.

2. Can the existing simulation and screening APIs represent DRF separately
   from ability differences and facet interaction, including unavailable paths?
   Use RSM/PCM, N=80, three raters, two criteria, three score categories 1:3.
   Seven cases in this fixed order: null; group_mean_only; drf;
   interaction; combined; connected_incomplete; no_common_raters.
   Seeds are 75000000 + 10000 × model index + case index. One dataset per
   case is an execution check, not an estimate of Type I error or power.

| Case | Group B ability mean shift | B-specific Rater eta effects | Rater × Criterion eta interaction | Assignment |
| --- | ---: | --- | --- | --- |
| null | 0 | 0,0,0 | 0 | complete |
| group_mean_only | 0.6 | 0,0,0 | 0 | complete |
| drf | 0 | 0.4,-0.4,0 | 0 | complete |
| interaction | 0 | 0,0,0 | outer(0.3,-0.3,0; 1,-1) | complete |
| combined | 0.6 | 0.4,-0.4,0 | same | complete |
| connected_incomplete | 0 | 0.4,-0.4,0 | 0 | two raters per Person |
| no_common_raters | 0 | 0.4,-0.4,0 | 0 | A has R01/R02; B has R03 |

Use `simulate_mfrm_data()` directly. A constant Group B eta shift is represented
by equal `dif_effects` on all raters; mathematically it is exactly an ability
mean shift, not differential rater functioning. Archive the decomposition
separately from the generator's combined signal table and verify independent
softmax probabilities with effective theta = base theta + group mean shift.
DRF contrasts sum to zero across raters, and interaction has zero row/column
margins. Positive injected effects mean greater expected scores (leniency);
refit severity contrasts have the opposite effect sign for the affected group.
PCM uses distinct criterion thresholds (-0.7,0.7) and (-0.2,0.2); RSM uses
(-0.6,0.6). Check probabilities within 1e-12 and truth/mapping explicitly.

Fit additive MML q61/maxit200/reltol1e-10 to every retained dataset. In the
interaction and combined cases also fit the explicit Rater:Criterion term;
in group_mean_only also fit the population regression on Group. The additive
fixed-prior fit to nonzero group means deliberately omits that feature: its
screen cannot be interpreted as a calibrated null test. Run residual and
refit DRF screens on additive fits, min_obs=10, Holm adjustment across the
three rater contrasts for each single pair of groups (fewer/none when missing).
Record all rows, adjusted p-values, availability and directions. No screening
p-value is qualified formal inference. Explicit interaction/population fits
must retain the documented refit rejection. No-common-rater cases must not
manufacture comparable per-rater contrasts; this is not a claim that the
entire multi-facet incidence graph is disconnected.

## Output contract and accounting

Use existing summary, plot, replay, save/read and appendix CSV routes. Check
actual FairZ rows and diagnostic eligibility, including stored/legacy objects,
non-unit weights, population, GPCM/JML and missing covariance. Reuse existing
focused readiness tests. Catalogue targets and known limitations; this is not
an exhaustive new test of every exported function.

Archive assigned runs, warnings/errors, fit objects, truth, all target rows,
per-cell elapsed times and source hashes. Do not replace failed seeds, relax
thresholds or promote numerical checks into coverage evidence. Save artifacts
before the final assertions, so a failure remains reviewable. Any implementation
repair and rerun must be described in the record. This bounded preflight cannot
settle the prior RSM R3 FairZ coverage concern or the full GPCM/TAM comparison.

## Addendum after the first 14 execution cases, before the extension

The initial cases completed, but all refit p-values were unavailable: two
criterion anchors fall below the existing minimum of three common linking
anchors. Preserve these outcomes. Add cases 8 `linked_null` and 9 `linked_drf`
per model with three criteria (PCM C03 thresholds -0.45,0.45), complete
assignment, zero group mean shift, and respectively zero or (0.4,-0.4,0)
DRF. Keep the seed formula; these are new seeds. This checks a positive
conditional refit-screen path, without lowering the linking threshold.

The reviewed execution reruns the original 14 seeds unchanged and adds these
four cases. It is 18 unique datasets overall, not 32 independent replicates.
Correct the runner's access to an absent Contrast column in the empty refit
table; the two artificial warnings per no-common-rater case came from this
validation script. Retain the actual package warning about population-based
identification. Archive the initial runner before editing. The FairZ numerical
run predates this addendum; its condition definitions have not changed.

### Correction after the 18-case review, before five-anchor cases

The minimum was misread in the first addendum: the actual returned
`LinkingThreshold` and `build_dff_linking_setup()` default are **5**, not 3.
All four three-criterion positive-path assertions failed as they should;
their returned contrasts remain descriptive, with SE/p-values unavailable.
Preserve that runner, protocol and all fit/error artifacts under `reviewed/`.
Cases 8/9 now explicitly test this weak-link result, retaining their original
names and seeds. Add cases 10 `five_anchor_null` and 11 `five_anchor_drf`,
N=80, three raters and five criteria, full assignment, no interaction/mean
shift. Use PCM C03 (-0.45,0.45), C04 (-0.3,0.3), C05 (-0.8,0.8), and the
original RSM thresholds. Keep the seed formula; these four seeds are fresh.
The final run has 22 unique datasets, including the same original 18.
Expect finite conditional refit screens for cases 10/11; formal eligibility
must still be false. Do not alter the linking threshold or count reruns as
independent evidence. Save every returned table before checking its assertion.
