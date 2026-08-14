# GPCM literature-to-contract review for 0.2.3

Status: evidence review, not release authorization

Review date: 2026-08-07; implementation follow-through: 2026-08-11

Scope: the bounded one-slope-facet GPCM route in `mfrmr` 0.2.3

## Executive disposition

The implemented response kernel is a mathematically correct restricted form of
Muraki's generalized partial credit model (GPCM). Probability normalization,
adjacent-category logits, expected-score derivatives, and score information are
internally coherent. The positive log-slope expansion also enforces its declared
geometric-mean-one constraint exactly.

That result does **not** establish a full generalized many-facet model claim.
The current model estimates one positive slope for each level of the same facet
that owns the step parameters. It does not jointly estimate Uto and Ueno's
rater-consistency and task-discrimination factors, group-specific slopes,
person-by-rater random effects, or arbitrary virtual-item slopes. Accordingly,
bounded GPCM remains a slope-aware sensitivity route within the wider 0.2.3
claim portfolio.

The main mathematical qualification concerns scale. With JML, or with MML
that estimates a residual ability variance, the geometric-mean-one slope
constraint identifies a scale indeterminacy. The initial 0.2.3 MML route also
fixed the ability distribution to the standard-normal quadrature basis, which
made that route one dimension narrower than conventional GPCM. The correction
completed on 2026-08-11 makes an intercept-only free population distribution
the default for GPCM MML. Population SD now carries the common discrimination
scale. The former fixed-standard-normal likelihood remains available only as
an explicitly named restricted compatibility mode.

The earlier sealed v3/v4 score-calibration artifacts target that restricted
fixed-standard-normal likelihood and remain immutable. They are not replayed
under, or cited as full numerical validation of, the new free-population
default; a current-lineage numerical check must also cover the population
intercept and log-variance score coordinates.

## Audit of the supplied generalized-MFRM memorandum

The memorandum's central mathematical warning is accepted: "GPCM in an MFRM"
does not identify one universal model, and the owner and composition of every
slope and step block must be stated. Its Uto--Ueno (2020) adjacent-logit form,
the multiplicative scale indeterminacy, the separation of severity from slope
and category use, and the need to treat multidimensional rubric models
separately are substantively correct.

The following corrections and qualifications are material to the package
contract:

- The memorandum's reference `[1]`, DOI `10.1007/BF02296272`, is Masters
  (1982), not Muraki (1992). Muraki's GPCM article is DOI
  `10.1177/014662169201600206`. The former establishes PCM parameter
  separability; the latter introduces the varying-slope GPCM. They cannot be
  represented by one citation.
- Wang and Liu (2007) directly supports a multilevel, two-parameter facets
  model and a facet extension of GPCM. It is not, by itself, the source for the
  multiplicative rater-consistency factor `alpha_i * alpha_r`. Usami (2010)
  is an earlier direct source for a multiplicative item/rater discrimination
  decomposition and rater-related threshold spread; Uto and Ueno (2020)
  provides the later explicit task-by-rater GMFRM formulation.
- In Uto and Ueno (2020), `i` indexes a task. Treating it as a rubric criterion
  requires an additional design argument; Uto (2021) supplies the direct
  multidimensional rubric/evaluation-item formulation.
- Uto and Ueno (2020), equation 9, uses logistic scaling `D = 1`. Uto (2021),
  equation 6, includes `1.7`; dropping it is a rescaling rather than a verbatim
  transcription.
- The identification conventions are family-specific. The 2020 model fixes
  the geometric mean of the task-slope block, whereas the 2021
  multidimensional model fixes the geometric mean of the rater-slope block in
  addition to its latent-distribution, location, and step constraints. A
  generic phrase such as "use a product constraint" is not enough for an
  external match.
- The memorandum is correct that freeing slopes leaves the narrow Rasch-family
  sufficiency/specific-objectivity contract: an ordinary unweighted raw score
  is no longer the common sufficient statistic. For fixed unequal slopes, the
  likelihood instead exposes discrimination-weighted score information; when
  slopes are estimated, that statement is itself conditional on the fitted
  parameterization.
