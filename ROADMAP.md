# mfrmr roadmap

Status: public roadmap, updated 2026-08-13.

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

Here, bounded describes the public model/workflow scope, not finite parameter
boxes. The current GPCM JML estimator is an unpenalized, identified fixed-
effects joint likelihood with post-fit recession auditing. Muraki's MML-EM,
Wijayanto et al.'s penalized JML, and box-constrained JML implementations are
distinct estimator families and are not numerical-equivalence targets without
an explicit objective map. In particular, a finite penalized, adjusted, or
box-constrained estimate is not called the maximizer of mfrmr's original JML
objective. This separation is now part of fitted-object summary, print, and
plot metadata.

For GPCM MML, 0.2.3 now estimates an intercept-only population distribution by
default while retaining geometric-mean-one relative slopes. The population SD
therefore carries the common discrimination scale; this is a one-to-one
reparameterization of the conventional fixed-latent-variance GPCM in the
documented item-only ConQuest overlap. The former fixed-standard-normal plus
geometric-mean-one likelihood remains available only as an explicitly named
legacy restriction. JML continues to use geometric-mean-one slopes as a true
identification constraint on jointly estimated person coordinates.

The sealed v3/v4 GPCM score artifacts remain attached to their historical
fixed-standard-normal package payload. They are not reinterpreted or replayed
as evidence for the free-population default. A future current-lineage numerical
candidate must cover the population intercept and log-variance coordinates in
addition to the relative-slope block; this is a bounded deterministic gate,
not a reason to resume broad simulation.

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
  identification, and integration conventions can be aligned. The first
  actual ConQuest additive RSM/PCM binding now routes 36 prespecified
  coordinates through the common eligibility ledger. All are finite. Under
  the hidden-solution interpretation, zero rows remain eligible because the
  native CSV rounding rule and unprinted precision are undocumented. Under the
  separately frozen exact reported-decimal policy, all 36 rows are
  structurally eligible for that narrower metric. This completes source-
  precision plumbing, not comparison acceptance. A prospective tolerance
  precedes any candidate-bound rerun. The prospective-freeze validator is now
  implemented over 19 cross-engine binary/RSM/PCM estimand rows and 38 engine-
  specific integration-stability rows. Its generic empty template remains
  `pilot_required`, while the source-bound canonical table now freezes all 57
  future-candidate-only engineering budgets. The cross-engine rules are
  `1e-5` for common coordinates and `2e-6` for deviance; both q61-minus-q31
  units use `2e-6`. The opened calibration cannot pass these rules, and the
  freeze does not establish hidden-solution/scientific equivalence. The first
  six-arm candidate was invalidated before execution because its RSM/PCM
  commands were item-only and omitted the Rater/Criterion estimands in the
  57-row table. Corrected candidate 002 binds six command/input identities,
  an estimand-derived model-dimension registry, and 50 expected-empty output
  paths. Its additive RSM/PCM arms use `rater + criterion + step` and
  `rater + criterion + criterion*step`; all model statements, facet
  declarations, nodes, input schemas, free dimensions, estimand classes, and
  local hashes match, while every expected output remains absent. The clean
  core remains six arms (`Binary/RSM/PCM x q31/q61`), because the 57-row
  registry cannot be evaluated by the four additive RSM/PCM arms alone. The additive
  reported points have now been evaluated on a common likelihood: deviance
  increases over the mfrmr point are below `4.75e-10`, all local Hessians are
  positive definite, and same-point q31/q61 differences are below `2.73e-12`.
  This calibrates scale without freezing a rule. The Binary reported-output
  normalizer is now implemented over 18 pre-result rows: three population
  coordinates, five free item difficulties, and deviance in each of q31/q61.
  Together with the additive 36 rows, a content-hashed 54-row registry now
  proves six-arm normalizer and exact-decimal parser coverage. It also records
  that only the four RSM/PCM calibration arms have retained native files;
  Binary q31/q61 remain unobserved. Adapter, tolerance, and binding readiness
  are complete. All six source-bound mfrmr numerical references are now ready:
  RSM/PCM pass independent probability/marginal-likelihood oracles and local
  full-rank checks; Binary passes its explicitly weaker converged, finite,
  internally consistent coordinate contract. All three q31/q61 pairs pass the
  prospective within-engine coordinate and deviance budgets. Every fit remains
  non-inference-ready, and numerical agreement cannot promote inference.
  The candidate-002 handoff was consumed when its first Binary arm failed
  semantically despite process exit zero; ConQuest rejected the generated
  C-style prose preamble and estimated no model. The remaining arms were not
  launched and that candidate remains non-reusable. Candidate 003 then bound
  repaired command-only input, a post-incident source, six numerical
  references, the exact executable and invocation order, and 50 empty output
  paths. Its arm-by-arm semantic gate prevents status-zero false success. All
  six Binary/RSM/PCM q31/q61 arms completed, all 50 outputs are nonempty and
  hash-bound, and the exact A matrices and 54 native decimal coordinates pass
  all 19 cross-engine plus 38 integration rows in the prospectively frozen
  table. Rows `conquest_binary_core`, `conquest_rsm_core`, and
  `conquest_pcm_core` are therefore closed at the exact-reported-decimal MML
  scope. This is not hidden-solution/scientific equivalence or inference
  readiness; DFF, fit, rank/ordering invariance, sparse allocation, free-slope
  GPCM, and independent-platform replication remain separate claims. No large
  simulation should be started merely because this bounded core passed. The
  next MML comparator is now a bounded TAM calibration, not another ConQuest
  execution. TAM 4.3-25 `tam.mml.mfr()` was run on the same additive
  complete-crossing RSM/PCM fixture at q31/q61 after explicitly transforming
  its `constraint="cases"` item location into mfrmr's free population
  intercept plus sum-zero criterion coordinates. All 46 transformed
  coordinate observations and both deviances are finite; the largest observed
  coordinate and deviance differences are about `9.90e-8` and `2.23e-7`.
  The mfrmr side retains independent probability and marginal-likelihood
  oracle checks. This advances `tam_mml_core` only to `review`: the values are
  calibration input, not a post hoc `EXT-TAM-TOL`; a TAM-specific prospective
  rule and disjoint candidate remain necessary. `tam.mml.mfr()` has fixed
  slopes, so this result does not test free-slope GPCM;
