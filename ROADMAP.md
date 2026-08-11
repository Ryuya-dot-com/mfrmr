# mfrmr roadmap

Status: public roadmap, updated 2026-08-11.

This file is the single source of truth for mfrmr's public release direction.
It describes intended outcomes and support boundaries, not promises about exact
dates. Completed user-visible changes are recorded in `NEWS.md`.

## Current position

- mfrmr 0.2.2 is the current CRAN release, published on 2026-07-27.
- Development is focused on 0.2.3.
- The package currently supports one observed rating scale per fit and a
  unidimensional latent trait, with RSM, PCM, and bounded GPCM routes under the
  documented JML and MML contracts.
- Existing fitted-object person scoring is not the same as applying a saved,
  frozen calibration to new operational data.

## Direction

mfrmr aims to provide a transparent, reproducible, and reviewable MFRM
workflow in R. Its value is not defined as feature parity with FACETS,
ConQuest, TAM, or any other program. External programs are used as independent
comparators where estimands and parameterizations can be matched.

Its intended distinction is a direct many-facet specification combined with a
shared data-review, diagnostic, visualization, and reporting workflow for the
supported MML and JML routes. The project does not claim to be the first or
only R implementation of either estimator. A common interface also does not
imply that the two estimators have identical statistical maturity.

The project develops in this order:

| Version | Public goal |
| --- | --- |
| 0.2.2 | Published stabilization and contract baseline. |
| 0.2.3 | Establish the numerical and empirical operating envelope of the existing models. |
| 0.2.4 | Add typed fixed calibration, threshold/step anchors, and operational scoring for one observed scale. |
| 0.2.5 | Add explicit multiple-scale routing and mixed response structures without silent pooling. |
| 0.3.0 | Consolidate APIs, object schemas, compatibility policy, examples, performance evidence, and contributor workflows. |
| 1.0.0 | Declare a deliberately bounded, validated core stable. |

## 0.2.3: numerical trust and external validation

0.2.3 is primarily a validation release, not a new-model-family release. It
will strengthen evidence for the RSM, PCM, bounded GPCM, JML, and MML surfaces
published in 0.2.2.

The bounded-GPCM route is specifically an aligned single-owner model: one
selected facet owns both relative slopes and step profiles
(`slope_facet == step_facet`) on one latent dimension. Criterion-owned and
rater-owned uses require separate evidence and interpretation even though they
share code. It is not the multiplicative task/criterion-by-rater model, a
multidimensional generalized MFRM, or an unrestricted cell-slope model.
Maintainer evidence keeps those model families and their validation
dependencies in separate strata.

Priorities are:

- parameter recovery and numerical stability by model, estimator, and
  parameter class;
- standard-error and interval coverage where the interval definition is
  supported;
- stress tests for small samples, sparse and weakly linked rating designs,
  two-rater panels, planned and unplanned missingness, uneven rater workloads,
  rare, unused, and severely imbalanced categories, extreme scores, severe
  raters, and disconnected designs;
- separate JML evidence for finite optimizer traces, mathematically unbounded
  extreme-Person results, and extended profile-limit structural estimates;
  none may be relabelled as another, and profile-limit computation is not
  finite-item bias correction. The first internal paired recovery calibration
  supports that distinction but does not supply profile uncertainty, a
  preferred correction, or a numeric release rule;
- separate operating-characteristic studies for fixed facet interactions,
  bias/DIF screening, and exploratory residual-PCA signals, including null
  controls, planted alternatives, and confounded structures;
- matched JML comparison with FACETS, TAM, and immer for supported RSM/PCM
  estimands, preceded by explicit checks for category-map and step-dimension
  identity, constrained design estimability, extreme-score convention, and
  whether an unadjusted, extreme-score-adjusted, or bias-corrected estimator is
  being compared. The first internal TAM/immer normalization smoke now binds
  these mode identities to one common structural surface, but it is not a
  correction choice, recovery study, or release threshold. A subsequent
  22-dataset feasibility smoke makes Persons, realized exposure, Raters,
  Criteria, category count, assignment sparsity, workload imbalance, response
  endpoints versus extreme Persons, local dependence, anchors, and missingness
  first-class design identities. It keeps bias, RMSE, rank recovery,
  truth-SD/RMSE recovery separation, engine-labelled convergence, and evidence
  eligibility separate. It deliberately withholds common-surface SE coverage,
  reported Rasch/FACETS-style facet separation, and anchor comparisons until
  their covariance, definition, and common-basis contracts are aligned. The
  checkpointed 290-dataset follow-up is now complete and exposes four
  one-Rater-per-Person profile families as structurally unidentified, plus
  aliases between Rater count, assignment density, and exposure. Its
  five-replicate correction and recovery traces remain calibration-only, not
  sample-size recommendations, method selection, or release thresholds. A
  subsequent 36-dataset structural smoke now restores connected low-exposure
  assignment with explicit bridge Persons and audits assigned and observed
  Rater graphs. It shows that bridge percentage and total Person count cannot
  substitute for absolute bridge count and topology: adding Persons seen by
  only one Rater does not strengthen cross-Rater links. A second checkpointed
  36-dataset topology smoke now compares matched path, cycle, distributed, and
  hub allocations plus adversarial loss of one common-Person link. It shows
  that algebraic connectivity alone misses articulation-Rater and cut-edge
  vulnerability. It also finds natural extreme Persons in every connected
  low-exposure cell, making original raw JML ineligible throughout and blocking
  the unchanged replicated performance grid. The next comparison must separate
  an operational sparse/extreme lane from a raw-JML-eligible high-information
  lane and strengthen native convergence evidence before high-replication
  coverage or confirmation;