- A rater slope is conditional response steepness under the stated model. It
  is not direct evidence of test--retest consistency, rater competence, or
  absence of local dependence. Range restriction, omitted interactions,
  multidimensionality, and local dependence can reduce information or distort
  slope attribution without having one guaranteed direction of bias.
- Wu (2017) usefully separates severity, centrality, and discrimination, but
  its rater-as-item analyses are not a joint generalized-MFRM implementation
  template. Centrality/extremity, threshold structure, conditional slope, and
  residual fit therefore remain distinct evidence targets.
- Usami's Japanese and English abstracts report different initial examinee
  counts. Neither that application nor the small HMC simulations supplies a
  transferable minimum sample size for this package.
- As of this review, Uto and Ueno (2020) should be called a foundational direct
  source, not the uniquely latest formulation. Uto et al. (2024) adds a
  rater-by-rubric-item severity interaction and item-specific steps. That is a
  location/step extension, not an unrestricted cell-slope model. Uto and
  Aramaki (2024) further demonstrates that generalized-model scale linking is
  its own contract and cannot be inferred from within-sample fit.

The model-family and evidence consequences of this audit are specified in
`generalized-mfrm-model-ladder-0.2.3.md`. That ladder adds `SlopeOwner`,
`StepOwner`, `SlopeComposition`, and `LatentDimensionCount` as required future
model/evidence identities while retaining the current 0.2.3 support boundary.

## Mathematical cross-check

For an observation whose slope/step facet level is `g`, let

\[
  \eta = \theta - \sum_f s_f\delta_f,
  \qquad
  T_{gk}=\sum_{h=1}^{k}\tau_{gh},
  \qquad T_{g0}=0.
\]

The implementation evaluates

\[
  P(X=k\mid\eta,g)=
  \frac{\exp\{\alpha_g(k\eta-T_{gk})\}}
       {\sum_{c=0}^{K-1}\exp\{\alpha_g(c\eta-T_{gc})\}},
  \qquad \alpha_g>0.
\]

It follows directly that

\[
  \log\frac{P(X=k)}{P(X=k-1)}
    =\alpha_g(\eta-\tau_{gk}),
\]

which is the declared adjacent-category contract. Differentiating the
log-normalizer gives

\[
  \frac{dE(X\mid\eta,g)}{d\eta}
    =\alpha_g\operatorname{Var}(X\mid\eta,g),
  \qquad
  I_\eta(\eta,g)=\alpha_g^2\operatorname{Var}(X\mid\eta,g).
\]

The last identity is Muraki's GPCM information formula with logistic scaling
constant `D = 1`. The implementation uses log-sum-exp normalization and computes
the same conditional variance before multiplying it by `slope^2`.

The slope transformation is

\[
  \lambda_G=-\sum_{g=1}^{G-1}\lambda_g,
  \qquad \alpha_g=\exp(\lambda_g),
\]

so `sum(log(alpha)) = 0` and the geometric mean of the slopes is one.

### Independent numerical oracle, 2026-08-07

Twelve random predictor values, four slope/step levels, and five categories
were checked independently of the package tests.

| Identity | Maximum absolute error |
|---|---:|
| Probability rows sum to one | `8.882e-16` |
| Adjacent log odds equal `alpha * (eta - step)` | `1.332e-15` |
| Finite-difference `d E(X) / d eta` identity | `2.479e-09` |
| Fisher-information identity | `3.517e-09` |
| Geometric mean of expanded slopes | `1.000000000000000` |

Focused package tests also passed: 434 assertions, zero failures, zero skips,
and three expected review-only display warnings across `estimation-core`,
`gpcm-verification`, `information-module`, and `mathematical-consistency`.
The first attempted build encountered a stale Windows COFF object in the local
macOS arm64 tree; after that generated object was set aside and the native
object rebuilt, the tests completed normally.

### Contract-hardening follow-through, 2026-08-08

The first implementation tranche from this review is complete:

- public fitting, package, and GPCM-scope documentation now distinguishes
  geometric-mean-one relative slopes from their fixed-latent-SD values. The
  corrected GPCM-MML default estimates the common scale through population SD;
  the earlier fixed-standard-normal likelihood is an explicit legacy mode;
- DFF subgroup refits now replay the resolved rating range, response family,
  step/slope facets, observation handling, optimizer, MML engine, iteration
  budget, tolerance, and relevant support controls;
- active latent regression, facet interactions, and group-anchor constraints
  fail closed in the refit route until their subgroup linking contracts are
  implemented; and
- the fixed per-group sample-size sentence was removed. `min_obs` is now
  explicitly documented as a computability/sparsity guard rather than evidence
  of power or adequacy.

The focused DFF module passed 235 assertions with zero failures and zero skips;
23 expected category-support review warnings came from the existing fixture.
The GPCM capability suite then passed 203 assertions with zero failures,
warnings, or skips, including a non-null `slope_facet` replay check. A separate
real (unmocked) compact MML run replayed `GPCM`, rating range 1--4,
`slope_facet = "Criterion"`, and the direct engine in both subgroup fits. Both
subgroups remained weak-link and nonconverged at the deliberately compact
`quad_points = 5` / `maxit = 20` settings; that run verifies dispatch and
provenance only and is not stability or inferential evidence.
This closes a documentation/model-replay sub-gate, not the DFF inference,
operating-characteristic, or external-validation gates.

### Estimator-family audit, 2026-08-11

The supplied JML/PJML memorandum adds a useful distinction but its proposed
classification of mfrmr as finite-box or bounded JMLE is rejected. Source
inspection establishes the following contract.

| Route | Statistical objective and person treatment | Extreme/boundary consequence | Relation to mfrmr |
|---|---|---|---|
| Muraki (1992) | GPCM with random-person MML estimated by an EM route. | Person coordinates are integrated and then summarized, not fitted as one fixed parameter per Person. | Response-model and MML precedent; not the source for mfrmr JML. |
| mfrmr GPCM JML | Identified, unpenalized fixed-effects joint log-likelihood; log slopes have a sum-zero identification constraint. No finite lower/upper parameter box is passed to `optim()`. | A certified recession direction produces an extended-real or typed primary boundary result. A finite optimizer iterate is a numerical trace, not an attained finite maximum. | Current implementation. Numerical rejection of non-representable slope proposals is a line-search safeguard, not regularization. |
| Wijayanto et al. (2021) PJML | GPCM parameters are jointly fitted under an explicitly penalized likelihood. | The penalty can select finite values where ordinary JML has weak or receding directions. | Methodologically relevant alternative; a different objective and therefore not numerical-equivalence evidence for unpenalized JML. |
| `Rirt::model_gpcm_jmle()` | JML software route with documented finite defaults for ability, slope, location, and category-parameter bounds. | A box endpoint can be a constrained optimum even when the unconstrained likelihood has no finite maximizer. | Concrete box-constrained comparator; not a description of mfrmr. |
| Hessen (2025) fixed/random-effects distinction | In the fixed-effects formulation, Person and item parameters are fixed and jointly estimated; the random-effects formulation instead marginalizes over a population distribution. | With fixed test length, increasing the number of Persons alone does not generally remove JML item-parameter inconsistency. | Justifies a separate JML operating envelope indexed by information per Person/item, not a correction already implemented in mfrmr. |

Accordingly, `bounded GPCM` is retained only as a public-scope label. It means
one aligned slope/step owner and a deliberately restricted downstream workflow;
it does not mean a box-constrained estimator. A future PJML, extreme-score
adjustment, or finite-box option would require a new estimator-family code,
objective definition, output basis, and recovery/coverage evidence. Its finite
point estimates could not be described as maximizers of the present original
JML likelihood.

## Literature-to-contract matrix