- a deterministic cross-engine algorithm/correlation audit now separates
  mathematical-estimand identity from literal solver identity. After excluding
  deviance and TAM coordinates derived from sum-zero constraints, the smallest
  observed Pearson correlation is above `0.999999999995` for ConQuest--mfrmr,
  above `0.999999999999999` for TAM--mfrmr, and above `0.999999999998` for
  ConQuest--TAM across the matched complete-crossing cells. Correlation remains
  descriptive: affine slope/intercept, maximum absolute difference, deviance,
  and q31/q61 stability stay separate. The audit also proves that the mfrmr
  Person likelihood sums log probabilities and uses shifted log-sum-exp; the
  negative control `log(0.01^200)` underflows while the production path remains
  finite and agrees with `200*log(0.01)` to `2.51e-12`. The remaining external
  differences are not labelled floating-point-only because fixed-grid versus
  Gauss--Hermite approximation and ConQuest decimal export precision also
  contribute. TAM is in the same broad MML/EM family as ConQuest, not a proven
  identical implementation; immer CML/CCML/JML use different objectives.
  Therefore literal ConQuest solver replication is not a default-release
  requirement. A fixed-grid/EM compatibility mode should be considered only
  for a concrete reproducibility use case, after the current disjoint TAM and
  decision-invariance gates, rather than displacing higher-priority DFF, fit,
  endpoint, sparse-design, and inference-readiness work;
- a source- and version-bound `sirt::rm.facets()` MML comparison, beginning
  with the item-only GPCM and equal-discrimination many-facet reductions. The
  comparison must align category support, threshold coordinates, slope
  centering, trait distribution, quadrature grid, retained rows, and rounding
  before assigning a numerical tolerance. The general sirt free-slope rater
  model is a near-neighbour rather than a matched current-mfrmr estimand:
  sirt places the product of item and rater slopes on the trait term and keeps
  rater severity as a separate location term, whereas mfrmr assigns one slope
  owner to the complete adjacent-category predictor. It will therefore remain
  sensitivity evidence unless an exact submodel map is established. The
  installed sirt 4.2-133 help also documents finite default slope bounds of
  `0.05--10`; item-only free-slope results therefore fail the exact mfrmr
  parameter-space contract unless that difference is explicitly resolved.
  Equal-discrimination reductions remain the cleaner first lane;
- conditional-likelihood results from immer as separate Rasch-family reference
  evidence where their estimands match, without treating CML or CCML as current
  mfrmr fitting methods. A loaded-function-bound 22-row eligibility ledger now
  permits only exact-design item, shared-step, criterion-step, and rater
  contrasts to proceed to later fixtures. Person ability and population
  regression/distribution parameters are conditioned out; CML and pairwise-
  composite CCML objectives do not match MML/JML objectives; neither route
  estimates free GPCM slopes. Positive and adversarial design/category/rank/
  constraint fixtures remain necessary before any fitted reference;
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
The same record now fixes a compact endpoint-response ladder rather than a new
large simulation: sign-symmetric all-1/all-5 Persons, isolated and joint
all-1/all-5 Raters, a response-constant non-recession control, anchors,
near-extreme support, interaction cells, and category/step support. The release
order is deterministic boundary attribution, public-surface propagation,
estimator-specific JML/MML/adjustment semantics, and fit/DFF eligibility; only
then may bounded operating-characteristic simulation or external FACETS work
begin. An endpoint Rater is a support warning, not by itself proof of an
infinite facet estimate.

The companion solution/decision-stability roadmap adds a second ordering:
common objective-gradient-free-dimension identity, prespecified multiple-start
and quadrature candidates, boundary competition, Hessian/interval eligibility,
and only then DFF, infit/outfit, Person/Rater rank, facet-separation, and final
readiness invariance. It requires exact categorical decision signatures in
addition to class-wise transformed-coordinate tolerances. A positive-definite
local Hessian, code-zero optimizer, close dense-grid objective, or high rank
correlation cannot substitute for the preceding gates.

Its first repository-only P0 instrumentation slice is now complete for one
fixed, benign, free-population GPCM-MML microcase. Seven preregistered starts
are compared through one canonical objective, analytic and independent numeric
scores, five free-dimension counts, labelled expanded coordinates, and an exact
fail-closed decision signature. All seven returned near the same numerical
solution, but no tolerance is frozen and all boundary, Hessian, interval, DFF,
fit, rank, and separation fields remain explicitly unevaluated. The result is
therefore a working gate instrument, not a global-maximum or inference-ready
claim; endpoint fixed-facet controls and start-by-quadrature adjudication remain
next.

A bounded P0b extension now covers reflected all-5/all-1 and 19/20 near-endpoint
Person patterns. It preserves the intended distinction between exact-response
provenance and near-endpoint responses, but it also shows why a finite MML EAP
cannot by itself be called stable: all four default source fits have
nonconverged population states and very large population variances, while a
prespecified low-variance start attains a materially lower common objective in
every case. No candidate is selected and no tolerance or capability is
promoted. The next narrow gate is a population-variance profile and a
default-versus-low-variance q=31/61/91 comparison on a common dense evaluation
grid; Rater endpoints remain separate fixed-facet boundary work.

The q=31 P1a nuisance-profile calibration has now completed that first
population-variance slice. Reoptimizing all other free coordinates at ten
fixed log-variance values confirms a locally stationary low-variance
finite-grid minimum in each reflected endpoint case. It does not confirm the
default high-variance plateau: those tail points remain nonstationary, and the
wider reflected curves retain numerical path differences. Consequently the
next q=31/61/91 audit is limited to the qualified low-variance local candidate,
with the default basin retained only diagnostically. This is not a selected
package solution, a global profile, or a continuous-integration result.