- matched MML comparison with ConQuest and TAM where likelihood,
  identification, and integration conventions can be aligned;
- conditional-likelihood results from immer as separate Rasch-family reference
  evidence where their estimands match, without treating CML or CCML as current
  mfrmr fitting methods;
- explicit classification of validated, caveated, exploratory, blocked, and
  unsupported combinations; and
- clear separation between optimizer completion, statistical readiness, and
  suitability for use.

For 0.2.3, MML and JML therefore receive separate recovery, uncertainty, and
failure-mode conclusions. JML bias correction is a research question rather
than a promised option. Conditional-likelihood estimation remains external
reference evidence. Hierarchical rater models address a different latent-data
and local-dependence structure and will not be presented as another estimator
switch for the current additive MFRM.

Repository validation can now reconstruct the extended JML likelihood
supremum after independently free extreme Persons are sent to their signed
boundaries. This remains a non-production evidence route until recovery,
uncertainty, sparse-design, runtime, and external-convention gates are complete;
it does not turn the original full finite JML vector into an attained MLE.

### Typed G-theory and D-study direction

The existing `mfrm_generalizability()` and `mfrm_d_study()` functions remain a
caveated univariate main-effects baseline: object and measurement-facet main
effects are estimated with `lme4`, while interactions are collapsed into the
residual and projected under explicit sensitivity assumptions. They are not a
general crossed, nested, or multivariate G-theory engine.

mfrmr will investigate a typed reconstruction rather than reproduce the
archived `gtheory` API by name. An eventual arbitrary mixed-model formula must
be paired with a design specification that identifies the object of
measurement, random and fixed facets, nesting, strata, and the role and exact
D-study scaling of every variance/covariance component. Formula syntax alone
cannot determine those meanings. Unresolved or aliased components will fail
before `E rho^2`, `Phi`, SEM, or a composite coefficient is formed.

The ordered path is:

