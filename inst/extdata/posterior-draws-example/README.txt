Synthetic external GPCM joint-posterior example

This example demonstrates reading a checksum-bound Stan summary together with
its saved chain-by-iteration draws (posterior-draws.rds) for shared-calibration
contrasts, arbitrary equal-tailed credible levels, empirical draw views, and
reports without compiling or running Stan or brms.

It was generated from a small subset of example_core (8 Persons, 3 Raters with
the first Rater anchored at 0, and 3 Criteria under a Criterion-step and
Criterion-slope estimated-population GPCM specification) using two short chains
(50 retained post-warmup draws per chain; seed 20261031). The numbers are
workflow illustrations, not findings about a real assessment, and do not
qualify posterior recovery or finite-sample coverage.

Keep model-data.rds, posterior-summary.rds, and posterior-draws.rds together
with unmodified bytes so read_mfrm_posterior() can verify their MD5 checksums
and algebraic constraint bases.