That bounded q audit is now complete as P1b. Independent q=31/61/91 refits of
the four qualified low-variance endpoint candidates all pass the existing
native numerical rule and remain coherent under a held-out q=121 objective,
score, labelled-coordinate, EAP, and posterior-SD evaluator. The largest
qualified q-pair common-objective difference is about `1.14e-13`; the largest
labelled-coordinate difference is below `1e-11`, and the largest common EAP
difference is about `5.42e-12`. These observed values are not acceptance
tolerances. None of the 12 predesignated default/high-variance diagnostic arms
passes native stationarity, and their common-evaluator failures can be
enormous. P1b therefore redirects the next work from adding more q points to
population-boundary and source-solution selection contracts. It still does
not authorize a default replacement, continuous-integration certificate,
Hessian inference, DFF/fit/rank decisions, or broad simulation.

P1c now implements the fixed-nuisance `sigma2 -> 0+` likelihood limit exactly:
q=1 has node zero and weight one, and all 12 returned boundary traces agree
with a separately reconstructed conditional-GPCM likelihood to at most about
`1.71e-12`. This closes the likelihood-evaluation identity, not the profiled
boundary. Zero of the 12 three-start nuisance refits passes the existing
stationarity rule; returned slopes range into highly start-sensitive regimes,
with maximum observed values above 36,000 in one diagnostic trace. No magnitude
is a frozen boundary cutoff, and no nonstationary trace enters the interior
comparison denominator. The next bounded question is therefore a joint
zero-variance/log-slope path, followed separately by the upper/joint variance
path and a source-solution rule. P2 uncertainty and downstream decisions remain
blocked.

P1d now evaluates the observed joint lower-boundary geometry without applying
the P1c q=1 identity outside its assumptions. Along the declared C4 ray,
`sigma2` decreases as `exp(-2t)`, the C4 slope increases as `exp(t)`, and the
other three slopes decrease symmetrically while preserving their geometric
mean. Thus C4 `slope * population SD` stays constant and standardized-normal
quadrature must remain active. All 48 finite path fits return, and same-vector
q=61/91/121 objective ranges are at most about `1.74e-11`, but only 14 pass
nuisance stationarity; none of 32 points with `t >= 4` passes. Terminal
objectives are higher than their interior anchors, yet route and derivative
behavior is not stationary enough to certify a finite turnback. The next
bounded question is a coordinate-aware reduced joint limit or well-scaled
reparameterization for this ray, before the separate upper/joint variance path
and source-selection rule. A denser grid, more iterations, Hessian/DFF/fit/rank
work, or broad simulation cannot bypass that question.

P1e resolves the coordinate question for the declared symmetric C4 ray. It
replaces the ill-scaled raw nuisance coordinates by an exact finite affine map:
C4 location, C4 steps, and Rater coordinates are divided by `exp(-t)`, while
C1--C3 locations and steps are multiplied by `exp(-t/3)`. Round-trip error is
at most about `1.39e-17`, and analytic chain-rule gradients agree with an
independent derivative to about `2.20e-7`. All 32 transformed fits pass their
declared scale-specific numerical rule; raw absolute-gradient review remains
visible rather than being overwritten. A separately derived direct reduced
limit then passes from both starts in all four scenarios. Its routes agree to
about `3.41e-13` and its objective is 3.38--4.15 above the qualified interior,
conditional on the path-fixed `slope * population SD` coefficient. P1f now
shows that this coefficient is not stationary when released, so P1e closes
only that declared fixed-coefficient path rather than the entire C4 face.

P1f classifies the linear lower-boundary rates that retain at least one finite
random coefficient. After normalizing the slope rates by the population-SD
decay rate, `w_c = (1 - u_c) / J` is an exact affine map to the standard
simplex. For four criteria this gives 14 nonempty proper target faces: four
single-target faces, six two-target edges, and four three-target vertices. A
canonical reduced likelihood with free positive target coefficients is now
implemented with an independently checked analytic gradient. It reproduces
the eight P1e objectives to about `1.14e-13`, while the released C4 coefficient
gradient is 2.42--2.89 and a signed local probe improves every point. The next
bounded gate is multistart optimization of these 14 canonical faces. The
empty-target deterministic-Rater rate hierarchy, curved/nonconvergent rates,
upper variance boundary, and source-selection rule remain separate blockers;
Hessian, DFF/fit/rank, and broad simulation remain downstream.

P1g follows the released C4 coefficient in coordinates that remain finite at
its lower endpoint. Writing `lambda = a_C4 * population SD`, the exact map
uses `B=lambda*q`, `V4=lambda*u4`, and `G4=lambda*H4`; at `lambda=0` it becomes
a direct conditional model retaining C4 Rater severity but no latent-person
variation. All 56 two-route fits on the declared seven-point grid are
eligible, route differences are at most about `5.76e-10`, and the endpoint
matches an independent conditional oracle to about `1.93e-12`. Both routes
increase monotonically away from zero and have positive natural-coefficient
derivatives at every positive grid point. The endpoint remains 2.08--2.58
objective units above the qualified interior. This adjudicates the C4 grid
and its deterministic-Rater endpoint, not an unseen C4 interior basin or any
other face. The next efficient screen applies the same construction to C1--C3
single-target faces before multiple-target faces or broader boundary work.

P1h completes that remaining single-target screen without repeating the C4
fits. C1--C3 use the same exact target-specific scaled coordinates, two
opposite routes, seven fixed coefficient values, q=61/91/121 reevaluation, and
direct conditional endpoints. All 168 new fits pass; route differences are at
most about `1.21e-9`, and independent endpoint oracles agree to about
`2.50e-12`. Every new grid increases from its singleton deterministic-Rater
endpoint, and every endpoint remains above the qualified interior. Combining
P1g and P1h closes the declared grids for all four single-random-target faces
and their four singleton-Rater strata. The next bounded gate is the six two-
target faces and their two-criterion Rater endpoints. Four three-target
vertices, multi-criterion empty-target strata, upper variance, source
selection, Hessian, DFF/fit/rank, and broad simulation remain downstream.