1. during 0.2.3, freeze the design algebra, formula/effect-map parser,
   balanced crossed and nested negative-control fixtures, and reproducible
   evidence contract without broadening the public support claim. The first
   repository-only parser/algebra slice now reproduces hand-calculated p x i
   and p x r x i results and fails closed for unresolved, nested, or aliased
   designs. A second internal balanced-estimation slice now reconstructs raw
   ANOVA/MoM components, matches `lme4` REML on interior orthogonal fixtures,
   distinguishes ML and constrained boundary zeros, and reproduces the current
   collapsed-residual helper identity. A third internal slice now audits
   canonical retained/omitted rows, conditional nested identities, global and
   pairwise incidence, workload, cell replication, and fixed-effect-equivalent
   component ranks across complete, sparse, disconnected, nested, replicated,
   and missing controls. This remains a necessary pre-fit screen, not
   covariance-parameter identifiability or sampling recovery. A fourth
   repository-only slice now defines component-specific planned-weight
   allocation operators: uniform crossed plans reduce exactly to balanced
   divisors, nested levels retain conditional identities, unequal units remain
   unit-specific, and shared/disjoint support remains visible. It supplies no
   fitted components or uncertainty evidence. A fifth repository-only slice
   now audits component covariance-derivative rank, separates ML from REML
   expected-information rank, and binds `lme4` point estimates to the exact
   retained rows while distinguishing optimizer convergence, singularity, and
   boundary regularity. It remains point-estimation diagnostics, not recovery,
   interval, or coefficient-readiness evidence. A sixth internal slice now
   compares glmmTMB and lme4 only under an identical Gaussian ML/REML model and
   retained-row identity. Interior fixtures match; a positive-definite
   glmmTMB Hessian does not override boundary nonregularity or backend
   disagreement. No backend is selected. A seventh repository-only slice now
   freezes a 24-scenario pre-simulation ADEMP registry and exact denominator
   schema. It keeps Gaussian recovery, bounded observed-score projection,
   local-dependence sensitivity, boundary/identification controls, and anchor-
   rate nonapplicability separate; routes coverage to the later interval gate;
   and prevents successful-only pooling. No recovery run or replication count
   is claimed. An eighth repository-only slice now deterministically generates
   all 22 executable scenarios while leaving two anchor scenarios blocked. It
   separately hashes complete-potential, assigned, and post-missingness data;
   realizes exact density and within-Person counts; audits workload,
   categories, omission, dependence, and boundaries; and makes disconnected
   and aliased negative controls fail the pre-fit screen. This is generation
   evidence only: backend fitting, recovery, and zero-false-ready accounting
   remain later gates. A ninth repository-only slice now applies an exact
   scalable covariance-component rank audit to all generated data and binds it
   to the 89-unit manifest. Equality-signature compression avoids the dense
   N=300 covariance design while preserving exact rank and null directions for
   the current scalar random-intercept family. Nineteen scenarios/77 units are
   structurally eligible and three scenarios/12 units are blocked. No backend
   is called in that slice. A tenth repository-only slice now records all 89
   units through atomic balanced-MoM, lme4 ML/REML, and glmmTMB ML/REML
   adapters: 77 eligible fits are attempted and returned, while all 12 blocked
   units receive typed pre-fit failures. Exact-zero and identification controls
   produce zero passed gates, but all four near-zero likelihood routes pass the
   current optimizer/finite/boundary/local-curvature rule. The zero-false-ready
   gate therefore fails. An eleventh repository-only slice now freezes a
   separate 5-design x 6-variance x 4-route weak-information diagnostic
   registry and executes all 120 covering units. The existing whole-model gate
   yields 27/40 false-ready negative controls and 3/12 false-block positive
   controls, demonstrating that target-component weakness must be separated
   from nuisance-component fit failure. Ten truth-blind candidate observables
   are available, but no threshold or sample-size rule is selected. A twelfth
   repository-only slice now freezes the replicated execution architecture.
   Schema, feasibility, calibration, and confirmation use disjoint replicate
   bands; one generated scenario-by-replicate dataset is the independent unit
   and its four methods remain paired. Feasibility is 25 replicates/cell,
   calibration is 100, and sealed confirmation is 200, with primary operating
   characteristics reported by scenario and method. A 24-fit schema execution
   passes but cannot select a rule. Before effect recovery, the 3,000-fit
   feasibility phase was initially authorized but is now prospectively
   superseded before any reserved seed was generated. A thirteenth repository-
   only slice audits boundary variance-component inference against Self and
   Liang, Crainiceanu and Ruppert, Greven et al., and current lme4/glmmTMB/
   RLRsim contracts. It withdraws the noncommensurate common target-relative-
   SE candidate, executes 24 already viewed full/reduced ML/REML diagnostic
   pairs, retains four tiny negative numerical likelihood differences, and
   records 20/24 backend-coordinate local scales without treating them as
   tests or intervals. A fourteenth repository-only slice now registers and
   executes the exact-observed-design fitted-reduced-model bootstrap mechanics
   on the same three viewed controls. Its 12 observed routes and 36 `B=3`
   bootstrap pairs require 96 full/reduced fits; all return, exact design and
   generated-response identities pass, and failure-aware plus-one bounds are
   computable. Eight bootstrap pairs reach a non-target nuisance boundary and
   the Monte Carlo grid is 0.25, so the values are not test calibration. A
   replacement feasibility identity must keep resolution-score feasibility,
   bootstrap operating characteristics, positive-component recovery, and
   D-study stability as distinct gates. Production `B`, calibration, and
   confirmation remain unauthorized. A fifteenth repository-only slice now
   freezes that replacement feasibility identity without generating reserved
   data. The 3,000 rows bind 750 replicate-101--125 datasets to four methods and
   6,000 full/reduced fits. An all-cell, already viewed 120-pair runtime schema
   returns every route but retains nine unavailable common scores, including
   six materially negative nested likelihood differences. Timing-excluded
   hashes reproduce, and serial runtime sensitivity supports checkpointed
   execution. Only the descriptive feasibility run is now authorized; rule
   selection, inner bootstrap, calibration, and confirmation remain disabled.
   A sixteenth repository-only slice now executes all 3,000 authorized pairs
   and writes 3,000 atomic checkpoints plus 750 completion markers. All pairs
   return, 2,804 common scores are available, and a no-refit resume reproduces
   the scientific hash. High-information materially negative likelihood
   differences and few-level nuisance boundaries/weak ordering show that one
   universal resolution rule is not yet supportable. Feasibility accounting
   is complete, while numerical sensitivity, size/power calibration,
   positive-component recovery, D-study stability, thresholds, and
   confirmation remain pending. A seventeenth repository-only slice now
   re-fits every viewed route under three frozen optimizer profiles per
   backend: 9,000 pairs and 18,000 fits resume exactly. Same-algorithm tighter
   controls reproduce every default objective. lme4 bobyqa resolves all 34
   finite default-lme4 material-negative differences, but glmmTMB BFGS creates
   331 non-finite and 401 material-negative differences, so no universal
   optimizer winner is supportable. The strict replay contract also leaves
   seven non-finite-versus-non-finite defaults unadjudicated; numerical
   sensitivity, calibration, and D-study readiness remain false. An eighteenth
   repository-only slice now prospectively types those replay states and
   adjudicates only the immutable ledgers, without refitting: 2,993 finite
   matches and seven matching `NA_real_` diagnostic states leave zero
   mismatches. This closes the replay-definition gap, but deliberately keeps
   the b1e finite-only result and numerical-sensitivity readiness false. A
   backend-specific glmmTMB start/restart/gradient/Hessian contract remains a
   prerequisite to untouched calibration. A nineteenth repository-only slice
   now freezes that contract and a 9,000-pair/18,000-fit manifest over all
   1,500 viewed glmmTMB routes. Cold nlminb/BFGS, self restart, and cross-
   algorithm warm start form a symmetric non-adaptive DAG; all ten start
   blocks, parent failures, two gradient definitions, and Richardson Hessian
   diagnostics stay explicit. The manifest is ready, but its runner and
   execution are not yet authorized, and no diagnostic cutoff is selected. A
   twentieth repository-only slice implements the atomic runner and executes
   a 120-pair/240-fit viewed covering smoke. All 20 base checkpoints resume
   without fitting; 84 rows are diagnostic-complete, while 21 material-
   negative, 11 non-finite, and four typed fit/dependency rows remain. Two
   BFGS fits fail strict bitwise joint-state alignment, so full execution is
   not authorized. A twenty-first repository-only slice prospectively defines
   and tests the deterministic correction without choosing a tolerance from
   those failures. The same full 120-row denominator now has 120 returned
   pairs and exact aligned fixed coordinates for all 240 fits; four returns
   are recovered and none is lost, while common returned objectives,
   likelihoods, and parameter hashes remain unchanged. Fourteen non-finite,
   21 material-negative, and adverse gradient/curvature diagnostics remain,
   so this validates only state transport and resume mechanics. A separate
   prospective numerical-adjudication contract is required before the full
   18,000-fit execution can be reconsidered. A twenty-second repository-only
   slice now completes that no-refit adjudication without selecting a cutoff.
   It shows that all 120 pair objectives are finite, while glmmTMB masks the
   reported likelihood in 14 pairs because at least one Hessian is non-PD;
   one nonzero optimizer code and two gradient-surface mismatches were hidden
   by the earlier primary-state precedence. Across six-profile best-observed
   envelopes, 12 routes are positive and eight exact-zero routes remain small
   negative, with no material-negative envelope. These envelopes are neither
   global maxima nor an optimizer choice. A twenty-third repository-only
   slice now prospectively instruments the unchanged 120 pairs and retains
   raw parameter, gradient, and Richardson matrices for all 240 fits. Every
   b1g2 fitted quantity and repeated derivative hash reproduces. Spectral
   Hessian positivity holds for 224 fits but numerical Cholesky factors for
   only 221, while metric-minimizing and objective-minimizing profiles do not
   generally coincide. Raw, objective-relative, lme4-compatible, and
   Newton-type summaries therefore remain separate and unthresholded. The
   next gate must calibrate a prespecified stationarity rule on independent
   data before full stabilization execution can be reconsidered. A
   twenty-fourth repository-only slice now freezes the prerequisite
   calibration design without viewing reserved data. It separates finite
   stationarity, curvature/factorability, profiled log-SD boundary limits, and
   statistical component resolution; verifies affine Hessian-inertia and
   Newton-decrement identities; registers coordinate-dependent comparison
   metrics; and seals a 3,000-dataset workload corresponding to 144,000
   candidate fits and 24,000 reference problems. A twenty-fifth repository-
   only slice now calibrates the intensive reference mechanics before any
   reserved dataset is generated. It uses six analytic state fixtures, an
   AD-independent adaptive central-difference ladder, evaluation-order-
   invariant TMB random-effect starts, three deterministic optimizer families,
   Newton polishing, and nuisance-stationary boundary profiles. All four
   full/reduced objectives from nonreserved replicates 901--902 resolve and
   their content-addressed sidecars validate, so only the high-accuracy
   reference tolerances are frozen. Every production stationarity cutoff,
   calibration replicate 201--300, full stabilization run, bootstrap,
   inference, and D-study decision remains unauthorized. A twenty-sixth
   repository-only slice now audits whether that authorization can safely be
   issued. It corrects the prospective candidate-fit upper bound from 144,000
   to 108,000 because glmmTMB has six registered profiles while lme4 has
   three, freezes truth-blind candidate-state precedence and objective-only
   per-role profile aggregation, and finds that only glmmTMB REML has passed
   a nonreserved high-accuracy replay. Calibration remains sealed. A twenty-
   seventh repository-only slice now evaluates the same nonreserved datasets
   under a separately identified glmmTMB ML objective. All four full/reduced
   objectives, both nuisance-stationary boundary profiles, and a complete
   repeat execution pass, advancing reference coverage to two of four method
   lanes. A twenty-eighth repository-only slice now fixes the prerequisite
   lme4 objective identity without reading any response reservation. A dense
   Gaussian oracle reproduces the theta-only profiled ML deviance and REML
   criterion, analytic gradients, fit accessors, evaluation-order stability,
   and exact-zero full-to-reduced algebra. Namespace-bound negative controls
   exclude `devfun2()` and `deviance(..., REML=TRUE)` from REML reference work.
   A twenty-ninth repository-only slice now completes that lme4 replay. All
   eight ML/REML full/reduced objectives pass a three-algorithm box solver,
   independent sparse objective/gradient oracle, analytic Newton raw-KKT
   polish, positive free curvature, and content-addressed sidecars. All four
   seven-point nuisance-reoptimized profiles support finite interiors, their
   zero-theta endpoints match reduced objectives, and a complete repeat is
   exact. Reference mechanics are therefore complete for four of four method
   lanes. A thirtieth repository-only slice now freezes the truth-blind
   acceptance/indeterminate policy over 24 candidate family-zone pairs. It
   preserves scenario x method x model-role denominators, rejects any observed
   false-ready or false-boundary-handoff event, prevents an always-
   indeterminate rule from winning, and treats exact-binomial bounds as
   descriptive calibration scores without post-selection coverage. A thirty-
   first repository-only slice now implements the coordinate-correct
   production boundary probe. lme4 theta zero and glmmTMB log-SD limits retain
   separate nuisance-reoptimized paths and are joined only by the fitted
   reduced-model objective; flat, nonmonotone, endpoint-mismatched, and failed
   paths remain typed, and first-order zero is insufficient. A thirty-second
   repository-only slice now implements exact-resume mechanics. Atomic
   dataset-method checkpoints retain every optimizer profile, both model
   roles, both high-accuracy references, all 48 candidate decisions, and typed
   failures; interrupted, cold, and complete-reuse fixture executions have one
   scientific hash. A thirty-third repository-only slice now freezes the real
   production evaluator adapters and a runtime-, dependency-, output-, and
   shard-identified reserved run manifest. A four-lane nonreserved dry-run
   retains all 36 planned candidate fits, 192 decisions, and eight references,
   including one typed `start_snapshot` failure, while 100 exact calibration
   shards remain non-executable. This still does not open calibration. A
   thirty-fourth repository-only slice now completes the independent
   response-free one-way authorization preflight. It freezes 100 prospective
   non-executable shard manifests, proves their exact union and counts,
   performs an actual write / same-directory checked rename / readback /
   cleanup probe in the frozen output parent, and applies conservative
   32x-disk-plus-32-GiB and 4x-time planning with one concurrent shard.
   Readiness and activation eligibility are true, but no authorization record
   is issued and no reserved response is opened. The next gate must be a
   separately reviewed immutable activation artifact and authorized shard
   runner that repeat site/runtime checks before reconsidering replicate 201.
   A thirty-fifth response-free slice now audits whether the apparent
   simulation volume is scientifically proportionate. It distinguishes 3,000
   independent datasets and at most 100 trials per primary cell from 108,000
   dependent fit rows and 576,000 dependent decisions. Complete-denominator
   0/100 gives a one-sided 95% upper bound of 0.029513 and detects at least one
   event from a true 3% rate with probability 0.952447. The design is retained
   for numerical-rule calibration only; broad bias/RMSE/coverage and D-study
   operating-characteristic claims require a separate precision-designed
   study. The next gate remains the independently reviewed activation artifact
   and authorized runner, and nominal n=100 cannot rescue unresolved cells. A
   thirty-sixth response-free slice now performs the stronger pre-activation
   hardening audit and stops execution. The exact 9,756 phase-specific seed
   rows are collision-free, but a nonreserved same-integer-seed control changes
   data when ambient `RNGkind()` changes. The upstream runtime hash also omits
   RNG, BLAS/LAPACK, locale/timezone, glmmTMB parallel state, and numerical-
   library thread state; no isolated vanilla process, reserved-only runner,
   exclusive writer lock, activation marker, typed initial/resume root, or
   per-shard capacity recheck exists. Eight gates therefore supersede the
   narrower b1g15 activation-eligibility conclusion. The next work is RNG,
   runtime, and runner hardening followed by downstream nonreserved re-freezing;
   replicate 201 remains sealed. A thirty-seventh nonreserved slice now
   preserves the historical generator and adds a separately hashed wrapper
   that explicitly fixes all three RNG kinds, records them in identity, and
   restores caller state. All 30 scenarios at replicate 901 reproduce across
   two ambient RNG configurations, and reserved bands fail closed. This makes
   the prospective generator component ready, but the existing candidate and
   reference adapters still bind the historical identity. Consequently
   `AuthorizationRNG01Closed=FALSE`; downstream nonreserved adapter re-freezing
   remains the next ordered gate and no large simulation may start. A thirty-
   eighth slice now completes that nonreserved adapter rebase under a new
   descendant identity. Historical and hardened glmmTMB/lme4 x ML/REML paths
   have exact semantic parity over 36 fit rows, 192 decisions, eight references,
   and the complete one-failure denominator; four hardened checkpoints reuse
   exactly. The prospective reserved manifest and entry point are deliberately
   not rebuilt yet, so the authorization-level RNG gate remains open and no
   large simulation may start;
