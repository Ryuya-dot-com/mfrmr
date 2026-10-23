# JML structural inference: literature and implementation review

Date: 2026-09-27. Local development review; no new inferential API qualified.

## October 13 — Adjusted-score inversion and bootstrap: adoption decision

**Decision following the user's proposal.** Select nuisance-adjusted score
test inversion as a distinct corrected-JML candidate. It reuses the actual
Person equations and can avoid dividing by weak interest-parameter curvature;
it is not an assumed cure for finite-exposure centering. Keep r* on the
existing observed-marginal EM/profile route. A scalar adjusted-likelihood
ratio is conditional on deriving an appropriate objective, which the present
iterated equation does not supply. Bootstrap calibration is a later layer on
a specified statistic and sampling law, not a reason to begin a large batch.
This decision supplements the retained October 3 bootstrap work rather than
restarting it. No existing statistical obligation is closed or removed.

### 1. Equation, projection and variance contract

Let beta=(psi,lambda), with scalar psi a declared structural coordinate (or
a contrast after a declared linear coordinate transformation). Write

    F(beta) = N^-1 sum_j U_j(beta),
    A(beta) = dF(beta)/d beta'.

Here U_j is the complete order-k contribution returned by
`mfrm_jml_adjustment_problem()`: Person ability is already profiled at each
beta, and the MLE-plug-in transition adjustment is recomputed there. The
implementation uses a negative-score convention; reversing all signs reverses
T and leaves the two-sided test unchanged. Fix psi, solve F_lambda=0 for a
declared branch lambda_tilde(psi), and evaluate the **full nonsymmetric** A
there. Holding the fitted abilities or the correction operator fixed while
differentiating would be a different equation. If A_lambda,lambda is regular,

    w = (1, -A_psi,lambda A_lambda,lambda^-1),
    u_j = w U_j,
    T(psi) = sum_j u_j / sqrt(sum_g sum_(j in g) (u_j-ubar_g)^2).

The last formula matches the existing fixed-roster sampling contract:
independent new Persons from each roster population, fixed roster counts,
and centering within roster g. Global centering is the different random-roster
contract. The denominator is the variance of the projected **sum**; applying
the inverse full Jacobian again would double-apply the transformation. At an
exact constrained root, sum u_j=sum U_psi,j, but the individual nuisance
contributions must remain in the variance. Center only for the meat, never
replace the estimating equation by residuals whose group sums are identically
zero. Small roster counts remain a statistical limitation, not solved by the
computational minimum of two Persons per group.

The ordinary Taylor expansion gives the projection: if lambda_0 solves the
population nuisance equation at psi, then
F_psi(psi,lambda_tilde)=F_psi(psi,lambda_0)
- A_psi,lambda A_lambda,lambda^-1 F_lambda(psi,lambda_0)
+ o_p(N^-1/2), under the matching root-consistency and regularity conditions.
Consequently a matching CLT, consistent meat and negligible projected mean
are needed for T to have a standard-normal limit. Independence alone supplies
none of the latter conditions. This is the generalized-score-test principle;
[Boos (1992)](https://doi.org/10.1080/00031305.1992.10475921) is a primary
reference (publisher abstract inspected here; full text not obtained).

The full-root covariance API cannot simply be called at these null points:
`mfrm_jml_adjustment_covariance()` requires all mean equations to be zero
and the full A to pass its rank check. A future internal null-statistic helper
must share the contribution/derivative conventions but check the nuisance
block, projected variance, constrained residual and branch stability instead.
Do not relax the existing covariance checks. A singular interest direction
may cease to prevent evaluating the statistic; it does not automatically
establish weak-identification-robust inference.

### 2. What differs from Wald, and what does not

Let S=A_psi,psi-A_psi,lambda A_lambda,lambda^-1 A_lambda,psi and let
B=N^-1 sum_j centered(U_j) centered(U_j)'. At a regular unrestricted root,

    w A = (S,0),
    (A^-1 B A^-T)_psi,psi / N = (w B w')/(N S^2).

Thus score inversion agrees locally, to first order, with the existing
root-Wald construction. Its possible improvement comes from evaluating the
constrained nonlinear path and variance at the tested value, avoiding a full
inverse/finite unrestricted estimate where possible, and using an appropriate
reference distribution. It cannot remove structural centering bias merely by
rewriting the same local sandwich.

**Saved-only check.** Reused all sixteen N20/N60, L1/L2 pilot fits, their saved
full Jacobians, Person contributions, fixed-roster groups and covariance
matrices. Source/input/completion and deletion-manifest hashes were checked;
no package was loaded, no derivative recomputed and no data or fits generated.
Across eighty free-coordinate checks, the maximum relative covariance
discrepancy is 1.519e-15 and the block identity error is 2.221e-16. All examined
nuisance blocks are nonsingular (minimum singular value .06678). The arithmetic
is to form w and S above, center the saved U within saved groups, and compare
`sum((centered_U %*% w)^2)/(N*S)^2` to the saved diagonal covariance.
Results are retained in
`tmp/score-inversion-review-20261013/saved-algebra.csv`. These are unrestricted
saved-root checks, not evaluations along a new constrained path or coverage
evidence.

Finite-exposure bias remains decisive. If the population equation root differs
from structural truth, the projected score at the true psi can retain a
nonzero mean. Studentization estimates dispersion, not that mean. The order
of the remainder must match the actual correction: the earlier repeated-block
order-2 derivation gives root displacement O(L^-3), subject to its assumptions;
O(m^-2) is not a universal label for every correction or design. A normal
cutoff requires centering error negligible on the SE scale, or a separate
valid bias-aware/calibration argument. The fixed-exposure identification
obstruction and the existing conditional identified-contrast routes remain
part of D1; no score test can supply information absent from the model.

### 3. Confidence sets and honest unbounded reporting

The mathematical result is a set {psi: |T(psi)|<=z_(1-alpha/2)}, which need
not be one connected interval. A continuation from a local root does not
prove that all nuisance branches or accepted components have been found.
Record the branch rule, each evaluated statistic and unresolved ranges.
Distinguish a finite crossing, a justified unbounded accepted tail, and a
tail not resolved because of search extent, variance failure or a failed
nuisance solve. No crossing on a finite grid does not prove infinity.

If user-facing output includes unresolved tails conservatively to infinity,
label it an **outer confidence-set envelope with unresolved search**, not an
established infinite endpoint of the exact inverted set. This preserves useful
bounds without silently treating a numerical failure as statistical acceptance.
Proven containment would transfer any separately justified coverage; the
envelope does not create a calibration theorem. Respect the parameter space:
minus infinity on a log-slope scale maps to zero on the positive-slope scale.

### 4. Adjusted likelihood is a separate prerequisite

For a C2 scalar objective with this exact equation as gradient, the Jacobian
must be symmetric. The retained sixteen-fit asymmetry (.0111–.1354, versus
derivative-step discrepancies below 2.1e-8) excludes that interpretation of the
current iterated equation in its stated coordinates. This does not exclude a
different objective, an explicitly derived integrating transformation or a
target-specific construction; none is obtained by simply symmetrizing A or
calling a one-dimensional path integral a joint profile likelihood.

Arellano and Hahn's review distinguishes equation and objective corrections
and establishes equality for particular corrections, not for every adjusted
score. Read the page-separated text of their author working paper, PDF
pp. 10–15 (printed pp. 8–13), especially equations (18), (20), (29)–(38).
The consulted source is the [October 2005 CEMFI paper](https://www.cemfi.es/ftp/wp/0507.pdf),
not an asserted page-for-page reading of the 2007 book chapter. No matching
Arellano title/creator library item was returned, and Zotero was not modified.

Even an objective with the right root does not by itself justify r_A~N(0,1).
Multiplying an ordinary log likelihood by c>0 leaves its maximizer unchanged
but multiplies the LR by c. Bias, information/variability calibration and the
applicable likelihood-ratio theorem must therefore be checked. A new
Arellano–Hahn-type objective would be a distinct candidate, not an extra output
attached to the present order-2 root. Do not open a second objective-development
project before the simpler equation-based test has a decision-relevant result.

### 5. Parametric calibration: complete procedure and generating law

The proposed null-specific bootstrap is plausible: for each tested psi_0,
generate at (psi_0,lambda_tilde(psi_0)) using a declared ability/design law,
then recompute Person profiles, the correction, constrained nuisance root,
full derivative, projection and variance for every draw. A pure score test
needs no extra unrestricted fit unless its defined root-selection procedure
uses one; an r_A statistic needs both constrained and unrestricted objectives.
Reuse original fits for starts only, never as fixed bootstrap nuisance values.
Calibrate either the signed distribution with its two quantiles, or |T*| with
its .95 quantile. Freeze that choice; do not assume symmetry or remove the
bootstrap mean if the purpose is to reproduce remaining null displacement.

Re-read Zotero Higgins & Jochmans (2024), parent `6DPLH5S5`, PDF `FM9KM2UF`,
pp. 4–11 individually (printed pp. 414–421). Their ordinary-ML distribution,
basic/studentized inference and assumptions provide real support for the idea
of reproducing incidental-parameter bias. They do not establish the present
adjusted-root test. In particular, their LR bootstrap uses an unrestricted
plug-in generator and a recentered constraint; the null-constrained generator
proposed here is not a literal implementation of that paper. Its compactness,
within-Person identification and jointly growing N,m conditions remain as
reviewed in the October 3 sections below. Studentization is justified in that
regime but the biased limit is not pivotal; higher-order gains and double-
bootstrap refinement are not automatic. [Published article](https://doi.org/10.3982/ECTA20712).

Bootstrap consistency would allow reproduction of residual bias, discreteness
and joint estimation dependence; running the whole algorithm alone is not a
proof of that consistency. Increasing B reduces inner simulation error, not
nuisance plug-in error. No assertion of complete absorption or finite-N exact
coverage is adopted. Existing failed-draw/rank-envelope and Monte Carlo error
work is reusable; successful-only quantiles are not.

The generating abilities are a methodological choice, not a numerical patch.
The current structural correction still returns profiled extreme abilities
as +/-Inf; a corrected structural estimate is not an independently justified
finite bias-corrected ability estimator. Those extreme plug-in generators are
degenerate. Shrinkage or finite corrections need a stated rule, scale and
hyperparameter treatment; if part of estimation, refit them in every draw.
Holding a list of shrunken abilities fixed approximates a conditional
fixed-ability experiment. Drawing new abilities within each roster from a
specified distribution approximates the existing new-Person population law.
They are different experiments and need matching claims. In particular,
between-ability variation in nonzero conditional mean adjusted scores can
enter the current within-roster meat; independence does not make it a
conditional-on-every-ability variance estimator.

### 6. Bounded next decision

The r* saved-point observed-marginal equivalence/cost check is now
[complete](internal-roadmap-0.2.4.md#october-13-r-observed-likelihood-kernel-decision):
reuse the existing fixed-241 evaluator as a search candidate with adaptive
final checks; reject an unconditional fixed-121 replacement and a slower
specialized backend. No coverage allocation follows from that component result.
The constrained-score comparison and subsequent known-law calibration screen
are now complete, as recorded below. The latter rejects the uncalibrated
normal-reference rule in all four N20 cells, while N60 remains inconclusive
at its declared precision. Retain adjusted-score calibration as a candidate;
do not inflate SEs or substitute these eight empirical quantiles as a general
rule. The subsequent bounded structural-nuisance substitution comparison is
also complete, with the ability law held known: 791/792 statistics return,
but conditional distribution equivalence is unresolved at B=99. The subsequent
population-centering and saved-score component checks are also complete below.
Their small drift mismatch does not warrant a tiny-bias repair campaign;
the score's estimated denominator has a much larger practical diagnostic
effect at N20. Preserve the complete null-specific calibration candidate and
design its bounded finite-N evaluation, without adopting oracle variances,
empirical cutoffs or a fixed-exposure exactness claim. Do not add estimated
abilities or an outer coverage batch before that complete-procedure contract
and cost/precision decision are fixed.
Reuse a reference distribution across observed datasets only when its entire
design/N/exposure/null/generating law is identical. Null-constrained plug-in
generators generally differ between datasets and cannot share that reference
as though it were their bootstrap distribution. Preserve all draws and
separate inner B from outer R. No large allocation or endpoint search follows
automatically. Release scope and the other GMFRM/population questions remain
unchanged; these research candidates do not block independent ready outputs.

## October 13 — Independent primary bootstrap screen

**Completed decision.** The frozen Rater/N20/L1 primary screen completes all
99 new independent outer samples. The unchanged normal-reference rule rejects
truth 14 times; the null-specific bootstrap rejects six times. Every outer
decision is determined, including four whose inner calculations contain a
failure. Retain the bootstrap candidate: this is evidence of a reduction in
truth rejection in the stated condition, but its nominal-size claim remains
**unresolved**, not qualified. The normal-reference procedure remains
**repair required** under the prespecified gross-inflation screen. Do not
increase R/B on these results or automatically launch all seven other cells.

The manifest was saved before generation, reserving all 9,900 streams beyond
the preceding 792 planned streams, including unused suffixes. The complete
calculation expression matches the checked computational pilot exactly. No
outer samples from method development were reused. The single primary target,
all-attempt denominator, ten-rejection screen, MC precision and cost were fixed
in the following section before these outcomes. The normal comparison uses
the same new outer statistics; no sampling or numerical settings changed.

The evaluated procedure includes the finite B=99 Monte Carlo randomization.
Outer rejection rates therefore average over both new data and independently
reserved inner draws. They do not estimate the size of an ideal infinite-B
bootstrap, and a later change in B would be a changed procedure. The exact
outer binomial MC calculation does not make the nuisance plug-in test itself
finite-sample exact. All 99 outer attempts are retained even when a decision
remains unresolved.

| Rule | Truth rejections / all attempts | Rejection rate | Exact 95% MC interval | One-sided gross-inflation p | Prespecified disposition |
| --- | ---: | ---: | --- | ---: | --- |
| Normal reference | 14 / 99 | 14.14% | [7.95%, 22.59%] | .0004174 | Repair required |
| Null-specific bootstrap, B=99 | 6 / 99 | 6.06% | [2.26%, 12.73%] | .3750 | Inflation not detected; not qualified |

All six bootstrap rejections also occur under the normal rule; eight normal
rejections become nonrejections and none switch the other way. The paired
change is -8.081 percentage points, MCSE 2.753 points; the prespecified
secondary exact discordance test gives p=.0078125. This supports a comparison
within this design and law, not a universal improvement or an equivalence
claim to nominal 5%. The bootstrap MC interval still permits materially
greater rejection than 5%. A wider acceptance region also does not establish
useful confidence-set width or power. These were truth-membership decisions,
not delivered interval endpoints.

All 99 observed statistics return. Of 2,094 attempted inner calculations,
2,090 return; the four unavailable nuisance-root calculations are retained
at outer/draw (17,3), (41,3), (42,9) and (76,7). Each used all six prescribed
start/stage attempts. All four parent decisions are nonrejections even after
the unknown draws and unattempted suffixes are retained in the bounds; none
was replaced, discarded or individually rescued. There are therefore zero
unresolved outer decisions. The observed 99/99 determination rate has exact
95% MC interval [.9634243,1], not a general guarantee of complete delivery.
Retain the complete failure records without treating them as proof that no
finite nuisance root exists.

**Cost and numerical evidence.** The primary run took 1,122.572 seconds
(18 minutes 42.572 seconds) including loading/I/O. Generation/calculation
totaled 1,114.448 seconds: 48.457 outer and 1,065.991 inner. The completion
rule avoided 7,707 of the 9,801 planned inner calculations (78.63%). The
executed inner count per parent ranges from 5 to 97, median 11; the mean is
21.15. This is a calculation-count saving in this cell, not a measured
78.63% wall-time speedup or a forecast for all other conditions.

Fresh saved-only replay passes with warnings treated as errors. Independent
arithmetic checks verify all 2,193 generated inputs and 2,193 consumed
decision prefixes, stream assignment, coordinate-transformed statistics and
binomial/paired summaries. Maximum coordinate discrepancy is 1.777e-15 and
probability discrepancy 4.997e-16. Among available calculations, maximum
nuisance residual is 9.983e-11, root spread 9.878e-9 and derivative-step error
2.501e-8; minimum nuisance singular value is .00302224.
Extreme-Person counts range from 0 to 7;
all are retained. The 4,402 solver attempts comprise 4,386 at stage one and
eight at each of stages two and three. A generation/refit-blocked restart
reproduces all decisions in 1.235 seconds, and saved numerical artifacts are
unchanged. No successful estimation was rerun for reporting verification.

Evidence: `validation-results/jml-score-bootstrap-primary-20261013/`;
driver: `jml-score-bootstrap-primary-20261013.R` (prepare/run/replay, frozen
installed package, four thread variables set to 1). `run` resumes saved inputs,
fits and decisions without recalculating completed numerical work. `check.R`
and `verification.rds` record the independent saved-data audit. These are
private research files; no public estimator, help/API contract or release
artifact changed, so a package rebuild/full test suite was not repeated.

**Next bounded decision and explicit priority refinement.** The primary
screen makes a conditional benefit credible, but it uses an ability law that
an ordinary user does not know. Seven more known-law cells could examine
design dependence; they cannot determine how a user constructs the generator.
Before buying that expansion, specify a computable ability-law procedure and
its sensitivity assessment. Reuse the October 3 bootstrap/ability plug-in
review and the user's corrected/shrunken-ability proposal; distinguish fixed
Person plug-in values from sampling new Persons within each roster. Fix the
estimand, law assumptions, null-specific estimation, extreme-Person treatment
and failure rule before fitting a new generator or allocating outer data.
Do not silently use the inaccessible true mixture, substitute divergent raw
Person MLEs, or infer a theorem from the present empirical improvement.

This is a priority change after the planned statistical decision, not a
reduction in the intended design domain. Retain both owners, N20/N60, L1/L2
and the earlier medium/large-N evidence; broader claims still need the matching
comparisons for the actually proposed procedure. Do not now launch the seven
known-law cells, add replications to this completed primary sample, or open
an endpoint/optimizer campaign. Saved samples may be reused for development
and sensitivity work, but would not be independent confirmation of a revised
generator or revised method. The current candidate's nominal-size guarantee,
unknown-ability applicability, useful width/power and public integration remain
open. This completes this primary allocation's D1.3/D1.4 decision, not D1.5.

## October 13 — Complete bootstrap procedure and computational completion

**Outcome.** The null-specific bootstrap procedure now has a checked
prospective research implementation. Fixed-B completion preserves the declared
decision, including failures. It reduced the eight existing development cases
from 792 to 73 needed inner calculations on saved replay; an actual run on the
remaining eight original views required 100 calculations and 61.193 seconds.
These are process and cost results, not evidence of nominal coverage or a
qualified public interval. This closes the computational unit; do not turn it
into another optimizer or stopping-rule project.

### Complete statistical and failure contract

For each tested structural value psi, obtain the observed constrained nuisance
root using the retained two-start/stage/check policy. Calculate the complete
order-2 projected, within-roster-studentized score. If it is unavailable, the
membership decision is unresolved. Otherwise generate from this observed
null-constrained structural vector, with the roster-specific ability mixture
held known in this phase. Keep the roster counts and exposure design fixed,
including every extreme Person. Each generated dataset independently repeats
the nuisance solve, Person profiling, correction, full nonsymmetric derivative,
projection and variance. Neither the observed nuisance estimate nor the
observed denominator is held fixed during refitting. The target is the shared
owner's log slope ratio, psi=.5; this is not yet inversion for endpoints.

With B=99 fixed in advance, the complete-data reference is

    p = (1 + sum_b 1{|T_b*| >= |T_obs|}) / 100.

Ties are inclusive. After n attempts, let e be the known exceedances and f the
unavailable inner statistics. Retain the conservative completion bounds

    p_lower = (1+e)/100,
    p_upper = (1+e+f+99-n)/100.

Stop with nonrejection when p_lower>.05 and with rejection when p_upper<=.05.
Otherwise continue until B; a straddling interval at B is unresolved. Failed
calculations are unknown, not nonexceedances, and are never replaced. This
finite-statistic implementation treats nonfinite results as unavailable; it
does not interpret an overflow as a proved infinite statistic. A known five
exceedances implies nonrejection; rejection can first occur after 95 successful
nonexceedances. With failures, some decisions can still be established, while
others remain unresolved. A bound such as [.06,.90] is a logical range over
the unfinished planned calculation, not a confidence interval or an estimate
of p=.06. A nonrejection does not prove that psi is true.

Both bounds become no less decisive as results arrive. Thus early stopping
returns exactly the full-B decision whenever it can be established for every
completion; no optional-stopping approximation is introduced. This arithmetic
property supplies **no additional statistical validity theorem** for the
nuisance plug-in bootstrap. The finite-exposure centering and unknown-ability
limitations in the preceding review remain in force.

### Saved comparison, actual execution and checks

The completion driver enumerated 3,280 ternary prefixes and 32,640 binary
completions, plus thirteen explicit tie, .05-boundary, failure and unavailable-
observation controls. All bounds and decisions match independent enumeration.
For each of eight retained conditional banks, it also checked all 100 prefixes
at six deterministic thresholds; all terminal decisions match the complete
bank. The probes are arithmetic/cost controls, not additional observations.

| Probe on eight retained banks | Inner calculations needed / planned | Retained calculation plus generation time of consumed prefixes |
| --- | ---: | ---: |
| Actual first-replicate observed statistics | 73 / 792 | 48.255 s |
| Normal-reference threshold 1.960 | 493 / 792 | 307.229 s |
| Tail probe 3.291 | 748 / 792 | 442.078 s |
| Above every returned statistic in each bank | 761 / 792 | 451.026 s |

The complete banks cost 469.232 seconds. These prefix sums reuse recorded
times; they are not a new wall-time benchmark. The low observed statistics
explain the large first-row saving. Do not extrapolate it to tail cases. The
one retained failed calculation remains in the bounds where it is consumed.
Saved review took 1.3 seconds; a fresh replay also passes with warnings treated
as errors.

The prospective execution allocation was frozen before generation: all eight
remaining original views (replicate 2 of each design/N/L), four original
parents, no new outer datasets. The 792 planned L'Ecuyer streams were fixed
after the earlier reference bank, one per case/draw, including suffixes that
would never be attempted. This preserves restart behavior and avoids moving
later cases onto earlier streams because a previous case stopped early.

| Owner | N | L | Actual inner attempts | Decision |
| --- | ---: | ---: | ---: | --- |
| Criterion | 20 | 1 | 15 | Nonreject |
| Criterion | 20 | 2 | 10 | Nonreject |
| Rater | 20 | 1 | 15 | Nonreject |
| Rater | 20 | 2 | 35 | Nonreject |
| Criterion | 60 | 1 | 6 | Nonreject |
| Criterion | 60 | 2 | 6 | Nonreject |
| Rater | 60 | 1 | 5 | Nonreject |
| Rater | 60 | 2 | 8 | Nonreject |

All 100 attempted statistics returned and all 200 original starts passed at
stage one. Generation/calculation cost was 60.475 seconds; actual run cost
was 61.193 seconds including loading/I/O. The 692 unused suffix draws were
not generated or fitted. The underlying complete null-calculation expression
is syntactically identical to the checked conditional-bank driver. Fresh
saved-only replay passes; independent checks verify all 100 input contracts,
coordinate-transformed statistics and all 108 consumed decision prefixes.
Maximum nuisance residual is 9.801e-11, root spread 1.637e-9 and derivative
step discrepancy 9.554e-9; minimum nuisance singular value is .01236.
Extreme-Person counts range from 0 to 10 and none are discarded. A restart
with generation and refitting blocked reproduces every case in .074 seconds
without new numerical work. Neither run demonstrates tail-frequency accuracy:
all eight observed |T| values are below 1.842.

Evidence and reproducible drivers:

- `validation-results/jml-score-bootstrap-completion-20261013/` and
  `jml-score-bootstrap-completion-20261013.R` (review/replay; base R only).
- `validation-results/jml-score-bootstrap-membership-20261013/` and
  `jml-score-bootstrap-membership-20261013.R` (prepare/run/replay, frozen
  package and four thread variables set to 1). Inputs are saved before fits;
  completed fits and decisions are reused on restart.

### Prespecified primary-screen contract (now completed above)

The next question is whether this **unchanged complete procedure** repairs
gross N20 truth-rejection inflation even when the ability law is known. It is
not whether another eight easy examples finish. Use a primary screen of
**99 new independent outer datasets at Rater/N20/L1**, the prespecified cell
with the largest previous normal-reference inflation (20/99). Previous banks
and all sixteen original views are development data; do not relabel them as
independent confirmation. Fix psi=.5, the same structural vector, roster law,
correction order, numerical policy, B=99 and completion rule. Reserve new
outer and inner streams beyond **all** 792 planned streams in this unit,
including those unused. Compare the normal and calibrated decisions on the
same new outer datasets and keep every unavailable observed or inner result.

At R=99, the rejection-probability MCSE is .02190 at .05 (maximum .05025).
A one-sided exact binomial screen at .05 first rejects at 10 known rejections;
its power is .94047 at true rejection probability .15 but only .53552 at .10.
This is a gross-inflation screen, not a precise 95%-coverage demonstration.
With k definite rejections and u unresolved outer decisions, report the
all-attempt identification range [k/99,(k+u)/99] and the corresponding exact
MC envelope. A lower-bound count of at least 10 requires repair; counts whose
possible completions straddle that screen remain unresolved. Even a fully
identified nonsignificant result does not qualify the method. Keep the paired
normal comparison and availability explicit. Complete the fixed 99 outer
attempts without replacing failures or extending R to obtain a favorable
result; this is the only primary cell, not eight unadjusted primary tests.

Do not launch all eight cells merely because the runner now works. At the
recorded complete-bank costs, 99 outer datasets in all eight cells would need
up to 78,408 inner calculations and about **12.9 hours** of generation/fitting
if all inner draws are needed. These are cost projections, not upper time
guarantees. The selected Rater/N20/L1 primary screen instead plans at most
9,801 inner calculations; its corresponding conditional-bank cost projects
about **78 minutes**, plus roughly a minute for outer calculations and I/O.
Completion may reduce that substantially, but the eight easy cases do not
justify a precise shorter forecast. No outer screen was launched in this
computational unit. Its manifest must bind the above contract before execution.

If the primary screen needs repair, use that result to reconsider the method
before buying the remaining seven comparisons. If it warrants further study,
retain both owners, L1/L2 and N20/N60 for the next predeclared comparison; this
priority does not remove their obligations or the earlier medium/large-N
evidence. Estimating the ability law, endpoint delivery, useful width/power
and public integration remain separate requirements. A known-law primary
success alone cannot support a practical bootstrap API or close D1.

## October 13 — Population centering and saved-score component decision

**Decision.** The population-centering check is complete. The standardized
drift of the null-constrained plug-in law is numerically different from that
of the original law in all four examined design/exposure cells, but this
difference is too small on the examined N20/N60 scale to make it the next
repair priority. Do not turn a fixed-exposure asymptotic mismatch into either
a claim of practical failure at N20 or another campaign of tiny-bias corrections.
Saved-only component comparisons instead support retaining calibration of the
complete studentized statistic, including its fitted denominator. They do not
supply an implementable oracle correction or qualify a bootstrap interval.

**Population calculation and its meaning.** Write d(gamma)=b(gamma)/s(gamma)
for the projected score's mean divided by its within-roster SD per Person,
after solving the population nuisance equation at psi=.5. The fitted null
generator's limiting structural vector is gamma-dagger, as defined in the
next section. Re-solve its nuisance equation; do not hold the first root fixed
when evaluating its bootstrap limit. Results below use order 2, the same known
three-point ability law, centered positive slopes and fixed roster proportions.
There is no N-specific population refit.

| Owner and design | L | d(gamma0) | d(gamma-dagger) | Difference in absolute drift | Absolute leading-gap size at N20 |
| --- | ---: | ---: | ---: | ---: | ---: |
| Criterion, unequal | 1 | -.0053008313 | -.0052690572 | -3.17741e-5 | .00014210 |
| Rater, sparse | 1 | .0057706326 | .0057445181 | -2.61145e-5 | .00011679 |
| Criterion, unequal | 2 | .0036882171 | .0036879836 | -2.33519e-7 | .00000104 |
| Rater, sparse | 2 | .0048660105 | .0048621944 | -3.81609e-6 | .00001707 |

The largest absolute leading-gap size is .0002462 at N60 and .0006962 at
N480. These multiply the same population coefficient by sqrt(N); they are
not new simulations, finite-N mean estimates or coverage estimates. The
original-law leading center itself is only .0165–.0258 in absolute value at
N20. These values do not account for the finite-N random denominator and
nuisance fitting and must not be presented as the exact expected T.

There is nevertheless a mathematical limitation. If the selected sample and
bootstrap roots converge to the stated stable population branches and their
projected variances converge to positive limits, then

    |T_N| / sqrt(N) -> |d(gamma0)|,
    q*_.95 / sqrt(N) -> |d(gamma-dagger)|.

Thus a strict leading-drift inequality cannot yield asymptotically nominal
rejection under fixed exposure. Under those convergence conditions, a smaller
bootstrap limit would eventually make rejection tend to one, and a larger
limit would make it tend to zero. This is a conditional mathematical implication,
not an outward-rounded proof that the displayed double-precision differences
are nonzero, a global root-selection theorem or a finite-N rejection prediction.
Exact equality would still leave fluctuation and generator-estimation effects
to check. Growing exposure is a different regime. The calculation therefore
precludes asserting exact reproduction on the current evidence, while its size
argues against prioritizing this mechanism for the observed small-N problem.

**Numerical verification and cost.** The original two-start/stage policy
returns all eight population nuisance roots at stage one. Maximum residual
is 4.194e-11, between-start discrepancy 1.358e-10 and derivative-step error
2.252e-9; the minimum nuisance singular value is .21198. Complete Person
variation within owner-total patterns is retained. The previous full population
roots reproduce their saved means and covariance exactly. At all eight new
points, independently enumerated count patterns passed through the frozen
installed package reproduce means within 1.684e-15 and covariance entries
within 9.993e-15. Derivative-step changes in the drift differences are at most
1.225e-15. These last discrepancies measure numerical consistency, not a
rigorous enclosure of root or floating-point error.

The compressed roster spaces have 21–153 owner-total states, compared with
54–3,375 complete count patterns used only for independent verification.
Generation is unnecessary. Calculation and verification took 10.063 seconds
(10.629 seconds for the run including loading/I/O); fresh saved-only replay
passes. Source, contracts, attempts, complete means/covariances and verification
arrays are under `validation-results/jml-score-population-centering-20261013/`,
with driver `jml-score-population-centering-20261013.R`.

**Which part has a larger small-N effect?** Reuse every one of the 792 saved
known-law calculations. The earlier studentization analysis concerns different
root-Wald targets and is not a substitute for this constrained-score comparison.
Look up each observed Person's corrected score in the complete population
pattern tables; this needs no model evaluation, refit or generated response.
Cross fitted versus population-constrained equation/projection values with
estimated versus population variance. Keep the uncentered numerator and the
same 1.96 cutoff. Population values depend on the unknown true generating law;
these are four exploratory diagnostics, not four usable inference methods.

Each entry below is the number of exceedances among the same 99 N20 datasets.
All diagnostic values return; the first column exactly reproduces the original
statistics. "Fixed equation" also fixes the nuisance projection, while retaining
the sample within-roster variance of those projected contributions.

| Owner | L | Original statistic | Only variance fixed | Only equation/projection fixed | Both fixed |
| --- | ---: | ---: | ---: | ---: | ---: |
| Criterion | 1 | 13 | 6 | 9 | 7 |
| Criterion | 2 | 14 | 7 | 10 | 3 |
| Rater | 1 | 20 | 3 | 15 | 6 |
| Rater | 2 | 13 | 6 | 12 | 6 |

Fixing only variance reduces the N20 observed exceedance rate by 7.1–17.2
percentage points; paired MCSEs are 2.59–3.81 points. The SD changes from
1.256–1.414 to 1.019–1.060. Fixing only the equation leaves 9–15 exceedances,
so removing sample nuisance/projection variation alone does not remove the
pattern. This implicates the estimated denominator and its dependence on the
numerator in these data; it is not a unique causal decomposition, proof that
variance is always underestimated, or a universal multiplier/t degrees-of-
freedom formula. At N60 the original 3–6 exceedances become 2–5 with fixed
variance, a smaller difference. Preserve those cells and the earlier larger-N
evidence; do not extrapolate the N20 diagnosis to every design or estimator.

The saved summary retains pointwise MC uncertainty and paired changes for
all 32 design/N/L/diagnostic combinations. Reuse of development data makes
this exploratory evidence, not independent qualification. The computation
took .77 seconds, and a fresh base-R replay passes without loading mfrmr or
initializing an RNG. An initial row-name recycling warning was repaired;
the prior source/result is retained, all numerical rows and summaries are
identical, and replay also passes with warnings treated as errors. Evidence:
`validation-results/jml-score-oracle-components-20261013/`; driver:
`jml-score-oracle-components-20261013.R`.

**Earlier next decision, now implemented and checked in the
[complete-procedure unit](#october-13--complete-bootstrap-procedure-and-computational-completion).**
Keep the user's proposed complete null-specific
bootstrap candidate as a finite-N approximation to evaluate, not as an already
established general fixed-exposure method. Its rationale here is reproducing
the entire ratio distribution, rather than repairing only the very small
population drift. Do not adopt the infeasible population denominator or open
a separate adjusted-likelihood, higher-order or optimizer project.

Before allocating new outer replications, freeze a complete truth-membership
procedure, all-failure accounting, independent-versus-development data roles,
outer MC precision and cost. Reuse the existing finite-B rank bounds to save
work without changing the eventual B=99 test. With the inclusive reference
`p=(1+exceedances)/100`, five known exceedances already imply nonrejection at
.05 regardless of remaining draws. Rejection requires the upper bound,
including unresolved and unattempted draws, to be <=.05. This deterministic
completion rule differs from optional stopping on an estimated p-value.
Retain logical bounds and the full planned denominator; an unresolved result
stays unresolved. That comparison is target membership, not endpoint delivery.
Known-ability finite-N calibration remains unqualified, and estimating the
ability law is still a later, separate issue. No new outer allocation is made
by these diagnostics. This closes their bounded decision, not general JML/D1.

## October 13 — Structural nuisance substitution with known ability law

**Completed outcome and disposition.** The eight preselected generator
comparisons are complete. Retain null-specific calibration as a candidate;
neither substituting nuisance estimates nor reusing the true-law reference is
qualified by this experiment. Seven cells return 99/99 statistics and one
returns 98/99. Below, rates use every attempted draw; the range for the missing
statistic is an identification bound, **not** a Monte Carlo confidence interval.
The normal cutoff is a common distributional probe, not the proposed final
bootstrap rejection rule.

| Owner | N | L | True-law normal exceedance | Plug-in-law normal exceedance | Paired change, percentage points | Paired MCSE, percentage points |
| --- | ---: | ---: | --- | --- | ---: | ---: |
| Criterion | 20 | 1 | 13/99 (13.1%) | 20–21/99 (20.2–21.2%) | +7.1 to +8.1 | unresolved |
| Criterion | 20 | 2 | 14/99 (14.1%) | 14/99 (14.1%) | 0.0 | 4.06 |
| Rater | 20 | 1 | 20/99 (20.2%) | 15/99 (15.2%) | -5.1 | 5.05 |
| Rater | 20 | 2 | 13/99 (13.1%) | 9/99 (9.1%) | -4.0 | 4.52 |
| Criterion | 60 | 1 | 6/99 (6.1%) | 6/99 (6.1%) | 0.0 | 3.21 |
| Criterion | 60 | 2 | 3/99 (3.0%) | 3/99 (3.0%) | 0.0 | 2.49 |
| Rater | 60 | 1 | 3/99 (3.0%) | 5/99 (5.1%) | +2.0 | 2.86 |
| Rater | 60 | 2 | 3/99 (3.0%) | 4/99 (4.0%) | +1.0 | 2.68 |

All seven identified paired tests have Holm p=1; the missing cell's paired
test remains unidentified under the frozen rule. These results do not establish
equal distributions, a reliably signed change or bootstrap coverage. Even the
same total exceedance count can hide different paired decisions. The N20
plug-in empirical .95 absolute-T quantiles are 2.793–3.331, with broad rank
uncertainty; the first cell's pointwise MC upper bound is infinite because of
one unresolved statistic at the highest order statistic. That is uncertainty
about the quantile, not proof of an infinite confidence endpoint.

The single unavailable draw is Criterion/N20/L1 replicate 9 (baseline parent
33). Both first-stage residuals are below 9e-11, but the independently checked
Newton corrections are .517 and 4.723, above 1e-5. The other four prescribed
attempts fail the residual criterion. Keep this as failure of the declared
finite-root procedure, not a demonstrated nonexistence result. Do not bypass
the check or launch a one-case rescue as this unit's next task. All 791
available draws pass both starts at stage one; all 1,588 attempts are retained.

Generation and complete per-draw calculation cost 469.232 seconds; the run
including loading/I/O cost 471.120 seconds. The baseline 792 statistics were
reused without fitting. Fresh saved-only replay and independent checks pass:
all 792 inputs obey the generating parameter/ability/roster/exposure contract;
coordinate-transformed statistics agree within 1.333e-15 and separate
paired-event arithmetic within 6.662e-16. Among returned calculations, maximum
nuisance residual is 9.944e-11, root spread 4.490e-9 and derivative-step error
1.238e-8; minimum nuisance singular value is .001247. All Persons are retained,
including 0–13 extreme profiles. These verify numerical calculations, not
finite-sample statistical validity. Results and replay/independent verification
are in `validation-results/jml-score-plugin-20261013/`.

**Decision at completion of the substitution unit.** Its population-centering
and component follow-up is now complete in the preceding section, which gives
the current decision. This sensitivity unit closes its D1.3/D1.4 comparison;
general corrected-JML inference and aggregate D1 remain open. Do not increase
B on these eight generators to seek significance or immediately mix in
ability-law error. The matching condition used in the follow-up is as follows.

For a fixed null and generating structural vector gamma, let lambda-bar(gamma)
solve the roster-weighted population nuisance equation. Let b(gamma) be the
mean projected score at that constrained root and s(gamma)^2 the matching
within-roster projected variance per Person. Under local smoothness, stable
roots and positive variance, the statistic has leading drift
`sqrt(N) * b(gamma)/s(gamma)`. The fitted null generator converges, if that
root limit holds, to `gamma-dagger=(psi0,lambda-bar(gamma0))`. Re-solving the
complete equation in bootstrap draws reproduces the population calculation
under gamma-dagger, not automatically the one under gamma0. Retain signed
`b/s` for diagnosis. For the declared absolute-T test, matching `abs(b)/s`
is the necessary leading-drift check (opposite signed drifts can have the
same magnitude). This alone does not establish the fluctuation law,
generator-estimation effect or finite-N accuracy; zero drift requires its
own ordinary first-order distribution argument.

Inconsistent nuisance estimation alone is not a proof that the statistic's
bootstrap law fails: a suitably pivotal statistic could still match. Conversely,
small numerical residuals and two agreeing starts do not show this matching.
Keep fixed exposure and exposure growth separate, and retain N20/N60 and the
existing larger-N evidence in scope. A mismatch would call for a change to the
generating/centering argument, not more inner repetitions or arbitrary SE
inflation. A match would justify considering a costed outer calibration design,
not immediate public support. This is a prerequisite check of the current
candidate, not a new adjusted-likelihood or optimizer-development project.

**Question and resource decision.** Does replacing the four generating
structural nuisance values by their null-constrained estimates materially
change the adjusted-score reference distribution, even with the ability law
known? The previous 792 calculations answer the fully specified-law question;
they do not answer this substitution question. The experiment is conditional
on selected retained nuisance vectors, not an outer coverage study of an
estimated-generator procedure.

First check whether probability-ratio reweighting can reuse those calculations
without refitting. Let Q be the true full-sample law, P the proposed plug-in
law and W=P/Q. Enumerate each roster's complete count-pattern support, mixing
the product of cell likelihoods over the known three-point ability law.
Independent Persons give

    E_Q(W^2) = product_g {sum_y P_g(y)^2 / Q_g(y)}^(n_g).

For any fixed statistic event A, the unbiased paired difference estimator is
the average of (W-1)1(A). Its variance is bounded above by
`{E_Q(W^2)-1}/B`. Freeze the sufficient reuse screen at square root <= .025
with B=99, before evaluating all sixteen retained truth-null generators.
No trimming, clipping, self-normalized p-value or favorable nuisance search
is permitted. This is a conditional probability-difference calculation,
not a composite-null importance-sampling test.

**Overlap outcome.** All sixteen generators fail that sufficient screen.
Calculated second moments range from 1.998 to 11,874.1, giving root-MSE bounds
.1004–10.9513; realized weight ESS ranges from 3.03 to 43.22 out of 99.
The upper bounds can be conservative: failure does not prove every weighted
tail estimate inaccurate, and density differences do not prove differences
in the score statistic. Nevertheless this bank does not meet the predeclared
reuse criterion. Do not interpret the saved raw weighted tail differences
as resolved distribution comparisons or start enlarging an importance bank.
Finite-sum calculation cost 2.576 seconds. A fresh replay reproduces the
results without simulation or fitting; 448 independently evaluated
`dmultinom` log masses agree within 5.330e-15. These are double-precision
finite sums, not outward-rounded certificates. The driver and retained
results are `jml-score-plugin-overlap-20261013.R` and its matching directory
under `validation-results/`.

**Direct comparison frozen before generation.** Select the first original
pilot replicate in each design/N/L cell, as already stated in the overlap
contract before its results. This gives eight fixed generators from four
original parent datasets, not the most extreme observed statistics or
nuisance estimates. For each, substitute its
four null-constrained nuisance values and retain psi=.5, the known
roster-specific three-point ability mixture and fixed roster counts. Allocate
99 draws per generator (792 complete constrained calculations). Reuse the
matching saved true-law parent RNG stream: ability draws and rosters coincide,
while each response generator retains its correct marginal law. The eight
groups reuse 396 distinct streams; independence is within each 99-draw cell,
not across all 792 calculations. This coupling does not guarantee variance
reduction. L1/L2 have separately estimated
nuisance vectors, so these arms are not nested samples from one generating law.

Recompute the entire order-2 profile/correction/nuisance-root/statistic procedure
in every draw. Keep the original starts, stages, maxit=400, derivative and
projection checks, full nonsymmetric Jacobian and within-roster variance.
Save inputs before fitting, all attempts and failures, with no replacement.
The primary comparison is the paired change in `P(|T|>qnorm(.975))`, including
all-attempt difference bounds, paired MCSE and an exact discordance test with
Holm adjustment across eight generators. If any statistic is unknown, retain
its binary-event bounds and leave the incomplete paired test unidentified.
Secondary output is the absolute-T .95 quantile and pointwise binomial-rank
uncertainty. Individual-probability MCSE at .05 is .02190; paired worst-case
MCSE is `1/sqrt(99)`. Nonsignificance cannot establish equivalence.

The unchanged baseline phase cost predicts about 478 seconds; different
generators can cost more. No wall-clock cutoff, result-dependent extension,
estimated abilities, new outer trial or endpoint search is allocated. The
source, generator, package, runtime, inputs and analysis are bound by
`jml-score-plugin-20261013.R prepare`. Its `run` preserves completed draws;
`replay` verifies saved arithmetic without loading the fitting package or
generating responses. This unit can resolve a conditional sensitivity/cost
decision, not general bootstrap validity or public interval qualification.

## October 13 — Known-law score calibration: first-stage contract

**Completed outcome and decision.** All 792 predeclared null calculations
returned usable statistics, but the normal-reference rule is anti-conservative
in every N20 cell. All four N20 inflation tests remain significant after the
prespecified Holm correction across eight cells (adjusted p from 7.068e-7
to .008006). Classify the N20 normal-reference candidate as **repair required**;
do not adopt it for structural-truth intervals. N60 is **unresolved**, not
qualified by nonsignificance or point estimates near .05. This completes the
bounded screen's evaluation and disposition, not the overall JML/D1 obligation.
It does not reject bootstrap-calibrated adjusted-score inference, which was
not tested here, or change the separate r*/GMFRM conclusions.

Each row below has 99 independent parents and 99 returned statistics. L1/L2
within a design/N use the same parents, so the total 792 calculations represent
396 independent datasets. MC intervals are pointwise exact-binomial 95%
intervals for rejecting structural truth at the normal cutoff.

| Step/slope owner and assignment | N | L | Reject truth | Rate | 95% MC interval | Empirical .95 quantile of absolute T |
| --- | ---: | ---: | ---: | ---: | --- | ---: |
| Criterion, unequal | 20 | 1 | 13/99 | 13.1% | 7.2–21.4% | 2.726 |
| Criterion, unequal | 20 | 2 | 14/99 | 14.1% | 8.0–22.6% | 2.462 |
| Rater, sparse | 20 | 1 | 20/99 | 20.2% | 12.8–29.5% | 2.889 |
| Rater, sparse | 20 | 2 | 13/99 | 13.1% | 7.2–21.4% | 2.650 |
| Criterion, unequal | 60 | 1 | 6/99 | 6.1% | 2.3–12.7% | 2.261 |
| Criterion, unequal | 60 | 2 | 3/99 | 3.0% | 0.6–8.6% | 1.605 |
| Rater, sparse | 60 | 1 | 3/99 | 3.0% | 0.6–8.6% | 1.828 |
| Rater, sparse | 60 | 2 | 3/99 | 3.0% | 0.6–8.6% | 1.902 |

At N20, the SD of T is 1.256–1.414. The Rater/L1 cell also has mean -.2704
and 16 lower-tail versus 4 upper-tail rejections; the other three means are
between -.0449 and .0423. These observations show distributional discrepancies
and do not identify a unique mechanism or justify a universal t correction.
Correct computation, a small equation residual and first-order score/Wald
equivalence do not establish a finite-Person standard-normal reference.
Residual finite-exposure structural bias remains a distinct issue. The
empirical quantiles are descriptive, with wide saved binomial-rank uncertainty
envelopes; they must not be installed as universal replacement cutoffs.

**Computation and verification.** All 1,584 start paths passed at stage one,
with maximum nuisance residual 9.997e-11, between-start discrepancy 3.672e-10,
derivative-step discrepancy 1.125e-8 and minimum nuisance singular value .07865.
All Persons were kept, including 0–13 extreme profiles per view. There were
no replacements or rescue starts. The observed 99/99 return rate in each
cell still has a pointwise 95% lower confidence bound of .9634; numerical
availability in every possible sample is not proved. Generation plus complete
per-view calculation cost 478.237 seconds; the run phase including package
loading/I/O cost 481.739 seconds, compared with the predicted 497 seconds.
Preparation, code development and the later replay are outside these timings.

A fresh base-R replay reconstructs all 792 statistics, complete counts and
source/input bindings without estimation or new responses. Independent
coordinate-transformation arithmetic agrees within 1.333e-15 and direct
binomial-tail summation within 2.443e-15. A separate exhaustive check covers
2,304 missing-value/rank cases and 64 sharpness cases, including ties, zero
and infinity. The sixteen older development inputs have exploratory known-law
reference p-values .15–.99; their favorable outcomes must not replace the new
99-per-cell screen or be called independent calibrated-method coverage.
Results, all draws/attempts, manifest, replay and independent checks are in
`validation-results/jml-score-calibration-20261013/`.

**Decision at completion of the first stage.** The bounded substitution
comparison above now supplies the subsequent evidence and current next step.
Keep the completed adverse
result; do not increase B to change it or start an endpoint grid. A useful
next calibration comparison must separate (a) the fully true generating law,
(b) null-constrained structural nuisance plug-in with the ability law still
known, and (c) estimation/misspecification of the ability law. Begin by specifying
(b); jumping directly to a shrunken fixed list of abilities would mix those
errors and change the existing independent-new-Person sampling law. An oracle
Monte Carlo test can be calibrated under its completely specified law, but
that fact cannot qualify a composite-null bootstrap using estimated nuisance
values. Neither plugging in nuisance estimates nor completing every refit
supplies the missing validity theorem. Future power/informativeness, interval
delivery and wider design/slope comparisons remain necessary for adoption;
the current screen is not a comparison of interval endpoints or method superiority.

**Why this allocation, after the whole-D1 review.** The preceding 32-null
check addresses numerical feasibility (part of D1.2), not structural-truth
inference. The next unresolved decision is whether the normal reference is
already substantially miscalibrated when the entire generating law is known,
before spending on an estimated ability/nuisance bootstrap. Existing R50
inputs have three owner levels and unit generating slopes; the retained N400
root-Wald study is a different experiment. Neither supplies this constrained
score distribution. Preserve them as complementary evidence, not as draws
from the new reference law. This bounded screen cannot close D1.5 or select
a best interval method by itself; independent user workflows remain unblocked.

**Frozen before generation.** `jml-score-calibration-20261013.R prepare`
binds the generator, installed package, numerical root/statistic functions,
inputs, independent streams and analysis. Reuse the exact functions from the
preceding frozen drivers without executing their command dispatch. The new
streams continue after the eight pilot streams. Allocate 99 independent
parents per design/N (396 parents), each providing nested L1/L2 views (792
null calculations). Keep Criterion-owned unequal and Rater-owned sparse
designs, N20/N60, all positive slopes exp(+/-.25), and each roster's known
three-point ability law. Every trial fixes structural truth psi=.5; the
population-root null is not substituted. All structural nuisance values and
the population distribution are known only to the generator, while the
statistic re-solves its four sample nuisance equations. No fitted nuisance
or fixed-list ability generator is called an oracle reference.

**Precision and cost.** B=99 is an initial gross-miscalibration screen:
MCSE at probability .05 is .02190 (worst case .05025). Without missing
statistics, the pointwise one-sided 5% exact-binomial screen rejects a .05
rate at 10 or more rejections; its power is .9405 at a true .15 rate but only
.5355 at .10. Thus it can detect large problems and cannot establish close
nominal calibration. Report exact pointwise uncertainty and Holm-adjusted
inflation screens across eight cells, without treating the pointwise power
as simultaneous power. Prior complete null costs predict about 497 phase
seconds; difficult new samples may cost more. No wall-clock cutoff or
favorable-result extension is adopted. Shared references avoid a new inner
bank for each of the sixteen development views; unrestricted fits and
endpoint searches are unnecessary for this question.

**Outputs and failures.** Keep the existing two starts, all solver stages,
derivative checks, full nonsymmetric projection and fixed-roster variance.
Save generated inputs before solving, all start attempts, failures and cost.
With k known rejections and f unknown statistics among B attempts, report
[k/B,(k+f)/B] and the outer exact-binomial uncertainty bounds. No successful-
only rejection denominator or replacement draw is allowed. Unknown |T|
values lie in [0,+Inf]; retain sharp empirical order bounds and pointwise
binomial-rank bounds for the population .95 quantile. Inclusive reference
p-value bounds for a finite observed t are

    [(1 + number(|T_b| >= |t|))/(B+1),
     (1 + number(|T_b| >= |t|) + f)/(B+1)].

The same independently generated bank can serve multiple development inputs
with identical complete null laws. Their p-values are exploratory: those
inputs helped develop the procedure. Do not report the reference bank's own
rank acceptance fraction as independent coverage of a calibrated method.
The fully specified-law rank principle is already reviewed with Dufour (2006)
below; it does not supply a feasible composite-null guarantee after substituting
estimated nuisance parameters. Matched ability-generator sensitivity, useful
power/width and interval delivery are subsequent questions, not conclusions
from this screen. Record an adverse or inconclusive outcome before authorizing
another numerical unit; no large nested bootstrap is queued.

## October 13 — Constrained-score feasibility on retained inputs

**Outcome and disposition.** The adjusted-score statistic is numerically
feasible in all 32 predeclared null problems and can differ materially from
unrestricted-root Wald. Keep it as a candidate for calibration; this does not
qualify structural intervals, prove normal reference calibration or establish
better coverage. There are eight independent parents, with two nested exposure
views each, not 32 independent simulated datasets. No responses were generated.

**Question and design.** Can the complete order-2 nuisance equation be solved
at a declared target, and does the resulting statistic do something beyond
re-expressing local Wald? Reuse every N20/N60, L1/L2 view of the Criterion-owned
unequal and Rater-owned sparse pilot designs. The interest parameter is
psi=log(a_1/a_2)=2*beta_5 under the existing centered log-slope constraint.
For each view test both structural truth (psi=.5) and the independently
retained population-equation-root value. Their displacements from truth range
from -.021412 to .015468; they remain separate inferential targets.

`inst/validation/jml-constrained-score-20261013.R` freezes its source, all
retained inputs, installed package/runtime and complete policy before solving.
Use the original neutral/perturbed starts restricted to the four nuisance
coordinates and the original Broyden/Newton stages, maxit=400, residual <=1e-7,
Newton step <=1e-5 and between-start agreement <=1e-6. Recompute ability
profiles and the full correction at each beta. No warm continuation, truth
nuisance start, replacement or additional rescue is used. The full nonsymmetric
mean-equation derivative uses steps 1e-4 and 5e-5 (relative discrepancy <=1e-5);
eligibility requires nuisance-block minimum singular value >1e-6 and positive
within-roster projected variance. Full-A inversion is unnecessary. Keep all
Persons, including the 0–8 extremes per retained view. These extremes are
handled by the existing equation, not turned into a finite bootstrap generator.

**Numerical evidence.** All 64 start paths solve at their first stage; every
pair agrees. The maximum nuisance residual is 7.175e-11, between-start
discrepancy 9.262e-11, derivative-step discrepancy 5.325e-9, and projection
identity residual 4.441e-16. The smallest nuisance singular value is .19412.
Both starts agreeing is evidence of local branch consistency, not a global
uniqueness proof. The retained Schur values are positive (.2361–1.6757), so
the negative-score statistic has the same local sign as
W=(psi_null-psi_hat)/SE. No weak-identification performance claim follows.

At the usual absolute cutoff 1.96, the score accepts each tested target;
Wald rejects both targets in one N20/L1 Criterion-owned view and accepts the
others. That single view has, at structural truth, W=2.059029 and T=.938667.
The population-root comparison is W=2.075650 and T=.949036. The largest
absolute T/Wald difference across the 32 calculations is 1.126613; changing
truth to the population root changes T by at most .052780 in this pilot.
These counts must not be interpreted as coverage estimates or evidence of
superiority. A useful procedure must also discriminate false values and
deliver informative sets; simply increasing acceptance can be uninformative.

The decision-changing view has a useful saved-value decomposition. Its
unrestricted local linear predicted projected sum is 4.104368, compared with
the null sum 3.987928 (ratio .971630). The projected-sum standard deviation
increases from 1.993351 at the unrestricted root to 4.248501 at the null
(inverse ratio .469189). Their product .455878 equals T/W. Thus the main
change comes from evaluating projected variability at the null, not from
eliminating the structural-root displacement. This is an explanation of one
observed case, not a general mechanism established across repeated sampling.

**Cost and verification.** A standalone null calculation including data/problem
setup costs .470–.837 seconds. Charging shared setup once per view, the paired
32-problem total is 19.890 seconds. These timings include root solving, full
derivatives and the statistic; they exclude process/package startup, provenance
hashing and result serialization. No unrestricted fit is repeated. A bootstrap
needs these null calculations for every draw, not merely a cached Wald update;
price it before allocation and avoid endpoint-by-endpoint calibration by default.

Before fitting, nonsymmetric linear controls verify score/Wald equivalence,
the transformed psi scale, a computable statistic with singular full A but
regular nuisance block, and rejection of singular nuisance/zero variance.
Fresh base-R replay loads no estimation package, uses no root solver or new
derivatives, and reproduces each saved statistic using an independent block
expression and cross-product variance. It also checks the uncentered numerator,
nuisance residual, projection identity and factor-two parameter/equation
transformation. All pass. No package source, public help or API changes.

Retain `validation-results/jml-constrained-score-20261013/` (manifest,
32 case files including all attempts, report, CSV and logs). Run `prepare`,
`run`, then `replay` from the package root with the existing four BLAS/OpenMP
thread variables set to 1. A completed run is resumed from its saved cases;
normal-cutoff failure or unavailable statistics are retained, not stopping
criteria that discard subsequent planned cases. Replay alone performs no fits.

**October 13 cross-reference.** The
[independently learned prediction review](gmfrm-mml-em-20260927.md#october-13-learned-predictor-likelihood-sets-applicability-and-next-gate)
follows the October 12 fixed-Q anchor finding below. It derives the
fixed-normal, whole-Person split/crossfit argument and checks retained GMFRM
partition feasibility, without fitting. That route changes the inference law;
it does not qualify arbitrary-population JML or its current RootSE. Safe global
null-likelihood bounds remain a necessary unmet computational dependency, so
the old one-family inversion forest is not resumed or transferred to GMFRM.

## October 13 — Split-panel centering decision before additional fitting

**Question and decision.** Would a design-preserving split correction address
the structural centering gap strongly enough to justify the next small-sample
interval study? It is an implementable, distinct candidate, but the retained
population calculations do not support selecting it as that next repair.
Its effect is mixed across targets and exposure, and the population-root
displacements in these particular two-level designs are already small on the
retained variability scale. Do not start half-panel refits or coverage runs
solely because the formula can now be applied. This decision does not reject
split-panel methods in general, assert adequate current coverage, or close D1.

### Applicable formula and what it can remove

Dhaene and Jochmans (2015), *Split-panel Jackknife Estimation of Fixed-effect
Models*, [DOI](https://doi.org/10.1093/restud/rdv007), was reread in Zotero
`BCNJKY74` / attachment `NCPNCNAA`, PDF pages 9, 10, 28 and 29 (printed
999, 1000, 1018 and 1019), separately. Page 9 was also rendered to check the
formula. The published version uses equations (3.4)--(3.5) and Section 6;
the author-hosted manuscript has different section numbering. The ordinary
half-panel weights remove a first-order exposure bias under a common
expansion; the paper explicitly warns that remaining higher-order terms can
increase. Its theorem is not a theorem for mfrmr's corrected equation.
The local API probe was sandbox-blocked; the known library attachment was
read directly, without modifying Zotero.

For the restricted repeated-block family of the existing growth argument,
write the order-2 population root in native free coordinates as

    beta*_L = beta_0 + C/L^3 + O(L^-4).

This remains a local-root, fixed-dimension, independent-block argument with
the previously stated information, ability-tail and derivative assumptions.
Suppose a response-independent split yields two equally exposed halves with
the same Persons, roster proportions, parameter constraints and population
law. At full exposure L, use

    beta_hat_SP = [8 beta_hat_L - (beta_hat_A + beta_hat_B)/2]/7,
    beta*_SP   = [8 beta*_L - beta*_(L/2)]/7.

The weights sum to one and cancel C/L^3. Locations and centered steps retain
their constraints; combine **log** slopes before exponentiating. This is a
different estimator, not a covariance correction or a result still solving
the original adjusted equation. For the more explicit expansion
`beta*_L = beta_0 + C/L^3 + D/L^4 + o(L^-4)`, its remaining term is
`-8 D/(7 L^4) + o(L^-4)`. Thus, if a target has C=0, even this correctly
chosen correction increases its leading absolute bias by 8/7. The ordinary
`2*full-half_mean` weights instead multiply C by -6; they are not appropriate
to this order-2 expansion. The choice r=3 was fixed before the new comparison,
not estimated from the observed bias ratios or selected for coverage.

If only `|R_L| <= M/L^4` is known coordinatewise, the new remainder is bounded
by `24 M/(7 L^4)`. There is no uniform finite-L improvement without further
information about C and the remainder. Given the existing matching CLT and
local-branch conditions, bias order O(L^-4) would relax the sufficient
truth-centering restriction from N/L^5 -> 0 to N/L^7 -> 0. This algebraic
consequence does not establish a practical rating-count threshold, remove
fixed-exposure bias, or prove small-N interval calibration.

### Keep the three estimators' dependence

Let psi_F, psi_A and psi_B be aligned Person influences for the full and two
half estimates, each using its own full nonsymmetric equation derivative and
the declared roster centering. The composite influence is

    psi_SP = [8 psi_F - (psi_A + psi_B)/2]/7.

Use `crossprod(psi_SP)/N^2` with the same specified finite-roster convention;
do not add independent variances. If V_j denotes a sampling covariance and
C_jk the cross-covariance of estimates j,k, the matching expression is

    V_SP = [64 V_F + (V_A + V_B + C_AB + C_AB')/4
              - 4(C_FA + C_FB + C_FA' + C_FB')]/49.

Halves sharing a Person can be dependent after mixing over ability, even
when their ratings are conditionally independent. Each conditional influence
mean need not vanish for a finite-exposure adjusted root. Reusing the full
estimate's SE, omitting cross terms, or calling a sum of the three marginal
covariances the new uncertainty is therefore not justified.

With equal marginal half SE s_H and full SE s_F, Cauchy gives only

    max(0, 8*s_F-s_H)/7 <= s_SP <= (8*s_F+s_H)/7.

These are bounds for a matching asymptotic variance, not confidence limits.
The saved marginal covariances alone cannot determine the actual split SE.
The algebra was checked with aligned, roster-centered deterministic Person
influences both by a stacked joint covariance transformation and by the
explicit cross-term formula; errors were 3.04e-18 and 2.61e-18. This checks
the identity, not statistical performance or a fitted split procedure.

### Saved results and the practical size of the proposed repair

The [saved-only driver](jml-split-centering-20261013.R) froze the coefficient,
all four owner/design settings, full L=2/4/8 versus half L=1/2/4, and all five
free structural coordinates before computing their combinations. It reuses
the 16 reviewed order-2 population roots and their original source bindings;
all 32 root files from the completed historical stage also match its retained
result hashes. No responses, sample fits, roots, derivatives or integration
are recomputed. A synthetic L^-3/L^-4 control agrees within 1.11e-16; a
separate matrix-map calculation of all 60 coordinate combinations agrees
within 1.11e-16.

The following values are **log-slope population-root displacement**, not
finite-N estimator bias. These are the shortest full/half exposure pair L=2/1;
the other four coordinates and larger exposures are retained in `review.rds`.

| Slope/step owner | Allocation | Original full-root displacement | Split-root displacement | Absolute displacement |
| --- | --- | ---: | ---: | --- |
| Criterion | Sparse | -.002635 | -.002432 | Decreases |
| Criterion | Unequal | -.003117 | -.004667 | Increases |
| Rater | Sparse | -.004988 | -.004172 | Decreases |
| Rater | Unequal | -.002159 | -.003324 | Increases |

At L=2, absolute displacement decreases in 3/5, 1/5, 5/5 and 2/5 coordinates
in those respective rows. These dependent coordinate counts are descriptive,
not replications or tests. At L=4, the largest absolute displacement decreases
in all four designs; at L=8 it increases in both sparse designs and decreases
in both unequal designs. The smallest absolute change across all comparisons
is 7.33e-7, versus maximal retained start spread 1.39e-10. Start agreement is
not a certified bound on root error or global uniqueness.

Magnitude matters: at L=2 the largest absolute displacement divided by the
**original full-estimator** asymptotic SE at reference N400 changes from
.09745 to .11044 across these conditions/coordinates. Scaling that retained
SE as sqrt(400/N), the largest split-root ratio is .02469 at N20 and .04277
at N60. These are asymptotic reference comparisons, not estimates of actual
small-N SE, split SE, finite-N bias or coverage. They do not explain the
separate three-level, four-category R50 study: that study has a different
design and generating law. Its finite-Person/studentization problems remain
distinct from this centering calculation.

### Feasibility, verification and disposition

All eight parents from the October 13 small pilot have an exact eligible
L2 split: the saved L1 counts are half A, and L2 minus L1 is half B. Every
Person/cell has the same nonnegative integer exposure in both halves, with
the original Persons, facet levels and roster proportions. Thus the earlier
L1 roster obstruction does not prohibit applying this candidate to **L2**.
This input audit does not establish half-fit existence. No half-B fit was
run and no favorable design was selected for a new performance study.

An initial reader check incorrectly required the later stage.R hash on the
original L1 pilot result, which predates staging. It stopped before producing
a comparison. The repaired reader checks that stage hash when present and
always checks the historical result hashes and original source bindings;
the initial source/manifest are retained. The protocol and coefficient did
not change. Fresh saved-only replay is exact without loading mfrmr or
initializing an RNG. Results are in
`validation-results/jml-split-centering-20261013/`; the independent covariance,
input-split and matrix-map checks are in `tmp/jml-split-centering-20261013/`.

**Do not allocate further split fitting now.** A new study of this candidate
would need a decision-relevant bias reduction as well as matching finite-N
uncertainty. The present evidence provides neither a uniformly helpful
finite-exposure correction nor a large centering problem in these pilot
designs; it does provide a reason not to repeat optimizer/covariance tuning
under the name of bias correction. Retain the candidate for a justified
target/design where its benefit could change a decision, with all failures
and covariance cross terms included. Current corrected-JML RootSE and public
interval scope are unchanged. General structural-truth inference, GMFRM
nuisance calibration, and small/medium/large-design obligations remain open.

## October 13 — Fixed-roster deletion: mathematical and computational decision

**Decision.** Do not directly import a GEE correction, use N−p as a universal
t degrees of freedom, or replace nonlinear deletion fits by the one-step
approximation evaluated here. The bounded comparison is complete. It supports
the current full nonsymmetric root-covariance calculation and identifies a
real limit to a cheap alternative; it does not qualify a new truth interval.
Do not automatically follow this negative result with another approximation,
more Newton steps or a large jackknife coverage study.

### Primary source and the applicability check

Fay & Graubard (2001), *Small-Sample Adjustments for Wald-Type Tests Using
Sandwich Estimators*, Biometrics 57, 1198–1206,
[DOI](https://doi.org/10.1111/j.0006-341X.2001.01198.x), was obtained from the
author's [saws source distribution](https://michaelfay-niaid.r-universe.dev/saws)
(0.9-7.0), without installing it. The included author manuscript is dated
August 13, 2001, with a 2007 contact/formatting update. All 21 PDF pages were
read individually; pp. 5–6 were also rendered to verify the matrix notation.
The PDF is bound in the deletion manifest. No matching Fay–Graubard item was
found in the Zotero title/creator search; the library was not modified.

The paper separates variance correction and a contrast-specific approximate
reference distribution (pp. 5–7). Its derivation uses a working covariance
relationship; the appendix also uses centered scores, normal/quadratic-form
approximations and approximate independence (pp. 15–17). Exactness is proved
for an identical-design Gaussian special case. Unbalanced simulations show
overcorrection, and N−p degrees of freedom can remain badly liberal (pp. 10,
12–13, Tables 3–4). This is relevant precedent, not a general finite-sample
guarantee for corrected JML.

The applicability conclusion is our own. The author implementation's
`sawsCalc`/`dfCalc` uses a symmetric model-based inverse on both sides of the
meat. Corrected JML requires A^-1 B A^-T. Its fixed-roster covariance also
centers scores within assignment groups; these empirical residuals cannot
simply be substituted as independent estimating equations with their original
derivatives. Indeed, their within-group sum is identically zero as a function
of beta. A valid extension remains possible, but requires its own derivation;
the existing implementation is not a drop-in adapter. The new numerical review
finds relative Jacobian asymmetry .0111–.1354 across sixteen saved fits,
against derivative-step discrepancies below 2.1e-8, so it is not rounding noise.

### A deletion rule that preserves the stated population mixture

Write the estimating equation as

    F(beta) = sum_g pi_g * Ubar_g(beta),    pi_g = n_g/N,

where U_i is the complete order-2 Person contribution. The original pi_g
is held fixed. Deleting Person i from roster g reweights its remaining n_g−1
Persons; it does not change the population mixture. For n_g>1,

    F_-gi(beta) = F(beta) - k_g * (U_i(beta) - Ubar_g(beta)),
    k_g = pi_g/(n_g-1).

At the original fitted root, let D_i = dU_i/dbeta and A=dF/dbeta. Then

    A_-gi = A - k_g * (D_i - Dbar_g),
    delta_1,gi = -solve(A_-gi, F_-gi(beta_hat)).

These are exact identities for the deletion equation/Jacobian, followed by
one local Newton approximation to its root. No symmetry or working-information
identity is assumed. They require an invertible deletion Jacobian; they do not
establish existence or global uniqueness of a nonlinear root. Constant
nonsingular changes of equation basis and linear parameter coordinates leave
the mapped-back one-step displacement unchanged. The numerical checks retain
both transformations, full derivatives at two step sizes, and a nonsymmetric
affine-equation control whose exact deletion roots are available algebraically.

For deletion displacements delta_gi, the stratified jackknife covariance is

    V_JK = sum_g (n_g-1)/n_g *
             sum_i_in_g (delta_gi - delta_bar_g)(delta_gi - delta_bar_g)'.

Freezing A_-gi at A makes this covariance **exactly equal** to the already
retained finite-roster sandwich,

    A^-1 [sum_g n_g/(n_g-1) * sum_i_in_g e_i e_i'] A^-T / N^2,
    e_i = U_i - Ubar_g.

The common term due to a small original equation residual cancels in the
within-roster centering. Thus a fixed-Jacobian deletion calculation is not
an additional small-sample remedy. Updating A_-gi includes extra local
nonlinearity, whose accuracy needs checking. Deleting independent Persons for
covariance estimation is also different from the within-Person split-panel
bias correction reviewed below: it leaves per-Person exposure unchanged and
does not remove incidental-parameter bias.

### Completed bounded comparison

The [deletion driver](jml-delete-person-20261013.R) froze its protocol and
source before numerical evaluation. It reuses the sixteen preceding pilot fits
and their isolated installed package. All sixteen receive derivative and
one-step reviews (N20/N60, two owners/designs, L1/L2, two parent replicates).
Only the first N20 parent per design receives all twenty nonlinear deletions
at each L: four datasets, eighty deletion fits. Each fit uses the original
two starts, solver stages, maxit 400 and root acceptance criteria, with no
rescue or unrelated covariance computation. All eighty returned consistent
local roots. They are not eighty independent simulation replications.

The prespecified numerical-surrogate criteria were: all deletion roots return,
the maximum coordinate approximation error is at most .05 original SE, and
every coordinate's jackknife SE differs by at most 5%. These are engineering
tolerances, not coverage criteria. They were not relaxed after seeing results.

| Owner/design | L | Qualified deletions | Maximum error / original SE | Maximum relative jackknife-SE error | Surrogate criteria met |
| --- | --- | --- | --- | --- | --- |
| Criterion / unequal exposure | 1 | 20/20 | .19868 | 16.14% | No |
| Criterion / unequal exposure | 2 | 20/20 | .08735 | 8.83% | No |
| Rater / sparse allocation | 1 | 20/20 | .15394 | 5.73% | No |
| Rater / sparse allocation | 2 | 20/20 | .08219 | 3.24% | No |

For these four matched datasets, derivative/one-step calculations total 1.095
seconds versus 43.991 seconds for nonlinear deletion solving and root checks.
Across all sixteen, derivative/one-step review totals 3.435 seconds. These
measured phases exclude source preparation, input reconstruction, startup and
result-file I/O; they are not full study-cost estimates. The speed advantage
does not compensate for the failed approximation criteria. Full-deletion SEs
range from 1.014 to 1.268 times the finite-roster-sandwich SE across these
twenty dataset/coordinate combinations. Widening is not evidence of improved
coverage, and four datasets cannot establish a population performance ranking.
Failure as an accurate surrogate for the nonlinear jackknife does not prove
that the one-step covariance is intrinsically worse as a statistical estimator;
that distinct claim would require an independently specified evaluation.

The frozen-Jacobian covariance identity, direct reweighting identities and
coordinate/equation transformations agree to about 1e-15; the affine control
discrepancy is 1.1e-16. Fresh saved-only replay reproduces `review.rds` exactly,
without loading mfrmr, invoking a solver or initializing an RNG. Results and
all eighty attempt records are in
`validation-results/jml-delete-person-20261013/`. Replay from the package root:

```sh
env OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1 VECLIB_MAXIMUM_THREADS=1 /usr/local/bin/Rscript --vanilla inst/validation/jml-delete-person-20261013.R replay
```

### Consequence for the next inference decision

The unchanged method remains an experimental estimator with root-target
uncertainty; this review does not justify general fixed-exposure structural-
truth intervals. Even a correctly calibrated root covariance cannot remove
beta_star(L,pi)−beta_true. Where this displacement is nonzero and intervals
shrink around the root as N grows at fixed exposure, a covariance/t adjustment
alone cannot supply general truth coverage. This is not a claim that the
observed R50 deviations prove undercoverage, nor that all studied finite
designs necessarily perform poorly.

Any further method allocation must state separately how it handles that target
displacement and finite-Person calibration. Full deletion remains an unqualified
root-covariance comparator with measured cost; the one-step shortcut is not
admitted as its substitute. Do not turn this into an open-ended optimizer or
SE-tuning branch. Reuse existing centering/exposure and conditional-reference
results, and preserve the MML/ordinary-JML comparisons and larger-N evidence
when choosing a decision-changing candidate. No outer coverage study is
allocated by this calculation, and other supported 0.2.4 workflows remain
independent of it. Structural-truth JML inference and D1 remain open.

## October 13 — Literature, studentization and a bounded independent pilot

**Decision and research question.** The general distinction between bias
reduction, uncertainty about an estimating-equation root and truth coverage
is already in the literature. Do not claim it as a new discovery. A narrower
research question remains worth assessing: under specified multifacet GPCM
designs, how do independent Person count, ratings per Person and assignment
affect structural-interval delivery, centering and calibration? No claim of
novelty, universal optimality or publication readiness follows from the
targeted search. This exploratory paper opportunity does not replace the
package roadmap or make a paper a prerequisite for other 0.2.4 workflows.

### Primary-source reading and its limits

The following Zotero PDFs were read page by page in the listed ranges;
these are targeted readings, not claims to have read every paper in full.
Page numbers below refer to the PDF unless printed pages are specified.

| Source and version | Pages read | Consequence for this study |
| --- | --- | --- |
| Dhaene & Jochmans, *Profile-score adjustments for incidental-parameter problems*, local September 12, 2017 manuscript (Zotero `IK3Z5JEY`, attachment `998WJCQJ`) | 1–5; p. 5 also visually checked | The large-exposure argument is explicitly informal on p. 4; fixed-exposure bias can remain. The asymptotic center on p. 5 is the population root, equal to truth only under consistency. Sandwich SE does not itself resolve that distinction. |
| Dhaene & Weidner (2023), *Approximate functional differencing* (Zotero `43I5UXS2`, attachment `9J58ETYC`) | 1–3, 19–20, 26–27; Table 6 visually checked | Section 7 separates population bias/variance from finite-sample simulation. Section 8.1/Table 6 explicitly treats the MLE plug-in alternative, including nonmonotone bias and imperfect coverage; the paper's main posterior-predictive operator is not the same operator as the present JML implementation. |
| Morris, White & Crowther (2019), *Using simulation studies to evaluate statistical methods* (Zotero `PKQMUBH7`, attachment `RKPTAYIP`) | 1, 3, 14–16 (printed 2074, 2076, 2087–2089) | Use ADEMP, independent random streams, small procedure checks and Monte Carlo precision planning. Bias-eliminated coverage is a diagnostic, not an implementable correction. Conditioning coverage on estimated-SE groups can itself mislead. |
| DeMars, Shapovalov & Hathcoat, *Many-facet Rasch designs: How should raters be assigned to examinees?*, local 2023 NCME manuscript (Zotero `L9CTTW8C`, attachment `L9Y5VK7V`) | 1–11 | MFRM assignment and model-versus-empirical SE comparisons already exist. Its 200-replication design holds abilities/severities fixed and randomizes assignments; it is a different sampling law. The 2023 abstract and main text differ on the fixed-pair comparison, so no directional conclusion is adopted here. |

Primary sources: [Dhaene–Jochmans manuscript](https://jochmans.github.io/preprints/score%20adjustments/Dhaene-Jochmans%20adjscore.pdf),
[Dhaene–Weidner article](https://doi.org/10.1007/s13209-023-00283-1),
[Morris et al. author manuscript](https://discovery.ucl.ac.uk/10066118/1/2019%20-%20Morris%20-%20simulation%20studies%20tutorial%20-%20stat%20med.pdf),
and [DeMars et al. conference record](https://commons.lib.jmu.edu/gradpsych/63/).
The earlier review below cites a February 2024 Dhaene–Jochmans version;
the local 2017 PDF is not silently substituted for that later version.
The publisher confirms a [2025 DeMars et al. article, 26(1/2), 67–86](https://jamntnu.net/issues_vol26-1_abstracts.html),
but its full text has not been read. Resolving version differences and extending
the targeted Zotero/web search are necessary before any novelty claim.
The Mancl–DeRouen (2001) small-cluster GEE correction is a related lead, but
its full text was not retrieved in this pass and no correction is adopted
from its abstract. A GEE adjustment requires a derivation for this corrected
equation and fixed-roster sampling law; it is not an automatic JML remedy.

### Saved evidence: centering alone does not explain the observed misses

The [studentization reader](jml-studentization-review-20261013.R) reuses the
800 saved JML inference records and the separate N400 experiment. It retains
all targets, four JML arms, both covariance normalizations and failed returns.
Within-roster centered Person scores and the full, possibly nonsymmetric
Jacobian reconstruct the saved sandwich exactly (maximum absolute discrepancy
zero). Fresh saved-only replay is exact, without generation, fitting or loading
mfrmr. Results are in
`validation-results/jml-studentization-review-20261013/review.rds`.

For the unchanged order-2 Criterion 1−2 contrast, the following diagnostic
counts use only returned intervals. The parent study planned 50 per cell.

| Persons | Exposure multiplier | Returned | Original truth inclusion | After removing empirical mean error | Using a fixed empirical-SD width | SD of studentized error |
| --- | --- | --- | --- | --- | --- | --- |
| 20 | 1 | 38 | 35 | 34 | 36 | 1.185 |
| 20 | 2 | 48 | 43 | 43 | 46 | 1.285 |
| 60 | 1 | 50 | 48 | 49 | 46 | 1.016 |
| 60 | 2 | 50 | 45 | 45 | 47 | 1.158 |

Recentring uses the mean error from these same returned replications;
fixed width uses their empirical SD and the unchanged 1.96 critical value.
Neither supplies a usable interval, independent validation, a binomial
Monte Carlo confidence interval for the transformed metric, or a causal
decomposition. The changing N20 return subsets remain explicit. In particular,
both L2 counts are unchanged by recentering alone; random fitted variance,
tails and their dependence on the point estimate still need consideration.
Estimated variance is more variable at N20, while Person influence
concentration is similar across L1/L2 at a fixed N. That concentration is
neither an estimated number of degrees of freedom nor a leverage correction.
No SE multiplier is fitted to these results.

The retained N400 unequal-slope experiment has independent population roots
and covariance references. Across its 20 design/order/coordinate summaries
(200 replications each), original truth inclusion is 93–98%; substituting the
population root changes at most two inclusions per summary. Fixing interval
width at the population SE does not uniformly improve inclusion. These larger-N
results are retained as complementary evidence, not pooled with the R50
all-unit-slope design or treated as qualification of N20 intervals.

### ADEMP and bounded pilot, fixed before responses were generated

The [pilot driver](jml-small-pilot-20261013.R) freezes the following unit in
`validation-results/jml-small-pilot-20261013/manifest.rds` before generation:

- **Aim:** verify the generating law/reference alignment, complete estimation
  procedure and cost at small N. This is not a coverage or superiority study.
- **Data-generating mechanisms:** two raters, two criteria, three categories;
  the retained Criterion-owned unequal-exposure and Rater-owned sparse designs.
  Both thresholds and slopes belong to the named owner. All slopes are positive,
  exp(±.25), with geometric mean one. Independent Persons have the declared
  three-point ability mixture within fixed roster counts. N is 20 or 60;
  L=2 adds independent rating events to each L=1 parent, retaining its Persons,
  abilities and assignment. It does not duplicate observed scores.
- **Estimands:** the five constrained structural coordinates and their true
  values; separately, the independently computed order-2 population roots
  for exactly these laws. Population covariance is scaled from N400 by 400/N
  as a local asymptotic reference, not asserted to be the finite-N variance.
- **Method:** existing public order-2 corrected GPCM JML, maxit 400, unchanged
  default starts and fixed-roster covariance. Research intervals require
  consistent roots, available covariance and finite parameter-specific bounds.
  No rescue starts, fitted SE adjustment or correction-order selection.
- **Allocation and measures:** eight independent parent datasets, two exposure
  views each, sixteen attempts total. Save input/RNG state before fitting;
  preserve errors, warnings, return status, estimates, SE and elapsed cost.
  Two parents per N/design cannot estimate coverage or rank methods. They are
  development data excluded from subsequent independent confirmation.

Eight L'Ecuyer-CMRG streams use the fixed seed family 20261013. The adjacent-
category recurrence independently checks generating probabilities. Existing
population truths/owners/orders/exposure and input hashes are checked before
generation. The isolated checked installed package is reused: all JML code
matches the live tree; the sole later R-source change batches unrelated GMFRM
reference integrals. That specific difference is recorded, and the changed
routine is forbidden during this JML pilot. Helper code, installed files,
runtime/dependencies and single-thread settings are frozen. An initial source
identity rejection and a preparation assertion error occurred before any
generation; both were resolved before freezing the manifest.
Native source, DESCRIPTION and NAMESPACE also match the checked archive;
the comparison is retained in `native-source-review.log` in the pilot directory.

**Completed pilot.** All sixteen attempts returned points with
`consistent_roots`, covariance and finite research intervals; none was replaced
or rescued. Fitting took .616–1.205 seconds per attempt, 13.288 seconds summed.
Long-format construction and the public-output checks bring the recorded job
sum to 15.711 seconds; this excludes process startup, preparation, generation
and result-file I/O, so it is not a complete project-time benchmark. The timing
supports feasibility only for these two-level designs. Fresh replay reproduced
`completion.rds` exactly without loading mfrmr or initializing an RNG.

All attempts retained one repeated-cell warning. The reused public helper
uses the default `repeated_ratings="review"`; source inspection shows the
rows are retained and the warning does not change estimation. Conditional
independence is established by the declared generator, not by suppressing a
warning. A future frozen protocol should explicitly pass
`repeated_ratings="independent"` for this generating law. Do not rerun these
successful fits merely to change that declaration. No coverage proportion is
reported from two parents per N/design, and successful delivery in this pilot
does not overturn the failures in the existing R50 study.

Saved-only replay from the package root is:

```sh
/usr/local/bin/Rscript --vanilla inst/validation/jml-studentization-review-20261013.R replay
env OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1 VECLIB_MAXIMUM_THREADS=1 /usr/local/bin/Rscript --vanilla inst/validation/jml-small-pilot-20261013.R replay
```

### What can follow, and what cannot follow automatically

A new interval rule first needs a target-specific mathematical argument:
how it addresses centering, estimated covariance and tail approximation under
the declared independent sampling units. Existing N400 and all-unit-slope
evidence, ordinary/order-4 JML and MML comparisons remain in scope. Future
phased comparisons should preserve small/larger N, ownership, allocation and
equal/mild/strong positive slope heterogeneity; this is a design constraint,
not allocation of a new full-factorial experiment.

Before confirmation, freeze the whole candidate, primary contrasts, data law,
failure handling and requested Monte Carlo precision. Report truth inclusion
conditional on return, return rate and delivered inclusion separately, together
with width, point bias/RMSE, root inclusion where a compatible reference exists,
failure types and computational cost. Planned independent replications, not
multiple coordinates or exposure views, determine precision. For illustration,
MCSE .01 requires about 475 replications if coverage is .95, 900 at .90, and
2,500 for the worst-case .50; MCSE .005 at .95 requires 1,900. These are planning
calculations, not allocated runs or precision guarantees under an unknown
coverage rate. Paired method/exposure differences need their own paired MCSE.
Do not repeatedly extend a study until a favorable result appears. Price the
complete procedure in each relevant design; a two-level pilot cannot price
higher-level enumeration. No L16 extension, N480 rerun, restart of the paused
3,000-fit study, nested bootstrap or large confirmation is launched here.
Structural-truth JML intervals and D1 remain open.

## October 12 — Exposure evidence reconciled before another JML allocation

**Decision.** The observed-data equation/covariance bridge and the N20/N60
paired exposure comparisons already exist. Do not repeat that bridge, extend
the population calculation to L=16, or resume the paused 3,000-fit study merely
because structural intervals remain open. The immediate inference dependency
includes finite-Person covariance and the studentized sampling distribution,
in addition to structural centering. More independent ratings per Person can
improve point estimation without qualifying a nominal confidence interval.

The original-source directory alone contains only 81/79 complete output files
for the N20/N60 L2 conditions. Those are **not** the completion counts. Both
conditions have 400/400 output jobs and 200/200 research-inference records in
their source-routed summaries under
`mfrm-wide-map-pcm-r50-portable-20261003/transition-reuse-l2-20261007/`.
The historical "running" handoff text is superseded by this saved-state check;
no claim about current operating-system processes is needed. The previously
qualified one-function source change and original results remain intact.

The [saved-only review](jml-exposure-evidence-20261012.R) checks all four
N20/N60 by L1/L2 complete conditions, 1,600 original output bindings and 800
JML research records, with 4,115 input/result/script file hashes in total.
It independently reconstructs every saved JML target and both asymptotic and
finite-roster summaries. The 100 paired parent bundles match exactly: L1 uses
the first event of L2, with the same Persons, abilities, assignment and truth.
L1/L2 have 6/12 conditionally independent ratings per Person. These are 100
independent parent datasets, not 800 independent replications. Saved-only
fresh-process replay reproduces the result exactly, without loading mfrmr,
fitting, generating responses or evaluating an equation/Jacobian.
Results are in `validation-results/jml-exposure-evidence-20261012/review.rds`.

### What the matched results establish

The following is the unchanged order-2 research interval for Criterion 1 minus
2 (truth -.5), with asymptotic fixed-roster Person covariance. Errors and SDs
in this table use the **interval-returned subset**; all-point summaries and
joint-return paired comparisons remain separately recorded.

| Persons | Ratings per Person | Returned / planned | Covered / returned | Covered / planned | Mean error among returns | Root-mean squared SE / empirical SD |
| --- | --- | --- | --- | --- | --- | --- |
| 20 | 6 | 38/50 | 35/38 | 35/50 | -.18867 | .84177 |
| 20 | 12 | 48/50 | 43/48 | 43/50 | -.01596 | .87715 |
| 60 | 6 | 50/50 | 48/50 | 48/50 | +.05955 | 1.02793 |
| 60 | 12 | 50/50 | 45/50 | 45/50 | +.04650 | .88223 |

At N20, higher exposure improves interval delivery and delivered inclusion;
its returned-subset inclusion is nevertheless 89.58%, with exact 95% Monte
Carlo interval [77.34%, 96.53%]. The L1 and L2 return subsets differ. Among the
42 common finite point returns, the paired squared-error difference L2 minus
L1 is -.10978 (MCSE .06966); this conditional comparison is not the MSE of an
estimator defined on every planned dataset.

At N60 all order-2 points and intervals return. Paired squared error decreases
by .012679 (MCSE .004816), while delivered inclusion changes by -.06 (paired
MCSE .04435). The 45/50 inclusion has exact 95% Monte Carlo interval
[78.19%, 96.67%]. Thus these results neither qualify 95% coverage nor establish
that increasing exposure worsens population coverage. The shorter intervals
coexist with residual mean error and a reported-to-empirical SD ratio below
one; R50 does not identify a unique causal explanation or a correction factor.
The finite-roster divisor adjustment widens these four order-2 intervals but
changes none of their covered counts. Order 4 gives 37/40 and 43/48 at N20,
and the same 48/50 and 45/50 at N60; no automatic higher-order rule follows.
Ordinary PCM/GPCM, all other structural coordinates, and both normalizations
remain in the reconciled result, including adverse outcomes.

### Mathematical scope and next method decision

The population exposure calculations used two-level facets, three categories,
unequal slopes and a declared finite ability mixture. These empirical paired
comparisons use three-level facets, four categories and N(0,1) abilities with
all true slopes equal to one. They address complementary questions; they are
not one common simulation or a coverage validation for the earlier population
roots. The N400 unequal-slope evidence and completed N240/N480 comparisons
remain part of the program, not replaced by these small-N results.

The full sandwich estimates local variation about the estimating-equation
root. The growing-exposure root expansion addresses centering under its stated
regime; it does not establish finite-sample covariance calibration, normal
tails, a stable root on every dataset or unbiased fitted sandwich estimates.
Doubling ratings leaves the number of independent Person contributions at
20 or 60. A divisor adjustment alone does not address all these dependencies.

The next bounded JML method unit should use the retained Person contributions,
full Jacobians and studentized errors to distinguish covariance estimation,
tail approximation and residual centering **before** selecting a small-sample
method. A method change needs a mathematical argument for that target and
sampling law, not a multiplier chosen to make these 50 intervals cover.
Any subsequent independent evaluation must freeze the whole rule, include
failures, preserve the existing model/design/N scope, and price the complete
calculation. The known-normal nuisance-region construction remains a separate
unfinished candidate, not an automatic next computation. Public structural
JML intervals and D1 are still unqualified; no new API, response sample or fit
is introduced by this reconciliation.

**Current scope, updated October 3:** the
[shared MML/JML roadmap](internal-roadmap-0.2.4.md#mml-and-jml-validation-plan)
governs further work. It includes ordinary and corrected JML across small and
larger samples, N versus per-Person exposure, facet count/levels, allocation
and output-specific inference. The N=400 studies remain substantive evidence.
The additional study remains paused at 113/3,000 fit records. The prior design
review held new fitting, generation and timing, with no automatic resumption.
The user subsequently requested small new numerical checks. The
[bounded normal-range pilot](#bounded-numerical-pilot-after-authorization)
below is the resulting exception: four new datasets, paired ordinary/orders-2/4
fits and targeted exact-expectation/derivative checks. It does not resume the
paused study or authorize either large confirmation proposal.
The October 2 deadline has been relaxed. Historical launch/deadline statements
below are superseded, and the separate 400-case MML replay has completed.
No current estimator, covariance rule or public interval scope changed in
this roadmap revision; the dated records retain their original source scope.
The current [JML uncertainty and candidate-evaluation specification](internal-roadmap-0.2.4.md#jml-uncertainty-and-candidate-evaluation-specification)
now fixes the next output decisions: ordinary-JML profile/centering work stays
separate from corrected-JML root inference; orders 2/4 enter the expanded
mapping with an explicitly labelled consistent-root research interval candidate.
Its structural contrasts and paired-order summaries reuse saved full covariance
and Person influences. No automatic order selector or public CI is supplied.
Truth inclusion can be evaluated against generating truth without a new
population-root calculation in every cell; root-target inclusion requires a
compatible retained independent root. The paused N=400 protocol remains intact.
The [expanded allocation](internal-roadmap-0.2.4.md#expanded-allocation-shared-controls-and-scheduling-priorities)
now assigns first-stage R=50 to admitted facet/robustness mapping conditions,
retaining ordinary JML and both correction orders where supported. Only the
proved impossible output receives zero calls; covariance exclusions do not
remove admitted point fits. This descriptive delivery allocation does not
qualify truth coverage or replace the historical N=400 studies. Comparisons
keep their controls and small/large-N scope at each scheduling priority.

The source review also confirms that the internal adjusted-problem order-0
evaluation still inherits owner-total enumeration and its cap. It must not be
used to restrict ordinary JML's supported scope or relabel a profile reference
as the actual public joint optimizer. For corrected fits, public `Converged`
includes unresolved-start local points; candidate intervals instead require
consistent roots. The status and target distinctions are part of the future
study aggregation, not changes to public fitting, scoring or RootSE rules.
The [ordinary-JML residual bridge](#october-1-ordinary-jml-residual-bridge)
below gives an exact conditional identity linking a finite public iterate
to the extended-profile gradient. The October 3 fixed-slope RSM/PCM increment
supplies sufficient finite-root and distance conditions, evaluated on saved
PCM derivatives; the GPCM branch argument remains separate. Numerical
equivalence, sampling covariance and truth centering remain distinct gates.
The [corrected-equation derivative/tail increment](#full-derivatives-and-normal-tail-transfer)
extends the fixed-design normal-tail bound to the full evaluation Jacobian
and covariance moments, and establishes integrability of the proposed leading
bias coefficient. The later
[normal-population growth derivation](#october-3-expanding-range-remainders-and-local-normal-population-inference)
tracks the central remainders and full derivatives for fixed finite independent
blocks and fixed correction orders, and connects their local roots to the
matching sampling covariance. Its local-root selection, numerical-error and
joint-growth requirements are explicit; it does not qualify fixed few-rating
public intervals. The October 1 statements below retain their historical scope.
The [October 2 analytic increment](#october-2-analytic-jml-bridge-and-fixed-exposure-counterexample)
strengthens the ordinary RSM/PCM bridge without a Person-curvature lower bound
and derives an exact two-item counterexample separating optimization, root
covariance and structural bias. Its fixed-slope correction calculation checks
the plug-in operator algebra, not the full public free-slope GPCM estimator.
Only symbolic identities were evaluated; no data, fits or numerical derivatives
were generated. The current mathematical-first roadmap instruction governs
the next action; older numerical launch instructions remain historical.

The subsequent [public/profile numerical bridge](#october-3-public-profile-correspondence-and-comparison-output-connection)
checks five retained ordinary-JML fits, including extremes and changed facet
structure, without structurally refitting them. The corrected research
candidate is now connected to the eight-arm comparison's output accounting.
Neither action establishes removal of incidental-parameter bias or resumes
the separate paused 3,000-fit confirmation study.

The latest [feasible-design and literature audit](#october-3-feasible-inference-baselines-roster-replication-and-literature-scope)
puts the full bias/covariance/interval evaluation on existing basic replicated
assignments before more local-root certificates. It explains the deliberately
sparse pilot's singleton/rank obstruction, checks all 50 running N30 assignments
and replays saved small-N covariances with a distinct normalization sensitivity.
The many-facet growth derivation is an internal argument requiring independent
review, not a published general GPCM theorem. Earlier priority statements
below retain their dates; diagnostics may be evaluated without presuming that
the candidate intervals are valid.

**October 3 work priority:** resolve the structural-truth inference procedure
before further API integration of these numerical diagnostics. Reuse the
existing covariance decompositions and fixed-exposure counterexamples to
decide how bias is handled by an observable procedure, with its matching
uncertainty. The expanding-range remainder/derivative argument remains a
required growth-route task; it does not qualify the practical fixed few-rating
designs. A bias-corrected estimate requires uncertainty for the correction,
and a bias-bounded interval requires a justified bound over its stated domain.
Neither oracle root displacement nor agreement between correction orders
provides such a bound. The running R=50 map supplies descriptive evidence
under unchanged procedures, not a substitute for this inference gate. See the
[current work order](internal-roadmap-0.2.4.md#ordered-work-and-reviewable-exit-conditions).

The [fixed-exposure inference decision](#october-3-fixed-exposure-identification-and-bias-aware-inference)
below now derives a conditional reference for fixed-slope RSM/PCM, an exact
observational-equivalence obstruction for a specified unrestricted-population
GPCM model, and a finite-sample score-envelope confidence-set construction.
The latter requires certified, informative bounds and set inversion; no
public covariance or interval is qualified by this theoretical construction.
The subsequent [conditional intervals and envelope calculation](#october-3-finite-conditional-intervals-and-certified-score-envelopes)
delivers finite reference intervals for the saved PCM's two primary contrasts,
and certified whole-ability mean envelopes for two GPCM location-score
components at one specified parameter point. It does not supply general GPCM
set projection or turn these reference intervals into JML intervals.
The later [free-slope conditional projection](#october-3-free-slope-gpcm-projection-for-a-nonowner-contrast)
does give a finite reference interval for Rater 1-minus-2 over **all** positive
Criterion slopes with geometric mean one on the saved 3 x 3 design. Its
conditional law removes Criterion locations, so it does not resolve their
inference or provide a JML covariance.

## October 1: structural-inference gaps and a normal-tail bound

**Analytic/source review only; no numerical evaluation or new procedure.**
The central-expansion gap stated in this dated section is addressed for a
restricted fixed-block normal-population family in the
[October 3 derivation](#october-3-expanding-range-remainders-and-local-normal-population-inference).
Its fixed-exposure and public-implementation limitations remain in force.
The immediate question is whether the retained compact-ability argument can
justify structural truth intervals in the planned normal-population, low-exposure
comparisons. It cannot yet do so. The argument below resolves a narrower issue:
unbounded true abilities need not make the *profile-score* moments undefined,
even though extreme-response Person estimates are infinite. This is a local
derivation for the declared response model, not a theorem imported from a
different panel model or a qualification of the public solver.

### Separate equation-root variation from structural centering

Let beta_0 be generating structural truth and beta*_{k,L} a regular local root
of the population order-k equation under the stated roster/ability law. For a
fixed contrast c, the exact decomposition is

    c'(beta_hat - beta_0)
      = c'(beta_hat - beta*_{k,L}) + c'(beta*_{k,L} - beta_0).

The implemented Person sandwich addresses the first term. It does not estimate
or remove the second. For fixed exposure, a nonzero second term can persist as
N grows. The retained order-2/order-4 reconciliation has nonzero displacements
in all 20 coordinate/condition/order combinations, and opposite signs of the
paired MSE difference in its two log-slope conditions. These are existing
results, not a new failure calculation or a universal impossibility claim.

As a diagnostic identity under an adequate root-centered normal approximation,
write delta=c'(beta*_{k,L}-beta_0)/s, where s is the actual contrast SD, and let
the reported SE divided by s tend to r. A symmetric interval then has approximate
truth inclusion `Phi(z*r-delta) - Phi(-z*r-delta)`, with z the nominal normal
quantile. Thus covariance scale and centering affect coverage separately;
wide intervals can mask displacement. This is not an observed-data bias
estimate, a proposed SE inflation rule or a new acceptance cutoff. Refusal
gates can change the distribution of the returned subset, so this expression
does not qualify conditional coverage after selection. The exact accounting
identity remains `P(return and cover) = P(return) * P(cover | return)`.

The actual source uses the finite-MLE plug-in transition, as declared in
`R/core-jml-adjustment.R`; it does not average over a posterior for Person
ability. The distinction is material: the primary paper's
[Section 8.1](https://arxiv.org/html/2301.13736v2) explicitly separates
that alternative operator from its posterior-based construction, and the
general high-order rate in Section 4.2 is a conjecture. Neither supplies the
missing general-GPCM inference theorem. The retained fixed-block derivation
must carry its own assumptions and proof obligations.

### A bound that does not require finite Person-estimate moments

Fix a finite roster, unit weights, K categories, conditionally independent
ratings and independently free Person coordinates. Let observed cell counts
be L*e_j, with fixed nonnegative integer
e_j and at least one positive e_j. Structural evaluation parameters stay in a
fixed compact neighborhood with slopes `0 < a_min <= a_j <= a_max` and bounded
location/step offsets and their first derivatives. K, facet dimension, the
roster and correction order k stay fixed. These conditions concern the local
mathematical model; the public numerical gates do not prove them globally.

For one rating in cell j, write

    p_j(y | theta,beta) proportional to exp(a_j*y*theta + h_jy(beta)),
    y=0,...,K-1, with h_j0=0.

Bounded h gives, uniformly in the structural neighborhood, a constant C with

    E(Y_j | theta,beta) <= C*exp(a_min*theta)                 for theta<=0,
    K-1-E(Y_j | theta,beta) <= C*exp(-a_min*theta)             for theta>=0.

The first bound uses the category-0 term in the denominator; the second
uses the category-(K-1) term. Sum with weights L*e_j*a_j. A nonextreme observed
weighted total T lies at least a_min away from both 0 and its maximum M_L.
At its finite profile solution, expected weighted total equals T. Consequently

    abs(theta_hat) <= C0 + C1*log(L),   L>=1,

for constants depending on the fixed model neighborhood and roster. This is
a bound over all nonextreme response patterns, not a truncation of generated
abilities or an instruction to cap fitted Person estimates. The all-low and
all-high patterns retain their exact extended limits; their structural
profile-score contribution is zero under these free-Person/positive-slope
conditions. Anchored or constraint-coupled extremes are not included.

The envelope score for locations/steps is bounded by a constant times L.
Log-slope derivatives additionally contain theta_hat, so the full raw
negative profile score satisfies

    sup_y ||U_0,L(y;beta)|| <= C*L*(1+log(L)).

This follows directly from bounded category residuals and the preceding
profile bound. Let P_beta,L be the plug-in response transition, with absorbing
extreme patterns. It is a stochastic operator, hence a contraction in sup
norm. For fixed k, the implemented equation therefore obeys

    sup_y ||U_k,L(y;beta)||
      = sup_y ||(I-P_beta,L)^k U_0,L(y;beta)||
      <= 2^k*C*L*(1+log(L)).

This loose bound does not rank correction orders or establish a small mean
score. It does show that at each fixed L these score moments are finite under
any proper generating ability law within this conditional response model;
finite moments of theta_hat itself are unnecessary. With the additional local
root, nonsingular derivative, independent-Person and sampling-law conditions,
root-centered M-estimation is a distinct question from truth centering. This
observation does not prove root existence/selection or covariance calibration
at small N. Ordinary RSM/PCM have a_j=1 for the raw-score bound; it does not
introduce a corrected RSM/PCM estimator.
For an algebraic counterexample, one binary rating per free Person gives
only extreme patterns and U_0=U_k=0: the bound holds while the structural
equation has no information. Also, its constants need not remain bounded as
slopes approach zero or dimensions grow. Neither counterexample adds a study
condition; both prevent interpreting this bound as an identification or
practical-adequacy certificate.

For the planned normal laws, choose a mathematical cutoff
`t_L = mu_max + sigma_max*sqrt(2*q*log(L))`, L>=2, with
`abs(mu)<=mu_max`, `sigma<=sigma_max` and fixed q>0. Then
`P(abs(theta)>t_L) <= 2*L^(-q)`. For each fixed moment order r>=1,

    E[ ||U_k,L/L||^r * 1{abs(theta)>t_L} ]
      <= C_{k,r}*(1+log(L))^r * L^(-q).

Thus this *score-moment tail contribution* can be made negligible at any fixed
polynomial rate by choosing q sufficiently large. This is an analytic split
of an expectation, not conditioning the study on bounded abilities, changing
the normal generator or evaluating a new integral. It proves neither the
interior bias expansion nor a uniform derivative bound on that expanding
interval. Normal tails alone do not transfer the compact-ability theorem.

### Full derivatives and normal-tail transfer

**Subsequent October 1 analytic/source increment; no numerical calculation.**
The score bound above can be extended to the *full evaluation-parameter
derivative* and to the covariance's second-moment term. This resolves a tail
integrability issue in the fixed-design model; it does not yet establish the
central-region expansion or qualify the public covariance. The following
bounds concern the exact mathematical finite-MLE plug-in equation. Finite
profile tolerances, floating-point underflow refusals and source-specific
solver/covariance gates still require their own numerical evidence.

Keep the preceding fixed roster, unit weights, independent repeated blocks,
finite K>=2, fixed structural dimension/order and compact structural domain.
For this derivative argument the location/step and log-slope maps have bounded
derivatives of each required fixed order on that domain, as the present affine
and exponential maps do. Ability remains independently free and unanchored.
Write ell_L=1+log(L), W_k,L=U_k,L/L, and Q_beta,L=I-P_beta,L. All operator
formulas act on functions of the **full response pattern**, whether the exact
implementation evaluates them through owner-total compression or directly.

#### Differentiate the transition as well as the raw score

For any fixed structural direction v, the product rule gives exactly

    D_v W_k = Q^k D_v W_0
      - sum_{j=0}^{k-1} Q^j (D_v P) Q^(k-1-j) W_0.               (C1)

The operators need not commute. Dropping the sum treats the plug-in transition
as fixed and differentiates a different equation. In a population evaluation,
the generating beta_0, roster law and ability law F_g stay fixed:

    D_v G_k,L(beta) = sum_g pi_g E_beta0,Fg[D_v W_k,L(Y;beta)].    (C2)

At fixed L this interchange is a finite sum over responses, followed by an
ability mixture of their probabilities. The uniform bounds below also justify
it directly for any proper F_g on this fixed structural domain. Differentiating
`E_beta,F[W_k(Y;beta)]` instead would additionally differentiate the generating
law and would not yield the Jacobian needed for the estimator's covariance.

`mfrm_jml_adjustment_covariance()` in `R/core-jml-adjustment.R` differentiates
`problem$mean_score(b, order)` as a whole. Each evaluation recomputes the
profiles, probabilities, within-total expectations and transition recursion.
It thus targets the complete derivative in (C1), including beta-dependent
weighted totals. Its two finite-difference step sizes test numerical stability;
they are not a proof of the present bounds or small-sample covariance accuracy.
The code also uses actual Person contributions for the covariance, not just
their conditional owner-total means. No missing-transition-derivative defect
was found by this source tracing.

#### A lower bound at every nonextreme fitted ability

For one Person let n_j=L*e_j, T=sum_j a_j sum_r y_jr, and
M_L=sum_j n_j*a_j*(K-1). At a nonextreme profile t_hat, the conditional
expected weighted total equals T and both T and M_L-T are at least a_min.
Bounded category offsets imply p_j0>=c when t_hat<=0, and p_j,K-1>=c when
t_hat>=0, uniformly over the structural domain. For integer categories,

    Var(Y_j) >= p_j0 E[Y_j^2] >= p_j0 E[Y_j],
    Var(Y_j) >= p_j,K-1 E[(K-1-Y_j)^2]
             >= p_j,K-1 E[K-1-Y_j].

The appropriate inequality in each half-line gives the total Person curvature

    H_tt = sum_j n_j*a_j^2 Var(Y_j)
      >= c*a_min*T           if t_hat<=0,
      >= c*a_min*(M_L-T)      if t_hat>=0,
      >= c*a_min^2 > 0        in either case.                   (C3)

The constant is independent of L and the nonextreme pattern, within this
fixed structural/design scope. This is total curvature **at the fitted
nonextreme ability**, not one-block information at an arbitrarily large true
ability. Dividing it by L gives only a c/L lower bound. Extreme profiles are
excluded from (C3); their extended score is zero and their transition row is
absorbing and independent of beta. This does not invert their zero curvature.

Together with |t_hat|<=C*ell_L, (C3) supplies conservative derivative envelopes.
At a fixed finite theta, derivatives of a rating's log probability in beta
grow at most polynomially in |theta|. In particular, the total cross derivative
|H_t,beta| is bounded by C*L*ell_L at t_hat. Implicit differentiation gives

    ||D_beta t_hat|| <= C*L*ell_L.

This intentionally loose bound avoids assuming that Person information grows
linearly with L for every possible response pattern. Differentiating W_0 at
the profile gives `||D_beta W_0|| <= C*L*ell_L^2`. For a transition row,
differentiate its conditional response probabilities, including D_beta t_hat.
The absolute log-probability derivative is bounded by C*L^2*ell_L, so the
sum of absolute derivatives in that row has the same bound. Consequently

    ||D_beta P||_(infinity -> infinity) <= C*L^2*ell_L,
    sup_y ||D_beta W_k,L(y;beta)|| <= C_k*L^2*ell_L^2.            (C4)

The second inequality uses (C1), ||Q||<=2 and ||W_0||<=C*ell_L. Fixed dimension
allows directional and matrix norms to differ by constants. None of (C3)--(C4)
claims that these worst-pattern bounds describe typical numerical accuracy.

For any other fixed derivative order, repeated implicit differentiation divides
by H_tt and combines finitely many likelihood derivatives and lower-order
profile derivatives. By (C3), induction gives some finite powers of L and
ell_L. Derivatives of transition probabilities have the same property because
they are a probability times a finite polynomial in log-probability derivatives;
summing probabilities avoids a factor equal to the number of response patterns.
Repeated product differentiation of Q^k then gives polynomial envelopes for
the required fixed-order derivatives of W_k. This argument does not assert
sharp powers, uniformity as k grows, or an O(1/L) weak-error expansion.

#### Tail bounds for the Jacobian and covariance

Retain the same cutoff t_L and bounded-mean/variance normal family as above.
Using (C4), uniformly over the fixed structural domain,

    ||E[D_beta W_k,L * 1{|theta|>t_L}]||
       <= C_k*L^(2-q)*ell_L^2.                                 (C5)

For the unnormalized score U_k,L, its second moment on the covariance scale
obeys

    ||E[(U_k,L U_k,L')/L * 1{|theta|>t_L}]||
       <= C_k*L^(1-q)*ell_L^2.                                 (C6)

The same order holds for the centered score outer product within each fixed
roster, since its mean norm is also bounded by C_k*L*ell_L. Thus q>2 suffices
to make both displayed tails vanish. Larger fixed q controls any specified
polynomial rate, or other fixed-order derivatives/moments after accounting
for their envelope powers. There is no truncation of generated abilities or
data-dependent selection here; t_L only splits an expectation in a proof.

These are the tail pieces of `A_L/L=E[D_beta W_k,L]` and `B_L/L`, respectively.
They do not establish that either converges to J: the central-region limits,
nonsingularity, chosen local root and sampling-law assumptions are still
needed. They also do not establish an empirical sandwich CLT or consistency
when N and L grow together, or justify conditional coverage after refusals.
At fixed L, all these response-score derivatives and moments are finite under
any proper ability mixture in this model, even if ability itself has no finite
moments. The large-L bias expansion is a different, stronger question.

#### The leading bias coefficient is integrable; the remainder is the gap

For the fixed one-block family, let I(theta)=psi_tt(theta). The finite category
probabilities and positive slopes imply

    I(theta) >= c*exp(-C*abs(theta)) > 0.

For example, one observed cell's adjacent-category probabilities provide this
lower bound on its variance; the block has fixed nonzero exposure. The block
cumulants and their fixed-order derivatives have at most polynomial growth
in |theta| before division by I. Therefore the previously derived coefficient

    c_k(theta) = (-D_1)^k b_1(theta),
    b_1 = C_moment/(2 I) - A_moment*kappa_3/(2 I^2),
    D_1 f = f''/(2 I) - kappa_3*f'/(2 I^2)

has a bound `||c_k(theta)|| <= C_k*(1+abs(theta))^d*exp(C_k*abs(theta))`
for some finite d at each fixed k. Here A_moment and C_moment are the block
covariances defined in the fixed-block derivation, not the equation Jacobian.
Repeated differentiation produces only finite sums/products and finite powers
of 1/I. A normal family with bounded mean and variance integrates this envelope
uniformly. Hence the candidate coefficient `c_bar_k=sum_g pi_g E_Fg[c_k]`
is well-defined. This does **not** justify exchanging the large-L expansion
with expectation. The coefficient is defined at generating/evaluation truth;
its derivative along that diagonal is not the off-truth Jacobian in (C2).

To state the remaining obligation precisely, write at truth

    m_k,L(theta) = E_beta0,theta[W_k,L(Y;beta_0)]
                = c_k(theta)/L^(k+1) + R_k,L(theta).

One sufficient transfer condition would be

    sup_{|theta|<=t_L} ||R_k,L(theta)||
      <= C*(1+t_L)^d*exp(C*t_L)/L^(k+2).                         (C7)

If (C7) is proved for the actual recursion, its central remainder is
`L^(-k-2+o(1))`, since t_L=O(sqrt(log L)). The score-tail bound above and the
coefficient envelope then imply, for q>k+2,

    G_k,L(beta_0) = c_bar_k/L^(k+1) + O(L^(-k-2+o(1))).          (C8)

For the coefficient-tail step, completing the square in the normal density
shows that its exponential-polynomial envelope integrated outside t_L is
bounded by `L^(-q+o(1))`; bounded mean/variance make this uniform over the declared family.
The coefficient term also carries L^(-k-1). The raw score tail is bounded by
`C*ell_L*L^(-q)`, so both are negligible at the displayed remainder scale.

This is a **conditional transfer lemma**, not a claim that (C7) has now been
proved. It specifies what the compact-domain argument must additionally
control: its cutoff neighborhoods, inverse-mean derivatives, Taylor remainders
and every fixed operator composition as the true-ability range expands.
Tracking the score alone or the coefficient alone is insufficient. Merely
knowing that each compact interval has a finite remainder constant also
does not suffice: if that constant grew like exp(C*t_L^2), choosing a larger
q could worsen the central rate while improving the tail. Such growth is a
warning about an unproved bound, not a finding that the present remainder
actually has it.

Full evaluation derivatives and second-moment central remainders need their
own expanding-range control. If those establish a regular local root,
`A_L/L -> J`, `B_L/L -> J` and the matching empirical limit, then (C8) would
recover the previous leading centering rate and its conditional
`N/L^(2k+1) -> 0` sufficient restriction. The tail bounds alone cannot license
that restriction. Growing facets, vanishing slopes, informative allocation,
missingness and dependence remain separate design-specific problems.

Finally, the public exact calculation's default 5,000 owner-total-state cap,
positive-probability checks and finite profile solver remain unchanged.
An L-to-infinity result for the mathematical equation does not mean that the
current API can execute an arbitrarily long sequence of such fits. No new
correction order, covariance choice, bias estimate or interval is introduced.

### Bounded numerical pilot after authorization

**October 1: completed after the user requested small new estimation,
simulation and numerical differentiation.** The question was whether the
derivative accounting agrees with the current implementation, and whether
wider abilities reveal finite-exposure or delivery problems before a larger
study. This pilot does not prove the expanding-range remainder bound above.

The [runner](jml-normal-range-pilot-20261001.R) reuses the saved Criterion-owned
GPCM design: two raters, two criteria, categories 0/1/2, centered locations/steps
and log slopes, truth (.3,-.4,-.6,-.9,.25), and two unequal rosters with
exposures (2,1,0,1) and (0,2,2,2), in proportions .6/.4. Repeats are generated
conditionally independently. The frozen scope was:

- Full response-pattern derivative witnesses for both rosters, at truth and
  one fixed off-truth vector; all five structural directions, central steps
  1e-4 and 5e-5, and correction orders 2/4. Generating distributions stay fixed
  during evaluation-parameter differentiation. The independent pattern
  reference uses scalar root solving; the current equation uses compressed
  totals and vector bisection.
- Exact conditional score means at abilities -6,-4,-2,0,2,4,6, exposures
  L=1,2,4,8 and orders 0/2/4, for both rosters and all five coordinates.
  These are 168 vector expectations (840 coordinate rows), not simulated
  datasets. The largest total-state space is 2,145; all states are retained.
- Four new datasets: N=40/120 crossed with normal SD=1/2, mean zero, one
  replicate per condition, original exposure L=1. Seeds 98100101--98100104
  differ from the paused study's declared seed family. Each dataset is shared
  by ordinary public JML and explicit orders 2/4. The public default starts,
  maxit=400 and method-specific tolerances remain unchanged. A 60-second
  per-call resource limit is recorded; no retained fit reached it.

#### Derivative and covariance agreement

The explicit product rule (C1) and the independent response-pattern derivative
were compared with finite differences of the current complete equation, over
80 direction/order/step witnesses. Maximum point discrepancy was 2.586292e-12.
Maximum derivative discrepancies, divided by max(1, maximum absolute complete
derivative in that witness), were 2.249613e-8 for the independent full reference
and 2.250534e-8 for the product rule. Halving the derivative step changed the
complete derivative by at most 2.979173e-8 on this scale. All pass the frozen
1e-8 point and 1e-6 derivative tolerances.

Freezing the transition while differentiating the raw score instead produced
scaled discrepancies .1339160--.9946845 across the same witnesses. These are
derivative differences, not estimated coverage loss or percentages of SE.
Thus including the transition derivative matters in these designs; the
current whole-equation implementation agrees with the complete calculation.

All eight returned corrected covariances were independently reconciled at
their retained roots using the total-expectation research implementation and
the original fixed-roster sampling law. Maximum discrepancies were
1.177921e-9 for the Jacobian scaled by max(1, its maximum absolute entry),
1.332268e-15 for the meat in absolute units, and 2.936638e-9 for covariance
relative to its maximum absolute entry. The saved influence cross-product
reproduced the public covariance exactly in these checks. This is agreement
between calculations of local-root uncertainty, not sampling calibration or
truth-centering evidence.

#### Finite-exposure and public-fit findings

At true ability +/-6 and L=8 (32 or 48 ratings per Person), extreme-pattern
probabilities across the two rosters and signs still range from .4290673 to
.8389072. At ability zero they are below 2.33e-17. The exact equations retain
all of that endpoint mass. The maximum absolute normalized score mean over
both rosters, all seven abilities and all coordinates is:

| L | Raw profile | Order 2 | Order 4 |
| --- | ---: | ---: | ---: |
| 1 | .251451 | .093250 | .066747 |
| 2 | .152324 | .060461 | .047588 |
| 4 | .096830 | .037086 | .024734 |
| 8 | .056698 | .018892 | .014922 |

These maxima decrease, but their L^(k+1)-scaled values have not stabilized
on this wide ability grid: for order 2 the maximum rises from .09325 to
9.67291, and for order 4 from .06675 to 488.958. Four exposure levels neither
refute an eventual asymptotic rate nor establish it. These are conditional
score means, not structural estimator bias; they do not integrate over either
normal distribution used in the new datasets. The result supports treating
the expanding-range central remainder as substantive work, rather than
declaring the compact-range approximation adequate for modest exposure.

| N | Generating SD | Extreme Persons | Ordinary JML numerical/readiness result | Corrected orders 2 and 4 |
| --- | ---: | ---: | --- | --- |
| 40 | 1 | 1 | Numerical pass; fit remains review | Both return a local point/covariance with unresolved alternate start |
| 120 | 1 | 10 | Numerical pass; fit remains review | Both starts agree for both orders; local covariance available |
| 40 | 2 | 7 | Iteration limit; fit blocked | Both starts agree for both orders; local covariance available |
| 120 | 2 | 32 | Numerical pass; fit remains review | Both starts agree for both orders; local covariance available |

For N=40/SD=1, unsuccessful corrected-start stages include owner-total
probability underflow; the last unsuccessful stages stop without solving the
equation (residuals 3.386879e-4 and 9.625520e-4 for orders 2/4). Small residuals
and available covariance at the returned branch do not resolve that missing
start confirmation. These two results fail the existing consistent-root
research-interval gate; they are not discarded from point-delivery results.
No second distinct accepted root was observed.

The ordinary N=40/SD=2 fit returns finite structural traces but is explicitly
blocked: fitted slopes are approximately .01736 and 57.5886, and the largest
absolute error among the five free structural coordinates is 38.1878. The
independent profile-reference evaluation underflows at that point and is
unavailable. It supplies no profile-error certificate. The three numerical-pass
ordinary cases have independent profile mean-score residuals at the unchanged
public structural point between 1.13e-7 and 3.90e-7; no structural reference
refit or neighborhood-curvature certificate was performed. In the machine
summary, ordinary `PointAvailable` only records finite returned structural
values; the separate readiness status determines whether they are usable.

All fits retain the expected duplicate-cell warning for this repeated-response
design. The failed ordinary fit additionally retains the iteration-limit
warning. Generated repeats are independent conditional on ability by design;
this does not validate dependence between real repeat ratings. One dataset
per condition supplies no bias estimate, empirical SD, coverage estimate,
failure-rate comparison or preferred order. The generic small-to-large-N and
facet/missingness/dependence roadmap is unchanged.

#### Execution accounting and decision

The initial pilot calls were rejected before estimation because the runner
passed correction-only sampling to ordinary JML and `reltol` to corrected JML.
Those 12 argument errors and their source are retained. The corrected runner
reuses the same four saved inputs. Its first pass saved six fits, then stopped
when the ordinary N=40/SD=2 reference evaluation underflowed outside the error
handler. Completion preserves that failure, reuses the six saved fits and
retains reference failures without aborting. The unretained ordinary fit was
repeated once on the same saved input. Thus there were 12 pre-estimation
rejections and 13 estimation calls for 12 unique method/dataset pairs, with no
additional data generation. A summary-field bug caused R's partial `$error`
lookup to match `$errors`; exact lookup and reconciliation corrected the
reported reference-error column without recomputing those fitted results.

The final evidence is
`validation-results/jml-normal-range-pilot-20261001/verified-summary.rds`,
with initial/refit/completion logs, all four inputs, source snapshots/hashes,
derivative arrays and step checks, exact means, and each fit's warnings,
attempts and covariance. The twelve retained fits used 87.405 seconds in their
recorded fit calls; this excludes reference calculations and failed/repeated
pilot work and is not a runtime benchmark. Source and input hashes were checked
after completion. No paused study, MML confirmation, public inference gate or
estimation default was changed.

This pilot provides concrete targets for further work: distinguish the
corrected-start transition-probability underflow from unresolved root behavior
using the saved attempts, retain the blocked ordinary fit as an adverse
boundary/numerical witness, and control the finite-exposure remainder before
claiming normal-population centering. Increasing replication before resolving
which procedure will be evaluated would not answer these numerical questions.

### Subsequent facet-structure witness

The [bounded C-design pilot](internal-roadmap-0.2.4.md#bounded-facet-structure-pilot-after-authorization)
adds N=20/240 comparisons with two or three non-Person facets, varying Rater
3/6 and Task 2/4 while retaining Criterion 2, categories 0/1/2 and eight
responses per Person. Ordinary JML and both corrected orders share each input;
estimated-population one-family MML supplies the matched marginal arm. The
full design, integration refinements and all censored calls are recorded there.

This witness makes the C-design covariance limitation concrete. At N=20,
six-rater and four-task allocations have within-roster score ranks 5 and 8
for nine structural coordinates. Returned corrected points therefore do not
imply estimable full covariance under the declared fixed-roster law. At N=240,
all ten corrected calls return consistent-start roots and covariance. Three
N=20 corrected calls reach the declared time budget; their root status is
unresolved, not established nonconvergence. Half-step covariance reconstruction
agrees for the fourteen available cases, using native score evaluation.
These are design-specific numerical witnesses. They establish neither the
ordinary estimator's structural sampling covariance nor corrected truth
centering, growing-facet asymptotics or protection against informative
assignment and dependent ratings.

### Remaining conditions tied to the actual roadmap

| Planned use | What this review establishes or reuses | Remaining condition for structural truth inference |
| --- | --- | --- |
| Ordinary public JML | The raw mathematical profile score has the stated bound. Retained finite-profile and extreme-profile fixtures distinguish ordinary optimizer output from a separately reoptimized extended-profile estimator. | Bridge the actual public structural point to a declared finite/extended-profile solution; derive its joint sampling covariance and address structural centering. A finite optimizer trace or the Schur inverse alone is insufficient. |
| A/B normal populations and fixed L=1/2 | Score, complete-Jacobian and covariance-moment tail contributions have bounds in the fixed-design model; the leading bias coefficient is normal-integrable. Independent data allow direct descriptive truth inclusion of the named corrected candidate. | Prove the expanding-range central remainders for the actual recursion, full evaluation derivatives and covariance; justify local-root/sandwich behavior and control displacement relative to SE. Two exposure values do not establish a growth theorem or a practical threshold. |
| C new facets, levels and categories | Each fixed supported design can have its own constants and parameter map. Existing cap/roster exclusions remain. | Bounds and identification are design-specific; no uniform claim across growing dimensions or arbitrarily weak links follows from fixed-dimension results. |
| E assignment, missingness and dependence | Random-roster centering is already a different sampling target; the existing controls separate mechanisms. | Informative allocation/missingness can alter conditional response/ability laws; dependence breaks the independent-block premise. A normal-tail bound and a sandwich do not remove these sources of displacement. |
| A public bias-adjusted or bias-bounded interval | Existing saved roots diagnose displacement for their own generating laws. | A usable observed-data bias correction needs its own target, uncertainty and validation. A bound needs a justified bound over a declared domain. Generating truth, saved oracle displacement or a difference between orders supplies neither. |

The next mathematical step is to track the compact expansion's constants and
its full evaluation-parameter derivative on the expanding normal range, or
to derive a directly integrated remainder bound. This is a proof obligation,
not a request for another exposure-root grid. The retained joint-growth
restriction `N/L^(2k+1) -> 0` cannot be reused unchanged until the transferred
rate, covariance and root assumptions are justified; no minimum-N or minimum-L
rule is chosen from it. Fixed-L descriptive mapping remains scientifically
useful without claiming such a theorem, and cannot itself supply a universal
truth-interval guarantee.

Keep the observed-data orders 2/4 and their research candidate gates unchanged.
The ordinary public/profile bridge and corrected centering argument are
separate outstanding tasks; neither requires a new estimator default, automatic
order selection or a new all-cell population-root calculation now. Full formal
JML inference remains unfinished within the agreed work. This review adds no
repetitions, numerical checks or public interval, and resumes no paused study.

## October 1 ordinary JML and matched comparison contract

This is a static source review and design decision, with no fitting, generation,
derivative evaluation, numerical pilot or restart. It supports the
[current baseline contracts](internal-roadmap-0.2.4.md#resolved-baseline-comparison-contracts).
Older repeated-sample and external-engine records retain their original
source/procedure identities; they are not evidence that all current public
ordinary-JML outputs share a qualified profile estimator or covariance.

| Question | Current source evidence | Consequence for the planned evaluation |
| --- | --- | --- |
| What is ordinary JML? | `fit_mfrm()` in `R/api-estimation.R` dispatches a non-NULL `jml_correction_order` to the distinct corrected route. Otherwise `mfrm_loglik_jml()` / the cached evaluator in `R/mfrm_core.R` and the direct optimizer fit free Person and structural coordinates jointly. | Retain the public unadjusted procedure as its own arm. The research extended-profile reference, external score adjustments and classical multiplicative corrections are different procedures. |
| Which scale is common? | `build_facet_constraint()` calls in `R/mfrm_core.R` leave Person uncentered and center non-Person facets under `noncenter_facet="Person"`; one-family log slopes and step constraints determine the remaining representation. `fit_mfrm()` requires this centering for estimated-population MML. | Match centered facet/step parameters and geometric-mean-one slopes in A/B, with explicit estimated-normal MML. A fitted normal mean/SD is not available under JML. Do not transform JML by its noisy empirical Person SD. |
| What happens to extreme Persons? | `audit_mfrm_person_boundary()` and `apply_mfrm_person_boundary()` in `R/core-jml-boundary.R` set independently free all-low/all-high primary estimates to -Inf/+Inf and display estimates to NA, retaining finite optimizer traces separately. Anchored extremes are fixed; constraint-coupled extremes require review. | Count endpoints and boundary statuses. Keep all original datasets/Persons; do not treat the finite trace as an MLE or infer that all structural contrasts are unidentified. |
| What do ordinary-JML SEs mean? | `calc_facet_se()` sums weighted observation-level information within each level. `build_measure_se_table()` uses these approximations for JML and labels their precision exploratory/screening-only. The full-curvature source check for GPCM scoring does not return a structural sampling covariance. | Do not create a joint contrast interval by combining marginal printed SEs, call the screening bands qualified truth intervals, or transfer research sandwich coverage to the public fields. |
| Can this calibration score new Persons? | `prediction_source_scoring_readiness()` and `prediction_jml_calibration_review()` in `R/api-prediction.R` reject known Person/additive/slope boundaries; the latter also checks finite unregularized joint curvature. `mfrmr_calibration_jml_source_review()` in `R/core-fixed-calibration.R` enforces source readiness for extraction. | Calibration-cohort Person endpoints and new-Person conditional EAP are different outputs. Report source acceptance and score delivery separately from calibration point recovery, including how those rates change with N. |
| Is corrected-JML scoring the same gate? | `mfrm_jml_scoring_components()` in `R/core-jml-adjustment-scoring.R` checks the adjusted equation, rank and remaining root step. Point availability is separate from covariance availability. | Do not apply ordinary-likelihood source rules to the adjusted estimator or discard an admitted point/scoring result merely because RootSE is unavailable. |

**Why the larger-N conditions matter for delivery as well as bias.** Under
independent Persons with fixed per-Person exposure and common extreme-response
probability p_ext, the probability of at least one extreme training Person is
`1 - (1-p_ext)^N`. With fixed roster counts N_g and roster-specific probabilities
p_ext,g, it is `1 - product_g[(1-p_ext,g)^N_g]`. These are probability identities
under the stated independence/sampling assumptions, not estimated frequencies.
For 0<p_ext<1 the common-design probability increases as Persons are added
without changing their individual designs. Therefore larger N need not increase the availability of
an ordinary-JML consumer requiring *all* training Persons to have finite
estimates. Absence of extremes only gives an upper bound on acceptance; other
checks can still fail. This does not establish that structural calibration
becomes less accurate or that MML/corrected JML will be preferable.

The old external-engine pilot includes an `extended_profile_limit_v1` arm.
Its `mfrmr_jml_profile_recovery_apply()` adapter lives in
`inst/validation/jml-extreme-profile-recovery-pilot-0.2.3.R` and replaces tables
with a separately computed profile-limit result. This is not the ordinary
public optimizer's automatic behavior. The retained GPCM raw-profile and
corrected research studies likewise cannot silently stand in for current
public-solver failure rates. A future numerical bridge is needed only for the
specific evidence transfer sought, after the computation hold is lifted; a
successful bridge would not make all resulting statistical claims universal.

**Decisions closed for the A/B baseline.** Use explicitly estimated-normal MML
and the centered-facet/relative-slope scale shared with ordinary/corrected JML;
retain fixed-N(0,1) fitting as a separate assumption/default-workflow comparison.
Do not impose a normal population fit on JML. Common-prior EAP uses a declared
N(0,1) scoring prior through the supported prediction route, separately from
native scoring. Preserve all data-dependent refusals in delivery denominators.
No structural interval consumer or boundary-profile extension is added by
this decision. Source classification is established. The shared roadmap now
specifies [A/B generating truths and assignments](internal-roadmap-0.2.4.md#ab-generating-truth-and-assignment-specification),
[facet/workload comparisons](internal-roadmap-0.2.4.md#c-facet-structure-with-explicit-workload-controls)
and [robustness mechanisms with matched controls](internal-roadmap-0.2.4.md#e-robustness-mechanisms-and-matched-controls).
The fixed-roster baseline and iid assignment/missingness experiments have
different sampling laws; corrected-JML covariance must target the declared
law, rather than switch options after a rank failure. Statistical performance,
missing interval consumers, extensions and final execution/replication settings
remain open. The shared
[inference decisions and evidence allocation](internal-roadmap-0.2.4.md#inference-decisions-and-evidence-allocation)
now assigns existing studies, broad comparisons and future confirmation their
separate roles. The retained compact-domain, independent-exposure growth
argument does not qualify the new normal/skewed/dependent designs. Orders 2/4
remain separate point-estimation comparisons, while ordinary-JML formal
structural uncertainty and corrected-JML truth centering remain open. This
does not restart or replace the paused order-2 research protocol.
The [F scoring/reuse specification](internal-roadmap-0.2.4.md#f-person-scoring-future-cohorts-and-saved-reuse)
keeps native Person profiles separate from post-hoc reference-prior EAP,
accounts for calibration-source and batch refusals, and evaluates held-out
Persons with calibration-replicate uncertainty. Missing RootSE alone does not
invalidate an adjusted calibration that passes its own scoring-source checks;
ordinary-JML boundary refusals are not bypassed by finite printed estimates.
The [numerical protocol](internal-roadmap-0.2.4.md#calibration-procedures-and-bounded-numerical-refinement)
now specifies ordinary-JML controls and the corrected public maxit=400 call
with its two deterministic starts and recorded root-solving stages. No external
start search, order switch or covariance-driven root refit is introduced.
[Source/RNG identity](internal-roadmap-0.2.4.md#source-identity-and-random-number-allocation)
and [replication allocation rules](internal-roadmap-0.2.4.md#condition-accounting-and-precision-decisions)
retain the original studies and their seeds; no new manifest or data was created.
The [static source audit](internal-roadmap-0.2.4.md#static-source-audit-and-reusable-units)
now separates the research studies' different starts/root-acceptance rules from
the public procedure. In contrast, the public pilot snapshot's three adjusted-
JML core files match current files, and its order-2/fixed-roster/maxit=400 call
matches the planned public settings. The paused study retains that identity
and its additional consistent-root requirement for candidate intervals; its
113 fit files and 57 input files were counted without evaluating their results.
No interim sampling summary or resumption was performed. The
[family allocation ledger](internal-roadmap-0.2.4.md#family-allocation-ledger-and-work-order)
selects the full A/B sample-size/SD/exposure mapping for a working R=100 delivery
assessment, while preserving N=400 evidence and separately budgeting precise
correction-effect or interval claims when their required planning inputs exist.

The workflow help's blanket statement that the public JML route was uncorrected
was corrected in both its roxygen source and Rd page. It now distinguishes the
default unadjusted call from explicit experimental GPCM correction and retains
the limits on RootSE. NEWS already made this distinction; no fitting default,
estimator or numerical threshold changed. Documentation was checked statically;
no R tests or help regeneration were run during the computation hold.

## October 1 ordinary JML residual bridge

**Static source tracing and analytic derivation; no new numerical evaluation.**
The question is whether covariance derived for a profile estimator can describe
the structural values actually returned by ordinary `fit_mfrm(method="JML")`.
An exact regular joint solution supplies a correspondence, but a finite
optimizer iterate and a successful termination status do not establish it.
The derivation here makes the discrepancy explicit before any covariance is
transferred. It is conditional mathematical work, not an empirical certificate
for all public RSM/PCM/GPCM fits.

### Which public point is being compared?

`make_mfrm_direct_evaluator()` in `R/core-optimizer.R` evaluates the negative
conditional log likelihood jointly in free Person and structural coordinates.
`run_mfrm_direct_optimization()` retains an `opt$par` and recomputes its joint
gradient. In `mfrm_estimate()` (`R/mfrm_core.R`), `expand_params(opt$par, ...)`
supplies the parameters used by `build_other_facet_table()`, `build_step_table()`
and `build_slope_table()`. `apply_mfrm_person_boundary()` only changes Person
table fields: setting an extreme Person's primary estimate to signed infinity
does not reoptimize or replace the retained structural coordinates. The bridge
therefore concerns those unshrunk structural estimates and their identified
free-coordinate representation, not the displayed infinite Person values or
post-hoc `ShrunkEstimate` columns.

`build_mfrm_optim_control()` uses objective-change controls and, for L-BFGS-B,
a projected-gradient control. `build_optimizer_diagnostics()` reviews the
terminal joint gradient against `max(1e-4, 10 * reltol)` in this route; this is
not a bound on structural parameter error. R documents `reltol` in terms of
objective reduction and convergence code zero as successful completion.
Neither is a guarantee of proximity to an identified profile minimum.
See the [R optim documentation](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/optim.html).
The package's separate boundary/readiness checks remain in force; this review
does not replace them or change their numerical thresholds.

### Exact identity at a finite joint iterate

Use unit weights, a fixed finite observed response design with at least one
response per included Person, a finite category set of size at least two,
no interactions or shrinkage, and independently free, unanchored Person
coordinates. Work in identified free
structural coordinates beta, with the declared affine location/step constraints
and, for one-family GPCM, identified log-slope coordinates. Restrict beta to a
finite neighborhood where slopes have a positive lower bound. RSM/PCM have
unit slopes. This establishes a baseline, not a restriction on the package's
other supported point-estimation designs.

Write the negative log likelihood as

    Q(theta, beta) = sum_i q_i(theta_i, beta).

Partition Persons into nonextreme I and all-low/all-high E. For i in I,
q_i is strictly convex in its scalar theta_i: its second derivative is the
sum of positive slope-squared conditional response variances. The score has
opposite signs in the two tails, so a unique finite conditional minimizer
t_i(beta) exists. For i in E, the infimum is zero as theta_i tends to the
appropriate infinity. It is not attained at a finite theta_i. Thus the
extended-profile objective for this observed dataset is

    M(beta) = inf_theta Q(theta, beta)
            = sum_{i in I} q_i(t_i(beta), beta).

The zero terms from E are an exact likelihood limit, not deletion of failed
datasets or a change to recovery/delivery denominators. They say nothing yet
about existence, identification or uniqueness of a structural minimum of M.

At a finite public iterate (theta_tilde, beta_tilde), define the following
column vectors in the same free-coordinate representation:

    r_beta = partial_beta Q(theta_tilde, beta_tilde)
    r_I    = partial_theta_I Q(theta_tilde, beta_tilde)
    e_beta = sum_{i in E} partial_beta q_i(theta_tilde_i, beta_tilde).

Let d = theta_tilde_I - t_I(beta_tilde). Hold beta=beta_tilde and the extreme
traces fixed; integrate Hessian blocks along theta_I(s)=t_I+s*d, 0<=s<=1:

    Hbar_II    = integral_0^1 partial_theta_I,theta_I Q(theta_I(s), beta_tilde) ds
    Hbar_betaI = integral_0^1 partial_beta,theta_I Q(theta_I(s), beta_tilde) ds.

Hbar_II is positive diagonal. The fundamental theorem of calculus gives
r_I=Hbar_II*d and the difference between the nonextreme structural gradients
as Hbar_betaI*d. Using the envelope gradient at t_I therefore gives the exact
identity

    g_profile(beta_tilde) = grad M(beta_tilde)
      = r_beta - e_beta - Hbar_betaI Hbar_II^{-1} r_I.                 (1)

There is no omitted Taylor remainder: the bars denote integrated Hessians,
not blocks evaluated only at the terminal point. If I is empty, the last term
is absent and M is constant, so structural identification fails in this
baseline. Small r_I alone need not imply small ability error when Person
curvature is weak; the effect on beta depends on the cross-curvature term.

When E is empty and the finite joint score is exactly zero, (1) yields a zero
profile score. A positive Person block and positive profile Schur complement
give a strict local joint/profile minimum. This is a local statement; in
particular it does not select a global GPCM optimum. When E is nonempty there
is no finite joint optimum in the independently free extreme directions.
The finite public structural point may still approximate an extended-profile
minimum, but its approximation must account for all three terms in (1).

### From score discrepancy to structural error

Suppose a selected interior profile root beta_p exists, and the profile
Hessian has smallest eigenvalue at least lambda>0 throughout a convex
neighborhood containing beta_tilde and beta_p. Then integration of the
profile Hessian between these points, followed by Cauchy--Schwarz, gives

    ||beta_tilde - beta_p|| <= ||g_profile(beta_tilde)|| / lambda
      <= (||r_beta|| + ||e_beta||
          + ||Hbar_betaI Hbar_II^{-1} r_I||) / lambda.               (2)

This is a Euclidean bound in the stated coordinates. A positive Hessian at
one point does not certify the neighborhood, root existence or the lower
bound lambda. The first-order expression `S^{-1} g_profile`, with S the
profile Hessian, is a local displacement diagnostic, not a proved error bound,
bias correction or confidence interval.

Existence can instead be certified locally if a closed ball of radius rho
around beta_tilde lies inside the regular structural domain, the same lower
curvature bound holds throughout the ball, and `||g_profile|| < lambda*rho`.
On its boundary the outward radial derivative is at least
`rho*(lambda*rho - ||g_profile||)>0`. A minimum over the compact ball must
therefore be interior, and strict convexity makes that root unique within the
ball. This supplies a sufficient existence condition for (2), not global
uniqueness. Neither the ball nor its curvature bound has been numerically
certified here.

For fixed structural dimension p, let every component of the finite joint
gradient be bounded by epsilon and put
`kappa_i = ||Hbar_beta,i|| / Hbar_ii`. A sufficient bound from (1) is

    ||g_profile|| <= sqrt(p)*epsilon + ||e_beta||
                    + epsilon*sum_{i in I} kappa_i.                (3)

Consequently, even a joint-gradient check cannot be interpreted without
curvature and aggregation over Persons. As an illustrative conditional regime,
suppose lambda>=c*N, sum(kappa_i)<=C*N and the deterministic gradient bound
epsilon hold on events with probability tending to one, for constants c,C>0.
If a justified contrast has a nondegenerate sampling scale N^(-1/2),
`epsilon=o(N^(-1/2))` and `||e_beta||=o_p(sqrt(N))` then suffice to make
the bound in (2) negligible in probability at that scale. These are sufficient asymptotic conditions
for that bound, not necessary conditions for a particular fit or proposed
package cutoffs. A fixed review tolerance alone proves neither equivalence
nor failure as N changes. Sparse designs, increasing structural dimension or
weak curvature require their own rates.

For an extreme Person already in the correct tail, finite categories, bounded
structural offsets/derivatives and slopes bounded below by a_min>0 give

    ||partial_beta q_i(theta_i, beta)||
       <= C*n_i*(1+abs(theta_i))*exp(-a_min*abs(theta_i)).            (4)

Here n_i is observed exposure and C depends on the declared structural
neighborhood/design. To see the bound, each nonendpoint category probability
is at most a constant times exp(-a_min*abs(theta_i)); its utility derivative
is bounded for locations/steps and grows at most linearly in abs(theta_i)
for log slopes. Their finite sum gives (4). Summing over E bounds e_beta.
The same limit makes extreme-Person curvature tend to zero: substituting an
infinite estimate into an inverse finite-joint information matrix is invalid.
One must form the extended profile first. The constants are not uniform over
vanishing slopes, growing facet structure or unbounded structural sequences.

### What transfers to covariance, and what remains separate?

Under a declared sampling law, let beta_star denote the population target
of the selected profile branch, and beta_0 generating structural truth. The
exact accounting is

    beta_public - beta_0
      = (beta_public - beta_p)       [numerical/procedure discrepancy]
      + (beta_p - beta_star)         [sampling variation]
      + (beta_star - beta_0).        [structural target bias]

For a prespecified contrast, a profile sampling limit transfers to the public
point if its first term is negligible at that contrast's justified sampling
scale, with the same branch/selection and availability accounted for. Reusing
a covariance estimator additionally needs its consistency under that sampling
law and stability under this perturbation; closeness of points does not qualify
the public screening SEs.
Equations (1)--(4) address the first term conditionally. They do not supply the
sampling covariance or bound the last term. The candidate sandwich in
[Sampling covariance and its target](#sampling-covariance-and-its-target)
concerns the second term under its stated assumptions. The inverse Schur
complement alone is not that sandwich, and neither removes fixed-exposure
incidental-parameter bias. The number of Persons and information per Person
therefore retain different roles in the roadmap.

Anchored extreme Persons contribute their likelihood at the fixed ability;
their profile contribution is not zero. Coupled Person constraints require
profiling the constrained nuisance vector, not the scalar separation above.
Nonunit weights, interactions, structural boundaries and growing facet counts
need explicit extensions. Conditioning on an observed missing-response roster
can preserve this likelihood algebra while changing the sampling law or
target. It does not justify informative missingness, assignment or dependence;
those remain the separate C/E comparisons. No normal ability distribution was
assumed for the deterministic identity, but that does not establish the
corrected-JML uniform derivative/bias expansion for unbounded abilities.

### Evidence reuse and the next bounded check

The two saved finite GPCM examples in the existing profile-information record
check local envelope/Schur identities, with nonzero retained structural
gradients. They do not certify (2) for current public sources. The older
[90-dataset extreme-profile pilot](jml-extreme-profile-recovery-pilot-record-0.2.3.md)
found a maximum raw/profile aligned structural change of 5.935103e-6 under
its own source and forced-extreme design. That is evidence of closeness there,
not a universal tolerance, an SE-scale result or a current-source bridge;
the record already shows that the profile operation does not repair bias.

After authorization for numerical work, first reuse compatible saved fits
and source identities. At their unchanged structural coordinates, independently
profile the free nonextreme Persons, use exact extreme limits, and check the
profile objective/gradient and the residual decomposition. New nuisance solves
or derivative evaluations are calculations and remain held. Only if local
curvature/branch evidence is adequate can a displacement diagnostic be used;
a rigorous error certificate additionally needs the neighborhood bound in (2).
A separately optimized structural reference, if needed, must retain its own
procedure identity and must not overwrite the public point. No correction
enumeration engine, order-0 state cap, new automatic refinement or public
interval is introduced. The bounded bridge concerns numerical correspondence;
covariance accuracy, bias and robustness still require their own evidence.

## October 2 analytic JML bridge and fixed-exposure counterexample

**Purpose.** Decide what a correctly optimized ordinary JML point and a matching
covariance would actually establish before spending more computation on them.
The first result strengthens the RSM/PCM source-to-profile bridge; the second
shows exactly why solving that bridge cannot by itself supply truth inference.
Both concern declared likelihoods/equations. No public return is certified or
changed, and no new simulation condition or fit is allocated.

### A design-only residual bound for ordinary RSM and PCM

Use the preceding bridge's baseline: observed unit-weight ratings on fixed
finite category ladders, no shrinkage/interactions, independent unanchored
Person coordinates, affine structural constraints and **fixed unit slopes**.
Write the category utility for rating j of Person i as

    z_ijk = k*theta_i + h_jk(beta),
    h_jk(beta) = c_jk + D_jk' beta.

Here beta is the identified free structural vector and D_jk is fixed by the
facet/step design and its constraint map. This is the ordinary RSM/PCM kernel,
not a GPCM kernel with freely estimated slopes merely evaluated at one.
For p>0 define the finite, coordinate-dependent design constant

    C = max_{j, k != l} ||D_jk-D_jl||_2 / |k-l|.

For one rating, conditional on theta_i and beta,

    H_theta,theta = Var(Y),
    H_beta,theta = Cov(D_j,Y),
    Cov(D_j,Y) = (1/2) sum_{k,l} p_k*p_l*(D_jk-D_jl)*(k-l).

The corresponding double-sum identity for Var(Y) gives
`||Cov(D_j,Y)|| <= C*Var(Y)`. Summing over ratings and integrating along
the Person-profile segment preserves this inequality. Consequently every
nonextreme Person in identity (1) satisfies

    ||Hbar_beta,i|| / Hbar_ii <= C.

This controls the structural effect of its residual even when Hbar_ii is
small; it does not bound the Person-ability error itself. For an extreme
Person, all category residuals point toward the same endpoint. The same
Lipschitz bound implies

    ||partial_beta q_i|| <= C*|partial_theta_i q_i|.

For example, at an all-high response, each norm is bounded by C times its
expected shortfall from the top category; the absolute Person derivative is
the sum of those nonnegative shortfalls. The all-low case uses expected
scores above zero. This holds at any finite Person iterate, not only deep in
the correct tail. Applying the triangle inequality to (1) therefore yields

    ||grad M(beta_tilde)||
      <= ||r_beta|| + C*sum_{all observed Persons i} |r_i|.          (5)

All residuals here are for the **summed** negative log likelihood. Source
inspection confirms that `make_mfrm_direct_evaluator()` sums the ordinary JML
log probabilities; any averaged or reparameterized diagnostic needs the
corresponding transformation. Equation (5) needs no pattern enumeration or
evaluation of the integrated Hessian. It is a sufficient bound, potentially
conservative because it discards cancellation. It does not change a cutoff.

The joint RSM/PCM negative log likelihood is convex in the free affine
coordinates. Partial minimization over Persons preserves convexity, including
the zero extreme limits. Hence a finite exact stationary structural point is
a global profile minimizer in this baseline. Positive-definite profile
curvature at such a point additionally makes that minimizer unique. A
positive Hessian at a nonstationary point does not supply root existence.
For a finite public iterate, the earlier neighborhood curvature condition is
still needed to turn (5) into a parameter-error bound:

    ||beta_tilde-beta_p||
      <= [||r_beta|| + C*sum_i |r_i|] / lambda.                    (6)

When p and the design are fixed, lambda>=c*N and every joint component is at
most epsilon in magnitude, (6) is of order epsilon. Equivalence at a regular
N^(-1/2) sampling scale therefore follows under the sufficient condition
epsilon=o(N^(-1/2)), together with the root/neighborhood conditions. This is
not a claim that every fixed-tolerance fit fails. C is not uniform over
arbitrarily growing facet structures. Free log-slope derivatives contain
theta; the same design-only bound and convexity argument do not transfer to
GPCM. Its existing integrated-Hessian bridge and branch review remain needed.

### Two-item ordinary JML: an exact bias and covariance calculation

This is the item-only binary Rasch submodel: **one non-Person facet, Item,
with two levels; two categories 0/1; two responses per Person**. There is no
rater facet, interaction, missingness or estimated slope. Center difficulties
as b1=delta/2 and b2=-delta/2, and let s(t)=1/(1+exp(-t)):

    P(Y1=1 | theta)=s(theta-delta/2),
    P(Y2=1 | theta)=s(theta+delta/2).

Responses are conditionally independent. For sampling, Persons are iid with
any proper ability distribution on the real line and a finite generating
contrast delta_0. Normality and finite ability moments are unnecessary.
Let n10,n01 count the two discordant patterns, and nD=n10+n01. Both discordant
patterns have theta_hat=0 at every finite evaluation delta; 00/11 have zero
extended-profile negative log likelihood. Thus

    M(delta) = -2*n10*log s(-delta/2) - 2*n01*log s(delta/2).

For n10,n01>0 its unique finite minimizer is

    delta_hat_J = 2*log(n01/n10).

At every true ability, `P(01 | theta)/P(10 | theta)=exp(delta_0)`.
The same ratio holds after integrating over any such ability distribution.
With pi_D=P(Y1+Y2=1)>0 and tau=P(01 | discordant)=s(delta_0),

    delta_hat_J -> delta_star = 2*delta_0.

This reproduces the classical two-item inconsistency result, also discussed
in [Skrondal and Rabe-Hesketh (2022), Section 6](https://link.springer.com/article/10.1007/s11336-021-09816-8).
The derivation here is explicit so that its identification, extreme limits
and covariance can be checked together. It is not a claim that all ordinary
many-facet JML contrasts have a universal factor-two bias.

Write Z=1 for pattern 01 and D=1 for a discordant Person. With
p=s(delta/2), the negative profile-score contribution is `U_0=D*(p-Z)`,
where the value of Z outside D=1 is immaterial. At delta_star, p=tau, so

    A = E[dU_0/ddelta] = pi_D*tau*(1-tau)/2,
    B = Var(U_0)       = pi_D*tau*(1-tau),
    V_root            = B/(N*A^2) = 4/[N*pi_D*tau*(1-tau)],
    inverse curvature = 1/(N*A)   = 2/[N*pi_D*tau*(1-tau)].

The inverse profile curvature is only half the root-centered Gaussian-limit
variance in this example. The discrepancy remains at delta_0=0, where root
centering is correct. Conversely, at any fixed nonzero delta_0, even the
matching root sandwich produces shrinking intervals around 2*delta_0, whose
truth inclusion tends to zero. Optimization error, covariance mismatch and
structural bias are three separate failures. `calc_facet_se()` supplies a
different conditional screening approximation, not this profile inverse;
no universal rescaling of its public fields follows from this example.

At finite N the probability that a finite unique root is unavailable is

    (1-P10)^N + (1-P01)^N - (1-pi_D)^N.

If only one discordant pattern is observed the optimum is an infinite
contrast; with neither pattern the profile is flat. These are retained
boundary/nonidentification outcomes, not datasets to redraw. V_root denotes
the covariance in the root-centered asymptotic normal approximation, **not
an exact unconditional finite-N variance** of an estimator that can be infinite.
The finite-root event tends to probability one for the stated fixed truth.
For comparison, conditioning on each Person's total gives
`delta_hat_C=log(n01/n10)` and a consistent target in this submodel. This
is an algebraic reference, not a newly implemented CML API or a proposal to
halve general PCM/GPCM estimates.

### What the finite-MLE correction operator does in this submodel

Apply the same mathematical rule `U_k=(I-P_delta)^k U_0` to this **fixed-slope
scalar** model. This is the operator used in `R/core-jml-adjustment.R`, also
distinguished from posterior averaging in
[Dhaene and Weidner, Section 8.1](https://arxiv.org/html/2301.13736v2).
The calculation does not represent a public corrected-RSM/PCM call: the public
route is shared-owner GPCM and includes free slope coordinates. It also
requires at least two observed levels in every declared facet, so a one-level
slope facet is not an admissible workaround for holding these slopes fixed.

Extreme patterns are absorbing and have zero U_0. On the nonextreme states
ordered (10,01), the transition submatrix is

    P_I = [[(1-p)^2, p^2], [(1-p)^2, p^2]],
    q = p^2+(1-p)^2,   r=1-q=2*p*(1-p),   P_I^2=q*P_I.

Induction then gives, for every nonnegative integer k,

    U_k = D*(F_k(delta)-Z),
    F_k(delta) = (1-r^k)*s(delta) + r^k*s(delta/2).                 (7)

In particular F_0=s(delta/2) is ordinary JML. For delta>0, r decreases and
`s(delta)>s(delta/2)`. Differentiating (7) gives

    F_k' = (1-r^k)*s'(delta) + r^k*s'(delta/2)/2
           - (r^k)'*[s(delta)-s(delta/2)] > 0.

The last term is nonnegative on either side of zero, and the first two have
positive sum. Also `F_k(-delta)=1-F_k(delta)`, with limits 0 and 1. Therefore
the population equation `F_k(delta_star,k)=s(delta_0)` has a unique finite root.
For delta_0>0 and finite k>=1,

    delta_0 < delta_star,k < 2*delta_0.

For negative delta_0 the inequalities reverse. Increasing k reduces this
root displacement in this special scalar example, but every finite order
retains nonzero displacement when delta_0 is nonzero. Close to delta_0=0,

    F_k'(0) = 1/4 - 2^(-k-3),
    delta_star,k = delta_0/[1-2^(-k-1)] + O(delta_0^3).

Thus the local root multipliers are 2 for order 0, 8/7 for order 2 and 32/31
for order 4. These are local population-root expansions, not finite-sample
bias percentages for the actual free-slope package estimator. The matching
Gaussian-limit variance in this scalar model is

    V_k = tau*(1-tau) / [N*pi_D*F_k'(delta_star,k)^2].

The complete derivative of F_k includes the parameter-dependent transition;
holding P fixed while differentiating would generally give a different result.
As k tends to infinity, F_k tends to s(delta) and the scalar root tends to
the conditional-likelihood target. This special limit supplies no general
free-slope GPCM convergence, variance improvement or order-selection rule.

**Verification and consequence.** Exact symbolic algebra with SymPy 1.14.0
verified `P_I^2=q*P_I`, the order-zero identity and
`(I-P_I)*[F_k,F_k-1]'=[F_(k+1),F_(k+1)-1]'`, treating r^k as a formal symbol.
The ordinary covariance ratio and the exact derivatives/local multipliers
for orders 0/2/4 were also checked. No floating-point sampling, optimization
or numerical differentiation was used. The general residual bound and
monotonicity arguments are analytic derivations, not automated proof certificates.
The source checks confirm the summed ordinary objective, the corrected
recursion/derivative contract and its model restrictions. No source or API
was modified and no saved fit was requalified.

These results close specific algebraic questions. Next numerical bridge work
can use (5) for admitted RSM/PCM fits after mapping their exact free coordinates;
GPCM still needs its own curvature and branch analysis. A structural truth
interval additionally needs a justified bias treatment or a proved centering
regime with its own covariance. More accurate ordinary optimization or merely
choosing a finite correction order cannot be the general inferential repair.

## Question and decision

Can the joint-curvature check added for portable GPCM JML justify formal
structural intervals? No. Three distinct requirements remain: identified
finite estimation, a sampling covariance appropriate to the stated target
and asymptotic regime, and adequate centering of the interval on the true
parameter. A local Hessian check addresses only part of the first requirement.
Fixed-calibration agreement with TAM/ConQuest cannot establish the other two.

This increment corrects a public help formula and makes those distinctions
explicit. It does not change estimation, standard-error calculations,
numerical cutoffs or scoring eligibility. Formal JML slope intervals remain
unavailable. The corresponding ordered completion criteria are in ROADMAP's
JML structural-inference milestone.

## Primary source and reading scope

Haberman, S. J. (2004). *Joint and conditional maximum likelihood estimation
for the Rasch model for binary responses*. ETS Research Report RR-04-20.
[Publisher record](https://www.ets.org/research/policy_research_reports/publications/report/2004/hytm.html),
[DOI](https://doi.org/10.1002/j.2333-8504.2004.tb01947.x),
[full report](https://files.eric.ed.gov/fulltext/EJ1110899.pdf).

All 69 PDF pages were read in page order through page-delimited text,
including front matter, printed pages 1-58, references 59-61 and appendix
62-63. Printed pages 26-29 were additionally rendered and visually checked
for the normal-approximation statements and covariance formulas. This is a
source review, not an independent proof verification; some proofs are omitted
in the report itself. No copy of the report is added to the package. Download
SHA-256: `66b13a8aef09ede41cac95e4151b2a36370f490d36a0c02bbc30d0e9ba93ae12`.

| Printed pages | Finding used here |
| --- | --- |
| 3-4 | Assumptions include complete binary Rasch responses, bounded parameters and independent Persons. |
| 7-13 | Extreme Persons obstruct a finite full JML vector; extended estimates require a separate interpretation. This does not make every structural parameter inestimable. |
| 13-24 | With fixed test length, structural JML may approach a biased limit as the Person count grows. |
| 25-29 | Normal approximation can be centered on that limit. Its covariance is not generally the ordinary inverse information; increasing test length introduces additional conditions. |
| 29-35 | Person asymptotics, residuals and misspecification have distinct requirements. |
| 35-54 | Rasch CML conditions out Person parameters; this does not provide a CML algorithm for the present free-slope GPCM. |
| 54-58 | Latent-distribution identification and the interpretation of JML/CML require care. |

These binary-model results do not qualify sparse many-facet GPCM. The
report's growth-rate conditions are not finite-sample package cutoffs. It
supplies no universal item-count correction for this free-slope implementation.

## Implementation audit and user-facing correction

`compute_response_probability_bundle()` in `R/core-likelihood.R` computes information
for the additive predictor as squared slope times conditional score variance.
`calc_facet_se()` in `R/mfrm_core.R` sums this information with observation
weights within each facet level. Thus its location approximation is

    SE_g = 1 / sqrt(sum_{r in g} w_r * a_r^2 * Var(X_r | fitted predictor))

with slope one in RSM/PCM. The previous `fit_mfrm()` help omitted weights and
squared slopes and used the overly broad label "SEs reported under JML".
It now identifies these as facet/location approximations conditional on other
fitted parameters, not slope SEs or a joint nuisance-adjusted covariance.
The existing `PrecisionTier`, `SupportsFormalInference` and `CIUse` safeguards
already label this output exploratory/screening-only; no duplicate warning
system or new API is needed.

The source check for portable GPCM JML evaluates the full local joint Hessian
but returns no inferential covariance. If Person parameters are denoted P
and structural parameters S, the candidate profile curvature is
`H_SS - H_SP solve(H_PP, H_PS)` where the required blocks are invertible on
the identified parameter space. This algebra does not establish that its
inverse is the sampling covariance for growing nuisance dimension, nor that
intervals cover true parameters. Regularization or fit-based SE inflation
cannot by itself resolve that centering problem.

## Evidence reused and remaining work

- [Portable JML qualification](portable-gpcm-jml-20260927.md) already checks
  independent joint likelihood, off-optimum gradients and mixed-direction
  curvature for two shared owners. Those checks were not repeated here.
- [External fixed scoring](gpcm-jml-external-scoring-20260927.md) uses actual
  JML calibrations in TAM/local ConQuest but holds the calibration fixed.
- [TAM/immer factor pilot](tam-immer-jml-factor-pilot-record-0.2.3.md) retains
  290 design cells with five replicates per condition, including failed and
  unidentified cases. Its unequal-exposure correction differences are a
  reason to define the estimator carefully, not a slope-coverage result.
- [Paired PCM/GPCM record](pcm-gpcm-jml-paired-calibration-record-0.2.3.md)
  contains six descriptive pairs, not a coverage study.

The next implementation gate is a derivation of covariance and bias treatment
for the existing shared-owner scope. Then evaluate Person count and exposure
separately, retaining failure denominators and Monte Carlo uncertainty. Merely
inverting the newly available Hessian would bypass this gate. A new large
simulation was not launched before defining its inferential target.

## Profile-information derivation and numerical check

A subsequent check makes the covariance work concrete without promoting it to
public inference. The [runner](jml-profile-information-20260927.R) reuses the
two saved shared-owner GPCM fits; it does not recalibrate structural parameters.
Their Person coordinates are unconstrained and unanchored, so profiling can
be done separately for each Person. This separation must not be assumed for
coupled Person constraints.

Let beta denote the identified free structural coordinates and let
`q_i(beta, theta_i)` be Person i's negative log likelihood. Define
`m_i(beta) = inf_theta q_i(beta, theta)` (allowing extended Person limits).
At a finite interior conditional
minimum with positive Person curvature, implicit differentiation gives

    d theta_hat_i / d beta = - H_ii^{-1} H_iS
    grad m_i = grad_S q_i
    Hess m_i = H_SS,i - H_Si H_ii^{-1} H_iS
    S = sum_i Hess m_i = H_SS - H_SP H_PP^{-1} H_PS.

The runner forms adjacent-category log probabilities independently, solves
each Person score equation by bracketing and a scalar root, and compares the
resulting profiled likelihood with this Schur complement. Package parameter
expansion is reused to preserve the exact identification. Four structural
directions at two step sizes check curvature; independent finite differences
of the per-Person profile contributions check the envelope gradient.

| Saved owner | Objective discrepancy | Envelope-gradient discrepancy | Maximum directional relative discrepancy | Inverse-block discrepancy |
| --- | ---: | ---: | ---: | ---: |
| Criterion | 0 | 1.16e-9 | 1.34e-7 | 1.67e-16 |
| Rater | 5.69e-14 | 1.69e-9 | 1.01e-7 | 1.95e-16 |

The inverse-block check verifies `solve(S) == solve(H)[S,S]`. All declared
checks pass. Person score residuals are below 2.2e-11; structural gradients
remain those of the retained near-stationary sources (at most 5.83e-5), not a
new exact structural optimum. These checks establish local differentiation
and parameter bookkeeping, not a global solution or sampling performance.

After mapping all four relative log slopes through their sum-zero Jacobian,
`sqrt(diag(J solve(S) J')) / sqrt(diag(J solve(H_SS) J'))` ranges from
1.090-1.305 for Criterion ownership and 1.100-1.288 for Rater ownership.
Both denominators account for other structural coordinates; the difference
is whether Person coordinates are treated as known. These are **inverse-
curvature scales**, not qualified SEs or a comparison with the package's
observation-table facet SEs. No slope confidence bounds are generated.

### Sampling covariance and its target

For an iid Person sampling regime with a fixed common response design, let
`psi_i(beta) = grad m_i(beta)` and let `beta_star` be the minimizer of the
expected profiled criterion. Under the differentiability, finite-moment,
identification and interior-solution conditions for a fixed-dimensional
M-estimator, a candidate covariance about `beta_star` is

    A = E[Hess m_i(beta_star)]
    B = Var[psi_i(beta_star)]
    Cov(beta_hat) approximately A^{-1} B A^{-T} / N.

Using total observed curvature S and centered profile gradients G gives the
empirical form `solve(S) crossprod(G) solve(S)'`. Equality to `solve(S)`
requires an information identity not supplied just by profiling. Centering
or sandwich scaling cannot replace `beta_star` by the true structural
parameter. This is a derivation of a candidate under stated assumptions,
not a new GPCM consistency or bias-correction theorem.

Both saved fits have N=14 Persons and 17 free structural coordinates. Their
centered profile-gradient matrices have rank 13, the maximum N-1 allows.
Thus they cannot qualify a nonsingular full 17-dimensional empirical
sandwich. Some contrasts can still have nonzero estimated variance; rank
failure alone is not proof that every contrast is inestimable. Increasing
N beyond 17 would remove this arithmetic obstruction only, not establish
adequate precision, independence, bias control or coverage. No arbitrary
minimum-N inference rule is introduced.

Fixed heterogeneous Persons, different assignment patterns and dependent
ratings need their own sampling design and covariance argument. In
particular, raw cross-products can include between-design mean-score
variation if the expected profile score differs across designs. A Person-
cluster label is not by itself a proof of robustness to selective assignment.

The finite profile runner refuses all-minimum/all-maximum Persons. For fixed
finite structural parameters and positive slopes, their extended profile
negative log likelihood has infimum zero as ability tends to the appropriate
infinity. That local fact does not resolve possible structural boundaries or
qualify the existing portable workflow to accept an infinite full JML vector.

### Consequence for the next implementation gate

Local nuisance-adjusted curvature and its identified log-slope transformation
are now checked for the two existing finite examples. Transfer to current
public points still requires the source/procedure and residual bridge above.
The **centering/bias treatment for the true relative-slope target** and
covariance/coverage checks under a declared sampling design remain open. The current
runner is retained as a regression oracle for that work, not added to the
public API or the CRAN test suite.

TAM's current [`tam.jml()` help](https://alexanderrobitzsch.github.io/TAM/reference/tam.jml.html)
describes B as supplied category loadings and `errorP` as item-intercept SEs;
it does not document a corresponding estimated relative-slope covariance.
Consequently, those SE columns are not a direct reference for this proposed
JML slope route. Existing TAM/ConQuest fixed-score comparisons retain their
original scope; neither engine was rerun here.

Evidence is under `validation-results/jml-profile-information-20260927-final/`:
source hashes, runner hash, full curvature/profile-gradient matrices, identified
slope transformations, summaries and session information. The earlier sibling
directory retains the first calculation, whose slope summary used only free
coordinates; the final version includes the constrained fourth slope too.
No source fit, numerical tolerance or statistical eligibility was changed.

## Exact centering check and correction decision

The [exact-response runner](jml-profile-bias-exact-20260927.R) asks whether
profiling Person ability leaves an unbiased structural estimating equation
at the known truth, and whether substituting estimated ability into a single
score-centering correction fixes it. This addresses the remaining centering
gate directly, without running a large recovery study or fitting a correction
whose target is not yet established.

### Design and accounting

There are two Raters, two Criteria and three ordered categories (0, 1, 2).
Rater locations are (.3, -.3), Criterion locations (-.4, .4), and the two
step-owner threshold vectors are (-.6, .6) and (-.9, .9). Relative slopes are
(exp(.25), exp(-.25)); ownership is either Criterion or Rater. The whole
adjacent-category predictor is multiplied by the slope, as in the package.

One or two conditionally independent ratings per Rater-Criterion cell gives
4 or 8 ratings per Person while holding the structural dimension at five.
The second condition is a mathematical repeated-response design, not evidence
that repeated ratings in practice are independent. Each case is evaluated at
fixed true abilities -1, 0 and 1; no normal ability distribution is assumed
or fitted. Sparse designs and ability-dependent allocation are not studied.

All response sequences are retained. Four ratings have 81 patterns. Eight
ratings have 6,561 ordered patterns, represented exactly by 1,296 within-cell
category-count patterns with their multinomial multiplicities. Both all-low
and all-high patterns contribute their probability mass and their exact
extended profile limit (zero negative log likelihood and structural gradient).
They are not deleted or replaced by artificial finite abilities. Profile
ability depends on category totals by slope owner, so only the distinct
conditional roots need solving.

The analytical negative-profile-log-likelihood gradient is checked against
central differences for every aggregated pattern. Its maximum discrepancy
is 7.77e-10; Person-root residuals are below 8.31e-13. Independent probabilities
match the package GPCM kernel within 2.23e-16. Total response probability is
one within 1e-12 in every case. With true ability held fixed, the expected
structural score is zero within 1.12e-15. These checks separate the profiling
effect from a probability, derivative or response-accounting error.

### Result and what the numbers mean

Write `g(y; beta)` for the negative profile-likelihood gradient and
`b(beta, theta) = E_{beta,theta}[g(Y; beta)]`. The one-step candidate uses
`g1(y; beta) = g(y; beta) - b(beta, theta_hat(y; beta))`. Both expectation
layers are finite sums here, including the extreme-ability limits. All
quantities below are evaluated at the true beta; no corrected estimator
has been fitted.

For the relative log-slope coordinate alpha, with slopes `(exp(alpha),
exp(-alpha))`, the fixed-ability-zero results are:

| Slope/step owner | Ratings per Person | E[g_alpha] | E[g1_alpha] |
| --- | ---: | ---: | ---: |
| Criterion | 4 | -.133343 | .012302 |
| Criterion | 8 | -.109085 | .006417 |
| Rater | 4 | -.138495 | .013429 |
| Rater | 8 | -.115976 | .005474 |

Across all 12 owner/exposure/ability cases, the raw log-slope score expectation
is negative, ranging from -.173556 to -.109085. It varies with ability.
The one-step adjustment reduces its absolute value in all checked cases but
leaves values from -.013204 to .014555, including sign reversals. Thus the
true beta is not a stationary point of the expected raw criterion, and the
one-step adjusted equation is not exactly centered either. The negative raw
component locally favors increasing alpha while other coordinates are held
at truth; this is not a determination of the jointly fitted limit.

These are estimating-equation means, **not parameter bias, standard errors,
RMSE or coverage**. Score size also depends on exposure and parameterization;
comparing unnormalized scores across lengths is not a bias-rate estimate.
Neither a unique pseudo-true limit nor a corrected root is established here.

A common positive multiplier c is separately ruled out as a relative-slope
correction: `(c*a_j) / geometric_mean(c*a) = a_j` under the package's
geometric-mean-one convention. Multiplying log slopes instead would change
ratios and is a different estimator with no validation supplied by the
classical item-intercept correction. The public help now states this distinction.

### Literature and implementation implications

Dhaene, G., & Jochmans, K. (2017). *Profile-score adjustments for incidental-
parameter problems*, working paper, version September 12, 2017.
[Author manuscript hosted by Yale](https://economics.yale.edu/sites/default/files/dhaene-jochmans.pdf).
All 20 pages, including examples, simulations, appendix and references, were
read in order using extracted page text; method pages 3-5 were additionally
rendered and inspected. PDF SHA-256:
`a8b43169bfa84a53e16b233da1fb78a9b4758d2fdc5ecebcc2b461afa89584b9`.

Pages 2-4 distinguish zero profile-score bias, bias independent of nuisance
parameters, and nuisance-dependent bias. The one-step subtraction examined
here corresponds to the latter case (with the sign reversed for negative
log likelihood). Pages 4-5 qualify the iterative argument and base uncertainty
on the adjusted score; pages 9-12 include extended binary limits and examples
where identification prevents exact correction. Pages 13-16 provide examples
and simulation qualifications, not a many-facet GPCM guarantee. No universal
convergence, bias-order or coverage claim is transferred to mfrmr.

The candidate to investigate next is model/design-specific profile-score
recentering, with the exact calculation retained as its oracle. It is not yet
selected for the public estimator. Before adoption, resolve adjusted roots,
identification and remaining parameter bias; evaluate the derivative of the
**adjusted** equation for sandwich covariance. An adjustment need not be a
likelihood gradient, so raw-JML Hessians, profile likelihood intervals, IC
rankings and ordinary likelihood-ratio tests cannot be inherited automatically.
Higher-order iterations require their own convergence and information checks;
vanishing estimating equations alone would not establish valid estimation.

Final evidence is in `validation-results/jml-profile-bias-exact-20260927-plugin/`,
with the first raw-centering calculation retained in the sibling directory
without `-plugin`. All conditions and adverse residuals remain in the tables.
No Monte Carlo sampling, free calibration, external engine run or change to
public estimation/interval eligibility occurred in this increment.
The count-pattern multiplicities were also checked to reconstruct all ordered
responses. Updated estimation help was regenerated, parsed, checked and rendered;
NEWS and ROADMAP were synchronized, and `git diff --check` passed. No whole-
package test suite was rerun.

## Population roots of the candidate correction

The [root runner](jml-profile-bias-roots-20260927.R) reuses the response space
above. A shared factory was extracted from the original exact-response
runner; all 12 retained raw/adjusted expectations reproduced within 1e-12.
Generating response probabilities are fixed at the original true structural
parameters, with true ability -1, 0, 1 having probabilities .25, .5, .25.
This distribution is a declared benchmark, not a population model estimated
by JML. The correction's inner expectations use each response pattern's
profiled ability at the candidate structural parameters, not the true ability.

For each owner/exposure design we solve the **five-dimensional** expected raw
or one-step-adjusted equation. Every structural coordinate is free under the
existing centering and geometric-mean conventions. These are population
estimating-equation roots: candidate large-N limits when a sample estimator
converges to the corresponding branch. They are not finite-sample estimates,
Monte Carlo bias estimates or proof of a unique/global probability limit.
All extreme response probabilities remain in the expectation.

### Solver accounting and numerical qualification

Three starts were fixed in advance: truth, neutral `(0,0,-.8,-.8,0)` and
opposing `(-.3,.4,-.3,-1.1,-.25)`. Newton/double-dogleg solves used function
tolerance 1e-9, parameter tolerance 1e-10 and at most 100 iterations. Of 24
initial attempts, 16 passed the separate residual/Jacobian review. The eight
unresolved attempts were all six four-rating raw-JML attempts, neutral-start
four-rating Criterion correction, and neutral-start eight-rating Criterion
raw JML. They are retained, not relabelled as successes or inestimable models.

For the seven raw failures, BFGS minimized the expected negative profile log
likelihood (500-iteration ceiling, relative tolerance 1e-12), followed by
Newton root refinement. The adjusted failure used Broyden with cubic line
search (150-iteration ceiling). All eight follow-ups passed. Across all
resolved attempts, the three starts agree within 2.75e-9 in every structural
coordinate. This demonstrates agreement under the tested combined workflow;
it does not make the original direct-Newton procedure initialization-robust.

Review requires score sup norm below 1e-7, Jacobian minimum singular value
above 1e-6, and agreement of central-difference Jacobians at step sizes 1e-4
and 5e-5 within relative 1e-5. Raw likelihood minima additionally have positive
curvature; failed raw roots were checked against independent finite differences
of the objective. These are numerical criteria for this benchmark, not a
statistical coverage rule. No parameter bound was treated as an estimated
infinite endpoint.

The first follow-up harness attempted a scalar-objective gradient using a
vector-valued Jacobian output size. It stopped with a length mismatch before
saving a follow-up result. The helper now uses the actual function output
length. That failure log is retained; completed initial attempts were reused.

### Point-estimation result

The first relative slope has true value exp(.25) = 1.284025; the other slope
is its reciprocal. All structural parameters are jointly solved here:

| Slope/step owner | Ratings | Raw root: first slope | Adjusted root: first slope | Largest absolute coordinate displacement, raw / adjusted |
| --- | ---: | ---: | ---: | ---: |
| Criterion | 4 | 4.739506 | 1.288533 | 2.354141 / .056878 |
| Rater | 4 | 3.336691 | 1.289889 | 1.355291 / .056389 |
| Criterion | 8 | 1.501156 | 1.269916 | .233662 / .017707 |
| Rater | 8 | 1.485156 | 1.271156 | .222214 / .016955 |

The last column compares the same five coordinates (Rater, Criterion, two
steps and log slope); it is a descriptive sup norm, not a standardized error
measure or RMSE. The full coordinate table and all initial/follow-up values
are saved. The candidate substantially reduces the displacement in these four
settings, but does not eliminate it. In particular, the eight-rating relative
slope remains slightly below truth. A nonzero limit displacement still matters
for coverage as intervals narrow with increasing sample size.

The maximum absolute antisymmetric Jacobian entry is .127-.162 for adjusted
roots, versus at most 1.50e-8 for the raw roots. Thus the adjusted equation is
not locally the gradient of a scalar objective in these coordinates. Its
sampling covariance needs the adjusted Jacobian and adjusted Person scores,
including the transpose of the inverse Jacobian; it cannot reuse the raw-JML
Hessian or claim ordinary profile-likelihood/LRT semantics. Numerical root
agreement is not qualification of this covariance.

### Disposition

This completes the intended small-design **root preflight**, including its
adverse numerical results. It supports further work on the candidate, not
adoption as a default, a bias-free estimator or a formally qualified JML
interval route. Finite-sample recovery, uncertainty, sparse/unequal assignment,
other populations, larger facet structures and scalable approximation of
expectations remain untested. Three starts do not prove global uniqueness.
The next gate is a sample-level solver/covariance implementation checked
against this oracle; further variations of this tiny benchmark alone would
not close that gate.

Evidence: `validation-results/jml-profile-bias-roots-20260927/` contains the
24 initial checkpoints, eight separate follow-ups, resolved coordinates,
start agreement, source hashes and session information. Only local validation
code and the roadmap/review record changed in this increment. No new exported
function, dependency in DESCRIPTION, production estimate, help promise or
NEWS feature claim is introduced.

## Initial help-only verification

The displayed formula was checked against observation tables from the saved
Criterion-owner JML fit, first with its unit weights and then with deliberately
unequal table weights. Both maximum SE discrepancies were zero. Neither calculation refits a model
or validates a weighted estimator. Source and capability help were regenerated, parsed,
checked and rendered as HTML. Logs are retained in the ignored directory
`validation-results/jml-inference-review-20260927/`. Whole-package tests and
external estimators were not rerun for this documentation-only change.

## Sample estimator and matching covariance (2026-09-27)

The [sample runner](jml-profile-bias-sample-20260927.R) now solves the candidate
one-step-adjusted equation on observed response frequencies. This advances the
methodology alongside the package integration review; it does not introduce
an exported estimator or change `fit_mfrm()` results. The retained exact-response
factory supplies Person contributions, and reproduces the previous raw and
adjusted per-pattern arrays within 1e-12. No new package dependency is added.

### Target, equation and sampling unit

Let `u_i(beta)` be the negative-profile-log-likelihood gradient for Person i,
including profiling their ability at each candidate structural parameter beta.
For the same rating design, the candidate contribution is

```
psi_i(beta) = u_i(beta) - E_beta,theta_hat_i(beta)[u_Y(beta)]
mean_i psi_i(beta_hat) = 0
A = derivative_beta mean_i psi_i(beta_hat)
B = mean_i (psi_i - mean(psi)) (psi_i - mean(psi))^T
V = inverse(A) B inverse(A)^T / N
```

The expectation covers **all** response patterns, with their multiplicities;
abilities are profiled anew for the generated patterns. Its generating ability
is the observed Person's fitted ability, not their simulated true ability.
Both that fitted ability and the expectation vary with beta in the numerical
Jacobian. Extreme all-low/all-high Persons contribute their exact zero limits;
they remain in the sample and the denominator. Observation rows are not
independent sampling units here. No ridge, symmetrization of A, pseudoinverse
or raw-JML information substitution is used to make covariance available.

This check samples independent Persons from the explicitly declared ability
mixture (-1, 0, 1 with probabilities .25, .5, .25). It studies the sampling law
of the estimating equation under that iid mixture, not inference conditional
on a fixed collection of heterogeneous Person abilities. The mixture is used
only to generate test data. It is not fitted or supplied to the estimator.
The sandwich targets variation around the candidate's population root under
regularity; it does **not** remove the residual displacement of that root from
the true parameter. Consequently these calculations do not qualify confidence
intervals for the truth. Exact enumeration introduces no Monte Carlo error in
the inner correction; scalable approximate expectations remain separate work.

The method motivation remains the reviewed 2017 Dhaene/Jochmans manuscript
([alternative university-hosted copy](https://www.princeton.edu/~erp/erp%20seminar%20pdfs/dhaene-jochmans.pdf)).
Its profile-score adjustment is a starting point, not a GPCM validity result.
The formula above and its implementation are assessed for this particular
estimating equation and declared sampling unit.

### Prespecified engineering cases and failures

The four existing owner/exposure designs are reused, with **one** 400-Person
sample per design (seeds 20260928–20260931 as integer RNG seeds, not dates),
2 raters, 2 criteria and 3 categories. Each Person has 4 or 8 ratings.
Raw and adjusted calculations use the same observed responses and two fixed
starts, neutral and opposing; no truth start or population-root warm start
is used. CSV response rows, empirical pattern frequencies and all attempts
are retained. This is an implementation check, not a four-cell coverage study.

Raw equations use BFGS likelihood minimization then Newton refinement; adjusted
equations initially use Broyden with line search. Initial sample roots pass
both-start review for 7/8 method/design combinations (15/16 individual starts).
The eight-rating Rater adjustment fails from the opposing start after 150
iterations (score norm .06825). Newton/double-dogleg from that **same** start
resolves the failure and agrees with the successful neutral start within
9.11e-11. This supports the tested fallback, not the original solver's robustness
or global uniqueness. Initial failed attempts and the nonzero initial exit
status remain in their original evidence files.

For the four-rating Criterion raw JML, the Jacobian is ill-conditioned
(`kappa(A)` about 36,810) and the estimated log-slope SE is 1.765. Empirical
frequency perturbations of 1e-4 and 5e-5 have influence-linearization errors
.01459 and .00355, exceeding the prespecified .001 relative tolerance.
Refitting at 1e-5 and 5e-6 reduces those errors below the **unchanged** tolerance
(maximum .000143). The covariance arithmetic is locally consistent, but this
large uncertainty and nonlinear response remain warnings about the example;
passing a smaller-step derivative check does not make its inference useful.

### Results and independent calculation checks

The first relative slope has true value 1.284025. Entries below describe these
single samples, not bias, RMSE or average correction benefit.

| Owner | Ratings per Person | Raw first slope | Adjusted first slope | Adjusted log-slope SE |
| --- | ---: | ---: | ---: | ---: |
| Criterion | 4 | 4.973086 | 1.243343 | .124339 |
| Rater | 4 | 3.329804 | 1.416967 | .110687 |
| Criterion | 8 | 1.322236 | 1.187053 | .054246 |
| Rater | 8 | 1.524772 | 1.297716 | .057497 |

In the eight-rating Criterion sample, adjustment moves the first slope
**farther** from truth. The reduction in the largest error across all five
coordinates does not negate that adverse slope result. These data do not
justify claiming uniformly improved estimation, smaller MSE or correct coverage.

After the two targeted follow-ups, all eight method/design cases pass:
expanded-Person versus frequency-aggregated scores and meat; covariance versus
independently expanded influence contributions; symmetry/positive definiteness;
zero extreme contributions; inverse-N scaling at fixed empirical frequencies;
refusal of rank-one empirical covariance; and actual perturbed-data root
refits at two step sizes. Both-start coordinate disagreement is at most 2.10e-9.
Adjusted Jacobians remain nonsymmetric (.114–.172 maximum antisymmetric entry).
Two Jacobian step sizes agree within the original relative 1e-5 tolerance.
The 1/N scaling check is an algebra check, not permission to treat duplicated
Persons as independent observations. Neither numerical agreement nor rank
review is coverage qualification.

### Integration disposition and next gate

The sample-level equation and matching covariance are now implemented and
numerically checked for this exact small response space. The stage is
**engineering evidence complete after targeted follow-ups; statistical
qualification open**. Before public adoption, specify the intended sampling
interpretation, residual-bias treatment, solver/failure policy and feasible
expectation calculation for longer/sparse/unequal designs. A repeated-sampling
comparison must evaluate failure-aware bias, empirical variation versus SE,
interval availability/width and true-value coverage with Monte Carlo precision.
Do not proceed directly from this sandwich to ordinary likelihood tests or
public formal JML intervals.

In parallel, the current-source portable-calibration public-API test file
passed, with its check-installed fresh-process test skipped in this source-load
run. The capability matrix, README, capability help, portable/GPCM tutorials
and NEWS agree on scoped JML EAP support and unavailable formal JML inference.
This is focused integration evidence, not whole-package completion; the final
installed archive and corresponding platform checks remain open. No runtime
estimator, public inference promise or NEWS feature is added by this research.

Evidence is in `validation-results/jml-profile-bias-sample-20260927/`: original
responses, starts, summary and results, the preserved original runner, separate
follow-up results/resolved summary, source hashes and session information. The
initial failures are not overwritten. The targeted public-API log is retained
there as `public-api-integration.log`.

## Paired repeated-sample decision (2026-09-27)

The [prespecified protocol](jml-sample-comparison-20260927.md) and
[runner](jml-sample-comparison-20260927.R) evaluate the adverse single-sample
Criterion-owner case above: 2 raters, 2 criteria, 3 categories, 8 ratings per
Person, 400 independently sampled Persons and the same three-point ability
mixture. There are 200 new, paired datasets; neither the earlier engineering
samples nor truth/root starting values enter the evaluation. This is a
one-design method-development comparison, not release qualification.

Both methods supply reviewed estimates and covariance in all 200 datasets.
The adjusted equation required its prespecified Newton fallback from one
original start in replicates 33 and 42; the original Broyden attempts are
retained. No fallback, tolerance or replication count was changed after the
run began, and no planned dataset was omitted. Two reviewed starts must agree.
These remain local numerical checks, not global-optimum certificates.

The primary target is relative **log slope**, with true value .25. The raw
reference and adjustment both use their own Person-level sandwich in this
research calculation. These are not the public package's existing exploratory
SEs, and the table does not describe a released formal JML interval API.

| Primary log-slope outcome | Raw profile JML | One-step adjustment |
| --- | ---: | ---: |
| Bias (MCSE) | .154730 (.005933) | -.012427 (.003805) |
| RMSE | .175912 | .055090 |
| Empirical SD | .083899 | .053804 |
| Root mean estimated variance (SE scale) | .090879 | .058318 |
| Mean 95% interval width | .354204 | .227814 |
| Truth inclusion | 124/200 = 62.0% | 193/200 = 96.5% |
| Wilson 95% MC interval for truth inclusion | 55.1–68.4% | 93.0–98.3% |
| Method-specific population-root inclusion | 191/200 = 95.5% | 193/200 = 96.5% |
| Interval availability | 200/200 | 200/200 |

The paired squared-error difference (adjusted minus raw) is -.027910, MCSE
.001992, with normal 95% MC bounds [-.031815, -.024005]. It satisfies the
prespecified criterion for reduced log-slope MSE **in this design**. All five
coordinate summaries and paired comparisons are retained; the other coordinates
are secondary, not additional prespecified primary tests. The earlier adverse
single-sample slope result is not removed or contradicted by an average benefit.

The raw truth-coverage upper MC bound is below .925, failing the declared
95%-inference criterion for this reference calculation. Its approximately
nominal population-root coverage, together with the previously measured
nonzero root displacement, supports bias as the main explanation in this
case rather than a broken sandwich implementation. This is not proof that
variance approximation never matters. The root-mean estimated variance, expressed on the SE scale, is about 8%
larger than empirical SD in both methods. Adjusted
truth coverage is compatible with 95% at this Monte Carlo precision; it does
not demonstrate exact calibration or universal coverage. Its residual bias
and population-root displacement persist and can matter as N increases.

### Decision and remaining scope

Retain the adjustment as a promising research candidate and its separate
sandwich as the matching variance implementation. Do not replace the public
JML estimator, publish formal JML intervals or extrapolate to sparse/unequal
exposure, other populations, many facet levels, anchors, weights or separate
slope/step owners. This result answers the declared finite question; no automatic
replication extension or new factorial grid follows it. The next method gate
is a justified residual-bias/sampling-target policy and tractable expectation
calculation for relevant larger/incomplete designs, with independent evaluation
of any changed procedure. Package integration continues separately.

All checkpoints, initial/fallback attempts, source/protocol hashes, sessions,
per-coordinate estimates/intervals, dispositions and paired summaries are in
`validation-results/jml-sample-comparison-20260927/`. Hashes stayed unchanged
through both workers and summary generation. Summed worker time was 947.301
seconds; workers ran concurrently, so this is not elapsed wall time. An
independent Python recomputation of bias, RMSE, truth/root inclusion and paired
MSE/MCSE from all exported rows agrees within 1e-12. No fitted case was rerun
for that aggregation check. Public help and NEWS continue to state that formal
JML slope inference is unavailable; this research creates no public feature claim.

## Method decisions before broader JML inference

The 200-dataset result does not make the one-step equation a consistent
estimator of the generating truth when ratings per Person stay fixed. The
existing exact roots already show nonzero displacement. If estimates
concentrate around that displaced root while interval widths decrease with N,
truth coverage can deteriorate even with a correctly implemented sandwich.
Increasing N or simulation replication does not remove this methodological
problem. Do not subtract the benchmark's known root displacement from user
estimates: that would use unavailable generating parameters/population information.

The next method work must settle these contracts before another broad study:

| Decision | Retained starting point | Required extension or rejection condition |
| --- | --- | --- |
| Sampling target | Current evidence samples independent Persons with one common complete rating design and fixed structural truth. The estimator is not given their generating mixture. | Define whether new incomplete rosters are fixed/stratified or sampled with Persons. Conditional means and between-roster variation must not be conflated in the meat matrix. Ability-dependent assignment is a different question; connectivity alone does not establish identification or accuracy. |
| Residual bias | One-step score recentering improves the examined finite-sample MSE but leaves a displaced population root. | Before general truth intervals, justify a bias treatment or a defensible restricted inferential scope. Further score-recentering is only a candidate: show that reducing mean score does not destroy rank/information or produce nearly zero equations everywhere. A narrower scope is not proof that bias vanishes. |
| Unequal/sparse assignments | Existing exact calculations enumerate one small common response space; a Person is the sampling unit. | Contributions and correction expectations must use each Person's actual assigned rows, shared parameter constraints and extreme-response limits. An unassigned rating must not be imputed to make enumeration convenient. Distinguish underidentified samples from failed numerical searches. |
| Scalable expectations and covariance | The present correction and its derivative use exact finite sums; no inner Monte Carlo noise is present. | An approximate correction must control value and derivative error, retain numerical randomness/settings, and address the extra approximation uncertainty. It cannot inherit the exact-sum covariance qualification merely by increasing the number of draws. |

The next implementation question is therefore a design-aware adjustment with
a justified bias/information tradeoff, rather than exposing the current small-
design solver through `fit_mfrm()`. The existing exact and repeated-sample
records remain reference evidence for any changed procedure; fitting cases
used to choose a new method are not its independent validation. This research
can progress alongside integration but does not delay fixes to admitted public
scoring/reporting workflows or make a general JML inference claim part of the
current release by implication.

## Design-aware iterations, sparse rosters and numerical approximation

The [method-development contract](jml-design-adjustment-20260927.md) and
[design-aware implementation](jml-design-adjustment-20260927.R) now extend the
sample equation to actual four-cell exposure vectors, including zeros for
unassigned cells. The previous exact/sample/comparison sources are unchanged.
This is excluded research code, not a new public estimator or formal interval.
The motivation is the previously reviewed Dhaene/Jochmans iterative adjustment.
The [author manuscript](https://jochmans.github.io/preprints/score%20adjustments/Dhaene-Jochmans%20adjscore.pdf)
also explicitly cautions that convergence of iteration does not guarantee
fixed-stratum-length consistency: an unbiased limit must retain information.
No general theorem from that paper is asserted for this GPCM.

### Residual bias: improvement is not monotone or complete

For a fixed roster, U_k = (I - P_beta)^k U_0 uses that roster's generated
responses and each generated response's reprofiled Person ability. The sample
fit never receives generating abilities, population mixture weights or true
structural coordinates. The population reference uses the earlier declared
mixture only to measure remaining displacement. Both are five-parameter roots,
with no structural coordinates held at truth.

| Design | Raw log-slope displacement | Order 1 | Order 2 | Order 4 |
| --- | ---: | ---: | ---: | ---: |
| Complete, eight ratings per Person | +.156235 | -.011049 | -.005072 | +.000760 |
| Sparse, two fixed five-rating rosters | +.611867 | -.013540 | -.019553 | -.005396 |

These are population estimating-equation displacements from true log slope
.25, not finite-sample bias or coverage estimates. In the sparse case order 2
has **worse parameter displacement** than order 1 even though its expected-score
sup norm is smaller. Reduced score norm cannot select correction order. At
order 4 the largest displacement across all five coordinates is .000760 in the
complete case and .006068 in the sparse case (order 1: .017707 and .038860).
Residual bias remains, particularly relevant as N increases at fixed exposure.

The minimum Jacobian singular value divided by score RMS is .15439/.14853
for complete order 1/4 and .12109/.11510 for sparse order 1/4. Thus these
examined roots do not show collapse of local information as the fourth
adjustment improves displacement. This is neither a proof for higher orders
nor a global-uniqueness certificate. All 16 planned population/sample/order
cases agree across two reviewed starts within 1.99e-10. Six original sparse
opposing-start attempts fail; their prespecified Newton fallback resolves them.
Both attempts remain in the evidence.

The 400-Person sparse sample also illustrates the limit of population results:
its first/fourth adjusted log slopes are .041711/.045680 (truth .25), with
matching fixed-roster SEs .099983/.105267. An improved population limit does not
make every realized estimate close to truth. These single samples are not
coverage replications, and no order is adopted on their basis. All five
coordinates, SEs and true-reference differences are exported in parameters.csv.

### Sparse and unequal allocation: matching covariance

The complete and sparse factories reproduce the earlier complete-roster
calculation for both slope owners, two exposure lengths and two parameter
points. Sparse rosters (2,1,0,2) and (0,2,2,1) use only assigned cells, with fixed
200/200 Person counts. No unassigned response is imputed. The derivative
includes the fitted Person abilities and the full iterated correction.

Independent Persons drawn within fixed roster strata use within-roster score
centering in the sandwich meat. Random roster sampling adds the between-roster
mean-score covariance. The implementation verifies this decomposition and
expanded Person influence covariance. These assumptions do not cover a design
conditional on a fixed, nonrandom vector of Person abilities, outcome-dependent
missingness, or shared random-rater dependence. Connectivity alone is not a
sufficient inferential condition. An isolated-cell design is correctly refused
for deficient covariance rank without a ridge or pseudoinverse.

An additional engineering sample uses four versus six ratings per Person,
with 240/160 Persons and exposures (2,1,0,1)/(0,2,2,2). Actual response rows
and Person counts are saved. Both orders initially fail the two-start gate:
neutral starts converge, whereas opposing starts and their first Newton
fallbacks drift to small slopes and reach the iteration limit. A
[targeted follow-up](jml-design-unequal-followup-20260927.R), declared after this
failure, retries the **original opposing start** with stepmax .25 instead of 1.
The iteration limit and acceptance tolerances are unchanged; no truth or
successful-root initialization is used. Both orders then agree with their
neutral roots within 4.25e-11. Initial failed attempts and their nonzero process
exit are retained in unequal.rds/log, separately from the follow-up.

In that unequal sample the order-1/order-4 log slopes are .251853/.247794 and
SEs .077863/.077852. Expanded influence covariance and analytic-gradient checks
pass. Actual within-roster frequency perturbations followed by refitting at
two step sizes agree with the derivative prediction within 1.20e-9 relative
error; the five-rating sparse case agrees within 1.21e-8. This supports the
local covariance calculation and the targeted solver repair, not broad
coverage or universal convergence. A generally adopted solver policy remains
an open decision; the original policy is not relabelled robust.

### Approximation: bounds for scores, derivatives and covariance

The expectation implementation generates probability columns in blocks and
uses count-pattern multiplicities. It avoids storing a full transition matrix.
It still enumerates the response count space and explicitly refuses more than
50,000 count patterns; this is **not** a scalable solution for arbitrary large
rosters or many facet levels. Block size 1 versus 16 produces matching scores,
and multiplicities reconstruct the full ordered response space.

The [approximation audit](jml-design-approximation-20260927.R) implements
unnormalised probability pruning with an omitted-mass bound propagated through
each iteration. The bound also propagates to centered finite differences at
the chosen step size. Finite-difference discretization is checked separately;
these are bounds on deterministic truncation, not Monte Carlo SEs. All examined
score/Jacobian discrepancies lie within the derived bounds (with the declared
floating-point allowance).

At the exact sample roots for orders 1 and 4 in both designs, omitted-mass
budgets 1e-3 and 1e-6 fail the declared derivative-error certification, while
1e-10 and 1e-14 pass. Passing same-root covariance discrepancies are at most
3.34e-8 relative to the exact calculation. **Failure to certify is not proof
of large actual error**: some rejected cases have small observed error but
bounds too loose for the tolerance. At very small budgets a sparse case drops
no mass at all; successful agreement is not evidence of useful acceleration.

The audit evaluates approximate covariance at exact roots, not approximate
estimator convergence or formal coverage. It adds no stochastic approximation,
measures no general speed gain, and does not transfer exact-space qualification
to a future Monte Carlo implementation. Before approximate fitting, retain a
smooth/reproducible expectation calculation, error control at the candidate
root and its Jacobian, and a policy for any added simulation uncertainty.

### Decision and remaining work

The three requested issues now have a connected research implementation:
iterated correction, actual-roster contributions and design-specific sandwich,
and controlled deterministic approximation checks. Engineering evidence passes
after the separately recorded unequal-roster solver repair. Residual-bias
elimination, a generally justified order/solver policy and scalable expectations
are **not resolved**. The next decision is how to select or restrict the
correction without using generating truth, with independently evaluated
performance and a declared exposure/population scope. Simply choosing order 4
or increasing sample size would not answer that question.

All results, failed/successful attempts, observed responses, source hashes,
parameter tables and checks are in
validation-results/jml-design-adjustment-20260927/. An independent Python
aggregation checks exported displacements and approximation bounds. No broad
simulation grid, whole-package test rerun, runtime API/default change, NEWS
feature, commit/push or publication is included. The previously frozen public
archive remains unchanged; this research does not inherit or alter its checks.

## Order sensitivity without generating truth

The [comparison implementation](jml-order-sensitivity-20260927.R) and
[method contract](jml-order-sensitivity-20260927.md) address the next decision:
can observed stability select a correction order without known truth? They
reuse the three saved sample datasets and reviewed roots from the preceding
increment. No new sampling simulation or population-root calculation is run.

### Paired comparison, not independent estimates

For orders k and l fitted to the same Persons, the difference's influence is
IF_l - IF_k. Its local covariance is the sum of those outer products divided
by N squared. The implementation retains within-roster centering for the fixed
allocation target, and verifies the equivalent expression
V_k + V_l - C_kl - C_lk. Adding the two marginal variances would omit the
substantial positive covariance in these samples. The calculation describes
variation about each method's estimating-equation root; it is not a validated
interval/test for the generating parameters or evidence that either root is
unbiased.

The research comparison requires aligned Person identities, strata, parameter
names and sampling targets, plus reviewed roots. It returns every coordinate
comparison and `selected_order = NA`, with no p-value, cutoff or automatic
stopping recommendation. Same-influence comparisons explicitly return zero
difference variance and an undefined standardized ratio. Invalid alignment,
mixed fixed/random targets and unreviewed roots are rejected.

| Design, order 1 to 4 | Log-slope change | Later estimate's SE | Paired difference SE | SE if incorrectly treated as independent |
| --- | ---: | ---: | ---: | ---: |
| Complete | +.008556 | .057407 | .002718 | .079742 |
| Sparse | +.003969 | .105267 | .005708 | .145182 |
| Unequal lengths | -.004059 | .077852 | .005326 | .110107 |

For the complete sample, this change is .149 times the later estimator's SE
but 3.148 times the paired difference SE. These are different comparisons,
not contradictory results. They are descriptive ratios, **not z-tests** with
an asserted normal calibration. Smallness relative to the estimator's SE alone
does not identify a negligible order effect or justify stopping. Nor does a
large paired ratio establish practical importance or prove a method's bias.

Log slope is not the only relevant coordinate. Across the retained pairs,
maximum change relative to the later estimator's SE is .354/.302/.510 for the
complete/sparse/unequal samples. The largest paired ratios are 9.581 for Step1
(complete, 1 to 2), 8.868 for Criterion (sparse, 1 to 2) and 8.470 for Step1
(unequal, 1 to 4). All five coordinates are retained; these maxima are not
multiplicity-adjusted significance results or independent hypotheses.

### Verification and method decision

Expanded Person influences reproduce each stored covariance. Difference
covariance agrees with the separate covariance/cross-covariance identity and
is positive semidefinite within numerical precision. Perturbing the same
sparse empirical frequencies for both orders 1 and 4, then refitting both,
reproduces the predicted change in their difference at two step sizes; maximum
relative discrepancy is 6.09e-8. Eight targeted refits replace a new simulation
study. Input/source hashes, saved comparisons and independent Python checks of
exported differences/ratios are retained under
validation-results/jml-order-sensitivity-20260927/. Previous research sources
and results are unchanged.

Adding the same coordinate displacement to all candidate estimates leaves
these difference-based summaries unchanged. This algebraic check is not a
new generated model or a sampling experiment; it shows why these summaries
alone cannot identify a common bias component. Agreement across examined
orders also gives no bound on unexamined orders or their limiting root. The
previously reviewed original paper's warning about fixed-length consistency
therefore still applies.

The resulting method decision is to **retain explicit research orders and
paired sensitivity reporting, without automatic order selection**. Do not
convert a small change, a nonsignificant test, a smaller equation residual,
or a stable Jacobian into a claim of bias elimination. An eventual adaptive
rule must name the target and loss/exposure scope, assess the whole selection
procedure independently, and account for selection in uncertainty evaluation;
it cannot inherit one fixed order's covariance as if selection had not occurred.
The present comparison does not solve that qualification problem. No public
runtime, help/NEWS feature, automatic stopping default, formal JML interval or
release claim is introduced by this increment.

## Exact expectations on owner totals

The next computational step changes the calculation, **not the correction
order or estimating equation**. The [derivation and check contract](jml-total-expectation-20260927.md)
and [implementation](jml-total-expectation-20260927.R) replace full response
count-pattern enumeration by a transition on the two slope-owner score totals.

Within an owner, the common ability factor cancels when conditioning on its
total score. Polynomial convolution computes total probabilities and conditional
cell-category counts. At a fixed pair of totals, the profiled ability is fixed
and the raw structural score is affine in the cell counts. Consequently its
conditional expectation can be calculated exactly in this smaller state space.
A recursion on these states reproduces each iterated correction. This is a
model-specific algebraic identity, not a Monte Carlo approximation or a generic
claim for every GPCM structure.

Crucially, the actual observed response score is retained for each Person;
only its correction expectation is compressed. Replacing observed responses
by conditional averages would remove within-total response variation and
change the sandwich meat. The implementation does not make that substitution.
Assigned exposure, zero/unassigned cells, extreme-score limits and the matching
fixed-roster covariance remain as in the previous implementation.

### Equivalence and larger-sample engineering check

Both owner conventions, four complete/sparse/unequal exposure patterns, two
parameter points and orders 0/1/2/4 were compared against the frozen response
enumeration. Every response score agrees within 3.68e-12. Independently grouping
full response masses at generating abilities -1, 0 and 1 verifies conditional
expectation invariance within the same tolerance. At the six retained sample
roots (three designs, orders 1/4), the maximum relative Jacobian discrepancy
is 2.62e-10 and covariance discrepancy 1.20e-9. This reuses the prior fitted
samples; it does not rerun their population or sampling studies.

A separately declared computational example uses 400 Persons and exposure
(8,8,8,8), giving 32 ratings per Person. Cell responses are drawn directly;
neither their generating abilities nor truth is passed to fitting. The old
factory refuses this 4,100,625-count-pattern space under its existing resource
guard. The total-state calculation uses 1,089 states and blocks transition
probabilities without constructing all response patterns.

| Explicit adjustment order | Reviewed starts | Log-slope estimate | Matching local SE | Two-start fitting seconds |
| --- | ---: | ---: | ---: | ---: |
| 1 | 2/2 | .246107 | .023962 | 10.683 |
| 4 | 2/2 | .246759 | .024042 | 15.238 |

The two-start differences are at most 1.34e-12. All initial attempts pass;
no fallback is needed in this sample. Independent central differences of the
profile criterion match its analytic gradient within 7.88e-10. Expanded Person
influence covariance and exact extreme limits pass. Actual empirical-weight
perturbations followed by refitting at two step sizes agree with the influence
prediction within 2.48e-9 relative error. Both fits and every structural
coordinate/SE are retained. These are engineering results from one sample,
not estimates of bias, RMSE, coverage or a new capacity guarantee.

On the same small eight-rating problem, three local evaluations of order 4
have median elapsed time .021 seconds for enumeration and .012 seconds for
total states. These short timings are environment-dependent, exclude setup,
and are not a general speed benchmark. The larger-sample timings above include
two starts and their Jacobian review, but exclude later perturbation checks.
They describe the tested initial implementation; the final cleanup does not
inherit a newly measured timing claim.

A subsequent single-Person input check reproduced an array-dimension defect:
R simplified its two totals to a vector. An explicit matrix shape repairs it.
One-Person extreme/non-extreme comparisons pass within 3.42e-13; invalid counts,
state-limit overflow and an unsupported pruning request are rejected. Removing
an unused variance calculation is the only other final cleanup. The initial
source is preserved, and focused comparisons produce identical outputs before
and after those repairs on the multi-Person complete/sparse/unequal and larger
inputs. Original run hashes and final source hashes are separately retained.

### Method decision and remaining boundary

Use exact owner-total expectations as the candidate computational route for
this research scope, rather than introducing stochastic expectations solely
to bypass response enumeration. No extra Monte Carlo variance term is needed
for this exact reformulation; numerical root/derivative accuracy still needs
its own checks. The earlier probability-pruning results remain separate
approximation evidence and are not silently used here.

The tested scope remains two fixed raters, two criteria, three categories,
shared step/slope ownership and conditionally independent responses. There is
a 5,000-total-state guard and explicit refusal of numerical mass underflow.
The total-state space can itself grow quickly with more slope owners; larger
facet counts, dependent/testlet responses and arbitrary designs are not qualified.
The single 32-rating sample does not qualify a statistical exposure range.

This resolves a concrete computational obstacle for the tested structure.
It **does not remove the remaining statistical bias, choose an order or qualify
formal JML intervals**. The active method gate is now statistical scope and a
prespecified fixed-order procedure (including its solver), evaluated independently
of method-development examples. Broader scalability should be reopened for a
specified roster/model need, not by automatically adding more timing cases.
No public runtime/default, NEWS feature, full package test or publication is
included. Evidence is in validation-results/jml-total-expectation-20260927/.

### General-input follow-up (2026-09-28)

The [general-input implementation check](jml-general-inputs-20260928.md) extends
the internal equation and covariance beyond this reference's fixed coordinates.
It includes arbitrary column/level labels, independent full-response checks
with three judges and four categories, and a two-roster observed sample with
matching roots and Person covariance. The subsequent internal runtime solver
retains explicit order, attempts and separate point/covariance outcomes, and
an internal adapter reuses native parameter tables. The public fit/output
contract remains unfinished. This computational extension
does not change the residual-bias findings, choose an order or establish wider
coverage. The earlier scope and timings above refer to their recorded source.

## September 30: structural target before computational optimization

The user requested that mathematical/statistical adequacy take priority over
further CRAN runtime work. The current public explicit-order fitting/output
route is documented in the general-input record; formal structural confidence
intervals and an automatic order rule remain unfinished. This review does not
withdraw that agreed work or present a local root covariance as its completion.

The [reconciliation script](jml-inferential-target-audit-20260930.R) joins the
saved exact population roots with the completed order study. All 400 datasets,
both orders and all five free coordinates are retained. Bias, empirical SD,
root-mean estimated variance, truth coverage and population-root coverage were
independently recomputed from exported per-replicate rows and agree with the
saved summaries within 1e-12. Original input hashes are unchanged. No response
generation, fitting, quadrature change or new inference test was performed.

The distinction that governs further work is beta_k* versus beta_0: the root
of the expected order-k equation versus generating structural truth. With
mean-equation derivative A and design-appropriate score variance B, the current
covariance has the form A^{-1} B A^{-T}/N. The implementation retains the full
nonsymmetric derivative and uses the transpose on the right; the actual Person
scores and within-roster centering match the fixed-allocation target. Its
mathematical target remains variation around beta_k*. It cannot remove the
displacement beta_k* - beta_0. Under a valid root-centered normal approximation,
nonzero fixed displacement and shrinking intervals cause truth coverage to
tend to zero at fixed per-Person exposure. This deduction is conditional on
those assumptions, not a newly observed finite-sample failure.

| Retained condition | Order | Log-slope root displacement | Displacement / local SE at N=400 | Observed truth coverage |
| --- | ---: | ---: | ---: | ---: |
| Criterion / unequal | 2 | +0.007734 | 0.1061 | 94.5% |
| Criterion / unequal | 4 | +0.001083 | 0.0151 | 93.5% |
| Rater / sparse | 2 | -0.010706 | 0.1157 | 94.5% |
| Rater / sparse | 4 | -0.007277 | 0.0769 | 94.5% |

All 20 coordinate/condition/order combinations have nonzero retained root
displacements. Their absolute displacement/local-SE ratios at N=400 range
from 0.0015 to 0.1858. These are oracle diagnostics for the saved generating
conditions, not statistics available to an analyst or proof of poor coverage
at N=400. The earlier N=1600 population calculation halves SE and doubles these
ratios; this is algebraic scaling, not 1,600-Person simulation evidence.
Observed truth coverage across the 20 combinations is 93–98%, with only 200
independent replicates per condition. It cannot certify a general coverage claim.

The retained paired log-slope MSE difference (order 4 minus order 2) is
-0.0001833 in Criterion/unequal (95% Monte Carlo interval
[-0.0003182, -0.00004835]) and +0.0005310 in Rater/sparse
([+0.0002449, +0.0008171]). Thus smaller population displacement does not give a
uniform finite-sample MSE improvement. Other coordinates remain in the audit;
these are retained paired comparisons, not newly selected superiority tests.
More iterations, a stable equation or selecting the smallest reported SE
cannot provide a justified default order from these findings.

Sections 1.2–1.3 of the previously reviewed
[Dhaene–Jochmans manuscript](https://jochmans.github.io/preprints/score%20adjustments/Dhaene-Jochmans%20adjscore.pdf)
were rechecked: their finite-order large-stratum argument is distinct from
fixed-stratum-length consistency and an informative limiting equation.
No theorem for this GPCM is imported by analogy. The current scope decision
therefore still needs a justified bias treatment or declared growth regime,
followed by evaluation of that exact procedure. Existing finite-condition
success does not justify silently changing the default or exposing formal CIs.

Audit outputs are under `validation-results/jml-inferential-target-audit-20260930/`:
all-coordinate table, retained paired MSEs, input hashes and session. The
authoritative order of remaining work is in the
[internal roadmap](internal-roadmap-0.2.4.md#ordered-work-and-reviewable-exit-conditions).

## September 30: covariance sampling target and finite-roster centering

Question: does the current covariance describe new independent Persons, or
new responses from the same Persons with their abilities fixed? This matters
because JML's absence of a parametric ability distribution does not identify
the repeated-sampling target of a sandwich covariance.

At a saved adjusted-equation population root, let U be one Person's actual
score vector, g the assignment pattern and a the generating ability. Write
m_g(a) = E[U | g,a], mu_g = E[U | g], and pi_g for the pattern proportion.
The law of total covariance gives three distinct population meats:

* Fixed abilities and assignment composition:
  B_response = sum_g pi_g E_a[Var(U | g,a)].
* New independent Persons, fixed assignment counts:
  B_fixed = B_response + sum_g pi_g Var_a(m_g(a)).
* New independent Persons and random assignment patterns:
  B_random = B_fixed + Var_g(mu_g).

All are evaluated at the same root and transformed by the same full,
nonsymmetric Jacobian: V = A^(-1) B A^(-T)/N. For the first comparison,
the fixed ability frequencies match the saved population masses, so the
limiting equation and derivative are the same. Arbitrary fixed abilities
could change both. The last two added matrices are positive semidefinite.
Neither is a bias correction, and neither is shared-rater random-effect
uncertainty. Random assignment here means joint sampling of Persons and
patterns; it does not impose independence between assignment and ability.

The current sample implementation centers within observed assignment patterns
for `fixed_rosters` and globally for `random_rosters`, matching the second
and third targets. The repeated-sample study drew full response patterns
from each roster's ability mixture, not from a fixed list of individual
abilities. The interpretation is therefore internally consistent. Section 2
of [Dhaene and Weidner (2023)](https://arxiv.org/html/2301.13736v2#S2) also
separates a specified conditional response model from an unrestricted
distribution of latent effects conditional on covariates. Their MLE plug-in
connection is in section 8.1; neither point makes its general inference
claims automatic for this GPCM. This is a targeted source recheck.

The existing `jml-inferential-target-audit-20260930.R` now reconstructs exact
response probabilities at the three generating abilities per roster and
uses the saved score vectors, roots and Jacobians. It reuses all 12 reviewed
corrected cases (both owners, both designs, orders 1/2/4), without simulation,
refitting or changing the original evidence. At every case, probability
normalization, ability-mixture reconstruction, total-covariance decomposition,
positive-semidefinite added components and stored covariance agree to 1e-12
absolute tolerance. Input/source hashes are retained alongside the output.

| Order | Ability-composition share of fixed-roster variance, range across 20 coordinates |
| --- | ---: |
| 1 | 0.00197%–0.09962% |
| 2 | 0.00103%–0.05336% |
| 4 | 0.0000871%–0.02675% |

These small shares in the retained conditions are not a bound for other
ability distributions or designs. The new CSV `sampling-decomposition.csv`
retains all 60 coordinate results, including response-only, ability and
assignment-composition terms; no coordinate was selected for a favorable
conclusion. These are population linearizations, not new finite-sample
coverage results.

There is a separate finite-roster normalization issue. With n_g iid Persons
in roster g, at a known fixed root and Sigma_g = Var(U | g), the implemented
sample-centered meat has expectation

    E[Bhat] = (1/N) sum_g (n_g - 1) Sigma_g,
    B_fixed = (1/N) sum_g n_g Sigma_g.

Multiplying each roster's centered cross-product by n_g/(n_g-1) would remove
this particular finite-sample deficit at a known root. It would not make a
fitted nonlinear sandwich unbiased, remove structural displacement or
establish confidence-interval coverage. The current asymptotic meat is
consistent with a fixed number of sufficiently populated rosters under the
usual independent-Person moment and regular-root conditions. With many tiny
rosters that argument cannot simply be reused. For example, n_g=2 halves
the expected within-roster centered cross-product relative to its population
target; the API's two-Person minimum is numerical, not statistical permission.

For the saved N=400 designs, applying the same saved Jacobian to E[Bhat]
gives coordinate variance ratios 0.994544–0.995227 relative to B_fixed.
This calculation is explicitly at the population root; it is not the
expectation of the fitted variance estimator in the 400 datasets. A divisor
change would address only this small normalization effect in those designs.
It cannot be used to close the residual-bias decision or explain all observed
SE/coverage differences. No numeric estimator or covariance change is made.

Public output now makes the repeated-sampling basis explicit in summary,
report and saved-result tables, and help explains the ability-population and
small-roster assumptions. Existing estimates and covariances are retained.
The remaining D1 task is structural-bias treatment or a justified exposure-
growth regime, followed by evaluation of the specified procedure. In
particular, the T^(-k-1) bias rate stated as Conjecture 1 in Dhaene and Weidner
is not a GPCM theorem; it cannot alone authorize formal structural intervals.

Verification of this change: the existing `jml-adjustment` and
`jml-public-workflow` test files pass without failures or warnings, including
the saved numerical reference, full-Jacobian covariance and report/export/
reopen checks. The updated Rd file parses and agrees with roxygen generation.
No whole-package check, simulation, Windows run or timing claim is added.

## September 30: exact centering loses identification; a conditional growth route

**Question and decision.** Can a further correction remove the remaining
structural displacement, using the observed responses without the generating
ability distribution? Exact conditioning on the vector of slope-owner totals
does remove the score mean. It does **not** identify all five structural
coordinates in the retained designs. It is therefore rejected as a complete
replacement for corrected JML. A design-preserving exposure-growth route is
specified below as the next mathematical candidate. Its primitive bias
expansion and finite-sample performance remain to be established; formal
structural intervals are still an unfinished requirement.

### An exact candidate and the information it discards

Fix a Person's assigned roster g and let S_c be the score total for slope
owner c. Under the implemented conditionally independent GPCM,

    p_beta(y | theta, g)
      = h_beta,g(y) exp{theta * sum_c a_c S_c(y)} / D_beta,g(theta).

The numerator h includes the location/step terms and, for aggregated repeated
responses, the multinomial multiplicity. Conditioning on the **vector** S
eliminates theta even when slopes are unknown:

    p_beta(y | S=s, g) = h_beta,g(y) / sum_{z:S(z)=s} h_beta,g(z).

This distribution is computable from the existing finite response spaces.
Its negative score is the original profile score minus its conditional mean
given S. This is a different equation from the finite MLE-plug-in correction;
no assertion is made that infinitely iterating that correction converges to
this conditional score.

An owner-location term b_c contributes exp(-a_c b_c s_c) to h. This is constant
within each conditioning stratum and cancels. Consequently the conditional
likelihood cannot estimate that owner's location contrasts. Centering the
locations does not recover this information. This is an algebraic invariance,
not a numerical eigenvalue threshold or a property of a particular ability
mixture.

There is also a broader, explicitly qualified obstruction. Suppose the finite
set of feasible weighted totals a'S has distinct values, as is generic for
free unequal slopes. A moment u(y,beta) that is centered for **every** ability
must satisfy

    sum_s exp(theta * a's) H_beta,g(s) E_beta[u | S=s,g] = 0

for all theta. Linear independence of the distinct exponential functions and
positive H imply E_beta[u | S=s,g]=0 in every stratum. Along a smooth parameter
direction that leaves this conditional distribution unchanged, differentiating
that identity gives a zero column/direction in the population moment Jacobian.
Thus a smooth, uniformly ability-centered moment construction cannot supply
a full-rank regular estimating equation in those directions. This argument
is local to generic slopes and the stated nuisance-uniform moment class. It
does not prove that every estimator under every restriction on the ability
distribution is impossible; equal/colliding weighted totals, distributional
assumptions and nonregular inference require separate arguments.

The **existing** sparse/unequal rosters expose another loss for Rater-owned
slopes. Rater 1 never crosses Criteria within a Person: its Criterion is fixed
within each roster. Conditional data identify the Criterion-location product
with Rater 2's slope, but cannot separate all the remaining scale components.
Writing slopes as exp(alpha), exp(-alpha), the transformation

    alpha' = alpha + t,
    CriterionLocation' = exp(t) * CriterionLocation,
    Step1' = exp(-t) * Step1,
    Step2' = exp(t) * Step2

preserves the conditional distribution for these Rater-owned rosters. The
Rater-owned location is already absent. For either ownership, if the other
facet's location contrast is zero, changing alpha and inversely rescaling
the two owner steps also preserves the conditional distribution.

The new repository-only
[check](jml-centering-identification-20260930.R) evaluates these claims in
the four saved owner/design conditions. It generates no observations and
fits no roots. Ability mixtures and count-pattern multiplicities are retained.
The zero-other-location case is a declared algebraic counterexample, not a
new sampling condition or an estimate from the saved data.

| Slope/step owner | Saved design | Conditional information rank, out of 5 | Rank with zero other-facet location |
| --- | --- | ---: | ---: |
| Criterion | Sparse | 4 | 3 |
| Criterion | Unequal | 4 | 3 |
| Rater | Sparse | 3 | 3 |
| Rater | Unequal | 3 | 3 |

Conditional probabilities agree with the independent response model at
abilities -4,-2,0,2,4; conditional score means and the explicit invariant
paths agree to at most 3.67e-15. Finite differences of conditional log
probabilities agree with the analytic scores within 1e-8. The full derivative
of the mean equation agrees with conditional score information to 6.05e-10.
The first check stopped because an anticipated rank of four also for Rater
ownership was false. The actual roster structure explains rank three; the
failed assertion and initial source are retained, and the final check tests
the explicit invariance rather than relaxing its numerical threshold.

### A precise growth condition, with its unproved premises exposed

The alternative keeps the existing full adjusted equation. Let every Person's
base cell exposures e_g be multiplied by an integer L, holding facet levels,
parameter dimension, roster proportions and ability distributions fixed.
The repeated responses must be conditionally independent. This is not an
argument for duplicating observations, treating dependent repeat ratings as
independent, or increasing facet levels and nuisance dimension with L.

For fixed beta at truth define U_k,L=(I-P_beta,L)^k U_0,L and
m_k,L(theta)=E_theta[U_k,L/L]. If K_L f(theta) is the expectation of
f(theta_hat(Y)) under that same conditional response model, the exact identity

    m_(k+1),L = (I-K_L) m_k,L

follows from iterated expectation. All-low/all-high responses keep the
implemented extended limits; they are not removed. A **sufficient conditional
argument**, not yet a theorem verified for this package, is as follows:

1. The normalized raw profile-score mean is O(L^-1) uniformly with the needed
   ability derivatives (through at least order 2k+2 on the relevant compact
   sets).
2. The plug-in expectation operator obeys a uniform weak-error bound
   `||(I-K_L)f||_(C^s) <= C/L * ||f||_(C^(s+2))` for the function class used
   at each step, with tail contributions negligible at the required order.
3. The normalized full mean-equation Jacobian stays nonsingular near truth;
   a nearby root exists and its linearization remainder is controlled.

Induction then gives m_k,L=O(L^(-k-1)) and local structural root displacement
O(L^(-k-1)). The operator bound, uniform derivative control and root remainder
are substantive outstanding premises. A scalar MLE variance of order 1/L
alone does not establish them. In particular theta_hat has infinite values
on extreme patterns; a naive assertion that its unconditional moments are
finite is invalid. Under bounded true abilities/parameters, category
probabilities bounded away from zero and independent repeated ratings, the
extreme-pattern probability decreases exponentially with L. Turning that
fact into the required uniform operator/tail bounds still needs proof.

A matching root-centered CLT and consistent full covariance are additionally
required. If, for each retained contrast, SE is of order (N L)^(-1/2), then
a sufficient growth restriction for the stated bias bound to be negligible
relative to its SE is

    sqrt(N L) * L^(-k-1) -> 0, equivalently N / L^(2k+1) -> 0.

For example the conditional sufficient restriction is N/L^5 -> 0 for fixed order 2,
and N/L^9 -> 0 for fixed order 4. These are consequences of the stated premises,
not validated rating-count cutoffs or a reason to select order 4. They are not
necessary when a leading bias coefficient vanishes; the actual requirement is
displacement/SE -> 0 for the contrast at issue. If a contrast
has a different information rate, use its actual covariance instead. Growing
the Person count alone at fixed exposure cannot satisfy this centering condition.

To check that this route does not already fail at the information premise,
the check constructs the full per-Person Fisher information at the generating
parameters, removes the Person coordinate by its Schur complement, and averages
over the **saved** roster-specific ability mixtures. Under independent
replication of each cell, this information grows exactly by L. All four saved
conditions have rank five, with minimum eigenvalues .22824--.29834 per base
exposure unit. Independent finite differences of complete-pattern log
probabilities agree with the joint information within 7.95e-11. This checks
the candidate design's information at the specified truth; it is not the
finite-exposure adjusted-root covariance, a CLT or evidence of global uniqueness.

### Additional correction candidate and its admission criteria

Once a leading displacement expansion has been justified for a fixed order,
an additional **design-preserving split correction** is implementable using
observed responses and the existing solver. Suppose its full-design root is
beta_L*=beta_0+C/L^r+D/L^(r+1)+o(L^(-r-1)), and two half designs have the
same coefficients and parameter interpretation. With a split specified
independently of responses, define

    beta_SP = [2^r beta_full - (beta_half1 + beta_half2)/2] / (2^r - 1).

The leading C term cancels; the next coefficient becomes
`-2^r D/(2^r-1)`. Coefficient equality is essential. Selecting a power r from
the observed best coverage, or rounding each cell count independently, is not
this procedure. In particular `r=k+1` depends on the unproved expansion above.
The source paper's split-panel theory concerns specified fixed-effect models;
it does not directly qualify the current corrected GPCM equation.

Each half must retain the same Persons, facet levels, identification, category
scale, roster proportions and normalized cell exposure; each fit must pass its
existing full equation/rank review. The observed-data influence is the same
linear combination of the three **aligned Person influences**. Its covariance
must retain their cross terms, e.g. `crossprod(IF_SP)/N^2` with the declared
roster centering. Adding three separate variances or reusing the full fit's
covariance is not a justified finite-sample implementation. A failed half-fit
means an unavailable corrected result; keep all input datasets in accounting.

The current rosters are 2:1:0:2, 0:2:2:1, 2:1:0:1 and 0:2:2:2. Only the last
can be divided into two identical integer cell rosters. **Neither whole saved
design passes this proposed exact-split prerequisite.** This does not rule out
every generalized jackknife, but it prevents applying this candidate to the
existing 400 JML datasets by a convenience split. No such refits were run.

The next bounded gate is to establish the operator/expansion bounds for a
fixed-dimension exposure family, then check the predicted displacement rate
and full covariance under that exact family before any new coverage study.
Any split implementation must first demonstrate source/Person/design alignment,
equal-half eligibility, paired influence agreement under perturbation, and
unchanged failure accounting. Independent coverage evaluation must address
all promised coordinates, availability and Monte Carlo precision; a lower
population bias by itself is insufficient. No automatic order, new public
interval, scope withdrawal or independent large study is introduced here.

Primary-source checks were focused: Dhaene and Weidner's
[Sections 3, 4 and 8.1](https://arxiv.org/html/2301.13736v2) distinguish
informative nuisance-free moments, a conjectured higher-order rate and the
MLE-plug-in operator. Dhaene and Jochmans'
[profile-score manuscript, method and identification discussion](https://jochmans.github.io/preprints/score%20adjustments/Dhaene-Jochmans%20adjscore.pdf)
separates small moment means from information. Their
[split-panel paper, Sections 2, 3 and 5](https://jochmans.github.io/publications/spj/spj.pdf)
requires compatible subpanel expansions and discusses remaining bias terms.
The GPCM factorization, rank/invariance calculation, conditional growth lemma
and admission decisions above are this review's derivations, not claims that
those papers prove this package's inference.

Evidence is in `validation-results/jml-centering-identification-20260930-final/`:
all eight conditional-rank cases, four growth-information cases, split
eligibility, inputs/source hashes, source snapshots and session. The initial
failed check and follow-up logs remain in the sibling unsuffixed directory;
the intermediate successful conditional check retains its own source. No
package estimator, acceptance threshold or covariance was changed. The
separate frozen 400-case adaptive-MML process continues unaffected.

## September 30: fixed-block expansion and an exact expectation check

**Bounded execution specification, before the all-case calculation.** Reuse
the four saved owner/design settings and both rosters in each. Multiply every
cell exposure by L=1,2,4,8,16, keeping the five coordinates and the saved
roster-specific ability values/proportions fixed. Evaluate exact owner-total
score means at the generating parameters for correction orders 0,1,2 and
all five coordinates. No responses are generated, no population/sample roots
are solved and no sampling covariance or interval is inferred from conditional
mean scores. Compare L*m_0 with the derived raw-score coefficient b_1 and
L^2*m_1 with the derived one-step coefficient -D_1 b_1; retain the scaled
order-2 mean L^3*m_2 without a fitted coefficient or selected rate. Include
all extreme-state probability mass and every planned roster/ability.

The maximum state space is 8,385; the existing blocked transition computation
is used with an explicit 10,000-state ceiling and no pruning. A largest-roster
L=8 pilot with 2,145 states took .67 seconds. Quadratic state-count scaling
suggests roughly 1--2 minutes for the 40 expectation cases on one process;
this is a planning estimate, not a hard bound. The pilot exposed only a
data-frame row-name warning, corrected before the final run. Its source,
result and warning log remain separate. The reference expectation helper
adds the already-computed total-specific ability profiles, with infinite
extended endpoints, to its return value; existing calculations are unchanged
and will be compared against its saved previous source at L=1.

### Fixed-block argument and the first bias coefficient

The useful question is whether an explicit correction order can make the
remaining structural bias negligible relative to sampling uncertainty when
each Person supplies more information. It is not whether a smaller equation
residual certifies an interval. The following argument is for a **fixed** finite
roster with conditionally independent responses, fixed structural dimension,
positive slopes bounded away from zero, and structural parameters and generating
abilities in compact sets. It does not cover increasing facet dimension,
arbitrary within-Person dependence, or unbounded ability distributions.

For one base block X of the specified roster, write its probability as

    p_beta,theta(X) = exp{theta T_beta(X) + H_beta(X) - psi_beta(theta)}.

Here `T_beta = sum_j a_owner(j) Y_j`, and H contains the location/step terms.
L independent copies of the block multiply each cell exposure by L. At fixed
beta, put `mu=psi_theta`, `I=psi_theta,theta > 0` and
`kappa_3=psi_theta,theta,theta`. For an interior observed mean total, the profile
ability is `theta_hat=mu^{-1}(T_bar)`. The all-minimum and all-maximum patterns
have extended profiles minus/plus infinity. They have positive probability at
every finite L: **do not take an ordinary finite expectation of theta_hat**.
The profile score and its corrections are zero at those absorbing patterns.

For smooth functions with controlled endpoint growth, the plug-in operator
`K_L f(theta)=E_theta[f(theta_hat)]` has the local expansion

    K_L f = f + D_1 f/L + O(L^-2),
    D_1 f = f''/(2 I) - kappa_3 f'/(2 I^2).

This follows by expanding `f(mu^{-1}(T_bar))`, using
`Var(T_bar)=I/L`, `(mu^{-1})'=1/I` and
`(mu^{-1})''=-kappa_3/I^3`. Two exact identities, including the extended
endpoints, are `K_L mu=mu` and `K_L mu^2=mu^2+I/L`. The numerical check below
uses these identities and independently checks the interior profile equation.
These witnesses check signs and normalization; they alone do not prove the
operator expansion for an arbitrary function.

The leading score coefficient must also account for **beta-dependent T**;
omitting that dependence would give the wrong slope calculation. With all
quantities below evaluated at the generating beta and theta, define the
block logit derivative `D=partial_beta(theta T_beta+H_beta)`,
`A=Cov(T,D)`, and `C=E[(T-mu)^2 (D-E D)]`. Let U_0 be the **negative** profile
score, in the same sign convention as the research implementation. Then

    m_0,L(theta) = E_theta[U_0/L] = b_1(theta)/L + O(L^-2),
    b_1 = C/(2 I) - A kappa_3/(2 I^2).

For completeness, write the normalized score as
`psi_beta(theta_hat)-theta_hat T_bar,beta-H_bar,beta` and expand around theta.
The first-order profile displacement has mean `-kappa_3/(2 L I^2)` and
second moment `1/(L I)` on the central event. The covariance term from
`theta_hat T_bar,beta` is `Cov(T,T_beta)/(L I)`. Using

    psi_beta,theta - E T_beta = A,
    partial_beta I = 2 Cov(T,T_beta) + C

cancels that last term and yields b_1. This expansion concerns the score,
whose endpoint values are defined; it does not assume that the untruncated
profile displacement itself has finite moments. The implementation checks
the second identity by finite differences of I, separately from the cumulant
calculation of b_1.

There is a concrete way to control the expansion remainder for this restricted
family. The empirical block category frequencies are averages of bounded,
finite-support independent vectors. On a fixed neighborhood of their generating
means, the profile score divided by L and the inverse mean map are smooth,
with uniformly bounded derivatives of every required **fixed** order. Taylor
expansion there expresses expectations in central moments of sample means;
these moments are polynomials in 1/L, with smooth cumulant coefficients.
A smooth cutoff inside a larger neighborhood makes the expansion global
without changing the central calculation. Concentration gives exponentially
small probabilities for its complement, uniformly over the specified compact
parameter/ability set.

Endpoint control is essential in that argument. Any finite observed mean total
is at least `a_min/L` from an extreme total. The inverse exponential-family
mean map therefore has magnitude O(log L) there, uniformly on compact beta
sets. The normalized raw score is at most O(1+log L), and the Markov operator
bound gives `||U_k/L||_infinity <= 2^k ||U_0/L||_infinity` for fixed k.
Exponential tail probabilities dominate these bounds. A fixed number of
theta derivatives of an L-block probability introduces at most polynomial
factors in L. Taking the Taylor expansion to a sufficiently higher finite
order controls these derivatives too. This supplies the locally smooth
mean expansions needed below; it is not a uniform-in-k argument or the
earlier proposed sharp bound using only two additional derivatives. Nested
compact neighborhoods handle any fixed number of operator compositions.

For the implemented recursion `U_k=(I-P_beta,L)^k U_0`, iterated expectation
gives exactly `m_k+1,L=(I-K_L)m_k,L`. Applying the smooth expansions to this
identity yields, for fixed k in the stated family,

    m_k,L = (-D_1)^k b_1 / L^(k+1) + O(L^(-k-2)).

In particular, the one-step coefficient is `-D_1 b_1`; it is evaluated below
using two theta finite-difference spacings and Richardson refinement. The
order-2 numerical results retain `L^3 m_2` without claiming that its coefficient
was independently evaluated. The recursion and fixed-block expansion explain
the power for score **means**. They do not by themselves locate a structural
root, prove that the solver selects it, or establish a sampling covariance.

### Complete numerical result and the targeted slow-convergence check

The 40 planned cases completed in **31.418 seconds** of summed elapsed case
time, retaining 1,800 coordinate/ability/order means. All checks passed:

- All original-exposure values from full response-pattern enumeration agree
  with the total-state computation to the required 1e-10 tolerance for all
  eight owner/design/roster combinations and orders 0,1,2.
- At L=1, every old return field is identical to the saved previous helper
  for all those cases and orders. Only `total_theta` is added.
- The maximum independently checked profile-mean error is 1.21e-12; the
  b_1 derivative/cumulant identity differs by at most 2.24e-11. The maximum
  change in the one-step coefficient between theta spacings .002 and .001
  is 6.46e-8, below the fixed 2e-6 threshold.
- No total states were intentionally omitted, no correction order was
  selected from these results, and no root/covariance/coverage was fitted.
  These are finite floating-point sums with unpruned state spaces, not
  symbolic exact arithmetic or a certified bound on floating-point error.

Maximum absolute errors against the leading coefficients, across all 120
coordinate/ability/roster values at each L, are:

| Exposure multiplier L | `abs(L m_0 - b_1)` | `abs(L^2 m_1 + D_1 b_1)` |
| --- | ---: | ---: |
| 1 | .097085 | .246842 |
| 2 | .083979 | .301773 |
| 4 | .067686 | .159041 |
| 8 | .030443 | .028552 |
| 16 | .013227 | .030379 |

Convergence is visibly **not monotone**. The largest remaining one-step error
at L=16 is Criterion ownership, unequal design, roster 1, ability 2, log slope.
Before extending that case, its reason and two additional multipliers (32,64)
were recorded in a separate runner. All three saved abilities, five coordinates
and orders 0,1,2 for that roster were retained; none of the original cases was
replaced. The explicit ceiling became 50,000 states, with 49,665 at L=64.
The prospective timing comment used 1.05 seconds for L=16; the saved matched
case actually took .877 seconds. The conservative 15/250-second projections
are retained as written. Actual L=32/64 times were **6.719/70.095 seconds**.

For the coordinate that triggered the extension, the predicted one-step
coefficient is .14691115:

| L | `L^2 m_1` | Absolute coefficient error | Probability of either extreme pattern |
| --- | ---: | ---: | ---: |
| 16 | .17728989 | .03037874 | 5.34e-6 |
| 32 | .15942983 | .01251869 | 2.85e-11 |
| 64 | .15269200 | .00578085 | 8.10e-22 |

Those are also the largest one-step errors among all 15 retained coordinates
and abilities of that roster at each of the additional multipliers. Thus the
slow case approaches the coefficient when exposure increases, while the first
grid alone would not justify assuming an already accurate asymptotic regime.
This roster has four ratings per base block, so L=32/64 means 128/256 ratings
per Person, **not** a validated practical minimum. Order-2 scaled means in the
same coordinate change sign across the grid; they do not establish a uniformly
better finite-exposure order. Retain all of them rather than selecting a
favorable range. No larger grid is needed to make the present decision.

### What this closes, and the remaining structural-interval gate

This closes the explicit leading score-mean calculation and its bounded
numerical falsification check for the fixed-block family. It strengthens the
exposure-growth argument beyond borrowing a conjectured power from another
model. A near-truth population root additionally needs a uniformly regular
**two-argument** mean equation (evaluation beta versus generating beta) and
a nonsingular local Jacobian. Under those conditions the implicit-function
expansion transfers the score power to root displacement. The saved rank-five
Schur information is evidence for the limiting Jacobian at the specified truth;
it is not a check of the complete finite-L adjusted-equation Jacobian.

With independent Persons, a root-centered CLT and a consistent full Person
covariance of order 1/(N L), the sufficient centering restriction remains
`N/L^(2k+1) -> 0`. It is conditional on that covariance rate and the root
argument, not a required lower bound on the number of ratings in practice.
The actual contrast-specific displacement/SE is the relevant quantity, and
a vanishing leading coefficient can weaken the sufficient rate. A compact
ability assumption used here must not silently become a guarantee for the
package's arbitrary Person populations.

The next decision is therefore the local structural root and **full response**
covariance in this same family: derive their matching expansion, reuse the
saved original-exposure roots/covariances, and check displacement/SE and the
entire Jacobian before planning independent sampling validation of a fixed
procedure. The conditional means used here discard within-total response
variation and must not be inserted as sandwich contributions. Solver branch,
all-coordinate availability and failure accounting remain part of that later
validation. Neither formal intervals, automatic order selection, a split
implementation nor a withdrawal of the promised structural target is delivered
by this score-mean result. D1 remains open.

The derivation above is specific to this review's finite exponential-family
representation. The previously linked primary papers motivate the iterative
operator and the distinction between centering and information; their results
are not relabelled as a GPCM theorem. No package estimator or public API was
changed. The helper and new runner are research-only code.

Evidence: `validation-results/jml-exposure-expansion-20260930-verified/`
contains all 40 cases, input/source hashes, source snapshots, `means.csv`,
completion checks and the R session. The initial pilot, warning log, old helper,
full-run log and prospective follow-up runner remain in the unsuffixed sibling
directory. The `-followup/` directory contains the two additional cases and
their own manifest/source snapshots. After the 40-case run, the runner's
hard-coded 10,000 ceiling was made an optional argument with the same default
for the targeted extension. Its separate source identity is retained; do not
attribute the original run to that later source or overwrite either manifest.

Final artifact reconciliation verified the snapshot hashes, every case's
declared source identity and all 1,890 saved means. The only working-source
change relative to the 40-case manifest is the documented ceiling argument;
the follow-up manifest matches its working sources. Both research R files
parse and `git diff --check` passes. An initial broad log scan mistakenly
matched the printed column name `LeadingError`; inspecting that match and
restricting the scan to R diagnostic prefixes found no warnings/errors in
the final all-case log. No statistical calculation or result was changed
in response. No full package suite was rerun for these research-only changes.

## October 1: local population roots and full response covariance

**Prospective bounded calculation.** The next question is whether the fixed-block
score-mean result transfers to structural-root displacement and matching
uncertainty in the same saved designs. Reuse the eight original-exposure
population roots for both owners, both designs and orders 1 and 2. First
reproduce the full generating mean, Jacobian and fixed-roster covariance,
including comparisons away from the generating parameter. Then evaluate
L=2,4,8,16 with the same two saved starts, solver fallbacks and numerical
review thresholds. Keep all five coordinates and all failures. No new sampled
responses, coverage study, automatic order selection or public interval is
part of this calculation. N=400 is a reference for the bias/SE comparison;
the Person count is not used to choose a correction order.

Full response covariance requires within-total variation as well as variation
of the conditional score mean. The new research calculation carries first
and second moments of four cell totals and four middle-category counts through
the generating probability convolution. These generating moments stay fixed
when the evaluation parameter changes. The existing plug-in correction and
ability profiles are still recomputed at the evaluation parameter. No
conditional mean is passed off as an observed response pattern.

The maximum total-state space remains 8,385 with a 10,000-state ceiling.
The original-exposure reconciliation is the first gate. An L=8 Criterion /
unequal / order-2 pilot will measure the full two-start/root/covariance cost
before all 32 new cases run. The earlier expectation costs suggest minutes
rather than hours, but do not measure repeated root evaluations; the actual
pilot cost will determine the all-case estimate. Use one R process while the
separate frozen 400-dataset MML replay continues.

**Cost decision after the pilot, before the remaining roots.** All eight
original-exposure reconciliations passed. The complete L=8 pilot took 28.269
seconds with both starts reviewed and agreeing. Quadratic total-state scaling
would put an L=16 case near 7 minutes and the eight such cases near one hour,
before allowing for different solver iterations. Stage the calculation at
L<=8 first: 32 cases in total, including the eight reused original roots and
the completed pilot, with roughly 5--8 minutes estimated for the remaining
cases on one process. The eight originally listed L=16 cases remain explicitly
unexecuted pending the lower-grid decision; they are not successes or deleted
failures. This limits cost while directly testing the root/covariance question.
The stage runner and its source hash are retained separately from the unchanged
mathematical runner/manifest used by the preflight and pilot.

### Transfer from a small mean score to a nearby structural root

Separate the evaluation parameter beta from the generating parameter beta_0.
The roster-specific generating ability distributions F_g and roster proportions
pi_g remain fixed during evaluation. For one block and true ability theta,
let t_beta(theta) solve

    mu_beta(t_beta(theta)) = E_beta0,theta[T_beta(X)].

In a neighborhood of beta_0 this solution is smooth and remains in a compact
interior set under the previous section's conditions. It equals theta at
beta_0. The population limit of the normalized negative profile score is

    v_g(beta,theta) = [partial_beta psi_beta(t)
                      - E_beta0,theta D_beta(X;t)] at t=t_beta(theta).

The structural partial derivative holds t fixed. At beta_0, v_g is zero.
Differentiating the profiling equation shows that
the derivative of v_g there is the Schur information

    J_g(theta) = I_beta,beta - I_beta,theta I_theta,theta^-1 I_theta,beta.

All four blocks in this matrix refer to the joint, generating **one-block**
likelihood. The fixed design averages to
`J = sum_g pi_g integral J_g(theta) dF_g(theta)`. J must be positive definite;
the prior independent information calculation verifies this at each of the
four retained generating settings. Positive definiteness at these points is
not global identification of arbitrary sparse designs.

The same central-event Taylor argument used above applies smoothly in both
evaluation and generating parameters. The plug-in adjustment is O(1) before
normalization, together with its local evaluation-beta derivatives, for each
fixed correction order. Consequently the complete normalized mean equation

    G_k,L(beta) = sum_g pi_g E_beta0,Fg[U_k,L(Y;beta)/L]

converges locally, with its first derivative, to the averaged v_g. In
particular `G'_k,L(beta_0)=J+O(L^-1)`. At the generating beta, the preceding
score expansion gives

    G_k,L(beta_0) = c_bar_k/L^(k+1) + O(L^(-k-2)),
    c_bar_k = sum_g pi_g integral (-D_1,g)^k b_1,g(theta) dF_g(theta).

A nonsingular J and local smooth convergence give a unique root in a
sufficiently small neighborhood for all sufficiently large L, with

    beta*_k,L - beta_0 = -J^-1 c_bar_k/L^(k+1) + O(L^(-k-2)).

This is a **local** result in the fixed-block family. It does not say that
there are no distant roots, that a finite-L numerical solver reaches this
branch, or that a given number of ratings is sufficiently large. The two
declared starts and the complete nonsymmetric finite-L Jacobian are therefore
retained in the numerical check. The k=1 leading displacement vector is
computed independently from the previously derived `-D_1 b_1` and the saved J;
k=2 retains its scaled displacement without a separately evaluated coefficient.

### Matching covariance and the centering condition

At beta_0, the leading random part of a Person's adjusted score is the sum
over its L blocks of the efficient negative score

    xi_g(X,theta) = -(D_beta - E D_beta)
                    + I_beta,theta I_theta,theta^-1 (T - mu).

Its conditional mean is zero and its conditional covariance is J_g(theta).
The profile Taylor remainder and each fixed-order correction have bounded
second moments of order O(1) in the compact family. At the nearby population
root, the additional shift also has this order or smaller. Thus for the
unnormalized complete equation and fixed roster counts,

    A_L/L -> J,     B_L/L -> J,
    V_L = A_L^-1 B_L A_L^-T / N,
    N L V_L -> J^-1.

Here `B_L=sum_g pi_g Var_beta0,Fg(U_k,L | roster g)` includes both response
and ability-mixture variation. Fixed roster counts exclude only variation in
the proportions of the rosters. The equation's A_L is its full derivative,
not a symmetrized approximation or a Hessian of a convenient likelihood.
The population sandwich V_L is a root-centered asymptotic covariance; it is
not an exact finite-N sampling variance.

For independent Persons, fixed positive roster proportions with every roster
count tending to infinity, and a consistent local root, bounded higher moments
in this family give the triangular-array root-centered CLT and consistency of
the matching empirical Person sandwich. Both N and L must grow. Combining
this with the local root expansion gives the sufficient truth-centering
condition `N/L^(2k+1) -> 0` when a leading bias coefficient is nonzero.
For any named contrast, its actual displacement relative to its standard
error is the quantity to check; a vanishing leading coefficient can relax
that sufficient restriction. None of these arguments covers unspecified
dependence, growing facet dimension or arbitrary unbounded ability laws.

The finite-L covariance calculation implements the law of total variance,
with S the vector of owner totals:

    Var(U | g) = Var(E[U | S,g] | g) + E[Var(U | S,g) | g].

At evaluation beta, the plug-in correction is a function of S. The raw
negative profile score is affine in the eight cell-total/middle-count
statistics Z. Its log-slope coefficient also contains theta_hat times an
owner-total contrast; that term is constant conditional on S. Therefore
the within-S covariance is `D_0(beta)' Cov(Z | S,g) D_0(beta)`, where D_0
is the block-logit derivative's coefficient at ability zero. The generating
conditional covariance and means of Z are computed at beta_0. The conditional
mean at evaluation beta must likewise use those generating means, rather
than substitute the model's means at beta. This distinction is required for
the correct finite-L Jacobian and root as well as the meat.

The new implementation checks its count-moment law of total covariance
against direct multinomial moments at each exposure, including the saved
ability mixtures. At L=1 it also compares the full score mean and meat with
independent response-pattern enumeration at truth, the opposing parameter
vector and the saved root, then compares the entire Jacobian and saved
covariance. These checks target the two errors that would otherwise make a
mean-only extension misleading: differentiating the generating distribution
along with the evaluation parameter, and dropping within-total variation.

### Results and the next inference decision

All **32 cases through L=8** are complete: eight original-exposure roots
reused and reconciled, and 24 new two-start fits. Both starts passed the
unchanged equation/Jacobian/rank review and agreed in every case. Summed case
time was **300.186 seconds**, of which 297.893 seconds was for new roots.
Maximum start spread was 1.94e-10, maximum equation residual 9.46e-11 and
maximum Jacobian refinement discrepancy 3.54e-9. The independent original-
exposure mean/meat/Jacobian/covariance checks and direct count-moment checks
all passed; their maximum reported discrepancy was 1.86e-12. This is a
numerical root/covariance calculation, not 32 sampled datasets.

For N=400, the largest absolute structural displacement divided by the
matching full population-sandwich SE across all four settings and five
coordinates is:

| Exposure multiplier L | Order 1 | Order 2 |
| --- | ---: | ---: |
| 1 | .624882 | .185752 |
| 2 | .285345 | .097449 |
| 4 | .115859 | .052335 |
| 8 | .044887 | .012843 |

The all-coordinate table retains each signed displacement, root, SE and
scaled displacement, not just these maxima. The largest order-2 ratio at
L=8 is Criterion / unequal / log slope: displacement -.000239832 and
SE .01867358. Each saved roster originally contains four to six ratings,
so L=8 represents 32--48 ratings per Person. N=400 is a reference population
calculation, not evidence that a fitted sample sandwich is calibrated there.

A coordinate-only maximum can miss a less favorable linear combination.
The full-covariance diagnostic `sqrt(displacement' V^-1 displacement)` is
the maximum standardized displacement over all nonzero linear contrasts
within a case. Its maxima over the four cases are .835652/.306617/.139226/
.056199 for order 1 and .232856/.117212/.060271/.014702 for order 2, ordered
by L=1,2,4,8. This uses the known generating parameter **only for validation**;
it is not an observed-data selection rule or a proposed bias correction.

The independently predicted order-1 leading root vector is also approached:
the maximum absolute difference between `L^2 (beta*_1,L-beta_0)` and its
predicted coefficient falls from .084565 at L=1 to .047691/.016506/.010489
at L=2/4/8. The leading approximation still has finite-L error. Order 2's
scaled displacements are retained without fitting a power or selecting an
order from the results. The lower order-2 population ratios in these cases
do not override the previously retained sample-MSE tradeoff between orders
2 and 4.

For covariance, comparing individual diagonal entries is likewise insufficient.
The extreme eigenvalues of `J^(1/2) (N L V_L) J^(1/2)` give the variance ratio
to the limiting `J^-1/(N L)` over **all** linear contrasts. The smallest and
largest such ratios across the four settings are:

| L | Order-1 variance ratio range | Order-2 variance ratio range |
| --- | ---: | ---: |
| 1 | .966951--3.379910 | .971084--2.769584 |
| 2 | .978663--1.655046 | .991748--1.682710 |
| 4 | .993128--1.298874 | .999004--1.320351 |
| 8 | .998440--1.147679 | .999923--1.154585 |

The full covariance tends toward the information limit, but even at L=8 a
contrast can have about 15% more variance than that limit. Keep the complete
finite-L sandwich rather than replacing it with the limiting inverse
information. Dropping within-total variation is more damaging: across all
coordinates/orders/settings, the minimum resulting SE/full-SE ratio is
.421613/.330691/.287942/.268391 at L=1/2/4/8. These are deliberately incomplete
research calculations used to demonstrate the loss; the package's existing
Person sandwich already uses actual response contributions. This result is
not evidence of a new defect in that public implementation.

**Decision.** The local-root and matching-covariance argument is now concrete
for the declared fixed-block family, with the finite-L numerical bridge
checked through L=8. The eight L=16 cases remain unexecuted and recorded in
`stage-plan.rds` and `stage-completion.rds`. Solving them merely to improve
the population approximation is not required for the next decision: it
would not test the sample sandwich, branch selection on observed samples,
or actual truth coverage. No further exposure-root grid is launched here.

The next inference gate is to freeze a complete **observed-data** procedure,
reconcile its equation/Jacobian/Person covariance with this population
reference, and evaluate its availability, bias, covariance estimation and
all-coordinate truth coverage under independent sampling. Use the existing
explicit order rather than inventing an order selector, retain numerical
failures and all denominators, and state which rating/Person growth and ability
conditions are being evaluated. Record a measured cost and required Monte
Carlo precision before launching that study. Existing original-exposure
sample evidence remains relevant and adverse findings cannot be overwritten
by these more favorable population calculations. The October 2 decision
checkpoint remains in force; general-input scope and the agreed formal
structural-interval target remain open.

No public estimator, SE, interval or API was changed by this work. The new
`jml-exposure-roots-20261001.R` is a research reference, not a public inference
implementation. Evidence is in `validation-results/jml-exposure-roots-20261001/`:
the original manifest/source snapshots, all 32 case records, separate stage
plan/runner/log, 160 coordinate rows, full contrast-variance and contrast-bias
summaries, reconciliation source/results, and retained preflight/pilot logs.
Hashes verify each primary result against the unchanged mathematical source
and inputs; the staged orchestration has its own hash. The calculations use
unpruned floating-point sums, not certified arbitrary-precision arithmetic.
Final verification also checks the reconciliation source/result hashes, parses
the new research source and passes `git diff --check`; all four retained logs
have no R warning/error diagnostics. No full package suite was rerun because
this turn changes only research code and its decision records.

## October 1: observed-data procedure and independent evaluation protocol

The next decision is whether a fully specified observed-data interval candidate
has acceptable finite-sample behavior, rather than whether another population
root can be computed. The public corrected-JML route already supplies the
complete Person sandwich but does not expose structural confidence intervals.
Its default starts and handling of unresolved starts differ from the older
research solver, so old sampling results are not automatically evidence for
the complete present procedure.

### Procedure fixed before the cost pilot

Use `fit_mfrm()` with GPCM/JML, the declared shared step/slope owner,
`jml_correction_order=2`, `jml_correction_sampling="fixed_rosters"`,
`maxit=400`, a preserved declared category scale, observed unit-weight ratings,
and the public default neutral/perturbed starts. Keep the public three-stage
solver policy and all point/covariance checks unchanged. There is no
truth-based start, order search, covariance-driven refit, relaxed tolerance,
or added retry. Retain all returned points and their statuses.

For **this research candidate**, interval eligibility additionally requires
`point$status="consistent_roots"` and an available full Person covariance.
A point returned with unresolved starts remains a point result but supplies
no candidate interval. Each coordinate also needs a positive finite SE and
finite transformed bounds. Form 95% normal intervals on centered locations,
centered steps and log slopes; exponentiate log-slope endpoints for reported
positive slopes. The free-coordinate covariance is transformed with the full
sum-zero linear map, including off-diagonal terms. Evaluate every expanded
location, step and slope, including dependent final levels/steps, not only
the free coordinates. These are pointwise intervals, not simultaneous
intervals or Person-ability intervals. No public API eligibility is changed.

Freeze the whole package R source, compiled-binary identity, reference code,
inputs and this protocol. Reconstruct the first retained sample of each of
the two original order-study designs and compare the public result with the
saved order-2 root/covariance. Independently compare actual Person equations
at the fitted and opposing parameters, the full Jacobian, meat and influence
covariance with the research total-state calculation. Then run a separately
seeded cost pilot with one paired dataset for each design below, rechecking
the two prototype equations/covariances at increased exposure. All pilot data,
failures, warnings and source identities are retained; pilot outcomes will
not enter the independent study's coverage summaries.

### Questions, conditions and precision fixed before sampling

Hold N=400 independent Persons and the saved assignment proportions fixed.
Compare L=1 with L=4, using the same Persons' generated abilities and the
first base block of ratings within the four-block arm. Different replications
are independent; L arms within a replication are paired. This tests whether
the exposure increase that reduced population displacement also improves
the complete observed-data inference, including sample covariance estimation.

1. **Criterion-owned unequal design:** retain the four-/six-rating rosters,
   proportions .6/.4, five structural coordinates and the different saved
   three-point ability mixtures. This preserves informative assignment and
   the slow leading-coefficient case.
2. **Rater-owned sparse design:** retain both five-rating rosters, proportions
   .5/.5, the other owner convention and the saved different ability mixtures.
   This preserves the earlier correction-order MSE counterexample.
3. **Existing non-prototype design:** reuse the three-rater, two-criterion,
   four-category model and six-rating rosters from the general-input witness,
   with Criterion ownership, eight free coordinates and independent N(0,1)
   abilities in both rosters. This tests actual category/level generalization;
   its unbounded ability law is empirical evidence outside the compact-family
   proof, not an automatic extension of that proof.

No factorial expansion of unrelated designs is proposed. L=4 means 16--24
ratings per Person in these conditions. The largest state space is 1,225,
within the unchanged public 5,000-state ceiling. The pilot seeds are
100190001--100190003. If the bridge and measured cost permit execution,
the independent study uses **500 replications per design**, paired L=1/4
arms, for 1,500 new datasets with 3,000 public fits. Its separate seed formula
is `100100000 + 10000 * design_index + replicate`. Store each input before
fitting and each attempted arm atomically; failures count as attempted arms
and are not replaced. The study must not stop early after favorable coverage.

At full availability, a 95% coverage estimate based on 500 replications has
MCSE about .00975 (about .01 with 475 available intervals). This precision is
suited to the same **limited** practical margins used in the MML protocol:
for each coordinate/condition require availability >=.95 with exact 95%
binomial lower bound >=.90, and the exact 95% conditional-coverage Monte Carlo
interval entirely inside [.92,.98]. These are evaluation margins, not a
theorem or universal practical thresholds. Failure or an inconclusive result
leaves that claim unsupported; do not change margins or add replicates
automatically. Monte Carlo bounds are pointwise across the correlated,
constrained coordinates.

Report every coordinate's point/interval availability, failure stage, signed
bias/RMSE, empirical SD, root mean estimated variance, width, tail misses,
conditional truth coverage and delivery-with-truth-inclusion over all 500
attempts. Give exact binomial Monte Carlo bounds for availability, conditional
coverage and delivery. Compare L arms by replication, keeping failures in
paired availability/delivery differences and using common available pairs
only where a paired width/error calculation requires them. All expanded
coordinates and both exposure arms remain in the report even if one fails.
Existing original-exposure adverse findings remain visible; this study does
not establish general sparse-design, dependence, unbounded-population or
automatic-order guarantees.

The initial execution is only the two saved-data bridges and six pilot fits.
Retained root timings suggest seconds to minutes per pilot arm but do not
measure this public path. Measure its preparation/fit/verification cost, then
forecast the full independent study before launch. Use one study process
alongside the existing MML replay. If the interpretable result is projected
after October 2 at 18:00 JST, apply the existing user-consultation rule first.

### Bridge result, measured cost and launch decision

Both retained datasets reproduce the older order-2 root with maximum
coordinate difference 1.40e-10 and covariance-entry difference 5.15e-11.
Comparisons of the actual Person scores, complete Jacobian and sandwich
against the separate research implementation pass, including the opposing
parameter and increased-exposure pilot datasets; the largest recorded
relative covariance discrepancy is 4.07e-11. The pilot's expanded constrained
estimates and SEs also reproduce public tables for all 10/10/13 location,
step and slope coordinates in the three designs. This checks the complete
source-identified implementation; it does not transfer the old study's
failure rate to the new public solver policy.

All six pilot fits returned consistent roots and available covariances:

| Design | L=1 public fit seconds | L=4 public fit seconds |
| --- | ---: | ---: |
| Criterion / unequal | .964 | 6.393 |
| Rater / sparse | .994 | 7.324 |
| Three raters / four categories | 2.505 | 32.820 |

These are one dataset per arm, **not coverage or availability estimates**.
Total fit time is 51.000 seconds; multiplying by 500 gives **7.083 hours**
for 3,000 fits on one process at those times. Reproducing the saved pilot
inputs takes .026/.006/.007 seconds per design and verifies exact rating
counts and paired L=1 prefixes within L=4. Generation is small relative to
fitting. A planning range of **8--22 hours** allows preparation/reporting,
solver retries and approximately threefold variation from the pilot fit
projection; it is not a guaranteed upper bound. At the October 1 early-morning
launch this is before the October 2 18:00 JST decision checkpoint. Actual
times and failures remain recorded for revising that projection.

The independent runner will use the pilot's immutable package snapshot and
its own frozen orchestration/protocol/manifest. It runs serially alongside
the existing MML matched replay, saves generated inputs before any fit,
saves each arm atomically and resumes only matching-source records. It
builds coverage summaries only after all 3,000 attempts exist. In-process
numerical failures remain unavailable outcomes. An unexpected failure of
the validation code is saved and stops execution for investigation; it is
not silently classified as statistical noncoverage or bypassed on resume.

Before launch, a synthetic summary fixture verifies the distinction between
2/3 interval availability, 1/2 conditional inclusion and 1/3 delivery, plus
paired inclusion differences and all-unavailable cases. Separate checks
confirm that unresolved starts and unavailable covariance block only the
candidate intervals, and a failed fit retains all expected coordinate rows.
The pilot data never enter the study denominator. These checks introduce no
new fitted samples or public confidence-interval support.

The complete summary reader was also exercised on copies of the six pilot
records: it produced all 66 coordinate/condition summaries and 33 paired
summaries, with the pilot-only count of one per arm and no precision-margin
qualification. This is a file/denominator check, not a six-dataset coverage
study. The fixture is separate from the independent study directory's fits.

**Launched October 1 at 00:44:37 JST**, one process, PID 59186. The frozen
runner is `validation-results/jml-independent-inference-20261001/runner.R`;
its manifest references the immutable package snapshot in
`validation-results/jml-observed-inference-20261001/source/`. The launch
record, lock ownership, generated inputs and first completed arm records
confirm execution. Estimates and candidate intervals remain research results.
All independent attempts are pending final coverage review; early successful
fits are not a coverage conclusion. `summary.rds` and the full CSV summaries
are created automatically only when all 3,000 attempts have been saved.
The separate 400-dataset adaptive-MML matched replay is still running; no
independent MML coverage study has been launched by this JML action.

**Paused October 1 at 01:00:49 JST after priority review.** The additional
study was interrupted by SIGINT; PID 59186 exited and `RUNNING` was removed.
All 113 saved fit records and 57 generated inputs remain readable with
matching manifest/input hashes and seeds. Frozen runner/protocol hashes also
match. No temporary files or final summaries remain. The interrupted
`fit-3-019-L4.rds` has no saved fit record; its input is retained for a possible
same-procedure restart. It is not classified as a numerical failure.

This scheduling decision was not based on interim coverage. No partial
coverage analysis or qualification is made. `pause.json` preserves the
interruption and restart policy. Do not restart automatically or expand the
study: first specify which public inference/scope decision the remaining
calculation would resolve and reassess its priority against unfinished public
consumers. Formal corrected-JML structural inference remains open. The
separate 400-dataset MML matched replay remains running.

## October 3 public/profile correspondence and comparison-output connection

### Numerical correspondence at the actual public structural estimates

The [independent observed-pattern runner](jml-public-profile-bridge-20261002.R)
implements category utilities, their first and second derivatives, scalar
Person profiling and the profile Schur complement independently of the
package response kernel. It covers centered unit-weight PCM and shared-owner
GPCM with independently free Persons. Ordinary JML uses observed patterns;
the adjusted-equation enumeration ceiling is never invoked to restrict it.

At each retained structural vector it solves only the nonextreme scalar
Person equations. Extreme contributions have their exact zero extended-profile
limits. It compares the independent finite-joint value and full gradient with
the public evaluator, integrates Hessian blocks along the actual Person
displacements, and verifies the exact residual identity from the earlier
derivation. Central differences at 1e-4 and 5e-5 check the full profile gradient
and Schur information. No new response data or structural optimization occurs.

| Retained case | N | Non-Person facets and levels | Extreme Persons | Profile gradient sup norm | Local Newton structural displacement |
| --- | ---: | --- | ---: | ---: | ---: |
| A/B PCM | 20 | Rater 3, Criterion 3 | 0 | 3.27103e-5 | 1.56472e-6 |
| A/B GPCM | 20 | Rater 3, Criterion 3 | 0 | 6.67825e-5 | 3.80044e-6 |
| Earlier GPCM base | 240 | Rater 3, Criterion 2 | 5 | 1.60748e-5 | 8.19566e-8 |
| Earlier GPCM Task extension | 20 | Rater 3, Criterion 2, Task 4 | 1 | 8.90976e-5 | 2.39977e-5 |
| Earlier GPCM Rater extension | 240 | Rater 6, Criterion 2 | 3 | 1.32942e-5 | 1.33860e-7 |

The largest package/reference joint-value discrepancy is 3.87e-12 and the
largest gradient discrepancy is 1.99e-14. The exact residual decomposition
agrees to 4.67e-12. The largest finite-extreme structural contribution is
2.73e-5; retaining it matters for checking the identity even though its
extended-profile limit is zero. Every retained profile Hessian is positive
definite, with minimum eigenvalues 1.36--99.54.

The displacement column is `max(abs(H_profile^-1*g_profile))`, a local
diagnostic. It does not certify a neighborhood curvature bound, global GPCM
root selection or an actual parameter-error bound. Where the observed fixed-
roster covariance can be calculated, the largest displacement divided by a
coordinate root SD is below 9.81e-6. In the N20 Task case, some observed
rosters have only one Person; its fixed-roster covariance is left unavailable
rather than pooled under a different sampling assumption.

### Matching covariance remains different from inverse curvature

The numerical reference retains all actual Person profile-score contributions,
including zero extreme contributions. For the fixed observed roster counts,
it centers within each roster and computes
`H_profile^-1 * sum_i U_i,centered U_i,centered' * H_profile^-1`.
At nearly stationary retained vectors this is a diagnostic sample version of
the root-centered sandwich derived earlier; it is not an established truth
interval or a small-N covariance-accuracy result.

Across all linear contrasts, the empirical sandwich/inverse-profile-information
variance ratios are the eigenvalues of
`chol(H_profile) V_sandwich chol(H_profile)'`. Their observed ranges are:

| Case | Minimum ratio | Maximum ratio |
| --- | ---: | ---: |
| A/B PCM, N20 | .07829 | 3.14607 |
| A/B GPCM, N20 | .04738 | 4.64158 |
| Earlier base GPCM, N240 | .89415 | 2.06547 |
| Earlier six-rater GPCM, N240 | .76031 | 1.91278 |

These are same-sample matrix comparisons, not true sampling-variance ratios.
They demonstrate why the inverse profile curvature is not interchangeable
with the declared empirical Person sandwich. A close public/profile point
does not remove the previously proved fixed-exposure structural bias.

### Corrected candidate and training-score outputs now connected

`wide_jml_candidate()` in the [interval recovery adapter](mfrm-wide-map-interval-recovery-20261002.R)
uses each original order-2/4 root and its complete saved fixed-roster Person
covariance. It emits all centered locations, all steps, log slopes and the
prespecified Rater/Criterion contrasts. The dependent final levels use the
full linear map, including covariance terms. Positive-slope display bounds
are exponentiated from log coordinates. Consistent starts, available matching
covariance and positive finite target variance remain required; unresolved
starts, missing covariance and fit errors retain unavailable rows and reasons.
No interval outcome selects a root or correction order. Formal structural-CI
eligibility remains false; these are labelled research candidates.

On the existing eight-arm N20 PCM-truth witness, both corrected fits supply
20 candidate targets. Expanded values/SEs/bounds reproduce the earlier frozen
research candidate, and contrast variances reproduce the direct full-covariance
formula. Failure fixtures preserve all target denominators and leak no bounds.

The [training-score adapter](mfrm-wide-map-f-scoring-20261002.R) also keeps
native training estimates separate from explicit-prior re-scoring. All planned
Persons, observed exposure and extreme/source statuses are retained. Infinite
native JML values produce infinite squared loss and undefined Monte Carlo SE,
rather than finite-only RMSE or substituted EAPs. The saved N20 witness supplies
160 native rows across eight methods and 16 training re-scoring batches.
Every refined scoring batch passes at q61; the initial q31 refusals remain.
This is one parent response dataset, not 160 or 16 independent replications.

Evidence is in `validation-results/jml-public-profile-bridge-20261002/` and
`validation-results/mfrm-wide-map-comparison-outputs-20261002/`. Fresh-process
replay with numerical work forbidden reproduces the saved results identically.
The source is unchanged in `R/`; no new public JML interval API is introduced.
The R=50 PCM execution unit now has these output stages, with its complete-stage
large-N/exposure feasibility check tracked in the main roadmap.

**Remaining inferential obligation.** The observed public/profile bridge is
resolved for these retained examples, and the labelled corrected candidate
is executable. A general bridge/selection theorem, growing-exposure bias and
covariance control for unbounded ability populations, and design-specific
truth-coverage qualification remain distinct scientific tasks. An inverse-
information replacement or larger N alone cannot resolve their counterevidence.
The paused N=400 confirmation records remain untouched.

## October 3 RSM/PCM curvature transport and a finite-profile-root criterion

**Question resolved within a stated baseline.** The earlier numerical bridge
measured a small profile gradient and a positive Hessian at the public point,
but did not supply the neighborhood curvature bound needed to control its
distance to a profile minimizer. For ordinary RSM/PCM with fixed unit slopes,
the finite affine category design supplies that bound. The result below is a
deterministic sufficient condition, not a truth-bias correction or an inference
theorem. Its numerical evaluation reuses the saved PCM derivatives; no new
estimation, Person profiling, finite differences or simulated responses occur.

Keep the earlier baseline: unit-weight observed ratings, categories 0,...,K,
independently free unanchored Persons, finite affine structural coordinates
beta in R^p, no shrinkage/interactions and fixed unit slopes. Use the original
identified coordinates; these Euclidean bounds depend on that parameterization.
The observed roster can be incomplete or repeated. This is a statement about
the specified likelihood conditional on that roster, not validation of its
missingness, assignment or independence assumptions. Extreme Persons have
their exact zero extended-profile contributions for every finite beta.

### 1. Transport of the profile Hessian

For each nonextreme Person i, let

    C_i = max_{j in roster i, k != l} ||D_jk-D_jl|| / |k-l|,
    L_i = max_{j in roster i, k != l} (|k-l|*C_i + ||D_jk-D_jl||),
    L   = max_i L_i.

The earlier covariance identity gives
`||partial_beta t_i(beta)|| <= C_i` at every finite beta. The scalar optimum
exists uniquely at every such beta, so integration along a structural segment
gives `|t_i(beta)-t_i(b)| <= C_i*||beta-b||`. Consequently the range across
categories of the change in utility of any rating j is at most
`L_i*||beta-b||`. For normalized category probabilities this implies

    exp(-L_i*||beta-b||) <= p_jk(beta)/p_jk(b)
                         <= exp(L_i*||beta-b||).

For any real random variable W on those categories,
`Var_p(W) = min_c E_p[(W-c)^2]`. A density ratio between a and b therefore
bounds its variance between a and b times the reference variance. Applied to
every linear combination of the fixed joint features `(Y,D_jY)`, this bounds
the whole joint Hessian in positive-semidefinite order. The bound survives
summation over ratings and nuisance elimination because the profile Schur
quadratic form is the minimum of the joint quadratic form over the scalar
nuisance direction. Writing S_i for the individual profile Hessian and H for
their sum gives

    exp(-L_i*||beta-b||) S_i(b) <= S_i(beta)
                               <= exp(L_i*||beta-b||) S_i(b),
    exp(-L*||beta-b||) H(b)     <= H(beta)
                               <= exp(L*||beta-b||) H(b).          (7)

The inequalities are in matrix order, not elementwise order. Zero extreme
contributions preserve them. Positive curvature at b now supplies an explicit
lower curvature bound on every finite ball about b; it still does not by
itself guarantee a finite minimizer. The general convexity under partial
minimization and the quadratic Schur representation are described in
[Boyd and Vandenberghe, section 3.2.5](https://web.stanford.edu/~boyd/cvxbook/bv_cvxbook.pdf).
The probability-ratio/profile transport argument here is the present
model-specific derivation, not a theorem attributed to that reference.

### 2. A sufficient existence, uniqueness and distance condition

Suppose `lambda_min(H(b)) >= lambda > 0` and `||grad M(b)|| <= G`. For any
unit vector u and radius r, integration of (7) bounds the radial derivative:

    u' grad M(b+r*u) >= -G + lambda*(1-exp(-L*r))/L.

If `s=L*G/lambda < 1`, define

    rho = -log(1-s)/L.                                           (8)

Every sphere with radius r>rho has a strictly outward radial derivative.
The minimum over its closed ball is thus interior. Convexity of M makes it a
global minimizer, and (7) makes it unique. Integration along the segment to
that root gives `||b-beta_profile|| <= rho`. Convexity also gives the exact
profile-objective gap bound `M(b)-M(beta_profile) <= G*rho`.
For L=0 use the continuous limits `rho=G/lambda` and constant curvature.
If s>=1 the criterion is inconclusive: it neither proves nonexistence nor
licenses a parameter-error bound. If G=0 and H(b) is positive definite, b is
already the unique global profile minimizer.

Unlike the earlier local Newton displacement, (8) incorporates a neighborhood
bound and a root-existence argument. It remains a sufficient condition for a
declared dataset/design, not a universal optimizer tolerance. Under varying N,
design or dimension, numerical equivalence at a sampling scale requires this
radius to be negligible at that scale with appropriately controlled probability.

### 3. Allow for the saved scalar-profile residuals

The saved nuisance coordinates are finite numerical approximations, so their
gradients must not simply be set to zero. At the stored t_tilde_i and b let
`r_i=abs(partial_theta q_i)` and `a_i=partial_theta,theta q_i>0`. The same
probability-ratio argument in the scalar direction gives, when `K*r_i/a_i<1`,

    delta_i = -log(1-K*r_i/a_i)/K,
    |t_tilde_i-t_i(b)| <= delta_i.

Use the stored structural gradients U_tilde_i and joint-Hessian Schur
complements S_tilde_i. Their sum is H_tilde. With C_i as above, valid inputs
to (8), in exact arithmetic, are

    G      = ||sum_i U_tilde_i|| + sum_i C_i*r_i,
    lambda = exp(-K*max_i delta_i) * lambda_min(H_tilde).

Exact extreme contributions are zero and need neither a finite scalar
inverse nor a tail truncation. These formulas account for nuisance-profile
error; they do not account for floating-point roundoff in the stored gradients,
Hessians, eigenvalues or bound evaluation. Outward-rounded certification would
require verified enclosures for those quantities. Independent derivative
agreement and a generous numerical margin are evidence, not such enclosures.

### 4. What can be transferred to the empirical covariance matrix?

There is also a finite-perturbation bound for the previously defined empirical
fixed-roster sandwich. This bounds how that same matrix changes upon moving
from the approximate stored profile to the exact root. It is **not** consistency
for the true sampling covariance. Keep all original roster groups and require
at least two Persons per group for this recorded covariance procedure.

Let `A_tilde=H_tilde^{-1}`, let Z_tilde_i be U_tilde_i centered within its
original roster, and set `B_tilde=sum_i Z_tilde_i Z_tilde_i'`. For the radius
rho above, define

    e_i = C_i*r_i + exp(K*delta_i) * ||S_tilde_i||_op
                    * (exp(L_i*rho)-1)/L_i,
    d_i = e_i + mean_{j in roster group i} e_j,
    E_B = sum_i (2*||Z_tilde_i||*d_i + d_i^2),
    T   = exp(max_i (K*delta_i + L_i*rho)),
    a   = 1/lambda_min(H_tilde).

Use rho for the ratio when L_i=0, and e_i=0 for an exact extreme contribution.
Integrating the individual profile Hessian along the structural segment gives
the e_i score bound; centering gives d_i, and expanding the outer products
gives `||B_root-B_tilde||_op <= E_B`. Equation (7), including the initial
nuisance discrepancy, gives `||A_root||_op <= T*a` and
`||A_root-A_tilde||_op <= (T-1)*a`. Thus

    ||V_root-V_tilde||_op
      <= (T*a)^2*E_B + (T+1)*a * ||B_tilde||_op * (T-1)*a.        (9)

This is a worst-direction matrix bound. It does not imply the same relative
bound for every contrast variance or standard error. The population meat,
fixed versus random roster sampling, centering at a possibly biased target,
and consistency of the empirical covariance remain separate obligations.

### Saved-data evaluation and falsification checks

The [saved-derivative evaluator](jml-pcm-profile-certificate-20261003.R) uses
the unchanged N20 PCM example (Rater 3, Criterion 3, 10 free structural
coordinates, no extreme Persons). It reconstructs only the fixed design map
and performs matrix arithmetic on the independently saved derivatives.

| Quantity | Floating-point evaluation |
| --- | ---: |
| Maximum C_i / maximum L_i | 2.44949 / 13.34847 |
| Profile-gradient norm upper input G | 5.28767e-5 |
| Curvature lower input lambda | 2.40557 |
| Maximum scalar-profile distance allowance | 1.50129e-13 |
| Sufficient-condition ratio L*G/lambda | 0.000293412 |
| Structural Euclidean radius rho | 2.19842e-5 |
| Exact profile-objective gap upper expression G*rho | 1.16245e-9 |
| Empirical covariance change upper expression (9) | 0.0113994 |

The last bound is about 2.51% of the stored covariance's operator norm;
it is conservative and is not a measured covariance difference or a sampling-
accuracy result. The radius is a calculated bound expression, conditional on
adequate derivative accuracy, not an outward-rounded numerical certificate.
No claim is made that the saved point is exactly stationary.

An exact binary two-item fixture uses ten discordant Persons, split 6/4, plus
two extreme Persons. Its profile root is `2*log(6/4)`. At an offset of .01,
the computed radius .01005543 contains the known displacement, and the exact
objective/covariance changes obey their respective bounds. A distant point
with a finite root is correctly inconclusive. When all ten discordances have
the same orientation, finite-point curvature is still positive but the optimum
escapes to infinity; the criterion does not pass. A singular-curvature case
is also refused, and the implementation explicitly rejects free-slope GPCM.
These deterministic fixtures are not independent simulation replicates.

Evidence is in `validation-results/jml-pcm-profile-certificate-20261003/`.
A fresh-process replay reproduces the saved evaluation with public fitting,
optimization and scalar root solving forbidden. The running R50 worker's source
is unchanged. The analytic result applies to the stated ordinary RSM/PCM
baseline; numerical evaluation here covers this PCM case only. Free slopes,
coupled/anchored Person coordinates and other likelihood/equation changes need
separate arguments. Most importantly, this resolves a numerical correspondence
obligation under its sufficient conditions; the fixed-exposure truth bias and
the lack of qualified ordinary/corrected JML structural confidence intervals
are not removed.

## October 3: fixed-exposure identification and bias-aware inference

**Decision.** Low-exposure truth inference needs both centering and
identification. Fixed-slope RSM/PCM admits a conditional-likelihood reference
with an explicit estimability criterion. In a stated unrestricted-population
GPCM model, an owner-location contrast is not identified even from the entire
response distribution. This is stronger than the earlier failure of a class
of unbiased estimating equations. A bias-aware confidence set can nevertheless
have valid coverage while retaining this ambiguity; it must not promise to
shrink around one of observationally equivalent truths.

The derivations below are for independent Persons and the specified
conditionally independent response law, fixed finite rosters and finite
category support. They do not introduce a public estimator, silently replace
JML by CML, impose a normal population on JML, or qualify the current research
Wald intervals. The new arithmetic witness has **two non-Person facets, Rater
2 x Criterion 2, four complete binary ratings per Person**. It is a probability
calculation with no Person sample size, simulated dataset or estimated root.

### 1. Fixed slopes: a truth-centered reference and its information

In the affine fixed-unit-slope RSM/PCM baseline, write a Person's response law
on their assigned roster g as

    p_beta,theta(y | g) = h_g(y) exp{theta S(y) - beta' T_g(y)}
                         / D_g(beta,theta),

where S is the scalar total score, beta contains the identified structural
coordinates, and h includes any known offsets or count multiplicities.
Conditioning on the *observed* S=s gives

    q_beta(y | s,g) = h_g(y) exp{-beta' T_g(y)}
                     / sum_{z:S(z)=s} h_g(z) exp{-beta' T_g(z)}.

The ability cancels exactly. The negative conditional score and its derivative
are

    U_C(y;beta) = T_g(y) - E_beta[T_g(Y) | s,g],
    d U_C/d beta' = Cov_beta(T_g(Y) | s,g).

At the generating beta, `E[U_C | S,g,theta]=0`; it remains zero after mixing
over any ability distribution compatible with the conditional response law.
Its conditional score variance equals this same information matrix. This is
score centering, not an assertion that the finite-N CML point estimate is
unbiased. It also does not make this matrix a covariance for the ordinary
public JML estimate.

For the actual conditioned totals/rosters, conditional information has a null
direction v exactly when `v' T_g(y)` is constant within every contributing
total-score stratum. Equivalently, the span of all feature differences
`T_g(y)-T_g(z)` within those strata must have full rank in the promised
coordinates. This is an estimability check on the conditional design, not just
connectivity of the original facet graph. All-low/all-high strata are
singletons and provide zero conditional information. They need no finite
Person estimate and are retained as uninformative strata. Completely unobserved
Persons likewise cannot supply structural information.

With positive limiting information and a regular finite root, the inverse
conditional information gives the CML asymptotic covariance. For finite-sample
coverage one can instead invert tests under the **full conditional law**, with
all structural nuisance coordinates retained or projected out. For example,
for each candidate beta choose a statistic T_beta and its nonrandomized tail
probability under q_beta. Then

    C(Y) = {beta: p_beta(Y | observed totals, rosters) > alpha}

has conditional coverage at least 1-alpha when those tail probabilities are
evaluated exactly or conservatively. Projecting this joint set gives contrast
sets with at least that coverage; replacing them by their interval hulls is
also conservative. With no conditional information the set can be the whole
domain. Neither a finite MLE nor a normal approximation is required for this
test-inversion statement. Enumeration/inversion cost and useful interval
width remain separate implementation questions.

This applies only when conditioning on assignment/missingness preserves the
stated response law. Ability-dependent assignment alone may change the ability
mixture without affecting this cancellation; arbitrary outcome-dependent
selection or response dependence cannot be ignored. The general CML rationale
and its distinction from JML are reviewed in
[Skrondal and Rabe-Hesketh, Section 8](https://link.springer.com/article/10.1007/s11336-021-09816-8).
The explicit feature-rank and interval construction here define the proposed
reference for this package's affine baseline; no CML API is being released.

### 2. Unequal slopes: exact equivalence of different structural truths

Fix a finite roster and positive slopes a_c. Let S be the vector of totals
by slope owner. As in the earlier owner-conditioning argument,

    p_beta,theta(y) = h_beta(y) exp{theta * a'S(y)} / D_beta(theta),
    q_beta(s | theta) = H_beta(s) exp{theta * t_s} / D_beta(theta),
    H_beta(s) = sum_{y:S(y)=s} h_beta(y),   t_s = a's.

Assume the m feasible weighted totals t_s are all distinct, and H_beta(s)>0.
Choose m distinct finite abilities theta_j. The m x m matrix
`Q_beta[s,j]=q_beta(s | theta_j)` is nonsingular: after positive row/column
scaling it is `[exp(t_s theta_j)]`. A nonzero linear combination of m real
exponentials with distinct exponents has at most m-1 distinct real zeros.
This follows inductively by dividing out the smallest exponent and applying
Rolle's theorem to the derivative, which has m-1 terms. It proves the stated
matrix rank without a numerical eigenvalue threshold.

Start from a strictly positive weight vector w0 summing to one and let
`p_S=Q_beta0 w0`. Vary an owner-location contrast while holding slopes and
other coordinates fixed, preserving the imposed centering constraints.
The conditional law `p_beta(y | S=s)` is unchanged: the owner-location factor
is constant inside each stratum and cancels. Define

    w(beta) = Q_beta^(-1) p_S.

Continuity gives w(beta)>0 in a neighborhood of beta0. Since Q_beta is column
stochastic, its weights sum to one. Both the distribution of S and the
conditional distribution of Y given S are unchanged. Consequently

    P_beta,F_beta(Y=y) = P_beta0,F0(Y=y)   for every response pattern y,

despite the different owner-location contrast. This establishes local
nonidentification in this unrestricted ability-mixture model, even with known
unequal slopes. Free-slope GPCM contains that submodel. The result is not
caused by a failed numerical optimizer, uncertain covariance, or extreme
Person estimates. Bounded ability support alone does not fix it: all chosen
theta_j can lie in a finite interval.

For finitely many rosters with separate unrestricted F_g, apply the construction
to each roster and take a common sufficiently small structural displacement.
This does not assert the same conclusion for every collection of rosters
sharing one constrained F. The witness below has only one roster, so its
population is common to all Persons without that qualification. Equal or
colliding weighted totals violate the rank premise and need separate analysis;
the fixed-unit-slope CML result above is not contradicted.

**The obstruction is not limited to discrete populations or heavy tails.**
For a continuous baseline F0, now set `p_S=integral q_beta0(.|theta) dF0(theta)`.
If F0 has a positive density on an interval, choose m bounded nonnegative smooth
functions psi_j with disjoint small supports near m suitable abilities. The
matrix `A_beta[s,j]=integral q_beta(s|theta) psi_j(theta) dF0(theta)` is invertible
when the supports are sufficiently small. Put

    r_beta = p_S - integral q_beta(.|theta) dF0(theta),
    c_beta = A_beta^(-1) r_beta,
    dF_beta = [1 + sum_j c_beta,j psi_j] dF0.

Near beta0, c_beta tends to zero, so the density stays nonnegative. Summing
the rows of `A_beta c_beta=r_beta` proves normalization. This gives the same
response distribution and leaves the density unchanged outside a compact
set. In particular, F0 may be normal, although the alternative F_beta need not
be normal. Thus controlling normal tails does not identify this unrestricted
model. A model requiring both laws to be exactly normal is a different model;
the existing normal-MML identification results remain unaffected.

For any two such equivalent truths with contrast separation Delta>0, a
confidence set with coverage at least 1-alpha at *both* truths must, under their
common data law, contain both with probability at least 1-2 alpha. Hence

    P(diameter of the contrast set >= Delta) >= 1-2 alpha

for every N. No uniformly valid shrinking interval, ordinary or corrected JML
order, bootstrap, or alternative covariance can remove this exact ambiguity.
This does not prohibit informative sets of nonvanishing width, valid inference
for identified contrasts, or inference under justified additional assumptions.

### 3. Exact arithmetic witness and positive control

The [research check](jml-fixed-exposure-identification-20261003.py) uses complete
binary ratings at cells `(r,c) in {+1,-1}^2`, with

    a_+ = 2,   a_- = 1/2,
    b_Rater,r = r * 2 log(6/5),
    b_Criterion,c = c * 2 log(d),   theta_j = 2 log(x_j),
    x = (1/4, 1/3, 1/2, 2/3, 1, 3/2, 2, 3, 4).

The two facets are centered and the geometric mean of slopes is one. There
are 16 response patterns and 9 owner-total states. Their weighted totals are
`(4 s_+ + s_-)/2`, all distinct for s_+,s_- in {0,1,2}. Each rating has rational
odds `(x / [(6/5)^r d^c])^(2 a_c)`, so all comparisons can use exact rational
arithmetic. Start with d=11/10 and nine equal ability weights.

| Alternative d | Change in Criterion 1-minus-2 contrast | Minimum solved mixture weight | Admissible probability law? |
| --- | ---: | ---: | --- |
| 1101/1000 | +0.0036347117 | 0.0503603812 | Yes; all 16 marginal probabilities are exactly equal. |
| 111/100 | +0.0361993421 | -0.4970893111 | No; a signed solution is not an equivalent population. |
| 6/5 | +0.3480455080 | -6.4732217586 | No; retained as an inadmissible larger displacement. |

The valid weights have maximum 0.1836363663 and sum **exactly** to one. The
baseline contrast is 0.3812407192. Equality of all response probabilities,
the direct exponential factorization, and conditional invariance pass exactly.
The location Schur information at known generating ability is positive
definite, also in exact arithmetic: the example is not an ordinary linear
facet-design alias. That curvature does not identify an unrestricted mixture.
The witness demonstrates a positive ambiguity, not a practical lower bound
on interval width throughout the package's domain.

The fixed-unit-slope positive control uses the same design and ability grid.
Scalar-total conditional probabilities are ability-invariant, both conditional
location scores have exactly zero conditional expectation, and their expected
information is positive definite. The two extreme rows have zero score.
Changing the Criterion contrast changes those conditional probabilities.
Its owner-total probability matrix has rank 5, not 9, so the unequal-slope
equivalence construction cannot be applied to it.

An initial standard-library Fraction solve and the saved SymPy 1.14.0 solve
agree on the three weight classifications. The repository research script saves
all exact fractions, settings and its source hash to
`validation-results/jml-fixed-exposure-identification-20261003/exact-witness.json`.
No simulations, public fits, finite differences or new correction orders were
run. These algebraic checks do not independently certify the general analytic
proof or evaluate small-sample interval performance.

**Connection to the saved few-rating PCM fit.** The same conditional-rank
criterion was applied to the existing N=20, Rater 3 x Criterion 3 PCM dataset:
six ratings per Person, categories 0--3, three assignment rosters and ten free
structural coordinates. The checksum-verified saved input was exported through
`jml_bridge_context()` with fitting, optimization and scalar root finding
blocked. No likelihood derivative was evaluated.

For each observed total s, the exact feature-difference span can be built by
transferring one score unit from rating ell at category b>=1 to rating j at
category a<K. Such a move is feasible precisely when
`0 <= s-a-b <= (n-2)K`. Every pair of integer response vectors in a fixed-total
product support is connected by these moves: transfer from a coordinate above
its target to one below its target until the vectors agree. Summing their
feature differences therefore gives the same span as complete enumeration.
The saved design features are integers, so rational row reduction requires no
numerical rank tolerance.

The pooled observed-total rank is **10 out of 10**. Individual-Person ranks are
3, 6 or 9; all twenty Persons remain in the pool. An independent enumeration of
the first Person's 21 fixed-total patterns gives exactly the same rank-six row
space as the transfer construction. The export, exact check and results are
saved as `pcm-design.json`, `pcm-rank.py` and `pcm-rank.json` in the same evidence
directory. This establishes conditional estimability for these observed
strata. It does not establish a finite CML maximizer, adequate precision,
useful confidence-set width or coverage of a numerical interval implementation.

### 4. A finite-sample bias-aware score-set candidate

It is possible to keep the ordinary/order-k equation as a statistic without
asserting that its expectation is zero. For candidate beta and each Person's
fixed roster g_i, choose M scalar score components (or directions fixed before
seeing responses), denoted X_ij(beta). Use the exact extended-profile or
fixed-order corrected response function, including zero extreme contributions.
For every possible response pattern obtain safe bounds

    a_ij(beta) <= X_ij(beta) <= b_ij(beta),
    l_ij(beta) <= E_beta,theta[X_ij(beta)] <= h_ij(beta)
                 for every admitted theta.

The expectation bounds can use the infimum/supremum over abilities or a
justified narrower population class. They bound the **equation mean**, not
parameter bias; no conversion through an unchecked inverse Jacobian is needed.
At each finite beta, fixed finite exposure gives bounded score values even
when the mathematical Person profile is infinite on an extreme pattern.
Let bars denote Person averages and define

    epsilon_j(beta) = sqrt{log(2 M/alpha) *
                          sum_i [b_ij(beta)-a_ij(beta)]^2 / (2 N^2)},
    C(Y) = {beta: lbar_j(beta)-epsilon_j(beta) <= Xbar_j(beta)
                  <= hbar_j(beta)+epsilon_j(beta), for all j}.

Under independent Persons and the declared response law, the bounded-sum
inequality of [Hoeffding (1963)](https://doi.org/10.1080/01621459.1963.10500830)
and a union bound give `P_beta0(beta0 in C) >= 1-alpha`. Indeed, each observed
mean differs from its actual mean by at most epsilon_j except with probability
alpha/M, and its actual mean lies in the declared mean envelope. This argument
works conditional on a fixed ability vector, or after averaging over independent
ability draws. No numerical root, normal approximation or consistent estimated
covariance is assumed. Inverting a continuum of candidate-beta tests does not
require an additional union bound over beta: coverage concerns the test at the
single generating beta0. Projecting the joint set retains conservative
contrast coverage. Empty, disconnected and unbounded sets remain possible.

This establishes a mathematical candidate, **not an implemented useful CI**.
Its concrete admission conditions are:

* Bounds must cover the entire declared ability and parameter domain. A finite
  ability grid without a remainder/tail bound, or truncating parameter search
  to obtain finite endpoints, can invalidate coverage.
* Numerical response bounds and set inversion must be conservative. An outer
  approximation of C retains coverage; an incomplete accepted grid generally
  does not. Unqualified solver refusals are not statistical exclusions.
* Arbitrarily centering by a fitted mean, using data-selected score directions
  or selecting a correction order requires a separate selection argument.
  Independent Person sampling is not established by treating shared-rater
  random effects or dependent ratings as independent observations.
* Using only the raw range `[a_ij,b_ij]` as the mean envelope is always safe
  but gives an uninformative whole-domain set. A sharper certified envelope
  must actually exclude some parameter values and respect the exact ambiguity
  in section 2. Coverage alone is not a successful user-facing result.

### 5. Consequence for the next implementation decision

| Candidate | Mathematical decision | Next required evidence |
| --- | --- | --- |
| CML reference for fixed-slope RSM/PCM | Admissible for conditionally identified coordinates under its stated response/selection law; different estimator and uncertainty from JML. The saved N20, 3 x 3, six-rating PCM design retains all ten coordinates by exact conditional-rank calculation. The subsequent calculation gives finite exact conditional reference intervals for two primary contrasts, with boundary/uninformative fixtures. | Extend only with a defined conditioning rule and information/availability review for the requested contrast and design. The two-contrast procedure does not qualify all ten coordinates. No relabelling of its covariance as JML covariance. |
| Ordinary or finite-order corrected Wald intervals with unrestricted GPCM ability laws | Cannot have a generic shrinking structural-truth guarantee for the equivalent owner-location contrasts above. | A justified identifying restriction, an identified target, or an interval that retains ambiguity is necessary. More repetitions or a different sandwich is insufficient. |
| Bias-aware equation-mean set | Finite-sample coverage follows from the stated deterministic envelopes and independence; allows nonidentification. The subsequent whole-ability calculation certifies nontrivial mean envelopes for two location components at one 2 x 2 binary GPCM parameter point, at orders 0/2/4. | Qualify free-slope bounds and conservative projection while structural nuisance parameters vary. Assess interval width/availability before any sampling study or API; a test at one parameter point is not a projected interval. |
| Growing-exposure JML | Remains a distinct route; the fixed-exposure obstruction does not assert equivalence with a common fixed alternative law for all increasing exposures. | Continue the expanding-range remainder/derivative, covariance and selected-root work. It does not qualify the finite few-rating designs by itself. |

The immediate next gate is usefulness and target preservation of these
specified candidates, not a new large simulation or public API. Formal JML
inference remains open; this decision neither withdraws the agreed outcome nor
claims an impossible universal guarantee. The ongoing normal-population R=50
comparison, historical larger-N evidence and other designs retain their scopes.

## October 3: finite conditional intervals and certified score envelopes

**Question and result.** Can the fixed-exposure candidates produce useful
restrictions using observed data, without a known generating ability law?
For the saved N20 PCM data, two primary contrasts have finite exact-conditional
reference intervals. For the retained 2 x 2 GPCM witness, the expectation
envelope can be bounded over **all real abilities**, and the resulting tests
can exclude some response datasets even at N20. The latter is only a
non-vacuity witness at one structural parameter point; practical power and
full projected GPCM interval width remain unassessed.

### A. PCM: a conditional procedure using the saved responses

The input remains 20 Persons, Rater 3 x Criterion 3, two assigned Raters and
all three Criteria per Person, categories 0--3 and six ratings per Person.
The PCM has unit slopes, Criterion-owned centered step deviations, additive
centered severity facets, unit weights and independent responses conditional
on Person ability and the fixed facets. The following are two separate
conditional analyses of the prespecified Rater 1-minus-2 and Criterion
1-minus-2 contrasts. Each has pointwise 95% coverage under this model. They
are not a simultaneous 95% family, a covariance for public JML, or intervals
for all ten structural coordinates.

**Rater contrast.** Pair the two assigned Raters within each Person and
Criterion; every response belongs to exactly one pair in this analysis.
Condition on each pair's unordered scores {a,b}. The two orderings have
log probability ratio

    log[P((a,b) | {a,b}) / P((b,a) | {a,b})]
      = -(severity_r - severity_s) * (a-b).

Person ability, Criterion severity and the Criterion's category steps cancel.
Conditional ordering probabilities do not depend on ability. Consequently
the disjoint pairs remain conditionally independent after mixing over
abilities, under the stated response model. This argument would fail with
unmodelled residual dependence; repeated ratings are not automatically
independent because they form pairs.

Let T_r be the sum of scores assigned to Rater r after reordering the fixed
unordered pairs. Their total T is fixed by conditioning. Write
`psi=b1-b2`, `zeta=b1+b2`, and `b3=-zeta`. Conditioning additionally on T_3
leaves a scalar exponential family

    P_psi(T_1=t | T_3, unordered pairs)
       proportional to h(t) exp(-psi*t),

where h(t) is the integer count of compatible pair orientations. This uses
the comparisons involving Rater 3 while removing the remaining Rater
nuisance coordinate. Equal-score pairs have one distinct orientation and
zero information, but remain in the accounting.

**Criterion contrast.** Pair Criteria 1 and 2 within each Person and assigned
Rater. These pairs are disjoint within this analysis. Criterion 3 is not used
in this reference construction; it remains part of the original fit and the
separate Rater analysis. Define category utility differences

    D_k = -k*(c1-c2) - [cumulative_step_1(k)-cumulative_step_2(k)].

After conditioning on the unordered category pair, its orientation probability
is proportional to exp(D_a) when Criterion 1 receives category a. The Person
and Rater terms cancel. Here D_0=0, and centered steps give
`D_3=-3*(c1-c2)`. Let n_k count how often Criterion 1 receives category k
among the selected pairs. Conditioning on n_1 and n_2 removes D_1 and D_2:

    P_psi(n_3=t | n_1,n_2, unordered pairs)
       proportional to h(t) exp(-3*psi*t),   psi=c1-c2.

This retains information from intermediate-category comparisons; it is not
an analysis restricted to observed all-low/all-high pairs. Step ownership,
centering and the unit-slope restriction are essential to this derivation.
The conditional treatment of structural nuisance parameters is consistent
with the general exact-conditional framework discussed by
[Skrondal and Rabe-Hesketh, Section 8.2](https://link.springer.com/article/10.1007/s11336-021-09816-8).
The specific disjoint-pair construction and target maps here are derived for
this saved PCM design, rather than imported as a theorem for every mfrmr model.

**Counting, inversion and numerical coverage protection.** The
[research implementation](jml-pcm-conditional-intervals-20261003.py) computes
integer h(t) by convolution, retaining every compatible orientation. It only
prunes partial nuisance counts that already exceed the conditioned totals;
all subsequent increments are nonnegative. With natural parameter
`lambda=-scale*psi`, its inclusive lower and upper tails are monotone in
`z=exp(lambda)>0`. Equal-tail inversion at alpha/2=1/40 uses rational brackets
and exact integer polynomial comparisons. A boundary statistic retains its
infinite endpoint; a singleton support returns the whole real line.

Log transformation of each endpoint uses range reduction and the rational
series `log(r)=2 sum_j w^(2j+1)/(2j+1)`, with w=(r-1)/(r+1), together with a
positive remainder bound. The final six-decimal endpoints round **outward**.
Thus neither a finite search window nor a floating-point root tolerance is
used to turn a one-sided or unavailable conclusion into a finite interval.
Validity follows from the exact conditional tail construction, not from a
normal approximation or a new empirical coverage experiment.

| Contrast | Pairs / unequal-score pairs | Conditional statistic support / observed | Outward 95% interval |
| --- | ---: | --- | --- |
| Rater 1-minus-2 | 60 / 40 | 38,...,65 / 55 | [-1.176306, 0.339916] |
| Criterion 1-minus-2 | 40 / 26 | 2,...,10 / 7 | [-0.925717, 0.497008] |

Both intervals contain zero. In this sample neither comparison separates the
two levels at the stated conditional 5% level. The intervals are finite but
wide; this is evidence of an executable reference with retained uncertainty,
not adequate precision for an unspecified practical decision. No generating
truth, fitted ability distribution, public JML estimate or estimated SE is
an input to the interval endpoints. Existing fitted values are used only in
the independent likelihood-identity check below.

Checks include exhaustive versus convolution counts, known one-trial tail
limits, uninformative and boundary strata, finite interior endpoints, and exact
reflection when the target levels are exchanged. A separate calculation from
the saved PCM's literal category utilities verifies the pair log-odds identity
at saved abilities and after adding 2: maximum discrepancy 2.45e-15. Weighted
convolution using these literal ordering probabilities, followed by nuisance
conditioning, agrees with the integer-count exponential family to 6.11e-16
for Rater and 3.20e-16 for Criterion.

The first check stopped on an inconsistent artificial observed-statistic
fixture before analyzing the saved data. That fixture was corrected; the
initial script is retained. No statistical cutoff or interval formula was
relaxed. Evidence is in `validation-results/jml-conditional-intervals-20261003/`:
checksum-bound input, integer counts, rational root brackets, intervals and
independent probability checks. This is research-only reference inference;
there is no CML feature announcement or JML API promotion.

### B. GPCM: certified mean envelopes at the retained parameter point

Reuse the previous complete Rater 2 x Criterion 2 binary witness, with slopes
2 and 1/2, Rater half-contrast 2 log(6/5), and Criterion half-contrast
2 log(11/10). Evaluate the two **location components** of the ordinary and
orders-2/4 profile-score equations at this parameter point. These components
are the same location components of the full GPCM correction at that point;
the slope-score envelope is not evaluated here. No new response data, Person
sample or structural calibration fit is constructed.

The [bound calculation](jml-gpcm-score-envelope-20261003.py) uses
`x=exp(theta/2)>0`. Response probabilities are rational functions of x, with
pattern numerator `h_y*x^(4*S_plus+S_minus)` and common denominator of degree
10. The nine owner-total states have seven nonextreme ability profiles. Each
is bracketed by exact rational evaluation of its monotone weighted-score
equation; the two extreme states retain absorbing transitions and zero scores.

To keep the correction arithmetic finite and explicit, round the reference
transition probabilities to a nonnegative integer grid of denominator 2^60,
preserving each row sum exactly. Round each raw location score on that same
grid. This is an approximation with a retained bound, not exact finite-MLE
profiling. If e0 bounds the raw-score error, eP bounds the kernel's maximum
row L1 error, and U0_tilde is the rounded raw score, then

    ||U_k-U_k_tilde||_infinity
      <= 2^k*e0 + k*2^(k-1)*eP*||U0_tilde||_infinity.

The second term is zero at k=0. This follows by telescoping powers of the two
operators I-P, each of norm at most 2. The profile brackets bound Bernoulli
marginal errors, and product-distribution L1 distance is at most twice their
sum. Kernel rounding contributes at most 30/2^60 for 16 states. Correction
powers are then computed with integer numerators and known common denominators.
The resulting uniform location-score errors are at most 4.34e-13 here.

For each rounded score, group its generating expectation by the exponent t:

    m_tilde(x) = [sum_t n_t*x^t] / [sum_t d_t*x^t].

Map the entire domain to u=x/(1+x) in [0,1]. The numerator and denominator
have Bernstein coefficients `n_t/choose(10,t)` and `d_t/choose(10,t)`.
Nonnegative denominator coefficients imply that the rational function lies
between the smallest and largest coefficient ratios; a zero denominator
coefficient also has zero numerator. Exact de Casteljau subdivision refines
these bounds, including both infinite-ability limits. Add the uniform score
error to cover the actual corrected equation. Endpoint and interior evaluations
give lower/upper witnesses for the extrema; the final extremum enclosures are
less than 8.60e-7 wide.

| Order | Coordinate (location half-contrast score) | Whole-ability expectation envelope, displayed approximately |
| --- | --- | --- |
| 0 | Rater | [-0.262902, 0.032075] |
| 0 | Criterion | [-0.225040, 0.212844] |
| 2 | Rater | [-0.058890, 0.035908] |
| 2 | Criterion | [-0.052962, 0.071694] |
| 4 | Rater | [-0.023346, 0.020055] |
| 4 | Criterion | [-0.013938, 0.027959] |

The saved exact fractions are authoritative. These are bounds on **expected
estimating scores**, not on structural-parameter bias or interval endpoints.
The envelopes are strictly narrower than the raw response-score ranges.
Applying the previous two-component Hoeffding construction, with log(80) and
square roots also enclosed from above, supplies a rigorous constant-response-
pattern exclusion witness for each component/order at N=20,30,40,60,120,240,480.
This proves that the test at this particular beta need not accept every dataset.
Those constant-pattern arrays were not generated or fitted. Their rarity and
the test's practical power are not evaluated, and this does not prove a finite
joint confidence region or finite projected intervals when all GPCM parameters
vary. The observational-equivalence restriction still applies.

Linear, constant and interior-extremum rational-function checks pass. Direct
pattern probabilities agree exactly with the separate identification-witness
implementation. An initial version allowed integer zeros for missing polynomial
terms to become floats during division, so it did not furnish an exact rational
certificate. Its source and exploratory output are preserved. The corrected
version uses rational zeros and rejects any nonrational coefficient before
subdivision. Only `envelopes-rational.json` is the retained bound evidence;
its sources and all exact bounds are recorded in
`validation-results/jml-gpcm-score-envelope-20261003/`.

### C. What remains before any public inferential change

The PCM reference now returns actual finite intervals for its two named
contrasts and source assumptions. Extending that procedure to other owners,
contrasts, rosters or dependence needs a defined pairing/conditioning rule and
its own information/availability review. It does not replace the agreed JML
covariance and bias work or complete all-coordinate PCM inference.

The GPCM calculation closes one concrete gap: certified mean envelopes can be
nontrivial on the whole ability line. The remaining gate is conservative
projection while structural nuisance parameters vary, including log slopes,
and whether the resulting set retains useful finite bounds on the promised
contrasts. The rational-exponent device above is particular to the specified
slope ratio and is not a general free-slope implementation. No practical
order recommendation follows from the smaller envelopes in this one case.
Reuse these results when deciding that next calculation; do not launch a new
coverage study before specifying the complete interval procedure.

## October 3: free-slope GPCM projection for a nonowner contrast

**Question and decision.** Can a useful GPCM structural contrast interval be
obtained without fixing the slopes at a fitted value or truncating their search
range? Yes for the saved design's Rater 1-minus-2 contrast, using a conditional
reference procedure and the package's geometric-mean-one slope constraint.
This closes a contrast-specific nuisance-projection problem. It does not close
all-coordinate GPCM inference, qualify ordinary/corrected JML Wald intervals,
or make the previously derived score-envelope set computationally complete.

### 1. Conditional products retain the nonowner contrast

The setting is the same N20, Rater 3 x Criterion 3, two assigned Raters and all
three Criteria per Person, six ratings and categories 0--3. Allow **every**
positive Criterion slope a_c subject to product_c a_c=1. Steps are also
Criterion-owned; location effects are additive, weights are one, and responses
are independent conditional on abilities and the fixed facets. The observed
allocation must preserve that response law. These restrictions matter: pairing
ratings with different slope or step owners would not justify the cancellation.

Pair the two Raters within Person and Criterion, and condition on each
unordered score pair {u,v}. The implemented GPCM category utility is
`a_c * [k*(theta_i-b_r-c_c)-cumulative_step_c(k)]`. Therefore

    log[P((u,v) | {u,v}) / P((v,u) | {u,v})]
       = -a_c*(b_r-b_s)*(u-v).

Ability, Criterion location and its steps cancel for **all** their values;
no normal population or estimated ability is required. Pair probabilities do
not depend on ability, so their product remains valid after arbitrary ability
mixing under the stated conditional-independence model. Equal-score pairs,
including all-low/all-high pairs, stay in the accounting with one orientation
and zero contrast information.

For each Criterion c separately, condition also on its Rater-3 total T_3c.
The same centered-location argument as for PCM yields

    P_delta_c(T_1c=t | T_3c, unordered pairs for c)
       = h_c(t) exp(-delta_c*t) / sum_s h_c(s) exp(-delta_c*s),
    delta_c = a_c*psi,       psi=b_1-b_2.

The remaining Rater contrast is eliminated by conditioning. The h_c(t) are
integer orientation counts. The product parameters delta_c are observable-law
targets, not plug-in corrections based on a generating ability distribution.
This construction follows the conditional-nuisance principle reviewed by
[Skrondal and Rabe-Hesketh, Section 8.2](https://link.springer.com/article/10.1007/s11336-021-09816-8);
the specific product mapping and projection below are derived here for this
GPCM structure.

### 2. Coverage and projection over an unbounded slope domain

With C=3 declared slope owners, invert each scalar conditional law with
inclusive equal tails at alpha/(2C)=1/120. Each interval [L_c,U_c] has conditional
coverage at least 1-alpha/C. Bonferroni gives simultaneous coverage at least
1-alpha for the product vector; independence between these three intervals is
not required for that step.

Admissible products are either all zero (psi=0), or all have the same nonzero
sign. For the latter,

    psi = sign(delta_1) * (product_c abs(delta_c))^(1/C),
    a_c = delta_c/psi > 0,       product_c a_c=1.

These formulas prove both directions of the parameter mapping. Intersect the
product interval box with this sign constraint, map it to psi, and take the
closed interval hull. It therefore has coverage at least 95% for psi under
every permitted slope vector, including arbitrarily small/large positive
slopes. This is an analytic projection, not a finite slope grid or a locally
optimized nuisance value.

For example, if every component interval straddles zero, the projected hull is

    [ -(product_c abs(L_c))^(1/C), (product_c U_c)^(1/C) ].

If some component endpoints are zero or infinite, retain the corresponding
limits. Zero can be a closure point approached only as slopes escape; including
it is conservative. Incompatible signs may give an empty region. An empty
confidence set is a possible outcome of this construction, not a solver
failure to replace silently with a finite answer. A singleton conditional
support gives the whole line for its product; unobserved declared slope owners
cannot simply be dropped from the geometric-mean constraint. The present
implementation is explicitly restricted to the saved three-owner design.

### 3. Saved-data result and independent checks

The [reference implementation](jml-gpcm-conditional-projection-20261003.py)
reuses the earlier integer-count, exact tail-comparison and rational logarithm
helpers without changing their source. Conditional tails are inverted using
rational brackets; product intervals round outward. Projection then uses
integer comparisons for the cube roots and outward rounding again. No finite
ability/slope range, covariance estimate or asymptotic normal approximation
enters the endpoints.

| Criterion owner | Pairs / unequal-score pairs | Product delta_c interval (coverage at least 59/60 individually) |
| --- | ---: | --- |
| 1 | 20 / 16 | [-1.643617, 1.119184] |
| 2 | 20 / 12 | [-2.689020, 1.270990] |
| 3 | 20 / 12 | [-3.515233, 1.262158] |

The resulting **95% Rater 1-minus-2 interval is
[-2.495263, 1.215400]**. The earlier unit-slope PCM interval on the same responses
was [-1.176306, 0.339916]. This comparison changes the permitted model and the
conditioning/multiplicity construction. It is not an isolated estimate of the
cost of slope uncertainty, an efficiency ranking, or a coverage study. These
remain the saved PCM-generated responses; no GPCM-truth sample was generated.

The saved ordinary GPCM fit is checksum-verified and has exactly those same
responses, Criterion ownership and the required slope normalization. Its public
probability kernel verifies every category-pair log-odds identity, first at the
saved parameters and then with changed slopes, abilities, locations and steps.
Maximum discrepancy is 1.60e-14. Fitting, optimization and scalar root finding
are explicitly blocked during this R check. Its fitted values are verification
inputs only, not inputs to the interval.

Independent weighted convolution of those literal orientation probabilities,
followed by conditioning on T_3c, agrees with h_c(t) exp(-delta_c*t) to 1.12e-15.
Exhaustive orientation enumeration matches each owner's integer h_c exactly.
Exact rational tail-coverage checks at five named natural-parameter values per
owner pass; they are deterministic checks of the inversion argument, not
empirical or uniform coverage estimates. Known-tail, positive/negative/zero,
incompatible-sign, infinite-endpoint and slope-escape projection cases also
pass. Evidence and independent check sources are retained under
`validation-results/jml-gpcm-conditional-projection-20261003/`, with hashes.

### 4. The unresolved targets remain explicit

All three product intervals contain zero here. Consequently the region admits
psi=0 with **every** normalized positive slope vector. A finite Rater-difference
interval thus does not imply bounded slope intervals or a regular slope
covariance at zero contrast.

Criterion locations cancel identically from this conditional law. Its projected
Criterion-contrast set is the whole real line whenever its product region is
nonempty, as it is here. This loss is specific to the reference procedure;
the earlier unrestricted-mixture equivalence rules out generic shrinking
owner-location intervals but does not itself prove that every possible honest
interval must be unbounded. Informative owner-location inference still needs a
justified identifying restriction or a useful ambiguity-preserving procedure.

The next mathematical decision must retain this split: a nonowner contrast has
an observable finite-sample reference over free slopes; owner locations and
the full slope vector do not follow from it. Ordinary/corrected JML retain
their own bias, matching-covariance and selected-root obligations, including
the expanding-range growth argument. No public estimator, JML standard error,
study allocation or running numerical source is changed by this result.

## October 3: expanding-range remainders and local normal-population inference

**Question and outcome.** Can the compact-ability bias argument be transferred
to the unbounded normal populations in the roadmap, with its full evaluation
derivative and matching covariance? The following derivation supplies that
transfer for a **fixed finite independent-block family**, fixed correction
order, an interior structural neighborhood and a positive-definite limiting
Schur information. It covers the exact ordinary extended-profile equation
(k=0) and the exact finite-MLE plug-in equations at fixed k, including 2/4.
It is a local asymptotic result for those equations. Public solver selection,
numerical approximation, a usable small-exposure guarantee and general changed
designs remain separate. No observations, fits, finite differences or new
sampling experiments are used in this analytic increment.

### 1. Family, sampling law and quantities that stay fixed

There are finitely many fixed rosters g. One block in roster g contains e_gj
independent ratings at each cell j, where e_gj are fixed nonnegative integers,
not all zero. Repeat that block L times **independently conditional on the
Person ability**. Categories 0,...,K-1, facet levels, structural dimension and
the correction order k stay fixed. The per-rating model is

    p_j(y | t,beta) proportional to exp{a_j(beta)*y*t+h_jy(beta)}.

Work in a compact interior neighborhood B of beta_0, with positive slopes
bounded above and away from zero. The affine location/step and exponential
log-slope maps have bounded derivatives of every required fixed order on B.
Persons are independently free and unanchored; their extreme response patterns
retain extended profiles and zero structural score. Fixed-slope RSM/PCM meet
these model conditions at k=0. This does not introduce their corrected versions
as package features.

For each fixed roster, Persons have independent abilities from a normal law
with bounded mean and variance: |mu_g|<=mu_max and
sigma_g<=sigma_max<infinity. The law is
held fixed during evaluation-parameter differentiation. The argument uses
its tail and moment properties, not an estimated normal population in JML.
Take fixed roster counts N_g with N_g/N tending to pi_g>0. Use the **actual**
proportions pi_g,N=N_g/N in finite-N population centering; otherwise a changing
allocation can introduce an extra centering term. Both N and L grow for the
sampling result. Missing cells can be part of a predeclared fixed roster;
outcome-dependent selection and residual dependence are not justified by
this representation.

Write W_k,L=U_k,L/L for the exact normalized negative equation. P_beta,L is
the finite-MLE plug-in response transition, Q=I-P, and W_k=Q^k W_0. Let

    m_k,L^beta(t) = E_beta,t[W_k,L(Y;beta)],
    K_beta,L f(t) = E_beta,t[f(t_hat_beta(Y))].

The diagonal mean m has generating and evaluation beta equal. The actual
estimating-equation Jacobian instead differentiates
`G_k,L,N(beta)=sum_g pi_g,N E_beta0,Fg[W_k,L(Y;beta)]`, with beta_0 and F_g fixed.
The distinction is retained throughout the proof.

### 2. Exponential, rather than unspecified compact-set, constants

Let Z(X) be the finite vector of cell/category counts in one block and
z_0(theta)=E_beta0,theta Z. The L-block empirical mean Z_bar is an average of
bounded independent vectors conditional on theta. Finite categories and the
bounds on a_j and h_jy give constants c,C>0 such that

    min_j,y p_j(y | t,beta) >= c*exp(-C*abs(t)),
    I_beta(t)=Var_beta,t(T_beta(X)) >= c*exp(-C*abs(t)).       (G1)

For the second inequality use any observed cell's adjacent-category pair in
`Var(Y)=sum_{u<v} p_u p_v (u-v)^2`; fixed independent cells contribute positive
terms. Fixed-order derivatives of probabilities, cumulants and logit features
grow at most polynomially in |t| before division by I. Implicit derivatives of
the inverse mean map divide by finite powers of I and combine finitely many
such derivatives. They therefore grow at most as

    C_r*(1+abs(t))^d_r*exp(C_r*abs(t))                       (G2)

at each fixed derivative order r. The same closure under finite sums, products
and differentiation holds for the expansion coefficients b_j and D_j below.
No constant of the form exp(C*t^2) is needed here.

For off-truth evaluation, define t_beta(theta) by

    mu_beta(t_beta(theta)) = E_beta0,theta[T_beta(X)].

This mean is strictly inside the evaluation support. At either end, its
distance to the endpoint is bounded above and below by constants times
exponentials in |theta|, uniformly over beta in B. The same is true for
mu_beta(t) as a function of t. Inverting those bounds proves
`abs(t_beta(theta)) <= C*(1+abs(theta))`. Thus (G2) also holds, with changed
constants, for the off-truth inverse and its evaluation-beta derivatives.
This step prevents using a compact evaluation neighborhood as though it also
bounded every fitted or generating ability.

Choose a smooth radius comparable to
`rho(theta)=c*exp(-C*sqrt(1+theta^2))`, small enough that
`||Z_bar-z_0(theta)||<=2*rho(theta)` keeps each evaluation profile within one
unit of t_beta(theta), uniformly on B. The normalized raw profile score,
inverse mean map and their required derivatives on this neighborhood obey
an exponential-polynomial bound in |theta|. A bounded-vector concentration
bound and a union over the fixed number of coordinates give

    P(||Z_bar-z_0(theta)||>rho(theta))
       <= C*exp{-c*L*exp(-C*abs(theta))}.                   (G3)

The constant C in the exponent absorbs the square of the radius. This is the
usual bounded-sum concentration argument; it is not a fitted cutoff or a
selection of Persons. The earlier worst-pattern bounds supply polynomial
envelopes in L and 1+log(L) for scores and each required fixed-order derivative
on the complement, including all nonextreme fitted profiles. Extreme rows
are absorbing and have identically zero score and derivatives.

### 3. A finite-order expansion with a tracked remainder

Insert a smooth cutoff between rho and 2*rho and Taylor-expand the local
smooth function of Z_bar about z_0. The cutoff derivatives cost only further
finite powers of 1/rho, and hence still satisfy (G2). For centered bounded
block vectors Delta=Z_bar-z_0, each tensor moment has the exact partition form

    E[Delta^{tensor m}]
      = sum_{partitions with no singleton blocks}
          (L)_{number of blocks}/L^m * product(block central moments).

Here (L)_b is the falling factorial. In particular the powers of 1/L are
integers, beginning at ceil(m/2), and the coefficients and their fixed-order
parameter derivatives obey (G2). This also explains why differentiating the
moment expansion need not cost powers of L in its retained coefficients.

For clarity about the remainder, to obtain an expansion through L^-M with s
parameter derivatives, a Taylor degree at least 2M+4s+3 suffices. Differentiating
the generating probabilities costs at most L^s times a polynomial in the
ability, while differentiating the centered Taylor remainder reduces its
vanishing order by at most s. The remaining even-moment bounds then give
L^-M-1 or better. Terms beyond order M in the exact moment polynomial already
have that order with their derivatives. Cutoff-boundary and noncentral terms
are bounded using (G3) and the global polynomial envelopes. Constants may
depend on M,s,B and the roster; none depends on L or the cutoff radius T.

Consequently, on |theta|<=T, each relevant fixed-order remainder has the form

    ||remainder||_(C^s)
       <= C*(1+T)^d*exp(C*T) *
          [L^(-M-1) + L^A*(1+log L)^B*
                         exp{-c*L*exp(-C*T)}].             (G4)

There is also a pointwise exponential-polynomial envelope for the first term
before taking the supremum over theta. Finite powers in (G4) are sufficient;
their optimal values are not claimed. This is more specific than knowing
that each compact interval has some finite remainder constant.

Apply this expansion first to W_0 and then to a smooth f composed with the
inverse mean map. At generating/evaluation truth it yields

    m_0,L^beta(theta) = sum_{r=1}^M b_r,beta(theta)/L^r + R_0,M,
    K_beta,L f = f + sum_{r=1}^M D_r,beta f/L^r + R_f,M,
    D_1 f = f''/(2I) - kappa_3*f'/(2I^2),
    b_1 = C_moment/(2I) - A_moment*kappa_3/(2I^2).           (G5)

The moment quantities in b_1 are the previously derived ones, including the
beta dependence of T. The constant term of m_0 is zero. The coefficient
functions have (G2) bounds through any required fixed derivative order.
For analytical coefficient functions that lack finite limits at infinity,
assign bounded endpoint values when applying K. At nonextreme profiles
|t_hat|<=C*(1+log L), so their values have polynomial L envelopes; changing
their extreme endpoint extension affects only the noncentral remainder.
The actual m_k and score endpoint values remain exactly zero.

### 4. Fixed correction orders, full derivatives and normal integration

Iterated expectation gives `m_k=(I-K)^k m_0` exactly. To expand order k,
start with the raw expansion through at least M=k+1, together with the
necessary finite derivative orders. Expand K on each retained coefficient.
The leading term is

    m_k,L^beta(theta)
      = c_k,beta(theta)/L^(k+1) + R_k,L(theta),
    c_k,beta = (-D_1,beta)^k b_1,beta.                      (G6)

The remainder has (G4) with M=k+1. A useful point is that one need not claim
an O(1/L) improvement for an arbitrary remainder: the original remainder was
already carried through order k+1, and ||I-K||<=2 preserves its order for
fixed k. Use neighborhoods |theta|<=T,T+1,...,T+k+1. A transition exits its
next neighborhood only on (G3); a union over the fixed number of transitions
and the global polynomial bounds controls these paths. Retained coefficient
compositions are finite and need not commute. Derivatives use the deeper
Taylor expansion above, rather than an unproved sharp operator inequality
requiring only two extra derivatives.

The full evaluation derivative can also be tracked without freezing P.
Telescoping the exact recursion gives the pointwise identity

    W_k,L(y;beta)
      = W_0,L(y;beta)
        - sum_{j=0}^{k-1} m_j,L^beta(t_hat_beta(y)).          (G7)

This matches the accumulation of `apply_transition(mean_raw-adjustment)` in
`R/core-jml-adjustment.R`. Differentiating (G7) includes both the parameter
dependence of the bootstrap mean and its fitted-ability argument. It therefore
includes the transition derivative that a frozen-kernel calculation omits.
Using (G2)--(G6), this correction is O(L^-1) in normalized score and in each
required fixed evaluation derivative on the central region, with tracked
exponential-polynomial constants. At beta != beta_0 its expectation is taken
under the **fixed** generating beta_0 and F_g; differentiating the diagonal
mean m^beta alone is not substituted for that Jacobian.

Now take `T_L=mu_max+sigma_max*sqrt(2*q*log L)` and q sufficiently large for the
finite list of moment/derivative bounds. Then exp(C*T_L)=L^o(1), whereas the second term
of (G4) is smaller than any fixed inverse power of L. The earlier normal-tail
bounds control scores, their full derivatives and score second moments outside
T_L. In addition, the pointwise first-term bound integrates to a finite
constant because a bounded-mean/variance normal family uniformly integrates
every fixed exponential-polynomial envelope. Taking q with a strict margin
over the relevant polynomial envelope powers gives

    G_k,L,N(beta_0) = c_bar_k,N/L^(k+1) + O(L^(-k-2)),
    c_bar_k,N = sum_g pi_g,N E_Fg[c_k,g(theta)].              (G8)

This slightly sharper integrated remainder uses its pointwise envelope; merely
taking the central supremum would give L^(-k-2+o(1)). No truncation of the ability
generator or removal of extreme responses occurs. Similarly, uniformly on a
sufficiently small fixed evaluation neighborhood, with two beta derivatives,

    G_k,L,N(beta) = V_N(beta) + O(L^-1),
    V_N(beta) = sum_g pi_g,N E_Fg[v_g(beta,theta)],
    V_N(beta_0)=0,     D_beta V_N(beta_0)=J_N,                (G9)

where v_g and the joint-information Schur complement J_g(theta) were defined
in the compact derivation, and J_N=sum_g pi_g,N E_Fg[J_g(theta)]. This supplies
the off-truth derivative transfer that score means and normal tails alone did
not establish.

### 5. Local root, matching covariance and empirical inference

Assume J=lim J_N is positive definite in the declared structural coordinates.
This is a substantive identification/information condition, not a consequence
of the normal ability law or of a connected facet graph alone. By (G9), a
small ball around beta_0 has uniformly positive symmetric part of the mean
Jacobian for large L,N. Its boundary points outward and the equation has one
root within that ball. Taylor expansion using (G8)--(G9) gives

    beta*_(k,L,N)-beta_0
      = -J_N^-1 c_bar_k,N/L^(k+1) + O(L^(-k-2)).            (G10)

This is the nearby population root, not a claim of global uniqueness or of
which root the public optimizer selects. The use of actual pi_g,N avoids an
unjustified rate assumption on convergence of the roster proportions.

For a Person's block define the efficient negative score at truth

    xi_g(X,theta) = -(D_beta-E D_beta)
       + I_beta,theta I_theta,theta^-1 (T-mu).

Conditional on theta it has mean zero and covariance J_g(theta). The same
central Taylor expansion, conditional even-moment bounds and tail split give

    U_k,L(Y;beta_0) = sum_{ell=1}^L xi_g(X_ell,theta) + R_k,L,
    E[||R_k,L||^r] <= C_r                                  (G11)

for each fixed required r, in particular r=2,4. The raw Taylor remainder is
L times a quadratic empirical deviation with the (G2) envelope. By (G7), the
unnormalized correction begins at L*m_0=O(1) and has the same moment bound.
Bad empirical events use (G3); true-ability tails use q chosen for that moment
and the global bounds. The shift from beta_0 to (G10) changes U by an O(1)
term in these moment norms (or smaller for k>0), since its first derivative
is of order L with an integrable envelope.

Let A_L,N=sum_g pi_g,N E_g[D_beta U_k,L] and
B_L,N=sum_g pi_g,N Var_g(U_k,L), evaluated at the local population root.
The within-roster variance includes both response and ability variation.
From (G9)--(G11),

    A_L,N/L -> J,       B_L,N/L -> J,
    N*L*{A_L,N^-1 B_L,N A_L,N^-T/N} -> J^-1.                (G12)

The fourth moments of the centered U/sqrt(L) are uniformly bounded. Independent
Persons therefore satisfy the triangular-array Lindeberg condition as N grows.
The integrated derivative bounds supply a uniform law of large numbers on
the local ball: pointwise second-moment bounds give convergence on finite
nets, and the next derivative's integrable envelope controls the gaps.
Consequently an exact sample root in that ball exists uniquely with probability
tending to one and, if that local branch is selected,

    sqrt(N*L)*(beta_hat-beta*_(k,L,N)) -> Normal(0,J^-1).     (G13)

For fixed roster counts, the empirical meat must center actual Person scores
within each roster; every N_g must grow. With
`A_hat=N^-1 sum_i D_beta U_i` and
`B_hat=N^-1 sum_g sum_(i in g)(U_i-U_bar_g)(U_i-U_bar_g)'`,
the complete sandwich `V_hat=A_hat^-1 B_hat A_hat^-T/N` satisfies
`N*L*V_hat -> J^-1`. Substituting beta_hat is justified by the same local
derivative envelopes. A conditional owner-total mean is not the full Person
contribution, and inverse curvature alone is not the finite-L sandwich.

Combining (G10) and (G13), a sufficient condition for intervals to be centered
at structural truth is

    N/L^(2k+1) -> 0.                                      (G14)

Thus the sufficient restrictions are N/L -> 0 at k=0, N/L^5 -> 0 at k=2 and
N/L^9 -> 0 at k=4, under the stated family, information and local-branch
conditions. These concern a population-root displacement relative to its SE,
not an exact finite-sample expectation of the selected estimator. If the
leading contrast coefficient vanishes the restriction can be weaker; if it
does not, root-centered standard errors alone do not remove the displacement.
The rates do not rank finite-L correction orders or give a practical minimum L.

### 6. What this derivation changes, and what it does not

The former expanding-range gap is now addressed for this restricted family:
the constants are tracked, the fixed-order remainder survives the actual
recursion, the evaluation derivative retains its two arguments, and the
normal mixture is integrated before the local-root and sandwich conclusions.
The analytic proof is recorded here for review; it is not independent empirical
coverage evidence or a theorem imported from a different estimator. The
primary paper's [Section 8.1](https://arxiv.org/html/2301.13736v2#S8.SS1)
distinguishes the MLE plug-in transition, while its broader high-order statement
in Section 4.2 is a conjecture. The present argument relies on the finite
exponential-family block structure and the explicit bounds above.

The following obligations remain:

* **Actual estimator and branch.** A public numerical result must approximate
  the specified local root by o_p((N*L)^-1/2), with a compatible full covariance.
  The saved five-fit bridge is finite-sample evidence, not an algorithmic branch
  selection theorem. Ordinary printed screening SEs are not the sandwich in
  (G12). Corrected evaluation must retain its full transition derivative.
* **Finite exposure.** N increasing with six or another fixed number of
  ratings per Person does not satisfy (G14). The fixed-exposure counterexamples,
  nonidentification results and contrast-specific conditional references remain
  relevant. Normal abilities alone do not make fixed-L JML unbiased.
* **Numerical availability.** The current corrected calculation has a finite
  owner-state cap, profile tolerances and underflow refusals. This theorem for
  the exact equation is not an executable L-to-infinity sequence of public
  calls with fixed defaults. Mathematical validity and numerical feasibility
  remain different gates.
* **Design and sampling scope.** Increasing facet dimension, slopes approaching
  zero/infinity along the asymptotic sequence, arbitrarily weak links, dependence,
  response-dependent missingness and a different roster sampling law are not
  covered without their own argument. Every fixed admissible design can have
  its own constants and J; this is not uniform qualification across the package.

No package code, interval default, correction-order choice, simulation
allocation or public claim is changed. No new numerical experiment is needed
to illustrate the derived rate again: retain the existing finite-L failures
and slow-convergence evidence when deciding the next practical inference gate.

## October 3: certified ordinary-GPCM local roots at saved public estimates

The next missing numerical implication was local existence: a small score and
positive Hessian at one GPCM point do not imply a root in its neighborhood.
This section derives a sufficient neighborhood bound with varying slopes,
then verifies it by outward interval arithmetic on the same five saved fits.
It uses no new response generation, structural fitting or nuisance profiling.
It qualifies the correspondence of these finite public structural coordinates
to a local mathematical root. It does not identify that root with the
near-truth population branch in (G13), establish global GPCM optimality, or
control structural-truth bias/coverage at fixed exposure.

### 1. Complete the nuisance square before bounding the neighborhood

Let f be the summed ordinary negative log likelihood over nonextreme Persons.
Independently free extreme Persons have identically zero extended-profile
contributions for every finite beta with positive slopes; omit their ability
coordinates from this local problem. Their membership in the original sample
and covariance/availability denominators is retained. The center contains the
**public structural beta**, together with the saved approximate nonextreme
Person profiles. Retain their nonzero nuisance-score residuals.

Write each center Hessian in nuisance/structural blocks as

    H_i = [ h_i   c_i' ],       S_i = H_beta,beta,i - c_i c_i'/h_i,
          [ c_i   H_bb ]        S = sum_i S_i.

Suppose h_i>0 and S is positive definite. Choose B with B'SB=I and introduce
coordinates w=(v,t) by

    delta beta    = B t,
    delta theta_i = v_i/sqrt(h_i) - c_i'B t/h_i.             (L1)

The total Hessian in these coordinates is I at the center, and each individual
Hessian has blocks 1, zero cross block, and B'S_i B. The transformed gradient
norm is eta, including all g_theta,i/sqrt(h_i) and the sum of
B'(g_beta,i-c_i g_theta,i/h_i). This handles saved scalar-profile residuals
without pretending they are exact zeros. In the interval implementation B,
nu_i and tau_i in `delta theta_i=nu_i v_i+tau_i't` are fixed binary numbers.
Instead of assuming exact whitening, it recomputes the entire center Hessian
and bounds `||H_w(0)-I|| <= epsilon`.

For one rating's utility, the transformed representation is

    u_k(w) = a0 exp(gamma't) { h0_k + f_vk v_i + f_tk't }.

Here h0_k is the unscaled center utility, f_vk=k*nu_i,
f_tk=B'D_k+k*tau_i and gamma=B's_j, with D and s extended by zero columns to
the full structural coordinates. For every category pair k,l, on ||w||<=R,
put s=||gamma||, F_v=|f_vk-f_vl|, F_t=||f_tk-f_tl|| and

    H = |h0_k-h0_l| + R sqrt(F_v^2+F_t^2),
    A = a0 exp(R s).

Taking the maximum over category pairs of each expression below bounds the
corresponding category range, uniformly over unit directional arguments:

    A_v   = max A F_v,               A_t   = max A(F_t+H s),
    H_vt  = max A F_v s,             H_tt  = max A(2 F_t s+H s^2),
    T_vtt = max A F_v s^2,           T_ttt = max A(3 F_t s^2+H s^3).

For log-sum-exp minus the observed utility, the third derivative is the mean
utility third derivative minus its observed value, plus three covariance
terms between utility Hessians and gradients, plus their third central
moment. For scalar variables with ranges R_x,R_y,R_z,
`|Cov(X,Y)|<=R_x R_y/4` and
`|E[(X-EX)(Y-EY)(Z-EZ)]|<=R_x R_y R_z/4`.
The latter follows from a supremum bound on one centered variable and
Cauchy--Schwarz plus the range variance bound on the other two. Therefore
rating-level mixed-block bounds are

    a = A_v^3/4,
    b = A_v^2 A_t/4 + A_v H_vt/2,
    c = A_v A_t^2/4 + (A_v H_tt+2 A_t H_vt)/4 + T_vtt,
    d = A_t^3/4 + 3 A_t H_tt/4 + T_ttt.                    (L2)

Sum these within each Person. Since nuisance directions are separate scalars
but t is shared, Holder/Cauchy--Schwarz gives the full trilinear bound

    ||D^3 f(w)|| <= M
      = max_i a_i + 3 max_i b_i + 3 sqrt(sum_i c_i^2) + sum_i d_i. (L3)

For three nuisance arguments use `sum |x_i y_i z_i|<=||x||||y||||z||`;
for two use Cauchy--Schwarz; for one use the l2 norm of c_i. This avoids
summing every nuisance-only bound over N. It does not assume that increasing
N repairs weak structural information.

### 2. A checkable contraction and an error bound

For T(w)=w-grad f(w), the derivative and self-map bounds are

    ||DT(w)|| <= epsilon+M R,
    ||T(w)||  <= eta+epsilon R+M R^2/2.                    (L4)

Thus, if the first bound is below one and the second is at most R, the closed
ball is invariant and T is a contraction. There is a unique stationary point
in that ball. Its Hessian is positive definite throughout the ball, making
it a strict local minimum. Each nonextreme Person's nuisance likelihood is
strictly convex with a unique finite minimum, so this joint root gives a
local minimum of the extended profile. This statement does not exclude
other GPCM minima outside the ball.

For epsilon<1, try R=2 eta/(1-epsilon). A sufficient condition is
`2 M eta < (1-epsilon)^2`, with M evaluated over that entire trial ball.
The smaller certified radius is

    r = 2 eta / {1-epsilon + sqrt((1-epsilon)^2-2 M eta)},
    q = epsilon+M r < 1.                                 (L5)

The implementation rounds the denominator downward, then checks both (L4)
inequalities at the resulting rational radius exactly. For any structural
contrast c, `|c'(beta_root-beta_public)|<=r ||B'c||`; coordinate j uses the
norm of row j of B. The interval implementation uses `r ||B||_F` as a simple
conservative Euclidean bound and gives objective-gap bound
`eta^2/{2(1-q)}`. Neither bound is a confidence interval.

This also supplies a useful numerical stopping requirement for the growth
argument: if the selected local branch has S of order NL, and a valid
certificate has r=o_p(1), its structural numerical error is
`o_p((NL)^-1/2)`. The branch and information assumptions are still needed.
Five small finite radii do not establish either assumption along a general
asymptotic sequence. A corrected equation has a generally nonsymmetric full
Jacobian and is not covered by this ordinary-likelihood argument.

### 3. Outward verification on the five retained fits

The source and immutable evidence are:

* `jml-gpcm-local-root-bound-20261003.R` and
  `validation-results/jml-gpcm-local-root-bound-20261003/`: initial
  floating-point evaluation of (L1)--(L5), including the empirical-covariance
  perturbation calculation below.
* `jml-gpcm-local-root-interval-export-20261003.R`: checksum-bound export of
  original designs, responses, saved coordinates and a fixed preconditioner
  as hexadecimal binary numbers. Optimization and profiling are explicitly
  refused during export.
* `jml-gpcm-local-root-interval-20261003.py` and
  `validation-results/jml-gpcm-local-root-interval-20261003/certificate.json`:
  independent interval evaluation of the actual transformed category
  likelihood gradients/Hessians and neighborhood bounds. All five certificates
  passed. The JSON retains exact rational upper bounds and self-map margins;
  its display fields are only decimal approximations.

The calculation uses 128-bit interval basic arithmetic and square root from
mpmath 1.3.0. Its installed implementation rounds endpoints outward. Exponential
bounds are computed explicitly: reduce a nonnegative argument below 1/2,
use the Taylor sum through degree 32 with tail
`(x^33/33!)/(1-x/34)`, then square back; negative arguments use reciprocals.
It therefore does not depend on high-level interval differentiation,
optimization, matrix decompositions, or an unchecked transcendental evaluation.
The [mpmath interval documentation](https://mpmath.org/doc/current/contexts.html#arbitrary-precision-interval-arithmetic-iv)
marks general interval support experimental; the arithmetic dependency and
its version are retained, rather than treating this as a formally verified
software proof. Exact final rational inequalities protect against rounding
in the acceptance decision.

Independent interval gradients/Hessians agree with the transformed saved
bridge derivatives to at most 2.52e-15. The rigorously bounded initial Hessian
identity errors epsilon range from 1.35e-15 to 5.51e-15. Checks also include an
exact quadratic root, a worst-case cubic self-map boundary, refusal at a
noncontractive boundary and a too-small radius, exact binary conversion,
rational Taylor enclosures of exp(1) and exp(-1), exp(0), and sqrt(2).
No finite-difference steps or rerun profile optimizations enter this evidence.

The following reported upper bounds are rounded **up**. Facet counts exclude
Person. Parameter distances refer to the free coordinates of the recorded
centered-facet/step and sum-zero log-slope representation; a derived level or
contrast uses its own row/contrast map.

| Saved case | Model, N | Non-Person levels | Extreme Persons | Local metric radius upper | Largest free-coordinate error upper | Euclidean structural error upper |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| AB20-PCM | PCM, 20 | 3 x 3 | 0 | 1.213e-5 | 6.052e-6 | 1.521e-5 |
| AB20-GPCM | GPCM, 20 | 3 x 3 | 0 | 2.483e-5 | 1.847e-5 | 3.922e-5 |
| pilot240-base | GPCM, 240 | 3 x 2 | 5 | 1.501e-6 | 1.481e-7 | 2.550e-7 |
| pilot20-task4 | GPCM, 20 | 3 x 2 x 4 | 1 | 8.317e-5 | 6.533e-5 | 9.148e-5 |
| pilot240-rater6 | GPCM, 240 | 6 x 2 | 3 | 2.480e-6 | 2.768e-7 | 7.099e-7 |

The largest refined curvature-change upper bound q is below 0.492, in the
three-facet N20 example. Consequently all these particular public structural
returns are close to a genuine strict local extended-profile minimum, including
the examples with extreme Persons. The claim is local and data-specific; it
supersedes an unverified Newton-step interpretation for these five points.
The older convex PCM argument has the additional global-minimum conclusion;
that conclusion does not transfer to the four GPCM examples.

### 4. Empirical covariance stability remains a separate question

There is also a deterministic perturbation bound for the *same* fixed-roster
empirical sandwich, separate from the interval certificates above. In exact
whitened coordinates let u_i=B'U_i be the retained structural scores, let
z_i be their within-roster centered versions, and let M0=sum_i z_i z_i'.
For a root within r, the individual score change is bounded by

    e_i = ||B'S_i B|| r + (b_i+2c_i+d_i)r^2/2
            + ||B'c_i/h_i|| |g_theta,i|.                  (L6)

Set e_i=0 for extreme Persons. Within roster g, centering changes the score
bound to d_i=e_i+mean_g e; this still applies to an extreme Person's centered
score. Therefore the meat change is at most
`E_M=sum_i {2||z_i|| d_i+d_i^2}`. With epsilon=0 in the ideal whitening
argument and q=Mr, the full transformed Hessian bound implies that the root
profile Schur complement lies between (1-q)I and (1+q)I. It follows that

    ||V_t,root - M0|| <=
      D_V = {E_M + ||M0|| q(2-q)}/(1-q)^2.                (L7)

Multiplying by B gives a structural covariance operator bound. If M0 is
positive definite, `D_V/lambda_min(M0)` bounds relative variance change
uniformly over structural contrasts, and
`r/sqrt(lambda_min(M0))` bounds root distance in units of the retained
contrast SD. This is variation of an observed matrix under numerical
perturbation, not accuracy relative to the true repeated-sample covariance.

The initial R evaluation of (L6)--(L7) remains **floating point**, not outward
certified by the point-root interval calculation. Its approximate uniform
relative-variance bounds are 0.182 for AB20-PCM, **46.92** for AB20-GPCM,
0.001570 for pilot240-base, and 0.004020 for pilot240-rater6. The N20 GPCM
bound is far too loose to establish close covariance, despite the small
point-root distance. The three-facet N20 case has singleton observed rosters,
so its fixed-roster empirical covariance remains unavailable; no uncentered
or inverse-Hessian fallback was substituted. Across the four available cases,
the floating-point all-contrast point distances are below 0.000115 stored
root SD. This comparison also does not validate those SDs as sampling errors.

The remaining method gates are therefore explicit: select/approximate the
near-truth branch under the intended regime, qualify the full covariance
for the declared sampling law, and control truth-centering bias. Fixed
few-rating inference, correction orders 2/4, changed facet dimension,
missingness/assignment and dependence keep their own requirements. No package
API, help/NEWS inference claim, worker source, simulation allocation or
running fit was changed by this local-root work.

## October 3: feasible inference baselines, roster replication and literature scope

The user correctly distinguishes a deliberately difficult assignment from an
intrinsic inability to estimate JML covariance. The preceding three-facet
example's refusal was predetermined by its design and the selected empirical
covariance rule. It is useful as a limit case, but should not drive the first
complete bias/SE/coverage implementation. Numerical root certificates are
supporting evidence; further certificates are not the next central deliverable.

### What the singleton refusal actually means

Here a roster is a Person's vector of counts over the declared facet cells.
It is neither a single rating nor a single rater. The current fixed-roster
sandwich describes independent **new Persons** from each roster population,
with counts n_g held fixed. It integrates their ability and response variation;
it is not the conditional-on-every-true-ability variance of repeatedly scoring
the same Persons.

At the specified population equation root beta*, write U_i for the actual
Person estimating contribution, mu_g=E(U_i|g), and Sigma_g=Var(U_i|g). Then

    A = N^-1 sum_g n_g E[D_beta U_i | g],
    B = N^-1 sum_g n_g Sigma_g,
    V = A^-1 B A^-T / N.                                  (R1)

For ordinary JML the derivative must match the extended-profile equation;
for corrected JML it must differentiate the full adjusted equation. At finite
exposure, the aggregate mean can vanish at beta* without every mu_g vanishing.
This explains the roster-specific empirical centering. Repeated iid Persons
within a roster allow its mean and covariance to be estimated without borrowing
a parametric mean/variance model from other rosters.

Two Persons per roster is the current computational minimum, not sufficient
statistical support. With G observed rosters and p free structural coordinates,
centered scores have rank at most N-G. A full positive-definite empirical meat
requires N-G>=p as well as actual full rank; the complete Jacobian must also
be nonsingular and numerically stable. For the retained consistency argument,
G stays fixed and every n_g grows, with the stated independence, moment and
local-root conditions. These requirements do not assert adequate coverage
at n_g=2, 5 or 10.

The retained N20, K=3, Rater3 x Criterion2 x Task4 pilot crosses three rater
pairs with four task pairs. Of its twelve patterns, eight contain two Persons
and four contain one. Consequently N-G=8<p=9. It fails both replication and
full-rank requirements before looking at responses. The broader K=4,
Criterion3 four-task condition is a different design, with p=15; its N20
exclusion is retained separately. This is not an all-three-facet-JML exclusion.

Nor is singleton refusal a universal theorem against fixed-design inference.
Known zero conditional score means, an explicit model for roster means and
variances, or a justified conservative procedure could support a different
estimator. For example, at a fixed root the uncentered second moment contains
B plus `N^-1 sum_g n_g mu_g mu_g'`; silently substituting it changes the variance
construction. A model-based bootstrap adds its population/generating-model
assumptions. Switching to random roster sampling changes the repeated-sampling
experiment. None of those alternatives is the current empirical fixed-roster
estimator, and none automatically corrects truth-centering bias.

### Checked feasible starting points

`jml-roster-design-audit-20261003.R` reads retained designs, checks roster sizes,
within-Person additive-location rank, parameter counts and correction state
counts, and replays four saved corrected covariance matrices. Evidence is in
`validation-results/jml-roster-design-audit-20261003/`. All 50 immutable N30
parent inputs were checked: every one has three rosters of ten Persons. No
responses were generated, fitted or reprofiled.

| Design | N, K | Non-Person levels | Persons per roster | p; N-G | Status |
| --- | --- | --- | --- | --- | --- |
| Retained basic pilot | 20, 3 | 3 x 2 | 7, 7, 6 | 6; 17 | Orders 2/4 already have consistent-root status and full-rank saved covariances. |
| Running paired A/B condition | 30, 4 | 3 x 3 | 10, 10, 10 | 12; 27 | Counts pass in all 50 inputs; first saved orders 2/4 have full-rank covariances. |
| Existing full-panel A/B condition | 20, 4 | 3 x 3 | 20 | 12; 19 | Count/rank feasibility; 1,000 owner-total states. Actual roots/SEs remain outcome-dependent. |
| Existing paired A/B condition | 20, 4 | 3 x 3 | 7, 7, 6 | 12; 17 | Count/rank feasibility; 343 owner-total states. Small groups still need evaluation. |
| Three-facet common incomplete block, prospective | 20, 3 | 3 x 2 x 4 | 20 | 9; 19 | Eight cells per Person, additive-location rank 6/6, 81 owner-total states. Design only. |
| Three-facet four replicated blocks, prospective | 20, 3 | 3 x 2 x 4 | 5, 5, 5, 5 | 9; 16 | Same eight-rating workload, additive-location rank 6/6, 81 states. Design only. |

The prospective common block contains (Rater,Criterion,Task) cells
(1,1,1), (2,2,1), (2,1,2), (3,2,2), (3,1,3), (1,2,3), (1,1,4), (2,2,4).
Every Person receives those eight cells. The second option uses five Persons
each with rater/task pairs (12/12), (23/23), (31/34), (12/41), crossing each pair
with both criteria. These are explicit demonstrations that N20, three facets
and eight ratings do not force singleton failure. They change the allocation
and estimable-information geometry; they are not replacements for the frozen
12-roster comparison. Additive rank alone does not prove global free-slope
identification, positive observed information or successful coverage. No new
50-dataset allocation or fit is launched for these examples.

### A small-group effect that belongs in the complete evaluation

At a **known fixed root**, the current centered meat has expectation
`N^-1 sum_g (n_g-1) Sigma_g`. Multiplying each roster cross-product by
n_g/(n_g-1) removes this particular deficit. The existing review had already
derived this fact; it must now be used in the evaluation rather than left as
an incidental limitation. This remains distinct from parameter-bias correction,
fitted-root uncertainty and small-sample critical-value choice.

The audit reconstructs all four retained covariances exactly from their saved
Person scores and full Jacobians. A separate Bessel-weighted sensitivity gives:

* N20 basic pilot, orders 2/4: coordinate SEs increase by approximately
  8.03%--8.90% (group sizes 7,7,6).
* N30 first paired dataset, orders 2/4: V becomes exactly (10/9)V, hence every
  contrast SE is multiplied by sqrt(10/9), approximately 1.05409.

These are deterministic saved-matrix replays, not observed bias or coverage
improvements. Keep the frozen public/current covariance as the original
comparison; add the explicitly named finite-roster normalization sensitivity
from saved scores after complete-condition collection. Do not choose between
them by which happens to give 95% in these data. Do not alter the running
worker or repeat fitting for this calculation.

### What comes from the literature, and what is specific to this project

The source review was repeated on October 3. Version labels matter: the
currently accessible Jochmans-hosted PDF says February 2, 2015; the Cambridge
2019 wrapper also contains that 2015 text. A seminar-hosted author manuscript
says February 17, 2024. The earlier retained 2017 review/hash remains a
historical record; these online PDFs should not all be labelled the 2017 text.

| Source | What it supports here | What it does not establish |
| --- | --- | --- |
| [Dhaene and Jochmans, February 17, 2024 manuscript, Sections 1.2--1.3](https://www.cerge-ei.cz/pdf/events/papers/3.%20dhaene&jochmans.pdf) | MLE plug-in recentering of the profile score, iteration, and uncertainty around the resulting root. Section 1.3 explicitly treats the general large-m iterative rationale as informal rather than supplying detailed regularity conditions. | A many-facet GPCM theorem, zero finite-exposure bias for orders 2/4, or N20/60 coverage. Their independent strata correspond to Persons here, not to our groups of Persons sharing an assignment. |
| [Dhaene and Weidner, arXiv v2, Sections 4.2 and 8.1](https://arxiv.org/html/2301.13736v2) | The operator representation and the distinction between posterior-averaged and MLE plug-in transitions. The stated generic high-order rate is Conjecture 1 in this version. | A proved general rate for the implemented GPCM equation. The posterior transition cannot replace the package's MLE plug-in operator without changing the procedure. |
| [Skrondal and Rabe-Hesketh, 2022, Sections 6 and 8](https://link.springer.com/article/10.1007/s11336-021-09816-8) | The incidental-parameter distinction between increasing Persons and increasing information per Person, and conditional-likelihood routes under their model conditions. | General free-slope GPCM conditional identification or equivalence of CML intervals to JML intervals. |
| [Zeileis, 2006](https://www.jstatsoft.org/article/view/v016i09) | General estimating-function/sandwich computation and the need to match contributions and derivatives to the fitted procedure. | The validity of a specific roster law, a bias remedy, or finite-sample GPCM coverage. |

The roster-centering decomposition, count/rank checks, finite-owner-total
implementation, normal-population growth argument and GPCM interval root
certificates in this repository are **project-specific derivations and
checks**, not published mfrmr theorems obtained merely by citing these papers.
In particular, the growth argument remains an internal proof for independent
review; its assumptions and operator derivatives must be checked before a
formal public claim. Interval evaluation validates specified numerical
inequalities; it cannot independently establish the whole statistical argument.

### Corrected work order

First complete the common inferential path on the existing feasible basic
conditions: ordinary GPCM and explicit orders 2/4 on the same inputs, matching
full covariance, parameter/contrast bias and RMSE, empirical SD versus reported
SE, interval width/truth inclusion, and every refusal or nonreturn. Maintain
PCM and correctly specified normal-MML/conditional references for their
respective targets. Bias and coverage diagnostics can expose failure; their
implementation need not await a universal theorem or a favorable result.
Formal API qualification still requires a defensible target and applicability.

Finish the running N30 condition, then give existing N20/60 common/full and
replicated-pair conditions priority for the same complete path. Preserve
N40/120/240/480, both SDs, all truth families, exposure conditions and historical
N400 evidence. R=50 is exploratory mapping: at 95% coverage and 50 returned
independent datasets, binomial MCSE is about 3.1 percentage points, and is
larger with fewer returns. Report conditional inclusion alongside interval
availability and returned-and-covered frequency; paired comparisons use shared
datasets. A single saved fit only demonstrates computational availability.

Then extend that completed path to identifiable repeated three-facet designs
and use singleton/weak-link/missingness/dependence designs to delineate limits
or evaluate a specifically justified alternative covariance. Preserve all
original adverse designs. Do not substitute more ordinary-JML certificates,
more API plumbing, or unplanned broad refitting for the missing complete
bias/uncertainty evaluation.

## October 3: basic-design JML inference comparison connected

The feasible-design work now has an executable common comparison path in
`jml-basic-inference-comparison-20261003.R`. It consumes the original A/B
PCM-JML, GPCM-JML, GPCM-JML2 and GPCM-JML4 fits. It adds no structural
optimization, response generation, correction-order selection or public CI.
The original numerical worker and its fit/score outputs remain unchanged.

For ordinary JML, structural beta is held at the public return. The existing
independent profile evaluator solves only the one-dimensional nonextreme
Person profiles at that beta and constructs actual Person scores and the
Schur-complement derivative. Extreme contributions retain their zero limits,
with all Persons retained in roster sizes and covariance denominators. The
sandwich uses the declared fixed-roster centering, not inverse curvature alone.
For corrected JML, the comparison reuses stored actual Person scores and the
full equation Jacobian, and requires the existing `consistent_roots` status.
It does not re-enumerate correction states or refit either order.

Two separately labelled covariance normalizations are carried through the
same targets: the current asymptotic meat, and the finite-roster n_g/(n_g-1)
weighted meat. Point estimates are identical across the two. Both versions
require sufficient roster replication, full score rank, and a complete
Jacobian whose smallest singular value exceeds the existing 1e-6 threshold.
Ordinary candidates additionally require positive profile curvature and the
existing floating-point local-root bound to be at most **0.01 of the retained
SD for every structural contrast**. This is a declared numerical-error budget,
not a coverage criterion, a new outward certificate, or a claim about global
branch selection. An inconclusive bound refuses that candidate while retaining
the original point and reason. Covariance perturbation and truth bias remain
unqualified even when this numerical screen passes.

The target map retains every location, owner-specific step and estimated log
slope, plus the prespecified Rater and Criterion first-minus-second contrasts.
PCM contributes 17 target rows and GPCM 20. Log-slope intervals remain in log
coordinates for recovery/coverage analysis; the existing public/result display
layer retains its separate exponentiated representation. Every plan explicitly
marks `FormalStructuralInference=FALSE`.

The comparison now produces:

* **Point and interval accounting:** point bias/RMSE use all returned finite
  points; interval bias and coverage use the declared interval-return subset.
  Availability, refusals, interval width, conditional truth inclusion,
  returned-and-covered frequency and MCSE retain their own denominators.
* **SE calibration:** empirical SD, mean SE, root mean estimated variance and
  reported/empirical SD ratio use the same interval-delivered datasets. This
  prevents comparison of an SE on an easy subset with an SD from all datasets.
* **Paired point comparisons:** original shared inputs, common mapped targets,
  joint-return counts, paired MSE differences and Monte Carlo uncertainty.
* **Refusal counts:** reasons remain separated by model, target and covariance
  normalization. An unavailable interval does not discard a valid point or
  shrink the original 50-dataset denominator.

The first retained N30 dataset supplies a workflow check for all four arms,
not a sampling-performance comparison. All 17/20/20/20 interval targets return
under both normalizations in this example. Ordinary PCM/GPCM all-contrast
numerical-distance bounds are approximately 1.08e-5 and 2.11e-5 retained SD.
The original corrected intervals agree with their already saved outputs; the
N30 finite-roster covariance equals (10/9) times the current covariance in all
four arms, with maximum floating-point discrepancy below 1.67e-16.

Focused verification includes an exact two-coordinate sandwich fixture,
singleton/rank/derivative refusals, fitting-error accounting, and unchanged
saved replay with profiling and root-bound evaluation forbidden. A separately
labelled synthetic accounting fixture uses 50 distinct IDs: 40 zero errors,
10 errors of three, and five interval refusals among the zero errors. It
recovers all-point mean error .6, RMSE sqrt(1.8), 45 interval returns, 35 covered,
conditional inclusion 35/45 and returned-and-covered frequency 35/50; the
interval-subset SD is sqrt(70/44). Missing and duplicate dataset fixtures are
refused. These synthetic checks are not simulated GPCM performance evidence.

Evidence and the four source-bound job phases are in
`validation-results/jml-basic-inference-comparison-20261003/`. The verified
phases were copied byte-for-byte to the actual completion destination,
`validation-results/mfrm-wide-map-pcm-r50-portable-20261003/summary-n30/jml-inference/jobs/`,
so their nuisance/derivative calculations will be reused. The completion-time
command in `mfrm-wide-map-pcm-summary-20261003.R` first performs the original
complete-condition aggregation, then invokes the research extension. The
extension requires all 400 original output jobs before condition summaries
are produced. Individual completed JML jobs can be prepared beforehand and
reused among the final 200 JML phases. Its CSV tables and labelled RDS live
under `summary-n30/jml-inference/`; they do not overwrite original outputs.

Both the command sequence and its early-stop behavior were checked without
numerical calls. The actual incomplete condition was also refused before
performance aggregation. At this checkpoint, the 50-dataset bias/coverage
results remain pending, as do their comparative narrative and figures. No
help/NEWS inferential claim or public API changes follow from these workflow
checks. The next central result is the complete basic-condition comparison,
including unfavorable results and unavailability, rather than another
standalone ordinary-JML numerical certificate.

The completion command now also invokes
`mfrm-wide-map-pcm-report-20261003.R` after both summaries succeed. It reads
saved summaries and checks their job dependencies; no calibration or scoring
is invoked. `report.html`, two English-labelled PNG figures and `report.rds`
are written beside the original summary. The report separates initial finite
returns from source-reviewed point outputs, and formal/source-reviewed
interval availability from research JML candidates. Prespecified Rater and
Criterion contrasts show bias, interval return counts, conditional inclusion,
returned-and-covered frequency, width, matched-subset SE/SD and paired losses.
The full tables preserve every target and the original prediction/scoring
outputs; figures do not select favorable targets or correction orders.

Binomial Monte Carlo intervals accompany displayed conditional coverage.
Exact 95% bounds for 50/50 are approximately [0.9289, 1], and for 47/50
[0.8345, 0.9875]. These illustrate the precision limits of R=50; they are not
observed outcomes from this study. Zero returned intervals leave conditional
coverage undefined while returned-and-covered frequency is zero. Neither
nominal coverage inside a Monte Carlo interval nor an SE/SD ratio near one
establishes structural-truth qualification or model-selection validity.

The renderer's synthetic check covers missing/incomplete or mismatched
summaries, missing targets, zero returns and both binomial endpoints; its HTML
links and rendered graphics were inspected. The initial forced Cairo device
failed because this Mac lacks its X11 dependencies. Using R's platform-default
PNG device resolves the output failure without installing dependencies or
changing numerical work. Synthetic previews are labelled as such in both
HTML and images and live separately under
`validation-results/mfrm-wide-map-pcm-report-20261003-check/`.
The updated completion entry point is checked through all six calls and
failure stops; its evidence supersedes the earlier four-call entry-point
witness only for report orchestration. The earlier JML numerical witnesses
and sealed running source remain unchanged. Actual performance interpretation
still awaits all 50 independent datasets.

### Saved adverse cases and preparation during the running condition

The first completion snapshot now has 147 source-bound JML comparison phases
saved at the actual final destination. These use completed original jobs only;
the full 50-dataset performance gate remains unchanged. This is work brought
forward from final aggregation, not a second simulation or structural refit.
The nine previously checked phases (four first-dataset arms and five adverse
corrected jobs) were reused unchanged. No performance summary was produced.

Five actual corrected jobs exercise the unresolved-start path: `job-03647`
(replicate 6, order 2), `job-03783`/`job-03784` (replicate 23, orders 2/4), and
`job-03791`/`job-03792` (replicate 24, orders 2/4). Each retains one accepted
local root out of two requested starting values, with mean-equation residual
between 2.87e-13 and 2.97e-11. Its local covariance is available, and the smallest
Jacobian singular value is between .00921 and .07333, above the 1e-6 gate.
These are not singleton-roster or unavailable-covariance failures. Unsuccessful
attempts include owner-total probability underflow; their last unresolved
stage has residual between .000857 and .001436. No second distinct accepted
root was observed. Underflow earlier in the search does not establish why
the final alternate-start stage remained unresolved.

For every one of these five jobs, all 20 original point outputs remain
available, while all 20 intervals are refused under both covariance
normalizations. Unavailable SEs and bounds remain missing. Agreement with the
original saved corrected-interval contract is checked by the same job runner.
The evidence is `adverse-replay.rds` and its log under
`validation-results/jml-basic-inference-comparison-20261003/`; the completed-job
preparation log records the reused and newly saved phases.

The ordinary GPCM path also encounters real numerical-screen refusals:
inconclusive local-root bounds, unresolved scalar-profile score checks, and a
failed floating-point whitening check. These remain separate from corrected
alternate-start failures and from lack of roster replication. For example,
`job-03614` has a profile mean-score norm of approximately 8.66e-7, but the
sufficient contraction ratio is about 1.478 (required to be below one), so the
bound is inconclusive. This is not proof of root nonexistence or structural
bias. The final availability comparison describes the declared screen as well
as the estimator; it cannot be relabelled as the availability of every possible
JML inferential method. No thresholds, starts, fit outputs or numerical source
were changed after observing these cases.

### Interpretation of the saved refusal cases

The five corrected jobs represent **three independent datasets**, not five:
replicate 6 contributes order 2, and replicates 23/24 contribute both orders.
Likewise, the 20 mapped outputs in a GPCM job are correlated functions of 12
free structural coordinates. Their simultaneous refusal is one job-level
decision, not 20 independent numerical failures. In this N30 design, each of
the three assignment rosters has ten Persons; N-G=27 exceeds the 12-coordinate
rank requirement. Replication feasibility therefore does not explain these
refusals, and it does not by itself establish useful small-sample information.

Saved final unsuccessful stages for all five corrected cases terminate with
`termcd=3`, algorithm stagnation, after 167--340 iterations under maxit=400.
Some earlier stages reach 400 iterations, but the final unresolved stage does
not. Extending the iteration limit alone has no demonstrated remedy here.
The unsuccessful terminal vectors differ from the accepted root by about
21.8--66.5 in maximum absolute structural coordinate, despite equation
residuals near 1e-3. They are not a second accepted root or merely a root that
missed the 1e-7 equation tolerance by rounding. The accepted-root Jacobian
condition numbers are approximately 64--633 in the current coordinates;
nonzero singular values do not qualify stability under sampling or remove
the branch-selection uncertainty. Underflow and subsequent stagnation are
observed events; a causal link between them is not established.

The same-data comparison makes the mechanisms more concrete. Intervals below
are research candidates under the declared, method-specific numerical screens.

| Dataset | Extreme Persons | Ordinary GPCM slope range | Order-2 slope range | Order-4 slope range | Candidate intervals returned: PCM JML / GPCM JML / order 2 / order 4 |
| --- | ---: | ---: | ---: | ---: | --- |
| 6 | 0 | .0141--485.8 | .311--2.776 | .303--2.829 | 17 / 0 / 0 / 20 |
| 23 | 2 | .549--2.492 | .712--1.472 | .716--1.457 | 17 / 20 / 0 / 0 |
| 24 | 0 | .0222--903.8 | .454--2.337 | .436--2.454 | 17 / 0 / 0 / 0 |

Generating slopes are all one under this PCM-truth condition. The ordinary
free-slope returns in datasets 6/24 warrant boundary/weak-information review,
but their finite magnitudes do not prove an infinite optimum or nonidentification.
Extreme response totals are not necessary for the observed instability.
Correction produces less extreme slope values in these selected cases, but
this is not an estimate of bias reduction, RMSE advantage or valid coverage.
Dataset 23 also shows that an ordinary numerical screen can pass while both
corrected alternate-start screens remain unresolved. Order 4 is not uniformly
more deliverable than order 2 on the basis of dataset 6.

In the frozen 147-job snapshot, eleven ordinary GPCM jobs refuse intervals.
Seven have the original `NumericalState=ready` but an inconclusive additional
contraction bound (ratios approximately 1.48--85.1); four have
`NumericalState=review` and fail a scalar-profile or whitening check. These
counts describe the diagnostic snapshot, not a completed failure-rate study.
For the seven ready cases, a first-order Newton displacement calculated solely
from the saved U, A and V is about 6.4e-6--2.0e-4 stored SD in the all-contrast
metric. This makes conservatism of the sufficient bound a plausible issue,
not a demonstrated root-distance guarantee. No screen was relaxed.

Passing the point-distance screen also does not certify covariance proximity.
In dataset 35, its floating-point point-distance upper bound is 1.90e-5 stored
SD, but its all-contrast relative covariance-change upper bound is about 204.
The latter is a loose upper bound, **not an observed 204-fold covariance error**.
It cannot establish small covariance perturbation. The current 0.01-SD
admission policy controls its declared numerical point criterion only;
covariance accuracy and structural-truth coverage remain separate questions.

For a specified local branch, numerical error, sampling variation around its
population-equation root, and displacement of that root from generating truth
are distinct terms. A sandwich addresses the second under its regularity and
sampling assumptions; within-roster n_g/(n_g-1) normalization and successful
root solving do not eliminate the third. This is consistent with the explicit
pseudo-root centering in section 1.3 of
[Dhaene and Jochmans, February 17, 2024](https://www.cerge-ei.cz/pdf/events/papers/3.%20dhaene%26jochmans.pdf).
That section also describes its general large-m rationale as informal; it is
not a published guarantee for this shared-owner GPCM implementation.

The final comparison must preserve all-point bias, same-subset SE/SD, return
rates and refusal reasons. Method-specific conditional coverage uses different
returned subsets, so differences cannot be attributed solely to correction
order; a common-return comparison would itself remain selection-conditional.
Matching two starts is useful evidence, not proof of global uniqueness, and
an unresolved start is not a mathematical theorem against local inference.
Future changes to stabilization, starts or numerical screens must define a
separate procedure evaluated on the same retained datasets without replacing
the frozen first-stage results. Evidence for this diagnosis is
`validation-results/jml-basic-inference-comparison-20261003/adverse-interpretation.rds`,
which binds the saved fits/phases and records that no structural refitting,
new responses or model reevaluation was performed.

### Separating owner-total arithmetic failure from statistical failure

The next investigation changes only the arithmetic of the existing owner-total
expectation, in the isolated research candidate
`inst/validation/jml-log-total-stability-20261003.R`. The package source, original
R50 fits, starting values, acceptance rules and interval decisions remain
frozen. This is not a public covariance/CI qualification or a new simulation.

The original recurrence stores both probabilities and probability-weighted
counts at Person ability zero. It divides the latter by the former, then takes
the logarithm of the probability for exponential tilting to each profiled
ability. Positive but extremely small probabilities can lose relative accuracy
in the subnormal floating-point range, before they finally round to zero.
Such states cannot simply be discarded: tilting to another ability can make
their probability substantial.

The candidate carries log total masses and conditional expected counts instead.
For a newly added rating in cell j, category k, let ell_jk be its log probability
at ability zero. If L_s is the previous log mass for total s and C_s its
conditional expected count vector, the exact recurrence is

```
L'_s = logsumexp_k(L_(s-k) + ell_jk)
w_sk = exp(L_(s-k) + ell_jk - L'_s)
C'_s = sum_k w_sk (C_(s-k) + e_jk).
```

The implementation combines these positive mixtures incrementally using
`log1p`; e_jk adds one count to the new cell/category. With the shared slope
within an owner, conditioning on its total cancels the ability-dependent
exponential tilt, so these conditional count vectors remain valid at every
profiled ability. The transition uses L_s directly. All owner-total states,
the estimating equation, adjustment order and Person profiling are retained.
This algebra does not require a latent normal distribution and does not add
an assumption that removes incidental-parameter bias.

Independent arithmetic evidence now includes:

- Four frozen full-response references, each at orders 0, 1, 2 and 4:
  maximum score discrepancy 1.65e-12. Saved full-Jacobian covariance results
  at orders 2/4 change by at most 1.02e-13 at their original roots.
- A closed-form binomial case with category log odds -1000: log masses down
  to -5000 and conditional counts agree within 4.55e-13. The absent-owner
  singleton case is also retained. This case tests the recurrence, not a fit.
- Actual accepted and unsuccessful terminal coordinates from the five
  corrected jobs on datasets 6, 23 and 24: the new scores agree with direct
  enumeration of ordered responses within each owner to at most 7.98e-12.
  All five accepted roots have old/new score differences below 9.11e-15.

The largest old/new score difference at the saved unsuccessful coordinates
is 2.22e-4, for dataset 24, order 2, second solver stage. Direct enumeration
agrees with the new calculation. Inspection locates the loss in the original
owner-total log masses: their smallest probabilities are approximately
7.62e-320--4.27e-319, with log-mass errors up to 2.85e-5. The new log-mass error
is at most 5.69e-14 in that comparison. Conditional counts themselves are
accurate there; the defective log masses feed the transition. The original
mean-equation residual changes from .004494 to .004449 at that fixed vector,
so arithmetic stabilization does **not** turn this vector into a root.

For dataset 6, order 2, the original neutral-start first stage was replayed
with its saved solver/version/settings until the same underflow exception.
The 891st equation evaluation captured the previously discarded trial vector.
Its owner slopes are approximately 186.98, .005304 and 1.0083; owner-total log
masses near -747 cannot be represented as positive ordinary double-precision
probabilities. The log-domain candidate evaluates that exact vector without
the exception and agrees with direct enumeration within 9.71e-12. Its adjusted
mean-equation residual is 4.620, so this is successful evaluation of a trial
point, not successful estimation. Person-profile residual at this extreme
vector is 2.68e-8; its profiling algorithm has not been altered or independently
qualified over arbitrary extreme coordinates.

Evidence is saved under `validation-results/jml-log-total-stability-20261003/`:
`arithmetic-check.rds`, `subnormal-diagnosis.rds`,
`job-03647-captured-trial.rds` and `captured-owner-tables.rds`. They bind the
candidate, original source and retained input fits. The direct enumeration
oracle changes only the owner-total table; the frozen full-response references
provide the separate whole-equation check. No probability threshold or
state-pruning approximation has been introduced. Finite representable logits,
the remaining floating-point transition and Person profiling still limit the
numerical claim; this is not an arbitrary-precision or interval-arithmetic
proof.

The same-settings candidate first-stage pilot has also completed for dataset
6, order 2. The original neutral start, Broyden/cline method, step limit and
maxit=400 were retained. It no longer throws the underflow exception, but
terminates at iteration 159 with `termcd=3` (stagnation), after 660 equation
evaluations including numerical derivative calls. Its residual is .038760,
well above the 1e-7 root threshold; it is approximately 5.69 away from the
original accepted root in maximum structural coordinate. Slopes are about
92.25, .01028 and 1.055. Thus the arithmetic remedy alone has **not** repaired
this failed start. No additional stages, iteration-limit extensions, new
responses or revised CI decisions followed this pilot.

At that unsuccessful terminal vector, the finite-difference full equation
Jacobian has an approximate condition number of 3.43e8, and the implied
Newton step has maximum coordinate magnitude 1.055. Changing the relative
derivative step from 1e-4 to 5e-5 changes the Jacobian by 1.09e-5 under the
existing relative comparison; this slightly exceeds the covariance stability
threshold. These are local numerical diagnostics at a nonroot, not an
information-matrix argument or proof of model nonidentification. They also
do not establish a second root, an infinite optimum or data corruption.

The pilot and its separate derivative inspection are retained in
`job-03647-candidate-stage.rds` and
`job-03647-candidate-terminal-derivative.rds` in the same evidence directory.
The solver record includes the starting vector, method/global strategy,
controls, result, review, runtime and session version. It evaluates one
candidate stage, not the complete two-start candidate estimator. The next
estimation question remains how to obtain reproducible accepted roots on
the retained designs; the independent statistical questions remain bias,
variance calibration and truth coverage across the completed R50 comparisons.

### Same-data PCM initialization for the unchanged corrected equation

The follow-up in `inst/validation/jml-pcm-start-pilot-20261003.R` tests an
implementation choice, not a modification of the profile-score correction.
Before any new corrected fit, it fixes four retained datasets (6, 23, 24 and
the first replicate as a comparison), both correction orders 2/4, and two
starting vectors per fit. The three adverse datasets were selected from
known failures; this is method development, not an independent estimate of
failure rates or performance over the full simulation roadmap.

The first vector uses the already fitted ordinary PCM structural coefficients
on the same data, followed by zero free log slopes. The second adds the same
perturbed-minus-neutral displacement used in the original solver. The initial
PCM has ten structural coordinates; the final GPCM equation still has twelve,
with its two free log slopes released immediately. There is no constraint,
penalty, truth value, previous corrected root or covariance-based choice in
the final fitting call. The original Broyden/Newton stages, tolerances,
maxit=400 and two-start agreement screen are unchanged. The log-domain
owner-total calculation from the preceding investigation is reused.

All four initial coordinate mappings are checked against the independent
ordinary-PCM profile calculation: raw profile criteria differ by at most
5.69e-14 and Person scores by 1.11e-12. This checks the nesting and coordinate
mapping; it does not assume that ordinary PCM estimates already solve the
corrected GPCM equations. Initial vectors and the complete eight-fit plan are
saved before fitting, with source and input hashes in
`validation-results/jml-pcm-start-pilot-20261003/prepared.rds`. Each completed
fit is saved separately using the existing immutable phase helper.

All eight fits completed: both starts converged in every fit, all in the
original first Broyden/cline stage, with 13--34 iterations per start. Thus all
five previously unresolved two-start cases now satisfy the unchanged root
agreement screen; the three previously consistent cases remain consistent.

| Dataset | Original order 2 / order 4 | PCM-initialized order 2 / order 4 |
| --- | --- | --- |
| 6 | one resolved start / both starts agree | both starts agree / both starts agree |
| 23 | one resolved start / one resolved start | both starts agree / both starts agree |
| 24 | one resolved start / one resolved start | both starts agree / both starts agree |
| 1 | both starts agree / both starts agree | both starts agree / both starts agree |

Maximum retained mean-equation residual is 7.45e-11. The largest coordinate
difference from the original accepted root is 1.14e-9, below the unchanged
1e-6 root-agreement tolerance. All eight local-root covariance calculations
are available. Their maximum measured relative variance change over all
nonzero linear contrasts is 2.08e-7, and maximum relative coordinate-SE change
is 7.26e-8. These comparisons are calculated from the actual pairs of saved
covariance matrices, not from a loose upper bound on possible changes.
The eight fitting calls, including their covariance calculations, took
297.6 seconds in this run; that is not an isolated benchmark against all
original fitting/scoring stages.

Dataset 6, order 2, isolates an effect of initialization: the preceding
log-domain neutral-start pilot stalled at iteration 159, while the same
log-domain equation and Broyden/cline settings now converge from the two
PCM-derived starts in 22 and 34 iterations. In the other cases, the comparison
with the original procedure changes both arithmetic and starts, so it cannot
attribute the gain to initialization alone. No new distinct accepted root
was found in these comparisons. Agreement across finitely many starts remains
a numerical diagnostic, not proof of a globally unique or unbiased solution.

This provides concrete evidence that these saved difficulties can be remedied
through implementation choices without altering the data or the correction
equation. It does not invalidate the prior method, certify truth coverage,
or establish broad robustness of PCM initialization. All four datasets are
N30, two-facet 3-by-3, six-ratings-per-Person, four-category, PCM-truth cases.
GPCM-truth cases with unequal slopes, other sample sizes, facet structures
and assignments remain in the broader validation plan. The current pilot
also requires a usable preliminary PCM fit; fallback behavior for an
unavailable preliminary fit has not been qualified.

Results and actual covariance comparisons are in `summary.rds`, `summary.csv`
and `covariance-comparison.rds` in the pilot directory. The original 50-dataset
comparison, its source hashes, output ledger and interval refusals were not
replaced. Public defaults and formal structural-CI support remain unchanged.

### October 3 whole-procedure sensitivity and decision consequences

The PCM-start result resolves the recorded two-start disagreements in a
selected pilot. It does not resolve the entire inference problem. Review
three separate outcomes: whether a point/interval is returned, whether
accepted estimates or intervals differ, and whether a prespecified decision
changes. A refusal is not evidence of no effect, and an interval containing
zero is not an equivalence conclusion.

**Retained-result decision check.** No new responses or fits are needed for
this check. Use the two already specified primary contrasts, Rater 1 minus 2
and Criterion 1 minus 2, with the saved asymptotic fixed-roster covariance and
pointwise normal 95% Wald construction. These remain unqualified research
intervals. In the four datasets and two correction orders, there are sixteen
contrast rows, not sixteen independent datasets:

| Original procedure | PCM-start/log-arithmetic candidate | Contrast rows |
| --- | --- | ---: |
| Interval available and entirely below zero | Same classification | 6 |
| Interval unavailable | Entirely below zero | 2 |
| Interval unavailable | Contains zero | 8 |

There is no classification reversal among the six jointly available rows.
The largest primary-contrast point difference, including the original
single-start roots retained for diagnostics, is 1.02e-10. Dataset 6, order 2,
changes from unavailable to intervals [-1.162951, -0.225449] for the Rater
contrast and [-3.207904, -0.163194] for the Criterion contrast. This establishes
availability/abstention sensitivity in the research procedure, not a validated
real-world decision reversal or calibrated rejection rate. Its preceding
log-arithmetic neutral-start failure isolates initialization for that case;
the other original/candidate comparisons also change arithmetic.

`validation-results/jml-pcm-start-pilot-20261003/primary-contrast-sensitivity.rds`
contains the sixteen rows, input hashes, interval level and covariance
normalization. Original bounds calculated from single-start diagnostic roots
are stored only for comparison; `unavailable` remains their original decision.
The original study ledger and its refusals are unchanged. These selected
datasets cannot estimate the frequency of decision changes over intended use.

**Literature and its scope.**
[Nader, Tran and Voracek (2015)](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0140163)
varied initialization and convergence criteria in BILOG-MG 3's 2PL estimation.
Latent-distribution initialization affected item bias under empirical-histogram
estimation; item-parameter starts had little effect, and standard MML showed
virtually no initial-value effect in their conditions. Tighter criteria reduced
initialization sensitivity but could increase item bias. Item characteristic
curve recovery was little affected by starts, so parameter sensitivity did
not establish equal sensitivity of every downstream outcome. This is evidence
against treating numerical convergence and statistical accuracy as equivalent,
not evidence that all IRT procedures are start-sensitive. It neither establishes
this corrected GPCM behavior nor justifies relaxing our root checks.

[Dhaene and Jochmans, February 2024 working paper](https://www.cerge-ei.cz/pdf/events/papers/3.%20dhaene%26jochmans.pdf)
provides the profile-score-adjustment basis, with Section 1.3 distinguishing
centering at a population estimating-equation root from centering at structural
truth. Finite correction order is not a universal fixed-exposure bias remedy.
The reviewed paper does not establish the present shared-owner GPCM
implementation's multistart convergence or the proposed PCM initialization.
Its correction order must not be confused with numerical solver iterations.

[Morris, White and Crowther (2019), Sections 3.4 and 5.1](https://onlinelibrary.wiley.com/doi/full/10.1002/sim.8086)
treat failure handling as part of the evaluated method and warn that
nonconvergence need not be random across generated datasets. Comparing only
returned results can therefore distort method comparisons. Our frozen
procedure must include its fallback and refusal rules; their outcomes are
performance results, not discarded bookkeeping.

**Factors to distinguish before qualification.** The following refines the
existing roadmap families; it does not introduce a new full factorial study.
Numerical diagnostics determine whether the specified sample equation is
being solved. Statistical arguments and repeated-sampling evidence determine
what that solution estimates and whether its interval covers the target.

| Factor | Possible effect on bias, coverage or decisions | Required comparison or limit |
| --- | --- | --- |
| Estimand, scale and identifying assumptions | Correctly solved equations can center away from structural truth; contrasts can become incomparable under different normalizations. | Align estimands/constraints; distinguish fixed exposure from exposure growth, ordinary from corrected JML, and MML population assumptions. Preserve the fixed-exposure obstructions already established above. |
| Correction order and branch selection | Finite-order displacement can remain; selecting an order or root after seeing favorable intervals changes the procedure. | Fix orders and selection rules in advance. Two nearby starts agreeing does not prove global uniqueness. A corrected score root is not automatically a maximum of the ordinary likelihood. |
| Initialization, solver, scaling and stopping | Failure, false convergence or a different branch can change returned subsets, estimates and intervals. | Reuse saved starts/paths; isolate arithmetic and starts on the same inputs before attributing effects. Include prespecified dispersed starts in a focused branch check, all attempted stages and preliminary-PCM failure behavior. Do not select roots by truth, smallest SE or desirable interval. |
| Probability calculation, profiling and differentiation | Underflow and inaccurate profiles/derivatives can affect both roots and covariance even when an optimizer reports success. | Retain independent equation checks and inference-scale stopping checks. Assess full nonsymmetric JML equation derivatives; for MML, assess quadrature range/nodes and population-nuisance information as separate accuracy questions. |
| Amount and arrangement of information | Small N, few ratings per Person, weak assignment connections, sparse categories, extremes and unequal slopes can produce weak identification or nonnormal sampling distributions. | Retain N20--60 and existing middle/large-N cases, exposure, facet counts/levels and roster replication. Include unequal-slope GPCM truth; success on PCM-generated data alone cannot qualify PCM starts. |
| Observation law and model assumptions | Informative missingness/assignment, local dependence, multidimensionality, omitted interactions or misspecified latent distributions can change the target and variance. | Keep planned incomplete assignments distinct from missing responses; use the existing missingness/dependence/model-change families with matched controls. Include latent-regression exogeneity, covariate support/missingness and residual-distribution assumptions. |
| Covariance and interval construction | A stable covariance need not describe the actual sampling law; Wald intervals can fail through bias, skewness or boundary behavior. | Match fixed/random assignments and the independent sampling unit; compare empirical SD with SE, width and tail-specific errors. Finite-roster normalization does not correct point bias. Any resampling method must reproduce the full fitting/selection procedure and require separate justification. |
| Selection and decision reporting | Successful-only summaries, post hoc settings or tuning on the same simulations can overstate performance. Multiple comparisons and thresholds add distinct decision errors. | Report every refusal, returned-result performance and matched comparisons with their denominators. Prespecify contrasts and decision rules; assess false positives under nulls, power/sign errors under alternatives, and multiplicity when relevant. Do not invent a substantive cutoff solely for this pilot. |

Even with negligible numerical error, finite-sample bias and displacement of
the population equation root from truth remain possible. Increasing N does
not by itself remove a fixed-exposure incidental-parameter problem or model
misspecification. Conversely, calling a small or sparse dataset "bad" does
not establish an appropriate scope for a general-purpose package; each
limitation needs an identifying, statistical or numerical explanation.

For returned intervals, report conditional truth inclusion with its actual
denominator alongside the interval-return rate. Also report the fraction of
all generated datasets that both return an interval and include truth. This
joint success measure is not ordinary unconditional coverage of an interval
that is undefined on failures. Common-return comparisons remain selected
subsets and must not hide differential failures. R=50 gives approximate
binomial Monte Carlo SE 0.031 near 95% inclusion if all fifty intervals are
returned; fewer independent returns reduce precision further. Multiple
coordinates/orders on a dataset do not increase the independent replication
count.

**Execution order.** Preserve the running original R50 comparison and all its
failures under the original hashes. Reuse the completed arithmetic, derivative,
initialization and contrast checks for development; no new fit is launched
for this review. Before independent confirmation, freeze the complete
candidate, including preliminary-fit failure, multiple-root and refusal
handling. Use untouched confirmation inputs or a new independent stream for
claims affected by tuning, while retaining compatible earlier evidence. The
four selected datasets and their eight fits are not confirmation data.
Compare procedures on common inputs with all outcomes retained, extending
through the existing model/design roadmap rather than treating one successful
baseline as qualification. Numerical repair, a justified inferential target
and bias treatment, and independent uncertainty/decision evaluation are all
required for formal structural-CI support; success at one does not waive the
others.

### October 3 Zotero reading: bootstrap and split-panel inference

**Decision.** Do not restrict the JML inference roadmap to correcting a point
estimate and then attaching a Wald interval. A basic parametric bootstrap
is a literature-supported way to account for incidental-parameter bias in
an ordinary MLE's sampling distribution, under growing exposure. It deserves
a model-specific applicability check before further general-purpose increases
in correction order. It is not yet qualified for this package, particularly
for fixed few-rating designs, paired assignments or corrected score roots.
Keep the conditional/bias-aware fixed-exposure route and the frozen original
R50 comparison. The split-panel alternative is conditional on a valid split
and bias expansion, not the default replacement for either route.

**Sources and reading scope.** Read the full attached articles, including
their designs, results and discussion; inspect the principal equations,
assumptions and cited result tables in the PDFs to resolve extraction errors.
The attachments were added on October 3. Earlier October 2 library additions
are not counted as newly read here. Separately hosted supplements and author
replication code were not used to claim an independent proof or replication.

| Article | Zotero parent / PDF attachment | Passages used for the decision |
| --- | --- | --- |
| Higgins & Jochmans (2024), *Bootstrap Inference for Fixed-Effect Models*, Econometrica 92, 411-427, [DOI](https://doi.org/10.3982/ECTA20712) | `6DPLH5S5` / `FM9KM2UF` | Sections 2-3, equations (1)-(3), Table II, Assumptions 1-6, Theorem 1/Corollaries 1-2, Theorem 3, conclusion and printed Appendix. |
| Dhaene & Jochmans (2015), *Split-panel Jackknife Estimation of Fixed-effect Models*, Review of Economic Studies 82, 991-1030, [DOI](https://doi.org/10.1093/restud/rdv007) | `BCNJKY74` / `NCPNCNAA` | Assumptions 3.1-3.5, equations (3.4)-(3.9), Theorems 3.1-3.2, Tables 2-3 and 11, Sections 4-7 and conclusion. |
| Nader, Tran & Voracek (2015), *Effects of Initial Values and Convergence Criterion...*, PLOS ONE 10, e0140163, [DOI](https://doi.org/10.1371/journal.pone.0140163) | `GKW7L8VL` / `Q2Z44J4H` | Sections 2.1-2.4, results, Tables 1-3 and discussion, especially PDF pp. 11-12. |

For the last article, the PDF identifies three authors; Lourens J. Waldorp
is the editor although the imported Zotero creator list includes his name.
Use the PDF authorship in citations. No Zotero records were modified.

**1. What the bootstrap paper actually establishes.** Let N denote Persons,
m observations per Person, beta the common parameter, and eta_i the fixed
Person effect. For the ordinary MLE, the paper establishes that both
`sqrt(N*m) * (beta_hat - beta_0)` and its conditional parametric-bootstrap
counterpart `sqrt(N*m) * (beta_hat_star - beta_hat)` have the same generally
nonzero-mean normal limit as N,m grow with N/m tending to a positive finite
constant. The bootstrap regenerates responses from the fitted conditional
model, holds covariates/initial observations fixed, and refits common and
individual parameters. In a dynamic model it regenerates recursively; a
locally independent static model needs its corresponding conditional generator.
Resampling Persons nonparametrically is a different procedure.

For a prespecified scalar contrast q=c'beta, let Q_p be the p quantile of
`q_hat_star - q_hat`. The two-sided basic 95% interval is

    [q_hat - Q_0.975, q_hat - Q_0.025].

The subtraction accounts for the biased sampling law. Taking the .025/.975
quantiles of `q_hat_star` itself is the ordinary percentile interval, which
the paper explicitly does not justify in this setting. Thus a valid interval
need not be symmetric about the uncorrected estimate, and point bias removal
need not precede interval construction. If a corrected point is desired, the
paper proposes subtracting the median of the centered bootstrap distribution.
It expressly separates distributional consistency from consistency of the
bootstrap variance: the former does not establish the latter. A basic interval
candidate therefore does not supply `vcov()` or structural-SE qualification.
Studentization is not automatically preferable with a nonpivotal biased limit;
the paper also does not prove a higher-order refinement for double bootstrap.

The assumptions include a correctly specified conditional likelihood,
independence across Persons, uniform mixing/moment and smoothness conditions,
compact parameter spaces with interior truths, identification within every
Person's growing observations, and uniformly nonsingular information.
Stationarity is not required in this paper. The result concerns ordinary ML;
neither our finite-trace public implementation nor U_2/U_4 roots inherit it
merely by being labelled JML. The printed proof relies on uniform estimator
and distributional results, including consistency of the fitted individual
effects. The existing local-root certificates and corrected-score growth
argument do not establish that bootstrap theorem for this implementation.

The empirical illustration has N=1,461 and ten annual waves. Table II uses
2,500 outer datasets and 999 bootstrap replicates per dataset. Its basic 95%
interval coverage is .972, .970, .921 and .782 as the autoregressive coefficient
changes from 0 to .5, 1 and 1.5. The last result is a material failure to reach
nominal coverage despite improvement over the analytic comparators. The paper
does not establish performance for N20-60 many-facet polytomous data. Nor does
it license ignoring missingness, dependence or feedback omitted from the
generating likelihood. Keep every inner fit failure; silently retaining only
successful bootstrap draws changes the conditional distribution being used.

**2. What split-panel jackknife adds, and what it costs.** The relevant split
reduces the observations *within* each Person, not the number of Persons. For
an even panel with two nonoverlapping halves, the ordinary-MLE correction is

    beta_SP = 2*beta_full - (beta_half1 + beta_half2)/2.

If the full and half panels share the same target and expansion
`beta_m - beta_0 = B1/m + B2/m^2 + ...`, this removes B1/m but changes the
next term to `-2*B2/m^2`. It does not make finite-m bias vanish. Theorems
3.1-3.2 use N,m growing together. The first-order variance agrees with ML
under those assumptions, but finite-sample variance can increase and is not
obtained by pretending the three estimates are independent. Overlapping
halves introduce a first-order variance penalty; smaller subpanels must still
admit the required estimator. Higher-order corrections further amplify terms
that remain and require valid higher-order expansions.

The paper distinguishes correction of the estimator from correction of the
profile likelihood; these have different finite-sample behavior and
reparameterization properties. Additive correction is not equivariant under
nonlinear transformations. Free log-slope versus raw-slope correction therefore
cannot be chosen after seeing results, and raw-slope combinations need not
preserve positivity. The likelihood correction is more costly but has the
equivariance advantages described in Section 3.2. Neither construction is the
same estimator as iterating our profile-score correction.

Under Assumption 3.1, units are independent, within-unit processes are
stationary/mixing and parameters are identified within each unit. Section 4
examines departures from stationarity and tests the common-bias-expansion
premise; a nonrejection is not proof of validity in a short panel. The proposed
unbalanced-panel extension assumes gap-free individual series and exogenous
unbalancedness. It does not cover arbitrary missingness or planned crossed
assignments simply by changing the name of the index. In the empirical example,
three of the four joint validity tests have near-zero p-values, which the
authors discuss as evidence of instability or misspecification.

The finite-sample warning is concrete. In Table 3's stationary probit case
N=500, m=6, autoregressive coefficient .5, its coefficient bias changes from
-.531 (ML) to +.315 (additive half-panel correction), while nominal 95% coverage
is only .082 for the latter. The SE/SD ratio is .952: approximately correct
variance alone does not repair the remaining centering error. At m=18 in the
same coefficient condition, coverage improves to .911. These are dynamic
probit results, not mfrmr performance. Sections 5 and 7 further show why
average effects and two-step estimators need their own uncertainty and all
stages refitted within each subpanel; this is relevant to future derived
scores/effects, not a direct latent-regression theorem.

**3. Initial-value evidence: empirical result versus explanation.** The Nader
paper uses a 20-item dichotomous 2PL, N=250/500/1,000, normal or standardized
skew-normal ability, ten fixed support points and 100 datasets per condition.
Starts and stopping criteria are compared on the same responses. The larger
effect concerns estimated histogram weights, not ordinary item starts or
fixed-normal MML in those conditions. Its outcomes are item bias, curve
recovery and latent-distribution recovery, not structural-CI coverage. The
discussion's accounts involving flat likelihoods, multiple maxima and numerical
error propagation are proposed explanations, not an isolated causal test.
This supports our paired sensitivity design; it does not justify transferring
BILOG's 1e-2 stopping default to mfrmr, choosing a loose tolerance by favorable
bias, or treating N=250 evidence as a small-N20 guarantee.

There is a useful mathematical qualification to the discussion (our check,
not a new finding attributed to that paper). With fixed item parameters and
fixed support points, write p_i for the vector of conditional response-pattern
probabilities and w for histogram weights on the simplex. Then

    ell(w) = sum_i log(p_i' w),
    Hessian_w ell(w) = -sum_i p_i p_i' / (p_i' w)^2.

This is negative semidefinite wherever mixture probabilities are positive.
The weight-only objective is concave; joint estimation with item parameters,
weak curvature or changing support locations is a different problem. Thus
neither a generic appeal to nonconvexity nor interpreting an algorithmic
starting distribution as a Bayesian prior establishes the mechanism. Compare
the actual objective/equation, information and output consequences. Their
short-run selection by largest log-likelihood also does not transfer to a
corrected estimating equation with no established scalar likelihood criterion.

**4. Applying the assumptions to the current many-facet design.** Our mapping
is N=Persons, m=ratings per Person, fixed-dimensional beta=facet locations,
steps and (where estimated) normalized slopes, eta_i=ability. Repeating an
entire finite rating block L times gives m proportional to L while keeping
the target dimension fixed. Adding new facet levels can increase dimension
and is a different asymptotic problem. Repeated responses must be independent
under the declared conditional model, not copies of existing scores.

There is a specific identification gap in transferring either paper's stated
conditions to the paired roster. In the current shared-owner model, adjacent
log odds contain `a_c*(eta_i - b_r - d_c - tau_ck)`. A Person rated by Raters
1 and 2, but not 3, has unchanged probabilities under the transformation

    (b1,b2,b3,eta_i) -> (b1+h,b2+h,b3-2*h,eta_i+h),

with other parameters fixed. This preserves sum-zero Rater locations and all
that Person's logits, for any sufficiently small h. Consequently the full
structural vector and eta_i are not identified from that Person's observations
alone, even if the same roster is repeated indefinitely. This violates the
literal within-Person condition in bootstrap Assumption 4 and split-panel
Assumption 3.1. Other roster groups can break this invariance in aggregate;
this is not a new claim of global nonidentification of the current design.
An aggregate-identification extension is needed before citing either theorem
for the full paired-design structural vector. A complete common roster is a
more suitable first applicability case, subject to its own identification check.
The [complete-block follow-up](#october-3-complete-block-bootstrap-applicability-and-identification-boundary)
below establishes the PCM case and a further GPCM identification boundary.

Two further gaps persist even with a complete roster. Normal/unbounded ability
draws do not give the fixed common compact ability range assumed by the
bootstrap theorem. Existing expanding-range score bounds are ingredients to
reuse, not a proof of uniform bootstrap validity. Also, plugging +Inf/-Inf
ability estimates for all-high/all-low Persons into the response generator
makes their bootstrap responses degenerate. The probability and treatment of
these events need a theorem-compatible argument for the actual estimator.
Finite clipping, shrinkage or deleting these Persons changes that procedure
and must not be inserted as an unrecorded workaround.

For splitting, each cell in the current L1 two-Rater-by-three-Criterion roster
occurs once. It cannot be divided into two identical integer cell rosters.
This rules out the already proposed exact design-preserving split here, not
all possible generalized splits. Complete independently repeated blocks can
admit an exact split; target identity, rank, common bias coefficients and
failed-half handling remain necessary. Reuse the earlier generalized split
derivation and its joint influence covariance. Applying the ordinary `2,-1`
weights automatically to U_2/U_4 is not justified by the 2015 theorem.

**5. Revised priorities and completion criteria.**

1. For fixed few-rating use, retain conditional RSM/PCM references and the
   identified-contrast/bias-aware GPCM work. Neither newly read theorem
   removes the fixed-exposure identification obstruction or provides a
   general shrinking truth interval. Preserve small and larger N and the
   full model/design roadmap rather than choosing only favorable conditions.
2. For growing exposure, first assess ordinary profile-JML basic parametric
   bootstrap on a complete, fixed-dimension repeated-block family. Establish
   the model/source correspondence and sufficient uniform identification,
   information, ability-range and extreme-response conditions before a
   candidate implementation. Derive paired-roster/unbounded-ability extensions
   where those are the intended scope; do not label the prototype universal.
3. Use split-panel jackknife as a comparator only after split feasibility and
   its expansion are justified. Keep its coordinate choice, all refits and
   covariance cross terms explicit. Consider corrected-score extensions only
   with a matching argument; ordinary-MLE theory is not a proof for them.
4. Freeze the actual returned procedure before independent evaluation:
   initial and fallback fits, generators, numerical checks, roots, intervals,
   inner failures and decision rules. Keep bootstrap quantile precision
   separate from outer R=50 Monte Carlo precision. Double bootstrap and a
   published count such as 999 are not automatic defaults or new budgets.
5. Continue MML's own population/integration and latent-regression assessment.
   The fixed-effect papers do not qualify its latent distribution or external
   covariates. Reuse the existing start/accuracy/shape controls; an EH feature
   is not warranted solely because the initial-value paper studies it.

This review changes the method-selection rationale and the gates, not the
public estimator or CI API. No new simulations, estimation, bootstrap or
jackknife refits were performed for this reading. Existing run settings and
evidence remain intact. A future valid interval procedure and a future valid
covariance procedure may have different prerequisites and must be reported
as separate supported outputs.

## October 3: complete-block bootstrap applicability and identification boundary

**Question and answer.** Does replacing the paired roster by a complete common
roster satisfy the mathematical conditions for ordinary-JML basic parametric
bootstrap? For the fixed-dimension PCM below, with abilities uniformly in a
compact interior range and independently repeated blocks, it does: the model
meets Higgins and Jochmans (2024), Assumptions 1--6. This is a specialization of
their published theorem, not an independently reproved bootstrap theorem.
For shared-owner GPCM, completeness alone is insufficient. A nonzero non-owner
facet contrast gives a sufficient within-Person identification condition;
the all-equal Rater case supplies an exact counterexample to that condition.
Aggregate identification may still hold there. This result identifies a
defensible mathematical reference procedure, not a qualified public CI API.

The argument below resolves the first complete-block applicability question
from the preceding reading. It does not remove the fixed-exposure obstruction,
extend the theorem to normal ability tails, or validate corrected-score roots.
The evidence is algebraic; no responses, estimates, bootstrap replications,
finite differences or coverage trials were generated for this increment.

### 1. Model and identifiable coordinates

Take two non-Person facets: R Raters and C Criteria, each with at least two
levels, common categories 0,...,K-1 with K>=2, unit likelihood weights, no
interactions or anchors, and freely estimated abilities without Person
centering. Criterion owns the steps and, in GPCM, slopes. A block contains one conditionally
independent response in every Rater-by-Criterion cell. Each Person receives L
independent blocks. R,C,K and the structural dimension stay fixed. The adjacent
log odds for one Person are

    z_rck = log{p_rc(k)/p_rc(k-1)}
          = a_c * (theta - b_r - d_c - tau_ck),    k=1,...,K-1,

with sum_r b_r=sum_c d_c=0, sum_k tau_ck=0 for every c, and sum_c log(a_c)=0.
The last constraint fixes the geometric mean slope at one. PCM fixes all
a_c=1. These are the centered coordinates in `R/core-jml-adjustment.R` and the
ordinary likelihood reference in `jml-public-profile-bridge-20261002.R`.
Agreement of the model formula does not establish that every public numerical
return equals its exact joint/profile maximum.

Write a bar for the simple average over the named indices. Under PCM,

    theta = average_(r,c,k) z_rck,
    b_r   = theta - average_(c,k) z_rck,
    d_c   = theta - average_(r,k) z_rck,
    tau_ck = theta - d_c - average_r z_rck.

All probabilities are positive at finite parameters, so adjacent log odds
exist and determine the categorical probabilities, and conversely. These
formulas are a global inverse for the constrained PCM parameters. Thus a
single Person's block distribution identifies theta and all
`p=(R-1)+(C-1)+C*(K-2)` structural coordinates. This is identification from
the probability law, not exact estimation from one observed block. Repeating
the block supplies the observations used by the asymptotic theorem.

For GPCM, suppose a fixed Rater pair r,s has b_r-b_s nonzero. Then

    Delta_c = z_rck-z_sck = -a_c*(b_r-b_s),
    a_c = abs(Delta_c) / {product_h abs(Delta_h)}^(1/C).

The contrast is independent of step k. The second equality uses positive
slopes and their geometric-mean constraint. Dividing every z_rck by its
recovered a_c reduces identification to the PCM inverse above. On compact
parameter sets where this Rater contrast stays bounded away from zero, that
inverse is smooth with bounded derivatives. This yields uniform identification
and nonsingular information. Equal Criterion slopes, including PCM truth
fitted as GPCM, are not themselves a violation of this condition.

### 2. Why a complete GPCM roster is not sufficient

If all centered Rater locations are zero, choose any positive q_c with
product_c q_c=1 and define

    a'_c    = a_c*q_c,
    theta'  = average_c {(theta-d_c)/q_c},
    d'_c    = theta' - (theta-d_c)/q_c,
    tau'_ck = tau_ck/q_c,
    b'_r    = 0.

All centering/scale constraints remain satisfied, and

    a'_c*(theta'-d'_c-tau'_ck)
      = a_c*(theta-d_c-tau_ck).

There are C-1 freely varying scale directions, arbitrarily near the original
parameter. Repeated complete blocks for this one Person cannot distinguish
them. This violates the cited theorem's within-Person identification
Assumption 4 and removes positive information in those directions. Small
nonzero Rater contrasts also make the within-Person inverse poorly conditioned;
pointwise identification is not a uniform lower bound near the all-equal case.

This is **not** a proof of aggregate nonidentification. The transformed d'_c
depends on theta. It generally cannot serve as the same structural vector for
Persons with different abilities. Indeed, for two Persons with theta_i !=
theta_h, the differences
`z_irck-z_hrck=a_c*(theta_i-theta_h)` recover relative slopes in a complete
roster. A single Person then recovers the other parameters after unscaling.
That observation does not on its own prove the required aggregate bootstrap
theorem, but prevents an incorrect rejection of the whole GPCM model.

The exact check in `jml-bootstrap-identification-20261003.py` uses R=C=3,
K=4 and rational parameter values, with symbolic differentiation of adjacent
log odds. The ranks include the Person ability coordinates:

| Distribution observed | Model / Rater locations | Jacobian rank / coordinate count |
| --- | --- | --- |
| One Person, all 3 x 3 cells | PCM | 11 / 11 |
| One Person, 2 x 3 cells of the same 3 x 3 model | PCM | 10 / 11 |
| One Person, all 3 x 3 cells | GPCM, nonzero Rater contrast | 13 / 13 |
| One Person, 2 x 3 cells of the same 3 x 3 model | GPCM, nonzero Rater contrast | 12 / 13 |
| One Person, all 3 x 3 cells | GPCM, all Rater locations zero | 11 / 13 |
| Two Persons with different abilities, all 3 x 3 cells each | GPCM, all Rater locations zero | 14 / 14 |

Positive categorical probabilities make the Fisher information and this
Jacobian have the same null space. Removing the one-dimensional ability
coordinate by a Schur complement subtracts one from both the joint rank and
coordinate count in each one-Person row. The rank examples verify the algebra
at specified points; the inverse and invariance arguments establish the
general claims. The script also checks the flat-Rater transformation
symbolically for arbitrary positive normalized slopes/scaling multipliers,
and checks the paired-roster location invariance from the preceding review.
All six rank assertions and both symbolic invariances passed under SymPy 1.14.0.
Reproduce with `python3 inst/validation/jml-bootstrap-identification-20261003.py`.

### 3. A sufficient ordinary-PCM bootstrap theorem specialization

Condition on independent Persons' fixed abilities theta_i. Assume all true
abilities lie in a fixed bounded interval strictly inside a larger common
compact estimation interval, with a uniform positive boundary margin. Put
the structural truth in an interior compact set, also separated from the
boundary of a larger estimation set. These sets are theoretical conditions;
they do not introduce a normal prior, shrinkage or clipping into mfrmr.
Use the correctly specified independent complete-block PCM above, with
N,L -> infinity and N/L -> lambda in (0,infinity).

Take one complete R*C response block as one observation in the paper's
notation: n=N, m=L. The block distribution is the product of the R*C
categorical distributions. Taking individual ratings instead changes the
asymptotic scaling by a fixed factor; it does not require extra parameters.
The paper's assumptions then have the following direct justification:

| Assumption | Model-specific justification |
| --- | --- |
| 1: continuity, interior truth, common compact sets | Softmax probabilities are continuous; choose the nested sets and uniform margins above. |
| 2: uniform mixing | Blocks are independent conditional on fixed ability, so mixing coefficients vanish at positive lags. Persons are independent as required by the sampling setup. |
| 3: smoothness, envelope moments and uniform convergence | A block has finite support and the parameter sets are compact. Log probabilities and derivatives of every fixed order are uniformly bounded; the block law is the same at each repetition. |
| 4: uniform within-Person identification | The PCM inverse is injective. The expected likelihood gap is a block-distribution KL divergence. Continuity, compactness and injectivity give a strictly positive uniform minimum for alternatives separated by any fixed positive coordinate distance. |
| 5: rectangular growth | N/L tends to a finite positive constant by the stated sampling regime. |
| 6: uniformly regular nuisance and structural information | The adjacent-logit design has full column rank. Positive category probabilities bounded away from zero give uniformly positive joint information; its ability entry and structural Schur complement stay positive and bounded on the compact sets. Correct specification gives the information identity. |

Use exact joint maximum likelihood on those sets and refit **all** Person
abilities and structural parameters in each bootstrap dataset. The generator
uses the fitted theta_i and beta, independently regenerates responses at the
original cells/repetition counts, and preserves the centered parameterization.
It does not draw new abilities from an estimated population distribution.
For a fixed structural contrast q=c'beta, let Q*_alpha be the quantile of
`q_hat_star-q_hat`. Higgins and Jochmans Theorem 1 and Corollary 1 give

    [q_hat-Q*_(1-alpha/2), q_hat-Q*_(alpha/2)]

as an asymptotically valid 1-alpha **basic** interval. Ordinary percentile
endpoints of q_hat_star do not follow. In particular the ordinary-JML bias
of order 1/L can remain comparable to the SE of order 1/sqrt(NL), since
sqrt(N/L) need not vanish. The bootstrap reproduces that displacement instead
of assuming it away. This differs from the earlier uncorrected truth-Wald
centering condition N/L -> 0. It supplies neither a finite-N coverage bound
nor a consistent bootstrap covariance without the separate moment argument.

The same assumption mapping applies to an **exact compact global GPCM MLE**
if true structural neighborhoods have a specified non-owner Rater contrast
bounded away from zero and positive slopes bounded above and away from zero.
The smooth inverse in section 1 supplies identification/information. GPCM's
nonlinear likelihood does not supply the PCM concavity bridge below; an
accepted local numerical root is not thereby the requisite global estimator.
This is a sufficient special case, not a general GPCM identification rule.

### 4. Extreme Persons and the bridge to unconstrained PCM maximum likelihood

Compactness implies a common lower bound epsilon>0 for every category
probability. With M=R*C cells per block, the conditional probability that at
least one of N Persons is all-low or all-high satisfies

    Pr(any extreme Person) <= 2*N*(1-epsilon)^(M*L).

For the stronger event that some Person-cell-category is absent from its L
repetitions, a union bound gives

    Pr(any empty Person-cell-category count) <= N*M*K*exp(-epsilon*L).

Both bounds tend to zero when N/L tends to a finite positive constant.
This stronger event is sufficient, not necessary, for finite estimates.
They are bounds under the stated compact, independent-block law, not practical
cutoffs for declaring six or nine ratings adequate.

PCM also has an elementary bridge between exact compact and unrestricted
maximum likelihood, rather than a license to silently clip public abilities:

1. Its log likelihood is jointly concave in all centered linear structural
   coordinates and the N abilities. The full-rank complete-block design makes
   it strictly concave at every finite parameter vector. If every
   Person-cell-category count is positive, the negative likelihood is coercive
   and hence has a unique finite global minimum. To see coercivity, a positive
   minimum empirical category frequency bounds each cell cross entropy below
   by that frequency times its category-logit range. Those ranges control the
   norm of (theta_i,beta) through the full-rank linear adjacent-logit map.
2. Uniform count concentration gives a minimum empirical category frequency
   at least epsilon/2 with probability tending to one, uniformly over Persons.
   At the MLE, comparison with the true vector bounds the average cross
   entropy and hence beta uniformly. For each fixed fitted beta, a Person's
   fitted ability has no larger loss than ability zero; the same coercivity
   then bounds every fitted ability uniformly. Thus all these unrestricted
   maxima lie in a sufficiently large fixed compact set with high probability.
3. On that set, uniform empirical-probability convergence gives uniform
   convergence of each Person's criterion. The positive KL gap first gives
   consistency of the shared beta: a separated beta would incur the gap for
   every Person. Comparing each profiled ability with its true ability at
   that consistent beta then gives uniform consistency of all theta_i.
   The uniform boundary margins make the compact maximum interior with
   probability tending to one, where it equals the unrestricted global MLE.
4. The same concentration/identification argument is uniform for generating
   parameters in an interior neighborhood. The fitted vector enters that
   neighborhood with high probability, so it also applies conditionally to
   bootstrap data. The compact and unrestricted PCM procedures agree with
   conditional probability tending to one. Their sampling distributions
   differ by at most the corresponding disagreement probabilities.

Consequently the cited basic-bootstrap limit transfers to the exact
unrestricted ordinary PCM MLE in this regime, with any predeclared measurable
completion on the vanishing exceptional events. This completion statement
is about distributional asymptotics, not about moments, a finite-sample
variance guarantee, or a recommended arbitrary replacement estimate.

Finite-sample handling is still substantive. All-high/all-low Persons in an
extended profile have theta=+Inf/-Inf; their direct plug-in bootstrap generator
is degenerate. A public procedure must expose such cases and specify its
return/refusal policy. At fixed L their probability need not vanish as N
increases. Removing Persons, clipping their abilities or drawing bootstrap
datasets repeatedly until a fit succeeds changes the procedure. Counting only
successful bootstrap refits also changes the distribution being approximated.
Do not apply the compact-growth argument to excuse these choices in small data.

### 5. Implementation boundary and next qualified deliverable

The **mathematical reference** is now ordinary PCM basic parametric bootstrap
for complete independently repeated blocks, fixed dimensions and bounded
interior fixed abilities, targeting exact joint/profile maximum likelihood.
Its GPCM sufficient subcase additionally requires the stated non-owner
contrast and an actual global maximum. This resolves a positive applicability
case and a counterexample before expensive resampling. It does not select a
new package default or narrow the agreed general-package validation scope.

Before a public or independent-performance candidate is frozen:

- Match the actual ordinary-JML fit and bootstrap refits to this likelihood
  and parameter scale. Their numerical errors in beta must be
  `o_p((N*L)^(-1/2))`, and conditionally so for bootstrap refits. Reuse the
  existing profile bridge and curvature-scaled residual criterion; a fixed
  optimizer tolerance or successful return flag alone does not establish
  this condition. For GPCM, global/near-truth branch selection remains extra.
- Specify finite-sample extremes, boundary estimates, absent categories and
  failed refits as part of the returned procedure. Keep every planned inner
  attempt in accounting; a refusal is not evidence of no structural effect.
  Quantile simulation error requires its own accuracy assessment after this
  candidate is defined, separate from the outer R=50 performance uncertainty.
- For normal/unbounded abilities, reuse the existing expanding-range bounds,
  but prove conditional bootstrap uniformity at the fitted ability vector and
  matching bias/information, as well as original-sample bounds. An argument
  only for the original score does not establish bootstrap validity.
- For incomplete/paired rosters or all-equal/near-equal non-owner locations,
  establish an aggregate-identification bootstrap extension. Do not change
  the generating Rater contrasts solely to avoid this requirement: those
  designs remain relevant use cases and validation conditions.
- Keep fixed few-rating PCM conditional inference and GPCM identified-target/
  bias-aware work as the separate immediate short-design route. Keep MML,
  corrected JML, unequal-slope truth, changed facet counts/levels, missingness,
  dependence and small/middle/large N in their existing roadmap. None is
  qualified by the compact complete-block specialization alone.

The next implementation unit is a development ordinary-PCM reference using
the existing likelihood bridge, with an explicit all-attempt/failure contract
and inference-scale numerical checks. It must remain distinct from the public
estimator until that correspondence is qualified. A new blanket bootstrap
experiment, additional correction order or more outer replications would not
close the remaining mathematical/source gaps.

## October 3: ordinary-PCM bootstrap reference and finite-only refusal limit

**Question and outcome.** Can the complete-block argument be represented by a
working ordinary-PCM reference, with the actual generator, all refits, numerical
checks and interval arithmetic kept together? Yes, as a repository-only
development procedure. The first retained-data check passed. It also exposed
an important limitation: a rule refusing the entire interval after any extreme
Person in any inner dataset is unsuitable for increasing the inner replication
count in this small-exposure case. Therefore this is not yet a candidate to
promote to the public CI API or launch as a large coverage study.

**Implementation and declared procedure.**
`jml-pcm-basic-bootstrap-20261003.R` reuses the existing ordinary profile bridge,
its analytic score/Schur Hessian, the PCM root-distance bound, preserved-seed
helper and atomic/checksummed phase storage. It adds no dependency and changes
no package R/C++ code. The current admission is two additive non-Person facets,
ordinary PCM, at least three declared categories, unit weights, unconstrained
Person abilities, centered facet/step coordinates, no interactions/anchors,
and a complete common block repeated equally at every Person-cell. Conditional
independence must be declared; the observed counts cannot establish it.
The mathematical binary-PCM case remains outside this reference adapter.

The reference refines the saved/public structural point using `nlminb` and
exact scalar profiling, with the original point retained separately. Every
bootstrap response is drawn independently at the **fitted fixed ability** and
refined structural point, on the same observed design rows. No new normal
abilities, clipped abilities, posterior draws or replacement datasets enter
this generator. Every inner dataset refits all Person profiles and structural
coordinates using the same reference fitter. The point and resulting basic
quantiles belong to that reference estimator, not automatically to the public
finite optimizer trace or a corrected JML equation.

The existing exact-arithmetic PCM theorem is evaluated in floating point to
bound Euclidean structural root distance by r. For stored profile information S,

    rho = r*sqrt(lambda_max(S)),
    abs(c'*(beta_returned-beta_root))/sqrt(c'*S^(-1)*c) <= rho.

The second inequality follows from Cauchy--Schwarz for every contrast c.
Acceptance requires finite abilities/structural coordinates, an available
root bound, and `rho <= 1e-4/(N*L)^(1/4)`. The numerical budget tends to zero;
under the already stated regular growth information S of order NL it targets
negligible numerical error on the inference scale. This is not an estimate of
truth bias or a qualified structural SE. The bound computation here is not
outward-rounded interval arithmetic. An optimizer return code alone neither
admits nor rejects a point; its full code/message and the separate bound remain
saved. Iteration/evaluation limits are declared numerical failure rules, with
no wall-clock cancellation of a running procedure.

The finite-only v1 policy refuses a source or inner dataset containing an
all-low/all-high Person. Source refusal precedes random generation. Every
planned inner attempt is retained and a failed one is never replaced. Basic
endpoints are computed only if every planned inner refit passes; otherwise
the endpoints remain unavailable. The generalized-inverse empirical quantile
uses R `type=1` and the endpoints are `q_hat-Q*.975` and `q_hat-Q*.025`.
`ComputationallyAvailable` is separate from `InferenceQualified`, which remains
FALSE throughout this development reference.

**Executed check and its scope.**
`jml-pcm-basic-bootstrap-check-20261003.R` uses the already generated
`AB:full-L1:N20:SD0.5:S-PCM`, replicate 1: N=20, Rater 3 x Criterion 3,
four categories, L=1, nine ratings per Person and 180 observations. This is one
retained normal-generated input for implementation checks, not a newly
qualified bounded-population sampling experiment. One public fit, one reference
refinement and 12 inner refits were performed. The 12 inner datasets are not
12 independent outer performance replications, and do not replace the agreed
R=50 allocation.

Evidence is in `validation-results/jml-pcm-basic-bootstrap-20261003/`:

- The source and all 12 inner refits passed the floating-point numerical gate.
  Source rho was 2.623468e-10; the largest inner rho was 4.824068e-8, against
  the prespecified 4.728708e-5 budget. The maximum coordinate shift from the
  original public point to the reference was 5.751346e-6, so the reference is
  explicitly not substituted for that public point.
- Generator probabilities agreed with the package's separate expanded-
  parameter/category-probability calculation to 2.220446e-16. The ordinary
  native and reference joint gradients agreed to 2.775558e-15, and their
  negative log likelihoods agreed within 1e-8. These compare evaluations at
  the same refined parameter vector; they are not coverage evidence.
- Seven inner `nlminb` returns had code 0 and five had code 1 with
  `singular convergence (7)`. All twelve had positive profile information and
  the accepted independent root-distance bound. Thus this result is twelve
  accepted numerical diagnostics, not a claim of twelve clean optimizer flags
  or a reason to suppress optimizer messages.
- Checks covered seeded response replay and RNG preservation, fresh draws for
  repeated design rows, all-low/all-high refusal, incomplete-design and missing
  independence-declaration rejection, an intentionally inadequate optimizer
  run, and basic-versus-percentile arithmetic using skewed artificial estimates.
  An unavailable inner estimate suppressed endpoints without removing its row.
- The actual completed-stage replay was run with the refit and generation
  functions replaced by error traps. It returned the identical result. Source
  extreme refusal generated zero datasets. Subsequent check-only edits reused
  the original/public and all 12 completed inner fits; these were not counted
  or rerun as new estimation evidence.

**Inner quantile precision is not established.** For each ideal bootstrap
quantile at probability p, the result records a conditional 95% order-statistic
bracket with ranks

    lower = qbinom(.025,B,p), upper = qbinom(.975,B,p)+1.

Rank 0 means -Inf and rank B+1 means +Inf. This follows by bounding the number
of draws below the population quantile with binomial tails (inclusive bounds
are conservative with ties). With B=12 and p=.025/.975, the ranks are 0:3
and 10:13. Hence each tail has an unbounded side of its Monte Carlo bracket.
The saved nominal-95% basic endpoints are engineering outputs, not accurate
95% interval estimates or substantive contrast decisions.

**Why increasing B is not the next action.** This can be answered without
additional simulated responses. For fitted probabilities p_ij(k), the exact
conditional probability that Person i is extreme in one bootstrap dataset is

    e_i = product_j p_ij(0) + product_j p_ij(K-1).

Independence across Persons gives the probability of at least one extreme
Person in one dataset as `e=1-product_i(1-e_i)`. With independent inner draws,
the probability of an interval refusal caused by at least one such dataset is
`1-(1-e)^B`. This is a lower bound on the **total** refusal probability, since
other numerical or structural failures can also occur. It is conditional on
this particular fitted generator, not an estimated population failure rate.

Here e=0.02558333. The implied refusal lower bounds are:

| Planned inner datasets B | Probability of at least one extreme dataset |
| --- | --- |
| 12 | 0.2672827 |
| 199 | 0.9942430 |
| 999 | Greater than 0.99999999999 |

Twelve observed successes are compatible with these probabilities and do not
qualify the policy for larger B. For any fixed positive e the all-success
probability tends to zero as B grows. In the growth theorem's regime, a
sufficient joint condition for this particular finite-only policy to avoid
such refusals is `B*N*exp(-c*L) -> 0`, using the earlier uniform extreme-event
bound; increasing B at fixed L does not satisfy it. The ideal bootstrap CDF
theorem by itself does not resolve this algorithmic refusal rule.

**Next decision.** Keep the finite-only reference and its evidence intact as
a scoped baseline. Prioritize a mathematically explicit extension using the
existing **extended profile likelihood**: an extreme Person has an infinite
ability supremum and zero structural profile contribution, rather than a
finite ability obtained by clipping. Determine the existence/identification
of the structural maximizer, full-procedure completion/refusal rules and the
generator at an extreme source, including datasets that still have structural
boundary or rank problems. That work must distinguish changing the estimator
from representing its exact extended likelihood. Do not simply remove extreme
Persons, reuse only successful inner draws, increase B, or call the v1 result
a calibrated public interval. The normal-tail/paired-roster mathematical
extensions, fixed few-rating inference, corrected JML and MML remain on their
existing tracks, and the running comparison keeps its original source.

## October 3: extended-profile PCM bootstrap and structural existence

**Answer to the refusal problem.** An independently free extreme Person does
not, by itself, invalidate structural estimation. The reference now uses the
exact extended profile for that Person, retains every original design row,
and generates the corresponding endpoint point mass. The original dataset
and every bootstrap dataset use the same rule. A finite structural maximum
is assessed separately. This removes the artificial rule that any extreme
response invalidates the entire bootstrap, without declaring nonexistent
structural estimates to be finite.

This reuses the identity in the earlier
[extreme-profile contract](jml-extreme-profile-limit-contract-0.2.3.md) and the
already implemented ordinary profile bridge. The new work connects that
identity to the bootstrap generator/refit, adds a structural-recession check,
and verifies the combined procedure. The finite-only v1 source and check
script were preserved byte-for-byte under
`validation-results/jml-pcm-basic-bootstrap-20261003/source-v1/`, with their
original MD5 identities. Its numerical results were not overwritten.

### 1. Extreme ability and structural maximum are different questions

For a complete PCM Person i, write the category utility at rating j as

    u_ijk = k*theta_i + x_jk' beta,
    ell_i(theta_i,beta) = sum_j log p_ij(y_ij | theta_i,beta).

The centered facet/step coordinates give the fixed linear vectors x_jk. For
all-high responses, theta_i -> +Inf makes every observed-category probability
tend to one, at every finite beta. For all-low responses the same holds as
theta_i -> -Inf. Therefore, for either extreme,

    sup_theta_i ell_i(theta_i,beta) = 0 for every finite beta.

The profiled contribution is the constant zero: its structural score and
Hessian are also zero. This is exact profiling over an extended parameter,
not a finite approximation at theta=10 or a Person deletion rule. It requires
the independent, unanchored, uncentered ability coordinates already enforced
by the reference. Anchored or constraint-coupled Persons do not satisfy this
argument and remain outside its admission.

Let G be the nonextreme Persons. The structural profile is consequently

    ell_profile(beta) = sum_(i in G) sup_theta_i ell_i(theta_i,beta).

For any fixed finite beta, each nonextreme Person has a unique finite ability
profile: the expected total increases strictly from the minimum to the maximum
possible total, and the observed total is strictly between them. Extremes
remain in the data, counts, boundary records and bootstrap generator; their
profile contribution happens to be zero. If beta has a finite profile maximum,
the full original likelihood nevertheless has no finite joint maximum when
an extreme Person is present. The result records `FiniteJointMaximum=FALSE`
separately from structural computational availability.

### 2. A condition for a finite structural maximum

Use w=(theta_G,beta) and the observed-versus-alternative utility contrast
matrix A on the nonextreme Persons. For every observed rating j and alternative
category k != y_ij, its row applied to a direction d=(v_G,h) is

    (A*d)_ijk = (y_ij-k)*v_i + (x_j,y_ij-x_jk)'h.

At finite w, the likelihood is strictly concave if A has full column rank.
In the complete common PCM block with at least one nonextreme Person, the
earlier adjacent-logit identification argument gives that rank after the
declared centering constraints. Rank alone does not establish existence.
Under full rank, a finite unique maximum exists **if and only if**

    {d : A*d >= 0} = {0}.

Here is the direct finite-support argument. A nonzero direction with all
margins nonnegative has at least one positive margin under full rank. Moving
along it leaves the observed category at least as favorable relative to every
alternative, and strictly improves at least one rating likelihood for every
finite w. Hence there is no finite maximum. Conversely, if the cone contains
only zero, every unit direction has a negative margin. Compactness of the unit
sphere gives a uniform positive lower bound c on the largest adverse margin.
The negative log likelihood is at least `max_rows(-A*w) >= c*norm(w)` and is
therefore coercive. Continuity gives a finite minimizer, and strict convexity
makes it unique. For nonextreme Persons, a nonzero pure-ability direction cannot
satisfy the inequalities, so an improving direction necessarily affects beta.

If G is empty the structural profile is constant and no structural coordinate
is identified. If rank fails, the full structural target also needs an
identification decision. Thus none of the following implications is valid:
"an extreme Person implies structural failure", "a nonextreme sample guarantees
a finite estimate", or "positive curvature at one finite point proves a
finite maximum exists".

The implementation reuses the package's recession LP construction/solver,
maximizing the sum of the margins subject to A*d>=0 and abs(d_l)<=1. It uses
`timeout=0`, with no added wall-clock cutoff. For a positive LP direction,
small-denominator integer candidates are checked against the original integer
PCM matrix. A returned structural-recession certificate has all margins >=0,
at least one strictly positive margin, and a nonzero structural component.
The product/summation bound stays below 2^52, so the integer margin check does
not treat a small negative floating LP residual as exact feasibility. If this
verification is inconclusive, the result remains unresolved.

A near-zero LP objective is labelled `no_recession_detected`, not an exact
existence proof. The subsequent analytic profile/root-distance diagnostic
still has to pass, with positive curvature and its declared numerical budget.
It evaluates an exact-arithmetic sufficient root theorem in floating point;
outward-rounded certification is still distinct. A failed numerical check is
not relabelled as mathematical nonexistence.

### 3. The generator and every refit use the same extended estimator

For a finite fitted ability, the generator uses the usual PCM probabilities.
For an all-low/all-high fitted Person, it uses probability one at category
0/K-1 respectively. Those rows and Person IDs remain present, and the other
Persons' responses are generated independently at their fitted abilities.
An infinite ability attached to a nonmatching response pattern is rejected.
The code evaluates the endpoint distribution directly; it does not calculate
`0*Inf` logits or replace infinity with a chosen cap.

Every bootstrap dataset recomputes its own extreme/nonextreme classification.
An originally finite Person may become extreme in a generated dataset, and
is then profiled by the same zero-contribution rule. Structural checks use
the remaining nonextreme likelihood. The original N, repetition count, all
response rows, signed endpoint abilities, active-Person count, optimizer
messages and all planned attempts remain recorded. No unsuccessful dataset
is replaced and no successful-only reference distribution is constructed.

In the bounded complete-block growth regime already established above, this
extended estimator agrees with ordinary finite maximum likelihood with
probability tending to one, and likewise in conditional bootstrap probability.
Thus the earlier bootstrap limit is unaffected on the regular event. This
observation does **not** prove correctness at a fixed few-rating exposure,
at an extreme source conditional on that observed event, or for an unbounded
normal-population sequence. A point-mass generator represents the declared
plug-in estimator; it does not establish that the actual ability is infinite
or recover uncertainty about an extreme Person's finite true ability.

### 4. Executed positive and negative controls

The existing two-facet, Rater 3 x Criterion 3, four-category, N20, L1 design
was retained. In a copied validation fixture, Person 1 was set to all-low and
Person 2 to all-high; the other responses were kept. All 180 rows remain.
This is a deliberate boundary case, not a newly sampled outer dataset or a
new public fit to those altered responses. The inherited public parameter
vector serves only as initialization for this fixture; no public-point
comparison on the altered data is claimed.

Results in `validation-results/jml-pcm-extended-bootstrap-20261003/` show:

- The source extended-profile fit and all 12 planned inner refits passed the
  structural/numerical checks. Every inner dataset retained the two source
  extremes; all twelve returned structural points with
  `FiniteJointMaximum=FALSE`. They used 18 nonextreme likelihood contributions
  while retaining N=20 and every response row. The largest inner curvature-
  scaled distance bound was 4.496459e-7, below the 4.728708e-5 budget.
  Four nonzero optimizer termination codes remain recorded separately.
- At the fitted structural point, evaluation of the full original likelihood
  at signed ability caps 10,20,40,80 approached the extended supremum. The
  negative-log-likelihood gap decreased from 2.883779e-3 to 1.309314e-7 and
  then below 1e-8. At cap 80 the structural-gradient difference was
  3.441691e-15 and the largest extreme-ability gradient was 3.739742e-34.
  These caps check the limit identity; they are never fitted ability values.
- An all-extreme fixture returned `no_structural_information`, before any
  bootstrap generation. A different fixture with all responses equal to
  middle category 1 had **no extreme Persons**, but returned
  `structural_recession` before optimization/generation. Its retained integer
  direction had minimum margin zero and 360 strictly positive margins.
- Anchored extremes, incomplete common blocks, missing independence
  declarations and mismatched infinite abilities were rejected. RNG
  preservation, deterministic endpoint generation, basic-interval arithmetic,
  unavailable-inner accounting and completed-stage replay passed. Replay was
  checked with the refit and generator functions replaced by error traps.
- One refit of the unchanged finite source matched the earlier reference beta
  exactly in stored floating-point values. All twelve old generated response
  vectors were reproduced with their old seeds, but their old inner fits were
  **not rerun**. The new source/12 inner refits concern the changed boundary
  fixture; old finite-only evidence retains its own version and scope.

### 5. What is resolved and what remains

The previous 2.56% per-dataset extreme probability no longer implies a
refusal, so the old 99.42% lower bound at B=199 does not apply to v2. Indeed,
every dataset in the new check contains extremes and is accepted structurally.
This does not estimate the v2 failure rate: the fixture was deliberately
constructed and the inner count remains only 12.

Genuine structural nonidentification/recession or unresolved numerical fits
still produce an explicit unavailable result. Increasing B can still encounter
such outcomes, and the current all-required-refits rule is not a promise of
universal availability for arbitrarily large B at fixed exposure. A finite
structural estimate cannot be manufactured for those samples without changing
the estimator or restricting the target. Coverage, return probabilities,
inner quantile precision and the treatment of any remaining boundary mass
must be assessed together for a declared procedure. B=12 still has unbounded
sides in the previously recorded tail-quantile Monte Carlo brackets.

## October 3: all-attempt bootstrap quantile bounds and remaining inference limits

**Question and answer.** Must one unavailable inner fit invalidate every
bootstrap endpoint? No: bounds on the quantiles can retain all planned draws,
including unknown values. But a bound on possible quantiles is not by itself
a confidence interval for structural truth. Numerical uncertainty about an
existing estimate and mathematical nonexistence of that estimate must remain
distinguishable. The output-only implementation below resolves the accounting
and rank arithmetic; it does not supply the missing sampling theorem.

### 1. Why requiring every refit to succeed is the wrong limiting criterion

For a fixed source, let delta be the probability that an inner structural
estimate is unavailable. With independent draws, the probability of at least
one unavailable result in B attempts is `1-(1-delta)^B`. Even after the exact
extreme-profile treatment, delta can be positive: under the finite active-
Person generator, the event that every remaining Person becomes extreme has
positive probability and leaves a flat structural profile. More inner draws
therefore cannot guarantee success of an all-refits-required rule at fixed
exposure. This argument establishes positive mass, not a practically important
failure rate; the old 2.56% extreme-person event is still not a v2 failure rate.

Keep three different records: accepted structural estimates (which may include
infinite *abilities*), certified structural nonexistence/nonidentification,
and unresolved numerical cases. A finite iterate from a failed diagnostic is
not an accepted estimate. Missing results cannot be removed, resampled until
success, or assigned the mean of successful results: each would change the
reference distribution.

### 2. Sharp bounds without dropping or imputing a draw

For one nonzero contrast, let qhat be its original estimate. Among B attempted
bootstrap estimates, s=B-f are accepted. Sort their centered values as
`v_(1) <= ... <= v_(s)`. For a type-1 p quantile the rank is k=ceil(B*p).
Over every possible completion of the f unknown scalar values, its sharp
lower and upper bounds are

    Qlower(p) = -Inf          if k <= f, else v_(k-f),
    Qupper(p) = +Inf          if k > s,  else v_(k).

Putting all unknowns below the accepted values gives the first bound; putting
them above gives the second. Any other placement lies between them. Infinite
bounds describe arbitrarily remote finite completions as well as extended
values. This argument needs no missing-at-random assumption. For a nonzero
linear contrast every scalar completion can be realized by a structural-vector
completion; no assertion of simultaneous sharpness across contrasts is made.

For pL=(1-level)/2 and pU=(1+level)/2, the outer envelope of all completed
empirical *basic* intervals is

    [qhat - Qupper(pU), qhat - Qlower(pL)].

It reduces to the existing empirical basic interval when f=0. Removing
information cannot shrink it. This is a rank envelope, not a successful-only
quantile, percentile interval, point imputation or a treatment of a failed
finite iterate as a solution. The implementation obtains ranks from R's
type-1 quantile convention, preserving the frozen v2 behavior at floating-
point rank boundaries as well as ordinary ranks.

For a 95% interval, B=12 has ranks 1 and 12, so one unknown makes the envelope
`[-Inf,+Inf]`. B=199 has ranks 5 and 195: with finite accepted values, as many
as four unknowns still permit finite endpoints. B=999 has ranks 25 and 975
and permits 24. These are arithmetic facts, not acceptable failure-rate
thresholds or coverage guarantees. The illustration with B=199 is synthetic
rank arithmetic; no 199-refit experiment was conducted.

### 3. What theorem would make this an inferential procedure?

An undefined estimator has no bootstrap distribution until its behavior on
exceptional samples is defined. One can mathematically complete a structural
estimator by a prespecified finite vector whenever its finite maximum does
not exist, or work with a suitably defined extended estimator. This changes
its finite-sample definition and must be stated. The current output does not
silently adopt such a fallback: it encloses every scalar completion and marks
`InferenceQualified=FALSE`, even when both endpoints are finite.

Two implications can be proved directly and should not be attributed to
Higgins and Jochmans as a published missing-refit procedure:

- If two completed statistics agree outside an event of conditional bootstrap
  probability delta, their bootstrap CDFs differ uniformly by at most delta.
  This follows by bounding the difference of their indicator functions by
  the disagreement indicator. Thus, if delta tends to zero in probability,
  every such completion has the same weak limit as an already justified
  reference. A continuous, strictly increasing limiting CDF at the relevant
  quantiles then gives the same limiting quantiles. Agreement on original
  samples with probability tending to one is also required.
- For any specified completion, the empirical basic interval is contained
  pathwise in the completion envelope. Consequently an independently proved
  coverage lower bound for that completed procedure transfers to the envelope.
  This implication does not prove the premise. At fixed exposure with
  nonvanishing boundary mass, different completions can give genuinely
  different laws; finite envelope endpoints do not resolve that choice.

This containment does **not** require the unresolved numerical fraction to
vanish merely to transfer a coverage lower bound: even an unbounded envelope
contains the reference interval. A vanishing fraction is needed to recover
the same limiting quantiles and useful precision. Distinguish that computational
requirement from a vanishing *statistical nonexistence* probability, which
makes arbitrary estimator completions asymptotically equivalent in the
growing-exposure argument. Neither replaces correctness of accepted numerical
values. A complete coverage claim must also specify the output on unavailable
original samples; reporting coverage only among returned intervals would
condition on selection. The current assembler records that refusal and makes
no unconditional coverage claim.

In an admitted growing-exposure regime, a vanishing *fraction* of unknown draws
is the relevant quantity: conditional expectation of f/B is delta, and
`P*(f/B > epsilon) <= delta/epsilon`. Requiring none would unnecessarily demand
control of B*delta. To recover limiting quantiles one additionally needs
B->infinity, bootstrap consistency for the completed statistic, and numerical
error negligible on the inference scale. The earlier bounded complete-block
PCM argument supplies a candidate regular statistical regime, not a proof that
this numerical solver's unresolved probability vanishes. Normal tails,
paired rosters, corrected JML and fixed few-rating truth inference retain
their separate gaps. A failed original fit still has no qhat or generator;
this assembler returns no interval for it.

The underlying ordinary-ML bootstrap result remains
[Higgins and Jochmans (2024)](https://doi.org/10.3982/ECTA20712), under the
previously reviewed assumptions. CDF or quantile convergence still does not
establish convergence of moments or validate a covariance API.

### 4. Inner Monte Carlo uncertainty is another error budget

For a declared everywhere-defined statistic and a fixed number B of iid inner
draws, binomial order-statistic bounds enclose its ideal bootstrap quantiles.
For one target and desired joint Monte Carlo level 1-gamma, use

    l(p) = qbinom(gamma/4, B, p),
    u(p) = qbinom(1-gamma/4, B, p) + 1

at each of the two tail probabilities. Order 0 is -Inf and order B+1 is +Inf.
The four one-sided error probabilities total at most gamma; ties make the
binomial argument conservative. Apply the same unknown-rank bounds to these
orders. Pathwise completion containment preserves the joint guarantee without
assuming independence between the failure indicator and the statistic.
The guarantee is conditional on the source, not on a selected pattern of
successful fits, and is for both tails of **one** contrast, not all contrasts.

This 95% Monte Carlo statement is not 95% coverage of structural truth. Even
if an ideal basic interval had error alpha, a union-bound transfer through
an additional Monte Carlo event gives at best error alpha+gamma without a
stronger argument. A finite-budget inferential design must allocate these
errors jointly; alternatively its Monte Carlo error must vanish in the
asymptotic argument. Adaptive repetition counts need their own stopping/error
analysis. The output's `MCOuterLower/Upper` are precision diagnostics, not a
second qualified CI. Both nominal levels are retained explicitly in its tables.

### 5. Implementation and executed evidence

`jml-pcm-bootstrap-completion-20261003.R` adds only output arithmetic and a
checksum/binding-verified saved-v2 reader. It records the original denominator,
all unknown rows, reason classes, empirical quantile bounds and the two-tail
Monte Carlo envelope. The v2 numerical source, source binding and original
results remain frozen; this separate output is bound to those saved records
and its own source. The older v2 all-refits-required assembly remains historical
evidence, not the rule for this new completion-envelope result. No public API
or formal CI is changed. Accepted numerical values still inherit the floating-
point root-diagnostic limitations documented above; the rank bounds do not
turn those diagnostics into outward-rounded certification.

The targeted command is

    Rscript inst/validation/jml-pcm-bootstrap-completion-check-20261003.R \
      validation-results/jml-pcm-bootstrap-completion-20261003

It passed 817 enumerated completions, including ties, both infinite endpoints,
all-unknown samples and exact sharpness of every order bound. A synthetic
199-value example expanded [5,195] to [4,196] with one unknown, retained finite
endpoints with four unknowns and became unbounded with five. Basic-versus-
percentile arithmetic, monotonicity under hiding values, ignored failed finite
iterates, distinct structural/numerical reasons and unavailable-source refusal
also passed. Exact binomial tail budgets were checked for B=12,199,999 and
nominal levels .8,.9,.95,.99. These deterministic checks are not coverage trials.

The saved N20, Rater 3 x Criterion 3, four-category boundary fixture's 12
accepted draws reproduced both existing empirical basic endpoints exactly:
Rater 1-2 [-0.8158426,0.02940505] and Criterion 1-2 [-0.8675291,0.28141968].
Both joint-tail Monte Carlo outer envelopes remain `[-Inf,+Inf]`: B=12 is
insufficient for their tail precision. Deliberately hiding one result and
substituting a saved separation control checked negative branches; neither is
an observed bootstrap failure-rate estimate. Every saved numerical file and
the frozen R50 source identities remained unchanged, with generator/refit
functions replaced by error traps during replay. New fits: **0**. New generated
datasets: **0**. Evidence is retained in `checks.rds` in the directory above.

The resolved issue is the unnecessary rejection caused by a free extreme
Person, not incidental-parameter bias or universal confidence-interval
validity. Keep source/generator identity, the fixed few-rating route,
normal-tail/paired-roster extensions, corrected JML and MML obligations
separate. The public package, its finite optimizer traces and the frozen R50
comparison were not changed by this reference implementation.

## October 3: whole-sample interval rule and a joint error budget

**Question and answer.** The previous completion envelope still left the
original-sample failure output and the combined error budget unspecified.
The new research rule returns the full real line on an unavailable original
fit or recorded source-generation failure, and otherwise uses the two outer
quantile bounds with an explicit Monte Carlo error budget. This defines an
output for every statistical failure branch in the admitted PCM reference.
It does not turn an uninformative output into a successful estimation or
establish finite-sample truth coverage. Malformed inputs, corrupt saved records
and unfinished runs remain errors; they are not classified as statistical
failures to be hidden behind a full-line interval.

### 1. A declared comparison statistic and interval procedure

For the proof comparison, define T(y) to be the exact extended-profile PCM
structural maximum when it is finite and unique, and the zero structural
vector otherwise. The zero respects the centered coordinates and makes this
a measurable finite-valued statistic on every finite response array. It is
an explicitly declared *theoretical completion*, not a substituted estimate:
the implemented unknown-rank envelope includes all possible scalar values and
does not insert this zero into the draws. On the regular event this T agrees
with exact ordinary maximum likelihood. In the bounded complete-block growth
regime previously proved, its exceptional event vanishes both in the original
sampling law and conditionally in the bootstrap law, so the completed T has
the same bootstrap limit. This argument does not make completions equivalent
when boundary mass persists at fixed exposure.

Fix one nonzero contrast h in advance. For an accepted source with exact point
qhat=h'T(y), the ideal conditional bootstrap contrast is q*=h'T(y*), using the
declared fitted fixed-ability generator and the original design. Free extreme
abilities retain their exact endpoint generators. Declare a target error alpha
and a positive Monte Carlo allocation gamma<alpha. Set a=alpha-gamma. At a
fixed inner B, retain every attempted dataset, and use

    pL=a/2, pU=1-a/2,
    l=qbinom(gamma/2,B,pL), u=qbinom(1-gamma/2,B,pU)+1.

From the accepted centered values and all unknown ranks, let L be the sharp
lower bound on order l and U the sharp upper bound on order u, with order 0
equal to -Inf and order B+1 equal to +Inf. Return

    C_B = [qhat-U, qhat-L].

Only two one-sided Monte Carlo events are needed for this outer interval.
The earlier four-sided bands for both quantiles remain a separate diagnostic;
the new rule does not pay for two unused sides. On original-fit failure or
recorded generation failure, return C_B=R without attempting to manufacture
a point or generator. Record the reason and whether a point was available.
If the source is usable but B/unknown ranks leave both sides unbounded, that
also returns R, with `SourceFallback=FALSE` to distinguish its cause.

For a concrete *error-allocation illustration*, alpha=.05 and gamma=.005 give
a .955 ideal basic interval and a .995 joint Monte Carlo enclosure of its
two required sides. These numbers are explicit inputs, not a new package
default or an independently validated small-sample configuration.

### 2. Coverage transfer without conditioning on successful original fits

Let C_infinity(y) be the ideal basic interval at statistical error a for an
accepted source, with R on source fallback. Suppose a matching statistical
argument establishes

    P_q0(q0 not in C_infinity) <= a + epsilon_NL.

This is an assumption to check for the intended sampling regime, not a result
of the quantile code. The previously established specialization of
[Higgins and Jochmans (2024)](https://doi.org/10.3982/ECTA20712) gives a route
with epsilon_NL->0 for exact ordinary PCM under its bounded complete-block
growth conditions. It does not supply a numerical finite-N bound here.

Conditional on each usable original sample, the binomial order bounds imply

    P*(C_infinity subset C_B) >= 1-gamma.

The lower-quantile failure is bounded by `P{Bin(B,pL)<l}`; the upper-quantile
failure by `P{Bin(B,pU)>=u}`. Each is at most gamma/2. Atoms are conservative.
Unknown-rank bounds contain the relevant completed order statistics for every
realization, even when numerical failures depend on their values. On source
fallback both intervals are R, so containment is automatic. Averaging over
all original samples and applying a union bound yields

    P_q0(q0 not in C_B) <= a + epsilon_NL + gamma
                       = alpha + epsilon_NL.

No division by the original-fit success probability appears. Arbitrarily
frequent numerical *nonreturns* cannot invalidate this containment argument;
they can make it useless by returning R frequently. Thus B->infinity and a
vanishing numerical-failure fraction are precision conditions, not necessary
for this conservative coverage transfer. This is a pointwise statement for
the prespecified contrast, not simultaneous coverage across facets/contrasts.

The implication assumes correct accepted numerical values and the specified
generator. If the required numerical/coupling validity can fail with probability
eta_NL, a corresponding argument adds eta_NL to the bound; setting it to zero
without proof is invalid. The current floating-point root diagnostic is not
outward-rounded certification and does not by itself supply that probability
bound. Approximation of the generating probabilities also needs its own
negligible-error or coupling argument. Hence every result continues to carry
`InferenceQualified=FALSE`. There is still no finite-N 95% truth guarantee,
normal-tail/paired-roster extension, corrected-JML theorem or covariance claim.

### 3. Finite endpoints, useful precision and useful delivery are distinct

With f unknown inner results and the two orders above, finite accepted values
give two finite endpoints precisely when `f <= min(l-1,B-u)`. For the .05/.005
allocation just specified:

| B | Lower order l | Upper order u | Largest f allowing two finite endpoints |
| --- | --- | --- | --- |
| 12 | 0 | 13 | None, even f=0 |
| 199 | 0 | 200 | None, even f=0 |
| 263 | 0 | 264 | None, even f=0 |
| 264 | 1 | 264 | 0 |
| 999 | 11 | 989 | 10 |

B=264 is the smallest count allowing finite endpoints with no unknowns for
this allocation. It uses the most extreme observed orders and is not an
adequate-precision recommendation. B=999 is a rank illustration, not an
authorized launch or a universal replication count. These are binomial
calculations, not new fitted bootstrap experiments.

The outer-condition summary now requires every planned dataset row and reports
all-sample truth inclusion, finite-interval rate, finite truth-delivery rate,
coverage conditional on finite intervals, full-line rate and source-fallback
rate separately. It also retains overall width, which is infinite if an
unbounded interval occurs, alongside explicitly conditional finite width.
For example, returning R on every dataset yields 100% all-sample containment
and **0% finite truth delivery**. Neither conditional coverage nor the number
of defined set outputs can be presented as practical success by itself.
The existing broader validation summaries already distinguish availability
from delivery; this addition gives the new set-valued rule its matching counts
without changing those frozen studies. These remain descriptive outer metrics;
R=50 does not become a precise coverage guarantee through this accounting.

### 4. Implemented and checked without refitting

The existing completion script now provides `jml_pcm_bootstrap_procedure()`
and `jml_pcm_bootstrap_delivery()`. Its saved-result reader accepts an explicit
analysis level and recorded zero-generation failures. Numerical source bindings
are preserved; analysis-level/error-budget changes affect only postprocessing.
The previous completion source/check were archived byte-for-byte under
`validation-results/jml-pcm-bootstrap-completion-20261003/source-completion-v1/`
before editing, retaining the old `checks.rds` identities. New evidence is in
`checks-whole-sample.rds` in that directory's parent. No public help/API or
frozen R50 fitting rule changes.

The targeted check passed the new source and generation fallback branches,
joint-budget validation, corruption rejection, exact rank thresholds and
whole-sample delivery accounting, alongside the affected completion regression.
It reused both saved original-failure controls and the accepted source/12
inner fits; all original numerical files and R50 numerical source identities
were unchanged. A copied synthetic cache exercised generation failure; it is
not an observed failure-rate estimate. New fits and generated datasets: **0**.

An independent finite-support calculation checked Monte Carlo containment:
for Bernoulli-valued bootstrap contrasts with probabilities .1 and .9, B=60,
target level .8 and gamma=.05, enumerate all 61 possible success counts and
weight them by their exact binomial probabilities. Hide every rare value,
making availability depend on the statistic. The procedure contained the
ideal [.2-1,.2-0] basic interval with probability .998203 in each case, exceeding
the required .95 Monte Carlo containment. This checks the Monte Carlo layer
under value-dependent failures; it is not PCM truth-coverage evidence.

The new 95% research rule applied to the saved N20, Rater 3 x Criterion 3,
four-category source still returns R because B=12. The all-extreme and
structurally separated original controls also return R, but as identified
source fallbacks with unavailable point estimates. This increment closes the
definition and error-accounting gap; obtaining *informative*, qualified JML
intervals still requires the matching statistical and numerical evidence.

## October 3 — Completed N30 comparison: numerical accuracy and truth inference

The 400 jobs are **eight matched procedures on 50 independent parent datasets**,
not 400 independent replications or 400 inner bootstrap draws. This review uses
all twelve frozen tables in
`validation-results/mfrm-wide-map-pcm-r50-portable-20261003/summary-n30/`, the
separate 200-job JML research comparison, and the saved calibrations. The
updated `report.html` connects the actual figures, results, numerical audit and
interpretation. The two existing figures were visually inspected. No original
fit, generated dataset, failure, method allocation or acceptance rule was
replaced. The original 400 output hashes, 200 research-result hashes, input
bundles and numerical source identities were checked before interpretation.

The condition is `AB:paired-L1:N30:SD1:S-PCM`: 30 Persons, two non-Person facets
(Rater 3 levels, Criterion 3 levels), scores 0–3, two Raters per Person and all
three Criteria, hence six ratings per Person and 180 rows. Each of the three
Rater-pair rosters has ten Persons in every dataset. Generating abilities are
independent N(0,1), slopes are one, and responses are conditionally independent.
Planned incomplete assignment here is not evidence for random or informative
missingness, repeated-response dependence, arbitrary facet structures or
covariate effects. Free-population MML here estimates an intercept-only normal
population. Other N, SD, exposure, model and design conditions remain required.

### 1. Adopted solutions: retain the procedure and the output-specific checks

| Arm | Finite initial points | Initial numerical pass | Scoring source ready | Research JML interval returns |
| --- | ---: | ---: | ---: | ---: |
| PCM-MML-fixed | 50 | 50 | 50 | Not this procedure |
| PCM-MML-free | 50 | 50 | 50 | Not this procedure |
| PCM-JML | 50 | 50 | 16 | 50 |
| GPCM-MML-fixed | 50 | 50 | 50 | Not this procedure |
| GPCM-MML-free | 50 | 50 | 49 | Not this procedure |
| GPCM-JML | 50 | 46 | 14 | 36 |
| GPCM-JML2 | 49 | 45 | 49 | 45 |
| GPCM-JML4 | 49 | 46 | 49 | 46 |

These columns implement different contracts. In particular, ordinary JML's
scoring-source refusal on extreme Persons is not proof that its structural
profile has no finite solution. Conversely, a conditional-scoring source
return does not establish consistent roots across all corrected-JML starts,
truth-centered inference, or a global GPCM solution. The order-2/order-4
research interval rules retain their consistent-root requirement; four/three
finite candidates have unresolved starts, and one candidate in each arm has
no local root. The same cases remain in all planned denominators.

The ordinary PCM and GPCM local-root diagnostics give maximum displacement
bounds of 9.3944e-5 and 1.0419e-4 stored-root SD, respectively, among the
50/36 admitted cases. The PCM profile is concave in its linear structural
coordinates, so an exact finite stationary solution has a different global
interpretation from a GPCM stationary solution. However, the current sufficient
root inequalities are evaluated in floating point without outward rounding.
They are numerical evidence, not machine-certified existence or a probability
bound on accepting an incorrect solution. GPCM's local branch remains distinct
from a global maximum; its 14 research refusals are three nuisance-profile
checks, one whitening-identity check and ten inconclusive/excessive local bounds.

Corrected order 2/4 scoring checks have maximum equation residuals
9.8484e-11/9.6928e-11 and remaining-step norms 7.3737e-10/4.2326e-10 among the
49 finite candidates. Those very small values do not resolve inconsistent
starts or show that the equation's population root is the generating truth.

For MML, selected scoring-source orders (31/61/121) are 50/0/0 for fixed PCM,
8/26/16 for free PCM, 0/39/11 for fixed GPCM and 5/22/23 for free GPCM.
Refinement is part of the frozen output rule, not a new independent replicate.
The one unresolved free-GPCM source is replicate 3 (`job-03620`): at q121 its
q241 comparison gradient is 1.74565e-4 and gradient change is 1.79793e-4, exceeding
the source threshold 1e-4. Its interval may nevertheless pass its distinct
standardized gradient/covariance rule. Do not call this an inconsistency without
first identifying the intended output and declared tolerance.

All 50 primary-contrast intervals return for each MML arm. The nonlegacy
intervals retain maxima below .00548 for the standardized quadrature score
shift and below .00942 for relative full covariance change (threshold .01).
Their selected fit stages differ from the scoring-source stages. Initial-q31
to later-stage grid probabilities change by as much as .00149 (free PCM),
.00613 (free GPCM), and .00117 (fixed GPCM). These are observed refinement
sensitivities, not rigorous errors relative to exact integration.

The legacy fixed-N(0,1) PCM records lacked a finer-grid comparison. A targeted
supplement, `mfrm-wide-map-fixed-pcm-quadrature-20261003.R`, now evaluates q61 and
q121 at each of its **unchanged 50 q31 parameter vectors**, reusing the stored
q31 covariance. It uses analytic gradients and numerical differences of those
gradients for observed information; no optimization or simulation occurs.
The maximum q31-to-q121 standardized score displacement is .0029142 and the
relative covariance change is .0019772; all 50 pass the interval-sensitivity
limits. The maximum q61-to-q121 covariance change is 1.5633e-5. In contrast,
none of the 50 passes the other arms' strict absolute scoring-source criterion
when applied retrospectively: q121 gradients range .0004793–.0122158, while
the q31-to-q121 objective difference can reach .0028742. Thus the interval
sensitivity is small, but **identical quadrature qualification across all
scoring sources has not been shown**. This audit does not retroactively change
public readiness or discard the retained fixed-PCM comparisons.

### 2. Probability arithmetic, local-generator error, and truth recovery

`mfrm-wide-map-n30-accuracy-20261003.R` exports exact hexadecimal binary64
parameters and probabilities from all retained finite calibration phases and
available ordinary-JML nuisance profiles. The independent Python adjacent-odds
recurrence in `mfrm-wide-map-probability-precision-20261003.py` recomputes 43,605
four-category probability vectors in 681 job/phase/purpose groups with mpmath
1.3.0 at 80 decimal digits. Maximum raw absolute error is 6.427315e-16; the worst
row differs between 80 and 120 digits by 1.824785e-81. This is a different
implementation of the same conditional response model, not another fitted
estimator. Binary64 values are passed exactly, without decimal parameter
rounding. Rows at infinite ordinary-JML ability use the mathematical endpoint
mass rather than a finite ability clip.

For a distribution comparison, binary64 probability vectors are first
normalized as sampling weights in high precision; their raw row-sum error
can reach 3.27043e-16. Half the L1 difference of unequal-mass vectors would not
be a valid total-variation distance. The maximum sum of normalized row TV over
an ordinary-JML 180-response generator is 1.114483e-14, an upper bound on its
independent product-law TV discrepancy at identical stored parameters. The
136 underflowed categories occur in four ordinary-GPCM grid evaluations; their
largest group total omitted mass is below 4.3e-331. No profile-generator group
has underflowed positive categories. Tiny absolute mass error does not imply
small relative error for a vanishing probability or accurate log-tail losses.
No PRNG/discrete sampling implementation or outward-rounded arithmetic bound
is certified by this comparison.

The twelve-table response-probability RMSE, in contrast, measures recovery of
**true probabilities** on the fixed theta grid -2,-1,0,1,2 and nine facet cells.
It is approximately .0584 for fixed PCM MML, .0615 for free PCM MML, .0845 for
ordinary PCM JML, .0702/.0757 for fixed/free GPCM MML, .1529 for ordinary GPCM
JML, and .0786/.0799 for orders 2/4 (49 returns). Those errors are orders of
magnitude larger than arithmetic roundoff. They combine structural estimation
error and the chosen procedure; they are neither floating-point precision nor
an integrated error over the normal ability population.

A separate local perturbation calculation connects the stored root radius to
conditional generating probabilities. Let B satisfy B' H_profile B = I and
let the retained joint metric use

    delta_beta = B t,
    delta_theta_i = v_i / sqrt(h_i) - c_i' B t / h_i,
    ||(v,t)|| <= r,

where h_i is nuisance information and c_i is its structural cross-information.
For categories k,l in row j of Person i, let d be the difference of their
linear structural designs, s the log-slope design, and g=k-l. Define

    G = r || B' (0,s) ||,
    F = sqrt(g^2/h_i + || B' ((d,0) - g*c_i/h_i) ||^2),
    f0 = g*theta_i + d' beta_linear.

The change in this pair of logits is bounded by

    exp(s' log_slope) * { |f0| expm1(G) + exp(G) r F }.

Taking the maximum over category pairs gives a bound D_j on the range of the
logit perturbation. Hoeffding's bounded-range log-mgf inequality gives
KL(p_j || q_j) <= D_j^2/8. Independent rows and Pinsker's inequality therefore
give row TV <= D_j/4 and dataset TV <= sqrt(sum_j D_j^2)/4 (capped at one).
Extreme-person endpoint rows contribute zero to this *local-root* perturbation.
They do not thereby reproduce the true finite-ability sampling law.

Across the admitted ordinary PCM/GPCM cases, the largest dataset bounds are
2.67865e-4/6.47037e-4. The bound function reconstructs saved scores and profile
Hessians to within 1e-10 for all 86 admitted profiles. A separate deterministic
check at the largest PCM/GPCM bounds tested 88/92 positive and negative axis
and mixed directions on the joint ball. Every observed logit span and row TV
satisfied its bound; maximum TV/bound ratios were .521/.534. These checks
support the algebra and implementation, not a proof of all inputs or a new
coverage experiment.

The error accounting must also include the number B of inner datasets.
Independence gives a KL-based bound **sqrt(B)** times the one-dataset local-root
TV bound; a general arithmetic product coupling adds at most B times its
one-dataset TV. At the illustrative B=999, the maximum local bounds would be
about .00847 for PCM and .02045 for GPCM, whereas the arithmetic contribution
is at most approximately 1.12e-11. These are conservative sensitivity bounds,
not observed coverage errors, and not an instruction to launch B=999. The
local bounds do not yet justify setting numerical error eta_NL to zero in the
whole-sample coverage-transfer argument above. Original/inner root acceptance,
contrast endpoint perturbations, global GPCM branch selection and outward
certification remain additional issues. This hypothetical paired-roster
probability law is also not the currently scoped complete-block bootstrap
adapter. No new paired-design bootstrap experiment was run.

### 3. Statistical evidence: bias persists after numerical accuracy

Prespecified contrast: Criterion level 1 minus level 2, generating value -.5.
Bias/RMSE below use all finite initial point returns; interval inclusion uses
its own explicitly stated procedure and denominator. JML intervals use the
prespecified asymptotic-roster research sandwich and a normal approximation.
They are not bootstrap intervals or newly qualified public truth intervals.
MML intervals use their saved output-specific selected stages.

| Arm | Points | Criterion bias | Bias MCSE | RMSE | Intervals | Covered / returned | Returned and covered / 50 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| PCM-MML-fixed | 50 | -.0222 | .0316 | .2220 | 50 | 47/50 | .94 |
| PCM-MML-free | 50 | -.0320 | .0340 | .2404 | 50 | 47/50 | .94 |
| PCM-JML | 50 | -.1490 | .0419 | .3293 | 50 | 46/50 | .92 |
| GPCM-MML-fixed | 50 | -.0466 | .0355 | .2530 | 50 | 47/50 | .94 |
| GPCM-MML-free | 50 | -.0792 | .0446 | .3219 | 50 | 48/50 | .96 |
| GPCM-JML | 50 | -1.2605 | .7497 | 5.3969 | 36 | 34/36 | .68 |
| GPCM-JML2 | 49 | -.1025 | .0490 | .3549 | 45 | 40/45 | .80 |
| GPCM-JML4 | 49 | -.1052 | .0495 | .3590 | 46 | 41/46 | .82 |

The ordinary PCM Criterion bias is about 3.55 Monte Carlo SE from zero, while
its local numerical displacement is negligible on the reported uncertainty
scale. This is evidence of centering error in this sampling condition, not a
roundoff explanation. It does not by itself identify its exact population
pseudo-root or prove a fixed-exposure asymptotic bias formula.

Ordinary GPCM requires a different interpretation before calling its whole-table
mean error estimator bias. Replicates 6/24/28 have Criterion estimates
-37.2950/-9.3021/-3.7881 and account for **99.0269%** of total Criterion squared
error. Their minimum/maximum slopes are .0141/485.8, .0222/903.8 and .0603/118.4;
all three fail both the initial numerical screen and the research interval
admission. Extreme parameter traces are evidence of a numerical/boundary/branch
problem needing discrimination, not proof of the exact global likelihood's
nonexistence. Do not remove these cases from practical failure accounting or
pretend they establish the sampling bias of the accurately solved estimator.
On the selected 36 interval-return cases, Criterion mean error is still -.1881
(MCSE .0582). That selected-subset result is not the all-sample bias.

Correction order 4 has not demonstrated an advantage over order 2. On their
49 common finite returns, the order-2 minus order-4 Criterion MSE difference
is -.002931 (paired MCSE .002593); for the Rater contrast it is +.000174
(MCSE .000308). On the common 45 numerical-pass cases these become -.000365
(.000484) and -.000136 (.000167). Preserve both named orders and their
failures; choosing an order using the observed truth coverage would define a
new, unevaluated selection procedure.

Within the interval-return subset, Criterion empirical SD / root mean reported
variance are .2966/.2899 (PCM JML), .3490/.3764 (GPCM JML), .3165/.2820 (order 2),
and .3561/.3115 (order 4). The corrected Criterion intervals therefore combine
residual centering error with a lower average estimated variation on this
subset. Rater variation is much closer for both corrected orders. Accurate SE
alone cannot establish truth coverage, and mixture/selection effects remain.

The ten Persons per roster permit the fixed-assignment meat calculation;
count/rank feasibility is no longer blocked by singleton rosters. The
finite-roster variant multiplies each group's meat by 10/9, increasing SE by
sqrt(10/9)=1.05409. Criterion covered counts become 46/34/41/42 for
PCM/GPCM/order2/order4, at unchanged return counts 50/36/45/46. This mechanical
normalization does not remove structural bias or supply exact finite-N
unbiasedness for a sandwich evaluated at estimated parameters. Under the
current repeated-sample design, Person abilities are redrawn independently
within the fixed rosters. A different target conditioning on every fixed
ability requires a separate score-mean/variance argument.

R=50 is not sufficient to claim calibrated 95% coverage or model equivalence.
For example, 46/50 has an exact 95% binomial Monte Carlo interval approximately
[.808,.978]. Conditional GPCM inclusion 34/36 is .944, but successful truth
interval delivery over all requested datasets is .68. The two quantities
answer different questions. The ordinary-GPCM outliers also make a normal
Monte Carlo approximation to its mean error fragile. No selective deletion,
post-hoc tuning or universal winner follows from this first condition.

### 4. Scoring, extremes, and the applicability decision

There are 50 extreme Persons across 34/50 original datasets. Ordinary PCM and
GPCM native JML retain 1,450 finite and 50 infinite abilities; infinite losses
are not clipped away. Corrected arms have 1,421 finite, 49 infinite and 30
unavailable native abilities, reflecting their one failed calibration. MML
returns all 1,500 finite native posterior scores, including extreme-response
Persons, under the fitted or fixed normal population model. Those native
scores are not the same estimator as ordinary JML abilities.

Common-prior N(0,1) EAP after prespecified refinement supplies the comparable
scoring procedure. Future-panel delivery is 50/50 for fixed/free PCM MML and
fixed GPCM MML, 49/50 for free GPCM MML and both correction orders, 16/50 for
ordinary PCM JML and 11/50 for ordinary GPCM JML. The latter loses three of its
14 source-ready datasets to posterior integration refusal. Future RMSEs are
.4555/.4569 (fixed/free PCM MML), .4714/.4751 (fixed/free GPCM MML), .4798 (PCM
JML, selected 16), .5463 (GPCM JML, selected 11), and .4831/.4851 (orders 2/4,
selected 49). The 60 future Persons within each dataset do not multiply the
number of independent calibration replicates. Returned-only rankings must
retain their paired common-return subset and Monte Carlo SE. Scoring intervals
remain conditional on calibration and omit its uncertainty.

A degenerate fitted generator for an observed extreme Person is the correct
extended-profile limit at the fitted infinite ability. At finite true ability,
that Person can give nonextreme responses on repetition. Thus correctly
computing the fitted endpoint law is not by itself a bootstrap validity
argument. Fixed six-rating exposure leaves positive extreme-response
probabilities; rejecting an entire source whenever an extreme occurs loses
34/50 PCM sources here. The extended structural profile resolves that source
*definition* issue in the scoped research method, while informative truth
inference requires additional statistical evidence.

Higgins and Jochmans, *Bootstrap inference for fixed-effect models*,
[authors' full paper, assumptions 1–6 and theorem 1](https://jochmans.github.io/publications/panel%20bootstrap/panel_bstrap.pdf),
justify a bootstrap under joint N/exposure growth, compact/interior parameters,
within-Person identification and uniform information conditions. The current
fixed-six-rating, normal-ability, paired-roster condition is not covered merely
because a bounded complete-block PCM sufficient case was previously checked.
This is a limitation of the attempted application of the theorem, not evidence
that the published theorem is false. The new whole-sample completion rule
retains its own distinction between containment, full-line fallbacks and
finite useful delivery; no current Wald table estimates that bootstrap rule's
coverage.

The next methodological priorities, now supported by this condition, are:

1. Treat ordinary PCM as a numerically resolved benchmark for the unresolved
   centering/coverage problem. For fixed few-rating PCM/RSM, reuse the exact
   conditional-rank and two-contrast interval reference already checked on the
   saved N20 paired design. Establish its N30 conditioning/support mapping and
   compare useful interval delivery on the same parent datasets, keeping
   extremes' zero conditional information explicit. Do not redo the existing
   derivation or imply that its two contrasts qualify a full covariance for all
   structural coordinates. This is a separate comparator, not a relabeling of JML.
2. Retain the exposure-growth JML/basic-bootstrap route under verified design,
   tail, information and numerical assumptions. Extend paired rosters and
   informative delivery before promoting it to the present condition; budget
   generator and endpoint errors over the complete procedure.
3. Diagnose GPCM's rejected extreme-slope branches on the identified saved cases,
   retaining failed jobs and a prespecified root policy. Do not confuse tiny
   local residuals or correction-order agreement with truth centering. Use
   matched common-return comparisons alongside overall delivery.
4. Retain MML as the model-based comparator here, with the exact population
   assumption and output-specific integration checks. Preserve the unresolved
   strict fixed-PCM source comparison and the one refused free-GPCM source.
   Extend SD/exposure/sample-size and model checks using the existing roadmap;
   no general latent-regression, missingness or dependence claim follows.

The new checks are in `accuracy-review/audit.rds`, `probability-precision.csv`
with its metadata JSON, `fixed-pcm-quadrature/summary.rds`, and
`local-bound-checks.rds`. They reuse saved data and parameters. New model fits,
new response datasets and new bootstrap replications: **zero**. The fixed-PCM
information supplement does perform the explicitly described fixed-parameter
numerical differentiation. The numerical R50 sources and outputs remain
unchanged. Formal JML structural-truth interval qualification remains false.

## October 3 — Truth-interval qualification decision after the completion request

The request to finish qualification requires a decision about the **interval
procedure**, not permission to change an unqualified flag to true. The current
uncorrected truth-Wald rule cannot be qualified generally: an exact finite-N
counterexample below rules it out even with perfect arithmetic and the matching
sandwich. A different, conditional procedure gives finite-sample truth coverage
for the specified PCM contrasts and the GPCM nonowner contrast. Its validity is
not a validation of JML Wald or plug-in bootstrap intervals. Public JML API
qualification for all structural coordinates is **not** complete.

The user was asked whether the intended deliverable may retain the JML point
and use an explicitly conditional interval, or must remain inference based on
the JML sampling distribution via Wald/bootstrap. The following read-only
qualification work is useful under either interpretation. It does not silently
replace the requested estimator, change a public API or authorize a universal
claim for GPCM Criterion locations.

### A. A closed rejection decision for a general uncorrected JML Wald rule

Consider the two-item binary Rasch submodel, with centered item difficulties
`b1=log(2)`, `b2=-log(2)`, all true Person abilities zero, and independent
responses conditional on ability. The target is `delta=b1-b2=log(4)`.
For one Person the probabilities of response patterns 01, 10, 00, 11 are
4/9, 1/9, 2/9, 2/9. Let A=count(01), B=count(10), with N-A-B extreme Persons.
Their extended-profile contributions are exactly zero, not approximated by a
large finite ability. The two mixed patterns have profile ability zero.

Writing q=logistic(delta/2), the retained profile log likelihood is

    ell(delta) = 2 A log(q) + 2 B log(1-q).

For A,B>0 the exact structural JML estimate and the one-roster Person sandwich
are therefore

    delta_hat = 2 log(A/B),
    Var_hat(delta_hat) = 4(1/A + 1/B).

This is the sandwich for fluctuations about the equation root; replacing it
by the smaller inverse profile information cannot repair the example.
Consider the wider-than-usual interval `delta_hat +/- 2 SE`, and even enlarge
its covariance by the finite-roster factor N/(N-1). On the event

    E = { A >= 3 B, B >= 40 },  N=480,

its center exceeds truth by at least log(9/4), whereas its squared half-width
is at most `(64/120)*(480/479)`. A rational lower bound for log(9/4), using the
previously checked positive-series remainder, has square strictly larger than
this rational number. Every dataset in E therefore misses the true contrast.
This is an inequality proof; no normal approximation to the sampling law is
used. Returning the whole line on other, failed datasets cannot rescue its
coverage on E.

The exact trinomial probability is

    P(E) = 9^(-480) sum_{b=40}^{120}
             choose(480,b) 4^(480-b)
             sum_{a=3b}^{480-b} choose(480-b,a).

Integer arithmetic proves P(E) >= .958951. Consequently coverage of this
wider interval is **at most .041049**. The usual 1.96-SE interval is a subset
and obeys the same upper bound. This does not claim that the specific N30,
four-category, 3 x 3 condition has 4% coverage, or that every conceivable JML
interval is invalid. It closes the possibility of a **general uncorrected
truth-Wald qualification** merely by solving the equations more accurately or
estimating their root covariance. The existing fixed-exposure asymptotic
counterexample is now backed by an explicit finite-sample probability bound.

The reproducible certificate is
`jml-wald-noncoverage-certificate-20261003.py`, with exact rational probability
and source identities saved in
`validation-results/jml-truth-interval-decision-20261003/wald-noncoverage.json`.
No optimizer, response generator, estimated ability distribution, Monte Carlo
coverage study or floating normal quantile enters this certificate.

**The same submodel also rules out a general fixed-exposure plug-in basic
bootstrap claim.** As N increases with two items fixed, A/N tends to 4/9 and
B/N to 1/9, so the exact source JML tends to 2 log(4). Every mixed-pattern
Person has fitted ability zero; the original extreme Persons have signed
infinite fitted ability. At the limiting source structural parameter, a mixed
Person's fitted probabilities of patterns 01 and 10 are 16/25 and 1/25.
The original extreme Persons remain extreme under the extended-profile
generator. There are asymptotically (5/9)N mixed source Persons; conditional
laws of large numbers for their bootstrap counts imply

    A*/B* -> 16,
    delta_hat* = 2 log(A*/B*) -> 2 log(16) = 4 log(4).

Both ideal bootstrap quantiles at fixed interior probability levels therefore
converge to 4 log(4). The basic interval with endpoints
`2 delta_hat - quantile(delta_hat*)` converges to the singleton {0}, whereas
the true delta is log(4). Its truth coverage tends to **zero**. The probability
of A* or B* being zero tends to zero, so this failure is not explained by
refit nonexistence, an unresolved numerical branch, a finite inner replication
count or inaccurate categorical probabilities. An always-full-line fallback
could contain truth, but would not supply informative intervals.

This derivation concerns the exact, extended-profile fixed-ability generator
with fixed two-item exposure. It does not contradict the exposure-growth
bootstrap theorem, and does not assert that the existing two-facet,
four-category complete-block implementation has this particular limiting
value. It establishes that **plug-in basic bootstrap is not a general repair
for fixed-exposure JML bias**. An application to the N30 six-rating design still
needs its own applicable argument; simply increasing B cannot create it.

### B. What can be qualified while retaining the JML point

For the preceding disjoint-pair PCM construction, write H for the selected
unordered pairs and conditioned nuisance statistics. For Rater 1-minus-2,
`t=T1` after also conditioning on T3 and `s=1`. For Criterion 1-minus-2,
`t=n3` after conditioning on n1,n2 and `s=3`; responses on Criterion 3 are held
fixed. In both cases the conditional law is

    P_psi(T=t | H) = h_H(t) exp(-s psi t) /
                       sum_u h_H(u) exp(-s psi u).

All Person abilities and remaining structural nuisance parameters cancel.
The inclusive lower/upper tail tests, each of size at most alpha/2, give an
interval C(H,T) satisfying

    P_beta,theta(psi in C | H) >= 1-alpha,
    P_beta,theta(psi in C) >= 1-alpha.

The second statement follows by averaging over H. It holds for each fixed
finite ability vector and hence for arbitrary mixtures, including the normally
distributed abilities of N30. It needs neither negligible JML bias nor a normal
sandwich approximation, and does not require a fitted bootstrap generator.
Extreme Persons give equal-score pairs and zero conditional information; they
remain in the accounting. Singleton conditional support gives the full line;
a boundary statistic retains its infinite endpoint. Finite bounds are rounded
outward as exact decimal strings. No finite search box is substituted for an
infinite confidence limit.

There is a useful connection to the *exact* ordinary PCM JML statistic, without
claiming that the two point estimators coincide. Under this conditioning, the
full joint log likelihood has the form

    ell_H(psi,nu;t) = -s psi t + K_H(psi,nu).

The data term for every nuisance sufficient statistic is fixed by H. Profiling
nu gives `-s psi t + k_H(psi)`. The two maximizing inequalities imply that an
exact maximizing psi is nonincreasing in t; it is strictly decreasing wherever
the finite unique profile maximum is regular. Thus the conditional tail
ordering is also the ordering of that regular exact JML contrast. Numerical
optimizer output is not needed to evaluate these tails. On nonregular samples
the sufficient-statistic procedure remains defined with its honest unbounded
outcomes; no fictitious finite JML value is inserted.

The current public JML point can therefore be **retained and displayed beside**
this exact conditional truth interval. The point is not replaced by a CML
estimate, and no estimated JML bias correction or covariance is fabricated.
This is explicitly `InferenceMethod=exact_conditional`, not
`JMLWaldQualified=TRUE` or `JMLBootstrapQualified=TRUE`. Confidence sets are for
the structural parameter; a separate estimation method can supply a displayed
point. The mathematical connection does not promote a general conditional
reference into a covariance or normal interval for JML.

For one-family GPCM, the retained nonowner Rater construction instead bounds
`d_c=a_c*psi` within each Criterion owner. Exact component intervals at error
alpha/3 and Bonferroni give simultaneous coverage of those three products.
Projecting their box over every positive slope vector with product one gives
pointwise coverage at least 1-alpha for psi. This allows the original ordinary,
order-2 or order-4 point to remain visible, even if a point fails numerical
qualification. It uses no plug-in slope estimates. The conditioned law removes
Criterion locations; it supplies **no Criterion-location restriction**.
Absence of that information in this conditional experiment must not be called
proof of nonidentification in every full GPCM model.

These statements require the specified response model, fixed/exogenous
assignment, unit weights, centered Criterion-owned steps, no interactions and
conditionally independent rating events. They do not validate arbitrary
informative missingness, dependence, alternative slope ownership/normalization
or a public all-coordinate interval API. Each 95% interval is pointwise;
two separately reported 95% intervals are not a simultaneous 95% family.
The conditioning principle is established in the literature; the particular
pairing/projection maps above are derived for this design. See
[Skrondal and Rabe-Hesketh (2022), especially Section 8.2](https://link.springer.com/article/10.1007/s11336-021-09816-8).

### C. Completed application to the same 50 N30 datasets

The existing exact algorithms were applied to **all** frozen N30 response
sets. Ordinary and corrected point records, failed points, model labels and
truths retain their original identities. Truth is used for evaluation only,
never to set conditional endpoints. No original dataset was replaced and no
new fit or simulated response was needed.

| Conditional interval procedure | Finite intervals / 50 | Truth in returned set / 50 | Finite and truth-containing / 50 | Mean finite width |
| --- | ---: | ---: | ---: | ---: |
| PCM, Rater 1-minus-2 | 50 | 48 | 48 | 1.1683 |
| PCM, Criterion 1-minus-2 | 50 | 48 | 48 | 1.2937 |
| GPCM, Rater 1-minus-2, all positive normalized slopes | 48 | 49 | 47 | 2.7050 |

Both PCM intervals contain the unchanged public JML point in all 50 samples.
Its earlier research Wald widths were 1.1829 (Rater) and 1.1223 (Criterion),
with 47/50 and 46/50 truth inclusion. These matched descriptive differences do
not make R50 a proof of coverage or identify a universal best method. The
conditional theorem, rather than the observed 48/50, supplies the guarantee.

For GPCM, the two unbounded sets remain visible and make the **unconditional
mean width infinite**. The 49/50 truth inclusion cannot be reported as 49/50
finite useful intervals: that count is 47/50. The same conditional confidence
procedure applies to the three GPCM estimation arms and therefore produces
identical interval sets, not three independent validations. It accompanies
50 ordinary points and 49 points in each corrected arm. A confidence set
obtained from the model and responses does not require fabricating a point
when the corrected estimator fails. Its larger width is the cost of retaining
uncertainty over all admitted positive slopes.

`jml-conditional-truth-qualification-20261003.py` independently checked all
250 scalar conditioning distributions: 100 PCM plus 150 GPCM owner-specific
ones. At seven rational natural-parameter values per distribution it enumerated
every statistic outcome, giving 1,750 exact rejection-probability checks; all
passed their declared size. It independently checked the observed endpoints'
rational tail brackets, their logarithmic outward rounding with 100-digit
Decimal arithmetic, and all 50 GPCM projections by rational product
inequalities. The finite grid is an implementation check, not the proof of
uniform coverage. Input/source identities and all point/interval denominators
are recorded under `summary-n30/conditional-reference/`.

### D. Qualification status and remaining work are now explicit

| Requested claim | Decision after this increment |
| --- | --- |
| General ordinary-JML structural-truth Wald intervals, repaired solely through covariance/numerical accuracy | Rejected. The exact N480 counterexample proves that claim false. More replications or a better root solver cannot establish it. |
| A general fixed-exposure repair using the extended-profile, fitted-fixed-ability basic bootstrap | Rejected. In the same exact two-item submodel its ideal interval converges to {0} while truth is log(4); increasing the inner replication count does not repair it. This does not reject the separately scoped exposure-growth theorem. |
| Pointwise finite-sample conditional truth intervals alongside the retained PCM JML point, for the two stated contrasts/design | Mathematical coverage and retained-data implementation checks complete. This is the separately named conditional procedure; not a public API or JML covariance. |
| Conditional all-positive-slope GPCM Rater projection alongside ordinary/order-2/order-4 points | Mathematical coverage and retained-data implementation checks complete for the stated target/design. Unbounded outcomes and wider intervals are required, not errors to discard. |
| GPCM Criterion locations, general corrected-JML Wald intervals, or the complete plug-in bootstrap procedure | Not qualified by these results. Their requested estimator/target/domain must be preserved; a conditional Rater result cannot close these tasks. |
| Public integration and arbitrary facet/model/design support | Not completed by research reference scripts. Keep an explicit conditional method, support guards, precision/assumption metadata, help and actual consumer checks if this route is adopted. |

Thus the scientifically defensible result is a closed negative decision for
one general claim and a closed positive decision for the specified conditional
procedures. It is **not** a claim that all requested JML confidence intervals
are now valid. The existing root, covariance, missingness/dependence and wider
model/exposure roadmap remains intact. The unqualified GPCM owner target or
bootstrap cannot be made qualified by renaming a conditional reference.

## October 3 — GPCM owner-location decision for the actual three-by-three design

**Question.** Could a more informative conditioning of each Person's responses
finish the missing Criterion interval, and was the earlier nonidentification
result merely an artifact of its two-by-two binary example or separate
roster-specific populations?

**Answer.** For a family of positive, normalized slopes arbitrarily close to
one, exact elimination of the free Person abilities removes the Criterion
locations in this actual three-by-three, four-category design too. More
strongly, different Criterion contrasts can have the same full response law
under **one common ability population**, hence under all three observed paired
rosters. This remains possible when the common populations have the same mean
and variance and one is N(0,1). The alternative population need not be normal.
Thus neither a new conditional statistic nor merely increasing N can qualify
a uniformly shrinking owner-location interval over that unrestricted model.
This does **not** reject informative nonshrinking sets or inference within a
specified normal family, and it does not establish nonidentification at the
exactly unit-slope generating point of the 50 retained datasets.

This closes a design-specific mathematical question, not all GPCM inference.
The following is a derivation for this model, rather than a theorem attributed
to the general conditional-likelihood literature. The distinction between JML,
conditional inference and distribution-based MML is consistent with
[Skrondal and Rabe-Hesketh, Sections 6–8](https://link.springer.com/article/10.1007/s11336-021-09816-8).

### A. Why the obstruction persists arbitrarily near equal slopes

Keep finite centered Rater and Criterion severities, finite centered
Criterion-owned step deviations, unit weights, independent conditional ratings,
and positive Criterion slopes whose product is one. In a complete nine-cell
panel let S_c be the total of the three Rater scores for Criterion c. Then
S_c is in {0,...,9}, and the complete response law factors as

    p_beta,theta(y) = h_beta(y) exp{theta * t(S)} / D_beta(theta),
    t(S) = a_1 S_1 + a_2 S_2 + a_3 S_3.

For any integer q > 9 take

    a = (1, (q+1)/q, q/(q+1)).

The product is one and max_c |a_c-1| = 1/q. If two owner-total vectors have
the same weighted total, their difference d satisfies

    q(q+1)d_1 + (q+1)^2 d_2 + q^2 d_3 = 0,  |d_c| <= 9.

Reduction modulo q forces d_2=0. Dividing by q and reducing modulo q next
forces d_1=0, and therefore d_3=0. All **1,000** complete-panel owner-total
vectors have different weighted totals. The same proof applies to the
observed two-Rater panels, where S_c is in {0,...,6}: their **343** vectors
have different totals too. This is exact integer arithmetic, not a numerical
rank judgment at an ill-conditioned matrix.

For any positive-probability pair of response patterns y,z in a deterministic
conditional stratum, their conditional probability ratio equals their
unconditional ratio and contains `exp{theta[t(S_y)-t(S_z)]}`. Independence of
the unknown theta requires equal weighted totals, and hence equal S at these
slopes. But the location factor `exp{-sum_c a_c b_c S_c}` is constant within
such a stratum. It cancels. This also rules out rescuing the location through
a deterministic joint partition of several Persons while eliminating **each**
free ability: independence of all theta_i forces the equality separately for
each Person. This statement concerns exact conditional laws; it does not
assert that every possible inference method is a conditional partition.

At **exactly** a=(1,1,1) the scalar total has only 28 values in the complete
panel, or 19 in the observed panel. For example S=(1,0,0) and (0,1,0) have
the same scalar total but different Criterion-contrast features. The PCM
conditional argument therefore remains available. Closeness of estimated
slopes to one is not a license to impose equality in a free-slope interval.

### B. One common population, all observed rosters

Let `H_beta(s)=sum_{y:S(y)=s} h_beta(y)>0`, and write the complete-panel
owner-total probabilities as

    Q_beta,s(theta) = H_beta(s) exp{t_s theta} / D_beta(theta).

The 1,000 functions Q_beta,s are linearly independent. Multiplying a proposed
zero linear combination by the positive denominator reduces it to a linear
combination of exponentials with distinct real exponents. Such a combination
can have at most m-1 real zeros unless it is identically zero, by induction
using Rolle's theorem after removing the smallest exponent. In particular,
evaluation at m distinct finite abilities gives an invertible matrix. No
floating-point inversion of a 1,000-by-1,000 matrix is needed for this claim.

Take a baseline common population F0=N(0,1), and shift the centered Criterion
locations by `(d/2,-d/2,0)`, keeping slopes, Raters and steps fixed. The target
Criterion 1-minus-2 contrast changes by d; `p_beta(y | S=s)` does not change.
The earlier smooth-density construction applies to the **complete panel**:
choose bounded smooth bump functions psi_j of compact support for which

    A_beta[s,j] = integral Q_beta,s(theta) psi_j(theta) dF0(theta)

is invertible near the baseline. Such bumps exist by the functional
independence just proved and continuity of integrals of sufficiently narrow
bumps about suitable distinct points. Put

    r_beta = p_S,0 - integral Q_beta(theta) dF0(theta),
    c_beta = A_beta^(-1) r_beta,
    dF_beta = [1 + sum_j c_beta,j psi_j] dF0.

For sufficiently small |d|, c_beta tends to zero and the multiplier is strictly
positive. Summing the Q rows gives normalization. The S distribution and the
within-S distribution are unchanged, so **every one of the 4^9=262,144
complete response-pattern probabilities is equal** under the two parameter
and population pairs.

Each observed six-rating roster is a marginal of this same complete law.
Summing over the omitted Rater therefore preserves equality for rosters
{1,2}, {1,3} and {2,3} simultaneously. One common F_beta suffices; no
roster-specific selection of ability populations is used. Consequently the
joint data law is equal for independent Persons with these fixed rosters, for
N30 with ten Persons per roster and for any other fixed roster counts. The
argument also permits exogenous random assignment with the same assignment
law. It does not establish anything for arbitrary outcome-dependent missingness.

**Even the first two population moments can be held fixed.** Augment the
functions Q_beta,s by theta and theta^2, using 1,002 bump functions and adding
two zero entries to r_beta. The augmented functions are linearly independent:
any combination of the Q functions is bounded on the real line, so it cannot
cancel a nonzero linear or quadratic polynomial; the remaining exponential
combination is zero only with all coefficients zero. They are real analytic,
so this independence also holds on an open bounded interval, allowing compact
bumps. The augmented system preserves integral(theta)dF=0 and
integral(theta^2)dF=1, while the Q rows still enforce normalization.
Thus the alternative has a smooth positive density, exactly normal tails
outside a compact set, mean zero and variance one. **These properties do not
make the alternative an exactly normal distribution.** Requiring the whole
distribution to be N(0,1), or to lie in a specified normal family, removes
these particular alternatives and changes the inferential assumptions.

This is a local existence proof. It supplies no practically sized lower bound
on |d|, and no numerical mixing distribution has been solved or represented
as checked. Near unit slopes the required matrices can be extremely ill
conditioned. That affects the size of the neighborhood and the practicality
of a numerical construction, not the exact independence or existence argument.

### C. Implication for the requested interval and what was checked

Let two such equivalent truths differ by d != 0. An interval with coverage at
least .95 at both must, under their common data law, contain both with
probability at least .90. Thus

    P(interval width >= |d|) >= .90

for every N. A confidence interval uniformly valid over the unrestricted
ability class cannot also shrink to a point at every one of these parameter
settings when each Person's exposure is fixed. This applies to any order of
JML correction and to any covariance or bootstrap formula claiming that
generality; it does not say that all finite-width intervals are impossible.
An interval uniformly valid conditional on every fixed ability vector would
also be valid after integrating over each of these populations, so treating
abilities as fixed alone does not evade the restriction.

The [exact design audit](jml-n30-owner-identification-20261003.py) reads all
50 saved inputs. All have N30, 180 rows, scores 0:3 and ten Persons on each
of the three Rater-pair rosters. For q=10,100,10000 it verifies the product-one
slopes, the 343/1,000 distinct weighted totals, the 4^6/4^9 pattern-count
identities, and the equal-slope positive control. The six-rating pattern counts
are also independently enumerated. Maximum slope differences from one are
.1, .01 and .0001; no arbitrary rank tolerance is used. The output is
`summary-n30/conditional-reference/owner-identification.json`, with all input
and script SHA256 identities. This verifies the design arithmetic; the common
population result is the analytic proof above, not a fitted numerical witness.
New response datasets, model fits and numerical derivatives: **zero**.

The resulting work decision is:

* Close the proposed distribution-free **exact-conditioning rescue for the
  GPCM owner location** as unavailable in this free-slope domain. Do not
  spend more repetitions on trying to obtain that missing interval from the
  Rater projection, or substitute fitted slopes as if known.
* Keep the conditional PCM and GPCM Rater results qualified only in their
  established scopes. The negative result does not change their coverage.
* For fixed six-rating GPCM owner inference, a further candidate must either
  retain population/identification ambiguity in its confidence set, or state
  an identifying population or measurement restriction and calibrate under it.
  A nonshrinking, nuisance-projected set remains mathematically possible;
  certified projection and useful width have not been established.
* For the existing N(0,1) comparison, normal-population calibration is a
  legitimate **separate** target. Preserving a JML point does not preclude
  calibrating its sampling distribution under that declared population, but
  this would be model-based JML inference, not distribution-free JML or the
  previously rejected fitted-fixed-ability bootstrap. Other structural
  nuisance parameters, failures and solver selection must remain in the
  calibration. A plug-in population alone does not give finite-sample coverage.
* Retain the growing-exposure route and all original sample-size/model/design
  conditions. Increasing N with six fixed ratings and increasing informative
  exposure are different regimes. No MML or corrected-JML qualification is
  supplied by this negative result.

In particular, the exactly unit-slope, exactly normal R50 generating condition
does not validate the unrestricted GPCM claim, nor does this construction
explain the large errors of its three numerically rejected GPCM fits. Those
are separate empirical and computational findings. Formal general Criterion
CI delivery remains unavailable; the reason is now established for the actual
design rather than inferred solely from a smaller example.

## October 3 — Normal-population Monte Carlo calibration and the projection gate

**Decision.** A candidate can preserve the public ordinary/order-2/order-4 JML
point and calibrate its complete numerical algorithm under an explicitly
declared normal population. It need not pretend that the point is unbiased,
that its covariance centers on structural truth, or that a local optimizer
is an exact global JML solution. The candidate developed here uses a
finite-sample corrected importance-sampling test, with **absolute likelihood
ratios**, and retains known estimator failures through a defined statistic.
The statistical construction and bounded likelihood evaluation are in place.
Full nuisance maximization and finite useful Criterion interval endpoints are
not yet implemented; no public CI or independent coverage claim is made.

The first self-normalized candidate is **rejected as the default for this
unrestricted nuisance projection**: exact certificates show that 45/50 retained
samples would have the whole real line as their Criterion set. This is a
limitation of that finite-bank procedure, not the preceding unknown-population
identification theorem and not a claim that the normal model is unidentified.
Checking this before launching nested refits avoids spending simulations on a
procedure already known to be uninformative in most of the retained samples.

### A. Test the generating candidate, while retaining the original JML point

Let beta=(psi,eta) specify the structural parameters, with psi the Criterion
1-minus-2 contrast. In the present GPCM model there are twelve free structural
coordinates: two Rater, two Criterion, six centered-step and two log-slope
coordinates. Fixing psi leaves eleven nuisance coordinates. The current
candidate assumes iid N(0,1) abilities, independent conditional ratings and
the declared exogenous assignment law. Estimating a normal mean/variance would
add population nuisance parameters; using those fitted values as known does
not inherit a finite-sample guarantee.

For a completed frozen algorithm A, define

    T_psi(y) = |A(y)_CriterionContrast - psi|, if that point is finite;
               0, if the algorithm completed with no finite point.

No point is imputed in the second case. Its output stays unavailable. When the
observed algorithm fails, set the test p-value to one and return the whole
parameter domain if an interval is requested. All reference failures remain
in the B draws. Unfinished/interrupted calculations are not completed failures:
their statistics remain unknown and can only give conservative rank bounds.

The choice zero is justified independently of these results. It makes a
failure the least extreme statistic and automatically gives p=1 in the
normalized rank test. It also permits the conservative p=1 override for the
absolute-weight test below. Mapping reference failures to +Inf while overriding
observed failures to p=1 is valid but weakly less powerful: for finite positive
observed T it adds failed-reference weight to the upper tail unnecessarily.
Deleting failures or redrawing only successful fits is a different sampling
law and is not allowed. A covariance/root screen required for a Wald interval
is not automatically a prerequisite for using an algorithm's finite output as
a Monte Carlo statistic. Its numerical-quality flag remains separate.

Under a fully specified candidate beta, direct independent simulations give
the inclusive rank p-value `(1 + number(T_b >= T_observed))/(B+1)`. Ties are
retained. Exchangeability gives a level at most alpha, including finite B;
neither zero estimator bias nor growing exposure is required. For a contrast,
use the supremum of this p-value over **all** eta admitted by that null.
This is the Monte Carlo nuisance-parameter principle of
[Dufour (2006), Section 4](https://jeanmariedufour.research.mcgill.ca/Dufour_2006_JE_MCT.pdf).
A maximum found at a finite grid or local optimizer is a **lower** bound on
that supremum. It can witness retention, but cannot certify rejection.
Untested nuisance regions must be bounded from above before excluding psi.

### B. Reuse a simulation bank without pretending the proposal is truth

Let Q be a specified proposal response distribution with positive mass on the
model's finite response support, independent of the observed sample X. The
bank Y_1,...,Y_B is iid Q. Its JML outputs can be stored once. At candidate
beta evaluate `w_beta(y)=P_beta(y)/Q(y)` and the unchanged algorithm statistic.
[Harrison (2012), equation (2)](https://pmc.ncbi.nlm.nih.gov/articles/PMC3412608/)
gives two corrected tests, both including the observed sample's own weight:

    p_absolute = min(1, [w(X) + sum_b w(Y_b) 1(T_b >= T_X)]/(B+1)),
    p_normalized = [w(X) + sum_b w(Y_b) 1(T_b >= T_X)]/
                   [w(X) + sum_b w(Y_b)].

For example, under iid Q samples indexed 0,...,B, arrange their statistics
from largest to smallest, keeping ties. The total weight of indices whose
inclusive upper-tail weight is <= alpha*(B+1) is at most alpha*(B+1).
Multiplying by w at the distinguished observed index, symmetrizing over
indices and taking expectations proves `Pr_P,Q(p_absolute<=alpha)<=alpha`.
The analogous threshold alpha*sum(w) proves the normalized version. Raising
p to one on observed failure preserves the bound. This proof also shows why
ordinary self-normalized importance estimates that omit w(X) are insufficient.

For exact weights, `C(X,Y)={psi: sup_eta p_absolute(psi,eta)>alpha}` has
pointwise coverage at least 1-alpha; its interval hull is conservative. No
union correction over the continuum of candidates is required: coverage uses
the single true beta. The two references above support the generic methods;
this combination, the JML failure rule and its numerical scope are our
specified application. This is model-based inference for the numerical JML
algorithm, not validation of the fitted-fixed-ability basic bootstrap.

The current bank reuses each of the 50 independent saved samples in turn as
X, with the other 49 as references. Q is the **prespecified generating-design
distribution**, not a fitted proposal chosen from X. Its frozen generator
uses exogenous randomized balanced Rater-pair assignment. Conditional inference
for an arbitrary fixed roster would need a matching bank or a justified
permutation-invariance reduction. These 50 overlapping analyses are development
calculations, not 50 independent outer experiments or 2,450 newly drawn samples.
In particular, 48/50 retention when Q=P follows from the rank construction;
it is not empirical proof of 95% interval coverage.

### C. Bounded normal integrals, rather than unqualified quadrature differences

The probability of one six-rating response vector is the normal integral of
its conditional GPCM mass. The evaluation omits the common sqrt(2*pi) factor,
which cancels between candidate and proposal for the same N. Put

    f(z) = exp(-z^2/2) * product_j P_beta(Y_j=y_j | z),
    R = 1/(3*max_c a_c),   C = 2*(8/7)^6.

For the product-one positive slopes, R<=1/3. In the complex strip |Im z|<=R,
the phases in each four-category denominator lie within a width of one radian.
Rotating to its midpoint bounds its absolute value below by
`cos(1/2)*sum(real positive masses) >= (7/8)*sum(masses)`.
Every conditional mass has modulus <=8/7 and the normal kernel has modulus
<=exp(R^2/2)<2. Thus f is analytic there, bounded by C, and Cauchy's inequality
gives `|f^(2n)(x)| <= (2n)! C/R^(2n)` for real x.

On [-M,M], composite n-point Gauss-Legendre with segment width h<=R then has
absolute error at most

    2 M C / [(2n+1) choose(2n,n)^2].

This follows by substituting the derivative bound into the ordinary
Gauss-Legendre remainder and summing the segment lengths. The two omitted
normal-kernel tails have total mass at most `2 exp(-M^2/2)/M`, because response
probabilities are at most one. Here n=20, M=12: 72 segments for unit slopes and
80 for (1,1.1,1/1.1). Legendre nodes are enclosed by disjoint rational brackets
with exact polynomial sign changes; their weights, logits, integrals and
likelihood ratios use 45-decimal interval arithmetic. The analytic remainder
and tail bound are added outward. This supplies enclosures for the stated
ideal normal-response probabilities, not just a tolerance between two grids.

Across 1,172 distinct observed Person/roster patterns at four parameter
settings, the maximum Person-integral relative enclosure width is 4.88e-17.
Independent adjacent-odds Gauss-Hermite calculations at orders 121/241 agree
with all 800 normalized test values within 4.39e-15 and give identical decisions.
Their maximum log-likelihood difference is 4.98e-11. Three least-probable
patterns, one per roster, also pass independent 80-digit adaptive integration
inside the enclosures. Floating comparison values can differ from displayed
outward endpoints by <8e-16; those comparisons are checks, not the enclosures.
The existing R pseudo-random generator is a numerical approximation to the
ideal normal law; no uniform generator-discrepancy certificate is claimed by
this likelihood calculation.

### D. Why self-normalized nuisance projection is uninformative here

For sample j, form its six-vector n_j of category-1 and category-2 counts for
each Criterion. Each Criterion has 60 ratings. With unit slopes, perturb its
cumulative steps at categories 1/2 by t*(gamma_c1,gamma_c2), leaving cumulative
steps at 0/3 zero. In step coordinates the change is
`t*(gamma_c1, gamma_c2-gamma_c1, -gamma_c2)`, so centering is preserved. Keep
any finite target contrast psi and all other locations fixed. As t tends to
infinity, dominated convergence in the normal integrals gives

    log P_t(sample j) = -t*[gamma'n_j +
                    60*sum_c max(0,-gamma_c1,-gamma_c2)] + O(1).

The denominator's leading category terms have positive finite normal integrals;
normal exponential moments bound them uniformly in t. Therefore, if
`gamma'(n_j-n_i)>0` for every j != i, the observed sample i's normalized
importance weight tends to one. Since its own weight is always in the corrected
tail numerator, `sup_eta p_normalized(psi,eta)=1` for **every finite psi**.
The exact projected set is the whole real line, independently of how good its
JML point is. Normality and measurement identification do not prevent this
finite-bank projection problem.

Linear programming found directions and rational dot products verified
strictly positive margins for **45 of the 50 samples**. The five with no such
certificate are replicates 17,25,36,41,46; they are not certified to have finite
intervals. The directions and counts are saved, so this conclusion does not
depend on the linear solver's floating success flag. It applies to the
ordinary and corrected statistics alike.

The **absolute-weight correction** avoids this specific escape. Along all 45
certified directions, every sample's absolute decay rate above is positive
(minimum across these rational checks: 7/2). Thus all P_t/Q weights tend to
zero and p_absolute tends to zero when the observed algorithm returned a
finite point. Known observed failures still retain p=1 by the declared rule.
This closes this particular source of whole-line sets; it does not yet bound
every joint escape of locations, steps and slopes.

### E. Retained-data result and next computational obligation

Four candidate points were evaluated: psi=-.5 (Q itself), psi=-1 and psi=0
with unit slopes, and psi=0 with slopes (1,1.1,1/1.1). Other locations/steps
are held at the declared proposal values solely for these **nuisance witnesses**.
The table counts samples where that point witnesses retention under the
absolute-weight correction with the failure-zero rule:

| Candidate | Ordinary GPCM JML | Order 2 | Order 4 |
| --- | ---: | ---: | ---: |
| psi=-.5, unit slopes | 48/50 | 48/50 | 48/50 |
| psi=-1, unit slopes | 45/50 | 38/50 | 38/50 |
| psi=0, unit slopes | 38/50 | 14/50 | 18/50 |
| psi=0, unequal slopes above | 29/50 | 13/50 | 13/50 |

Rejecting a point in this table does **not** reject its composite contrast null.
For example, a retained unit-slope nuisance point is sufficient to keep psi=0
even if the unequal-slope point is rejected. The corrected-order differences
do not establish a preferred order. All observed failure cases remain retained
and their points remain missing. No decision was unresolved because of the
computed weight enclosure. The proposal-weight ESS diagnostic falls from 50
at Q to about 9.18 at psi=-1 and 4.43/3.22 at the two zero-contrast points;
these values warn about power, not invalidity, and are not used to delete cases.

The known-failure-zero rule was checked on 4,096 exact weighted-rank
configurations; the absolute correction on another 1,296. The initial direct
rank check covers 1,024 tied/failure vectors and all 16 completions of a small
unknown-rank example. An intentionally uncorrected importance example has
type-I error 4/9 at nominal .05, while its corrected rule satisfies its bounds.
The weight scale for the absolute correction was recovered using only one
sample's enclosed likelihood per candidate plus already enclosed rank
differences, avoiding a repeat of all 1,172 pattern integrals.

The sources are `jml-normal-mc-rank-20261003.py`,
`jml-normal-importance-mc-20261003.py`, `jml-normal-importance-check-20261003.py`,
`jml-normal-failure-rule-20261003.py`, and
`jml-normal-mc-projection-gate-20261003.py`. Results and source/input identities
are under `summary-n30/normal-mc-calibration/`. New fits and new simulated
datasets: **zero**. The 400 original jobs and their numerical source epoch are
unchanged.

The next required work is a **conservative nuisance supremum and contrast
projection for p_absolute**, with joint parameter tails bounded, rather than
more inner JML refits or a local grid advertised as an interval. Unknown
regions retain their candidates. Once useful widths and whole-line outcomes
are established, freeze the complete procedure and evaluate independent outer
coverage across the retained small/mid/large-N and design roadmap. The current
50-sample reuse remains development evidence. No public API, JML covariance,
general Criterion CI qualification or independent confirmation is complete.

## October 4 — Uniform joint parameter tails for the normal MC projection

**Result and decision.** The unbounded structural-parameter region can now be
excluded conservatively for the retained bank under the declared N(0,1) model.
This includes simultaneous changes in slopes, Rater and Criterion locations,
and centered steps. It does not require fixing nuisance values at their fitted
estimates, dropping extreme Persons, or assuming that all cells contain every
category. The original absolute-weight confidence sets are bounded for the
50 ordinary GPCM points and the 49 finite points in each corrected arm.
Completed observed failures still have p=1 and whole-line sets.

The resulting common outer radius is approximately **5.00676e37**. This is a
valid but deliberately loose mathematical search bound, not useful interval
precision. No interior nuisance supremum or useful endpoint has been certified.
Boundedness also does not imply nonemptiness. The existing four candidate
points witness nonempty sets in 48/50 ordinary cases and 47/49 finite-point
cases in each corrected arm. Nonemptiness remains unresolved in ordinary
replicates 6/24 and corrected replicates 2/6. A future implementation must
report an empty projected set as such, rather than silently returning a point
or substituting a different estimator.

The generic test validity remains the Harrison/Dufour construction documented
above. The model-specific tail inequalities below are derived here; neither
reference is being cited as having proved these GPCM bounds. Their purpose is
to replace an arbitrary numerical search cutoff by a justified one. Small
useful widths and independent coverage remain separate requirements.

### A. Opposite rating orientations bound arbitrarily large slopes

For one Criterion, write its four-category probabilities as

    p_k(x) = exp(k*x - s_k) / sum_l exp(l*x - s_l),
    k = 0,...,K,  K=3,  s_0=s_K=0,
    x = a*(theta - b_C - b_R),  s_k = a*S_k.

Here S_k is the cumulative centered step, so S_0=S_3=0. Let two Raters have
natural location difference d=a*(b_R2-b_R1). Their natural ability coordinates
are x and x-d for Raters 1 and 2. Reversing that
orientation changes signs, not the bounds below. Conditional independence is
essential in this argument.

First, the probability ratio for a specified pair (u,v) and its swap (v,u) is
exp(d*(u-v)), with scores ordered by Rater 1 then Rater 2.
The ratio is constant in theta, and therefore survives normal integration.
For whichever ordering is less likely, a discordant pair probability is at
most exp(-|d|). In a roster with n_+ positive and n_- negative observed score
differences, put n=n_++n_- and m=min(n_+,n_-). Independence across Persons gives

    L_roster <= exp(-m*|d|).

All other ratings and concordant Persons can be bounded by one. Thus this is
an upper bound on the full roster likelihood, not a fitted orientation model.

Second, let mu(x)=E_x(Y). Direct differentiation gives mu'(x)=Var_x(Y), and
mu(-infinity)=0, mu(+infinity)=K. For two independent draws at x,
E|Y-Y'| <= E(Y-Y')^2 = 2 Var_x(Y), since differences are integers. The family
is stochastically ordered in x. Couple a draw at x and one at x-d monotonically,
and use the triangle inequality with an independent draw at x. Integration
over the natural coordinate then gives

    integral Pr{Y(x) != Y'(x-d)} dx
      <= integral E|Y(x)-Y'(x-d)| dx
      <= 2K + K*|d|.

The first term integrates 2 Var; the second integrates the mean shift, whose
integral is K*|d| by nonnegativity and Fubini. These bounds hold for all finite
cumulative steps, including unordered ones; the constants do not depend on
those steps. Changing variables from theta to x and using sup phi(theta)<2/5
therefore yields

    Pr(discordance) <= (6/5)*(2+|d|)/a,
    L_roster <= [(6/5)*(2+|d|)/a]^n.

When m>0 and a>=4, split at |d|=(n/m)*log(a). Above this threshold, the first
bound is at most a^(-n); below it, the second applies. Consequently

    L_roster <= min(1, [(6/5)*(2+(n/m)*log(a))/a]^n).

The right-hand expression decreases for a>=4. Roster groups use disjoint
Persons, so their bounds multiply. An owner with at least one roster containing
both orientations has a likelihood bound tending to zero as its slope tends
to infinity, **uniformly over all other structural parameters**. A roster
without both orientations contributes only the bound one. If no roster has
both, this certificate is unavailable; the implementation explicitly refuses
to manufacture a finite bound in that case.

All 50 datasets satisfy this condition separately for all three Criteria:
150 checked dataset/owner certificates. To keep comparisons exact, slope
cutoffs are powers 2^k and log(2)<7/10 supplies a rational upper envelope.
The selected cutoffs range from 2^19 to 2^89. These very large values reflect
the looseness of the likelihood envelope; they are not slope estimates or
evidence that equally large slopes fit the data well.

### B. From a likelihood level to bounded locations and steps

Consider one sample's response likelihood conditional on its observed roster,
L(beta), and any epsilon>0. If L(beta)>=epsilon, every Person marginal
probability is at least epsilon, since each factor is at most one. Choose H
with Pr(|theta|>H)<epsilon/2. Some theta in [-H,H] for each Person must then
give its complete conditional response mass at least epsilon/2. Each of its
observed category probabilities is also at least epsilon/2. With
C>=log(2/epsilon), all observed-category logit comparisons consequently obey

    logit_k(theta)-logit_observed(theta) <= C.

No ability is estimated, imputed, truncated in the generating model, or
excluded here. H is solely a device for bounding the likelihood superlevel
set, using the entire normal tail probability.

Let A_c bound each positive slope from above as in A. The product-one slope
constraint implies a_c >= 1/(A_d*A_e) for the other two Criteria d/e. Write
F_c=A_d*A_e. A cell (r,c) containing both category 0 and category 3 has

    |b_Rr+b_Cc| <= D_c,   D_c = H + C*F_c/3.

This follows by comparing logits 0 and 3 in the two observed Persons; centered
steps make their cumulative-step difference zero. Their theta values need not
be equal. Among the 450 dataset/cell pairs, 13 lack one endpoint category.
Those cells are retained. Every dataset still has (i) a Criterion whose three
Rater cells contain both endpoints, (ii) an endpoint cell for each Criterion,
and (iii) a Rater with endpoint cells for both target Criteria 1/2.

Since sum_r b_Rr=0, an all-Rater endpoint Criterion gives

    |b_Rr| <= R = (4/3)*min_{complete endpoint Criteria c} D_c,
    |b_Cc| <= D_c+R,
    |b_C1-b_C2| <= D_1+D_2.

For the first inequality, average the two differences b_Rr-b_Rs, each bounded
by 2D_c; for the second use an available endpoint cell. The third uses the
common Rater, whose location cancels. This is a direct graph argument, not
an assumption of complete-category cells or a numerical linear-program result.

Every Criterion also has observed categories 1 and 2. Comparing an observed
interior category to 0 bounds S_k above; comparing an observed 0 in an endpoint
cell to category k bounds S_k below. The preceding location bounds give the
conservative symmetric bound

    |S_ck| <= C*F_c + k*(H+D_c+2R),   k=1,2.

The original steps are S_1, S_2-S_1, -S_2, so they too are bounded. Together
these inequalities enclose the entire superlevel set L(beta)>=epsilon in a
finite box. They cover joint escapes; bounding slopes while silently fixing
locations or steps is not part of the proof. Mean/variance or unknown-population
nuisance parameters are not included: the N(0,1) assumption is necessary here.

### C. A valid cutoff for the absolute Monte Carlo supremum

For each of the 50 samples, obtain a certified proposal probability lower
bound q_j^L conditional on its roster. The common assignment law cancels from
P_beta/Q, so conditional response likelihoods suffice. On 128 subintervals of
[-8,8] of width 1/8, the proposal's conditional log response mass is concave
in theta. Its minimum on each interval is therefore at an endpoint. Multiply
that minimum by the normal density minimum and the interval width, then sum.
All operations are enclosed with interval arithmetic; omitted tails add
nonnegative mass. This is a lower-integral construction and does not claim a
quadrature error bound. It reuses the same 1,172 response patterns and does
not refit or regenerate the saved data.

Let 2^(-e_j)<=q_j^L and epsilon_j=2^(-e_j-5). For a beta outside sample j's
certified box, L_j(beta)<epsilon_j, hence w_j(beta)<1/32. Outside the union of
the 50 boxes, **all** weights are below 1/32, including the observed weight.
For a finite observed point, the numerator is bounded by their total, giving

    p_absolute(beta) <= (sum_{j=1}^{50} w_j(beta))/50 < 1/32 < .05.

Thus the original .05 projected set is contained in
[-max_j(D_j1+D_j2), +max_j(D_j1+D_j2)]. No multiplicity penalty is needed for
these deterministic inequalities. For epsilon=2^(-t), the implementation uses
integer H>=2 with 5H^2>=7(t+1), and C=ceiling(7(t+1)/10). The elementary normal
tail bound 2 exp(-H^2/2)/H and log(2)<7/10 verify the required inequalities.
Here H ranges from 21 to 23. These constants are analytical integration bounds,
not imposed bounds on the model's Persons or structural parameters.

Known observed point failures are the explicit exception to this argument:
their p-value is overridden to one, so they keep the whole line even outside
these likelihood boxes. This occurs at replicate 38 for both correction orders.
All failures and raw finite numerical outputs remain in the accounting.

### D. Verification, practical consequence, and remaining work

`jml-normal-mc-tail-bounds-20261004.py` stores exact rational slope-envelope
values, category/graph witnesses, finite parameter bounds, source identities
and input hashes in `normal-mc-calibration/tail-bounds.json`. The lower proposal
integrals were checked independently against 241-node Gauss-Hermite evaluation:
all 1,172 were strictly smaller, with Person-level lower/approximate ratios
.7702–.8758. Whole-sample log lower/approximate ratios were -5.03 to -4.47.
These comparisons check implementation and scale, while the mathematical
minima and interval arithmetic establish the lower bounds. Fifteen independent
improper-integral calculations, including strongly unordered steps and both
signs of the Rater difference, checked the discordance lemma. A missing-
orientation test verifies that an unsupported design does not get a certificate.

This proves boundedness of the exact absolute projection, in contrast to the
self-normalized method's proved whole-line escape. **It does not show that the
exact projection is broad, narrow, empty, or accurate as an approximation to a
direct Monte Carlo inversion.** In particular, the approximately 1e38 outer
width results from deliberately loose likelihood envelopes and small proposal
probabilities, not an estimated precision or a lower bound on information.
It must not be published as a useful JML confidence interval.

The unresolved task is now within a mathematically bounded region: establish
upper bounds for nuisance suprema tight enough to determine useful endpoints,
and distinguish retained, rejected and unresolved candidates. Local optima and
finite grids can still only witness retention. An empty exact set is possible
in principle for this finite-bank procedure and must remain distinguishable
from optimizer failure and an unbounded set. If useful widths cannot be obtained,
the importance-bank procedure needs an explicit redesign rather than more
replications of the same weak rule. Freeze that complete rule before independent
outer validation across the original wider roadmap. New fits and datasets in
this step: zero; public CI qualification remains incomplete.

## October 4 — Interior upper bounds and a quadrature failure in slope searches

**Current status of the requested endpoint and independent-validation work.**
A global location/step likelihood upper bound is now certified at a fixed
slope vector, and a uniform inequality transfers it to a box of slopes. This
is a genuine upper bound, unlike an optimizer's fitted value. However, the
whole two-dimensional normalized-slope region and all reference-likelihood
terms have not been covered. There are still **zero certified CI endpoints
and zero new independent coverage datasets**. The first prototype is explicitly
restricted to the saved three-by-three design; it does not implement the
other facet configurations. The existing 680-condition allocation remains in
place and must not be described as evaluated by this work.

The exploration also exposed a numerical defect that must be resolved before
freezing a procedure: a 241-node fixed Gauss–Hermite grid can strongly
overestimate the likelihood when slope optimization creates narrow transitions.
Eight of 20 exploratory nuisance points differed from independent adaptive
integration by more than .1 log-likelihood units; the largest difference was
39.12283. Ordinary optimizer success is therefore insufficient even as a claim
that the displayed likelihood at its point is accurate. No such value has been
used to declare an endpoint or reject a composite null.

### A. Certifying the full location/step profile at fixed slopes

Fix a positive slope vector and the target contrast psi. The conditional
softmax log likelihood is concave jointly in abilities and the remaining
linear structural coordinates. Adding the normal log density preserves this
property. Integration preserves log concavity by
[Prékopa (1973), Theorem 6](https://rutcor.rutgers.edu/Prekopa/pdf/SCIENT2.pdf).
Thus each sample's continuous normal marginal log likelihood is globally
concave in the nine remaining location/step coordinates. This is a statement
about the **continuous integral**, not every discrete quadrature approximation.
It does not assert concavity in free log slopes, nor concavity of the sum of
likelihood terms in the importance-test numerator.

At a numerical candidate, let z be coordinates transformed by an invertible
matrix B. B is obtained from approximate curvature but its stored doubles are
subsequently treated as exact numbers. Enclose the continuous gradient g and
Hessian H using interval arithmetic. Suppose

    ||g|| <= G,  ||H+I|| <= E < 1,  mu=1-E,
    ||D^3 ell|| <= M globally,  r=4G/mu,  M*r <= mu/2.

The log likelihood has negative curvature at least mu/2 throughout the ball
of radius r. Its outward directional derivative is negative on the sphere,
so a maximum lies inside. Global concavity then makes it a global maximum.
Taylor's inequality gives the upper certificate

    sup_z ell(z) <= ell(candidate)_upper + G^2/mu.

No finite location/step search box, equality of a floating score to zero,
or optimizer success flag is needed for this conclusion.

For completeness, if d_i is the Euclidean diameter of a rating's category
design vectors after transformation, put B_p=sum_i d_i,
V_p=sum_i d_i^2/4 and W_p=sum_i d_i^3 for each Person. Complete conditional
scores have norm at most B_p, Hessian norm at most V_p and third derivative
norm at most W_p. Differentiating the marginal log integral gives the expected
third derivative, three score/Hessian covariance terms and a third score
cumulant. A conservative global bound is therefore

    M = sum_p [W_p + 12*B_p*V_p + 8*B_p^3].

The implemented outward calculation uses the existing analytically bounded
Gauss–Legendre normal integral, now for the integrand, its gradient and its
second derivative. In the same complex strip, a coordinate score is bounded
by (39/7) times the sum of the maximum absolute category coefficients. A
conditional Hessian entry is bounded by (1248/49) times the corresponding sum
of coefficient products. These constants bound the differentiated integrands'
Cauchy remainders and also dominate their real normal-tail bounds. Derivatives
are not inferred by subtracting two approximately integrated likelihoods.

For replicate 1, psi=3 and unit slopes, the certificate gives:

| Quantity | Verified bound or check |
| --- | ---: |
| Global profile log likelihood | approximately -304.15218204194605 |
| Enclosure width, including optimization gap | 6.654e-15 |
| Transformed gradient norm upper | 9.665e-14 |
| Transformed curvature error upper | 1.267e-10 |
| Global third derivative upper | 14875.41 |
| Certified root radius | 3.866e-13 |
| Independent finite-difference Hessian discrepancy | 5.025e-11 |

All admission inequalities were rechecked as exact rational comparisons from
the saved moments. An initial implementation error used an interval product
instead of an interval square for a norm straddling zero; that pilot raised
an exception and produced no certificate. It was corrected before the saved
certificate above. Integrated moments are now retained for subsequent checks.

### B. Uniform transfer to a slope box

At fixed locations, steps and theta, changing an owner slope from a_c to a'_c
raises its category masses to the power r_c=a'_c/a_c and renormalizes them:

    p'_k = p_k^r_c / sum_l p_l^r_c.

For four categories, sum_l p_l^r >=1 when 0<r<=1, and is at least 4^(1-r)
when r>=1. Hence p'_k <= 4^((r-1)_+) p_k^r. In a slope box let
t=min(1,min_c r_c_lower)>0. Since probabilities are at most one, replacing
each r_c by t increases the product upper bound. Jensen's inequality for
u^t then permits normal integration and yields, for a whole dataset,

    ell(a',lambda;psi)
      <= log(4)*sum_c n_c*(r_c_upper-1)_+ + t*ell(a,lambda;psi).

Here n_c counts its observed ratings for owner c. The bound is uniform over
all location/step nuisance values lambda. A certified profile upper bound at
the reference a can therefore be substituted on the right. This step does
not require the slopes to be equal or a claim of joint concavity in slopes;
the product-one subset can be retained within each bounding box.

Combining the replicate-1 certificate with its existing proposal-probability
lower bound shows that, at psi=3, **that sample's** importance weight is at most
7.697e-12 for every slope in [.9,1.1]^3 and every remaining location/step value.
This is one term of a numerator, not the p-value of the entire 50-sample test.
Other bank terms and other slope boxes remain required. The pointwise power
inequality was checked on 2,268 category/probability/exponent combinations;
the proof above, rather than that finite grid, supplies its general validity.

A sharper normalization bound is also available. For r>1 and 0<t<=1,
minimizing the other three category masses at fixed p_y gives

    p'_y / p_y^t <= C(r,t),
    C(r,t) = max_{0<=u<=3} (1+u)^t / [1+3^(1-r)*u^r].

Here u=(1-p_y)/p_y. The unique positive maximizing root solves
`3^(1-r)*[(r-t)*u^r+r*u^(r-1)]=t`. Its left-hand side is strictly increasing;
the root is at most 3. On that interval the objective is nondecreasing in r,
so the box's upper r suffices. For r<=1 and t<=r the constant one suffices.
Replace the previous log(4) penalty by the sum of n_c*log C(r_c_upper,t).
The positive product-one constraint additionally permits at most two of three
ratios to exceed one. With 60 ratings per owner, a common box constant therefore
needs exponent only 120, rather than 180.

The roots were enclosed by rational brackets with interval-verified derivative
signs. A single sample's proposal probability was enclosed directly, replacing
its earlier deliberately coarse power-of-two lower bound. Together, these
changes give the following rigorous upper bounds for replicate 1's weight at
psi=3, uniformly over all location/step values and normalized slopes in the box:

| Slope box | Upper importance weight for this one sample |
| --- | ---: |
| [.9,1.1]^3 | 1.566e-23 |
| [.85,1.15]^3 | 1.666e-16 |
| [.8,1.2]^3 | 1.406e-9 |
| [.75,1.25]^3 | .009585 |

The rational root brackets, probability enclosures, formulas and source/input
identities are retained in `profiles/sharp-transfer.json` and
`profiles/proposal-and-sharp-transfer.json`. These are certificates for one
term over bounded slope regions, not endpoints or a complete numerator bound.

### C. What the exploratory search does and does not establish

`jml-normal-mc-profile-20261004.py` evaluates 20 nuisance problems: replicates
1/12/22/38 and psi=-10,-3,0,3,10. These development cases were selected using
the existing tail-design audit. They do not add independent samples. Slopes
are constrained to [.01,100] solely to find candidate nuisance points;
**this box is not substituted for the model's full slope domain**. An analytic
gradient check had maximum finite-difference discrepancy 4.45e-9. The original
JML points, correction orders, failure handling and 400 jobs remain unchanged.

`jml-normal-profile-quadrature-check-20261004.py` separately integrates at those
points with interval splits at all category-logit crossings. The large-slope
discrepancies described above invalidate treating fixed-grid convergence as
probability accuracy. This check is ordinary adaptive numerical integration,
not an outward probability certificate or an independent coverage experiment.

`jml-normal-profile-adaptive-20261004.py` repairs the exploratory objective by
integrating each Person's likelihood and analytic score around its conditional
normal mode, with its log peak subtracted. This prevents underflow in poor
trial parameters and tracks narrow probability transitions. A first unscaled
adaptive attempt raised an unresolved-integral exception before completing any
profile; it supplied no accepted result. The scaled calculation preserves the
original responses and estimates. Its outputs remain candidate points until
the appropriate outward bound is evaluated.

All 20 scaled adaptive profiles have now completed. Tightening the integration
tolerance changed their displayed log likelihoods by zero at double precision;
a separate unshifted, category-crossing-split integration using an adjacent-odds
recurrence differed by at most 5.685e-14 across the 20 cases. This is independent
numerical verification on the same development data, not independent sampling
validation or a new outward certificate. The score's finite-difference check
differed by at most 9.04e-9. The largest improvement over the old candidates'
independently integrated likelihood was 20.25646 log units. In replicate 1 at
psi=-10, the third slope moved from the exploratory limit 100 to approximately
24.08027. This demonstrates an effect on the nuisance search, rather than just
a different printed objective value. GH961 still differed by as much as 9.7318
at the repaired high-slope candidates: simply increasing the node count again
is not the adopted accuracy criterion. Its underflowed extreme-node weights
give harmless log(0) warnings in this diagnostic only; it is not the adaptive
objective or an admitted probability bound.

The immutable repaired points, provenance and independent comparison are in
`profiles/adaptive-scaled/`. There were 20 original exploratory nuisance
problems, their 20 integration-repaired reoptimizations, and one fixed-slope
profile certificate. These are probability-calibration calculations; the
number of new response datasets and refitted original JML estimators is zero.

The fixed-slope upper-bound calculation is in
`jml-normal-profile-upper-20261004.py`; its saved moments and independent
arithmetic/derivative/transfer checks are in `normal-mc-calibration/profiles/`
and `normal-mc-calibration/profile-upper-checks.json`. Free-log-slope curvature
at a separate checked point has a positive eigenvalue approximately 51.0053,
illustrating why the fixed-slope concavity certificate cannot simply be
relabelled as an all-slope global certificate.

The outstanding dependency is now explicit: cover the admissible slope region
with sufficiently sharp, certified profile/transfer bounds for every required
bank term, combine them using the actual inclusive statistic tails, and invert
with unresolved regions retained. Only then can the full procedure be frozen
and its independent outer validation begin. N20–480, both SD conditions,
facet/level changes, assignment and missingness/dependence conditions remain
in scope. Correct specification and deliberate misspecification must be
reported separately; the N(0,1) guarantee does not become a guarantee under an
unknown or incorrectly fixed population distribution merely by increasing the
number of simulation replications.

## October 4 — General slopes and the complete reference sum within slope regions

**Result and remaining limitation.** The one-sample upper calculation now
extends to unequal, large slopes. A separate, cheaper analytic upper bound
has been certified for **all 50 reference samples at two slope vectors**.
After transfer to surrounding slope regions, these bounds control the complete
absolute-weight MC numerator on continuous contrast rays. Thus the missing
reference terms have been supplied within those regions. The entire positive,
product-one slope domain is still not covered: **there are no final CI
endpoints and no new independent coverage datasets**. In particular, boundaries
from different slope regions cannot be combined into a full-model interval.

### A. Accurate profile bounds at large slopes

`jml-normal-profile-regions-20261004.py` retains the concavity and stationary
point argument above but permits arbitrary positive rational, product-one
slopes. At replicate 1, psi=-10 and a=(1/5,1/5,25), the global location/step
profile is enclosed at approximately -308.6286893655993 with width 3.627e-14.
All nine unbounded location/step coordinates are covered. A scalar adaptive
integrator using adjacent category odds agrees to floating precision; three
transformed directional Hessian comparisons differ by at most 1.107e-7.

The new Gauss mesh does not assume one narrow complex strip everywhere. On a
real segment of width h<=1, each cell must satisfy one of two exact tests:

1. a_c*h<=1/3, so complex phases stay within the previous pole-free strip; or
2. at its midpoint, some leading category k exceeds every other category l
   in logit by at least `2+(3/2)*a_c*abs(k-l)*h`.

In the second case, disks of radius h centered at **every real point of the
segment** have each competing exponential at most exp(-2)<1/6 of the leading
one. The denominator cannot vanish; each category probability has absolute
value at most 2 and the sum of absolute probabilities is at most 3. The normal
kernel has absolute value less than 2. Consequently the six-rating integrand
is bounded by 128, and the earlier score/Hessian constants still dominate.
Cauchy's derivative bound combined with the
[Gauss quadrature remainder](https://dlmf.nist.gov/3.5#v) gives total integration
error at most `24*128 / [41*choose(40,20)^2]`, plus the enclosed normal tail.
This derivation supplies the guarantee; the mesh is not selected by comparing
two floating quadrature orders. Only 99 segments are needed in this example,
instead of 1,800 from a uniform strip at maximum slope 25. This is a count of
integration segments, not a measured total runtime speedup.

The saved mesh's 41 dominance segments were checked independently with exact
rational inequalities. The certificate's gradient, curvature and root-radius
admission inequalities were also replayed from its saved moments. The new
method retains the old unit-slope implementation as an immutable reference.

For fixed slopes the profile is concave in psi as well. If U bounds its value
at psi0 and a feasible likelihood at psi1 has lower bound L>U, the secant
`U+(U-L)*(psi-psi0)/(psi0-psi1)` bounds the whole profile on the ray extending
from psi0 away from psi1. A log-concave-kernel chord integral, independent of
the Gauss remainder, gives L>=-304.140483 at psi1=-9 in the large-slope case.
The previous proposal probability supplies a witness at psi1=-.5 for the
unit-slope, psi0=3 certificate. These certify rays rather than isolated points;
`profiles/general-region-checks.json` records both. They still concern one
sample's contribution, not the complete numerator described next.

### B. An integral-free upper envelope for all reference contributions

Repeatedly integrating a sharp profile for every obviously excluded region
is unnecessary. Write a rating's category logits at fixed slopes as

    eta_ik = a_c*k*theta_p + D_ik' * lambda + h_ik*psi,

where lambda contains the nine unrestricted location/step coordinates. Choose
category probabilities q_ik>=0 with sum_k q_ik=1, satisfying the **exact**
balance constraints

    sum_i [D_i,y_i - sum_k q_ik*D_ik] = 0.

The log-sum-exp/negative-entropy conjugacy in
[Boyd and Vandenberghe, Example 3.25](https://www.stanford.edu/~boyd/cvxbook/bv_cvxbook.pdf)
implies `log sum exp(eta) >= sum q*eta - sum q*log(q)`.
Substituting it into the conditional likelihood cancels lambda exactly. Put

    g_p = sum_(i in p) a_c*(y_i - sum_k k*q_ik),
    H   = sum_i [h_i,y_i - sum_k q_ik*h_ik],
    I   = sum_i,k q_ik*log(q_ik) + (1/2)*sum_p g_p^2.

Integrating the remaining linear theta terms with the **exact** independent
N(0,1) moment generating function yields

    sup_lambda log P_(a,lambda,psi)(sample) <= I + H*psi.

This affine bound holds for every real psi. It involves no quadrature and no
assumption that an optimizer reached its maximum. It is generally looser than
the accurately integrated marginal profile, which remains necessary where
this bound cannot resolve a region. This construction is a derived envelope
for the current normal sampling model, not a claim that the cited book
qualifies JML confidence intervals or the broader missingness/dependence cases.

For a useful q, the code finds a joint normal-mode candidate, rounds positive
category masses to common dyadic rationals, and corrects their nine balance
residuals by an exact rational covariance projection. Positivity, sum-one and
all nine balances are mandatory. Failed feasibility would produce no bound.
Numerical optimizer success alone is not used for admission. The joint-mode
calculation is an auxiliary bound construction: it does not replace or refit
the original JML estimates or generate fitted abilities for a new simulation.

`jml-normal-profile-dual-20261004.py` produced 50 certificates at unit slopes
and reference psi=3, and 50 at (1/5,1/5,25) and reference psi=-10. Its separate
checker reconstructs all probabilities from the rational witnesses using raw
rating equations, rechecks balances, and recomputes the entropy and affine
coefficient at higher interval precision. Independently enclosed joint-mode
likelihoods have primal/dual gaps between zero and 7.574e-14 in all 100 cases.
This small gap concerns the **joint-mode relaxation**, not the gap between
that relaxation and the marginal likelihood. For example, the large-slope
replicate-1 dual upper bound is -234.00284, whereas the accurately integrated
marginal profile is -308.62869.

### C. Continuous exclusions for the full MC sum in explicit regions

For reference a, take the product-one subset of the componentwise region
`a_c*(1-rho) <= a'_c <= a_c*(1+rho)`. With t=1-rho and the previously certified
sharp normalization constant C(1+rho,t), at most two owner ratios exceed one.
Each owner has 60 ratings, so a simultaneous bound on all 50 weights is

    p_abs(psi,a',lambda)
      <= min(1, (1/50)*sum_j C^120 * exp[t*(I_j+H_j*psi)] / Q_lower_j).

The observed self term and every reference term are included. Replacing each
inclusive statistic-tail indicator by one is conservative, so the bound is
valid for all three finite-point GPCM arms in the current development bank.
Completed observed point failures retain the separately specified whole-line
override. No successful-only denominator or bank resampling is introduced.
The previously certified power-of-two proposal lower bounds are reused.

All H_j are negative in the unit-slope construction and positive in the other
construction. Thus the displayed sum is monotone on the respective exterior
ray. Its crossing of .05 was bracketed to width below .001 with outward
arithmetic; the boundary below is chosen on the certified exclusion side.

| Reference slopes | Relative slope region | Excluded contrast ray | Complete-sum upper at boundary |
| --- | --- | ---: | ---: |
| (1,1,1) | [.9,1.1] per coordinate | psi >= 2.9892578125 | .04863809 |
| (1,1,1) | [.8,1.2] per coordinate | psi >= 4.03125 | .04930536 |
| (1,1,1) | [.75,1.25] per coordinate | psi >= 4.650390625 | .04911707 |
| (.2,.2,25) | [.9,1.1] times reference | psi <= -21.8056640625 | .04985210 |
| (.2,.2,25) | [.8,1.2] times reference | psi <= -30.3125 | .04996631 |
| (.2,.2,25) | [.75,1.25] times reference | psi <= -35.30859375 | .04998653 |

The two largest named regions are `[.75,1.25]^3` and
`[.15,.25] x [.15,.25] x [18.75,31.25]`, intersected with product-one slopes.
These are **regional exclusion certificates**, not parameter restrictions
adopted for the package, not full-model CI endpoints, and not exact crossings
of the actual p-value. The bound may fail to exclude points that the full
calculation could exclude. All 100 witnesses and six complete-sum checks are
retained in `profiles/dual-unit/`, `profiles/dual-small-small-large/` and
`profiles/dual-region-checks.json`.

The direct remaining dependency is coverage of the rest of the admissible
slope domain, combining these cheap bounds with accurate marginal profile
bounds where needed. Merely completing more auxiliary fits cannot close that
gap. This turn adds one integrated nuisance-profile certificate and 100
joint-mode auxiliary bounds on the existing 50 development datasets; it adds
no independent samples or original JML refits. The original 400 jobs and
existing broad-condition allocation remain unchanged. Independent sampling
validation still awaits a complete, frozen inversion rule.

## October 4 — Uniform slope tails strengthened by entropy and centered locations

**Result.** All 150 dataset/owner slope bounds are sharper, uniformly in the
other structural parameters. Combining them with the centered-facet geometry
reduces the common Criterion-contrast outer radius from 5.00676e37 to
7,149,605,588.6667. This remains an impractical outer enclosure, not an endpoint
of the projected confidence set. The result closes neither the interior
supremum nor the independent-validation gate. All calculations here reuse
the 50 N30 development datasets and their existing proposal probabilities.

### A. A uniform conditional likelihood bound

For each Criterion owner, enlarge the conditional model to give every Person
an independent owner-specific natural ability, with two free centered Rater
effects and two cumulative step effects. This includes every original
conditional model: absorb the owner's positive slope into its Rater and step
effects and write its Person coordinate as a_c*(theta_p-b_c).

Let q_ik be a probability vector for each rating. Require exact agreement with
the observed owner-specific sufficient statistics: each Person's two-rating
score total, each Rater's aggregate score, and each category count. The
log-sum-exp entropy inequality then cancels every parameter and gives

    log L_conditional(theta,b,steps,a) <= E = sum_i,k q_ik log(q_ik) <= 0.

Summing over all three owners makes this bound uniform in all abilities,
slopes, locations and steps. Pairs with total 0 or 6 contribute at most one
to likelihood and zero to this entropy bound. They are omitted only from the
auxiliary finite optimization; the observed responses, original JML fits and
Monte Carlo statistic remain unchanged.

The numerical auxiliary solution is rounded to dyadic probabilities and
projected onto the sufficient-statistic equations with exact rational
arithmetic. Nonnegative probabilities and exact balance, rather than an
optimizer success code, admit a witness. In six owner problems the proposed
projection is infeasible. An exact fallback exchanges the two observed scores
within a Person with a roster-specific probability: if the sums of positive
and negative score differences are D+ and D-, the respective flip
probabilities are D-/(D++D-) and D+/(D++D-). This preserves each Person's
category multiset and balances the Rater score changes within each roster.
It is a valid, possibly weaker entropy witness, not a deleted dataset or a
replacement original estimate. Zero probability contributes 0 log 0 = 0.

The six fallbacks are (replicate,owner) = (6,2), (24,2), (28,3), (33,2),
(34,2), (35,3). All 150 witnesses pass a separate reconstruction from raw
responses, exact simplex/Person/Rater/category checks, and outward entropy
evaluation. The conjugacy argument is the standard entropy/log-sum-exp
inequality; the owner relaxation and its use below are project-specific
derivations, not a previously established JML interval result.

### B. Powered discordance controls arbitrarily large slopes

For a cumulative-category probability G(x)=Pr(Y>=cut | x),

    (logit G)' = E(Y | Y>=cut) - E(Y | Y<cut) >= 1.

If x* is its unique half-probability crossing, this implies
G(x)<=min(1,exp(x-x*)) and 1-G(x)<=min(1,exp(x*-x)). For an observed pair
y1>y2 and natural Rater difference d, splitting the real line at x* and
x*+d gives, for 0<s<=1,

    integral [p(y1|x) p(y2|x-d)]^s dx
      <= (|d|+2/s) exp[s min(d,0)].

Reverse the sign of d for the opposite score orientation. The normal density
is everywhere less than 2/5, and changing variable to x contributes 1/a_c.
For a roster with n+ positive and n- negative differences, put
n=n++n- and m=min(n+,n-)>0. Independence across Persons and maximization over
the unrestricted common Rater difference give the uniform bound

    E_theta product_selected_pairs p_pair^s
      <= min(1, [2*n/(5*a_c*s*m)]^n exp(-n+2*m)).

Indeed the maximizer of (|d|+2/s)^n exp(-s*m*|d|) is
|d|=n/(s*m)-2/s. Rosters without both directions contribute the bound one;
they do not silently supply a finite slope cutoff. Distinct rosters use
different Persons, so their bounds multiply. Other response probabilities
are at most one.

Since L_conditional<=exp(E), splitting its power gives

    L = E_theta[L_conditional]
      <= exp[(1-s)*E] E_theta[L_conditional^s]
      <= exp[(1-s)*E] product_rosters min(1,
           [2*n/(5*a_c*s*m)]^n exp(-n+2*m)).

The calculation uses s=min(1,N/(-E_upper)), with N the sum of informative
roster n values. Its validity does not depend on this being the sharpest
power. All arithmetic deciding exclusion is outward bounded. The old
proposal floor Q_j>=2^(-e_j) is reused: choose a slope cutoff A_jc=2^k so the
bound is at most 2^(-e_j-5). Above the cutoff, the sample importance weight is
at most 1/32 regardless of every other parameter.

The new cutoff exponents range from 10 to 53, versus 19 to 89 previously;
each of the 150 individual bounds improves. A separate log-form calculation
recounts the orientations and verifies every cutoff. Numerical integration
of 270 powered pair kernels, spanning unequal steps, signed differences and
three powers, also respects the analytic bound (largest integral/bound ratio
.942804). These finite numerical checks corroborate the derived inequality;
they do not replace its all-parameter proof.

### C. Centering prevents simultaneous location escapes

Reusing the earlier normal truncation H and logit budget C, likelihood at
least 2^(-e_j-5) implies, for every cell containing both endpoint scores,

    |b_r+b_c| <= D_c = H + C/(3*a_c).

The earlier bound replaced each reciprocal slope separately by a product of
two upper bounds. It did not exploit the two centered facets simultaneously.
Order the slopes a_i>=a_j>=a_k. Their product is one, hence

    1/a_i <= 1,    1/a_j <= sqrt(a_i) <= sqrt(A_i).

The two selected endpoint columns suffice to bound the requested contrast.
When its centered representation is b_i-b_j, subtract two cells sharing a
Rater. When it is 2*b_i+b_j or b_i+2*b_j (up to sign), add three endpoint
cells, one for each Rater, assigning the selected Criteria in the required
2:1 ratio. Rater effects then cancel by their sum-to-zero constraint, and
the omitted Criterion cancels by its own sum-to-zero constraint.

All six possible slope orderings have the necessary cells in every retained
sample; the 13 missing endpoint cells occur in different samples. For each
ordering the script constructs an exact cell combination and checks its raw
six-coordinate coefficients independently of the construction. The bound is

    |psi| <= (|alpha|+|beta|)*H
               + (C/3)*(|alpha|+|beta|*ceil(sqrt(A_i))),

where alpha and beta are the contrast coefficients on the largest and middle
slope owners. Integer square-root checks enclose the root without floating
rounding. Taking the maximum over six orderings, then over 50 samples, gives
the exact common radius 21448816766/3. This is sharper than 1.77876e23 from
the new slope bounds alone. All 300 cell combinations are verified directly
against the saved responses. The construction must be checked anew for a
different endpoint graph; it is not an assumption that incomplete designs
always admit the same bound.

Outside this contrast radius every sample weight is at most 1/32, so the
entire 50-term absolute MC sum is at most 1/32 before statistic-tail pruning.
Completed observed point failures still override this result and return the
whole line. Interior regions, possible empty sets and the useful endpoint
locations remain unresolved. No independent coverage data or original JML
refits were added by this bound work.

Sources are `jml-normal-profile-global-tail-20261004.py`, its independent
`-check-` companion and `jml-normal-profile-location-bound-20261004.py`.
Immutable witnesses, source/input hashes and checks are in
`normal-mc-calibration/profiles/global-tail/`. The result is an improvement
in the mathematical domain reduction, not evidence of interval precision,
coverage under misspecification, or qualification of a public covariance API.

## October 4: continuous retention and reusable slope-domain partitions

The first end-to-end development target is ordinary GPCM-JML, retained sample
1, Criterion 1 minus 2, under the same known-normal law and B=49 proposal
bank. The original algorithm points, self term, inclusive ties and denominator
50 are unchanged. Completed observed point failures still return the whole
line. No new responses, original JML fits or independent coverage units are
introduced by the work below.

**Continuous inner witness.** At fixed slopes the normal marginal likelihood
is log-concave in the linear location/step coordinates: its joint normal and
categorical kernel is log-concave before integrating abilities. Consequently,
along the stored unit-slope nuisance path, each sample weight satisfies

    w_j((1-t)*psi0+t*psi1) >= w_j(psi0)^(1-t)*w_j(psi1)^t.

The retained normalized-weight enclosures and absolute scale recover the
endpoint weights at psi=-1,-1/2,0 without repeating their integrations. At
the proposal itself every weight is exactly one. Split at all statistic
midpoints and the observed point; within a resulting segment include only
reference statistics that are at least the observed statistic throughout.
The sum of each geometric lower certificate's minimum bounds the whole
numerator below. This does not assume log-concavity of a likelihood mixture.
For ordinary GPCM-JML sample 1 the resulting p-value lower bounds exceed .05
on the **entire interval [-1,0]**. The saved pointwise enclosures overlap the
independently reconstructed anchor enclosures. All segment boundaries are
covered, including ties. This establishes genuine retained width one; it
does not identify the confidence set's endpoints or exclude other components.
The declared refinement precision is 1e-6; this particular interval required
no refinement beyond its statistic-change points.

On October 6 the same first-sample procedure gains the additional retained
segment [0,1/2]. The existing sample-38 zero-contrast nuisance point is reused;
there is no new optimization. Its first two slopes are represented as exact
rationals and the third is their reciprocal product. At contrasts zero and
one-half, outward chord integration gives log-weight lower bounds 7.46506936
and 2.30774781. An independent adjacent-odds calculation checks each point.
Sample 38 belongs to the inclusive statistic tail throughout this segment:
the difference of its squared statistic and the observed squared statistic
is affine in contrast and nonnegative at both endpoints. Fixed-slope marginal
log concavity then makes this one reference term alone supply p-value lower
bound .20103521 on the entire segment, with the original denominator fifty.

Together with the earlier result, this first extension gives the continuously
retained inner component **[-1,1/2]**. Fresh replay checks exact tail membership, the normalized
parameter constraints, the earlier interval partition and an 80-digit
reconstruction of the lower bound, reusing the certified endpoint integrals.
The original retention helper is resolved to its hash-matching immutable v2
source. Evidence is in `profiles/retained-extension-20261006/`. This establishes
genuine retained width 1.5 for one development set; it supplies neither an
exclusion, a projected endpoint nor the remaining topology.

**Genuine left-side width.** Reusing the saved far-ray nuisance points does
not supply a retained witness at -3. A new auxiliary likelihood search for
reference sample 6 finds a finite point with slopes approximately
(.24179941,3.38049187,1.22338983). Adaptive integration agrees with its
q241 value to 1.01e-10. With those slopes fixed, a second nuisance point at
-1 supplies the other endpoint. Its optimizer precision-loss flag remains;
only feasibility and the certified likelihood lower bounds are needed.
Neither calculation refits a frozen JML estimate or changes the proposal bank.

Outward chord integration gives endpoint log-weight lower bounds 3.88946683
and 12.06775592. Reference sample 6 stays in the inclusive tail throughout
[-3,-1], and the linear nuisance path stays within the centered location,
step and product-one slope constraints. Joint log concavity yields a p-value
lower bound .97769632 on this entire added segment. The joined retained
component is therefore **[-3,1/2]**, with genuine width 3.5. Fresh replay checks
the raw affine-logit coefficients, exact tail membership, prior component and
80-digit lower-bound reconstruction without repeating the endpoint integrals.
Evidence is in `profiles/retained-extension-20261006/left-minus3/`.
Loose outer bounds alone cannot explain this retained width, but endpoints,
other components and usefulness of the completed procedure remain unsettled.

All fifty original point statistics are finite. The remaining band [-10,-3)
has one exact rank-change point, sample 24's midpoint approximately -4.98988;
(1/2,10] has none. Sample 6's midpoint is about -18.98635, outside those bands.
These facts locate inclusive-tie changes; they do not make the nuisance-
supremum p-value monotone or establish the whole set's connectedness.

At that exact left rank-change point, the saved sample-6 witness from -3
and its linear rescaling do not certify retention. One warm auxiliary search
returns a feasible point with log weight about -19.70072942; independent
adaptive integration differs from q241 by 3.77e-8. This is below the
single-term retention threshold, so no lower integration or interval extension
is justified from this candidate. It neither excludes the composite null nor
locates an endpoint: all-slope upper bounds are still required. The original
estimates, fifty-sample bank and tie rule remain unchanged; the source-bound
record is in `profiles/retained-extension-20261006/left-rank-change/`.

The reference whose membership changes there (sample 24) also has an actual
auxiliary candidate checked by adaptive integration. Its log weight is
-43.96509388, with q241 discrepancy 4.23e-7. This candidate cannot certify
retention; it is not a composite-null exclusion. The original inclusive tie
and all fifty reference records are preserved in
`retained-extension-20261006/rank-change-reference24/`.

The complete 23-term rank-cut bound is then evaluated at the saved sample-6
candidate's exact product-one slopes. Retained outer-ray witnesses alone are
insufficient. Targeted dual refinement leaves sample 6 limiting; its new
global fixed-slope marginal upper is -240.9085533355, with supporting-plane
correction .0004058167. Independent adjacent-odds integration agrees with the
candidate value, and the exact nuisance-box/ray check passes. The original
optimizer precision-loss flag remains. Reusing this marginal certificate and
all 23 dual witnesses gives point upper approximately .00004051909.

Four subdivisions of the existing slope box then certify the entire rectangle
with approximate limits a1 in [.1683677233,.1808923278], a2 in
[4.1997763432,4.5121909594], with a3
their reciprocal product. The full numerator upper is .0046083624 for every
contrast at or below the exact rank cut. Fresh 80-digit replay checks inclusive
membership, all 621 raw balance/score cases, category-factor brackets and
the preserved partition. The four complementary children and all other slope
regions remain open: this is not a composite-null exclusion or a CI endpoint.
Evidence is in `left-rank-cut-reference6/` and
`retained-extension-20261006/rank-cut-point-gate/`; no original estimator or
response sample changes.

The existing fixed-slope concavity argument also permits inward profile
reuse throughout the finite band. Writing the boundary as a convex
combination of an outward witness and the target yields the upper directly
from the certified boundary upper and witness lower. The signed branch
continues to work across zero. In `normal-rescale/inward-finite-band-20261006/`,
66 left and thirteen right profiles pass exact algebraic reconstruction;
the exterior formula remains unchanged. Six captured-box transfers pass
fresh 80-digit independent replay. Their component log-weight uppers remain
above 215, so these boxes are not excluded. A preflight exact-equality
assertion failed on outward rounding; both computations are retained and
their larger upper is used, without a tolerance. No original fit or integral
is repeated. The original exterior-ray sources remain unchanged; the inward
right-ray epoch described below uses this qualified extension.

**Slope coverage.** `jml-normal-mc-slope-cover-20261004.py` retains a rectangle
partition in the first two positive slopes, with the third their reciprocal
product. The previous common upper slopes [2^26,2^53,2^27] supply its root
rectangle and certified exterior. Exact rational splits preserve coverage;
a separate rectangle sweep checks every horizontal slab for gaps/overlaps.
Pending and sharper-bound-required rectangles remain unresolved. A finite
`--steps` invocation checkpoints work; it does not turn unprocessed regions
into failed estimates. Source snapshots and input hashes bind inherited
exclusions to the procedure and parent partition.

Cold-start profiling identifies exact forest-bank construction as the main
cost of the captured iteration; this is not a steady-state timing. The
candidate in `forest-exact-reuse-20261006/` reuses identical ordered probability
row pairs and expands the normal variance with an exact Gram matrix.
All fifty samples give unchanged exact variance bounds; complete banks for
two samples and all twelve saved forest choices/uppers also agree. Fresh
replay rebuilds the raw scores and checks the original unmodified upper.
The inward right-ray epoch described below uses this qualified candidate;
its independent checker retains the original forest upper. The original
left-ray and terminal right-ray sources remain unchanged. The timing examples
do not establish an overall speedup.

`forest-bank-persistence-20261006/` additionally stores those proposal banks
under their exact probability inputs, helper source and runtime. Across the
two previously qualified samples, construction plus saving takes 69.40 seconds
and reading takes .227 seconds in one loaded-machine comparison. All twelve
banks, selected forests and exact uppers agree; fresh-process reading works
with reconstruction disabled, and damaged payloads or bindings are rejected.
The unchanged witness reconstruction also retains its existing cache keys,
while the actual producer remains source-bound. The v9 right-ray epoch below
uses the saved banks; all interval bounds and the original independent forest
checker remain unchanged. This measures bank reuse, not total search speed.

Four upper bounds are combined by taking their minimum per sample:

- Transfer an existing balanced dual q at reference slopes a0 via
  `q_new = delta_y + c*a0/a*(q-delta_y)`. Feasibility is checked exactly;
  every nuisance balance, Person score and contrast coefficient scales by c.
  Entropy is convex in 1/a, so each owner's box maximum is at an endpoint.
- Reuse the previous powered-discordance bounds. Selected pairs may now
  belong to different Criteria when they use different Persons. Dynamic
  programming proposes such allocations; raw recounting checks disjointness.
  The bound uses every assigned Person's actual orientation and roster.
- For a subset of small-slope owners, replace the free-ability conditional
  entropy by the saturated Rater/category entropy at theta=0. Away from zero,
  the conditional log likelihood increases by at most
  `t*sum(abs(theta_p))`, with `t=6*sum(a_upper)` for that subset. After the
  power split put k=(1-s)*t. The tilted normal density is at most
  `(2/5)*exp(k^2/2)` and its mass at most `exp(k+k^2/2)`. Thus each selected
  informative roster/owner group adds the previous log pair bound minus n*k,
  capped at zero, to `(1-s)*E + N*(k+k^2/2)`.
- Pair observed endpoint scores from Criteria 1 and 2 at a common Rater,
  in the orientation contradicting the proposed contrast ray. Flip endpoint
  probability by c/(3*a). These disjoint cell pairs cancel all nine nuisance
  coefficients, with contrast coefficient c*H and Person scores c*g_p.
  A Person may appear in more than one pair: square the **summed** Person
  scores when forming S, rather than treating those pairs as independent.
  Combining with conditional entropy E and, optionally, the static third
  Criterion gives the bound

      (1-s)*E + s*entropy_endpoint + s*c*H*psi
        + s^2*c^2*S/2 + s*c*k*sum(abs(g_p)) + N*(k+k^2/2),

  where k=(1-s)*t. This follows by normal exponential tilting and
  `E exp(k*abs(Z)) <= exp(k+k^2/2)`. It is a convex quadratic in s after
  fixing the endpoint-entropy upper bound; its minimizer on [0,1] is enclosed
  with rational arithmetic. The cell flips' raw nuisance balances, Person
  scores and contrast coefficients are checked independently.

These bounds exclude named large/large/small regions that the previous
single-owner bounds could not settle. For sample 1 the statistic-tail union
has 30 terms on psi>=10 and 22 on psi<=-10, still divided by 50. Membership
is checked against all exact change points and open segments for the saved
finite points, including failure-zero behavior. The inherited all-term
exclusions also apply to these subsets. The new endpoint bound settles the
first remaining rectangle on each side (log p upper bounds -55.6343 and
-25.8043 respectively). This is a regional result, not an exterior-ray or
endpoint completion.

Current evidence is in `normal-mc-calibration/profiles/` under
`slope-cover-observed-01-v2/`; `jml-retention.json` records the continuous
inner witness from `jml-normal-mc-retention-20261004.py`. Earlier partition
epochs and their source snapshots are preserved for replay. In particular,
the first available endpoint bound still leaves regions with one very large
slope and one moderate slope unresolved. The convex entropy mixture used by
the power split can be loose there; retain the original conditional entropy
witnesses when sharpening this gap. No completed topology, practical outer
endpoints, frozen public procedure or new sampling claim follows yet.

### Direct entropy, signed normal scores and the remaining sharpness gap

The continuation reuses the actual rational conditional-entropy probabilities,
including their separated-model swap fallbacks. For the first two owners, mix
these balanced probabilities with the endpoint-flip probabilities before
evaluating entropy, rather than mixing the two entropy upper bounds. Keep
the third owner's balanced conditional probabilities, or its saturated
Rater/category probabilities. All nine nuisance coefficients still cancel
exactly. In the latter case the Person score is
`s*c*g_p + a3*d_p`, where d_p is the signed residual under those saturated
probabilities; its normal MGF is computed directly. Entropy is convex in each
reciprocal slope, and the squared normal-score norm is convex in a3, so the
corresponding box maxima are at endpoints. Raw coefficient/score checks
cover both choices of third-owner probabilities and both contrast directions.

The same construction also uses any subset of the three saturated owners.
For that subset let E be the sum of the static/conditional entropies and let
`g_p(a)=sum_c a_c*d_cp` over the static owners. The Gram matrix is constructed
from the signed Person score vectors, including their cross-products.
Convexity bounds `V=max_a sum_p g_p(a)^2/2` at the slope-box vertices. This
replaces the earlier absolute-score envelope where that envelope is too loose.
Direct raw-design checks verify zero nuisance and contrast coefficients and
the exact Gram-matrix identity. These bounds concern the declared normal law;
they are not distribution-free statements about fixed-Person JML.

For either dual write its conditional bound as `log L <= F + g' theta`, with
V an upper bound on `sum(g_p^2)/2`. A further power u combines it with the
disjoint discordance pairs:

    log P <= (1-u)*F + (1-u)^2*V
             + sum_groups min(0, n*log(2*n/(5*a*u*m))-n+2*m).

Exponential normal tilting preserves independence and leaves each shifted
normal density below 2/5. Thus the existing powered-pair proof still applies;
different means for different Persons do not invalidate that uniform bound.
Floating optimization only proposes the powers/allocations. Accepted bounds
recheck raw assignments and use rational/outward arithmetic. This settles the
identified large-slope rectangles on which separately taking the minimum of
the two earlier bounds was insufficient. It does not settle the entire slope
domain or determine a confidence-set endpoint.

**Proposal probabilities now retained.** The old rectangle-integral floors
remain valid but lose 4.505--5.581 log units relative to precise probabilities
on these 50 inputs. `jml-normal-proposal-probabilities-20261004.py` fills the
missing absolute-probability stage using the original certified integrator.
Earlier normalized weights did not retain these 50 values. The maximum log
enclosure width is 3.45e-17; independent 241-node floating quadrature differs
by at most 1.14e-13. A wrapper type error initially interrupted validation
after integration; it was corrected, and raw integrals are now checkpointed
before normalization/cross-checks so a later validation failure cannot discard
that computation. `normal-mc-calibration/proposal-probabilities.json` and its
`.integrals.json` companion retain the normalized and raw enclosures with
source/input identities. The `--proposal` option uses them without changing
the proposal law, statistic, self term, ties or denominator 50.

**Strict rounding repair.** The general-slope profile integrator originally
formed its analytic Gauss remainder as a Python floating division before
interval conversion. It rounded downward by 6.43e-17 relatively. Replace it
with an exact `Fraction` division. The affected 99-segment sample-1 profile
was recomputed from its saved nuisance solution: parameters are identical,
and the global log-likelihood upper bound increases by about 1.17e-30. The
local-root/global-concavity qualification and independent regional checks
still pass. The unit-slope prototype already used rational arithmetic here.
The superseding certificates are under `profiles/rational-remainder/`;
the original results and both historical checker/source versions are retained.
Use the corrected general certificate for new claims, despite the negligible
change at displayed precision. The tail, direct-entropy and continuous-retention
proofs do not depend on this general-profile remainder.

**A specific marginal-profile obstruction resolved.** At slopes (1/5,1/5,25)
and psi=-10, reference sample 6 dominated the remaining conditional-dual
numerator bound. Its additional nuisance profile, with unchanged original JML
point, now has a certified global fixed-slope log likelihood upper bound
-276.18854923. Independent integration and directional Hessian checks pass.
A lower witness at psi=-9 gives the positive profile secant 3.65981347 and
therefore a certified whole left ray at those slopes. The checker accepts a
replicate argument and records the affine ray coefficients. `--sharp-profile`
transfers such a checked ray to a slope box using the categorical temperature
inequality and Jensen; it does not replace the integrated bound by a conditional
MAP value. Combining the sample-6 marginal bound with the other stored duals
and precise proposal probabilities gives log p upper approximately -7.4916
at that reference slope vector. This closes that named numerator gap, not the
remaining slope supremum.

Current partition epochs are `slope-cover-observed-01-v5/` (precise proposal
and the sample-6 marginal ray) and `slope-cover-observed-01-v6/` (signed static
normal scores). Their pending/unresolved rectangles remain explicit. The
continuous retained interval [-1,0] is unchanged; whole-set topology, practical
endpoints, application to the retained bank and independent confirmation remain
unfinished. No response datasets or original JML fits were added by these
bound refinements, and no public covariance API or coverage claim is qualified.

### Reuse auxiliary duals where the existing witnesses are loose

The remaining left-ray rectangles exposed a specific weakness of reusing only
the original two slope anchors. In the rectangle containing slopes
(3/4,1400,1/1050), samples 6 and 32 dominate the upper sum. Applying the existing
joint-MAP dual construction there gives exactly balanced witnesses; the
sample-6 log-weight upper after transfer over the whole identified rectangle
is -41.1210. This is a marginal-likelihood upper bound from entropy and the
normal MGF, not a claim that conditional MAP equals marginal likelihood.
The slope-cover runner now caches these auxiliary witnesses, checks the ray
sign of their affine contrast coefficients and transfers them to other boxes.
It invokes new auxiliary fits only for influential terms in narrow unresolved
boxes. These are not refits of the frozen JML statistics. Every certificate
used by an exclusion has a retained digest; source snapshots and exact
partition checks preserve completed exclusions across continuation epochs.

Epoch `slope-cover-observed-01-v7/` stopped when one auxiliary projection
produced a negative probability. Its last complete checkpoint remains valid.
The continuation in `slope-cover-observed-01-v8/` records that particular
construction failure as `WitnessUnavailable`, with `StatisticalFailure=FALSE`
and no certified exclusion. A cached witness may still resolve the box;
otherwise it stays unresolved. This does not invoke the completed-estimator
failure rule or turn unresolved computation into a whole-line statistical
result. Replaying one new exclusion from its actual endpoint, pair, mixture
and adaptive selections gives a complete numerator upper of 8.32149e-14;
the adaptive witness also passes 27 independent raw balance/score/entropy
checks. Omitting other selected bounds in that replay is insufficient and
is not a valid test of the recorded combined bound.

For a separated conditional auxiliary model, a simpler replacement for the
weak swap fallback pools Persons with the same co-rater roster and owner
pair total. The empirical category marginals within each pool preserve every
Rater/category count and every Person's pair total exactly. They therefore
give another balanced conditional entropy witness with zero ability score.
This improves sample 6's owner-2 entropy upper from -5.00402 to -13.86294,
without another optimization. The runner uses it only when it is stronger.
Raw sufficient-statistic balance, normal-score checks and retained marginal
likelihood enclosures pass. On the first right-ray rectangle whose new
auxiliary projection failed, the complete log numerator upper becomes
-8.71359. This addresses the particular numerical obstruction without an
arbitrary slope cap. Epoch `slope-cover-observed-01-v9/` continues both rays
from the completed v8 checkpoints, using this witness; neither exterior-ray completion nor a confidence-set endpoint
has been asserted. The inner witness [-1,0] and all other D1 obligations
remain unchanged.

### Exact probability-face projection for a separated auxiliary model

The owner-2 sample-6 fallback still left a conditional entropy gap of 2.72810
after the empirical improvement. Its original saved auxiliary fit already
contained a near-optimal limiting probability vector; enforcing strictly
positive probabilities in the subsequent rational projection caused the
failure. The revised calculation permits zero cells. Floating QR proposes
an independent correction basis on a selected probability face, then rational
elimination enforces row normalization and every original sufficient-statistic
balance equation. Every probability must be nonnegative. Independent checks
in response coordinates verify each Person's pair total, each Rater's total
and the shared category counts. A proposed face or rank that fails those exact
conditions supplies no bound. No floating rank tolerance certifies an exclusion.

For this stored sample/owner, 80 nonzero cells and a 69-coordinate correction
basis give entropy upper -16.591042310315533 and a retained primal/dual gap
at most 1.20e-9. This uses the saved candidate probabilities and no additional
auxiliary optimization, response data or original JML refit. The empirical
fallback remains available when an exact face projection cannot be recovered.
Zero probabilities use the continuous convention `0 log(0)=0`; they do not
require zero response probabilities in the evaluated marginal model.

The direct balance, entropy, normal-MGF, marginal-likelihood enclosure and
inclusive ray-membership checks pass with the refined witness. The new
`slope-cover-observed-01-v10/` epoch retains its exact source, sample-6
probabilities and checker output, and reuses completed v9 exclusions while
re-evaluating unresolved boxes with the stronger bound. This improvement
does not alter the statistic, proposal, denominator, tie or failure rule.
Exterior-ray completion, useful endpoints and independent confirmation remain
open; the additional witness is not reported as a completed confidence set.

### Normal integration from a forest of probability transfers

The v10 conditional/normal-MGF bounds left narrow rectangles with highly
unequal slopes. A joint-MAP envelope alone can lose substantial integration
mass in this regime. The new `jml-normal-profile-forest-20261004.py` retains
that mass effect without a new auxiliary optimizer or original JML refit.
This is a project-derived bound for the existing iid N(0,1) calibration law;
it does not extend that law to fixed abilities or dependent Persons.

Start with exactly balanced category probabilities q. Each owner's probabilities
are either the retained conditional witness or empirical probabilities within
Rater/owner cells. They preserve every Rater total and owner/category count,
so all unrestricted location/step coefficients and the contrast coefficient
vanish in the Fenchel bound. Write its entropy as E and its Person-score vector
as g. The conditional likelihood is at most exp(E + g' theta).

For two response rows at the same Rater/owner but different Persons, transfer
probability between categories k < l in opposite directions in the two rows.
Positive amounts delta+ and delta- define two alternatives, each preserving
normalization, nonnegativity and every cell/category total exactly. If their
two-row entropies are E+ and E-, their additional Person-difference coefficients
are -s+ and s-, where s+/- = a (l-k) delta+/-. Their pointwise minimum has
Lebesgue integral

`exp((s- E+ + s+ E-)/(s+ + s-)) * (1/s+ + 1/s-)`.

Select disjoint **response rows** whose Person-pair edges form a forest.
Persons may occur in several edges. All combinations of the probability
transfers remain feasible because the response rows are disjoint. After
tilting the independent normal law by exp(g' theta), the vector of edge
differences has mean B g and covariance B B', with B the signed incidence
matrix. Its density is bounded by `(2*pi)^(-m/2) / sqrt(det(B B'))` for m edges.
For a forest, `det(B B')` is the product of its component vertex counts:
Cauchy--Binet sums the squared full-rank incidence minors, each 1, and a tree
on v vertices has v such minors. Independent components multiply. Thus the
full upper bound is the unused-row entropy, plus `sum(g^2)/2`, plus the log
integrals above, minus `m*log(2*pi)/2 + log(det(B B'))/2`.
This preserves shared-Person dependence; replacing the determinant by 2^m
would be incorrect except for disjoint Person pairs. Cycles and repeated
response rows are explicitly refused.

Across a slope rectangle, the reciprocal-slope factors use its lower bounds
and the convex quadratic `sum(g^2)` uses the maximum over its vertices.
Floating arithmetic proposes a forest and transfer amounts only. The accepted
probabilities, row/cell balance, disjointness and forest condition use exact
rationals; entropies and normalizing constants use outward interval arithmetic.
Subtracting a selected row entropy uses its lower enclosure. No rounded
proposal value can certify an exclusion.

On the previously unresolved sample-6 rectangle, the selected nine edges
have incidence determinant 72. The outward marginal log-likelihood upper is
-286.29116 and the log absolute-weight upper is -65.08293. Independent raw
balance/score checks at three slope settings pass for both directions of all
nine transfers (54 checks); exact elimination reproduces determinant 72.
Nine direct one-dimensional normal integrals, including nonzero tilted means,
lie below the corresponding density-envelope bounds. The checked sources,
probabilities' inputs and result are retained under `profiles/normal-forest/`.

The v11 slope-cover epoch inherits the closed v10 exclusions and applies this
bound to pending/unresolved boxes. A separate verifier, which performs no
witness selection or fitting, has replayed the complete absolute MC numerator
for the first 363 newly excluded left-ray rectangles. Every recomputed upper
is at most .05 with denominator 50 and the actual inclusive tail membership;
the optional sharp marginal-profile ray is omitted in that replay. Its saved
state snapshot still has pending regions, so the replay does not certify the
whole ray. Both ray searches continue with the original points, proposal,
failure rule and inner witness [-1,0] unchanged. Complete set evaluation and
independent confirmation remain required.

### Contrast transfers in rows left free by the normal forest

The v11 forest bound leaves some moderate-slope rectangles unresolved. A
second kind of probability transfer adds contrast decay without changing
its normal-score vector or incidence covariance. Choose two unused response
rows at the same Person and Rater, one for Criterion 1 and one for Criterion
2. On a left ray, transfer `c/(3*a1)` from category 0 to 3 in the first row,
and `c/(3*a2)` from 3 to 0 in the second. On a right ray reverse both moves.
Uniform feasibility requires positive c no greater than three times the
smaller lower-slope-weighted probability of the two removed categories.

The weighted mean changes are equal and opposite. Sharing Person and Rater
therefore cancels both ability and rater coefficients. The remaining
unrestricted location coefficient also cancels, and probabilities of
categories 1 and 2 do not change, preserving all step coefficients. The
contrast coefficient is +c on the left and -c on the right. Thus the bound
gains `-|psi|*c` uniformly on the corresponding exterior ray. Because the
rows are disjoint from every selected forest row, all combinations of its
two-sided transfers remain feasible with exactly the same normal scores and
incidence determinant.

The changed-row entropy is convex in reciprocal slope, so its maximum on
each slope interval occurs at an endpoint. The implementation adds the upper
entropy change, subtracts the lower enclosure of the original row entropy,
and adds the contrast term to the forest bound. It requires the original
forest upper to be strictly negative: adding a correction to a value already
clipped at zero would not in general be valid. Floating scalar optimization
only proposes transfers; rational feasibility and outward entropy enclosures
determine the accepted bound.

On the first newly unresolved v11 left rectangle (a1 about 0.3983--0.4597,
a2 about 2319.6--2677.6), the complete 22-term inclusive MC numerator divided
by the original 50 is bounded by **0.01401142**. The same selected forests
without these transfers give upper **0.11355885**. Raw response-design checks
at three slope settings verify normalization, nonnegativity, all nine
nuisance balances, unchanged normal scores and the exact contrast coefficient,
including both alternatives of each forest edge (1,290 checks). A separate
fresh-process replay with forest/transfer selection and fitting disabled
reproduces every stored term and the complete sum exactly. An additional raw
design check reverses the contrast direction on the same sample-6 forest:
all 57 balance/score checks pass for eight right-ray transfers. No response data
or original JML fits are added. Sources, choices, the state snapshot and replay
are retained under `profiles/forest-endpoint/`; its `archived-sources.json`
maps the earlier slope-cover and endpoint-helper sources to their exact snapshots.

After this check, the two dedicated v11 workers were interrupted to adopt
the stronger bound, preserving their atomically saved partitions. Exact
partition checks retain 1,395 left and 1,517 right exclusions. The v12 epoch
reuses those exclusions and requeues only pending/unresolved rectangles
(11+149 left, 8+13 right at the transition). Its source and transition record
are retained in `profiles/slope-cover-observed-01-v12/`. This is still the
same sample-1 procedure and iid-normal calibration scope: full-ray and
confidence-set completion, general JML uncertainty and independent coverage
qualification remain open.

The v12 right search adds nine exclusions; separate full-numerator replay
verifies all nine. It then encounters an actual proposal-selection error:
floating entropy summation can make the zero-transfer candidate appear
slightly improving. Exact validation correctly refuses its zero scalar before
saving an exclusion. A retained sample-1 case reproduces the error. Requiring
a positive proposed scalar removes that candidate, preserves every positive
witness and produces exactly the same checked bound as the former helper
with its zero move removed. This is a computation repair, not an estimator
failure or a change to the test's failure rule.

The v13 continuation keeps both completed exclusions and prior unresolved
decisions, because this repair cannot sharpen an already completed bound.
Only the saved pending boxes are resumed: 65 left and 7 right. The 95 left
and 5 right unresolved rectangles remain explicit; 1,395 left and 1,526 right
exclusions are retained. The previous helper and main source stay archived
with matching hashes, including the v12 replay. Ordinary continuation after
a genuinely stronger bound may requeue unresolved boxes; `--pending-only`
distinguishes this repair from that operation. Full confidence-set completion
and independent coverage remain open.

The next unresolved left rectangle has a1 about 0.09484--0.10947 and a2 about
735.94--849.50. Sample 6 remains the limiting term even at its midpoint under
the forest bound. At fixed slopes (51/500, 791, 500/40341), the retained
marginal candidate has log likelihood about -285.0978474452602. Tightening the
floating integrator fails its admission check; that failure is preserved.
An optimizer-free outward moment calculation uses the existing certified
complex-disk mesh (331 segments), a checked order-32 Gauss rule and the same
global concavity/root argument. The original floating center does not pass
the root test. One exact rational Newton correction from its saved enclosed
gradient/Hessian is reevaluated at a denominator-2^120 center; this passes,
with global fixed-slope log-likelihood upper -285.0978474452603. No tolerance
is relaxed and no original estimator is refitted.

An independent adjacent-odds integral agrees to floating precision; three
directional Hessian differences are below 2.5e-6, and all 447 dominance disks
pass separate natural-logit checks. The rational center's effect on this
independent comparison is bounded explicitly. A chord lower integral at
contrast -9 exceeds the certified upper at -10, proving the left contrast
ray with affine slope 0.8107910711. The earlier coarse slope-temperature
transfer already lowers sample 6's log-weight bound on the identified box
from 3.86465 to -0.92433. This is one term, not a complete MC exclusion.
Candidate, failed and successful root checks, moments, quadrature verification,
independent checks and the ray witness are retained in
`profiles/large-owner-two/`.

Before the stronger-bound transition, separate full-numerator replay verifies
19 new v13 left and 10 new v13 right exclusions. The terminal left partition
contains 1,427 exclusions, 230 unresolved rectangles and 8 pending rectangles.
The v14 left epoch preserves all exclusions and requeues the remaining boxes;
the right v13 worker is unchanged. The replay checker now includes retained
allocated-pair/affine-dual witnesses and optionally recomputes certified
profile-ray transfers. Its earlier source and outputs remain archived.
The complete useful set, endpoint enclosures and independent confirmation
remain the deliverable; these auxiliary bounds alone do not complete it.

The existing four-category temperature bound gives a sharper transfer near
either checked profile. For a slope ratio r>1 and common power 0<t<=1, its
factor is `C(r,t)=max_u (1+u)^t/(1+3^(1-r)*u^r)`. Its unique maximum lies in
0<u<3; the increasing derivative is bracketed outward. Ratios between t and
1 need no factor. Because both slope vectors have product one, at most two
owners have ratio above one; each has 60 responses in this retained design.
Thus `t*U + 120*log(C(rmax,t))` bounds the marginal log likelihood on the
rectangle, by the category inequality followed by Jensen. The search takes
the minimum with its former bound. It evaluates this refinement only for
rmax<=2; all other boxes retain the former bound and remain in the domain.

On another actual unresolved left rectangle, sample 6's log-weight upper
falls from 24.25976 under the coarse profile transfer to -2.35333. Combining
it with nineteen checked forest/free-row witnesses gives complete MC upper
**0.0462285977443835**, below 0.05. There are 2,655 raw balance/score checks.
A fresh process independently checks the scalar root bracket and recomputes
all 22 terms with witness selection disabled, reproducing the complete upper
exactly. This is an actual regional exclusion, not merely a smaller single
term. The evidence is in `profiles/sharp-transfer/`, including its archived
source map. It does not settle other regions or sampling coverage.

At the validated transition, v14 retains 1,427 exclusions and has 188
unresolved plus 50 pending boxes; it has added no exclusion before this
transition. Of its unresolved boxes, only 25 can change under the new profile
transfer. Direct comparison verifies exact equality of old/new bounds on the
other 163, no increase on the affected boxes, preservation of all exclusions
and exact partition coverage. The v15 left worker therefore revisits those
25 plus the 50 pending boxes (`--profile-only`). The right v13 worker remains
unchanged. Replay now resolves a changed main source to the partition epoch's
exact hash-matching `source.py`, preserving the earlier source identity rather
than assigning new code to old exclusions. This refinement and regional
exclusion do not yet constitute the completed confidence set.

The next right-side replay encounters a saved probability mixture with an
additional pair power, which its initial verifier did not implement. That
explicit refusal is preserved; no failed replay is counted as verification.
The verifier now reconstructs the saved rational mixture and its recorded
pair assignments, without rerunning the mixture optimizer. The subsequent
snapshot verifies all 166 new right exclusions, including these witnesses;
all earlier 78 replay values reproduce exactly. The earlier verifier sources
and failed/successful logs remain archived. The right ray still has pending
and unresolved boxes. All fifteen new v15 left exclusions pass
complete-numerator replay with the independently evaluated sharp profile
transfer (`slope-cover-observed-01-v15/left-final-replay.json`). The terminal
partition retains 1,442 exclusions, 327 unresolved and ten pending boxes.

The v16 transfer uses the two largest individual owner factors:
`t*U + 60*(log(C_(1)) + log(C_(2)))`, retaining the minimum with both older
bounds. Product-one still limits the above-one ratios to two. Exact scalar
bracket and complete-numerator replay in `profiles/owner-temperature/`
excludes three actual remaining rectangles with uppers 0.04509298728151271,
0.0027206044728424134 and 0.04617282867683616. The first two reuse all forest
choices; the third needs new forests only for the identified sample-7 and
sample-48 terms. Existing endpoint transfers are scaled to the new lower
slopes before evaluation. `replay-exact.json` reproduces every saved term
and total exactly, superseding the earlier comparison-tolerance replay.
Integration checks preserve all 1,442 exclusions, give exact equality on 275
unaffected unresolved boxes and no increase on 52 affected boxes. Only the
52 affected plus ten pending boxes enter the v16 continuation.

The fixed-slope profile calculation now also admits an enclosed supporting
plane without a stationary-root test. If the full marginal likelihood is
at least epsilon, every Person's pattern has probability at least epsilon.
An outward normal-tail bound then gives an ability in [-H,H] at which each
observed category has probability at least epsilon/2. Observed-versus-other
category logit inequalities bound all nine location/cumulative-step
coordinates; outside that box the full likelihood is below epsilon.
Log concavity therefore bounds the entire profile by the larger of the
supporting plane over this box and log(epsilon). The new
`jml-normal-profile-concave-bound-20261004.py` reuses the verified complex-disk
mesh, Gauss rule and integration remainders and computes only value/gradient.

At the previously retained initial center for slopes (51/500,791,500/40341),
all nine gradient enclosures agree with the stored transformed moments.
The box correction is 0.0000015167, yielding global log-likelihood upper
-285.09784592857847. Independent review verifies 108 raw logit inequalities,
18 exact rational coordinate duals, the tangent bound, normal tail and all
447 dominance disks. Reusing the existing inward witness gives left-ray
slope 0.8107895544. Evidence is in `profiles/concave-box/`; no original
estimator was refitted. This bound does not replace the sharper root-based
bound at the same slopes.

The method subsequently resolves an actual uncovered rectangle with a1 about
0.02258--0.02607 and a2 about 980.59--1131.90. Reusing the existing forests
first identifies sample 6 as the limiting term; all other terms together
are already small. At reference slopes (243/10000,1054,5000/128061), a finite
auxiliary candidate stops with a precision-loss message. No stationary-root
or optimizer-success claim is needed: its enclosed supporting plane gives
global upper -286.7416364378813, including a 0.01916467 box correction.
Independent logit/coordinate and mesh checks pass. The inward chords at -9
and -8 do not exceed that upper and remain recorded. The nearer chord at
-9.5 does, giving a valid left-ray slope 0.01258505.

Complete-numerator verification in `profiles/concave-gap/full-check.json`
gives **0.000003186090158634659**, with 2,655 raw balance/score checks and no
new forest selection or original estimator fit. The independently evaluated
transfer and the main expression differ by 3.42e-49 from outward operation
ordering. An exact comparison verifies that the main expression is the more
conservative one; that larger value is used, without a tolerance adjustment.
The initial equality-check refusal is preserved. This is a regional
exclusion, not a complete confidence set or independent coverage result.

The terminal v16 partition has 1,450 exclusions, 390 unresolved and eleven
pending boxes; all eight new v16 exclusions pass separate full-numerator
replay. A source-bound queue transition compares the old and added
profile on every unresolved box. It preserves all exclusions and 332 exactly
unchanged bounds, and requeues only the 58 strictly improved boxes plus the
eleven pending boxes. The unchanged search code resumes this queue as v17
using its existing `--pending-only` path. The right-side replay now verifies
272 new v13 exclusions; all 166 previously verified values are reused
unchanged against the identical archived verifier. Both complete rays,
useful whole-set evaluation and independent confirmation remain unfinished.

The next unchanged region has a1 about 0.07117--0.08216 and a2 about
98.70--113.93. Its three influential terms are samples 6, 7 and 48. New
forest selections for these terms, checked before use, resolve samples 7
and 48; sample 6 still requires a marginal-profile bound. At reference
slopes (19/250,106,125/1007), the gradient-only enclosure gives global upper
-271.81244389199094 with a 0.000155865 box correction. The independent
coordinate/logit check, all 321 dominance disks and the -9.5 inward chord
pass; the resulting left-ray slope is 3.98970284. The auxiliary optimizer's
precision-loss status remains recorded and does not substitute for this
certificate.

`profiles/concave-mid-owner-two/full-check.json` bounds the complete 22-term
numerator by **0.0000007198169533087932**, with 3,054 raw checks. The transfer
is independently evaluated, and the more conservative outward endpoint is
used without a tolerance adjustment (both expressions coincide here).
The terminal v17 state retains 1,460 exclusions, 409 unresolved and ten
pending boxes; all ten new exclusions pass full-numerator replay. A new
queue comparison preserves all exclusions and 346 unchanged bounds, and
requeues exactly 63 improved boxes plus the ten pending boxes. The existing
search resumes this queue as v18 with unchanged source and four checked
profiles. No original estimator or dataset is regenerated; neither complete
ray, whole-set evaluation nor independent coverage is claimed.

The right-ray review now identifies sample 6 as the sole limiting term in
an actual unresolved rectangle with a1 about 0.07117--0.08216 and a2 about
359.11--414.52. Reusing the retained right-side forests gives MC upper 7.24249;
a newly checked sample-6 forest alone remains insufficient (5.82181).
At slopes (19/250,386,125/3667), the same supporting-plane method gives global
log-likelihood upper -322.356145456353, with box correction 0.0000007798.
Independent checks verify the 108 raw inequalities, 18 rational coordinate
bounds and 426 dominance disks. The 9.5 inward chord yields right-ray slope
-5.65947605. `profiles/right-remaining/full-check.json` then bounds the full
30-term MC numerator by **1.760352960406744e-16**, retaining denominator 50.
Its 4,098 raw checks include 57 reused unchanged from the new forest check.
No original estimator fit or dataset is regenerated.

The terminal right v13 state retains 1,926 exclusions, 80 unresolved and
11 pending boxes. All 400 new v13 exclusions pass full-numerator replay;
the first 343 verified entries are reused unchanged against the identical
archived verifier. The source-bound transition preserves all exclusions and
34 exactly unchanged profile bounds, requeuing only 46 strictly improved
boxes plus the pending 11. The v19 right continuation uses the existing
search with the checked profile; the v18 left continuation is unaffected.
These remain regional inversion results under the retained known-normal
development law, not complete rays, a general JML API or independent coverage.

The next retained right region has a1 about 0.008270--0.009546 and a2 about
980.59--1131.90. Reused forests give MC upper 0.05352479, and a newly checked
sample-6 forest reaches only 0.05148891, so no exclusion is claimed at that
stage. At slopes (89/10000,1054,5000/46903), an immutable finite candidate
snapshot gives global log-likelihood upper -334.9910651142387, including a
0.000873802 box correction. The independent logit/coordinate checks and 480
dominance disks pass; the 9.5 chord gives right-ray slope -6.37083613.
The auxiliary optimizer subsequently stops naturally with precision loss;
its success is not required by the supporting-plane certificate.
`profiles/right-small-owner/full-check.json` bounds all 30 terms by
**1.2344665928610291e-23**, with 4,098 raw checks including 57 reused unchanged.

All 41 new terminal v19 right exclusions pass full-numerator replay. Its
1,967 exclusions and 49 unchanged unresolved boxes are retained; only 23
strictly improved boxes and nine pending boxes enter v20. All 159 new
terminal v18 left exclusions also pass replay, retaining the earlier 82
verified entries. The storage-only v21 left transition preserves its 1,619
exclusions, 530 unresolved decisions, twelve pending boxes and four profiles.
Neither complete exterior ray nor the full inference outcome is finished.

**Checkpoint storage.** The right state had exceeded 1.3 GB and was rewritten
in full after each decision. The adopted private epoch code stores immutable
inherited exclusions by path/hash/count and writes only the new exclusion
suffix; it reconstructs the complete state before partition checks. No
canonical numerical helper or existing proof source is changed. Reversing
the explicit I/O/provenance edits restores the original search and replay
numerical programs exactly. The actual 1,285,460,575-byte terminal v13 state
becomes a 118,608-byte reference checkpoint (0.00124 seconds to write).
A separate fresh process recovers the exact original JSON SHA256 and
partition. Appended records, multiple epochs, altered ancestors and incorrect
counts are checked. Replay expands the captured snapshot, so an active-file
update cannot silently change the state associated with its recorded hash.
The unadopted gzip trial preserves every byte but writes 489,710,746 bytes in
19.0 seconds. These are checkpoint measurements, not total-estimation speedup.
Evidence is in `profiles/checkpoint-storage/`. Referenced parent checkpoints
remain immutable and required; the new files are not independent substitutes
for their parents. The v20 right and v21 left runs use this qualified storage.

Actual v20/v21 output now also passes fresh-process expansion and complete-
numerator replay: the first ten right exclusions (including the certified
small-owner target box) and seven left exclusions are verified. The first
additional decision was stored in about 2.3 MB on the right and 2.1 MB on
the left, with the full immutable parent retained. Later files grow with
the new suffix. These observed checkpoint results confirm the storage path;
they do not establish complete confidence sets or nominal coverage.

**October 5: normal rescaling of the retained profile bounds.** A central
remaining right rectangle has a1 about 0.03009--0.03473 and a2 about
552.33--637.56. Its reused full-sum bound is 1.77152, with only sample 6
limiting. The reference slopes (323/10000,594,5000/95931) give certified
global upper -312.3592915167154, including a 0.003490750 supporting-plane
correction. The immutable finite center, 272 integration segments, 108 raw
logit inequalities, 18 exact coordinate duals and 420 dominance disks are
checked. The auxiliary optimizer's precision-loss status is retained.
`profiles/right-mid-owner/full-check.json` gives complete 30-term MC upper
**2.6635518568883333e-19**, with 4,098 raw checks and no new forest selection.

The transfer to nearby slopes can be sharpened without fitting more reference
points. Put z=c*theta, 0<c<=1, and rescale all locations/steps and the contrast
by c. The reference normal density ratio is
`h(z)=exp((1-c^-2)*z^2/2)/c`. For a nonnegative Person likelihood F and
0<t<1, Holder's inequality gives
`E[F^t h] <= (E[F])^t K(c,t)`, where

    log K(c,t) = -t log(c) + (1-t)/2 log((1-t)/(1-t*c^2)).

At t=1 use K=1/c; at c=1 use K=1. Category temperature ratios are now
`a_j/(c*a0_j)`. Their product is c^-3, so **all three owner factors** are
required. With t the minimum lower ratio, capped at one, the log-likelihood
upper is `t*U(c*psi) + N*log K + 2*N*sum_j log C_j`. The same scalar maximum
proof applies above ratio two; ratios above sixteen may conservatively use
`C_j=4^t`. These are bound choices, not slope-domain restrictions.

A feasible likelihood lower at contrast 10.5, together with the checked
global upper at 10, gives a concave-profile secant valid toward smaller
contrasts. The existing right secant handles contrasts above 10. The three
outward lower witnesses give inward-extension slopes -5.86391460,
-6.71531758 and -3.93767097. Thus U(c*psi) bounds the entire transformed ray,
including both sides of the original profile boundary. The source and
witnesses are in `profiles/normal-rescale/`.

The qualification checks 972 exact raw-utility rescaling identities, five
direct Gaussian integrals and independent scalar-maximum brackets. A second
actual unresolved rectangle (a1 about 0.02258--0.02607, a2 about
414.52--478.49) uses c=0.7 and t=0.9969316849684585. Its checked profile upper
is -243.12596470735974; the full 30-term bound in
`normal-rescale/region-right/full-check.json` is **6.057411817110168e-12**,
with 4,098 raw checks. No numerical tolerance is used for exclusion.

The private search retains the previous bounds and adds their minimum with
this qualified bound. Its separate replay rebuilds the profile secant,
normal moment and all three scalar factors. Exact source-reversal checks
preserve the previous search/replay paths; scale-one and large-ratio branches
also pass. Canonical shared numerical sources remain unchanged. The v22
transition preserves all 2,080 terminal v20 exclusions and requeues the 67
strictly improved unresolved boxes plus nine pending boxes. Neither ray,
the complete useful confidence set nor independent coverage is yet complete.
All 113 new terminal v20 exclusions subsequently pass full-numerator replay,
reusing the first ten unchanged entries.

The same density transformation applies to the left ray. Outward -10.5
witnesses for the retained concave-gap and medium-owner-2 profiles give
inward-extension slopes 0.17153289 and 4.44746213. Independently evaluated
sample-6 bounds improve in 495 of the 530 retained unresolved boxes; fourteen
fall below the entire MC budget for that term. This is a scheduling screen,
not a 14-region full-sum exclusion result. For the rectangle with a1 about
0.03009--0.03473 and a2 about 849.50--980.59, all 22 terms are independently
bounded by **0.00007618990469902294**, with 2,655 raw checks. Other influential
terms (7 and 48) retain their bounds. No new auxiliary fit is needed.

The v23 transition preserves 1,723 terminal v21 exclusions and 516 unresolved
boxes, revisiting the fourteen relevant boxes plus ten pending boxes. Of the
516 retained unresolved boxes, 481 have an improved sample-6 profile bound
that remains above the whole MC budget; 35 have no improvement. They remain
explicitly unresolved. The full domain, denominator and original procedures
are retained. Evidence is in `normal-rescale/left-impact.json`,
`normal-rescale/region-left/full-check.json` and `left-queue-transition/`.
All 104 new terminal v21 exclusions pass full-numerator replay, retaining the
first seven unchanged entries. The first four actual v22 output exclusions
also pass fresh-process replay through the new independent normal-factor
checker. Later decisions remain subject to incremental replay.
The first 22 actual v23 exclusions subsequently pass the same independent
replay; they include all fourteen selectively requeued left rectangles.
The incremental v22 replay subsequently verifies 69 actual new exclusions,
reusing the first four unchanged entries. Exact rectangle matching confirms
that both named right targets are included in those 69 checked decisions.
Later suffix entries remain subject to incremental replay.

Three further right reference profiles address the actual sixteen remaining
unresolved rectangles. At slopes (431/10000,386,5000/83183),
(3/50,650,1/39) and (91/5000,685,1000/12467), their checked global uppers
are -314.9435283683394, -317.49605752172977 and -320.69716013397215.
The supporting-plane corrections are respectively 0.00000124349,
0.000339136 and 0.000232000. Independent natural-logit constraints,
coordinate duals, adjacent-odds integration and inward/outward witnesses
pass for all three; finite centers remain valid despite the latter two
auxiliary optimizers' recorded precision-loss statuses. The outward witnesses
give inward-extension slopes -5.17201842, -4.21294045 and -5.16762554.
No new original JML statistics or datasets are fitted/generated.

Fifteen parent rectangles pass directly; the remaining parent is covered by
four exact children. A single containing rectangle, a1 about
0.014682--0.094835 and a2 about 269.51--980.59, bounds the other 29 terms
uniformly by MC contribution **1.2752097023916459e-11**. Reusing this bound
avoids repeating the same raw checks for each child. All 19 complete 30-term
bounds pass, with maximum **0.0005378115896344246**, retaining denominator 50.
The shared forest proof passes 4,041 independent raw constraint checks;
normal moments, profile secants and all three temperature factors are also
independently checked on each leaf. Evidence is in
`normal-rescale/right-gap-coverage/shared-forest-full-check.json` and
`normal-rescale/right-gap-profile-checks.json`. The preceding individual
check's two completed rows and interrupted remainder are retained; its
replacement uses the more conservative common rectangle, not a time cutoff.

The v24 transition preserves all 2,212 terminal v22 exclusions and the nine
original pending boxes, replacing the sixteen unresolved parents with their
nineteen checked covering leaves. Exact partition verification includes the
three added splits. The numerical and replay source bytes are unchanged;
the new epoch adds only the three qualified profiles. Actual output replay
and completion of the remaining pending domain still follow. This does not
complete the left ray, useful whole-set topology or independent coverage.
All 132 new terminal v22 exclusions subsequently pass independent full-sum
replay, reusing the earlier 69 unchanged entries. The inherited exclusions
remain represented by their immutable parent chain.
The first 21 actual v24 exclusions also pass independent full-numerator
replay. Exact rectangle matching confirms that they include all nineteen
covering leaves above. The remaining pending domain is still being evaluated.
The next captured v24 snapshot passes replay for 94 new exclusions in total,
reusing the first 21 unchanged entries. This verifies the additional decisions,
while the active worker's later suffix and pending domain remain separate.
A subsequent snapshot passes the same independent replay for 251 new
exclusions, reusing those 94 checks. The right ray remains incomplete; new
unresolved rectangles encountered by the continuing worker are retained.
All 281 terminal v24 exclusions later pass independent replay. The worker
stops while proposing a dual witness at slopes (109/250000, 163, 250000/17767):
the auxiliary trust-region optimizer raises a nonfinite-array error. Replaying
that actual sample-6 proposal confirms the failure. A private v28 copy handles
only that explicit error as `WitnessUnavailable`; unrelated errors propagate,
and neither a statistical failure nor an exclusion is recorded. Source
reversal confirms that no bound or statistic formula changed. Its exact parent
partition retains 2,493 exclusions, five unresolved rectangles and nine pending
boxes. The same independent checker still qualifies every later exclusion.

**October 5: targeted left-profile continuation.** Four actual remaining
rectangles are limited principally by sample 6. The central, small-a1,
low-a2 and high-a1 references use slopes (89/1000,217,1000/19313),
(91/5000,386,2500/17563), (26/125,60,25/312) and
(43/100,1054,50/22661). Their independently checked global uppers are
-267.8609357354191, -294.2870557141686, -271.36029103758716 and
-337.1470529424191, respectively. The same finite-superlevel-box,
outward-gradient and exact coordinate-dual arguments apply; optimizer success
is not required or substituted for those checks. Their outward -10.5
witnesses give inward-extension slopes 1.79522192, 4.27531387, 5.50539580
and 8.18862755.

The first high-a1 center produces a valid but uninformative global upper
344.666901, with supporting-plane correction 681.816638. At that center,
the auxiliary adaptive integral differs from the independent enclosed value
by 1.4227e-5 and its scaled gradient by 0.0240051. Adding the mode and
slope-scaled offsets to its integration breakpoints reduces those differences
to 3.98e-13 and 6.33e-10. Both original and modified tighter-tolerance trials
retain their explicit unresolved integration status. A private proposal
copy, with an exact source-reversal check, refines the same center; fresh
outward enclosure gives the useful upper above, including correction
0.002663465. The original failed-usefulness evidence remains in
`left-gap-high-a1/`; the qualified result is in `left-gap-high-a1-refined/`.
Canonical helpers, original JML fits, response data and statistical rules
remain unchanged. This repair qualifies an auxiliary proposal followed by
independent bounds, not a general claim about floating integration accuracy.

Across the captured 525 unresolved rectangles, 361 profile bounds improve,
but only fifty improve enough to contribute to exclusion. Four exact children
give that same scheduling result for seven additional parents. Independent
complete 22-term checks for the central and high-a1 targets give
3.6548414323759635e-9 and 7.533431542088503e-25, with 2,997 raw checks each.
The remaining duplicate standalone checks are superseded by the unchanged
full-sum gate and independent replay on the actual worker output; their
unfinished rows are not treated as exclusions. Evidence is in
`normal-rescale/left-gap-coverage/` and the two new left profile tables.

The v25 transition preserves 1,947 terminal v23 exclusions, 468 unresolved
rectangles and eight old pending boxes. It requeues the 57 affected parents
as 78 leaves, with the 21 added splits verified by the exact partition check.
Numerical/replay source bytes are unchanged. Each new exclusion still needs
the entire 22-term bound with denominator 50 and independent actual-output
replay. The left ray, useful whole-set topology and independent coverage
remain unfinished.
All 224 new terminal v23 exclusions subsequently pass independent full-sum
replay, reusing the first 22 unchanged entries. The v25 actual decisions are
checked separately under their added profile-source bindings.
The first 90 actual v25 exclusions subsequently pass that independent
22-term replay. Exact rectangle matching includes all 78 requeued leaves,
closing the 57 selected parents. The 468 retained unresolved rectangles and
the remaining pending domain are still open; neither the whole left ray nor
the confidence set is complete.

**October 5: remaining left slope gaps.** Three actual unresolved rectangles
still have inadequate pointwise profile bounds, so subdivision alone cannot
close them. New sample-6 references at slopes (7/25,25,1/7),
(37/100,163,100/6031) and (1/100,685,20/137) have independently checked global
uppers -284.87909214639666, -302.23367967343006 and -304.0616467258196.
Their outward witnesses give inward-extension slopes 9.52432427,
6.81983302 and 4.48873425. All three use the already checked private
integration proposal followed by fresh outward enclosures and independent
natural-logit/coordinate-dual checks; canonical helpers are unchanged.

For the first rectangle, reusing only the earlier forest banks leaves other
reference terms too loose. Seven retained exact dual witnesses reduce the
other 21 terms to 0.004430831107445845 without new witness optimization.
The three complete 22-term MC uppers are **0.004430831108452122**,
**1.5686356891936723e-9** and **7.14247285308123e-21**, each with 2,997 raw
forest checks, the first also rechecking those seven exact dual witnesses.
Evidence is in `normal-rescale/left-next-gap-coverage/` and
`normal-rescale/left-next-gap-profile-checks.json`.

Of 468 retained rectangles, 144 bounds improve; 42 can contribute directly to
exclusion, and four covering children suffice for ten further parents. The
v26 transition retains all 2,098 terminal v25 exclusions, 416 unresolved
rectangles and eleven old pending boxes. The 52 selected parents become 82
leaves, with thirty added splits verified by the exact partition check.
Actual full-sum decisions and replay still follow; no whole-ray, set-topology
or independent-coverage completion is claimed.
All 151 new terminal v25 exclusions subsequently pass independent replay,
reusing the first 90 unchanged entries. The new v26 output is checked separately.
The first 85 actual v26 exclusions now pass that separate full-numerator
replay. Exact rectangle matching includes all 82 selected leaves and thus
the 52 revisited parents. The 416 retained unresolved rectangles and pending
domain still prevent completion of the left ray and the whole confidence set.

**October 5: remaining left-region coverage.** Six further sample-6 profiles
target actual pointwise gaps in the retained 416 rectangles. Their global
upper bounds pass the existing independent natural-logit, coordinate-dual and
outward-integration checks. The private mode-bracket proposal supplies finite
centers; optimizer status does not establish an upper bound. Canonical helpers,
original JML fits, reference data and the statistical rule remain unchanged.

| Reference slopes | Global fixed-slope log-likelihood upper |
| --- | ---: |
| (11/125, 45, 25/99) | -291.23474405081726 |
| (4/125, 141, 125/564) | -298.0453377719816 |
| (107/250, 60, 25/642) | -298.1494249932369 |
| (157/1000, 290, 100/4553) | -278.338828051757 |
| (107/250, 334, 125/17869) | -321.19317743050425 |
| (17/125, 1054, 125/17918) | -293.58131838865376 |

The six outward witnesses and normal-rescaling checks are retained in
`normal-rescale/left-frontier-profile-checks.json`. Across the captured
partition, 191 bounds improve and 71 rectangles can contribute directly to
exclusion. Four-child covers add thirteen parents. For the remaining
four-child failures, screening corner bounds and subdividing only failing
children adds four more complete covers; this uses existing profiles without
new fitting. These are scheduling checks, not full-MC exclusion decisions.

The exact v27 partition transition preserves all 2,227 terminal v26 exclusions,
328 unresolved rectangles and nine old pending boxes. It requeues the 88
selected parents as 157 leaves, with 69 additional splits verified by the
exact rectangle sweep. The numerical and replay source bytes are unchanged;
the profile collection grows from thirteen to nineteen. All actual new
decisions still require the complete 22-term bound with denominator 50 and
independent replay. Evidence is in `normal-rescale/left-frontier-coverage/`
and `normal-rescale/left-frontier-queue-transition/`. Whole-ray completion,
useful set topology and independent coverage remain open.
All 129 terminal v26 exclusions subsequently pass independent full-numerator
replay, reusing the first 85 unchanged entries.
The first 158 actual v27 exclusions also pass independent full-numerator
replay. Exact rectangle matching confirms that these include all 157 leaves
and thus all 88 selected parents. The 328 retained unresolved rectangles and
remaining pending domain are still open.

**October 5: three remaining left interior gaps.** The actual unresolved
rectangles around slopes (37/1000,445,200/3293), (59/500,60,25/177) and
(287/5000,1054,2500/151249) still have inadequate pointwise profile bounds.
Their new independently verified global uppers are -276.8417197157378,
-272.6855284943744 and -285.2935589731884. The existing finite-superlevel,
coordinate-dual, integration and normal-rescaling methods are unchanged.
The outward-witness extension slopes are 1.01431928, 6.14225557 and
0.14464198. Evidence is in `normal-rescale/left-interior-profile-checks.json`.

Of 328 captured unresolved rectangles, 74 bounds improve and 29 become
eligible for another full-sum decision. Four-child covers add nine parents;
further subdivision of the actual remaining child failures adds seven.
The v29 transition retains 2,417 terminal v27 exclusions, 283 unresolved
rectangles and eight old pending boxes, requeuing 45 parents as 126 leaves.
The exact partition sweep verifies the 81 additional splits. Source and replay
bytes are unchanged, and the profile collection contains 22 entries. All
190 terminal v27 exclusions pass independent replay, reusing the first 158.
The first 127 actual v29 decisions pass independent full-numerator replay.
Exact rectangle matching includes all 126 selected leaves and all 45 parents.
The 283 retained unresolved rectangles and pending domain still prevent
completion of the left ray and whole set.

**October 5: two new right slope neighborhoods.** New sample-6 profiles at
(9/100000,3600,250/81) and (109/250000,163,250000/17767) target actual
remaining rectangles. The first proposal's floating integration cannot meet
its requested 1e-10 tolerance at the initial point. A separate 1e-9 auxiliary
proposal reaches a finite center; unchanged outward value/gradient enclosure
and independent global-upper checks govern adoption. This does not relax a
statistical decision or a certified-bound tolerance.

At that center, the original independent scalar integral differs from the
enclosed likelihood by -1.16459066. Adding the retained certified-mesh
breakpoints to the same adjacent-odds scalar integral reduces the difference
to 2.84e-13. Its formula, domain and tolerances are unchanged, with an exact
source-reversal check. The original disagreement is retained. The half-unit
inward feasible point is genuinely below the boundary upper, so it cannot
establish the ray. A one-hundredth-unit feasible displacement passes instead;
both witnesses are retained. No additional original JML fit, response sample
or repeated global enclosure is used for these repairs.

The independent global uppers are -465.9318128306885 and -442.84100295601417,
with inward ray slopes -29.98900421 and -4.17475273. Their one-hundredth-unit
outward witnesses give extension slopes -35.18894842 and -61.03675635.
The second profile reuses the checked scalar-mesh calculation. Canonical
helpers are unchanged; the two separate right-frontier profile tables retain
the full source bindings and the earlier failed or uninformative attempts.

Both profiles improve all 21 captured unresolved bounds, but only nine
rectangles become eligible for another full-sum decision. Further subdivision
does not add a complete covering parent. The exact v30 transition preserves
2,558 terminal v28 exclusions, twelve unresolved rectangles and eight old
pending boxes, requeuing the nine selected leaves. It retains v28's explicit
auxiliary-proposal failure handling and unchanged independent checker. Actual
complete 30-term decisions, their replay, the remaining ray domain and useful
whole-set topology are still required.
All 65 terminal v28 exclusions subsequently pass independent full-numerator
replay under the explicit auxiliary-proposal failure handling. This does not
verify the later v30 decisions, which use the two additional profile tables.

**October 5: actual right auxiliary failures and retained-bound reuse.**
The terminal v30 output adds 43 exclusions, all independently replayed,
including six of its nine selected leaves. The other three leaves remain
unresolved despite negligible sample-6 contributions: their local replicate-20
auxiliary fits raise a nonfinite trust-step error. Replacing the floating
Hessian subtraction by the algebraically identical centered covariance does
not resolve these failures. Both attempts remain recorded.

Reusing the closest retained replicate-20 joint-MAP point as the initial value
resolves all three proposals with the original objective, optimizer and
tolerances. Exact reconstruction checks positive category probabilities,
unit sums, all nine nuisance balances and the normal-score bound. The checked
replicate-20 log-weight uppers on the three actual rectangles are -117.59,
-117.90 and -118.14. These are auxiliary witnesses, not new original JML fits
or full-numerator decisions. The original failed cache entries are retained;
qualified witnesses have separate filenames and source/seed bindings in
`right-dual-warm-start/`.

The v31 partition retains all 2,601 terminal v30 exclusions, twelve unresolved
rectangles and ten old pending boxes, requeuing only those three leaves.
Main and replay source bytes are unchanged. Its actual complete 30-term
decisions now pass independent replay for the first five new exclusions,
including exact matches to all three repaired target rectangles. Twelve
retained unresolved rectangles and the pending domain still prevent whole-ray
completion. On the left, two closer
outward feasible witnesses sharpen existing profiles without refitting;
further selective subdivision reuses prior child bounds. These scheduling
checks do not certify new exclusions or complete the confidence set.

The left retained-bound refinement is now complete. Two nearer outward
witnesses improve the extension slopes of existing profiles from 8.1886 and
8.0948 to 6.7249 and 6.6266 without new profile optimization. Of the actual
283 unresolved rectangles, two are directly eligible; selective four-child
and deeper covers add six and one. Further subdivision of 44 actual failures
reuses their previously checked children, refining only failing children.
It stops a parent when a pointwise bound cannot support subdivision, or when
all covering leaves pass the component budget. Thirty-four parents obtain
complete covers; this makes no full-numerator exclusion by itself.

After removing duplicate parents and choosing their smallest verified covers,
the v32 transition revisits 37 parents as 662 leaves. The exact partition
check preserves all 2,584 terminal v29 exclusions, 246 unresolved rectangles
and six old pending boxes, with 625 added splits. Scheduling reuses the saved
source/input-bound component uppers instead of recomputing them. Main and
replay source bytes are unchanged; the two outward-witness entries are added
to the retained profile collection. All 167 terminal v29 exclusions pass
independent full-numerator replay, reusing the first 127 unchanged entries.
Actual v32 full-sum decisions and replay remain separate. Evidence is in
`normal-rescale/left-near-coverage/`, `left-retained-refinement/` and
`left-retained-queue-transition/`.

**October 5: the remaining captured right component gaps.** The twelve
retained right rectangles still have insufficient sample-6 bounds. A new
fixed-slope profile at (1/6250,122,3125/61) has independently verified global
upper -457.638781920621, with supporting-plane correction 1.228628e-6.
Its inward 9.999 chord gives ray slope -3.62119426; the outward 10.001
chord gives extension slope -61.20210858. It makes eleven rectangles eligible
for another full-numerator decision. The twelfth has center log-weight upper
1.76791, above log(2.5), so subdividing that bound cannot settle it.

A second profile targets that actual rectangle at
(39/500000,163,500000/6357). The auxiliary optimizer stops with precision
loss; its finite center is preserved. The global supporting-plane upper
-467.7868283388302 includes correction 0.00323977 and passes independent
natural-logit, exact coordinate-dual and scalar-integral checks. The observed
curvature loss and chord gap in the preceding profile justify a smaller
feasible displacement of 1/4000 and four subdivisions of its retained mesh
for the chord lower only. The inequality, integration tolerances and global
upper method are unchanged. The inward lower -467.7853904910958 passes the
ray condition; the outward lower -467.8015730062602 gives extension slope
-58.97866972. This does not convert optimizer status into statistical success.

Both normal-rescaling tables are immutable. Their combined checked bounds
make all twelve captured rectangles eligible. Existing warm-start witnesses
also bound the five actual earlier replicate-20 proposal failures strongly,
without additional optimization. The v33 transition reuses these component
checks for scheduling and preserves all 2,656 terminal v31 exclusions and ten
old pending boxes. It requeues the twelve selected leaves, so its pending
count is 22; no new exclusion is made by the transition. Numerical main and
replay source bytes are unchanged. Actual complete 30-term decisions,
independent replay, the remaining domain and whole-set evaluation still
follow. Evidence is in `right-remaining-small-a1/`, `right-remaining-edge-a1/`,
their two normal-rescaling tables and `normal-rescale/right-remaining-edge-*`.
All 55 terminal v31 exclusions subsequently pass independent full-numerator
replay, reusing the first five unchanged entries. The new v33 decisions use
the two additional profile tables and require their own replay.

The first v33 replay now independently verifies 26 new full-numerator
exclusions, with exact rectangle matches to all twelve selected leaves.
The first v32 replay verifies 448 of its 662 selected leaves, completing
28 of the 37 selected parent covers. Both replay snapshots and logs are
retained in their respective epoch directories. Further pending and unresolved
regions remain; these counts do not complete either ray or the whole set.
All 662 selected v32 leaves subsequently pass the actual full-numerator gate,
with exact rectangle matching. Incremental replay now independently verifies
681 new exclusions, including all 662 selected leaves and all 37 complete
parent covers. It reuses the first 448 unchanged checks. Later pending and
unresolved regions still prevent completion of the ray.

Four actual left pointwise gaps in the remaining 246 rectangles have existing
center log-weight uppers 33.58, 25.43, 35.09 and 26.64, all above log(2.5).
They justify four targeted auxiliary profiles; subdivision of those old
pointwise bounds cannot settle the corresponding centers. The first, at
slopes (431/10000,188,2500/20257), has independently checked global upper
-278.2649044049445, supporting-plane correction 0.000251789 and left-ray
slope 3.34009419. Its finite precision-loss center is retained. The other
three profiles also pass the unchanged global-upper, integration, constraint
and ray checks:

| Reference slopes | Global log-likelihood upper | Left-ray slope | Inward extension slope |
| --- | ---: | ---: | ---: |
| (431/10000,188,2500/20257) | -278.2649044049445 | 3.34009419 | 3.70212225 |
| (157/1000,122,500/9577) | -268.6898147897131 | 2.72772578 | 3.34795016 |
| (153/2000,445,400/13617) | -274.5801913784384 | 0.56901841 | 0.82368379 |
| (321/1000,168/5,625/6741) | -283.2072670365110 | 6.07311003 | 8.32786948 |

The combined component check reuses all 246 existing source/input-bound
old uppers, evaluating only the four new profiles. Eighty-three rectangles
improve and 31 become eligible for another full-numerator decision. Four-child
checks of the 52 improved but ineligible rectangles add five complete parent
covers. Reusing those child bounds, adaptive subdivision of the 39 remaining
parents with nonempty child records adds eleven covers. It first checks the
corners and then subdivides only failing children, stopping a parent at an
actual pointwise-bound obstruction. No fitting or exclusion occurs in these
scheduling checks. The immutable table is
`normal-rescale/left-pointwise-profile-checks.json`.
The selection-only snapshot in `normal-rescale/left-pointwise-gaps-coverage/`
is not a partition checkpoint and cannot serve as a queue-transition parent.

The v34 transition instead uses the frozen complete v32 parent. It preserves
all 3,274 exclusions, 199 unresolved rectangles and eight old pending boxes,
requeuing 47 parents as 148 leaves with 101 additional splits. The exact
partition check passes. All 690 terminal v32 exclusions pass independent
replay, reusing the first 681; main and replay source bytes are unchanged.
The v34 profile collection has 28 entries. All 148 selected leaves pass the
actual full-numerator gate. Its first independent replay verifies 154 new
exclusions, including all 148 leaves and all 47 selected parent covers. The
remaining unresolved and pending domain still prevents completion of the ray/set.

On the right, nine actual new unresolved rectangles have existing pointwise
log-weight uppers between 10.07 and 63.84. A profile at
(9/10000,69,10000/621), initialized from the retained nearby profile, passes
global-upper and independent checks with upper -433.8694584535354 and
supporting-plane correction 2.499552e-7. Its inward 9.999 witness gives ray
slope -21.19279543; the outward 10.001 witness gives extension slope
-43.81825884. The existing proposal, integration and exact-bound methods
are unchanged. The new checked whole-box log-weight uppers are all below
-21.71, so all nine captured rectangles become eligible for full-sum decisions.

The right transition preserves 2,748 terminal v33 exclusions and ten old
pending boxes, requeuing only the nine selected leaves. Its pending count is
19, and it retains no previously unresolved rectangles; this does not mean
that the remaining domain is solved. Evidence is in `right-pointwise-low-a2/`
and `normal-rescale/right-pointwise-low-a2-*`. All 92 terminal v33 new exclusions
pass independent replay. The v35 continuation copies the unchanged main and
checker sources and uses eleven profiles. All nine selected leaves pass the
actual full-numerator gate. Its first independent replay verifies 14 new
exclusions, including all nine selected leaves. Later pending regions can still
produce new unresolved boxes.

**October 5: remaining left scale-selection checks.** A captured set of 225
actual v34 unresolved rectangles supplies two bounded investigations before
commissioning further auxiliary profiles. Aligning the floating candidate
selector with the existing exact large-temperature factor reuses 199 old
whole-box bounds and evaluates the 26 newly encountered boxes. Two additional
exact candidates yield one strict improvement and no newly eligible rectangle.
Allowing additional rational scales between the existing minimum and one,
including scalar-factor breakpoints, reuses all 225 bounds; 224 independently
enclosed candidates yield 223 strict improvements but again no newly eligible
rectangle. These are candidate searches, not global-optimality proofs.

The existing mathematical enclosure and independent checker are unchanged.
Neither investigation changes the running v34 source, profile collection,
failure rule or partition. No full-numerator exclusion follows from these
component checks. Evidence is in
`normal-rescale/left-scale-choice-review-20261005/` and
`normal-rescale/left-continuous-scale-review-20261005/`. Further work must
distinguish actual pointwise gaps from box-width loss, reusing these checked
bounds rather than repeating the complete search.

The v34 worker subsequently stops at an auxiliary optimizer's nonfinite trust
step (`array must not contain infs or NaNs`). Its last complete checkpoint
preserves 3,624 exclusions, 225 unresolved rectangles and seven pending boxes;
the interrupted box remains pending. All 350 new terminal exclusions now pass
independent full-numerator replay, including the earlier 154 checks. The exact
terminal partition is preserved.

The v36 continuation adopts only the six-line exception disposition already
qualified in the right worker: this exact numerical error records an unavailable
auxiliary witness, with `StatisticalFailure=False` and
`ExclusionCertified=False`; other ValueErrors propagate. Its numerical bounds,
28 profiles, estimator, data and statistical failure policy are unchanged.
It resumes the seven pending boxes from the immutable v34 checkpoint and retains
all 225 unresolved rectangles. The v34 failure log, terminal replay and v36
continuation check are preserved in their epoch directories. This recovery
does not close the left ray or the complete confidence set.

The next left-side check reuses 816 distinct saved point bounds and 1,910
saved rectangle bounds after verifying their source/input bindings. Of the
225 captured unresolved rectangles, ten have passing bounds at all four
corners and their center. Targeted subdivision supplies one complete
22-leaf component cover; the other nine encounters stop at actual interior
points where the existing upper is insufficient. This distinguishes box-width
loss from gaps that subdivision of the current bound cannot settle. No
full-numerator decision follows from a component cover. Evidence is in
`normal-rescale/left-reused-bound-audit-20261005/` and
`normal-rescale/left-reused-bound-refinement-20261005/`.

Three subsequent actual v36 unresolved regions have replicate-16 auxiliary
nonfinite trust-step failures. Reusing the nearest saved valid replicate-16
joint-MAP solution changes only the auxiliary starting vector. The original
objective, optimizer, tolerances and exact feasibility reconstruction are
unchanged. All three new witnesses pass the exact reconstruction, with
component log-weight uppers below -101 on their respective rectangles.
The original failures are immutable; the qualified witnesses are installed
under distinct names for a future continuation. The v36 bank was not
reloaded, and the complete numerator and independent replay remain
required. Evidence is in `left-dual-warm-start/`. Neither this auxiliary
repair nor the component refinement changes the original JML estimator or
the statistical failure policy.

The largest of the nine measured interior obstructions motivates a profile
at slopes (189/10000,615,2000/23247). At that rounded reference, the existing
pointwise log-weight upper is 4.8954, above log(2.5). The finite precision-loss
candidate supplies global upper -287.47721385760923 after an outward
supporting-plane correction of .000418224. Independent adjacent-odds
integration and exact coordinate bounds pass. The inward lower gives left-ray
slope 1.76773863; the outward lower -288.4608012663207 gives inward-extension
slope 1.96717482. These checks qualify the upper independently of the
optimizer's convergence flag.

Reusing all 225 previous checked rectangle bounds, the new profile improves
15 and makes eight eligible for a complete-numerator decision. Selective
refinement of the other seven adds four two-leaf covers; it reuses thirteen
cached bounds and stops the other three at actual pointwise obstructions.
The earlier 22-leaf parent cover and three warm-start cases remain valid.
Evidence is in `left-reused-interior-gap/`, its normal-rescaling table and
`normal-rescale/left-reused-interior-gap-{coverage,refinement}/`.

All 98 terminal v36 exclusions pass independent full-numerator replay. The
v37 transition preserves all 3,722 exclusions, 212 unresolved rectangles and
eight old pending boxes, requeuing only the sixteen selected parents as
41 leaves. The exact partition passes. Main/checker source bytes are unchanged;
the profile collection has 29 entries. The transition makes no exclusions:
actual full-numerator decisions, replay, the remaining domain and complete
useful confidence-set evaluation still follow.

The first v37 replay now independently verifies 44 actual full-numerator
exclusions, including exact matches to all 41 selected leaves and all sixteen
complete parent covers. Later exclusions and the remaining unresolved/pending
domain require their own checks; this does not complete the left ray or set.

On the right, the same retained-start repair qualifies three actual
replicate-49 auxiliary failures, with component log-weight uppers below -130
on their respective rectangles. Original failures are preserved, and the new
witnesses are installed under distinct names; the active v35 bank is not
reloaded. Later unresolved boxes and other auxiliary failures remain explicit.
Evidence is in `right-49-dual-warm-start/`. This does not qualify new
full-numerator exclusions or change the statistical failure policy.

Four later right unresolved rectangles have eleven further exact-center
auxiliary failures. Trying up to three nearby retained feasible witnesses per
affected reference term supplies eight sufficient component bounds without
fitting. The remaining three are all reference sample 18; their retained
component log-weight uppers are 3.00--3.33. Using its saved nearby joint-MAP
solution as the auxiliary start qualifies all three, with exact reconstructed
log-weight uppers below -126. The original failures remain immutable and the
new witnesses have distinct bank filenames. Evidence is in
`right-retained-dual-reuse-20261005/` and `right-18-dual-warm-start/`.
Together with the three sample-49 repairs, these support selective requeueing
of the seven captured right unresolved rectangles. The v35 bank was
not reloaded; no new complete-numerator exclusion or right-ray
completion is claimed from these component checks.

All 221 terminal v35 new exclusions subsequently pass independent
full-numerator replay, reusing the first fourteen completed checks. The v38
transition preserves all 2,969 exclusions and nine old pending boxes,
requeuing exactly the seven auxiliary-failure rectangles. Its initial queue
has sixteen pending boxes and no retained unresolved rectangles; this is a
queue change, not right-ray completion. The exact partition check passes.
Main/checker bytes and all eleven profiles are unchanged. Actual full-sum
decisions and their replay remain required.

The first v38 independent replay verifies 72 new full-numerator exclusions,
including exact matches to all seven selectively requeued rectangles. Later
unresolved/pending regions remain explicit; this does not complete the ray.

The next left profile addresses a measured pointwise obstruction at slopes
(111/10000,360,250/999), where the retained collection's log-weight upper is
7.9814. Reusing the nearby finite candidate gives global upper
-319.3735132245398 after a supporting-plane correction of .000127890260063.
Independent adjacent-odds integration and exact coordinate checks pass. The
inward witness gives ray slope 7.428145884; the outward lower
-323.5977290401872 gives inward-extension slope 8.448431631294742. The
optimizer's finite precision-loss status is preserved.

For 218 actual unresolved rectangles, the impact check reuses 212 previous
bounds and evaluates the six newly encountered rectangles. Eleven improve;
nine become eligible for complete-numerator decisions. The other two stop at
actual pointwise obstructions after four bound evaluations, giving no further
covers. Evidence is in `left-reused-low-product-gap/` and its
`normal-rescale/left-reused-low-product-gap-*` checks.

The six new rectangles have exact-center sample-29 auxiliary nonfinite
failures. Retained feasible same-sample witnesses suffice for all six after
exact reconstruction, with component log-weight uppers below -93. No new fit
is needed, and the original failures remain unchanged. Evidence is in
`left-29-retained-dual-reuse-20261005/`. These component checks support a
selective fifteen-parent requeue; they are not complete-numerator exclusions.

All 164 terminal v37 new exclusions now pass independent replay, reusing the
first 44 checks. Its final checkpoint retains 3,886 total exclusions, 218
unresolved rectangles and nine pending boxes. The v39 transition passes the
exact partition check and requeues only the fifteen supported rectangles,
adding the thirtieth checked profile. Its continuation has 24 pending boxes
and retains 203 unresolved rectangles. Original estimator, failure policy and main/checker bytes are
unchanged. Actual complete-numerator decisions and their replay still follow.

The first v39 independent replay now verifies 29 new complete-numerator
exclusions, including exact matches to all fifteen selectively requeued
rectangles. Later exclusions and the remaining unresolved/pending domain
remain separate; neither the left ray nor the useful whole set is complete.

Later right-side failures are handled by their actual cause. Fifteen sample-6
`exact_projection_not_positive` records are resolved by retained feasible
witnesses alone, with whole-box component log-weight uppers below -63.45.
Four sample-6 nonfinite trust-step failures are not settled by the three
nearest retained witnesses: their best log-weight uppers remain 6.57--16.47.
Using the saved nearby sample-6 joint-MAP solution as the auxiliary starting
vector qualifies all four, with exact reconstructed uppers below -104.47.
The objective, optimizer and tolerance controls are unchanged. The original
failures remain immutable and the new witnesses have distinct bank names.
These witnesses subsequently settle ten further actual failure rectangles
without another optimization. Evidence is in
`right-06-{retained-dual-reuse-20261005,nonfinite-dual-reuse-20261005,dual-warm-start,later-dual-reuse-20261005}/`.

All 190 terminal v38 new exclusions pass independent replay, reusing the first
72 checks. A controlled interruption occurred while writing the temporary
checkpoint; the atomic destination retains the complete valid partition with
3,159 exclusions, thirty unresolved and nine pending boxes. The v40 transition
passes the exact partition check and requeues the 29 supported rectangles,
retaining one unresolved and 38 pending boxes. Main/checker source and eleven
profiles are unchanged. These are checked component repairs and a continuation;
actual complete-numerator decisions and their replay still follow.

The first v40 independent replay verifies 59 complete-numerator exclusions,
including exact matches to all 29 selected rectangles. Its remaining actual
sample-6 auxiliary failure is resolved by a retained feasible witness, with
whole-box component log-weight upper -106.9043 and no new optimization.
Evidence is in `right-06-v40-dual-reuse-20261005/`; requeueing and a new
complete-numerator decision remain necessary.

The next left profile uses slopes (91/5000,217,5000/19747), at a measured
pointwise obstruction with old log-weight upper 3.01718. Its finite
precision-loss candidate has log likelihood -312.1988953724742. The checked
supporting-plane correction .00014938054 gives global upper
-312.1987459919353. Independent adjacent-odds integration, exact coordinate
bounds and outward/inward ray witnesses pass; optimizer status is unchanged.
Evidence is in `left-reused-mid-a2-gap/` and its normal-rescaling table.

The impact check reuses 203 previously checked rectangle bounds and evaluates
four newly encountered ones. Exactly three bounds improve, all becoming
eligible for complete-numerator decisions; no refinement of unchanged bounds
is needed. Five later actual sample-32 nonfinite auxiliary failures are
resolved by retained feasible witnesses, with log-weight uppers below -97.51.
The initial reuse script incorrectly retained the right-ray sign filter and
stopped before producing any component proof. Correcting only that filter and
its assertion to require Contrast times AffineUpperSlope < 0 admits the
left-ray witnesses; the initial script/log and original failures are retained.
Evidence is in `left-32-retained-dual-reuse-20261005/`.

All 132 terminal v39 exclusions pass independent replay, reusing the first
29 checks. The v41 transition preserves 4,018 exclusions, 200 unresolved
rectangles and eight old pending boxes; only the eight supported parents are
requeued. Its exact partition passes, main/checker bytes are unchanged, and
the profile collection has 31 entries. Actual full-sum decisions and their
replay still follow. Neither exterior ray nor the useful whole set is complete.

All 68 terminal v40 exclusions subsequently pass independent replay, reusing
the first 59 checks. The v42 transition preserves 3,227 exclusions and seven
old pending boxes, requeuing only the remaining sample-6 failure rectangle.
The exact partition passes; main/checker bytes and eleven profiles are
unchanged. Its zero retained unresolved rectangles do not imply ray completion:
eight pending rectangles still require decisions and replay.

The first v41 and v42 replays independently verify 65 and 21 new exclusions,
including exact matches to all eight and one selected rectangles, respectively.
The next left profile uses slopes (61/25000,1620,1250/4941), selected from an
actual high-second-slope obstruction. Its precision-loss candidate has enclosed
log likelihood -341.4262866603733 and supporting correction 5.058155550792009,
giving global upper -336.3681311095814. A half-unit inward chord is insufficient;
that failed check is preserved. The same retained vector at a one-unit inward
point gives independently checked lower -334.3061412053317 and a valid left-ray
bound. No further optimization or changed numerical tolerance is used.
Evidence is in `left-reused-high-a2-gap/` and its normal-rescaling table.

Reusing all 200 old rectangle bounds, this profile improves thirteen and makes
six eligible for full-sum decisions. Selective refinement of the other seven
stops at actual pointwise obstructions, yielding no additional eligible parents.
Five actual sample-6 exact-projection failures are separately resolved with
retained feasible witnesses and no optimization; their component log-weight
uppers are below -36.56. Original failures remain in place. All 108 terminal
v41 exclusions pass incremental independent replay. The v43 transition passes
the exact partition check, retains 4,126 exclusions and 194 unresolved boxes,
and requeues only the eleven supported parents alongside seven old pending
boxes. Main/checker bytes and statistical rules are unchanged; the profile
collection now has 32 entries. Actual exclusions and their replay still follow;
neither exterior ray nor the useful confidence set is complete.

The first v43 replay subsequently verifies seventeen new exclusions, including
all eleven selected parents. The next candidate uses slopes (1/200,913,200/913)
at a measured pointwise log-weight gap of 30.6817. Its optimizer reports
precision loss with scaled score 4.62e-8; the independent adjacent-odds value
is -325.88166888366425. The enclosed supporting correction 2.98214385654e-6
gives global upper -325.88166590152025. Independent inward-chord and
normal-rescaling witnesses pass. Evidence is in
`left-reused-next-obstruction/` and its normal-rescaling table.

Its impact check reuses all 194 old bounds and makes seventeen parents
directly eligible. The only other improved parent receives a complete
seventeen-leaf component cover after sixteen splits and 66 new bound checks;
there are no further improved-but-unsettled parents in that impact snapshot.
This supports eighteen parents as 34 leaves for a subsequent full-numerator
decision, not immediate exclusion. This thirty-third qualified profile and
the following profile are subsequently adopted together; the completed v43
worker retains its original 32-profile identity.

The additional measured gap uses slopes (181/1000,126/5,2500/11403). The
precision-loss candidate has scaled score 1.06e-8. Independent adjacent-odds
integration gives -288.2435990049517; the enclosed supporting correction
3.73461761133e-6 yields global upper -288.243595270334. The inward-chord lower
-283.75071817165053 and normal-rescaling witnesses pass independently.
Evidence is in `left-reused-residual-obstruction/` and its normal-rescaling
table. Reusing all 194 old bounds, its impact check improves nine rectangles
and makes two more directly eligible. Refinement of the other seven supplies
three two-leaf covers, using 60 new bound evaluations and six cached bounds;
four stop at actual pointwise obstructions.

All 62 terminal v43 new exclusions pass independent replay, reusing the first
seventeen checks. The combined v45 transition passes the exact partition check
and requeues only 23 supported parents as 42 leaves alongside eleven old
pending boxes. It retains all 4,188 exclusions and 171 unresolved rectangles.
The 34-profile collection is bound to the unchanged main/checker source.
No original estimator, statistical failure rule or dataset changes. New
complete-numerator decisions, their independent replay and the useful whole
confidence set remain unfinished.

The first v45 replay verifies 71 new exclusions, including all 42 selected
leaves from those 23 parents. All 100 terminal v45 exclusions subsequently pass
incremental replay. The next actual residual obstruction, selected from the
largest retained whole-box gaps, has slopes (157/1000,514,500/40349). Its finite
candidate reports precision loss (scaled score 5.90e-7), so qualification uses
the independent enclosure: global upper -286.41213669670674, supporting
correction 9.75293028858e-5, adjacent-odds value -286.4122342260097 and
inward-chord lower -285.4773054721963. The normal-ray witnesses also pass.
Reusing all 171 prior bounds, this one profile directly supports fifteen
parents; selective refinement supplies three more complete covers with thirteen
leaves. Four improved parents retain actual pointwise bound obstructions.

Six newly encountered v45 auxiliary nonfinite trust-step failures, all in
reference sample 6, separately admit retained feasible witnesses without any
new optimization. Their checked whole-box log-weight uppers range from
-101.09 to -70.42. The v47 transition combines these six repairs with the
eighteen profile-supported parents, requeuing 24 parents as 34 leaves. It keeps
all 4,288 exclusions, all five old pending boxes and 153 other unresolved
rectangles. The exact partition check passes, with unchanged main/checker bytes
and 35 qualified profiles. This is continuation of the unchanged full22-term
gate, not a completed confidence set or a new statistical failure convention.
Evidence is in `left-reused-v45-obstruction/`, its normal-rescaling coverage
and refinement records, `left-06-v45-dual-reuse-20261005/` and the v47 transition.

All 222 terminal right-v42 new exclusions pass incremental independent replay,
reusing the first 21 checks. Three newly encountered sample-35 auxiliary
failures admit retained feasible witnesses without optimization. The fourth
failure is in sample 28: three retained witnesses remain insufficient (best
whole-box log-weight upper +9.47117), so one warm-start auxiliary optimization
is necessary. Only its start vector changes; the objective, trust-exact method,
gradient tolerance and iteration limit remain fixed. Exact feasibility and
negative-curvature reconstruction qualify the resulting upper -127.29960.
The original failed record and initial selection/preparation guard refusals
are preserved. The installed certificate is byte-identical to the checked
record. The v46 transition keeps all 3,449 exclusions and nine old pending
boxes, requeues exactly four supported parents and passes the partition check.
Its eleven profiles and main/checker bytes are unchanged. Actual full30-term
decisions and replay remain required; no statistical failure rule changes.
Evidence is in `right-35-v42-dual-reuse-20261005/`,
`right-28-v42-dual-reuse-20261005/` and `right-28-dual-warm-start/`.
The first actual v46 replay now verifies eleven new full-numerator exclusions;
all four repaired parent rectangles match its checked boxes exactly. Later
new decisions and the remaining pending domain still require continuation.

All 34 selected v47 leaves (24 parents, including the six retained-witness
repairs) occur in its first 38 independently verified exclusions. All 46
terminal new exclusions subsequently pass incremental replay. Two further
qualified profiles address remaining pointwise obstructions without changing
the original JML fits or response bank:

| Profile slopes | Certified global upper | Supporting correction | Independently checked inward lower |
| --- | --- | --- | --- |
| (181/1000,194/5,2500/17557) | -275.8590093068152 | .000998486415329 | -272.63385841113205 |
| (241/1000,398/5,2500/47959) | -275.20657012270976 | .000006088579437 | -273.3329727988364 |

Their finite optimizer candidates report precision loss; the bounds and
normal-rescaling witnesses supply the independent qualification. Both impact
checks reuse all 153 prior whole-box bounds. The first supplies five direct
parents and two refined covers (five/four leaves); one improved parent stops
at a pointwise obstruction. The second adds six direct parents and three
refined covers (three/three/25 leaves); four improved parents retain pointwise
obstructions. An initial refinement launch stops at its old profile-count
guard before any bound calculation; the original script/log are preserved,
and the verified collection count is corrected before execution.

The combined v49 transition keeps all 4,334 exclusions and eleven pending
boxes, requeues sixteen supported parents as 51 leaves, and retains 137
unresolved rectangles. Its partition passes with 37 profiles and unchanged
main/checker bytes. Actual full-numerator decisions and independent replay
remain necessary; neither exterior ray nor the useful confidence set is done.
Evidence is in `left-reused-v47-obstruction/`, `left-reused-v47-residual/`,
their normal-rescaling checks and `left-v47-combined-profile-queue-transition/`.

All 51 selected v49 leaves occur in its first 106 independently verified
exclusions; all 155 terminal exclusions subsequently pass incremental replay.
The next two profiles, at (287/5000,689/10,50000/197743) and
(181/1000,163,1000/29503), have independently certified global uppers
-294.98247989139907 and -274.26549389355296. Their outward feasible lower
witnesses are -299.45854842270796 and -275.8860240117059, giving inward
extension slopes 8.952137062617796 and 3.241060236305889. Each impact check
reuses all 137 preceding whole-box bounds. Together they support eleven direct
parents and four refined parents with 23 leaves. The combined v51 transition
keeps 4,489 exclusions and eight old pending boxes, requeues those fifteen
parents as 34 leaves, and retains 126 unresolved rectangles. Its partition
passes with 39 profiles; actual full22-term decisions and independent replay
remain required. The SIGINT that stopped v49 interrupted a temporary checkpoint
write; the last atomic destination, its full partition and terminal replay
remain valid, and the unfinished temporary file is not used.

The isolated v51 source also adds optional reuse of exactly reconstructed
witnesses, without changing the mathematical bound functions or independent
checker. `exact-witness-cache-qualification/` binds the source edit, three
deterministic active records, source/input/runtime keys, cold/warm comparisons
of every exact field/array and fresh-process reads with reconstruction disabled.
A changed certificate fails the original exact-balance check; a corrupted
cache payload is refused before decoding. These disposable local files do
not replace certificate verification or independent reconstruction in replay.
The first production startup reports three hits, 1,352 misses, 176.22 seconds
in cache/reconstruction calls and 207.48 seconds for setup. This is a mostly
cold startup, not a measured whole-run speedup. Evidence is in the two
`left-reused-v49-*` folders, their normal-rescaling records and
`left-v49-combined-profile-queue-transition/`. The useful set and independent
statistical confirmation remain open.

The first actual v51 replay verifies 39 new exclusions and matches all 34
selected leaves exactly. The unchanged checker reconstructs the witnesses
independently of the new startup cache. On the right, the second incremental
v46 replay verifies 134 new exclusions; later decisions remain live.

All 119 terminal v51 new exclusions pass incremental replay. A qualified
profile at (287/5000,251,5000/72037) supplies six direct parents and four
refined covers with 25 leaves, reusing 122 old bounds and calculating the four
newly needed ones. Its global upper is -270.4849527161692. The next profile at
(75,63/50000,2000/189) has global upper -461.81661000101036, but initially fails
the ray check: the conventional inward half-unit coordinate shift has actual
log likelihood -1447.14926 and cannot qualify monotonicity. The original
failed witness/check remain preserved. Ten finite feasible proposals, without
optimization, identify psi=-9.98 with unchanged nuisance values. Independent
adjacent-odds integration agrees, and the chord lower -461.4606813131354
exceeds the global upper, giving a checked ray slope 17.796434393746903.
The outward psi=-10.02 chord lower is -462.6927813306911, giving the normal
extension slope 43.80856648403683. No chord-mesh refinement beyond the original
376 segments is needed. An initial helper-signature error occurs before this
lower integration and is preserved separately.

This forty-first profile supplies the four newly uncovered parents directly;
their checked single-term log-weight uppers fall from about 221.2 to -32.71,
-74.01, -121.74 and -174.44. The combined v53 transition preserves 4,608
exclusions and eleven old pending boxes, requeues fourteen parents as 35 leaves,
and retains 123 unresolved rectangles. Its exact partition passes, with
unchanged mathematical bound functions and checker. Startup observes 1,355
exact-witness cache hits and thirty misses: 16.54 seconds in that stage and
47.16 seconds overall. The first v53 replay verifies 56 new full-numerator
exclusions, including every one of the 35 selected leaves. Later decisions
still require incremental replay; useful-set completion and independent
confirmation remain required. Evidence is in
`left-reused-v51-obstruction/`, `left-reused-v51-residual/`, their normal-rescaling
records and `left-v51-combined-profile-queue-transition/`.

The next two remaining-region profiles use slopes (51/500,141,500/7191)
and (75,87/250000,10000/261). Their global fixed-slope uppers are
-266.2289180509225 and -473.01553684925636. The latter's original half-unit
inward witness fails and is retained; a contrast change of 1/200 with unchanged
nuisance coordinates instead has independently enclosed lower
-472.9884471574993. Its outward lower is -473.2968792890944. Neither profile
requires treating optimizer precision loss as convergence.
The combined component bounds cover eighteen unresolved parents as 25 leaves.
Terminal v53 replay verifies all 120 new exclusions, preserving 4,728 total.
The v55 transition checks the exact partition, retains 105 unresolved and
eleven old pending regions, and resumes with both qualified profiles. Its
first replay verifies nineteen new full-numerator exclusions, including fifteen
of the 25 selected leaves. The other ten actually remain unresolved: their
sample-6 component is covered, but other numerator terms encounter nonfinite
auxiliary trust steps. They are not counted as exclusions.
For those actual failures, 25 same-sample auxiliary witnesses are reconstructed
using the nearest retained feasible MAP vector as the start. Only that start
changes; objective, solver, tolerances and the original JML statistic are
unchanged. Every first attempt passes exact rational feasibility, and its
whole-box log-weight upper is at most -104.93. Original failed records remain.
Terminal v55 replay verifies all 38 new exclusions (4,766 total); v57 preserves
that partition, requeues just the ten affected boxes and retains 105 unresolved
and eight old pending regions. All ten requeued regions subsequently pass
the complete 22-term decision and independent replay. The other 105 unresolved
regions and the pending search remain; neither exterior ray nor the complete
confidence set is declared finished. The additional repair evidence is in
`left-v55-auxiliary-warm/`, including the exact source-change and installation
records.
Evidence is in `left-reused-v53-obstruction/`, `left-reused-v53-residual/`
and `normal-rescale/left-v53-combined-profile-queue-transition/`.

Two further fixed-slope profiles at (107/250,194/5,625/10379) and
(107/250,919/10,2500/98333) have independently checked global uppers
-295.0074663638299 and -303.2022061584075. Reusing the 105 old component
bounds, they make seven additional complete boxes eligible for a full-numerator
attempt. Refinement of the one remaining improved parent stops at an actual
pointwise gap. Terminal v57 replay checks all 105 new exclusions (4,871 total).
The v59 transition retains those exclusions, 98 unresolved regions and nine
old pending regions; it requeues only the seven eligible boxes with unchanged
mathematical source, checker and statistical rule. These component certificates
and the transition are not themselves full-numerator exclusions. Subsequently,
all seven requeued boxes pass the complete decision and independent replay;
the first v59 replay verifies eleven new exclusions in total. Later search
output subsequently passes terminal incremental replay: all 122 new exclusions
are verified, preserving 4,993 total. Two further qualified profiles
at (497/10000,593,10000/294721) and (51/500,290,50/1479) have global uppers
-277.49643304858756 and -271.4450388439265. Their component bounds reuse the
98 old region checks and identify eleven eligible parents as thirteen leaves.
The checked v61 transition retains all exclusions, 87 unresolved regions and
ten old pending boxes, adding only those thirteen leaves. The 47-profile
collection changes neither mathematical source nor the decision/checking rule.
Actual new decisions and their independent replay still follow; both complete
rays, useful endpoints and independent confirmation remain required.

All thirteen selected v61 leaves subsequently pass the complete decision and
independent replay. The terminal replay checks all 34 new exclusions, preserving
5,027 total. Two further qualified profiles at (883/10000,593,10000/523619)
and (17/125,689/10,1250/11713) have global uppers -279.4773036757259 and
-268.7169014671281. Reusing the 87 prior region bounds gives fifteen eligible
parents as 25 leaves; one additional refinement stops at an actual pointwise
bound obstruction. The checked v63 transition retains all exclusions, 72
unresolved regions and eleven old pending boxes, adding only those 25 leaves.
Its 49 profiles retain the original statistical rule. New actual decisions,
their replay and the complete useful set remain outstanding.

All 25 selected v63 leaves subsequently pass the complete decision and
independent replay; terminal replay verifies all 46 new exclusions, preserving
5,073 total. A fiftieth profile targets the saved failed refinement point,
after five proposed rounded centers are found already covered by existing
bounds. Its independently checked global upper is -267.16755395837527,
with supporting-plane correction 0.0000048976. Reusing all 72 prior bounds
makes five parents eligible as seventeen leaves. The checked v65 transition
preserves every exclusion, 67 unresolved parents and nine old pending boxes.
It changes neither the numerical bound formulas nor the full-numerator rule.
All seventeen selected v65 leaves subsequently pass the full decision and
independent replay. Terminal replay verifies all 27 new exclusions, retaining
5,100 total. The additional reuse audit examines all 67 retained parents with
the same fifty-profile collection: improvement of a whole-parent upper is not
necessary for improvement at one of its points or children. It reuses 234
checked evaluations and performs 1,684 new bound evaluations, with no fit,
finding twelve complete component covers as 136 leaves. The other 55 parents
retain actual failed point bounds. The v67 continuation requeues those twelve
covers with the unchanged profile collection, full decision and checker;
its actual leaf decisions still require replay. The largest remaining saved
point bound identifies the next single profile calculation. Complete rays,
useful endpoints and independent confirmation remain outstanding. Evidence is in
`left-reused-v63-obstruction/`, `normal-rescale/left-v63-profile-queue-transition/`
and `normal-rescale/left-v65-retained-refinement/`, with the checked continuation
in `normal-rescale/left-v65-retained-queue-transition/`.
The initial v67 launcher stops before starting its worker because its log name
already exists. `slope-cover-observed-01-v67/prepared-resumption.json` verifies
the unchanged prepared arguments and source hashes before starting them with
the distinct v67 log; the original failure and launcher remain preserved.

All 136 selected v67 leaves subsequently pass the complete decision and
independent replay. Terminal replay verifies all 158 new exclusions, preserving
5,258 total. The next actual retained point initially fails the inward-witness
check: its numerical optimizer reports precision loss, and the supporting-plane
correction is 38.2943. That failed attempt remains in `left-v65-retained-point/`.
Refining its center on the saved integration mesh reproduces all nine interval
scores, passes a higher-order check, and reduces the correction to .0000014188.
The independently checked global upper is -295.60472415270067, with positive
left-ray slope 1.60623. Its unchanged outward/ray checks pass in
`left-v65-retained-point-refined/`.

The full 55-parent update reuses 1,012 existing evaluations and evaluates only
the new profile at 370 cached points/children. It completes three parent
component covers and preserves 52 actual failed point bounds. The v69
transition retains every exclusion and nine old pending boxes, adding only
those three parents with the 51-profile collection. New actual decisions
and replay still follow. The reusable fixed-mesh proposal calculation also
matches retained likelihood/score enclosures at three differing slope
conditions (largest scaled score discrepancy 1.29e-9). It is a numerical
proposal tool, not a replacement for the global upper or ray checks; those
remain mandatory for each new center. Qualification is in
`fixed-mesh-proposal-qualification/`. Complete rays, useful endpoints and
independent confirmation remain open.

The next retained failed point uses that proposal evaluator and passes on its
first mesh: rebuilding the mesh at the returned center and using order 64
changes the likelihood by less than displayed double precision and the scaled
score by 4.56e-13. Its independent outward upper is -297.2309283200341, with
supporting-plane correction .0000001890 and left-ray slope 10.34383.
The full 52-parent update reuses 1,009 evaluations and adds 376 bound
evaluations, producing three further complete parent component covers.
All three selected v69 decisions pass independent replay; terminal replay
checks all ten new exclusions, retaining 5,268 total. The v71 continuation
adds the 52nd profile and requeues the three newly covered parents, preserving
the remaining partition and original decision rule. Evidence is in
`left-v69-retained-point/`, its `normal-rescale/` coverage/refinement records,
and `normal-rescale/left-v69-profile-queue-transition/`. All six selected child
rectangles subsequently pass the unchanged full-numerator decision and
independent replay. The stopped v71 partition retains 5,274 exclusions,
49 unresolved parents and eleven pending regions.

The next actual failed point, retained in `left-v71-retained-point/`, also
passes fresh-mesh/order-64 review and the independent global/ray checks.
Its numerical optimizer reports precision loss with scaled score 1.03e-8;
that flag is preserved. The enclosed supporting correction 3.6564861e-6
gives global upper -277.1305251417391, below the independently enclosed
inward likelihood -274.3634672479898. Thus numerical success is not used
as a substitute for qualification. Updating the 49 retained parents reuses
every previous parent bound and 1,001 child/point bounds, adds 387 evaluations
(366 using only the new profile), and gives five complete component covers
with twelve leaves. Actual exclusions still require the complete numerator
and independent replay; neither complete ray nor the useful full set is
finished, and independent confirmation has not begun.

All twelve selected v73 leaves subsequently pass the full numerator and
independent replay. Two further actual failed points use the same proposal
and independent qualification pipeline, with global uppers
-289.2856354743101 and -282.031385160015. Their supporting corrections are
2.8640713e-6 and .0002788672; both pass their independently integrated inward
witnesses. Evidence is in `left-v73-retained-point/` and `left-v73-residual/`.
The first update covers four of the 44 retained parents. The second reuses
those valid bounds and gives nine combined parent covers with eleven leaves,
without reevaluating the previous 54 profiles at cached points. These two
profiles are carried together to v75 after independent replay of all fourteen
terminal v73 exclusions. The verified transition retains 5,288 exclusions,
35 unresolved parents and twelve old pending regions, and requeues the eleven
newly covered leaves. The original data, statistics, thresholds and
full-numerator replay requirement are unchanged.

All eleven selected v75 leaves subsequently pass independent full-numerator
replay. Three further retained points are qualified in
`left-v75-retained-point/`, `left-v75-residual/` and `left-v75-next-point/`.
Their global uppers are -281.58947550607655, -278.3133692058997 and
-274.4735868401104; supporting corrections are 2.3334827e-5,
.0007683100 and 3.2240649e-6. Each retains the optimizer precision-loss flag
and passes fresh-mesh/order-64, outward enclosure and independent inward-ray
checks. The three updates progressively cover three, six and nine of the
35 retained parents, ultimately with nine leaves. All 138, 82 and 72 new
bound evaluations use only the newly added profile; previous valid bounds
remain available. All thirty terminal v75 exclusions pass independent replay,
retaining 5,318 total. The v77 transition adds these three profiles together,
preserves 26 unresolved parents and ten old pending regions, and requeues
the nine newly covered leaves. This is progress on the same sample/contrast
inversion, not completion of a ray or independent sampling qualification.

All nine requeued v77 leaves pass the complete numerator and independent
replay. Two further profiles (`left-v77-retained-point/` and
`left-v77-residual/`) have certified global uppers -286.3116825229251 and
-292.3874304678949, with supporting corrections .0005320158 and 7.0122252e-7.
Fresh-mesh/order-64, outward enclosure and independent ray checks pass; the
first retains its optimizer precision-loss flag. Reusing previous point and
box bounds, 71 and 66 new single-profile evaluations cover four and then five
of the 26 retained parents, each with one leaf. All 42 terminal v77 exclusions
pass independent replay, retaining 5,360 total. The v79 transition preserves
21 unresolved parents and eight old pending regions and requeues those five
leaves. Actual exclusions still require the unchanged full-numerator check.
Both rays, useful complete-set evaluation and independent confirmation remain
open; the right v46 search has also encountered one newly unresolved region.

The five selected v79 leaves subsequently pass full-numerator replay. Two
additional profiles in `left-v79-retained-point/` and `left-v79-residual/`
have global uppers -277.9760226133075 and -469.8206393102065. Their supporting
corrections are 2.0490316e-5 and 6.5635788e-5. The second retains the failed
unshifted .02 inward witness; a checked half-unit contrast change accompanied
by a one-sixth change in the third Criterion location gives inward lower
-454.87524211845584. This preserves the relative locations of the two
high-loading owners. Both original numerical precision-loss flags remain.
Incremental audits cover four then five of the 21 retained parents, with
five then six leaves, using 69 and 60 new bounds and retaining earlier valid
bounds. All 49 terminal v79 exclusions pass independent replay, retaining
5,409 total. The v81 transition preserves sixteen unresolved parents and
eleven old pending regions, requeuing the six newly covered leaves. All six
subsequently pass the complete numerator gate and independent replay. The
first v81 replay checks 21 new exclusions and retains all 5,409 prior ones;
sixteen unresolved parents and pending regions remain. After validating and
persisting the transition, its launcher releases the expanded historical
partition before starting the child; the statistical calculation is unchanged.

The sixty-third profile, `left-v81-retained-point/`, has global upper
-275.7014678925952 with supporting correction 1.5023422e-5. The numerical
precision-loss flag remains, despite a fresh-mesh/order-64 likelihood
difference of 5.68434e-14. The initial balanced inward witness fails
(-292.41695795774393); its record and source remain. Here owner 2 dominates,
so a half-unit increase in contrast with a half-unit decrease in the third
Criterion location preserves that owner's location. The independently
checked inward lower is -274.763537237905; the opposite outward witness
gives -276.75693340535804. The resulting ray and extension slopes are
1.8758613093804426 and 2.1109310255256744. No optimizer or gradient enclosure
is repeated for this repair. Incremental refinement uses 53 new one-profile
bounds and reuses 160 bounds, covering two of the sixteen retained parents.
All forty terminal v81 exclusions pass independent replay, retaining 5,449
total. The v83 transition retains fourteen unresolved parents and eleven
old pending regions, adding these two leaves to the unchanged full-numerator
queue. Whole-ray and useful complete-interval qualification remain open.

`left-v81-residual/` adds the sixty-fourth profile at a point still in the
fourteen-parent residual partition. Its dominant owner-2 location is
preserved in both half-unit witness proposals. Independent checks give
global upper -279.1411667691344 (supporting correction 3.1344262e-6), inward
lower -276.8848874651697 and outward lower -282.2928328930301. The ray and
extension slopes are 4.512558607929434 and 6.30333224779139. The original
precision-loss flag remains; the fresh-mesh/order-64 likelihood difference
is zero and scaled-gradient discrepancy 4.40536e-13. Incremental refinement
uses 45 new one-profile bounds and reuses 138 bounds. It covers three of the
captured sixteen parents, including the two already requeued under v83:
only one additional current parent is covered. Its subsequent adoption by
the complete numerator queue is recorded below.

Both selected v83 leaves subsequently pass the complete numerator and
independent first replay (six new exclusions). The sixty-fifth profile in
`left-v83-retained-point/` adds a checked global upper -332.2007710527373,
with supporting correction .00071252017. Its half-unit, owner-2-preserving
inward and outward witnesses give -329.82951328182344 and
-336.57322208991957; the ray and extension slopes are 4.742515541827708 and
8.744902074364575. The optimizer precision-loss flag is retained; fresh-mesh
order-64 likelihood agrees and scaled-gradient discrepancy is 2.96154e-11.
Incremental refinement uses 38 new one-profile bounds and reuses 121 bounds.
Four captured parents are covered, of which two are already excluded under
v83; profiles 64/65 together cover two additional actual parents.
All seventeen terminal v83 exclusions are independently replayed, retaining
5,466 total. The v85 transition adds both qualified profiles and requeues
the two new leaves, retaining twelve unresolved parents and eleven old
pending regions. Both selected leaves subsequently pass the complete
numerator and independent first replay (ten new exclusions plus all 5,466
prior ones). No whole-ray or complete confidence-set claim follows.

The sixty-sixth profile, `left-v85-retained-point/`, targets an actual
remaining point where the retained 65-profile bound fails. Its checked global
upper is -306.0903184238715 (supporting correction 6.8515773e-7); owner-2-
preserving inward/outward witnesses give -301.74560150583596 and
-311.13326098340366, with ray/extension slopes 8.689433836071096 and
10.085885119064338. Fresh-mesh/order-64 likelihood difference is 5.68434e-14
and scaled-gradient discrepancy 1.27898e-12. The optimizer succeeds with
scaled score 6.45559e-9, but the conclusion rests on the independent bounds.
Incremental refinement checks only 37 new component bounds and reuses 116;
one of the twelve actual retained parents passes, with log-weight upper
-15.37425. Its complete-numerator decision is still required.

The sixty-seventh profile, `left-v85-residual/`, uses the next actual
point obstruction after retaining all 66 earlier profiles. Its independently
checked global upper is -307.3460922884963 (correction 6.0879168e-6).
Owner-2-preserving inward/outward witnesses give -305.9692532595358 and
-309.25273919095014, with ray/extension slopes 2.7536780579210904 and
3.8132938049076746. The optimizer succeeds; fresh-mesh/order-64 likelihood
and scaled-gradient discrepancies are 5.68434e-14 and 1.82240e-10.
The incremental audit uses 36 new component bounds and reuses 111. Three
of twelve retained parents pass, including the one already covered by the
sixty-sixth profile. All 41 terminal v85 exclusions independently replay,
retaining 5,507 total, with the saved stop/checkpoint SHA unchanged.
The v87 transition adopts both qualified profiles, requeues the three selected
leaves and preserves nine unresolved parents plus eleven old pending regions.
All three selected leaves subsequently pass the complete 22-term numerator
and independent first replay, which checks six new exclusions and retains
all 5,507 preceding exclusions. Nine unresolved parents and pending regions
remain; no whole-ray or useful complete-confidence-set conclusion follows.

The sixty-eighth profile, `left-v87-retained-point/`, has independently
checked global upper -268.0430431775574, supporting correction 2.2063432e-6,
and owner-2-preserving inward/outward lower bounds -266.7680895573228 and
-269.48585092336106. Its ray/extension slopes are 2.549907240469199 and
2.8856154916072296. The optimizer succeeds; fresh-mesh/order-64 likelihood
agrees, and scaled-gradient discrepancy is 9.91918e-12. Ten new component
bounds and 35 reused bounds cover three of the nine actual retained parents.

The sixty-ninth profile, `left-v87-residual/`, addresses the next retained
point and adds global upper -294.9605985610256, correction .00030447927,
and inward/outward lower bounds -293.7746577082437 and
-296.55347389536496. Ray/extension slopes are 2.371881705563803 and
3.185750668678677. Its optimizer precision-loss flag remains; fresh-mesh/
order-64 likelihood agrees, and scaled-gradient discrepancy is 4.66684e-11.
Seven new component bounds and 28 reused bounds cover eight of nine parents,
including the three already covered by profile 68. Complete-numerator
adoption and independent replay remain required; the last component-bound
obstruction is retained rather than declared excluded.

The seventieth profile, `left-v87-second-residual/`, targets the last
remaining component-bound obstruction, whose saved log-weight upper was
.99201819. Its independently checked global upper is -266.88980258343673,
with supporting correction 4.2716360e-5. Owner-2-preserving inward/outward
witnesses give -265.23845067802085 and -268.76464425477104; ray/extension
slopes are 3.302703810831747 and 3.7496833426685843. The original optimizer
precision-loss flag remains; fresh-mesh/order-64 likelihood agrees and
scaled-gradient discrepancy is 5.16920e-12. The last parent now has component
log-weight upper -14.35576. All nine retained parents pass the component
audit; refinement reuses all nine parent bounds without new evaluations.
All 33 terminal v87 exclusions independently replay, preserving 5,540 total,
and the stop/checkpoint SHA agrees. The v89 transition adds all three
qualified profiles (68--70), requeues all nine selected parents, and retains
nine old pending regions, for eighteen pending regions and no deferred
unresolved parent at launch. All nine selected parents subsequently pass the
actual complete 22-term numerator and independent first replay; the largest
selected upper is .044327552464666214. The replay preserves all 5,540 prior
exclusions. Old pending regions still need processing, so this queue state
is not a complete ray or confidence set.
Incremental independent replay now checks 366 v89 exclusions, reusing the
previous 277 proofs and preserving 5,906 total exclusions. The sixth snapshot
hash, full checked-box set, recorded uppers and verifier-source hashes agree.
Nine pending regions remain at that snapshot, with no deferred unresolved
region. Earlier snapshots/logs remain retained; the whole left ray is open.

Two subsequently unresolved rectangles have sample-6 corner bounds above
budget even after reusing every available dual with the required sign.
Two targeted exact-corner duals cover this component on five children per
parent, preserving both exact partitions. Fresh 80-digit reconstruction checks
all ten leaf uppers and both new witnesses, including 324 raw balance/score
cases. The first auxiliary optimizer's failure flag remains. No marginal
profile or original JML estimate is recomputed. This component refinement in
`normal-rescale/left-v89-initial-gaps/targeted-dual-refinement/` is then adopted
through a source-bound transition. All 491 terminal v89 exclusions pass
independent replay, preserving 6,031 total. The v91 successor requeues the ten
children, preserves three other unresolved and thirteen pending regions, and
uses the previously qualified exact forest implementation. All ten children
pass the actual 22-term gate and independent replay; twelve new exclusions are
checked in that first snapshot. The checker retains the original forest upper.
New unresolved records also retain the already computed approximate term
bounds for diagnosis, without changing inference. The full left ray remains open.

At the next nine captured unresolved rectangles, 830 retained sample-6 duals
cover one parent on two children without a new fit. Fresh 80-digit raw replay
checks both leaves and preserves all nine parent partitions. The eight other
pointwise dual obstructions remain explicit; existing marginal profiles give
sharper point bounds at two of them, so a dual-only failure is not a reason to
add a profile automatically. All 68 terminal v91 exclusions pass replay,
preserving 6,099 total. The byte-identical v93 successor replaces only the
covered parent, retaining twelve other unresolved regions and sixteen old
pending regions. Both children pass the complete 22-term gate and independent
replay, with largest recorded upper .04458406. This closes that parent, not
the entire ray. Evidence is in `normal-rescale/left-v91-first-gaps/` and
`normal-rescale/left-v91-dual-queue-transition/`.

At the two remaining parents where profile point bounds were stronger than
retained duals, combining the existing methods still exposes a shared point
obstruction. One exact auxiliary dual resolves the first parent on twenty
children; its optimizer failure flag is preserved. A second auxiliary dual
does not resolve the other parent. Before adding a marginal profile, a retained
forest bound at the actual remaining point gives log weight -2.7274, where
the dual and profile bounds were 1.1277 and 3.9379. Reusing that forest covers
the second parent on two children without another fit or integral. Fresh
80-digit replay checks the first twenty children, both new dual points and
six independently bracketed profile scalar bounds (432 raw dual checks); a
separate replay verifies both remaining children using the original forest.
These are component bounds, not complete-numerator exclusions.

All 74 terminal v93 exclusions pass incremental replay, preserving 6,173 total.
The byte-identical v95 successor retains thirty-two other unresolved and eleven
old pending regions, replacing only these two parents with the twenty-two
verified children. It adopts the first parent's exact auxiliary witness and
keeps all seventy profiles. All twenty-two selected children now pass the
complete 22-term gate and independent replay. The largest selected upper is
.04773541; the first snapshot checks twenty-four new exclusions and preserves
all 6,173 prior exclusions. Both selected parents are resolved. Other pending
and unresolved regions remain. Evidence is in
`normal-rescale/left-v93-shared-point-refinement/`,
`left-v93-second-point-refinement/`, `left-v93-retained-forest-refinement/` and
`left-v93-combined-bound-queue-transition/`. The whole left ray and confidence
set remain open.

The v95 queue then ends normally with no pending region and thirty-two
unresolved regions. All 56 new exclusions pass incremental independent replay,
preserving 6,229 total. A retained-bound pass on the twenty-nine parents whose
saved diagnostics identify sample 6 as the main obstruction covers ten parents
on one hundred children. It adds no fit or integral, reuses the existing
profiles/duals/forest, and stops at an explicit point obstruction or work limit.
Fresh replay checks all twenty-nine partitions, the hundred covered leaves,
1,512 raw dual identities and forty-four original-forest bounds. The v97
successor retains twenty-two other unresolved parents. All one hundred selected
children now pass the complete numerator and independent terminal replay,
preserving 6,329 total exclusions. Its queue ends normally with twenty-two
unresolved regions and no pending region. These ten parents are resolved;
the whole ray remains open.

The nineteen component failures contain thirteen distinct obstruction points.
A full retained-dual selection review and eleven new exact-point auxiliaries
leave four points below the full single-term budget; all thirteen selected
retained bounds and eleven new witnesses pass fresh raw reconstruction.
Optimizer failures and the nine unresolved point bounds remain explicit.
Additional subdivision reuses saved component values and the new checked
witnesses, with a component budget of 2.4; other-term floating diagnostics only
select that budget, and the complete numerator remains required. Before a new
marginal profile, all seventy retained profiles including normal rescaling are
also evaluated at the nine remaining points. None has an exact reference there
or supplies a sufficient bound. One new profile therefore targets the exact
point shared by four still-unresolved parents, using the qualified fixed-mesh
procedure and a checked retained seed. Evidence is in the
`normal-rescale/left-v95-*` directories and `left-v95-shared-point/`; no original
JML statistic, data or failure rule changes.
The follow-up subdivision covers three of four selected parents on seventy-three
children; fresh replay checks 1,755 raw dual identities and eight original-forest
bounds. The fourth parent retains a new point obstruction. The new marginal
profile has global upper -296.63826853. Its first inward witness failed the ray
gate after shifting the high-slope third Criterion. Keeping the nine nuisance
coordinates fixed gives inward lower -294.69358337 and outward lower
-299.48710628; the existing global enclosure is reused. The failed witness/check
remain. The revised independent ray and normal-rescaling checks pass, and four
shared parent boxes pass independent classic-profile bounds without subdivision.
The v99 successor combines these four boxes with the seventy-three children,
preserves 6,329 exclusions and fifteen other unresolved parents, adopts only the
two new auxiliary witnesses used by those children, and appends the seventy-first
profile. All seventy-seven selected leaves now pass the complete twenty-two-term
gate and terminal independent replay. The queue ends naturally with 6,406
excluded rectangles and fifteen unresolved parents; every recorded upper and
exact selected box matches the fresh proof. The whole left ray remains open.

The seventy-first profile alone does not cover any of those fifteen whole
parents. Reusing the prior seventy-profile point review and checking only the
new profile leaves another actual shared point unresolved (log-weight upper
24.2962). A profile at that point, shared by two remaining parents, gives
global upper -283.44014302. The fixed-nuisance inward and outward lower
witnesses are -281.45317981 and -286.13976296; independent ray and normal
rescaling checks pass. The optimizer's precision-loss flag remains recorded,
and the fresh-mesh/order-64 numerical review passes. This profile supplies
component bounds for three whole remaining parents. Reusing the retained
profile/dual/forest evidence then covers ten of the fifteen parents on sixty-two
children at the component work budget of 2.4. Fresh replay checks all fifteen
partitions and the sixty-two covered children, including 567 raw dual checks,
24 independent scalar profile checks and 17 original-forest checks. The v101
successor preserves all 6,406 exclusions and the other five parents. All
sixty-two children pass the unchanged complete twenty-two-term gate and the
terminal independent replay, with exact box, recorded-upper, source and snapshot
matches. The queue ends naturally with 6,468 exclusions and five unresolved
parents; the whole left ray remains open.

The five incomplete partitions retain 159 successful component leaves and
their unresolved remainder. A retained-dual-only check of the other twenty-one
terms on two whole parents gives upper bounds too loose to justify increasing
the component work budget. This is a limitation of those bounds, not evidence
that the actual contribution is large. Retained forest choices reduce that
other-term upper to 9.6446 on the second whole parent, still insufficient for a
uniform budget; 2,085 raw balance checks pass. Neither the .05 gate nor the
denominator of fifty changes.

Checking retained normal-rescaling transfers resolves four of the five point
obstructions. Those four parent regions have thirteen covering children, checked
independently with nine normal-rescaling reconstructions and 108 raw dual checks.
The fifth parent's existing partition has 154 partial component successes and
twelve unresolved children. The v103 transition preserves this exact partition
and the four checked covers, placing all 179 children into the complete
twenty-two-term evaluation. It retains all 6,468 exclusions and all 72 profiles;
no new fitting, component-budget increase or exclusion is implied by the
transition. The v103 queue ends naturally with 176 of those children excluded
and three unresolved. All 176 pass terminal independent replay, including the
thirteen earlier normal-component leaves; exact selected-box accounting,
recorded uppers, snapshots and sources match. The retained total is 6,644.
Further subdivision of the three actual failures uses only the same retained
bounds and gives ten component-covered children. Fresh replay checks their
partitions, 54 raw dual identities, six normal-rescaling bounds and two original
forest bounds. The v105 successor then excludes all ten children through the
unchanged complete twenty-two-term gate and terminates naturally. Independent
terminal replay verifies all ten, with largest upper .04818246; the exact
selected-box set, recorded uppers, source hashes and terminal snapshot match.
All 6,644 prior exclusions are preserved, for 6,654 checked leaf rectangles,
with no pending or unresolved region. The exact partition and retained
exterior bounds therefore close the entire positive product-one slope domain
on (-infinity,-10] for ordinary GPCM-JML development sample 1. Evidence is in
`slope-cover-observed-01-v105/terminal-replay.json`.

Together with the completed right ray [10,infinity), this confines this
development confidence set to (-10,10), while the current continuously retained
component is [-3,5/8].
The completed rays also apply to other saved statistics when their inclusive
whole-ray reference union is a subset of the certified union: the proposal
weights are nonnegative, the nuisance model and proposal are identical, and
the denominator remains 50. The new
`jml-normal-ray-subset-reuse-20261006.py` checks all 150 ordinary/order-2/order-4
results using both exact affine squared-distance inequalities and independent
absolute-distance evaluation at every breakpoint and intervening interval.
The source-bound terminal certificates, completed partitions and input/proposal
identities are reused without refitting, integration or new slope searches.
This gives 30 right/21 left exclusions for ordinary JML, 21/4 for order 2,
and 22/4 for order 4. Only ordinary sample 1 has both of these rays excluded;
each corrected arm's one completed observed failure retains the whole line.
Failure of subset containment is undecided, not evidence of retention.
Evidence is in `profiles/complete-ray-subset-reuse-20261006/check.json`.
These 102 directional bounds reuse the same development bank and do not supply
independent coverage or complete the other confidence sets.
Endpoints, possible additional components, other ordinary/corrected-JML
procedures and independent confirmation remain open. Feasible-point screens
using the saved sample-38 and sample-6 witnesses do not extend retention to
5/8, 3/4 or 1; these failed lower-bound candidates are not exclusions.

A fixed-slope sample-38 location search at 1 still fails the single-term lower
gate (log weight -6.12973). A warm free-slope candidate improves that to -3.22605;
the next candidate at 3/4 gives -.20179. Both remain failures to establish
retention, without any exclusion implication. At 5/8 the same bounded-proposal
routine gives a feasible log weight 1.34358, with adaptive-versus-q241 discrepancy
8.53e-14. Exact rational product-one slopes and the same nuisance coordinates
work at both 1/2 and 5/8, requiring no additional endpoint optimization.
Outward chord integration gives log-weight lower bounds 2.76928 and 1.33159.
Fixed-slope log concavity and inclusive membership then retain the whole added
segment with p-value lower .07574119. Fresh replay checks 36 raw affine logit
coefficients, normalization, exact membership and the 80-digit lower-bound
reconstruction, preserving all previous endpoint proofs. Evidence is in
`retained-extension-20261006/right-fiveeighths-retention/`. This extends retained
width to 3.625 for the first development set; it does not locate an outer
endpoint, exclude additional components or qualify the other procedures.

The next inward-left run evaluates -13/2, the midpoint of -10 and -3. It
reuses all 6,654 old leaves as pending geometry, with zero inherited exclusions,
and the same twenty-two inclusive ray members. The previously qualified generic
inward producer and original-forest checker are copied byte for byte. Sixty-eight
retained normal-rescaling profiles and the separately checked rank-cut profile
are valid here; four older profiles without inward certificates stay inactive.
The run also reuses 1,649 exact dual witnesses, including the relevant checked
rank-cut witnesses, and recomputes their bounds at the new contrast. Its first
launcher was rejected by argument parsing before numerical execution; a separate
`slope-cover-observed-01-left-13over2-v2/` launch passes the identical rational
value as -6.5 and preserves the failed invocation. Complete-numerator decisions
and independent replay at this new contrast remain required.

Observation of the complete method identifies sample 6 as the limiting term
in the first two unresolved parents; their log-weight uppers are 11.56250 and
10.97356. Partial dual/profile diagnostics alone had misleadingly highlighted
other terms. Retained forests at the shared corner and a new exact auxiliary
dual remain too loose, so one marginal profile is evaluated directly at -13/2
and that corner. Its global fixed-slope upper is -262.04654116. The existing
independent checks verify 108 raw inequalities, eighteen exact nuisance-box
bounds and 174 integration dominance disks, with inward and outward witnesses.
Its checked normal transfers put the sample-6 contribution below the individual
budget on 184 of 193 captured unresolved parents. Those old left-worker rows
contain no stored term diagnostics. Independent full22-term reconstruction
using the recorded forest/dual choices now verifies the first two parents,
with p-value uppers .01657317 and .00787453. Each checks 2,847 raw forest
identities and 189 raw dual identities at 80-digit precision. Component bounds
alone do not exclude the other parents.
Evidence is in `left-13over2-native-profile/` and
`normal-rescale/left-13over2-native-profile-coverage/`; the earlier failed
auxiliary bound remains in `normal-rescale/left-13over2-initial-gaps/`.

All thirty-one terminal left-v2 exclusions pass independent replay, reusing
the first seventeen proofs and matching the full snapshot, boxes, recorded
uppers and verifier sources. Forty-four additional terminal unresolved parents
receive only the new component check, preserving the earlier 193 checks.
The exact v3 transition retains all thirty-one exclusions and 6,386 pending
parents, requeues 188 component-qualified parents with the two complete-bound
parents first, and preserves forty-nine other unresolved parents. Its producer
and original-forest checker are byte-identical to v2. The same twenty-two-term
gate decides actual exclusions; the whole inward ray and useful set remain open.
The first v3 replay verifies eight new actual exclusions, including both
prioritized parents, while preserving the thirty-one checked prefix. The two
independent replay bounds are .02222393 and .02881812; each satisfies the
unchanged .05 criterion. These checks match the captured snapshot, exact box
set, recorded decisions and verifier sources. Later decisions still require
their own incremental replay.
The completed selected-parent pass now independently verifies all 178 new
exclusions, reusing the first eight proofs. Exact box matching accounts for
all 188 requeued parents: 178 excluded and ten retained as unresolved, with
none still pending. The thirty-one earlier exclusions are unchanged. This
completes that selected revisit, not the remaining inward-ray domain.
The next incremental replay reuses those 178 checked entries and verifies
93 later decisions, for 271 checked new exclusions plus the thirty-one-entry
prefix. Exact snapshot, box, recorded-upper and source comparisons pass;
the original selected-parent proof remains unchanged. Evidence is in
`slope-cover-observed-01-left-13over2-v3/progress-replay-02.json`.
The following replay reuses those 271 proofs and checks 51 additional
decisions, for 322 independently checked exclusions after the thirty-one-entry
prefix. `progress-replay-03.json` retains its own captured state and unchanged
verifier sources. Exact box/recorded-upper matching and the .05 bound pass;
the remaining domain is still unresolved.
Subsequent incremental replays retain those proofs. The latest,
`progress-replay-06.json`, reuses 418 checked v3 entries and verifies 99 later
decisions, giving 517 plus the unchanged thirty-one-entry prefix: 548 checked
left-ray leaves. The new independent uppers range from .0000440861 to
.04906659. The original forest checker, all source bindings, captured state,
exact boxes and recorded uppers pass comparison; no fit or dataset is added.
Its snapshot retains 5,831 pending and 415 unresolved rectangles, so the
complete inward ray, confidence-set endpoint and topology remain open.

An inward re-expression of thirteen old right-ray profiles is algebraically
valid, but the active right-v4 source already applies their inward secants via
`normal-rescale/inward-finite-band-20261006/`. The re-expression supplies no
stronger mathematical bound, and its check on 79 captured unresolved parents
does not clear the component work budget. It is not adopted, does not trigger a
worker restart, and is not an additional interval result.

The new right-side profile is in `right-v46-retained-point-corrected/`.
Its original proposal evaluated contrast +10 but serialized -10; the ensuing
enclosure refused, and both the original source and failed record remain.
Reevaluation at the same saved center confirms the +10 value/gradient before
correcting the metadata. Its global upper is -476.4608153832581. A balanced
half-unit inward witness gives lower -460.3821759045266 and the independent
right-ray check passes; the failed original witness is retained. The actual
remaining box's sample-6 log-weight upper is -188.4204670684781. Older partial
forest/dual comparisons still fail their full-sum bound and are not exclusions.
The v48 queue retains all 4,168 terminal v46 exclusions, independently replayed,
and eleven old pending regions, requeuing this one box with the new profile.
It uses the unchanged full 30-term gate; a read-only observer records the actual
limiting terms if this selected box remains unresolved, then removes tracing.
The selected box subsequently passes the actual complete gate with upper
.018227513385340587, below .05. All nine first v48 exclusions pass independent
full-numerator replay, including this exact selected box. This closes the named
region with the original rule; pending regions and the complete right ray
remain open.

The v48 search subsequently encounters two actual unresolved rectangles.
Their centers already have sample-6 log-weight uppers -45.67085 and -8.87739
under the twelve retained profiles, so no new center fit is needed. An
independently reconstructed component audit covers the first whole box but
finds a corner of the second with upper log-weight 8.04515442. The thirteenth
profile in `right-v48-corner-point/` targets that measured corner. Its
evaluation and serialized metadata both use the verified contrast +10.
The global upper is -483.4327655500706, with supporting correction
3.9629052e-5; inward/outward witnesses give -467.5458716896752 and
-502.1619133461677. Their ray/extension slopes are -31.773787720790818 and
-37.45829559219418. Fresh-mesh/order-64 likelihood agrees, scaled-gradient
discrepancy is 3.83693e-13, and the original precision-loss flag remains.
Both boxes now pass the component budget, with log-weight uppers -91.55844
and -140.89078; their complete thirty-term decisions remain necessary.

All 112 terminal v48 exclusions pass independent replay, preserving 4,280
total. The v50 transition requeues the two boxes with the new profile and
retains nine old pending regions. It reuses the previously qualified exact
startup reconstruction cache: the old source matches the qualification's
original SHA and the successor matches its candidate SHA; mathematical
functions and the independent checker are unchanged. A read-only observer
records the actual limiting terms if either selected parent remains
unresolved, and disables tracing after both parents are classified. The
parent releases its expanded partition after persisting the audited
transition. These execution changes do not alter the inference rule.
Both selected v50 boxes pass the actual thirty-term gate, with uppers
.04934853580875889 and .036321666134810436. The worker subsequently terminates
naturally with complete coverage. Terminal independent replay verifies all
418 v50 exclusions, reusing its preceding 396 proofs and preserving all 4,280
inherited exclusions. The saved snapshot and terminal worker state have the
same SHA; the complete checked-box set, recorded uppers, verifier sources and
inherited transition/replay hashes agree. No pending or unresolved region
remains. The exact rectangle partition and retained exterior certificates
therefore cover the whole positive product-one slope domain on [10,infinity),
using the unchanged thirty-term numerator and denominator fifty. This closes
the right exterior ray for ordinary GPCM-JML development sample 1. It does
not locate the endpoint within (1/2,10), close the left side, or qualify the
other ordinary/corrected-JML procedures. Evidence is in
`slope-cover-observed-01-v50/right-profile-replay-terminal.json`; the earlier
incremental snapshots remain retained.

The next inward right-ray epoch uses contrast 21/4, the midpoint of 1/2 and
10. It preserves the terminal partition's 4,698 leaf rectangles as pending
geometry, inheriting no exclusions. All thirty inclusive ray members remain
the same. It reuses 1,337 unchanged feasible dual witnesses and thirteen
qualified marginal profiles, recomputing every upper at the new contrast;
the inward profile formula and exact forest reuse are active. Independent
replay checks the first three complete-numerator exclusions against the
original forest upper, their full recorded box set and all bound source
hashes. The largest checked upper is .000004760213. Processing continues;
the complete [21/4,infinity) ray and the endpoint are still open. Evidence is
in `slope-cover-observed-01-right-21over4-v1/`, including `geometry.json`,
`retained-duals.json`, `source-changes.json` and `first-replay.json`.
A separate observation of the unchanged complete-bound calculation identifies
sample 38 as the limiting term in the first two unresolved rectangles, with
approximate log-weight uppers 1.34196 and 1.51274. All auxiliary optimization is
disabled during that observation, and the live queue is unchanged. These are
diagnostics for targeted refinement, not exclusions; source-bound records are
in `normal-rescale/right-21over4-initial-gaps/full-method/`.
Reusing 96 available sample-38 dual witnesses covers that component on two
children per parent, without another fit. Fresh 80-digit raw replay verifies
all four leaves, with a component numerator budget of two and 108 balance/score
checks. All sixty terminal v1 exclusions then pass independent replay. The v2
successor preserves those exclusions, 61 other unresolved regions and 4,621
old pending regions while requeuing the four children. All four then pass the
complete thirty-term gate and independent replay, with largest upper .02742341.
The whole ray remains open. Evidence is in `retained-38-dual-refinement/` under
the same diagnosis directory and `right-21over4-v1-dual-queue-transition/`.

Two later rectangles expose terms 6, 38 and 20 as the main obstructions.
Retained duals and two exact-corner auxiliary duals cover these three terms
on 22 children of the first parent. Fresh 80-digit reconstruction checks all
22 children and both witnesses; the second parent remains unresolved. All
24 terminal v2 exclusions pass full replay, preserving 84 total. The v3
successor then excludes eighteen of those 22 children through the complete
thirty-term gate and independent replay. The other four remain pending.

At the second parent's observed corner, one new marginal profile is certified
directly at contrast 21/4, using a retained start and the qualified fixed-mesh
procedure. Its global upper is -300.38804528018954. The optimizer's precision-loss
flag is retained; the supporting-plane certificate uses the finite center and
verified gradient enclosure, without requiring optimizer success. The adjacent-odds
integral, exact nuisance-box inequalities and inward/outward witnesses pass
their existing checks. Across 99 retained unresolved rectangles this strengthens
the sample-6 component below its single-term budget on fourteen, but none passes
the stored full-term diagnostic solely from that change. It is not a whole-sum
exclusion. Combining the new profile with retained duals for terms 38, 20, 4 and
28 covers the second parent on three children. Fresh 80-digit replay checks
all three five-term bounds, including 324 raw dual identities and three
independent normal-profile transfers. The v4 successor adopts the new profile,
preserves 102 checked exclusions and the first parent's four pending children,
and requeues these three new children. All three and the first parent's four
remaining children now pass the complete thirty-term gate and independent
replay. Together with the eighteen checked v3 children, both named parent
regions are resolved; the largest selected v4 upper is .03366601. Its first
replay checks eight new exclusions while preserving the 102 checked prefix.
Evidence is in `right-21over4-native-profile/` and
`normal-rescale/right-21over4-v2-first-new-gaps/`; the full ray and confidence
set remain open.

Two later right-v4 gaps are limited by references 28 and 38. Retained and four
new point duals remain too loose; checking the existing forest method isolates
reference 28 at the first center. One native-contrast marginal profile now has
independently checked global upper -278.01895382. The optimizer's precision-loss
flag remains recorded; the certificate uses its finite center and verified
supporting plane. Combining that profile with recorded reference-38 forests
gives the second parent a two-term numerator upper .47513513, reproduced at
80 digits with 111 raw forest checks. The first parent remains unresolved.
Evidence is in `right-21over4-reference28-profile/` and
`normal-rescale/right-21over4-v4-first-new-gaps/`. The terminal v4 state retains
398 exclusions, including 296 new decisions that now all pass independent
replay. The v5 successor requeues only the two selected parents, retaining
every other pending and unresolved region. Both pass the complete thirty-term
gate and terminal independent replay, for 400 retained exclusions.

The remaining first parent's reference-38 corner still defeats the existing
forest and auxiliary-dual bounds. A native-contrast marginal profile at that
corner now has independently checked global upper -275.7463681459188, with
the optimizer's precision-loss flag preserved. Its finite-center supporting
plane, integration and inward/outward witnesses pass the existing checks.
Combined reference-28/38 transfers identify two additional unresolved parents
for complete-numerator evaluation. The exact v6 transition preserves all 400
checked exclusions, 4,371 prior pending regions and 273 other unresolved
regions, adds no splits, and requeues only these two parents. Producer and
independent checker are byte-identical to v5. Evidence is in
`right-21over4-reference38-profile/` and
`normal-rescale/right-21over4-v5-reference38-queue-transition/`. Both selected
parents subsequently pass the complete thirty-term gate and independent replay,
with upper values .00405076 and .02011773 under the unchanged .05 criterion.
The replay matches every recorded upper and box against its captured snapshot,
retains the 400-entry prefix and uses the original forest checker. This adds
two verified exclusions; the full ray, endpoints and confidence-set topology
remain open.
The subsequent incremental replay preserves those two proofs and verifies a
third exclusion, whose independent upper is .04922442. The 400-entry prefix
remains unchanged. `slope-cover-observed-01-right-21over4-v6/progress-replay-02.json`
records the captured snapshot and original checker/source bindings; pending
and unresolved regions still prevent a complete-ray decision.

The v6 epoch subsequently stops at a preserved checkpoint with twenty new
exclusions after the 400-entry prefix. Terminal independent replay verifies
all twenty, reusing the three earlier proofs. A saved unresolved rectangle
dominated by reference sample 12 motivates one additional fixed-slope profile
at (49/10,41/5000,50000/2009), contrast 21/4. Its finite-center proposal keeps
the optimizer's precision-loss flag; the higher-order/fresh-mesh value agrees
and the scaled score is 1.119e-7. Independent integration, coordinate bounds,
supporting-plane and inward/outward witness checks establish a global
fixed-slope upper of -282.371094514482, including the 9.16e-5 correction.
This certificate does not require relabelling the optimizer as successful.

Independent transfers of that profile over 327 captured unresolved rectangles
select four parents for the unchanged full thirty-term gate. The exact v7
transition preserves all 420 verified exclusions, 4,322 existing pending
rectangles and 324 other unresolved rectangles, and requeues only those four
parents without splitting. Producer and original-forest checker remain byte
identical. Evidence is in `right-21over4-reference12-profile/`, its
`normal-rescale/` profile/coverage/transition records, and
`slope-cover-observed-01-right-21over4-v7/`. The complete ray, endpoint and
confidence-set topology remain open; a transfer-based candidate is not itself
an exclusion.

All four selected v7 parents subsequently pass the unchanged thirty-term
gate and the original independent forest replay. Their recorded upper
values are .01549794, .01982329, .02834561 and .03895836, below .05; the
captured snapshot, source bindings and exact boxes agree. This preserves
the 420-entry verified prefix and adds four verified exclusions. The
remaining pending and unresolved rectangles still prevent a complete ray.

The terminal v7 replay subsequently checks ten new exclusions, retaining
the four earlier proofs and the 420-entry prefix. A profile for reference
sample 35, previously without a sharp profile and dominant in 110 captured
unresolved rectangles, gives global fixed-slope upper -317.20211073718815
at (101/100,817/100000,10000000/82517). Its first integration mesh fails the
unchanged numerical review and is retained as such. Rebuilding the mesh
resolves that discrepancy; the optimizer's precision-loss flag remains.
Independent integration, exact coordinate bounds and contrast witnesses
qualify the finite-center supporting bound, including its .00096150 correction.

Independent transfer over all 331 captured unresolved rectangles selects
two parents for the full thirty-term gate. The exact v8 transition preserves
430 verified exclusions, 4,316 pending rectangles and 333 other unresolved
rectangles, adds no splits and requeues those two parents. Producer and
independent checker remain byte-identical; the existing witness cache is
reused. Evidence is in `right-21over4-reference35-profile/`, its
`normal-rescale/` records and `slope-cover-observed-01-right-21over4-v8/`.
Both selected v8 parents subsequently pass the full thirty-term gate and
the original independent forest replay, with upper values .04420760 and
.04355384 under the unchanged .05 criterion. The captured snapshot, exact
boxes and source bindings agree, retaining the 430-entry verified prefix.
The remaining 4,316 pending and 333 unresolved rectangles in that snapshot
still prevent a complete ray, endpoint or confidence-set topology claim.

The terminal v8 check verifies eleven new exclusions, reusing the two earlier
checks and preserving the 430-entry prefix. Reference sample 49 then supplies
a fixed-slope upper of -309.7942133617017 at
(877/1000,23/5000,5000000/20171). The initial proposal mesh fails the unchanged
fresh-mesh check; the second passes. The original shifted inward witness
fails the required chord inequality and is retained as a failure. Keeping its
nuisance coordinates fixed gives a valid inward lower without repeating the
upper calculation or fitting again. The same choice improves the outward
lower; independent transfer checks over 374 saved unresolved rectangles select
five parents, including the original four selected by the weaker outer witness.

The v9 transition preserves all 441 independently checked exclusions and
4,292 pending rectangles, retains 376 other unresolved rectangles, and
requeues only those five parents without splitting. It adopts the qualified
persistent proposal banks while retaining the numerical formulas and original
independent checker. Evidence is in `right-21over4-reference49-profile/`, its
v2 `normal-rescale/` records, `forest-bank-persistence-20261006/` and
`slope-cover-observed-01-right-21over4-v9/`. All five selected parents pass
the complete thirty-term gate and independent replay, with upper values .01541227,
.02554141, .02596147, .03199578 and .03883926. Their source bindings and exact
boxes agree with the captured snapshot; 143 recorded forest choices are
verified by the original checker, and the 300 saved banks remain unchanged.
This gives 446 checked right-ray exclusions, with 4,292 pending and 376
unresolved rectangles in the checked snapshot. The ray, endpoint and
confidence-set topology remain open.

The terminal v9 replay verifies all 23 new exclusions, preserving the 441-entry
prefix. Reviewing retained bounds at six actual unresolved parents and their
corners motivates two binary split levels per parent. The exact v10 transition
replaces those six parents with 24 children, preserves all 464 checked
exclusions, 4,287 prior pending rectangles and 372 other unresolved rectangles,
and keeps all nineteen existing profiles. No additional marginal fitting or
integration is needed. All 24 children subsequently pass the complete
thirty-term gate and original independent forest replay, resolving all six
parents. Their independently checked upper values range from .00144103 to
.04724724 under the unchanged .05 criterion; all 719 recorded forest choices,
source bindings and exact boxes agree. This gives 488 checked right-ray leaves,
with 4,287 pending and 372 unresolved rectangles in the checked snapshot.
Evidence is in `normal-rescale/right-21over4-v9-retained-point-review/`,
`normal-rescale/right-21over4-v9-retained-partition-transition/` and
`slope-cover-observed-01-right-21over4-v10/selected-replay.json`.

At this necessary transition, v10 also adopts the separately qualified
write-through witness cache: newly reconstructed adaptive witnesses are saved
immediately, with unchanged numerical formulas and the original independent
checker. Startup records 5,953 cache hits and fifteen reconstructions; this is
not a matched whole-run speed comparison. The initial launcher's metadata
guard counted fifteen profile files instead of their nineteen contained rows
and stopped before successor output; its failed source/log are retained, and
the corrected guard preserves the same profiles and numerical procedure.
Pending and unresolved rectangles still prevent a complete ray, endpoint or
confidence-set topology claim.

The separate `prefix-reader-review-20261006/` compares the frozen v6
checkpoint chain with an imported-prefix reader that retains only the
exclusion rectangles in memory. The projected state and exact partition
agree, and the unchanged writer/full reader recover the original certificates
plus a new suffix. Modified parent hashes/counts and ancestor references are
rejected. Peak RSS falls from 1,529,528,320 to 1,078,689,792 bytes in one
sequential comparison, but elapsed reading time rises from 7.609 to 8.351
seconds. No speed gain is established, and the running producer is unchanged.
The reader is restricted to a fresh epoch whose complete imported prefix is
immutable and hash-bound; it must not replace current-epoch resume or the
independent certificate checker.

**Alternative-method review.** Section 6 of Wasserman, Ramdas and Balakrishnan's
[Universal Inference](https://arxiv.org/html/1912.11436v4) permits nuisance
profiling and conservative upper bounds on null likelihoods in split-likelihood
confidence sets. The non-iid extension requires the appropriate conditional
likelihood. This could avoid refitting a reference simulation bank, but it
still requires valid global nuisance bounds. For this MFRM application, a
Person-level split, a proper prediction density formed without held-out
responses, model/target assumptions and useful set evaluation would need to be
fixed and checked. Those are application requirements inferred here, not a
paper-provided MFRM qualification. No replacement procedure or sampling study
has been adopted, and the current inversion continues unchanged.

## October 12 — Finite-sample nuisance restriction before further inversion

**Decision and relation to the roadmap.** The remaining obstacle is a useful
structural-truth confidence set, not another successful optimizer, local-root
standard error or isolated exclusion in the old forest. A confidence-region
restriction can reduce the nuisance domain without treating an estimated
nuisance value as known. Its finite-sample error budget is derived below and
its pointwise action is checked using existing exact likelihood enclosures.
Neither computational improvement nor usable interval endpoints is established.
Do not resume the old forest or allocate an outer simulation on this evidence.
This advances the JML method dependency; it does not complete D1 inference or
repair the separate GMFRM source/boundary problem. N480's point comparison is
not a dependency and its frozen numerical sources remain unchanged.

### Literature checked and the distinction that matters

The Zotero attachment `7S53CJRG` to Dufour item `6D9DW4D2` is now available.
The local PDF's pages 14--20 (printed pages 456--462) were read separately;
page 18, including equation (5.8), was also rendered and visually checked.
Section 4 gives the full-nuisance supremum argument. Section 5's consistent-set
restriction requires the true nuisance value to lie in the set with probability
tending to one. It does **not** justify replacing the nuisance space by an
unqualified small-sample Wald box. Its asymptotic result must not be reported
as a finite-N20 coverage guarantee. Reference: Dufour (2006), *Journal of
Econometrics*, 133(2), 443--477,
[doi:10.1016/j.jeconom.2005.06.007](https://doi.org/10.1016/j.jeconom.2005.06.007).

Berger and Boos (1994), *P Values Maximized Over a Confidence Set for the
Nuisance Parameter*, *JASA*, 89(427), 1012--1016,
[doi:10.1080/01621459.1994.10476836](https://doi.org/10.1080/01621459.1994.10476836),
provides the relevant confidence-set restriction principle. The publisher's
metadata and abstract were checked; an exact Zotero record/full PDF was not
found in this review, so this is not a claim of full-paper or page-by-page
reading. The finite-sample argument used here is explicitly derived below.

Sections 2 and 6 of
[Wasserman, Ramdas and Balakrishnan, *Universal Inference*](https://arxiv.org/html/1912.11436v4)
were checked for independent prediction densities and nuisance projection.
The application below combines a proper prediction density with the
confidence-region restriction. These papers do not provide an already
qualified MFRM/JML interval procedure for this design.

### Construction and proof under the declared model

Write the full parameter as `theta = (psi, eta)`, with scalar contrast `psi`
and all remaining structural parameters `eta`. Retain the October 3 known
N(0,1) population, exposure and exogenous roster law. `P_theta` is the complete
sampling distribution, integrating abilities under that population; it is not
the likelihood obtained by inserting fitted Person abilities. Let `Q` be a
proper, positive prediction distribution fixed independently of observed `X`,
and let `w_theta(X) = P_theta(X) / Q(X)`.

For a fixed `0 < beta < alpha`, define the preliminary **full-parameter** region

```
C_beta(X) = {theta : w_theta(X) >= beta}.
```

On this finite response/roster support, for every true `theta_0`,

```
Pr_theta0(theta_0 outside C_beta)
  = sum_{x: P_theta0(x) < beta Q(x)} P_theta0(x)
 <= beta sum_{x: P_theta0(x) < beta Q(x)} Q(x)
 <= beta.
```

This also follows from the likelihood-ratio/Markov argument. A randomly
constructed `Q` must satisfy the proper-density and independence conditions
conditionally on its training information. Fitting `Q` on the same observed
responses and then using this calculation is not justified. Roster terms may
cancel when they have the same law; a change from joint random-roster to
fixed-roster inference still requires the matching calibration experiment.

Let `p_{psi,eta}(X,Y)` be the existing valid absolute-weight corrected
Monte Carlo p-value for a fully specified null, with the already frozen
completed-algorithm statistic and inclusive tie rule. Its validity is over
the observed data **and** the independent proposal bank, not conditional on
an arbitrarily fixed bank. Define

```
p_restricted(psi) = min(1, beta + sup_{eta: (psi,eta) in C_beta(X)} p_{psi,eta}),
sup(empty set) = 0.
```

For `t >= beta` and the true `theta_0 = (psi_0, eta_0)`, rejection at `t < 1`
is contained in the union of `theta_0 outside C_beta` and
`p_{psi_0,eta_0} <= t - beta`. Its probability is at most
`beta + (t - beta) = t`; for `t < beta` rejection is impossible. Thus this
is a valid conservative p-value and its inversion has coverage at least
`1 - alpha` **if the required supremum is evaluated or bounded safely**.
No independence between the preliminary region and the p-value is required.
For observed completed algorithm failures, retain the prior policy of setting
the final p-value to one. Raising these p-values preserves the bound. Unknown
computations are not converted to known failures or silently dropped.

This is an application derivation, not a new claim that JML is unbiased or
that its local Hessian targets the structural truth. The known population is
an identifying assumption. The earlier arbitrary-population obstruction and
ordinary/corrected JML exposure distinctions remain unchanged.

### Numerical rules and the simplest competing construction

For a certified enclosure `w in [L,U]`, exclude a point only if `U < beta`;
`L >= beta` certifies membership. A straddling enclosure remains in a
conservative outer region. Likewise, exclude a whole nuisance region only
using an upper bound applying everywhere in that region. Rejection needs an
upper bound on the p-value supremum over the entire retained outer region,
including unbounded tails and admissible limiting sequences. A point/grid
maximum is only a lower bound. A certified member with `beta + p_lower > alpha`
witnesses nonrejection; excluding that member alone never rejects `psi`.

The restriction may be wide or unbounded. Adding `beta` also consumes testing
power; a smaller search domain does not imply a shorter confidence interval.
For any subsequent feasibility decision, compare against the simpler direct
projection of `{theta: w_theta(X) >= alpha}`. That construction already has
the same finite-sample coverage argument and needs no JML simulation bank,
although it still needs global nuisance bounds and may be uninformative.
It is model-based likelihood-ratio inference, not evidence about JML's
sampling bias. Do not build a more complicated calibration layer unless it
demonstrably helps the stated inferential task.

### Bounded replay of saved evidence

`jml-nuisance-region-review-20261012.py` fixes `alpha = 1/20` and
`beta = 1/200` before the diagnostic. The latter is a 0.5-percentage-point
error allocation, leaving 4.5 percentage points for the fully specified
p-value; it is neither an optimized choice nor a proposed public default.
It reuses all four existing structural candidate points and all 50 N30
datasets. Positive interval multiplication recovers each absolute weight
from the saved normalized-weight enclosure and its common scale. No new
fitting, responses, integrals or nuisance optimization is performed.

| Full-parameter candidate | Inside preliminary region | Excluded | Numerically unresolved |
| --- | ---: | ---: | ---: |
| Proposal: contrast -1/2, unit slopes | 50 | 0 | 0 |
| Contrast -1, unit slopes | 44 | 6 | 0 |
| Contrast 0, unit slopes | 45 | 5 | 0 |
| Contrast 0, slopes (1, 1.1, 1/1.1) | 44 | 6 | 0 |

All other coordinates at these witnesses remain those of the proposal; they
have **not** been optimized away. The 17 exclusions are parameter-point/data
pairs, not 17 excluded contrasts, shorter intervals or a measured fraction
of the full search space. At the proposal, `P_theta = Q` makes membership
automatic; its 50/50 count is not evidence of confidence-region coverage.
The 50 leave-one-out banks are dependent development diagnostics, not a new
independent coverage experiment. Ordinary/order-2/order-4 GPCM-JML and PCM-JML
retention witnesses are retained separately in the machine-readable output.

The script verifies 58 historical source/input bindings, exact boundary
classification, the 200 candidate keys and all 800 arm-specific p-value rows.
Its saved result is
`validation-results/jml-nuisance-region-review-20261012/review.json`;
running the script again compares against it and refuses to replace differing
evidence. This validates evidence reuse and point screening, not a global
optimization engine. N480's separate 187-source/2,208-input manifest check
also passes without changing its running campaign.

**Next eligible decision.** Before authorizing a numerical method campaign,
establish whether the preliminary likelihood region admits substantially
sharper global bounds on the actual unresolved nuisance domain than the
existing unrestricted calculation, and whether direct likelihood-ratio
projection already suffices. Use retained likelihood certificates where they
answer that question. A useful complete set, its failure/unknown policy and
declared population/design scope must precede independent coverage assessment.
The 17 point exclusions do not justify another long forest continuation or
new population/JML/GMFRM simulations. Public interval defaults remain unchanged.

### October 12 follow-up — Actual unresolved regions and the cost of restriction

**Method decision.** The observation-based restriction can exclude complete
regions that defeated the old Monte Carlo sum bound: 60 of the 120 previously
selected unresolved regions are certified outside `C_.005`. This justifies
keeping the restriction as a computational candidate. It does not establish
a net saving for a complete confidence set. The tightened Monte Carlo cutoff
invalidates automatic reuse of some old exclusion bounds, and the simpler
direct fixed-Q projection has a deterministic anchor problem. Do not adopt
either as a public interval procedure or restart the old forest unchanged.

**Actual retained evidence.** The preceding dated narrative's v10 count is a
historical snapshot. Later saved computations exist. The hash-bound
`normal-rescale/right-v12-third-child-merge-20261007/check.json` verifies a seed
with 1,130 exclusions, 3,989 pending rectangles and 472 unresolved rectangles.
Its snapshot hash is
`11755fd3a6b1e2bf3aa8f230e964a61b2cd736142f34c6b567f271836e78d7b2`.
The retained v13 selection contains 120 of these unresolved rectangles; it
was made before this method review, omits 141 previously reviewed parents,
and requires a positive remaining budget after the other-reference diagnostic
terms. All 120 are used here, not just those with favorable observed weights.
This is one N30 observed dataset, GPCM-JML replication 1, and the right ray
`psi >= 21/4`. It is neither the full nuisance domain nor 120 datasets.

**Region bound and implementation.** The original dual-transfer engine is
reused without changing it. For each rectangle, select the three nearest
saved observed-data dual witnesses by maximum absolute log-slope distance
from the rectangle center. The inventory contains 236 witnesses; 100 unique
witnesses are reconstructed with exact nuisance-balance checks. A scalar
optimization chooses a feasible certificate, not a model estimate or a
purported global maximum. For fixed feasible scalar `c`, the existing bound is

```
log P_theta(X) <= sum_owner max_endpoint sum_i,k q_ik(c) log q_ik(c)
                  + c^2 sum_person g_person^2 / 2 + c H psi.
```

The transferred probabilities stay nonnegative and sum to one. The nine
location/step nuisance balances are zero; the known-normal moment-generating
function supplies the quadratic term. Convexity of the entropy in the
transfer factor puts its maximum at a slope-box endpoint. `H < 0` extends
the bound at `psi = 21/4` over the complete right ray. The third slope's
enclosure is induced by the positive product-one constraint. Thus this covers
all admitted location/step nuisance values and all slopes inside that box,
not just its corners or the local fitting solution.

Subtract the saved certified lower bound on `log Q(X)` to obtain a log-weight
upper. Compare it with a lower enclosure of `log(beta)` or `log(alpha)`;
an upper that does not pass the cutoff remains unresolved. No new responses,
model fits or integrals are used. The old queue and statistical outputs are
not mutated.

| Use of the observed-likelihood bound | Certified excluded regions | Not certified by this bounded review |
| --- | ---: | ---: |
| Preliminary region, beta = .005 | 60 | 60 |
| Direct likelihood region, alpha = .05 | 115 | 5 |

The old Python 3.13 runtime cannot start because its Homebrew framework is
absent. This calculation therefore uses Python 3.14.3, NumPy 2.4.2,
SciPy 1.17.1 and mpmath 1.3.0. It is not reported as a replay in the old
environment. An independent directed Decimal calculation at 80-digit
precision encloses the entropy/quadratic formula for all 120 winning
certificates; the final upper retains the larger upper bound. A separate
saved-output audit checks all 444 source/input bindings, exact equality of
the 120 regions to the frozen selection and independently computed cutoff
comparisons. The minimum log-distance from either cutoff is .0267958,
so no decision depends on numerical equality at a threshold. Two missing
historical temporary scripts were located in their preserved repository
copies and checked against their original hashes; neither was reconstructed
or edited.

Producer: `jml-nuisance-region-bounds-20261012.py`. Evidence:
`validation-results/jml-nuisance-region-review-20261012/region-bounds.json`.
Only the bound certificate, assumptions and scope are new. The previously
qualified dual formula is reused; there is no new likelihood engine and no
matched runtime benchmark.

**The error budget has a real cost.** In the restricted p-value, the remaining
cutoff is `alpha - beta = .045`. An old unrestricted regional bound of .049
does not automatically certify the new test merely because it was below .05.
The four latest additions in the verified seed have p-value uppers
.0468358992, .0359363024, .0392581149 and .0401232878. Three directly meet
.045; the first needs a sharper bound or proof that its region is outside
`C_beta`. It is unresolved under this reuse check, not proved retained.
`budget-reuse.json` stores these exact rational comparisons and their source
bindings. The older 1,126 exclusions are not reclassified here. Consequently
the 60 new regional exclusions must not simply be added to the old 1,130 or
reported as an established net reduction in the complete search.

**Why direct fixed-Q projection is not the general solution.** Here the
prespecified proposal is itself an admitted model, `Q = P_thetaQ`, with
Criterion contrast `psi_Q = -1/2`. For every possible observed dataset,

```
w_thetaQ(X) = P_thetaQ(X) / Q(X) = 1.
```

Therefore the direct region `{theta: w_theta(X) >= .05}`, and its projection
on `psi`, always contains `-1/2`, irrespective of the data. Its finite-sample
coverage argument remains valid, but at a different true contrast it cannot
generally yield shrinking intervals around that truth: whenever the true
contrast is covered, the set also includes this fixed anchor. The retained
development condition sets the generating law equal to Q, making apparent
perfect truth inclusion at that anchor automatic. This cannot qualify a
general-purpose interval procedure or establish an advantage over JML
calibration. This limitation follows algebraically; a new simulation is not
needed to discover it.

The restricted Monte Carlo construction does not force final acceptance at
that anchor: `C_beta` includes it, but its calibrated p-value still has to
pass the test. This is not a proof that the restricted procedure is useful
or consistent. If direct prediction-density inference is revisited, the
choice of Q must first avoid this fixed model anchor (for example, a properly
independent fitted prediction density); small-sample information loss and
global projection would then be separate feasibility questions. Do not
silently fit Q on the same responses or call such a change already qualified.

**Disposition.** Retain the finite-sample restriction as a candidate with
demonstrated regional pruning, and decline direct fixed-Q projection as the
general interval replacement. The next method gate is a complete useful set
under one fully specified procedure, covering all retained regions and tails
and requalifying old bounds at the adjusted cutoff. Another isolated leaf
or successful fit would not close that gate. No broad simulation, renewed
old-forest run, public interval change or GMFRM repair follows from this
review. The existing N20 and other sample-size/design obligations remain.

### October 12 full-domain feasibility decision

**Decision.** The fixed observation-screening recipe has now been evaluated
on the entire preserved right-ray slope partition, not just a favorable
selection of leaves. It does not complete the right-ray exclusion or produce
a useful confidence set. Keep the confidence-region restriction as a possible
component; do not promote this computational recipe, restart its old forest,
or increase its iteration/splitting allocation on the basis of the earlier
60/120 result. This is a completed negative feasibility decision for the
specified recipe, not an impossibility theorem for finite-sample JML inference.

**Complete domain and reused evidence.** The same verified seed contains
5,591 leaves: 1,130 excluded under the original .05 rule, 3,989 pending and
472 unresolved. A compact read preserves every rectangle and recorded p-value
upper through all 24 hash-bound prefix checkpoints. The existing exact
rectangle-sweep checker verifies complete, nonoverlapping coverage of the
original root and the split count. The real terminal suffix is also compared
with the ordinary JSON reader. No historical checkpoint is edited.

Of the 1,130 original exclusions, 951 directly satisfy the new .045 cutoff;
179 do not. Matching saved independent replay entries are found for all 951,
with the same box and recorded original upper, and all their independent
uppers also satisfy .045. No Monte Carlo numerator is recomputed to obtain
this reuse decision. Outside the common slope rectangle, the existing
all-joint-escape certificate gives `p <= 1/32 = .03125`, which still meets
.045. The common rectangle is checked to contain every sample's certified
slope box. Thus the external parameter tail is accounted for; it is not
silently truncated at the plotted or explored range.

**Fixed pass.** First reuse those 951 MC bounds and all 120 previous observed
region evaluations. Apply the already qualified observed-data slope-tail
bound to the rest, with an independent directed Decimal enclosure. This
settles 1,489 previously pending rectangles and leaves 3,091 for the second
stage. On each new residual rectangle, the three nearest saved observed dual
witnesses propose feasible scalars; the best floating proposal is evaluated
with exact feasibility and outward arithmetic. Only this single proposal is
certified per rectangle, and no additional split or witness fit is allowed.
Previous evaluations, including unsuccessful bounds, are reused. Every new
dual exclusion also receives the independent 80-digit Decimal check. All
3,091 residual leaves are processed; there is no time-based truncation or
unreported partial queue.

| Historical leaf status | Settled under the restricted test | Still unresolved |
| --- | ---: | ---: |
| Originally excluded: 1,130 | 1,029 | 101 |
| Originally pending: 3,989 | 1,846 | 2,143 |
| Originally unresolved: 472 | 168 | 304 |
| Total: 5,591 | 3,043 | 2,548 |

The 3,043 consist of 951 reused MC bounds, 60 previous observed bounds,
1,489 observed tail bounds and 543 new observed dual bounds. Of the 179 old
exclusions that failed the tightened cutoff, 78 are recovered by observation
screening and 101 remain unresolved. The count of resolved leaves is neither
a fraction of parameter probability nor a speed benchmark: the rectangles
differ in size. An unresolved upper does not prove that a null is retained,
that the true parameter lies there, or that repeated subdivision will settle
it. The entire exercise still concerns one N30 observed dataset and
`psi >= 21/4`; it does not qualify another N/design, the left ray, an interval
endpoint, corrected-JML coverage, or GMFRM inference.

Evidence is in `validation-results/jml-nuisance-region-review-20261012/`:
`domain-review.json` records the exact partition and first pass;
`domain-dual.json` records the completed residual pass and its source/runtime
binding; `domain-checks.json` records the saved-output audit and independent
MC-bound matches. The producers are `jml-nuisance-domain-review-20261012.py`
and `jml-nuisance-domain-dual-20261012.py`. All 470 source/input bindings of
the completed pass match; the 543 new dual exclusions pass their independent
Decimal enclosures and exact cutoff comparisons. The numerical engines and
the public package are unchanged. No model fitting, response generation,
integration, new forest split or independent coverage experiment is performed.

**The next change must address a bound, not extend the same queue.** Inspection
of the current MC upper shows that reference likelihoods are bounded one at
a time, maximizing out their location/step nuisance parameters separately
before summation. The actual test uses one shared nuisance vector. The
preliminary-region screen removes whole slope boxes, but in surviving boxes
it does not use the observed-likelihood constraint to restrict the nuisance
maxima for the reference samples. This is a documented relaxation in the
calculation, not a claim that it explains every one of the 2,548 failures;
some remaining rectangles are also broad.

One concrete candidate for a sharper bound can be stated without fitting
anything. For observed `X`, reference sample `Y_i`, and a region `B`, suppose
a valid joint upper is available:

```
U_0i(B) >= sup_{theta in B} P_theta(X) P_theta(Y_i).
```

On `B intersect C_beta(X)`, the definition `P_theta(X) >= beta Q(X)` gives

```
w_theta(Y_i) <= U_0i(B) / (beta Q(X) Q(Y_i)).
```

The same theta appears in both likelihoods. Separate maximization gives only
the looser product of two suprema and can erase the benefit. More generally,
`sup P_theta(X)^lambda P_theta(Y_i)` with fixed `lambda >= 0` gives the
corresponding denominator `(beta Q(X))^lambda Q(Y_i)`; lambda zero recovers
the existing bound. Choosing a valid bound from this family is a numerical
bound choice, not permission to tune beta after observing favorable outcomes.

This inequality is an application derivation, not an implemented replacement
or an instruction to launch a new campaign. The factor `1/beta` can make it
unhelpful; the joint upper must demonstrably beat the existing bound in the
remaining domain, with the same target and error budget, before further
allocation. Full nuisance/tail coverage and a useful complete set remain the
adoption gate. D1's other obligations and the parallel N480 point comparison
are unchanged.

### October 12 shared-nuisance bound — first complete-numerator check

**Decision.** A joint observed/reference bound now certifies two actual
residual rectangles, including every term of their restricted MC numerator.
It does not certify the third preselected rectangle. This establishes a
useful component, not a complete confidence set or permission to repeat
auxiliary optimizations across the remaining domain. Retain the 90 new
certificates for reuse. The next eligible computation is a bounded reuse
assessment over the residual partition, with floating proposals followed by
exact certification only where a complete numerator can meet the cutoff.
Keep all unqualified boxes explicit; do not pursue the one failed sentinel
with extra starts, splits, or a post-result change of beta.

**What is shared, and what is independent.** For sample s, a feasible
categorical probability vector gives the conditional Fenchel inequality

```
log L_s(eta, psi, theta_s)
  <= E_s + b_s' eta + H_s psi + g_s' theta_s.
```

Here E is the sum of q log q, eta contains the nine unrestricted structural
location/step coordinates, and theta_s is that sample's Person vector.
Integrating independent standard-normal Persons gives

```
log P_s(eta, psi) <= E_s + b_s' eta + H_s psi + ||g_s||^2 / 2.
```

The usual separate certificates impose b_0 = b_i = 0. For the product
P_0 P_i, it suffices to impose b_0 + b_i = 0. Thus the feasible joint dual
family includes the separate family and can improve its optimal upper.
In this review both samples' Persons remain independent: the normal term is
`(||g_0||^2 + ||g_i||^2)/2`, not `||g_0 + g_i||^2/2`. This remains true for
i = 0: squaring a marginal likelihood means two independent latent copies,
even though their observed responses are identical. Shared structural
parameters do not justify identifying Persons across reference datasets.
The exogenous roster factors cancel against Q as in the retained engine.

Concatenating the two samples with different Person indices therefore reuses
the existing exact dual construction for lambda = 1. The stored rational
probabilities cancel the joint structural score. Their scalar/slope transfer
preserves that cancellation over each whole rectangle, and a negative H
extends the bound over `psi >= 21/4`. On C_beta, divide the joint likelihood
upper by `beta Q(X) Q(Y_i)` to bound w_i. Taking the smaller of this and any
valid old w_i upper, then summing all 30 retained ray members and dividing
by 50, bounds the restricted MC part. Its cutoff remains .045; beta remains
.005. Numerical optimizer success is not a condition for this certificate:
nonnegative normalized rational probabilities, exact joint balance, the ray
sign, and outward evaluation are the conditions.

For future weighted variants, the corresponding cancellation is
`lambda b_0 + b_i = 0`, with normal term
`(lambda ||g_0||^2 + ||g_i||^2)/2`. Multiplying the already integrated
log-likelihood inequality by lambda proves this for lambda >= 0. Replacing
the term by lambda squared, or moving a fractional power through an integral
without the appropriate inequality, would be a different and potentially
invalid construction. No weighted variant was fitted in this allocation.

**Frozen, bounded selection.** The previous 2,548 residual leaves were grouped
by their historical status (101 excluded, 2,143 pending, 304 unresolved).
Within each group, order by the largest log-width among all three slope
enclosures, breaking ties by the exact box coordinates; select index
`floor(group size/2)` using zero-based indexing. The three choices, the
retained witness inventory and source/runtime bindings were saved before
new optimization. This is a transparent mechanism check, not a random sample
or an estimate of a domain-wide success proportion.

Each of the three rectangles receives all 30 reference terms. For each term,
the comparator is the existing tail bound and the nearest retained separate
dual witness; the new candidate is one joint dual at the geometric slope
center and one certified transfer. There are no extra starts, subdivisions,
new responses, integrations or JML refits. The 90 auxiliary optimizations
propose probabilities for a likelihood bound; they are not new mfrmr fits.

| Historical status of selected rectangle | Restricted MC upper after combining bounds | Meets .045? |
| --- | ---: | --- |
| Excluded under the original .05 rule | 0.06484408849 | No |
| Pending | 5.2812097015e-11 | Yes |
| Unresolved | 0.00008842648419 | Yes |

The first rectangle already has a historical full-engine upper of
0.04952694180, better than this new simplified combination, but still above
.045. Do not call the 89/90 improvements over the simplified term comparator
an improvement over the full historical engine. The latter's additional
profile, forest and other certificates have not been combined term by term
in this review. The old full-domain files are preserved. Overlaying only the
two new certified exclusions changes the bookkeeping from 3,043 settled /
2,548 unresolved to 3,045 settled / 2,546 unresolved out of 5,591 leaves.
These are rectangle counts, not probabilities, coverage, or width estimates.

**Verification and evidence.** All 90 joint certificates pass exact balance
and outward-transfer checks. An independent reconstruction from the raw
response coordinates verifies all nine shared nuisance balances and the
separate 30-Person normal terms, and checks the anchor entropy with directed
80-digit Decimal arithmetic. In all 90 cases the two samples' individual
nuisance balances are nonzero but cancel jointly; treating their Person
vectors as shared would also change the quadratic term in all 90 cases.
The independent checker reproduces all three full MC sums and verifies all
1,776 manifest source/input bindings. Although only 67 optimizers report
success, all 90 proposed witnesses satisfy the exact certificate conditions;
no accuracy claim relies on the small floating primal/dual gaps or on an
optimizer flag, and no retry was allocated to change those flags.

The producer and independent checker are
`jml-shared-nuisance-review-20261012.py` and
`jml-shared-nuisance-check-20261012.py`. Their manifest, all 90 term records,
`summary.json`, and `checks.json` are retained in
`validation-results/jml-shared-nuisance-review-20261012/`. This evidence is
still for one N30 observation and one contrast ray under the known-normal
law. The complete-set, topology, other N/design and independent statistical
qualification obligations remain open. No public package implementation or
running N480 source was changed.

### October 12 shared-certificate reuse over the full residual partition

**Decision.** The bounded reuse pass is complete. It screens all 2,546
remaining rectangles, certifies seven additional exclusions, and leaves
2,539 unresolved. The fixed shared-certificate inventory therefore does not
complete even this right ray. Keep its valid certificates, but do not expand
its auxiliary fits, scalar search or subdivision merely because some local
exclusions worked. The three-sentinel result was not a forecast of full-domain
success. A complete, useful structural confidence set is still the method
gate; neither the shared-nuisance idea nor JML inference itself is disproved
by failure of this particular bounded implementation.

**Reuse and computational scope.** Reuse all 90 saved joint witnesses and
the 90 separate witnesses selected by the previous sentinel calculation,
together with the retained tail bounds. These are the whole fixed inventory;
no live-directory discovery adds further witnesses. For each witness and
rectangle, evaluate five fixed fractions of a feasible scalar cap, its saved
scalar clipped to that cap, and scalar one clipped to the cap. A quadratic
search cap proposes useful values but never replaces the exact probability
feasibility cap. No scalar optimizer or auxiliary optimizer is called; both
SciPy optimization entry points are replaced by an explicit failure function.
The existing JML statistics, 30 inclusive ray members, denominator 50, beta
.005 and remaining cutoff .045 stay fixed.

The floating stage uses precomputed convex entropy chords to compare the
complete 30-term numerators. Seven rectangles fall below the deliberately
looser .05 screening threshold and receive exact certification. The other
2,539 have no certified exclusion from this recipe. They are not evidence of
retention, and the floating stage is not asserted to exhaust all possible
scalar choices or valid bounds. It can only determine which certificates to
attempt. This confines final exact numerator evaluation to 210 terms rather
than evaluating all 76,380 residual terms with the expensive exact transfer.
That is a scope count, not a wall-time speed benchmark.

**Why the entropy reuse is an upper bound.** For a response row let y be its
observed category, q the saved probability vector, m = 1-q_y, and let M be
the maximum m among an owner's rows. The original transfer is
`q(t) = delta_y + t(q-delta_y)`. Use normalized scalar `s = t M` in [0,1].
Writing `f(u) = u log u + (1-u) log(1-u)`, the owner's entropy is exactly

```
H(s) = sum_rows f(s m/M)
       + s sum_rows sum_{k != y} (q_k/M) log(q_k/m).
```

It is convex in s because each probability is affine in s and x log x is
convex. A line segment between any two node uppers is consequently an upper
bound between those nodes; it is not a tangent approximation. The fixed grid
contains multiples of 1/16 and additional dyadic nodes near both endpoints.
Node enclosures use 80-digit directed Decimal arithmetic, including the
continuous zero-probability limits. Their rational interpolation encloses
the entropy at both slope endpoints, and the larger endpoint upper encloses
the whole slope interval. Add the unchanged exact normal-MGF and contrast
terms, then the fixed proposal/beta offsets. Log-weight uppers are rounded
upward to a 10^-30 lattice before summation; this is an additional conservative
enclosure, not a statistical tolerance or a relaxed rejection cutoff.

The independent formula check compares both joint and separate witnesses
against the original four-category entropy at 30 owner/node combinations,
including zero, one, one-half and the two near-boundary nodes. It uses the
original categorical formula with 100-digit interval arithmetic. All new
Decimal node enclosures contain those independent enclosures.

| Historical status | Additional exclusions from this reuse pass | Settled after the overlay | Remaining |
| --- | ---: | ---: | ---: |
| Originally excluded under .05 | 0 | 1,029 | 101 |
| Originally pending | 6 | 1,853 | 2,136 |
| Originally unresolved | 1 | 170 | 302 |
| Total | 7 | 3,052 | 2,539 |

The seven certified MC uppers range from 0.00001219757865 to 0.02896886450,
all below .045. Every selected term uses a shared-nuisance certificate; 60
distinct saved joint witnesses contribute. The 1,216 evaluated entropy nodes
are cached. No prior result or historical partition is changed. Outside the
common slope rectangle, the retained 1/32 upper continues to satisfy .045.

**Independent verification.** The checker bypasses the new entropy factors,
nodes and interpolation. For every selected term it reconstructs the original
saved witness, verifies the exact scalar feasibility and negative contrast
slope, and evaluates the original unfactored probability-transfer formula
using the previous directed Decimal routine. All 210 resulting uppers are
below the corresponding new recorded uppers. All seven complete sums are
enclosed again with 100-digit interval arithmetic, and all 1,870 bound source
files match. Thus the exclusion claims do not depend solely on the new reuse
implementation agreeing with itself. No new optimization, response generation,
JML refit, numerical integration or partition split occurs in either pass.

Evidence is in `validation-results/jml-shared-nuisance-reuse-20261012/`:
`manifest.json`, `formula-checks.json`, `screen.json`, `nodes.json`,
`certified.json` and `checks.json`. The two producers are
`jml-shared-nuisance-reuse-20261012.py` and
`jml-shared-nuisance-reuse-check-20261012.py`. The counts describe rectangular
pieces of one N30 right-ray calculation, not parameter probability or
repeated-sampling performance. Full-set topology, other N/design conditions,
ordinary/corrected-JML inference qualification and the GMFRM method gap remain
open. Close this bounded reuse task and return to the already scheduled public
model-comparison evidence reconciliation while N480 continues; that D2 task
does not replace the unresolved D1 interval requirements.
