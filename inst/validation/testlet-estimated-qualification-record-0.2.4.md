# Estimated-population testlet comparison and conditional-scoring decision

Local expanded 0.2.4; 2026-09-23. All 480 planned datasets and both model
fits are complete, with all original failures retained. The result is a bounded statistical assessment
of the retained conditional Person-scoring interpretation, not a general
coverage guarantee or completion of M3/M5. No commit, push or publication.

## Question and frozen comparison

The [protocol](testlet-estimated-qualification-0.2.4.md) fixes the questions,
conditions, sample sizes, numerical review, failure handling and decisions
before main outcomes. Earlier fixed-population evidence is retained under
its original scope. It cannot qualify the estimated-ability-variance route.

The comparison fits Person-local testlet and ordinary RSM MML models to the
same observed events with the same fixed Task/Criterion effects. Both estimate
normal ability variance. Person scores and interval endpoints subtract the
ordinary fitted population mean to align the two identification conventions;
the unit Rasch slope is unchanged. A third reference uses the known generating
calibration. Its score is not represented as an estimated fit.

There are 120 independent datasets per condition and twelve prespecified source
Persons per dataset. The full source roster is used for calibration/scoring.
Conditions are (1) N=120, local variance zero, two tasks with three criteria;
(2) the same design with local variance .8; (3) N=24 with variance .8;
(4) N=120, variance .8, all Persons receiving the three-criterion task T1,
with odd IDs also receiving two criteria on T2 and even IDs one on T3.
Unassigned events are absent, not missing or imputed. The fourth condition
changes workload and block size together and retains a common task for every
Person. It does not isolate an allocation effect or assess weak/disconnected
linking. Ability SD is 1.3; criteria are (-.3,0,.3), steps (-.6,.6).

Testlet fitting starts at 61 quadrature points; a prespecified grid-failure
review allows one 121-point refit. Corresponding checks use 123/243 points.
Ordinary fitting uses 121 points. This evaluates the reviewed fitting
procedure, not universal adequacy of any order or the default 31-point route.
A pure optimizer failure is retained without an outcome-dependent restart.
Estimated zero local variance permits conditional scoring; zero ability
variance withholds scores. Both withhold regular calibration intervals.

The artifact directory is
`validation-results/testlet-estimated-qualification-20260923/`. The roster,
source hashes/snapshot, session, every generated dataset, truth, fit, attempt,
warning, error and score are retained. Main seeds are
92330000 + 1000*Condition + Replicate and do not overlap the 16 preflight
trials or the cost probe. The production source, runner and protocol remained
unchanged throughout the main study. The analysis counts attempted refits by
their recorded timing entry so even an errored refit is counted; assigning
NULL to a list element would otherwise remove it. Both analysis versions
are retained. This accounting correction changes no trial or criterion.

## How to read the results

Coverage is first averaged over all twelve selected Persons, then over
independent datasets with complete available panels. Dataset-level t Monte
Carlo intervals/MCSEs reflect shared calibration uncertainty. Availability
has an exact binomial interval over all 120 planned trials. Primary bounded
support requires a coverage lower MC bound >=92.5%, coverage estimate <=97.5%,
and an availability lower bound >=95%. An upper coverage MC bound <92.5%
is material undercoverage; remaining outcomes are inconclusive. These are
operational pointwise criteria, not fixed-ability or universal guarantees.
The MCSE planning goal is one percentage point; replication is not topped up
after observing outcomes.

All-trial available-and-covered counts include every planned Person.
Unavailable-as-uncovered/covered bounds are accounting bounds, not confidence
intervals. Paired method differences retain their own complete-pair count.
The oracle comparison concerns all estimated calibration parameters together;
it does not isolate the contribution of estimating ability variance. This is
same-source scoring, not new-Person transport or external validation.

## Original main results