2. after validation, consider a univariate crossed/nested observed-score
   engine using `lme4` as the primary Gaussian backend and `glmmTMB` as a
   separately identified parity/structured-covariance backend;
3. add full-refit checkpointed bootstrap intervals that recompute each D-study
   scenario, rather than propagate marginal component endpoints; and
4. only with explicit `ScaleId`/stratum and shared-facet allocation identities,
   prototype multivariate component covariance matrices and weighted
   composites. Composite reliability will use the full covariance matrices,
   not averages of univariate coefficients. A repository-only supplied-matrix
   algebra preflight now implements this quadratic-form and allocation-overlap
   oracle, including one-stratum reduction and PSD/rank controls. It does not
   estimate covariance matrices or broaden the public API; the univariate
   recovery and uncertainty gates remain prerequisites for a multivariate
   estimator.

Balanced ANOVA/method-of-moments remains an independent oracle because it can
expose negative raw sampling estimates. Likelihood backends constrain variance
components to be nonnegative; their boundary zeros must not be described as
raw negative estimates or silently repaired. Sparse, unbalanced, missing, and
nested designs require component-specific rank and allocation audits, not a
median facet-count shortcut. The full internal sequence and promotion gates are
recorded in `gtheory-reconstruction-roadmap-0.2.3.md`.