P1i executes that six-pair radial gate in four exact/near endpoint fixtures.
For each pair it uses `tau=sqrt(lambda_1*lambda_2)` and a free relative
coordinate `(kappa_1,kappa_2)=(exp(d),exp(-d))`; the transformation is exactly
P1f-equivalent for positive `tau` and has a direct finite-`d` conditional
endpoint at `tau=0`. Of 336 fits, 318 are eligible. Ten of 24 scenario-by-pair
grids are locally adjudicated and their paired deterministic-Rater endpoints
remain 2.07--2.58 objective units above the qualified interior. The remaining
14 grids show coefficient-ratio branching: route differences reach about
`0.0599` and `d` moves below `-7` on affected endpoint traces. Consequently
`AllSixTwoTargetRadialGridsScreened`, coefficient-ratio closure, and source
selection remain false. The next bounded gate is an explicit slower/faster
coefficient-rate chart, not a denser `tau` grid or a larger iteration cap.
Three-target faces remain unopened until that nested two-target hierarchy is
classified; Hessian, DFF/fit/rank, and broad simulation stay downstream.

P1j supplies the missing ordered closure chart without another fit search.
Writing `lambda_slow=mu` and `lambda_fast=mu*rho` with shared Rater coordinate
`B=mu*q` transports all 288 positive P1i points exactly and makes `rho=0`
identical to the P1h/P1g singleton likelihood. All 672 ordered singleton-grid
identities pass, including nuisance and natural-`mu` gradients; independent
natural-`rho` derivatives agree within about `6.32e-8`. The derivative is
nonnegative in only 280/672 rows and is negative in every ordered direction at
`mu=0.1` and `0.2`. The identity is therefore closed, but the ratio profile is
not. The next bounded gate profiles `rho` on `[0,1]` at each frozen `mu`, from
both singleton and transported-P1i starts. A rectangular two-dimensional grid,
three-target work, and downstream inference remain unjustified at this stage.

P1k runs that bounded optimizer first on exact-high and near-high
representatives. All 336 fits pass their boundary-aware KKT and quadrature
checks, producing 113 lower, 188 interior, and 35 upper solutions. Two starts
agree on both objective and `rho` in 125/168 cells; ten have the same objective
but different coordinates, while 33 have distinct eligible KKT objectives.
The best observed value for every representative unordered pair remains
2.07--2.58 objective units above the qualified interior, but multi-basin
stability is not closed by P1k alone.

P1l now completes scoped fixed-`rho` continuation for those 43 cells without
rerunning the priority lane when opening the coordinate lane. All 766
objective-discordant and 260 coordinate-only fits are eligible. Both starts
coalesce to the same nuisance solution at every common `rho`. The 33-cell
objective lane resolves into 22 profile-maximum brackets, six profile-minimum
brackets, and five monotone-increasing grids; the ten coordinate-only cells all
bracket one profile minimum. Hence P1k's discrepancies reflect natural-`rho`
profile geometry and a `1e-4` stopping tolerance, not observed multiple
nuisance basins. The finite grid does not certify a continuous profile or
exclude an unseen turn. P1m therefore takes a compact local
turning-point/endpoint certificate for these three mechanisms before reflected
transport. Three-target faces and downstream inference remain deferred.

P1m implements that local certificate without expanding to every cell. It
freezes four mechanism representatives, tightens nuisance stationarity to
`2e-6`, and uses Richardson-Hessian Newton polishing where ordinary optimizers
stop at objective-rounding scale. All 87 points pass. The maximum and two
minimum roots are narrowed to brackets below `7.2e-8`, both starts coalesce,
and nuisance-Hessian minimum eigenvalues remain about `5.64`. The monotone
representative has positive derivatives on a nine-point grid. This supports
the local mechanism taxonomy but cannot prove continuous monotonicity or a
global profile between numerical points. P1n therefore takes an exact
category-reversal/reflection transport, with refitting only on identity
failure; it is not a denser `rho` grid.

P1n completes that transport for the four P1m local mechanisms without
refitting. The exact-high/exact-low and near-high/near-low fixtures preserve
row identity and reverse every score. A linear involution negates location and
Rater coordinates and reverse-negates each full step vector; symmetric
quadrature mirrors the latent node. Across all 87 stored points, maximum
objective and transported-gradient differences are about `2.27e-13` and
`2.17e-13`; four independent numeric-gradient checks differ by at most
`1.86e-8`. Nuisance Hessians transport by nonsingular congruence, which
preserves inertia but does not imply identical eigenvalues. The next bounded
step is to materialize this identity over the full P1k/P1l finite-grid
registry. Continuous ratio closure, three-target faces, and inference remain
false.

P1o completes that finite-grid registry without optimization. It verifies all
1,362 stored P1k/P1l points and transports 168 high-side cells to 168 low-side
cells. The resulting four fixtures each contain 84 cells; maximum objective
and gradient-transport differences are about `3.41e-13` and `8.90e-13`.
`FullFourFixtureFiniteGridRegistryCompleted` is true, but continuous profile
and face-closure flags remain false. Before opening another large numerical
gate, the release portfolio must decide whether it actually requires a
continuous ratio theorem or should retain this explicitly finite claim and
move to another open structural dependency.

P1p makes that release-scope decision without fitting. The public capability
registry advertises no continuous ratio-profile or two-target-face closure
claim, and the 106-row release checklist contains no independent mandatory
row for such a theorem. The P1o finite-grid evidence is therefore retained as
bounded repository evidence and continuous ratio work is deferred. The next
GPCM release-spine blocker is row 88, `gpcm_owner_evidence_partition`, because
Criterion-owned and Rater-owned aligned GPCM interpretations cannot borrow
evidence from each other. Fit and DFF claims retain their exploratory and
screening-only fallbacks; no simulation or public promotion follows from this
scope decision.

P1q performs that first deterministic owner-evidence audit. The sealed
Draft.66 manifest, result rows, and all 120 checkpoints retain their historical
owner/estimator/ability-scale/runtime identities, but the global and grouped
aggregate tables are not self-describing and none directly records the exact
1--4 category range. A derived envelope binds all seven aggregate surfaces to
a four-stratum identity registry without changing the source bundle or adding
substantive evidence. More importantly, Draft.66 MML is a historical fixed-
standard-normal run; it cannot validate today's `free_population` default.
The next step is therefore an explicit prospective owner/scale/support
contract followed by a small paired common-data smoke, not expanded
replication. Row 88 remains `review` and broad simulation remains unauthorized.

