# Probability-interval attribution: matched refits, 2026-09-25

Question: does updating estimation materially change the probability-interval
shortfall identified in the saved-fit reanalysis? Select the entire original
spread-slope / Rater-owner / rotating-40 cell: all 100 datasets, not just failed
or uncovered cases. Selection is motivated by an adverse result and is not a
new independent confirmation. The 100 cases are already included in the 800.

Keep the original data, category ladder, model, estimated population intercept
and variance, quadrature Q61, iteration ceiling 400 and reltol 1e-10. Run fresh
fits with the current numerical implementation and its ordinary initialization;
do not initialize at known truth or at the old fit. Do not tune starts, cutoffs,
SEs, or confidence levels using outcomes. Retain errors, warnings and every
planned index. The old fits and earlier reanalysis stay unmodified.

Use exactly the earlier nine contexts (three rater levels, C02, native Theta
-2, 0, 2) and 27 probabilities, original saved truths, model and independent-
Person sandwich covariance, adjust = FALSE, 95% pointwise and Bonferroni
intervals. Compare actual public-API results; do not use a different inference
formula. The historical side is the earlier 800-fit reanalysis using these
same current interval calculations. Check input hashes, fitted row/category/
parameter identities, and native-scale targets before comparing outcomes.

Report per-dataset and per-row paired changes: fit return/convergence,
likelihood and parameters, interval availability, point estimates/endpoints,
all-target family coverage and widths. All planned datasets remain in the
covered-and-returned denominator; available-case rates have their own counts.
Report MC intervals descriptively, not as independent confirmation after
selecting this cell. No multiple grid-point pseudo-replications.

Prespecified attribution criteria: probability point changes above 1e-4 or
endpoint changes above 1e-3 are numerically material for this comparison; report
actual maxima as well, rather than reducing results to these indicators.
An objective improvement is above 1e-6*(1+abs(old objective)). These are paired
numerical-review tolerances, not coverage-acceptance margins or statistical
thresholds. If no more than two of 100 sandwich Bonferroni family outcomes
change and its available-case MC upper limit remains below .95, changes in
estimation do not explain the observed shortfall in this selected cell. If
outcomes change more, inspect their source before attributing the shortfall.
Neither outcome establishes global optimality, accurate integration, general
coverage or the exact cause of approximation error. A reproduced calculation
or scale defect must be corrected before further qualification.

At most two processes and 15 minutes elapsed, checked after batches of ten.
Retain partial results if interrupted; do not summarize an incomplete cell as
complete. No new datasets, broad grid, bootstrap or unrelated model study.

A computation-only supplement checks the probability delta calculation on the
first and last planned refits (404 and 800). Independently decode the 11 free
coordinates for these centered 3-by-3, three-category models, analytically
differentiate the softmax probabilities, and compare propagated SEs and limits
with the public API (absolute 1e-6). Check the analytic derivatives against
Richardson differentiation of that independent formula (absolute 1e-6).
This uses the same covariance inputs and therefore checks the transformation,
not covariance estimation or finite-sample accuracy. It adds no fits or data
and does not select cases based on their interval outcomes.
