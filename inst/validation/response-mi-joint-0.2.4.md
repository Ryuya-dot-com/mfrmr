# Assigned-score joint RSM example: plan fixed before sampling

2026-09-23. M1/M2: replace the tutorial's insufficiently justified ordinal
regression imputer with an explicitly specified joint score model. This is
an executable example and numerical/inferential reconciliation, not a new
public imputation engine or a repeated-sampling coverage qualification.

## Question and target

Can the supplied-completion workflow represent uncertainty in a fixed
R04-minus-R01 severity difference while respecting assigned events and the
dependence between multiple missing responses of one Person? Compare Rubin
pooling with direct observed-score MML and with the observed-score Bayesian
posterior. The Bayesian posterior has proper calibration priors whereas the
complete-data MML estimator does not; agreement is an empirical check of a
large-sample approximation, not an identity or a congeniality theorem.

Use the existing fictional 48-Person, four-rater, four-criterion data. The six
R04 Content events for the first six Persons remain unassigned. Among assigned
R04 Content/Language events, generate missingness with probability
`plogis(-0.5 + (2.5 - mean_R01_score))`, seed 26230901. R01 ratings are always
observed. Selection depends only on observed ratings: it is MAR by construction
in this masking example. Held-out scores are retained only for prediction
checking and never passed to the imputer. No claim that real missingness is MAR.

## Imputation model and computation

Adjacent-category RSM, unit discrimination, additive severity/difficulty,
sum-zero rater, criterion and shared steps, independent N(0,1) Persons. These
constraints match the complete-data analysis. The sum-zero coordinates have
orthonormal bases with independent N(0,2.5^2) priors. They are invariant to a
relabeling of the facet levels and specify the prior, rather than estimating
a random-rater population variance. A Person draw is shared by all that
Person's missing responses within a completion; all calibration draws are
shared across the roster. Discrete missing responses are generated after
conditioning on observed scores, not added to the observed likelihood.

Four Stan chains, 1,000 warmup and 2,000 retained iterations each, seed
26230902, adapt_delta .9, max_treedepth 10. Preserve all chains before checking
Rhat <1.01, bulk/tail ESS >=400 for every latent/calibration coordinate,
zero divergences/treedepth hits and E-BFMI >=.3. Do not discard or replace bad
chains. Draw forty completion indices without replacement using seed 26230903;
retain their chain/iteration identities and predictive probabilities. This
random selection is an approximate independent-draw example, not evidence that
arbitrarily thinning a poorly mixing chain creates valid MI.

## Checks and interpretation fixed in advance

Check the Stan conditional likelihood and selected missing-event probability
vectors against the package's independent implementation at retained parameter
draws (absolute tolerance 1e-9), including normalization and sum constraints.
Check all completions preserve observed scores, event IDs, assignment and
integer support. Check model save/reload identity and all downstream fits;
retain failures and refuse pooling if any fit is ineligible.

Fit every completion with fixed-N(0,1) RSM MML, Q61. Use the full observed
information covariance of the fixed rater contrast. Use Q121 for the direct
observed-data comparator; require Q61/Q121 contrast and SE differences <=1e-4
before interpreting it. Report estimates/SE/intervals for direct MML, direct
Bayes and MI, plus the MI point-estimate Monte Carlo SE. Differences are
descriptive; no after-the-fact pass margin for statistical agreement.

For sensitivity, subtract one category from each selected missing score,
floored at 1, keeping the same baseline draws. Analyze as a separate pool.
This is a declared discrete pattern-mixture perturbation, not an estimated
MNAR mechanism. Report held-out category probability scores and ordinal means;
successful sampling does not prove model adequacy. This small example cannot
certify population bias, nominal interval coverage or general missingness
robustness. A repeated-sampling qualification remains a separate requirement.

Use the current generic importer/fitter/pooler without changing its statistical
scope. Retain the prior ordinal-imputer evidence and adverse prediction result.
Document that direct observed-score MML is sufficient for the same likelihood
target under ignorable score missingness; MI creates no additional information.

## Sources

- Andrich (1978), doi:10.1007/BF02293814: adjacent-category rating scale model.
- Rubin (1987), *Multiple Imputation for Nonresponse in Surveys*.
- Bartlett and Hughes (2020), doi:10.1177/0962280220932189: congeniality,
  complete-data inference and limits of Rubin/bootstrapping arguments.
- Stan User's Guide, posterior predictive sampling and missing-data chapters:
  https://mc-stan.org/docs/stan-users-guide/posterior-prediction.html and
  https://mc-stan.org/docs/stan-users-guide/missing-data.html.
