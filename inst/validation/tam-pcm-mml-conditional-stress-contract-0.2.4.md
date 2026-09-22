# TAM PCM MML conditional-stress contract for mfrmr 0.2.4

Status: prospectively frozen before any result from this runner is inspected,
2026-09-06. This is an internal numerical-validation contract, not a
scientific preregistration or a claim of general TAM compatibility.

## Why this conditional lane exists

The retained RSM stress isolated a Person-pattern integration-resolution
problem rather than an RSM likelihood or coordinate-map disagreement. Because
the 0.2.4 portable-calibration scope includes both RSM and PCM under a fixed
standard-normal scoring basis, the issue must be checked with criterion-owned
PCM steps before release. Estimated-population fits are outside that portable
scope and are not repeated here.

## Frozen design

The lane reuses the five RSM stress profiles, dimensions, deterministic seeds,
and three replications: `BASELINE`, `SPARSE_RATER`, `MCAR_20`, `EXTREME_10`,
and `WEAK_EXPOSURE`. Only the generating/fitted family changes from RSM to PCM,
with `Criterion` as the step owner. This yields 15 fixed-N(0,1) datasets.

Every dataset is fitted in both engines at q31, q61, q121, and q181, for 60
matched comparisons and 45 consecutive-grid comparisons. TAM uses the exact
many-facet PCM design `~ item + rater + item:step`, fixed latent mean zero and
variance one, and the common `[-8,8]` node range. The widened range follows the
already-recorded RSM mechanism diagnosis and prevents known TAM tail truncation
from being mistaken for a PCM likelihood difference.

## Frozen checks

- All 60 matched comparisons and all 45 consecutive-grid comparisons stay in
  the denominator, including errors.
- Both engines must return finite objectives; mfrmr must report convergence and
  TAM must stop before 1,000 iterations.
- At q181, absolute deviance, cumulative-difficulty, EAP, and posterior-SD
  differences must each be at most `1e-4` for every dataset.
- Within each engine, q31-to-q61, q61-to-q121, and q121-to-q181 maximum
  movements in deviance, cumulative difficulty, EAP, posterior SD, mean, and
  variance are retained. Each transition must be at most `1e-3` for a complete
  stress pass.
- q31/q61 cross-engine differences are descriptive because the packages use
  different quadrature rules. They cannot overwrite the within-engine
  sensitivity result or the q181 matched result.
- No profile, seed, node count, range, metric, or bound may be changed after
  result inspection without a new contract version.

The `1e-4` and `1e-3` values remain engineering regression bounds for this
matched contract. They are not user decision thresholds. A pass would support
only the bounded fixed-N(0,1) PCM overlap. It would not validate estimated
populations, multidimensional models, unrestricted GPCM, substantive model
choice, or a universal quadrature default. A failure remains a 0.2.4 release
blocker until its mechanism and smallest truthful remedy are resolved.

