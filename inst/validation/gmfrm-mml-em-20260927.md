# Joint task/rater slopes: numerical MML--EM verification

Date: 2026-09-27; mathematical-design review updated 2026-10-13.
Internal implementation record; current execution decisions are in the
[internal roadmap](internal-roadmap-0.2.4.md#current-d1-work-order-and-next-decision).
The October 11 source-to-interval evaluation below ends in non-adoption of
the proposed continuation. The N480 comparison and output handoff are complete;
the October 12 roadmap gives the next method dependency priority
over further local optimizer rescues. Dated dependencies later in this record
retain their historical context.

## October 13 learned-predictor likelihood sets: applicability and next gate

**Decision.** Keep a Person-split likelihood confidence set as a distinct
candidate, but do not launch training fits or a coverage simulation yet. A
training-only prediction density removes the deterministic fixed-Q anchor
identified in the October 12 JML review. The validity argument can avoid
estimated-nuisance bootstrap calibration. Useful scalar bounds still require
global null-likelihood upper bounds; the retained regularized free/null fits
do not supply those bounds. This is a more precise method dependency, not an
implemented interval, a statistical-performance qualification or a scope cut.

This method is **not newly discovered or previously unmentioned**. The JML
review already discussed universal inference, the fixed-Q obstacle and an
independently learned alternative. An initial statement in this work calling
universal inference unexamined was corrected after finding those records.
The increment here is the fixed-design GMFRM argument, the distinction between
training and null optimization, exact failure controls, and the retained-data
Person-partition audit. It does not repeat the old nuisance-region forest.

### Literature and application assumptions

Wasserman, Ramdas, and Balakrishnan (2020), *Universal inference*, PNAS 117(29),
16880--16890, [doi:10.1073/pnas.1922664117](https://doi.org/10.1073/pnas.1922664117),
provides the split/crossfit likelihood framework. The
[arXiv v4 manuscript](https://arxiv.org/abs/1912.11436v4), dated October 21, 2022,
was read page by page on PDF pages 2, 3, 4, 12, 13, 14, 15 and 16; page 13 was
also rendered and inspected. These are targeted pages, not a complete-paper
reading or a claim that the v4 manuscript equals the published pagination.
Pages 2--4 cover prediction, the expectation argument and composite tests;
12--13 cover averaging, projection and safe likelihood relaxations; 15 treats
conditional likelihoods for non-iid data. Page 16's misspecification result
has extra convexity conditions and is not transferred to GMFRM here.

The exact-title Zotero search returned no matching item; semantically related
fallback papers were not treated as matches. The local API probe had an EPERM
sandbox error, not evidence that Zotero was stopped; the connector search
worked. The public manuscript was downloaded without changing the library.
Its SHA256 is retained with the checks below. No novelty claim is made for
the published inference principle.

The following is our application argument. Fix an exogenous rating roster,
the native constraints/category ladder, structural parameter beta=(psi,eta),
and independent Person abilities Z_i ~ N(0,1). For each Person's **joint**
response vector Y_i on roster R_i, use

    p_beta,i(Y_i | R_i)
      = integral phi(z) product_{j in R_i} Pr_beta(Y_ij | z,R_i) dz.

Rows sharing a Person are not independent after marginalization. Conditional
on the fixed roster, the Person vectors are independent but may have different
designs/distributions. This is the fixed-normal GMFRM law, not JML with an
arbitrary ability distribution, an estimated-ability plug-in law, or a model
with unaccounted response dependence/informative allocation.

### A complete probability argument, distinct from a complete implementation

Choose Person folds A/B using the roster/IDs and no scores. A fitting rule
using only B produces a proper predictive probability q_A on all response
arrays of A. For example, fit finite structural coordinates on B and evaluate
the **unpenalized marginal response probability** on A. Define q_B analogously.
Independent algorithm randomness can be conditioned on. For the true beta0,

    E_beta0[q_A(Y_A | Y_B) / L_A(beta0) | Y_B, roster] = 1,
    e(beta) = 0.5 * (q_A/L_A(beta) + q_B/L_B(beta)).

The equality follows by summing the proper q_A over the complete finite
response support; a sub-probability lower bound gives <=1. Hence
Pr_beta0(e(beta0)>1/alpha)<=alpha. The two terms need not be independent.
A fixed weighted average is valid; selecting the largest ratio or a favorable
split after inspecting the test outcomes does not inherit this argument.

An arbitrary finite training estimate can define a proper q. An MLE, unbiased
training estimate, invertible training Hessian or optimal training solution is
not required for this coverage argument. Regularization can therefore be used
in **training**; a declared fixed-model fallback after training failure can also
be proper. Poor training predictions reduce information/power. Hyperparameters,
split choice and fallbacks must not adapt to held-out responses; inspected
development cases cannot become independent confirmation of the selected rule.

At a tested scalar value t, suppose certified bounds satisfy

    U_A(t) >= sup_{eta:(t,eta) admissible} L_A(t,eta),
    U_B(t) >= sup_{eta:(t,eta) admissible} L_B(t,eta).

Using e_lower(t)=0.5*(q_A_lower/U_A(t)+q_B_lower/U_B(t)), where each
q_lower<=q, preserves e_lower(psi0)<=e(beta0). Rejecting only when
e_lower(t)>1/alpha gives a conservative confidence set for psi. Exact equality
is retained. Unknown bounds retain the candidate with unresolved status; they
must not be counted as informative completed intervals. For whole excluded
regions/rays, the upper bounds must cover every nuisance value and target
value there, including admissible boundary limits. A finite plotting grid is
not an endpoint certificate. Taking a conservative interval hull of a fully
qualified set preserves coverage but can lose useful disconnected topology.

Separate fold-wise profiling is a conservative **outer** projection of the
crossfit full-parameter set: inf_eta(e_A+e_B) >= inf_eta(e_A)+inf_eta(e_B).
It need not equal projection with one common nuisance vector. This allows a
simpler valid composite test, at a possible cost in width/power.

The denominator direction matters. A local feasible fit provides a **lower**
bound on the maximum likelihood, whereas rejection needs an upper bound.
Good gradients, repeated starts or a finite regularized minimum do not reverse
that inequality. In NLL form the required certificate is a global lower bound
on the unpenalized null NLL. A penalized objective is not that certificate.
Neither the earlier regularized statistic nor its numerical admission flags
can be inserted unchanged in this denominator. Independent integration
agreement at isolated parameter points is also not a uniform domain bound.

### What the bounded checks establish

The standalone exact-arithmetic driver
`gmfrm-split-likelihood-contract-20261013.py` generates no responses. For
training/test binomial counts of size 6/6 and nine complete-null probabilities,
it sums all 49 count pairs exactly. The averaged e-value has expectation one;
lower-numerator/upper-denominator replacement never increases rejection.
The largest rejection probability is .00058124288 at nominal .05 in these
small discrete controls: the logic can be very conservative. These are code
and mathematical controls, not a simulation or GMFRM performance evidence.

Three deliberately invalid controls demonstrate why the restrictions matter:

* Replacing a composite Bernoulli-null likelihood supremum by the likelihood
  at p=.1, when p=.9 is true, gives .81 rejection with two test observations.
* Maximizing 21 individually valid e-values over a uniform 21-state outcome
  gives certain rejection at .05; their fixed average is one.
* Splitting paired, perfectly dependent ratings across folds for five Persons,
  while pretending the test ratings are independent of training, gives e=32
  and certain rejection. This is a dependence counterexample, not GMFRM data.

An exact two-nuisance-point calculation checks separate versus common profiling
(5/9 versus 25/9). For scalar normal location with known variance one, a single
equal split has squared radius
`(mean_A-mean_B)^2+4*log(1/alpha)/N`. Its expected squared radius is
`[4+4*log(1/alpha)]/N`; at alpha=.05 the RMS radius is 2.03976 times the usual
full-sample normal radius. This is neither the mean width nor a GMFRM/crossfit
inflation factor. It quantifies why finite-sample validity alone is not enough
to prefer splitting at N20. Unlike fixed Q at mean zero, a learned prediction
at training mean one can exclude zero when the test mean is also one; the
calculation checks removal of a fixed anchor, not consistency in weak designs.

The design-only `gmfrm-person-split-audit-20261013.R` reuses the five saved
GMFRM inputs. Within identical observed roster patterns it alternates sorted
Person IDs, balancing fold sizes across groups, without accessing scores for
selection. Every N20 case splits 10/10 Persons and 60/60 ratings; N60 splits
30/30 and 180/180; N240 splits 120/120 and 720/720. Both folds retain all Task
and Rater levels in each case. Disjointness, complete row assignment and saved
replay pass. Level presence does not establish identification or useful
information, and no training/source/null fit was performed.

Evidence is in `validation-results/gmfrm-split-likelihood-contract-20261013/`
and `tmp/universal-inference-20261013/`. The source/PDF hash, exact rational
results and source-bound Person partitions are retained. This neither changes
public functions nor invalidates previous sampling evidence.

### Resource decision and next eligible work

The architecture replaces inner simulation with two training fits and the
evaluation of two null-likelihood upper bounds at each requested target value.
These are **global bounds**, not two ordinary optimizer calls; their complete
cost may dominate. Existing full-data/bootstrap timings cannot be relabelled
as costs for half-data fitting or certified projection. The trivial discrete
likelihood upper bound U=1 is valid but gives e_lower<=1 and no exclusion.

Before allocating fitting or simulation, establish a nontrivial, full-domain
likelihood upper bound or relaxation for one declared GMFRM contrast, including
its unbounded slope/location nuisance directions. The one-family JML dual
certificates concern a different response law and data product; they cannot
be imported as two-family or half-data certificates. If no useful tractable
bound is available, retain this as a valid construction with an unmet
computational dependency; do not substitute a local optimum or begin a new
forest merely because the theorem is appealing. The training design is now
feasible, so no further partition audit is needed. No broad simulation,
automatic method adoption, release-scope change or original JML population
assumption change is allocated. D1 remains open.

### October 13 bound gate: two-family algebra, scale and integration loss

**Decision after the bounded review.** The entropy/normal-MGF construction
does extend to two slope families on a declared positive finite slope box.
That is a positive mathematical component, not the required useful bound on
the whole null family. Do not allocate half-data training fits, a new domain
partition, or a coverage simulation on the strength of this component. Two
specific weaknesses must be addressed: preserving the fixed-normal scale
when bounding nuisance parameters, and retaining enough integration mass to
avoid a noncontracting envelope. The result changes the method-selection
gate; it supplies no GMFRM interval and closes no D1 inference claim.

The review checked the live product-slope setup and exported Stan response
law against the earlier one-family dual source. It also reread the JML
record's *Normal integration from a forest of probability transfers* section.
That earlier work **already recognized integration-mass loss and developed
sharper bounds**. Neither this problem nor the general entropy inequality is
claimed as newly discovered. Its old data, one-family slope constraints and
remaining domain gaps do not become two-family certificates by analogy.

**A valid finite-box extension.** For rating j by Person i, Task t and Rater r,
write the category logits as

    v_jk = A_j [k z_i - k b_t - k d_r - sum_{h<=k} tau_rh],
    A_j = a_t c_r > 0, product_t a_t = 1,
    psi = b_t1 - b_t2.

The Task locations are centered, Rater locations are free, and each Rater's
steps are centered, as in the inspected implementation. Express the bracket
as `k z_i + u_jk psi + D_jk eta`, using the native linear constraints.
For any normalized nonnegative category vectors q_j, the log-sum-exp
inequality and independent standard-normal integration give

    log L(psi,eta,A) <= E + H psi + B' eta + sum_i g_i^2/2,
    E = sum_jk q_jk log(q_jk),
    g_i = sum_{j in i} A_j [y_j - sum_k k q_jk],
    H = sum_j A_j [u_j,y_j - sum_k q_jk u_jk],
    B = sum_j A_j [D_j,y_j - sum_k q_jk D_jk].

Thus exact B=0 removes **all** location/step nuisance directions. Persons'
scores must be summed before squaring; marginally treating ratings as
independent would change the bound. This proof uses the same fixed-normal
response law as the split-likelihood contract, without latent plug-in values.

At reference effective slopes A0, suppose q0 has B=0. For scalar h>=0, use

    q_j(A) = delta_yj + h A0_j/A_j (q0_j - delta_yj).

Then B remains zero and g/H multiply by h. A positive finite component box
gives product enclosures `0<l_j<=A_j<=u_j`. Taking
`h <= min_j l_j/[A0_j(1-q0_j,y_j)]` over nonzero denominators ensures
probability feasibility. Convexity of `sum_k q_jk log(q_jk)` in `1/A_j`
bounds each row's entropy by its larger endpoint value. Summing those
maxima, plus `h^2 sum_i g0_i^2/2 + h H0 psi`, is a valid uniform upper
on that box. Ignoring dependence between product enclosures only loosens it.
For H0<0 it also bounds a right ray psi>=T by substituting T.

This extension needs a witness for the **actual held-out response array**;
old full-data witnesses are not such witnesses. Boxes allowing arbitrarily
small effective slopes force the above *fixed-h* feasibility rule to h=0,
unless the affected rows have no transfer. In the common-scale-zero direction
all nontrivial transfers are affected, leaving the trivial upper log L<=0.
This is a limitation of this transfer/box construction, not a proof that all
possible boundary bounds are trivial. A finite positive box, however finely
resolved, does not cover the unbounded second-family scale and relative-slope
limits. The earlier exact-zero saturated bound covers one boundary family,
not its neighborhoods or diverging relative slopes; its full-data comparison
cannot settle the new held-out likelihood-ratio threshold.

**Why freeing Person abilities is too loose for this target.** A seemingly
cheap alternative is to bound the integral by the supremum of the conditional
likelihood over free Person abilities, then profile all other nuisances.
For any d>0 the transformation

    (z,b,d_r,tau) -> d*(z,b,d_r,tau),
    a_t -> a_t,  c_r -> c_r/d,  psi -> d*psi

leaves every conditional logit unchanged and respects the structural
constraints. Therefore this relaxed null supremum is identical for every
positive psi, and likewise for every negative psi. A plug-in GMFRM training
prediction with positive target has marginal likelihood no larger than that
relaxed supremum for **any** positive target. Its split ratio cannot exceed
one there. If both training fits have that sign, the averaged crossfit ratio
also cannot exclude that entire half-line. This conclusion has the stated
sign/predictor conditions; it is not a theorem for arbitrary predictive
densities or opposite-sign crossfit fits.

The transformation does **not** preserve the fixed-N(0,1) marginal law: holding
the integration variable z fixed leaves logits with z/d instead of z. Along
this path, as d tends to infinity, latent variation vanishes and the response
law tends to the corresponding independent categorical law. The fixed-normal
model still contains the scale information that the free-ability relaxation
discarded. This does not prove GMFRM nonidentification at finite positive
slopes. It connects to the existing common-variance chart rather than adding
a new boundary search.

**A validity/utility counterexample with an exactly known integral.** Even
keeping the normal MGF is insufficient if the envelope loses too much mass.
At a finite joint optimum, the tight single-tangent entropy/MGF envelope
equals the conditional log likelihood minus `sum_i z_i^2/2`; it lacks the
integration-volume term. This statement concerns an exactly feasible
envelope/optimum, not permission to treat a numerical MAP value as certified.

For an independent analytic control, take `Y_i|Z_i ~ N(mu+Z_i,1)` and
`Z_i ~ N(0,1)`. The exact marginal is N(mu,2). With m held-out Persons,
the optimized tangent/MGF upper is exactly `U(mu)=2^(m/2) L(mu)`.
If the training and held-out means are a and b, the single-split confidence
set using U has squared radius about b

    (a-b)^2 + 2 log(2) + 4 log(1/alpha)/m.

The exact marginal denominator omits `2 log(2)`. With consistent training,
the envelope radius tends to sqrt(2 log(2))=1.177410 rather than zero. For
alpha=.05, equal-sized folds and a=b, exact/envelope radii are
1.09467/1.60767 at total N20, .31600/1.21908 at N240, and
.22345/1.19843 at N480. These are analytic normal controls, **not GMFRM
widths, simulated coverage, or expected widths**. They establish that a
mathematically safe but loose bound can defeat increasing N. Larger runs
would not repair this structural loss. A finite-sample valid nonshrinking
set can still be useful for some questions; validity alone does not select
it for the package's structural-precision goal.

**Checks and scope.** `gmfrm-likelihood-bound-gate-20261013.py` checks exact
rational nuisance/score transfer at 27 slope settings in a fixed 2-Task,
2-Rater, 2-Person arithmetic fixture, 48 conditional scaling identities and
48 fixed-normal path identities. This fixture is not one of the retained
3-Task/6-Rater datasets. The general inequalities above establish their
domain; a finite grid alone cannot do so. Reported entropy values use ordinary
floating arithmetic and are controls, not outward-rounded endpoint
certificates. The normal identities are checked separately by R's numerical
integration and density calculations. No GMFRM fitting, response generation,
integration or forest search is performed. Evidence is
`validation-results/gmfrm-split-likelihood-contract-20261013/bound-gate.json`
and `tmp/universal-inference-20261013/independent-bound-check.R`/`.log`.

**Updated allocation condition.** A future implementation proposal must give
one full-domain two-family bound that preserves the fixed-normal scale and
quantifies its likelihood gap, including the integration-volume and slope
boundary cases. Reusing the existing sharper witnesses may help only after
their actual scope is shown to match; do not automatically transfer the old
forest, add a finite slope cutoff, fit more training cases, or begin another
method cascade. No additional computation on this candidate is selected now.
Return the next allocation to the existing portfolio priorities and compare
it with the open JML/population claims and deliverable user workflows. This
is a bounded non-selection of the present relaxation, not abandonment of
likelihood confidence sets, proof that D1 intervals are impossible, or a
change to agreed release scope.

## October 12 common procedure and calibration allocation decision

**Completed computational unit.** The private
`gmfrm-regularized-procedure-20261012.R` now composes the frozen initial
fixed/adaptive search and the single qualified continuation. Both observed
and regenerated datasets call `regularized_pair()` with the declared design,
responses and tested contrast. No observed/bootstrap flag or generating
nuisance truth enters the fitting policy. The original penalty, starts,
accuracy thresholds and 200-iteration continuation limit are unchanged.

Input failure remains unavailable. A qualified primary fit returns directly;
only NLL/gradient disagreement or stationarity failures with the other checks
passing receive the common continuation. Integral disagreement selects the
existing segmented evaluator; otherwise adaptive-121 is retained. There is
one continuation, not a retry loop. Failed primary execution, failed
continuation execution, input refusal and unsupported numerical qualification
retain distinct reasons. Both fits must qualify and the raw statistic must
be at least -2e-6; an inadmissible value is preserved diagnostically, not
clamped into an admitted test statistic.

`gmfrm-procedure-contract-20261012.R` checks the complete routing against all
94 saved primary fits: 89 accept, three select segmented continuation and
two select adaptive continuation. Composition reproduces all 47 saved final
pair statistics. Constructed checks cover single-category input, independent
integration failure, start disagreement, unexpected errors, materially
negative statistics and a continuation that remains unsuccessful without
retry. Exhaustive rank/failure checks include ties and all 256 outcomes of
an exchangeable four-state experiment with a response-related failure state.

The two fixed end-to-end witnesses reuse job-001 (ordinary N20-zero) and
job-014 (N20-plus, both fits require segmented continuation). They test the
changed call path, not statistical performance. Both qualify and reproduce
the saved statistics exactly in this run: .35005535 and .07131776. Elapsed
time including setup and outer capture is 9.488 and 46.219 seconds. The
other saved fits are not re-executed. Fresh saved-only replay passes with
generation, fitting and integration blocked; the source/runtime/input bindings
are preserved under `validation-results/gmfrm-regularized-feasibility-20261012/procedure-contract/`.
No new response draws, public API, full bootstrap test or interval output are
introduced. This closes composition of the numerical research procedure,
not independent confirmation or D1 as a whole.

**Clarified mathematical target of the rank calculation.** Dufour (2006)
was rechecked in the Zotero attachment, PDF pages 9, 10 and 22 (printed
451, 452, 464), one page at a time; PDF 22 was also rendered and inspected.
Proposition 2.4 concerns exchangeable statistics and ties; Proposition 6.1
requires consistency and continuity conditions for plug-in asymptotic validity.
See the [author-hosted article](https://jeanmariedufour.research.mcgill.ca/Dufour_2006_JE_MCT.pdf).
This is targeted verification, not a new complete-paper reading.

For a *known complete generating null*, exchangeability applies to the same
fixed computed statistic on each dataset. Proof of a global optimum on every
dataset is not a prerequisite for the rank-level argument. It remains
necessary to distinguish this operational statistic from the ideal penalized
profile and to preserve numerical checks for the intended interpretation.
Changing optimization policy only for observed data breaks that common rule.
Nothing in this argument makes the estimated-nuisance generating law known.

Here is the failure completion used to justify the conservative upper rank
calculation, not to conceal missing results. Map a qualified computed statistic
T to `2*atan(T)/pi`, and a failed computation to 1. This is a fixed real-valued
statistic and preserves ordering among qualified values. For a qualified
observed value, all failed simulated values exceed it; therefore its tied-rank
p-value is `(1+a+u)/(B+1)`, where a is the number of known exceedances and u
the number of failures. For an observed failure the procedure returns
`observed_unavailable` and upper p=1, which cannot increase rejection. Thus
rejecting only when the upper p is at most alpha is conservative under the
known-law exchangeability conditions. The implementation retains `NA`, the
lower/upper rank range and unresolved status, rather than exporting an
artificial statistic or counting unavailable intervals as delivered coverage.
This is a direct completion argument for the declared computational procedure;
it does not certify the exact profile likelihood or unknown-nuisance calibration.

**Concrete oracle/plug-in comparison, not yet allocated.** For a declared
truth `(t0, eta0)`, independently generate each outer dataset and apply the
common procedure at t0. Use the same observed statistic in two diagnostic
arms: inner data generated at `(t0, eta0)` and at the constrained estimate
`(t0, eta_hat0(Y))`. The true nuisance parameter belongs only in the oracle
generator, never in fitting, starts or qualification. Within an outer dataset,
the arms may share normal Person draws and categorical uniforms to estimate
their difference with paired uncertainty. Simulation streams must remain
independent of the outer data and independent across outer replications.

The conditional difference in exceedance probabilities at the observed
statistic measures the change in the reference distribution; it is not itself
the unconditional Type I error. With complete inner pairs, estimate it by
the mean of `I_plugin-I_oracle` and use the empirical SD of these paired
differences divided by sqrt(B). Missing inner outcomes yield bounds and keep
their denominator. An outer evaluation separately estimates rejection,
retention, unresolved status and observed-source availability, as well as
paired decision differences. Reusing one reference sample for every outer
dataset would correlate outcomes and invalidate an ordinary independent-
binomial precision calculation; that shortcut is not part of this design.

The known-law rank theorem removes the need to run an oracle arm merely to
rediscover its level bound. Simulate that arm only if a paired distributional
comparison changes the method decision. The original five generating cells
and the inspected 47 datasets remain development evidence; they cannot be
relabelled as independent confirmation. The five cells do not isolate N or
target effects because nuisance values also differ. Test inversion membership
at t0 still avoids endpoint searches, but does not validate interval width,
topology, endpoint accuracy or delivered interval coverage.

**Meaningful precision and complete cost before a decision.** A finite B is
part of the tested random procedure. Its rank resolution, conditional tail
MCSE, power and outer performance are different quantities. B=19, 199 and
1999 are cost scenarios, not defaults. A small B is not automatically invalid
under a known null; nor does a large B repair plug-in error. The existing exact
Gaussian counterexample is retained rather than simulated again.

Exact binomial planning for a nonrandomized count threshold shows that a
one-sided 5%-level diagnostic of nominal
rejection .05 against actual rejection .10 needs at least R=169 independent
datasets for 80% power: reject at 14 or more, attained level .045036 and power
.806264. Against rejection .15, R=52 and a threshold of six give level .044536
and power .811894. These are diagnostics for substantial size inflation, not
coverage-equivalence acceptance criteria, allocation decisions or a change
to earlier target-specific margins. Passing one would not qualify coverage,
delivery, power, widths or other structural targets. Failures must still be
reported, with unresolved outcomes bounded rather than counted as successes.

The following arithmetic uses the completed pilot's primary plus continuation
time per pair, including failed original attempts and their independent checks.
It prices R=169 and B=199 at one null per outer dataset. Plug-in-only needs
`R*(B+1)` pairs; adding the paired oracle needs `R*(2*B+1)`, reusing each
observed pair. It excludes setup, generation, serialization and other overheads,
and is a scenario anchored to a small development sample, not a runtime bound.

| Cell | Recorded seconds per completed pair | Plug-in only, worker-hours | With paired oracle, worker-hours |
| --- | ---: | ---: | ---: |
| N20-plus | 12.9517 | 121.60 | 242.60 |
| N60-zero | 21.8282 | 204.94 | 408.86 |
| N240-zero | 80.9860 | 760.37 | 1516.94 |

Even the much weaker .15 alternative with R=52 and B=19 costs 3.74/6.31/23.40
worker-hours for these three plug-in cells, before the oracle or overhead.
N240's anchor has only three draws. Neither successful earlier feasibility nor
the label "small" makes a nested allocation cheap.

**Decision and stopping point.** Do not launch this nested allocation. It
would consume substantial resources before addressing why the proposed
nuisance calibration should be adequate. Preserve the common numerical
procedure and this comparison design; further tuning of its five repaired
fits is closed. A calibration claim needs an identified, informative regime
or a justified changed treatment of nuisance uncertainty, and target-specific
coverage/delivery criteria before independent confirmation. Fixed lambda/N
alone does not establish the consistency/continuity conditions, especially
with sparse exposure or weak identification. The operational-statistic
completion above does not solve that statistical dependency.

This is an explicit resource/method decision rather than a pending simulation
or an accepted public method. Reconsider a bounded GMFRM calibration unit
only for a concrete mathematical improvement or decision-changing comparison;
do not automatically add a nested pilot or a new optimization project. The
existing JML structural-truth dependency is the next competing research unit
to review from its retained evidence under portfolio priority 3. No promised
GMFRM/JML inference outcome or supported design is removed.

## October 12 small conditional simulation and computation review

**Purpose and fixed allocation.** At the user's request, a small conditional
simulation precedes any large study. It screens frequent refitting failures,
measures the distribution of the fitted target under a known generating
parameter, and compares actual computation strategies. It is not nested
coverage evaluation of a newly calibrated test on every outer dataset.

| Cell | Question | New datasets |
| --- | --- | ---: |
| N20, retained observed null at 0 | Does the complete numerical rule survive new small-sample responses? | 11 |
| N20, same retained source, null at +1 | What changes away from the penalty's target center? | 11 |
| N20-b19, null at 0 | Does the previously difficult source reveal a different failure mechanism? | 11 |
| N60, retained observed null at 0 | Do the smaller-sample findings transfer to the medium-N anchor? | 11 |
| N240, retained observed null at 0 | What are large-anchor computation and numerical checks on a few new draws? | 3 |

These are fitted-null *scenarios*, not an isolated causal effect of N or target:
their nuisance parameters also differ. Within each cell, independent seeds
produce new standard-normal Person abilities and conditional categorical
ratings on the unchanged roster. All 47 draws and 94 planned free/null fits
are retained. Eleven draws detect at least one failure with probability
`.9141007` when its probability is .20; ten give .8926258. Zero failures in
eleven still gives a one-sided 95% failure-probability upper bound .2384042.
This design cannot exclude rare failures or precisely calibrate 5% tails.
The N240 count is a cost/numerical sentinel, not an estimate with that detection
power. The broader package scope and prior larger-N evidence remain intact.

The first draw in each zero-null N20/N60/N240 anchor also receives free/null
adaptive-only fitting from the same two starts. Six additional fits reuse
those three datasets and do not replace primary outcomes. All starts, penalty
and final checks are held fixed; only the cheap fixed-rule initial search is
omitted in the comparator. Timings include final independent references.
These are single sequential matched comparisons, not universal speed claims.
The original three-stage loop body is checked against the frozen feasibility
source. Primary phase accounting and independent checks remain unchanged.

**Pre-generation issue found and handled.** The initial deterministic probe
revealed that the common input validator refuses a single observed score
category, even though positive definite penalization makes the mathematical
criterion coercive. The pilot now records that input-stage refusal for both
planned fits instead of redrawing or aborting all subsequent jobs. The public
validator is unchanged. Fixed probes at each endpoint exercise the refusal;
two observed endpoints with a missing interior category preserve the declared
parameter layout, original Person mapping and finite likelihood. Independent
literal/working category probabilities agree within 1.12e-16 in all five
generating cells before any random generation. Initial preflight sources are
retained separately; the finalized manifest precedes every stochastic draw.

**Mathematical interpretation.** For fixed design and a correctly specified
finite generating parameter z_g, normalization of the marginal probability
law gives `E_zg[gradient(-ell(z_g))]=0` under differentiation/integration
regularity. Therefore `E_zg[gradient Q(z_g)] = lambda*z_g`, and under the null
the tangent expectation is `lambda*U'*z_g`. Finite existence from coercivity
does not imply that the true parameter minimizes the expected penalized
criterion. Nor can expectation of the minimizer be substituted for the
minimizer of that expectation: actual estimator bias must be assessed.
Under fixed parameter dimension and suitable identification/regularity,
constant lambda enters the averaged objective as lambda/N; that observation
does not prove small-N bootstrap calibration or uniform validity near weak
identification. The earlier exact Gaussian counterexample still separates
nuisance plug-in error from optimizer failure and Monte Carlo error.

Free-fit target bias/RMSE and their Monte Carlo uncertainty in the original
summary are conditional on both the free and null fit being qualified, under
each supplied generating law. Missing fits remain visible separately.
Tail-probability intervals retain all B
comparisons, treating numerical refusals as unresolved. They do not certify
the ideal global profile statistic or the unknown true nuisance law. In
particular B=11 has minimum rank p=1/12; absence of a 5% rejection is not
evidence for nominal calibration. No new seed, tolerance, start or repetition
is added because a result is favorable or adverse.

Driver: `gmfrm-small-pilot-20261012.R`; isolated inputs, source snapshots,
seeds, each generated array and each fitting outcome are under
`validation-results/gmfrm-regularized-feasibility-20261012/small-pilot/`.
The original feasibility library and checked independent reference are reused.

**Completed original allocation.** All 47 generated datasets, 94 primary fits
and six same-data comparator fits are saved and accounted for. There were no
input refusals, exceptions or captured warnings in these random draws. Of the
94 primary fits, 89 meet the fixed numerical criteria; 43 of 47 free/null pairs
are qualified. All six adaptive-only comparator fits qualify. Every independent
reference integration itself passes its internal checks, and no primary
statistic is negative. These facts do not establish global minima or coverage.

| Generating cell | Qualified primary fits | Qualified primary pairs | Main unresolved mechanism |
| --- | ---: | ---: | --- |
| N20-zero | 22/22 | 11/11 | None observed |
| N20-plus | 19/22 | 9/11 | Three working-integral disagreements, two also failing stationarity |
| N20-b19 | 21/22 | 10/11 | One stationarity failure |
| N60-zero | 22/22 | 11/11 | None observed |
| N240-zero | 5/6 | 2/3 | One stationarity failure |

The N20-plus discrepancies are total NLL differences 1.17e-6 to 9.71e-6
against a 1e-6 limit. Two starts agree essentially exactly, but share the
same inadequate 121-point integral. For the two stationarity-only failures,
the working and independent integrals agree. Their final BFGS calls report
convergence; the subsequent PORT polish reports `singular convergence (7)`
after just one iteration, with independent total projected gradients
1.44e-4 (N20-b19) and 1.02e-4 (N240). This is not exhaustion of the 200-iteration
polish limit, and that optimizer message alone does not prove a singular
statistical model. Raising the cap would not address the observed stopping
mechanism. At N240 the two candidates straddle the gradient limit, while
their objective difference is only 3.47e-10; smallest objective and numerical
qualification remain distinct checks.

**Bounded common continuation, preserving the original pilot.** The contract
in the roadmap was frozen before this follow-up. All five failures meet its
eligibility rule. Reuse each saved candidate endpoint: choose the existing
segmented working integral for the three integral-disagreement cases, and
retain adaptive-121 for the two stationarity-only cases. Apply L-BFGS-B with
`factr=0`, total projected-gradient goal 1e-5 and the existing 200-iteration
polish budget. Since the optimizer sees Q/N, its `pgtol` is 1e-5/N; the total
penalty and final total-gradient admission threshold are unchanged. This
changes numerical evaluation/stopping, not the statistical objective. No
additional starts, response draws or tolerance relaxation are used.

All ten continued endpoints stop on the working-gradient criterion, using
5--14 function/gradient evaluations per endpoint. Both endpoints of each fit
receive the original independent reference, and all five fits then meet all
original admission criteria. Across them, independent total projected
gradients are at most 1.012e-5, NLL disagreement 1.345e-8, full standardized
gradient disagreement 1.697e-7, and between-start coordinate difference
5.609e-7. The slight excess over the internal 1e-5 working-gradient goal is
consistent with the measured integration difference and is below the unchanged
1e-4 admission threshold. There are no exceptions or captured warnings.

The largest movement from an original selected endpoint is 5.626e-5 in
standardized coordinates; the largest change in the independently evaluated
penalized objective is 4.84e-9. Thus these were numerical-precision failures
near the same solutions, not demonstrated distant local minima or evidence
that numerical polishing removes statistical bias. Two-start agreement and
stationarity still do not prove global optimality. The follow-up costs 102.631
seconds: 46.108 fitting and 56.523 independent verification of both endpoints.
No further numerical rescue is allocated.

`gmfrm-small-pilot-continuation-20261012.R` and the pilot's `continuation/`
directory retain the contract, source, every endpoint and independent check.
Fresh replay of both the original pilot and continuation passes with random
generation, optimization and integration blocked. Sources, runtime and all
original inputs/outcomes remain bound to their saved hashes. The selected
failure repair is development evidence; it does **not** turn 47/47 completed
saved pairs into an independent validation of the revised procedure.

**Cost and useful efficiency findings.** Primary fitting/refinement takes
280.776 seconds, stage/candidate review 87.934, and independent integration
349.204: 717.914 seconds (11.97 minutes) in total. Reviews and independent
references account for 60.9%. The six comparators add 183.285 seconds; the
bounded continuation adds 102.631. All recorded fit/review/reference blocks
therefore total 1,003.830 seconds (16.73 minutes). Preparation, input setup,
generation, serialization and analysis are outside these timed blocks, so this
is neither a whole-session wall time nor a CPU benchmark.

| Same generated free/null pair | Fixed-start then adaptive: seconds; qualified fits | Adaptive-only: seconds; qualified fits |
| --- | ---: | ---: |
| N20-zero, draw 1 | 8.221; 2/2 | 10.359; 2/2 |
| N60-zero, draw 1 | 23.573; 2/2 | 33.456; 2/2 |
| N240-zero, draw 1 | 64.467; 1/2 | 139.470; 2/2 |

The N20/N60 matched pairs support retaining the cheap initial search in this
development candidate. N240 cannot supply a like-quality speedup claim from
the original comparison: the faster strategy has one refusal. Independent
penalized objectives across all six matched fits differ by at most 4.19e-10,
but that agreement does not replace stationarity checks. Adaptive-only fitting
uses fewer evaluations in every pair (151/173/184 versus 233/255/195) while
taking longer; evaluation cost, not just count, determines efficiency. These
are single sequential comparisons, not stable population speed estimates.

Exact reference-pattern counts across the new draws range from 18--20 for
N20, 47--55 for N60, and 147--151 for N240. Keys include the full literal
kernel and derivative design, not just response totals. These are reuse
counts, not measured time savings. Retain the previously qualified exact
reuse, paired objective/gradient cache, early cheap searches and independent
final checks; do not start another kernel rewrite based on these counts.

**Statistical findings and resource decision.** The original success-only
N20-plus subset has mean target error -0.488720 on 9/11 pairs (MCSE .095775).
After the saved numerical failures are completed, all 11 give -0.321716
(MCSE .142117). The point corrections themselves are tiny; the change is
principally a change in the reporting denominator. N20-b19 similarly changes
from -0.095987 on 10 pairs to -0.152404 on all 11. The following descriptive
table includes all draws after the selected development continuation, rather
than presenting those original successful subsets as full-sample bias.

| Cell | Draws | Mean target error | MCSE of mean error | Target RMSE |
| --- | ---: | ---: | ---: | ---: |
| N20-zero | 11 | -0.155996 | 0.082163 | 0.303053 |
| N20-plus | 11 | -0.321716 | 0.142117 | 0.552696 |
| N20-b19 | 11 | -0.152404 | 0.106335 | 0.369185 |
| N60-zero | 11 | 0.032792 | 0.083844 | 0.267159 |
| N240-zero | 3 | 0.070571 | 0.043644 | 0.093754 |

These are estimates under five supplied generating laws, with substantial
Monte Carlo uncertainty, conditional on the fixed design and selected source
nuisance values. They neither isolate a causal N/penalty effect nor qualify
the plug-in generating law at unknown nuisance parameters. The nonzero-cell
result is compatible with the shrinkage mechanism above but does not identify
it as the sole cause. Increasing B would narrow Monte Carlo error, not remove
penalization bias or nuisance plug-in calibration error. Tail intervals in the
original summary retain unresolved draws; no 5% calibration conclusion is
drawn from B=11 or B=3.

The small allocation changed a concrete decision: the original numerical rule
is not ready for a large resampling allocation, but its observed failures have
a bounded common remedy using existing code. Retain that remedy as a candidate
and stop this optimizer branch here. Before any confirmatory study, freeze the
complete revised procedure, including input refusal and failure accounting,
and resolve the calibration claim/evaluation design using the existing
analytic counterexample and membership-at-truth principle. Any new independent
qualification must be justified and separately budgeted; it is not automatically
launched by this repair. Full inversion, extra N cells and covariance/coverage
claims remain unqualified. This scoped GMFRM work does not close JML structural
intervals or D1 as a whole, nor block independent supported user workflows.

## October 12 nonzero-null prerequisite completed

**Question and outcome.** Does the same retained regularized procedure work
when the Task-location contrast is fixed away from zero? The ten prespecified
fits (five unchanged datasets, contrast -1 and +1) all pass the original
numerical criteria and two-start agreement, with no warnings or errors.
The earlier five free fits are reused. This closes the named observed-data
prerequisite, not calibration, a continuous null range, other contrasts,
global optimality or interval coverage. No new random data or resampling ran.

**Mathematics before fitting.** Write the native contrast as `C p = t`,
`p=T z`, and `c=C T`. Use `z=z0+U u`, where `z0=c' t/(c c')`, `c U=0`,
`U' U=I` and `U' z0=0`. Thus
`||z||^2=||u||^2+t^2/(c c')`. The second term is constant during a particular
null fit but is essential to the objective used for the test statistic.
It cannot be omitted merely because it does not affect that fit's minimizer.
The frozen evaluator includes it. The constrained stationarity criterion is
the tangent gradient `U'[-T' score + lambda*z]`, not the unrestricted gradient
whose normal component supplies the Lagrange multiplier.

Before the ten fits, the extracted fixed evaluator reproduces the saved
zero-null stage for every dataset. Constraint, orthogonality, penalty
decomposition and finite-difference gradients pass at both nonzero values:
maximum constraint discrepancy 2.23e-16, squared-norm discrepancy 1.12e-16,
total-objective constant-term discrepancy 9.81e-14, and gradient discrepancy
2.15e-7 over step sizes 1e-5 and 5e-6. The fixed/adaptive escalation loop is
structurally identical to the frozen original. Numerical helper definitions
and the installed package are reused from their isolated source; the checked
pattern reference supplies final independent integration.

| Final check across the ten fits | Observed maximum | Existing limit |
| --- | ---: | ---: |
| Independent projected total gradient | 9.75e-5 | 1e-4 |
| NLL difference, working vs independent integration | 1.39e-10 | 1e-6 |
| Full standardized gradient difference | 1.94e-9 | 1e-4 |
| Objective difference between starts | 1.99e-10 | 1e-5 |
| Standardized coordinate difference between starts | 1.13e-5 | 1e-3 |

All independent integration checks pass; all constrained objectives exceed
their retained free objectives. Constraint residuals are at most 2.23e-16,
and the independent normal/tangent gradient decomposition agrees within
1.78e-15. The calculated `2*(Q_null-Q_free)` values range from 1.55634 to
113.03913; no chi-square p-values or confidence endpoints are assigned.

Of the 20 starts, five finish at fixed 61-point quadrature, fourteen after
adaptive-61 refinement, and one after adaptive-121 refinement. The last
escalation (N240, target +1, cosine start) is triggered by a projected gradient
1.01888e-4, **not** quadrature disagreement: the preceding 61/121 review has
zero recorded objective difference and gradient difference 1.44e-14. The
already specified joint accuracy/stationarity rule adds optimization work;
this is not evidence that 121 nodes were required for integration accuracy.
No tolerance relaxation, extra starts or case-specific rescue was used.

Recorded timed blocks total 96.198 seconds: fitting/refinement 14.821,
stage/candidate reviews 14.392, and independent integration 66.985. Setup and
preparatory algebra/derivative checks are outside that sum. For comparison,
the old five zero-null fit/review/reference blocks total 45.867 seconds,
excluding final candidate reviews. These are cost anchors, not interchangeable
timing definitions or predictions for new simulated data.

`gmfrm-nonzero-nulls-20261012.R` and
`validation-results/gmfrm-regularized-feasibility-20261012/nonzero-nulls/`
retain the pre-fit contract/checks, frozen source bindings, every start and
phase, ten individual results and fresh replay. Replay reconstructs all ten
decisions with generation, optimization and integration blocked. The previous
fit/source records and the public estimator remain unchanged.

**Pre-simulation method contract, without a new allocation.** For this
candidate, generate under the *constrained* regularized fit at each tested
target, including its estimated nuisance locations, steps and log slopes.
Keep the observed assignment, facet levels, maximum score and fixed N(0,1)
population law. A future draw uses one independent normal ability per Person,
shared by that Person's ratings, and conditionally independent categorical
ratings from the literal product-slope law. It does not draw Person abilities
from their observed-data posterior or structural parameters from the penalty.
The penalty is part of the estimator, not extra variation in the generating
model. The existing literal generator in `gmfrm-null-bootstrap-20261010.R`
has this fixed-normal/roster structure; its old unpenalized fitting policy
cannot substitute for the current regularized procedure.

Every future generated dataset must receive the same free and constrained
procedure, fixed lambda, standardized coordinates, starts, escalation and
admission rules as the observed data. Reuse the observed free fit across
targets, but not as the free fit of new datasets. Retain every failed draw
and distinguish definite inclusion/exclusion, unresolved comparison and
observed-source unavailability. Existing rank/Monte Carlo calculations do
not convert diagnostic quadrature differences into rigorous bounds on the
ideal optimum. The rule remains approximate nuisance plug-in calibration;
neither its finite-B correction nor these successful fits proves its level.

**Evaluate membership before endpoints.** Apply the existing October 10
[membership principle](#october-10-paired-profile-membership-diagnosis) to this
changed statistic, rather than budgeting a full null grid in every outer
replication. If the frozen randomization and failure policy defines
`C(Y,U)={t: the test at t retains t}`, then
`P(t0 in C(Y,U))=P(the test at t0 retains t0)`. For initial pointwise set
calibration, evaluate the test at the generating target t0 only. Truth selects
the evaluation point; it does not enter the candidate's fitted nuisance values
or starts. This algebra changes neither the test nor its inner B. Missing or
unresolved memberships retain all-attempt bounds, rather than being counted
as successful returns. Shared targets/methods do not create independent outer
replications. The corresponding historical population plan already uses this
distinction; it is reused here, not a new statistical method.

This can avoid repeated null searches in the initial calibration study,
but is not a measured speedup and does not establish the coverage of an
implemented interval-reporting algorithm. A separate prespecified evaluation
must still assess endpoints, width, disconnected/unbounded sets and full
interval availability, with a fixed across-null random-number mapping.
Numerical admission for the retained location contrast does not qualify all
other structural targets. The pending decision is a justified calibration
evaluation contract (targets/designs, practical margin, precision, independent
confirmation and complete cost), not another null-grid extension. The
deterministic counterexample and fixed-B calculations below remain relevant.
No bootstrap, coverage study or additional N480 task is allocated here.

## October 12 exact-pattern reference implementation

**Outcome.** The private independent marginal reference now integrates each
exact Person pattern once and restores its contribution at every original
Person position before computing likelihood, score and accumulated error
checks. The key contains responses, slopes, offsets and the complete native
location/step/slope design, sorted independently of observation order and
serialized without numeric rounding. Equal totals, or equal probabilities at
one parameter value, cannot merge different score derivatives. There is no
persistent cache or changed quadrature/tail tolerance. The fixed-normal,
unweighted, unanchored scope of this reference is unchanged; it is not a new
public estimation route, nor a change to the separate boundary reference.

`gmfrm-reference-patterns-20261012.R` checks the ten unchanged free/null states
against their saved uncompressed independent references. All ten reproduce
NLL, native score and the six precision diagnostics exactly in this R 4.6.1
run, retain every Person result and remain qualified. The two targeted test
files (`test-gmfrm-reference-patterns.R`, `test-gmfrm-run.R`) pass, including
row permutation, same-total/different-roster counterexamples, a 1e-14 input
difference, updated responses, likelihood-only evaluation and independence
from working-model arithmetic. Fresh saved-result replay passes with
integration, optimization and generation disabled. No new data or fits ran.

The frozen installed pre-change namespace supplies a fresh timing comparator
for three observed free states. Both paths use the same retained parameters,
R session and four single-thread settings. Each timing is one execution,
not a repeated benchmark or a guarantee under new data:

| State | Persons / patterns | Uncompressed reference | Pattern reference |
| --- | ---: | ---: | ---: |
| N20 free | 20 / 19 | 1.871 s | 1.860 s |
| N60 free | 60 / 56 | 5.543 s | 5.476 s |
| N240 free | 240 / 159 | 21.996 s | 20.535 s |

The N240 point timing is 6.64% shorter, **not** the 33.75% reduction in
Person integrations. Its 81 eliminated evaluations all have three ratings;
all 48 expensive 18-rating Persons remain, alongside 111 distinct three-rating
patterns. A separate key-only timing is .073 seconds. Thus evaluation count
is not a runtime weight, and pattern reduction does not justify a large new
bootstrap allocation. The ten new references total 60.752 seconds, but that
sum is not a paired end-to-end fitting comparison. This change speeds only
this independent validation calculation; optimization, public fitting and
the separate Wald reference are not timed or changed.

Results and source/input/runtime bindings are `pattern-check.rds`,
`pattern-check.log` and `pattern-replay.log` beside the existing feasibility
results. The earlier manifest, installed package and fit records stay frozen.
The subsequent nonzero observed-data null prerequisite is completed above;
the nuisance-calibration decision still precedes a pilot. No broader speed project,
additional N/truth cell or full confidence inversion follows automatically.

## October 12 null-calibration decision and precision budget

**Decision.** Finite, repeatable regularized fits justify further method work,
but do not justify launching a complete plug-in bootstrap inversion. Retain
that construction as an approximate research candidate. Do not adopt a
chi-square cutoff, claim finite-sample validity from the plus-one correction,
or launch a large nested run to compensate for unspecified nuisance treatment.
The deterministic calibration review below separates the statistical gap from
Monte Carlo precision and identifies a bounded, exact computational saving.
It adds no GMFRM data, fits, MCMC, confidence intervals or public defaults.

**Page-specific primary reading.** Dufour (2006), *Journal of Econometrics*,
133, 443--477, [doi:10.1016/j.jeconom.2005.06.007](https://doi.org/10.1016/j.jeconom.2005.06.007),
was found in Zotero as `6D9DW4D2`, attachment `7S53CJRG`. PDF pages 9, 10, 15,
16, 20, 21 and 22 (printed 451, 452, 457, 458, 462, 463 and 464) were read
individually; page 22 was also rendered and inspected. This is targeted reading,
not a claim to have read all 35 pages. Proposition 2.4 handles exchangeable
statistics and ties. Propositions 4.1--4.2 use a nuisance-space supremum.
Section 6 and Proposition 6.1 require consistency, independence of simulation
randomness and distributional continuity conditions for point-estimate plug-in
calibration. These results do not establish those conditions for small-N GMFRM.
The exact-title Berger--Boos search produced no matching library record;
unrelated fallback results were ignored.

**What the proposed test means.** At a fixed target t, continue to define
`T_t = 2[Q_null(t) - Q_free]` with the total regularized marginal objective.
The five retained t=0 statistics are 2.77052, 8.93893, 22.24478, .571629 and
.268057 (N20, N60, N240, b09, b19); these numbers are not assigned chi-square
p-values. With a known complete null generating parameter, applying the same
data-only statistic to the observed and B simulated datasets gives the
conservative tied-rank p-value `(1 + #{T_b >= T_obs})/(B + 1)`. Small B affects
resolution and stability even when that rank test has valid level. In the
candidate, however, the generating nuisance parameter is estimated from the
observed data. Its error remains as B tends to infinity.

**Analytic failure mechanism, not GMFRM performance.** Consider
`X ~ N_2((0, eta), Sigma)`, `Sigma = [[1,rho],[rho,1]]`, and penalty
`||theta||^2/2`. All optimizers have unique closed forms. Write
`H = Sigma^-1 + I`, `A = (I + Sigma)^-1`. The free estimate is `A X`, the
null estimate of eta is `U/(2-rho^2)`, where `U=X2-rho*X1`, and the penalized
profile statistic for theta1=0 is `(A X)_1^2/(H^-1)_11`.

Under the true null, U is independent of X1 and has distribution
`N(eta,1-rho^2)`. Put `d=4-rho^2`, `a=2-rho^2` and
`s=sqrt(4-3*rho^2)/d`. Conditional on U, the observed fitted first coordinate
has mean `-rho*U/d` and SD `a/d`. The plug-in bootstrap distribution instead
has mean `-rho*U/(a*d)` and SD s. Its exact 95% absolute-value cutoff is
`s*sqrt(qchisq(.95,1,ncp=(rho*U/(a*d*s))^2))`. Integrating the actual conditional
rejection probability gives the following *infinite-B* error rates at rho=.8:

| True nuisance eta | Nominal 5% rejection probability |
| ---: | ---: |
| 0 | .04274049 |
| 2 | .07562122 |
| 4 | .13207495 |
| 8 | .30978542 |

Two independent cutoff calculations (noncentral chi-square quantile and a
root of the folded-normal CDF) agree to 1.26e-14 in the integrated rates.
Integration over [-9,9] has omitted probability at most 2.26e-19; the largest
reported numerical integration error is 1.98e-11. With rho=0 the calculation
recovers .05. The profile-statistic formula is also checked against the full
quadratic objective and normal equations. Thus optimizer failure, Monte Carlo
noise and model misspecification are unnecessary for this plug-in failure.
This does not prove failure at any retained GMFRM truth or invalidate a
properly qualified regular-regime approximation; it rules out a generic
finite-sample guarantee from regularization plus parametric resampling.

**Failure accounting and precision are separate outputs.** The research
helper in `gmfrm-null-calibration-20261012.R` retains all B comparisons. If a
comparative statistic is represented by a valid enclosure, count guaranteed
exceedances a and unresolved comparisons u. The possible realized rank p-value
lies in `[(1+a)/(B+1), (1+a+u)/(B+1)]`. Exact ties count as exceedances. Failed
fits enlarge u; the observed statistic being unavailable yields an explicit
unavailable status. Neither case is removed from the denominator. Exhaustive
completion checks verify the bounds, including unknown comparisons whose
failure can depend on their value.

The same helper returns a fixed-B Clopper--Pearson tail-probability interval
using the lower endpoint for a and upper endpoint for a+u. All 20 complete
counts at B=19 reproduce `binom.test()`, and the incomplete-count enclosure
contains every completed-count interval. This is conditional Monte Carlo
uncertainty under the supplied generating law, not a structural-parameter
confidence interval and not protection against plug-in nuisance error. The
previous quadrature differences and gradient checks are diagnostics, not
rigorous bounds on global minima: passing them does not manufacture certified
statistic enclosures. Without those bounds, the envelope is numerical
sensitivity only. Ordinary fixed-B intervals also do not authorize optional
stopping or searching until a favorable p-value appears.

| B | Minimum rank p | MCSE if tail probability=.05 | Example exact 95% tail-probability interval |
| ---: | ---: | ---: | ---: |
| 19 | .05 | .0500 | [.00133, .26028], 1 exceedance |
| 199 | .005 | .01545 | [.02436, .09047], 10 exceedances |
| 1999 | .0005 | .004875 | [.04088, .06051], 100 exceedances |
| 7999 | .000125 | .002437 | [.04533, .05501], 400 exceedances |

No row is an allocated run or a recommended default. Pointwise precision near
a test boundary, interval-endpoint stability, and the validity of a randomized
finite-B test are different requirements. The number of stored targets does
not itself prescribe simultaneous coverage or a multiple-testing correction.

**How repetition counts are chosen (October 12 clarification).** Distinguish
inner B, the simulated datasets used to calibrate one observed-data null test,
from outer R, the independent datasets used to assess a complete procedure.
For a binary outcome with probability p, the planning MCSE is
`sqrt(p*(1-p)/n)`; a target MCSE e requires `ceiling(p*(1-p)/e^2)`.
This is Monte Carlo precision, not a bound on statistical bias. Near p=.05
(inner tail probability) or p=.95 (outer coverage), MCSE .005 requires 1,900
independent draws; .0025 requires 7,600. An approximate 95% Monte Carlo
half-width .01 instead requires 1,825, and .005 requires 7,299. These normal
approximations are planning examples; recorded binomial intervals describe
the achieved uncertainty. When p is not expected near those values, use the
relevant p or the conservative p=.5, which needs 10,000 draws for MCSE .005.
See Morris, White and Crowther (2019), Section 5.3,
[doi:10.1002/sim.8086](https://doi.org/10.1002/sim.8086).

For a new confirmatory allocation, first state which practically meaningful
departure changes the method decision; use that margin to set precision or
power, price the complete inner/outer procedure, and freeze its allocation
and failure handling before inspecting confirmation results. A feasibility
pilot diagnoses computation and calibration mechanisms; its count is not a
coverage guarantee. The historical four-truth point comparisons retain R=50
per condition: 600 jobs are three truths times 50 datasets times four methods,
not 600 independent draws of one performance measure. At coverage .95, R=50
has MCSE .03082. Those comparisons use their declared exploratory paired
uncertainty; they do not justify a precise nominal-coverage claim. For paired
method differences use the empirical SD of per-dataset differences divided
by the square root of the paired count. For mean bias use the corresponding
per-dataset error SD, not the binomial formula. Unavailable results and their
denominators remain explicit rather than being replaced until R successes.

B=1999 is an arithmetic illustration with rank resolution 1/2000, not a
selected resampling default. Endpoint stability also depends on how rapidly
the tail probability changes with the target; an adequate pointwise MCSE
does not by itself qualify interval endpoints. Any adaptive allocation or
stopping rule needs its own valid uncertainty treatment; ordinary fixed-count
intervals do not authorize extending a run until the desired conclusion.
Optimizer iteration limits (500 BFGS iterations in the retained feasibility
protocol) are separate safeguards, assessed using stationarity, objective and
integration checks. Neither reaching that limit nor avoiding it establishes
convergence or global optimality. No new replication allocation follows from
this clarification.

**Cost before allocation.** The recorded free/null pair costs, including both
starts, refinements, stage/candidate reviews and independent references, are
6.897 seconds for N20, 19.419 for N60 and 57.672 for N240. Multiplying by
`B+1` (one observed plus B replicated pairs) gives these single-worker scenarios:

| Saved timing anchor | B=199, one null | B=1999, one null | B=1999, 21 nulls |
| --- | ---: | ---: | ---: |
| N20 | .38 h | 3.83 h | 80.47 h |
| N60 | 1.08 h | 10.79 h | 226.56 h |
| N240 | 3.20 h | 32.04 h | 672.84 h |

These are arithmetic scenarios, not bounds or validated runtime forecasts:
new responses/nulls can change optimization difficulty; setup/generation and
other overheads are excluded. Twenty-one nulls is illustrative, not a chosen
grid. Reusing the observed free fit across nulls reduces a small fixed cost;
it does not reuse B free refits when the generated data change with the null.
An outer coverage study or an automatic 56-target inversion would add further
cost. No such allocation follows from the five successful fits.

**A concrete saving without changing the statistic.** For the retained
unweighted, fixed-N(0,1), conditionally independent model, identical complete
rosters and responses yield identical Person marginal likelihoods and scores.
With pattern multiplicity w, `ell=sum(w*ell_pattern)` and
`score=sum(w*score_pattern)`. A total score alone is insufficient; so are
matching responses with different raters. Covariates, weights, population law
or additional modeled context would have to enter the key in other designs.
The saved cases contain respectively 19/20, 56/60, 159/240, 20/20 and 19/20
distinct patterns. Reweighting existing individual reference contributions
reproduces all five free/null likelihoods and scores within 1e-10. This verifies
the reuse identity on retained data without reintegration. In N240 it could
remove 33.75% of Person integrations, not 33.75% of total runtime; bootstrap
pattern counts and actual speed gains remain unmeasured. This scoped reuse,
not a new solver or broad benchmark, was the justified efficiency change;
the implementation and measured limits are recorded above.

**Next bounded unit, now completed above.** Exact pattern reuse, comparison
with the old uncompressed oracle and the two nonzero observed-data null values
are checked under the same fixed estimator, starts and accuracy rules.
Nuisance-calibration design remains necessary before choosing a pilot. Any finite
search window remains a window, not a proven interval boundary. Full nuisance
maximization is not adopted as a shortcut: a finite grid provides a lower
bound on its supremum, and the penalty's bound on an optimizer does not bound
the true nuisance parameter. The approximate candidate still needs nuisance
sensitivity and independent calibration evidence within its declared scope.
No weaker acceptance criteria, extra N480 work or new release method is added.

`calibration-design.rds` and `.log` beside the frozen feasibility results bind
the driver, saved inputs, deterministic counterexample, precision/cost tables
and pattern replay. Random generation and optimization are blocked in this
review; no prior fits or successful numerical checks were rerun.

## October 12 regularized estimator feasibility and computation

**Decision.** The common regularized fitting rule below passes its declared
numerical feasibility checks on all five retained datasets, for both a free fit
and the affine null `Task location t1 - t2 = 0`. This removes the immediate
retained-case refitting obstacle for this *changed* estimator. It does not
qualify unpenalized MML, a confidence interval, all null values or a global
optimizer. Two matching starts are evidence of stability, not a global minimum
certificate. No production estimator, default or inferential eligibility changes.

The driver is `gmfrm-regularized-feasibility-20261012.R`; inputs, isolated
installed package, frozen driver, checks, attempt records and fresh replay are
under `validation-results/gmfrm-regularized-feasibility-20261012/`. Preparation
verified all 173 current R source files against the source of the already
checked installed package, copied that package, and bound its files and inputs.
The new execution therefore does not freeze unrelated live development.
R 4.6.1 and four single-thread environment settings are retained. No new
responses or MCMC draws were generated.

**Same estimator, cheaper search.** If native coordinates are `p = T z`, z is
the standardized orthonormal coordinate vector of the preceding mathematical
design. The total objective is `-ell(T z) + ||z||^2/2`; its gradient is
`T' * (-score) + z`. In native coordinates the penalty matrix is
`T^-T T^-1`, not a new diagonal matrix. The driver checks the penalty against
the independently expanded locations, steps and log slopes, including the
centering scale adjustments. Dividing the *whole* objective and gradient by
N for optimization leaves the minimizer unchanged; the penalty is not added
to an already averaged likelihood without this division.

An affine null uses `z = z0 + U u`, with U an orthonormal basis of the null
space and z0 satisfying the target. Checks include a nonzero target (.4),
chain-rule gradients, coordinate rotation and cache reuse. Across the five
datasets, the largest finite-difference discrepancy at either step size is
1.38e-7; penalty/coordinate discrepancies are at most 5.56e-17. These checks
test the changed objective and mapping, independently of optimizer success.

Every free/null fit uses the same two deterministic starts (zero and
`.25*cos(1:p)` in standardized coordinates), fixed lambda 1 and BFGS controls.
A shared conditional nlminb polish is used when the total projected gradient
exceeds 1e-4. The first search uses the existing vectorized 61-point fixed
normal-quadrature kernel. Its result is checked against 121-point adaptive
integration. If objective agreement (1e-6), full standardized gradient
agreement (1e-4) or projected stationarity (1e-4) fails, refinement uses
61-point adaptive integration, with the same 121-point check; a 121-point
refinement is available under the same rule. Both starts are retained and
compared. The lowest finite reviewed objective is independently evaluated by
the existing segmented Legendre/Gauss--Kronrod reference, including its own
rule and tail-error checks. Failed attempts cannot be silently excluded.

All 20 starts required the adaptive-61 refinement; none required adaptive-121
optimization. At fixed-rule candidates, objective disagreement ranged from
4.70e-6 to .0187452 and gradient disagreement reached .112645. Thus fast fixed
quadrature alone is **not** an adequate replacement, even with regularization.
After refinement, all 10 free/null results pass. Across these results:

| Check | Observed maximum | Declared limit |
| --- | ---: | ---: |
| Total projected penalized gradient, independent reference | 8.00e-5 | 1e-4 |
| NLL difference, adaptive vs independent reference | 1.17e-10 | 1e-6 |
| Full standardized gradient difference | 5.65e-9 | 1e-4 |
| Objective difference between starts | 3.18e-10 | 1e-5 |
| Standardized coordinate difference between starts | 3.13e-6 | 1e-3 |

Every independent reference also passes its existing integration checks. All
five constrained objectives exceed their corresponding free objectives. No
warnings or attempt errors occurred. Fresh replay reconstructs the ten-row
summary with optimization, numerical integration and random generation blocked.

**Measured cost and its limits.** The fixed-rule searches took 1.109 seconds
over 782 uncached evaluations; adaptive refinement took 18.464 seconds over
246. This is 19.573 seconds for all 20 searches/refinements. Stage reviews
took 9.467 seconds, final candidate reviews 4.742 seconds, and the ten
independent references 64.205 seconds: 97.987 seconds across those timed
blocks, excluding preparation, setup, initial self-checks and replay. The
stored `summary.csv` separates fit, stage-review and reference time; final
candidate-review times remain in each case's RDS record.

At five nearby prespecified parameter vectors, mean fixed/adaptive-61
evaluation times were approximately .0014/.0472 seconds for N20 and
.0028/.5192 for N240. These short profiled measurements establish a useful
search-cost difference, not a stable benchmark or an end-to-end speedup
factor. No otherwise identical adaptive-only fit was timed. Exploratory N240
profiling places about 59% of sampled time within the R probability-bundle
routine and 22% within posterior mode finding (inclusive, overlapping call
stacks); it does not identify a universal bottleneck across parameter values.
Do not extrapolate those percentages to the historical N480 campaign.

The immediate useful efficiency change is procedural: reuse the existing
fast kernel for exploration, cache paired objective/gradient calls, use
standardized coordinates, and reserve costly integration for refinement and
qualification. A new compiled solver is not needed to establish this
feasibility result. Independent checking now dominates these measured blocks;
that observation does not authorize dropping accuracy checks in a future
bootstrap. Any proposed repeated-fitting allocation must include their cost
and justify which checks can be reused under unchanged inputs and parameters.

**Next decision and limits.** Proceed to specify null calibration and its
resource/precision requirements, using these timings before allocating
resampling. Lambda 1 is still the declared main-prior feasibility reference,
not an optimized or recommended tuning value. Nuisance plug-in error,
regularization bias, behavior across the inverted null range and interval
coverage remain unresolved. One null per dataset does not validate a whole
test-inversion search, and no chi-square reference or inverse-penalty-Hessian
interval follows from these fits. No additional sample-size cell, broad
coverage run or public API is triggered automatically. This completes the
bounded estimator-feasibility unit, not D1 or the separate JML obligations.

## October 12 regularization and interval-method selection

**Decision to be made.** Can a changed estimator address escaping structural
parameters without changing the response law, while providing a defensible
route to structural confidence sets? The former continuation left no complete
repair ready for confirmation. Select full-coordinate regularized marginal
likelihood for bounded estimator-feasibility work, with null-calibrated test
inversion as the candidate interval architecture. This is a research selection,
not adoption of a new estimator or a qualified interval procedure. It targets
the prerequisite behind the retained refitting failures, not another N/truth
cell or the presumed prevalence of two adverse cases.

**Primary reading, page by page.** Uto and Ueno (2020), Zotero `IR3LFDRM` /
`K393E4IU`, PDF 12 and 13 (printed 480--481), were reread separately: identified
product slopes and Bayesian EAP with explicit structural priors. Exact Firth,
Schauberger and Sterzinger searches returned no matching library record;
semantic annotation suggestions were not treated as papers. Public primary
texts therefore supplemented the library without adding items:

- [Kosmidis and Firth (2021)](https://doi.org/10.1093/biomet/asaa052), PDF 5 /
  printed 75, read separately and visually inspected. Theorem 1/Corollary 1
  concern full-rank logistic regression. The same page explains why finite
  estimates/SEs do not ensure confidence coverage throughout an unbounded
  parameter space. Its finiteness theorem is not a theorem for latent-marginal
  GMFRM.
- [Sterzinger and Kosmidis (2023)](https://doi.org/10.1007/s11222-023-10217-3),
  PDF 6, 7 and 12 read separately; page 12 visually inspected. Section 5 gives
  a boundary-penalty argument, Section 7 distinguishes information accumulation
  from penalty strength, and Appendix B requires regularity, consistency and
  control of approximate-likelihood score error. Their logistic mixed-model
  penalty and theorems are not imported unchanged into GMFRM.

**A finite-sample limitation, not a new release requirement.** At fixed rating
assignments, finite categories give finitely many possible response arrays
`Y`. For an unbounded scalar structural target h, suppose a deterministic
procedure returns a finite upper endpoint U(y) for every possible y. Then
`M = max_y U(y)` is finite. Any parameter with h(gamma)>M is missed on every
response array, giving zero coverage. Replacing missing endpoints by finite
regularized ones cannot guarantee uniform nominal coverage over that entire
target space. This elementary extension of the finite-response argument applies
to the declared GMFRM design, not only to logistic regression. It does not
establish undercoverage at a specific retained truth or preclude useful
finite intervals on a stated domain. A justified unbounded set is distinct
from a failed endpoint search. Prior restrictions or a bounded target domain
must be explicit; neither is added here. Existing design-specific acceptance
criteria remain unchanged, and were not a promise of universally finite sets.

**Model-specific finite-estimator construction.** Let gamma contain only the
identified free structural locations, centered step coordinates and log slopes;
integrate Person abilities against the existing fixed N(0,1) law. In the
orthonormal coordinates used by `mfrm_model_export_data()`, let D be the
invertible diagonal inverse-SD matrix from the retained main setting
(marginal location/step SD 1, log-slope SD .7, including the exporter's centering
adjustments). Define, for the *total* marginal log likelihood,

`Q_lambda(gamma;y) = -ell(gamma;y) + lambda * ||D gamma||^2 / 2`,
with `lambda = 1` as a fixed feasibility reference, not a recommended strength.
Do not multiply this penalty by the number of Persons or ratings. It represents
the same structural normal density as the main posterior reference, but its
minimum is a marginal posterior mode, not EAP or a joint Person/structure mode.
There is no additional penalty on estimated Person coordinates because those
coordinates are not optimized in this marginal objective.

For finite gamma, the exact categorical marginal likelihood is continuous and
`0 < L_y(gamma) <= 1`, by dominated convergence under the fixed normal density.
Thus `Q_lambda >= lambda * ||D gamma||^2 / 2` and tends to infinity as
`||gamma||` tends to infinity. It attains a finite minimum. Any nonempty closed
affine constraint `C gamma=t` also has a finite minimum. This proves existence
for free and location/log-slope-constrained fits, even when an unpenalized finite
MLE does not exist. It proves neither uniqueness, successful optimization,
data identification nor calibrated intervals. Omitting a block from the
penalty loses this full-coordinate argument.

The argument also applies to a positive normalized fixed-quadrature mixture,
which is a probability law. It must not be asserted automatically for an
arbitrary adaptive approximation: the implemented objective, gradient and
integration error still need qualification. The definition remains the normal
marginal model, not an unannounced finite latent-class model. Under a linear
coordinate change eta=T gamma, transform the quadratic form as
`P_eta=T^-T P_gamma T^-1`; independently reassigning diagonal penalties after
changing coordinates changes the estimator. This is not a Firth correction
or a literal implementation of the published MSPL penalty.

**Why an inverse penalized Hessian is not the interval repair.** At a regular
local penalized root, a linearization gives sampling covariance of the form
`(H + lambda P)^-1 J (H + lambda P)^-T`, not simply
`(H + lambda P)^-1`. H is marginal negative-log-likelihood curvature and J is
the covariance of independent Person score contributions. Even the former
covariance does not remove penalization bias; neither expression has been
qualified for small-N GMFRM by this calculation.

An exact scalar counterexample separates these issues without simulation.
For `X ~ N(theta,1)`, penalty `theta^2/2` gives estimate `X/2`. Its sampling
SD is .5, whereas inverse penalized curvature gives SD `sqrt(.5)`. At true
theta=2, the nominal 95% interval `X/2 +/- 1.959964*sqrt(.5)` covers with
probability .779885, by the normal CDF. Using the correct sampling SD alone
gives .483995 because the center is biased. A plug-in parametric percentile
bootstrap also need not fix this: `X* ~ N(X/2,1)` and refitting gives conditional
center `X/4`, moving in the wrong direction. These are exact normal-model
counterexamples, not estimates of GMFRM coverage. Their closed-form CDF values
were evaluated in base R; direct density integration independently reproduces
the .779884906639 result within 1e-12. No random data, optimizer or MCMC was used.

**Candidate confidence-set construction, and the unresolved step.** For a
specified native location/log-slope contrast `h(gamma)=C gamma`, define

`T_t(y) = 2 * [min_{C gamma=t} Q_lambda(gamma;y) - min_gamma Q_lambda(gamma;y)]`.

Both minima exist by the argument above and the ideal statistic is nonnegative.
Finite computation does not establish a chi-square reference law. The proposed
calibration is a *null-specific* parametric bootstrap: generate full Person
rating vectors under the constrained regularized fit at t, preserving the
normal population, assignments, category ladder and fixed penalty. Every
replicate applies the same free/constrained fitting and numerical review rule.
Invert these tests over t, retaining disconnected/unbounded/undetermined sets
and all refitting failures. A finite search limit is not a confidence endpoint;
successful-only bootstrap denominators are prohibited. Original unpenalized
bootstrap draws can be stress inputs, not replicates from this changed null law.

This is an approximate composite-null procedure: fitted nuisance parameters
are not known true nuisance values. A `(1 + exceedances)/(B + 1)` calculation
controls neither that plug-in error nor weak identification. Regular interior
large-sample reasoning requires fixed structural dimension, accumulating
information, consistent roots and adequate integration; a fixed penalty becomes
small relative to total information only under those conditions. No finite-N
coverage theorem or singular-boundary bootstrap validity has been established
here. More draws would reduce Monte Carlo error without fixing nuisance error.

**Disposition and next bounded action.** Reject automatic Firth substitution,
inverse-penalty-Hessian Wald intervals, and successful-only/plain percentile
bootstrap as a generic repair. Retain explicit-prior Bayesian intervals under
their own interpretation and existing numerical flags. The regularized
marginal estimator is selected only for the next feasibility question: can
one unchanged rule evaluate and minimize the defined objective on the existing
N20/N60/N240 observed cases and b09/b19, with correctly transformed target
constraints? First reuse the saved input/source and timing evidence and check
the objective/derivative/coordinate mapping; isolate source before any fits.
No case-specific starts or favorable penalty selection follows an outcome.
Only a usable common fitting rule would justify specifying the bootstrap
allocation, Monte Carlo precision and nuisance-calibration evaluation. Neither
such an allocation nor new fitting was started in this review. D1's original
MML/JML inference obligations remain open; this selects a mathematical repair
mechanism, not a supported new API or a claim of completed method qualification.

## October 12 proper-prior posterior feasibility contract

**Question and scope.** Can one complete, data-only posterior procedure give
numerically usable structural uncertainty on the five retained diagnostic
datasets, including the two cases that prevented adoption of the continuation?
Does that uncertainty materially depend on the prior? This addresses weak
information and escaping likelihood paths directly, not the accuracy of another
local Hessian. It is a bounded alternative-method decision, not adoption of a
new default, a frequentist coverage study, or a new Bayesian release obligation.
The original MML/JML inference claims and small/medium/large-design scope remain.

Use the already verified Stan product-slope likelihood, fixed N(0,1) ability
population, L-metric, first-family sum-zero log slopes, native location
constraints and second-family centered steps. On its orthonormal free
coordinates use the existing export's proper normal priors, scaled to marginal
SD 1 for locations and steps and .7 for each component log slope. This .7 is the
previous compiled-export check's declared setting, not the public default or a
value estimated from these responses. It shrinks departures from common unit
slopes; it does not forbid genuine heterogeneity. Two prespecified sensitivity
arms multiply **all structural prior SDs** by .5 and 2, leaving the population
law unchanged. The main component-slope prior's central 95% interval is about
[.254, 3.94]; an independent cross-family product has interval [.144, 6.96].
These are substantive regularization assumptions, not universally weak priors.
The middle prior is a transparent feasibility reference, not a prior elicited
for a particular assessment or a general recommendation for users.
Changing the strength does not change the structural quantity being described,
but does change the estimator and posterior interval.

**Mathematical mechanism.** For any of these proper priors pi(gamma), every
finite response-pattern likelihood satisfies 0 < L_y(gamma) <= 1. Therefore
0 < Z_y = integral L_y(gamma) pi(gamma) dgamma <= 1 and the marginal structural
posterior exists even without a finite unconstrained MLE. Gaussian free-coordinate
priors also bound posterior moments of native coordinates and exponentiated
linear log-slope contrasts. Finite central posterior quantiles therefore exist;
this does not prove that NUTS reaches them or that the data identify each effect.
The posterior mean minimizes posterior squared-error loss for its stated target;
95% posterior mass is not 95% repeated-sampling coverage at every fixed truth.
No inverse penalized Hessian, MML SE correction or global-mode claim is used.

**Primary reading.** Zotero `IR3LFDRM` / `K393E4IU`, Uto and Ueno (2020), PDF
pages 12 and 13 (printed 480--481) were reread separately. They supply the
identification constraints, Bayesian EAP precedent and normal-prior/NUTS
description, and explicitly discuss the parameter-count/accuracy tradeoff.
The existing Appendix discrepancy and exporter covariance verification remain
applicable: this is not a literal reproduction of their Appendix priors/code.
The [Stan diagnostics guidance](https://mc-stan.org/learn-stan/diagnostics-warnings.html)
supports multi-chain, rank-R-hat, effective-sample-size and divergence checks;
the mathematical propriety argument above is model-specific reasoning here.

**Frozen computational recipe.** Reuse N20/N60/N240 observed and N20 b09/b19
from the completed-procedure manifest, with unchanged ratings, assignment,
category ladder and 56 native/contrast/slope targets. All fifteen case/prior
arms get four chains, 1,000 warmup and 1,000 retained iterations per chain,
adapt_delta .95, maximum tree depth 12 and randomized initial free coordinates
within [-.5,.5], with recorded fixed seeds. Run one chain at a time to avoid
duplicating N480's resource demand; no discretionary retries or replacement of
failed chains. Reuse the compiled, independently verified Stan model after
checking its source and executable bindings. Its generated posterior predictive
ratings are simulation output, not new coverage-study datasets.

Keep all computed means, medians and equal-tail 95% intervals, with a separate
numerical-review flag. Review every free structural/Person coordinate and all
56 targets: finite rank-R-hat <1.01, bulk and tail ESS >=400, zero post-warmup
divergences, zero tree-depth hits, chain E-BFMI >=.3, and endpoint Monte Carlo
SE <=2.5% of interval width. The tree-depth rule is a conservative candidate
delivery rule, not a claim that every depth hit proves invalid inference.
Retain diagnostics and sampling errors for every planned arm. Quantile Monte
Carlo SE quantifies sampling precision, not repeated-calibration uncertainty.
Compare prior arms by changes in target medians and widths, retaining raw values
and Monte Carlo precision; do not tune or choose the prior that resembles a
known truth or MML result. These selected cases cannot estimate bias/RMSE,
coverage or representative availability rates.

The exit is computationally feasible with stated prior sensitivity, numerical
repair required, or no useful advance. It can justify a separately designed
method comparison, not an automatic larger allocation. Source, data, prior,
executable, seed, diagnostics and posterior summaries are bound in
`gmfrm-posterior-feasibility-20261012`; fresh replay must reconstruct the tables
from saved draws without fitting, integration or new random numbers. Existing
MML likelihood/information/coverage evidence is not rerun.

### Completed posterior feasibility outcome

All fifteen prescribed arms finished four chains and saved 4,000 retained
draws per arm, with no missing chains or sampling-call errors. All 840 target
rows retain their computed means, medians and equal-tail intervals. The
`Available` field in the arm audit means **all prescribed numerical criteria
passed**, not that the other arms failed to produce intervals. Target rows
explicitly separate numerical qualification from `CoverageQualified=FALSE`.
This is fifteen case/prior computations, not fifteen independent calibration
datasets or an estimate of population availability.

| Retained case | Priors passing mixing/transition checks | Priors passing every criterion, including endpoint MCSE | Main-prior maximum endpoint MCSE / interval width |
| --- | ---: | --- | ---: |
| N20 observed | 3/3 | none | .03461 |
| N60 observed | 3/3 | none | .02860 |
| N240 observed | 3/3 | main | .02439 |
| N20 b09 | 3/3 | none | .03049 |
| N20 b19 | 2/3 | none | .03501 |

The maximum includes the declared free Person coordinates as well as the
structural targets. Fourteen arms have zero retained divergences/depth hits,
rank-R-hat <1.01, bulk/tail ESS >=400 and E-BFMI >=.3. Thirteen of those
fourteen miss only the fixed .025 endpoint-MCSE fraction rule: observed maxima
range from .02528 to .04889. These are finite-chain precision decisions, not
undercoverage, nonexistence of the posterior or failed identification. Do not
relax the rule retrospectively, report these as thirteen severe convergence
failures, or claim that merely increasing draws would fix every case.

The different case is b19 with doubled structural prior SDs: 31/4,000 retained
transitions diverge, maximum R-hat is 1.02462, minimum bulk/tail ESS are
207.17/72.80 and the maximum endpoint-MCSE fraction is .34913. Its displayed
posterior is numerically provisional. Longer retention alone does not address
that geometry problem. Sporadic rejected nonfinite-proposal messages in other
arms are retained in the original sampler output; refresh=0 does not establish
that every message arose only during warmup.

**Prior sensitivity is substantive.** Across the 56 retained targets, the
largest absolute median change relative to the main-prior interval width is
.518 for N20 observed, .454 for N60 observed, .134 for N240 observed and .531
for b09. The .504 value for b19 includes its unqualified wide-prior arm and
cannot establish a reliable wide-prior posterior. These maxima are descriptive,
target-dependent and include duplicated native/expanded targets; they are not
simultaneous tests or an isolated causal sample-size comparison.

For b19 Task t1's positive slope, the half/main/double-prior medians are
.989/1.361/2.203 and the corresponding approximate intervals are
[.577,1.715], [.553,2.961] and [.682,6.324]. All carry the above numerical
qualifications, especially the last one. More sampler precision would not make
those prior assumptions identical. The posterior can be mathematically proper
while the evidence about an individual facet effect remains prior-sensitive.

**Disposition: this fixed recipe is not qualified for general adoption.**
The component missing from the former optimizer continuation is now concrete:
a proper-prior, data-only structural posterior exists and is actually computed
on both difficult datasets, without choosing an interior MLE over a better
boundary limit. However, the complete numerical rule passes only the N240
main arm, and the smaller cases expose material sensitivity to structural
regularization. Retain this as a bounded Bayesian alternative assessment;
neither declare the MML confidence-interval problem repaired nor start a broad
Bayesian coverage study or individual-case rescue automatically. Reopening
requires a stated scientific use/prior rationale and a complete numerical
recipe addressing precision separately from geometry. No MML/JML release
claim is closed, no public estimator changes and no domain is dropped.

**Verification and cost.** The fifteen saved-draw summaries reproduce exactly
in a fresh R session with fitting, integration and RNG blocked. Independent
comparison to Stan's expanded locations, steps, slopes and direct differences
checks 56 targets at five retained draws per arm; maximum relative difference
is 4.85e-16. The older export evidence bound source but lacked a recorded
executable hash. Four existing complete-density/gradient vectors therefore
were reevaluated once against the now-bound executable, agreeing exactly;
the old fitting/coverage studies were not repeated. An initial parser typo
stopped before preparation, and the independent CSV review initially expected
bracket names where raw CmdStan uses dot names. Both harness issues were fixed;
neither required another sampler run. The fifteen recorded sampling-call times
sum to 427.023 seconds including output handling under concurrent N480 work,
not a controlled performance benchmark. All numerical thresholds and the
original fifteen-arm allocation were preserved.

### October 13 posterior reporting without new sampling

The completed 15-arm summaries were revisited to separate target precision
from the complete-arm criterion. Input summary/manifest/draw hashes were checked;
no original outcome or criterion was changed. In the 14 arms with satisfactory
mixing/transition diagnostics, 73 of 784 structural-target rows exceed the
prespecified .025 maximum endpoint-MCSE/width criterion. The targets include
dependent and duplicated transformations: this count is not an independent
success-rate estimate. N240/half has 0/56 structural-target misses despite
failing the complete-arm rule; the latter also checks free coordinates and
Persons. b19/double still has 31 divergent transitions and is not rescued by
any apparently precise target. The previous prior-sensitivity findings stand.

The public Stan bundle previously printed CmdStanR's default parameter summary
(5th/95th percentiles) and chain diagnostics, while retaining complete draws in
fit.rds. It did not write explicit 95% endpoints and their MCSE as reviewable
tables. The runner now saves fit.rds before reporting and writes:

* `parameter-summary.csv`: explicit equal-tailed 95% bounds, posterior moments,
  endpoint MCSE, R-hat and bulk/tail ESS for reported parameters/free coordinates;
* `sampler-diagnostics.csv`: original chain IDs, divergence and tree-depth counts,
  and E-BFMI;
* `posterior-summary.rds`: both tables, interval definition/level and notes.

`Rscript run.R --summarize` regenerates only these reports from fit.rds.
No CmdStan compiler or sampling call is required. Finite bounds are retained
when diagnostics warn; `interval_computed` is not a qualification flag.
The endpoint fraction is descriptive and receives no universal public cutoff.
Constant draws preserve NA diagnostic values: a known constraint must be
distinguished from a stuck chain. Guidance follows the primary
[Stan diagnostics documentation](https://mc-stan.org/learn-stan/diagnostics-warnings.html)
and [posterior quantile-MCSE documentation](https://mc-stan.org/posterior/reference/mcse_quantile.html).
Monte Carlo precision does not establish model adequacy, prior suitability or
frequentist coverage, and does not overrule chain-level concerns.

The saved-only regression uses N20/main, N240/half, b19/double and a prior ordinary
PCM export. The three GMFRM native bounds/MCSE match the saved research summaries
to 1e-12; direct pooled quantiles independently check the reported probabilities
and scales. The ordinary no-slope case and a fixed binary-step component pass.
Fresh CLI sessions for b19/double and ordinary PCM reproduce report RDS files
byte-for-byte with fit.rds unchanged and CMDSTAN set to a nonexistent path.
The focused two-family export tests pass, and changed help/tutorial excerpts
render. An initial test assertion incorrectly treated CmdStan's per-process
`num_chains` metadata as the count across CSV files; it was corrected to the
retained chain IDs. No fitting or reporting calculation needed repair for that
harness issue.

The regression driver is `inst/validation/stan-reporting-20261013.R` and output
is `validation-results/stan-reporting-20261013/`; bounded verification logs are
under `tmp/stan-reporting-20261013/`. The original exporter source, bound by the
October 12 manifest, is archived as `api-model-export-before.R` in the new
output directory. Its hash matches the old manifest; parsing the old/current
exporter gives identical executable code (only help comments changed). The
old study's exact-source replay therefore requires that archived source rather
than silently accepting a different live-file hash. Its model, draws, criteria
and results are unchanged. This closes the reporting increment, not D1 or
general Bayesian/MML/JML interval qualification. It allocates no new sampling.

## October 11 D omitted-heterogeneity counterpart comparison

The next active question is the cost of omitting genuine Task/Rater slope
variation, complementary to the retained equal-slope control. The original
N240 H-both allocation supplies four R50 cells (SD .5/1, common/rotating-pair
rosters). Their two-family outputs are already complete. The counterpart
driver adds the three missing PCM/first-owner/second-owner point-calibration
arms on exactly those ratings; it generates no responses and does not repeat
the two-family fits. The four cells share original random streams, so paired
Monte Carlo uncertainty is calculated within each cell, not by treating their
200 condition-datasets as independent replications.

The frozen free-population templates use direct fixed-quadrature MML, BFGS,
maxit 400 and reltol 1e-9, with the existing q31/61/121 integration-only source
retry. Initial finite estimates are diagnostic output; source-admitted output
is reported separately. The targets are equal-weight probability MSE on the
five-z by three-Task by six-Rater by three-category grid, normalized expected-
score MSE and first-minus-second location discrepancies on the population-SD
scale. Each comparison preserves the 50-attempt denominator, pair-return and
four-return subsets, and unavailable outcomes. Native-parameter coverage under
omitted heterogeneity is not asserted. These are descriptive R50 comparisons,
not an independent qualification or a universal model-choice rule.

The execution record is
`validation-results/mfrm-wide-map-d-counterparts-20261011/`. Its dispatch freezes
600 missing model-by-dataset jobs and 200 retained reference outputs. New phases
are atomic and resumable; two disjoint worker queues reuse the first three
completed jobs. Both the native-scale and standardized-scale literal response
laws are checked for every returned mapping. A separate deterministic output
test verifies oracle zero loss, discrepancy signs/scales, unequal availability,
paired/four-way intersections and all-attempt counts. The summary continuation
removes only `expand.grid` display metadata from the reference grid; the frozen
numerical producer and all its completed phases stay byte-identical.

Source epochs remain explicit. The retained two-family adaptive optimizer has
three changed reachable functions in current source: explicit-start handling
is inactive under its original neutral/EM policy, the expanded polishing rule
does not change its fixed-normal adaptive GPCM branch, and cumulative thresholds
are now cached at the same fixed parameter vector. Its response helper is
byte-identical. Runtime version, platform, dependency versions and thread
settings agree; the relocated R/BLAS/LAPACK binaries match the recorded SHA256s.
Current and retained additional-package code/data also agree; full package-tree
identity is not asserted because debug bundles, metadata serialization and
additional installation-provenance fields differ. Historical outputs retain
their own admission record rather than being relabeled a new-source run.

**Completed outcome.** All 600 counterpart jobs finish, with 992 fitting phases:
320 jobs stop at q31, 168 at q61 and 112 at q121. Every counterpart and all 200
retained two-family records return source-admitted points. Pair-return and
four-return subsets therefore both contain all 50 datasets per cell. The
maximum native/standardized probability discrepancy is 4.441e-16. The corrected
summary passes the deterministic accounting test and a fresh-session replay
with fitting, simulation and information calculation disabled. The saved
`comparison.rds`, `rows.csv`, `summary.csv` and `paired.csv` retain the complete
initial/admitted accounting; `replay.log` records the successful replay.

Probability MSE below is multiplied by 1,000; lower is better. It uses the
source-admitted population-relative grid, not held-out Person scoring.

| N240 condition | PCM | Task slopes only | Rater slopes only | Both slope families |
| --- | ---: | ---: | ---: | ---: |
| Common, SD .5 | 2.351 | 2.228 | 2.642 | 2.584 |
| Common, SD 1 | 3.057 | 2.737 | 2.861 | 2.523 |
| Rotating pair, SD .5 | 2.256 | 2.279 | 3.158 | 3.307 |
| Rotating pair, SD 1 | 2.695 | 2.452 | 2.905 | 2.591 |

The paired PCM-minus-two-family MSE difference is .534 (exploratory 95% Monte
Carlo interval .322 to .747) for SD1/common, but -1.051 (-1.349 to -.753) for
SD.5/rotating, on the same multiplied scale. For SD1/rotating, Task-only minus
two-family is -.138 (-.337 to .060); its mean ordering does not resolve that
comparison. These t-based Monte Carlo intervals describe sampling uncertainty
in the R50 paired loss differences; they are neither parameter confidence
intervals nor simultaneous/multiplicity-adjusted model-selection guarantees.

The location target gives a different answer. For the specified first-minus-
second Rater contrast, Task-only RMSE is .324/.160/.321/.168 in table order,
versus .444/.185/.426/.188 for two-family. These are discrepancies from the
generating standardized contrast, not coverage of a native misspecified-model
parameter. The result supports comparing both response approximation and the
assessment quantity of interest, rather than recommending the generating model
solely because it is correctly specified. It does not establish that one-family
models are generally preferable: N, slope magnitudes, their ordered alignment,
facet counts and other truths retain their uncompleted comparisons.

The bounded N240 point-comparison unit is complete. The other original
units have complete two-family SD1/common references at N20/30/40/60/120/480;
the first N120/N480 results explicitly reuse retained jobs 203/207. The completed
N20 counterpart continuation is recorded below; the remaining counterparts
retain their original allocation and larger-N controls. No new slope-sensitivity
replication allocation, public model-choice rule or GMFRM interval qualification
follows from this unit.

## October 11 D N20 matched counterpart outcome

The next bounded unit is complete: PCM, Task-only and Rater-only each finish
all 50 original SD1/common H-both inputs, reusing the 50 saved two-family
outcomes. The driver
`inst/validation/mfrm-wide-map-d-n20-counterparts-20261011.R` loads the frozen
N240 `point_job`, native mapping check and admission/retry functions unchanged.
Only input selection and the N20 collector/dispatch differ. The source-bound
results are in `validation-results/mfrm-wide-map-d-n20-counterparts-20261011/`.
No responses or two-family fits were generated. All 150 counterpart jobs finish
with 282 fitting phases (75 final q31, 18 q61 and 57 q121); none has a mapping
failure. Maximum native/standardized probability discrepancy is 9.095e-13,
below the unchanged 1e-12 check. The largest discrepancy occurs in an unadmitted
initial diagnostic. Deterministic checks cover oracle loss, unequal returns,
empty initial/admitted subsets and mapping failures. Fresh-session replay with
fitting, generation and information calculation disabled reproduces 400 rows,
eight marginal summaries and 48 paired metric/subset summaries.

**Availability is the primary limitation.** Counts below apply the respective
source procedures for response/scoring admission, not certification of native
structural parameters, interval coverage or a global maximum. The two-family
5/50 was known from retained evidence before the counterpart execution; the
new allocation nevertheless includes every original replication.

| Model | Admitted / planned | Delivery %, exact 95% Monte Carlo interval | Probability MSE x 1,000 among that model's returns | Task contrast RMSE among that model's returns | Rater contrast RMSE among that model's returns |
| --- | ---: | ---: | ---: | ---: | ---: |
| PCM | 38/50 | 76 [61.8, 86.9] | 19.735 | 24.573 | 25.275 |
| Task slopes only | 15/50 | 30 [17.9, 44.6] | 29.329 | 11.631 | 1.738 |
| Rater slopes only | 16/50 | 32 [19.5, 46.7] | 22.824 | .571 | 1.170 |
| Both slope families | 5/50 | 10 [3.3, 21.8] | 45.196 | 328.598 | 1.431 |

These marginal losses use different returned subsets and are **not a matched
ranking**. PCM, Task-only and Rater-only have respectively 5, 3 and 2 joint
returns with two-family; only replications 12 and 15 return all four models.
On those two datasets the probability MSEs x 1,000 are 14.461, 24.703, 21.056
and 38.335 in table order. All three four-return paired Monte Carlo intervals
include zero, and two selected replications cannot resolve a general ordering.
PCM minus two-family on its five joint returns is -28.860 [-37.886, -19.835]
on the multiplied scale, but that exploratory interval pertains only to this
selected returned subset, not all 50 attempts or arbitrary small-N settings.
Unavailable results have no imputed zero error or invented failure penalty.
All four arms have 50 initial finite maps; those remain diagnostics and are
not promoted to admitted results to increase a comparison's denominator.

**Passing response-source checks does not establish structural recovery.**
The large contrast RMSEs are retained, not trimmed. Saved replication 4 under
PCM has population SD .00498763, so dividing location contrasts by the estimated
SD produces a Task discrepancy of -151.444 on the generating standardized
scale. In replication 12, Task-only and two-family Task discrepancies are
-44.652 and -734.760. The saved two-family Task slopes are approximately
(.00638, 8.132, 19.281); large compensating locations coexist with a finite
response mapping. These observations explain why response discrepancy and
parameter recovery are separate targets. They do not by themselves prove the
likelihood's global geometry or justify changing the predeclared admission
rules. No outlier deletion, new optimizer rescue or retrospective cutoff is
introduced.

The PCM refusals all carry weak-category-information review. The two-family
45 refusals retain 28 convergence-related errors, 10 finer-integration/gradient
review failures and seven source-readiness reviews. One-family refusals include
category support, numerical status, integration changes and information
refinement/gradient checks; their multiple reason codes are retained rather
than summed as disjoint causes.

The generating parameters match the N240 SD1/common control exactly. Both have
20% common Persons with 18 ratings and 80% with three ratings: N20 has 120
ratings (four common Persons), N240 has 1,440 (48 common Persons). The N240
control admits all four models on all 50 replications. This supports keeping
small-sample delivery visible alongside response/contrast loss; it does not
establish a universal N cutoff or a recommendation to use PCM for every N20
assessment. N, category support, absolute linkage and slope patterns jointly
limit applicability.

This completes one additional original D response/point cell. The subsequent
N60/N480 and N30/N40/N120 completions are recorded below. Other truths/rosters
and planned magnitude/alignment sensitivity contrasts remain open; this result
does not reopen isolated optimizer rescues as a prerequisite, close D1, qualify
GMFRM intervals or change public defaults.

## October 11 D N60 and N480 matched counterpart outcome

The original N60 and N480 SD1/common H-both cells are now complete,
complementing the complete N20/N240 controls. They preserve the same generating
parameters, three Tasks, six Raters and category structure. The common-Person
assignment retains 20% with 18 ratings and 80% with three: N60 has 360 ratings
and 12 common Persons; N480 has 2,880 ratings and 96 common Persons. This is an
information/sample-size contrast within the existing design, not a new response
allocation or a universal sample-size threshold study.

`inst/validation/mfrm-wide-map-d-size-counterparts-20261011.R` binds the 300
missing PCM/Task-only/Rater-only jobs and 100 retained GMFRM outcomes. N480
replication 1 reuses retained job 207 through its original summary binding.
All retained runtime/source epochs agree with the existing reference epoch;
new fits use the unchanged current epoch and verified relocated runtime. The
N240 point-fitting and source-admission functions and the N20 numerical
collector are reused. Initial maps, admission, mapping errors, all-attempt
counts and paired/four-return conditional losses remain separate. Large
location discrepancies are not trimmed or used to tune the procedure.

Pre-fit regression detected absent mapping-error fields in older saved outputs.
Only a validated in-memory copy receives the missing metadata: an existing map
has no mapping error, and an unavailable map with no recorded error remains
unknown. Raw files, their checksums and source admission stay unchanged. The
superseded `-preflight-v1` folder contains no fitted jobs. The corrected
continuation reproduces all 2,000 N20/N240 initial/admitted rows, 40 marginal
summaries, 240 paired summaries and their consumed file hashes without fitting,
generation or information calculation. It also reproduces the original fit
specifications for both input selectors. Outputs and execution evidence are in
`validation-results/mfrm-wide-map-d-size-counterparts-20261011/`.

These compare implemented model/procedure combinations. The two-family arm
uses its retained adaptive, fixed-normal procedure; the other arms retain
fixed-quadrature, free-population fitting with the existing integration-only
retry policy. Differences in numerical delivery therefore cannot be attributed
to the number of slope parameters alone. Conditional loss comparisons remain
within each N and each declared returned subset; cells are not pooled as
additional independent replications. No general model choice, interval validity
or global-optimum guarantee follows from numerical admission.

**Completed N60 cell.** Source admission is PCM
48/50, Task-only 45/50, Rater-only 45/50 and two-family 50/50. All four return
on 42 replications. On that shared subset, probability-MSE differences against
two-family, multiplied by 1,000, are PCM -3.339 [-4.404, -2.275], Task-only
-2.411 [-3.263, -1.559] and Rater-only -1.663 [-2.632, -.694]. These exploratory
paired Monte Carlo intervals describe the returned subset, not unconditional
risk or a general model-selection rule.

All 12 counterpart refusals occur at q121 in the subsequent q241 integration
comparison. Gradient change exceeds 1e-4 in all 12; comparison gradient exceeds
1e-4 in 11, and NLL change exceeds 1e-5 in six (overlapping indicators). Thus
these records identify insufficient numerical precision under the declared
procedure, not proof of data nonidentifiability or an intrinsic inability of
the simpler models to estimate N60 data. The declared q31/61/121 fitting
schedule is retained; no outcome-specific refits or looser thresholds are used.

**Completed execution and replay.** All 300 missing counterpart jobs finish,
with 855 fitting phases: N60 uses 411 (39 final q61, 111 q121), and N480 uses
444 (six final q61, 144 q121). All 100 GMFRM outcomes are reused. There are no
mapping failures; the maximum native/standardized probability differences are
4.441e-16 and 3.331e-16 for N60 and N480. Fresh replay with fitting, simulation
and information calculation disabled reproduces all 800 initial/admitted rows,
16 marginal summaries and 96 paired metric/subset summaries. The source and
input guards pass after execution; no worker or run lock remains active.

`compare-sizes.R` in the result directory reads only the three completed
comparison files (N20, the N240 cells, and N60/N480). Its `size-comparison.rds`
binds those inputs and independently reconciles each paired mean loss
difference against the common-subset model means. It includes delivery Monte
Carlo intervals and keeps every N separate. The resulting SD1/common admission
counts are:

| Persons | PCM / 50 | Task-only / 50 | Rater-only / 50 | Two-family / 50 | All four return |
| --- | ---: | ---: | ---: | ---: | ---: |
| 20 | 38 | 15 | 16 | 5 | 2 |
| 60 | 48 | 45 | 45 | 50 | 42 |
| 240 | 50 | 50 | 50 | 50 | 50 |
| 480 | 50 | 50 | 50 | 50 | 50 |

Fifty returns from fifty attempts is an observed result, not a guarantee:
its exact 95% binomial Monte Carlo interval is .929 to 1. At N60 the intervals
are .863 to .995 for PCM and .782 to .967 for each one-family arm. Keep the
actual procedure-specific refusal reasons alongside these rates.

Probability MSE x 1,000 below uses the **same returned datasets for all four
models within each row**, with the unchanged equal-weight response grid. The
N20 row is only a two-dataset descriptive result; N60 conditions on 42 returns,
whereas N240/N480 retain all 50. These rows do not estimate one common
unconditional risk over sample sizes.

| Persons (shared returns) | PCM | Task slopes only | Rater slopes only | Both slope families |
| --- | ---: | ---: | ---: | ---: |
| 20 (2) | 14.461 | 24.703 | 21.056 | 38.335 |
| 60 (42) | 7.265 | 8.194 | 8.941 | 10.604 |
| 240 (50) | 3.057 | 2.737 | 2.861 | 2.523 |
| 480 (50) | 2.069 | 1.611 | 1.696 | 1.190 |

**Answer for these conditions.** The response-loss ordering changes across
sample size. The three simpler procedures have lower conditional response MSE
at N60, while two-family has lower response MSE at N240 and N480. At N480,
PCM minus two-family is .879 [.777, .982], Task-only minus two-family is
.422 [.328, .516], and Rater-only minus two-family is .506 [.457, .555], all
on the multiplied scale. These are exploratory paired 95% Monte Carlo
intervals, not parameter intervals or simultaneous model-choice guarantees.
They are consistent with a finite-sample tradeoff between representing genuine
heterogeneity and estimating additional parameters, but do not isolate that
mechanism from the differences in implemented numerical procedures and
returned-subset selection. The N20 row cannot qualify a general ordering.

The target still matters at N480. For the declared standardized first-minus-
second Rater contrast, Task-only RMSE is .108 versus .126 for two-family;
the paired squared-discrepancy difference is -.004144 [-.007399, -.000889].
Two-family's smaller response MSE does not make it uniformly best for this
location target. These are discrepancies from the generating contrast, not
coverage or recovery of a misspecified likelihood's native target.

**D1 disposition and D2 consequence.** The N60/N480 response/point execution
units are complete. Among the ten existing historical H-both cells with
complete two-family references, seven had matched four-model comparisons at
this stage (four N240 cells, N20, N60 and N480). The October 12 outcome below
closes N30/40/120; other truths/rosters and the separate magnitude/alignment
sensitivity requirements remain in scope. No generic minimum N, automatic model-selection
rule, new public numerical method or GMFRM interval qualification is adopted.
The public distinction between numerical admission, model comparison and
interval validity remains appropriate. D1 as a whole stays open.

## October 12 D N30, N40 and N120 matched counterpart outcome

The three remaining SD1/common H-both cells are complete. Together with the
four N240 cells and N20/N60/N480, all ten historical H-both cells with complete
GMFRM references now have the four matched model arms. This closes the ready
reference subset of D's response/point comparison, not D1, the other generating
truths/rosters or GMFRM interval inference.

**Question and implementation.** These cells fill the original intermediate-N
gaps under the same ordered positive-slope pattern, population SD1 and common-
Person assignment. They have 180/240/720 ratings and 6/8/24 common Persons,
respectively. No new ratings are generated. The separate continuation
`inst/validation/mfrm-wide-map-d-remaining-counterparts-20261011.R` reuses all
150 GMFRM outcomes, including N120 replication 1 from retained job 203, and
computes only the 450 missing PCM/Task-only/Rater-only jobs. The fitting,
admission, q31/61/121 integration-only retry, input selectors and numerical
collector remain those of the qualified preceding continuations. Actual
reference manifests, observations and source/runtime epochs match their saved
bindings. The pre-fit regression reproduces all 800 N60/N480 numerical rows,
summaries, paired losses and consumed file hashes, as well as specifications
from both input selectors, without fitting.

All 450 jobs finish with 1,166 fitting phases: 371 at N30, 392 at N40 and 403 at
N120. The final q31/q61/q121 counts are 24/31/95, 5/48/97 and 1/45/104. There are
no mapping failures; maximum native/standardized probability differences are
1.654e-14, 2.942e-15 and 3.331e-16, below the declared 1e-12 tolerance. Source and
input guards pass after execution. Fresh replay with fitting, simulation and
information calculation disabled reproduces all 1,200 initial/admitted rows,
24 marginal summaries and 144 paired metric/subset summaries. No run lock
remains. Evidence is retained under
`validation-results/mfrm-wide-map-d-remaining-counterparts-20261011/`, including
`comparison.rds`, `completion-check.rds`, `continuation-check.rds` and the run,
summary and replay logs. The new `size-comparison.rds` reuses the four completed
comparison files and independently reconciles all paired differences against
the common-subset means; the earlier comparisons remain unchanged.

**Delivery before conditional accuracy.** Each arm attempts all 50 datasets.
The table combines the completed SD1/common cells; the other three N240 SD/roster
cells retain their earlier results. Exact binomial delivery intervals remain
in the saved comparison. For example, N120's 49/50 Task-only returns have a 95%
Monte Carlo interval of .894--.999; 50/50 is .929--1, not assured delivery.

| Persons | PCM / 50 | Task-only / 50 | Rater-only / 50 | Two-family / 50 | All four return |
| --- | ---: | ---: | ---: | ---: | ---: |
| 20 | 38 | 15 | 16 | 5 | 2 |
| 30 | 44 | 35 | 26 | 24 | 11 |
| 40 | 49 | 38 | 34 | 42 | 28 |
| 60 | 48 | 45 | 45 | 50 | 42 |
| 120 | 50 | 49 | 50 | 50 | 49 |
| 240 | 50 | 50 | 50 | 50 | 50 |
| 480 | 50 | 50 | 50 | 50 | 50 |

The 75 new counterpart refusals remain in the all-attempt denominator. At N30,
28 concern integration comparison, four information refinement/inversion or
scaled-gradient checks, ten numerical readiness and three weak category
information. N40 has 24 integration, four information-review and one numerical
readiness refusal. N120's sole refusal is Task-only replication 15: q121-to-q241
NLL change is 3.044e-6, but gradient change .000387 and comparison gradient
.000399 exceed 1e-4. These are procedure-specific numerical/admission outcomes;
they do not establish data nonidentifiability. No outcome-specific refits,
threshold changes or replacement datasets are used. GMFRM retains its original
adaptive, fixed-normal procedure; the other arms retain fixed-quadrature,
free-population fitting. Numerical delivery differences therefore cannot be
attributed solely to the number of slopes.

**Response accuracy on matched returned subsets.** Probability MSE x 1,000
uses the same datasets for all four models within each row and the unchanged
equal-weight category/z/context grid. The N20 row has only two common returns.
The rows condition on different returned subsets; they are not one common
unconditional risk curve and must not be pooled as independent replications.

| Persons (shared returns) | PCM | Task slopes only | Rater slopes only | Both slope families |
| --- | ---: | ---: | ---: | ---: |
| 20 (2) | 14.461 | 24.703 | 21.056 | 38.335 |
| 30 (11) | 14.077 | 14.302 | 20.192 | 20.982 |
| 40 (28) | 10.357 | 11.963 | 13.671 | 17.231 |
| 60 (42) | 7.265 | 8.194 | 8.941 | 10.604 |
| 120 (49) | 4.651 | 4.727 | 4.930 | 5.075 |
| 240 (50) | 3.057 | 2.737 | 2.861 | 2.523 |
| 480 (50) | 2.069 | 1.611 | 1.696 | 1.190 |

The new cells' paired differences, other model minus two-family on the same
multiplied scale, have the following exploratory 95% Monte Carlo intervals.
These are t-based intervals for mean loss differences within the returned
subset, not parameter intervals or simultaneous model-choice guarantees.

| Persons | PCM minus two-family | Task-only minus two-family | Rater-only minus two-family |
| --- | ---: | ---: | ---: |
| 30 | -6.905 [-10.181, -3.630] | -6.681 [-10.254, -3.107] | -.790 [-2.130, .549] |
| 40 | -6.875 [-8.801, -4.949] | -5.268 [-7.158, -3.378] | -3.560 [-5.357, -1.763] |
| 120 | -.423 [-.757, -.089] | -.348 [-.564, -.132] | -.145 [-.402, .112] |

At N120 the PCM and Task-only procedures still have smaller response MSE;
the Rater-only difference remains uncertain. The retained N240/N480 results
favor two-family response MSE in this SD1/common design. Normalized expected-
score MSE gives the same ordering at N120 (.003485/.003604/.003774/.003921).
The transition in these observed comparisons is consistent with a finite-
sample cost of estimating heterogeneity, but does not isolate that mechanism
from numerical procedure and selection effects. It does not identify a
universal N cutoff or a generally preferred model.

**Location targets and adverse outcomes.** On N120's common 49 returns, the
specified standardized Rater contrast has RMSE .221/.215/.267/.259 in model
order PCM/Task-only/Rater-only/two-family. Task-only minus two-family squared
discrepancy is -.020808 [-.040685, -.000930]. At N480, the previously recorded
Task-only advantage for that contrast coexists with two-family's smaller
response MSE. Parameter and response targets cannot be merged into one rank.

Numerical admission also leaves large adverse outcomes visible. The retained
GMFRM Rater discrepancies are -36.549 at N30 replication 31 and -47.823 at N40
replication 16. Rater RMSE over each model's own admitted outcomes is 7.746 and
7.432 for GMFRM, whereas the four-return subsets give 3.034 and 1.054. The
matched subset is necessary for pairing, but omits some adverse outcomes when
another arm refuses that dataset. Thus both all-attempt delivery and each
arm's full admitted results remain essential. PCM at N30 replication 22 also
has Task/Rater discrepancies -32.945/28.217. None is deleted or rescued. These
are discrepancies from the generating contrast, not evidence of misspecified
native-target coverage, stable structural recovery or global optimality.

**Next D1 decision.** The ten-cell ready H-both subset is complete. The next
model-structure comparison should use the original equal-slope, Task-only and
Rater-only generating conditions, reconciling actual saved stages before
computing missing arms. Their historical input rows cover N20/60/240/480 and
both SDs/rosters; input-registry reuse flags are not a current completion ledger.
Keep the remaining original designs and the separately declared magnitude/
alignment sensitivities visible. Fix the latter's contrasts and precision
contract before generating additional responses. The earlier optimizer
candidate remains non-adopted, and this outcome does not reopen isolated
optimizer rescues as a prerequisite. D1, structural intervals and the distinct
JML/population inference obligations remain open; no public default changes.

## October 12 D N240 structural-truth control outcome

The original N240/SD1/common four-truth response/point comparison is complete.
In this design the least complex correctly specified slope structure has the
smallest probability MSE: PCM for equal slopes, Task-only for Task variation,
Rater-only for Rater variation and GMFRM when both vary. This is a descriptive
result for the declared response target and implemented procedures, not an
automatic model-selection rule or qualification of structural intervals.

**Question and design.** The earlier H-both results establish the cost of
omitting slope heterogeneity in one pattern. The original equal/first-only/
second-only controls ask whether estimating each slope family is still useful
when that family does not vary. They retain N240, SD1, the common-Person roster,
1,440 ratings, locations, thresholds and geometric means. The registry label
`historical-reduced-common` refers to the reduced generating slope structure,
not fewer ratings. Matching replications use the same roster, latent draws and
response uniforms; scores change according to the generating slopes. Models
within each truth receive identical observations. These are dependent truth
contrasts, not 200 independent replications to pool across truths.

Inspection of the 24 saved dispatch records found no compatible control stages.
`mfrm-wide-map-d-controls-20261012.R` therefore computes 600 missing point jobs
on 150 existing control datasets and reuses the 200 completed H-both outcomes.
The ordinary arms retain fixed quadrature and free-population fitting; GMFRM
retains adaptive integration and a fixed standard-normal population. Its
arguments come from the retained prototype. The unchanged point runner uses
q31/61/121 integration-only retry and the same source-admission rule. Saved-
phase qualification reproduces immediate refusal, integration retry ending
in refusal and immediate admission; it verifies the selected review and maps
with fitting and information calculation disabled. Only unused interval
consumers are omitted. Historical H-both and current-control source epochs
remain explicit, and there is no outcome-driven numerical tuning.

**Completion and delivery.** All 600 jobs finish with 1,382 fitting phases
(459/462/461 by equal/first-only/second-only truth). All 150 new GMFRM jobs are
admitted at q31. There are no mapping failures: native and independently
constructed response probabilities differ by at most 3.331e-16, below the
declared 1e-12 tolerance. Source/input checks pass and the run lock is removed.
Fresh replay with fitting, generation and information routines disabled
reproduces all 1,200 initial/admitted rows, 24 marginal summaries and 144 paired
summaries. The four-truth aggregate retains 1,600 rows and 96 all-six-pair
metric comparisons, independently reconciling the three existing contrasts
against GMFRM. Evidence, hashes and logs are under
`validation-results/mfrm-wide-map-d-controls-20261012/`, including
`qualification.rds`, `completion-check.rds`, `comparison.rds` and
`truth-comparison.rds`.

| Generating slope variation | PCM / 50 | Task-only / 50 | Rater-only / 50 | GMFRM / 50 | All four return |
| --- | ---: | ---: | ---: | ---: | ---: |
| Neither family | 50 | 50 | 49 | 50 | 49 |
| Task only | 50 | 50 | 50 | 50 | 50 |
| Rater only | 50 | 50 | 50 | 50 | 50 |
| Both families, retained baseline | 50 | 50 | 50 | 50 | 50 |

The sole new refusal is equal-truth Rater-only replication 45. The q121-to-q241
comparison gives NLL change 5.809e-8 and gradient change 4.837e-6; the comparison
gradient 1.000867e-4 exceeds the fixed 1e-4 tolerance. This near-threshold
numerical-review outcome is retained without relaxing the criterion or adding
a rescue fit. It does not establish nonidentifiability. Exact 95% binomial
delivery intervals are .894--.999 for 49/50 and .929--1 for 50/50; complete
delivery in this sample does not guarantee future delivery.

**Matched response accuracy.** Probability MSE x 1,000 uses the unchanged
equal-weight z/Task/Rater/category grid. Within each row, all four procedures
are compared on the same returned datasets. Initial diagnostics and each
arm's own admitted losses remain separately saved. For example, equal-truth
own-admitted means are 1.571/1.859/2.139/2.451, which must not be substituted
for the matched row below.

| Generating variation (shared returns) | PCM | Task-only | Rater-only | GMFRM |
| --- | ---: | ---: | ---: | ---: |
| Neither (49) | 1.581 | 1.870 | 2.139 | 2.457 |
| Task only (50) | 2.182 | 1.798 | 2.759 | 2.381 |
| Rater only (50) | 2.481 | 2.795 | 2.297 | 2.634 |
| Both (50) | 3.057 | 2.737 | 2.861 | 2.523 |

The normalized expected-score losses give the same mean ordering in every
truth. Key paired probability-MSE differences, also x 1,000, are below.
Intervals are exploratory approximate 95% Monte Carlo intervals conditional
on common returns; they are not simultaneous or independent confirmation.
All six model pairs and all four metrics remain in the aggregate.

| Generating variation | Difference (left minus right) | Mean [Monte Carlo interval] |
| --- | --- | ---: |
| Neither | PCM minus Task-only | -.289 [-.394, -.184] |
| Neither | PCM minus Rater-only | -.558 [-.669, -.448] |
| Neither | PCM minus GMFRM | -.876 [-1.052, -.700] |
| Task only | PCM minus Task-only | .383 [.308, .459] |
| Task only | Task-only minus GMFRM | -.582 [-.691, -.474] |
| Rater only | PCM minus Rater-only | .184 [.045, .324] |
| Rater only | Rater-only minus GMFRM | -.337 [-.480, -.194] |
| Both | PCM minus GMFRM | .534 [.322, .747] |
| Both | Task-only minus GMFRM | .214 [.060, .367] |
| Both | Rater-only minus GMFRM | .338 [.182, .494] |

Each row's minimum-MSE model differs from all three alternatives in the same
direction throughout its paired intervals. This demonstrates the value of
including the varying family and the cost of including an unnecessary family
for this response target at N240. It does not isolate parameter burden from
the procedures' integration/identification choices or guarantee the pattern
at smaller N, another slope magnitude, alignment or rating assignment.

**Targets and next decision.** Response accuracy and location recovery still
differ. Under Rater-only truth, the specified standardized first-minus-second
Rater contrast has RMSE .166/.166/.196/.195 in PCM/Task-only/Rater-only/GMFRM
order. PCM minus Rater-only squared discrepancy is -.01069
[-.01956, -.00182], despite Rater-only's smaller probability MSE. Under H-both,
Task-only has Rater-contrast RMSE .160 versus GMFRM .185; the squared-error
difference is -.00850 [-.01444, -.00257]. These are discrepancies from the
declared generating contrast, not coverage of a misspecified likelihood target.

This closes three original control cells and their four-truth N240 comparison.
The corresponding original N20 controls, completed below, distinguish
delivery under necessary and unnecessary slope families while reusing the
H-both cell. Their original attempts are preserved, and sparse common returns
do not qualify a ranking. N60/N480, other SDs/rosters, rubric controls and the
separate magnitude/alignment design remain open. No public estimator/default
changes, interval qualification or isolated optimizer-rescue prerequisite
follows from this outcome. D1 is not complete.

## October 12 D N20 structural-truth control outcome

The original N20/SD1/common four-truth response/point comparison is complete.
Simpler generating slope structures do not resolve the small-sample delivery
problem in this design. Only 4/3/1/2 datasets return all four models under
equal/Task-only/Rater-only/both-family variation. These subsets cannot qualify
a stable model ranking. Large structural discrepancies also occur in the
ordinary models; they must not be described as a GMFRM-only problem.

**Question and design.** The existing N20 H-both cell cannot distinguish
delivery under necessary and unnecessary slope families. The three original
controls supply that contrast while keeping N20, SD1, locations, thresholds,
slope geometric means and the common-Person roster. Each dataset contains
120 ratings: four common Persons have 18 ratings each and the other 16 have
three each. Matched truth replications reuse the roster, latent draws and
response uniforms; their observed scores differ with the generating slopes.
Each truth has its original 50 attempts, not a pool of 200 independent
replications. All four fitted models within a truth use identical observations.

The frozen `mfrm-wide-map-d-n20-controls-20261012.R` inherits the qualified
N240 specifications, point runner, independent mappings and numerical
collector. A 28-dispatch audit finds no compatible N20 control stages. Before
fitting, qualification reproduces 1,600 saved numerical rows and summaries,
750 existing job specifications and 50 retained N20 product argument sets.
The ordinary arms retain free-population/fixed-quadrature fitting, and GMFRM
retains fixed-standard-normal/adaptive fitting. The q31/61/121 integration-only
retry and source-admission rules are unchanged. Historical H-both outputs keep
their source epoch. Thus this compares the specified procedures; it does not
isolate parameter count from their scale and integration choices.

**Completion and delivery.** All 600 missing jobs finish, with 1,176 fitting
phases (398/392/386 by equal/Task-only/Rater-only truth). The 200 H-both model
outcomes are reused. Source-admission counts are below; a returned fit object
alone does not count as admission.

| Generating slope variation | PCM / 50 | Task-only / 50 | Rater-only / 50 | GMFRM / 50 | All four return |
| --- | ---: | ---: | ---: | ---: | ---: |
| Neither family | 37 | 16 | 19 | 7 | 4 |
| Task only | 36 | 19 | 19 | 4 | 3 |
| Rater only | 37 | 15 | 15 | 4 | 1 |
| Both families, retained baseline | 38 | 15 | 16 | 5 | 2 |

GMFRM admission remains 8--14% across these truths. Exact 95% binomial intervals
are .022--.192 for 4/50, .033--.218 for 5/50 and .058--.267 for 7/50; the
differences do not establish a truth-specific improvement. PCM admission is
72--76%, but this does not qualify its structural recovery. The saved aggregate
contains all delivery intervals and all six paired delivery tables. Against
GMFRM, the PCM/Task-only/Rater-only pair-return counts are 7/7/4 under equal
truth, 4/4/3 under Task-only truth, 3/1/2 under Rater-only truth and 5/3/2 under
H-both. Pairwise availability is therefore also limited for GMFRM.

The 600 new attempts produce 228 admitted and 372 refused outputs. The 135
GMFRM refusals comprise 71 convergence-review outcomes, 45 local numerical
checks and 19 source-readiness reviews. The 237 ordinary refusals comprise
93 weak-category-information records (including co-occurring numerical flags),
63 other numerical-readiness states, 68 integration comparisons and 13
ill-conditioned-information checks. These are the recorded final review
mechanisms, not demonstrations of mathematical nonidentifiability. Every
refusal is retained; none triggers a post hoc rescue or criterion change.

**Numerical checks and diagnostic exceptions.** Input/source bindings and all
600 completed-output checks pass. Fresh replay with fitting, response generation
and information routines disabled reproduces 1,200 initial/admitted rows,
24 marginal and 144 paired summaries. The four-truth aggregate keeps 1,600
rows, 24 paired delivery records and 192 metric/subset comparisons, independently
reconciling the saved contrasts against GMFRM. Evidence and hashes are under
`validation-results/mfrm-wide-map-d-n20-controls-20261012/`, including
`qualification.rds`, `completion-check.rds`, `comparison.rds`,
`truth-comparison.rds` and `replay.log`.

All admitted probability mappings pass the fixed 1e-12 tolerance. Six initial
q31 diagnostic mappings fail it and remain unavailable. A saved-fit evaluation
of the native and standardized response equations gives these maximum absolute
probability differences:

| Truth | Model | Replication | Difference |
| --- | --- | ---: | ---: |
| Equal | Task-only | 11 | 2.896e-12 |
| Equal | Rater-only | 11 | 2.714e-12 |
| Equal | Rater-only | 21 | 1.804e-12 |
| Task-only | Task-only | 11 | 3.118e-12 |
| Task-only | Rater-only | 11 | 2.176e-12 |
| Rater-only | Task-only | 43 | 1.104e-12 |

All six already fail source admission independently of this mapping check;
there is no change to the delivery table. Their native slopes reach 236--15,011,
and some standardized locations are enormous when estimated population SD is
near zero. These values accompany sensitivity to the arithmetic used for
equivalent response expressions. The threshold is not relaxed and the missing
diagnostics are not substituted. The largest difference among successful
mapping checks is 9.095e-13. Consequently this is not an all-mappings-pass
claim, and probability agreement is not evidence of structural accuracy.

**Conditional response losses.** The table reports probability MSE x 1,000
on each truth's four-return subset, with the unchanged equal-weight response
grid. Each row uses identical datasets across models, but the very small
counts are central to interpretation.

| Generating variation (shared returns) | PCM | Task-only | Rater-only | GMFRM |
| --- | ---: | ---: | ---: | ---: |
| Neither (4) | 29.174 | 43.541 | 34.580 | 48.967 |
| Task only (3) | 13.205 | 18.934 | 21.610 | 30.980 |
| Rater only (1) | 8.692 | 8.210 | 17.998 | 30.365 |
| Both (2) | 14.461 | 24.703 | 21.056 | 38.335 |

Each arm's own-admitted losses and all six pair-return comparisons remain
separately saved. For example, under Task-only truth, PCM minus GMFRM
probability MSE x 1,000 is -17.302 [-27.692, -6.913] on four pair returns,
but -17.775 [-37.431, 1.881] on three four-way returns. PCM minus Task-only
is -8.340 [-12.945, -3.735] on their 19 pair returns. These are exploratory,
approximate conditional Monte Carlo intervals, not simultaneous intervals,
independent confirmation or all-attempt risk comparisons. The Rater-only truth
has just one four-way return; no sampling interval can be estimated from it.
All 28 metric/subset records with one common return correctly retain missing
MCSE and interval endpoints. Neither an interval excluding zero on a tiny
selected subset nor a smaller conditional mean qualifies a general ranking.

**Structural discrepancies and their interpretation.** The standardized
first-minus-second location contrasts retain severe admitted errors:

| Truth | Admitted model / replication | Native population SD | Task discrepancy | Rater discrepancy |
| --- | --- | ---: | ---: | ---: |
| Equal | GMFRM / 4 | 1 (fixed) | -2.019 | -282.047 |
| Equal | GMFRM / 48 | 1 (fixed) | -.234 | 134.035 |
| Task-only | PCM / 11 | .000267 | -755.434 | -1021.518 |
| Task-only | GMFRM / 12 | 1 (fixed) | -239.927 | -.066 |
| Rater-only | Task-only / 4 | .001016 | -794.971 | -970.308 |
| Rater-only | GMFRM / 12 | 1 (fixed) | -164.649 | -.123 |

Near-zero estimated population SD magnifies the ordinary models' location
differences under the declared standardization. Fixed-SD GMFRM can instead
have very uneven component slopes and large location contrasts; for example,
Task-only-truth replication 12 has Task slopes .0131/5.599/13.586. These
observed parameter configurations distinguish two routes to unstable
structural results without claiming that they establish the unique cause or
global likelihood geometry. Numerical source admission is not structural
recovery, and common-return filtering can omit adverse admitted outputs when
another model refuses that dataset. No extreme is trimmed. Own-admitted
Rater RMSE is 118.031 for equal-truth GMFRM and 170.255 for Task-only-truth
PCM; Rater-only-truth Task-only has Task/Rater RMSE 205.262/250.533. These
summaries use different return sets and are not matched model rankings.

**Decision and remaining scope.** This closes three original N20 control
cells and their four-truth point comparison. It shows that the observed N20
delivery limitation is not restricted to data generated with both slope
families varying; it does not establish a universally preferable estimator.
The resulting priority was the original N60/SD1/common controls, now completed
below. Its H-both comparison already had 42 shared returns and lower response
MSE in the simpler arms, making the missing controls informative about
necessary versus unnecessary slope families at an intermediate information
level. N480 and other SD/roster/rubric controls, the magnitude/alignment design
and population/JML/GMFRM interval obligations remain open. No public estimator/
default, tolerance or admission rule changes, new responses, extra repetitions
or optimizer-rescue prerequisite follow from these results. D1 is not complete.

## October 12 D N60 structural-truth control outcome

The original N60/SD1/common four-truth response/point comparison is complete.
PCM has the smallest response-probability loss under all four generating
structures on their shared return sets, including truths with real slope
variation. This differs from N240, where the least complex correctly specified
slope structure has the smallest response loss. The comparison separates
representing the generating structure from minimizing finite-sample error;
it does not justify a general instruction to omit slope heterogeneity.

**Question and design.** Does the N60 advantage of simpler procedures under
H-both persist when either or both slope families are unnecessary? The three
original controls hold N60, SD1, slope geometric means, locations, thresholds
and the common-Person roster fixed. Each dataset has 360 ratings: 12 common
Persons have 18 ratings each and the other 48 have three each. Matched truths
reuse latent draws, response uniforms and assignment, so the four R50 streams
are dependent, not 200 independent replications. Models within each truth
receive identical responses. The existing H-both outcomes are retained.

Before fitting, an inspection of all 29 current dispatches found no compatible
N60 control stages. The frozen `mfrm-wide-map-d-n60-controls-20261012.R`
inherits the qualified point procedure, source-admission checks and independent
response mapping. No-fitting qualification reproduces 400 relevant N60
baseline rows and summaries, 150 ordinary specifications and 50 product
argument sets. Ordinary models retain free-population/fixed-quadrature fitting;
GMFRM retains fixed-standard-normal/adaptive fitting. The q31/61/121
integration-only retry is unchanged. This compares those procedures, not
parameter count alone, and it preserves the historical H-both source epoch.

**Completion and delivery.** All 600 missing jobs finish with 1,387 fitting
phases: 455/460/472 under equal/Task-only/Rater-only truth. Reusing 200 H-both
outcomes gives the following all-attempt accounting. Admission means passing
the numerical scoring-source rule, not simply obtaining a fit object or
establishing valid structural inference.

| Generating slope variation | PCM / 50 | Task-only / 50 | Rater-only / 50 | GMFRM / 50 | All four return |
| --- | ---: | ---: | ---: | ---: | ---: |
| Neither family | 48 | 46 | 45 | 48 | 43 |
| Task only | 47 | 44 | 44 | 50 | 41 |
| Rater only | 48 | 46 | 46 | 49 | 45 |
| Both families, retained baseline | 48 | 45 | 45 | 50 | 42 |

These 41--45 shared returns permit a more informative conditional comparison
than N20's 1--4; they still omit refused datasets. All exact binomial delivery
intervals and six paired delivery tables per truth are retained. For example,
44/50 has a 95% interval .757--.955 and 50/50 has .929--1.000: complete observed
delivery is not a guarantee of perfect delivery in repeated use.

The new jobs contain 561 admissions and 39 source refusals, all retained.
The 36 ordinary refusals are final q121-to-q241 integration reviews. Three
GMFRM outcomes fail local numerical scoring review at that same final order.
Their comparison mean gradients are 1.330e-6 (equal, replication 19), .002157
(equal, 36) and .0002180 (Rater-only, 36), exceeding the product procedure's
1e-6 criterion. The latter two also exceed its 1e-6 per-Person NLL-change
criterion, at 1.050e-5 and 2.326e-6. Ordinary and product criteria are their
respective retained rules, not a newly harmonized tolerance. These mechanisms
do not prove mathematical nonidentifiability and do not trigger case-specific
rescue work or a changed admission rule.

**Numerical checks.** Source/input bindings and completed-output checks pass.
All 600 initial maps and all 561 admitted maps pass the fixed 1e-12 probability
tolerance; the maximum absolute error is 4.441e-16. Source readiness and mapped
availability agree in every case. Fresh replay with fitting, generation and
information routines disabled exactly reproduces 1,200 initial/admitted rows,
24 marginal and 144 paired summaries. The four-truth aggregate retains 1,600
rows, 24 paired delivery tables and 192 metric/subset records and reconciles
the saved contrasts against GMFRM. Its baseline input also contains N480;
the aggregate explicitly selects only N60. Evidence and hashes reside in
`validation-results/mfrm-wide-map-d-n60-controls-20261012/`, including
`qualification.rds`, `completion-check.rds`, `comparison.rds`,
`truth-comparison.rds` and `replay.log`. No new responses or public code changes
are involved.

**Conditional response losses.** Probability MSE x 1,000 on the unchanged
equal-weight z/context/category grid is below. Within each row, all four
models use exactly the same datasets.

| Generating variation (shared returns) | PCM | Task-only | Rater-only | GMFRM |
| --- | ---: | ---: | ---: | ---: |
| Neither (43) | 5.739 | 7.408 | 8.105 | 10.130 |
| Task only (41) | 6.551 | 7.318 | 8.954 | 10.102 |
| Rater only (45) | 6.490 | 8.030 | 8.063 | 10.308 |
| Both (42) | 7.265 | 8.194 | 8.941 | 10.604 |

All twelve PCM-versus-alternative differences have exploratory paired 95%
Monte Carlo intervals below zero, on both pair-return and four-return subsets.
The normalized expected-score losses have the same direction for those
contrasts. Under Task-only truth, PCM minus Task-only probability MSE x 1,000
is -.767 [-1.284, -.251] on the 41 four-way returns; under Rater-only truth,
PCM minus Rater-only is -1.573 [-2.093, -1.053] on 45. Under H-both, PCM minus
GMFRM is -3.339 [-4.404, -2.275] on 42. Task-only versus Rater-only differences
remain uncertain under equal, Rater-only and both-family truth. The evidence
therefore does not give a strict ordering of every model pair.

These are approximate, exploratory intervals for conditional Monte Carlo
mean differences, not simultaneous intervals, independent confirmation or
all-attempt risks. Each arm's full admitted losses remain separately saved.
The N60 and N240 contrasts show different finite-sample tradeoffs in this
one slope/assignment pattern. They do not identify a universal sample-size
threshold or isolate a bias/variance mechanism from the procedures' other
differences. N20's sparse common returns remain unqualified for ranking;
their completion is not superseded by the more favorable N60 delivery.

**Structural targets.** Response loss does not determine the ordering for
standardized first-minus-second Task/Rater location contrasts. For example,
under Rater-only truth the shared Task RMSE is .220/.232/.208/.238 in the
table's model order; the smallest point value is Rater-only, but its squared-
error difference from PCM is uncertain. Shared Rater RMSE is
.299/.316/.420/.480. PCM minus Rater-only squared Rater discrepancy is
-.0871 [-.1558, -.0184], illustrating that fitting the true Rater slope family
does not automatically improve the location target at this N. Other structural
differences also remain uncertain; no common ordering is imposed.

All admitted discrepancies, including adverse ones, remain. The largest
absolute Rater discrepancy over the combined four-truth outputs is -2.678
for H-both Rater-only replication 43; equal-truth GMFRM replication 44 has
-1.319. Neither source admission nor probability-mapping agreement establishes
accurate individual structural contrasts or their interval coverage.

**Decision and remaining scope.** This closes the three original N60 control
cells and their four-truth descriptive comparison. Together with N20/N240,
it shows why delivery, response error and structural error require distinct
answers. The initial next priority was the original N480/SD1/common controls,
retaining its complete H-both comparison; the external review below now
precedes that computation. At the large-N anchor, do the missing controls
support fitting a slope family when needed and avoiding it when unnecessary?
Audit saved stages and bind only missing jobs under the original allocation
before fitting. The other SD/roster/rubric controls, magnitude/alignment design
and population/JML/GMFRM interval obligations stay open. No new responses,
extra repetitions, changed numerical rules or public-default changes follow
from these results. D1 is not complete.

## October 12 D N480 structural-truth control execution

After the bounded external correspondence check completed, the original
N480/SD1/common controls resumed as the next priority. The question is whether
fitting a slope family improves response recovery when that family varies,
and adds estimation error when it is unnecessary, at this larger information
level. H-both already has all four fitted models on its 50 original datasets.
Its result alone cannot answer the latter question. The missing equal,
Task-only and Rater-only generating controls complete the four original
N20/N60/N240/N480 anchors on this SD/roster slice. They do not answer the other
SD/roster/rubric or slope magnitude/alignment questions.

**Existing evidence and allocation.** Inspection of all 30 current dispatches
found no exact target control identifiers; the registry also has zero candidate
stages for these 150 saved datasets. Each contains 480 Persons and 2,880
ratings: 96 common Persons with 18 ratings and 384 with three. The new
`mfrm-wide-map-d-n480-controls-20261012.R` freezes 600 missing point jobs
(three truths by 50 datasets by four models). It reuses the existing H-both
cell and preserves pairing of rosters, latent draws, response uniforms,
locations, thresholds and slope geometric means. Ordinary models retain their
free normal population and relative-slope constraints; the two-family route
retains its fixed-normal population. No new responses or extra repetitions
are generated. Estimates are compared on the same population-relative targets.

**Pre-fit qualification.** The driver inherits the existing `point_job`,
`make_spec`, response mapping and numerical collector bodies and arguments.
The retained N60 qualification binds earlier retry/refusal checks; the new
no-fitting check reproduces the actual N480 baseline's 400 numerical rows,
summaries and paired losses, 150 ordinary specifications and 50 product
argument sets. It also checks the correctly specified arms under each truth
and all intended assignment counts. Source/input/runtime identities match,
and the completed external PCM comparison is bound as an input dependency.
The unchanged integration-only sequence is q31/61/121, with the existing
source-admission rule and 1e-12 response-map criterion. An initial preparation
attempt retained the N60 numeric selector while expecting N480's rating count;
the assertion stopped it before creating a dispatch or fitting. The corrected
selector passed the full qualification; both preparation logs remain saved.

**Execution and completion.** Two disjoint worker queues ran only these
missing point jobs. Each fitting/review phase is saved and checked on reuse.
`run-to-completion.sh` under
`validation-results/mfrm-wide-map-d-n480-controls-20261012/` chains estimation,
the 600-attempt completion audit, first-use summaries, the four-truth aggregate
and both fresh no-fitting replays. A failed stage stops the workflow while
preserving completed results. The inherited long-running procedure has no
new wall-clock cutoff and no outcome-driven optimizer rescue. The three old
C/E/Task lock files inspected before launch refer to processes that no longer
exist; those unrelated files were left intact.

**Completed outcome (October 12).** All 600 original point attempts completed,
and the completion audit and both fresh no-fitting replays passed. All 600
sources and mapped outputs are admitted; there are no refusals or mapping
exceptions in these three cells. The audit retains 1,488 fitting phases:
ordinary models selected q61 in 12 attempts and q121 in 438, while all 150
adaptive two-family attempts selected q31. These orders describe different
integration procedures and are not directly comparable measures of accuracy.
Maximum independent probability-mapping error is 4.44e-16 (criterion 1e-12).

Including the unchanged H-both results, each of the sixteen truth/model cells
returns 50/50, and the all-four matched denominator is 50 for every truth.
Own-admitted, pair-return and four-return subsets therefore coincide here;
they remain separate fields. Each delivery interval is [.9289, 1] under the
retained rule. Observed full delivery is not a guarantee for every future
sample. The 50-attempt denominator stays separate for each truth; shared
streams across truths are not independent extra replications.

Four-return mean squared probability error, multiplied by 1,000 (smaller is
better):

| Generating slope truth | PCM | Task-only GPCM | Rater-only GPCM | Two-family GMFRM |
| --- | ---: | ---: | ---: | ---: |
| Equal | 0.728 | 0.854 | 1.023 | 1.145 |
| Task only | 1.348 | 0.854 | 1.644 | 1.137 |
| Rater only | 1.540 | 1.682 | 1.095 | 1.229 |
| Both | 2.069 | 1.611 | 1.696 | 1.190 |

At this N the least complex procedure containing the true varying slope
families has the smallest probability loss in each row; normalized expected-
score loss has the same row minima. Exploratory paired 95% Monte Carlo
intervals separate each row minimum from all three alternatives. For example,
PCM minus Task-only loss under Task-only truth is .494 [.449, .539], PCM minus
Rater-only under Rater-only truth is .445 [.356, .534], and PCM minus GMFRM
under H-both is .879 [.777, .982], all on the displayed x1,000 scale. Under
equal truth, PCM minus GMFRM is -.417 [-.494, -.340]. These intervals measure
simulation uncertainty in mean paired losses, not parameter coverage or
simultaneous model-choice guarantees. All six pairs, including H-both's
uncertain Task-only versus Rater-only difference, remain in the saved table.

**What changes across N, and what does not.** N60's four-return subsets
(43/41/45/42 for equal/Task/Rater/both) favored PCM on probability loss in all
four truths. N240 (49/50/50/50) and now N480 (50/50/50/50) instead favor the
least complex correctly specified slope procedure for this loss. N20 has only
4/3/1/2 all-four returns and cannot support a comparable ranking. These are
separate samples under the retained common-Person design, not a demonstrated
universal sample-size threshold. They show the finite-sample cost of extra
slopes as well as the larger-sample cost of omitting slope variation. Ordinary
arms estimate a free normal population with fixed quadrature; GMFRM uses the
fixed-normal adaptive procedure. The comparison is between these complete
procedures, not an isolated causal effect of parameter count.

**Structural targets do not inherit the response-loss ranking.** Under
Rater-only truth, Rater contrast RMSE is .115/.114/.135/.132 in table order.
PCM minus Rater-only squared contrast error is -.00488
[-.00903, -.000734], despite Rater-only's smaller response loss. Under H-both,
Rater contrast RMSE is .111/.108/.133/.126; Task-only minus GMFRM squared
error is -.00414 [-.00740, -.000889]. Task contrast RMSE and the remaining
comparisons are retained in `truth-comparison.rds`. Probability loss averages
the fixed ability/context/category grid; it is not new-Person predictive
accuracy, a universal structural ranking, or an interval-coverage assessment.

**Disposition and handoff.** This closes the named N480 SD1/common control
comparison and its reconciliation with N20/N60/N240. No further N/truth cell,
response generation or optimizer rescue follows automatically. Other
SD/roster/rubric and slope magnitude/alignment questions, and the unresolved
population/JML/two-family interval claims, retain their existing scope.
After completion, the two reviewed reporting patches were integrated. The
187 numerical source files and 2,208 bound inputs were preserved; the frozen
source plus runtime/data support also passes both replays after integration.
`replay-frozen.sh` in the campaign directory uses an external temporary
workspace, so the result-tree link does not recurse into the source snapshot.
This numerical replay is distinct from the integrated-source saved-output
replay documented in the internal roadmap. Neither closes D1 or D2 overall.

## October 12 D external correspondence priority review

The user asks whether TAM/ConQuest correspondence should precede N480. For the
current D comparison, the bounded model/estimator bridge now takes priority.
The N60 results remain evidence about the specified native procedures; they
are not an external-package ranking. The existing external comparison contract
already separates equivalent models, fixed-calibration checks and alternative
facet-effect laws. This clarification changes execution order without adding
an all-engine simulation program or changing the native estimand.

**What is already supported.** The retained unit-slope RSM/PCM TAM and ConQuest
comparisons supply actual matched multifacet calibration evidence for their
specified designs. Item-only GPCM has an analytic response/scale map and
historical native TAM q31/q41 and ConQuest latent-regression comparisons.
Their original GPCM fit/raw-output objects are not supplied by the aggregate
records, so those comparisons are not relabelled current execution or joint-
covariance evidence. Fixed-calibration TAM scoring and the later constrained
mirt two-family objective/information/local-solution checks are separate valid
evidence. They do not establish a native free-estimation TAM/ConQuest many-
facet product model.

**The material model distinction.** For the current Task/Rater D model,

```text
mfrmr: log(P_k/P_(k-1)) = s_ir * (theta - b_i - rho_r - tau_rk)
s_ir = 1, a_i, c_r, or a_i*c_r in the four fitted arms.
```

An external additive-intercept design with independently estimated shared
effects has the form `s_ir*theta - d_ir,k`, with its own linear constraints
on `d`. Equality requires `d_ir,k = s_ir*(b_i+rho_r+tau_rk)` throughout the
free parameter space, not just at one fitted point. For two families it also
requires the product restriction on the context slopes. An unrestricted
generalized-item fit or an independently shared A/E/C design does not by
itself impose these relations. For example, a .5 ability-scale Rater contrast
has log-odds effects .4 and .625 at slopes .8 and 1.25; a shared additive Rater
intercept has a constant log-odds contrast instead. These are different models,
not merely different printed units or proof of an optimizer error. The current
[TAM Example 14c](https://alexanderrobitzsch.github.io/TAM/reference/tam.mml.html)
and [ConQuest A/C and scoresfree documentation](https://conquestmanual.acer.org/s4-00.html)
were checked; the distinction concerns those realized designs, not a blanket
claim that either program lacks flexible slope models.

**Current fixed-point check.** The new research runner
`mfrm-wide-map-d-external-map-20261012.R` reads replication 1 of each of the
four N60 truths and all four native model arms. This fixed index is a numerical
witness, not a selected subset for estimating performance. All 16 selected
sources happen to be admitted. It preserves the 360 observations, 60 Persons,
18 Task/Rater contexts and three categories, and reads native coordinates
directly. For native population mean mu and SD sigma, it constructs

```text
TAM AXsi[ir,k] = s_ir * (k*(mu-b_i-rho_r) - sum(h=1..k,tau_rh))
TAM B[ir,k] = k*sigma*s_ir, with z = (theta-mu)/sigma.
```

For the product model mu=0 and sigma=1. Cumulative `AXsi` is not an adjacent
threshold. Each external cell/category intercept is fixed; no free external
facet decomposition is asserted. TAM 4.3-25's plain-R and compiled probability
engines agree exactly on the five-z grid. Their probabilities differ from both
the saved and current native probabilities by at most 3.331e-16, below the
unchanged 1e-12 mapping criterion. Source/input/phase identities and fresh
replay pass, with native/external fitting, generation and native information
functions blocked. This verifies response representation and arithmetic;
it checks neither optimization, marginal-likelihood integration, information
nor sampling coverage. No new data or fits are generated.

**Current ConQuest availability.** The executable at
`/Applications/ConQuest/ConQuest` is present and has SHA-256
`61d0b87f379f1578466b789866366c5cc633d31a6c3501e872861d44ff02da48`, identical
to the retained historical binary. A `quit;` probe under x86_64 launches
ConQuest 5.47.5 Standard Version, prints `End of Program`, returns status zero
and has no stderr. Thus the October 4 absent-path observation no longer
describes the current runtime. This probe estimates no model and supplies no
new ConQuest parameter or covariance comparison. An initial shell launch
referenced the not-yet-created result directory and never started a process;
the subsequent directory creation and actual probe completed normally.

Evidence is under `validation-results/mfrm-wide-map-d-external-map-20261012/`:
`tam-map.rds`, `tam-map.csv`, execution/replay logs, and the ConQuest command/
console/stderr files. The TAM result binds the actual input phases, source,
probability function, DLL and runtime. Earlier successful simulations and
numerical checks were not rerun.

**Prospective comparison and stopping point (now completed below).** Use the retained N60/SD1/common H-both
replication 1 PCM data and native fit for an actual TAM/ConQuest freely
estimated overlap. Align observation mask, categories, centered facet/step
design, population mean/variance, likelihood constants and integration first;
bind settings and numerical criteria before execution. Explain any numerical
discrepancy without relaxing source admission or importing an external default
silently. The variable-slope native routes require the stated nonlinear
constraints or must be labelled alternative models; a different-model study
needs its own matched generating-law allocation. Reuse the constrained mirt
evidence for its actual role. Joint transformed uncertainty still requires
the relevant full covariance and does not follow from marginal SEs. Once this
bounded bridge has an explained result and explicit comparison roles, return
to N480 if no unresolved discrepancy undermines the native point comparison.
Missing interval evidence remains open without becoming an indefinite gate
on unrelated point comparisons.

### Matched PCM calibration outcome

The bounded free-estimation comparison is complete. It uses the saved
N60/SD1/common H-both replication 1 data and native PCM q121 solution from
`mfrm-wide-map-d-size-counterparts-20261011/job-0001/`. This is a deliberately
fixed numerical witness, not a performance sample or a claim that its PCM
is the generating model. The 60 Persons supply 360 observed scores among
18 Task-by-Rater contexts (720 structural missing cells), with categories
0:2. Task and Rater locations sum to zero; each Rater owns a two-step ladder
whose steps sum to zero. Thirteen free structural coordinates plus a free
normal mean and variance give 15 parameters. Both engines estimate their
parameters without receiving the native solution as a start.

**Settings fixed before execution.** TAM 4.3-25 uses explicit A/B arrays,
free mean/variance, q61/q121 equally spaced theta nodes from -8 to 8,
`maxiter=2000`, `conv=convD=convM=1e-10`, and 20 M steps. ConQuest 5.47.5 uses
`model rater + task + rater*step`, `lconstraints=items`, `sconstraint=none`,
quadrature q61/q121, `convergence=1e-8`, `deviancechange=1e-10`, and at most
2,000 iterations. `stderr=quick` is not a joint-information comparison.
The engine grids are not assumed identical merely because they contain the
same number of nodes. Their actual objectives are checked against continuous
normal integration, and each engine is checked across the two resolutions.

The original manifest binds the input/native-fit/source hashes, loaded TAM
DLL, R 4.6.1 runtime, thread settings and ConQuest executable SHA-256. It
sets mapping tolerance 1e-12, coordinate agreement 1e-4, probability agreement
1e-5, and NLL agreement per Person 1e-7. Across quadrature resolutions the
corresponding criteria are 1e-5, 1e-6 and 1e-8. The allowed relative integration
error estimate is 1e-8. No tolerance was changed after seeing results.

**Discrepancy explained rather than optimized away.** The original runner
mistook the last-facet-fast GIN output order for ConQuest's input order.
The [official format specification](https://conquestmanual.acer.org/s4-00.html#format)
requires the first declared implicit facet to cycle fastest. With
`facets=task(3) rater(6)`, the input must cycle Task within Rater, while the
exported A matrix here cycles Rater within Task. The historical additive
fixture already records this distinction. Correct exported A alone could
not establish correct response assignment; these are two separate mappings.

The initial q61 run is retained under `conquest-q61/`. Its reported deviance
is 709.993928. Independent continuous integration at its printed coordinates
reproduces that deviance within 2.428e-7 when the actual incorrect response
assignment is reconstructed. On the intended assignments, the same printed
coordinates yield deviance 740.7428448, a discrepancy of 30.7489168 from the
report. Thus the initial mismatch is an input-layout defect in this validation
runner, not evidence against the native likelihood or a need for more optimizer
iterations. `conquest-task-first-q61/` and `conquest-task-first-q121/` use only
the corrected column permutation; model, observations, settings and criteria
are unchanged. Round-trip checks recover the entire original score/NA matrix.
The initial incorrect q121 command was not executed. The original source and
outputs remain frozen; use the separate review continuation for replay.

**Independent checks and results.** The exported ConQuest 54-by-13 A matrix
matches the declared design exactly, including its category and parameter
labels, and has rank 13. TAM's returned A/B arrays and response matrix match
the inputs. Literal adjacent logits, implemented without either package's
probability kernel, supply probabilities at the same five ability values
`native_mean + native_sd * (-2,-1,0,1,2)` for all 18 contexts. For each Person,
`stats::integrate` independently integrates the response-pattern likelihood
against the standard normal over the whole real line (`rel.tol=1e-10`,
`abs.tol=0`, at most 1,000 subdivisions). The largest reported relative error
estimate is 9.984e-11. This is an adaptive numerical error estimate, not an
analytic error bound.

| Engine | Iterations | Max coordinate difference from native | Max probability difference | Continuous NLL difference per Person |
|---|---:|---:|---:|---:|
| TAM q61 | 87 | 1.848e-6 | 4.968e-7 | 8.669e-13 |
| TAM q121 | 87 | 1.852e-6 | 4.967e-7 | 8.650e-13 |
| ConQuest q61 | 37 | 3.244e-6 | 7.954e-7 | 3.004e-13 |
| ConQuest q121 | 37 | 3.244e-6 | 7.954e-7 | 2.018e-13 |

All five continuous deviances, including native, are 702.1886159 at the shown
precision. The largest discrepancy between an engine's reported NLL and its
independent continuous NLL is 5.612e-10 per Person. Between q61 and q121, TAM
changes by at most 1.431e-8 in coordinates and 1.874e-9 in probabilities;
ConQuest changes by 1e-6 and 3.015e-7 at its exported coordinates. Both grid
NLL changes per Person are below 1e-13. Every prospective criterion passes.
ConQuest's CSV `LogLikelihood` column is positive deviance; its written decimal
coordinates are evaluated as reported, without inferring hidden precision or
an undocumented rounding interval. TAM emits no warnings. ConQuest reports
deviance convergence and clean program exit. The retained native optimizer
has code 0 and `estimation_converged=TRUE`; its legacy population `converged`
alias follows `inference_ready=FALSE` and does not reverse that point-estimation
status. Its inference refusal remains unchanged.

Evidence and first-use summaries are in
`validation-results/mfrm-wide-map-d-pcm-external-20261012/`: the original and
corrected manifests, all engine inputs/outputs, `comparison.rds/.csv`,
`grid-comparison.csv`, `summary.log`, and `replay.log`. The frozen producer is
`mfrm-wide-map-d-pcm-external-20261012.R`; the correction and independent
review are in `mfrm-wide-map-d-pcm-external-review-20261012.R`. A fresh replay
reproduces the complete result exactly while native/TAM fitting, response
generation, information calculation and external process launch are blocked.
The pre-estimation ConQuest design-export probe reported that the design is
only available after estimation; it is not counted as a successful native
design preflight. Preparation-only DLL lookup and CSV header-whitespace
checks were repaired before any affected fit or manifest binding.

**What this closes.** This is independent agreement for the specified PCM
point calibration and response law. Along with the 16 fixed-point mappings
and retained constrained mirt evidence, it closes the bounded external
correspondence prerequisite for the current D point comparison. It neither
proves a global maximum nor establishes free multifacet GPCM equivalence,
joint covariance, interval coverage or performance over other datasets.
The original N480/SD1/common controls are again next, reusing their completed
H-both cell and earlier N20/N60/N240 comparisons. No new native fits, responses
or N480 jobs were launched for this bridge; D1 interval obligations stay open.

## October 11 D slope-sign and heterogeneity design review

The current D generator implements positive component slopes, not a mix of
positive and negative discrimination. Its adjacent log odds contain
`a_i*c_r*(theta-b_i-s_r-tau_rk)`, with `a_i=exp(u_i)` and `c_r=exp(v_r)`.
Negative u/v denotes a positive slope below one. This product-slope equation
and log-slope representation correspond to equations 9--10 of
[Uto and Ueno (2020)](https://doi.org/10.1007/s41237-020-00115-7);
the sensitivity magnitudes below are a local design proposal, not their
simulation settings or evidence for the current MML interval procedure.

Inspection of `mfrm-wide-map-d-inputs-20261001.R` and its saved target contracts
confirms Task slopes `exp(-.2,0,.2)` and Rater slopes .75 to 1.25, with Rater
geometric mean .985145. For their geometric-mean-preserving log-dispersion path
specified in the current roadmap, equal strengths in both families give:

| Dispersion multiplier | Task slope range | Rater slope range | Effective product range |
| --- | --- | --- | --- |
| 0, equal within families | 1--1 | .9851--.9851 | .9851--.9851 |
| .25, smaller than retained | .9512--1.0513 | .9202--1.0456 | .8753--1.0992 |
| 1, retained pattern | .8187--1.2214 | .7500--1.2500 | .6140--1.5268 |
| 2, larger than retained | .6703--1.4918 | .5710--1.5861 | .3827--2.3661 |

The exact response law implies `d E(Y|theta)/d theta = a_i*c_r*Var(Y|theta)`.
A central-difference check using the literal generator on the existing five-z
grid and all 18 rating contexts agrees within 1.916e-11; all derivatives are
positive. No responses were generated and no models fitted for this check.
A negative effective slope would reverse this direction: it is a distinct
misspecification stress condition for a positive-slope fitting model, not
ordinary positive slope heterogeneity. The law remains a valid softmax
probability law; the issue is its direction and fitted-model scope.

The existing truth also fixes a strong association between location and log
slope: Pearson correlations .9707253 for Task and .9972276 for Rater. Rater
threshold widths increase in the same order. This does not invalidate the
retained results, but prevents attributing their behavior to dispersion alone
or generalizing to arbitrary parameter alignment. The current roadmap now
requires smaller/larger and asymmetric dispersion, reversed/prespecified slope
permutations, preserved N/SD/roster coverage, and separate concentrated weak-
slope/category-support checks. Permutations preserve marginal values but may
alter more than one association, which must be reported explicitly.

The saved D input verification covers 164 condition templates and 8,200 input
rows with A/B aliases and paired views. Its `fit_calls=0` concerns input
preparation; later fitting records remain separate. The retained N240 summary
and dispatch cover 200 two-family datasets in four SD/roster cells and explicitly
exclude the other model arms. Neither artifact establishes completion of the
four-model comparison. The earlier Rater-slope-.2 screen has a saved input/
probability preflight; that is not matched-method performance evidence.
Original inputs and estimates are unchanged; no new sensitivity simulation
allocation or sign-reversing fitted-model capability is added by this review.

## October 11 complete-procedure feasibility contract

The active roadmap question is evaluated on the five already selected
multi-category datasets: N20/N60/N240 observed, and N20 b09/b19. These are
diagnostic cases, not independent performance replications. No responses,
truth-based starts, extra starts or null-constrained fits are allocated.

The baseline is public adaptive/direct MML, fixed N(0,1), GH31 initialization,
neutral plus EM (500 iterations, M-step 100, score tolerance 1e-6), BFGS with
maxit 500 and reltol 1e-10, including the existing adaptive refinement and
optimizer review. Select the lowest finite terminal objective, retaining a
better unfinished result rather than replacing it with a worse passing one.

The single candidate is **adaptive-initialized segmented estimation**. Run
that baseline on the same observations, then use its selected native vector
and the neutral vector as the two prescribed starts of the existing private
rater-intercept-chart procedure (PORT maxit 400, N-scaled objective,
Legendre 16/32, native interior finish, independent 32/64 and literal reference).
All-start agreement, reference score, integration, curvature and full-joint
Wald/log-Wald guards remain unchanged. An unavailable finite baseline vector
leaves this candidate unavailable; there is no discretionary replacement.
This is a deterministic data-only recipe, not a new public default.

An independently evaluated baseline point is also a feasible likelihood
comparison. Previously found feasible/limiting witnesses challenge the final
answer separately; they are not initialization inputs or an automatic boundary
search. A challenged interior answer cannot qualify this candidate. Boundary,
unfinished, integration disagreement and information refusal remain outcomes.
The original Task/Rater contrasts, slopes and other structural targets remain;
conditional Person scoring is not a substitute.

The three observed-case starts already came from precisely this public
baseline. Reuse their bound fit/search/finish records, and the neutral search
in both adverse cases. Only b09/b19 need a same-data public fit and the ensuing
adaptive-start segmented path. Reuse matching independent information at an
identical selected point. Record fresh reference checks separately from old
optimization. No successful optimization is repeated merely to connect stages.
Source, data, settings and runtime bindings are checked before execution.

The exit decision is retain the baseline, qualify this one numerical revision
for a separately specified statistical evaluation, or name a concrete remaining
method defect. A selected example alone, or more explicit refusals alone, is
not evidence of improvement. No coverage allocation or public adoption follows
automatically. Evidence and driver use `gmfrm-complete-procedure-20261011`.

**Completed decision: retain the public baseline; do not adopt this continuation
as a repair or allocate its coverage study.** The three observed data-to-interval
connections pass, reusing their searches, finishes and matching full information.
The 56 targets per case preserve the earlier 55 targets and add the Task
first-minus-second contrast. They are numerical intervals, not coverage evidence.

| Observed case | Baseline independent maximum native score | Candidate score | Independent NLL improvement |
| --- | ---: | ---: | ---: |
| N20 | 1.364e-5 | 2.908e-8 | 8.538e-11 |
| N60 | 3.565e-5 | 3.405e-11 | 6.941e-11 |
| N240 | 2.695e-5 | 1.615e-11 | 1.410e-11 |

These are refinements of existing finite solutions, not recovery of the
documented difficult sources. On b09, the newly computed same-data public
baseline selects the EM-derived solution with optimizer code 0 but gradient
review; the independent maximum native score is 2.085e-4. Its fixed public
procedure takes 114.767 seconds. It supplies no new qualified interval result.

**Necessary-condition stopping decision.** Both adverse datasets already have
bound neutral-path candidates with `boundary_review_required`; b19 additionally
has working/reference disagreement. The unchanged complete-start selector
requires every prescribed start to be qualified. If the missing adaptive path
is unqualified, it returns `no_qualified_candidate`; even if that path becomes
qualified, it returns `incomplete_start_qualification`. Thus neither missing
endpoint can make this candidate return an interval in those cases. This
follows from the actual selector and the retained endpoints, not a prediction
of how the new optimizer will behave.

The b09 adaptive search was therefore interrupted after 193.7 recorded seconds;
b19's new baseline/search was not launched. The initial five-case execution plan
is retained with this explicit amendment. There are **three completed connections
and two logical non-admission decisions**, not five completed fitting attempts.
The interrupted path is not counted as a statistical failure, and no endpoint,
runtime-to-completion or representative failure frequency is imputed. This
dependency check could have been made before starting that extra search; it
does not justify a time-limit extension or another start.

The all-start policy may itself merit a different mathematical design, but
dropping it here would define another procedure: an interior stationary point
alone cannot dismiss a better boundary or unfinished solution. No such change
is adopted from these selected cases. The present evidence neither proves a
global maximum nor nonexistence of an interior maximum. Source/boundary handling
and small-sample structural interval performance remain unresolved obligations.
The missing data-only connection has a specified recipe; **a useful repair has
not been established**, so the GMFRM D1 inference claim remains open.

`validation-results/gmfrm-complete-procedure-20261011/decision.R` binds all
completed phases and checks the selector's necessary condition in both possible
qualification states of the missing path. A fresh replay disables generation,
optimization and integration and checks all 168 computed interval rows against
the full covariance. `decision.rds`/`decision.csv` distinguish completed and
unexecuted work. The R 4.6.1 platform, package versions, BLAS/LAPACK and thread
settings match the reused calculation; the unavailable relocated executable
was not rebuilt. No public estimator, default, help, plot or coverage claim
changes. The next D comparison is specified in the current roadmap.

## October 11 matched standardized-contrast comparison

**Question and fixed reanalysis contract.** Under the retained PCM generating
model, does estimating an unnecessary Criterion slope family improve the
population-SD-standardized Rater and Criterion 1-minus-2 contrasts? Reuse the
eight complete paired-L1 cells in the original portable PCM comparison:
N20/30/60/240/480 at SD1, and N20/60/240 at SD.5, fifty datasets per cell.
The paired arms are PCM-MML-free and GPCM-MML-free. Both estimate the normal
population, use identical responses, and contain the generating model. This
is the equal-slope control for D's rubric comparison, not evidence about
omitting a genuinely varying slope family or the two-family historical design.
The remaining N40/N120, roster and truth comparisons stay open.

Preserve each target's originally selected native interval stage and numerical
refusals, including earlier source epochs. Transform its point and full joint
covariance to d/sigma using the complete delta derivative; do not select a
different fit using the resulting coverage or substitute later numerical
repairs. Report every planned attempt, returned intervals, conditional and
all-attempt inclusion, bias, RMSE, empirical SD, RMS model SE and mean width.
For model differences use paired squared-error contributions on common
returns, with their Monte Carlo SE and both original availability counts.
Retain the generating SD, never the realized sample SD, in the truth. R50 is
descriptive development evidence, not independent confirmation or a new
acceptance margin. Independent scalar covariance propagation checks the full
Jacobian calculation. No fitting, information calculation, scoring, new
response generation, default change or model-selection rule is allocated.

**Completed reanalysis.** All 800 saved model records and 1,600 target rows
reconcile with the original output summaries, selected fitting stages,
response bundles and full covariance. All transformed points are finite;
refused intervals remain refused. The full-Jacobian and independent scalar
variance calculations agree for every returned interval. The table gives
Criterion-contrast RMSE on the **same interval-returning datasets in each
pair**, not a comparison of different successful subsets. Positive MSE
differences favor PCM. MCSE describes the paired squared-error mean, not the
uncertainty of an individual fitted contrast.

| N | Generating SD | PCM / GPCM interval returns, each out of 50 | Common returns | PCM / GPCM Criterion RMSE | GPCM minus PCM MSE (MCSE) |
| --- | --- | --- | ---: | --- | --- |
| 20 | 1 | 49 / 47 | 47 | .3113 / .4006 | .06357 (.02815) |
| 30 | 1 | 50 / 50 | 50 | .2314 / .3095 | .04225 (.03306) |
| 60 | 1 | 50 / 50 | 50 | .1648 / .1708 | .00199 (.00138) |
| 240 | 1 | 47 / 42 | 39 | .0898 / .0901 | .000069 (.000402) |
| 480 | 1 | 18 / 24 | 6 | .0565 / .0564 | -.000007 (.000218) |
| 20 | .5 | 44 / 41 | 41 | .6602 / 1.4211 | 1.58363 (.95001) |
| 60 | .5 | 48 / 49 | 47 | .3712 / .5277 | .14065 (.14415) |
| 240 | .5 | 22 / 27 | 13 | .1723 / .1951 | .00840 (.00495) |

Rater-contrast differences have both signs. At N20/SD1, the common-return
RMSEs are .4142/.3846 (PCM/GPCM), with MSE difference -.02362 (MCSE .02893);
at N30 they are .2424/.2596. An unnecessary slope family therefore does not
provide a consistent accuracy gain across these severity/difficulty targets.
This is evidence against assuming that extra flexibility automatically helps;
it is not a universal PCM recommendation or a validated selection rule.
The original larger-N numerical refusals heavily restrict common returns.
Later stationarity/scoring continuations are separate records; these counts
are not current-package capacity limits or post-repair interval performance.

Coverage alone is particularly misleading at N20/SD.5. Criterion intervals
contain truth in 43/44 PCM and 39/41 GPCM returns, but their mean widths are
6.9798 and 8.2376 population SD units. Returned-and-containing fractions are
43/50 and 39/50; the exact conditional coverage intervals are [.8798,.9994]
and [.8347,.9940]. Among all fifty finite points, the GPCM Criterion RMSE is
3094.63, dominated by already refused near-boundary solutions; it is 1.4211
among its 41 interval returns. Both summaries remain visible. In the most
extreme refused point, native difference -.84675 divided by fitted SD .00003877
becomes -21841.33. No fit is rescued, removed or promoted based on this finding.
Even numerical admission does not ensure a useful ratio interval in a
weakly estimated population. Across returned rows, full-joint SE divided by
the incorrect fixed-SD SE ranges from .4688 to 11.2240: cross-covariance can
reduce or increase variance, so a universal SE inflation is not the remedy.

**D1 disposition.** The saved equal-slope control now has an explicit
common-scale descriptive comparison. General small-N interval usefulness,
nominal coverage, omitted-heterogeneity comparisons and the full two-family
question remain unresolved. The next comparison must retain those different
truths and a declared estimation/selection procedure; neither another
unchanged-Wald confirmation nor general model simplification follows from
this control. N40/N120 and the remaining assignment/exposure conditions have
not been silently qualified. No release obligation or public default changes.

The driver is `inst/validation/mfrm-standardized-comparison-20261011.R`;
`validation-results/mfrm-standardized-comparison-20261011/` contains all rows,
32 marginal summaries, 16 paired summaries and the source/input bindings.
The original native source epoch is retained, without claiming current-source
readmission. The first two read-only attempts stopped at a wrong saved-data
field and a nonexistent whole-eight-arm summary path. The corrected check uses
the sealed calibration input and verifies every completed MML output directly;
available prior aggregate hashes are verified as well. Neither interruption
changed or reran a numerical phase. No production R code changed.
Fresh-session replay reproduces the complete saved comparison exactly with
fitting/information/scoring blocked. The 5,708 consumed evidence-file hashes
and analysis/production-source hashes remain unchanged, and all three CSVs
agree with the saved result. The GPCM guide's extracted R code parses and its
full HTML renders with estimation chunks disabled. A literal-text check needed
HTML line-break normalization after that successful render; no rerendering or
model calculation was necessary. No full-package check or new sampling study
was run for this evidence-and-prose change.

## October 11 fit-bundle export repair

The defect recorded below is resolved. The ordinary/one-family `fit` plot
returns three plot-data objects and draws three pages. Treating that as one
PNG both lost earlier pages and failed single-figure notes extraction. Export
now draws the existing route once to numbered temporary pages, checks the page
count against the returned objects, and publishes a named PNG/notes-CSV pair
for each member. The `fit_wright_map`, `fit_pathway_map` and
`fit_category_characteristic_curves` names identify the figures; the starter
index links both the image and its notes. Other single-figure filenames stay
unchanged. There is no new renderer, plotting dependency or model computation.
Existing destinations are checked before any member of a bundle is published;
directory collisions are refused even with overwrite enabled;
failed rendering or a page-count mismatch records the refusal without replacing
an existing image. A failed route does not corrupt subsequent route output.

The focused checks independently render the original bundle, compare all three
PNG byte hashes with the exported images in the same session/device, and compare
each notes CSV with that figure's payload. They also check named manifest/index
links, one rendering call per route, saved replay, collision protection, device
cleanup and failed-route file preservation. The first test run exposed only a
test-path mismatch (`/var` versus normalized `/private/var`); normalizing the
expected path corrected the assertion without changing the export.

Visual inspection at 7 by 5 inches then exposed a pre-existing Wright layout
problem: when shortened labels collided, full separate-owner names were kept,
but a fixed bottom margin clipped them. The shared native renderer now measures
the rotated text and reserves adequate bottom space. The exact plot payload is
unchanged. Tests check distinct labels and nonnegative device bounds at 7 by 5
and 5 by 4 inches, while the existing device/layout tests check ordinary RSM/PCM,
crowded displays, legends and subsequent plots. Full labels fit in the inspected
final PNG; figures retain English axes and no overall title or explanatory footer.

Final focused export checks pass 73 assertions, the extended-output regressions
pass 240, and affected device/layout checks pass 165 (478 total). The extended
checks preceded the native-only margin adjustment; their separate testlet/random-
rater renderers were unchanged. This is scoped combined evidence, not a full-
package check. No inference procedure, threshold or numerical qualification was
changed, and no Monte Carlo performance study was repeated.

Fresh-session export of the previously failing standardized-contrast archive
produces seven figures with zero errors, retaining its exact interval table and
full covariance. Retained ordinary PCM MML/JML each produce six figures with
zero errors. Fitting, simulation and information entry points are blocked during
this replay. The reporting guide renders with computation disabled and help
validates. Evidence is in `validation-results/fit-bundle-export-20261011/`, with
inputs, source/image hashes, logs, final-source saved replay in `final/` and
before/after label-spacing exports. The current roadmap closes this output repair and returns
to the existing target/design-specific D1 obligations; successful export provides
no new statistical coverage evidence.

## October 11 standardized severity contrasts

The named common-scale contrast dependency is implemented in the existing
`mfrm_facet_intervals()` API via `scale = "standardized"`. For a zero-sum
within-facet contrast d and lambda=log(sigma^2), t=d/sigma has structural
derivative J_d/sigma and log-variance derivative -t/2. Transforming the full
inverse joint information gives
`[Var(d) + d^2 Var(lambda)/4 - d Cov(d,lambda)] / sigma^2`.
The cross term is retained; dividing native endpoints by SD is not this method.
The population mean cancels only for a zero-sum contrast, so individual
locations are excluded. Regression residual SD is not silently substituted for
marginal population SD. Only model-based, fixed-N(0,1) or intercept-normal
routes are supported; source admission and the default native route are unchanged.

Numerical differentiation across every free coordinate and the expanded scalar
variance formula agree for the retained estimated-normal RSM/PCM and one-family
GPCM fits, including shared/separate owners and fixed/adaptive integration.
Estimated-SD examples expose nonzero cross terms and differ from naive division.
Fixed-N(0,1) ordinary, one-family and both two-family owner contrasts coincide
with native results. Reverse/redundant targets, a zero estimate with positive
uncertainty, overflow, numerical refusal, regression rejection and source mismatch
are checked. Population-interval reuse preserves its target and omits contrast-
specific cautions. The combined affected checks contain **531 passing assertions**,
no unresolved assertion failures, errors or warnings. This is assembled evidence:
the first run's one failure was a name attribute on an expected scalar, corrected
without changing numerical acceptance; only corrected/new checks were repeated.
It is not a claim of a single final-source full-package run.

Saved tables retain the native estimate, standardized scale, full derivative,
population SD and whether it is estimated. `CIEligible` remains numerical and
`CoverageQualified` is FALSE. Fresh-session report/CSV/RDS and standardized plot
replay pass with fitting, simulation and information work blocked. Base and
ggplot output at the guide's 7-by-5-inch dimensions were visually inspected;
axes are English and explanatory text remains outside the figures in returned
notes. The help files regenerate and validate; the whole GPCM guide renders
with computation disabled. No new Monte Carlo performance study or full-package
check was run. Existing scope/performance obligations remain open.

Evidence is under `validation-results/standardized-contrasts-20261011/`, including
the original focused run, corrected checks, population regressions, source/input
hashes, current public output and fresh replay. The initial documentation loader
returned the wrong object type; returning the loaded namespace fixed the build
without rerunning estimation. Formula environments differ after serialization;
reuse checks compare the exact model/source identity rather than environment
addresses. Full covariance and numerical-source fingerprints remain bound.

**Distinct public-output defect discovered at this checkpoint (now fixed above).** The broad export also attempts its
existing generic `fit` plot, which returns an `mfrm_plot_bundle`. The new notes
extractor expects one `mfrm_plot_data` and errors on that bundle. The standard
contrast PNG and notes CSV succeed; `mfrmr_results_plot_errors.csv` retains the
generic `fit` failure. That historical run is not all-plot export success. The
bounded repair above preserves the association between each figure and its
notes, without another fit, interval method or simulation batch.

## October 11 mathematical design reassessment

**Target/design reconciliation after the public initialization bridge.**
The saved comparison, rank-policy correction and scoring summaries were read
and their input/result hashes checked, without loading mfrmr or repeating
estimation, scoring, information or response generation. The comparison binds
1,174 files and retains 500 condition-datasets, twenty structural targets and
three separate procedures (600 target/cell/procedure rows). The procedures and
targets share datasets; they are not additional independent replications.
The following counts describe the original frozen procedure, before the
separate rank-policy and numerical continuations. Every cell planned 50 datasets.

| Calibration N | Assignment / generating SD | Intervals returned | Rater r1-r2 contained / returned | Task t1-t2 contained / returned | Task t1 location contained / returned | Task t1 slope contained / returned |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| 20 | Common / 1 | 0 | undefined | undefined | undefined | undefined |
| 30 | Common / 1 | 20 | 20/20 | 19/20 | 19/20 | 18/20 |
| 40 | Common / 1 | 31 | 30/31 | 28/31 | 28/31 | 29/31 |
| 60 | Common / 1 | 46 | 46/46 | 44/46 | 44/46 | 37/46 |
| 120 | Common / 1 | 50 | 49/50 | 47/50 | 46/50 | 42/50 |
| 240 | Common / 0.5 | 50 | 50/50 | 47/50 | 47/50 | 48/50 |
| 240 | Common / 1 | 50 | 49/50 | 44/50 | 43/50 | 48/50 |
| 240 | Rotating pairs / 0.5 | 49 | 46/49 | 45/49 | 44/49 | 43/49 |
| 240 | Rotating pairs / 1 | 50 | 49/50 | 48/50 | 47/50 | 48/50 |
| 480 | Common / 1 | 50 | 49/50 | 47/50 | 48/50 | 50/50 |

Here Common is the historical common-Person roster, not an all-raters complete
crossing. Component slopes, locations and within-facet differences are distinct
targets; the displayed four were already specified in the retained study.
All twenty remain in the saved reconciliation. The original N20 zero reflects
the then-current empirical-score-rank exclusion. Under the separately checked
correction, 3/50 saved sources return intervals and 47 retain other refusals.
It is no longer a current N<p prohibition. The binary N20 public bridge has
six free parameters, whereas this historical design has 22; one cannot stand
in for the other.

The saved-source continuation raises N30/N40/N60 delivery to 24/50, 40/50 and
50/50. It still gives N60 Task t1 slope inclusion 41/50, while that task's
location gives 48/50. Local profile membership gives 42/50 and is not complete
interval delivery. Thus a return-rate repair is not a coverage repair, and a
slope result cannot decide whether a rater contrast is usable. Across each
procedure's 200 target/cell rows, exactly one has a pointwise exact 95% Monte
Carlo upper bound below .92; twenty have undefined coverage under the original
N20 exclusion. No row's Monte Carlo interval lies wholly inside [.92,.98].
Indeed no possible count out of 50 can meet that historical precision margin.
This is a descriptive precision check, not retroactive application of the old
confirmation proposal, a multiplicity-adjusted test, or a reason to declare all
methods inadequate or automatically increase repetitions.

**Person scoring has its own target and denominator.** The ten complete
population-scoring cells also reconcile. For the common-Person SD1 cells,
the complete prespecified refinement rule gives the following held-out-person
results. Each cell uses 50 calibration datasets and 60 new Persons per dataset;
the Monte Carlo SE uses calibration-replicate contributions, not 3,000
independent calibrations. Default31 and refinement remain separate saved arms.

| Calibration N | Scores returned / planned | Truth inclusion among returned posterior intervals | Calibration-replicate MCSE | Returned and containing truth / all planned |
| --- | ---: | ---: | ---: | ---: |
| 20 | 300/3000 | .8367 | .04627 | .08367 |
| 30 | 1440/3000 | .8590 | .01438 | .41233 |
| 40 | 2520/3000 | .8869 | .00968 | .74500 |
| 60 | 3000/3000 | .9123 | .00642 | .91233 |
| 120 | 3000/3000 | .9270 | .00543 | .92700 |
| 240 | 3000/3000 | .9520 | .00409 | .95200 |
| 480 | 3000/3000 | .9420 | .00498 | .94200 |

The N240 SD0.5 and rotating-pair cells remain separate in `target-review.rds`;
their population inclusion values are .9460, .9337 and .9423 for common/SD0.5,
rotating/SD0.5 and rotating/SD1. No pooled qualification is inferred. At N480,
the separate fixed-z panels give inclusion .8407 at z=-2, .9800 at z=0 and
.8607 at z=2. These are not five equally weighted population strata. Existing
calibration/source/integration refusals remain counted; the new binary bridge's
same-response scoring check does not add held-out Persons to these samples.

For a known correct calibration gamma and correctly specified ability/response
law, an exact posterior interval C_gamma(Y) with probability .95 obeys
`P_gamma{Theta in C_gamma(Y)} = E_Y[P_gamma{Theta in C_gamma(Y) | Y}] = .95`.
This is a population-average identity, not a statement for every fixed theta.
The evaluated output instead substitutes an estimated calibration and excludes
its uncertainty. Therefore neither tail-panel under-inclusion nor successful
integration alone identifies an implementation error or establishes the cause
of population under-inclusion. A paired known-calibration comparison on the
same held-out responses can isolate the combined consequences of calibration
estimation and source selection before proposing calibration-uncertainty
repair. It cannot by itself separate bias, covariance omission and selection,
and is not automatically allocated by this review. Fixed-calibration scoring
and calibration-inclusive uncertainty remain distinct promised outcomes.

**Current decisions and next bounded dependency.**

| Outcome | Disposition from the existing evidence | Consequence |
| --- | --- | --- |
| Numerical two-family fit/information/output delivery | Qualified only within the retained numerical/source/design checks; the explicit-start bridge is complete. | Preserve failures and current guards. Do not relabel the selected private fits or requalify unchanged witnesses. |
| Small-N interval delivery in the historical design | Repair required: the corrected N20 rule returns only 3/50 retained sources. | A common estimation/selection method must address weak information and boundary outcomes; further individual rescues do not complete this claim. |
| Broad nominal-coverage recommendation for structural intervals | Unresolved, with an adverse N60 Task-slope signal. R50 evidence is descriptive and does not support the declared precision claim. | Retain experimental full-information Wald and all target/design results. Neither broad unchanged confirmation nor automatic profile/bootstrap replacement follows. |
| Conditional Person scoring | Public calculation/replay verified; population performance and ability-specific performance are separate and not generally qualified. | Preserve per-source refusals and calibration-replicate uncertainty; do not impose .95 at every fixed z or treat conditional bounds as calibration-inclusive. |
| Matched simpler-model comparison | The old missing-native-consumer blocker is resolved in current source. Estimated-normal RSM/PCM and one-family GPCM already have native full-information location/contrast consumers. | Reuse them. The standardized zero-sum contrast is now implemented as recorded above, including estimated-SD uncertainty and cross-covariance; this does not qualify matched-model sampling performance. |

The last row corrects the historical October 1 staging list below; it does not
require implementing the native consumer again. The common-scale contrast transformation identified at that checkpoint has
now been completed using full joint information, as recorded above. This is tied
to the primary severity-comparison question and does not replace the unresolved
structural coverage or Person-scoring obligations. No new study allocation,
method default, acceptance margin or release scope is changed. The existing
`target-review.R`/`target-review.rds` checkpoint in the interval-disposition
result directory records this saved-evidence reconciliation and unchanged
production-source fingerprints.

Fresh-process replay reproduces the reconciliation exactly. The revised GPCM
guide's R chunks parse and the changed prose/table converts to HTML without
executing estimation chunks. The first documentation conversion used a relative
input path after Pandoc's directory change; using its absolute path resolved
that rendering-only failure. All 172 production R-file hashes are unchanged,
and the final whitespace check passes. No full-package check or new sampling
validation is claimed for this evidence/documentation review.

**Public adaptive initialization bridge and workflow verification.**
The source/workflow integration decision is to reuse the existing public
adaptive/direct engine with explicit native starts. `gpcm_mml_start` now accepts
a plain named list of at least two finite vectors in the model's native order;
optional coordinate names must agree exactly. Explicit vectors replace the
default roster and skip its EM seed calculation. Each start is reevaluated and
optimized under the adaptive objective, with all terminal failures, warnings
and selection records retained. The existing lowest-finite-objective selection
does not hide a better unfinished result behind a worse converged one.
Malformed coordinates are refused before likelihood work. The scalar settings
label is `explicit`; replay retains the full vectors and quadrature refits
check their agreement with the original attempt records.

This is deliberately a starting-value bridge, not a conversion of a segmented
result into `mfrm_fit`. A segmented likelihood, convergence label, information
matrix or scoring qualification never becomes public merely by copying it.
The public engine, convergence checks, full observed-information calculation,
interval/scoring gates and portable schema 6 remain unchanged. If adaptive
evaluation fails at a difficult retained source, this bridge does not repair
that failure or remove its refusal. Direct segmented-engine adoption is a
separate methodological decision, not an automatic new release prerequisite.

The same N20 binary 2-by-2 witness in `gmfrm-result.rds` supplies its retained
segmented estimate and neutral vector. A real `fit_mfrm()` call with adaptive
order 31 and `maxit=400` completes in 1.566 seconds. Both starts pass optimizer
and gradient checks; initial NLLs are 49.22636 and 51.07656 and terminal NLLs
both round to 49.22636. The selected total gradient sup norm is 1.340e-6.
The ordinary full-information checks (orders 31/61) return four component
log-Wald intervals and one Judge-severity contrast, each with
`CoverageQualified=FALSE`. The complete output phase takes 7.327 seconds.
Fixed-calibration scoring for 20 Person IDs agrees between the fitted route
and frozen portable calibration within 4.441e-16 over estimates, posterior SDs
and limits. The same response records with changed IDs test the scoring path;
they are not held-out performance data or additional statistical replications.

Fresh-session exported-result replay reproduces the results and report exactly;
loading the frozen calibration and scoring reproduces the portable estimates
without a training fit. Fitting and information calculation are blocked in
this replay, while the requested scoring integration remains enabled. All 96
assertions in `test-gmfrm-adaptive-start.R` pass, including default-policy
regressions, malformed inputs, complete failure records, replay corruption
refusal and saved-report metadata. Public-dispatch regressions reuse the actual
stored optimizer returns but reevaluate initial objectives. A first assertion
read the wrapper fixture's admission flag at the wrong nesting level; fixing
that test lookup required no implementation change or repeated live fit.

Evidence, the actual driver, completed logs, fixture and source bindings are
retained in `validation-results/gmfrm-public-start-20261011/`. Full Rd generation
updated `fit_mfrm.Rd`; its unrelated generated whitespace change was restored
from a pre-generation backup. This checkpoint connects starts to public outputs;
it supplies no new coverage or bootstrap-success evidence. The next decision
returns to D1.1's target/design-specific statistical claims using the existing
method review and retained small/medium/large-N evidence, not another automatic
wrapper, boundary rescue or broad simulation.

**Public output contract: numerical availability is separate from coverage.**
The existing public two-family component Wald/profile and location/contrast
tables now include `CoverageQualified = FALSE` alongside `CIEligible`.
The flag means nominal sampling coverage has not been established for the
target/design, not that estimated coverage equals zero or a numerical check
failed. Saved reports, CSV tables and plot payloads retain it; older saved
objects remain readable without assigning a missing flag to true. Help and
NEWS document the meaning. The public roadmap's old adaptive-profile exclusion
was corrected to match the already implemented component-profile route.

An output regression also reproduced `ModelSE = Inf` and `ModelLower = -Inf`
for finite contrast coefficients of magnitude 1e200, despite unavailable
primary limits. The two-family path now applies the existing native-location
cleanup to all SE/limit table columns, preserving finite point estimates and
the refusal reason. A nonrepresentable point is rejected with rescaling advice.
Ordinary available intervals and constraint-fixed targets retain their values.

All 54 assertions in `test-gmfrm-interval-status.R` pass. They reuse retained
outcomes and explicit test doubles for output assembly; they do not qualify
new fitting, information or profile calculations. Tests cover available and
unavailable Wald/profile results, fixed targets, overflow, unchanged full-
covariance limits, legacy objects and table/report/export/replay propagation.
A first computed-profile display test incorrectly assumed its refined fitted
point equalled the earlier joint-information fixture; that assertion failed.
The corrected output-only test uses an explicit dummy comparison covariance
and checks the actual saved profile endpoints without asserting new Wald
qualification. No production numerical rule changed in response.

Fresh-session exported replay and 7-by-5-inch public plot rendering pass with
fitting, information, profiling, integration, optimization and RNG blocked.
The two rendered figures were visually inspected; titles/captions remain
outside the figures. Source-bound evidence is in
`validation-results/gmfrm-interval-status-20261011/`. Of the preceding private
Wald epoch's 182 source files, 178 are byte-identical; the four changed files
assemble public interval outputs. Previous numeric results/archives are not
rewritten or represented as an all-source match to this revision.

Engineering recovery: a partial `roclet_output()` call removed other generated
help topics through its default cleanup. Full Rd generation from current R
sources restored them; a follow-up generation resolved the remaining local
link, and no deleted help files or whitespace errors remain. The contributor
guide now warns against partial output in the package directory. The fresh-
replay harness also needed explicit binding replacement to block base-package
numerical functions; its first preparation stopped before exporting results.
These were documentation/harness issues, not fitting or coverage failures.

**Decision:** this completes the scoped public output-status/overflow repair.
It does not promote the segmented private result to `mfrm_fit`, change admission
thresholds or alter any target/design-specific statistical decision. Its
public fit/scoring/portable-calibration bridge is completed above; D1 remains open. No
additional simulation or individual boundary rescue is implied.

**Private Wald calculation and independent full information connected.**
The October 10 method decision is retained: full-information native Wald and
component log-Wald are established asymptotic constructions and remain the
experimental reference. The result handoff did not by itself qualify their
widths. In particular, agreement of the score at one point does not establish
agreement of its derivative. The new `R/core-gmfrm-wald.R` therefore supplies an
independent observed-information check before constructing limits.

For each Person the Louis decomposition is
`I_observed = E(I_complete | y) - Cov(U_complete | y)`; Person contributions
are summed. The fixed N(0,1) prior has no structural-parameter derivatives.
The literal product-slope response law is differentiated with respect to the
complete native vector. Its location-by-log-slope and log-slope-by-log-slope
second derivatives are retained, including away from a stationary point. The
complete-score covariance is subtracted across the full parameter vector; this
is neither an inverse EM Q-matrix nor an inverse slope-only block.

The reference vectorizes integration nodes within each Person. It uses the
existing independent literal design and posterior segmentation, not the working
response decoder, optimizer or finite-difference Hessian. The first calculation
uses 32 Legendre nodes per segment and the existing density-drop-64 integration
range; the second uses 64 nodes and extends that range to density drop 96.
Both information matrices must be positive definite. Their unregularized inverses
and the retained full inverse are compared using
`||R (V_reference - V_retained) R' ||_2`, where `R'R = H_retained`.
The new numerical gate uses the public information-comparison tolerance .01,
alongside the private result's likelihood/score/standardized-stationarity gates.
The range/rule comparisons are numerical stability checks, not certified
entrywise error bounds for the Hessian. The retained covariance is used only
after agreement; it is never silently replaced or rescaled.

`mfrm_gmfrm_wald()` forms pointwise native limits
`C gamma +/- z * sqrt(C V C')`. An exponentiated target transforms both endpoints
and its estimate, while `NativeSE` remains on the native/log scale. The output
separates `NumericallyAvailable` from `CoverageQualified` (always false in this
private route), retains source identity and checks, and does not modify the
source's public admission fields. Constrained nuisance results, unselected
boundaries, unsuitable source categories and failed information checks return
no interval. No public `mfrm_fit`, `confint()` dispatch or inference default is
changed by this addition.

All 38 focused assertions pass. Tests compare the vectorized Louis calculation
with the existing independently coded scalar Louis reference and a derivative
of the fixed-rule marginal score at nonstationary binary/four-category points,
including incomplete assignments. They also exercise dependent first-owner log
slopes, full-covariance severity contrasts, altered information, category failure,
constraint/boundary refusals and changed saved sources.

The input/source-bound retained-result allocation uses all eleven result groups.
Only the four unrestricted eligible sources need new information calculation:

| Source | Wald rows | Covariance-scaled difference from retained inverse | Reference refinement change | Seconds including output |
| --- | ---: | ---: | ---: | ---: |
| Binary N20 | 15 | 9.394e-10 | 3.027e-14 | 0.863 |
| Three-category N20 | 55 | 7.831e-9 | 1.869e-12 | 6.039 |
| Three-category N60 | 55 | 1.644e-9 | 4.164e-14 | 19.764 |
| Three-category N240 | 55 | 7.880e-10 | 1.615e-14 | 80.615 |

Rows include free native coordinates, expanded locations, all second-owner
pairwise severity contrasts and both component-slope families; these are
correlated outputs, with some duplicate functionals, not independent samples.
The other seven groups preserve 385 unavailable rows. No fitted point, original
finite-difference Hessian or response sample is recomputed. This is new analytic
information at retained points, so it must not be described as zero new
information work or as a benchmark of a changed optimizer.

`inst/validation/gmfrm-wald-20261011.R verify` reconstructs all limit calculations
after disabling Louis information, integration, root finding, optimization and
RNG. Source/input/output hashes and fresh-session replay pass. Evidence and the
new source/fixture archive are under `validation-results/gmfrm-wald-20261011/`.
An initial driver preflight referenced a nonexistent nested facet slice and was
stopped by the nonzero-contrast guard before information calculation; its original
manifest and script are retained. Correcting that driver did not rerun the
successful unit checks or any fitted model.

Literature scope: Zotero author/title searches did not locate Louis (1982).
Fallback search results were checked and were unrelated; no library item was
added. The [publisher record](https://academic.oup.com/jrsssb/article/44/2/226/7027638)
confirms the article and its observed-information purpose, but attempts to
retrieve the full paper failed. This entry does not claim a new page-by-page
reading. The numerical justification here is the existing scalar reference,
explicit derivative algebra and the independent derivative comparisons above.

**Decision:** the scoped private Wald computation is numerically qualified.
The 500-dataset development evidence, adverse small-sample coverage and earlier
profile/bootstrap decisions are unchanged. Accurate information at these four
selected points is not a coverage repair. Reconcile target/design-specific
statistical claims and public integration next; do not automatically launch
broad confirmation of unchanged Wald inference or make a different method a
release requirement. D1 remains open.

**Private fitted-result, native targets and conditional Person scores connected.**
`mfrm_gmfrm_result(run)` now reuses the complete caller result without another
search or Hessian. It reconstructs candidates from their saved stages and repeats
the complete-start selection, including supplied comparison witnesses. For a
selected point it binds the saved information to the data/model by a fresh
independent likelihood/full-score comparison. The actual segmented rule and
historical search codes remain in `run`; the result has its own private class,
not `mfrm_fit`. The existing public EM/adaptive eligibility contract is unchanged.

`mfrm_gmfrm_result_targets()` returns native linear targets and their local
observed-information variances. For a contrast row C and full joint inverse V,
the variance is C V C-transpose, including cross-parameter covariances. Constrained
nuisance inverses return no unrestricted variance, and an unselected boundary
has no selected native target table. All interval-eligibility flags remain false.
No Hessian is transported between nonlinear charts and no empirical Person-score
covariance substitutes for the full observed information.

`mfrm_gmfrm_result_persons()` uses the selected calibration and fixed N(0,1)
prior. Its posterior is proportional to the product of that Person's supplied
response probabilities times the normal density. EAP and posterior SD describe
this conditional distribution; they exclude calibration-estimation uncertainty.
Scoring has its own explicitly recorded adaptive GH 31/61 rule, separately from
the segmented estimation rule. The existing per-Person integration review checks
moments and log-normalizer stability at 1e-5. Failed rows retain diagnostics and
return unavailable scores. The existing input/category/estimability/boundary
conditions for two-family conditional scoring remain in force; incomplete global
identification/boundary audits stay visible rather than becoming successful
audits. Constrained sources do not acquire scoring admission.

The scored batch may contain one Person, one observed category or a subset of
known owner levels. It uses the original category ladder and owner level order,
and composes slopes from the fitted owner components. It does not need to satisfy
the category-support requirements for estimating a new calibration. Unknown
levels, missing/invalid scores and duplicate Person-by-facet rows are refused.
The original training data, point tables and qualification are protected by a
saved-content fingerprint; altered results require reconstruction. This is an
identity check, not an authenticity or cross-environment equivalence claim.

All 45 focused assertions pass, including full-covariance severity contrasts,
changed-source/stage/constraint refusals, a retained unselected boundary result,
single-Person/single-category batches, row permutations and integration failures.
Eleven retained groups preserve eight selections and three unselected outcomes.
The 266 native parameter/contrast rows include 148 constrained rows with no
unrestricted variance. Four unconstrained sources produce these independent
continuous-Gauss-Kronrod moment comparisons:

| Retained source | Persons | Maximum absolute EAP/posterior-SD difference |
| --- | ---: | ---: |
| Binary 2-by-2 live witness | 20 | 3.399e-12 |
| Three-category N20 | 20 | 1.422e-9 |
| Three-category N60 | 60 | 9.082e-14 |
| Three-category N240 | 240 | 2.665e-15 |

The independent moments use the literal response kernel and continuous
integration, not the scoring response decoder or GH nodes. Integration is
centered and peak-scaled, with moment error estimates checked relative to the
normalizing mass. An initial reconstruction error passed an attempt's boundary
reference into its native candidate; the procedure intentionally stores these
separately. That copying error was fixed and a retained-boundary regression test
added. The partial first epoch and its exact source archive remain intact;
the completed epoch is `validation-results/gmfrm-result-20261011/qualified/`.
Fresh `inst/validation/gmfrm-result-20261011.R verify` replay passes with integration,
root finding, optimization, Hessian and RNG entry points disabled. No responses,
searches or Hessians were generated for this handoff.

This completes the scoped private numerical handoff. It does not establish
calibration-inclusive Person uncertainty, future-population performance, a global
optimum or structural interval coverage. The dependency at that checkpoint was the complete
interval procedure and its target-specific qualification, followed by a fixed
independent performance contract using the existing method review and retained
small/medium/large-N evidence. No case-specific boundary rescue or automatic
simulation allocation follows.

**Live caller and generic independent reference connected.** The private
`mfrm_gmfrm_run()` accepts observed data and a named roster of explicit native
starts, reuses the existing input/identification validation, and constructs the
native/natural evaluators and independent reference from that same specification.
Comparison evidence must contain the identical specification. The returned plain
result includes inputs, start roster, parameter order, actual integration rules,
evaluation counts, stage failures and explicit non-admission to public fit,
interval and Person-scoring outputs. The setup's two-point placeholder rule is
never used for fitting, independent reference or returned likelihoods and is
removed from the saved specification.

`mfrm_gmfrm_reference()` generalizes the frozen literal native design and
32/64-point Legendre plus Gauss-Kronrod reference to the declared category count
and owner levels/names. It calls none of the working parameter, coordinate,
response, derivative or quadrature implementations. Scope remains unweighted,
unanchored two-family MML with fixed N(0,1), the first owner centered/GM1 and the
second owning the steps. Binary/four-category incomplete designs and both natural
boundary charts are checked. The independent reference and working equations
agree; a 121-point fixed-rule comparison retained about 3.2e-7 score error in the
four-category test, resolved at 241 points without relaxing any test threshold.
This changed only the comparison rule, not a package integration default.

The newly explicit relative-accuracy gate initially refused four formerly finite
boundary integrals: an absolute quadrature tolerance applied to an extremely
small unscaled likelihood was insufficient. The correction integrates
`exp(logjoint(mode + t) - logjoint(mode))` and restores the log scale afterwards.
The mode only centers/scales the integral; it does not replace integration by
a posterior-mode approximation. The normal prior and nonnegative affine category
slopes make the log integrand concave. The relative-error criteria remain
unchanged. Exact zero-slope likelihoods with total NLL exceeding 1000 test this
case without a native inverse or a fabricated covariance.

All 64 current assertions pass. One frozen, deterministic N20 binary 2-by-2
response-pattern witness (80 rows, six native parameters, two fixed starts)
completes the actual data-to-result route in 48.375 seconds. Both starts pass
the existing local qualification; their independent NLL spread is 2.14e-14,
maximum independent native score is 3.67e-11 and information-scaled score is
1.42e-11. The original PORT code-1 results are retained separately. There are
76 native and 48 natural evaluator calls. This is an integration witness,
not a sample of convergence rates or a coverage study.

Only independent references were re-evaluated at three retained N20/N60/N240
interior points and six boundary points; no retained search or Hessian was
repeated. Interior NLLs/gradients exactly match the old reference. Mode-scaled
boundary integration returns six finite values. Four reproduce the earlier
values within 2.85e-14; b19-free's two earlier roundoff errors now yield finite
diagnostic values but disagree with the working NLL by 5.913e-7 and 1.530e-4.
Both still fail the unchanged 1e-7 identity gate and are not verified candidate
likelihoods. The old records and three unselected groups remain unchanged.

`inst/validation/gmfrm-run-20261011.R` and its evidence directory bind the initial
allocation and the boundary-only correction separately. Archived/current
function-body comparison confirms all interior reference functions and the
live caller are unchanged by that correction, so the successful live run and
three references are reused. A read-only verifier correction normalizes input
data with the same declared-column subset as the constructor (dropping only
`expand.grid`'s unused `out.attrs`) and records its own hash. Fresh `verify`
runs with numerical entry points disabled check all source/input/phase bindings,
the complete start roster, result persistence and non-admission fields.

The dependency at that checkpoint was the fitted-result/target/Person-scoring handoff (completed within its private scope above),
with actual integration provenance and existing eligibility checks intact.
This live private caller is not public estimator adoption or a D1 completion;
the broader small/medium/large-N and target/design obligations are unchanged.

**Private execution route assembled.** `mfrm_gmfrm_procedure()` now calls the
existing bounded search, native finish, chart/reference gates, candidate adapter
and start-set selector in order. One result retains all prescribed starts and
stage failures/warnings. An initial evaluation failure has no fabricated finite
point and prevents selection of a whole-procedure result, even if another start
qualifies. Positive-interior failures expose no covariance; exact boundaries
skip native inversion/finish while retaining independent NLL comparisons or
their errors. Original fixed coordinates must be unchanged between charts.
The full selected-point information is reused without another Hessian.

The inverse map and Jacobian come from the existing native-target functions,
covering both charts and different category ladders. The Jacobian transforms
gradients and componentwise integration diagnostics; it does not transport a
nonstationary Hessian by congruence. The independent reference supplies values,
native gradients and component diagnostics; the procedure recomputes the
existing qualification checks rather than trusting an incoming `passed` flag.
Data/model binding and independent reference construction remain explicit
caller responsibilities. This private result is not an `mfrm_fit` and grants
no public interval or Person-scoring eligibility.

All 79 assertions in eight tests pass. Live analytic problems exercise actual
search/finish/selection against known unconstrained and constrained solutions;
failure tests cover absent initial endpoints, finish/reference errors,
contradictory reference values and exact-boundary routing. Actual model target
maps are checked for binary/four-category designs in both charts. The retained
driver `inst/validation/gmfrm-procedure-20261011.R` replaces only costly kernels
with input-bound saved calls and executes the new orchestration and checks.
All twenty searches, fourteen finishes, original nulls, old optimizer histories,
seven selections, three unresolved groups and two b19-free reference errors
reconcile with the prior epoch. Source/input/result hashes and a fresh-session
`verify` replay pass. No model likelihood, optimization, Hessian or response
generation was repeated by this replay; it is not a new live GMFRM run.

The assembly dependency was closed. The next dependency at that checkpoint was a live data-to-result caller and
the independent reference over its declared model/design scope, preserving
the existing target-specific and public scoring eligibility checks. Do not
infer sampling coverage, global optimality or general convergence rates from
these retained cases; no automatic rescue or confirmation batch follows.

**Candidate selection and comparison reconciliation complete.** The private
`mfrm_gmfrm_select_candidates()` consumes the prescribed start roster, candidate
records and independently checked NLL values, with explicit NA for unavailable
references. It requires identical original constraints across starts and keeps
the existing all-start qualification, 1e-5 NLL-spread and non-domination rules.
It returns the selected candidate's complete information unchanged, or no
candidate when those rules fail. A low unfinished or unverified package NLL
cannot become a successful estimate, and a worse passing point cannot hide a
better verified unfinished point. Data/model/provenance binding remains the
caller's responsibility; the retained caller verifies it before comparison.

Comparison records distinguish feasible points, feasible limits and family
lower bounds. A feasible point or limit must satisfy the selection problem's
original constraint to challenge its candidate. A bound can apply to a more
restricted problem if it covers a larger family. Thus the b09 free limit does
not veto its original-null solution, whereas the unconstrained common-zero
family bound applies to both free and null comparisons. A family lower bound
never enters the minimum over known feasible values: if a verified feasible
value is smaller than it by more than the existing 1e-6 bound margin, only that
specified family is excluded. A feasible limit remains a comparison value,
not an attained finite estimate. Unverified comparisons remain visible and
have no evidential effect.

The saved-result driver `inst/validation/gmfrm-selection-20261011.R` applies this
rule to all ten original two-start groups, including the earlier feasible
points, audited rater-5-zero points, b09 free limit and common-zero bounds.

| Original groups | Selection outcome |
| --- | --- |
| N20/N60/N240 observed free and null; N20 b09 null (seven groups) | Select a reference-qualified local interior candidate; retain its exact full joint or conditional nuisance information |
| N20 b09 free | No qualified candidate. Both independently evaluated endpoints are worse than the known feasible limit; no limit is returned as an estimate |
| N20 b19 free | No qualified candidate. Both independent NLL references remain unavailable with their original roundoff errors; lower package values remain unverified |
| N20 b19 null | No qualified interior candidate. The prior finite-intercept face audits remain comparison evidence and do not confer native interior information |

The eight prior common-zero family exclusions are retained. They do not exclude
every individual-rater-zero face or establish global optimality. All twenty
endpoints, ten original null constraints, search histories and two unavailable
reference values remain accounted for. All 49 new selection assertions pass,
including bound/limit confusion, constraint-domain direction, unfinished-start
dominance, missing starts and incompatible point records. Fresh base-R replay
reproduces `validation-results/gmfrm-selection-20261011/review.rds` with package
loading, optimization, integration and response generation disabled. No
likelihood or Hessian evaluations were added; existing tests and numerical
phases retain their own unchanged source bindings.

This closed selection among the retained qualified interior candidates and
comparison witnesses. The next implementation dependency at that checkpoint was a single private
end-to-end search/finish/selection/result route that preserves these refusal
and information-scope distinctions. Do not automatically rescue the three
unselected groups or allocate another coverage batch. Public adoption and
statistical qualification still require the complete procedure and its stated
target/design contract; D1 remains open.

**Completed-stage and target handoff implemented and reconciled.** The private
`mfrm_gmfrm_candidate()` joins the saved bounded search, interior finish,
natural-chart check and independent reference without numerical evaluation.
It preserves the original search and every supplied stage, requires the same
endpoint and original constraint, and exposes information only after all
local qualification gates pass. Current parameters, the full free-coordinate
set, unregularized curvature and inverse are checked before reuse. Provenance
across data/model/source/integration remains the caller's responsibility; this
helper is not a cross-fit cache. The retained-result caller verifies those
bindings against the immutable phase records and source archive.

The companion native-linear-target helper reuses the existing natural-chart
target rules, including at exact zero. Its distinctions are deliberate:

| Retained outcomes | Information handed on | Native target result |
| --- | --- | --- |
| Six unrestricted interior points | The same full joint observed information and covariance | Finite native values and local model-based variances; no interval/coverage qualification |
| Eight original-null interior points | The same conditional nuisance information | Finite native values; no unrestricted target variance, including for the fixed target |
| Six exact-boundary points | No native interior information | Targets involving unsupported zero-slope severity, steps or log slopes remain unavailable; other defined targets acquire no covariance or identification claim |

For a native linear contrast C, the unrestricted local variance is C'VC using
the full inverse, retaining all cross-covariances. A null-fit nuisance inverse
cannot replace that unrestricted covariance. The new helper also refuses to
interpret a nonlinear transformed constraint as the same fixed coordinate
index. These are target and information-scope checks, not a new interval method.

All 72 new assertions pass, covering correlated contrasts, constrained versus
unrestricted information, failed/missing checks, changed points, serialized
results, binary/multicategory ladders, both chart types and arbitrary column
names. The saved-stage driver `inst/validation/gmfrm-candidate-20261011.R`
reconciles all twenty endpoints and the previous fourteen local passes. Its
39 native coordinate/contrast requests per endpoint produce 234 unrestricted
local variances checked against separate LU inverses; 62 boundary target
requests are undefined and 484 defined requests receive no unrestricted
variance. These 780 arithmetic checks are not new statistical replications.
All ten original nulls and all historical optimizer codes remain unchanged.
Results and a fresh-session replay are in
`validation-results/gmfrm-candidate-20261011/`; fitting, integration and RNG
are disabled, and evaluator calls are zero. No old finish or Hessian is repeated.

This completes the saved-stage information/target handoff. The public fitting,
interval and Person-scoring routes are unchanged. A complete fitting procedure
still needs selection across starts and valid competing boundary/limiting
solutions; this local candidate record must not override those decisions or
the public consumers' additional eligibility checks. Reconcile that selection
with existing evidence before allocating further numerical work. D1 and the
full target/design scope remain open.

**Retained-endpoint qualification complete: all fourteen interior endpoints pass.**
The frozen procedure below finishes without errors or warnings, with all 42
finish/chart/reference records saved. All fourteen endpoints pass the unchanged
native, natural-chart and independent-reference criteria. The seven interior
start pairs agree and are not dominated by their recorded feasible/limiting
comparators under the original 1e-5 NLL rule. All twenty original endpoints
and ten pairs remain in `attempts.csv`, `pairs.csv` and `summary.rds` under
`validation-results/gmfrm-interior-finish-20261011/`.

| Retained case | Constraint | Independent NLL spread between starts | Largest native-coordinate difference | Smallest terminal Hessian eigenvalue across starts |
| --- | --- | ---: | ---: | ---: |
| N20 observed | Free | 2.84e-14 | 7.61e-8 | 0.02649 |
| N20 observed | Original Task-t1 null | 7.11e-14 | 4.22e-9 | 0.02339 |
| N20 b09 | Original Task-t1 null | 1.42e-14 | 7.16e-8 | 0.0002841 |
| N60 observed | Free | 5.68e-14 | 2.37e-9 | 1.894 |
| N60 observed | Original Task-t1 null | 1.71e-13 | 6.29e-9 | 1.851 |
| N240 observed | Free | 2.27e-13 | 3.65e-9 | 14.16 |
| N240 observed | Original Task-t1 null | 2.27e-13 | 2.12e-9 | 12.43 |

The independent-reference maxima are 6.83e-13 NLL discrepancy, 2.79e-13 full
gradient discrepancy across either chart, 8.00e-8 native free score, 7.57e-8
natural free score and 2.74e-8 information-scaled displacement. Both terminal
Hessians are positive definite for every endpoint without regularization;
the maximum covariance-change diagnostic is 3.71e-8. All eight interior null
targets remain exactly their original values. The other two original nulls
are unchanged boundary outcomes, retained with the previous epoch's exact
constraint checks. Eleven historical code-1 endpoints now have a separately
qualified finish; neither their old codes nor the original adverse comparison
is rewritten. The three previously passing endpoints undergo the same finish.

Fresh-session saved-result replay and a separate base-R arithmetic verifier
both pass, with numerical execution and package loading disabled. The latter
reconstructs the forward chart and gradient transformations, checks current-
point information bindings, uses LU inversion independently of the producer's
Cholesky inverse, and recomputes the unchanged precision and pair decisions.
Input/source/result/archive hashes match. This checks stored matrix arithmetic;
it does not independently certify the Hessian entries. The separate quadrature
implementation checks the full likelihood and score. Unchanged helper tests
are reused with matching source bindings, without another fitting allocation.

**Measured cost and resulting decision.** The finish uses 128 evaluator calls
per 21-dimensional null and 134 per 22-dimensional free point: 1,828 in total,
with shared objective/gradient caching. Finish-phase elapsed times are
57.9--66.6 seconds at N20, 192.0--209.4 at N60 and 727.3--816.2 at N240.
These are per-endpoint worker times in this recorded three-worker run, excluding
the separately saved chart/reference phases; they are not an isolated-machine
benchmark or a package-wide speedup. Full information should be reused at the
same qualified point rather than recomputed by each inferential consumer.

This resolves the local stopping-precision question for the retained interior
set, including the weak-curvature b09 null. It does not qualify a global MLE,
the full boundary-aware fitting procedure, native targets on zero-slope faces,
or interval coverage. The six exact-boundary endpoints (b09 free, b19 free and
b19 null, each from two starts) retain their earlier separate assessments.
The next D1.2 dependency is integration of the qualified finish and bound joint
information with the existing boundary and target-eligibility rules. Reuse
these fourteen results; do not automatically refit them or allocate bootstrap
confirmation. Full-scope D1, including small/medium/large N, severity/contrasts
and Person scoring, remains open. Public estimation is unchanged.

**Retained-endpoint qualification frozen (October 11, before calculation).**
`inst/validation/gmfrm-interior-finish-20261011.R` binds all fourteen positive-
slope endpoints from the completed bounded-search epoch, including the three
previous first-order passes; six exact-boundary outcomes remain in the full
twenty-attempt accounting with their earlier disposition. The manifest in
`validation-results/gmfrm-interior-finish-20261011/` freezes original targets,
native starts, consumed input/source hashes, archived source copies, actual
R/DLL/package runtime and one-thread settings before any finish. The numeric
original Task-t1 values are preserved exactly; parameter-name attributes do
not define a different constraint. Explicit inverse-map/Jacobian/gradient
preflight checks pass without model evaluation. The unchanged 68 helper
assertions retain valid source bindings and are reused.

The execution follows the specification below, with no threshold changes:
one native Newton proposal, terminal two-step joint curvature, a direct
natural-chart evaluation, and the independent 32/64/Gauss--Kronrod reference
only for locally qualified endpoints. Each endpoint has separately saved
finish, chart and reference phases (42 records in total, including explicit
skips on failure). Native/natural likelihood and full-score identity are
checked before/after the finish. Independent componentwise score diagnostics
sum absolute per-Person rule differences before applying the native
information metric and the natural-coordinate Jacobian. The seven interior
start pairs are compared under the original likelihood rule; all ten original
pairs remain visible. Three disjoint N20/N60/N240 workers each use one thread.
No additional starts, response generation, bootstrap or public dispatch is
part of this allocation; numerical completion does not establish coverage.

**Final-precision diagnosis completed without new numerical fits.** The next
dependency after the bounded-search comparison was to distinguish stopping
precision from unresolved boundary behavior and specify a common finish for
finite interior points. The saved-arithmetic driver
`inst/validation/gmfrm-final-precision-20261011.R` reuses three native nuisance
Hessians from the earlier curvature followup. They describe N20 observed-null
and both N240 observed-null starts at their earlier, pre-Newton points. They
are not Hessians evaluated at the new bounded-search endpoints.

| Bounded endpoint | Predicted largest coordinate movement / local SE | Predicted NLL improvement | NLL gap to earlier refined point |
| --- | ---: | ---: | ---: |
| N20 observed null, retained start | 3.62e-5 | 2.83848e-9 | 2.83805e-9 |
| N20 observed null, neutral start | 4.38e-5 | 3.65789e-9 | 3.65739e-9 |
| N240 observed null, retained start | 2.06e-4 | 1.26347e-7 | 1.26350e-7 |
| N240 observed null, neutral start | 2.62e-4 | 1.01896e-7 | 1.01898e-7 |

The N240 table uses its earlier retained-start Hessian; using the independent
neutral-start Hessian gives essentially the same local predictions. These
are four endpoints with six Hessian/endpoint comparisons, not six independent
replications. This supports the stopping-precision diagnosis. It does not
qualify current-point curvature or amend the code-1 outcomes. No compatible
saved nuisance Hessian was found in this curvature followup for N60 or the
observed free fits; their twelve observed-data N20/N60/N240 likelihood
comparisons are retained, without inventing standardized-error results.

**Mathematical meaning and coordinate discipline.** Let F be the total
negative marginal log likelihood, g its free-coordinate gradient, and H the
positive definite full nuisance Hessian for the same original constraint.
The quadratic model predicts a Newton correction -H^{-1}g, a decrease
g'H^{-1}g/2, and a dimensionless displacement d=sqrt(g'H^{-1}g). For any linear
contrast a in those free coordinates, Cauchy--Schwarz gives

```
|a'H^{-1}g| / sqrt(a'H^{-1}a) <= d.
```

This is a bound on the *quadratic model's predicted correction* in local
model-based SE units. It is not an error bound to the true/global optimum,
a claim that these SEs have calibrated coverage, or a nonlinear-target
guarantee. Here d ranges from 7.53e-5 to 5.03e-4. The existing inference code
already uses this quantity, with a caution above 1e-4 and a separate looser
0.01 local-Wald gate; the new finish design targets 1e-4. No existing public
gate changes in this increment.

The diagnostic transforms the new natural-coordinate gradients exactly into
native coordinates, keeps Task-t1 coordinate 15 fixed, and solves with the
saved native nuisance Hessian. It does not transform an old Hessian by a
Jacobian alone. A nonlinear chart transformation requires its gradient-times-
second-derivative term away from stationarity. The diagnostic is invariant
under invertible affine changes of the free basis. Objective normalization
must also be undone: using F/N gives d/sqrt(N), not d. This explains why raw
scores, per-Person scores and standardized displacement must remain distinct.

The driver checks the exact gradient pullback against separate component
equations, its inverse, affine invariance, the coordinate contrast bound,
all three historical Newton corrections and their actual saved improvements,
source/input/result bindings and archived source identities. The original
epoch kept changed files only; unchanged files are verified against matching
hashes in the full followup archive, not represented as a single new run.
Optimization, Hessian construction, integration, root finding and response
generation are disabled. A fresh-session replay verifies
`validation-results/gmfrm-bounded-search-20261011/precision-diagnosis.rds`.
This auxiliary result does not modify the frozen search manifest or phases.

**Uniform interior-finish specification; native component implemented.**
Use the existing guarded one-step curvature proposal, rather than allocating
another from-start search. Its proposal Hessian is a search device; acceptance
and information reuse require checks at the resulting parameter vector.

1. Retain the original data, targets, search status and endpoint. Apply the
   same private procedure to every positive-slope finite endpoint, including
   those whose first-order checks already passed. In this retained set there
   are fourteen such endpoints: twelve observed-data fits across N20/N60/N240
   and two b09 null fits. Route the other six exact-boundary endpoints to the
   existing boundary assessment; do not substitute tiny positive slopes.
2. Use the exact positive-interior native map and the original free-coordinate
   constraint. Make at most one guarded Newton proposal using
   `mfrm_optimizer_curvature_proposal()`, with successful evaluations only.
   Preserve its positive unregularized curvature, conditioning, objective
   non-worsening and gradient-improvement guards. Do not restart BFGS/PORT
   after the proposal. An exactly zero free gradient needs no correction;
   a failed proposal remains an explicit unresolved finish, with the original
   point retained. A new successful Newton stage would have its own status;
   it would not turn the historical PORT code 1 into code 0.
3. Verify the candidate gradient in both native and natural coordinates.
   Keep the existing natural projected-score limit 1e-4; additionally require
   native free score <=1e-4, native free score/N <=1e-6, and d <=1e-4.
   Preserve the exact original null. The standardized criterion supplements
   raw scores and does not replace them with an easier observed-data cutoff.
4. At that candidate, obtain the full free/nuisance marginal Hessian from
   analytic-score central differences at native steps 1e-4 and 5e-5. Both
   symmetric matrices must be positive definite without regularization.
   Require inverse residual <=1e-6 and covariance change <=0.01 in the fine
   curvature metric, matching the existing information-stability scale.
   Retain unsymmetrized matrices/asymmetry diagnostics. Do not reuse a
   Hessian from a different parameter vector as current-point information,
   and do not use only the slope block, frozen EM-Q curvature or an empirical
   score covariance as the joint marginal Hessian.
5. Preserve the working integration gates and obtain the existing independent
   full likelihood/score reference once per locally qualified endpoint.
   Require NLL agreement <=1e-7 and score agreement <=1e-6 in both charts,
   and check the same raw/standardized criteria with the independent score.
   Transform componentwise integration diagnostics into the information
   metric: sqrt(e'abs(H^{-1})e) <=1e-5, one tenth of the displacement target.
   This envelope is rigorous only if e bounds the true component errors;
   quadrature-order differences are empirical diagnostics, not such a proof.
   Keep independent integration/tail checks. Final-point curvature here is
   locally checked, not independently certified by the score reference alone.
6. Compare paired starts and previously available feasible/limiting values
   with the original 1e-5 likelihood-spread rule. A local finish cannot supply
   a global optimum, a finite native target at a boundary, LR calibration or
   interval coverage. Save the final full information with its parameter,
   data, constraint, source and integration bindings for later consumers.

**Cost and allocation decision.** The three existing two-step curvature
checks used 87 evaluator calls each and took 28.385 seconds at N20 and
347.010/366.458 seconds at N240, including their reference phases. These are
historical worker timings, not a forecast on an idle identical machine.
The one-step proposal needs about 2p gradient evaluations; the two-step
terminal review needs 4p more, with a few endpoint evaluations. For p=21/22,
plan about 129/135 shared evaluator calls per completed interior finish,
plus independent-reference work. Across fourteen endpoints this is about
1,842 calls if every proposal proceeds to the full review. N60 timing remains
unmeasured for this procedure. Do not describe it as a free or negligible
cleanup, or compute a full Hessian at every search iteration. Reuse the
resulting joint information for later admissible consumers rather than
rebuilding it separately for each slope, severity or contrast.

The private native component `mfrm_gmfrm_finish_interior()` is implemented in
`R/core-gmfrm-interior-finish.R`, reusing the existing one-step proposal and
caching paired objective/gradient requests. It preserves the fixed coordinate,
records evaluator calls, retains the full terminal information and refuses
unsuccessful proposals, unresolved scores, indefinite/singular curvature,
unstable covariance and excessive information-scaled integration diagnostics.
It has no public caller. Its result explicitly leaves the natural-chart and
independent-reference checks pending; it does not claim that the complete
procedure has passed on a GMFRM dataset.

All 68 assertions in eight new tests pass: known coupled constrained solutions
at N20/N60/N240, one-step-only nonlinear behavior, zero-score saddles/singular
curvature, weak-information integration errors, small raw but excessive
standardized scores, positive but unstable curvature, rejected evaluations and
invalid inputs. The weak-information case also verifies that N<p alone is not
a Hessian-based refusal. Code/source/runtime-bound evidence is saved in
`validation-results/gmfrm-bounded-search-20261011/interior-finish-tests.rds`.
Unchanged estimator tests and completed fitting evidence are reused.

The next dependency is a separately bound retained-endpoint qualification
driver that applies the natural-chart/reference checks, records per-phase
cost, checkpoints each finish before reference work and reuses completed
phases. No new response generation, GMFRM fitting, iteration extensions or
coverage allocation was performed in this increment. D1, boundary/extreme
paths, severity/contrast and Person-scoring eligibility, and public adoption
remain open. Public estimation and help/API behavior are unchanged.

**Completed bounded-search comparison: repair required for this procedure.**
All 20 planned searches and their reference phases finish. The frozen
criteria yield three reference-qualified first-order candidates and zero
qualified two-start groups. Retain this adverse result; the private PORT
adapter is not adopted as the public estimator or a bootstrap/LR procedure.
This is a diagnostic comparison on selected retained datasets, not an
estimate of population success rates or interval coverage.

| Search outcome | Attempts | Interpretation under the frozen contract |
| --- | ---: | --- |
| Code zero and independent first-order checks passed | 3 | N20/N60/N240 observed free fits from the original parent; each takes one PORT iteration |
| `singular convergence (7)` | 13 | Preserve the non-success code and residual-score checks; this message is not proof of a singular model Hessian |
| Iteration limit at 400 | 4 | Both starts of b09 and b19 free fits; projected scores remain large |

The observations distinguish two issues rather than one generic optimizer
failure. Across all twelve N20/N60/N240 observed-data searches, the largest
absolute NLL difference from the previously qualified feasible solution is
1.26351e-7; the maximum two-start spread is 1.23732e-7. Nine nevertheless
stop with code 1 and raw projected scores between 1.1644e-4 and 1.8299e-3.
Thus close likelihood reproduction does not satisfy the predeclared stopping
contract. These results do not establish that the model Hessian is singular
or that those cases reached substantively different local maxima. Keep the
scores and optimizer messages separate from identification/curvature claims.

In contrast, both b09 free searches reach exact c4=0 but stop at 400
iterations, with projected scores 29.3689 and 11.3916. Their independently
evaluated NLLs are 106.872637665 and 106.875338487, both worse than the
saved feasible interior and the applicable free-model limit 106.837779662.
Their 0.00270082 start spread also exceeds the frozen threshold. More
iterations are not allocated automatically to pursue these already dominated
points. Both b19 free searches reach c1=c5=0, but stop at 400 iterations with
projected scores about 5.83e3 and 1.10e4 and extreme remaining parameters.
The separate literal whole-line base-R integrals report `roundoff error was
detected` for both endpoints. These are reference-phase failures, not
successful independent verification of the lower package-evaluated NLLs;
do not use those values to claim a likelihood improvement or LR statistic.
No failed or fabricated gradients occurred in the search records, and the
typed rejected-objective count is zero in this allocation.

The b19 null searches provide a narrower useful result: both original-parent
and neutral starts reach c5=0 near the previously audited local face. Their
NLLs differ from the audited retained point by 8.18e-9 and 4.98e-9 and from
each other by 3.21e-9; maximum coordinate differences from that point are
1.48e-4 and 4.43e-5. Their projected scores are 8.06e-5 and 1.45e-4, and both
retain code 1. The first meets the raw score threshold but not the frozen
optimizer-status requirement. These endpoints received NLL comparisons;
the full independent-score branch was not invoked after their candidate
gate failed. The prior point-specific curvature/score audit remains valid
for its own saved points, not silently transferred to these new endpoints.

All 18 available independent NLL comparisons agree within 4.55e-13. The
three full-score references agree within 1.85e-13. All ten original null
coordinates are unchanged exactly. Fresh-session replay, with optimization,
quadrature, root finding, `rnorm()`, `runif()` and `pkgload::load_all()` disabled, reproduces the
summary and verifies input/result/source identities. A saved-arithmetic
review also reproduces feasibility, active coordinates, projected scores,
candidate flags and passed reference checks, and verifies the archived
source copies. Evidence is in
`validation-results/gmfrm-bounded-search-20261011/`, including `attempts.csv`,
`pairs.csv`, phase records, the immutable manifest and `verification.rds`.
Recorded elapsed times sum to 6809.396 search-worker seconds and 22.145
reference-worker seconds; these parallel-worker sums are not wall-clock
duration. Each allocated search/reference phase ran once; the two
pre-allocation reference-route checks are described in the contract below. Unchanged package
regressions, including the 40 adapter assertions, are reused.

**Decision at that checkpoint (final-precision specification above).** The single shared search mechanism
can reach exact individual-rater boundaries, but this complete procedure
does not satisfy its from-start qualification contract across the retained
designs. Keep it private. Before allocating another fitting or coverage
study, specify a consistent final-point accuracy/curvature procedure for
regular finite solutions, reusing the existing joint-marginal-information
and curvature evidence and accounting for its computation cost. Distinguish
that stopping-precision question from the nonstationary boundary/extreme
paths in b09/b19. Do not relax thresholds, relabel code-1 endpoints, extend
these runs or add starts after inspecting this sample. Earlier valid
likelihood/boundary evidence is retained; the frozen comparison is complete
with an adverse decision. This work order does not narrow the agreed scope:
N20/medium/large designs, boundary behavior, severity/contrasts, Person scoring
and the promised inference outcomes remain open where not qualified. D1 and
public adoption remain open; no public dispatch or statistical claim changed.

**Frozen bounded-search comparison (October 11, before fitting).** The next
question is whether the shared nonnegative-slope search improves the retained
small-sample behavior while preserving regular medium/large-sample behavior.
`inst/validation/gmfrm-bounded-search-20261011.R` allocates exactly 20 searches:
N20 observed/b09/b19, N60 observed and N240 observed, each free/null and from
the original saved parent or native-zero start. These are from-start searches,
not continuations from the extreme earlier endpoints. The null fixes Task-t1
coordinate 15 to **original parent15 + 0.5**; neutral null starts obey the same
target. All starts are mapped once into natural rater-intercept coordinates.
The existing PORT policy (maxit 400, no retries/extensions) is unchanged.

Save each completed search before independent checking. Every evaluable
selected point receives an independent NLL comparison; only first-order
candidates receive the full independent score check. For positive slopes,
reuse the independently coded native 32/64-segmented/Gauss--Kronrod reference
and an explicit inverse Jacobian, propagating both score-rule discrepancies
and score-tail bounds into natural units. For exact zero slopes, use literal
response-probability integration and Richardson NLL differences for the
remaining coordinates, and independently integrate each outward score.
Require NLL agreement <=1e-7, full-score agreement <=1e-6 and independently
projected score <=1e-4; retain reference failures. Before allocation, these
reference routes reproduce the saved N20 interior and audited b19 boundary
scores within 3.37e-14 and 6.30e-10 respectively.

A pair requires two reference-qualified first-order candidates, NLL agreement
across starts <=1e-5, and no domination (at 1e-5) by the saved feasible interior
points or the applicable b09-free limiting path. That path is never a null
comparison or a finite attained MLE. This comparison does not add curvature
audits, study responses, bootstrap draws or coverage allocation, nor does it
qualify global optimization or intervals. Existing common-scale bounds and
limiting laws remain relevant outside the finite intercept chart. Search and
reference phases are independently checkpointed and source/input/runtime
bound; completed phases are reused. Public dispatch and D1 status are unchanged.

**Completed individual-rater boundary audit (October 11).** Both saved
b19-null/rater-5-zero points meet the frozen local-face checks below.
The natural-coordinate nuisance curvature is positive and stable, the
outward NLL derivative is strictly positive, and independently integrated
scores agree. This resolves the interpretation of this particular drift
mechanism: a finite response-intercept representation gives a stable
constrained local candidate even though native severity and steps can
diverge as c5 tends to zero. It does not prove the global constrained MLE,
resolve the unrestricted b19 fit or qualify LR calibration.

| Existing projection | NLL | Maximum free score | Outward c5 derivative | Smallest active-Hessian eigenvalue | Independent score discrepancy |
| --- | ---: | ---: | ---: | ---: | ---: |
| retained | 104.034364726056 | 3.55935e-5 | 1.440474 | 0.03814511 | 6.30e-10 |
| neutral | 104.034364726044 | 3.40604e-5 | 1.440474 | 0.03814511 | 3.84e-10 |

The two NLLs differ by 1.18377e-11 and their finite coordinates by at most
1.10322e-6. Both preserve the original fixed Task-t1 target exactly. Maximum
curvature eigenvalues are about 78.17017; relative two-step Hessian
discrepancies are at most 1.14609e-8. Minimum eigenvalues exceed the empirical
curvature-resolution threshold (at most 8.96e-6) by a wide margin. The five
independent integrated-NLL directional-curvature comparisons per point
agree within 9.741e-8 relative to max(1,absolute curvature). This includes
the least-curved direction rather than checking only the strong directions.
The unchanged evaluator reproduces the saved gradients exactly; retained
independent NLL/outward references agree within 2.85e-14/5.33e-15.

The lower-bounded parameter c5 satisfies the one-sided minimization
condition dF/dc5>0; the remaining 20 free coordinates satisfy the existing
1e-4 score threshold and positive curvature condition. These are numerical
KKT/local-face diagnostics, with small nonzero residual scores, not an exact
stationarity theorem or global search certificate. The fixed Task-t1
coordinate is not a free coordinate in this audit. Do not relabel this as
an unrestricted optimum or remove the current public information guards.
Nor should q5 be reported as a finite native severity: it equals
c5*(s5+tau5), and native severity/contrasts involving rater 5 are not defined
at this boundary. Ability information can still come from other raters.

The preliminary saturated-bound screen retains all 60 comparisons (five
datasets, six possible zero raters, free/null). None excludes a face:
bound-minus-interior margins range from -555.751 to -65.943. The arbitrary
remaining-response distribution makes this a valid but weak bound in these
rosters. Its failure to exclude is not evidence for a boundary maximum and
does not allocate 60 searches. The earlier exact-common-zero exclusions
remain valid and distinct, including the b19 exclusions; the chart relation
below explains why there is no contradiction.

Evidence is in `validation-results/gmfrm-rater-face-20261011/`, produced by
`inst/validation/gmfrm-rater-face-20261011.R`. The two point audits take
270.044 recorded evaluation/reference seconds, with no optimization or new
study responses. A prepare-only RNG guard initially intercepted the package's
existing fixed example-data initialization; placing the research guard
after package loading fixed this before the manifest or audit was created.
Research optimization/RNG remained disabled throughout the point audit.
Fresh-session saved-result replay also disables package loading, quadrature
and root finding, reproduces the 60 bounds and result table, and checks
source/input/result identities. It passes. No package likelihood or score implementation changed;
the point audit itself reused the evaluator. The separate search adapter
implemented subsequently is described below. The applicable earlier tests
and N20/N60/N240 fitting evidence are reused,
not relabelled as successful fits under a new procedure.

**Private bounded-search mechanism implemented.**
`R/core-gmfrm-bounded-search.R` adds an unexported adapter around R's
[`nlminb()`](https://www.stat.ethz.ch/R-manual/R-devel/library/stats/html/nlminb.html)
for the natural evaluator's zero/nonnegative and unbounded coordinates.
This uses the existing lower-bound model, not a positive slope floor.
Fixed native target coordinates are embedded unchanged. Optimization uses
explicit scaled free coordinates and NLL per Person, while terminal checks
use the original unscaled gradient. At an exact free lower bound, the
projected component is min(gradient,0); a tiny positive slope is not silently
treated as zero. A negative outward derivative can release a zero slope.

Typed failed objective evaluations return +Inf. Gradients come only from
successful direct evaluations; a gradient failure or unexpected error remains
an error with the best evaluable point retained. The optimizer code, endpoint,
selected point, active coordinates, outward scores and last numerical
rejection remain available. A first-order candidate requires code zero,
no error, raw projected score <=1e-4 and exact fixed coordinates. An
iteration stop remains a stop even when its selected point is stationary.
No Hessian/global-optimality or inferential eligibility is implied.

The new seven-test file `tests/testthat/test-gmfrm-bounded-search.R` passes
all 40 assertions, with no errors, warnings or skips, in the recorded local
R 4.6.1 environment. It covers a coupled convex quadratic with a known
active-boundary solution and a fixed target, release toward a known interior
solution, backtracking over an unavailable trial, code-zero/nonstationary
and near-zero counterexamples, gradient-only/unexpected failures, retained
iteration stops and invalid inputs. No fitting/comparison data were used to
tune this adapter. Its policy is one PORT call, iter.max=400 by default,
eval.max=5*iter.max, rel.tol=1e-12 and x.tol=1e-10; it has no automatic retries
or starts. This is a tested search mechanism, **not a GMFRM fit-performance
result**. Existing optimizers and public dispatch remain unchanged, so the
earlier likelihood, search and inference evidence retains its original scope.

**Decision before the bounded comparison (completed above):** preserve this finite c5=0 null candidate and stop
treating its native parameter drift as a reason for further native-coordinate
iterations. The private shared search mechanism now admits nonnegative rater
slopes, preserves the original target/null and checks actual projected scores
and outward directions without fabricated rejected-trial gradients. Couple it to the
existing likelihood bounds and common-scale candidates; this chart does not
represent every diverging-location or diverging-first-family limit. Qualify
its GMFRM behavior in a separately frozen bounded comparison across the
retained N20, N60 and N240 conditions, specifying start origins and independent
checks and keeping all failures and all original targets. The known-solution
tests do not replace this comparison or justify public optimizer substitution.
This result allocates no additional starts, iterations, bootstrap draws or
coverage study. It does not require an exhaustive boundary catalogue before
regular-interior support. D1, general method adoption, native severity/
contrast eligibility and interval calibration remain open.

**Individual-rater boundary audit contract (October 11, before evaluation).**
At c_r=0 in the rater-intercept chart, adjacent logits for that rater are
-a_i q_rk; its ratings factor out of the Person integral. The other raters
can retain ability dependence. An unrestricted categorical model for these
zero-rater cells, multiplied by an unrestricted joint response-pattern model
for the remaining ratings within each observed remaining roster, bounds this
family's likelihood. A saved-response calculation of this bound for all six
raters in all five datasets excludes no free/null case: the bound is too
loose. Do not allocate optimizations to all 60 comparisons merely because
this screening bound is inconclusive.

The two retained b19-null/rater-5-zero projections are already accurately
evaluated and have free-coordinate scores below 1e-4 and a positive outward
NLL derivative near 1.44047. Audit these **existing points**, without new
optimization or a changed null, to decide whether native severity drift is
consistent with a locally regular finite face in the intercept coordinates.
Hold original Task-t1 log slope (coordinate 15) and c5=0 (coordinate 21)
fixed; all other 20 coordinates vary. Keep the same two saved starts and
require original-target error zero, all other slopes positive, free score
<=1e-4 and strictly positive outward derivative. Compare NLL and the outward
score with the retained independent literal references (1e-7 and 1e-6).
Independently integrate literal response probabilities for central score
differences at 1e-4/5e-5 times max(1,abs(coordinate)); require Richardson
score agreement <=1e-6. Form active Hessians from natural scores at the same
two step scales; require relative spectral step discrepancy <=1e-5 and
minimum eigenvalue > max(1e-7*max(1,max(abs(eigenvalues))),10*step discrepancy).
Check curvature additionally by independent integrated-NLL second differences
along the smallest/largest eigenvectors and three fixed sine directions at
1e-3/5e-4, with relative Richardson agreement <=1e-4. Preserve all failures.
These are numerical local-face/KKT checks, not global optimality, target
identification over every boundary, finite-sample LR calibration or a new
fitting policy. Reuse N20 observed/b09 and N60/N240 fitting evidence without
relabelling it as evidence of this new boundary procedure. No additional
starts, iterations, responses or bootstrap draws are allocated.

The individual-rater and common-scale charts describe different finite parts
of the same model closure. With c5=epsilon and the other c_r fixed positive,
write C=(product_{r!=5} c_r)^(1/6). Then

```
lambda = C epsilon^(1/6), v = C^2 epsilon^(1/3),
rho5 = epsilon^(5/6)/C, rho_r = c_r/(C epsilon^(1/6)) for r!=5,
sqrt(v) a_i rho_r = a_i c_r.
```

Thus v tends to zero but the effective ability slopes for the five other
raters stay positive. This is not a finite common-zero chart point; its
relative slopes diverge. For fixed finite q5k, s5=mean(q5)/epsilon and
tau5k=(q5k-mean(q5))/epsilon also need not remain finite. This explains why
excluding the independent exact-zero family does not exclude the informative
individual-rater boundary, without changing the latent N(0,1) distribution
or the original Task-t1 constraint.

For a Person's ratings Y, the zero-rater law factorizes as
P(Y)=product_{j:r_j=5} p(y_j | a_i,q5) times P(Y_{-5}). Its original-ability
posterior therefore equals the posterior from the remaining ratings, not
necessarily the prior. The exact outward NLL score is

```
dF/dc5 = -sum_{j:r_j=5} a_i [ E(theta_p | Y_{p,-5}) - b_i ] (y_j-mu_j).
```

It retains the posterior from the other raters and the original Task
locations. Replacing it by an unconditional mean-zero theta score would be
incorrect. Along the q-fixed log-c5 path, the derivative is c5*dF/dc5;
it vanishes as c5 tends to zero even when the natural-coordinate outward
derivative is strictly positive. This provides a mathematical reason for
flat log-scale searches. Finite q5 is a response-probability parameter,
not a finite native severity s5 or its contrast with another rater.
Boundary feasibility, original-ability scoring and each structural interval
therefore require separate output contracts.

**Completed global exclusion and explicit limiting-path diagnosis (October 11).**
The next decision is informed by a bound on an entire response-law family,
rather than more attempts to finish each common-zero optimizer. Eight of the
ten retained case/constraint groups cannot achieve the best available feasible
positive-variance likelihood anywhere on the exact v=0 family or its closure.
The two remaining groups are N20 b09 free/null. This is a boundary exclusion,
not qualification of the full estimator or its intervals.

For v=0 and finite discrimination, conditional probabilities no longer depend
on Person ability. Conditional on the retained assignment, the likelihood is
the product of Task-by-Rater categorical probabilities. Write n_irk for the
observed category counts and n_ir for their totals. Allowing each cell its own
arbitrary probability vector gives the following lower bound on NLL:

```
F_sat = - sum_{i,r,k:n_irk>0} n_irk log(n_irk/n_ir)
F(p) - F_sat = sum_{i,r:n_ir>0} n_ir KL(p_hat_ir || p_ir) >= 0.
```

These are probabilities of labelled responses, with **no multinomial
factorial constants**. Unobserved categories use 0 log 0 = 0, and empty cells
contribute zero. The bound applies to every finite model point, both free and
null, and to limits of these independent categorical laws, including paths
with diverging discrimination/locations. It does not require an attained
boundary minimum, a stationary point, a Hessian or successful optimization.
If any feasible positive-variance point has F_int < F_sat, the whole family
is dominated. A feasible constrained point also belongs to the free parameter
space: the accurately evaluated b19-null point supplies the comparison for
b19-free despite its unavailable unrestricted numerical reference.

| Retained dataset | Saturated lower NLL | Free: lower bound minus feasible interior NLL | Null: lower bound minus feasible interior NLL | Exact-zero family excluded? |
| --- | ---: | ---: | ---: | --- |
| N20 observed | 112.590486 | 1.490432 | 0.873290 | Both |
| N20 b09 | 100.934763 | -5.906026 | -6.330814 | Neither by this bound |
| N20 b19 | 104.065055 | 0.030673 | 0.030673 | Both; same null point is feasible for free |
| N60 observed | 375.939885 | 30.796176 | 28.855309 | Both |
| N240 observed | 1528.881116 | 103.553684 | 94.555154 | Both |

All selected interior values already passed the independent numerical
reference and original-target checks; they need not be optimal to give this
comparison. The smallest positive margin, 0.03067, is well above the retained
1e-7 NLL agreement criterion. That criterion is numerical evidence, not a
new rigorous quadrature error enclosure. In particular, the b19 null
common-zero discrimination drift and absolute outward-score refusals need
no further optimization to decide this **particular boundary comparison**.

For the remaining b09-free case, an explicit feasible path explains why
additional log-coordinate iterations can chase a finite likelihood limit.
Let H_rk = S_r + T_rk at one of the three saved free endpoints and retain B.
For t >= 0 use

```
a1(t) = a1 exp(-t), a2(t) = a2 exp(-t), a3(t) = a3 exp(2t),
rho_r(t) = rho_r exp(t) for r != 4; rho_4(t) = rho_4 exp(-5t),
H_rk(t) = -B3 + exp(-3t) (B3 + H_rk)
          for r != 4 and [k=1 or r in {1,2}],
H_r2(t) = H_r2 for r in {3,5,6},
H_4k(t) = -B3 + exp(3t) (B3 + H_4k),
S_r(t) = mean_k H_rk(t), T_rk(t) = H_rk(t) - S_r(t), v(t)=0.
```

For every finite t, slopes remain positive, both slope geometric means stay
one, sum B stays zero and each rater's steps remain centered. Adjacent logits
are still exactly -a_i(t) rho_r(t) [B_i + H_rk(t)]. The path changes the original
Task-t1 target, so it is **only a free-model path**, never a replacement for
the original null. Its data-specific role is explicit: category 2 is absent
at Task 3 for raters 3/5/6. At those cells its probability tends to zero;
the Task-3 adjacent logits for the observed categories stay finite. For
rater 4, Task-1/2 probabilities tend to 1/3, while Task-3 probabilities stay
fixed. All observed-response probabilities have finite positive limits.

The algebraically evaluated endpoints at t=0,0.5,1,2,4,8 and the limit give:

| Saved start | Initial NLL | Limit NLL | NLL improvement |
| --- | ---: | ---: | ---: |
| retained | 106.837856862 | 106.837779680 | 0.000077182 |
| neutral | 106.837854096 | 106.837779745 | 0.000074351 |
| chart neutral | 106.837808188 | 106.837779662 | 0.000028526 |

Thus all three endpoints have explicit better limiting values, differing
by less than 8.4e-8 across starts and about 0.00301 below the best retained
positive-variance free value. This is evidence for a relevant noncompact
direction, **not proof that a finite global MLE cannot exist elsewhere**, a
global boundary supremum, or monotonicity at every unexamined t. The new
calculation does not declare the previous searches converged. It also does
not settle b09-null, whose fixed target cannot follow this path.

Scope matters for the exclusion: v approaching zero simultaneously with
diverging a_i rho_r can retain nonzero effective ability slopes
sqrt(v) a_i rho_r. Such joint limits can preserve Person dependence and need
not belong to the exact-zero response-law closure. Neither this bound nor
the constructed path excludes those limits or individual-rater boundaries
with remaining positive ability information. At exact zero, the original
ability posterior remains the prior; finite response probabilities do not
provide precise original-ability scoring or regular slope/severity intervals.

The standalone saved-arithmetic script
`inst/validation/gmfrm-zero-envelope-20261011.R` checks raw-row versus count
likelihoods, same-target feasibility and the three paths. Its independent
Python reference uses 100-digit literal transformed parameters (not the R
cancellation-avoiding logits), including finite t=20/40 checks against the
analytic limits. All 26 reference values agree within 2.27374e-13; the
identification constraints hold within 1e-80 in that reference. A fresh R
session reproduces the saved results with optimization, integration, RNG and
package loading disabled. Sources, inputs, results and reference are bound
in `validation-results/gmfrm-zero-envelope-20261011/`. No new fitting,
responses, quadrature, package-source changes or repeated package tests were
needed; the earlier package assertions and all original outcomes are retained.

**Decision at the envelope checkpoint (refined above):** stop pursuing common-zero optimizer completion in the
eight excluded groups. Retain the b09-free path as a concrete limiting-law
case and b09-null as unresolved by the global bound; do not infer a
sample-size-only defect from two selected generated datasets. Return the
general method design to comparisons with positive-variance and supported
individual-rater/combined limits under the original targets, using likelihood
bounds before allocating nuisance searches. A complete catalogue of all
limits is not a prerequisite for useful regular-interior support. No extra
starts, iteration increases or bootstrap draws are allocated by this result.
N20, medium/large designs, severity/contrasts and original-ability scoring
remain in scope; D1, public adoption and interval calibration remain open.

**Completed reduced profile search and rejected-trial repair (October 11).**
The private profile evaluator implements the envelope gradient and Schur
curvature derived below. It rejects unqualified inner solutions, applies the
first-order inner-residual diagnostic, and preserves the original fixed
coordinate and v=0. Its optional analytic derivatives leave the earlier
location evaluator's default arithmetic and search unchanged. Source-level
comparison with the saved epoch and the 65 location assertions confirm that
reuse. The 39 new profile assertions check direct-engine agreement, actual
reoptimized profile differences, curvature, original-null preservation,
query-order/cache behavior and inner-failure refusal. The initial two test
failures were misspelled expected error classes, corrected to the existing
`mfrmr_adaptive_quadrature_numeric_error`; no computational rule changed.

The frozen 30-search comparison finishes in 2.272 recorded search/review
seconds. This measures warm-start continuation plus a neutral start under
the stated policy, not speedup over full fitting or a new simulation.

| Original profile outcome | Attempts | Interpretation |
| --- | ---: | --- |
| Declared stationary profile candidates | 16 | Independent response/score checks, inner and outer stationarity, curvature comparison, code zero and unchanged targets. |
| Stationary, profile-curvature reference unresolved | 3 | N20 b09 null, all three starts. Relative discrepancies about 4.07e-5 exceed 1e-5; analytic curvature is positive but the frozen reference criterion is not waived. |
| Stationary, outward-score absolute reference unresolved | 2 | N20 b19 null retained/neutral. Absolute discrepancies 7.63e-6 and 1.25 exceed 1e-6 at derivatives about -2.45e10 and -1.55e15. Their relative discrepancies are about 3.11e-16 and 8.04e-16; these are absolute-precision refusals, not evidence of a wrong derivative sign. |
| Code-zero, nonstationary after rejected trials | 7 | All N20 free continuations with evaluable starts; the selected outer score remains above 1e-4. |
| Initial inner calculation unavailable | 2 | The retained/neutral extreme N20 b19 free starts; both failures are retained. |

Across the 16 declared candidates, maximum NLL, full-gradient and outward
discrepancies are 1.61436e-11, 5.68160e-11 and 1.74623e-10; maximum outer
score is 2.34970e-6 and relative curvature discrepancy 4.83750e-6. Every
one has a negative outward derivative (-1.004e10 to -630.18): increasing
variance improves the likelihood at that particular point. These are
therefore not full feasible optima. Some N20 constrained starts produce
nearly identical NLL with very different discrimination and outward scores;
the b19-null profile has outer curvature eigenvalues near 1e-15 and log
relative slopes reaching about -49.56. A small log-coordinate gradient in
that flat region does not establish finite outer attainment or regular
target information.

**Common stopping defect and bounded repair.** A one-dimensional quadratic
with its optimum inside the evaluable domain reproduces the legacy
finite-penalty wrapper returning code zero at a nonstationary start. The
private BFGS search instead returns +Inf for typed failed inner evaluations,
lets backtracking shorten the trial and supplies gradients only from direct
successful evaluations. Fourteen regression assertions cover this
counterexample, convergence to its known optimum, retention of unexpected
errors and best evaluable points. The shared/public optimizer is unchanged.

All seven allocated continuations finish in 12.045 recorded seconds. NLL
improves in every case, by 0.00007576--1.249581. The outer scores decrease
but remain 0.000108435--0.00273858: all seven retain code-1 maxit400 stops,
and none is declared qualified. Six pass the independent terminal checks;
the b19-free neutral-chart continuation has outward absolute discrepancy
5.72205e-6 at a derivative near -6.55316e9. One observed-free continuation
cannot complete the profile-curvature perturbation because its inner solve
refuses; all such reference failures remain visible. No additional retries
or tolerance relaxation follow. The other 23 original outcomes are reused.

Combining saved results for comparison, seven of ten case/constraint groups
agree across all three starts within 1e-5 NLL: all four N60/N240 groups and
the three N20 null groups. N20 observed-free and b09-free spreads remain
8.25795e-5 and 4.86732e-5. Only one b19-free start is computable, so its
single value is not start agreement. The best b09-free boundary NLL is
0.00298108 below the retained independently checked interior value, but its
nonstationarity means this does not establish the supremum. Other groups
with independent interior references have worse common-zero values, by
1.11762--107.33257. The b19-free interior reference is still unavailable.
These comparisons do not rule out unvisited boundary or interior optima.

All 118 affected/new assertions pass; both epochs pass fresh-session,
numerical-work-disabled aggregate replay and source/input/result/archive
checks. Evidence is in `validation-results/gmfrm-zero-profile-20261011/`
and `validation-results/gmfrm-zero-backtrack-20261011/`. The saved-only
`comparison.R` binds both result sets and the prior interior references.
No responses, bootstrap, positive-variance or individual-rater fits were
added, and no public estimation/scoring/inference path was changed.

**Decision at the reduced-search checkpoint (refined above):** keep the convex reduction
and repaired rejected-trial handling as internal components. Do not adopt
this composite search for LR inference or extend the completed allocation.
The remaining method decision is about finite outer solutions versus
limiting discrimination paths and their comparison with positive-variance
and supported individual-rater boundary candidates, under the same targets.
Do not treat a flat log-coordinate score or zero-common-variance minimum
as the full likelihood optimum. Regular-interior support need not await a
complete catalogue of all limits; N20, other designs, severity/contrasts and
original-ability scoring remain in scope. D1 and interval calibration remain open.

**Rejected-trial follow-up contract (October 11, before continuation).**
The 30 reduced searches have completed. Seven N20 free fits retain outer
scores above 1e-4 after rejected inner trials, yet L-BFGS-B reports code zero.
Its existing wrapper replaces rejected values with 1e100 and gradients with
zero; a separate one-dimensional quadratic with an unavailable trial region
reproduces false convergence at the starting point. This is a numerical
stopping issue, not evidence of a local optimum. The shared/public optimizer
is not changed by this internal comparison.

Apply one fixed private BFGS continuation to exactly those seven saved best
points. Return +Inf only for typed failed inner evaluations; provide no
fabricated gradient, and preserve other errors. R's BFGS backtracking must
reach a finite evaluated point before using its gradient. Keep maxit400,
fnscale N and initial parscale max(1,abs(q)), with reltol equal to machine
epsilon. Independently validate the selected endpoint under the existing
profile contract. Preserve original outcomes and all failures; do not rerun
the 16 qualified candidates, three stationary curvature-reference refusals,
two stationary outward-reference refusals or two unavailable initial points.
This is a bounded method repair using existing responses, not independent
confirmation of a complete multi-stage estimator or a new iteration extension.

**Reduced outer-search contract (October 11, before fitting).**
For finite discrimination coordinates q, let l*(q) minimize the convex
location block and P(q)=f(l*(q),q). Under the established full support rank,
the finite inner Hessian H_ll is positive definite and the implicit-function
calculation gives `P_q=f_q` and `P_qq=H_qq-H_ql H_ll^{-1} H_lq`.
These formulas do not make P convex. For each cell, log discrimination is
linear in q with row Z_j and logits L_jk=X_jk l. Hence
`f_q=sum_j Z_j sum_k (n_j p_jk-n_jk) L_jk`; the unprofiled outer curvature
is `sum_j Z_j' Z_j [sum_k (n_j p_jk-n_jk)L_jk+n_j Var_p(L_jk)]`.
The cross Hessian is the sum of the corresponding residual-X and
`n_j Cov_p(X_jk,L_jk)` terms, each multiplied by Z_j. These are analytic
derivatives of the same likelihood, without penalties or target changes.

The new private profile evaluator returns a value/gradient only after the
unchanged inner search qualifies. At every trial, use the last qualified
locations, then zero locations if needed; rejected trials cannot replace
that warm start. Retain the maxit80 inner policy and tolerances. Additionally
require the magnitude of `H_ql H_ll^{-1} f_l` to be <=1e-6 for every free
outer coordinate. This is a first-order residual diagnostic, not a rigorous
error bound. Cache exact successful queries, invalidate failed queries,
and retain failures. The optional profile derivative calculation leaves the
old location evaluator's default arithmetic and search unchanged.

After tests against the direct engine and finite differences that reoptimize
the inner problem, run 30 bounded profile searches: the five retained
datasets, free/original Task-t1 null, three starts each. The retained/neutral
starts use the saved-location outputs of the completed location study.
The chart-neutral start resets all locations/discrimination coordinates to
zero, retaining the original null coordinate and v=0, to preserve a distinct
start rather than another already-drifted endpoint. Use the existing
L-BFGS-B candidate policy (maxit400, factr1, pgtol1e-8, lmm20, fnscale N,
parscale max(1,abs(initial outer coordinates))) on the seven/six free outer
coordinates. This is a continuation comparison, not a fair timing comparison
with the original all-coordinate fits. Failed starts remain in the denominator.

Freeze terminal requirements: inner qualification, free outer score<=1e-4,
exact original null and v preservation; independent literal NLL<=1e-7,
complex-step full nonvariance gradient<=1e-6 at h=1e-20 and 1e-24,
and independent outward derivative<=1e-6. Check analytic profile curvature
against central profile-gradient differences at h=1e-4 and 5e-5 times
max(1,abs(outer coordinate)), reoptimizing the inner block. Require relative
spectral discrepancy<=1e-5 and no negative curvature resolved beyond
max(1e-7*max(1,max(abs(eigenvalues))),10*two-step spectral difference).
Optimizer code-zero qualification, independent stationarity, negative outward
directions and agreement across starts (NLL spread<=1e-5) remain distinct.
Compare with retained qualified interior and boundary values. Preserve every
stop; do not automatically extend iterations or add starts. No new responses,
positive-variance/individual-rater search, LR calibration or public adoption
is allocated by this bounded common-zero study.

**Completed fixed-discrimination location block (October 11).**
`mfrm_gmfrm_zero_location_problem()` aggregates observed cell/category counts
and computes analytic location gradients and Hessians; its companion Newton
search requires the sufficient support certificate derived below. All five
datasets have support-difference rank 14/14. Hence the inner optimum is
finite and unique for each fixed finite discrimination vector, including
vectors at which floating-point calculation is difficult. This does not
establish a uniformly bounded inner solution when discrimination tends to
zero/infinity, or a finite/full optimum of the outer problem.

All 60 predeclared attempts complete in 7.674 recorded search/review seconds.
The calculation reuses 30 saved discrimination vectors with saved/zero
location starts, not 60 newly generated datasets or complete GMFRM fits.

| Frozen outcome | Attempts | Meaning |
| --- | ---: | --- |
| Qualified inner candidates | 48 | Inner stationarity, independent response/derivative/curvature checks and exact nonlocation preservation. |
| Inner stationary, original reference check unresolved | 3 | N20 b09 free saved-location starts; original central-difference checks fail despite small analytic scores. |
| Iteration limit | 5 | Three b09-free zero-location starts and both b19-free chart-neutral endpoints; no automatic extension. |
| Numerical curvature unresolved | 4 | The two extreme b19-free discrimination vectors from each location start; this is not failure of the mathematical existence certificate. |

For the 48 qualified returns, maximum independent NLL discrepancy is
9.77707e-12, full coordinate score discrepancy 6.40579e-7, outward discrepancy
5.82077e-11 and relative location-Hessian discrepancy 2.39029e-9. Maximum
analytic location score is 7.82153e-9; stopping takes 2--7 iterations.
All 24 matching location-start pairs agree within 6.82121e-13 NLL, and all
60 nonlocation-coordinate errors are exactly zero. Nevertheless, 18 of the
48 have free discrimination scores 0.0009205--0.0951581, above 1e-4. They
are the N20 observed free/null and b19-null groups. Successful inner solves
therefore expose a remaining outer optimization problem; they do not qualify
full boundary or LR fits. Existing N60/N240 interior/boundary evidence remains.

**Independent-reference diagnosis, without refitting.** Rechecking all 51
inner stationary returns at central-difference steps eight times smaller
reduces the three b09 discrepancies from 4.03779e-4, 1.29209e-3 and 1.69267e-5
to 9.91591e-8, 3.19355e-7 and 8.33410e-9. But 11 N240 discrepancies increase
beyond 1e-6 (maximum 3.01016e-6). A uniformly smaller step is not a general
reference repair: truncation and subtraction error require different care.
The original frozen statuses and all these diagnostic results are retained.

A subsequent independent complex extension of the literal response equation
checks all 51 stationary points, at fixed h=1e-20 and 1e-24 for every free
coordinate except variance. For this analytic response law,
`Im f(z+i h e_j)/h = df/dz_j + O(h^2)`; shifting logits by their maximum
real part cancels in normalized probabilities. No large-NLL subtraction,
package decoder or package gradient is used in this reference. Maximum
NLL discrepancy is 8.41283e-12, full-gradient discrepancy 1.04142e-12 and
between-step discrepancy 7.84065e-13. This independently supports the three
additional inner solutions and the original 48; it does not retroactively
change the frozen finite-difference outcomes. It does not check the variance
derivative, whose independent conditional-law comparison remains separate.

All 65 new regression assertions pass, including binary/four-category,
unequal-slope, incomplete-data, known finite-optimum and unsupported-existence
examples. Existing natural-evaluator/search source files are unchanged, so
their completed 199 assertions are reused rather than rerun. Evidence and
source snapshots are in `validation-results/gmfrm-zero-location-20261011/`.
Its top-level `verify.R` passes source/input/archive/result binding checks and
byte-identical aggregation with numerical work disabled. The producer's first
nested verification entry hit R 4.6.1's standard-namespace mutation restriction;
the top-level verifier fixes this execution issue without repeating any fits.
The two supplementary reference scripts/results bind their own source and
the unchanged fitting results. No bootstrap, outer search or new responses
were generated.

**Decision before the reduced outer study:** retain the exact convex block
and its sufficient finite-solution certificate as an internal candidate.
The next method design should reduce the outer search from 21 free boundary
coordinates to seven discrimination coordinates (six under the original
null), while qualifying inner initialization/stopping and independent
derivatives across scales. Avoid an automatic maxit increase or adopting
all successful inner solves as full solutions. Original target/nulls,
other boundary/interior candidates, severity/contrast identification and
original-ability scoring remain essential. Public adoption, LR calibration,
coverage and D1 completion remain open.

**Fixed-discrimination location-block contract (October 11, before calculation).**
At v=0, hold both finite discrimination families fixed. Write the cumulative
category logits in observed owner cell j as `X_jk l`, where l contains the
identified location/step coordinates and `X_jk = -w_j D_jk`. With category
counts n_jk, the negative log likelihood is
`f(l) = sum_j [n_j log sum_k exp(X_jk l) - sum_k n_jk X_jk l]`.
Its gradient is the expected minus observed sufficient statistic and its
Hessian is `sum_j n_j Cov_p(X_jk)`, hence positive semidefinite. Aggregating
these counts is exact only for this zero-variance conditional law; the
outward variance derivative must still use the original Person grouping.

Convexity alone does not imply a finite optimum. Along a recession direction
d, the recession function is the sum of the nonnegative quantities
`n_jk [max_h X_jh d - X_jk d]`. For it to be zero, all categories observed
in the same cell must tie at the maximum. Form a matrix of their within-cell
logit differences. If it has full column rank, only d=0 can satisfy these
equalities: f is coercive. The same rank condition implies strictly positive
location curvature at every finite point, so a unique finite minimum exists.
Each cell's positive w merely rescales its difference rows; check rank on
the unweighted integer design. This is a sufficient, not necessary,
certificate. Failure of this certificate is not proof of nonexistence.

Implement a private analytic location gradient/Hessian and damped Newton
search, with column scaling, Cholesky solves and explicit numerical-curvature
refusal. Do not use a pseudoinverse, ridge penalty, parameter cap or change
the null. The maximum logit change in a proposed step is 10 before Armijo
backtracking (coefficient 1e-4; at most 50 halvings); it is a step restriction,
not a bound on the fitted parameter. Allow only rounding-scale NLL ties
with a decreasing scaled score. Fix maxit=80, raw score<=1e-6, scaled
score<=1e-8 and squared Newton decrement<=1e-12. A scaled Hessian reciprocal
condition number below 1e-12 is an explicit unresolved numerical state,
not statistical nonidentification or evidence against a finite optimum.

Reuse all 30 saved common-zero search endpoints: five datasets, free/null,
three original starts. At each endpoint freeze its discrimination parameters
and v=0; run the location block from its saved locations and from zero
locations (60 bounded attempts). Test binary/four-category, unequal-slope,
incomplete-data and absent-support examples before this calculation. Compare
with the observation-level engine and independent literal response equations:
NLL<=1e-7, full coordinate finite-difference gradient<=1e-6, outward score
<=1e-6, and analytic location-Hessian relative discrepancy<=1e-6. Retain
two finite-difference steps (1e-4 and 5e-5 times max(1,abs(coordinate))) and
Richardson extrapolation. Original nonlocation coordinates must be unchanged
exactly. Independent numerical qualification and solver stopping are separate.
Compare the two location starts at fixed discrimination within 1e-5 NLL;
inspect the remaining free discrimination score instead of treating successful
inner solutions as full optima. Preserve all failures and earlier outcomes.
No new responses, outer discrimination optimization, LR calibration or public
estimator change is allocated. This block has 14 location coordinates in the
retained design; a later profile search would have seven discrimination
coordinates (six under the original null). The outer problem remains
nonconvex, and all other boundary/interior and D1 obligations remain.

**Completed variance-score and common-zero search increments (October 11).**
The evaluator now implements both exact variance-score identities, selected
by the frozen per-Person envelope rule below. The 20 positive common-scale
evaluations finish with 18 independently qualified points, one computation
without an independent reference, and one numerical refusal. All 18 retain
bit-identical NLL and nonvariance scores. Maximum NLL reference difference is
6.82121e-13, full-gradient difference in log-chart units 9.40031e-11, and
natural-gradient difference from the saved heat calculation 5.99521e-13.
The original null/target errors are zero. Both b09-free points use heat for
all 20 Persons; the N60/N240 points use the prior score for every Person.
Mixed choices occur on the other N20 points, as allowed by the same rule.

The b19-free neutral-start point now meets all direct numerical gates
(score-rule difference 1.14072e-7, score-tail bound 2.07988e-9), but its missing
independent terminal reference is not waived. The retained-start point still
refuses: its variance-score rule discrepancy is now 7.35770e-9, while three
location-score components have discrepancy 0.0876110; the largest score-tail
bound is 3.19921e-9. This separates the repaired variance-score representation
from unresolved extreme location-score integration. No public failure count
or estimator eligibility is changed. The untouched rater-coordinate epoch
retains its own one refusal and one missing reference.

The next increment adds `mfrm_gmfrm_natural_search()` and vectorizes the
exact common-zero likelihood/gradient, preserving Person grouping for the
outward score. All 30 common-zero nuisance attempts finish on the five saved
datasets, free/null, from both saved projections and a chart-neutral start.
The sum of recorded search-plus-review times is 5.872 seconds in this runtime
(0.041--0.516 per attempt). This is a measurement of this exact-zero study,
not a benchmark for positive-variance fitting or other environments.

| Outcome | Attempts | Interpretation |
| --- | ---: | --- |
| Declared stationary boundary candidates | 9 | Code 0, independent NLL/gradient/outward checks, nuisance score <=1e-4 and no resolved negative nuisance curvature. |
| Independent stationary points with line-search error | 6 | Code 52 is retained. The independent criteria and positive nuisance curvature pass, but the frozen code-zero candidate contract does not. |
| Iteration limit | 13 | Code 1 is retained; none meets the nuisance score criterion. |
| Code-zero results failing independent/stationarity checks | 2 | Both extreme b19-free saved starts; code zero does not qualify them. |

Across all 30 attempts, 24 pass the independent response/derivative checks;
15 of these also meet the nuisance-score criterion. For those 15, maximum
NLL discrepancy is 2.06910e-11, full nuisance-gradient discrepancy 3.62148e-7,
and outward-derivative discrepancy 2.27374e-12. Their smallest nuisance
curvature eigenvalues are 0.04975--2.46188. All fixed coordinates are
preserved exactly. The six line-search errors are not rerun just to obtain
code zero; conversely the two false code-zero returns are not accepted.

The three starts agree within 1e-5 in five case/constraint groups: N20 b09
null, and N60/N240 observed free/null. Their actual NLL spreads are at most
4.41105e-11. The best common-zero NLLs are higher than the saved independent
interior values by 1.11762, 35.29318, 33.76811, 107.33257 and 100.18563,
respectively. Every one of their 15 candidates has a negative outward NLL
derivative, so increasing variance gives a feasible improvement. These
particular boundary candidates are not full feasible optima. Agreement of
three starts does not exclude a different, unvisited boundary optimum.

For b09 free points, two searched boundary values improve on the saved
interior values by about 0.00126--0.00150, but nuisance scores are still
0.58--1.26 across the three starts and the finite-difference checks do not
qualify. That improvement does not establish the likelihood supremum.
The other unresolved N20 groups retain their nonstationarity, start
disagreement and/or numerical discrepancies. No new responses were generated.
This allocation covers the common-zero boundary only; individual-rater
boundary optimization and renewed interior searches have not been run.

All 199 relevant assertions pass (174 evaluator, 25 search). The search tests
explicitly include a zero gradient at a nonminimum and distinct minima from
different starts; results always mark global optimality unassessed. An initial
double-well fixture starting at +/-2 landed at the central stationary maximum;
the final tests use +/-1.2 for the distinct minima and retain the central
counterexample explicitly, rather than changing the optimizer to hide it.
Source/input/archive/result checks and fresh-session byte-identical aggregate
replays pass for both studies. The positive-v calculation is reused after
verifying that the only subsequent evaluator change is the exact-zero branch.
Evidence is in `validation-results/gmfrm-variance-score-20261011/` and
`validation-results/gmfrm-zero-search-20261011/`, with their corresponding
repository-only producers and read-only `verify.R` files.

**Decision before the location-block study:** retain the stable score identities, efficient exact-zero
evaluation and transparent candidate-search diagnostics. Do not adopt this
one-stage all-parameter search as the GMFRM LR procedure or increase its
iteration limit automatically. The general optimization design still needs
work. At common variance zero and fixed discrimination components, the
location/step logits are affine in the location parameters, so their negative
log likelihood is convex. Profiling this block is a mathematically motivated
next design to examine before further all-parameter retries. Convexity of
that block supplies neither finite-MLE existence nor global optimality of
the remaining discrimination search. Keep supported individual boundaries,
original target/nulls, N20/N60/N240, severity/contrast identification and
original-ability scoring in scope. No LR calibration, coverage qualification,
public fitting change or D1 completion follows from these results.

**Common-zero nuisance-search contract (October 11, before fitting).**
After the variance-score comparison, vectorize the exact v=0 conditional
likelihood/gradient: probability rows can be summed directly, while the
outward variance score retains Person grouping. This changes no positive-v
arithmetic and avoids repeated quadrature or Person kernels during boundary
optimization. Test against the retained independent literal equations and
zero/near-zero checks before fitting. Reuse the completed positive-v epoch.

Run a bounded internal search on all five retained datasets (N20 observed,
b09, b19; N60/N240 observed), free and original Task-t1 null. For each, use
both saved endpoint projections and one newly constructed neutral chart
point with the same null coordinate: 30 attempts, no new responses. Fix v=0
and, for null fits, the original task-log-slope target; optimize the remaining
coordinates with the same L-BFGS-B policy (maxit=400, factr=1, pgtol=1e-8,
lmm=20, fnscale=N, initial parscale=pmax(1,abs(start))). Preserve every stop,
failure, best evaluable point and numerical rejection. This iteration bound
defines this comparison, not an automatic license for escalating retries.

Check terminal NLL and outward derivative against independent conditional
equations (1e-7 and 1e-6); check all nuisance gradients by literal central
differences at h=1e-4 and 5e-5 times pmax(1,abs(parameter)), with Richardson
agreement 1e-6. Require nuisance score <=1e-4 and original fixed-coordinate
error zero for first-order evidence. Inspect nuisance curvature with central
gradient differences at the same two steps, keeping asymmetry and differences
visible. A resolved negative eigenvalue rules out a minimum; semidefiniteness
does not prove one. Full positive definiteness is not a prerequisite for
likelihood evaluation. Inspect agreement in NLL across starts (1e-5), and
compare with saved interior NLL only where that reference was qualified.
An outward NLL derivative below -1e-4 rules out a full feasible optimum at
that boundary candidate. None of these results is a global certificate or
an adopted LR procedure. Individual-rater boundary searches and renewed
interior searches remain separate from this common-zero allocation.

**Variance-score stability contract (October 11, before saved-point work).**
For each Person, let F(u) be the conditional response likelihood and v the
common variance. For v>0, differentiating `integral F(u) phi(u;0,v) du`
gives `d log L/dv = E[(theta^2-1)/(2v) | responses]`, with u=sqrt(v)*theta.
Twice integrating by parts instead gives `E[F''(u)/F(u)/2 | responses]`,
the implemented heat score `(U^2-A)/2`. The Gaussian tails and bounded finite-
slope response derivatives justify these operations at finite chart points;
the heat form also has the right derivative at v=0. These are scores of the
same marginal likelihood, with no change of model, prior or likelihood term.

Implement both representations and select before quadrature, per Person.
Write M=sum(w*max(y,K-y)) and H=(M^2+sum(w^2)*K^2/4)/2. The heat score has
absolute envelope H. The prior score has envelope `(1+theta^2)/(2v)`, whose
standard-normal integral is 1/v. Select prior if v>0 and H>1/v; otherwise
select heat. This deterministic envelope comparison is a conditioning
heuristic, not a proof of numerical precision or posterior-error ordering.
There is no retry-to-pass rule. Forced heat/prior modes are private diagnostic
controls; prior at v=0 is refused. On a log-concave tail beginning at b with
outward slope s, the prior score's unnormalized absolute tail integral is
bounded by `exp(logjoint(b)-peak)/(2v) * ((1+b^2)/s + 2*abs(b)/s^2 + 2/s^3)`.
Retain the existing normalizer correction and all numerical accuracy gates.

Re-evaluate only the 20 saved positive common-variance points, both starts and
free/null cases across N20 observed/b09/b19 and N60/N240 observed. Compare the
18 available independent references using the preceding NLL 1e-7, transformed
gradient 1e-6 and target 1e-8 criteria; additionally compare full natural
gradients to the retained heat results within 1e-6. Preserve both missing
terminal references even if evaluation becomes possible. Reuse the unaffected
rater-intercept and zero-variance saved evidence, with archived sources and
input/result identity checked; targeted tests cover the shared-code changes.
Freeze this increment before the 20 evaluations. No fitting, Hessians, new
responses, bootstrap or interval-adoption decision is part of this check.

**Completed direct natural-coordinate increment.** The private evaluator in
`R/core-gmfrm-natural.R` now computes both response laws and their marginal
scores directly, without a native inverse. It accepts finite intercepts at
zero rater slope and finite scaled locations/relative slopes at zero common
variance. Compensated affine logits preserve small category differences;
positive slopes that underflow are refused rather than silently becoming
boundary observations. The variance score uses the Person-level Gaussian
heat identity below. An entirely ability-independent response law reports
that the original ability posterior equals its prior. Results explicitly say
`optimality = "not assessed"`. Boundary targets are conservatively supported
only when independent of the unavailable native blocks; other targets are
reported unsupported, not automatically declared unidentified.

The frozen 44-point allocation is complete:

| Evaluation | Independent agreement | No independent reference | Accuracy refusal |
| --- | ---: | ---: | ---: |
| Positive rater-intercept chart | 18 | 1 | 1 |
| Positive common-variance chart | 18 | 0 | 2 |
| Fixed rater-5-zero projections | 2 | 0 | 0 |
| Fixed common-variance-zero projections | 2 | 0 | 0 |

All 36 interior comparisons with retained independent references pass. The
allocation keeps both starts and free/null points on N20 observed/b09/b19 and
N60/N240 observed data. Maximum NLL difference is 6.82121e-13 and full-gradient
difference in the preceding log-chart units is 1.16082e-10. Every evaluated
original task-log-slope target is preserved exactly. All four boundary
projections agree with independent literal equations/base-R integration:
maximum NLL discrepancy 5.68435e-14, boundary-score discrepancy 1.16416e-10.

For b09 free points, fixing common variance to zero decreases NLL by
0.00092610 and 0.00098206, with outward NLL derivatives 119820.2 and 139762.0.
For b19 constrained points, fixing rater-5 slope to zero decreases NLL by
0.0000185125 and 0.0000177152, with outward derivatives about 1.44047.
These are comparisons at fixed nuisance coordinates, with different
derivative units between charts. They show feasible finite boundary laws and
the first-order condition along those paths; they do not optimize the
boundary nuisance parameters, prove finite-MLE nonexistence, identify a
global maximum, or qualify an LR reference distribution.

The four unqualified interior results are still the two extreme b19-free
endpoints. The retained-start rater chart refuses score-rule discrepancy
1.80212e-5. Both common-variance charts refuse large natural-score rule
discrepancies (4.55789e12 and 1.13634e19) and tail bounds (6.54911e10 and
1.69151e11), despite NLL-rule discrepancies below 3e-14. The neutral-start
rater chart computes but has no independent terminal reference. These
absolute natural-score criteria are not the former log-chart criteria;
neither a stable NLL nor an earlier chart pass overrides them. Rule agreement
is a diagnostic, not a rigorous bound on total integration error.

There are 107 passing targeted assertions, with no final failures, warnings
or skips. They cover independent literal NLLs, interior Jacobian/target
checks, positive/zero/near-zero scores, binary/four-category incomplete designs
with unequal owner counts and arbitrary owner names, nonuniform intercepts
at zero slope, cross-response terms in the variance score, numerical/input
refusals, cache invalidation and product-rounding cancellation. The initial
one-sided finite-difference check had O(h^2) truncation error up to 2.84e-6
at h=1e-4. Halving h gives the required decrease and discrepancy below 2e-6;
Richardson extrapolation agrees below 1e-7. Production accuracy thresholds
were unchanged. Existing native and interior-adapter source fingerprints are
unchanged, so their completed numerical evidence is reused.

`gmfrm-natural-20261011.R` and the retained `validation-results/gmfrm-natural-20261011/`
manifest, archived sources, 44 records and aggregate bind the actual R 4.6.1
session and single-thread environment. Fresh-session replay verifies all
source/input/archive/result fingerprints and byte-identical aggregates with
fitting, integration, root finding, normal generation and package loading
disabled. No optimization, Hessians, responses, bootstrap or coverage work
was run. Public fitting/inference/scoring and previous failure counts remain
unchanged. D1 is open.

At the end of this initial increment, a numerical design distinction remained: the heat representation
is valid at zero variance but can involve cancellation of large squared
weighted scores. At v>0 the same derivative also equals
`E[(theta^2 - 1)/(2v) | responses]` in the standard-normal integration
coordinate, by differentiating the N(0,v) density for u. That representation
instead becomes ill-conditioned as v approaches zero. This algebra suggests
a general stability comparison, not a waiver of the three refusals or a
claim that an alternative had already been implemented and qualified at that
stage. The subsequent variance-score increment above implements and checks it.

**Direct natural-coordinate contract (October 11, before saved-point work).**
Evaluate the response law and scores directly using nonnegative rater slopes
with finite rater intercepts, or nonnegative common variance with finite
scaled locations and relative slopes. No native inverse is used in likelihood
evaluation. At zero common variance use the Gaussian heat identity with the
square of each Person's total score, including its cross-response terms.
The original standard-normal ability posterior then equals its prior; the
degenerate rescaled variable does not imply precise ability measurement.

Reuse the same 20 endpoints and two charts (40 interior evaluations), keeping
all accuracy refusals and missing references. Compare values within 1e-7 and
full gradients, expressed in the preceding log-chart units, within 1e-6 to
the retained independent references. Independently enforce the direct
natural-score rule discrepancy <=1e-6 and tail bound <=1e-7, NLL rule <=1e-7
and tail <=1e-8. Do not disguise derivative amplification by relaxing these
criteria. Preserve original targets/nulls within 1e-8. Also evaluate four
fixed boundary projections: both b09 free endpoints at common variance zero,
and both b19 null endpoints at rater-5 slope zero with intercepts held fixed.
Compare their NLL and boundary-coordinate derivative to separately written
response equations and base-R integration (or the exact variance-zero sum),
within 1e-7 and 1e-6 respectively. These are explicitly unoptimized points;
a derivative sign cannot certify a boundary maximum or a global supremum.
No fitting, Hessians, bootstrap, response generation or public adoption is
allocated. Archive sources, input identities and actual runtime before work.

**Optimization decision that these calculations can support.** Conditional
log-concavity supplies a unique Person integration mode. It does not prove
that the structural marginal likelihood is globally concave. Keep three
different questions explicit: is the likelihood accurately evaluated; is a
candidate locally stationary in its feasible directions; and have sufficiently
different interior and boundary candidates been compared? Neither the first
nor the second answers the third. Multiple starts can reveal a better maximum
but cannot by themselves certify the global supremum.

The next estimator increment must optimize the nuisance coordinates on each
supported candidate boundary, preserve the requested native null, and compare
the same accurate likelihood across interior and boundary candidates from
distinct starts. Report the best value found and all unresolved candidates;
do not rename it a certified supremum. The same policy must be checked on the
retained N20/N60/N240 controls and free/null cases, not devised only for b09
and b19. A projection's outward derivative is necessary-condition evidence at
that fixed nuisance point only. The two finite boundary charts do not exhaust
paths where relative slopes diverge or vanish. Their remaining limitations
must stay visible rather than being hidden by slope caps or a changed prior.
Do not launch a broader bootstrap until this procedure is sufficiently
qualified. Even then, LR calibration, target identification, severity/contrast
inference and original-ability scoring have their own completion obligations.

**Completed interior-coordinate increment.** Both analytic bijections are now
implemented in `R/core-gmfrm-coordinates.R`. Their evaluator composes the
existing native segmented likelihood with the inverse map and applies J' to
its gradient. The native calculator only gains componentwise error metadata;
its likelihood/score arithmetic and public callers are unchanged. This is an
interior adapter, not direct likelihood arithmetic in the new coordinates
or a way to evaluate zero/infinite slopes. At that increment, the zero-variance
derivation below remained a design result, not an implemented boundary optimizer.

All 40 fixed-point evaluations finish under the frozen contract:

| Chart | Independently qualified | Computable, independent reference unavailable | Accuracy refusal |
| --- | ---: | ---: | ---: |
| Rater intercepts | 18 | 2 | 0 |
| Common scale | 18 | 1 | 1 |

Both charts qualify at every one of the 18 points with an existing independent
reference, including N20 b09 free and b19 constrained points whose earlier
optimization/information status remains unqualified. Across these 36
evaluations, maximum NLL discrepancy is 6.83e-13, transformed full-gradient
discrepancy 2.43e-10 and relative inverse-map error 5.04e-13; the original
constrained target error is zero. These are evaluator comparisons, not newly
stationary points. In particular, full-gradient agreement includes the fixed
target coordinate and must not be mistaken for constrained stationarity.

All four unevaluated/unqualified reference comparisons belong to the two
extreme b19-free endpoints. Three chart evaluations return numerical values,
but the missing independent reference is not waived. For the retained-start
common-scale point, the propagated rule discrepancy is 3.13981e-5, exceeding
1e-6; the tail bound is 3.19920e-9 and is not the failed criterion. This new
refusal is an appropriate consequence of error amplification by the coordinate
Jacobian, not proof of a new integration defect or an improved maximum.
Agreement between two integration rules is a discrepancy diagnostic, not
a rigorous bound on the complete integration error. Only the retained tail
envelope has the stated tail-bound interpretation.

The 93 new assertions and 57 existing segmented assertions pass with no final
failures, warnings or skips. They check independent literal chart likelihoods
and finite-difference gradients, inverse Jacobians, native targets/nulls,
binary and four-category data, unequal owner counts, incomplete assignment,
input/numerical refusals and preservation of error diagnostics. The initial
mock-error fixture had only eight response rows and was corrected to twelve
to meet the existing preparation minimum; production eligibility was not
changed. RDS reconstruction is checked without retaining an evaluator cache.
A fresh-session replay of all 40 saved records and their aggregate is
byte-identical with fitting, integration, root finding, normal generation and
package-loading entry points disabled. Source/input/archive fingerprints pass.

The retained runtime launcher could not start because its embedded executable
was absent. This new epoch uses `/usr/local/bin/Rscript` and records the actual
session; R 4.6.1, Matrix 1.7-6, testthat 3.3.2 and pkgload 1.5.3 match the
preceding continuation, as do the four single-thread settings for the fixed-
point study. This is not a claim of having restored or tested the launcher.

**Disposition:** retain the interior adapter and the qualified positive-point
evidence. No optimization, Hessian qualification, boundary decision, bootstrap
or coverage calculation occurred. The adapter still calls the native evaluator
and therefore cannot by itself repair the extreme numerical paths. Its next
boundary increment required direct response/score evaluation in the appropriate
natural coordinates, the one-sided conditions derived below and preservation
of the target constraints. A new optimizer must use those contracts; neither
lower gradient norms nor another maxit increase supplies them. Public fitting,
information, scoring and all previous inference/failure counts remain unchanged.
D1 stays open, with the original small/medium/large sample and design scope.

**Interior-coordinate implementation contract (October 11).** Implement both
positive-interior bijections and their analytic inverse Jacobians, retaining
the native likelihood evaluator. The common-scale coordinate is log(lambda)
at this stage, not a variance-zero optimizer. Native linear targets are
evaluated as C*h(z) with gradient C*J, including rater log slopes and location
contrasts. Carry componentwise integration rule discrepancies and tail bounds
through abs(J)' before testing transformed-score accuracy. This adds no
Jacobian term to the likelihood and supplies no Hessian, stopping policy,
boundary estimator, prior or public inference route.

The bounded check reuses all 20 latest endpoints on the existing five datasets
(N20 observed, b09, b19; N60 and N240 observed), both starts and both free/null
fits, in both charts: 40 evaluations. Use all eight continuation records,
three curvature-corrected records and nine previously qualified original
endpoints. Compare to the retained independent reference where available;
keep the two b19-free records without references in the allocation. Freeze
NLL agreement 1e-7, full transformed-gradient agreement 1e-6, relative inverse
map error 1e-12, original null error 1e-8, transformed rule discrepancy 1e-6
and score tail bound 1e-7. No stationarity threshold or former qualification
count changes. Regression checks independently integrate the chart response
equations and finite-difference their gradients for binary/four-category,
unequal-owner and incomplete-assignment inputs. No data are generated or
refitted. Producer: `gmfrm-coordinates-20261011.R`; records:
`validation-results/gmfrm-coordinates-20261011/`.

**Decision:** separate regular finite-parameter estimation, boundary likelihood
calculation, target identification and inferential calibration. The completed
continuations diagnose the current procedure; they do not establish that every
useful GMFRM output requires a finite full-vector MLE and positive definite full
information. Those requirements belong to the current regular Wald route and
its finite-point checks, not to the definition of every likelihood ratio.
Retain the existing public guards and all frozen qualification counts until a
replacement procedure has its own justification. No result is retrospectively
reclassified by this review.

The user-facing question remains which estimates and uncertainty statements
the rating design supports, across small, medium and large samples. The two
retained N20 datasets reveal mechanisms worth addressing in a general
implementation; making these particular datasets pass is not the development
objective. Neither N20 nor N smaller than the structural parameter count is
an automatic exclusion. The earlier empirical-score-rank correction remains
applicable and is not reopened here.

### Same likelihood, different coordinates

Write the native adjacent-category log odds, for scores 0,...,K, as

`eta_irk(theta) = a_i c_r (theta - b_i - s_r - tau_rk)`,

with positive slopes, `sum_i log(a_i)=0`, `sum_i b_i=0`,
`sum_k tau_rk=0` for each rater, and the fixed N(0,1) ability law. Category
probabilities are the softmax of the cumulative adjacent logits. These are
the same restrictions as the existing native response model, with its
zero-based score convention and L-metric coefficient 1.

**Individual rater boundary.** Define `q_rk = c_r (s_r + tau_rk)`. Then

`eta_irk(theta) = a_i { c_r (theta - b_i) - q_rk }`.

For c_r>0 the inverse is
`s_r = mean_k(q_rk)/c_r` and
`tau_rk = {q_rk - mean_k(q_rk)}/c_r`.
This replaces K free severity/step coordinates by K intercept coordinates;
it neither adds parameters nor relaxes the task/rater factorization. Equality
of every adjacent logit proves equality of the conditional probabilities and
of the marginal Person likelihood. No Jacobian is added to a likelihood when
only its structural parameter coordinates change.

For fixed finite a_i, b_i and q_rk, taking c_r down to zero gives
`eta_irk = -a_i q_rk`: ratings independent of ability, with possibly nonuniform
category probabilities. Simply setting c_r=0 while holding the *original*
severity and steps finite instead gives uniform probabilities and misses this
legitimate limiting path. Finite q does not rescue a finite severity: recovering
s_r and tau_rk divides by c_r. Thus a computable response distribution and a
precisely interpretable severity are different claims.

**Common slope-scale boundary.** An individual-rater chart alone does not
resolve diverging task locations. For positive c_r, set

```
lambda = exp(mean_r(log(c_r)))
rho_r = c_r/lambda
B_i = lambda*b_i; S_r = lambda*s_r; T_rk = lambda*tau_rk
eta_irk(theta) = a_i*rho_r { lambda*theta - B_i - S_r - T_rk }
```

The inverse divides locations by lambda and sets c_r=lambda*rho_r.
The constraints become `sum log(rho_r)=0`, `sum B_i=0`, `sum_k T_rk=0`,
with the original task-slope constraint retained. This is again a bijection
in the positive interior with the same parameter count. Put v=lambda^2.
Equivalently, u=lambda*theta has distribution N(0,v) and predictor
`a_i*rho_r (u-B_i-S_r-T_rk)`. This transfers the common slope scale into a
variance coordinate; it does **not** add a free ability variance while keeping
all original slope scales free. Integration in u must include its N(0,v)
density; integration in theta retains the original standard-normal density.

At v=0 with finite chart coordinates the responses are independent of ability.
Because the standard-normal law is symmetric, the marginal likelihood in
signed lambda is even. Its derivative with respect to lambda at zero is
therefore zero regardless of whether zero maximizes the likelihood. Likewise
`d ell/d log(lambda) = 2v * d ell/dv` can approach zero automatically.
Small gradients in these coordinates cannot establish boundary optimality.

Person scoring must retain its original target theta, not silently replace it
by u. At this finite-chart boundary the conditional response probabilities
no longer depend on theta, so its posterior remains the N(0,1) prior: the
ratings give no ability information. The derived u collapses to zero because
its scale collapses, not because original-scale ability is measured without
error. Mapping scores back by u/sqrt(v) is undefined at v=0. An isolated
zero-slope rater similarly contributes no ability information along its q
chart, while other informative ratings can still support Person scoring.

The appropriate one-sided variance score can be derived without a new
simulation. For Person p let F_p(u) be the conditional probability of that
Person's entire observed response vector, holding the finite chart nuisance
coordinates fixed. The Gaussian expansion gives

`d log L_p(v)/dv |_(0+) = F_p''(0)/(2 F_p(0)) = (U_p^2 - A_p)/2`,

where, at u=0,

```
w_e = a_i*rho_r
U_p = sum_(e in assignment_p) w_e (y_e - E[Y_e | u=0])
A_p = sum_(e in assignment_p) w_e^2 Var[Y_e | u=0]
```

This follows from `(log F_p)'=U_p`, `(log F_p)''=-A_p` and
`F_p''/F_p = (log F_p)'^2 + (log F_p)''`. Finite categories and fixed finite
coefficients bound the required derivatives for this expansion. The Person
contribution is a *square of the sum* of its rating scores; replacing it by
the sum of squared row scores would remove the shared ability dependence.
This reuses the Gaussian variance-boundary identity already derived for RSM
in `mfrm-lr-rsm-natural-boundary-20261010.R`, with the GMFRM weights retained.
For maximizing log likelihood at v=0, a positive total one-sided score rules
out that boundary point. A nonpositive score is only a first-order necessary
condition along this path, not a global certificate. Boundary nuisance
representations can lose identification and generate other entering paths.

These two coordinate systems describe useful portions of the closure, not
its entirety. Simultaneously vanishing and diverging relative slopes can
escape both finite charts. An unrestricted matrix of cell slopes/intercepts
would change the model; it is not an equivalent shortcut. The task log-slope
null retains its original meaning in both charts. In the common-scale chart,
a rater log-slope null is `0.5*log(v) + log(rho_r) = t0`, not a fixed rho_r;
location/contrast nulls must also be transformed. At v=0 with finite rho_r,
that rater null cannot represent finite t0. Boundary limits must be taken
within the actual constrained family.

### What the saved endpoints support

Only saved-parameter arithmetic was performed for this reassessment. The
continuation manifest's input hashes, summary-bound result hashes and each
run's manifest binding matched. All eight terminal vectors were read; no
likelihood evaluation, derivatives, optimization or response generation was
rerun. The table shows the retained-start vector for each case; the neutral
starts show the same qualitative distinctions.

| Case | Saved-parameter calculation | Design implication, not a boundary-MLE conclusion |
| --- | --- | --- |
| b09 constrained | Largest absolute native location 12.9500; existing two-start numerical checks pass. | A regular finite-point candidate already exists under the recorded checks. |
| b09 free | Common scale lambda=8.79158e-5; largest absolute location changes from 106755.76 to 9.38552 in B/S/T coordinates; relative rater slopes range .001943 to 11.0766. | Common-scale/location coupling is a concrete coordinate problem to address; this does not prove the limiting optimum is v=0. |
| b19 constrained | Rater 5 has c=1.28513e-5, severity=-42884.95 and first step=-81524.40, but c*severity=-.551126 and c*step=-1.047693. All absolute q values are at most 5.33212. | The individual-rater intercept chart represents this finite endpoint without those large rater locations. It does not establish finite severity identification. |
| b19 free | Task slopes range 5.77236e-10 to 6.87465e6; the largest relative rater slope is 6.15310e12 and max absolute q is 5.51977e9. | Neither finite chart settles the extreme-slope limit. Independent terminal numerical qualification remains incomplete. |

Sources remain the immutable `run-*.rds` records in
`validation-results/gmfrm-segmented-continuation-20261011/`. The native free
vector is the two task locations (third is minus their sum), six severities,
six first steps (second is their negative), two task log slopes (third is minus
their sum), and six rater log slopes. The displayed transformations therefore
require only arithmetic on the saved 22-coordinate vectors. These mechanisms
are not estimates of their prevalence at N20, and no finite-MLE nonexistence
claim follows from the trajectories.

### Likelihood values, information and uncertainty are separate

For the fixed recorded assignments and finite categories, represent a model
by its vector of marginal Person response-pattern probabilities. Such vectors
lie in a finite product of probability simplexes. The closure of the model
image is compact, and the sample likelihood is continuous on it. Consequently
the likelihood supremum over the original family is attained somewhere in
that closure, even if no finite structural vector attains it. A finite
interior vector assigns positive probability to every observed response, so
the supremum has a finite logarithm. This elementary argument is specific to
the fixed finite observation space; it supplies neither an efficient boundary
parameterization nor an algorithm proving that a saved point attains it.

For a nonempty target family, use the closure of the image of
`{gamma: C gamma=t}` separately
from the closure of the unrestricted image. Their likelihood maxima define
the original LR supremum difference. Do not impose a parameter label on a
boundary distribution when that label no longer has a unique extension.
As a simple logical counterexample to requiring finite coefficients, all
successes in n Bernoulli trials give an infinite fitted logit but a finite
LR against 0<p0<1, namely `-2*n*log(p0)`. This does not supply a GMFRM cutoff.
Nor does existence of a maximizing marginal response law by itself supply a
unique latent joint law or justify Person scoring at an arbitrary boundary.

| Requested output | Required distinction |
| --- | --- |
| Conditional/marginal probability at a stated point | A valid response law and accurate numerical evaluation; no inverse full Hessian is needed. |
| Regular full-vector Wald covariance | Identified finite interior solution, stable observed marginal information including nuisance blocks, stationarity and the stated sampling approximation. Positive curvature alone does not establish coverage. |
| A particular target's uncertainty | Identification and regularity of that target after nuisance adjustment. Singular full information cannot be repaired by an arbitrary generalized inverse, but does not logically rule out every estimable function. |
| LR statistic | Sufficiently reliable unrestricted and correctly constrained likelihood suprema, including supported boundary paths. Full-vector Wald eligibility is not its definition. |
| LR p-value or confidence set | A justified reference law or resampling procedure in addition to the computed statistic. Boundary, nuisance and weak-identification conditions matter. |

Raw-gradient norms and Hessian eigenvalue ratios depend on coordinate units.
For a smooth interior change gamma=h(z), the negative-log-likelihood Hessian
is `H_z = J' H_gamma J + sum_j g_gamma,j Hessian_z(h_j)`.
The extra term vanishes at exact stationarity, not at arbitrary saved points.
At a stationary point a nonsingular change preserves definiteness, but not
the eigenvalue ratio. For a nonsingular linear change and unfloored positive
H, `g' H^-1 g / 2` is invariant. Eigenvalue floors remain search devices and
must not become inferential information. A boundary instead requires feasible
directional conditions and appropriate curvature on those directions.

Two-start agreement is useful evidence, not a global optimization error bound.
If valid log-likelihood bounds were available, with free supremum in [L_f,U_f]
and constrained supremum in [L_0,U_0], the LR would lie in
`[max(0, 2*(L_f-U_0)), 2*(U_f-L_0)]`. This shows the error quantity that matters;
integration-rule agreement or two similar local optima do not supply these
global bounds. The current local-search limitation must remain explicit.

### Literature correspondence and its limits

The following relevant pages were read individually, not the papers in full.
Zotero was read without library changes; exact Geyer/Self--Liang records were
not found, so primary public texts supplemented it.

| Primary source | Pages and implication |
| --- | --- |
| [Uto and Ueno (2020)](https://doi.org/10.1007/s41237-020-00115-7), Zotero `IR3LFDRM`, PDF attachment `K393E4IU` | PDF 11--14 / printed 479--482; PDF 11--12 also visually inspected. Equation 9 multiplies the entire predictor by both slopes. The constraints remove scale/location invariances. The proposed estimator is Bayesian EAP; the ten-replication recovery experiment reports bias/RMSE, not qualification of N20 unpenalized MML intervals. |
| [Geyer (2009), primary preprint](https://arxiv.org/pdf/0901.0455) | PDF 2--3, 8--9 and 14 / manuscript pages 1--2, 7--8 and 13. Finite natural-parameter existence and existence of a fitted limiting distribution are distinct. The paper's computation assumes full exponential families; its recession algorithm is not automatically applicable to the nonlinear latent-marginal GMFRM. |
| [Self and Liang (1987)](https://www.stat.cmu.edu/~brian/763-2015/week06/papers/self-liang-1987.pdf) | PDF 2--3 and 5--6 / printed 605--606 and 608--609. The boundary asymptotics assume identification, smoothness and positive expected information. Their nuisance-boundary example is not a simple chi-square mixture. Thus neither a universal 50:50 mixture nor applicability to a singular GMFRM boundary follows. |

The coordinate identities and the weighted variance score above are our
model-specific derivations. The papers do not prove the observed N20 endpoints
are boundary optima. Nor does a fitted-null parametric bootstrap automatically
repair boundary/nuisance calibration: its previously recorded justification
remains conditional on the appropriate regularity, not finite-B exchangeability.
An observed boundary fit does not establish that the data-generating parameter
is on that boundary; a reference distribution cannot be selected solely from
the fitted boundary label.

The existing Stan export is a separate small-sample option with explicit
proper priors. For a finite categorical likelihood, a proper prior with
positive mass where the likelihood is positive gives a proper posterior,
since the likelihood is bounded by one. This alone establishes neither data
identification, HMC mixing, existence of every posterior moment nor frequentist
coverage. Reparameterizing sampled coordinates must preserve the declared
prior density with the appropriate Jacobian; assigning independent priors to
q or scaled locations would instead change that model. No prior, slope cap,
default estimator or response model is changed in this reassessment.

### Consequence for the next method increment

Prioritize a same-likelihood coordinate/evaluation design and output-specific
qualification over another maxit increase or broad bootstrap. First preserve
the response law, identification and exact target constraints in the positive
interior; use the existing numerical reference to check the derivative chain
rule and integration before adopting an optimizer. Then give each supported
boundary an explicit limiting law, feasible-direction rule and target policy.
Unrepresented extreme-slope paths remain explicit refusals; a complete atlas
of every possible boundary is not made a prerequisite for useful regular
interior support. Neither merely smaller coefficients nor a smaller transformed
gradient constitutes success.

Only a declared complete estimator/test procedure warrants fresh independent
performance allocation. Reuse the existing N20-observed/N60/N240 controls and
the wider sample-size/design evidence within their recorded scope; do not
present them as checks of a new coordinate engine. Keep severity, contrasts
and Person scoring alongside discrimination, with target-specific limitations.
Reduced models and prior-based estimates require explicit user interpretation;
they are not silent fallbacks for the original two-family MML target. D1 and
the population/JML/GMFRM obligations remain open. This review changes the
method design and next dependency, not public inference or coverage evidence.

## October 10 empirical-score-rank policy correction

**Decision:** retain empirical Person-score rank as a diagnostic and warning,
not a prerequisite for the model-based inverse-observed-information interval.
The implementation was staged in
`validation-results/gmfrm-score-rank-20261010/candidate-source` while the
separate RSM precision workers used the frozen production source. It is now
integrated, after all 3200 attempts and the corrected reporting-only summary
passed their original source/result checks. This is a correction to the stated
method's eligibility rule, not a claim of improved coverage or a new estimator.

For independent Person response vectors, let `s_i` be each marginal likelihood
score and let `S` have these rows. The empirical outer product is `S' S`; its
rank is at most N, and at an exact stationary point at most N-1. The observed
negative marginal-log-likelihood Hessian is `H = -sum_i Hessian(log L_i)`.
It is not algebraically equal to `S' S` in a finite sample. The expected
information identity does not equate these two realized matrices. Therefore
rank deficiency of `S` does not itself prevent positive definite H or the
model-based covariance `H^-1`. It does prevent a nonsingular full-parameter
empirical sandwich covariance when H is invertible. Positive H at one fitted
point still establishes neither global identification, an interior global
maximum, nor nominal finite-sample coverage.

The candidate keeps source/category/engine checks, positive unregularized full
information, score-derivative agreement, mean-score and curvature-scaled
stationarity, inverse residual and q-versus-(2q-1) integration thresholds.
`Score derivative stability` replaces the combined `Local score rank` gate;
`ScoreRank`, `FineScoreRank`, `ScoreRankDeficient` and the existing rank ladder
retain the empirical diagnostic. Slope and location results carry a deficient
rank caution through printing, plots and saved reports. Fixed-grid profile
inference shares the corrected source check but retains its separate absolute
likelihood/gradient and constrained-search checks; adaptive profiles and
sandwich intervals remain unavailable.

### Bounded saved-source check

`inst/validation/gmfrm-score-rank-20261010.R` freezes all 50 original selected
N20 point sources before calculation and applies only the candidate inference
function within the verified historical package. It disables fitting and
preserves the original 50 design exclusions. No new responses, optimization,
source selection by truth, retries or criterion changes occur. Every newly
returned source receives the same independent Louis-reference thresholds as
the previous continuation: NLL discrepancy per Person <=1e-6, information-scaled
score discrepancy <=1e-4 and relative covariance discrepancy <=1e-3.

| Result under the candidate, N20/SD1/common, 50 datasets | Count |
| --- | ---: |
| All interval and independent-reference checks pass | 3 |
| First failure: direct convergence | 28 |
| First failure: category support | 7 |
| First failure: joint information | 4 |
| First failure: score-derivative stability | 1 |
| First failure: stationarity | 6 |
| First failure: quadrature sensitivity | 1 |

Replicates 15, 38 and 40 return all twenty original location/contrast/log-slope
targets. Their empirical score ranks are 18, 17 and 19, respectively, for
22 free parameters. The independent information for replicate 15 is positive
definite (smallest eigenvalue .02649176); its relative covariance discrepancy
is .0001913211. This is an observed fitted-model counterexample to the rank
veto, stronger than the earlier expected-information illustration. These are
saved simulation datasets, not new empirical application data. The three
selected successful datasets cannot qualify conditional or unconditional
coverage; all 47 refusals remain in the evidence.

The saved 500-case review also contains one N30 `Local score rank` refusal.
Its empirical rank is actually 22/22, but its derivative discrepancy is
1.350314e-6. It still fails the unchanged 1e-6 derivative criterion; no refit
or information recomputation is needed to establish this. The other 449
non-N20 cases have no eligibility change from this correction. Their existing
numerical evidence is reused, not reported as fresh candidate calculations.
The original and subsequent coverage comparisons remain unchanged.

The current-source regression witness is the first returned N20 source in
that frozen review, selected to test the logical counterexample, not as a
representative performance sample. Its full-information covariance is checked
against the independent reference. Controlled score pooling separately tests
that the empirical-rank gate can change while the gradient, Hessian and
intervals do not; it is explicitly a unit test, not an alternative data model.
The staged help and guide explain both the mathematical distinction and its
limits. Verification comprises 613 existing targeted regression expectations,
27 controlled-policy expectations and 16 actual-source/output expectations,
all with zero failures, warnings or skips. The existing regressions cover
adaptive fitting, facet/slope intervals, quadrature review and fixed-grid
profiles. The final plot-only addition has its own actual-source checks;
this is combined evidence, not a claim that every check was rerun together on
the final file set. The actual-source regression is included in the ordinary
CRAN/CI test selection. A separate fresh R 4.6.1 session (Matrix version
recorded in `fresh-replay.rds`) reads saved results with fitting and inference
disabled, reproduces report text, and redraws the plots at the guide's 7x5-inch
size; both PNGs were visually inspected. The revised guide renders with
`NOT_CRAN=false`, and both interval help files parse. No all-package check or
additional R/Matrix-platform qualification is claimed.

`candidate.patch` and `delivery.json` in the result directory identify the
thirteen files and exact preimage/candidate hashes, including the saved
regression fixture. The initial live-source fingerprint check confirms all
158 captured R/C++/header/DESCRIPTION/NAMESPACE files are unchanged.
Integration waited until both RSM workers finished and the frozen 3200-attempt
summary verified their source/results. The two N240 primary precision claims
are supported under their prespecified criteria. The reporting comparison
needed only removal of a `conf.level` attribute; no endpoint, tolerance or
decision rule changed. The delivery manifest records the verified preimages
and integrated hashes. No completed GMFRM calculation was rerun for integration.

## October 10 interval-method basis and claim decision

The current two-family intervals implement an established asymptotic MML
construction. Their unresolved finite-sample performance does not mean that
GMFRM has no inference methods or that a new interval method must be invented.
This review answers which existing method is implemented and what the retained
evidence supports; it is not a new coverage study or completion of the promised
interval outcome.

### Primary literature and model correspondence

- Uto and Ueno (2020), pp. 479--481, equation 9 and Section 7, supplies the
  direct product-slope response model and a Bayesian HMC/NUTS estimator.
  The local Zotero PDF (`IR3LFDRM`, attachment `K393E4IU`) was revisited in
  the preceding literature review: PDF pages 11--16 were read as page-separated
  text, and pages 11--14 were visually checked. Its recovery experiment on
  printed pp. 482--483 uses ten replications per condition and evaluates RMSE
  and bias. That experiment is not a 95% interval-coverage evaluation.
  A credible interval can be constructed from the posterior; this is an
  implication of the Bayesian formulation, not a coverage result reported in
  that experiment. Priors on structural parameters distinguish that estimator
  from the present unpenalized MML calibration.
- Robitzsch and Steinfeld (2018), printed pp. 111--114, describes existing MML
  and MCMC routes for rating models. Its GMFRM with additional Person-item and
  Person-rater random effects (pp. 108--109) is not the same model as the
  Uto--Ueno product-slope specification. Relevant pages were revisited in the
  preceding review (Zotero `392NVGT8`, attachment `XJ68FIC8`); this is not a
  claim of rereading the entire article on October 10.
- The authors' [sirt `rm.facets` documentation](https://alexanderrobitzsch.github.io/sirt/reference/rm.facets.html)
  provides MML--EM and item/rater slope and intercept standard errors. Its
  cumulative category predictor is `a_i*a_r*k*theta - k*b_r - tau_ik`.
  In the present model, the adjacent predictor is
  `a_i*c_r*(theta - b_i - s_r - tau_rk)`. With shared parameters, moving
  slopes across the intercept terms generally changes the restrictions, not
  just parameter labels. The earlier matched zero-location/zero-step kernel
  check is therefore a restricted overlap, not an external covariance match.

### Current covariance and interval construction

For the identified free calibration vector gamma, the fitted likelihood is
the product of Person-level integrals under the fixed N(0,1) population.
The code obtains the Hessian H of the negative observed marginal log likelihood
and uses V = H^(-1), including location, step and both log-slope blocks.
For a native location/contrast or component log slope t = C gamma, its
covariance is C V C'. Normal limits apply to locations/contrasts; component
slope limits exponentiate the log-scale limits. The first family's log slopes
sum to zero; the second family's slopes are free on the fixed ability scale.
This is not inversion of only the slope block or of the EM Q-function.

`R/core-gpcm-product-slopes.R`, `R/core-native-location-inference.R` and
`compute_mml_parameter_covariance()` in `R/mfrm_core.R` implement this path.
The independent reference in `tests/testthat/helper-gmfrm-information.R`
uses the [Louis (1982)](https://doi.org/10.1111/j.2517-6161.1982.tb01203.x)
identity: observed information equals posterior expected complete-data
information minus posterior complete-score covariance. The retained
`gmfrm-joint-information` fixture checks the full covariance and target
Jacobian; the adaptive independent-reference and October 10 continuation
results check the marginal derivatives separately. The current review reads
those sources and saved results without repeating their successful fits/tests.
It does not assert a new independent numerical verification of every current
source file.

The asymptotic interpretation needs an identifiable interior solution,
nonsingular information, a correctly specified response/population model and
appropriate independent-Person sampling with adequate information in the
rating design. More repeated ratings do not automatically supply more
independent Persons. Boundary solutions, local dependence, sparse assignment
and finite-sample bias/shape can invalidate a nominal-coverage recommendation.
Numerical checks evaluate computability; they do not prove all these conditions.
The observed Person-score rank veto is a stricter current procedure rule, not
an algebraic necessity for invertibility of an observed-information Hessian.

### Decision from existing evidence

The retained 500 condition-datasets and their paired comparison remain the
performance evidence. Targets must be named: in the common-Person SD1 N60
cell, the saved-source continuation gives Task t1 *slope* coverage 41/50,
whereas its *location* coverage is 48/50. At N240 in that design, the same
targets give 48/50 and 43/50; at N480 they give 50/50 and 48/50. These inspected,
correlated development results do not define a universal N threshold or prove
coverage for other targets/designs. Neither the count of methods nor more
replications changes the approximation itself.

Retain the current experimental MML intervals and disclose their method and
limits. Do not automatically require adaptive profile-LR, bootstrap or a new
Bayesian backend to complete every reported asymptotic interval. A specific
recommendation of adequate finite-sample coverage needs its own evidence;
existing adverse or inconclusive decisions are not converted to support.
The fixed RSM precision allocation and all frozen criteria are unchanged.
Profile-LR remains an optional methodological candidate, with no demonstrated
coverage advantage for the current adaptive procedure. Release obligations
remain open rather than being silently closed by this explanation.

Documentation validation: the revised guide renders with `NOT_CRAN=false`
under the available R 4.6.1, and its extracted R code parses. The six reported
counts above match `gmfrm-interval-disposition-20261010/comparison.csv`.
Cross-references and whitespace checks pass; all 161 production-file
fingerprints captured before this review are unchanged. No fitting, coverage
simulation or full package check was repeated for this prose-only change.

Primary references: [Uto and Ueno (2020)](https://doi.org/10.1007/s41237-020-00115-7);
[Robitzsch and Steinfeld (2018)](https://www.psychologie-aktuell.com/fileadmin/download/ptam/1-2018_20180323/6_PTAM_IRMHR_Main__2018-03-13_1416.pdf).

## October 10 adaptive component-profile delivery

The specific benefit is an explicit sensitivity check for likelihood
asymmetry on the **same adaptive direct MML fit**. The existing public
two-family component profile previously accepted only fixed-grid EM.
`confint(fit, method = "profile", slope = c(Task = "t3"))` now also supports
adaptive direct fits, subject to the same source eligibility checks. This
bounded extension does not replace the current log-Wald default or claim a
coverage advantage. Location/contrast profiles are not added.

For free calibration vector gamma and component log slope c'gamma = t, the
profile is the maximum observed marginal log likelihood subject to that
linear constraint. Every other location, step and log-slope parameter remains
a nuisance parameter. The implementation eliminates one coordinate exactly;
for the dependent Task t3 component, t is minus the sum of the other two
Task log slopes. At every nuisance trial, the direct evaluator recalculates
Person-specific integration modes, scales and Jacobians. Reusing the fitted
nodes without updating them would change the numerical objective and gradient.
Optimizer scaling by Person count does not rescale the reported total
likelihood ratio. Both source and constrained comparisons retain their fitted
integration method.

The Zotero copy of Fischer and Lewis (2021), *A robust and efficient algorithm
to find profile likelihood confidence intervals*, Statistics and Computing
31, 38, DOI [10.1007/s11222-021-10012-y](https://doi.org/10.1007/s11222-021-10012-y),
was read separately for PDF pages 1--4 (item `35VSKQWR`, attachment `HDY2SSV5`);
page 2's equations were also checked visually. Page 1 motivates the numerical
problem; page 2, equations 1--3, defines the constrained profile and
chi-square(1) cutoff **under regularity and as an approximation**. Page 3's
endpoint conditions distinguish the likelihood threshold from nuisance
stationarity; page 4 discusses unreliable local approximations and
inestimability. These support the interpretation and numerical checks, not a
finite-sample coverage claim. Our existing BFGS-plus-root search is not their
RVM algorithm, and a failed finite search is not proof of an infinite interval.
This entry does not claim a complete rereading of all 17 pages.

The validation contract fixes two retained fits, Task t3 and Rater r3,
95% chi-square(1) cutoff, working/reference orders 31/61 and unchanged public
controls (400 BFGS iterations per stage, eight search steps, initial log-slope
step .5). The N20 source is the retained rank-deficient fixture, one of the
three sources admitted by the earlier Hessian-policy correction. The N240
source is common-Person SD1 replicate 1 from
`gmfrm-adaptive-start-20260930/001-common_persons-1.rds`, stage 31.
Neither selection is a random new sample or a representative coverage estimate.
No data generation, source refitting or case-specific numerical rescue occurs.

| Retained dataset | Component | Lower | Upper | Numerical disposition |
| --- | --- | ---: | ---: | --- |
| N20 | Task t3 | unavailable | unavailable | Constrained numerical checks fail |
| N20 | Rater r3 | 1.0010410 | unavailable | Lower computed; upper checks fail |
| N240 | Task t3 | 0.8802862 | 1.3570834 | Both computed |
| N240 | Rater r3 | 0.5931232 | 1.2648027 | Both computed |

All evaluated candidates and both starts remain saved, including the eight
failed N20 Task points and four failed N20 Rater points. The N20 failures
include inadequate integration/gradient agreement; an optimizer code of zero
alone is not sufficient. The three missing endpoints are neither infinite
bounds nor substituted Wald bounds. A partial lower endpoint does not make
the full interval eligible.

`gmfrm-adaptive-profile-reference-20261010.R` reconstructs the literal response
formula, identification constraints and posterior modes/scales independently.
It compares continuous integration with independently assembled 121-node
adaptive quadrature, and uses the existing literal Louis reference for
nuisance scores and observed information. Across the five computed endpoints
and both starts, constraint error is below 7e-17, total negative-log-likelihood
disagreement below 7e-12, likelihood-ratio cutoff residual below 1.66e-6 and
the independent nuisance-score maximum below 6.87e-5. Nuisance information is
positive definite at each checked solution. These checks support local
numerical endpoints, not global maximality or sampling coverage. The first
reference-only run exposed an R name-propagation bug in the independent
kernel; un-naming its scalar theta corrected the reference, without rerunning
or modifying the producer searches. The original failure log is retained.

The lightweight regression fixture retains the N20 failure trace and independent
source derivatives; finite differences at a changed parameter vector check
moving-node gradients. It does not repeat the expensive search. New routing/
replay tests (28 expectations), affected adaptive workflow tests (125) and
existing profile/capability/reporting regressions (399) pass without failures,
warnings or skips. Installation and fresh-session replay use all four saved
public results with fitting, information and profile search disabled. Tables,
integration/engine labels, failed endpoints and exports survive reload. The
four profile plots render at 7 by 5 inches; successful and failed cases were
visually inspected. Three affected help pages and the full scope article render
using retained assets and the existing CRAN documentation mode, without
repeating numerical examples. Source/input bindings, scripts, results and logs
are retained in `validation-results/gmfrm-adaptive-profile-20261010/`.

This completes a concrete adaptive-component output, with experimental
interpretation preserved. The prior medium/large-N comparisons and adverse
coverage observations remain valid evidence. No new coverage allocation,
universal N rule, default-method change, D1 closure or assembled-source release
qualification follows. The two-family interval-performance question, JML
structural-truth intervals and the remaining N20 population questions remain
separate obligations under the current roadmap.

## October 10 paired profile-membership diagnosis

The decision question is whether profiling, with the current asymptotic
cutoff, changes the observed N60 Task t1 under-inclusion enough to justify
further method evaluation. The original saved-source comparison includes
truth in 41/50 log-Wald intervals; repairing numerical refusals alone cannot
improve that result. The new bounded diagnosis uses **all those same fifty
datasets**, not only the nine Wald misses, and does not generate or fit new
source data. Its frozen manifest precedes numerical execution in
`validation-results/gmfrm-profile-membership-20261010/`. Four cases use the
previously qualified later fitting source; the other 46 use the original
interval source. Truth plays no role in source selection.

For generating log slope t0, membership in the ideal profile-LR confidence
set is equivalent to
`2 * (max_gamma ell(gamma) - max_{c'gamma=t0} ell(gamma)) <= qchisq(.95, 1)`.
Thus membership can be examined without finding either endpoint. The actual
computation uses locally qualified optima; two starts and positive nuisance
information cannot certify a global supremum. This check is also distinct
from delivery of the public *connected* interval: it does not scan every
intermediate target or qualify an endpoint. The analysis must report
membership availability, inclusion among available calculations, all-50
bounds allowing for unavailable results, and paired changes from Wald.
It must not report membership counts as the return rate or validated coverage
of the complete public interval procedure.

`gmfrm-profile-membership-20261010.R` retains source eligibility and the fitted
integration order, reuses a single source information evaluation per dataset,
and applies the existing two-start nuisance optimizer at the fitted target
and at t0. No endpoint search, source refit, new grid, tolerance change or
case-specific rescue is used. Both target solutions retain full optimizer
traces. Independent literal-response continuous integration and Louis
information check the source and both passing solutions at truth. A result
within 1e-4 of the cutoff is numerically unresolved rather than assigned a
preferred inclusion label. Work resumes per completed dataset; both workers
use one numerical thread and the same frozen input/source/runtime bindings.

The initial preflight caught a transient pkgload DLL path before any numerical
job. Its record is preserved; the executable manifest instead binds the
persistent source DLL and verifies equality with each loaded copy. The
preparation also compares the saved log truth with -0.2 at floating-point
precision, leaving the original saved value unchanged. Neither adjustment
changes a statistical criterion or a completed result.

The same Zotero paper was read page by page for pages 5--7. Page 5 distinguishes
dependent nuisance coordinates from an unbounded quadratic approximation;
page 6 examines nonmonotone profile shapes; page 7 treats inestimability and
numerical discontinuities separately. These justify preserving the distinction
between a local membership calculation, endpoint search and a mathematical
claim of an unbounded set. The RVM-specific step rules are not adopted here.

The page-separated reading then continued through pages 8--17, completing
the 17-page article across the two turns. Figures on pages 4, 6, 13 and 14
were visually checked as well. Pages 8--10 describe numerical tolerances,
functions of parameters and comparator optimizers; our linear log-slope
constraint is exact and needs none of the article's approximate function
penalty. Page 11 explicitly defines benchmark success by solving the
likelihood-threshold optimization, rather than statistical coverage. Pages
12--14 report endpoint accuracy and evaluation cost under that definition;
the low Wald success rates in Figure 4 must not be interpreted as Wald
coverage rates. Page 15 explicitly retains local-optimization and disconnected
set limitations, including for RVM. Pages 16--17 provide implementation
availability and references. The numerical algorithm paper therefore does
not settle this package's finite-sample cutoff calibration, nor does it justify
switching optimizers to repair a sampling-performance result automatically.

The result is an inspected-development comparison, not independent validation
or a universal sample-size recommendation. Existing N20/30/40/120/240/480
and other assignment/SD evidence remains in scope without recomputation.
If the paired result does not improve inclusion or loses numerical delivery,
do not proceed automatically to broad profile confirmation. Even a favorable
result would require a separate complete-procedure and independent-performance
decision before changing a default or closing D1.

### Completed result and disposition

All fifty calculations complete and pass the frozen numerical and independent
reference checks. The paired classification is:

| Log-Wald result | LR outside | LR inside | LR unavailable |
| --- | ---: | ---: | ---: |
| Truth outside | 8 | 1 | 0 |
| Truth inside | 0 | 41 | 0 |

Thus local LR membership is 42/50 (.84), against 41/50 (.82) for log-Wald.
With no missing calculations, the all-attempt lower/upper inclusion bounds
both equal .84. The descriptive pointwise exact Monte Carlo interval is
[.7088737, .9282992]; this is an inspected condition, not an independent or
simultaneous qualification. Replicate 22 is the sole changed classification:
the Wald statistic is 3.905588, whereas the profile LR is 3.741870 against
the common cutoff 3.841459. Five of the eight remaining misses have estimates
above truth and three below it. These signs describe the estimates relative
to truth, not newly computed profile endpoints.

Every dataset retains the fitted-target and true-target optimizations from
both starts (200 constrained attempts). Independent checks of both truth
solutions give maximum negative-log-likelihood discrepancy 4.28e-7,
continuous-versus-reference-quadrature difference 2.28e-13, nuisance-score
maximum 3.91e-5 and minimum nuisance information eigenvalue .03837. The largest
independent LR discrepancy, including the source likelihood, is 4.37e-6. The
closest independent LR is .099589 from the cutoff, well away from the 1e-4 ambiguity
guard. All original input and production-source/DLL hashes still match.
`review.R`/`review.rds` reconcile selection, two-start arithmetic, reference
criteria and paired outcomes in a fresh process without repeating optimization.
The two numerical workers finish normally; total recorded case time is
1,508.866 seconds, including 25.850 for the first completed case reused by the
remaining run. These concurrent-run times are not a speed comparison with
the earlier N20/N240 endpoint calculations.

**Disposition:** this calculation removes the quadratic profile-shape
approximation but retains the chi-square cutoff and locally qualified source
and nuisance optima. It changes only one of the nine Wald misses in this
condition. The implemented local profile therefore is not a demonstrated
repair for the retained under-inclusion. Keep it as an explicit sensitivity
option; do not start broad profile confirmation, tune an empirical cutoff or
SE multiplier, or change the optimizer merely to make this result favorable.
The analysis does not identify all causes of the remaining error, prove
global maximality, establish complete connected-interval delivery, or show
that profiling cannot help other models/targets/designs. Finite-sample
calibration and the other retained inference obligations remain unresolved.
No production API or default changes in this diagnosis, so prior valid
engineering checks are reused rather than rerun.

## October 10 null-bootstrap candidate decision

**Decision:** admit a null-constrained parametric bootstrap of the marginal
likelihood-ratio statistic to a bounded numerical-feasibility check. Do not
adopt it as a public interval method, claim improved coverage, or commission
a broad confirmation yet. This is the candidate-selection outcome requested
after the L-metric documentation, not completion of D1.

The question is whether replacing the chi-square calibration, while retaining
the identified product-slope response model, produces a computable procedure
worth evaluating. The completed 41/50 versus 42/50 paired comparison did not
establish that the cutoff alone caused the misses. A bootstrap can address
that approximation; it cannot be assumed to cure nuisance-estimation error,
weak identification, model misspecification or inconsistent optimization.

### Primary reading and boundaries of the evidence

Pages below were read individually; this is not a claim of reading all pages
of each paper. The earlier Uto--Ueno model correspondence remains applicable.

| Source and pages read | Consequence for this candidate |
| --- | --- |
| Field and Welsh (2007), Zotero `KWB4JFSU`, attachment `AYH65Q4B`, PDF 1--4 / printed 369--372; page 3 also inspected as an image. | Resampling must match the dependence model and the asymptotic sampling unit. Their balanced one-way moment results do not qualify GMFRM likelihood-ratio inference. |
| Hall and Wilson (1991), PDF 2--4 and 6 / printed 757--759 and 761. | Reproduce the null distribution, not the distribution under the unconstrained alternative. Their discussion of the likelihood ratio as internally pivoted motivates this statistic, not a finite-sample guarantee for this model. |
| Dufour (2006), PDF 5, 7 and 20--23 / printed 447, 449 and 462--465; PDF 22 also inspected as an image. | Separate exchangeable known-null Monte Carlo tests from plug-in nuisance bootstrap tests. Proposition 6.1 requires consistency and continuity conditions for asymptotic validity. A finite simulation count does not remove the nuisance-parameter approximation. |

The latter two exact records were not found by the Zotero searches; semantic
fallback results were not treated as matches. Public full texts supplemented
the library; no item was added or modified.

Sources: [Field and Welsh](https://doi.org/10.1111/j.1467-9868.2007.00593.x),
[Hall and Wilson](https://ruc-econometrics.weebly.com/uploads/2/3/3/8/23387606/two_guidelines_for_bootstrap_hypothesis_testing.pdf),
[Dufour, author-hosted published article](https://jeanmariedufour.research.mcgill.ca/Dufour_2006_JE_MCT.pdf).

### Model-specific procedure and its mathematical claim

Let gamma be the identified free structural vector and let `t = C gamma`
be one component log slope. Conditional on each Person's recorded assignment
A_i, the likelihood contribution is

`f_gamma(y_i | A_i) = integral phi(theta) prod_{e in A_i} p_gamma(y_ie | theta) dtheta`.

Use the native L-metric, fixed N(0,1) population, first-family sum-zero log
slopes, source location constraints and second-owner steps throughout. For
`H0: C gamma = t0`, define the ideal statistic by

`T(y;t0) = 2 { sup_gamma ell_y(gamma) - sup_{C gamma=t0} ell_y(gamma) }`.

1. Obtain the constrained estimate `gamma_tilde(t0)` with all remaining
   structural coordinates reoptimized. Save its two starts and numerical
   qualification. Failure to obtain a qualified null fit is an unavailable
   observed test, not permission to generate from the unconstrained fit.
2. For each bootstrap dataset draw **one new N(0,1) ability per Person**, then
   draw all of that Person's ratings conditionally on that same ability under
   `gamma_tilde(t0)`. Keep facet levels, category ladder and analyzed assignment
   fixed. This generates exactly the displayed marginal law at the fitted
   null. Fixed EAP abilities or independent row-specific abilities generate a
   different law. No new assignment/missingness mechanism is represented.
3. Reestimate both unrestricted and null-constrained models on each generated
   dataset and compute `T_b`. Nuisance coordinates are reestimated in both;
   fixing them at the generating values is not this test. Apply the same
   declared source-selection/retry and numerical rules to observed and
   simulated fits, including empty categories and boundary/nonfinite results.
4. With a predeclared B, compute the finite-rank p-value
   `p_B = (1 + sum_b I(T_b >= T_observed))/(B+1)`. Retain ties as exceedances.
   This rule is conservative under exchangeability with ties; the fitted
   composite-null generator does **not** establish that exchangeability or an
   exact finite-N size bound. Its justification remains an approximation under
   regular, identified, interior MML with consistent nuisance estimation.

The implementation obtains locally qualified optima, not proven global
suprema. Paired starts, marginal gradients and positive information diagnose
numerical reliability but do not prove the missing global statement. The
candidate retains this limitation. It is separate from JML with increasing
numbers of person parameters and cannot inherit a JML validity claim.

For r verified exceedances, l verified lower statistics and all other planned
draws unresolved or uncomputed, the compatible rank values lie in
`[(1+r)/(B+1), (1+B-l)/(B+1)]`. Reject only if the upper bound is at most .05;
retain only if the lower bound exceeds .05; otherwise report unresolved.
Numerical ambiguity in comparing two LR statistics also belongs in this last
category. Never reduce B to the number of successful fits or redraw failures.
Stopping when every completion gives the same decision preserves this fixed-B
rule; stopping when a provisional p-value looks favorable does not.

Inverting these tests could later define a confidence set. A single target
test does not deliver an interval: finite-B p-values are discrete, may be
nonmonotone in t0, and can leave unresolved or disconnected regions. Endpoint
search, set topology and the full selected procedure need their own validation.

### Reuse, efficiency and the next bounded test

The existing RSM finite-Monte-Carlo record supplies the model-independent rank
rule, completion bounds and decision-preserving curtailment. Its source and
all six saved output files match. The full historical `verify` command fails
because the shared mutable `mfrm-wide-map-r50-20261001/rng-head.rds` differs;
the other 538 inputs match. Do not rewrite that historical fingerprint or
claim a complete unchanged-RNG replay. Reuse is limited to the unchanged
deterministic enumeration/formula evidence, not a new RSM or GMFRM experiment.

For the already specified no-refusal repeatability criterion (at most .01
decision disagreement when the true fitted-null tail is <=.025 or >=.075),
B=519 is the first admissible value in the grid 19,39,... . This is not an
outer coverage criterion or an automatic GMFRM allocation. At tail .05 the
expected curtailed count remains about 478, so endpoint inversion is not
made cheap merely by implementing early stopping. One complete point test
at B=519 requires up to 1,038 unrestricted/constrained optimization problems,
before multistarts and reference checks. No GMFRM runtime is inferred from
the RSM timings.

The parent selection is frozen in
`validation-results/gmfrm-profile-membership-20261010/bootstrap-candidate-review.rds`
and `bootstrap-candidate-parents.csv`: retained adaptive-profile N20 and N240
fixtures, plus N60 replicate 1 from the completed profile-membership manifest.
All use quadrature order 31 and Task t1 as the first-family target. These are
selected numerical fixtures, not a representative performance sample.

The next test has the following fixed boundaries:

- At each parent, set t0 to its fitted Task t1 log slope plus 0.5, without
  consulting generating truth or selecting a missed interval. Check the null
  at adaptive orders 31/61 before generating anything. Retain a failed parent;
  do not replace it with an easier dataset.
- For each passing parent use exactly 19 pre-seeded inner datasets, at most
  57 across the three parents. This small allocation tests generation, refits,
  failures and cost; it does not estimate tail accuracy or qualify coverage.
  Complete these draws for accounting rather than curtailing the feasibility
  check. Verify preservation of the caller RNG and reproducibility before use.
- Preserve both slope owners when building indices. The current public
  `bootstrap_mfrm_gpcm()` rejects product slopes, and its generator does not
  supply `gpcm_spec` to `build_indices()`. Reuse the underlying response and
  profile primitives with the explicit product specification; removing the
  public guard alone is not a valid implementation.
- Bind source, inputs, seeds and settings before execution. Use two starts,
  maxit 400 per existing profile stage, positive unregularized full information
  at unrestricted optima and nuisance information at constrained optima.
  Require the unrestricted score or projected nuisance score, respectively,
  to be <=1e-4 in absolute maximum; require constraint error <=1e-8 and
  two-start NLL agreement <=1e-5. Require order-31/61 NLL agreement <=1e-5
  and gradient agreement <=1e-4.
  Reuse the independent continuous-integral/Louis reference for observed and
  returned bootstrap optima; retain its existing constraint, score and
  positive-information gates. Do not use generated abilities as fit inputs.
- Report all parent/draw refusals and phase times. Any response-law mismatch,
  constraint change, failed reference check or incomplete accounting blocks
  advancement. Numerical refusals block a broad performance launch and need
  a recorded disposition; no automatic case-specific rescue follows. Passing
  the check establishes feasibility only. A full procedure and independent
  performance contract across the retained target/design scope are required
  before confirmation or public adoption.

Candidate selection and reuse review are complete. The user subsequently
authorized new generation/refitting on October 10. The research producer
`inst/validation/gmfrm-null-bootstrap-20261010.R` binds source, inputs,
environment and 57 seeds before execution. The bounded run is now complete
in `validation-results/gmfrm-null-bootstrap-20261010/`; its disposition follows.
Completed phases resume without new computation; numerical refusals are not
retried. The original candidate-review record remains unchanged and performed
no fitting or random draws. Production code/defaults, all D1 obligations and
the wider N20--480/facet/assignment scope remain intact.

## October 10 null-bootstrap feasibility outcome

**Disposition: repair required for the tested computational procedure.**
All three observed unrestricted/null fits pass their two-start, quadrature
and independent-reference gates. The full allocation of 19 draws per parent
is complete, with no redraws, curtailed cases or execution errors. The raw
summary's `blocked_pending_disposition` flag is resolved by this decision:
the procedure does not advance to broad performance evaluation, confidence-set
inversion or public adoption. This is not a rejection of parametric bootstrap
theory, a coverage result, or a change to the agreed release scope.

| Selected parent | Generated | Numerically qualified | Refused | Compatible B=19 rank values | Point-test status | Summed phase minutes |
| --- | ---: | ---: | ---: | --- | --- | ---: |
| N20 | 19 | 0 | 19 | [0.05, 1.00] | unresolved | 30.10 |
| N60 | 19 | 16 | 3 | [0.05, 0.20] | unresolved | 11.75 |
| N240 | 19 | 19 | 0 | [0.05, 0.05] | reject at the declared rank rule | 42.60 |

Times include observed-fit qualification and all subsequent phases within
each case; the three cases ran concurrently, so these are not additive
wall-clock durations. Optimization consumes 1775.382, 633.618 and 2274.189
seconds, respectively; independent reference checks consume 30.668, 71.326
and 281.710 seconds. Generation including exact replay takes less than 0.13
seconds per case. No B=519 calculation or endpoint inversion is allocated
from these timings.

The rank ranges are completion bounds for unresolved comparisons, not
confidence intervals for a tail probability. All qualified inner statistics
are below their observed statistic; the 19 and 3 refusals in N20 and N60
remain unknown rather than being removed from B. The numerical comparison
uses a predeclared +/-4e-5 sensitivity bracket per LR, derived from two
1e-5 objective tolerances. It is not a certified mathematical error bound.
Independent continuous-integral LR comparisons give the same ordering at
all qualified draws. B=19 tests the procedure and accounting; the N240 rank
decision does not establish size, power or interval coverage under unknown
nuisance parameters.

The failures are not confined to one difficult dataset or one narrow gate:

- N20: every draw fails at least one optimization/quadrature gate and at
  least one independent-reference score gate. Eighteen fail two-start NLL
  agreement. Fourteen have a returned point with nonpositive reference
  information. These categories overlap. When reference integration itself
  fails agreement, its curvature sign must not be treated as a verified
  property of the exact likelihood. This check does not prove nonexistence
  of a finite MLE or distinct local maxima.
- N60: draw 3 fails unrestricted two-start NLL agreement (difference
  1.063958e-4 versus the fixed 1e-5 limit). All four local point checks pass;
  this illustrates why local score/information checks alone are insufficient.
  Draws 14 and 15 fail the unrestricted retained-start high-order and
  independent score gates; independent maxima are approximately 1.14099e-4
  and 1.20872e-4 against the 1e-4 limit. These are not repaired or waived.
- N240: all 19 draws pass all declared gates. This is feasibility at one
  selected fitted null, not a representative performance sample or proof of
  global maximization.

Each N has only one parent, and the fitted null nuisance parameters and
assignments differ. Their effective slope ranges are approximately
0.0666--5.4546, 0.2507--1.9238 and 0.5284--1.9938, respectively. Therefore
the contrast between cases is not an isolated sample-size effect. The
difficult N20 parent is retained; substituting an easier source or only
qualifying the N240 case would change the contract.

Implementation and evidence checks are complete:

- The generator draws one N(0,1) ability per Person and shares it across
  that Person's recorded rows. It uses the qualified constrained estimate,
  both slope owners, fixed assignment and the original category ladder.
  An independent literal response formula agrees to at most 1.110223e-16
  across all 57 datasets. Caller-RNG restoration with and without an existing
  seed and exact same-seed replay pass for every dataset. A deterministic
  preflight also verifies that absent response categories do not alter the
  roster or parameter dimension. Generated abilities are never fit inputs.
- Observed and simulated fits use the same retained/zero starts and native
  optimization rules: direct BFGS at reltol 1e-10 with its existing polishing
  for unrestricted fits, and the existing constrained profile stages, with
  maxit 400 per stage. All nuisance coordinates remain free. All 120
  constrained returned vectors have zero recorded constraint error.
- All 240 optimization/reference pairs (12 observed, 228 bootstrap), 57
  generation records and 60 result records are saved as 597 bound phases.
  `verification.log` independently reconstructs every qualification flag,
  generated score from its saved uniforms/probabilities, and each finite-rank
  completion bound. It verifies source/input/result hashes. There are no
  missing outcomes or phase execution errors.
- `N20-replay.log`, `N60-replay.log` and `N240-replay.log` record fresh-session
  replay with generation, optimization and reference entry points disabled;
  all 199 phase files per case remain byte-identical. The epoch uses the
  recorded installed R 4.6.1 environment because the historical relocated
  executable was unavailable; it does not claim identical historical-runtime
  replay. The generation/fit/reference source and loaded native DLL remain
  bound to the pre-execution manifest. No production source changed, so
  unrelated package tests and completed numerical studies were not repeated.

The bounded study and its disposition are finished. The required improvement
is a justified, reliably computable full procedure across the retained scope;
changing the LR cutoff alone does not supply it. In particular, polishing the
two marginal N60 scores would leave the much broader N20 failures unresolved.
No automatic case-specific rescue, tolerance relaxation or extra simulation
follows. Any revised numerical/methodological policy needs its own bounded
contract and independent performance evaluation before public qualification.
The population and JML obligations remain separate and open; D1 is not closed.

## October 11 saved-point integration diagnosis

**Bounded contract, before reference evaluation:** determine whether inaccurate
integration and/or lack of stationarity explain the returned N20 points. The
existing 57-draw evidence is immutable. Evaluate all 80 N20 returned vectors
(observed plus 19 draws, two starts, free/null), and the eight observed N60/N240
vectors as controls. No new generation, optimization, bootstrap allocation,
information-matrix qualification or confidence-set inversion is authorized by
this diagnostic contract. All failures stay in the original denominator.

Saved-result inspection establishes the need: effective slopes reach 2.34e6,
native versus continuous NLL discrepancies reach 2.09, and GH121 versus
continuous discrepancies reach 0.80 in N20. A continuous normalizer alone does
not validate GH-based derivatives. No generated dataset has a missing internal
step-owner category; only three N20 draws have a missing boundary category.
Thus missing categories cannot explain all 19 refusals. This does not prove
finite-MLE existence, nonexistence or global optimization.

The new reference evaluates the literal response law in original theta
coordinates. Its log posterior is strictly concave, with second derivative
`-1 - sum(a^2 Var(K))`. Partition at the mode, posterior log-density drops
0.5/2/8/32/64, and all pairwise category-logit crossings with offsets
0, +/-1, +/-4, +/-16 and +/-40 transition widths. Integrate each finite
segment on [0,1]. Compare 32- and 64-point Gauss--Legendre likelihood/score
integrals and an independent adaptive Gauss--Kronrod normalizer. Bound the two
omitted tails using the endpoint log density and outward log-density slope;
also bound score tails with a constant-plus-absolute-theta envelope. These
analytical tail bounds are distinct from estimated quadrature errors and do
not constitute a floating-point proof of the entire calculation.

Qualification requires NLL agreement within 1e-7, maximum integrated-score
change within 1e-6, estimated normalizer error and tail NLL contribution within
1e-8, and tail score contribution within 1e-7. Retain unavailable outcomes.
Check directional NLL derivatives at the minimum/maximum effective-slope
unrestricted N20 bootstrap points, selected without reference to diagnostic
success, in three parameter blocks and one dense direction, using fixed
steps 1e-4, 2.5e-5 and 6.25e-6. Report convergence and discrepancy; these
checks do not alter the 1e-4 stationarity threshold. Source/input hashes,
per-vector results and session information are saved separately under
`validation-results/gmfrm-segmented-reference-20261011/`.

If independent integrals disagree, repair/qualify the reference before
inferring likelihood geometry. If they agree and the score is nonzero, the
returned point is not stationary; improving the optimizer's objective and
derivatives takes priority over a larger bootstrap. Agreement or a small score
alone cannot qualify an optimum, a new procedure, coverage or public release.
This bounded diagnosis ends with that disposition, rather than automatically
starting another fit campaign. The R documentation explains why a successful
adaptive-integration status alone can miss narrow features:
[stats::integrate](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/integrate.html).

**Completed outcome:** the segmented reference qualifies at all 88 fixed
vectors. This qualifies evaluation at those vectors, not their optimality.
No dataset was generated and no model was refit. All original parent/bootstrap
hashes remain unchanged. The producer is
`inst/validation/gmfrm-segmented-reference-20261011.R`; its separate evidence
directory contains the manifest, 88 point records, 24 derivative records,
`points.csv`, `derivatives.csv`, `summary.rds` and `verification.log`.

The integrated score follows directly from the response law. With category
design `D_k`, offset `d_k = D_k b`, slope `a = exp(Z g)` and
`p_k proportional to exp(a (k theta - d_k))`, each response contributes

```
U_b(theta) = -a sum_k p_k (D_y - D_k)
U_g(theta) =  a sum_k p_k ((y-k) theta - (d_y-d_k)) Z.
```

The marginal log-likelihood score is the posterior expectation of the sum
of these contributions. At a finite parameter vector the complete score is
bounded by a constant plus a constant times `abs(theta)`; the Gaussian prior
therefore supports differentiation under the integral. At a tail endpoint
`b`, concavity and outward slope `s > 0` give the normalized density bound
`exp(f(b)-f(mode)) exp(-s t)`. Its integral is `exp(f(b)-f(mode))/s`; the
first absolute moment is bounded using `abs(b)/s + 1/s^2`. This supplies the
recorded normalizer and score-tail bounds. Concavity is in **theta with
structural parameters fixed**, not in the structural parameters themselves;
it supplies no claim about their global optimum or finite-MLE existence.

Across all 88 points, the largest total-NLL difference is 6.82e-13 between
Legendre orders and 9.09e-13 against adaptive Gauss--Kronrod; the maximum score
change is 8.33e-11 even when absolute per-Person differences are accumulated
before summing. Estimated relative normalizer error sums reach 2.67e-12.
Analytical omitted-tail bounds reach 3.83e-27 for NLL and 1.82e-21 for a score
coordinate; these do not bound floating-point or quadrature error. The eight
directional checks at the preselected smallest/largest-slope free points
agree at the smallest declared step to at most 3.80e-9. Legendre polynomial
moments and a closed-form zero-coordinate response kernel also pass.

| N20 bootstrap diagnostic | Affected returned points | Largest discrepancy |
| --- | ---: | ---: |
| Native NLL vs segmented, limit 1e-5 | 60/76 | 2.08543 |
| GH121 NLL vs segmented, limit 1e-6 | 50/76 | 0.796821 |
| Previous unsplit continuous NLL vs segmented, limit 1e-6 | 6/76 | 0.00256571 |
| Unrestricted score exceeds 1e-4 | 38/38 | 5.66769 |
| Null-projected score exceeds 1e-4 | 29/38 | 18.1992 |

All 19 N20 datasets have both unrestricted returned points outside the
stationarity criterion; their smallest maximum score is 2.83e-4. In draws
9 and 16 the native NLL discrepancies at all four points are below 1e-5, yet
the unrestricted score still fails. Thus increasing quadrature order alone
does not establish convergence. Conversely, the earlier GH121 information
signs at discrepant points are not reliable evidence of exact-likelihood
curvature. The new reference deliberately computes no structural Hessian.
The twelve observed parent points retain NLL and relevant-score agreement;
the N60/N240 controls do not constitute a new evaluation of their inner draws.
The original 0/19, 16/19 and 19/19 bootstrap qualification counts and all
completion bounds remain unchanged.

The 88 evaluations take 62.040 seconds in the recorded environment; derivative
checks take 8.868 seconds. This is a saved-point diagnostic cost, not a refit
speed benchmark. Fresh-session replay with reference integration disabled
preserves all 116 RDS/CSV files byte-for-byte. No unrelated package checks or
completed numerical studies were repeated for this research-only addition.

**Disposition:** the bounded diagnosis is complete. Before any further
bootstrap/coverage allocation, a revised estimation procedure must use
mutually consistent, sufficiently accurate objective/score calculations and
demonstrate its stopping behavior on the retained scope. The new reference
can check that repair; it is not yet a production optimizer or interval
method. Neither local/global maxima nor boundary nonexistence are inferred
from these nonstationary points. No case-specific N60 rescue, tolerance
relaxation, public inference change or scope reduction follows. D1, population
and JML obligations remain open.

## October 11 segmented estimation candidate

**Completed small-sample continuation: partial numerical repair.** All eight
scheduled continuations finish and retain their stage checkpoints, including
two numerical refusals. No replacement starts or new responses are added.
The two retained datasets each have free/constrained fits and two starts;
these are eight attempts, not eight independent datasets.

| Retained N20 case | Terminal native gradient, two starts | Decision |
| --- | --- | --- |
| b09 constrained | 3.5253e-8, 6.1048e-8 | Both pass independent score, positive/stable curvature and start agreement |
| b09 free | 1.3514e-3, 2.3655e-4 | Both remain nonstationary; near-zero curvature and large parameter drift |
| b19 constrained | 4.6497e-7, 2.7283e-6 | Score passes, but nearly singular curvature prevents finite-point qualification |
| b19 free | 2.5692, 1.1786 | Extreme slopes and numerical refusals; terminal independent curvature/reference verification is incomplete |

For b09 constrained, each rescaled BFGS stage uses five gradient evaluations
(12 and eight function evaluations). Including curvature and independent
checks, the runs take 80.4 and 78.2 seconds. This is a continuation from
saved 2000-iteration endpoints, **not** an end-to-end speed comparison with
a fresh fit. Both endpoints have minimum curvature 2.8414e-4, condition
number 6.3533e4 and curvature-relative step discrepancy about 3.4e-6. Their
NLL spread is 1.42e-14 and maximum parameter difference 1.27e-6. No likelihood
term, constraint, parameter cap or prior was changed.

For b19 constrained, NLL also agrees across starts (spread 7.97e-7), but
maximum absolute parameters reach 81,524 and 85,194, minimum effective
slopes fall to 6.89e-6 and 6.60e-6, and curvature condition numbers are about
2e16. The small raw scores and agreeing likelihoods therefore do not imply
regular finite-parameter inference. The b09 free endpoints likewise drift
above 1e5 in parameter magnitude with minimum slopes around 2e-8; both
scores still exceed 1e-4, and their NLL spread 1.57e-4 exceeds the start
agreement criterion. These paths suggest boundary/weak-information behavior;
they do **not** prove that finite/global maxima do not exist.

For b19 free, the largest slopes reach 3.73e16 and 1.29e16. The retained
point evaluations succeed, but nearby curvature evaluations fail numerical
accuracy checks; the neutral run also records a root-bracketing failure
during search. These extremes exceed the previous 50-digit fixed-point
verification's scope. Preserve the failures rather than extrapolating that
verification or declaring convergence from a returned optimizer code.

All six completed independent point evaluations pass the numerical
likelihood/score agreement, rule, normalizer and tail checks: maximum NLL
discrepancy 4.26e-14 and gradient discrepancy 5.89e-14. The `ReferencePassed`
summary field additionally requires the 1e-4 independent score, so it is
false for the two b09 free points despite accurate evaluation. Only the
two b09 constrained points pass all local-candidate criteria. No dataset
has both a qualified free and constrained pair; no LR/bootstrap/inference
qualification follows from this allocation.

The 23 new continuation assertions and 97 existing curvature assertions
pass. `verify.R` in the continuation evidence directory checks all eight
attempts, stage checkpoints, source snapshots, original input identities
and stopping predicates. Fresh-session summary replay with `optim`,
`optimHess`, `integrate` and `uniroot` disabled is byte-identical.
The previous N20-observed/N60/N240 controls are retained as their original
evidence, not relabelled as fresh tests of this warm-continuation procedure.

**Method decision:** retain the reusable internal continuation and its
diagnostics, but do not adopt it as a complete public estimator or interval
route. Small-N support remains a priority. Further generic iteration
extensions or larger bootstrap runs do not address the remaining boundary/
weak-information behavior. A justified treatment of that behavior and of
extreme-slope numerical limits is needed before a from-start procedure or
performance allocation. Public fitting/information/scoring and D1's broader
N20 population, JML structural-truth and multi-design obligations remain
unchanged and open.

**Small-sample continuation (October 11, frozen contract):** the user's latest
instruction prioritizes practical N20 support while retaining the wider
package scope. Reuse all eight still-unresolved N20 endpoints from the
completed follow-up. First evaluate their repaired marginal scores and
central-difference Hessians at steps 1e-3 and 1e-4; archive the parameters,
both unsymmetrized matrices and eigensystems. This phase performs no refits.
It determines whether the existing curvature-coordinate search can address
the observed stagnation and whether local numerical geometry is resolved.
Producer: `gmfrm-segmented-scaling-20261011.R`; records:
`validation-results/gmfrm-segmented-scaling-20261011/`. A search policy must
be recorded before any new optimizer allocation. Keep the original
likelihood, constraints, gradient/reference criteria and all N60/N240
evidence. No parameter caps, implicit priors, new data or broader bootstrap
follow from prioritizing small samples. Finite-point convergence, boundary
behavior and interval performance remain separate claims.

The geometry phase completes all eight points. The b09 free endpoints have
curvature condition numbers approximately 3e5; b19 free curvature is much
more sensitive to difference steps (including negative curvature at the
neutral endpoint). Freeze the following common continuation before fitting:
reuse the existing curvature scaling and SPD polish helpers, at most three
scaled BFGS stages of maxit 400 and reltol 1e-13 on total NLL. Each stage
keeps its best valid point; a code-zero score failure allows one existing
SPD Newton correction. In addition to the unchanged native score gate,
require positive curvature with eigenvalue ratio above 1e-10 and predicted
Newton improvement at most 1e-6 to stop as a local candidate. The ratio is
the existing numerical scaling floor, not a prior or inferential ridge.
Terminal checks retain the original independent normalizer/tail tolerances,
use literal compensated 32/64-point score integration, and compare Hessians
at 1e-3 and 1e-4. Both must be positive, the finer eigenvalue ratio must
exceed 1e-10, and their discrepancy in curvature-scaled coordinates must
be at most .01. This last check is a numerical corroboration criterion,
not a proof of positive population information. The original two-start NLL
agreement criterion remains 1e-5. Save every completed stage before terminal
verification. Apply the policy to all eight unresolved endpoints without
selection or replacement; retain the completed N20-observed/N60/N240 controls.
Producer: `gmfrm-segmented-continuation-20261011.R`; separate epoch records
are in `validation-results/gmfrm-segmented-continuation-20261011/`. These are
warm continuations of retained fits, not a new from-start optimizer trial.

The coordinate change is invertible: for nuisance coordinates q, search in
q = q0 + T z with T constructed from the Hessian eigenvectors and strictly
positive search scales. Evaluate the same f(q) and transform the score as
T' g(q); the existing affine constraint map is applied after this change.
No penalty is added to the likelihood. The eigenvalue floor affects the
search transformation only. When the unfloored Hessian is positive, half
the squared transformed score is the local quadratic prediction of remaining
NLL improvement; this remains an approximation, not a global optimality
certificate. Flat/unstable curvature is retained as a review condition.

**Authorized follow-up (October 11):** the user explicitly requests increased
iteration limits, diagnosis of code-zero gradient failures and the integration
refusal, including consideration of a different internal evaluator. This
supersedes the completed candidate's prohibition on *automatic* retries.
Keep old evidence immutable. First add failure telemetry without changing
arithmetic. For the seven maxit returns, run the same original starts/policy
with maxit 2000 (formerly 400); retain the original 400-step prefix for comparison.
Reproduce the single integration failure with its original 400-step policy
and save the failing parameters and person-level quadrature differences.
For all three code-zero score failures, evaluate the constrained objective's
Hessian from central differences of the verified score at two step sizes,
then assess a positive-definite Newton correction against the independent
reference. This diagnoses objective-change stopping, curvature and score
error separately; it does not qualify structural intervals. Preserve the
existing integration, stationarity, constraint and two-start criteria. No
new responses, wider bootstrap, public defaults or parameter caps are added.
Any alternate integration repair must first be justified at the reproduced
failure and checked against an independent calculation before refitting.
Follow-up records are separate in
`validation-results/gmfrm-segmented-followup-20261011/`.

**Integration diagnosis and repair criterion:** the instrumented replay
reproduces the refusal at evaluation 384 (298 numerical refusals including
the terminal evaluation). The retained optimizer vector and last failing
vector are identical. The error is the accumulated 16/32 score difference
2.870075e-6; the NLL difference is 1.60e-14, with tail bounds 1.72e-28 NLL
and 6.18e-17 score. Effective slopes span 6.34e-12 to 6.58e10. Person 8
accounts for 2.59e-6 of the difference; Persons 3 and 14 account for most
of the remainder. This separates score-integration roundoff from tail
truncation, normalizer accuracy and optimizer stopping.

The independent `gmfrm-segmented-roundoff-20261011.py` compares 27 fixed-point
calculations (three people, three orders, three arithmetic routes). It holds
the retained double-valued coefficients/rules fixed, then compares ordinary
float64, 50-decimal-digit kernels on already-rounded nodes, and 50-digit
kernels on nodes reconstructed as origin plus local displacement. Raising
the rule from 16 to 64 does not monotonically fix the ordinary computation.
High-precision kernels alone leave node-rounding error. Locally reconstructed
high-precision nodes reduce order differences to 3.11e-15. This diagnoses
both node formation and cancellation in relative logits; it is not an
assertion that a denser rule provides a general error bound.

The alternate fixed-point calculator `gmfrm-local-coordinates-20261011.R`
retains the low part of local-coordinate additions, computes category logits
relative to a common category, and computes the log-slope score directly
from the same logit differences. No likelihood, constraints or tolerance
is changed. At the failed vector its total-score order differences are
below 2.62e-14, and the three problematic person scores agree with the
independent 50-digit reference within 9.55e-15. Four directional finite
differences (location, step, slope and dense), at three decreasing steps,
have final-step errors at most 1.29e-7. The comparison checks the score's
relation to the continuous likelihood as well as integration agreement.

Before replacing the internal native evaluator's arithmetic, verify the
same native-coordinate implementation on all 88 retained points, the
reproduced failing vector and binary/four-category native regression tests.
The original maxit experiment keeps its own unchanged numerical epoch.
Public fitting, information and scoring integration remain separate tasks;
roundoff repair alone does not establish a finite maximum or a valid interval.

**Completed code-zero diagnosis:** all three projected Hessians are positive
definite, checked by central differences of the continuous score at h=1e-3
and 1e-4. Their independent-reference scores after one Newton correction are
5.12e-10 and 1.02e-9 for the two N240 starts, and 2.19e-7 for N20 observed
from zero (previously 1.76e-4, 2.76e-4 and 5.09e-4). No score cutoff changes.
The two N240 Hessian condition numbers are about 36.85; remaining predicted
NLL improvements, 8.26e-10 and 5.14e-10, are below the original relative
objective-change threshold 1.43e-9. Actual decreases agree. This supports
objective-change termination, rather than severe local ill-conditioning or
integration disagreement, as the explanation for these two returns. R's
[BFGS implementation](https://raw.githubusercontent.com/wch/r-source/R-4-6-branch/src/appl/optim.c)
does not require the independent total-score criterion to return code zero.
The objective is divided by N; the displayed thresholds are in total-NLL
units. This is not a claim that changing fnscale alone changes that relative
threshold in total units.

The N20 observed null point instead has condition number about 2,742 and a
larger remaining decrease (7.73e-8). Its successful curvature correction
shows why the last BFGS search direction's small decrease does not bound all
remaining directions. A scalar stopping flag is insufficient for both
mechanisms. These are local numerical diagnostics, not a global-optimum or
information-based confidence-interval qualification.

**Internal arithmetic repair completed:** the compensated local-coordinate
calculator is now in `R/core-gmfrm-segmented.R`. Root searches locate segments
using the existing inexpensive calculation; integration nodes, the peak and
tail evaluations use compensated relative logits. Log-slope scores use those
same logit differences, avoiding a second cancellation. All 88 old points
agree with the frozen independent reference (maximum NLL difference
6.82e-13, score difference 5.46e-11). At the reproduced failing point, the
native/literal score difference is 2.61e-14 and the native accumulated 16/32
score difference is 3.89e-14. The actual package namespace passes 57 regression
assertions, including eight analytic narrow-transition checks designed to
fail if the small local displacement is first rounded away. An initial
prototype's scalar-to-matrix shape bug was detected by the existing tests and
corrected before these qualification checks; its failed log is preserved.

The promoted file is byte-identical to `local-fast-source.R`, whose tests and
saved-point checks have separate source bindings. The old maxit experiment
used its original loaded arithmetic, source snapshots and first-400
comparison. These results qualify this internal evaluator on the checked
domain; the repaired arithmetic has not been used for a new optimizer study,
Hessian-based inference, LR calibration or coverage claims. Public fitting,
information/scoring routes and defaults remain unchanged. No simulation is
regenerated to validate the arithmetic patch.

**Completed iteration-extension outcome:** all seven extended attempts return
vectors that qualify under the independent integration checks, but none
passes the unchanged complete numerical criterion. Six reach maxit 2000;
N20 draw 19, free from zero, returns code zero with score 0.00706. Its 39
rejected trial evaluations remain recorded. The stored improvement-history
prefix through the original 400-iteration run is identical for every attempt.
This verifies the saved prefix, not unrecorded full parameter vectors at
every optimizer call. The comparison changes only maxit within the old
arithmetic epoch, and retains both start types.

| N20 dataset / constraint / start | Score at original return | Score after extension | New termination |
| --- | ---: | ---: | --- |
| Draw 9 / free / retained | 0.0318080 | 0.0109596 | Maxit 2000 |
| Draw 9 / free / zero | 0.0179965 | 0.00341262 | Maxit 2000 |
| Draw 9 / null / retained | 0.00656912 | 0.000378145 | Maxit 2000 |
| Draw 9 / null / zero | 0.00386037 | 0.000720302 | Maxit 2000 |
| Draw 19 / free / zero | 0.0176201 | 0.00706185 | Code zero; score failure |
| Draw 19 / null / retained | 0.00674652 | 0.0109205 | Maxit 2000 |
| Draw 19 / null / zero | 0.00999787 | 0.00174823 | Maxit 2000 |

Total NLL improves by 0.00145–0.10871, while the largest coordinate changes
by 1.95–16.98 between the original and extended returns. Draw-9 free starts
still differ in NLL by 0.001723; its null starts agree within 2.65e-6 but
both fail stationarity. Draw-19 null starts differ by 0.005264. These are
different failure diagnostics: better objective values or agreement between
two starts do not substitute for the score check. Drift and extreme slopes
motivate attention to optimization geometry and boundary behavior, but do
not prove absence of a finite MLE or identify a global optimum.

All 11 follow-up phases are complete: seven extensions, one instrumented
reproduction and three curvature diagnoses. `attempts.csv`, `curvature.csv`
and `summary.rds` retain every case. `verify-final.R` verifies archived
sources, the promoted arithmetic, old-input hashes, multiprecision and
directional comparisons, and a byte-identical replay of all phase/summary
RDS/CSV files with `optim`, `integrate` and `uniroot` disabled. The repair and
diagnosis are complete; the full estimation/inference procedure is not
adopted. The next dependency is a coherent optimization and stopping policy
with finite/boundary behavior addressed before additional LR allocation.
No automatic further maxit increase, new responses, bootstrap expansion,
public inference change or reduction of the existing D1/JML/population scope
follows from these selected numerical fixtures.

**Contract before implementation checks/refitting:** build an internal
two-family MML objective/score evaluator using the native parameter expansion
and category designs, with segmented continuous integration and an owned
parameter cache. Its working 16/32-point Legendre rules must agree within
1e-7 total NLL and 1e-6 total-coordinate score; accumulated analytical tail
bounds must be below 1e-8 NLL and 1e-7 score. Fail closed on numerical errors.
Keep the public estimator, information/scoring routes and defaults unchanged
until a complete compatible route is qualified. The candidate supports the
existing two-family fixed-N(0,1), unweighted specification, arbitrary owner
names/counts, incomplete connected assignments and binary/polytomous scores.

First compare all 88 previous saved points against the frozen independent
reference (NLL 1e-7, score 1e-6), and test native-coordinate derivatives,
constraints, malformed input, rejected trials and cache ownership. Only then
refit five retained datasets: the observed N20/N60/N240 parents, N20 draw 9
(accurate old NLL but nonstationary), and N20 draw 19 (largest returned slope).
These diagnose different mechanisms; they are not statistical replications or
a replacement of the full sample-size/design scope. No new responses or RNG
streams are allocated. Preserve all original results.

For each dataset use unrestricted and the original Task-t1 null constraint,
each from the original parent vector and zero: 20 attempts total. The candidate
uses one BFGS stage, maxit 400, reltol 1e-12, objective scale N, the existing
typed-boundary rejection wrapper and no continuation/retry or parameter caps.
Record raw optimizer code, complete trace of improvements, terminal total
score, parameter/slope range, numerical rejections, evaluation counts and
time. A terminal point passes only with optimizer code zero, independent
reference qualification, relevant score <=1e-4, NLL agreement <=1e-5 and
gradient agreement <=1e-6. Null error must be <=1e-8; both starts must agree
in independent NLL within 1e-5. This stage supplies no information-matrix,
global-optimality, LR, interval or coverage qualification.

Stop this bounded evaluation with a recorded decision even if it fails.
Successful evaluation is not successful optimization; successful optimization
would still require curvature and downstream-consumer qualification before
public integration. Preserve distinct integration, stopping and boundary
questions rather than adding automatic optimizer rescues. Results are bound
separately in `validation-results/gmfrm-segmented-estimation-20261011/`.

**Completed bounded decision: evaluator verified; estimation candidate still
requires repair and is not adopted.** `R/core-gmfrm-segmented.R` implements
the native-coordinate objective/score, reusing native parameter expansion
and estimability designs. Constant designs and the Legendre rules are built
once; value/gradient calls share an owned parameter cache. Every successful
evaluation checks both integration orders and analytical tail bounds. This
internal engine has no public fitting/information/scoring caller.

All 88 saved-point comparisons pass: maximum independent discrepancies are
6.82e-13 NLL and 8.32e-11 score. The 88 checks take 42.281 seconds. The final
43 regression assertions pass, including binary/four-category responses,
unequal owner counts/names, incomplete crossings, full-coordinate finite
differences, linear constraint projection, typed rejection, cache ownership
and repeated invalid input. The first test version's fixed-prior GH121 oracle
was insufficiently accurate on the four-category fixture; mode-adapted GH121
and the independent literal Louis score agree, with the finite-difference
checks unchanged. No acceptance threshold was relaxed.

All 20 allocated refits and their reference outcomes are recorded:

| Retained dataset | Passing terminal points / 4 | Passing free/null start-pairs / 2 |
| --- | ---: | ---: |
| N20 observed | 3/4 | 1/2 |
| N20 draw 9 | 0/4 | 0/2 |
| N20 draw 19 | 0/4 | 0/2 |
| N60 observed | 4/4 | 2/2 |
| N240 observed | 2/4 | 1/2 |

The 11 unsuccessful attempts comprise seven optimizer iteration limits,
three code-zero terminations whose independent score exceeds 1e-4, and one
integration-accuracy refusal. The latter is N20 draw 19, unrestricted,
retained start: its phase records the error and 175.476 seconds, but the
aborting wrapper does not retain an intermediate/terminal vector or trace.
Its exact failing evaluation cannot be identified from the saved record;
it remains a failure in the denominator and was not rerun to fill that gap.

All 19 returned vectors pass independent integration checks. Their maximum
native/reference discrepancies are 4.55e-13 NLL and 2.29e-7 score. Thus the
candidate's remaining failures cannot be dismissed as disagreement between
the objective and the verified score at these returned points. In particular,
the N240 null points have optimizer code zero but scores 1.76e-4 and 2.76e-4;
the N20 observed null from zero has score 5.09e-4. N20 draw 9 reaches the
iteration limit from both starts under both constraints. One returned draw-19
free point has effective slope 4.84e9 and still fails stationarity. Such
behavior does not prove a finite maximum, nonexistence, a global optimum or
the correct boundary limit. No structural Hessian was evaluated.

The candidate deliberately uses one BFGS stage. It does **not** repeat the
existing public optimizer's polishing ladder, so its pass counts cannot be
interpreted as a controlled improvement/deterioration comparison with that
complete optimizer. They show that an accurate integration engine plus this
fixed stopping procedure is insufficient. Preserving the original 57-draw
study and all its counts prevents this diagnostic selection from replacing
the agreed broader evidence.

Summed optimization time is 29.698 minutes and terminal-reference time is
47.029 seconds; cases ran in up to three parallel processes with single-thread
BLAS. These totals are not wall-clock time or evidence of a fitting speedup.
No new responses, confidence-set inversions or coverage studies were produced.

`verification.log` reconstructs all 20 flags, constraints and ten start-pair
decisions, then replays the original epoch with candidate/reference entry
points disabled: all 132 RDS/CSV files are unchanged. A subsequent code review
fixes a cache-sentinel collision for repeated `NULL` input. The numerical
epoch's evaluator, producer and test file were archived in `epoch-source/`
before that fix. The valid numeric-vector path is unchanged; the final check
verifies that the evaluator differs by exactly this guard. Final regression
tests and `final-verification.log` pass without repeating the 88 evaluations
or 20 fits. The producer now permits read-only summarization of bound saved
phases after source changes; numerical `check`/`run` still require the exact
epoch source. Original parent/bootstrap/reference hashes remain unchanged.

This closes the bounded allocation and its adverse adoption decision, not
the estimation or interval obligation. Before public integration, settle the
complete optimization/stopping policy and its behavior near poorly scaled or
boundary configurations, then qualify information and downstream consumers
under the same numerical definition. Further automatic BFGS retries, larger
bootstrap batches or a scope reduction are not the conclusion of this study.
D1 and the separate population/JML obligations remain open.

## Historical execution status and numerical evidence

**Historical execution status (October 1):** all new computation is held for the
[full sample-size and facet-structure review](#october-1-small-cohort-and-facet-structure-review).
The user relaxed the October 2 18:00 deadline but explicitly requested design
review before further calculation. This supersedes earlier launch/deadline
instructions in this chronological record; frozen evidence remains unchanged.
The [shared MML/JML roadmap](internal-roadmap-0.2.4.md#mml-and-jml-validation-plan)
owns the current cross-estimator scope and execution sequence. The detailed
MML proposals below feed that plan; they are not a separate MML-first queue.
The shared [facet comparisons](internal-roadmap-0.2.4.md#c-facet-structure-with-explicit-workload-controls)
and [robustness controls](internal-roadmap-0.2.4.md#e-robustness-mechanisms-and-matched-controls)
now specify workload, population-shape, missingness and dependence contrasts
for the common model families. They do not qualify the two-family MML route
or replace its interval qualification. The subsequent
[D specification](internal-roadmap-0.2.4.md#d-mml-scale-slope-families-and-output-decisions)
fixes the matched normal-scale mapping, slope-family/null comparisons and
small-N integer allocations. The current interval rank gate remains a reference
procedure; changing it still requires justification and validation. The missing
estimated-population/one-family location-contrast consumer is now an explicit
implementation priority, not an available output. The shared
[inference and evidence allocation](internal-roadmap-0.2.4.md#inference-decisions-and-evidence-allocation)
supersedes older provisional comparison directions below; no computation resumed.
The [F scoring/reuse specification](internal-roadmap-0.2.4.md#f-person-scoring-future-cohorts-and-saved-reuse)
now fixes held-out panels, prior/scale comparisons, scoring-node retries and
calibration-replicate Monte Carlo accounting. Two-family scoring remains
conditional on fixed point calibration and N(0,1); a structural interval
refusal alone does not determine its separate source-scoring result.
The [calibration/refinement specification](internal-roadmap-0.2.4.md#calibration-procedures-and-bounded-numerical-refinement)
now separates initial, source-reviewed point/scoring and interval-stage results.
It is a prospective workflow, not a relabelling of the 400-case interval-driven
replay below. The [source/RNG rules](internal-roadmap-0.2.4.md#source-identity-and-random-number-allocation)
and [precision allocation](internal-roadmap-0.2.4.md#condition-accounting-and-precision-decisions)
are specified; actual registries, source bridges and preflight remain pending.
The [static source audit](internal-roadmap-0.2.4.md#static-source-audit-and-reusable-units)
finds unchanged reviewed fitting code/binary and component-slope calculations
relative to the matched replay; it does not call for a blanket 400-case refit.
New location/scoring consumers and the prospective stopping policy still need
their own evidence. The 800 prepared core inputs and eight saved jobs remain
separate from new small-N or rubric conditions. The
[family allocation ledger](internal-roadmap-0.2.4.md#family-allocation-ledger-and-work-order)
now records the common A/B and expanded C/D/E working R=100 allocations.
The [expanded workload account](internal-roadmap-0.2.4.md#expanded-allocation-shared-controls-and-scheduling-priorities)
deduplicates D's A/B inputs and identical MML fits, retains saved historical
inputs/stages as source-specific reuse candidates, and includes the additional
A/B fixed-population fits. Priorities preserve complete small/large-N contrasts;
the full count is a planning burden, not an approved compute budget or precise
confirmation. Neither the old core runner nor a fresh confirmation is launched.
The [native location-interval specification](internal-roadmap-0.2.4.md#native-mml-location-interval-extension-specification)
now identifies the existing full-covariance/contrast machinery, missing public
admission and result dispatch, and the proposed local/finer-grid checks for
estimated-population RSM/PCM and one-family GPCM. Its first added scope is
experimental native model intervals. The ordinary analytic Person-score helper
does not include the new population/slope coordinates; sandwich support needs
the complete-score path and a sampling-law decision. Standardized contrast
intervals additionally need fitted-SD uncertainty and cross-covariances.
Retained independent information/constraint fixtures are assigned to numerical
verification, separately from sampling qualification. No code, public help,
NEWS claim or two-family interval rule changed during this specification work.

## Model and sources

For score k=0,...,K, the adjacent predictor is
`a_i * c_r * (theta_p - b_i - s_r - tau_rk)`. This is Uto and Ueno
(2020), equation 9, with D=1 and rater-owned steps. With a fixed standard-normal
population, sum(b_i)=0, sum(log(a_i))=0, and sum_k(tau_rk)=0 identify the
parameterization; c_r remain free positive parameters. Crossing/support and
sample boundaries still need separate assessment.

Sources reviewed: the supplied two derivations, the Uto--Ueno article's
response equation, the official Muraki publication record, the official
sirt help, and the installed sirt 4.2.133 functions `rm.facets`,
`rm_facets_est_a_item`, `rm_facets_est_a_rater`, and `rm_facets_calcprobs`.
This record does not assert a new page-by-page reading of Muraki's PDF.

- Muraki (1992), *A generalized partial credit model: Application of an EM
  algorithm*, Applied Psychological Measurement, 16, 159--176.
  <https://doi.org/10.1177/014662169201600206>
- Uto and Ueno (2020), *A generalized many-facet Rasch model and its Bayesian
  estimation using Hamiltonian Monte Carlo*.
  <https://doi.org/10.1007/s41237-020-00115-7>
- sirt `rm.facets` official documentation:
  <https://alexanderrobitzsch.github.io/sirt/reference/rm.facets.html>

sirt's model has category logit `a_i*a_r*k*theta - k*b_r - tau_ik`:
slopes scale ability, not every location/step term. Its default two GM1 slope
constraints accompany estimated population SD. The local implementation
updates slopes numerically and clips increments/ranges. These are useful
algorithm references, not an interchangeable response model, proof of global
optimization or joint observed-data uncertainty. No sirt source was copied.

## Implementation and checks

`R/core-gmfrm-em.R` adds two non-exported functions. They accept observed
Person/Task/Rater/Score rows, arbitrary numbers of task/rater levels >=2,
and a common contiguous score scale 0:K. Missing/unassigned rows are omitted
by the caller; supplied missing scores and repeated triples are rejected.
No anchors, weights, estimated population or dependent-response model is
implemented. Task-rater rank failure is rejected, but a full rank check is
not a complete global/boundary qualification. There is no finite slope box;
floating-point slope underflow/overflow is rejected, not interpreted as a fit.

The E-step uses all observed ratings of the same Person. Expected counts are
aggregated by task/rater cell, category and fixed quadrature node. The M-step
uses analytical gradients in unconstrained contrast/log-slope coordinates.
Numerical generalized-EM steps must increase Q and the same quadrature-based
marginal likelihood (roundoff allowance 1e-12 per Person). Stopping requires
a maximum marginal score <=1e-6 per Person. Every iteration records likelihood,
Q improvement, score, numerical M-step status and step halving. Standard
`optim()` and the existing package Gaussian quadrature are reused.

Focused tests independently check the literal adjacent-category equation,
finite-difference marginal and complete-data scores, Person-level integration,
row reordering, binary and five-category responses, all three unit-factor
reductions against existing PCM/GPCM likelihood kernels, invalid crossings,
floating-point slope limits, and iteration-limit semantics. Frozen-Q and
observed-data Hessians differ numerically; frozen-Q curvature is not an SE.

## Executed algorithm comparison

Seed 20260927: 240 standard-normal Persons, 3 tasks, 3 raters, scores 0:2,
fully crossed 2,160 observations. Both slope blocks are non-unit in generation.
For each quadrature, direct BFGS uses two independent starts, neither taken
from the EM solution. Both methods share the verified probability and score
kernel, so this is an optimization comparison, not independent software
estimator replication. Likelihoods were monotone throughout EM.

| Nodes | EM iterations | Max mean marginal score | Largest EM/direct parameter difference | Largest log-likelihood difference | Smallest observed-information eigenvalue |
| --- | --- | --- | --- | --- | --- |
| 31 | 43 | 9.87e-7 | 3.78e-6 | 1.13e-9 | 51.661 |
| 61 | 43 | 9.88e-7 | 3.79e-6 | 1.14e-9 | 51.671 |

31-to-61-node parameter change: 8.84e-5. This is reported separately from
optimizer agreement; sharing the quadrature does not verify integration.
The actual sirt probability kernel agrees to 2.00e-15 in the explicitly
matched zero-location/zero-step submodel with both slope families non-unit.
No free-estimator equivalence with sirt, TAM or ConQuest is claimed.

Reproduce from the package root:

```r
pkgload::load_all(compile = FALSE)
testthat::test_file("tests/testthat/test-gmfrm-em.R")
source("inst/validation/gmfrm-mml-em-20260927.R")
run_gmfrm_em_validation(tempfile("gmfrm-em-"))
```

The runner saves data, optimization traces, estimates, observed information
and summaries; when sirt is available, its version and overlap check are also
saved. The initial local result directory was `/tmp/mfrmr-gmfrm-em-20260927`.
This single generated example is not a sampling recovery, sparse-design,
coverage, performance-capacity or global maximum study. Public fit/output
integration, boundary qualification and inference remain roadmap milestones
G2--G4. The existing single-owner GPCM and corrected-JML development are unchanged.

## Literature refinement requested after the initial implementation

Primary sources:

- Wang, W.-C., & Liu, C.-Y. (2007). *Formulation and Application of the
  Generalized Multilevel Facets Model*. Educational and Psychological
  Measurement, 67(4), 583--605. <https://doi.org/10.1177/0013164406296974>
- Wang, Y.-G., Wu, J., & Qiu, X. (2025). *A Differential Index Measuring
  Rater's Capability in Educational Assessment*. arXiv:2502.09099v1.
  <https://arxiv.org/abs/2502.09099v1>. Treat the reviewed version as a preprint.

The 2007 local PDF was located at Zotero storage AD3BDJY2 (a duplicate of the
previously catalogued work). Text review covered model/estimation pp. 583--590,
applications/discussion pp. 594--599 and appendix pp. 599--602. Printed pages
585, 599, 600 and 602 were also visually inspected individually, including
the response equation and executable SAS settings. The 2025 PDF and HTML were
used for definition/model/estimation/simulation/limitations and appendices;
PDF pp. 5, 9, 10 and 18 were individually inspected visually. This is targeted
implementation review, not a claim of visual inspection of every page.

### Model and estimation implications

Wang--Liu equations 3, 5 and 6 use item slopes multiplying the whole adjacent
predictor, item-owned steps and conditional-normal latent regression. The
empirical objects are household appliances, illustrating why facet roles
must be explicit and domain-independent. Their appendix fixes the first slope
to one while estimating residual SD; it uses `METHOD=GAUSS`, `NOAD`,
`QPoints=25`, `TECHNIQUE=NEWRAP`. The general prose discusses adaptive
quadrature, but the printed example is explicitly nonadaptive. Neither a
25-point setting nor the appendix's probability cutoff is a universal accuracy
rule to copy. Current `population_formula`/`person_data` already support the
single-owner conditional-normal MML route. The new two-slope EM core does not.
Reuse that interface when extending the population rather than introducing a
second latent-regression API or treating estimated EAPs as error-free outcomes.

Their simulations use 50 binary and only 10 polytomous replications with
1,000 persons, not sparse-link qualification. The binary variance estimate is
reported as 1.851 versus truth 2.25; broad recovery language is not assurance
of negligible bias for all targets. Their Q3/PCA discussion is a useful
diagnostic direction, not a ready-made general acceptance threshold.

Wang--Wu--Qiu equation 12 instead has `rho_r*sigma*theta - delta_i - eta_r`
for binary ratings: no task slope block, no polytomous steps, and unscaled
location terms. This differs from both the 2007 and current Uto--Ueno kernels.
Its first simulation is fully crossed; its second includes incomplete and
unbalanced assignment. The authors themselves identify manipulated linkage
sets as remaining work. Their empirical four-category scores are dichotomized.
None of these results qualify a polytomous two-slope estimator or all sparse
designs. No author-code execution or SAS replication was performed here.

The Laplace log likelihood in equation 21 approximates the same marginal
integral and includes posterior-mode curvature. It is not ordinary JML and
does not justify replacing posterior integration by an EAP or mode alone.
For candidate structural parameters, the mode and curvature must be recomputed;
their dependence matters when differentiating the approximate objective.
The printed iteration uses mode SD and rescales rho to maximum one. A scale
re-expression that preserves effective slopes needs both
`rho_new = rho/max(rho)` and `sigma_new = sigma*max(rho)`; the printed Step 4
does not explicitly specify the latter. The paper's algorithm is not adopted
without a source-level/objective audit. No claim is made that unreviewed author
code necessarily omits that compensation. Bounding rho above by one does not
bound ratios when another rho approaches zero, or identify rho and sigma
without an additional scale convention.

### Feedback estimand and mathematical checks

The useful contribution is a curve describing response sensitivity at each
ability, optionally averaged over a stated target population. This is not
external criterion accuracy. For the package's category kernel and effective
slope A, direct differentiation gives

```
d P_k / d theta = A * (k - E[Y]) * P_k
d E[Y] / d theta = A * Var(Y)
I(theta) = sum_k (d P_k / d theta)^2 / P_k = A^2 * Var(Y)
```

Three added tests compare these identities with independent centered
probability differences in the actual two-slope kernel. Score sensitivity is
not information; the binary paper's proportionality factor also depends on
the response probability. Feedback should preserve the task/context and
reference population. If tasks are averaged, require an explicit common
weighting rule; if capability is normalized, define a common admissible
parameter set, denominator and score scale. Joint uncertainty must propagate
all parameters that enter the curve and normalization, including population
and both slope blocks, not only the rater's isolated variance.

Independent numerical checks identify points requiring correction before
reusing the preprint's formulas:

1. Appendix A writes `T'(z) = -z*T(z)` after dropping the x-weighted term.
   That term is generally nonzero away from z=0. At z=1, numerical integration
   of the full derivative and a central difference both give -0.05262143;
   the printed simplification gives -0.17794338. The claimed maximum at zero
   can still be established by symmetry/unimodality; this flags the displayed
   derivation, not a disproof of that maximum.
2. Appendix B's z derivative additionally needs the chain-rule factor:
   the full integrand multiplier is `-(x+z)/(rho*sigma)^2`. Its analogous
   dropped x-term is not zero either. Do not copy the displayed simplification.
3. The approximate GMF denominator is not exact normalization. For sigma=1,
   numerical integration gives Delta=0.20662096, versus 0.20412415 from the
   approximation. Dividing the exact numerator of the reference-best rater by
   the approximate denominator gives 1.012232; at sigma=3 it gives 1.077275.
   This mixed exact/approximate calculation diagnoses denominator error, not
   the output of the author's entirely approximate algorithm. At each ability,
   even the exact TFM kappa curve can reach 1.209945: its normalization concerns
   a population average, not a pointwise 0--1 bound. Do not clip such curves.
4. Printed equation 25 centers at the mean estimate, which defines dispersion
   rather than RMSE about truth. Tables contain values consistent with bias
   contributions, so the displayed formula alone does not establish a coding
   error. Recovery comparisons must recalculate RMSE from truth and raw runs.

Minimal reproduction of the first and third checks (executed locally):

```r
f <- function(x) plogis(x) * plogis(-x)
T <- function(z) integrate(function(x) f(x) * dnorm(x + z),
                          -Inf, Inf, rel.tol = 1e-12)$value
integrate(function(x) -(x + 1) * f(x) * dnorm(x + 1),
          -Inf, Inf, rel.tol = 1e-12)$value
(T(1 + 1e-5) - T(1 - 1e-5)) / 2e-5
-T(1)
T(0) / (.25 * sqrt(2 / 3))
.25 / T(0)
```

These findings refine roadmap G2/G3: reuse existing latent regression and
curve/report interfaces, verify a polytomous feedback definition before adding
a normalized index, and compare Laplace with the quadrature reference before
making it an available estimator option. No new public model/index or default
was introduced, and no sampling study or full package test was rerun.

## Shared probability kernel and conditional prediction integration

The next G2 increment removes the internal EM core's separate softmax
implementation. It now uses `mfrm_jml_probability_bundle()`, whose historical
name refers to a conditional response calculation, not an estimator choice.
That kernel retains full log probabilities on request as well as observed-category
log probabilities. Existing caches do not retain an extra full log-probability
matrix by default. `category_prob_gpcm()` also delegates to it, connecting existing
GPCM predictions and probability-based diagnostics to the same calculation.
R and compiled marginal evaluators remain separate verified integrations;
this change does not claim every likelihood backend is a single implementation.

The internal problem object gains a conditional-response evaluator for supplied
`Theta`, `Task` and `Rater` rows. It returns category probabilities/log
probabilities plus expected score, score variance, expected-score sensitivity
and information. Task slopes, rater slopes and their product are separately
labelled. `ObservedContext` identifies whether a task-rater crossing appeared
in training. New combinations of known levels are allowed under the additive
product-slope model and labelled unobserved; unknown levels are rejected.
This flag is not a precision or validity assessment. Ability is supplied,
not estimated by this evaluator. Score variance is response variation, not a
parameter SE; no interval or normalized capability index is produced.

Checks include equality between estimation/prediction at quadrature nodes,
an independent scalar calculation for a held-out task-rater crossing, row
order, owner labels, unknown/missing inputs and extreme conditional scores.
Finite log probabilities of -1000 survive probability underflow, and positive
binary information at theta=+/-40 agrees with an independent stable formula.
The focused GMFRM file passes 74 assertions. Existing separated-owner kernel
checks pass 4; after delegating public category probabilities, estimation-core
checks pass 295, category-variance checks 19 and separated-owner public
inference/curve/save workflow checks 43, with no failures or warnings.

Reusing the saved 240-Person data and estimates from the original algorithm
comparison gives exactly zero reported likelihood change at both 31 and 61
nodes. One 61-node EM refit checks the changed execution path: it converges in
43 iterations, differs by 2.84e-8 in parameters and 7.73e-12 in log likelihood.
No new data were generated and no full suite or repeated sampling study was
run. The initial independent equation/gradient tests remain in place, so
kernel sharing does not turn all comparisons into implementation self-checks.

Public `fit_mfrm()` still accepts one slope family. This completes the shared
conditional calculation and internal prediction part of G2, not public model
integration. Remaining work is the free-parameter/owner representation in the
common fit, readiness/inference decisions and result consumers, followed by
the corresponding prediction, plotting, reporting and persistence acceptance.

## G2: common parameter representation

The next increment connects the internal EM and conditional-response calculation
to `expand_params()` and adds a two-owner specification for the existing MML
evaluator. Separate component tables retain Task/Rater level labels and log
slopes; the likelihood consumes their effective product for each observed
crossing. Only task log slopes sum to zero. A sparse design stores observed
crossings rather than enumerating all possible task-rater combinations.
This does not qualify large-scale memory use or sparse-design inference.

Gradient projection uses the transpose of that design; parameter collapse uses
sparse QR and rejects effective slopes that cannot be represented by the fitted
product structure. Crossing indices require the original facet-level ordering
and an explicit specification. The internal prediction evaluator can still
combine known component levels in an unobserved crossing, labelled as before.
Single-owner parameters retain their existing expansion and projection.

The common fixed-quadrature likelihood and analytical gradients agree with
the EM expected-count calculation for binary, three-category and five-category
examples, including a missing task-rater crossing and permuted rows/factor
levels. Finite differences independently check the common gradients. Adaptive
integration now uses the same slope design and passes its own derivative check.
Its likelihood agrees with independent `integrate()` calculations of the
literal equation. On this small fixture, fixed 61-node integration differs by
about 1.6e-5 in total negative log likelihood; it is not treated as an exact
reference. Agreement at one fixed grid does not establish integration accuracy.

Reproduction, reusing the previously saved validation output:

```r
pkgload::load_all(compile = FALSE)
source("inst/validation/gmfrm-mml-em-20260927.R")
run_gmfrm_common_validation("/tmp/mfrmr-gmfrm-em-20260927/results.rds")
```

At saved 31/61-node estimates, common likelihood differences are zero, mean
score differences are at most 4.69e-16, and expand/collapse discrepancies are
at most 5.56e-17. One 61-node common direct fit from zero converges with maximum
mean score 5.98e-8, maximum parameter difference 3.80e-6 from saved EM, and
log-likelihood difference 1.14e-9. No new data or sampling study was generated.

Targeted checks pass: GMFRM 120 assertions, separated-owner kernels 4,
estimation core 295, and the separated-owner public fit/inference/curve/save
workflow 43. Code-usage checks pass. These establish numerical integration into
common parameter management, not completion of G2. Public `fit_mfrm()` still
rejects multiple slope owners. Public result consumers, readiness/identification
audits, joint uncertainty targets and save/replay must be adapted before that
restriction can be removed; no new public fitting option is added to NEWS/help.

## G2: owner-aware parameter maps and marginal diagnostics

The common optimizer parameter map now carries both slope owners, level names,
reference levels, constraints and optimizer positions. Task slope coordinates
use a sum-zero log constraint; every rater slope coordinate remains free. The
internal EM result retains this map and the nonlinear transformation audit.
The audit verifies the crossing-product Jacobian and its finite differences,
uses only the task-family invariant, and remains explicitly parameterization
only. It does not mark a converged EM result as identified or inference-ready.
Natural-coordinate derivatives scale rows directly, avoiding a square dense
diagonal matrix indexed by every observed task-rater crossing.

This map also enables the existing observed-Person score and exhaustive
response-pattern information diagnostics, and their existing local-rank
classifier, for the two-owner model. Exhaustive pattern enumeration is not
automatically added to the EM fitting loop; its existing execution limits and
fixed-quadrature scope remain. Observed-score deficiency alone remains
inconclusive, whereas full-pattern information can classify first-order
deficiency. No conditional-JML Jacobian is substituted for MML information.

A deterministic counterexample holds 16 task/rater rows fixed: two tasks by
two raters, with four repetitions of each crossing and binary scores. Only
Person assignment changes. At the same interior six-coordinate vector
`seq(-0.3, 0.4, length.out = 6)`, using 31 normal quadrature nodes:

| Assignment | Persons | Ratings per Person | Additive preflight rank | Full-pattern marginal score rank |
| --- | ---: | ---: | ---: | ---: |
| A different Person for every row | 16 | 1 | 3/3 | 4/6 |
| Each Person appears in all four crossings | 4 | 4 | 3/3 | 6/6 |

Both slope-factor designs have rank 3/3. Thus neither that rank nor the
additive preflight can stand in for the marginal-model check. In the first
assignment the binary likelihood depends on only four success probabilities,
so more independent Persons in the same single-rating design cannot identify
six free parameters. In the second assignment joint patterns supply additional
information. Local full rank at one vector under fixed quadrature is not
global identification, continuous-integral certification, sufficient finite-
sample precision or evidence of an interior optimum for the observed scores.

Pattern probability sums differ from one by at most 2.23e-16 in this check;
selected score finite differences agree within 2.61e-10. Tests additionally
check zero expected scores, observed-score reconstruction of the full gradient,
and the classifier's explicit limits. Wide rank-audit matrices are transposed
explicitly before QR, preserving the existing rank calculation without leaking
Matrix's internal transpose warning to users.

Reproduce through `tests/testthat/test-gmfrm-em.R`; the relevant existing
regressions are `test-estimability-audit.R` and
`test-nonlinear-local-estimability-classification.R`. They pass, along with
code-usage and whitespace checks. No new sampling experiment or full-suite run
was used. The user guide/NEWS explain the assignment issue without exposing
internal helper names. Public multi-owner fitting, joint uncertainty, result
consumers, plotting and portable calibration remain open. The common data
preparation currently requires at least 10 observed rows; that software minimum
does not qualify a design or its estimates.


## G2/G3: shared observed covariance and slope-product targets

The common `compute_mml_parameter_covariance()` and numerical Person-score
paths now pass the two-owner product specification to `build_indices()`.
Internal component and effective-product targets retain both owner labels and
full free-coordinate Jacobians, so all estimated nuisance parameters enter
through the inverse full observed marginal information. They do not use the
curvature of a frozen EM Q function. On the log scale,

`Var(log(a_task*a_rater)) = Var(log(a_task)) + Var(log(a_rater)) + 2*Cov(log(a_task),log(a_rater))`.

The new deterministic target test retains a nonzero cross-owner term and checks
both Jacobians against finite differences. A separate check compares the shared
Hessian against differentiated marginal scores and reconstructs their gradient
from Person scores. The full focused GMFRM file passes 192 assertions. Existing
single-owner/separated-step-owner inference, curves, results and save/replay
regressions pass 43 assertions. Code-usage, Rd and whitespace checks pass.

Reusing `/tmp/mfrmr-gmfrm-em-20260927/results.rds`, without refitting or generating
a new sample, the saved 61-node, 240-Person example gives:

| Check | Result |
| --- | ---: |
| Shared covariance status | ok, unregularized |
| Observed information rank | 13/13 |
| Maximum Hessian difference from saved marginal-score differentiation | 4.444978e-11 |
| Twice the task/rater log-slope cross-covariance across crossings | -0.0008043166 to 0.0012474725 |
| Effective log-slope marginal variance across crossings | 0.01547135 to 0.01840537 |
| Maximum error in the variance identity above | 2.656295e-18 |

The checked routes are reproducible in `test-gmfrm-em.R` and
`test-gpcm-separated-owner-workflow.R`. The saved-example calculation uses
`mfrm_gmfrm_problem(saved$data, 2L, gauss_hermite_normal(61L))`, its common
configuration with `estimation_control = list(quad_points=61L,
mml_integration="fixed")`, and `saved$fits[["61"]]$em$par`. The latter is passed
to the shared covariance helper and `mfrm_gpcm_product_slope_targets()`.
Multiplying each target Jacobian around the joint covariance gives the reported
log-scale covariances. The saved reference is `saved$fits[["61"]]$information`.

These checks establish a covariance calculation and internal target mapping,
not inference eligibility, sampling coverage, global identification or a public
multi-owner interval API. The targets currently require fixed-standard-normal
MML; public multi-owner fitting, interval qualification and consumers remain
open. In particular, the sampling covariance of estimated slopes is not a
multivariate G-study covariance component.

## Relationship to multivariate G theory: implementation and primary sources

Inspected the public `mfrm_multivariate_gstudy()`, `mfrm_multivariate_d_study()`
and `mfrm_multivariate_d_compare()` implementations and help. They operate on
observed numeric score components, not latent GPCM parameters. The first two
support one/two common random facets and the declared nested structures;
paired normal-theory plan-difference intervals support two crossed facets.
Incomplete-design MINQUE(0) does not repair informative missingness, and the
future D-study design must satisfy its separate balanced-design contract.
The `mfrm_generalizability(fit)` main-effects convenience route reuses ratings,
not latent parameter estimates. Neither is a joint GMFRM/G-theory estimator.

The existing mGENOVA Table 12 data (60 rows, V/W scores, 10 Persons, 6 tasks)
were reused for a public G-study followed by 3/6/12-task D-studies with the
prespecified difference W-V. All nine score/composite rows were available.
At six tasks the difference-score G/Phi were 0.3000000/0.2411605; the underlying
fixture and reference comparisons already live in
`tests/testthat/test-multivariate-gtheory.R`. This was a workflow smoke check,
not another sampling experiment or a full-suite rerun.

Primary literature review:

- Hirai, A., & Koizumi, R. (2013). *Validation of Empirically Derived Rating
  Scales for a Story Retelling Speaking Test*. Language Assessment Quarterly,
  10(4), 398-422. <https://doi.org/10.1080/15434303.2013.824973>.
  Local Zotero item H7P2ZUPE, PDF ALGRXKAR: inspected methods/results pp. 404-408,
  including the page image for p. 405. mGENOVA supplies **multivariate**
  criterion-level G/D analyses over stories; Facets supplies MFRM analyses.
  Raters are excluded from the G-study, double ratings are averaged for that
  analysis, and negative variance estimates are replaced by zero. Those
  choices must not be silently transferred to mfrmr or described as evidence
  for generalization to new raters. The paper establishes complementary use,
  not a joint two-slope GMFRM estimator.
- Jiang, Z., Raymond, M., Shi, D., & DiStefano, C. (2020). *Using a linear
  mixed-effect model framework to estimate multivariate generalizability
  theory parameters in R*. Behavior Research Methods, 52, 2383-2393.
  <https://doi.org/10.3758/s13428-020-01399-z>. Local PDF SM7KLBUJ: read the
  11-page text and rendered appendix code pages 2390-2391. Its score-component
  covariance framework helps distinguish mGT from multiple discrimination
  parameters. Its estimation framework/examples are not a validation of the
  package's distinct MINQUE(0) implementation, selective-missingness correction
  or automatic GPCM conversion.
- Briggs, D. C., & Wilson, M. (2007). *Generalizability in Item Response
  Modeling*. Journal of Educational Measurement, 44(2), 131-155.
  <https://doi.org/10.1111/j.1745-3984.2007.00031.x>. Read the introduction and
  theoretical setup from the author-institution full text, not the entire
  article. GIRM makes facet distribution assumptions and uses a distribution
  of expected-response matrices for a GT analysis; the illustrated design is
  binary with one measurement facet. This is precedent for integration,
  not direct qualification of the present polytomous, two-slope model.

The user guide and workflow help now distinguish these uses, preserve
score-weight versus slope and score-covariance versus sampling-covariance
meanings, and link the primary sources. ROADMAP orders immediate complementary
use before a future model-based planning or joint latent/random-facet model.
No generalization guarantee, new public model, or automatic filling of
unassigned ratings is introduced.


## Normal-population scale identity before SD stress qualification

The September 27 release-coherence review separates normal scale conversion
from population misspecification. Added a deterministic test with ability SD
0.5, 1 and 2 and means -0.6 and 0.4. For the original equation evaluated at
`theta = mu + sigma*z`, task slopes stay fixed, all free rater slopes multiply
by sigma, task locations and rater steps divide by sigma, and rater locations
become `(s_rater-mu)/sigma`. This preserves task GM1 and all sum-zero constraints.

An independent literal category recursion on the original scale agrees with
the common standardized kernel, and independent quadrature of complete Person
response patterns agrees with the marginal objective (tolerance 1e-12). The
focused GMFRM test file now passes 216 assertions, including 24 for these six
transformations. No estimator was refitted and no sampling data were generated
for this identity check. It qualifies neither estimated-population fitting nor
anchor support in the internal two-owner model.

ROADMAP now puts source/output coherence before new broad experiments. It
specifies sparse-link placement, fixed versus uncertain anchors, SD/shape/group
variation, dependence, covariance components, numerical stability and sampling
performance as distinct questions. The historical 147-fit PCM/JML anchor pilot
and 80-dataset separate-owner single-slope MML pilot are relevant but do not
qualify two-owner GMFRM. Planned stress conditions are not reported as executed.
The third proposed release pillar is actionable rater feedback and assessment
planning; the current RSM/PCM-only feedback-sheet restriction is an explicit
integration gap, not an implemented GPCM feature.


## G2: self-contained internal results and fresh-process replay

Internal EM results now retain plain model inputs (the four observed-rating
columns and their labels, category maximum, exact quadrature nodes/weights)
and solver controls including the start and marginal-score tolerance. They do
not serialize the problem's evaluation closures or caches. Posterior rows name
Persons, and columns name node indices corresponding to the retained rule.
This closes a source-of-replay ambiguity: coefficients and an EM trace alone
do not identify the observations or the numerical integration objective.

The fresh-process test saves a two-iteration result from seven-node quadrature,
with reordered rows/factor levels and one task-rater crossing absent. It loads
the result in a separate R process, reconstructs the problem using
`do.call(mfrm_gmfrm_problem, result$specification)`, and recomputes the saved
likelihood, posterior, marginal-score norm, parameters, parameter map, response
probabilities and component/product slope targets. Both fitting entry points
are mocked to fail if called. Every comparison passes, as does reconstruction
of a prediction for the known but unobserved crossing. Its `ObservedContext`
remains FALSE. The source's `converged = FALSE` and `iteration_limit` reason
remain unchanged; successful plotting/prediction reconstruction is not a
qualification of that fit.

The focused GMFRM test file passes 237 assertions, including 21 for this replay.
Code-usage and whitespace checks pass. No broad sampling or whole-package test
was added. New internal results carry the specification; older saved research
results are not retroactively assigned missing provenance. This is not the
public portable-calibration schema, a public two-owner fit, a new-Person scorer
or a new confidence-interval contract. The public single-owner restrictions
remain. The next G2 consumer work must preserve owner/level identity and the
different task-GM1 versus free-rater scale interpretation before exposing
existing one-owner reporting/inference routes to the new model.


## G2: common slope tables and owner-aware qualification mapping (2026-09-28)

The common `build_slope_table()` now represents product-model components as
separate rows identified by `SlopeOwner` and `SlopeFacet`. Existing single-owner
output columns remain unchanged. Product rows retain `ScaleReference` and
`Identification`, derived from the same metadata as the covariance targets:
the first family has geometric mean one; the second is free given that family
constraint and the fixed-standard-normal ability distribution. Effective
crossing slopes remain distinct targets rather than mislabeled component rows.

The common slope-readiness table, its application to estimates, and the update
from output-specific interval fields now match within each owner. They no
longer select a row solely by a potentially shared level name or borrow the
first owner's name for all rows. Matching avoids concatenated-key ambiguity;
duplicated levels within one owner and malformed readiness identities are
refused. Legacy single-owner slope tables without `SlopeOwner` remain supported.
A multi-owner table without owner labels is rejected rather than guessed.

Internal EM results retain the common slope table and slope-readiness rows.
Their numerical estimates remain available, but a certificate from the earlier
single-family boundary calculation cannot promote either product component.
Primary/interval qualification remains unevaluated. This plumbing change is
not a claim that product-slope intervals or public multi-owner fitting exist.
The result-class, curve, feedback and inference-consumer contracts remain open.

Tests deliberately give Task and Rater identical level labels containing a
colon, reorder result and qualification rows, distinguish their numerical
estimates, and verify that interval fields map to the correct owner while a
location row remains unchanged. They check duplicate/omitted owner information,
malformed identities, refusal to reuse a single-family certificate, and
preservation/reconstruction of the new tables through the saved-result path.

Focused checks: GMFRM 265, separated-owner single-family workflow 43,
GPCM uncertainty/readiness 88, and JML GPCM boundary 98 assertions pass, with
zero failures, warnings or skips. Code-usage and whitespace checks pass.
No whole-suite or sampling-study rerun was required. The guide/NEWS explain
why a free rater slope of one is not the average rater or a competence cutoff;
they do not advertise the internal table extension as a released fitting API.


## G2: configurable facet/person/score names (2026-09-28)

Removed hard-coded Task/Rater access from the two-owner EM problem, common
configuration, parameter unpacking and response calculation. Internal arguments
`slope_facets`, `person` and `score` now bind actual data columns. The first of
the two slope facets supplies centered locations and geometric-mean-one slopes;
the second supplies free locations/slopes and the centered category-step sets.
All effects still enter subtractively inside the product-slope predictor and
the population remains fixed N(0,1). Roles do not depend on domain words or
physical column order. Merely swapping the step owner is not claimed to be
an equivalent statistical model.

Structured parameter output uses `locations` and `slopes` lists keyed by the
original owners, plus `step_facet`. Response summaries retain original context
columns and explicitly identify the owners of `Slope1` and `Slope2`.
The common crossing specification and target metadata preserve non-syntactic
column names instead of silently applying `make.names()`. Required columns
must be distinct/nonempty; names reserved by common data or response columns
are explicitly refused. The exact column-role specification is saved alongside
the data and integration rule. Historical internal role-specific parameter
fields are not a public stable schema; the local verification runner and tests
now use the structured representation.

Focused equivalence tests use two levels for the first facet and three for the
second, with person/score columns renamed and physical column order reversed.
They cover Criterion/Assessor and Unicode/space/hyphen names (観点 名/Judge-ID).
Conditional predictions, marginal likelihood, analytical gradients, common
direct-MML evaluation and two numerical EM updates agree with the original
role-equivalent problem to 1e-12. Metadata and saved input mappings retain the
original names. A reversed Rater/Task declaration separately checks that
constraints and step ownership follow the declared roles and agrees with an
independent literal probability recursion; it is not compared as the same
model as the original Task/Rater declaration.

The fresh-process RDS test now also uses renamed, non-syntactic columns and a
missing crossing, preserving original owners and the unobserved-context flag
without fitting. Wrong arity, duplicate/empty/missing role names, reserved
facet names and overlapping person/score selections are rejected.

GMFRM checks pass 328 assertions; the unchanged public single-slope,
separate-step-owner workflow passes 43. Both have zero warnings, failures or
skips; code-usage and whitespace checks pass. No new broad simulation was
needed. The guide/NEWS distinguish names from model roles and continue to say
that public `fit_mfrm()` accepts only one slope family. This is internal
flexibility for two modeled measurement facets, not support for arbitrarily
many facets, a third step owner, or a released two-slope API.


## G2: shared conditional responses and curve uncertainty (2026-09-28)

The internal two-owner response and public one-owner curve interval API now
use the same conditional evaluator, retaining the common free-parameter
coordinates, facet signs, interactions, steps and stable log probabilities.
Prediction combines fitted component slopes at the requested levels; it does
not insert unobserved crossings into the estimation design or relax its rank
checks. Unknown levels remain errors. Known levels not observed together are
labelled separately from observed contexts, with integer-level keys to avoid
collisions between user labels. Context identity describes the retained design,
not local/global identification or confidence-interval reliability.

Focused tests compare full-coordinate probability/information derivatives
against an independent literal adjacent-category recursion, including an
unobserved crossing and non-syntactic Japanese facet names. A positive-definite
test covariance with cross-family entries verifies propagation of the full
joint covariance and demonstrates the difference from discarding its
cross-family entries. This is an algebraic propagation check, not an estimated
sampling covariance or a new coverage experiment. Existing likelihood-response
equivalence, extreme-ability stability and fresh-process replay checks pass.

Public curve results now save `contexts` (InputRow, ObservedContext) separately
from user facet columns, avoiding a new reserved facet name. Reports include
the context table; printing and default captions identify unobserved
combinations. Explicit caption=NULL still suppresses text; old saved objects
without the new component remain accepted. The unavailable-interval and
unobserved-context notes can coexist. Help and NEWS document these behaviors.

Targeted GMFRM, separate-owner workflow, inference-extension and reporting
checks pass; no full-suite or broad simulation rerun was needed. G2 remains
in progress: public two-owner dispatch, interval eligibility and remaining
consumers are not implemented by this refactor. G3 still requires statistical
qualification of separation, sparse designs and interval performance. A shared
curve evaluator must not be interpreted as a released two-owner interval API.


## G2: shared summaries and printed scale meanings (2026-09-28)

The common summary path previously pooled slope rows under the first owner's
name and described all GPCM slopes as geometric-mean-one relative slopes. It
now aggregates separately by the declared owners, using the existing
owner-plus-level matcher and metadata. The first family's within-facet
geometric reference remains distinct from the free second family on the fixed
standard-normal ability scale. Missing, duplicate or ownerless component rows
are refused rather than silently reassigned. Settings retain both owners.

The common scale contract and model identity now represent the product model.
Both print paths explain its different scale references in ordinary language;
internal identification codes are not printed. Shared summary follow-up text
does not suggest single-family intervals or plots for this model. Numerical
traces, primary estimates and interval eligibility remain separate. No
likelihood, optimizer, default or inferential admission rule was changed.

The internal EM result saves the shared slope overview and scale contract.
It remains an unclassed list. Tests exercise common consumers with an explicit
test payload; they do not demonstrate a public fitted two-family object.
Public dispatch, expanded summary profiles, prediction/diagnostic/plot/report
consumers and portable calibration still require their own integration. In
particular, summary-profile recommendations must be audited before public
dispatch is admitted. Public `fit_mfrm()` still accepts one slope family.

Focused checks use three levels in the first family and two in the second,
with known geometric means of one and four. They verify independent counts
and readiness, overlapping level labels with delimiters, Unicode facet names,
row reordering, missing identity refusal, unavailable inference, nonconvergence,
printed meanings and RDS restoration. An actual saved public single-family
fit produces an entire common summary identical to the pre-change function.

`test-gpcm-owner-summaries.R`, `test-gmfrm-em.R`, `test-output-stability.R` and
`test-gpcm-mml-identification.R` pass with no failures, warnings or skips.
The existing GMFRM checks include fresh-process reconstruction. No full-suite
or sampling-study rerun was needed; these checks establish output consistency,
not sampling coverage or general identification. Public summary help explains
the primary/optimizer distinction without advertising the internal extension
as a new fitting feature.


## G2: assembling actual EM results in the shared fit structure (2026-09-28)

The internal `mfrm_gmfrm_fit_result()` adapter now builds the existing
`mfrm_fit` tables and current readiness record from an actual EM result.
It uses shared preparation, design/category review, person-boundary handling,
slope qualification and summary builders. It checks the saved specification,
retained marginal likelihood and score-based convergence flag before assembly.
The total log likelihood and parameter count retain their meanings; EM's
average negative-log-likelihood objective is not mistaken for the total.
Posterior moments use the exact retained standard-normal Gauss-Hermite rule.
The adapter refuses other rules instead of mislabelling them as that method.

The numerical record identifies generalized EM, ascent-checked BFGS M steps,
completed EM iterations and the actual marginal-score tolerance per Person.
Unknown function/gradient evaluation counts remain missing. It does not reuse
the relative-likelihood stopping label from the RSM/PCM EM implementation.
The existing optimizer diagnostics support this explicit score criterion;
their previous default and relative-likelihood behavior are unchanged.

Passing the score criterion does not admit statistical inference. The two-owner
boundary reason is distinct from the one-owner reason, so the common decision
text no longer suggests one-owner `confint()` or PCM/GPCM comparison. The common
IC contract explicitly marks the product structure unsupported for ranking and
withholds its IC panel. Lightweight summaries are available; expanded diagnostic
and reporting profiles stop explicitly, and their unqualified Wright/Pathway
recommendations are not advertised as available or required.

Tests compare EAP and posterior SD with direct moments of the retained E-step,
check total likelihood/counts, owner names, real nonconvergence, saved trace,
current readiness and likelihood/specification mismatches. A deliberately loose
stopping tolerance tests that numerical convergence alone still grants neither
primary slopes nor inference/IC eligibility; it is not a successful estimation
example. The existing fresh-process test now also restores the assembled fit,
its summary and conditional responses without either fitter running, including
Unicode names and a known but unobserved crossing.

The owner-summary, GMFRM EM, output-stability and information-criterion test
files pass without failures, warnings or skips. After extending saved-fit
coverage, the fresh-process case was rerun on its own and passed; the existing
optimizer-diagnostic case also passed (including the old relative-likelihood
route). No broad sampling study or whole-suite rerun was needed.

This is an internal fit adapter, not a released two-owner constructor.
`fit_mfrm()` still refuses multiple slope facets. Opening that dispatch requires
explicit input/default validation and the remaining prediction, diagnostic,
plot/report, interval and portable-calibration consumers to be adapted or
specifically refused. The adapter's class is not evidence that those consumers
support the model. Public help/NEWS describe numerical-summary fields without
advertising a two-family fitting option.

## 2026-09-28: scoped public fitting, curves and saved reporting

`fit_mfrm()` now admits exactly two ordered slope owners under explicit
fixed-N(0,1) MML--EM, with the second owner supplying free locations/slopes
and centered steps. Its first owner retains centered locations and GM1 slopes.
The existing one-family defaults and fallback behavior remain unchanged.
`em_score_tol` controls the per-Person marginal-score criterion; unsupported
arguments are rejected instead of silently ignored. Missing scored rows,
duplicate person/context rows and inappropriate category recoding are refused.
Preserving an absent internal category reaches the existing category-support
error before fitting, rather than changing the response scale.

The public route returns the existing fit class. Summary, conditional
probability/information curves, existing ggplot methods, minimal saved results,
reports and export are connected. Literal product-equation checks verify the
curve probabilities and slope-squared conditional variance for information.
Tests retain Unicode/non-syntactic owners, shared labels, original column
roles, nonconvergence, exact public-call replay, known unobserved crossings,
missing intervals and report/export source values. Scope errors guard ordinary
diagnostics, parameter intervals, scoring, calibration, model comparison and
unadapted figures, including routes that read fit tables directly.

Reports use provisional-model guidance instead of recommending unavailable
ordinary diagnostics or a required Wright map. The reader-facing report starts
with model settings and fitted slopes; full numerical metadata remain saved.
Plots retain non-color line styles, removable text and unavailable-interval
markers. The exported curve PNG was visually inspected. A fresh R process
loaded the exported RDS via its replay script and reproduced curve values
exactly without fitting. This is saved-analysis replay, not portable scoring.

Targeted test files passed: `test-gmfrm-public-workflow.R`, `test-gmfrm-em.R`,
`test-gpcm-owner-summaries.R`, `test-gpcm-separated-owner-workflow.R`,
`test-gpcm-inference-reporting.R`, `test-output-stability.R`, and
`test-gpcm-capability-matrix.R`. The capability file retains three existing
CRAN-skipped report/design/screening cases; they were not run in this check.
The other listed files completed without warnings or skips. Focused tests were
rerun when report/export changes were made. New helper usage checks and
`git diff --check` passed. The six affected Rd topics were checked and the
scope vignette rendered with examples disabled; its new data-dependent example
is explicitly `eval=FALSE`. Public end-to-end behavior was exercised separately
by the targeted tests. No whole-suite check, broad simulation or external
software run was repeated.

This closes the minimal public fit/curve/report connection, not all of G2.
Joint-slope interval eligibility, global/boundary identification, sampling
qualification, ordinary diagnostics, model ranking, new-person scoring,
portable calibration and individual feedback remain unfinished. G3/G4,
corrected-JML milestones and integrated release checks remain open. Nothing
was committed, pushed or released by this local integration step.

## G2/G3: experimental component-slope intervals (2026-09-28)

The public two-family fit now supports `ci <- confint(fit)` for an explicitly
experimental log-Wald approximation to each component slope. No new exported
function was added. The default scale for this model is `standardized`, since
the ability SD is fixed at one; the first family retains geometric mean one
and the second is free. Explicit relative-scale, profile, sandwich and contrast
requests are rejected. Bonferroni can adjust across all requested component
slopes; no individual unit-slope p-values are provided. The two families have
different reference meanings, retained in the table, print output and default
plot caption. This does not add intervals for slope products, locations or
response curves.

For component log slopes with full-coordinate Jacobian J, the covariance is
`J solve(H) t(J)`, where H is the observed marginal information for all free
coordinates. It includes nuisance-parameter uncertainty and cross-family
covariance. It is neither the inverse slope block nor frozen-Q curvature. The
first family's sum-zero constraint gives an expected singularity in the
expanded target covariance, without making the free-coordinate information
singular.

Qualification reevaluates model/source identity, score-category support,
convergence, unregularized joint information and the retained likelihood.
Observed Person-score derivatives must have stable full column rank across
three relative SVD tolerances and two finite-difference steps. In a smooth,
positive-probability model, full rank of these selected outcome-probability
derivatives is sufficient evidence for local separation at the fitted point.
The check concerns the quadrature model. It does not establish global
identification; failure of this sufficient subset check alone does not prove
structural nonidentifiability. Fresh per-Person and curvature-scaled gradients
and the inverse residual are checked separately. Higher-order integration
reevaluates scores and information at the retained parameters, without refitting.

The original 240-Person dataset and 31-node solution were retained in
`tests/testthat/fixtures/gmfrm-joint-information.rds`, with an independently
differentiated marginal-information reference. The focused test constructs
the 6-by-13 component Jacobian independently and verifies the full covariance,
log-Wald bounds and cross-family term. Both families' names survive arbitrary
facet labels and overlapping level labels. Original primary estimates and
global inference/IC readiness remain unchanged.

| Numerical check on the retained 31-node solution | Result |
| --- | ---: |
| Free-coordinate observed score rank | 13/13 |
| Maximum mean marginal score | 9.87e-7 |
| Curvature-scaled gradient length | 4.75e-5 |
| Infinity-norm inverse residual | 1.83e-14 |
| Score displacement, 31 versus 61 nodes, standardized by original covariance | 0.001375 |
| Spectral covariance change, standardized by original information | 0.001276 |
| Available component-slope intervals | 6/6 |

The two quadrature-change tolerances are 0.01. These are documented numerical
safeguards, not thresholds calibrated for statistical coverage. Two focused
public-entry refits of this same dataset test the convergence/integration
distinction: the five-node fit converges, but its five-versus-nine-node score
displacement is 1.700458 and covariance change is 0.605363. It retains all
estimates but no bounds, with the failed check recorded. The 31-node public
fit passes. These examples do not establish that a fixed grid size always
suffices. A third focused refit with `em_score_tol = 1e-3` meets its requested
EM stopping rule but fails the fresh stationarity check for intervals. Its
measured score and curvature diagnostics remain available, while unperformed
quadrature checks stay missing. Nonconvergence, source mutation, likelihood
mismatch and insufficient information-workspace budget also have explicit
failure tests.

The existing print/plot/ggplot, plot-data, APA-table, results/report and export
routes reuse the saved result. They preserve owner/level identity, scale,
experimental cautions, check tables and unavailable outcomes. Saved plotting
and reporting were checked in a fresh R process with fitting and covariance
recomputation disabled. The default plot was inspected at 9 by 6 inches; names,
uncertainty, warnings and both scale references are readable. Users can still
remove titles, subtitles and captions explicitly.

Targeted files passed: `test-gmfrm-slope-intervals.R`,
`test-gmfrm-public-workflow.R`, `test-gpcm-owner-summaries.R`,
`test-gpcm-inference-reporting.R`, `test-gpcm-inference-extensions.R` and
`test-gpcm-capability-matrix.R`. The capability file's three pre-existing
CRAN-skipped cases were not run. Subsequent plot-metadata/caption changes were
checked with the two affected interval/reporting files. Help topics were
regenerated and checked, the scope guide rendered with examples disabled,
and the data-dependent workflow was exercised by tests. No full-suite run,
new sampling study or external-software comparison was performed.

G2 has gained an experimental uncertainty/output route; G3 statistical
qualification remains open. Local information, numerical stability and one
retained example do not establish bias, boundary behavior or interval coverage
across assignment designs. G4 and integrated release checks are also open.
This local work does not commit, push or release the package.

### Subsequent sparse-design check and numerical-warning repair

The [400-case sparse-allocation study](gmfrm-sparse-intervals-20260928.md)
now evaluates common-Person versus rotating-pair allocation at normal ability
SD 1/.5 with scale-transformed truths. It identified an overly strict 1e-4
standardized-score refusal. The current helper retains a warning above 1e-4
and refuses above 0.01, preserving all other checks and all parameter estimates.
The original study and revised-rule interval reanalysis are stored separately.

Revised availability is 11/100 for common SD=1, 100/100 for rotating SD=1,
100/100 for common SD=.5 and 99/100 for rotating SD=.5. The common SD=1 failures
are integration-sensitivity failures, not a demonstrated identification defect.
The study also finds residual log-slope bias and a 90/99 task-interval coverage
case with possible SE underestimation. These findings replace any inference
that the earlier one-example numerical check qualified sparse-design coverage.
See the linked record for denominators, Monte Carlo uncertainty, all components,
source preservation, regression tests and the next G3 decision.

The subsequent [matched quadrature follow-up](gmfrm-sparse-intervals-20260928.md#2026-09-28-matched-quadrature-follow-up)
replays all 100 common-Person SD=1 datasets at 61 points with unchanged EM
controls. All return intervals and pass their 61-versus-121 checks. The
existing quadrature-sensitivity API now retains these two-family comparisons
and interval objects. Sampling bias/SE discrepancies remain, including t3
coverage 90/100, so this resolves numerical availability without closing G3.

### Same-data posterior response diagnostics (2026-09-29)

The G2 output contract now admits `mfrm_response_diagnostics()` for the
converged, fixed-N(0,1), two-family MML--EM model. It uses the shared conditional
response evaluator and integrates over each Person's posterior given every
observed rating, with calibration fixed. Returned rows preserve the observed
assignment; selecting rows changes only display and aggregation. The variance
is that of the posterior predictive mixture, including variation of conditional
means. These descriptive Infit/Outfit summaries have no established
expectation-one reference, formal fit test or rater-quality threshold.

Verification reuses the retained 240-Person numerical fixture and a sparse
common-Person fixture. There was no new sampling study or repeated full package
check. Independently coded literal logits and continuous normal integrals agree
with probabilities and moments to a test tolerance of 1e-8. The checks
distinguish posterior integration from an EAP plug-in and mixture variance from
the mean conditional variance. They also cover ordered row subsets, arbitrary
Unicode owner names and overlapping level labels, incomplete assignments,
insufficient quadrature, stale calibration and nonconvergence. Failed rows stay
in group denominators with missing summaries; slope-interval unavailability
does not remove a valid point calculation.

The new test file `test-gmfrm-response-diagnostics.R` passes 84 assertions.
Related two-family public workflow, ordinary/extended response diagnostics and
comparisons, corrected-JML diagnostics, capability and plot-guide checks pass;
three pre-existing CRAN-gated capability tests were not run. Saved paired/scatter
plots, ggplot conversion, reports and CSV/RDS export/replay are checked with
fitting and probability integration disabled; a separate R process reopens the
saved report. Rendered paired/scatter figures were inspected. Help, NEWS,
vignette and roadmap now distinguish this target from ordinary fit diagnostics.

Response quadrature checks do not refit the calibration or repair its bias.
The existing quadrature-sensitivity route still addresses calibration grid
sensitivity. Formal fit diagnostics, Q3/PCA for this model, model comparison,
Wright/Pathway maps, later-Person scoring and portable calibration remain
separate unfinished output contracts. This increment does not close G2/G3.

## September 30: empirical practitioner workflow

**Question and purpose.** Can a practitioner take an actual writing-rating
table through assignment review, the two-family fit, numerical sensitivity,
descriptive diagnostics and a saved report without treating unavailable
outputs as usable rater feedback? The purpose is applied problem discovery
and end-to-end interpretation. Real data have no known generating truth and
cannot supply parameter recovery or confidence-interval coverage.

**Provenance.** `sirt::data.ratings1`, installed sirt 4.2.133, is documented as
a 2009 Austrian grade-8 German writing survey. All 274 supplied Person/rater
rows and all five criterion columns were converted to 1,370 long-form scores,
without deletion, imputation or invented criterion labels. The complete
original table, source/package versions, input hashes and session are retained
under `validation-results/gmfrm-practitioner-20260930/`. Data remain external
to the mfrmr distribution; no new dependency is required for package use.
The installed author help is the provenance source, also available in the
[author's package manual](https://alexanderrobitzsch.r-universe.dev/sirt/doc/manual.html#data.ratings).

All nine bundled mfrmr score datasets are synthetic. In particular, the legacy
`ej2021_*` datasets reflect published dimensions, not actual TestDaF responses,
and their unknown generation mechanism does not establish a recovery truth.
The existing generic task/assessor example and common-Person/rotating-pair
simulation had not completed this empirical practitioner check.

**Observed design.** There are 135 Persons, seven observed raters, five criteria
and scores 0–3. The rater factor contains nine additional unused levels; those
were retained in the source archive but not invented as observed raters.
Observed rater counts per Person are:

| Raters per Person | Persons | Observed criterion ratings |
| ---: | ---: | ---: |
| 1 | 89 | 445 |
| 2 | 27 | 270 |
| 6 | 2 | 60 |
| 7 | 17 | 595 |

Each rater sees 37–41 Persons. All rater pairs share 17–21 Persons; the
Person/rater network is connected. There are 29 observed roster patterns,
13 occurring for only one Person. All rater-level categories occur, but five
rater/criterion/category cells are empty. The 17 commonly rated Persons
contribute 595/1,370 ratings, about 43.4%. Equal-ish rater workloads therefore
do not mean equal information per Person or broadly distributed links.

The source table contains no NA scores, but the intended assignment roster is
not supplied. `describe_mfrm_data()` correctly retains `not_declared` for
structural missingness: 1,370 of 4,725 possible cells is not an estimated
missing-at-random rate. No absent combination is assigned a zero or a
missing-score mechanism. Common Persons are links, not fixed parameter anchors.

**Fixed procedure and result.** The runner
`gmfrm-practitioner-20260930.R` used the whole table: Criterion then Rater
slopes, rater-owned steps/free location, first-family GM1 constraint,
N(0,1), observed categories 0–3, unit weights, generalized EM, 500 outer
iterations and mean-score tolerance 1e-7. A 61-node fit and a single explicit
121-node sensitivity refit were declared before execution. Both converged;
the first used 180 outer iterations. Local elapsed times were 16.222 seconds
for the initial fit and 44.883 seconds for the complete quadrature review,
not a general speed claim. Fitting code was the local `4ba94470` checkpoint.

The 61-node NLL was 1177.111; the 121-node refit changed NLL per Person by
.0007644152, the largest slope coordinate by .2546042, and a fitted category
probability by .1697842 over the common [-4,4] grid. A saved-fit review confirms
the same maximum within [-2,2]; the finding is not confined to extreme tails.
It compares conditional fitted curves at chosen abilities, not out-of-sample
accuracy. Both returned interval objects retain all 12 components as
ineligible with missing bounds. An existing result object is not equivalent
to an available confidence interval. Neither fit is an empirical truth.

At the 61-node calibration, `mfrm_response_diagnostics(..., quad_points=121)`
checks response probabilities against 243 nodes. Results by observed exposure:

| Raters per Person | Attempted rows | Available rows | Largest probability integration discrepancy |
| ---: | ---: | ---: | ---: |
| 1 | 445 | 283 | .004415534 |
| 2 | 270 | 35 | .002956452 |
| 6 | 60 | 0 | .007247950 |
| 7 | 595 | 0 | .040124097 |

The unchanged tolerance is 1e-7. Total availability is 318/1,370, and every
criterion/rater group has incomplete rows, so all grouped Infit/Outfit values
remain missing. These are approximation failures at a retained calibration,
not observed evidence that those Persons or raters misfit. Concentrated
within-Person ratings plausibly challenge a fixed prior grid, but this
association does not establish a cause or rule out changed local solutions.
The full calibration, fixed-parameter integral and refitting effects must
be separated before changing an integration algorithm or recommended setting.

`mfrm_results()` and `mfrm_report()` retain fitted curves, missing component
intervals and all descriptive-diagnostic failures. The results/report RDS and
Markdown report were saved; reopening preserves every table and the exact
response-diagnostics attachment. No individual feedback sheet, competence
ranking, automatic model-selection decision or unsupported Person score was
manufactured. There was no broad simulation, full-package check or CI run.
The empirical example and explanation are now in the GPCM vignette/help/NEWS.

The executed runner is archived as `executed-runner.R`. Subsequent cleanup
moves its existing-file guard before any writes, and the reporting block was
executed separately from saved fits without re-estimation. Initial numerical
results and hashes are unchanged. The central-grid comparison and exposure
breakdown also reuse saved fits/diagnostics, and are retained in their CSVs.

**Second domain and evidence limits.** Zotero read-only search confirmed
Uto--Ueno (2020), key `IR3LFDRM`, and Uto (2021), key `38TX837G`.
The OSCE title search found no matching local item. The primary
[Uto et al. (2024) article](https://doi.org/10.1371/journal.pone.0309887) and
[Dryad description](https://doi.org/10.5061/dryad.tmpg4f56q) describe a small
medical-interview design with two common raters plus three subgroup raters.
Its item-specific steps and rater/item location interactions distinguish it
from the native two-family kernel. This was a targeted data/method-description
review, not a fresh full-PDF review or empirical replication. The public CSV
download returned HTTP 403, so its scores, coding and missingness were not
inspected and no OSCE fit was performed.

**Decision.** This empirical case adds a concrete integration/output obstacle
to D1/D2; passing the earlier synthetic recovery checks does not close it.
It does not establish that GMFRM is unsuitable for writing assessment or that
an equal-slope model is better. The authoritative roadmap now requires
question-led real-design simulation contrasts, matched simpler-model targets,
and explicit decision/output availability in addition to recovery/coverage.
Resolve this numerical obstacle and specify the retained practitioner claim
before a new independent coverage study; do not expand a full factor grid or
repeatedly increase quadrature until the output appears satisfactory.

The published data-preparation chunk was executed and its result is identical
to all 1,370 rows used for fitting. The guide renders to HTML; the generated
Rd parses and matches its roxygen source. The runner's early existing-case
guard was exercised: it refuses a duplicate run before writes, preserving
hashes of all retained files. These checks add no refit or simulation.

## September 30: consequential ranking in judged sport

**Question.** The user asks specifically about a decision as consequential as
selecting a sports champion. Before adding winner inference, determine what
the recorded scores and outcome represent and whether the current model and
uncertainty consumers can answer that question. This bounded audit addresses
that scope decision; it is not a latent re-ranking of named competitors.

**Primary data.** The [ISU Olympic 2026 women's event](https://results.isu.org/results/season2526/owg2026/)
links the short/free score PDFs, their separate judge rosters and final result.
`gmfrm-sport-decision-20260930.R` parses locally saved copies, preserves source
URLs/hashes and fails on unaccounted records or aggregation discrepancies.
Inputs and resulting `audit.rds`, component-mark CSV, final-total CSV and
session information are under `validation-results/gmfrm-sport-20260930/`.
These are external empirical records, not a new bundled package dataset.

There are 29 short-program and 24 free-skating performances, three component
marks per judge, and nine judges in each segment: 1,431 component marks in
total. Named panels contain 13 different judges and five shared judges; only
one slot keeps the same judge. Local `J1`--`J9` labels cannot be joined across
segments as identities. Five short-program participants do not reach the
final: their absent free-skating records are not uncollected assigned ratings.
The HTML roster labels all judges ISU, so it does not independently supply
judge nationalities for any national-bias analysis.

**Executed arithmetic checks.** All 159 component trimmed means, 53 factored
PCS totals, 53 segment totals and 24 final totals agree with the published
figures to floating-point tolerance (1e-10). The audit uses integer
quarter-points/hundredths for mean and per-component half-up rounding before
adding factored components. The first draft correctly failed: rounding only
after summation, or R's ties-to-even convention, misses some PCS totals.
The parser also had to preserve negative signed deductions. These were audit
implementation errors, not defects in mfrmr's estimator or the official data.
Published technical-element totals are retained; element-specific GOE/base
value conversion, tie resolution and the complete technical rule engine were
not independently reconstructed. The first page of each score PDF was
visually checked; all numeric records were parsed and reconciled. This is not
a claim of visually reading every page of the full Olympic results book.

Across the two segments, the first finisher's TES/PCS are 119.08/107.71 and
the second finisher's 112.91/111.99, both with zero deductions. Totals are
226.79 and 224.90, a difference of 1.89. PCS ordering differs from total
ordering because their targets differ. Neither ordering establishes a latent
truth or gives a calibrated probability of a different future outcome.

**Mathematical/API consequence.** Athlete, segment, component and actual
judge are distinct roles. Integer PCS coding preserves 40 categories; it
does not remove empty cells, selected-population assumptions or within-
performance dependence. Pooling those marks with GOE and difficulty points,
dropping the segment, or treating repeated performances as independent
athletes would change the model. The two-family route admits exactly two
non-Person facets and supplies neither Person scoring nor athlete-rank
inference. Component-slope intervals are not athlete intervals. Existing
one-family EAP conditions on calibration; its marginal intervals do not
account for selecting the highest estimate among many. Linear observed-score
G/D composites do not reproduce trimming, and G is not a winner probability.

**Literature review limits.** Looney (1997), *Objective measurement of figure
skating performance*, Journal of Outcome Measurement 1(2), 143--163,
[PMID 9661718](https://pubmed.ncbi.nlm.nih.gov/9661718/), was checked through its
primary abstract: it analyzes the 1994 event and its historical median-rank
system, not today's scoring or this implementation. Mercier and Heiniger's
[2019 v3 paper](https://arxiv.org/abs/1807.10021) was reviewed selectively in
Sections III, VI and VIII (rank-method pages 9--10 also visually inspected).
It treats performance-dependent judging variability, imperfect control-score
proxies and limitations of rank-based judge assessment. It is neither a
GMFRM-equivalence study nor grounds to equate podium sensitivity with judge
incompetence. No fresh full-paper or Zotero-library audit is claimed.

**Disposition.** Public GPCM guidance now distinguishes official, latent and
future-performance targets with the empirical example. GPCM and multivariate
D-study help state the missing rank-inference scope. The internal roadmap
requires explicit selection loss, false confident decisions, candidate-set
coverage/size, unavailable outcomes, gap/tie contrasts and the appropriate
repeated competition unit before admitting a winner claim. No new model,
winner-probability API, simulation grid or estimator refit was introduced.
The empirical writing integration issue and corrected-JML centering issue
remain the mathematical priorities; this sport audit does not close them.

**Verification.** The final runner also passed in an isolated copy of the
five source files; its parsed ratings, checks and totals are identical to the
retained audit. A repeated call in the original directory refuses to overwrite
the saved result, with unchanged hashes. Both updated Rd pages parse, the
vignette renders to HTML, and the new section/table is present. Parsed R
expressions in the two edited package source files match HEAD: changes there
are documentation only. No full test suite, estimator simulation or refit was
needed for these changes.

## September 30: general-purpose fixed-calibration integration review

The user clarified that general APIs take priority over domain-specific
operational workflows. The empirical case therefore supplies a numerical
counterexample, not a requirement for another writing/sport product. Reuse
the existing integration machinery to separate integration error from fitted
parameter differences, without running another calibration or simulation.

**Mathematics.** At fixed positive component slopes, let `a_j` be their
product for an observed crossing. With the existing whole-predictor GPCM,
unit weights and N(0,1) ability distribution, the conditional log-posterior
score is `sum_j a_j * (y_ij - E[Y_ij | theta]) - theta`. Its negative second
derivative is `1 + sum_j a_j^2 * Var(Y_ij | theta)`, which is strictly positive.
Thus the existing scalar mode/curvature kernel applies directly to two
families once indices refer to their observed crossings. Under
`theta = mode + scale*z`, the GH sum retains the original normal density
through its density ratio and Jacobian; changing the integration coordinates
does not replace the prior with a fitted posterior. A unique conditional
posterior mode is not a unique marginal-likelihood calibration optimum.

**Executed independent check.** `gmfrm-fixed-integration-20260930.R` reuses
the original `quadrature-review.rds` containing the 61- and 121-node writing
fits. It compares fixed and adaptive 15/31/61-node integrals at unchanged
parameters, then independently evaluates literal category logits using
`stats::integrate()` over the real line for every one of the 135 Persons.
Density rescaling avoids underflow; mode and local scale only change the
continuous integral's coordinates. The reference uses neither the package
probability kernel nor its GH rules. All integration calls report `OK`.

| Saved calibration | Original fixed-grid NLL | Continuous-integral NLL | Maximum fixed log-integral error per Person | Maximum adaptive-61 log-integral error | Maximum adaptive-61 mean / SD error |
| --- | ---: | ---: | ---: | ---: | ---: |
| 61 nodes | 1177.111430 | 1178.139807 | .3893272 | 1.425e-8 | 2.336e-8 / 2.301e-8 |
| 121 nodes | 1177.214627 | 1177.662750 | .0921765 | 1.656e-8 | 5.599e-8 / 7.503e-8 |

The ordering of the two calibrations by NLL reverses under common accurate
integration. Maximum fixed-grid mean/SD errors are .072652/.084100 at the
61-node calibration and .026744/.034384 at the 121-node calibration. Neither
comparison reoptimizes parameters. These findings establish a numerical
approximation problem in this case; they do not identify the accurate
optimum, rule out local solutions or qualify interval coverage. Adaptive
31-to-61 log-integral changes reach 8.45e-6, so order agreement itself should
remain reported rather than interpreted as an exact-error certificate.
This complete diagnostic took 9.386 seconds locally; no runtime or accuracy
guarantee follows for arbitrary datasets.

**Public integration.** The existing `mml_quadrature_sensitivity()` and GPCM
alias now pass `gpcm_spec` to `build_indices()` for the optional adaptive
review instead of rejecting two families. The same kernel, existing output
class, summary/print and RDS path are retained. No new public function or
estimation algorithm is introduced. `summary` still has unavailable
two-family Person-score comparisons; posterior moments in the separately
labelled `quadrature_review` are fixed-calibration diagnostics. Fixed-grid
EM, reported estimates, component-interval checks and readiness are unchanged.
The actual capability table, help, NEWS and guide describe this distinction.

The next numerical decision concerns calibration against accurately
integrated likelihood, including the optimization/derivative contract. This
change does not silently turn the fixed-node generalized EM into an adaptive
EM, certify Person scoring, or close the corrected-JML centering question.

**Verification.** The scoped GMFRM quadrature tests and existing RSM/PCM
quadrature tests pass. The GMFRM tests include literal continuous integrals,
arbitrary owner labels with overlapping level names, an absent facet crossing,
unchanged source likelihoods, saved review tables and continuing rejection of
adaptive EM/Person scoring. Help generation and Rd parsing succeed, the actual
capability table contains the new scope, and the guide renders to HTML. The
initial test failures concerned expected console/error wording and were
corrected before the passing run; numerical-reference assertions passed.
No whole-package test or independent coverage simulation was repeated.

## September 30: adaptive two-family calibration

**Question and scope.** Can the existing adaptive likelihood and gradient
estimate the same two-family model accurately, after the fixed-grid error
identified above? The user prioritized a general-purpose API, not additional
domain-specific features. The response equation, two ordered slope owners,
fixed N(0,1), unit weights and absence of anchors remain unchanged. This is
MML with direct optimization; it is not a moving-node EM algorithm.

**Derivative and fitting procedure.** The shared evaluator differentiates the
finite adaptive GH sum, including posterior-mode, local-width and Jacobian
derivatives. Independent Richardson differences of the diagnostic objective
agree within 1e-6 for binary and four-category responses, incomplete crossings,
non-default owner labels and orders 1/3/15. Low-order checks expose omitted
moving-node terms. No alternate derivative or likelihood kernel was added.

`gmfrm-adaptive-calibration-20260930.R` uses the retained 135-Person,
1,370-rating empirical data. Two adaptive-order-31 fits start from the saved
fixed-order-61/121 EM fits. A third fit uses the public API's neutral start
and adaptive order 61. All use the existing BFGS direct optimizer, maxit 500,
reltol 1e-10 and its existing gradient checks/polishing. There is no wall-time
cap, newly simulated dataset or exclusion of unsuccessful runs. The two
initial scripts, their hashes, completed fit objects, independent integration
results and session information are retained in
`validation-results/gmfrm-adaptive-calibration-20260930/`; reruns load completed
fits rather than overwrite/refit them.

| Starting values | Adaptive fitting order | Fitted NLL | Literal continuous NLL | Maximum free-coordinate difference from neutral-start fit | Fitting seconds |
| --- | ---: | ---: | ---: | ---: | ---: |
| Saved 61-node EM | 31 | 1177.482530 | 1177.482535 | 2.54e-6 | 35.234 |
| Saved 121-node EM | 31 | 1177.482530 | 1177.482535 | 3.65e-6 | 51.155 |
| Public neutral start | 61 | 1177.482535 | 1177.482535 | 0 | 77.597 |

At every retained solution, all 135 continuous integrations return `OK`.
The reference uses literal category logits and `stats::integrate()` over the
real line, independently of the package probability kernel and GH rules.
Maximum per-Person log-integral discrepancies across the three solutions are
8.37e-6 (adaptive 31), 2.31e-8 (61), and 1.52e-11 (121). The total-gradient
61-to-121 difference is at most 6.95e-7. The public fit's largest per-Person
score at order 121 is 5.34e-7. Its local full marginal Hessian at order 61 has
eigenvalues 7.846 to 830.402 and curvature-scaled gradient length 2.47e-5.
These support a numerically stable local solution in this case; they establish
neither a unique global solution, absence of boundaries, sampling coverage nor
correctness of the empirical response model. Timing is descriptive only.

**API and output integration.** `fit_mfrm()` accepts the explicit combination
`mml_engine = "direct", mml_integration = "adaptive"` for the same two-family
model. It reuses the direct optimizer and common fit assembly; fixed-grid EM
is unchanged. Adaptive direct MML uses `reltol`, and fixed-grid EM uses
`em_score_tol`; supplying the other engine's tolerance is rejected. Saved
metadata, replay, `summary()`/`print()`, conditional curves, result reports and
quadrature-order refits retain the actual engine and integration method.
Reports no longer describe a direct fit as EM or claim numerical success on
optimizer code alone. The shared fit class and public function names remain.

Adaptive two-family Wald bounds remain unavailable with a specific reason;
profile requests and posterior residual diagnostics reject this unsupported
scope. No fixed-grid covariance is relabelled as adaptive. New-Person scoring,
model ranking and ordinary fit/bias outputs remain unsupported. The next
mathematical decision is adaptive observed-information/integration qualification
and corresponding interval/residual contracts, before replaying the existing
coverage/design scenarios. Corrected-JML centering is a separate open issue.

**Verification.** The two new adaptive gradient/workflow files and existing
GMFRM public workflow, EM, quadrature-sensitivity, component-interval and GPCM
capability files pass. The capability file retains three `On CRAN` skips for
unrelated one-family reporting/design/signal-detection scenarios; those were
not rerun. New checks include saved-data likelihood identity, distinct fixed
and adaptive integrals, arbitrary owner names, unavailable profile/residual/
Person-scoring routes, conditional ggplot objects, output wording, tolerance
validation, RDS/replay and integration-preserving refits. Initial failures
were outdated error-message expectations and an expectation of missing profile
bounds where the existing profile contract correctly raises an error; no
numerical-reference assertion failed. Help generation, five changed Rd parses
and HTML guide rendering succeed. No whole-package suite, CRAN check or fresh
coverage simulation was run.

## September 30: adaptive observed information and component intervals

**Question and decision.** Can the adaptive two-family calibration use the
existing full-information log-Wald procedure without substituting fixed-node
curvature? The answer is yes for the explicitly experimental local calculation,
subject to the source-specific numerical checks below. Sampling coverage is
still unqualified; no new response sample was generated and no model was refit.
Adaptive constrained profiles and posterior residuals remain unavailable.

**Mathematical target.** Let U_i(theta) be the complete-response score in all
free calibration coordinates, and J_i(theta) its negative derivative. The
continuous observed information for Person i is
E[J_i(theta) | y_i] - Var[U_i(theta) | y_i]. This missing-information identity
is the method described by [Louis (1982)](https://doi.org/10.1111/j.2517-6161.1982.tb01203.x).
The independent reference assembles literal category logits, their first and
second derivatives, and these conditional moments. It calls no package response,
parameter-expansion, score or Hessian kernel. It includes the mixed derivatives
between locations/steps and log slopes, and the second derivatives of the
exponential slopes. Omitting these terms or treating nuisance calibration as
known would change the information target.

The production covariance reuses `compute_mml_parameter_covariance()` and the
existing moving-node gradient. It differentiates the finite adaptive likelihood,
including mode, scale and Jacobian changes. The independent Louis oracle at
high order approximates the continuous information. These need not coincide at
low order; the low-order moving-node gradient has its separate Richardson
checks. The oracle uses the shared integration coordinates/rule, so it is an
independent response/derivative/information implementation, not a wholly
independent quadrature algorithm. The previous all-Person continuous integral
checks remain the independent integration evidence.

**Fixed numerical procedure.** No fitting defaults, automatic retries or
acceptance thresholds change. Adaptive direct fits must pass their optimizer
and gradient convergence checks, and then the existing category, source-identity,
unregularized full-information and two-step Person-score rank checks. The fresh
maximum mean score is at most 1e-6; standardized Newton displacement is at most
.01 (with the existing caution above 1e-4); inverse residual is at most 1e-6.
At unchanged parameters, the fitted adaptive order q is compared with 2q-1.
Standardized score displacement and covariance change must each be at most .01.
Failures retain point estimates, missing bounds and reasons. The fixed-grid EM
route and its min(em_score_tol, 1e-6) requirement remain unchanged. Neither
method switches integration or refits automatically during `confint()`.

**Retained-data result.** `gmfrm-adaptive-information-20260930.R` reuses the
public adaptive-61 fit from the preceding section: 135 Persons, 1,370 ratings,
36 free coordinates and 12 component slopes. The prespecified oracle discrepancy
limits were 1e-4 for standardized information/covariance, 1e-5 for individual
scores and 1e-6 for total NLL. All were met:

| Quantity | Result |
| --- | ---: |
| Smallest independent observed-information eigenvalue | 7.845930 |
| Standardized information discrepancy, adaptive 61 / 121 | 2.9325e-6 / 2.9298e-6 |
| Standardized covariance discrepancy, adaptive 61 | 2.9325e-6 |
| Maximum Person-score discrepancy | 9.4680e-10 |
| Adaptive-61 versus reference total NLL difference | 2.0008e-8 |
| Local score rank / free dimension | 36 / 36 |
| Standardized Newton displacement | 2.4722e-5 |
| Adaptive 61-to-121 standardized score displacement | 8.3116e-8 |
| Adaptive 61-to-121 standardized covariance change | 3.1574e-7 |
| Available experimental component intervals | 12 / 12 |

The audit took 149.302 seconds in the recorded local environment. Its script,
input/source hashes, independent matrices, scores, numerical checks, result
object and session information are retained in
`validation-results/gmfrm-adaptive-information-20260930/`. Every requested
component is reported. This empirical result does not establish sampling bias,
coverage, a unique global solution or suitability for rater feedback.

**Output and scope.** `confint(fit)` and integration-order refits now retain
adaptive log-Wald intervals, owner/level identity and engine/integration metadata
through tables, plots, reports and saved exports. Round-trip intervals and
report text are identical. The profile entry point explicitly refuses adaptive
two-family fits before entering the fixed-grid constrained evaluator. Curves
remain without intervals, and ordinary diagnostics, model ranking and portable
two-family scoring are unchanged. README, capability/help, guide, NEWS and the
active plans describe the same scope.

**Verification.** The seven targeted files (adaptive gradient/workflow, existing
GMFRM public workflow, quadrature sensitivity, slope intervals, capability matrix
and fixed-grid joint profiles) pass 585 assertions without failures or skips.
They include binary/four-category information references, renamed/overlapping
owner levels, nonconvergence, mismatched likelihood rejection, a converged
adaptive-3 fit rejected by the quadrature check, cross-family covariance and
plot/export/reopen identity. The initial run had one test-only failure: it
assumed the shared label sorted first in both renamed facets. The corrected
assertion matches the owner and level rather than their row positions.
No production calculation or tolerance was changed to pass that assertion.
The logs and per-file results are retained beside the audit.

`devtools::document()` completed; the six changed Rd files parse and the GPCM
guide renders to HTML in CRAN mode. This rendering is not fresh execution of
its long statistical examples. `git diff --check` passes. Unaffected G/D, MI,
feedback and JML studies were read and reused, not rerun. No full package check,
independent coverage study, remote CI, commit or publication was performed.

## September 30: adaptive posterior residuals

**Question and implemented target.** Can a saved adaptive two-family fit
describe its observed ratings without reverting to fixed-grid integration or
an EAP plug-in? `mfrm_response_diagnostics()` now integrates a replicate rating's
category probability over the Person's complete same-data ability posterior,
with calibration fixed. The response equation, both slope owners, original
N(0,1) population and observed assignment are retained. Selecting output rows
changes the displayed/summarized set, not the conditioning record or posterior
grid. It neither adds unassigned ratings nor supplies held-out predictions.

**Procedure and failures.** Source reconstruction checks the original roster,
categories, facet/step/slope point estimates, model roles and integration
settings. Adaptive source likelihood and gradient are freshly evaluated using
the fitting objective and checked against the saved optimizer tolerance;
stored convergence flags alone cannot admit a stale source. This check does
not require a covariance or slope interval. Saved-result attachment validates
identity without repeating the source likelihood or any posterior integral.

The existing adaptive basis supplies mode/curvature nodes with prior density
ratio and Jacobian weights. The existing response evaluator supplies both
slope components. For q requested points, compare each category probability
with 2q+1 points, retain the higher-order result, and require maximum absolute
change at most 1e-7. The existing normalization, positive-variance and missing
result checks remain unchanged. Mixture variance includes both expected
conditional rating variance and variance of conditional means. A group with
an unavailable observed row retains its full denominator and missing indices.
No threshold was relaxed and no automatic order escalation/refit was added.

**Independent all-row check.** `gmfrm-adaptive-residuals-20260930.R` reused
`public-adaptive61.rds` from the calibration review: 135 Persons, 1,370 ratings
and four categories. The prespecified orders were 7, 61 and 121; no data were
simulated and no calibration was refit. The generalized continuous reference
in `helper-gmfrm-response.R` constructs literal logits from labelled saved
estimates, independently solves for the posterior mode/scale, and integrates
over the real line with `stats::integrate()`. It calls no package probability,
mode, parameter-expansion or GH function. All 135 Person references and all
1,370 rows were retained, including those failing the public order check.

| Requested / check order | Available ratings / 1,370 | Complete criterion/rater groups / 12 | Maximum probability error among returned rows | Maximum mean / mixture-variance error among returned rows |
| --- | ---: | ---: | ---: | ---: |
| Adaptive 7 / 15 | 205 | 0 | 4.2742e-9 | 4.2702e-9 / 4.0079e-9 |
| Adaptive 61 / 123 | 1,369 | 10 | 2.9824e-11 | 2.9790e-11 / 2.7205e-11 |
| Adaptive 121 / 243 | 1,370 | 12 | 9.8603e-14 | 2.9555e-13 / 4.1262e-13 |

Every returned-row error meets the prespecified 1e-8 reference criterion.
The 61-point unresolved row has an integration difference 2.6653e-7 and remains
unavailable; it was not silently repaired in that saved output. The maximum
121-to-243 difference is 1.3146e-10. At the finest order all rows are returned,
so its reported maximum includes the entire requested roster. These are
numerical checks on a retained case, not a universal integration-error bound.

**Separate integration from calibration.** At exactly the same adaptive-fit
parameters, a numerical fixed-grid 121/243 comparison passes only 251/1,370
rows. The 243-point probabilities differ from the continuous reference by as
much as .003544; the largest 121-to-243 change is .047080. The numerical input
selects a fixed grid for this comparison; no fitted object is relabelled or
admitted through a different public source check. The earlier 318/1,370 result
used a different, fixed-EM calibration and remains separate evidence.

| Raters per Person | Ratings | Adaptive 61 available | Adaptive 121 available | Fixed 121/243 passing, same calibration |
| ---: | ---: | ---: | ---: | ---: |
| 1 | 445 | 445 | 445 | 237 |
| 2 | 270 | 269 | 270 | 14 |
| 6 | 60 | 60 | 60 | 0 |
| 7 | 595 | 595 | 595 | 0 |

This addresses the retained concentrated-posterior integration failure, while
preserving the low-order limitation. It does not test conditional independence,
population assumptions, rater competence, interval coverage or the effect of
giving feedback. These remain descriptive same-data residuals without an
expectation-one reference, fit cutoffs, p-values or calibration uncertainty.

**Workflow verification.** Adaptive workflow, fixed-grid GMFRM response,
corrected-JML response and ordinary/extended response regression files pass
(315 successful expectations). The public two-family workflow and capability
matrix files also pass (328 successful expectations): 643 across six files.
The two shared-rater RTMB tests skip because RTMB is unavailable in this R
library; their unchanged numerical branches are not newly qualified here.
Checks cover owner names with shared labels, exact source identity, altered
likelihood/parameters/gradient tolerance, selected-row invariance, independent
mixture moments, incomplete availability, both plot styles, ggplot conversion
and exported saved results. In a fresh R process, both the partial 61-point
and complete 121-point empirical results reconstruct their original rows,
groups, settings, plots and reports with fitting/gradient/integration functions
replaced by errors. No numerical recomputation occurs during replay.

`devtools::document()` completed, the seven cumulatively changed Rd files parse,
and the updated GPCM guide renders to HTML in CRAN mode. This does not rerun
its long statistical examples. `git diff --check` passes. The final test logs
and reviewed-source hashes accompany the numerical evidence.

The all-row audit took 129.306 seconds locally. Evidence, all Person references,
source/input hashes, exact executed R-source snapshots, partial/complete
diagnostics, saved results and fresh-process checks are in
`validation-results/gmfrm-adaptive-residuals-20260930/`. Later help-only edits
are distinguished from the hash-matched executed source. Existing evidence
was reused; no whole-package check, new sampling study or publication occurred.

## September 30: adaptive interval procedure feasibility

**Decision addressed.** Is the public neutral-start adaptive procedure ready
for a matched all-case replay and then independent coverage evaluation?
No: the bounded check found a poor flat solution which is not explained by
quadrature error. The current plan specifies the targets, all numerical gates,
starting values, existing optimizer polishing, conditional 31/61/121 refits,
failure denominators, Monte Carlo precision and consumer boundaries. That
protocol was saved before this run. No new response data were generated.

`gmfrm-adaptive-procedure-20260930.R` used the first two retained replicates in
each of the four September 28 design/SD conditions and the prespecified
near-zero-slope rotating-pair SD=.5 replicate 26. All calls used the public
neutral-start BFGS adaptive fit at order 31, maxit 500 per optimizer stage,
reltol 1e-10, and all-component model-based 95% intervals. Only a sole
quadrature-sensitivity failure could trigger the next order; no such failure
occurred. Numerical checks and public defaults were not changed to admit cases.

| Retained condition | Cases | Converged by raw-gradient check | Cases returning all nine intervals | Final refusal |
| --- | ---: | ---: | ---: | --- |
| Common Persons, SD=1 | 2 | 2 | 2 | None |
| Rotating pairs, SD=1 | 2 | 2 | 2 | None |
| Common Persons, SD=.5 | 2 | 2 | 2 | None |
| Rotating pairs, SD=.5, first two replicates | 2 | 2 | 1 | Replicate 1: joint information |
| Rotating pairs, SD=.5, prespecified replicate 26 | 1 | 1 | 0 | Joint information |

All seven returned sets pass the unchanged rank, stationarity, information and
31-versus-61 gates. Maximum standardized Newton displacement is 2.58e-5,
maximum quadrature score shift 7.42e-9 and covariance change 2.56e-8.
The two refused fits needed regularized near-singular information and retained
missing intervals. Every point, warning, optimizer stage and failure remains
saved; no case is replaced. Seven of nine is a feasibility disposition, not
an estimate of population availability from a representative random sample.

**Counterexample to the neutral-only procedure.** Replicate 1's adaptive
solution has component slopes from 3.14e-11 to 7.47e7. Compare the two saved
parameter vectors using the *same* adaptive objective and a literal continuous
integral over each complete Person record:

| Saved point | Continuous NLL | Adaptive-61 NLL | Maximum per-Person log-integral error |
| --- | ---: | ---: | ---: |
| Adaptive neutral start | 1558.971231708 | 1558.971231708 | 1.78e-15 |
| Retained fixed-grid EM parameters | 1471.593412080 | 1471.593412080 | 1.78e-15 |

The gap is 87.37782 NLL units in favor of a feasible retained point. The latter
row evaluates its parameters with accurate integration; it does not compare
two unmatched saved quadrature likelihoods or establish a global optimum.
The continuous-integral function is reused from the September 30 calibration
audit, calling no package likelihood/probability kernel. Both 31 and 61 nodes
give the same conclusion. More quadrature is not a remedy for this example.

**Separate starting-value diagnosis.** After completing the frozen nine-case
run, use the retained EM parameters as the start of the same adaptive BFGS
optimizer, with the same data, 31 points, 500 iterations and 1e-10 tolerance.
It reaches NLL 1471.593412033 and passes all nine component-interval checks.
Maximum log-slope change from the EM parameters is .0001719. This calculation
took 27.967 seconds for fitting and 57.541 for inference. It is an internal
diagnostic, not an available public initialization option or a new evaluated
retry rule. Its object explicitly has no neutral-start replay call, and its
starting vector/source are recorded. It does not overwrite the original failure
or add a success to the seven-of-nine count. Replicate 26's boundary/global
status remains unresolved; the refusal alone cannot classify it.

**Cost and decision.** The nine-case procedure took 552.207 elapsed seconds
with two computation workers; summed fitting and inference times were 531.235
and 528.869 seconds (CPU total 1,057.265 seconds). The eight ordinary cases
averaged 129.978 elapsed seconds each, range 114.825--186.385. At two workers,
simple extrapolation yields about 7.2 hours for 400 matched cases and 36.1 hours
for 2,000 independent cases. Using the observed minimum/maximum yields
6.4--10.4 and 31.9--51.8 hours respectively, not predictive intervals or hard
upper bounds. A small concurrent fixed-parameter comparison and ordinary
workstation activity were not isolated; these are planning measurements.
Actual grid retries, tails and a changed initialization rule can change cost.

Do not spend that budget on the neutral-only candidate. First fix and test a
data-based starting-value/solution-selection rule through the public route;
then refreeze the full procedure and re-estimate cost before either larger
study. The existing October 2 consultation checkpoint remains applicable.
The planned 500 independent datasets per condition would target roughly
one-percentage-point coverage MCSE if at least 475 intervals are returned;
it is not a completed study or evidence that earlier bias/undercoverage vanished.

**Verification and identity.** The runner checks pass/refinement/terminal/mixed
failure decisions. A mocked full-flow check additionally verifies actual call
controls, order progression and retention of a point when inference errors.
The first fresh-process cache check exposed a bookkeeping issue: pkgload
copies an identical compiled library to a different temporary path. The
current runner hashes that library under a stable label while retaining its
content hash. This changes no fitting or inference function. A two-process
cache test uses the retained objects as fixtures and requires replay without
fitting or changes to saved RDS files/timing. It is a cache test, not another
numerical run. Original numerical evidence and exact executed source remain
unchanged; future runs use the corrected runner and a new output directory.

Evidence is under `validation-results/gmfrm-adaptive-procedure-20260930/`:
the pre-execution protocol, input/source hashes and snapshots, nine saved
stage records, dispositions/timing, independent objective comparison and
separate starting-value diagnostic with scripts. No package estimator/API was
changed, no full package check or new coverage simulation was run, and no
commit or publication was performed. D1/D2 remain open.

## September 30: public adaptive initialization revision

**Problem and implementation.** A small terminal gradient did not distinguish
the earlier poor flat solution from a better likelihood solution. Public
two-family adaptive direct MML now optimizes from both the neutral vector and
a same-data fixed-grid EM vector. Every candidate uses the same requested
adaptive objective, optimizer and stopping controls. Select the lowest finite
terminal adaptive NLL; keep a better unfinished candidate's numerical status
instead of substituting a worse converged point. Exact ties retain neutral.
A known starting objective lower than every terminal point beyond roundoff
marks the selected result unresolved. This comparison is independent of truth,
interval outcomes and fixed-grid likelihood values, and does not establish a
global maximum.

`gpcm_mml_start=NULL` resolves to `"neutral_em"` only for this route;
`"neutral"` reproduces the previous public initialization. The EM seed uses
the requested quadrature, maxit outer iterations, 100 iterations per M-step
and per-Person score tolerance 1e-6. A finite unfinished EM vector can supply
a start. Each direct candidate separately retains its requested maxit/reltol
and existing gradient-polishing sequence. There is no new optimizer, changed
likelihood, automatic quadrature escalation or relaxed inference threshold.

`fit$opt$mml_initialization` retains every starting vector, adaptive starting
objective, optimizer result/stage history, error, warning, seed trace and cost.
Alternative failures are disclosed; an all-start failure condition carries
the same record. Summaries record the effective choice and selected start;
results/reports include the comparison table. The report also now correctly
labels adaptive direct fitting and its total gradient, rather than EM and
a per-Person score. Saved calls pin the effective policy, and quadrature
refits of older objects without the field retain neutral initialization.

**Fixed matched check.** Before executing the revised algorithm, the roadmap
recorded these rules and retained the same nine datasets, initial order 31,
maxit 500, reltol 1e-10, all-component 95% model intervals and conditional
31/61/121 quadrature rule. The runner additionally preserves the full error
condition if fitting fails. The original neutral-only evidence is unchanged;
the new run has a separate manifest, complete source snapshots and protocol.

**Outcome.** All nine cases completed at order 31; no conditional quadrature
retry occurred. All nine neutral candidates reproduce the previous saved
parameter vectors exactly (maximum absolute difference zero). The revised
selection retains neutral in four cases and the EM-derived candidate in five.
In seven ordinary cases the selected NLL is unchanged up to 7.60e-11 and all
nine component intervals remain available. The other two cases change as follows:

| Rotating-pair SD=.5 case | Previous neutral NLL | Revised selected NLL | Current numerical result | Component intervals |
| --- | ---: | ---: | --- | ---: |
| Replicate 1 | 1558.971231708 | 1471.593412040 | Total-gradient review fails | 0 / 9 |
| Prespecified replicate 26 | 1582.001695682 | 1484.228252536 | Joint information fails | 0 / 9 |

The literal continuous likelihood independently reproduces both new NLLs;
maximum per-Person log-integral error is 1.78e-15 at both 31 and 61 adaptive
nodes. Thus both improvements are improvements to the same accurately
integrated likelihood. They do not establish global optimality or coverage.
Every optimizer returns code zero, but only eight selected solutions pass
the gradient review. The runner's `Converged` column reflects the optimizer
flag; `matched-review.csv` separately records `GradientCheck` and the actual
gradient. Code zero alone is not the numerical convergence decision.

Replicate 1's selected slopes now range from .21247 to 1.28777. Its total
gradient is 1.5142e-4 against the unchanged 1e-4 threshold after all five
optimizer stages. The selected estimate is retained with a warning and
missing intervals; the full-information checks are not reached. The earlier
separate warm-start diagnostic had a different starting vector and passed;
it does not qualify this new public procedure's stopping result. Replicate 26
has slopes from .00135593 to 1.48323 and total gradient 7.29e-6, but its
unregularized full-information check fails. Its boundary/global-solution
status is still unresolved. Neither refusal was dropped, replaced by the
worse neutral solution, or repaired by changing thresholds. Interval
availability remains seven of nine, a bounded feasibility result rather than
a representative estimate of availability or sampling coverage.

**Cost and next decision.** The run took 1,016.773 elapsed seconds (16.95
minutes) on two workers, with 1,182.309 summed fitting seconds and 539.670
inference seconds; CPU total was 1,720.131 seconds. The eight ordinary cases
averaged 165.914 seconds, range 132.350--204.260. Replicate 26 took 394.665
seconds, including 343.334 for fitting, so the ordinary range is not an upper
bound on difficult cases. Small source/reporting checks and normal workstation
activity were not isolated from the run.

Simple ordinary-case two-worker projections are 9.2 hours for 400 matched
datasets and 46.1 hours for 2,000 independent datasets; minimum/maximum
ordinary-case scenarios are 7.4--11.3 and 36.8--56.7 hours. These omit the
frequency of difficult cases and unobserved quadrature retries and are not
predictive intervals. The combined mean projection is about 55.3 hours,
beyond the October 2 18:00 JST checkpoint if started at this review. Neither
large study was launched. The observable initialization repair is implemented;
the retained stationarity failure and weak-information case must inform the
next numerical/interval decision before spending the coverage-study budget.
The existing consultation rule continues to apply.

**Verification.** Selection tests retain a lower unfinished point, neutral
ties, seed/optimizer failures, all-start failure records and a starting point
better than all returned candidates. Four targeted test files account for
309 successful expectations after correction of one obsolete test assumption:
a short-run fixed/adaptive integral discrepancy is now checked on the explicit
neutral fit, because the new selected EM-derived point happens to agree.
The exact adaptive-likelihood equality and independent full-covariance and
response-moment checks remain unchanged. The corrected first workflow block
and selection tests were rerun; the other successful blocks were reused.
Both the initial failure log and successful correction log are preserved.

All nine saved fits reconstruct initialization tables, available/unavailable
intervals and reports in a fresh R process with fitting and adaptive-integration
functions replaced by errors. RDS round trips preserve the complete candidate
history and report text. A separate fresh-process runner-cache replay preserves
all nine result files and their original timing hashes. `devtools::document()`
completed, the three changed Rd files parse, and the updated GPCM guide renders
in CRAN mode without rerunning its long numerical examples. `git diff --check`
passes. No full package check or coverage qualification is claimed.

Evidence and executable checks are in
`validation-results/gmfrm-adaptive-start-20260930/`, including source/input
identity, the pre-execution protocol, all candidate/failure records, matched
comparison, literal-integral check, measured costs and test/replay logs.
The work changes the development source, not a published 0.2.4 artifact;
no commit or publication was performed. D1/D2 remain open.

## September 30: adaptive stationarity and weak-information review

**Decision addressed.** Separate a stalled numerical optimizer from an
unreliable information calculation before changing an interval threshold or
spending the matched-replay budget. Reuse the two refused fits from the
initialization review. The independent literal Louis implementation evaluates
all location, step and slope derivatives at both 31 and 61 adaptive nodes;
the package's moving-node gradient and existing guarded curvature proposal
are evaluated at the same saved points. No response data are generated.

| Saved rotating-pair SD=.5 point | Raw total gradient | Largest discrepancy from independent gradient | Smallest / largest independent curvature | Standardized Newton displacement |
| --- | ---: | ---: | ---: | ---: |
| Replicate 1 | 1.51422e-4 | 1.32e-14 | .985254 / 256.060 | .000115916 |
| Replicate 26 | 7.28836e-6 | 1.05e-14 | 6.81342e-8 / 218.112 | .0279766 |

At both points the literal marginal likelihood agrees within 2.28e-13 and
the maximum entrywise 31-to-61 information change is 5.69e-14. Replicate 1
has well-conditioned positive information (reciprocal condition .002104).
Its derivative is correct but has not met the package's raw-gradient rule.
This is consistent with the relative-objective stopping rule of
[`stats::optim()`](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/optim.html)
preceding the required gradient accuracy. Reusing the existing guarded Newton
proposal lowers NLL from 1471.593412039654 to 1471.59341203293 and the gradient
to 2.06e-8, without changing the objective or tolerance. This diagnosis supplies
a reason to extend an existing repair, rather than just relaxing acceptance.

Replicate 26 is different. Its independently positive information is extremely
weak (reciprocal condition 2.17e-10). The weakest direction is dominated by
rater r4's step and location coordinates, coupled to its .00135593 slope;
the fitted step coordinate is -222.839. The package's Richardson refinement
passes relative curvature change (5.998e-6 versus 1e-3) and inverse residual
(1.026e-10 versus 1e-6), but standardized displacement .0279765 exceeds the
unchanged 1e-4 weak-information threshold. The guarded proposal is rejected.
A small raw gradient therefore does not justify this point's local Wald
covariance. The refusal is supported by independently stable weak curvature
and inadequate stationarity in that metric, not demonstrated quadrature or
derivative error. A global optimum or a true boundary has still not been proved.
The two-point numerical diagnosis took 70.631 seconds on two workers.

**Public repair and frozen replay.** Extend the existing single curvature
restart to adaptive GPCM with a fixed population and at most 64 free
parameters, after the ordinary polish ladder still ends with
`code_zero_large_gradient`. This includes the one-family and two-family
adaptive direct routes. Other existing routes keep their previous behavior.
The same optimizer and iteration ceiling follow the proposal; positive
well-conditioned curvature, gradient improvement and no objective increase
beyond roundoff remain required. Failed proposals and every stage remain
visible. No new optimizer, dependency, user control, likelihood, information
matrix or acceptance threshold is introduced.

Weak-information refusals now report the actual curvature-change, inverse
residual and standardized-displacement values with their unchanged limits.
This makes the reason reviewable in interval checks and saved reports.
`gpcm_mml_start="neutral"` still selects neutral-only initialization; exact
historical optimizer behavior requires its source version, because numerical
repairs also apply to that starting policy.

The pre-execution protocol selects three refits from saved optimizer states:
001-common_persons-1, 001-rotating_pairs-0.5 and 002-common_persons-1. Each has
an EM-derived adaptive candidate that can enter the added branch. Refitting
uses both original starts and the unchanged public 31/61/121 interval procedure,
maxit 500 and reltol 1e-10. None of the other six saved cases has a candidate
meeting the added branch condition; they retain their original fits and source
identity as reused evidence. Only replicate 26's interval calculation is
refreshed to verify the expanded refusal detail. This avoids repeating
unchanged optimization and does not silently relabel old runs as new executions.

**Repaired public result.** All three full public refits pass at order 31 and
return all nine component intervals. Both ordinary cases retain their NLLs
within 4.40e-11 while improving their selected total gradients to 2.90e-8
and 3.49e-8. Replicate 1's recorded sixth stage, `curvature_restart`, changes
its NLL from 1471.593412039654 to 1471.593412032933 and its total gradient
from 1.51422e-4 to 1.81924e-7. This is the actual post-restart optimizer result,
distinct from the preceding diagnostic proposal. All 22 score directions and
the full unregularized information checks pass. Standardized displacement is
2.13e-8; the 31/61 score shift and covariance change are 3.73e-10 and 1.24e-12.
No quadrature retry, information regularization or threshold change occurs.

At this repaired point the independent Louis calculation reproduces the
gradient (1.81924e-7) and marginal likelihood. Its full nuisance-adjusted
log-slope covariance agrees with the public covariance to relative matrix
error 6.46e-7; the largest component log-SE difference is 1.99e-7. The
reference uses a literal constrained three-by-six log-slope Jacobian, retaining
all nuisance coordinates, rather than inverting a slope-only block.

Combined with the six explicitly reused fits, the disposition is now eight
of nine cases returning all component intervals, versus seven previously.
The refreshed replicate 26 still returns no intervals and now states the
three measured refinement/inversion/displacement values and limits. Its
original fit and optimizer history are preserved. This is a bounded numerical
repair and refusal check; eight of nine is not a representative availability
estimate, a coverage result or proof that all finite solutions have been found.

**Verification and cost.** The curvature, weak-information, ordinary adaptive,
two-family adaptive and start-selection test files pass (330 unique successful
expectations across the two targeted runs). Tests cover the new successful
restart, rejected indefinite proposals, excluded estimated-population/JML/
looser-control routes, existing raw-gradient checks, independent covariance,
arbitrary owner names, export and reopening. All nine current saved-output
paths preserve interval checks, candidate histories and report text in a fresh
R process with fitting, covariance and adaptive-integration functions replaced
by errors. The weak refusal's numeric explanation survives that round trip.

Three refits plus their interval calculations took 439.392 elapsed seconds
on two workers; the separate weak-information interval refresh took 48.038
seconds. Affected cases cost 208.005, 225.634 and 230.629 seconds respectively.
The tests and small documentation checks ran concurrently; these are planning
measurements, not isolated performance benchmarks. Combining their updated
costs with the five unchanged ordinary-case records gives a mean of 184.478
seconds and range 133.827--230.629. The separately retained difficult case
took 394.665 seconds and is not bounded by that ordinary range.

On that mixed timing basis, simple two-worker scenarios are 10.2 hours for
the 400-case matched replay and 51.2 hours for 2,000 independent cases;
ordinary minimum/maximum scenarios are 7.4--12.8 and 37.2--64.1 hours. These
are not predictive intervals and omit the frequency of difficult cases and
quadrature retries. No large study has started. The now-fixed numerical
procedure can proceed to the prespecified all-case matched comparison, retaining
all failures and paired denominators, before deciding whether independent
coverage work is warranted. Apply the October 2 consultation rule to the
actual launch time and workload; the combined mean scenario is about 61.5 hours.

`devtools::document()` and Rd parsing pass; the GPCM guide renders in CRAN
mode, without executing its long statistical examples. `git diff --check`
passes. The compiled library matches the earlier archived binary. Evidence
is in `validation-results/gmfrm-adaptive-stationarity-20260930/`: pre-change
diagnosis/source, the frozen replay protocol, post-change source/input hashes,
three new fit/interval records, explicit reuse identities, refreshed refusal,
independent verification and test/replay logs. No full package check, new
sampling study, release or commit is claimed. D1/D2 remain open.

## September 30 matched adaptive replay launch

The next prespecified comparison is now running on all 400 retained September
28 datasets. It started at **21:42:49 JST on September 30**, using two workers
and the frozen `neutral_em` procedure, with the existing 31/61/121 retry rule
and unchanged inference gates. Nine verified records are reused with their
actual source identities; the remaining 391 datasets are refitted. No new
observations, seeds, acceptance thresholds or optimizer choices were introduced.

The principal comparator is the saved revised fixed-grid EM procedure. Before
launch all 400 pairs were checked for identical observations, truth, seeds and
fixed-grid fits; the original strict and revised saved interval outputs gave
95/400 and 310/400 available datasets respectively. Both historical arms remain
in the comparison, under separate names. The adaptive arm is not summarized
until all 400 records are complete. Dataset-level failures remain observations;
they do not trigger replacement data or a change in the procedure.

The repository-only runner is
`inst/validation/gmfrm-adaptive-matched-20260930.R`. It snapshots the package
source, compiled library, procedure and aggregation code; hashes both historical
input sets and all prior reused evidence; and saves each result atomically.
Each record retains all quadrature attempts, both start histories, errors,
warnings and original timings. Resume checks the manifest and frozen inputs;
a process lock prevents duplicate runs. Computation runs as a detached local
process, with an idle-sleep assertion only for its lifetime. This is execution
of the present study, not a scheduled future review or reminder.

The frozen protocol specifies log-scale bias/RMSE/empirical SD separately among
all numerically qualified finite points and among interval-returned points.
It also specifies estimated variance, interval width, interval availability,
conditional coverage, and returned-and-covered frequency for each of nine
components in each condition. Unavailable intervals have missing conditional
coverage. Exact binomial Monte Carlo intervals are provided per arm; paired
differences use the dataset as the unit, with a paired delta-method MCSE for
conditional ratios with differing denominators. A separate both-available
contrast is labelled explicitly. The four conditions share random numbers
within each replicate and are not pooled as independent evidence.

Preflight checks exercised missing intervals, finite unfinished estimates,
zero-return denominators, the analytic paired-ratio MCSE example, source and
resume mismatches, and atomic saved-record handling. A temporary 400-record
accounting fixture using the same saved procedure in both comparison arms
reproduced both historical totals and returned exactly zero paired differences
and MCSEs; aggregation refused an incomplete 399-record fixture. Those fixture
files were deleted and are not adaptive study results. No package algorithm
changed in this execution step, so the preceding targeted numerical tests are
reused rather than rerunning the full suite.

Evidence and live results are in
`validation-results/gmfrm-adaptive-matched-20260930/`: `manifest.rds`, `source/`,
`protocol-before-execution.md`, `check-aggregation.R`, `preflight.log`, the nine
explicitly reused records, `launch.json` and `execution.log`. The frozen runner
will write `rows.csv`, `stages.csv`, `summaries.csv`, `paired.csv` and
`summary.rds` after all 400 records exist. At launch the remaining workload is
about 10 hours, with ordinary-case scenarios about 7--13 hours; difficult fits
and quadrature retries can extend it. This is before the October 2 18:00 JST
consultation checkpoint on current evidence. The matched replay is informed
by development on retained examples and cannot supply independent qualification
of nominal coverage. The 2,000-case independent study has not started; D1/D2
remain open pending evidence and review.

By 21:46:08 JST the first two new jobs (replicate 3, common Persons and
rotating pairs at SD=1) had both completed and been saved, in 198.334 and
153.291 seconds. Both ended at order 31 with all nine intervals. Including
the nine reused records, 11/400 records were complete at that startup check.
This verifies execution and persistence, not overall availability or coverage;
the remaining jobs continue under the same frozen procedure.

## October 1 completed matched replay and independent-study decision

The completed results in this section stand. Its subsequent 4 x 500 launch
proposal is now held; the [revised scenario design](#october-1-revised-scenario-design)
below records the current recommendation after the user's scope review.

All 400 retained datasets completed at **11:43:25 JST on October 1**; the
summary was saved at 11:43:30. The frozen source, 818 input hashes, manifest
identity and 400 saved result hashes were verified. A separate read-only
recalculation from `rows.csv` reproduced all 108 condition/component/arm
summaries, including both point-estimate denominators, exact binomial bounds,
estimated log variance and interval width. No additional fitting or seed
generation was needed for this assessment. Evidence remains in
`validation-results/gmfrm-adaptive-matched-20260930/`, with the review script
and verification output saved alongside the original summaries.

**Question answered:** did the frozen numerical procedure recover intervals
lost by fixed-grid EM, and is there a remaining reason to revise it before
independent evaluation? The principal comparison is adaptive minus revised
fixed-grid EM on identical observations, rather than a new interval formula.
All nine intervals were returned for 95/400 historical strict-EM datasets,
310/400 revised-EM datasets and **399/400 adaptive datasets**. All 400 adaptive
point estimates met the specified numerical qualification rules. All final
fits used order 31; the prescribed source/information/integration checks still
applied. No outer fit-order retry was requested.

The 89 additional returned datasets are all in the common-Person, SD=1
condition (11/100 to 100/100). Its paired availability difference is .89,
MCSE .03145. Availability is unchanged for the other three conditions. Among
datasets with intervals from both procedures, every component's coverage
indicator is unchanged; the largest absolute log-estimate difference is
.0022303 and the largest relative log-SE change is .0042879. Across all 399
adaptive interval-returning datasets, the largest absolute log-estimate
change from revised EM is .0104607. This supports recovery of numerical
availability, not a claim that the Wald approximation's coverage improved.

**Remaining statistical evidence:** the table shows ranges over nine distinct
components within each condition, not pooled independent replications. Bias
and RMSE use all 100 numerically qualified points. The SE ratio is
`sqrt(mean(LogSE^2)) / sd(LogEstimate)` on the same interval-returned subset;
width is the mean width on the log-slope scale. Each coverage denominator is
100, except rotating pairs at SD=.5, where it is 99.

| Design; ability SD | Returned datasets | Log bias | Log RMSE | RMS model SE / empirical SD | Mean log width | Conditional coverage |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Common Persons; 1 | 100/100 | -.0581 to .0169 | .1164–.1997 | .850–1.158 | .432–.793 | .90–.98 |
| Rotating pairs; 1 | 100/100 | -.0300 to .0108 | .1056–.2187 | .890–1.111 | .459–.835 | .93–.98 |
| Common Persons; .5 | 100/100 | -.1107 to .0200 | .1310–.3399 | .968–1.094 | .523–1.285 | .93–1.00 |
| Rotating pairs; .5 | 99/100 | -.1001 to .0169 | .1517–.6701 | .872–1.070 | .566–1.456 | .9091–.9596 |

Three observations constrain the next decision:

* Common Persons, SD=1, Task t3 has negligible mean log bias (-.00206),
  empirical SD .12982 versus RMS model SE .11034, and 90/100 coverage.
  Six intervals lie above truth and four below. Its exact 95% Monte Carlo
  coverage interval is [.8238, .9510]. Mean bias alone does not explain this
  result; local variance calibration or tail shape warrants independent
  evaluation. The observed .850 SE ratio is not a proven population constant.
* Rotating pairs, SD=.5, Task t1 has bias .01694, SE ratio .8718 and 90/99
  coverage; eight intervals lie above truth and one below. Conversely, common
  Persons at SD=.5, Rater r3 has bias -.11071 (MCSE .03230) but 99/100
  coverage. Thus neither near-zero mean bias nor apparent nominal coverage
  alone establishes adequate inference. No empirical bias correction or
  SE multiplier is estimated from these diagnostic findings.
* `026-rotating_pairs-0.5.rds` remains the single joint-information refusal.
  Its Rater r4 slope is about .001356, versus truth .525. For that component,
  all-point empirical SD/RMSE are .6659/.6701, while the returned subset has
  .3069/.3081. Its bias changes from -.1001 to -.0409 when conditioning on
  interval return. The missing interval is preserved, and the unstable point
  remains in the all-point summary. Counting only returned intervals would
  conceal this instability; forcing a covariance would not repair it.

**Decision:** retain the unchanged adaptive fitting/information/log-Wald
procedure as the candidate for independent evaluation, with experimental
status and the current refusal policy. The matched evidence does not isolate
a new calculation error or justify a particular bias/tail correction. It
does identify finite-sample concerns that an independent evaluation may
confirm or fail to resolve. The proposed evaluation is the already specified
four correctly specified conditions, 500 new datasets per condition, seed
family `93020000 + replicate`. The nine components and shared-random-number
conditions are not extra replications. No location, curve, simultaneous,
new-Person or population-transport claim follows from component coverage.

The original practical margins remain unchanged: availability >=.95 and its
exact 95% lower bound >=.90; the exact 95% conditional-coverage interval must
be contained in [.92,.98] for each proposed limited claim. Failure or an
inconclusive result does not trigger automatic extra replications, a changed
threshold, or a switch to a different interval method. Report adverse bias,
widths, SE calibration and failed fits alongside any margin decision.

**Revised compute decision:** the 391 new fits took 14.010 elapsed hours on
two workers. All 400 records contain 28.475 worker-hours of measured fit and
inference time. Extrapolating those measurements gives **71.2–71.7 elapsed
hours** for 2,000 new fits at two workers (about 142.4 worker-hours); this is
a planning estimate, not a runtime confidence interval. Difficult new fits,
additional quadrature orders, other workloads and suspension can extend it.
It supersedes the earlier 36–51-hour projections from selected examples.
The interpretable result would fall after October 2 at 18:00 JST, so the
existing user consultation rule applies before launch.

The repository-only `gmfrm-adaptive-independent-20261001.R` runner prepares
new inputs and copies the matched replay's frozen package/procedure exactly.
It reuses the existing generator, capture, numerical gates, atomic records
and summary formulas. It records every fit/inference stage, guards resume by
source/input/manifest identity, and refuses aggregation before all 2,000
records exist. Its preflight uses retained results and accounting fixtures;
no new fitting is required for readiness checks. The initial preparation
stopped because the original generator script's recorded whole-file hash
differed from the current file. The original script was not archived, so the
exact textual change cannot be established. The complete generation plan and
all 400 historical observations/truth tables/seeds were then reproduced
exactly before freezing the current generator; both file hashes and that
verification are retained in the new manifest. No fitting or inference
threshold changed. Preparation does not launch
the study. **Historical launch status:** this proposal was initially held for
a compute/deadline decision. The later October 1 instruction below supersedes
that rationale: the deadline is relaxed, but all new computation is held for
scientific redesign. Corrected-JML sampling remains paused and D1 remains open.

## October 1 revised scenario design

**Historical proposal, now held:** the later
[small-cohort review](#october-1-small-cohort-and-facet-structure-review)
supersedes this section's recommendation to execute the 24-condition design.
Its completed evidence and frozen inputs remain intact.

**Decision at preparation:** hold the unexecuted 4 x 500 confirmation proposal.
Its four N=240 cells can support only a narrow conditional claim. Repeating
them more precisely cannot establish how performance changes with sample size,
ratings per rater or rating allocation. Retain the unchanged adaptive/log-Wald
procedure as the candidate, but first examine its domain through the staged
design below. This supersedes the preceding launch recommendation, not the
completed matched evidence or the prepared proposal's immutable files.

**Main question:** under a correctly specified two-family GPCM, when does the
current procedure supply usable and appropriately calibrated slope intervals,
and which practical designs reveal failures? In particular, does the Task-SE
shortfall at N=240 diminish as information increases, and do weak slopes or
concentrated ratings produce point estimates whose instability is hidden by
conditioning on interval return? Accurate numerical integration is necessary
but does not answer these sampling questions.

### Conditions and their roles

The core is a complete 3 x 2 x 2 design: **N=120, 240, 480; ability SD=.5, 1;
common-Person and rotating-pair rosters**. This permits sample-size trends and
their interaction with ability spread and roster to be inspected, instead of
treating one-factor changes as proof of general robustness. All core cells
have three tasks, six raters and scores 0:2. The common-Person roster assigns
20% of Persons to all six raters and the rest to one rater, equally distributed;
the rotating roster assigns each Person to an adjacent pair on a six-rater
ring. Both have 2N Person-rater pairs, 6N scores, and N/3 Persons per rater.
The original N=240 four cells contribute their existing 100 records each.

Twelve further conditions probe specific limits. Except as stated, they use
N=240, SD=1, three tasks, six raters and scores 0:2. Their number is a scoped
set of questions, not a claim that 24 conditions exhaust the model's domain.

| Added conditions | Exact change and comparator | Question / interpretation limit |
| --- | --- | --- |
| 2 small-sample | N=60 under both existing rosters; compare the same roster at N=120/240/480 and SD=1. | Where do availability and point stability deteriorate? N=60 x SD=.5 is not covered. |
| 2 wider-population | SD=1.5 under both existing rosters at N=240; compare SD=.5/1. | Does increasing ability spread change SE calibration or tails? This is not a nonnormal-population condition. |
| 1 more tasks | Six tasks, rotating pairs; duplicate the original three task parameter settings as three additional levels. | Does more information per Person help? Scores double from 1,440 to 2,880; this is not cost matched. |
| 1 more raters | Twelve raters, rotating pairs; duplicate the original six rater parameter settings. | What happens with more estimated rater levels and 40 rather than 80 Persons per rater, at the same 1,440 scores? The ring topology changes too. |
| 1 unequal exposure | Adjacent pair group sizes 70/50/40/30/20/30 instead of 40 each. Rater Person counts become 100/120/90/70/50/50. | How does unequal information affect individual raters when every Person still has two raters and the total cost is unchanged? |
| 1 weak bridge | Six Persons rated by all six raters; within each of two three-rater groups, 105 Persons get pairs and 12 get one rater. | With 80 Persons per rater and 1,440 scores preserved, what happens when only six Persons connect the groups? Person exposure also changes; do not call this an isolated graph effect or assume graph disconnection alone proves MML nonidentification. |
| 1 weak slope | Rater r4's generating slope is .2 rather than 1.05; rotating roster. | Is near-zero estimated slope behavior confined to chance extremes, or systematic under weak discrimination? No replacement of failed draws. |
| 1 rare top category | Add +2.5 to all rater locations; retain the full 0:2 ladder and rotating roster. | How does poor targeting / sparse upper-category support affect output? The shift is fixed before draws; do not condition generation on achieving a chosen observed category count. |
| 2 writing-roster templates | 135 Persons, five tasks, seven observed raters, scores 0:3, 274 Person-rater pairs / 1,370 scores. Original exposure versus redistribution preserving exact per-rater counts. | Does concentrating repeated ratings on a few Persons matter? Original Person degrees are 89 x 1, 27 x 2, 2 x 6 and 17 x 7; control degrees are 131 x 2 and 4 x 3. This is a synthetic experiment on an empirical roster, not validation of the empirical responses. |

The writing template is the retained `sirt-data.ratings1.rds`, hash
`45cdfdc65f8ab0c5c86878fa043bdf0b`; observed rater counts are
41/37/37/41/38/41/39. Only its Person-rater incidence is used. The original
absent cells are not asserted to be known planned nonassignment. Five-task
locations span [-.4,.4], log slopes [-.2,.2]; seven-rater locations span
[-.3,.3], slopes [.75,1.25], and centered step vectors are (-h,0,h), with
h spanning [.45,.7]. These are declared synthetic parameters, not empirical
estimates treated as truth. The redistributed roster is a fixed allocation
algorithm preserving column totals, not a random sample from every feasible
roster or an asserted optimal allocation.
It changes Person exposure and pairwise overlap together; interpret it as a
comparison of allocation designs, not an isolated effect of one concentration
index.

All other parameters retain the original baseline values. The data generator
uses the literal adjacent-category recursion. Persons have theta=SD*z,
z~N(0,1), with allocation independent of z and conditionally independent
responses. On the fitted fixed-N(0,1) scale, task slopes are unchanged,
rater slopes are multiplied by SD, and locations/steps are divided by SD.
Thus different SDs do not imply identical identified slope truths. Centered
task locations, geometric-mean-one task slopes and centered rater steps are
preserved, including the larger facet/category conditions. Task and rater
parameters are fixed across repetitions within a condition; only Persons,
responses and the specified ability-independent allocation are randomized.
The ability-SD contrasts do not vary the distribution of rater severity or
task difficulty. The study therefore does not estimate performance averaged
over a population of randomly sampled tasks or raters.

Nonnormal populations, ability-associated allocation, score-dependent missing
ratings, Person-by-performance dependence, category compression and method
selection are **outside this first screen**. They remain relevant scope limits;
under misspecification a matching estimand must be specified before labeling
an interval as covering a parameter. The targeted contrasts above do not test
all interactions among adverse conditions. No slope-coverage result qualifies
location, curve, new-Person, simultaneous or consequential feedback claims.

### Replication, accounting and decisions

Use two separately budgeted screening blocks, not 500 repetitions in every
cell. **Core:** 100 per condition, reusing 400 saved N=240 records and adding
800 at N=120/480. **Targeted:** 100 in each of the 12 declared conditions,
adding 1,200. Completing both would therefore use 2,400 records, of which
2,000 are new. The equality with the old proposal's new-fit count is incidental:
these have a different scientific purpose, allocation and compute cost.
The retained four cells were used during development; the mixed screen must
not be described as independent confirmation. No new baseline rerun is needed
merely to make all records share the same provenance label.

At coverage .95, 100 returned intervals have MCSE .02179; 95/100 has exact
95% Monte Carlo bounds [.8872,.9836]. This can reveal large problems and
patterns, but cannot settle a 3-percentage-point equivalence margin. There is
no screen-level "coverage qualified" flag, and no absence-of-significance
claim of acceptable calibration. Interpret the size and precision of bias,
RMSE, empirical/model SE differences, width and failures jointly. New cells
are not guaranteed to reveal an effect at this replication count.

Preserve every attempted draw, warning, fit/inference error, check refusal,
quadrature retry and stage time. Report each task/rater component separately
(the component count varies with the scenario). Bias/RMSE and tail summaries
use all numerically qualified points, with the interval-returned subset shown
separately. Compare empirical SD to RMS model SE on the same returned subset.
Report conditional coverage and above/below-truth misses among returned
intervals, as well as availability and returned-and-covered probability over
all attempts; a withheld interval is not observed conditional noncoverage.
Keep category frequencies, rater exposure and overlap with failures rather
than pooling them into a single success rate. No pooling of components or
conditions creates more independent replications.

New screen seeds are `93100000 + 1000 * SeedGroup + replicate`, with fixed
scenario IDs in `gmfrm_design_plan()`. New conditions use independent streams,
except the two writing templates, which share latent Persons and potential
responses and require paired comparisons. The four historical N=240 cells
also retain their original shared random numbers; use paired accounting
within those cells and independent accounting against new cells. Replicates
are independent within each cell. The original 92810000 and held 93020000
seed families remain separate.

If a numerical defect calls for a procedure change, retain all results and
identify the change; do not patch the method halfway through a fixed study or
silently replace failed datasets. Choose any eventual confirmatory domain
from the intended user claim, keeping adverse screen evidence visible; do not
select only favorable cells and generalize to the omitted conditions. Freeze
the domain, method, seeds, margins and sample size before independent
confirmation. The number and scope of confirmation cells are intentionally
not predetermined by the exploratory screen's 24-cell count.

The held confirmation rule itself also needs a realistic power discussion.
With every interval returned and true coverage .95, the existing requirement
that the exact 95% binomial interval lie within [.92,.98] has the following
operating characteristics. These are exact binomial calculations, not a
simulation of fitted models or joint assurance over all components.

| Returned intervals | MCSE at .95 | Covered-count values satisfying the margin | Probability of satisfying it at true .95 |
| ---: | ---: | --- | ---: |
| 100 | .02179 | None | 0 |
| 250 | .01378 | 239 | .1106 |
| 500 | .00975 | 472–482 | .7124 |
| 1,000 | .00689 | 937–970 | .9709 |

Unavailable intervals reduce these denominators, and the separate availability
rule can also fail. Even 1,000 does not ensure every correlated component
passes; do not multiply pointwise probabilities as if components were
independent. This is a reason to match confirmation size to a concrete claim
and decision risk, not an instruction to double all runs or relax a failed
margin. Planning follows the question/design/estimand/performance/Monte Carlo
precision distinction in
[Morris, White and Crowther (2019)](https://pmc.ncbi.nlm.nih.gov/articles/PMC6492164/);
the exact intervals use [R's binom.test](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/binom.test.html).

### Execution boundary

`gmfrm-design-screen-20261001.R` generates the 24 scenarios and performs a
no-fit preflight: roster counts, response ladder, seed reproduction, parameter
constraints, old three-category equation, identification-scale equivalence,
and agreement with the package probability kernel. The writing pair is checked
for identical latent values/truth, preserved per-rater totals and identical
potential responses on shared cells. It has no fitting command. This makes
the proposed generating design reviewable; it does not make a full sampling
runner ready or establish coverage.

A bounded timing pilot uses the **eight new core cells, one draw each**, before
any long-run compute decision. It uses the matched replay's frozen package,
binary and exact procedure (31/61/121 quadrature rule, neutral-EM start,
maxit=500, reltol=1e-10, information checks, .95 model log-Wald intervals).
No new threshold or estimator is tuned. Keep these first draws as screen
replicate 1 if the same screen is subsequently launched, retaining failures
as well as successes. Their timing is a rough planning input, not a coverage
result, runtime confidence interval or proof of successful recovery.

Before a complete core block, freeze its new inputs and runner and report
remaining cost using pilot and historical stage times, with a broad sensitivity
range for one-draw timing and tails. The repository-only
`gmfrm-core-screen-20261001.R` provides that core-only preparation and execution:
it generates 800 fixed inputs, retains the 400 existing adaptive row sets,
reuses all eight pilot results as replicate 1, and leaves 792 new fits. It
references the already frozen matched package/binary by checked hashes, copies
its own runner/generator, and checks source/input/manifest identities on load
and resume. It refuses a complete summary before every planned case exists.
Accounting fixtures exercise separation of the three sample sizes, the
retained refusal, entirely unavailable intervals and incomplete-run refusal;
they create no sampling evidence or coverage-qualification flag.

Before the targeted block, separately
verify the greater facet counts and four-category procedure: the old frozen
wrapper explicitly hardcodes `rating_max=2` and cannot be applied unchanged to
the writing cases. Preserve all other algorithm settings when parameterizing
the score ladder. Do not extend the old fixed-nine-component, four-condition
summary assertions to the expanded design without checking the denominators.
The old 71–72-hour estimate applies only to the old 4 x 500 mixture.

If the expected interpretable result is after **October 2 at 18:00 JST**,
consult the user before launching the long run, as required by the roadmap.
Neither a time cutoff nor partial results authorize reducing the declared
replication count. The two blocks can be scheduled separately for compute
reasons; report a block not run as unstudied, never as passed. Corrected-JML
sampling remains paused, and D1/D2 are still open.

**No-fit preflight and core timing completed October 1:** all 24 generating
conditions passed the roster, ladder, parameter-constraint, reproducibility
and scale checks using two seeds per condition. Maximum probability-kernel
discrepancy was 4.44e-16 and identification-scale discrepancy 3.33e-16. The
eight fixed core timing cases finished at **13:39:34 JST**, using the matched
replay's 446 frozen package/procedure files and checked loaded binary. All
eight returned numerically qualified points and all nine component intervals,
with final fitting order 31 and no outer fit-order retries. This establishes
execution for these examples, not their coverage. Source/input/result and
manifest identities were checked. Evidence is in
`validation-results/gmfrm-design-screen-20261001/`, including the preflight,
binomial planning calculation and the eight `core-pilot/` records.

| Core timing condition | N=120 fit + inference seconds | N=480 fit + inference seconds |
| --- | ---: | ---: |
| Common Persons, SD=.5 | 139.890 | 685.864 |
| Common Persons, SD=1 | 215.786 | 1,013.719 |
| Rotating pairs, SD=.5 | 75.116 | 417.509 |
| Rotating pairs, SD=1 | 158.067 | 797.975 |

The pilot took 35.623 elapsed minutes and .9733 worker-hours. For the remaining
99 repetitions in each of eight cells (**792 fits**), extrapolating measured
stage times at two busy workers gives **48.18 hours**. Applying time strictly
proportional to N to the older 400-case measurements instead gives **35.24
hours**. These are different planning assumptions, not confidence limits.
Half/double the new measured per-case times give 24.09/96.36 hours as explicit
sensitivity scenarios, not probability bounds. One draw per cell cannot
estimate its runtime distribution; the old N=240 study itself had a median
181 seconds and maximum 1,941 seconds per case. Additional difficult fits,
retries, suspension or other workloads may extend the run. Multiplying the
small pilot's elapsed time by 99 would also preserve its unusually large
end-of-run load imbalance; the stage-time estimate assumes both workers stay
busy across the full block, apart from the final jobs.

Both central planning assumptions put interpretable completion after the
original October 2 18:00 checkpoint. The user subsequently allowed completion
beyond that time and explicitly requested **no further computation while the
scientific design is reconsidered**. Keep the remaining core computation on
hold for that reason. Preserve the eight pilot cases; reuse them if their exact
conditions/procedure remain relevant, rather than rerunning or replacing them
based on their successful interval output.
The held 2,000-fit confirmation proposal and the targeted 1,200-fit block
have not been launched. No public estimator, CI threshold, help claim or
release qualification changed in this redesign.

The core-only proposal is now prepared in
`validation-results/gmfrm-core-screen-20261001/`: 800 frozen input files, the
checked 400-case baseline table, eight reused pilot records, frozen runner and
generator, bound execution protocol, and `readiness.rds` / `readiness.log`.
A fresh R process loaded the frozen package/binary and correctly refused a
complete summary with only 8/800 new-case records. The initial preparation was
replaced before any new fitting to include the protocol itself in the source
identity check; all 800 input hashes stayed identical, and the initial copy is
preserved at `/tmp/mfrmr-core-preparation-before-protocol-hash-20261001`.
There is no active core-study run. Its archived entry point remains
`validation-results/gmfrm-core-screen-20261001/source/runner.R` in the development
root. **It is not the next launch recommendation.** The deadline relaxation
does not authorize this proposal, another timing pilot, or generation of a new
input batch. Preserve the immutable preparation; do not overwrite its protocol
with the revised scientific scope below.

## October 1 small-cohort and facet-structure review

**Current instruction and status:** mfrmr is a general-purpose R package.
Prioritize substantive adequacy over the October 2 18:00 JST checkpoint. The
user requires both the previously studied larger samples and the neglected
20–60-Person range, with explicit consideration of facet count and levels per
facet. Small-cohort priority expands the evaluation; it does not replace the
medium/large-sample scope. Do not run new estimation, simulation, timing or data-generation
work during this design review. The prepared 2,000-case confirmation and
800-input core proposal are held; 792 core cases remain unrun. This review
uses source inspection, retained evidence and literature only. No estimator,
public capability, inference threshold or release qualification changes here.

### Correct the question before choosing conditions

The preceding design was anchored to the existing N=240, Task-by-Rater study
and its slope-interval defect. Making N=120/240/480 the core and N=60 a targeted
stress condition did not address the user's intended small-cohort workflows.
The empirical/practitioner anchors already included small cohorts; they should
have influenced the main design. Numerical improvement on the 400 retained
datasets is useful evidence, but does not establish small-cohort usability.
The subsequent revision overcorrected by treating larger samples merely as
context. The user's latest correction restores them as substantive parts of
the main evaluation, not an optional appendix or evidence to discard.

The primary question is: **across small, medium and large samples and the
supported facet structures, which model and rating design deliver estimates
and uncertainty adequate for the intended interpretation, and where do outputs
need to be withheld or qualified?** N=20–60 receives the missing attention
without becoming the definition of the package's intended audience.
Rater severity/contrasts and Person scoring belong alongside discrimination,
not downstream of an automatic two-family slope-coverage qualification.
Separate exploratory rubric/rater review from individual consequential
decisions; a single generic acceptable-coverage rule cannot establish both.

The user's account establishes a development priority, not an independently
measured proportion of mfrmr users. A relevant published example is the
[Uto et al. (2024) OSCE study](https://doi.org/10.1371/journal.pone.0309887):
30 examinees, five raters, 30 rubric items and four score categories; two raters
assessed everyone and three assessed disjoint groups of ten. This anchors a
small-N, many-item, unequal-exposure design. Its richer response model uses
Bayesian EAP estimation with NUTS and declared priors; it does not validate
mfrmr's current two-family MML or its Wald intervals.
Published Rasch sample-size heuristics likewise cannot supply a universal
minimum N for this different model and inference procedure.

### Design dimensions and provisional applied settings

Count **non-Person facets** explicitly below; conventional descriptions may
count Person as an additional facet. For example, Person x Task x Rater has
two non-Person facets, while Person x Task x Criterion x Rater has three.
Criterion levels are rubric dimensions/items, not the ordered score categories.
The number of facets, levels, slope-owning facets and latent ability dimensions
are four different quantities.

| Dimension | Candidate scope, not a frozen simulation grid | Question it answers |
| --- | --- | --- |
| Independent Persons | N=20, 30, 40, 60, 120, 240, 480 in the main sample-size scope. Reuse the completed N=240 evidence and compatible N=120/480 pilot records. | Where do estimation and uncertainty improve, remain biased, or fail across the range? Neither small-N nor large-N results substitute for the other; N=480 alone does not prove asymptotic behavior. |
| Non-Person facet count | One-facet reduced reference; Task x Rater or Criterion x Rater; Task x Criterion x Rater; add Occasion only for a concrete repeated-assessment question. | Can distinct sources of variation be represented and separated? More facets are not automatically more ability dimensions. |
| Levels within facets | Initial candidates: 2/3/6 raters, 2/4 tasks, 3/5 criteria; retain a separate many-item OSCE anchor. Larger rater panels are relevant to training/shared-performance designs. | How do calibration burden and exposure per estimated level change? Values are proposed design contrasts, not measured usage frequencies. |
| Assignment and workload | Fully crossed small panels; two raters per performance; common-rater/common-Person links; unequal exposure and weak links. Specify Persons and performances per rater as well as total scored cells. | What can be separated using the observed crossings, and what precision is gained by a feasible allocation? |
| Ordered categories and steps | Three/four/five categories; common versus owner-specific steps; central versus poorly targeted scores. Declare which facet owns steps. | Does a richer rubric help measurement or leave individual step parameters unsupported? Changing step ownership changes the model. |
| Population and effect variation | Ability SD .5/1/1.5, then targeting/location shifts and selected nonnormal populations; separately change rater severity, task difficulty and log-slope variation. | Which source of heterogeneity causes the change? An ability-SD contrast does not test rater-severity SD. |

The main evaluation has two complementary sample-size comparisons. First,
hold facet levels, response equation, population and assignment rule fixed
while varying N; this isolates sample-size trends as far as discrete roster
constraints allow. Second, increase facet levels/model burden or change the
assignment together with N to represent larger operational assessments. A
large overall N can still leave each rater or task with sparse exposure.
Neither comparison can replace the other, and a fully crossed large-N design
alone does not qualify a large sparse assessment.

Retain an explicit connection to the historical four conditions: three Tasks,
six Raters, three categories, ability SD .5/1, and common-Person/rotating-pair
rosters, with rater-owned steps. Their N=240 records remain substantive
sampling evidence. Extend matching design definitions across the declared N
range where feasible, documenting small-N integer allocation differences
rather than silently changing the population or model. Criterion-owned rubric
models below are an additional comparison, not replacements for these cases.

Evidence status must remain visible: N=240 has 100 retained datasets in each
of those four cells; N=120 and N=480 have one timing case per corresponding
cell, not completed coverage evaluations. Compatible prepared inputs and pilot
records may be reused once the design is settled, but their existence neither
authorizes execution nor establishes performance. If the inference procedure
changes, label and evaluate the new procedure on retained data as appropriate;
do not pool old/new procedures as one arm or call reused development data
independent confirmation.

Selected misspecification and exposure contrasts must include larger samples
as well as small ones: increasing N does not remove a wrong-model target or
an assignment bias. Runtime/memory under larger facet counts is also a package
usability question, evaluated separately from statistical accuracy. The upper
sample size for a specific large-scale use case can be extended with a stated
purpose; 480 is the present main grid endpoint, not a universal package limit.
This is the MML validation strand of mfrmr, not a redefinition of the broader
package or a qualification of its separate G/D, MI and reporting capabilities.

Use cases give these dimensions a purpose. A small classroom with a few tasks
and two or three common raters differs from rater training where many raters
score a small set of shared performances. A rubric assessment with Task,
Criterion and Rater differs from both, even at the same N. The published OSCE
is a fourth, many-item example. Occasion requires an explicit stable-ability
or change estimand; a main-effect time column alone does not model individual
growth. These are design families to resolve, not additional automatic cells.

Two workload contrasts are necessary. If every existing Person receives ratings
from added raters/tasks, both cost and information increase. At a fixed number
of rating occasions, adding raters spreads observations across more estimated
rater effects and changes overlap. Likewise, more rubric marks on the same
performance are not equivalent to collecting new Persons or new performances.
Report rater-performance encounters separately from scored rubric cells; equal
cell counts need not imply equal human workload. When exact exposure/cost/
connectivity matching is impossible, state what changes instead of claiming an
isolated facet-level effect. Small N also makes exact balance and linking
constraints discrete; retain valid unequal allocations rather than silently
changing N to fit an old six-rater roster.

N counts independent Persons. Repeated scores can inform a Person's ability
and shared parameters, but do not create independent Persons. Start with
conditional independence as a declared baseline; examine a Person-by-performance
term for rubric scores on the same performance in the robustness block. Do not
silently manufacture independence by treating each criterion rating or each
occasion as a new Person. Also distinguish inference on the observed fixed
raters/tasks from generalization to populations of raters/tasks; more levels
alone do not turn fixed effects into a random-facet model.

### Model comparison and current implementation boundary

Compare supported **RSM, PCM, one-family GPCM and two-family GPCM using MML**
where they address the same applied question. Include generating cases with
equal slopes, only the Task/Criterion family varying, only the Rater family
varying, and both varying. Common and owner-specific category steps must be
distinguished too: RSM and PCM differ in that restriction, not just slope
complexity. Compare methods on the same generated observations. This permits
the possible variance cost of extra parameters to be weighed against bias
from restrictions, without presuming either model complexity is preferable.
Existing corrected-JML work remains paused; it is not restarted simply to
multiply comparison arms. If small-cohort MML proves inadequate for a needed
output, compare simplifying the model or improving allocation with a justified
regularized/Bayesian or externally calibrated alternative. Those alternatives
require their own estimand, prior/anchor sensitivity and uncertainty evaluation;
they are not automatic remedies or an instruction to build another engine now.
Likewise, a bootstrap cannot be assumed to repair structural nonidentification.
A rule that chooses a simpler model after a fit fails would itself need
procedure-level evaluation. Do not select the best-looking model/interval after
each draw and report its coverage as that of a fixed prespecified method.

Static source inspection establishes these boundaries:

- `R/core-gmfrm-em.R::mfrm_fit_product_slopes()` requires exactly two non-Person
  facets, both slope owners, with at least two observed levels each. The second
  owner has free locations/slopes and owns centered category steps. The ability
  population is fixed standard normal. Third/fourth additive facets, anchors,
  interactions and shrinkage are not supported by this route. Repeated rows for
  the same Person and both facets are also rejected.
- The ordinary route accepts one or more facets and constructs additive blocks
  per facet. Existing RSM/PCM MML backend fixtures explicitly include Rater,
  Task and Criterion (`tests/testthat/test-mml-cpp11-backend.R`). This is source
  evidence of a broader implementation scope, not a new small-N performance
  result or validation of every consumer/model combination.
- `extract_mfrm_sim_spec()` rejects product slopes and currently requires
  exactly two non-Person facets even for ordinary fits. The old scenario
  generator is similarly not a ready solution for this broader study.

Thus increasing Task or Rater levels within two facets cannot answer the facet-
count question. A three-facet ordinary-model study is conceptually distinct
from extending the two-family engine to additional location-only facets.
Resolve the latter's scientific need, identification, category ownership and
output contract before implementation. Do not concatenate Task and Criterion
to imply their separate effects were estimated, silently remove a requested
facet, or count a documented unsupported model as numerical nonconvergence.

Parameter burden should be explicit. For the current unanchored two-family
model with A first-owner levels, B second-owner levels and K score categories,
the source constraints give `(A-1)+B` locations, the same number of slopes, and
`B*(K-2)` centered step coordinates: **2(A-1)+BK** calibration parameters.
For example, the old 3-Task/6-Rater/3-category baseline already has 22.
Person abilities are integrated, not N additional freely estimated MML
parameters. This count exposes why rater levels and categories matter, but
neither N divided by parameter count nor total score count is a universal
identification or sample-size criterion.

Distinguish the Person-rating assignment graph, the rank of the facet-crossing
design, category support, local information curvature, and numerical convergence.
None alone certifies precise inference. Under a common fixed population model,
absence of shared Persons is not by itself a proof of MML nonidentification;
apparent comparability can depend strongly on the common-population assumption.
Conversely, connected data can remain weak or structurally confounded. Nesting
Rater within Task, for example, must be assessed for the actual estimable
contrasts and model, not handled as ordinary random missingness.

### Targets, scale and failure accounting

For interpretable location/slope parameters, report bias/RMSE, tails, empirical
versus estimated SE, interval availability, width and conditional coverage.
For rater review, prioritize prespecified severity contrasts and their
uncertainty over ranks alone. If flagging is proposed, specify a practically
meaningful difference, false-positive/missed-difference costs and multiplicity
policy first; componentwise coverage does not validate a feedback rule.

For Person scoring, distinguish calibration-cohort and new-Person performance,
central and extreme abilities, and the ability scale/estimand. Posterior SD or
fixed-calibration EAP uncertainty does not include calibration uncertainty.
Evaluate the uncertainty the public method actually supplies; do not label an
unavailable unconditional interval as covered or quietly substitute a research
oracle. Known-calibration scoring can later be an explicitly labeled diagnostic
comparator to separate limited Person responses from calibration error.

Use category probabilities/expected scores for shared response targets when
model parameters are not commensurate, with prespecified contexts and weights;
do not claim coverage of a nonexistent component in a simpler/misspecified
model. Raw locations/slopes from different identification conventions cannot
be compared directly. In particular, the two-family fixed-N(0,1) transformation
and one-family geometric-mean-one/free-population convention must be reconciled
before comparing truth. For RSM/PCM, changing ability SD while fitting a fixed
unit-SD population may add population misspecification, not merely information
variation. Choose and document population estimation or the appropriate
restriction explicitly. Fixed-effect severity remains conditional on the model;
an apparent rater difference is not automatically a causal training deficit.

Retain all planned attempts, including unsupported category draws, extreme
estimates and interval refusals. Report preparation/structural refusal,
optimization failure, integration sensitivity and inference refusal separately.
Show point performance for all qualified estimates and the interval-returned
subset; conditional coverage, availability and returned-and-covered frequency
answer different questions. Keep the original score ladder; no redraw until
every category appears. Report exposure and category support alongside failures.
Pointwise intervals are not simultaneous coverage, and many correlated
parameters within a dataset are not independent simulation replications.

### Follow-up: decisions that can be made without fitting

The continuation of this review remains a source/evidence/algebra review.
No numerical script, random generation, new derivative evaluation or timing
pilot has been run. The following findings narrow the study before replication
counts are chosen; they do not modify the frozen estimator or its checks.

**Observed-score rank is a binding output restriction at small N.**
`mfrm_gpcm_product_inference()` obtains an N-by-p matrix of observed Person
marginal-likelihood scores and requires column rank p at both derivative step
sizes (`R/core-gpcm-product-slopes.R`, the `Local score rank` check).
Consequently N < p cannot pass this check, irrespective of quadrature order,
optimizer tolerance or the number of ratings within each Person. This applies
to the current model-based component log-Wald and facet-location normal
interval paths sharing this check; it is not a claim about every possible
interval construction or about point-estimation feasibility.

The dimension consequences below follow algebraically from the source
constraints, not from simulated datasets. A and B are the first and second
slope owners; B also owns category steps. All levels are assumed observed.

| Candidate two-family design | Free calibration dimension p=2(A-1)+BK | Consequence at N=20 under the current check |
| --- | ---: | --- |
| Historical Task=3, Rater=6, K=3; rater-owned steps | 22 | Cannot return the model-based intervals through this check. |
| Rater=3, Criterion=3, K=4; criterion-owned steps | 16 | Not excluded by N < p alone; all other numerical and statistical issues remain. |
| Rater=6, Criterion=3, K=4; criterion-owned steps | 22 | Cannot return the model-based intervals through this check. |
| Rater=3, Criterion=5, K=4; criterion-owned steps | 24 | Cannot return the model-based intervals through this check. |

At an exact interior stationary point, the Person-score rows sum to zero,
so their rank is also at most N-1. Approximate numerical stationarity and
rank tolerances complicate the boundary N=p; a nominal full-rank result near
that boundary must not be made easier by a less accurate optimizer. Neither
N>p nor passing the check implies adequate precision or coverage.

This is **not a proof of structural nonidentification** when N<p. The retained
earlier two-owner example in this record already distinguishes the objects:
four Persons each observed at all four binary crossings had full-pattern
marginal score rank 6/6 at the stated interior vector, despite only four
observed Person-score rows. That result is first-order model information at
one vector, not an observed-data MLE or a coverage result. It is sufficient to
show why observed-score rank cannot be substituted for population/full-pattern
information. An observed-information Hessian and an outer product of observed
score rows are different finite-sample matrices.

For a full-parameter sandwich covariance, deficient empirical score rank is
a real limitation of that covariance construction. Requiring the same rank
as an additional condition for model-Hessian Wald intervals is a conservative
procedure choice whose role now needs explicit review. **Do not remove the
check merely to get intervals at N=20.** First determine whether it is an
essential requirement of the claimed procedure, a diagnostic that has become
an unnecessarily broad veto, or evidence that the public small-N claim needs
restriction. Any changed rule is a new inference procedure requiring its own
retained-case checks and sampling evaluation. Until then, record its known
small-N exclusions without spending repeated fits to discover them, while
retaining relevant point-estimation/scoring questions in those designs.

**The public output matrix is narrower than the fitting matrix.** The table
describes current source contracts, not small-sample qualification. Category,
identification and numerical prerequisites still apply to every admitted path.

| Fit specification | Non-Person facet structure | Public location/contrast interval helper | Relevant comparison restriction |
| --- | --- | --- | --- |
| RSM/PCM MML, fixed N(0,1), fixed quadrature, unit weights | Ordinary additive facets, including three-facet implementation fixtures | `mfrm_facet_intervals()` supports model and Person/cluster sandwich methods | The population mean/SD are assumed known, not estimated from 20–60 Persons. |
| RSM/PCM MML with `population_formula=~1` | Ordinary additive facets; all non-Person locations centered | The helper rejects active population estimation | Population mean/variance and facet points exist; this does not supply the proposed contrast-CI comparison. |
| One-family GPCM MML, default free population | Ordinary additive facets, one slope owner; step owner may differ | The helper rejects this model; `confint()` covers slopes only | Public slope intervals and one-family curve intervals do not replace severity-contrast intervals. |
| Two-family GPCM MML | Exactly two facets, both slope owners; second owns steps | Experimental model-based location/contrast intervals | Subject to the observed-score rank restriction above; no sandwich, and curve calibration intervals remain unavailable. |

Source anchors are `R/api-facet-intervals.R::mfrm_facet_intervals()`,
`R/api-gpcm-intervals.R::confint.mfrm_fit()`, the population dispatch in
`R/api-estimation.R`, and `R/api-gpcm-curve-intervals.R`. Do not substitute
independently combined printed SEs or internal covariance extraction and call
that a validated public contrast consumer. An internal research calculation
would have to be named and verified separately. Also, `facet_shrinkage` is
post-hoc empirical-Bayes shrinkage; its `laplace` alias does not turn the
estimation into penalized MML or repair a failed likelihood fit.

**Separate a matched scientific comparison from default-workflow behavior.**
RSM/PCM defaults fix N(0,1); one-family GPCM defaults estimate a normal mean
and variance with geometric-mean-one slopes. Two-family GPCM fixes N(0,1),
leaves second-owner locations/slopes free and thereby uses a different
location/scale representation. Comparing defaults is useful as a user-workflow
question, but its differences cannot be attributed only to adding slopes.

For the scientific comparison, explicitly specify the ordinary/one-family
population and reconcile each model's scale with the two-family representation.
The preferred planning direction is estimated-normal ordinary comparators,
with `population_formula=~1`, the required Person ID table and centered facets;
the fixed-population ordinary route is a separately labelled assumption/output
comparison, not a way to conceal the missing interval consumer. This leaves
a concrete pre-execution decision about extending that consumer or limiting
the matched block to currently supported point/scoring/response targets.

One common response target can be defined at population-standardized ability
z: evaluate an estimated-normal fit at Theta=mu+sigma*z, and the fixed-N(0,1)
two-family fit at Theta=z, in identical declared rating contexts. This defines
a percentile-relative response curve, not a prediction at a known absolute
ability. Corresponding location differences divide by sigma and effective
slopes multiply by sigma under this transformation. The means, scale and
nuisance covariance must be propagated if intervals on such transformed targets
are later proposed; supplying estimated mu+sigma*z as a fixed `Theta` to the
existing curve helper does not perform that propagation. Use the declared
generating distribution for truth; do not recenter/rescale every simulated
cohort to force its realized mean and SD to the population values.

**Proposed applied blocks and the decisions they support.** These specify
roster/model comparisons, not a frozen Cartesian grid or an authorization to
generate data. These applied blocks ensure coverage of N=20/30/40/60 and add
prespecified medium/large-N comparisons where the use case is meaningful.
They supplement the full-range historical-design extension above. A rater-
training block need not be inflated artificially to represent a large test;
large incomplete assessment belongs explicitly in the multi-task/roster work.

| Block | Concrete baseline and controlled comparisons | Main question and supported scope |
| --- | --- | --- |
| Single-performance rubric assessment | Three Criterion levels, three Raters, four categories. Compare every Person rated by all three with two raters per Person, the same pair scoring all criteria. Then compare three versus six raters at two raters per Person. | How much do rater severity contrasts and Person scores change with overlap and rater exposure? The all-three comparison changes workload; the three-versus-six comparison preserves rating encounters but changes overlap and rater-level burden. This is the two-facet model-comparison block. |
| Multiple tasks scored with a rubric | Task x Criterion x Rater, initially two Tasks, three Criteria, three Raters and four categories, with two raters per Person-task. Compare two versus four Tasks; compare three versus five Criteria. | How are task difficulty, criterion difficulty and rater severity separated in small cohorts? Ordinary RSM/PCM and the additive one-family route are the fitting candidates; the current two-family route is excluded by capability, not counted as a failed fit. More tasks and more criteria have different workload/dependence implications. |
| Rater training on common performances | The same small set of Persons/performances scored by all three or all six raters, with three criteria and four categories. | Does shared evidence allow useful comparisons among the observed raters? Every rater still sees N independent Persons. This is a separate full-panel/workload contrast; do not infer generalization to a population of replacement raters. |

For two-rater assignments, a prespecified balanced-pair schedule should keep
per-rater Person counts within one where feasible and deliberately preserve
overlap. For three raters use the three distinct pairs; for six, cycle complete
round-robin matchings before repeating. Fix the schedule before scores and
randomize Person labels independently of ability. In the multi-task block,
the baseline changes partners across tasks where feasible; retaining the same
pair across all tasks is a separate allocation contrast. Specify pairwise and
task-specific exposure as well as overall rater totals. Do not assume these
rosters isolate a graph effect or that randomized labels imply MNAR robustness.

Use **criterion-owned steps** as a primary hypothesis within the rubric block, with
explicit `step_facet="Criterion"`. For the two-family route this means
`slope_facet=c("Rater","Criterion")` and
`noncenter_facet="Criterion"`; the rater slopes then have geometric mean one.
This is a block-specific modeling choice, not a package-wide preference or a
claim that category use cannot vary by rater. Retain rater-owned steps in the
historical-design core and a matched ownership comparison; switching the owner
is not merely relabelling, and
the old Task/Rater results cannot validate it. The multi-task rubric has a
third facet even when the same criterion is used on every task; do not combine
Task and Criterion IDs to pretend their effects were separated.

The primary questions are severity **contrasts** and Person scoring; component
slopes and shared response probabilities explain where restrictions help or
hurt. Prespecify contrasts by design role, not by which fitted rater looks most
extreme. For scoring, compare calibration-cohort and held-out Persons, reporting
conditional bias across true ability and uncertainty on its actual public
definition. Do not manufacture normal confidence intervals from `PosteriorSD`.
Probability/expected-score recovery is a common point target when component
parameters differ; rankings alone are not the primary success criterion.

Evaluate equal slopes, one varying family in each direction, and both varying
within the compatible two-facet block, with a separately stated step structure.
The three-facet block also needs a genuinely nonzero Task effect so that it does
not merely demonstrate fitting an unnecessary column. N x rater exposure and
N x category/criterion burden are core interactions. Ability-associated
assignment, within-performance dependence and sparse category support then
receive targeted contrasts and selected combined adverse cases. The OSCE
example remains a separate many-item/unequal-exposure design anchor; adapting
its assignment is not replication of its Bayesian interaction model.

Nominal 95% intervals remain a reporting target, not an automatic acceptance
rule. Practical adequacy additionally depends on the width/error acceptable
for the actual use; do not invent a universal logit or ranking tolerance.
Report effect magnitudes and Monte Carlo uncertainty until an application-
specific decision margin is justified. A later qualification decision must
freeze that margin and the treatment of unreturned estimates before its
confirmation sample. The existing 3-percentage-point coverage margin is not
silently inherited by this broader comparison.

### Staging decisions before any new calculation

Historical October 1 staging: the later empirical-score-rank correction and
native-location consumers resolve those two parts of item 1. The October 11
target/design reconciliation above identifies the remaining standardized-
contrast dependency. The temporary no-computation hold below was superseded
by the subsequent bounded-work instructions; this list is not a new hold.

1. Resolve the observed-Person-score rank policy and the population/contrast-
   consumer mismatch for the affected outputs before freezing their sampling
   comparisons. Keep current checks in place during review. These issues do
   not erase the distinct questions addressed by larger samples. Use both the
   historical-design core and the applied blocks to fix primary outputs and
   matched methods. Three-facet work starts from existing additive models;
   any two-family extension needs a separate necessity/identification decision.
2. Specify a correctly modeled core across N=20/30/40/60/120/240/480 with
   matched design definitions and selected complexity/exposure comparisons.
   Test N x rater exposure and N x category/parameter burden at multiple sample
   sizes; single-factor departures alone cannot establish them. Separately
   examine increasing N with increasing facet levels. Preserve all relevant
   completed larger-sample evidence and two-family development failures.
3. Add targeted robustness contrasts for restricted/nonnormal ability,
   task/rater targeting, ability-associated assignment, assigned-rating
   missingness, and within-performance dependence. Separate planned
   nonassignment from missing assigned scores. Use selected combined adverse
   settings as checks; do not claim robustness from testing each in isolation.
4. Select primary performance tolerances and replications from their Monte
   Carlo precision and decision consequences. Keep method comparisons paired
   by dataset, specify any shared randomness across designs, and reserve fresh
   data for any later confirmation of a method tuned during exploration.
   Neither 2,000 total fits nor 100/500 repetitions per cell is a new constraint.
   Independent new draws are not independent implementation validation.
5. Only after the design is settled and the current no-computation instruction
   is lifted, freeze inputs/procedure, perform the necessary execution checks,
   and launch an appropriately scoped study. The old elapsed-time estimates
   do not price the new small-cohort/multifacet comparison. Do not start with a
   timing pilot while scientific choices are still open.

This approach follows the separation of aims, generating mechanisms, estimands,
methods and performance in
[Morris, White and Crowther (2019)](https://pmc.ncbi.nlm.nih.gov/articles/PMC6492164/).
It supplies a planning framework, not a completed small-sample validation.
The proposed primary outputs, full-range core and applied blocks are specified above.
Open choices are the observed-score eligibility policy, matched population/
output contracts, application-specific tolerances, final parameter values and
allocation schedules, any justified consumer/model extension, and the resulting
condition/replication allocation. D1/D2 remain open.
