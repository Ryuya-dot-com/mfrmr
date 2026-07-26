# Historical mfrmr development-roadmap record

Status: historical validation artifact, reviewed 2026-07-26.

The authoritative project sequence is the repository-root `ROADMAP.md`.
This file no longer defines active release gates. It is retained because older
0.2.2 evidence maps and review notes refer to a bundled development roadmap.

## Historical purpose

During 0.2.2 development, this note separated bounded-GPCM stabilization from
larger estimator and model-family ideas. Its durable conclusions remain:

- 0.2.2 should keep bounded GPCM visibly bounded and caveated;
- diagnostics and subgroup results are screening evidence unless a stronger
  design and validation contract exists;
- FACETS-style output is a compatibility and communication surface, not a
  claim of numerical FACETS reproduction;
- G/D-study coefficients are design-specific and must fail closed when their
  variance components or D-study transformation are unidentified; and
- complete GPCM, multidimensional estimation, posterior-predictive checks,
  MCMC, and multivariate G-theory are outside 0.2.2.

## Superseded sequencing

Earlier drafts placed restricted multidimensional RSM/PCM immediately after
0.2.2 and treated some external comparisons as 0.2.2 release blockers. Those
placements are superseded.

The current sequence is:

1. 0.2.2 source-truth and final-candidate alignment only;
2. 0.2.3 numerical trust, calibrated recovery, and matched ConQuest/FACETS
   comparison evidence;
3. 0.2.4 operational calibration, threshold/step anchors, starting values, and
   fixed-calibration scoring;
4. 0.2.5 explicit observed `ScaleId`, multiple RSM/binary scales,
   scale-specific PCM, and only then mixed binary/RSM/PCM structures; and
5. 0.3 or later for multidimensional and other research extensions.

This order reflects the project decision to establish trusted one-dimensional
operation and multi-scale observation contracts before adding multidimensional
latent traits.

## G-theory policy retained for future work

A future profile or multivariate G-theory route must identify the object of
measurement, profile dimensions, random/fixed facets, crossing or nesting,
and relative versus absolute decisions. Composite reliability must use the
full criterion covariance matrices rather than averages of criterion-level
coefficients. Raw negative variance-component estimates must remain visible,
and any nonnegative decision-use adjustment must be separately labelled.

Balanced deterministic fixtures, simulation recovery, missingness/design
stress, and external overlap are required before such a route is promoted from
research scope. Singular mixed-model fits are identification evidence, not
routine success.

## Interpretation

For current package behavior, consult exported help, `NEWS.md`,
`gpcm_capability_matrix()`, and `gpcm_runtime_guard_coverage()`. For future
sequence and release gates, consult only the root `ROADMAP.md`.