| Topic | Literature implication | Current 0.2.3 contract | Disposition and gate consequence |
|---|---|---|---|
| GPCM probability kernel | Muraki's category numerator is the exponential of a slope-scaled cumulative adjacent-category expression. | `alpha_g * (k * eta - cumulative_steps_gk)` with positive slopes and stable normalization. | **Mathematical pass.** Retain exact probability, adjacent-odds, and reduction tests as release-spine evidence. |
| PCM reduction | PCM is the unit-slope special case of GPCM. | All optimizer slopes equal one at the origin; one slope-facet level has no free slope coordinate. | **Pass within the bounded family.** Preserve objective, gradient, probability, and output metamorphic reductions. |
| GPCM information | Muraki's information is squared discrimination times conditional score variance for logistic `D = 1`. | `score_information = slope^2 * Var(score | eta)`. | **Mathematical pass.** Continue external finite-difference and aggregation checks. |
| Slope scale | Conventional single-group MML fixes the ability scale and estimates absolute item slopes. Uto and Ueno use a product constraint to separate multiplicative task and rater slope factors. | All methods use `sum(log slopes) = 0`. Default MML estimates an intercept-only population distribution, so population SD carries the common discrimination scale and `sigma * alpha_g` is the fixed-latent-SD slope. The explicit legacy mode fixes both population SD and slope geometric mean to one. | **Reparameterized conventional degree of freedom by default; legacy route narrower.** External comparison must match the population/slope transformation and cannot compare raw slope labels alone. |
| Many-facet extension | Generalized rater models may include task discrimination, rater consistency, rater-specific scale use, and local-dependence effects. | One slope facet, required to equal the step facet; all other facets remain additive inside `eta`. | **Supported with caveat.** This is a restricted GPCM-MFRM sensitivity model, not Uto-Ueno GMFRM or an arbitrary virtual-item GPCM. |
| MML | MML integrates random person ability under an assumed distribution; EM is an algorithm, not the definition of MML. | Estimated-normal Gauss-Hermite integration by default for GPCM; direct BFGS/L-BFGS-B by default, with EM/hybrid alternatives. | **Framework pass.** Claims must remain conditional on latent-distribution and quadrature sensitivity. Do not describe the default engine as the Bock-Aitkin EM algorithm. |
| JML | JML avoids a person-distribution assumption but introduces one parameter per person, incidental-parameter bias, and extreme-score/boundary problems. PJML and box-constrained JML alter the objective or parameter space and must be named separately. | Fixed person effects, positive log-centered slopes, no statistical penalty or finite parameter box, and explicit readiness and boundary/recession review. | **Experimental/caveated.** JML GPCM cannot be promoted from convergence alone; retain finite/boundary, fixed-information bias, and external-estimand gates. |
| Bayesian MCMC and variational estimation | Priors can regularize complex rater/slope models; HMC handles high-dimensional models at greater computational cost. Recent variational work improves multidimensional GPCM computation. | No Bayesian GPCM estimator or posterior predictive checks. | **Deferred, not a defect.** Use Bayesian/HMC or external software as a sensitivity lane, not as evidence that the package already supports those estimands. |
| Fit statistics | Fit is multi-layered. Rasch infit/outfit describe residual behavior, but fixed universal cutoffs are not automatically calibrated for estimated-slope GPCM. Parametric bootstrap can materially change rater-fit decisions. | Slope-aware expected values, residuals, infit/outfit-like summaries, marginal and graphical screens; no GPCM-specific bootstrap calibration or PPC. | **Screening only.** Require null/non-null simulations or bootstrap critical values before operational thresholds. Keep residual, item/facet, marginal, local-dependence, and practical-impact evidence separate. |
| DFF/DRF | Severity DRF is analogous to uniform DIF; centrality/discrimination DRF is analogous to nonuniform DIF. General fit or infit/outfit does not establish DRF. | The residual method holds the baseline slopes fixed. Subgroup refits re-estimate bounded slopes, but the DFF table contrasts additive facet locations and does not expose or test the subgroup slope difference. | **Location-like screen only.** Current methods can flag conditional subgroup residual/location differences, but do not fit a joint group-by-facet slope/centrality effect. A refit location contrast can also depend on subgroup slope recalibration. Add separate uniform and nonuniform generating conditions before stronger claims. |
| DFF uncertainty | A valid inferential contrast must account for calibration, linking, covariance, multiplicity, and design. | Residual SE uses plug-in conditional score variances; refit SE combines subgroup SEs and omits baseline-anchor uncertainty/cross-refit covariance; both are explicitly ineligible for formal inference. Refit now replays baseline score/estimation controls and fails closed for active latent regression, fitted facet interactions, and group-anchor constraints. | **Replay sub-gate closed; inference remains unavailable.** Preserve `screening_only` and false-ready gates. Full covariance, resampling, and complex-model linking contracts remain open. |
| Sparse rating networks | Missingness is not the same as disconnection. Connectivity is necessary but link size, link location, link fit, category support, and local information affect precision; rater estimates are particularly link-sensitive. | Connectivity, estimability, category-support, sparse/weak-link, and readiness reviews exist; target-size and replicated recovery gates remain open. | **Open evidence gate.** Stratify complete, sparse-connected, weak bridge, articulation, routed, and disconnected designs. Never let numerical convergence override identification or weak local information. |
| Sparse categories | Collapsing adjacent categories in GPCM data can induce structural misfit and biased item parameters even when a fit index appears to improve. | Category support and empty/internal-gap checks are explicit; no automatic category collapse is part of the fitted likelihood. | **Maintain fail-closed policy.** Category collapse must be an analyst-declared alternative scoring model with a new data/estimand identity, not an automatic repair. |
| Sample size | Recovery depends jointly on persons, effective observations, category counts, slope dispersion, test/facet length, overlap topology, missingness, estimator, and target effect. Power differs by test statistic. | `min_obs = 10` is explicitly a computability/sparsity screen; DFF documentation rejects a universal per-group threshold and names the interacting design factors. | **Wording gate closed; empirical gate open.** Treat 10 as an NA guard only and derive adequacy from estimand-specific simulation or power analysis. |
| PCM-versus-GPCM choice | Better likelihood fit is expected when slopes are freed, but it changes weighting and validity interpretation. Small-sample Wald/score/gradient behavior can be poor; LR was more stable in the cited MML study. | Equal-weight RSM/PCM is primary; bounded GPCM is sensitivity-first; model-choice outputs carry integration and readiness gates. | **Strategic pass.** Keep the broad comparison portfolio, but require common data, likelihood, constraint, quadrature, readiness, and effect/power contracts. |
| Reliability / D-study | GPCM can be embedded in GT-IRT models, but reliability then depends on posterior measurement error and variance components for the intended relative or absolute decision. | Existing generalizability helpers are not a joint Bayesian GT-GPCM estimator. | **Do not conflate layers.** Treat current GPCM information/score precision and existing G-theory summaries as complementary, not a validated integrated GT-IRT claim. |

