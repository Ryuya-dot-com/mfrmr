# Assigned-score MI: paired repeated-sampling result

2026-09-23. The [frozen protocol](response-mi-coverage-0.2.4.md) is complete.
This closes the planned bounded M2 comparison, not the whole release or a
general coverage guarantee. Raw evidence, frozen sources, environment and
all 400 incomplete-roster archives are in
`validation-results/response-mi-coverage-20260923/`.

## Question and design

Does joint-RSM predictive imputation with proper calibration priors, shared
Person draws and MML/Rubin analysis support inference on a fixed-rater
contrast under ignorable missingness? What happens if missingness depends on
the missing score itself? Compare with direct observed-score MML and Bayes;
agreement between methods is not a substitute for recovery of the true target.

Reuse all 200 normal-RSM/N=80 generating datasets from the earlier fixed-facet
study (seeds 92231001--92231200), without selecting favorable earlier results.
Three raters (.3,-.1,-.2), two criteria (.4,-.4), common steps (-.6,.6),
categories 0--2 and independent N(0,1) Persons. Twenty R2/C2 events are
unassigned independently of ability and response. The target R1-minus-R3 is
.5 logits. Every retained imputation keeps unassigned events missing and
preserves all observed ratings. The imputer's known N(0,1) population matches
the generator and completed-data MML model.

Both masks target R3 ratings, using the same dataset and uniform draws.
MAR selection depends on observed R1 scores. MNAR additionally increases the
missingness log odds by 1.5 per category below 1. Both are analyzed using the
MAR imputer; the latter is an assumption-failure challenge, not an MNAR
correction. Missing rates were not tuned to outcomes. Their realized averages
are 65.060 and 65.275 missing scores out of 460 assigned events, 14.143% and
14.190%, respectively. R3's own missing fractions are approximately 40.7%.

Two preflight masks were excluded. Main seeds, forty completions, MCMC
settings, 200 replications per mask, failure rules and operational decision
thresholds were frozen before main outcomes. The independent unit is the
dataset, not an imputation, rating or chain; the two masks are paired and do
not create 400 independent generating datasets. No replacement/top-up occurred.

## Results

Coverage is conditional on an available interval. Parentheses give exact
95% binomial **Monte Carlo bounds on coverage**, not severity intervals.
Bias and width are in logits. Bayes uses equal-tailed credible intervals and
posterior SD; MML uses observed-information normal intervals; MI uses Rubin
covariance and t intervals. These definitions remain distinct.

| Mask | Method | Available / 200 | Coverage, % (MC bounds) | Bias | Width | Frozen decision |
| --- | --- | ---: | ---: | ---: | ---: | --- |
| MAR | MML | 200 | 97.0 (93.58--98.89) | -0.007353 | 0.812692 | Bounded support |
| MAR | Bayes | 198 | 96.97 (93.52--98.88) | -0.003516 | 0.814218 | Bounded support |
| MAR | MI | 198 | 96.46 (92.85--98.57) | -0.003654 | 0.817035 | Bounded support |
| MNAR | MML | 200 | 25.0 (19.16--31.60) | +0.574431 | 0.858829 | Adverse undercoverage and bias |
| MNAR | Bayes | 200 | 24.5 (18.71--31.06) | +0.578447 | 0.859058 | Adverse undercoverage and bias |
| MNAR | MI | 200 | 26.0 (20.07--32.66) | +0.574395 | 0.863862 | Adverse undercoverage and bias |

The MAR MI bias MC interval is [-.032592,.025284], wholly within the frozen
[-.05,.05] band. Its availability lower MC bound is .964345. The coverage
lower bound .928518 exceeds the prespecified .925 criterion, with a point
estimate below .975. Thus all three stated criteria are met for this bounded
design. This is not proof of exact .95 coverage or an arbitrary-design result.
The attained coverage MCSE is 1.312 percentage points for MAR MI and 3.102
points for MNAR MI; the planning value near .95 was 1.54 points at n=200.