The 0.2.3 exit decision is claim-based. A model, estimator, parameter class,
diagnostic, or comparison is promoted only when its own evidence and failure
behavior are adequate. An unresolved exploratory surface does not have to be
promoted merely because it is callable: it may remain explicitly exploratory,
be disabled for primary use, or be deferred. Conversely, a caveat cannot be
used to excuse a defect in a result that remains part of the supported core.

The current portfolio checkpoint stops further G-theory execution-
authorization engineering and does not treat a technically runnable shard as
a scientific obligation. Before any new high-replication study, the retained
0.2.3 claim, the decision the study can change, the independent sampling unit,
the target precision, and a cheaper sequential alternative must be explicit.
If algebra, a deterministic reduction, or a matched external microcase can
answer the question, it comes first.

The claim-disposition review now maps the 106 evidence items to 53 mandatory
release-spine items, 32 claim-conditional items with explicit fail-closed
fallbacks, and 21 later or research items that do not block 0.2.3. This mapping
does not mark any evidence as passed. It prevents unfinished G-theory,
multidimensional, diagnostic-promotion, broader-GPCM, or secondary external-
aggregation work from becoming an accidental release dependency while keeping
the numerical, sparse-design, external-core, public-contract, and release-
engineering obligations for the retained supported core.

The deterministic follow-up audit is also complete. All nine conditional
fallback classes now have a fail-closed public decision route. It corrected
the JML wording to retain only explicitly exploratory observation-table SEs,
made residual-PCA non-promotion machine-readable in result/summary/plot
objects, and propagated exact GPCM slope/step ownership plus the
model-conditional-discrimination interpretation through fit summaries and
central boundary tables. These changes promote no conditional claim. The next
priority is therefore the 53-row release spine, not conditional simulation.

