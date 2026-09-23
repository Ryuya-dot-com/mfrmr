# Estimated-population testlet qualification

2026-09-23. Active M2/M3 work; previous fixed-population coverage results
cannot qualify estimated ability variance. Existing tensor, continuous-tail,
zero-submodel and saved-output checks are reused, not rerun.

## Questions and preflight

Compare Person-local testlet RSM with ordinary fixed-facet RSM on identical
rows. Both estimate one normal ability variance; Task and Criterion effects
are fixed and sum to zero. The ordinary population location is subtracted
when comparing its Person scores with the mean-zero generating abilities.
That transformation is also used by the public model-comparison workflow.

Ask separately about numerical availability, Person-score error, marginal
coverage of conditional plug-in intervals, and fixed-facet precision.
The oracle knows all calibration parameters; it is evaluated as a reference,
not represented as a fitted model. Marginal oracle coverage averages over
random abilities and responses. No 95% fixed-ability guarantee, calibration-
adjusted interval, Person contrast, automatic model choice or general sparse-
design guarantee is being tested.

Four named conditions, without an unnecessary factorial expansion:

| Condition | Persons | Local variance | Assigned design |
| --- | ---: | ---: | --- |
| Null control | 120 | 0 | Two tasks, three criteria per task |
| Local dependence | 120 | .8 | Same balanced design |
| Small calibration | 24 | .8 | Same balanced design |
| Sparse unequal blocks | 120 | .8 | T1 has three criteria for everyone; odd IDs receive two criteria on T2, even IDs one on T3 |

Ability SD is 1.3; task effects zero; Criterion effects (-.3,0,.3); adjacent
steps (-.6,.6); categories 0,1,2. Generate independent normal ability and
Person/task effects with direct adjacent-logit probabilities. Absent assignments
are removed, not imputed. No assigned missingness, informative assignment,
nonnormality, heterogeneous local variance or joint shared-rater effect is added.
The sparse condition is a named combined challenge, not a causal isolation of
block length from workload or assignment.

The cost probe (seed 92328000) is excluded. Its initial Criterion-only coding
raised an ordinary-model duplicate-cell warning because Task was not part of
the ordinary facet identifiers. Both methods therefore explicitly include Task
as a fixed facet in the comparison; the initial probe is retained unchanged.

Before fixing a confirmation workload, run four preflight datasets per
condition (16 total), seeds 92328100 + 100*Condition + Replicate. Fit testlet
at 61/123 points, ordinary at 121, maxit=400; score the first 12 IDs using
the full source roster. Oracle scoring is checked at 61/123 local-effect
points. All 12 IDs, errors, boundaries, warnings and failed fits remain.
No replacement, selective retry or statistical qualification follows from
this preflight. It tests whether the comparison and numerical route are
ready for the planned statistical question and measures actual workload.
Any failure is diagnosed before starting confirmation; the main count,
precision and decision tolerances must be frozen before main outcomes.

## Frozen main comparison

The 16 preflight trials are retained separately. Fourteen initial testlet fits
were ready. Two null-control fits failed Person-grid agreement; both pass
after 121-point refitting and 243-point checking, with all 12 Person scores
available. All ordinary and oracle scoring routes executed. No coefficient,
coverage or method-ranking outcome is used to select seeds or conditions.

Use **120 independent datasets per condition**, 480 total. Seeds are
92330000 + 1000*Condition + Replicate, disjoint from the probe and preflight.
Fit both models and score IDs P001--P012, chosen independently of responses
or abilities. Retain the complete source roster during public scoring.
No new-Person transport, retrospective Person selection or Person pairs are
claimed. Task/criterion comparison uses the same observed multiset of events.

The preflight median whole-trial times are about 9--25 seconds, with occasional
grid refits adding cost. Fix the workload now; four independent process workers
divide trial IDs. No post-outcome replication top-up or selective restart.
The ideal independent-Person coverage MCSE at 120*12 targets is about .0057
near .95. Estimated calibration correlates scores within each dataset, so
use datasets as the independent units and report achieved MCSE. A .01 MCSE
is the planning goal, not a guarantee or permission to increase n afterward.

### Numerical protocol and failures

Testlet starts at 61 points with its 123-point check and maxit=400. Exactly
one 121-point refit (checked at 243) is allowed if the initial fit converged,
did not hit an artificial search bound, and its likelihood, gradient or moment
grid discrepancy fails the existing thresholds (1e-6, 1e-5, 1e-6). This
prespecified integration-review protocol is the method being assessed, not
the default API order or a new automatic fitting API. Retain both attempts,
warnings and all statuses. A pure optimizer failure, a search bound, or a
failure after the higher-order refit is not selectively restarted. Numerical
and information readiness are both required for scoring. An estimated zero
local variance may be scored; estimated zero ability variance remains
unavailable. Neither boundary is deleted from the denominator.

Ordinary RSM uses population_formula=~1, 121 points, maxit=400 and the same
Task/Criterion effects. Use its public conditional scoring with its existing
readiness restrictions. Oracle intervals use known generating calibration,
with the existing continuous scorer checked at 61/123 local orders.
Capture errors as missing method results, never as dropped trial IDs.

### Targets and decisions fixed before outcomes

1. Primary conditional Person-interval assessment: a trial has a complete
   scored panel only when all 12 selected Persons have finite, available
   equal-tail .95 intervals. Average coverage, width, bias and squared error
   over those 12, then across independent complete trials. Report all Person
   statuses and incomplete-panel counts as well. Keep the conditional-on-
   availability estimand distinct from performance over all planned trials.
2. Report pointwise 95% t Monte Carlo intervals from dataset summaries;
   full-panel availability uses an exact binomial interval. Bounded positive
   evidence requires lower coverage bound >=.925, coverage estimate <=.975,
   and lower availability bound >=.95. An upper coverage bound <.925 is
   evidence of material undercoverage. Other outcomes are inconclusive.
   This 2.5-percentage-point tolerance is an operational criterion, not a
   theorem or fixed-ability guarantee. No pooling conditions to erase failure.
3. All-trial available-and-covered counts use the full 120*12 denominator.
   Also report lower/upper accounting bounds by treating each unavailable
   Person as uncovered/covered. These are not confidence intervals. All
   available pairs enter testlet-minus-ordinary and testlet-minus-oracle
   comparisons at the dataset level; report their own paired denominators.
4. Secondary targets: centered ordinary versus mean-zero testlet EAP MSE,
   width and coverage changes; ability SD and local variance bias/boundaries;
   Criterion C3-minus-C1 (truth .6), using full covariance for the testlet
   contrast and existing boundary restrictions. Ordinary calibration interval
   qualification is not added here. Report each named target, not an average
   that cancels positive and negative bias. Practical bias references are
   .10 logits for the contrast, .13 for ability SD and .08 for local variance;
   Monte Carlo intervals wholly outside these bands indicate clear adverse
   bias. No automatic model choice or likelihood-ratio test is made.
5. True ability bands below -1.3, within [-1.3,1.3], and above 1.3 are
   descriptive secondary summaries. They do not inherit the oracle's .95
   marginal property. Fixed-facet regular intervals at a local/ability
   boundary remain unavailable and count in target availability.

Preserve source/input identity and every outcome. A reproduced implementation
defect requires a recorded repair before affected evidence is used. Statistical
undercoverage is not a defect to erase by changing seeds, conditions or
tolerances. Update public help and the release decision to the actual result;
conditional intervals cannot be relabeled calibration-adjusted or universally
qualified. This experiment does not qualify MI, shared-rater Laplace,
heterogeneous local variances or all sparse designs, nor complete M5.
