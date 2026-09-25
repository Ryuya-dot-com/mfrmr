# Saved-fit target reanalysis, 2026-09-25

Question: what empirical interval behavior do the existing 800 historical
G3 fits show for standardized slope differences and fixed-native-ability
category probabilities/per-rating information? Previous slope coverage does
not answer this question. This is retrospective reuse, not a holdout or a
current-estimator simulation. No fits or datasets will be replaced or generated.

Use all 800 original indices (eight original cells, 100 datasets per cell),
including every unavailable fit. The original generation varies centered
facet effects across datasets; these results average over those draws. Sample
size and incomplete assignment are confounded in the two original designs.
Use the frozen September 25 current-arm inference implementation, checking the
two numerical public API bodies against the working source. Keep old fitted
estimates and label the combination explicitly. No repair-benefit, bootstrap
coverage, misspecification robustness or all-current-fit coverage claim follows.

Before any coverage calculation, verify saved truth, score/facet labels,
normal population SD 1, lack of injected effects, and sum-zero step means for
all datasets. At fixed native Theta = -2, 0, 2 evaluate each of three slope-owner
levels, holding the other facet at its second level (nine contexts). Center
both generating facet vectors to the fitted sum-zero reference. This changes
the generating population mean by minus the two original facet means, not its
SD. Check probability invariance by shifting raw Theta accordingly. Compute
truth directly from cumulative adjacent-category logits and slope-squared
category variance; do not use fitted probabilities as truth.

Differences are standardized first-minus-second and second-minus-third with
all three facet levels named. Use model and independent-Person sandwich
covariance, adjust = FALSE, level .95, pointwise and Bonferroni. Families are
separate calls: two differences, 27 probability rows or nine information rows;
these are finite grids, not continuous simultaneous bands. Inspect both row
and all-target family coverage. The dataset remains the independent MC unit.

Reuse one model information matrix and one Person-score sandwich calculation
per saved fit, with the public API bodies unchanged and a validation-local
lookup for the already computed exact-fit inference object. First-replication
cases from all eight cells must reproduce the unmodified public calls for
both covariance methods and all three targets (tables, status and reasons).
A mismatch stops the reanalysis. This is not a production caching change.

Report all planned/returned/available counts, covered-and-returned fractions,
coverage among available results, exact binomial MC intervals, median/95th
percentile widths, errors and numerical cautions. Preserve failed indices;
never count unavailable intervals as covered or discard them from planned
counts. Use no outcome-driven grid, threshold, method or replication revision.
No numerical parameter will be tuned using these outcomes.

Resource stop: at most two processes and 15 minutes elapsed for the reanalysis.
A measured sandwich covariance on saved case 401 took 0.602 seconds; reuse
avoids recomputing it for each output option. Stop and retain partial outputs
if the budget or equivalence check fails; do not summarize incomplete cells as
completed coverage evidence. The old 30-hour plan remains unexecuted.