| Condition | Method | Complete / 120 | Coverage, 95% MC interval | MCSE (pp) | All-trial accounting bounds |
| --- | --- | --- | --- | --- | --- |
| Null, N=120 | oracle | 120/120 | 95.07% [93.86, 96.28] | 0.61 | 95.07–95.07% |
| Null, N=120 | ordinary | 120/120 | 95.07% [93.78, 96.36] | 0.65 | 95.07–95.07% |
| Null, N=120 | testlet | 115/120 | 95.00% [93.70, 96.30] | 0.66 | 91.04–95.21% |
| Positive, N=120 | oracle | 120/120 | 95.69% [94.64, 96.75] | 0.53 | 95.69–95.69% |
| Positive, N=120 | ordinary | 120/120 | 84.93% [83.11, 86.76] | 0.92 | 84.93–84.93% |
| Positive, N=120 | testlet | 113/120 | 94.32% [92.96, 95.69] | 0.69 | 88.82–94.65% |
| Positive, N=24 | oracle | 120/120 | 94.24% [92.97, 95.50] | 0.64 | 94.24–94.24% |
| Positive, N=24 | ordinary | 120/120 | 83.33% [81.22, 85.45] | 1.07 | 83.33–83.33% |
| Positive, N=24 | testlet | 119/120 | 91.74% [89.71, 93.76] | 1.02 | 90.97–91.81% |
| Sparse unequal, N=120 | oracle | 120/120 | 94.31% [93.18, 95.43] | 0.57 | 94.31–94.31% |
| Sparse unequal, N=120 | ordinary | 120/120 | 85.69% [83.97, 87.42] | 0.87 | 85.69–85.69% |
| Sparse unequal, N=120 | testlet | 119/120 | 93.28% [91.88, 94.67] | 0.71 | 92.50–93.33% |

All four original testlet primary decisions are inconclusive. The two N=120
balanced cells meet the coverage component but fail the availability component
(exact lower availability bounds 90.54% and 88.35%). Small/sparse cells have
95.44% availability lower bounds but fail the 92.5% lower coverage bound.
Their upper bounds exceed 92.5%, so neither meets the protocol's material-
undercoverage decision. This is not evidence of nominal 95% coverage.
Ordinary RSM meets the adverse-undercoverage rule in all three positive-local-
variance conditions. The oracle meets the bounded rule in all four conditions.

Testlet primary MCSEs are .657, .689, 1.021 and .705 percentage points. The
small-sample value slightly exceeds the one-point planning goal; ordinary
small-sample MCSE is 1.067 points. No replication was added. Ordinary/oracle
scoring is available in all 480 datasets. All fourteen unavailable testlet
panels are optimizer-status failures (5,7,1,1 by condition), not partial-person
integration errors. Information is not evaluated after a failed optimizer
status; a FALSE information flag here is not evidence of negative curvature.
No artificial bound or estimated-zero ability variance occurred. Local-zero
estimates numbered 60,0,1,0. The reviewed workflow used 53,0,3,0 grid refits;
initial readiness was 63,113,116,119. Whole-trial median elapsed times were
19.65,19.08,11.70,20.85 seconds under four-process execution; maxima were
73.02,24.58,23.78,23.91 seconds. These are observed costs, not capacity limits.

## Other prespecified targets

Original C3–C1 contrast interval counts were 56,113,118,119 out of 120.
Conditional coverages were 92.86%,95.58%,94.07%,94.12%; 95% MC intervals
were [85.90,99.82], [91.73,99.43], [89.74,98.39], [89.83,98.41]. All four
secondary interval decisions are inconclusive. The null cell excludes
estimated-zero local-variance cases from regular intervals; these are retained
in availability. Full coefficient covariance is used. No new ordinary
calibration-interval qualification follows.

Contrast point biases were -.0115,-.0159,.0744,.0068 logits. Ability-SD biases
were .0125,.0296,.0204,.0240. Local-variance biases were .0450,.0446,.1930,.0288;
the small-sample local-variance bias MC interval [.0550,.3310] crosses the
prespecified .08 practical threshold. None meets the frozen clear-adverse-bias
rule, which does not establish negligible bias. Complete estimates and MC
intervals are in `population.csv` and `contrast_summary.csv`; these original
secondary summaries are conditional on original numerical availability.

Ability-band summaries remain descriptive. In the positive-variance cells,
original testlet coverage in the two tails ranges about 81–91%, compared with
about 96–97% in the central band. Even known-calibration oracle band coverage
is not uniformly 95% (about 85–92% in those tails). Dataset-weighted band
summaries do not test a fixed-ability 95% claim; the marginal property cannot
be transferred to each ability. All band counts and MC intervals are retained.



## Numerical reference and reproducibility checks

Preflight contained sixteen datasets; fourteen initial testlet fits were
numerically ready. Two null-control grid failures passed at the prespecified
higher order, with all selected scores available. Their original results are
preserved. The cost probe's missing Task facet produced an ordinary duplicate-
cell warning; both models in preflight/main explicitly include Task, and the
original probe remains preserved.