## Consequences for the 0.2.3 gate program

1. **Freeze the mathematical core, not the inferential envelope.** The kernel,
   constrained Jacobian, gradient, moment, and information identities are ready
   to serve as fixed structural gates. Numerical readiness still requires the
   high-dispersion and boundary grids already in the 0.2.3 program.
2. **Split slope claims by estimator.** JML uses geometric-mean-one as a scale
   identification convention. Default GPCM MML estimates the common scale via
   population SD while retaining geometric-mean-one relative slopes; only the
   explicit legacy mode fixes standard-normal population scale as well.
   External comparisons must reproduce the applicable transformation.
3. **Prespecify a multidimensional design grid.** Sample size cannot be a single
   `N`. At minimum cross persons, slope-facet levels, category support, exposure
   imbalance, ratings per person, common-person/link topology, slope spread,
   missingness mechanism, and estimator/engine.
4. **Keep recovery and detection separate.** Parameter RMSE/bias/coverage,
   PCM-versus-GPCM selection, fit-statistic Type I error/sensitivity, and
   DFF/DRF detection are different operating characteristics and require
   separate null/non-null cells.
5. **Add nonuniform DFF negative controls.** Generate group-specific slope or
   centrality effects that cross expected-score curves. The current location-like
   residual/refit screens must not be credited with detecting an estimand they do
   not fit. Refit tests must also prove exact baseline-model replay or fail closed
   when latent regression or facet interactions are active.
