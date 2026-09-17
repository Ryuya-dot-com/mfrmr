# Person interval numerical accuracy and prior-predictive coverage

Fixed before numerical outcomes, 2026-09-14. This study addresses conditional
Person intervals at known calibration, not structural-parameter Wald intervals.
The earlier 20,000 structural-coverage and 30,000 bias-confirmation datasets
remain separate historical evidence; their fixed-Q61 results are not silently
transferred to the new adaptive algorithm.

## Question and design

Do the reported equal-tail intervals actually contain the requested posterior
mass, including when EAP/SD integration is accurate? Under the stated correct
prior and response model, do they have the corresponding marginal repeated-
sampling coverage? Fix calibration so interval discretization can be separated
from uncertainty in estimated calibration parameters.

Cross RSM/PCM with 3, 6 and 30 conditionally independent ratings. Use categories
0--3, known rating difficulties repeating (-0.8, 0, 0.8), N(0,1) Persons and
unit slopes/weights. RSM steps are (-0.8, 0, 0.8). PCM rating owners repeat
three ladders: (-1.2,0.3,0.9), (-0.4,-0.1,0.5), (-0.8,0.7,0.1). These are
bounded known-calibration assignments; three ratings represent sparse Person
information, not a demonstration that an unlinked calibration is identified.

For unit-slope RSM/PCM with known calibration, the response total is sufficient
for the Person posterior under a fixed assignment. Examine all totals 0--3n,
including both extreme totals: 240 design/total combinations. Evaluate fixed
and adaptive Q31/Q61/Q121, at requested levels 80% and 95%: 2,880 intervals.
Independently compute the total-score probability using polynomial convolution
of the categorical probabilities, and the continuous posterior CDF by scalar
integration. No package probability kernel or quadrature rule enters that CDF.
Check its normalization and moments against a second existing independent
integration routine. Retain every result and numerical failure.

The numerical criteria are absolute tail-probability errors <=1e-4 at both
endpoints; independent integration relative error <=1e-9 and omitted relative
prior-tail bound <=1e-12. Calculate exact (numerically integrated) prior-
predictive coverage by summing total probability times posterior interval mass.
Use an absolute 0.002 nominal-coverage difference as a descriptive review bound.
Good marginal coverage cannot cancel a failed conditional endpoint check.

Generate 100,000 independent Persons per design, each with a fresh N(0,1)
ability and independently sampled integer responses: 600,000 Persons total.
Seeds are 93000000 + 1000*design, designs ordered RSM then PCM and 3/6/30
ratings within model. Use the same Persons to compare numerical methods.
No additional calibration fitting or Person exclusion is performed. Report
coverage, exact binomial Monte Carlo intervals, width, EAP RMSE and posterior
SD on the same Persons. At 95% coverage the planning MCSE is 0.000689.
Coverage by true-ability strata (-Inf,-2,-1,0,1,2,Inf) is descriptive: nominal
coverage averaged over the correct prior does not imply 95% at each fixed
ability. Do not pool the dependent method comparisons as new Persons.

Numerical counterexamples take priority over launching a large structural
refitting study. If a defect is found, preserve pre-repair outputs, fix the
shared calculation and apply the unchanged numerical criteria and same paired
sample to the correction. Such a paired comparison is not fresh independent
confirmation. Preserve existing stored-calibration algorithm identities and
their historical semantics when changing newly created scoring outputs.

## Interpretation

This is conditional on the known point calibration and correct prior. It does
not include calibration uncertainty, empirical-Bayes fitting on the same data,
prior misspecification, interval coverage at a fixed theta, GPCM inferential
readiness, anchors/linking transport, or a release decision. Failure of a grid
interval is an interval-calculation finding, not proof that EAP/SD or the fitted
likelihood is wrong.

The design separates targets, methods and Monte Carlo uncertainty following
[Morris, White and Crowther (2019)](https://doi.org/10.1002/sim.8086).
Prior-predictive posterior calibration is described in the
[Stan User's Guide](https://mc-stan.org/docs/stan-users-guide/simulation-based-calibration.html);
this study uses exact one-dimensional integration and interval coverage, not
an MCMC rank-based SBC claim. The engineering margins above are study choices.
