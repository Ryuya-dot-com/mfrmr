# Fair-score relationships and full-refit uncertainty

Date: 2026-09-10. Prespecified before this pilot. No release approval.

## Questions and targets

1. Does the plotted score equal the table's transformation at the declared
   reference? FairM uses mean measures; FairZ uses zero measures, not z-scores.
   Measure-to-score plots explain this transformation. Observed-minus-fair
   gaps also depend on assignment and person mix, so they do not establish bias.
   See the [FACETS definition](https://www.winsteps.com/facetman/fairaverage.htm).
2. When calibration is repeated, does an SE for a **fixed-reference FairZ**
   describe the variation of the complete fitted transformation? Refit every
   structural parameter and rescore Persons on every independently generated
   dataset. Compare the current focal-measure-only approximation with joint
   covariance propagation through effects AND thresholds.
3. What happens after an anchor intervention or a model change? This is a
   separate paired-estimator target, including covariance between fits.
   Existing graph/offset sensitivity and paired Wright/CCC plots cannot answer
   its uncertainty question because their source calibrations are fixed.

## Bounded executable preflight

Reuse the independent response generator from the structural-information
validation: RSM/PCM, 80 independent N(0,1) Persons, three Raters, two Criteria,
six ratings per Person, categories 0--2, unit weights, no anchors/interactions,
fixed population. Use 20 new datasets per model, seeds
`72000000 + 10000 * model_index + replicate` (RSM then PCM).

Targets are FairZ for each Rater and Criterion, using their own thresholds for
Criterion and the mean threshold profile for Rater. Truth and gradients use
explicit independent coordinate maps and a direct softmax, not the production
fair-score kernel. The gradient includes threshold uncertainty and covariance.
Check its numerical derivative at step 1e-5 (absolute error < 1e-7) and its
point-score agreement with the public table (< 1e-9).

Fit MML with q61, maxit=200, reltol=1e-10, from fresh starts. Refit the first
dataset of each model at q121 from scratch as an actual full optimization,
not a Hessian evaluation at old coefficients. Compare parameters, person
EAPs, target scores, target SEs and interval endpoints; report all changes.
Pilot numerical review bounds: score/endpoint changes <= 1e-5 and relative
SE change <= 0.001. These bounds are scoped diagnostics, not universal guarantees.

For each fit retain warnings, errors, convergence/readiness, covariance
status and elapsed time. Never replace failed datasets. Interval availability
requires inference readiness and unregularized covariance; unavailable rows
remain in the denominator. Both candidate intervals use the same normal
quantile and [0,2] clipping, separating the covariance calculation from the
choice of interval construction.

Report bias, empirical SD, RMS SE, RMS-SE/SD, coverage, exact 95% Monte Carlo
interval for coverage, mean width and availability. Twenty replications are
an execution/timing check, **not coverage validation** (planning MCSE near
95% coverage is about 4.9 percentage points). The joint-delta candidate is
repository-only; this pilot does not enable a new public inference API.

## Required continuation before new inference claims

* Fixed-reference FairZ: freeze the reviewed method, then use at least 2,500
  fresh replications per cell. Extend to 80/320 Persons and 3/6 ratings as in
  the structural-coverage protocol. Retain its coverage [0.93,0.97], SE-ratio
  [0.90,1.10], standardized-bias [-0.10,0.10], availability and numerical
  review rules, evaluated with Monte Carlo intervals. Pilot seeds are excluded.
* Mean-reference FairM: decide whether the reporting reference is fixed
  externally or reestimated. For the latter, rescore Persons and recompute
  reference means in every replicate; fixed-EAP structural propagation is
  insufficient. Define truth for the chosen population/reference explicitly.
* Person Fair Scores: distinguish a conditional posterior interval under
  fixed calibration from repeated-calibration uncertainty and frequentist
  coverage at a fixed ability. Include boundary/extreme patterns and coverage
  by ability and exposure; aggregate coverage alone is insufficient.
* Anchor/model interventions: separately specify (a) releasing an anchor
  constraint, (b) dropping ratings, and (c) excluding common elements only
  from alignment. Preserve a common identified scale. Refit both procedures
  on each SAME replicate, repeat linking/screening if the procedure includes
  it, and use paired differences. Do not add marginal SEs as if independent.
  Distinguish exact external anchors from estimated anchors; the latter need
  their calibration uncertainty propagated too. A resampling scheme must
  preserve person clusters and the actual assignment design.
* DRF/interactions: generate null and non-null Rater-by-group and
  Rater-by-Criterion effects with linked, sparse and unequal-exposure designs.
  Compare correctly specified and omitted-effect models, reporting bias,
  coverage, false positives, power and failed/disconnected fits separately.
  Specify how the Fair Score reference averages or fixes interactions before
  a score-level coverage claim. GPCM slope owners and JML need separate studies.
* Compare with TAM only where model, constraints, score coding, likelihood,
  reference and uncertainty target match. Item-only agreement or matching
  marginal SEs does not establish complete-model or contrast equivalence.

The previous 20,000-dataset structural study is evidence for its declared
structural targets; it does not validate Fair Scores, paired differences or
anchor interventions. Follow the explicit aims/generation/targets/methods/
performance separation and Monte Carlo reporting of
[Morris, White and Crowther (2019)](https://doi.org/10.1002/sim.8086).
