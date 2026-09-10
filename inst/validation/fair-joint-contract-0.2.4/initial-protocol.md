# Interval contract and DRF execution preflight — 2026-09-10

Repository-only bounded follow-up to priorities 0–2 in the active internal
roadmap. This protocol is written before running the cases below. It does not
replace the earlier Fair Score pilot or authorize a coverage confirmation.

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
