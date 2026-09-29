# Corrected JML: paired order-2/order-4 sampling study

Protocol fixed before generating samples. This answers the next decision in
ROADMAP milestone 3 (JML structural inference); it does not expose a new public
estimator. Reuse the exact score expectation, full Jacobian and fixed-roster
Person sandwich already checked against enumeration and influence refits.

## Question and conditions

Does the population bias/variance tradeoff survive finite samples, and do the
two explicitly chosen orders deliver intervals for generating truth? Use the
two contrasting cases from the population challenge, not another factorial grid:

- Criterion owner / unequal exposure: rosters (2,1,0,1)/(0,2,2,2), fixed counts
  240/160, ability supports (0,1,2)/(-2,-1,0).
- Rater owner / sparse exposure: rosters (2,1,0,2)/(0,2,2,1), fixed counts
  200/200, ability supports (-2,-1,0)/(0,1,2).

Each support has masses (.25,.5,.25). Both use the existing five-coordinate
truth (.3,-.4,-.6,-.9,.25), three response categories and shared slope/step
ownership. Zero exposure means unassigned, not missing or imputed responses.
Generate 200 independent samples per condition, N=400 each. Within a condition,
apply both orders to each same sample. Seeds are 27300000 + 1000*condition +
replicate. The earlier engineering samples are excluded. Sample exact pattern
mixtures; this is equivalent to drawing ability and then conditional responses.
Truth/population masses enter generation and evaluation only, never fitting,
starts, covariance or order selection. A 95% proportion has MCSE about .0154
at 200 complete attempts; report Wilson Monte Carlo intervals. This detects
large deficiencies, not precise nominal coverage or rare-failure guarantees.

## Frozen fitting policy

Use both original starts (neutral and opposing), the existing Broyden solver
and Newton fallback, followed if necessary by the previously checked Newton
double-dogleg stepmax=.25 retry from the original start. Keep residual <1e-7,
minimum Jacobian singular value >1e-6, agreement of derivatives at 1e-4/5e-5
within relative 1e-5 and two-start agreement <1e-6. No ridge, pseudoinverse,
truth starts, probability pruning, post-hoc solver changes or wall-time cutoff.
Retain every initial/fallback attempt and distinguish root, agreement and
covariance failures. A failure is not a zero estimate or a miss by an available
interval. Fixed-roster covariance uses within-roster centering and the full
nonsymmetric Jacobian. Keep point estimates if only covariance fails.

## Outcomes and decision

Primary target: relative log slope. Retain all five structural coordinates.
For each order report point/interval availability, fallback use, bias and its
MCSE, RMSE, empirical SD, root-mean estimated variance, interval width and
directional misses. Report 95% normal interval coverage conditional on
availability and delivery-and-truth-inclusion over all 200 attempts separately.
Also report coverage of the previously computed method-specific population
root to separate variance approximation from residual bias. This is an oracle
diagnostic, not the user's inferential target.

Compare order-4 minus order-2 squared error on matched available points, with
paired MCSE and a normal Monte Carlo interval. Each method's full available
sample remains reported because restricting to common successes can select
an easier subset. An interval excluding zero supports a direction of MSE
change only for that coordinate and condition; other coordinates are descriptive.
Truth-coverage Wilson upper bound below .925 is evidence against acceptable
95% inference for the declared condition; otherwise this study alone does not
qualify public intervals. Compare truth/root coverage before attributing a
failure to either residual bias or covariance. No order is selected by knowing
truth, minimizing estimated SE or observing overlapping estimates. A small
order difference cannot detect common residual bias, and adaptive selection
would require separate validation of the entire selected procedure.

All 400 datasets are attempted, with resumable individual records and source
hashes. An interrupted run reports incompleteness and resumes the remaining
declared IDs, not a reduced denominator. Do not add repetitions or conditions
in response to results. Record the method decision and outstanding integration
scope after completion. Public help/NEWS must not imply a released corrected
JML estimator or general coverage on the basis of this research study.