P1r now freezes that prospective contract without fitting. A Criterion-owned
and a Rater-owned non-unit source dataset each feed Criterion/Rater fit-owner
routes under JML and explicit current-default `free_population` MML, for eight
planned routes. Every manifest row fixes the 1--4 range, common-data pairing,
ability-scale role, runtime/runner/contract hashes, and no-claim boundary; 13
future output surfaces must retain the same identity directly or by a
full eight-route identity registry. The bounded smoke is admissible only after real runtime
binding.

P1s has now executed that exact bounded smoke. All eight fits returned, all
four route-level identity comparisons passed on every route, and all 12
required manifest/data/result/checkpoint/aggregate/replay surfaces retained
the full identity. During pre-admission review, warning-as-error reproduction
found and fixed recycled nonlinear-block selection in the MML estimability
audit; the admitted v3 has no such warning. This closes the current-default
identity-transport gap, not row 88: all eight fits remain `review`, zero are
inference ready, and two retain terminal-gradient review. Repeating the smoke
or expanding simulation is not authorized. The next GPCM foundation work is
estimator-specific nonlinear estimability, slope/joint-boundary completeness,
and fixed-objective numerical stability before recovery, uncertainty, fit,
DFF, or owner-comparison rules are frozen.

P1t now prevents the external branch from outrunning that foundation. A
source/version-bound no-fit preflight crossed the eight admitted P1s routes
with ConQuest, TAM, immer, and sirt. None of the 32 full route-by-program cells
has an established exact model-and-estimator identity: ConQuest JML free
scores are unsupported and its standard multifacet MML score ownership is not
the P1s single-owner kernel; TAM and immer supply only relevant item-only or
unit-slope reductions; and sirt's general MML product-trait-slope kernel is a
near-neighbour with a finite slope box. Five separately labelled projection
lanes remain, including the exact item-only ConQuest MML coordinate map, but
none is P1s reproduction and no external execution is authorized. A future
external run must first prove full probability/free-dimension identity or stay
explicitly in a reduction/sensitivity stratum; numerical closeness cannot
repair a model mismatch.

A separate FACETS/GPCM JML comparison-role contract now closes the omitted
role-classification gap without running FACETS. FACETS PCM/JMLE versus mfrmr
PCM/JML is the only future direct common-estimand FACETS lane. Unit-slope
GPCM/PCM remains an internal exact reduction; non-unit mfrmr GPCM/JML is
evaluated against generating truth with FACETS PCM only as a deliberately
misspecified control; and FACETS Table 7 discrimination is diagnostic-only
because it does not update the fitted PCM estimates. Wijayanto penalized JML,
Rirt finite-box JML, Muraki MML-EM, and mfrmr unpenalized no-box JML remain
separate estimator families. This structural result adds no external fit,
tolerance, equivalence, simulation, or GPCM promotion authority.

The next P1u slice now gives the retained nonlinear diagnostics a precise
local interpretation without promoting P1s. For JML GPCM, full column rank of
the complete conditional adjacent-logit Jacobian is recorded as a sufficient
retained-point first-order certificate. For unit-weight fixed-quadrature MML,
full rank of the observed Person-pattern score vectors is also sufficient:
those vectors are a subset of the strictly positive finite pattern support, so
their span makes the full expected score information positive definite. A
deficient observed subset is deliberately inconclusive; exhaustive all-pattern
information may classify first-order rank when computationally available.
This removes an avoidable exponential enumeration requirement in the positive
direction but leaves global and continuous-integral identification, weak
information, boundary completeness, and inference readiness false or open.
The admitted P1s bundle did not retain full fit audits and is not rerun under
this implementation slice.

The P1v follow-through now combines the two existing conditional-JML GPCM
path audits under an explicit estimator/objective identity. Monotone
slope-only recession, competitive joint additive/log-slope boundary,
finite-retained-point-with-no-certified-audited-path, numerical
indeterminacy, workload non-evaluation, and unit-slope reduction are separate
machine-readable states. In particular, two completed negative bounded-path
audits do not establish a finite global maximum or global boundary absence.
The classifier is limited to mfrmr's identified, unpenalized fixed-effects
JML likelihood with no finite box; penalized JML, finite-box JML, and MML
remain different objectives. It has no readiness, uncertainty, recovery,
external-comparison, or promotion effect. General rate vectors, curved paths,
and broader topology/category challenges remain open before simulation or
comparison expansion.

The next fixed-objective slice now types terminal-gradient stability for that
same JML-GPCM objective. At the retained vector it reconstructs the objective
and complete analytic gradient, reconciles the optimizer and selected polish
records, checks deterministic free-coordinate probes by central differences,
and reports blockwise norms. A certified slope-only or competitive joint
boundary path overrides any finite-point zero or small gradient. Only when no
audited path is certified, both bounded path families complete, optimizer code
is zero, and the numerical record is coherent can the result be labelled
retained-point first-order evidence. This is not a finite-interior or global-
maximum certificate, the implementation threshold is not a frozen scientific
rule, and readiness, uncertainty, FACETS comparison, recovery, and promotion
remain unchanged. General rate vectors, curved paths, and broader topology or
category stress remain the next GPCM foundation work.

P1x now closes the constant-rate-vector part of that next step for the bounded
joint linear-additive family. Any nonzero constant sum-zero log-slope vector
with a favorable first negative-rate tier has a canonical asymptotically
equivalent partition into positive, zero, leading-negative, and deeper-
negative groups. Enumerating these partitions exactly contains the existing
ordered `+1/-1` pairs and adds 12 candidates at three slope levels and 98 at
four. A `(3,-1,-2)` construction passes the generalized LP and direct
likelihood-limit checks while all six pair checks fail, demonstrating material
coverage rather than a relabelling of the pair audit. Completed negative
classification remains scoped: the default workload guard stops before the
combinatorial family becomes large, and curved paths, paths without limiting
rates, broader topology/category stress, global boundary absence, MML
geometry, recovery, uncertainty, FACETS equivalence, and promotion remain
open or unchanged.

