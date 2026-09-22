# Draft.83d2b2b1g11 truth-blind stationarity acceptance-policy contract

Status: completed repository-only policy freeze, 2026-08-10. This contract
freezes how calibration replicates 201--300 may compare and reject numerical-
stationarity candidates. It does not implement the production boundary probe
or exact-resume runner, open replicate 201, choose a diagnostic threshold, or
authorize calibration, confirmation, inference, or D-study decisions.

## Claim boundary

Draft.83d2b2b1g10 completed four of four nonreserved high-accuracy reference
lanes: glmmTMB ML/REML and lme4 ML/REML. That supplies reference mechanics but
not an application rule. Draft.83d2b2b1g11 freezes only the rule-selection and
failure-accounting procedure that must be applied after the remaining runner
prerequisites pass.

`AcceptancePolicyFrozen=TRUE` therefore coexists with
`StationarityThresholdFrozen=FALSE`, `StationarityCriterionReady=FALSE`,
`CalibrationAuthorizationReady=FALSE`, and
`CalibrationExecutionAuthorized=FALSE`.

## Frozen candidate grid and scope

The b1g5 registry contributes three primary-eligible score families:

1. affine-invariant Newton decrement;
2. lme4-style componentwise-minimum scaled gradient; and
3. objective/parameter-relative maximum gradient.

Each is crossed with the eight previously registered adjacent threshold zones,
giving 24 immutable candidates. Raw gradient remains a negative-control
benchmark and relative Newton step remains a sensitivity candidate; neither
may win the primary selection.

The primary target is one global rule family and one zone across all four
backend-likelihood lanes. Method-specific operating characteristics remain
separate. A diagnostic may not select the optimizer profile on which it looks
best, use generating variance at application time, use the viewed smoke, or
read confirmation replicates 501--700.

## Reference and application states

High-accuracy reference states are grouped without generating truth:

| Reference class | States |
| --- | --- |
| finite accept | `finite_local_minimum`, `finite_box_local_minimum`, `finite_stationary_flat` |
| finite reject | `finite_nonstationary`, `finite_saddle_or_max` |
| boundary | `boundary_limit` |
| unresolved | `reference_unresolved`, `not_evaluable` |

Candidate states remain `numerically_eligible`, `numerically_ineligible`,
`boundary_handoff`, `indeterminate`, and `not_evaluable`. The resulting events
are deliberately nonexchangeable:

| Event | Definition |
| --- | --- |
| safety false ready | finite-reject or boundary reference, candidate numerically eligible |
| false boundary handoff | resolved nonboundary reference, candidate boundary handoff |
| false unready | finite-accept reference, candidate numerically ineligible |
| missed boundary | boundary reference, candidate not handed off |
| abstention | resolved reference, candidate indeterminate |
| computational non-evaluation | resolved reference, candidate not evaluable |

Reference-unresolved rows enter none of the binary event denominators. They
retain their own counts. A missing denominator is `not_informative_not_zero`.

## Denominators and Monte Carlo uncertainty

Primary rates are retained for each
`scenario x method x model-role` cell. Persons, methods, likelihoods,
backends, scenarios, or model roles may not be pooled to improve a primary
denominator. Four methods remain paired within one generated
`scenario x replicate` dataset and are not four independent Monte Carlo units.

For (x) events among (n>0) trials, the one-sided 95% exact-binomial upper
bound is

\[
 U(x,n)=F^{-1}_{\operatorname{Beta}(x+1,n-x)}(0.95).
\]

When (n=0), the bound is unavailable. For zero events, the retained values
are:

| Trials | One-sided 95% upper bound |
| ---: | ---: |
| 25 | 0.1129281450 |
| 100 | 0.0295130496 |
| 200 | 0.0148670392 |

Fifty-nine zero-event trials are the minimum for an upper bound no greater
than 0.05. Zero observed events may never be described as zero population
risk. The worst-case Bernoulli MCSE, (1/(2\sqrt n)), is retained separately
from the observed-rate plug-in MCSE.

These cellwise bounds are calibration comparison scores. Because one of 24
candidates is selected using the same calibration data, they do not retain an
unqualified post-selection 95% coverage interpretation. Independent
confirmation remains mandatory.

## Frozen selection and negative-result rule

The policy operates lexicographically without an arbitrary weighted loss:

1. reject every candidate with any observed safety false ready or false
   boundary handoff;
2. require the reference data to observe, and the candidate to classify
   correctly at least once, every required method x model-role x reference
   class: finite accept/reject/boundary for full models and finite
   accept/reject for reduced models (20 classes total);
3. minimize the worst primary-cell exact upper bounds for false ready, false
   boundary handoff, false unready, missed boundary, indeterminate, and
   not-evaluable states, in that order;
4. prefer the affine-invariant Newton-decrement family, then the frozen family
   priority; and
5. prefer the more conservative zone and then candidate ID for an exact tie.

This coverage requirement prevents an always-indeterminate rule from winning
by avoiding binary errors. One observed safety error is disqualifying; it is
not averaged away across favorable cells. If no candidate satisfies the
frozen policy, the required result is
`negative_calibration_no_stationarity_threshold`. Cutoffs may not be relaxed
post hoc, and confirmation remains sealed.

Even a winning calibration candidate is only
`candidate_selected_for_immutable_confirmation_freeze`. It does not itself
freeze a production threshold or authorize confirmation.

## Reference receipts and integrity

The policy binds four nonreserved execution receipts:

| Lane | Execution SHA-256 |
| --- | --- |
| glmmTMB ML | `46ea4be751a3c54904bac28da31f15e5e05f347b9e8f10a1194887f55557807d` |
| glmmTMB REML | `28f155c91065cb56ebe695234eab7867392e25fe413ab362717e760f5e775e72` |
| lme4 ML | `b84c1d53f8653bb5329a0a165e2249b36e5d12e10c26099ab15cbdfac4281e8a` |
| lme4 REML | `b84c1d53f8653bb5329a0a165e2249b36e5d12e10c26099ab15cbdfac4281e8a` |

The combined receipt hash is
`777e7550a188f89515854738e3b7e42ef418037de4c9f7166a67d61e6dfa2e9e`.
The contract rejects any upstream b1g10 identity other than
`419fbf43fd1b86ab494aa96224916c0bfa9c1e1ef2668f8877d9d39659bcc7e0`.

## Remaining authorization blockers

Before replicate 201 can be opened, a separate immutable slice must:

1. implement the production boundary probe for both backend coordinate
   systems, retaining inconclusive and non-evaluable states;
2. implement the corrected 108,000-candidate / 24,000-reference atomic runner;
3. prove exact resume, complete failed-profile accounting, and reservation
   separation on nonreserved mechanics fixtures; and
4. bind the runner, boundary probe, this policy, all reference receipts, and
   the sealed 201--300 manifest in a new authorization identity.

Calibration results, an application threshold, statistical component
resolution, bootstrap operating characteristics, confirmation, inference,
coefficients, and D-study decisions remain unavailable.

## Sources

- Morris, T. P., White, I. R., and Crowther, M. J. (2019). Using simulation
  studies to evaluate statistical methods. *Statistics in Medicine*, 38,
  2074--2102. https://doi.org/10.1002/sim.8086
- R `stats::binom.test` documentation:
  https://stat.ethz.ch/R-manual/R-devel/library/stats/html/binom.test.html
- lme4 convergence documentation:
  https://lme4.github.io/lme4/reference/convergence.html
- lme4 singularity documentation:
  https://lme4.github.io/lme4/reference/isSingular.html
