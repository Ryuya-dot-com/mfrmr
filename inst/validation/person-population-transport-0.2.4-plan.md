# Transporting a learned scoring population — analysis plan

2026-09-14. Written after the learned-population study and before evaluating
its cross-population combinations. This is a secondary analysis of saved
simulations, not an independent replication or a new calibration experiment.

Question: when calibration and scoring populations differ, does the benefit
of learning a normal mean/variance persist? Does numerical/source readiness
establish that the learned prior represents the new people?

Cross the four training populations with all four scoring populations:
N(0,1), N(.75,1), N(0,1.5^2), and standardized Gamma(2). Retain RSM/PCM,
calibration N=80/320, and three/six new ratings. This gives 64 training/target
cells, including the 16 previously reported same-population cells. Measurement
parameters, categories 0–2, and the three-Rater/two-Criterion design are
unchanged between training and scoring. This tests population change on the
same measurement scale, not changes in Rater severity or item functioning.

Use all 128 saved main calibration samples per original cell, without
selection or refitting. Each source fit scores each target cohort with the
same model, calibration N label, and replicate number. Each target cohort
contains 512 people independent of every paired calibration sample by the
original disjoint seed construction. Pair fixed-N(0,1) and learned-normal
fits on exactly the same target responses. Keep the true-target-density,
known-calibration oracle. The contrast includes calibration differences
between the two fitting workflows; it is not a pure prior replacement.

There are 2,048 original calibration samples, 4,096 original fits and
1,048,576 original new-Person draws. Reusing each cohort under four training
conditions yields 4,194,304 source/target Person evaluations per scoring arm
and rating exposure; these are not additional independent people. The
128 replicate bundles are independent within each cell, while different
training/target cells reuse samples and must not be pooled as independent.

Use saved Q241 public profile scores and the existing unit-slope assignment/
total lookup. Cache only its index mapping; do not change the numerical
scoring algorithm or refit using target information. On replicate 1 in all
16 source cells, recheck saved profiles against the current checked package;
for every source/target pair also compare the lookup with public scoring of
eight actual target Persons at each exposure (max absolute score/SD/bound
difference <=1e-8). Record source readiness separately; learned-population
scoring continues to require explicit readiness_policy="review". No gate
changes are authorized by coverage or numerical success.

Before the complete derived run, verify input hashes against the previous
archive and qualify the four model/N replicate-1 bundles. If a check fails,
investigate before continuing; do not remove a sample or change the threshold
to obtain a pass. Replicate-1 bundles remain part of this secondary analysis;
their verification does not create extra independent observations. For every
saved sample the diagonal metrics must exactly reproduce the original, and
all diagonal aggregate estimates/MCSEs must agree within 1e-12.

Reuse the existing calibration-cluster ratio summaries and paired RMSE
delta method. Retain all marginal and ability-stratum metrics, counts,
availability, readiness and errors. The descriptive [.93,.97] whole-Monte-
Carlo-interval criterion is carried over unchanged, with the same availability
and numerical requirements; it is not a transport-approval rule. Report
pointwise Monte Carlo intervals without multiplicity adjustment and avoid
claiming nominal coverage at every true ability.

For the primary answer, present fixed and learned coverage matrices and
paired contrasts for all 64 cells and both exposures. Describe RMSE, bias,
width and selected tails alongside coverage; retain all results, including
same-population controls. Do not select a scoring prior from target outcomes
or interpret the oracle as a usable public feature. The intervals still omit
uncertainty from calibration and population estimation. Link to the original
inputs with their SHA256 identities, preserve the new runner and all derived
results, and report this reuse and its limits in the help/report.