P1y now transports those positive constant-rate certificates across a narrow
but genuinely curved neighborhood. If the free additive coordinates equal the
certified affine path plus a residual converging to zero, and expanded log
slopes equal their certified affine path plus a sum-zero residual converging
to zero, the strict source inequalities persist and the analytic boundary
likelihood is unchanged. Production slope-only and joint-pair certificates
and a direct `(3,-1,-2)` curved construction pass this rule. The scope cannot
be widened to arbitrary bounded residuals: a zero-rate slope with a
nonvanishing oscillatory residual yields two different subsequential limits in
an explicit three-category construction. P1y is therefore positive-only;
negative constant-rate completion does not exclude curved boundaries. General
nonvanishing-residual hierarchies, rate-nonconvergent paths, broader topology
and category stress, MML geometry, inference, and FACETS equivalence remain
open or unchanged.

P1z now gives the remaining rate-nonconvergence question a finite-dimensional
compactification without claiming a likelihood result. Every unbounded
identified JML parameter sequence has a subsequence whose normalized free-
additive and expanded sum-zero log-slope displacement converges. A nonzero
limiting log-slope direction has one finite positive, zero, leading-negative,
and deeper-negative primary role pattern; at three slope levels there are 18
patterns, six containing a zero primary rate, and 12 beyond the ordered pairs.
An alternating two-direction construction verifies that the full normalized
sequence need not converge. A separate
`t(1,-1,0) + sqrt(t)(-0.5,-0.5,1)` construction shows why the compactification
does not complete the boundary problem: the zero primary-rate coordinate can
carry a divergent slower scale. Thus the primary role partition is complete
as a structural enumeration, but secondary hierarchies, arbitrary
nonvanishing residuals, likelihood agreement across accumulation directions,
general curved paths, global boundary absence, MML geometry, inference,
FACETS equivalence, recovery, and promotion remain open or unchanged.

P2a now resolves the finite-coordinate part of the zero-primary-rate gap. For
a declared lexicographically ordered family of expanded sum-zero log-slope
coefficients, each stage acts only on levels which were zero at every faster
stage. The first nonzero stage resolves at least two levels and every later
stage at least one, so `J` slope levels require at most `J-1` nonzero stages.
The sum-zero constraint remains global at every stage; its restriction to the
still-active levels need not sum to zero because slower compensation can occur
in levels already resolved at a faster scale. A five-level construction attains
the `J-1` bound. A separate three-level construction proves why this finite
depth is not a likelihood theorem: the common primary rate `(1,-1,0)` followed
by opposite secondary directions sends the third slope to infinity versus
zero, producing binary top-category log-probability limits `0` and `-log(2)`.
Actual path-scale extraction, additive-coordinate hierarchies, ties and bounded
remainders, agreement across accumulation subsequences, general boundary
classification, MML geometry, inference, FACETS equivalence, recovery, and
promotion therefore remain open or unchanged.

P2b now adds a likelihood theorem for a deliberately declared and bounded
subclass of those hierarchies. Expanded sum-zero log slopes and unscaled
cumulative category utilities may each contain at most two strictly ordered
positive-power scales. Exact lexicographic utility ties followed by the base
utility determine infinite-slope support; exponentially vanishing slopes
dominate all admitted polynomial utility growth and give a uniform category
limit; finite slopes use a base-slope softmax on the final additive tie set.
The internal oracle returns row limits and the weighted joint log-likelihood
limit, including negative infinity when a positive-weight observed category is
excluded, and representative finite-distance traces converge to the analytic
answers. Production fits only advertise this facility: no path is extracted
or searched, declared utility directions are not checked for parameter-space
reachability, and exact ties are assumed unaffected by omitted remainders.
Path extraction, reachability, broader scales and remainders, monotonicity,
competitiveness, agreement across accumulation subsequences, global boundary
classification, MML geometry, inference, FACETS equivalence, recovery, and
promotion therefore remain open or unchanged.

P2c now closes reachability for the safer forward-declared parameter subclass.
The retained constrained free-additive design maps a declared coordinate
direction to adjacent-category utility changes; cumulative sums with category
zero fixed at zero then produce the P2b utility directions. Because the path is
constructed from actual free coordinates, its retained-design parameter-space
reachability is structural rather than a tolerance-dependent inverse
projection, and exact ties are computed on the constructed path itself. An
invertible change of free-coordinate basis with the contragredient direction
leaves every adjacent and cumulative utility unchanged. A current-fit wrapper
also reconstructs the retained base utilities, score and slope maps, weights,
and expanded log slopes before evaluating the P2b limit and direct finite-
distance likelihood. The production fit stores only the sparse operator scope
and coordinate map: it declares, extracts, searches, and evaluates zero paths.
Arbitrary caller-supplied utility matrices, inverse reachability, inference of
directions or scale exponents from optimizer traces, remainder-stable ties,
tail monotonicity and competitiveness, common subsequence limits, global
boundary classification, MML geometry, inference, FACETS equivalence,
recovery, and promotion remain open or unchanged.

P2d now separates finite optimizer-sequence description from a theorem that
can actually extend P2b. The optimizer exposes one coordinate vector per
optimization or polish stage only while `fit_mfrm()` is assembling its audits;
those vectors are discarded before the fit is returned, while the existing
aggregate stage table remains. Fewer than three endpoints yield a typed
insufficient-sequence state. An explicitly longer sequence can receive a
finite Euclidean SVD with at most two direction/scale components and optional
log-log scale estimates, but the result is coordinate-basis dependent, is not
within-stage iteration history, and certifies no asymptotic direction, power,
remainder, or P2b handoff. The analytic part instead starts from a completed
P2c path and admits a finite sum of fixed perturbations on the already scaled
category logits, each multiplied by a strictly ordered negative power. Every
within-row contrast of that residual tends to zero, so row log probabilities
and the finite joint log likelihood have the same declared limit. This theorem
does not separately classify arbitrary utility or slope remainders, bounded
oscillation, slower divergent terms, or an optimizer sequence. Production path
extraction, competitiveness, common-subsequence agreement, global boundary
classification, MML geometry, inference, FACETS equivalence, recovery, and
promotion remain open or unchanged.