An estimated-zero-local-variance preflight fit and its separately fitted
ordinary reference have a maximum discrepancy of 9.419728e-7 across EAP,
conditional SD and both endpoints after population-origin alignment. Their
ability variances differ by 8.981457e-7. Public `compare_mfrm()` replay matches.
For a sparse 3+1-rating Person, an independent nested `stats::integrate()`
calculation from direct adjacent probabilities verifies the oracle EAP/SD
(errors 1.11e-16/0) and both continuous tail probabilities (errors
5.21e-11/1.56e-11). These are numerical checks, not statistical qualification.

The full-roster audit checks source identity, disjoint seeds, event
multiplicities in both models, all selected truths/statuses, dataset MCSEs,
paired denominators and public Person-comparison coordinates. It does not
refit or rescore. Existing independent tensor gradients, continuous scoring,
report/map replay and model diagnostics checks are reused.

## Numerical selection issue and separate repair

Main trials 147 and 222 exposed a selection issue: the best-by-objective
start reported an abnormal line-search termination, while a converged start
was only 1.14e-12 or 5.68e-13 worse in the same optimization objective. Maximum
parameter differences were 1.99e-7 and 1.39e-7. The original selector chose
the failed start and withheld scores. These failures remain in the original
study; they are not evidence of a statistical coverage deficit.

The implemented repair prefers a converged start only within 64 machine epsilons
times max(1, abs(best objective)). It preserves the best failed start when
converged alternatives are materially worse, and retains every existing
higher-order, projected-gradient, search-bound and information check. Saved
preflight selections are unchanged in all sixteen cases. No production change
was made during the frozen main study.

The complete saved-run scan found exactly fourteen affected final fits; all
other 466 selections are unchanged. Every affected fit was refitted at its
recorded final quadrature order and scored for the same twelve Persons. Four
first-eligible unchanged controls, one per condition, were also
refitted. All eighteen pass numerical/information checks and return twelve
available scores. Each repaired parameter vector equals the saved converged
candidate exactly; its difference from the formerly selected failed vector is
at most 1.292122e-6. All four controls retain exactly the same parameters and
EAP/SD/endpoints. Public same-data comparisons pass on all eighteen.

The repair uses no extra optimization start, new estimator or relaxed
criterion. All original main fits, attempts, errors and summaries remain
unchanged. Saved affected models require refitting and rescoring; printing
old unavailable outputs cannot apply the correction. Repair source snapshots,
roster, logs, checks and scores are retained separately.

### Post-repair replay

This supplements the original comparison using repaired scores for the
fourteen affected datasets and saved scores for the unchanged 466. It is not
an independent confirmation sample or a default-order study. The four
controls verify deterministic replay; no full simulation was repeated.
All 120 panels per cell are available (exact availability lower bound 96.97%).

| Condition | Complete / 120 | Coverage, 95% MC interval | MCSE (pp) | Original rule applied to replay |
| --- | --- | --- | --- | --- |
| Null, N=120 | 120/120 | 95.14% [93.88, 96.40] | 0.64 | bounded_support |
| Positive, N=120 | 120/120 | 94.44% [93.13, 95.76] | 0.66 | bounded_support |
| Positive, N=24 | 120/120 | 91.74% [89.73, 93.74] | 1.01 | inconclusive |
| Sparse unequal, N=120 | 120/120 | 93.33% [91.94, 94.72] | 0.70 | inconclusive |

The same original decision rule now gives bounded support in the two N=120
balanced conditions, but remains inconclusive for small and sparse samples.
These are explicitly post-repair decisions; the original decisions above
are not overwritten. Bounded support allows the prespecified tolerance and
is not proof of exact 95% coverage or performance outside this design.

### Paired Person outcomes after repair

Differences are testlet minus comparator. Positive MSE differences mean
larger error. All rows now have 120 independent dataset pairs.

