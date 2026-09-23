# Shared-rater conditional scoring: independent posterior reference

2026-09-23. M2/M3, local 0.2.4. Freeze before new posterior or scoring
outcomes. The question is whether conditional Laplace Person scores are
numerically close to the joint latent posterior at the SAME calibration.
This is not a new estimator, calibration refit, repeated-sampling coverage
study, or proof that the fitted marginal likelihood is exact.

## Inputs and contrasts

Reuse the first replicate in each saved estimated-population condition
(trials 1, 201, 401, 601), and the previously selected largest Person-grid
discrepancy in each condition (141, 340, 455, 742). For the latter four,
use their completed 121-point repaired fits without refitting. The eight
full rosters have 240 Persons, six or 24 raters, two raters per Person,
three criteria and 1,440 responses; half have two weakly linked panels.
Selection precedes and does not use the present approximation errors.

Add four explicitly replaced scoring rosters from the first-replicate fits:
retain Persons 1:24 and 121:144, and only criterion C1 (48 Persons, 96
responses). Both bridging Persons, all rater identities and the original
pairing are retained. This stresses low per-rater information and only two
scores per Person. It is a selected numerical challenge, not a representative
sample of sparse assessments. Calibration and population SDs remain those of
the original full-data fit. Do not re-estimate or assert coverage after this
restriction. Source data, fits, selections and hashes remain archived.

For each of the twelve rosters, return P001 and P121 (the two bridge Persons
in weak designs), plus the lowest and highest observed total among remaining
Persons, breaking ties by lexical ID. The entire roster informs all four
scores. These 48 deliberately chosen scores are not independent replications.
No generating ability enters selection or scoring.

## Independent target and fixed computation

The independent Stan program samples one ability per Person and one severity
per rater, shared across every response carrying that ID. Ability and severity
have the same zero-mean normal populations as the fixed calibration. The
adjacent-category logits are accumulated directly; there is no Person
quadrature, conditional Laplace or calibration prior. Only latent effects
are sampled. The response log likelihood and normal prior constants are
retained as a generated quantity and checked against a separate direct R
calculation for the first ten retained draws of every chain (tolerance 1e-8).
This verifies coding/parameter sharing, not posterior convergence by itself.

For each roster use four chains, 2,000 warmup and 8,000 retained iterations
per chain, seed 92328000 + roster index, adapt_delta .9, max_treedepth 10,
diagonal metric, random initialization in [-2,2], 18-digit CSV output.
Require complete chains, Rhat <1.01 and bulk/tail ESS >=400 for every latent
coordinate, no divergences or tree-depth hits, and E-BFMI >=.3 per chain.
Retain all failures; do not replace chains, extend the run or retune seeds.
Use the installed CmdStan toolchain, with no new package dependency.

The production scorer uses quad_points=121 and its unchanged 243-point and
continuous-interpolation checks. Each score failure retains its row/reason.
No optimizer/readiness flag is overridden, and no fit is rerun. Save the
ordinary production scoring object, full latent draws, sampler diagnostics,
identities and timings; plots/reports can replay it without new calculations.
Run one roster at a time with four parallel chains. A 60-minute / 3-GiB budget
is a stop-and-report limit, never permission to discard unfinished cases.

## Error interpretation and decision fixed before outcomes

Compare EAP, posterior SD and the .025/.975 quantiles. Use chain-aware
posterior::mcse_mean, mcse_sd and mcse_quantile. For every returned quantity
require finite MCSE <=.01 for mean/SD and <=.02 for endpoints.
Prespecified practical approximation tolerances are .05 logits for EAP,
.05 logits for posterior SD and .10 logits for either endpoint. These are
bounded numerical tolerances, not universal educational decision thresholds.
They deliberately distinguish numerical agreement from inferential validity.

- Bounded agreement: abs(Laplace - reference) + 4*MCSE <= tolerance, with all
  reference and production numerical checks resolved and MC precision met.
- Material discrepancy: abs(difference) - 4*MCSE > tolerance under those checks.
- Otherwise inconclusive; retain unresolved reference/score status separately.

The four-MCSE allowance describes Monte Carlo uncertainty, not a simultaneous
confidence guarantee across 192 quantities. Report every quantity, maxima
by full/reduced roster and failed/inconclusive cases. Also evaluate posterior
probability between the production endpoints from the SAME paired latent
draws, with chain-aware MCSE. This is fixed-data posterior mass, not
repeated-sampling coverage of generating ability. Report it descriptively.

The earlier exact-tensor and independently checked brms/Stan tiny examples
remain evidence for their own targets and are not rerun. This study extends
the independent posterior comparison to the saved applied-scale rosters.
It cannot certify full marginal-likelihood/gradient accuracy, calibration
uncertainty, all sparse designs, nonnormal populations, informative assignment,
Person contrasts or rater classification. A favorable result closes only
this bounded scoring-approximation comparison. An adverse result requires an
explicit correction or scope decision, not softer wording or more samples.

Diagnostic and MCSE definitions follow the primary documentation:
[Stan diagnostics](https://mc-stan.org/learn-stan/diagnostics-warnings.html),
[posterior quantile MCSE](https://mc-stan.org/posterior/reference/mcse_quantile.html).
The implemented Laplace framework is described by
[Kristensen et al. (2016)](https://doi.org/10.18637/jss.v070.i05);
that paper does not qualify these particular scoring errors or intervals.