P2e now closes classification only after passing an arbitrary parameter
sequence through the exact nonlinear response map and taking a further
subsequence. With category zero as the rowwise logit gauge, the retained
response image has finite dimension `N(K-1)`. A bounded contrast image has a
convergent subsequence. For an unbounded image, recursive normalization,
subsequence compactness, and orthogonal projection produce at most `N(K-1)`
divergent directions with positive scales `s_g -> infinity`, successive ratios
`s_(g+1)/s_g -> 0`, a finite base, and a terminal contrast remainder tending to
zero. This is a general scale flag and does not require common powers. Exact
lexicographic maximization of the flag followed by a base softmax classifies
every retained row and the weighted joint-likelihood limit along that further
subsequence. Mapping before compactification absorbs slope--utility products,
intermediate growth orders, and cancellations which a parameter-space SVD
cannot classify. The production fit records only the theorem scope and
declares zero sequences; a finite caller-supplied sequence can be mapped
exactly but cannot be relabelled as asymptotic evidence. Different
subsequences may still produce different flags and limits. P2f must therefore
compare the complete contrast-boundary closure with finite points before any
claim about competitiveness, common limits, finite-JMLE existence, or a global
boundary. MML geometry, inference, FACETS equivalence, recovery, and promotion
remain open or unchanged.

P2f now separates certifiable global non-attainment from the still-missing
finite-attainment envelope. Every finite positive-category softmax gives a
strictly negative effective-row log probability, so zero is a universal upper
bound for the conditional joint log likelihood and no finite parameter vector
can attain it. Consequently, a P2c parameter-reachable divergent path with
exact analytic limit zero certifies both the global supremum and nonexistence
of a finite JMLE. Independently, an otherwise free extreme-Person ray or the
existing global additive recession-cone certificate strictly improves the
objective from every finite point; either proves finite-JMLE nonexistence even
when the supremum value is not identified. Existing analytic slope-only and
joint paths are promoted only when their certified limit is exactly the
universal upper bound. For the opposite conclusion, continuity and
Weierstrass give finite attainment if some finite point lies strictly above a
verified upper bound on the limsup of every parameter sequence escaping every
bounded set. P2e guarantees classifiable further subsequences but does not
enumerate this complete boundary envelope, so the package records the
implication without treating caller-declared completeness as a production
certificate. A negative bounded search and a finite optimizer trace therefore
leave finite existence open. No readiness, standard-error, MML, recovery,
FACETS-equivalence, simulation, or promotion decision changes.

P2g now isolates the bounded-response-image branch left open by P2e and P2f.
Write the retained adjacent utility as the affine map `b + A x`, let `x(t)` be
a finite sum of exponential free-coordinate directions, and let each expanded
log slope be affine in `t`. Every reference-category response contrast is then
an exact finite exponential sum whose rates are log-slope rates plus additive
rates. Coefficients with the same combined rate are added before
classification: positive rates form a P2e divergent flag, rate zero forms the
finite base, and negative rates vanish uniformly. If the parameter path
escapes every bounded set but no positive response rate remains, the response
image stays bounded and the parameter-to-response-contrast map is not proper.
For an unanchored affine operator with `b = 0`, the all-zero additive path and
any nonzero sum-zero log-slope direction give a canonical witness with every
contrast identically zero. Production records that witness only after an exact
structural zero-offset check; a nonzero anchor leaves properness open. This
refutes a hoped-for universal proper-map shortcut but does not enumerate every
bounded-image escape or maximize its likelihood limit. The next finite-
attainment gate is therefore a complete boundary envelope on response-
equivalence classes, including the bounded-image escape family. MML geometry,
inference, readiness, recovery, FACETS comparison, simulation, and promotion
remain open or unchanged.

P2h resolves the first P2g next-gate branch: quotienting finite parameter
points only by equality of their response contrasts is not enough. In a
binary two-Person, two-slope-owner GPCM, let centered owner locations be
`delta_1 = delta` and `delta_2 = -delta`, take
`theta(t) = (exp(-t), 2 exp(-t))`, `delta(t) = 0`, and use identified slopes
`alpha(t) = (exp(t), exp(-t))`. The finite response-contrast vector is exactly
`(1, 2, exp(-2t), 2 exp(-2t))`, so the escaping finite-parameter classes
converge to `z* = (1, 2, 0, 0)`. If a finite parameter represented `z*`, the
last two zero contrasts and positive finite second-owner slope would force
`theta_1 + delta = theta_2 + delta = 0`. Hence `theta_1 = theta_2`; the first
two rows share the positive finite first-owner slope and would have equal
contrasts, contradicting `1 != 2`. Equivalently, the implementation certifies
the exact affine relation `row_1 - row_2 = row_3 - row_4` and its nonzero
target witness. Therefore the finite response image, and its response-metric
equivalence quotient, is not closed or complete. Removing fibres alone cannot
produce a proper response map; the quotient must be completed with boundary
strata. This obstruction neither proves that `z*` is competitive nor decides
finite-JMLE existence. The next gate is now unambiguously the complete
response-image closure stratification and boundary-limsup envelope. MML,
inference, readiness, recovery, FACETS comparison, simulation, and promotion
remain open or unchanged.

P2i supplies the first complete closure rather than another obstruction. For
the exact P2h binary two-Person/two-slope-owner operator, write the response
contrasts as

```text
z = (alpha_1(theta_1-delta), alpha_1(theta_2-delta),
     alpha_2(theta_1+delta), alpha_2(theta_2+delta)),
alpha_1 alpha_2 = 1.
```

The owner differences satisfy the exact identity
`d1 = alpha_1^2 d2`. Conversely, every contrast vector satisfying the
resulting sign condition has an explicit finite inverse. The finite response
image is therefore

```text
(d1 > 0, d2 > 0) union (d1 < 0, d2 < 0) union (d1 = d2 = 0),
```

and its closure is the same set plus the axes `d1 != 0, d2 = 0` and
`d1 = 0, d2 != 0`. A bounded-response parameter escape has a further
subsequence on exactly one of those axes: `alpha_1 -> infinity` forces
`d2 -> 0`, `alpha_2 -> infinity` forces `d1 -> 0`, and a bounded positive
slope pair plus bounded contrasts gives bounded additive parameters. Explicit
inverse paths show that every axis point is reachable. This completes all five
finite closure strata and the complete bounded-response escape-limit set for
the fixture.