The five-category GPCM extreme/surface audit is recorded in
`gpcm-extreme-and-surface-audit-0.2.3.md`. It confirms the intended distinction
between a JML all-maximum Person (`+Inf` primary estimate; finite optimizer
trace only), an MML all-maximum Person (finite prior-regularized EAP), and an
all-maximum Rater (observed support boundary, with a certified relative JML
joint recession direction in the challenge design). Fit summary now separates
support warnings from parameter recession certificates, and standalone
diagnostic summaries inherit the source fit's readiness rather than appearing
to overrule it. Central functions execute and plots remain visibly review-only,
but this promotes no GPCM capability row: global additive/log-slope boundary,
covariance/SE/CI, owner-specific evidence, and external overlap remain open.

The first runtime-propagation slice is now stable for retained RSM/PCM fits.
Manifest, export, and replay surfaces preserve the exact v3 source-readiness
record, while replayed fits recompute rather than inherit readiness. Optimizer
code convergence and inference readiness are separate manifest fields, and
JML/MML iteration-limit plus legacy-object controls remain fail-closed. This
does not close checklist row 23: complete parameter/step/interaction
propagation, lower-priority saved/export adapters, and an exact-candidate replay
remain open. A real saved fit from the frozen CRAN 0.2.2 tarball now fails
closed as `legacy_unknown`, while a fresh-session development replay obtains a
separate new v3 decision and emits the required mismatch warning. The central
results/report/checklist/APA routes now preserve the exact source record and
cannot override a blocked fit with a diagnostic precision flag. The remaining
identity/contract gaps come before simulation.

Two upstream numerical contracts have now been separated. Binary RSM/PCM and
unit-slope GPCM/PCM reductions pass deterministic likelihood, probability,
marginal-objective, common-score, and parameter-transform checks against a
separately implemented oracle; this closes only those exact special cases.
The non-unit extension now agrees at retained, high-dispersion, and two finite
slope-stress points spanning slopes about 0.05--20.1, using an independently
expanded slope map, GPCM response kernel, Person-wise marginal objective, and
numeric free-coordinate score. Its 47 focused expectations also fail closed
under missing, duplicated, numerically drifting, or authorization-mutated
evidence. This removes the unit-slope-only shared-error gap but remains
calibration evidence because additive/step/population expansion is partly
shared. The bounded owner/category/topology follow-up was designed without
launching another large simulation: eight
five-category cells cross Criterion/Rater ownership with core, one-Person weak
bridge, workload imbalance, and category imbalance. Owner pairs share the same
deterministic 40-Person/four-Rater/four-Criterion data, avoiding a recovery
simulation where a formula check suffices. Four points and four parameter
classes produce 128 mandatory evidence strata under a five-point
derivative ladder, hard absolute/scaled caps, an independently estimated
numeric-error allowance, and explicit slope-Jacobian caps. The 63 design tests
fail closed on any missing stratum or rule violation. These are calibration-
evaluation guards, not the final general `NUM-SCORE-TOL`.
The `maxit` policy now also has a repository validator for prespecified ceiling
order, unchanged analysis identity, and first-eligible-run selection, but its
release evidence remains pending exact-candidate application. Neither result
freezes a general stationarity tolerance for GPCM. Automatic grid expansion is
not the fallback after a failed bounded calibration.

That bounded v2 calibration has now been executed once and retained as a
negative calibration. All 128 evidence strata and all 32 structural-oracle
point checks were evaluable, but 33/672 coordinate rows and three Jacobian
point rows failed the conjunctive absolute-and-scaled rule, so the immutable
v2 result is `rejected`. Three retained vectors had slopes around 2.5e5--3.3e6;
coordinate-relative objective differences could not simultaneously remain
local on the GPCM logit scale and avoid subtraction cancellation. A separate
48-stratum analytic attribution reconstructed the Person posterior and GPCM
sufficient-statistic score and agreed with the package to at most 1.05e-9,
without changing v2. The next rule must therefore separate finite-slope
stationarity from extreme-slope boundary handoff and use combined absolute-
plus-relative margins. It must not reinterpret extreme finite optimizer traces
as finite maxima or inference-ready estimates.

A no-execution v3 rule contract fixed that separation before retrospective
re-adjudication. It requires independent analytic-score and transformation
agreement at every finite point, applies one combined absolute-plus-relative/
numerical-error finite-difference allowance only when the expanded sum-zero
log slopes satisfy `max(abs(z)) <= 3`, and sends points outside that envelope
to an explicitly non-promoting review handoff. Its 43 focused expectations
pass. An artifact-reuse audit found only 48/128 independent analytic strata
and no reconstructible entrywise combined-Jacobian ratios, so aggregation was
not reverse-engineered into a pass.

The ensuing replay exposed a more fundamental reproducibility defect before
its first nominal pass could be accepted: log-sum-exp stabilization used
`max.col()` with R's random approximate-tie default. Identical weak-bridge
fits consequently changed optimizer code, objective, and retained slopes.
Likelihood and prediction paths now use deterministic first-maximum ties and
optimizer caches keep owned parameter snapshots. Consecutive weak-cell fits
are RNG-neutral and bitwise identical on all numerical and non-timing stage
fields. This source change invalidated the earlier v2/v3 payloads. Under the
corrected payload, unchanged v2 again rejected the same 33/672 coordinate and
three/32 Jacobian rows; its 48-stratum analytic attribution passed to maximum
absolute difference `1.92e-9`.

The corrected identity-bound v3 replay then completed 672 coordinate rows,
128 evidence strata, 32 point summaries, and 384 entrywise Jacobian rows.
All v3 components passed; maximum combined ratios were 0.172 for independent
analytic score, 0.00175 for finite differences, 0.172 for expanded-log
Jacobian, and 0.268 for positive-slope Jacobian. Three retained points entered
the extreme-slope review handoff, and all eight fits remained review-only with
`InferenceReady = FALSE`. Thus v3 is ready as a bounded retrospective
calibration rule, while v2 remains rejected. No general `NUM-SCORE-TOL`,
boundary proof, finite extreme-slope maximum, inference readiness, or
confirmation is established.