6. **Calibrate fit by design.** Prefer parametric-bootstrap or replicated
   simulation reference distributions for infit/outfit-like summaries. Retain
   graphical category curves, marginal/full-information checks, residual/local-
   dependence checks, and substantive impact as distinct evidence layers.
7. **Treat category sparsity as structural evidence.** Record counts and local
   information for every slope-by-step-by-category level. Do not pool rare
   categories merely to make an optimizer finish; a recode creates a new model
   and must be compared as such.
8. **Use likelihood sensitivity deliberately.** Compare direct MML, EM/hybrid
   MML, and JML only after matching estimands and constraints; compare Bayesian
   or external GPCM/GMFRM estimates in separate prior/model strata. Quadrature
   and latent-distribution sensitivity remain mandatory for consequential MML
   claims.
9. **Separate Person count from within-Person information.** The repository-only
   `gpcm-estimator-asymptotics-0.2.3.R` diagnostic now creates nested fixed-
   exposure and increasing-exposure sequences from one generated response
   table. Its smoke is directional only; the guarded replicated pilot must run
   before making any incidental-bias, estimator-selection, correction, or
   Bayesian-necessity decision.

## Zotero evidence consulted

The following local-library records were inspected through the Zotero local API;
indexed full text was used where available.

- Muraki, E. (1992), *A generalized partial credit model: Application of an EM
  algorithm* — Zotero item `5ECJR6HJ`.
- Muraki, E. (1993), *Information functions of the generalized partial credit
  model* — Zotero item `2QYG82FI`.
- Masters, G. N. (1982), *A Rasch model for partial credit scoring* — Zotero
  item `QRIZTW8H`.
- Bock, R. D., & Aitkin, M. (1981), *Marginal maximum likelihood estimation of
  item parameters: Application of an EM algorithm* — Zotero item `JG3JW3EC`.
- Robitzsch, A., & Steinfeld, J. (2018), *Item response models for human
  ratings: Overview, estimation methods, and implementation in R* — Zotero item
  `392NVGT8`.
- Wang, W.-C., & Liu, C.-Y. (2007), *Formulation and application of the
  generalized multilevel facets model* — Zotero item `SKBAV3HY`.
- Uto, M., & Ueno, M. (2020), *A generalized many-facet Rasch model and its
  Bayesian estimation using Hamiltonian Monte Carlo* — Zotero item `IR3LFDRM`.
- Uto, M. (2021), *A multidimensional generalized many-facet Rasch model for
  rubric-based performance assessment* — Zotero item `38TX837G`.
- Jin, K.-Y., & Eckes, T. (2022), *Detecting differential rater functioning in
  severity and centrality: The dual DRF facets model* — Zotero item `FLBCK7Q6`.
- Wind, S. A., Jones, E., & Grajeda, S. (2023), *Does sparseness matter?* —
  Zotero item `NBA428KJ`.
- Wind, S. A., & Jones, E. (2018), *The stabilizing influences of linking set
  size and model-data fit in sparse rater-mediated assessment networks* —
  Zotero item `F3CVK9EA`.
- Wind, S. A. (2023), *Detecting rating scale malfunctioning with the partial
  credit and generalized partial credit models* — Zotero item `TZSBP6N4`.
- Sinharay, S., & Monroe, S. (2025), review of IRT model-fit assessment — Zotero
  item `WRQ4F449`.
- Xiao, X., Patz, R. J., & Wilson, M. R. (2026), *Revisiting reliability with
  human and machine learning raters under scoring design and rater configuration
  in the many-facet Rasch model* — Zotero item `L59KNN8X`.