When each of the four binary design cells has strictly positive success and
failure mass, any unbounded contrast sends the joint likelihood to minus
infinity. On `d2 = 0`, cells 3 and 4 pool at their combined success/failure
logit while cells 1 and 2 retain their independent logits; `d1 = 0` gives the
symmetric second axis. These two analytic values form the complete parameter-
sequence limsup envelope. The integer expanded-row fixture with successes
`(2, 4, 1, 1)` and failures `(1, 1, 1, 1)` has independent optimum
`(log(2), log(4), 0, 0)`, exactly on the missing `d2 = 0` axis. Its supremum is
`6 log(2) - 3 log(3) - 5 log(5) = -7.184143344815158` and is approached by
finite identified slope paths but has no finite representative. Thus finite
JMLE nonexistence occurs despite both outcomes appearing in every cell and
despite the existing production P2f additive/extreme screens remaining
negative. The guarded current-fit wrapper reconstructs the exact `4 x 3`
operator, masses, and supremum; a retained optimizer trace lies about
`7.49e-6` below the boundary and is not promoted. This closes the entire
minimal fixture, not a general GPCM design. The next gate is to replace its
single identity `d1 = alpha_1^2 d2` with a general-design response-image
closure stratification. MML, inference, readiness, recovery, FACETS
comparison, simulation, and promotion remain open or unchanged.

P2j replaces the single P2i identity by a general fixed zero-offset operator.
For adjacent design `A`, owner incidence `P`, target response contrasts `z`,
and inverse slopes `w = 1 / alpha`, finite response-image membership is exactly

```text
diag(z) P w = A beta,  w > 0.
```

The zero offset makes common rescaling of `(w,beta)` harmless, so
`product(w) = 1` can be replaced by `sum(w) = 1` for membership. This gives a
linear program that maximizes the smallest owner weight. Every convergent
finite-image sequence also has a subsequence whose sum-normalized inverse slopes converge on
the compact simplex. Its limit is a nonnegative nonzero `w_star` satisfying
`diag(z) P w_star in col(A)`. Hence every closure point has a simplex-face
witness, and every missing finite boundary must lie on a proper face. P2j
enumerates all `2^G - 1` nonempty faces within the declared owner/face workload.

The face condition is necessary, not generally sufficient. P2j separately
certifies a sufficient first-order lift: for inactive owners `J`, positive
`c_j` and one additive direction `gamma` must satisfy
`(A gamma)_r = c_owner(r) z_r` on their rows. Then inactive inverse slopes
`epsilon c_j` and additive path `beta_star + epsilon gamma` give explicit
finite product-one parameters converging to the target. This construction
recovers both missing P2i axes and all five P2i strata. In contrast, the
three-owner all-ones rank-one operator has a nonnegative face witness for
`z=(1,-2,0)` even though every nonzero finite point has one common strict sign;
the target is outside the true closure and its first-order lift is infeasible.
Thus a nonnegative-kernel shortcut would repeat the P2h mistake at a new level.
Positive LP margins below the declared tolerance remain unclassified rather
than becoming false boundary exclusions. The next gate is higher-order face
lifts and a proof deciding every surviving face. Nonzero affine offsets, the
complete general likelihood envelope, finite-JMLE adjudication, MML,
inference, readiness, recovery, FACETS comparison, simulation, and promotion
remain open or unchanged.

P2k closes targetwise membership for every fixed zero-offset operator admitted
by its owner-rate workload. The finite-image relation is semialgebraic, so
curve selection supplies a boundary curve; after finite reparameterization,
the normalized inverse slopes have Puiseux leading terms. Their zero exponents
give the P2j active face, while distinct positive exponents order inactive
owners into tied rate stages. Only that order matters to the leading equations,
so the stages compress to consecutive integers `1,...,K`.

For owner rates `r_g`, positive coefficients `c_g`, and additive coefficients
`beta_k`, P2k imposes

```text
(A beta_k)_row = 0                       for k < r_owner(row),
(A beta_r_owner(row))_row = c_owner(row) z_row.
```

These conditions are linear. A feasible system gives
`w_g(epsilon)=c_g epsilon^r_g` and
`beta(epsilon)=sum_k epsilon^k beta_k`, hence an explicit finite product-one
path. Conversely every closure curve has one of these leading hierarchies.
Enumerating all ordered partitions of each inactive-owner set therefore
decides the target: one feasible hierarchy certifies closure membership; all
strictly infeasible hierarchies certify exclusion. The exact hierarchy count
for `n` inactive owners is `sum_k k! S(n,k)`; counts through seven owners are
`1, 3, 13, 75, 541, 4683, 47293`, and incomplete stage or workload caps fail
closed.

On the three-owner rank-one fixture, P2k finds seven hierarchies for
`z=(1,0,0)`. Besides the P2j first-order lift `(1,0,0)`, the rates `(2,0,1)`
and `(2,1,0)` produce genuine higher-order paths from singleton faces that P2j
left open. For `z=(1,-2,0)`, all three possible hierarchies `(1,1,0)`,
`(1,2,0)`, and `(2,1,0)` are infeasible, which proves the target outside the
closure despite its nonnegative P2j face witness. A numerically open P2k
hierarchy never weakens an existing P2j finite-path certificate. This completes
targetwise zero-offset closure membership, not a symbolic decomposition of the
whole response image. The next gate is the likelihood-limsup envelope over
these rate-hierarchy strata. Nonzero offsets, finite-JMLE adjudication, MML,
inference, readiness, recovery, FACETS comparison, simulation, and promotion
remain open or unchanged.

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
`scoresfree` GPCM result is compared with bounded GPCM only through the exact
probability-level item-only map now recorded in the repository; raw slope
labels remain insufficient. The deterministic ConQuest adapter/normalizer is
now bound to the retained four-arm additive review and excludes every finite
row under the unresolved source-precision contract. The next work is
independent numeric-resolution adjudication followed by a prospective
tolerance and candidate-bound replication, not a broad simulation. Multifacet
generalized-item score ownership remains a separate, unproved overlap.

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