| Condition | Comparator | Pairs | MSE difference, 95% MC interval | Coverage difference (pp), 95% MC interval | Width difference (logits) |
| --- | --- | --- | --- | --- | --- |
| Null, N=120 | ordinary | 120 | 0.00026 [-0.00005, 0.00057] | 0.07 [-0.07, 0.21] | 0.059 |
| Null, N=120 | oracle | 120 | 0.01750 [0.00797, 0.02704] | 0.07 [-0.84, 0.97] | 0.062 |
| Positive, N=120 | ordinary | 120 | 0.00665 [0.00190, 0.01140] | 9.51 [8.13, 10.90] | 0.780 |
| Positive, N=120 | oracle | 120 | 0.02802 [0.00906, 0.04698] | -1.25 [-2.02, -0.48] | 0.033 |
| Positive, N=24 | ordinary | 120 | 0.05174 [0.02582, 0.07766] | 8.40 [6.77, 10.03] | 0.757 |
| Positive, N=24 | oracle | 120 | 0.11043 [0.05818, 0.16269] | -2.50 [-4.35, -0.65] | 0.017 |
| Sparse unequal, N=120 | ordinary | 120 | 0.00778 [-0.00228, 0.01784] | 7.64 [6.22, 9.05] | 0.673 |
| Sparse unequal, N=120 | oracle | 120 | 0.04589 [0.02693, 0.06485] | -0.97 [-2.18, 0.23] | 0.014 |

The improved coverage relative to ordinary RSM does **not** imply better point
scores: the balanced positive-variance conditions have increased EAP MSE,
with paired MC intervals excluding zero. The null and sparse MSE comparisons
are inconclusive, not equivalence. Testlet interval widths average 2.441,
3.073,3.056,3.259 logits; ordinary widths average 2.381,2.293,2.299,2.587.
A width increase alone does not demonstrate better measurement. The paired
oracle comparison still shows lost coverage of 1.25 pp and 2.50 pp in the
balanced positive-variance conditions. Numerical repair did not propagate
calibration uncertainty or remove this statistical limitation.

## Output, checks and roadmap decision

Retain correctly labeled conditional Person EAPs, posterior SDs and equal-tail
intervals, with existing unavailability and variance-boundary rules. Their
mathematical conditioning is explicit; no frequentist calibration-adjusted,
fixed-ability, new-Person or universal 95% claim is retained. The study does
not support automatic model choice or uniformly better point accuracy.
Regular fixed-facet intervals remain labeled observed-information normal
approximations; their secondary qualification is inconclusive and cannot be
promoted to established coverage. No variance interval is added.

The two API help topics, scoring tutorial, application tutorial, interval
lookup and NEWS now explain the numerical correction and the observed
coverage/point-accuracy tradeoff. The public roadmap and active evidence
ledger distinguish this completed comparison from unresolved qualification.
Shared-rater Laplace/scoring/uncertainty, assigned-score MI adequacy and final
source integration remain required. M3 and M5 remain incomplete; this is not
a release or a reason to drop a mandatory outcome. The next cross-workflow
priority is the required defensible assigned-score MI example and its
inferential target, while keeping shared-rater and regular-calibration
uncertainty decisions explicit.

Targeted tests cover selection ties, materially worse converged alternatives,
all-failed/nonfinite cases and existing testlet/fixed-or-estimated-population
behavior. All three test files pass; the interval lookup retains its scope.
No full test suite or earlier statistical study was repeated. Changed help
and tutorial verification is recorded with the final checks below.


Main generator MD5: `ab0d8eb4a178159c986dea67e4688c0a`;
main protocol MD5: `7ff22ed58cd58a3c43b467acaf1903e5`.


### Final focused checks

Selection (8), existing testlet (74) and population (49) expectations pass:
131 passed, with zero failures, warnings, errors or skips. The changed
interval-guide row also passes. A first attempt to summarize the saved test
object lacked the loaded testthat S3 method; loading testthat summarized the
existing results without repeating any tests.

Both changed help topics were regenerated in isolation, parsed/checked and
rendered to HTML. Isolated roxygen topic-discovery warnings were checked
against the full package's existing aliases; all referenced local topics
exist. The two tutorials' changed prose/tables were rendered with existing
code displayed but not re-executed. The HTML table values match the saved
statistics. No fitting/planning examples changed. A browser was unavailable
to CUA, so no visual browser sign-off is claimed; HTML generation and structure
were verified. The previous executed examples/plots remain their own evidence.

Current R computations match the tested repair snapshot exactly after
removing comments; later edits change only help prose. The original frozen
source remains intact, and the corrected Person accounting preserves all
17,280 method/Person rows across 480 datasets. `git diff --check` passes.
No integrated package check, five-environment CI, main integration or publication
was performed. These remain outside this completed bounded checkpoint.
