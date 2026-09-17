# Person scoring under a mismatched prior — frozen design

2026-09-14. Fixed before outcomes. Who is affected: users applying a saved
calibration to a population whose abilities differ from the scoring prior.
Question: how do 95% interval coverage, bias and RMSE change when the assumed
N(0,1) prior is wrong, and can numerical convergence distinguish that mismatch?

Hold the known facet/step calibration fixed, reusing `person_interval_design()`
unchanged (RSM/PCM, categories 0--3, 3/6/30 ratings). This isolates scoring-prior
mismatch; it does not study recalibration under misspecification, density
estimation, latent regression, linking uncertainty or GPCM coverage.

Seven actual populations: N(0,1); N(0.75,1); N(0,0.6^2); N(0,1.5^2);
(Gamma(shape=2,scale=1)-2)/sqrt(2); an equally weighted mixture of
N(-sqrt(0.84),0.4^2) and N(sqrt(0.84),0.4^2); t(df=5)*sqrt(3/5).
The last three have mean zero and variance one, isolating shape from the first
two moments. Use the distributions directly, without centering/scaling each
realized random sample. Cross with six measurement designs: 42 cells.

Primary operating characteristics are obtained by integrating over true
ability and summing all attainable totals. For these unit-slope, fixed-design
likelihoods, total score is sufficient. Independently convolved total
probabilities at theta=0 determine P(T=t|theta) by exponential tilting; verify
this against direct item-probability convolution at other theta values.
Integrate across the full support using base R `integrate()`, with fixed splits
at -3,0,3 and any finite support boundary; never truncate Student-t tails.

Reuse the checked continuous-CDF scoring results from the speed verification
(candidate SHA256 be3119fcf18d62f86145f8c2826794b3dc202c489d16f9da77ed7d77121d6b4f).
Report assumed-normal fixed Q31 (public default), Q121 and adaptive Q61
separately for EAP/SD; their continuous 95% interval is common. Also calculate
an independent posterior using the actual generating density as an oracle.
The oracle isolates prior mismatch but is not a new package feature and does
not imply the true density can be identified from a user's data.

Report integrated coverage, mean width, bias, RMSE, mean posterior SD and
all-extreme-total probability. Include true-ability strata
(-Inf,-2],(-2,-1],(-1,0],(0,1],(1,2],(2,Inf), with their population masses.
Oracle marginal coverage must equal .95 within 1e-7; conditional-on-ability
coverage need not be .95 even for the oracle. The normal control must match
the prior-matched historical reference. Numerical acceptance: total mass and
generating moments within 1e-8, integration relative error <=1e-8 (positive
integrals), oracle posterior endpoint error <=1e-7, normal reference moments
and bounds within 1e-7. Require finite outputs and retain all conditions.

Check sensitivity at relative integration tolerances 1e-9 and 1e-11 for all
42 cell summaries; primary coverage differences must be <=1e-7 and bias/RMSE
differences <=1e-6. No numerical result is classified as a coverage success
merely because the integration converges. Describe under/overcoverage in
percentage points from .95; a >2 percentage-point deviation is a study-specific
practical concern, not a universal regulatory or psychometric threshold.

An independent response-by-response Monte Carlo check uses 20,000 Persons
per cell (840,000 distinct Persons) at seeds 114000000+1000*design+distribution.
Retain actual generated abilities and totals, seed and RNG kind. Compare the
assumed-normal and oracle empirical coverage to deterministic values within
5 binomial MCSEs; no replacement seeds. Summaries remain the deterministic
values, not estimates selected from the random check. First validate the
implementation on the seven distributions with the three-rating RSM design;
then run all fixed conditions. No production model/API change is prespecified.