The full-denominator MAR MI available-and-covered rate is **191/200 = 95.5%**
(MC bounds 91.63--97.92), versus **191/198 = 96.46%** among available intervals.
Keep these separate: the frozen decision used conditional coverage together
with a separate availability criterion. Counting unavailable results as
uncovered did not silently disappear from the report.

In the common 198 MAR datasets, MI-minus-MML estimate difference is .001919
(MCSE .001236), width difference .003957 (.001907), and coverage difference
-.505 percentage points (.505). The MI estimate is not more accurate merely
because scores have been completed. Empirical SD and mean MI SE are .206480
and .207931. Mean within/between/total MI variance is .031413/.011615/.043318;
mean point-estimate MCSE/inferential-SE ratio is .080894. The completed-data
covariance and imputation variation both contribute to the interval.

Under MNAR, the MI bias MC interval [.543554,.605235] is far outside the
permitted band. Paired MI-minus-MML estimates differ by only -.000036
(MCSE .001249), while both miss the true target by about .574 logits. Their
agreement therefore does not establish validity. Similar overall missing
fractions also fail to describe the mechanism or its concentration by rater.
More MAR imputations cannot correct this selection bias.

## Numerical outcomes and retained failures

- All 400 MML observed-data comparisons were available. Maximum Q61/Q121
  contrast/SE difference was 1.812e-9, below the prespecified 1e-4 tolerance.
- All 1,600 Stan chains completed. No posterior was replaced. Two MAR
  posteriors failed the required Rhat <1.01 check: dataset 100, theta[51],
  Rhat 1.010618; dataset 141, theta[17], Rhat 1.010424. Their contrast-specific
  diagnostics met the thresholds, but this does not override the rule for
  all latent/calibration coordinates. Both Bayes and MI remain unavailable.
- The other 398 posteriors supplied forty completions each. All **15,920**
  completed-data MML fits were eligible, with no retained fit warnings and no
  failed pool. The two unavailable posteriors are imputer diagnostic outcomes,
  not failures of the mfrmr MML or Rubin covariance calculation.
- Archives retain full latent/calibration chains, missing category draws,
  sampler diagnostics, settings/seeds, selected chain/iteration identities,
  all fitted analyses, original incomplete rosters and generating scores.
  Generating scores were never passed to the imputation likelihood.
- Each archive was read back and checked for identical content before its
  redundant temporary sampling CSV was removed. The source snapshot agrees
  with the presampling hashes. The main run took about 32.9 minutes with four
  process workers; trial archives occupy 1.854 GiB. Median timed analysis
  phase was 18.85 seconds per roster (archive writing/verification is additional).

## Integration, checks and disposition

`response-mi-coverage-summary-0.2.4.R` reads every planned archive and refuses
an incomplete sample. Its separate synthetic accounting check verifies that
an unavailable MI result remains in planned/joint denominators, while paired
comparisons use only common available datasets. The first fixture check used
exact floating-point equality for a binomial endpoint; replacing that test
assertion with a 1e-12 comparison corrected the check, without changing the
summary algorithm or study. The fixture is not simulation evidence.

Public pooling help, the assigned-score tutorial, NEWS, ROADMAP and the active
claim ledger now report the bounded support and adverse MNAR result. There
is no new imputation engine or numerical/API modification from this study.
The existing generic APIs still require an appropriate supplied imputation
model; they do not certify MAR, imputer adequacy or all model families.

Final integration checks confirmed that all six public result rows match the
saved summary, the frozen source matches its presampling hashes, and parsed
numerical R code remains unchanged. The tutorial executed with identity-checked
saved example fits, and the affected Rd help pages parsed and rendered. This
reused existing numerical evidence without rerunning the example or the full
test suite. `git diff --check` passed.

The planned MI statistical comparison is complete. Preserve the tested scope,
diagnostic failures and missingness sensitivity through final integration;
do not open a new replication series simply to narrow these MC bounds. Broader
population/design/imputer qualification remains outside this evidence. This
closes the specific M2 comparison obligation, not all M2/M3 work. Shared-rater
Laplace/scoring accuracy and retained extended-model uncertainty remain the
next unresolved statistical decisions. M5 local completion is not reached;
no commit, push, main merge or publication was performed.