Title and DOI searches did not locate top-level local-library records for
Usami (2010), Wu (2017), Wilson and Hoskens (2001), or Jin and Wang (2018) on
the review date. Title searches likewise did not locate Uto et al. (2024) or
Uto and Aramaki (2024). Their claims were therefore checked against the
publisher or journal-hosted primary pages rather than treated as Zotero-backed
records.

## Web literature additions reviewed

- Muraki, E. (1992). *A generalized partial credit model: Application of an
  EM algorithm*. <https://doi.org/10.1177/014662169201600206>
- Wijayanto, F., Mul, K., Groot, P., van Engelen, B. G. M., & Heskes, T.
  (2021). *Semi-automated Rasch analysis using in-plus-out-of-questionnaire log
  likelihood*.
  <https://doi.org/10.1111/bmsp.12218>
- Wijayanto, F., Bucur, I. G., Mul, K., Groot, P., van Engelen, B. G. M., &
  Heskes, T. (2023). *Semi-automated Rasch analysis with differential item
  functioning*.
  <https://doi.org/10.3758/s13428-022-01947-9>
- Hessen, D. J. (2025). *A convexity-constrained parameterization of the random
  effects generalized partial credit model*.
  <https://doi.org/10.1111/bmsp.12365>
- `Rirt` 0.0.2 reference manual, including `model_gpcm_jmle()` and its
  documented finite default bounds.
  <https://stat.ethz.ch/CRAN/web/packages/Rirt/refman/Rirt.html>
- Wang, W.-C., & Liu, C.-Y. (2007). *Formulation and application of the
  generalized multilevel facets model*.
  <https://doi.org/10.1177/0013164406296974>
- Usami, S. (2010). *A polytomous item response model that simultaneously
  considers bias factors of raters and examinees*.
  <https://doi.org/10.5926/jjep.58.163>
- Wu, M. (2017). *Some IRT-based analyses for interpreting rater effects*.
  <https://www.psychologie-aktuell.com/fileadmin/download/ptam/4-2017_20171218/04_Wu.pdf>
- Wilson, M., & Hoskens, M. (2001). *The Rater Bundle Model*.
  <https://doi.org/10.3102/10769986026003283>
- Patz, R. J., Junker, B. W., Johnson, M. S., & Mariano, L. T. (2002).
  *The Hierarchical Rater Model for rated test items and its application to
  large-scale educational assessment data*.
  <https://doi.org/10.3102/10769986027004341>
- Jin, K.-Y., & Wang, W.-C. (2018). *A new facets model for rater's
  centrality/extremity response style*. <https://doi.org/10.1111/jedm.12191>
- Cui, C., Wang, C., & Xu, G. (2024). Variational estimation for the
  multidimensional GPCM. <https://doi.org/10.1007/s11336-024-09955-8>
- Quan, Y., & Wang, C. (2025). Category collapsing with sparse polytomous
  responses. <https://doi.org/10.5964/meth.14303>
- Zimmer, F., Draxler, C., & Debelak, R. (2023). MML power analysis including
  PCM-versus-GPCM tests. <https://doi.org/10.1007/s11336-022-09883-5>
- Xiao, X., Patz, R. J., & Wilson, M. R. (2026). Sparse scoring designs and
  MFRM/MFPCM reliability. <https://doi.org/10.1111/bmsp.70034>
- Zhu, P., & Reeves, T. D. (2026). Instructional review of GPCM/GRM item-fit
  indices. <https://doi.org/10.1080/07481756.2025.2608875>
- Uto, M., Tsuruta, J., Araki, K., & Ueno, M. (2024). *Item response theory
  model highlighting rating scale of a rubric and rater--rubric interaction
  in objective structured clinical examination*.
  <https://doi.org/10.1371/journal.pone.0309887>
- Uto, M., & Aramaki, K. (2024). *Linking essay-writing tests using many-facet
  models and neural automated essay scoring*.
  <https://doi.org/10.3758/s13428-024-02485-2>

These recent sources extend the evidence map; they do not by themselves close a
0.2.3 gate. Gate closure requires candidate-bound, prespecified, replicated
evidence under the exact package likelihood and claim contract.