Freeze review then found that the replay identity had not named the numerical
helper supplying coordinate and Jacobian calculations. The runners now reload
their declared validation sources, and both v2 and v3 identities include that
helper hash. A source-bound rerun was numerically identical and the freeze seal
binds nine validation sources, the complete package payload, all three retained
artifacts, and their full denominators. The bounded v3 rule is now frozen only
for disjoint confirmation. The next step is to specify and seal disjoint
exact-candidate fixtures and their execution contract without changing the
rule; confirmation execution is not yet authorized.

The disjoint confirmation fixture layer is now sealed without fitting. It uses
three deterministic noncalibration structures (37x3x5 with four categories,
43x5x3 cyclic-sparse with five categories, and 46x4x6 workload-imbalanced with
six categories), each under Criterion- and Rater-owned slopes. The complete
future denominator is six scenarios, 96 evidence strata, 560 coordinates, 24
points, and 376 entrywise Jacobian rows. Fixture hashes and the unchanged freeze
identity are fixed, but execution remains NO-GO until a dry-run-by-default
record-consuming runner and separate fresh-process/output-absence authorization
contract pass negative tests.

The record-consuming runner and separate authorization boundary now exist.
Dry-run binds the exact candidate payload, freeze seal, design, fixture hashes,
manifest, and runner identity without fitting. Its future decision checks all
class-specific coordinate and scenario/point Jacobian denominators rather than
totals alone. The authorization layer independently requires a fresh-process
attestation, explicit request, matching runner/manifest, existing parent, and
absent target. Negative and synthetic issuance tests pass, but the actual
default decision remains `no_go_not_issued`; no confirmation result has been
opened. A future continuation may issue and consume one target-bound record in
one fresh process, with no result-dependent retry or rule change.

That one-time v3 confirmation has now been consumed and rejected with complete
96/560/24/376 denominators. All analytic-score, structural-oracle, finite-
difference-where-applicable, and both Jacobian rules passed. The rejection came
from the frozen constructed-point clause: a six-level sum-zero stress point
intended at the inclusive boundary three was represented as
`3.0000000000000009`, so the raw `<= 3` classifier sent it to the extreme
handoff. No retry or tolerance change was made. Post-execution review also
found that the consumed in-memory authorization row was not embedded in the
result artifact; even a numerical pass would therefore have lacked complete
acceptance provenance. V3 remains negative calibration evidence. The next
bounded lineage is a no-execution v4 contract with error-analysis-based
boundary representation and embedded authorization provenance, followed by a
new disjoint fixture set—not a rerun or large simulation.

A no-execution v4 rule is now specified. It leaves all four v3 comparison
rules unchanged and applies a binary64 forward-error allowance only to
contract-constructed inclusive-boundary points. The allowance is the sum of
input-rounding, `gamma_n` sequential-summation, and comparison bounds; retained
solutions receive zero allowance. For the observed six-level construction the
derived bound is 6.91e-15 versus an 8.88e-16 excess. V4 additionally requires
the exact consumed authorization row in every saved result and forbids post-
hoc reconstruction. The opened v3 fixtures are calibration-only. V4 review,
retrospective calibration, identity freeze, and a new disjoint confirmation
family remain pending.

No-fit retrospective v4 calibration now reconstructs all 24 expanded slope
vectors from the rejected v3 artifact. Exactly the intended six-level boundary
point changes region, with 8.88e-16 raw excess below the 6.91e-15 derived
bound; every retained extreme remains unchanged. The result is deliberately
`classification_calibrated_numerical_evidence_incomplete`: v3 saved no finite
difference for that formerly extreme point, and its consumed authorization row
is absent. Neither can be inferred from aggregates. V4 is therefore not frozen.
The next bounded step is a new calibration-only deterministic boundary fixture
with embedded authorization provenance—not a v3 refit, confirmation reuse, or
large simulation.

The single boundary-completion design is now sealed without fitting: one
Criterion-owned 31x3x6, four-category complete fixture with new level
namespaces and full owner-category support. It targets only the six-level
forward boundary and fixes four evidence rows, 24 coordinates, one point, and
30 Jacobian rows. The fixture is calibration-only and permanently ineligible
for confirmation.

Its dry-run runner and separate target-bound authorization boundary are now
implemented without fitting. Exact runner/source/payload/design/rule/manifest
identities, the 4/24/1/30 denominator, same-process issuance, exact output path,
authorization-source hash, issued-row hash, consumed-row hash, and absent target
are checked fail-closed. Forty-four no-fit expectations pass.

The one fresh-process issue-and-consume operation has now completed without
retry. The fixed 4/24/1/30 denominator passes: the maximum analytic-score,
finite-difference, log-Jacobian, and slope-Jacobian combined ratios are
5.05e-05, 6.33e-04, 0.203, and 0.282. The saved artifact embeds verifiable
issued and consumed authorization hashes. An independent no-fit validator pins
its artifact identity, source chain, manifest, aggregation, and non-promotion
boundary;
numerical and authorization tampering are rejected. The target was recorded in
repository-relative form, resolves to the artifact, and is disclosed as not an
absolute-path record. The result is calibration-only and the fit remains
`review`.

