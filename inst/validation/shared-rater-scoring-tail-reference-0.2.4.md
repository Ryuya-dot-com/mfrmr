# Conditional-CDF follow-through using the saved rater draws

2026-09-23. Fixed before evaluating any conditional-CDF reference. The first
three completed rosters show that raw latent-draw quantile MCSE can exceed
the original .02-logit cap (observed maximum .023718). Preserve the original
twelve-roster comparison and every original decision; do not replace it,
extend chains, add datasets, refit calibration or change practical tolerances.
This follow-through improves the numerical reference, not the package method.

At fixed calibration, abilities are conditionally independent given all
shared raters. Consequently

    F_p(t | all responses) = E_{u | all responses}[F_p(t | u, own responses)].

The same joint rater draw must supply both of the focal Person's raters.
Keeping that dependence is essential. Compute the conditional CDF by direct
one-dimensional integration of the normal ability density times the Person's
ordinal response likelihood. Averaging these smooth probabilities is a
Rao-Blackwellized reference; it does not omit within-Person uncertainty, use
rater modes as known, or change the full-roster posterior target.

Use every fourth retained iteration (1,5,...,7997) from each of the four
existing chains: 8,000 joint rater draws per roster. This fixed computational
subset is chosen before any such CDF values, used for all 48 planned Persons,
and preserves chain/iteration axes for MCSE. No added or replacement draws.
All original latent/sampler checks must pass. No CDF check can override them.

For each reported endpoint a, evaluate F(a-.10) and F(a+.10); the original
practical endpoint tolerance remains .10 logits. Use direct cumulative
adjacent logits, independent of production probability/integration helpers.
Integrate standardized ability on [-12,12] with 128- and 256-point Legendre
rules from statmod, and [-12,t/person_sd] for each CDF numerator. The omitted
normal mass is at most 2*pnorm(-12); require that divided by the smallest
conditional likelihood normalizer be below 1e-12. Require positive
normalizers >=1e-12, relative normalizer differences <=1e-7 and maximum
per-draw CDF difference <=1e-7. These checks assess numerical quadrature, not
sampling or approximation accuracy by themselves.

Independently verify the normalizer and four CDF values at the first selected
rater draw for every Person using stats::integrate over infinite bounds,
relative tolerance 1e-10 and absolute tolerance 1e-13. Require normalizer
relative and CDF absolute agreement within 1e-8. Report unresolved checks.
This continuous reference does not use the Legendre or production rules.

For each CDF function require Rhat <1.01, bulk/tail ESS >=400, finite MCSE
<=.0005, and resolved original/reference numerical checks. With e the larger
of the per-draw quadrature difference and the tail truncation bound, use
mean +/- (4*MCSE + e). For endpoint probability p (.025 or .975):

- Bounded endpoint agreement if the upper allowance at a-.10 is <=p and
  the lower allowance at a+.10 is >=p.
- Material discrepancy if the lower allowance at a-.10 is >p or the upper
  allowance at a+.10 is <p.
- Otherwise inconclusive, with failed sampling/numerical/precision checks
  retained separately. Do not increase the draw count or integration orders.

Strict monotonicity of the normal-prior ordinal posterior CDF gives the
quantile bracket. Four MCSEs are numerical uncertainty allowances, not a
simultaneous confidence theorem. This does not estimate new quantile values,
revise the raw-quantile comparison, establish frequentist interval coverage,
or qualify the calibration likelihood. Keep EAP/SD conclusions from the
original comparison. Record source/input hashes and all outcomes; use saved
case files as they finish. No uncompleted case may disappear from accounting.