A no-execution source/artifact seal has now frozen the bounded v4 rule and
calibration interpretation for a future structurally disjoint confirmation
design. It verifies the unchanged four numerical rules, constructed-versus-
retained allowance separation, unique retrospective reclassification, missing-
derivative completion, authorization provenance, repository-relative target
disclosure, and all non-promotion flags. This permits design—not execution—of
new confirmation fixtures. General score tolerance, a global slope-boundary
claim, confirmation execution, inference, and release promotion remain false.

That new confirmation design is now sealed without fitting. Three deterministic
structures cover 50% to 75% unobserved assignment cells, near-balanced and 4.42
rater-load imbalance, 5/6/7 categories, 4/5/6/7/8 owner-level counts, and both
Criterion- and Rater-owned slopes. New versus protected Person, Rater,
Criterion, and fixture identities have zero overlap. The six scenarios fix
96 evidence, 888 coordinate, 24 point, and 688 Jacobian rows. A dry-run-by-
default runner and separate same-process authorization now bind the complete
manifest. They reject relative or occupied targets and require the eventual
target to be supplied in absolute form. A runner-independent validator was
sealed prospectively and bound into authorization; 74 no-fit expectations
passed. The confirmation was then consumed once without retry. All fixed
numerical rows and aggregations pass, but two Criterion-owned fits reached the
iteration limit and are blocked. The runner omitted fit readiness from its
final aggregation and therefore reported a false-positive candidate pass. The
sealed validator also exposed a names-attribute false negative; a no-fit
retrospective audit separates that defect from the independently failing fit
gate and rejects confirmation. No retry or rule change is authorized. This is
a negative process/fit result, not a large simulation or a general boundary
claim.

Near-term external work therefore returns to matched RSM/PCM evidence. The
existing item-only ConQuest ladders require independent candidate-bound
replication, and the broader MFRM claim needs a separate additive
Person/Rater/Criterion overlap before any general ConQuest comparison is
considered. Native machine-readable exports, raw reported precision,
likelihood and constraint identity, integration controls, stopping rules, and
termination state are part of that comparison. Screen-rounded values and
same-named fit statistics are not acceptance evidence. A ConQuest
`scoresfree` GPCM result is compared with bounded GPCM only after an exact
probability-level parameter map exists; raw slope labels are insufficient.

G-theory remains a 0.2.3 contract/parser/algebra prototype. Its large
numerical-rule simulation is deferred unless the claim-disposition review
shows that a retained 0.2.3 decision genuinely depends on it. Recovery,
coverage, D-study stability, and multivariate covariance estimation retain
their later version-specific precision designs rather than inheriting the
numerical-rule replication count.

Repository tests follow the same boundary. Contract, schema, hash, mutation,
and fail-closed checks remain in the ordinary suite. Four isolated fitting and
exact-resume validations are opt-in with
`MFRMR_RUN_GTHEORY_SLOW=true`; skipping them in ordinary CI is a scheduling
decision, not positive evidence or removal of the archived validation.

Passing simulation and software-comparison checks does not establish construct
validity, fairness, population transportability, or suitability for a
high-stakes decision. Those require separate domain evidence.

## 0.2.4: fixed calibration and operational scoring

The next feature release will target a typed, versioned calibration object for
one observed scale. It is expected to include:

- element, group, and threshold/step anchors with explicit conflict checks;
- saved-calibration provenance and integrity checks;
- scoring of new data with explicit behavior for unknown levels, missing
  categories, disconnected cases, and out-of-range scores; and
- round-trip and compatibility tests that distinguish a fitted object from a
  validated frozen calibration.

## 0.2.5: multiple observed scales

Multiple rating scales will be represented by an explicit per-observation
`ScaleId`. Scale identity will not be inferred from category values. A
separate observation-model identity will describe the response family and the
facets active for each observation; `ScaleId` alone will not be overloaded to
perform both jobs. The work will begin with multiple ordinal scales that
reduce exactly to the existing single-scale model, then add scale-specific
category maps, PCM step structures, calibration namespaces, connectivity
checks, diagnostics, and reporting. Mixed response-family and active-facet
routing will be promoted only after their own identification and reduction
tests pass.

Multiple observed scales do not automatically imply a multidimensional latent
trait. Native multidimensional estimation and dimension-specific scores remain
separate research claims.

## 0.3.0 and 1.0.0

0.3.0 will emphasize consolidation: stable schemas, documented compatibility
and deprecation behavior, reproducible case studies, a performance envelope,
versioned validation resources, and independent methodological/code review.

1.0.0 will mean that the declared core has stable estimands and APIs,
replicated recovery and negative-control evidence, matched external evidence
where appropriate, cross-platform verification, and an explicit support
envelope. It will not mean support for every MFRM design or FACETS feature.

## Research boundary

The following are research tracks rather than committed near-term features:

- unrestricted GPCM structures;
- native multidimensional MFRM and dimension-specific scores;
- Bayesian or MCMC backends and posterior-predictive checks;
- joint GT-IRT/GPCM models and multivariate G-theory outside the explicitly
  validated typed observed-score design subset;
- mixture, unfolding, and specialized rater-process models;
- automatic DIF/DFF decision rules; and
- distributed or high-performance estimation engines.

A callable experimental helper is not by itself a public support claim. A
feature becomes supported only after its estimand, identification, failure
behavior, recovery evidence, documentation, and compatibility contract agree.

## Permanent principles

1. Unknown or unidentified designs fail closed or carry an unavoidable caveat.
2. External agreement is evidence within a matched overlap region, not proof
   that either program is ground truth.
3. Failed cells and failed replications are never hidden by pooled summaries.
4. Exploratory diagnostics remain exploratory until independently validated.
5. Public code, help, examples, capability tables, and release notes must state
   the same support boundary.
6. Slow validation remains reproducible without becoming a required runtime
   dependency or routine CRAN workload.
