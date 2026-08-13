# mfrmr 0.2.3

This is the unreleased development line after CRAN publication of 0.2.2.
CRAN 0.2.2 remains the immutable public baseline; the changes below belong to
0.2.3 and must not be attributed retroactively to 0.2.2.

* Clarified the public response-family and generalized-MFRM boundary. The
  bounded GPCM is now described consistently as an aligned single-owner
  relative-slope many-facet GPCM, not the multiplicative task-by-rater
  generalized MFRM of Uto and Ueno. The FACETS coverage matrix explicitly
  keeps its Table 7 discrimination as a post-fit diagnostic rather than a
  jointly fitted GPCM slope. Ordered binary/polytomous responses, unsupported
  nominal and count likelihoods, and supported row-likelihood weights are
  separated; a weight cannot relabel an ordered response as a Poisson or
  grouped-binomial outcome or collapse distinct MML Person patterns. No
  response family, GPCM slope block,
  external comparison lane, readiness status, or release claim is broadened.

* Made the bounded-GPCM slope and PCM-comparison contracts explicit. The
  selected slope facet now documents one positive relative slope per facet
  level (G levels, G-1 free log-slope contrasts), while all other facets retain
  additive location effects only; criterion-owned and rater-owned slopes are
  supported as separate fits, but simultaneous criterion-by-rater slope blocks
  are not. `compare_mfrm()` now records aligned PCM versus GPCM as
  `PCM_in_GPCM_ic_only`: same-basis inference-ready MML fits may be compared by
  AIC, Person-BIC, and SABIC, and `build_weighting_review()` exposes the
  resulting reweighting, but the automatic chi-square likelihood-ratio test is
  intentionally withheld. Its new `comparison_contract` types each pair as
  selectable same-basis MML information-criterion evidence, descriptive JML
  reweighting, or a non-ready optimizer-trace comparison. An unpenalized JML
  likelihood gain is never promoted to PCM-versus-GPCM selection, and FACETS
  remains a direct comparator for the PCM/JML side only rather than for the
  jointly fitted free-slope GPCM side.

* Added a deliberately small paired PCM/GPCM JML calibration under unit and
  moderate Criterion-owned generating slopes. All six same-data pairs fitted,
  but only the PCM fits were inference-ready; the GPCM likelihood gains,
  apparent slope spreads, and recovery errors are consequently retained as
  optimizer-trace evidence, not a model-selection rate or confirmation. The
  runner also verifies that FACETS remains a comparator for the PCM/JML side
  only and authorizes no broad simulation or GPCM promotion.

* Fixed a prospective ADEMP contract for the larger paired PCM/GPCM
  simulation before executing it. The 16-condition covering registry separates
  JML and MML, Criterion- and Rater-owned slopes, exact unit-slope PCM truth,
  a five-percent practical indifference band, material GPCM alternatives,
  sample size and design stresses, 27 recovery/prediction/consequence metrics,
  and complete planned-pair failure denominators. JML model selection is
  structurally ineligible; MML information criteria remain blocked pending
  common-grid integration stability. Smoke, pilot, broad simulation, and
  confirmation execution are not authorized by the design artifact.

* Completed a three-seed, 147-fit PCM/JML Rater-anchor-by-sparsity stress
  calibration. It separates 0--75% directly fixed Raters from all-Rater common
  linking Persons and one versus two Raters per ordinary Person. Direct
  anchors did not identify the disconnected one-Rater design; small and
  moderate common sets returned fits but left extreme-Person readiness holds;
  a connected two-Rater cycle restored many ready fits. Anchor range coverage
  and a 0.25-logit misspecification control show why percentage and anchor
  quality must be reported separately. Exact range-spanning 25% advances only
  as a feasibility candidate; no operational rate, public default, or
  confirmation claim is selected.

* Froze the prospective expansion of that Rater-anchor stress before further
  execution. Its non-factorial 16-Rater registry crosses eight anchor
  conditions with seven complete or sparse networks and binds 10 independent
  seeds into 560 paired feasibility fits. External anchor-selection and error
  identities are separate from response seeds and are reused across networks;
  direct anchors and added rating assignments remain separate resource axes.
  Feasibility may calibrate runtime, failures, and dispersion only. The
  Pareto-based decision rules cannot select a percentage without a separately
  precisioned confirmation study and externally supplied resource costs.

* Executed the contract-bound 12-fit Rater-anchor smoke. All anchor reviews
  passed and all PCM/JML fits returned code zero with identified free designs,
  but none was inference-ready. Four complete-design fits exceeded the common
  terminal-gradient review tolerance; the single-Rater-plus-5%-link and
  two-Rater-cycle designs instead contained nine and three extreme Persons.
  Paired identities and external calibration errors were exactly reproducible.
  The software execution contract passed, while scientific readiness and the
  560-fit feasibility handoff remain explicitly withheld.

* Kept the ensuing diagnosis deliberately small. Across the four complete
  anchor conditions, doubling `maxit` from 200 to 400 changed no gradient,
  likelihood, Person estimate, or free-Rater estimate, so iteration budget did
  not explain the numerical hold. Without refitting sparse models, response-
  pattern accounting showed that two Raters per Person reduced endpoint-
  extreme Persons from nine to three. Feasibility remains closed pending one
  prospective decision about whether Person boundary coverage is a gate or a
  separately reported outcome for Rater-scale recovery.

* Connected targetwise zero-offset response-image closure to the positive-mass
  ordered-category JML objective. P2l derives the unique independent saturated
  adjacent contrasts as successive log mass ratios and proves strict response-
  space concavity and coercivity. A saturated target in the finite response
  image therefore certifies a finite global JMLE; a target in the closure but
  missing from the finite image gives the exact nonattained global supremum and
  a certified product-one likelihood-convergent path. The P2i positive-count
  example is recovered, and the same theorem is exercised with three ordered
  categories. A target outside the closure is now known to have a constrained
  maximum strictly below the saturated bound, while its value, location, and
  finite representability remain open. Grouped category mass only represents
  repeated rows of the existing ordered likelihood: nominal multinomial,
  count, frequency-response, nonzero-offset, production-fit, MML, inference,
  readiness, simulation, and FACETS comparison scopes are unchanged.

* Completed targetwise zero-offset response-image closure membership over
  higher-order slope-owner rate hierarchies. P2k uses semialgebraic curve
  selection and Puiseux leading terms to reduce every boundary approach to an
  ordered partition of inactive inverse slopes. For each hierarchy, all lower
  additive coefficients must vanish on the relevant owner rows and the leading
  coefficient must reproduce the target; these conditions are linear and a
  feasible solution gives an explicit product-one finite path. Exhaustive
  numerically decided hierarchy enumeration therefore either certifies a
  targetwise closure path or excludes the target. In the three-owner rank-one
  fixture, two genuinely higher-order paths resolve P2j first-order-open faces,
  while all three possible hierarchies exclude the `(1,-2,0)` outer-only
  target. A coarse P2k tolerance cannot weaken an earlier P2j path certificate.
  Symbolic whole-operator strata, the general boundary likelihood envelope,
  finite-JMLE adjudication, nonzero offsets, MML, inference, readiness,
  recovery, simulation, FACETS comparison, and promotion remain unchanged.

* Generalized the P2i four-cell response-image calculation to a
  workload-admitted fixed zero-offset JML GPCM operator. P2j proves that finite
  response membership is equivalent to positive inverse-slope feasibility
  `diag(z) P w = A beta`, compactifies inverse slopes on a simplex, enumerates
  every nonempty owner face, and proves that every finite-image closure point
  must have a nonnegative face witness. A separate linear lift condition gives
  explicit product-one finite paths for certified proper faces. The general
  chart exactly reproduces all five P2i strata. It also supplies a three-owner
  rank-one counterexample where a nonnegative face exists although the target
  is outside the true closure, so nonnegative feasibility alone is not promoted
  to general closure membership. Near-zero positive LP margins remain open
  rather than becoming false boundary exclusions. Nonzero affine offsets,
  higher-order face lifts, the complete general closure and likelihood
  envelope, MML, inference, readiness, recovery, simulation, FACETS
  comparison, and promotion remain unchanged.

* Completed the finite response-image closure and likelihood envelope for the
  exact binary two-Person, two-slope-owner JML GPCM operator isolated by P2h.
  If `d1 = z1 - z2` and `d2 = z3 - z4`, the finite image is exactly the two
  same-sign interiors plus their common zero-difference intersection, its
  finite closure is `d1 * d2 >= 0`, and its only missing finite strata are the
  two one-zero-difference axes. With strictly positive success and failure
  mass in every cell, unbounded contrast paths have likelihood limit minus
  infinity and the two bounded-escape axes have exact pooled-logit maxima.
  The expanded-row fixture with success counts `(2, 4, 1, 1)` and failure
  counts `(1, 1, 1, 1)` has independent optimum
  `(log(2), log(4), 0, 0)` on a missing axis. Thus its global supremum is
  classified and no finite JMLE exists even though every design cell contains
  both binary outcomes. A guarded current-fit wrapper reconstructs the exact
  retained operator and reproduces the result without promoting its finite
  optimizer trace. The theorem is complete only for this minimal operator;
  general GPCM designs, MML, inference, readiness, recovery, simulation,
  FACETS comparison, and promotion remain unchanged.

* Closed the response-equivalence-quotient branch of the JML GPCM finite-
  attainment investigation in the negative. An exact binary two-Person,
  two-slope-owner construction has finite response contrasts
  `(1, 2, exp(-2t), 2 exp(-2t))` along an escaping parameter path and hence
  converges to `(1, 2, 0, 0)`. An exact affine row relation proves that no
  finite GPCM parameter represents that target: the two zero target rows
  force two unscaled utilities to zero, which would force the two common-
  slope nonzero target rows to agree. Thus collapsing finite parameter fibres
  by response equivalence does not make the finite response image closed,
  complete, or proper; a completion by boundary strata is still required.
  The P2h certificate is theorem-only and does not assert that this boundary
  target is competitive, that a finite JMLE fails to exist, or that the full
  boundary envelope is complete. MML, inference, readiness, recovery,
  simulation, FACETS comparison, and promotion remain unchanged.

* Added an exact exponential slope--utility balance oracle for JML GPCM.
  Finite exponential sums in the retained constrained free-additive
  coordinates are combined with affine sum-zero log-slope paths, and terms
  with equal combined exponents are aggregated before positive, zero, and
  negative rates are handed to the P2e contrast-flag limit. A divergent
  parameter path with no positive response-contrast exponent is therefore an
  explicit bounded-image witness that the parameter-to-response-contrast map
  is not proper. Production fits certify the canonical all-zero-utility
  witness only when the affine additive offset is structurally and exactly
  zero; nonzero anchors fail closed instead of receiving a universal
  nonproperness claim. The finite exponential family does not enumerate all
  bounded-image escapes or complete the escaping-sequence boundary envelope,
  so finite attainment, global boundary absence, readiness, uncertainty, MML,
  recovery, simulation, FACETS comparison, and promotion are unchanged.

* Added a JML GPCM global finite-attainment and non-attainment adjudicator.
  A parameter-reachable divergent P2c path whose analytic likelihood limit is
  exactly zero now proves that the universal conditional log-likelihood
  supremum is zero and cannot be attained by any finite GPCM parameter vector.
  Free extreme-Person rays and certified global additive recession cones also
  prove finite-JMLE nonexistence because they strictly improve the likelihood
  from every finite point, although they need not identify the supremum value.
  Conversely, a finite point strictly above a complete upper envelope of all
  escaping-sequence limsups would imply compactness of its upper level set and
  finite attainment. P2e does not construct that complete envelope, so the
  executable implication remains conditional and a negative boundary search
  never promotes an optimizer trace to a finite JMLE. Production readiness,
  uncertainty, MML, FACETS comparison, recovery, simulation, and promotion are
  unchanged.

* Added a JML GPCM parameter-sequence contrast-flag compactification theorem.
  Rather than transporting a Euclidean parameter direction through the
  nonlinear slope-times-utility map, every finite parameter point is first
  mapped exactly to category logits relative to category zero. Every sequence
  in that finite-dimensional contrast space then has a further subsequence
  which is either convergent or has a finite scale-separated flag, a finite
  base, and an `o(1)` contrast remainder. Exact lexicographic maximization of
  the divergent flag followed by a base softmax classifies the row and joint
  likelihood limit along that further subsequence, including finite and
  negative-infinite cases, without assuming common power scales. Production
  fits declare no sequence and extract no flag. Different subsequences may
  have different limits, so original-sequence convergence, competitiveness,
  global boundary status, finite-MLE existence, MML, inference, readiness,
  FACETS comparison, recovery, simulation, and promotion remain open or
  unchanged.

* Added a deliberately non-promoting JML GPCM optimizer-sequence diagnostic
  and a narrow decaying-logit remainder theorem. Optimizer stage endpoints are
  available only transiently during fitting and are discarded before the fit
  is returned. Fewer than three endpoints produce an explicit insufficient-
  sequence state; longer explicit sequences may receive a finite Euclidean
  SVD direction/scale summary, but those basis-dependent estimates have no
  asymptotic force and cannot enter the P2b oracle. Separately, a completed P2c
  path may be extended by finitely many fixed scaled-logit directions times
  strictly ordered negative powers: their within-row contrasts vanish, so row
  probabilities and the joint likelihood retain the declared P2b limit. This
  does not classify arbitrary utility, slope, or logit remainders; infer a path
  or power law from optimizer output; establish competitiveness or a global
  boundary; change readiness or uncertainty; or authorize FACETS comparison,
  recovery, simulation, or promotion.

* Added a forward parameter-space reachability contract for declared JML GPCM
  lexicographic paths. Caller-declared directions in the retained constrained
  free-additive coordinates are mapped through the exact sparse adjacent-
  utility operator and accumulated with category zero fixed at zero. This
  makes the resulting cumulative-utility path reachable by construction and
  preserves P2b's exact-tie contract without a tolerance-dependent inverse
  projection. A current-fit wrapper reconstructs the retained base utilities,
  scores, weights, and log slopes before invoking P2b, and its finite-distance
  evaluator uses the same constructed path. Production fits record the
  operator and coordinate map but declare no path. Arbitrary inverse utility
  reachability, optimizer-trace direction or scale inference, path search,
  remainder-stable ties, monotonicity, competitiveness, global boundary
  claims, MML, inference, FACETS comparison, recovery, simulation, and
  promotion remain open or unchanged.

* Added a declared-path lexicographic likelihood-limit oracle for JML GPCM.
  The internal v1 contract accepts at most two strictly ordered positive-power
  scales in each of the expanded sum-zero log-slope and cumulative-utility
  blocks. It analytically separates infinite-slope concentration, vanishing-
  slope uniformity, and finite-slope softmax limits after exact additive tie
  resolution; zero-weight rows and excluded observed categories are handled
  explicitly, and a direct finite-distance evaluator checks representative
  convergence paths. Production fits advertise the oracle without deriving or
  searching for a path. Exact coefficient identities, caller-supplied utility
  directions, and polynomial-versus-exponential dominance are part of the
  narrow contract; parameter-space reachability, remainders, arbitrary paths,
  monotonicity, competitiveness, common subsequence limits, global boundary
  claims, MML, inference, FACETS comparison, recovery, simulation, and
  promotion remain open or unchanged.

* Added a finite-depth lexicographic log-slope hierarchy audit for JML GPCM.
  For a declared ordered family of expanded sum-zero rate vectors, each stage
  resolves only slope levels which were zero at every faster stage. The first
  nonzero stage resolves at least two levels and every later nonzero stage at
  least one, giving a sharp maximum of `J-1` stages for `J` slope levels.
  Later active-coordinate restrictions need not themselves sum to zero because
  slower identification compensation can occur in already resolved levels.
  A two-stage construction with common primary rate `(1,-1,0)` shows that
  opposite secondary rates send the zero-primary slope to infinity versus
  zero and yield likelihood limits `0` versus `-log(2)`. The hierarchy is
  therefore a structural growth-order decomposition only; arbitrary-path
  likelihoods, additive hierarchies, global boundary absence, MML, inference,
  FACETS comparison, recovery, simulation, and promotion remain open or
  unchanged.

* Added a boundary-compactification scope audit for fixed-objective JML GPCM.
  Every unbounded finite-dimensional parameter sequence has a convergent
  normalized subsequence, and every nonzero limiting expanded log-slope
  direction receives a finite positive/zero/leading-negative/deeper-negative
  primary role pattern. The audit records exact role counts and separates this
  structural enumeration from completed boundary-likelihood classification.
  Alternating normalized directions demonstrate why whole-sequence rate
  convergence is unnecessary for the subsequence reduction, while an explicit
  `t(1,-1,0) + sqrt(t)(-0.5,-0.5,1)` construction proves that zero primary-rate
  coordinates can retain a divergent secondary hierarchy. That hierarchy,
  nonvanishing residuals, general curved paths, global boundary absence, MML,
  inference, FACETS comparison, recovery, simulation, and promotion remain
  unclassified or unchanged.

* Added a positive-only asymptotically-affine transport audit for JML GPCM
  boundary certificates. An already certified slope-only, ordered-pair, or
  canonical constant-rate path now carries the same analytic boundary value
  over curved perturbations whose additive and sum-zero expanded-log-slope
  residuals converge to zero. A direct `(3,-1,-2)` curve verifies the result.
  A separate zero-rate construction shows that bounded residuals which do not
  vanish can produce different subsequential likelihood limits, so general
  curved and rate-nonconvergent paths remain unclassified. Negative source
  searches gain no curved-path absence claim, and readiness, uncertainty,
  FACETS comparison, recovery, simulation, and promotion remain unchanged.

* Extended the fixed-objective JML GPCM joint-boundary audit from ordered
  `+1/-1` log-slope pairs to canonical general constant-rate vectors. The
  finite family partitions slope levels into positive, zero,
  leading-negative, and deeper-negative groups while preserving sum-zero log
  slopes; pair paths remain exact special cases. A constructed `(3,-1,-2)`
  path is certified although every pair check is negative, and its direct
  likelihood trace converges to the analytic boundary. Three-level production
  fits evaluate 12 additional paths beyond six pairs. Workload non-evaluation,
  curved or rate-nonconvergent paths, global boundary absence, MML, inference,
  FACETS equivalence, recovery, and broad simulation remain separate or open.

* Added a fixed-objective terminal-gradient stability audit for free-slope
  JML GPCM. It reconstructs the retained unpenalized conditional objective and
  analytic score, checks stored optimizer summaries and selected polish stage,
  verifies a deterministic set of free coordinates by central differences,
  and reports parameter-block gradient norms. Positive slope or joint-boundary
  certificates take precedence even when the finite-point gradient is zero or
  small. Scoped negative path searches permit only retained-point first-order
  typing; they do not certify a finite global maximum, boundary absence,
  uncertainty, FACETS comparability, or inference readiness. The existing
  implementation tolerance is recorded but is not frozen as a scientific
  criterion.

* Added an estimator-specific fixed-objective boundary classifier for JML
  GPCM. It combines the existing slope-only recession and joint
  additive/log-slope audits while preserving their unequal evidential force:
  a positive sufficient certificate is typed, but two scoped negatives mean
  only that no path was certified in the bounded audited families. A finite
  optimizer iterate remains a numerical trace rather than a finite global-MLE
  claim. Numerical indeterminacy, workload non-evaluation, unit-slope
  reduction, and objective mismatch are separate states. The classifier is
  bound to mfrmr's identified unpenalized fixed-effects JML objective with no
  finite parameter box; it is not reused for Wijayanto-style PJML, finite-box
  JML, or MML and does not change readiness, uncertainty, comparison, or GPCM
  promotion status.

* Added a deterministic no-fit FACETS/GPCM JML comparison-role contract. It
  freezes seven estimator identities and eight separate comparison lanes:
  FACETS PCM/JMLE is the only future direct common-estimand FACETS lane;
  unit-slope GPCM/PCM is an internal reduction; non-unit GPCM uses truth-first
  recovery with FACETS PCM only as a misspecification control; and FACETS
  Table 7 discrimination remains a post-fit diagnostic that does not update
  the fitted PCM estimates. Wijayanto penalized JML, Rirt finite-box JML,
  Muraki MML-EM, and mfrmr's unpenalized no-box JML retain different objective,
  parameter-space, and Person-treatment identities. The contract ran no
  external fit, froze no tolerance, and authorizes no GPCM promotion or broad
  simulation.

* Added a deterministic ConQuest/TAM/immer/mfrmr algorithm, correlation, and
  log-domain audit. On independent free coordinates and excluding deviance,
  the smallest observed Pearson correlation is above `0.999999999995` for
  ConQuest--mfrmr and still closer to one for the matched TAM comparisons.
  Correlation remains descriptive and is accompanied by affine, RMSE,
  maximum-difference, deviance, and q31/q61 checks. The audit distinguishes
  ConQuest/TAM's broad fixed-grid MML/EM relationship from mfrmr's default
  transformed Gauss--Hermite/direct-optimization route and from immer's
  conditional, composite-conditional, or joint objectives. It also adds a
  production-path underflow regression: `log(0.01^200)` is `-Inf`, whereas
  mfrmr sums log probabilities and remains within `2.51e-12` of
  `200*log(0.01)`. The external residuals are not mislabelled as
  floating-point-only, and the audit creates no scientific-equivalence,
  decision-invariance, or release claim.

* Added a loaded-function-bound estimand-eligibility contract for immer 1.5-13
  CML and CCML. It admits only exactly mapped item, step, criterion-step, and
  rater contrasts to a future structural-reference lane. Person ability and
  population parameters are conditioned out; CML and pairwise-composite CCML
  objectives cannot enter MML/JML objective or IC aggregates; neither route
  estimates free GPCM slopes. No fit, tolerance, candidate, comparison pass,
  native mfrmr CML/CCML claim, or release decision is created.

* Added a source- and loaded-function-bound TAM 4.3-25 MML calibration on the
  additive complete-crossing RSM/PCM fixture. The runner makes the TAM
  `constraint="cases"` location transform explicit, compares 46 coordinates
  and both deviances at q31/q61, and retains mfrmr's independent probability
  and marginal-likelihood oracle checks. The observed maximum transformed
  coordinate and deviance differences are below `1e-7` and `2.23e-7`,
  respectively. They are calibration observations, not `EXT-TAM-TOL`:
  candidate binding, comparison passage, free-slope GPCM, sparse/DFF/fit/rank
  extension, inference readiness, and release authorization remain false.

* Completed the prospectively frozen ConQuest candidate-003 core. All six
  ordered Binary/RSM/PCM q31/q61 executions pass the post-incident semantic
  gate, and all 50 expected native/console outputs are nonempty and SHA-bound.
  Exact native A matrices and 54 exact-reported-decimal coordinates feed the
  frozen 57-row adjudicator: all 19 cross-engine and 38 within-engine
  integration rows pass their prespecified limits. This closes only the
  bounded Binary/RSM/PCM MML exact-reported-decimal overlap. The ConQuest
  hidden-solution interval remains undocumented; scientific equivalence,
  inference readiness, DFF/fit/rank/ordering invariance, sparse/GPCM
  extension, large simulation, and release authorization remain false.

* Stopped candidate 002 after its first Binary arm failed semantically despite
  process exit status zero and an `End of Program` marker. ConQuest 5.47.5
  rejected the generated multiline C-style prose preamble, so no model was
  estimated and the remaining five arms were not launched. The public Binary
  command generator now emits command-only `.cqc` input beginning with
  `datafile`; explanatory prose remains outside the executable input. Candidate
  002 is non-reusable and no candidate-002 comparison was attempted. Candidate
  003 was subsequently rebuilt and reviewed under the repaired protocol.

* Froze the candidate-002 native execution handoff after rechecking the exact
  ConQuest 5.47.5 executable, pre-handoff source, candidate/model/reference
  bundles, six working-directory/stdin/console mappings, and 50 absent output
  paths. It authorizes exactly one six-arm run and no output reuse. Comparison,
  equivalence, confirmation, sparse/GPCM extension, and simulation remain
  unauthorized until the new native outputs pass their separate review.

* Generated all six mfrmr q31/q61 numerical references for corrected ConQuest
  candidate 002 from its exact pre-binding source commit. The four additive
  RSM/PCM arms pass independent probability/marginal-likelihood oracles and
  exhaustive local score-rank checks; the Binary pair passes its explicitly
  weaker converged/finite/internal-coordinate-consistency contract. All three
  families pass the prospective within-engine coordinate and deviance budgets.
  Every fit remains non-inference-ready, numerical agreement cannot promote
  inference, and ConQuest execution remains false until a separate exact
  execution-handoff contract is frozen.

* Invalidated the first prospective ConQuest candidate before execution: its
  RSM/PCM commands were item-only and could not evaluate the Rater/Criterion
  estimands required by the frozen 57-row table. The corrected candidate 002
  now binds six command/input identities plus an estimand-derived model-
  dimension registry. Its RSM/PCM arms use the native additive models
  `rater + criterion + step` and `rater + criterion + criterion*step`; exact
  model statements, facet declarations, nodes, input schemas, free dimensions,
  and estimand classes all pass. All 50 expected outputs, including additive A
  matrices, remain absent. External execution remains held pending the exact
  corrected-reference and handoff preflight; numerical-reference use is
  explicitly non-inferential and cannot promote fit readiness or equivalence.

* Froze the 57-row future-candidate-only ConQuest numerical budget before any
  new candidate output exists. Symmetric `EXT-CQ-TOL` limits are `1e-5` for
  common model coordinates and `2e-6` for positive deviance;
  `IC-INTEGRATION-TOL` is `2e-6` for both units. The canonical table SHA-256 is
  `64ab3338dc5e5144d98a7a8775512b5665f407e4d8778972521ff5bfe8754521`.
  The opened calibration informed the rule but remains permanently ineligible
  to pass it. Candidate binding is handled by the later source-bound contract;
  execution, scientific/hidden-solution equivalence, DFF/fit/rank invariance,
  and confirmation remain false.

* Added the missing Binary ConQuest q31/q61 reported-output normalizer. Its
  pre-result registry contains 18 rows: three population coordinates, five
  free item difficulties, and deviance in each arm. Missing retained Binary
  files remain 18 explicit missing rows rather than reconstructed evidence.
  A new content-hashed six-arm registry joins these rows with the 36 retained
  RSM/PCM coordinates and distinguishes adapter/parser implementation coverage
  (6/6 arms) from retained native calibration evidence (4/6 arms). The
  prospective preflight now requires the exact normalizer and source-precision
  registry hashes, not merely arbitrary SHA-shaped declarations. The later
  prospective freeze supplies the numerical table, but no candidate run,
  comparison, equivalence, or confirmation is created.

* Evaluated the retained exact ConQuest RSM/PCM decimal coordinates on an
  independent common-likelihood oracle. Across q31/q61, reported-point versus
  mfrmr-point deviance increases are below `4.75e-10`, all Hessians are
  positive definite, and same-point integration differences are below
  `2.73e-12`. These are opened calibration scales, not tolerances or
  equivalence. The audit also corrected the next-core topology: the 57-row
  registry requires six `Binary/RSM/PCM x q31/q61` arms, complete normalizer
  and precision coverage, and rejects the former four-arm interpretation.

* Split ConQuest source precision into exact reported-decimal and hidden-
  optimizer-solution strata. The SHA-bound 5.47.5 manual documents that the
  screen `decimals` option is ignored for file output but provides no file
  rounding rule or hidden-precision interval. A new lexical-decimal contract
  therefore makes all 36 retained RSM/PCM coordinates structurally eligible
  only for comparison to the exact decimals written to file; the hidden-
  solution stratum remains zero-eligible. The prospective tolerance binding is
  pinned to that reported-output policy and forbids promotion to hidden-
  solution equivalence. The later numerical budget applies only to this exact
  reported-decimal stratum; no candidate comparison, equivalence, or
  confirmation is created.

* Added a prospective ConQuest tolerance-freeze validator. It registers 19
  binary/RSM/PCM cross-engine `EXT-CQ-TOL` rows and 38 engine-specific
  `IC-INTEGRATION-TOL` rows, requires signed and absolute estimand-level rules
  with source hashes, requires the independently frozen exact reported-decimal
  source-precision policy, and binds the clean candidate before any candidate
  output exists or is opened. The opened four-arm calibration may inform a
  future error budget but is permanently ineligible under the new rule. The
  empty template remains `pilot_required`. A separately hash-bound canonical
  table now freezes all 57 values, but candidate binding and execution,
  equivalence, confirmation, sparse extension, and simulation remain
  unauthorized.

* Added an estimator-specific nonlinear local-estimability classification.
  JML GPCM uses full free-coordinate rank of the conditional adjacent-logit
  Jacobian. Unit-weight fixed-quadrature MML can use full rank of observed
  Person-pattern scores as a sufficient subset-of-positive-support certificate,
  falling back to exhaustive all-pattern information when available. A
  deficient observed subset remains inconclusive. The typed result does not
  claim global or continuous-integral identification, classify weak
  information or boundaries, change fit readiness, or authorize a P1s rerun.

* Added the no-fit P1t external-reproducibility preflight for the admitted P1s
  GPCM denominator. Its eight owner/estimator routes crossed with ConQuest,
  TAM, immer, and sirt yield 32 program-route decisions but zero established
  exact full-model routes. Five item-only, unit-slope, equal-discrimination, or
  near-neighbour projections remain separately labelled; none is P1s
  reproduction. No external execution, numeric comparison, replication,
  broad simulation, or confirmation is authorized.

* Completed the bounded P1s current-default paired-owner GPCM smoke. All eight
  Criterion/Rater source-owner, fitted-owner, and JML/MML routes returned fit
  objects; all route identity checks and all 12 required evidence surfaces
  passed, with exact 1--4 support and common-data hashes retained. A warning-
  as-error audit also fixed recycled nonlinear-block selection in the GPCM MML
  estimability audit. All eight fits remain `review` and zero are inference
  ready; two retain terminal-gradient review. Recovery, owner ranking,
  external comparison, added replication, broad simulation, fit/DFF
  promotion, and confirmation remain unauthorized.

* Added a no-fit P1r contract for the current-default paired-owner GPCM smoke.
  Two non-unit source-owner datasets are each shared by Criterion/Rater and
  JML/MML routes, yielding eight planned fits with explicit
  `free_population`, 1--4 support, runtime, replay, and 13-surface identity
  requirements. Content-hash and mutation guards pass. P1s has now executed
  this admitted smoke; P1r itself remains the immutable prospective contract.

* Added a no-fit owner-identity P1q audit over the sealed 120-row GPCM pilot.
  Row and checkpoint identities are intact, but frozen aggregate tables do not
  directly retain every owner, ability-scale, exact-category-support, and
  runtime field. A non-mutating derived envelope restores complete identity on
  seven aggregate surfaces. The historical MML pilot used the fixed-standard-
  normal contract and does not represent the current `free_population`
  default. Identity transport needs no new simulation; current-default owner
  evidence, gate passage, core promotion, broad simulation, and confirmation
  remain open or unauthorized.

* Added a no-fit GPCM release-scope P1p disposition. The completed reflected
  finite-grid claim is retained, while a continuous coefficient-ratio theorem
  is deferred because it is neither publicly advertised nor an independent
  0.2.3 release-spine item. The next GPCM release blocker is the existing
  Criterion-versus-Rater owner evidence partition. Core promotion, inferential
  fit/DFF use, broad simulation, and confirmation remain unauthorized.

* Added a four-fixture GPCM reflected finite-grid P1o registry. The exact P1n
  map verifies all 1,362 stored P1k/P1l high-side points without refitting and
  transports 168 classified cells to 168 low-side cells. Maximum objective and
  gradient differences are about `3.41e-13` and `8.90e-13`. The 336-cell
  finite-grid registry is complete, while continuous profile, two-target-face,
  source-selection, and inferential claims remain false.

* Added an exact GPCM category-reflection transport P1n audit. Reversing scores,
  negating location/Rater coordinates, reversing and negating full step
  vectors, and mirroring Gaussian quadrature transports the four P1m local
  mechanisms to the exact-low and near-low fixtures without refitting. All 87
  stored points pass; maximum objective and gradient-transport differences are
  about `2.27e-13` and `2.17e-13`. Four scheduled independent numeric-gradient
  checks pass within `1.86e-8`. This closes reflected representative transport,
  not the complete continuous ratio profile, face hierarchy, source selection,
  or downstream inference.

* Added a four-representative GPCM local profile-turning-point P1m audit. A
  stricter `2e-6` nuisance-gradient contract plus Richardson-Hessian Newton
  polish narrows one profile maximum and two profile minima to `rho` brackets
  below `7.2e-8`; both starts agree at the refined points and all nuisance
  Hessians are positive definite. One monotone representative remains
  increasing over a nine-point audit. All 87 recorded points are eligible.
  These results support the local P1l mechanisms but intentionally leave
  continuous monotonicity, global profile certification, reflected transport,
  face closure, source selection, and downstream Hessian/DFF/fit/rank claims
  false.

* Added a scoped GPCM fixed-`rho` nuisance-continuation P1l audit for P1k's 43
  nonmatching cells. Both starts coalesce at every common `rho`: all 766
  objective-discordant-lane fits and all 260 coordinate-only-lane fits are
  eligible, with same-`rho` objective differences below about `1.21e-9` and
  nuisance-coordinate differences below about `1.36e-5`. The 33 formerly
  objective-discordant cells separate into 22 profiled-maximum brackets, six
  profiled-minimum brackets, and five monotone-increasing grids; all ten
  coordinate-only cells are single-minimum brackets. This narrows the issue
  from multiple nuisance basins to one-dimensional ratio-profile geometry and
  KKT stopping tolerance. The audit remains a finite grid: reflected fixtures,
  continuous profile certification, face closure, source selection, and
  downstream Hessian/DFF/fit/rank claims remain open.

* Added a representative GPCM fixed-`mu` ratio P1k pilot. Natural `rho` is
  optimized on `[0,1]` with distinct lower/interior/upper KKT rules from
  singleton and P1i-derived starts. All 336 exact-high/near-high fits are
  eligible; q ranges stay below about `5.69e-13`, KKT sup-norms below about
  `9.72e-5`, and independent gradient differences below about `2.19e-8`.
  Nevertheless only 125/168 cells reproduce the same solution, ten reproduce
  the same objective at different `rho`, and 33 retain different eligible KKT
  objectives. P1l subsequently classifies those discrepancies; P1k alone does
  not distinguish approximate KKT stopping from one-dimensional profile
  geometry. All best observed candidates remain above the qualified interior,
  but reflected fixtures, ratio-profile closure, three-target faces, source
  selection, and inference remain open.

* Added a GPCM ordered coefficient-ratio P1j audit. The finite chart
  `lambda_slow=mu` and `lambda_fast=mu*rho` transports all 288 positive P1i
  points within about `2.27e-13` objective difference and identifies its
  `rho=0` edge exactly with all 672 frozen P1h/P1g singleton-grid directions.
  Nuisance and natural-`mu` gradients agree at that edge, and independent
  natural-`rho` derivatives agree within about `6.32e-8`. Only 280/672
  boundary derivatives are nonnegative; all directions at `mu=0.1` and `0.2`
  improve when the fast coefficient is released. Thus the likelihood identity
  is certified but fixed-`mu` ratio profiles, two-target closure, three-target
  faces, source selection, and downstream inference remain open.

* Added a GPCM two-target radial P1i screen. An exact geometric-mean radial
  coordinate and one free log coefficient ratio reproduce the canonical P1f
  two-target likelihood within about `1.14e-13`. Of 336 two-route fits, 318
  are eligible and 10/24 scenario-by-pair grids reach mutually consistent
  finite-ratio deterministic-Rater endpoints, all above the qualified
  interior. The other 14 grids expose an unresolved coefficient-ratio
  boundary: the largest route difference is about `0.0599` and returned
  endpoint log ratios reach about `-7.10`. This is recorded as structural
  incomplete closure, not repaired by more iterations or a denser radial grid.
  Coefficient-ratio boundaries, three-target faces, the remaining no-random-
  product hierarchy, upper boundary, source selection, and downstream
  inference remain open.

* Added a GPCM remaining-single-target P1h screen. The exact P1g scaled
  construction is applied to C1--C3 while C4 evidence is reused rather than
  refitted. All 168 new two-route fits pass; route differences are at most
  about `1.21e-9`, q=61/91/121 ranges at most about `5.68e-13`, and direct
  singleton deterministic-Rater endpoints agree with independent conditional
  oracles to about `2.50e-12`. All C1--C3 profiles descend toward endpoints
  above the qualified interior. Together with P1g, all four single-target
  grids and singleton-Rater strata are screened, but multiple-target faces,
  multi-criterion Rater strata, the upper boundary, source selection, and
  downstream inference remain open.

* Added a GPCM C4 face-to-deterministic-Rater P1g audit. The exact scaled
  coordinates `B=lambda*q`, `V4=lambda*u4`, and `G4=lambda*H4` remove the
  false appearance of convergence caused by a vanishing log-coefficient
  gradient and remain finite at `lambda=0`. All 56 two-route fixed-lambda
  nuisance fits pass; route objectives agree within about `5.76e-10`, and a
  direct conditional-GPCM oracle matches the deterministic-Rater endpoint to
  about `1.93e-12`. The declared profile descends toward that endpoint, which
  remains 2.08--2.58 objective units above the qualified interior. This closes
  only the bounded C4 grid and its endpoint; the full C4 face, other 13 random-
  target faces, empty-random hierarchy, upper boundary, source selection, and
  downstream inference remain open.

* Added a GPCM lower-boundary slope-rate-cone P1f audit. Under declining
  population SD and geometric-mean-one slopes, the normalized finite-random-
  coefficient rates are affinely identical to a standard simplex. All 14
  nonempty proper target faces for four criteria are enumerated, and one
  canonical reduced likelihood with free positive `slope * population SD`
  coefficients is independently differentiated. Exact conversion reproduces
  all eight P1e C4 objectives within about `1.14e-13`, but the newly released
  coefficient direction has objective gradient 2.42--2.89 and a prespecified
  signed probe improves every point. P1e therefore closed only its fixed-
  coefficient path, not the entire C4 face. Target-face optimization, the no-
  random-product deterministic-Rater hierarchy, upper boundary, source
  selection, and downstream inference remain closed.

* Added a coordinate-scaled GPCM joint-limit P1e audit for the declared C4
  lower-boundary ray. An exact rank-20 affine reparameterization separates
  coordinates shrinking as `exp(-t)` from non-target locations and steps that
  can grow as `exp(t/3)`. All 32 finite fits pass the declared transformed-
  scale rule, although only one passes the same absolute rule in raw nuisance
  coordinates. An independently derived direct `t = Inf` likelihood retains
  C4 Rater/latent variation and makes C1--C3 deterministic with respect to
  those facets; all eight two-route fits pass, agree within about `3.41e-13`,
  and are 3.38--4.15 objective units worse than the interior candidate
  conditional on their fixed `slope * population SD` coefficient. P1f later
  showed that this coefficient is not stationary when released, so P1e closes
  only its declared fixed-coefficient path, not the entire C4 target face.

* Added a bounded GPCM joint zero-population-variance/log-slope P1d audit. It
  preserves geometric-mean-one slopes while holding the observed C4
  `slope * population SD` term constant, so the fixed-nuisance q=1 limit is
  explicitly prohibited on this non-uniform sequence. Same-vector q=61/91/121
  objective ranges stay below about `1.74e-11`, but only 14/48 constrained
  path fits pass nuisance stationarity and none with `t >= 4` does. Although
  every terminal objective is worse than the qualified interior anchor, route
  and derivative behavior remains nonstationary; no recession, turnback, or
  source solution is certified. The next narrow gate is a coordinate-aware
  reduced-limit/reparameterization audit, not more path points, a larger
  iteration ceiling, downstream inference, or broad simulation.

* Added an exact fixed-nuisance GPCM zero-population-variance P1c audit. The
  q=1 node-zero/weight-one likelihood agrees with an independent conditional-
  GPCM oracle to about `1.71e-12` and is exactly invariant to its irrelevant
  finite log-variance placeholder. However, none of 12 three-start boundary
  nuisance refits passes the existing stationarity rule, and the returned
  traces contain strongly start-sensitive expanded slopes. They are therefore
  excluded from boundary-versus-interior comparison even though all return
  finite objectives. The next narrow gate is a prespecified zero-variance-by-
  slope joint path, not solution replacement, Hessian/DFF/fit/rank work, or a
  broad simulation.

* Added a bounded GPCM low-basin quadrature P1b audit. The P1a-qualified local
  basin is independently refit at q=31, 61, and 91 and every vector is
  reevaluated at held-out q=121 with analytic and independent numeric scores,
  labelled coordinates, EAPs, and posterior SDs. All 12 qualified arms pass
  the existing native numerical rule and agree closely across q, whereas none
  of the 12 predesignated default/high-variance diagnostic arms passes and
  several fail dramatically on the common evaluator. This conditionally
  closes the finite-q local-basin calibration, but it neither certifies the
  continuous integral nor selects a package solution. Population-boundary,
  uncertainty, DFF/fit/rank, simulation, and capability gates remain closed.

* Added a bounded q=31 GPCM population-variance nuisance-profile P1a audit.
  At ten fixed `log_sigma2` values, all other free coordinates are reoptimized
  independently from the default and low-variance P0b basins using the same
  gradient-polish policy as the package optimizer. All four reflected endpoint
  cases have a locally stationary finite-grid minimum at the low-variance
  anchor, but the high-variance tails fail nuisance stationarity and the wider
  high/low curves are not numerically reflection-invariant. The result narrows
  the next q=31/61/91 audit to a qualified low-variance candidate while keeping
  the default basin diagnostic-only. It selects no package solution and
  promotes no boundary, integration, uncertainty, DFF/fit/rank, simulation, or
  capability claim.

* Added a deterministic GPCM endpoint solution-stability P0b instrument and
  execution record. Reflected all-5/all-1 and 19/20 near-endpoint Person cases
  retain all five categories and replay the seven fixed P0 starts. Finite MML
  EAP provenance is preserved, but every default source fit has a nonconverged,
  extremely large population variance; in each scenario the prespecified
  `variance_low` start is the only existing-rule pass and has a materially
  lower common objective. All candidates remain review-only. No solution,
  tolerance, continuous-integration result, uncertainty, DFF/fit/rank result,
  simulation, or capability is promoted.

* Added a GPCM solution and decision-stability roadmap and its first
  deterministic P0 validation instrument. Seven fixed GPCM-MML starts are
  reevaluated through one canonical objective, analytic and independent
  numeric scores, five free-dimension counts, labelled expanded coordinates,
  and a fail-closed decision signature. The fixed benign microcase returned
  near one numerical solution, but boundary, Hessian, interval, DFF, fit,
  rank, and separation gates remain explicitly unevaluated. Regularized
  covariance, code-zero
  convergence, close objectives, and high rank correlations are insufficient
  on their own; no tolerance, simulation, formal DFF/fit rule, selected
  solution, or capability is promoted.

* Refined the five-category endpoint-response roadmap. It now
  separates all-5/all-1 Persons from all-5/all-1 Raters, observed support from
  certified constrained recession, isolated from joint attribution, JML
  extended boundaries from MML EAPs and adjusted displays, and exact from
  near-extreme patterns. Deterministic sign, negative, anchor, interaction,
  category, and public-surface gates precede any bounded simulation or external
  FACETS work. This planning change promotes no GPCM, fit, DFF, or external
  capability.

* Bound the retained ConQuest additive RSM/PCM four-arm review to the generic
  external-comparison eligibility ledger. A pre-result registry fixes 36
  coordinate rows; all 36 retained results are observed, successful, and
  finite, but all are excluded because the native CSV rounding rule remains
  unestablished. The upstream reviewer now also requires exact cross-manifest
  equality of run, model, quadrature nodes, free dimension, and input SHA-256.
  Missing, failed, unexpected, duplicate, model-conflicting, and unaudited-
  precision controls fail closed. No tolerance or equivalence is promoted.

* Extended the external-comparison admission contract so
  statistical penalties, finite parameter boxes, and source numerical
  precision cannot be hidden inside a generic estimator or correction label.
  Added sirt as a source/version-bound comparator: equal-discrimination PCM is
  structurally admissible, while the default free-slope route is rejected as
  an exact mfrmr match because `rm.facets()` documents finite `0.05--10` slope
  bounds. TAM and immer adjustment/bias-correction modes remain separate
  strata. This changes comparison governance only and runs no external fit.

* Clarified the GPCM estimator-family contract. "Bounded GPCM" now explicitly
  means bounded public model/workflow scope, not finite parameter boxes. New
  fits record whether the route is unpenalized identified JML or MML, that no
  statistical penalty or finite box defines the current GPCM estimator, and
  how extreme Persons are represented. `summary(fit)`, `print(fit)`, and
  draw-free plot payloads expose the same fields. The documentation now
  separates Muraki's MML-EM, Wijayanto et al.'s penalized JML, finite-box JML,
  and mfrmr's post-fit recession audit; numerical overflow safeguards are not
  described as regularization.

* Unified the basic fitted-object scale contract. `print(fit)` now exposes the
  coordinate and discrimination bases (and population SD when applicable),
  while every draw-free `plot(fit, ...)` payload carries the same structured
  `scale_contract` used by the fit summary. Corrected the GPCM vignette's stale
  fixed-standard-normal default and added a source-bounded sirt comparison
  lane: item-only GPCM and equal-discrimination reductions are candidate
  matches, whereas sirt's general item-by-rater slope kernel remains a
  different-model sensitivity comparison.

* Corrected bounded-GPCM MML scale identification. When no population formula
  is supplied, the new default `gpcm_mml_identification = "free_population"`
  activates an intercept-only `N(beta0, sigma2)` population model while
  retaining geometric-mean-one relative slopes. Population SD now carries the
  common-discrimination degree of freedom, and fixed-latent-SD optimizer
  slopes are exposed alongside the relative-slope trace. The former
  fixed-standard-normal plus geometric-mean-one likelihood remains available
  as the explicit `"fixed_standard_normal"` compatibility mode. JML is
  unchanged. Automatic and explicit `~ 1` fits are contract-tested as the same
  likelihood, and replay scripts record the identification convention. Frozen
  v3/v4 score-calibration artifacts remain bound to their earlier
  fixed-standard-normal package payload and are not replayed as evidence for
  the new free-population default.

* Established the exact narrow overlap between ConQuest 5.47.5
  `scoresfree` GPCM and mfrmr's bounded item-owned GPCM under active latent
  regression. A deterministic coordinate/probability contract and one native
  31-node microcase verify the latent-scale, Tau, item, step, regression, and
  objective map. Default unconditional MML, standard multifacet
  generalized-item scores, JML free-score estimation, and multidimensional
  GPCM remain different or unsupported strata. The external row moves to
  deferred review only; no tolerance, candidate, many-facet equivalence, or
  release claim is promoted.

* Added the initial deterministic metric-specific eligibility contract for
  external comparisons. Exact program/family/estimator/correction and data,
  facet, category, anchor, coordinate, identification, conditioning, and
  boundary identities are checked per metric and parameter stratum; rejected,
  missing, failed, and unexpected rows cannot enter aggregates. The current
  contract additionally separates penalty, finite-box, and source-precision
  identities and covers ConQuest, FACETS, TAM, immer, and sirt. This moves the
  structural checklist slice to review only: real program normalizers are not
  yet bound and no equivalence claim is promoted.

* Routed the next external-normalizer work through ConQuest rather than
  FACETS because no licensed FACETS executable is available in the current
  environment. FACETS 4.5.0 results remain historical pilot evidence; tool
  identity and candidate-linked WP7 execution require a portable bundle from
  a licensed external environment and cannot be closed by mocks.

* Split four internal G-theory execution/exact-resume validations from
  their fast contract, hash, mutation, and fail-closed checks. Ordinary tests
  retain the structural checks and report explicit skips for the execution
  layer; `MFRMR_RUN_GTHEORY_SLOW=true` restores the complete isolated runs.
  This changes test scheduling only, not the archived model or evidence.

* Made the existing 106-row claim-disposition profile a machine-checked part
  of the central release review. Recorded hashes, item order,
  53/32/21 class counts, class contracts, and all nine conditional fallbacks
  now fail closed. The review separately reports current open mandatory rows,
  active claim fallbacks, and deferred rows; it does not mistake a valid
  profile for release readiness.

* Closed the deterministic repository-content slice of the external privacy
  and licensing boundary. A tracked-file audit recomputes identities for
  ConQuest, FACETS, TAM, and immer source/contract/test/aggregate artifacts and
  rejects proprietary binaries, keys, identifier-bearing case formats, real
  local paths, and escaping symlinks without printing matched values. Ignored
  external result directories still require a separate candidate review.

* Completed the sealed four-arm ConQuest 5.47.5 additive RSM/PCM q31/q61
  calibration outside the filesystem sandbox. Exact native A-matrix checks
  establish the 7/9-dimensional sum-zero bases, and q31/q61 final coordinates
  agree at retained CSV digits. The review corrected implicit-facet command
  grammar, native GIN ordering, and a validation exporter that had omitted PCM
  step estimates. Raw CSV rounding, a prespecified tolerance, and candidate
  identity remain unresolved, so no scientific-equivalence claim is made.

* Adjudicated the opened ConQuest calibration without selecting a self-passing
  tolerance. Representation, optimizer termination, integration stability,
  scientific acceptance, and candidate binding are now separate gates. The
  internal history/export check is named `handoff_tolerance`; its old
  `export_tolerance` name is a deprecated alias and is explicitly neither CSV
  resolution nor `EXT-CQ-TOL`. The broad external claim remains in the future
  portfolio. Calibration may inform a prospective error budget for a disjoint
  candidate, but cannot pass itself under a newly chosen rule; the current
  result stays descriptive and no candidate,
  sparse extension, or large simulation is authorized.

* Kept `MML` and `JML` as the two canonical estimator labels while retaining
  `JMLE` only as a backward-compatible input alias. Legacy objects that still
  contain `JMLE` in retained method fields now emit `JML` consistently from
  summary, print, manifest, and replay surfaces; no likelihood or estimate is
  changed.

* Froze the bounded GPCM score-rule v3 calibration for a future disjoint
  confirmation, without freezing a general score tolerance. Freeze review
  found that the first corrected replay identity omitted the numerical helper
  supplying coordinate and Jacobian calculations. Source-bound v2,
  attribution, and v3 reruns now include that helper hash, reproduce the same
  numerical tables and decisions, and pass a no-fit seal over nine validation
  sources, the complete package payload, three artifacts, and all evidence
  denominators. Confirmation execution, boundary claims, and inference
  promotion remain unauthorized.

* Sealed a no-fit disjoint GPCM score-confirmation design without opening any
  result. Three deterministic structures spanning four to six categories,
  complete, cyclic-sparse, and workload-imbalanced assignments are crossed
  with Criterion- and Rater-owned slopes. Their fixture hashes and complete
  six-scenario/96-evidence/560-coordinate/24-point/376-Jacobian denominators
  are fixed. Execution remains NO-GO pending a record-consuming runner and a
  separate fresh-process/output-absence authorization contract.

* Added the corresponding dry-run-by-default confirmation runner and separate
  eleven-gate authorization decision. Exact source/payload/freeze/design/
  manifest identities, class-specific coordinate counts, point-specific
  Jacobian counts, stale records, missing authorization, and occupied targets
  are checked fail-closed. Synthetic issuance is tested without fitting; the
  actual default remains `no_go_not_issued` and no confirmation result exists.

* Consumed the sealed GPCM score v3 confirmation exactly once and retained its
  complete negative result. All score/oracle/finite-difference-applicable and
  Jacobian components passed, but a constructed six-level boundary value was
  represented as `3.0000000000000009` and failed the frozen raw `<= 3`
  classifier. No retry or tolerance adjustment was made. The saved artifact
  also omitted the consumed in-memory authorization row, so it could not have
  supported acceptance even if numerically positive. V4 must be specified
  prospectively with error-analysis-based boundary handling and embedded
  authorization provenance; no large simulation is authorized.

* Specified a no-execution v4 score contract without relaxing the four v3
  numerical comparison rules. Contract-constructed inclusive-boundary points
  receive a binary64 forward-error bound derived from input rounding,
  `gamma_n` summation error, and comparison error; retained solutions receive
  zero allowance. Future saved results must embed the exact consumed
  authorization row. Opened v3 fixtures are calibration-only, and v4 review,
  freeze, and new disjoint confirmation remain pending.

* Applied v4 retrospectively without fitting to the immutable rejected v3
  bundle. Exactly one intended six-level boundary changed to the finite region,
  while every retained extreme was unchanged. The result remains incomplete:
  v3 saved no finite difference for that formerly extreme point and omitted the
  consumed authorization row. V4 is not frozen. A new sealed calibration-only
  boundary fixture must fill the gap; refitting v3 cells and large simulation
  remain prohibited.

* Sealed a no-fit calibration-only boundary-completion fixture for v4. One
  Criterion-owned six-level scenario fixes four evidence rows, 24 coordinates,
  one point, and 30 Jacobian rows with complete owner-category support. It is
  permanently ineligible for confirmation.

* Added its dry-run runner and separate target-bound authorization boundary
  without fitting. Exact source, payload, design, rule, manifest, denominator,
  same-process, output-path, authorization-source, issued-row, consumed-row,
  and target-absence checks fail closed. The runner must embed the exact
  consumed authorization row and calculate the one missing five-point finite
  difference. Forty-four no-fit expectations pass. Before execution, the
  default remained `no_go_not_issued` and the single allowed action was a
  fresh-process issue-and-consume operation.

* Consumed that authorization once without retry and independently validated
  the saved calibration-only result. All 4/24/1/30 rows and all analytic-score,
  five-point finite-difference, log-Jacobian, and slope-Jacobian rules pass;
  their maximum combined ratios are 5.05e-05, 6.33e-04, 0.203, and 0.282.
  Issued- and consumed-row hashes reproduce, while the repository-relative
  target is explicitly recorded as not absolute and resolves to the hashed
  artifact. The fit remains `review`; v4 is freeze-review-ready but not frozen,
  and general tolerance, confirmation, inference, and release promotion remain
  unauthorized.

* Froze the bounded v4 score rule and calibration interpretation with a no-fit
  six-source/two-artifact seal. The seal preserves the unchanged four numerical
  rules, constructed-only binary64 allowance, zero retained-solution allowance,
  unique retrospective reclassification, completion evidence, authorization
  hashes, repository-relative target disclosure, and review-only fit boundary.
  A new disjoint confirmation design may now be specified, but execution,
  general tolerance, boundary, inference, and release promotion remain false.

* Sealed a no-fit structurally disjoint v4 confirmation design. Three new
  deterministic sparse/imbalanced structures, 5/6/7 categories, and both slope
  owners create six scenarios with fixed 96/888/24/688 denominators. Prior
  Person, Rater, Criterion, and fixture-hash overlaps are zero. Future execution
  must record an absolute target.

* Added the v4 confirmation dry-run runner and separate same-process
  authorization contract without fitting. They bind the exact runner identity,
  six-scenario manifest, package payload, design/freeze/rule chain, fixture
  hashes, and 96/888/24/688 denominators. Relative or occupied targets,
  missing/stale/tampered authorization, and incomplete evidence fail closed.
  A runner-independent validator was sealed before execution and its hash is
  an authorization gate. Seventy-four no-fit expectations pass; the default
  remains `no_go_not_issued`, and no confirmation result has been opened.

* Consumed the v4 confirmation exactly once and retained its negative result.
  The complete 96/888/24/688 denominator and every frozen score/Jacobian ratio
  pass, but two Criterion-owned fits reached the iteration limit and are
  `blocked`. The runner omitted fit readiness from its final aggregation and
  reported a false-positive candidate pass. The prospectively sealed validator
  also has a names-attribute false negative; an immutable no-fit retrospective
  audit distinguishes that defect from the independently failed fit gate and
  records `ConfirmationAccepted = FALSE`. No retry, rule adjustment, general
  tolerance, boundary, inference, or promotion is authorized.

* Fit summaries now keep observed boundary-constant facet support separate
  from certified JML additive facet recession directions. Diagnostic objects
  also retain the source fit readiness record, so a blocked or review-only fit
  cannot appear inference-ready merely because diagnostic calculations return.

* Closed a deterministic retained-core slice of readiness propagation without
  closing the full release gate. Manifests and replay objects now preserve the
  exact fit/component/parameter readiness provenance; exported bundles write
  those records as CSV files. Replay scripts recompute readiness after fitting
  and warn on source/replay disagreement instead of copying source status.
  Manifest `Converged` now means optimizer-code convergence, while
  `InferenceReady` remains the stricter v3 contract decision. RSM/PCM JML/MML,
  iteration-limit, and legacy-unknown checks pass. A real PCM/JML fit generated
  from the frozen CRAN 0.2.2 tarball remains `legacy_unknown` under 0.2.3, and
  a fresh-session development replay obtains a separate new v3 decision while
  warning on source/replay mismatch. Broader parameter/interaction coverage,
  lower-priority adapters, and candidate-bound replay remain open.

* Closed the structural exact-model-reduction gate for the binary RSM/PCM and
  unit-slope GPCM/PCM special cases. The fixed audit now checks observed log
  probabilities, full category probabilities, marginal objectives, common
  scores, and free/expanded transformations against both model routes and a
  separately implemented likelihood/marginalization oracle; broader numerical
  stationarity tolerances and candidate confirmation remain open.

* Added an internal `maxit` attempt-registry validator. It rejects
  skipped or unregistered ceilings, specification changes, iteration-limited
  or review-only selections, multiple selections, and choosing a later ready
  run when an earlier run was already eligible. Individual fits continue to
  fail closed through v3 readiness; the release row remains under review until
  the same rule is applied to the exact candidate.

* Completed the deterministic 0.2.3 conditional-fallback coverage audit.
  Fit-specific GPCM boundary tables and fit summaries now expose exact
  slope/step ownership and explicitly distinguish model-conditional
  discrimination from rater consistency. Residual-PCA result, summary, and
  plot payloads now carry machine-readable exploratory, non-primary, and
  no-automatic-dimensionality-decision fields. The JML fallback description
  now accurately retains explicitly exploratory observation-table SEs while
  continuing to prohibit profile-likelihood, finite-item-correction, or
  corrected-JML claims. No conditional claim was promoted and no simulation
  or external engine was run.

* Completed the response-free Draft.83d2b2b1g24 fresh-site issuance boundary.
  Six recomputed gates now bind the exact b1g23 entry contract and R0201
  prospective manifest to fresh isolated-runtime/site receipts, one-shard
  scope, complete denominators, no early stopping, and confirmation isolation.
  One observed GO produces a hash-valid production record and unexecuted
  active R0201 manifest; a forced occupied-target condition produces a
  separately hash-valid NO-GO from which issuance is refused. Fifty-one
  assertions pass. No response, fit, checkpoint, reserved root, or lock was
  created. Exactly R0201 may be opened by a fresh record-consuming runner, but
  `LargeSimulationMayStart=FALSE` and no later shard is authorized.

* Implemented the response-free Draft.83d2b2b1g23 record-bound reserved entry
  point and exact R0201 active-manifest conversion. Exact AST/source audits
  retain the b1g17 generator, b1g18 preparation, and b1g13 complete-checkpoint
  bodies while replacing their three nonreserved admission guards with one
  issued-record/manifest/capability boundary. A four-unit replicate-902
  reduction exactly matches b1g21 over 36 fits, 192 decisions, and eight
  references, then reuses all checkpoints. Four tests with 75 assertions pass.
  No production issuer exists, R0201 remains prospective, no reserved root was
  created, and fresh site receipt plus separate six-gate issuance still block
  replicate 201 and large simulation.

* Completed the response-free Draft.83d2b2b1g22 execution-authorization
  decision. The exact b1g21 source closes a nonreserved scientific reduction,
  but its preparation guard rejects reserved replicates and the inherited
  b1g13 loop is explicitly nonreserved-only. Five decision gates pass and
  `RESERVED-ENTRY-01`, `ACTIVE-MANIFEST-01`, and `SITE-RECEIPT-01` block.
  The honest result is `no_go_refused_not_issued`: no authorization record,
  response, fit, or reserved root was created, large simulation remains
  prohibited, and replicate 201 stays sealed. The next bounded task is a
  response-free record-bound reserved entry point and exact one-shard active
  manifest, not simulation expansion.

* Completed the Draft.83d2b2b1g21 guarded single-shard runner reduction.
  The real b1g18 glmmTMB/lme4 x ML/REML evaluator path now runs in the b1g20
  isolated vanilla child under an exclusive lock and typed activation root.
  Replicate 902 reproduces all 36 candidate fits, 192 decisions, eight
  references, 35 returned fits, and one retained typed failure; a second child
  reuses all four checkpoints and reproduces the scientific execution hash.
  Reserved 201 and confirmation 501 fail before generation, so `RUNNER-01`
  closes but `AUTH-RECORD-01` remains: no reserved response is authorized,
  large simulation remains prohibited, and replicate 201 stays sealed.

* Consolidated the remaining shared preactivation infrastructure into the
  Draft.83d2b2b1g20 response-free authorization kernel. An isolated
  `Rscript --vanilla` child now binds RNG, locale/timezone, startup, BLAS/LAPACK,
  package, glmmTMB, and serial thread state. Atomic exclusive-lock,
  initial/resume marker, unmarked-root rejection, fresh filesystem, and
  capacity mechanics pass without creating the reserved root. Nine common
  gates pass; only the real reserved runner and a separate immutable
  authorization record remain. No further infrastructure-only layer is
  planned, and large simulation remains prohibited.

* Completed the Draft.83d2b2b1g19 response-free hardened reserved-lineage
  rebase. The exact b1g14 workload and 100-shard partition are preserved, but
  all 12,000 atomic-unit and all 100 shard hashes are rederived against the
  b1g17 generator and b1g18 adapters; historical hashes remain provenance-only
  and have empty intersection with the active registry. All prospective shard
  manifests remain non-executable, confirmation replicates are excluded, and
  no output root or response was created. The reserved adapter entry point,
  extended runtime, and locked runner are still absent, so
  `AuthorizationRNG01Closed=FALSE`, large simulation remains prohibited, and
  replicate 201 remains sealed.

* Completed the Draft.83d2b2b1g18 nonreserved hardened production-adapter
  rebase without altering historical b1g14 evidence. The old and hardened
  paths execute the same replicate-902 dataset through glmmTMB/lme4 x ML/REML.
  All 36 candidate rows, 192 decisions, eight reference states, 35 returned
  fits, and the one retained `start_snapshot` failure have exact semantic
  parity after excluding identity fields that must change. Hardened candidate
  and reference paths independently agree on generator and pre-fit identity;
  all four checkpoints reuse exactly. The prospective reserved manifest is
  still deferred, so `AuthorizationRNG01Closed=FALSE`, large simulation is
  prohibited, and replicate 201 remains sealed.

* Completed the Draft.83d2b2b1g17 nonreserved RNG-hardened generator replay.
  The historical b1g2a generator remains untouched; a separately versioned
  wrapper explicitly fixes and records uniform, normal, and sample RNG kinds,
  preserves the historical parent identity, and restores caller RNG state.
  All 30 scenarios at replicate 901 reproduce identical hardened generator,
  parent, and analysis-data hashes under Mersenne-Twister and Wichmann-Hill
  caller states. Reserved replicates are rejected. This closes only the
  prospective generator component: current production adapters still bind the
  old identity, so `AuthorizationRNG01Closed=FALSE`,
  `LargeSimulationMayStart=FALSE`, and replicate 201 remains sealed.

* Completed the Draft.83d2b2b1g16 response-free pre-activation hardening
  audit and stopped before large calibration. The actual 9,756 phase-specific
  scenario-replicate seed rows are collision-free, but a nonreserved same-seed
  negative control proves that the current generator depends on ambient
  `RNGkind()`. The upstream runtime identity also omits RNG, BLAS/LAPACK,
  locale/timezone, glmmTMB parallel state, and numerical-library thread state;
  no isolated vanilla process, authorized reserved runner, exclusive writer
  lock, activation marker, typed resume-root lifecycle, or per-shard capacity
  recheck exists. Eight required gates therefore block activation.
  `LargeSimulationMayStart=FALSE`, replicate 201 remains sealed, and the next
  work is deterministic/runtime/runner hardening followed by downstream
  nonreserved re-freezing—not simulation.

* Completed the Draft.83d2b2b1g15a response-free Monte Carlo value audit.
  The apparently large calibration consists of 3,000 independent datasets,
  not 108,000 independent candidate fits or 576,000 independent decisions;
  the primary planned denominator is only 100 per scenario x method x model-
  role cell. Under a complete resolved denominator, 0/100 has a one-sided 95%
  upper bound of 0.029513 and a true 3% safety-event rate is observed at least
  once with probability 0.952447. This justifies the design for numerical-rule
  calibration only. Broad bias/RMSE/coverage, D-study operating characteristics,
  achieved precision, universal sample-size, authorization, and inference
  claims remain false or unavailable.

* Completed the Draft.83d2b2b1g15 response-free one-way authorization
  preflight without issuing an execution authorization or opening calibration
  replicate 201. One hundred non-executable prospective shard manifests
  exactly partition 3,000 datasets, 12,000 atomic units, 108,000 candidate
  fits, 576,000 decisions, and 24,000 references. An actual write,
  same-directory checked rename, readback, cleanup, target-absence, and
  site-capacity probe passes in the frozen output parent. Conservative 32x
  storage plus 32-GiB residual and 4x serial-time planning passes with one
  concurrent shard. Authorization readiness is true, while authorization
  record issuance, calibration execution/data/results, threshold selection,
  confirmation, inference, and D-study decisions remain false or unauthorized.

* Completed the Draft.83d2b2b1g14 response-free production-adapter and
  reserved-manifest preflight. Real lme4/glmmTMB x ML/REML candidate and
  high-accuracy-reference adapters share generator and pre-fit identities,
  preserve objective-only profile selection, and complete a four-unit
  nonreserved dry-run with all 36 fits, 192 decisions, and eight references
  retained; one typed `start_snapshot` failure remains in the denominator.
  The runtime- and dependency-identified reserved manifest fixes 100 shards
  and the exact 3,000-dataset workload but remains non-executable. Calibration
  authorization, replicate 201, threshold selection, confirmation, inference,
  and D-study decisions remain false or unauthorized.

* Completed the Draft.83d2b2b1g13 exact-resume stationarity-runner mechanics
  without opening calibration replicate 201. Content-addressed atomic
  dataset-method checkpoints retain all optimizer fits, all 24 candidate
  decisions per model role, both high-accuracy references, and every failed
  row. Interrupted, cold, and complete-reuse fixture runs have the same
  scientific execution hash, while partial runs are explicitly non-evidence.
  Production evaluator adapters, the reserved run manifest, calibration,
  threshold selection, confirmation, inference, and D-study decisions remain
  false or unauthorized.

* Completed the Draft.83d2b2b1g12 coordinate-correct production boundary
  probe without opening calibration replicate 201. lme4 finite theta zero and
  glmmTMB log-SD boundary limits retain separate paths and acquire a common
  interpretation only after a nuisance-reoptimized profile matches the
  separately fitted reduced objective. Flat, nonmonotone, mismatched, and
  failed profiles remain inconclusive or non-evaluable; first-order zero is
  never sufficient. Analytic controls and lme4/glmmTMB x ML/REML fixtures pass.
  The exact-resume runner, calibration, threshold selection, confirmation,
  inference, and D-study decisions remain false or unauthorized.

* Added an internal non-unit GPCM score oracle that independently
  reconstructs the positive-slope transformation, GPCM response kernel,
  Person-wise fixed-quadrature marginal objective, and numeric free-coordinate
  score. Four retained/high-dispersion/finite-stress points and 47 fail-closed
  expectations pass, including slopes about 0.05--20.1. This is calibration
  evidence only: the general score tolerance, owner/category/topology grid,
  confirmation, boundary, selection, and public-capability decisions remain
  open or unauthorized.

* Froze a no-execution bounded follow-up design for that oracle. Eight
  five-category cells cross Criterion/Rater slope-step ownership with core,
  one-Person weak bridge, workload imbalance, and category imbalance using
  paired deterministic 40-Person/four-Rater/four-Criterion fixtures. Four
  parameter points and four coordinate classes create 128 mandatory evidence
  strata under a five-point derivative ladder, hard absolute/scaled guards,
  an adaptive numerical-error allowance, and slope-Jacobian caps. Sixty-three
  focused expectations pass. Calibration execution, final `NUM-SCORE-TOL`,
  confirmation, and release promotion remain unauthorized or unresolved.

* Executed that bounded design once and retained its negative result. All 128
  evidence strata and 32 structural-oracle point checks were complete, but
  extreme retained slopes around 2.5e5--3.3e6 caused objective finite
  differences to lose local resolution, and the conjunctive absolute/scaled
  rule rejected 33/672 coordinates plus three Jacobian point rows. A separate
  48-stratum Person-posterior sufficient-statistic score reconstruction agreed
  with the package to at most 1.05e-9 while leaving the v2 calibration
  `rejected`. The next rule must separate finite-slope stationarity from
  non-promoting extreme-slope boundary handoff; no general tolerance,
  confirmation, readiness, or release claim is promoted.

* Added a no-execution GPCM score-rule v3 contract before retrospective
  re-adjudication. It fixes `max(abs(z)) <= 3` as the inclusive finite-slope
  validation envelope, requires independent analytic-score and transformation
  agreement everywhere, uses one combined absolute-plus-relative/numerical-
  error finite-difference allowance only inside that envelope, and sends
  outside points to a non-promoting review handoff. Forty-three focused
  expectations pass. V2 remains rejected; no boundary is proved, and no
  general `NUM-SCORE-TOL` or confirmation is frozen.

* Audited whether the immutable v2 artifacts alone can support exact v3
  adjudication. All 128 structural/finite-difference strata are retained, but
  independent analytic scores cover only 48/128 strata and the 32 Jacobian
  point checks retain separate maxima rather than entrywise combined-rule
  ratios. Aggregation was not reverse-engineered into acceptance evidence;
  one identity-bound replay of the same eight deterministic cells was used
  instead, as calibration rather than a recovery simulation or confirmation.

* Fixed a GPCM reproducibility defect found by that replay before accepting
  its first nominal pass. Log-sum-exp stabilization used `max.col()` with R's
  random approximate-tie default, so identical weak-bridge fits could change
  optimizer path and retained vector. All likelihood and prediction routes
  now use deterministic first-maximum ties, and optimizer cache keys retain
  owned parameter snapshots. Repeated weak-cell fits are RNG-neutral and
  bitwise numerically identical. The pre-fix replay is explicitly invalidated.
  Under the corrected payload, unchanged v2 again rejected the same 33/672
  coordinates and three/32 Jacobian points. The corrected v3 replay completed
  128 evidence strata and 384 entrywise Jacobian rows and passed all v3
  components, with maximum combined ratios 0.172, 0.00175, 0.172, and 0.268
  for analytic score, finite difference, log Jacobian, and slope Jacobian.
  Three retained points remain non-promoting extreme-slope handoffs; every fit
  remains review-only and inference-unready. General tolerance, boundary,
  confirmation, and release claims remain open.

* Froze the Draft.83d2b2b1g11 truth-blind numerical-stationarity acceptance
  policy without opening calibration replicate 201. The policy binds all four
  nonreserved reference receipts, crosses three primary score families with
  eight prespecified indeterminate zones, retains scenario x method x model-
  role denominators, and separates false ready, false boundary handoff, false
  unready, missed boundary, abstention, non-evaluation, and unresolved
  reference states. Zero observed safety errors remain subject to one-sided
  exact-binomial upper bounds and no post-selection coverage claim. The
  production boundary probe, exact-resume runner, threshold selection,
  calibration, confirmation, inference, and D-study decisions remain false or
  unauthorized.

* Completed the Draft.83d2b2b1g10 nonreserved lme4 ML/REML high-accuracy
  reference replay. A three-algorithm box-constrained ladder, independent
  sparse Gaussian objective/gradient oracle, analytic-gradient Newton polish,
  raw KKT, free-curvature, and seven-point nuisance-reoptimized theta profiles
  pass for all eight objectives on replicates 901--902; a complete repeat is
  exact. The four prespecified lme4/glmmTMB x ML/REML reference lanes are now
  complete, but acceptance/indeterminate policy, production boundary probe,
  exact-resume calibration runner, reserved calibration, inference, and
  D-study decisions remain unauthorized.

* Completed the Draft.83d2b2b1g9 lme4 objective-reference preflight without
  opening any nonreserved or reserved response. An independently coded dense
  Gaussian oracle reproduces lme4's theta-only profiled ML deviance and REML
  criterion, their analytic gradients, fit accessors, and exact-zero full-to-
  reduced identity. Source-hashed negative controls exclude `devfun2()` and
  `deviance(..., REML=TRUE)` from REML reference work in installed lme4 2.0.6.
  This freezes objective identity only: the lme4 box solver, boundary profile,
  nonreserved replay, complete method coverage, calibration, inference, and
  D-study decisions remain unauthorized.

* Completed the Draft.83d2b2b1g8 nonreserved glmmTMB ML high-accuracy
  reference replay. The b1g6 mechanics are reused by exact function hash on a
  separately identified `REML=FALSE` objective. All four full/reduced ML
  objectives from replicates 901--902 pass solver consensus, AD-independent
  derivative, positive-curvature, six-point nuisance-stationary boundary-
  profile, and sidecar-integrity gates; a complete second replay reproduces
  every row and hash. glmmTMB ML and REML reference mechanics are now ready,
  but lme4 ML/REML, production stationarity, reserved calibration,
  confirmation, inference, and D-study decisions remain unauthorized.

* Completed the Draft.83d2b2b1g7 fail-closed stationarity-calibration
  preauthorization audit without opening reserved data. The audit corrects
  the prospective b1g5 candidate-fit upper bound from 144,000 to 108,000 by
  retaining six glmmTMB profiles but only three lme4 profiles, while keeping
  3,000 datasets and 24,000 high-accuracy reference problems unchanged. It
  freezes truth-blind candidate-state precedence and per-role minimum-finite-
  objective profile aggregation. Only glmmTMB REML has passed the nonreserved
  reference replay, so method coverage, the acceptance policy, the runner,
  reserved calibration 201--300, inference, and D-study decisions remain
  unauthorized.

* Completed the Draft.83d2b2b1g6 high-accuracy stationarity-reference gate on
  analytic objectives and nonreserved replicates 901--902. The derivative
  audit now selects a central-difference interval from adjacent-step stability
  without consulting the AD gradient, retains a componentwise numerical-
  resolution envelope, and resets TMB random-effect starts before every
  evaluation. Six analytic states and all four full/reduced glmmTMB REML
  objectives pass solver consensus, derivative, curvature, nuisance-
  stationary boundary-profile, and sidecar checks. This freezes only the
  reference mechanics; no production stationarity rule, reserved calibration,
  full stabilization, bootstrap, inference, or D-study decision is authorized.

* Added the sealed Draft.83d2b2b1g5 stationarity-calibration design. Numerical
  finite stationarity, curvature/factorability, log-SD boundary limits, and
  statistical variance-component resolution now have noninterchangeable state
  spaces and ordered gates. Analytic affine fixtures confirm Hessian-inertia
  and Newton-decrement invariance while retaining raw, lme4-compatible, and
  Newton-step coordinate dependence. The existing calibration reservation
  remains sealed; its original workload identity contains 3,000 independent
  datasets, 144,000 candidate fits, and 24,000 high-accuracy reference
  problems. The later b1g7 backend-specific audit corrects the prospective
  candidate-fit upper bound to 108,000 without rewriting that identity. No
  reference tolerance, stationarity rule, optimizer, calibration execution,
  bootstrap, inference, or D-study decision is authorized.

* Added prospective scale-aware stationarity instrumentation for the exact
  120-pair glmmTMB alignment smoke. All 240 fits retain content-addressed raw
  parameter, outer-gradient, `sdreport`-gradient, Richardson-Jacobian, and
  derived-vector sidecars; b1g2 parameters, objectives, likelihoods, and
  nested drops reproduce without mismatch, and no-fit resume reproduces the
  scientific hash. Spectral Hessian positivity is observed in 224 fits, but
  numerical Cholesky factors are available in only 221, so those states are
  now explicit rather than collapsed. Raw, objective/parameter-relative,
  lme4-compatible, Newton-decrement, and relative-Newton-step summaries stay
  distinct. Cross-profile metric minima disagree with the best observed
  objective often enough to prohibit optimizer selection. No observed value
  defines a stationarity cutoff; full execution, calibration, inference, and
  D-study decisions remain unauthorized.

* Added a no-refit, multi-axis numerical adjudicator for the exact glmmTMB
  alignment smoke. All 120 pairs have finite raw objectives, while 14
  pairwise reported likelihoods are unavailable solely because the installed
  glmmTMB method masks `logLik()` when `pdHess` is false. The new ledger keeps
  optimizer termination, objective finiteness, reported likelihood, two
  gradient surfaces, sdreport/Richardson curvature, and nested trace ordering
  independent. It also records six-profile best-observed envelopes without
  claiming global maxima. One nonzero optimizer code and two gradient-surface
  mismatches are no longer hidden by primary-state precedence. No
  stationarity threshold, optimizer, full execution, inference, or D-study
  rule is selected.

* Added a prospective, tolerance-free correction for glmmTMB start-state
  transport and replayed the same 120-pair stabilization smoke under a new
  identity. Every returned fit now replaces only the fixed positions of the
  immediate joint state with `fit$fit$par` before `parList`; raw and aligned
  states are separately hashed. All 240 fits return and align exactly, all 80
  dependent transfers verify, all checkpoints resume without fitting, and the
  four b1g1 fit/dependency rows are recovered without losses. Common returned
  objectives, likelihoods, and top-level parameter hashes are unchanged. The
  result still contains 14 non-finite and 21 finite material-negative rows,
  so full execution, numerical stabilization, calibration, thresholds,
  inference, and D-study decisions remain false.

* Implemented and executed a guarded glmmTMB stabilization covering smoke on
  10 viewed datasets: 20 atomic base routes, 120 profile pairs, and up to 240
  backend fits. All checkpoints and dataset markers validate; a no-fit resume
  reuses all 20 base routes and reproduces the execution hash. Of 120 rows, 84
  are diagnostic-complete, 21 retain finite material-negative differences, 11
  have non-finite objective/likelihood state, and four retain typed fit or
  parent failures. Two BFGS fits expose non-bitwise equality between
  `last.par.best` fixed coordinates and `fit$fit$par`; this blocks the strict
  start snapshot and therefore the full 18,000-fit authorization. Runner
  mechanics are ready, but numerical stabilization, calibration, thresholds,
  inference, and D-study decisions remain false.

* Froze the next internal glmmTMB stabilization design without
  authorizing its fits. The exact b1e/b1f ledgers yield 1,500 viewed base
  routes and a symmetric six-profile DAG: cold nlminb/BFGS, same-algorithm
  restart, and cross-algorithm warm start. Its 9,000-pair/18,000-fit manifest
  retains all ten named start blocks, an immediate `last.par.best` snapshot,
  exact parent lineage, outer and sdreport
  gradients, Richardson Hessian diagnostics, and typed parent failures. Five
  tests and 73 expectations pass. `ManifestReady` is true, while runner,
  execution, numerical stabilization, calibration, thresholds, inference,
  and D-study decisions remain false or unauthorized.

* Completed a typed, no-refit adjudication of the frozen G-theory b1d/b1e
  ledgers. All 2,993 finite default replays match within 1e-10; the remaining
  seven are `NA_real_` on both sides with identical likelihood-unavailable
  diagnostic states. Thus `TypedReplayAdjudicationReady` is true under the new
  b1f contract, while the immutable b1e finite-only `DefaultReplayPassed` and
  `NumericalSensitivityEvidenceReady` remain false. No missing value is
  treated as a zero difference or promoted to likelihood availability. The
  next gate must prospectively bind glmmTMB start blocks, cold/current-optimum
  restarts, gradients, Hessians, and alternative algorithms before calibration
  data are generated.

* Executed a frozen internal numerical-likelihood sensitivity on the
  already viewed G-theory feasibility data: three profiles per original route
  produce 9,000 full/reduced pairs and 18,000 fits with exact checkpoint
  resume. Tightening the same algorithms changes no objective. lme4 bobyqa
  removes all 34 finite default-lme4 material-negative differences, whereas
  glmmTMB BFGS yields 331 non-finite and 401 material-negative differences.
  Seven default replays are non-finite in both the old and new ledgers, but the
  frozen finite-absolute-difference replay rule did not define that state, so
  `NumericalSensitivityEvidenceReady` remains false. This audit also corrects
  the legacy feasibility count from 133 false tolerance flags to 126 finite
  material-negative plus seven non-finite rows. Calibration, thresholds,
  inference, and D-study decisions remain unauthorized.

* Executed the frozen internal G-theory weak-information feasibility
  band: 3,000 full/reduced method pairs over 750 untouched replicate-101--125
  datasets now have atomic route checkpoints and dataset markers. All pairs
  return, but only 2,804 common scores are available; 79 optimizer/likelihood-
  identity failures and 126 finite materially negative likelihood differences
  overlap in nine rows, while seven non-finite differences belong to the
  failure set. High-information availability is only 76.2%, while the
  few-level design has weak score ordering and 283/600 nuisance-boundary rows.
  A no-refit resume reuses all 3,000 checkpoints and reproduces the scientific
  hash. Descriptive feasibility accounting is ready, but no threshold,
  operating-characteristic calibration, inference, or D-study decision is.

* Froze a replacement 3,000-row G-theory weak-information resolution-
  feasibility manifest without generating any reserved replicate-101--125
  data. A 240-fit runtime schema over all already viewed design x variance x
  method cells returns all 120 full/reduced pairs, but only 111 common scores
  are available: six materially negative nested likelihood differences and
  four optimizer/likelihood failures overlap in one row, leaving nine explicit
  unavailable routes. Timing-excluded execution and authorization hashes
  reproduce. Local serial projection is about 33 minutes centrally and 2.2
  hours at x4 sensitivity, but is planning telemetry only. Exact checkpoint
  accounting now authorizes the descriptive 6,000-fit run; thresholds, inner
  bootstrap, calibration, inference, and D-study decisions remain blocked.

* Implemented the internal exact-observed-design parametric-bootstrap
  mechanics schema for the G-theory weak-information lane. Three already
  viewed baseline controls x four lme4/glmmTMB ML/REML routes x `B=3` produce
  12 observed and 36 bootstrap pairs, or 96 full/reduced fits. All pairs
  return, all generated responses retain exact design identity and distinct
  hashes, 16 small negative likelihood differences remain untruncated, and
  eight bootstrap pairs expose a non-target nuisance boundary. Failure-aware
  plus-one bounds retain every planned draw, but the 0.25 Monte Carlo grid is
  mechanics-only. No finite-sample exactness, size, power, threshold,
  production `B`, inference, coefficient, or D-study decision claim is added.

* Added a source-audited G-theory weak-information inference contract and
  full/reduced diagnostic schema. The contract withdraws the former common
  `target_relative_se_profiled` candidate because lme4's profiled relative-SD
  and glmmTMB's joint log-SD local scales are not commensurate component
  standard errors. All 24 viewed-schema pairs return and supply raw ML/REML
  likelihood differences; four tiny negative glmmTMB differences are retained
  as numerical results, 20/24 backend-local quadratic diagnostics are
  available, and no p-value or interval is produced. The previously authorized
  3,000-fit feasibility manifest is superseded before any of its seeds are
  generated. A new feasibility identity now requires a custom exact-design
  reduced-model bootstrap contract plus separate positive-control recovery and
  D-study stability checks; inference and confirmation remain blocked.

* Froze the internal replicated G-theory weak-information pilot architecture.
  The independent unit is now one scenario-by-replicate dataset with four
  paired likelihood routes. Separate schema, feasibility, calibration, and
  sealed confirmation seed bands contain 24, 3,000, 12,000, and 24,000 fits,
  with worst-case cell-by-method Bernoulli MCSE targets of 0.354, 0.10, 0.05,
  and 0.035. A 24-fit schema run passes atomic accounting, but contributes no
  pilot evidence. Four-state resolved/indeterminate/not-resolved/not-evaluable
  accounting and four candidate rule architectures are registered without a
  selected threshold. Calibration and confirmation execution remain blocked.

* Added a 120-unit internal G-theory weak-information diagnostic smoke across
  five design/information strata, six Rater-variance regions, and lme4/glmmTMB
  ML/REML. All fits return and atomic accounting passes, but the existing
  whole-model point gate produces 27 false-ready results among 40 zero or
  near-zero target-component routes and three false blocks among 12 narrowly
  registered positive controls. This is evidence that the point gate is not a
  calibrated component-resolution rule. No threshold, sample-size rule,
  recovery, interval, coefficient, estimator preference, or public support
  claim is added; a replicated pilot with frozen Monte Carlo precision remains
  prerequisite.

* Executed all 89 units of the internal G-theory ADEMP point-fit smoke through
  atomic balanced-MoM, lme4 ML/REML, and glmmTMB ML/REML adapters. Twelve
  structurally blocked units never call a backend; all 77 eligible attempts
  return, and every unit is recorded as one success or typed failure. The
  near-zero variance negative control nevertheless passes all four likelihood
  routes, so the zero-false-ready gate fails and recovery promotion remains
  blocked pending a pre-registered observable weak-information calibration.
  No recovery, interval, coefficient, estimator preference, or public support
  claim is added.

* Implemented an exact scalable pre-fit layer for the internal G-theory ADEMP
  smoke. Equality-signature compression now distinguishes covariance-component
  rank from fixed-effect-equivalent rank without materializing dense
  covariance derivatives. Nineteen scenarios and 77 fit units are structurally
  eligible; three scenarios and 12 units are blocked before fitting by
  disconnected or aliased designs. This authorizes no fit, reports no recovery,
  and adds no interval, coefficient, public engine, or checklist claim.

* Implemented the deterministic generation half of the internal G-theory
  ADEMP smoke. Twenty-two executable registry scenarios now produce separately
  hashed complete-potential, assigned, and post-missingness tables; two anchor
  scenarios remain typed semantic blocks. Exact assignment density and
  observations per Person, workload imbalance, bounded-score projection
  truth, MCAR/MAR/MNAR/unknown omissions, residual local dependence, zero and
  near-zero boundaries, and disconnected/aliased controls replay under one
  generator identity. This fits no model, reports no recovery, freezes no
  replication count, and adds no estimator, interval, coefficient, public
  engine, or checklist claim.

* Implemented an internal supplied-matrix multivariate G-theory algebra
  preflight for the future Draft.85 route. Component covariance matrices are
  combined with explicit cross-stratum allocation Gram operators, preserving
  common, partially shared, and independent facet sampling before weighted
  composite G/Phi is formed. Exact one-stratum reduction, two-/three-stratum
  order, PSD/rank state, component contributions, and invalid-matrix/weight
  controls are retained. This estimates no covariance, changes no public API,
  and adds no multivariate inference or support claim.

* Implemented an internal pre-simulation G-theory ADEMP registry and exact-
  denominator contract. Twenty-four covering scenarios now separate Gaussian
  component recovery, missingness sensitivity, bounded observed-score
  projection, local-dependence reference deviation, boundary and
  identification controls, and anchor-rate nonapplicability. Bias/RMSE,
  prediction/rank recovery, interval coverage, coefficient recovery,
  convergence, false-ready rate, and failed-cell accounting have distinct
  eligibility and denominators. This runs no simulation, freezes no pilot or
  confirmation size, and adds no recovery, interval, estimator, coefficient,
  public-engine, or checklist claim.

* Implemented an internal matched Gaussian glmmTMB/lme4 G-theory point-
  estimation comparison. Exact retained-row, formula, family, dispersion,
  covariance, and ML/REML identities are required before component, intercept,
  or full-log-likelihood differences are evaluated. Interior crossed and
  nested fixtures agree under recorded smoke tolerances; a boundary fixture
  with positive-definite glmmTMB Hessian remains nonregular and materially
  disagrees with lme4. No backend preference, recovery claim, public engine,
  interval, coefficient eligibility, or checklist promotion is added.

* Implemented an internal G-theory covariance-design and expected-information
  audit. Component-specific covariance derivatives expose exact variance-
  component aliases; ML and REML information ranks are evaluated separately;
  and `lme4` point fits are bound to the exact retained rows with optimizer,
  singularity, and boundary states kept distinct. A finite optimizer-code-zero
  boundary fit remains nonregular. This adds no public nested/unbalanced
  engine, coefficient eligibility, interval, estimator preference, or
  checklist promotion.

* Implemented an internal component-specific G-theory allocation operator.
  Planned weights transform each typed variance component through the squared
  marginal-weight concentration for its own `ScaleBy` identities. Uniform
  crossed allocations reduce exactly to the earlier balanced divisors;
  ancestry-qualified nested allocations, unequal unit-specific coefficients,
  and shared/disjoint cross-unit condition overlap remain distinct. Weights are
  never normalized silently, heterogeneous unit coefficients are not averaged,
  and equal effective counts with disjoint support cannot form a scenario
  scalar. This fits no model and adds no public nested/unbalanced engine,
  estimation, interval, allocation default, or checklist promotion.

* Implemented an internal pre-fit G-theory observed-design incidence audit.
  It canonicalizes retained and omitted rows, uses conditional identities for
  nested child levels, records global and pairwise connectivity, workload,
  full-cell replication, and component-specific fixed-effect-equivalent rank
  increments, and fails visibly for disconnected islands, metadata conflicts,
  missingness conflicts, and rank-capacity limits. Connectivity and fixed-
  equivalent rank are not treated as variance-component identifiability;
  estimation eligibility remains unadjudicated and all coefficient and
  decision-ready states remain false. No exported engine, nested/unbalanced
  support claim, allocation rule, missingness assumption, or checklist pass is
  added.

* Implemented an internal balanced univariate G-study estimator prototype on
  the typed design map. Orthogonal ANOVA/MoM inversion reproduces frozen p x i
  and p x r x i components and retains raw negative estimates; matched `lme4`
  REML agrees on interior fixtures, while ML remains separately identified and
  a negative-MoM control reaches a constrained zero/singular REML boundary.
  The legacy main-effects/collapsed-residual identity reproduces the current
  public helper but cannot enter the interaction-specific algebra. All
  inference and decision-ready states remain false. No exported estimator,
  formula family, interval, preference, sample-size rule, or release claim is
  added.

* Implemented an internal typed G-theory design parser and balanced
  D-study algebra oracle. It canonicalizes random-intercept formula terms into
  explicit object/facet roles and component-specific divisors, reproduces hand-
  calculated persons-by-items and persons-by-raters-by-items coefficients, and
  stops before coefficient output for unresolved residual meaning, nesting
  without conditional scaling, and highest-order interaction/residual aliasing.
  Raw negative components remain visible and non-ready. This performs no fit,
  changes no exported API, and adds no crossed, nested, multivariate, interval,
  estimator, cutoff, optimum-design, or release claim.

* Added an internal typed G-theory and D-study reconstruction roadmap. It
  preserves the current univariate main-effects/collapsed-residual helpers as a
  caveated baseline while specifying a future formula-plus-design/effect-map
  contract for crossed, nested, partially crossed, unbalanced, and missing
  designs. Component-specific D-study scaling, visible likelihood boundaries
  and raw ANOVA/MoM negatives, full-refit bootstrap uncertainty, and
  multivariate covariance/PSD/shared-facet rules are staged separately. No
  backend dependency, arbitrary-formula support, multivariate claim, interval
  method, coefficient cutoff, optimal design, default, or release state is
  added.

* Completed an internal checkpointed 36-dataset matched-topology JML smoke.
  Path, cycle, distributed, and hub assignments hold bridge-Person count,
  degree, and density fixed while recording articulation Raters, cut edges,
  one-link-Person failure, cycles, edge weights, and algebraic connectivity.
  Six planned observed-disconnected controls stop before optimization; all 30
  connected RSM/PCM cells retain their method rows. A second process resumes
  all checkpoints and reproduces the aggregate and completion marker exactly.
  The smoke also blocks the unchanged performance pilot: every connected cell
  contains a natural extreme Person and most TAM adjusted fits reach the smoke
  iteration ceiling. Sparse operational, raw-eligible high-information, and
  stronger convergence lanes must be separated before replication. No graph
  cutoff, topology preference, correction, sample-size rule, method ranking,
  threshold, default, or release state is selected.

* Completed an internal 36-dataset connected-assignment TAM/immer/mfrmr JML
  structural smoke. Six no-link negative controls fail before optimization and
  30 connected RSM/PCM cells retain all 270 planned method rows. Assigned and
  post-missingness Rater graphs now record bridge counts, degree, density,
  workload imbalance, components, shared-Person edge weights, and weighted
  algebraic connectivity. The result shows that bridge rate and total Persons
  alone do not determine linking information, and that fixed-degree and fixed-
  density Rater comparisons are different conditional contrasts. It freezes
  no bridge cutoff, sample-size rule, correction, method ranking, threshold,
  default, or release state.

* Completed the internal 290-dataset TAM/immer/mfrmr factor pilot with atomic
  dataset checkpoints and an independently replayed completion marker. The
  five-replicate result retains 230 fitted RSM/PCM cells, 40 expected
  one-Rater-per-Person structural failures, 20 common-anchor-basis guards,
  2,070 mode rows, and 39,406 metric rows. It exposes connected-design and
  factor-alias revisions, confirms that sparse/missing exposure separates the
  TAM and immer classical corrections, and keeps fit return, convergence,
  extreme-boundary eligibility, recovery, rank, and separation denominators
  distinct. Results remain calibration-only: common-surface coverage and
  reported facet separation are unavailable, and no correction, sample-size
  rule, threshold, default, or release state is selected.

* Added an internal factor-structured TAM/immer/mfrmr JML feasibility smoke.
  Twenty-two RSM/PCM datasets exercise Persons, realized exposure, Raters,
  Criteria, category count, sparse assignment, workload imbalance, endpoint
  responses and extreme Persons, local dependence, anchors, and none/MCAR/
  Rater-MAR/score-MNAR missingness. Expected anchor-basis and structural-rank
  guards remain failures by design. Bias, RMSE, rank recovery, recovery
  separation, fit return, finite output, convergence, and evidence eligibility
  are recorded separately; common-surface coverage and reported facet
  separation are withheld. The later checkpointed 290-dataset pilot likewise
  selects no correction, sample-size rule, tolerance, default, or release
  state.

* Added an internal source-audited TAM/immer/mfrmr JML normalization smoke for
  matched RSM/PCM cumulative-difficulty surfaces. The validation runner records
  exact loaded-function hashes and keeps TAM raw, adjusted, classically
  postscaled, and combined modes separate from immer `jml`, `eps_adj`, and
  `jml_bc`. The microcases verify the shared response kernel while showing that
  identically named JML modes do not share one extreme-score or finite-item
  correction. Results are calibration-only: they select no estimator,
  correction, release tolerance, default, or readiness state.

* Completed an internal paired calibration of raw finite JML traces and the
  extended extreme-Person profile limit. Ninety RSM, PCM, and aligned
  Criterion-owned GPCM datasets crossed low/high exposure and three forced
  extreme fractions. All fits, signed boundary classifications, profile paths,
  and structural pairings completed without a false-ready result. Person
  recovery and profile uncertainty were deliberately excluded. The paired
  structural estimates were nearly unchanged, which reinforces that the
  profile operation resolves likelihood non-attainment but is not a
  finite-item bias correction, estimator selection, or readiness promotion.

* Added an internal JML extreme-Person profile-limit prototype. For
  independently free all-minimum/all-maximum Persons it reoptimizes the exact
  reduced supremum objective and separately reconstructs finite original-JML
  cap paths. Selected RSM, PCM, and aligned-owner GPCM controls reach the
  profile limit while anchored extremes remain fixed and constraint-coupled
  extremes fail closed. Raw fits are not overwritten: the result explicitly
  is not a finite maximum of the original full-vector JML likelihood, a
  finite-item bias correction, a public estimator, or a readiness promotion.

* Added fixed-quadrature marginal-MML GPCM slope-boundary instrumentation.
  The audit derives nodewise sufficient conditions for a nondecreasing
  sum-zero log-slope ray, enumerates every ordered two-level direction, and
  independently reconstructs its Person-pattern marginal boundary
  likelihood. It is estimator-specific and does not reuse the conditional
  JML audit. The result is explicitly not a continuous-integral or
  joint-coordinate proof and has no readiness effect: finite MML optimizer
  slopes remain numerical traces until independent calibration and a separate
  propagation contract are complete.

* Completed an internal retrospective q-grid calibration for that MML
  slope-path instrument. Forty exact owner-pilot datasets were rerun at
  q=31/61/91: all 120 fits reproduced the earlier likelihoods exactly, and the
  none-certified state was stable across grids for every dataset. Direct
  q61-to-q91 changes were retained separately for slopes, facets, steps,
  Person EAPs, and posterior SDs. Because the datasets were already inspected
  and contained no positive certified case, the result changes no quadrature
  default, tolerance, readiness state, or release gate; prospective positive
  controls and untouched owner data remain required.

* Added the corresponding deterministic positive/negative challenge and
  retained its concern result. Mixed-negative and positive-weight-discordant
  expectations behaved as declared, but the known five-node positive
  construction did not remain certified at 31, 61, or 91 quadrature points
  for either slope owner. The extreme Gaussian--Hermite nodes move outward as
  the grid is densified, making the current individual-response all-node
  sufficient condition too restrictive for those positive controls. MML
  slope readiness therefore remains blocked pending broader Person-marginal
  path mathematics; no default or inferential surface is promoted.

* Added an internal analytic prototype for that broader Person-marginal
  path. It reconstructs the finite-quadrature likelihood, first derivative,
  curvature, surviving-node boundary, and leading tail coefficient. Selected
  controls show how adverse conditional nodes can lose posterior mass while
  the Person marginal continues upward. The prototype does not certify the
  complete half-line and cannot affect fitted objects: outward numerical
  bounds, a compact-interval proof, and a rigorous tail remainder remain
  required.

* Hardened direct GPCM optimization against non-representable slope proposals.
  Parameter-cache updates are now transactional, and only the typed
  floating-point slope-boundary condition is converted to a finite dominating
  line-search objective; unrelated failures and invalid retained parameter
  vectors still fail hard. The fitted optimization cache records the rejected
  proposal count. A fixed 40-dataset owner-pilot recheck retained both formerly
  lost JML fits while leaving the criterion weak-bridge path convergence-failed
  and inference-ineligible, so the numerical repair does not conceal the
  substantive boundary warning.

* Added an identity-stamped internal GPCM MML integration-sensitivity
  lane. It fits exact owner-pilot datasets at q=31/61/91, reevaluates all
  candidates on a common q=91 grid, and separates structural-parameter,
  Person-EAP, posterior-SD, optimizer, and evidence-readiness sensitivity.
  The calibration run keeps q=31 as a comparison starting grid rather than an
  integration-sufficiency claim; no package default or release threshold is
  changed.

* Hardened differential-facet-functioning subgroup refits so they replay the
  baseline response family, resolved rating range, step/slope facets, weighting,
  optimizer, MML engine, and numerical controls instead of silently redefining
  the subgroup model or capping its iteration budget. Refit screening now fails
  closed for active latent regression, facet interactions, and group-anchor
  constraints until complete subgroup linking contracts exist. Documentation
  now treats `min_obs` as a computability guard rather than a universal
  sample-size rule. The bounded-GPCM contract also identified that the then-
  default fixed-standard-normal MML plus geometric-mean-one slopes estimated
  relative discrimination contrasts rather than the full conventional GPCM
  common-slope scale; the current release line corrects that default as
  described above and retains the old likelihood only by explicit request.

* Sanitized the workflow vignette's export preview to display path basenames.
  The rendered public artifact no longer embeds a build machine's temporary
  directory, while the live return object still retains usable local paths.

* Corrected MML Person EAP and posterior-SD alignment after retained rows are
  permuted or filtered. Person-pattern posterior summaries are now mapped by
  their internal Person indices before the fitted Person table and EAP-based
  expected-score, residual, fit, bias, and residual-PCA diagnostics consume
  them. Previously, stochastic or outcome-dependent row removal could pair
  posterior summaries with the wrong Person labels even though the marginal
  structural estimates were unaffected.

* Added one versioned fit-readiness record that combines input review,
  estimability, category support, parameter-boundary status, and numerical
  diagnostics with deterministic precedence. `fit$summary$FitReadiness` and
  the conservative `InferenceReady` scalar now come from that stored record;
  summaries, result bundles, and plot review consume it instead of treating
  optimizer convergence as end-to-end readiness. Localized typed exclusions
  remain distinguishable from general review or failure. Objects saved without
  the current record are labelled `legacy_unknown` by the compatibility
  adapter rather than being upgraded from an older Boolean; convergence,
  summary, result, and fit-plot entry points keep them review-only until refit.

* Added parameter-level readiness for free GPCM slopes. Certified JML
  fixed-additive slope paths now have typed low, high, or two-sided boundary
  states and extended-real primary values, while finite optimizer values remain
  explicitly labelled numerical traces. A bounded joint JML check now also
  searches ordered slope-pair paths with simultaneous additive movement. A
  competitive path is retained as a candidate rather than promoted to a global
  unbounded estimate; a negative result remains limited to that path family.
  Neither result is treated as proof of a finite joint GPCM maximum, and the
  conditional JML evidence is not reused for MML. MML now has a separate
  fixed-quadrature sufficient-path instrument, but its results remain
  non-propagating and cannot establish finite slopes. Approximate covariance calculations remain
  available in `Optimizer*SE` / `Optimizer*CI` fields, while ordinary slope
  uncertainty is withheld until estimator-specific readiness is established.
  `summary()` separates primary slope summaries from finite optimizer traces,
  and the documentation distinguishes FACETS' post-fit discrimination
  diagnostic, TAM's non-faceted GPCM slope route, and `immer`'s equal-
  discrimination or alternative-model reference roles.

* Added a model-scoped category and step-support preflight. Every new fit now
  distinguishes declared, globally observed, ladder-observed, retained, free,
  derived, fixed, weak, and unsupported category/step coordinates. RSM uses
  one shared-ladder support decision; PCM and bounded GPCM audit every current
  `step_facet` ladder. An internal category with no positive-weight
  observations creates an exact adjacent-step recession direction and now
  stops before optimization with a structured error. Empty boundary
  categories and local RSM gaps remain review evidence for the separate
  element-boundary contract. Binary ladders do not invent a free threshold
  blocker. Repeated
  design evaluations retain category-error class/state/reason provenance in
  `rep_overview` and preserve the documented zero-row results schema when all
  fits in a design fail preflight.

* Added an estimator-specific sparse constrained estimability preflight for
  RSM/PCM Person, facet, interaction, and step coordinates. Exact aliases now
  stop before optimization with a structured audit; MML designs whose apparent
  linkage depends on a common latent-population assumption remain review-only.
  Simulation-design examples now use a crossed two-rater assignment so their
  summaries remain populated under this preflight; an unlinked one-rater-per-
  Person design continues to fail closed rather than fabricate recovery output.
  Bounded-GPCM slopes and active latent-regression residual variance are
  explicitly outside the completed linear-block claim rather than being
  certified by additive rank. For stationary nonlinear fits with at most 80
  free coordinates, the estimability record now also stores a diagnostic
  observed-information Hessian tolerance ladder and nonlinear-block summary.
  This bounded calculation does not classify weak information, complete the
  nonlinear preflight, or alter readiness. The same estimability record now
  verifies the analytic free-to-expanded transformation Jacobians for GPCM
  log slopes and latent-regression residual variance against central
  differences. Transformation rank is explicitly parameterization-only and
  is not presented as response-likelihood identification. For JML GPCM fits,
  the record additionally checks the combined additive and log-slope
  adjacent-category response-kernel Jacobian. MML does not reuse that
  conditional calculation as evidence about its integrated likelihood.
  Eligible nonlinear MML fits instead receive a bounded observed-Person-
  pattern score decomposition with objective, gradient, and numerical-
  derivative consistency checks. Observed-pattern rank remains diagnostic and
  does not establish structural identification or alter readiness. Within a
  bounded execution envelope and for unit row weights, the same fits now also
  enumerate every response pattern on each retained Person observation design
  and check probability normalization, zero expected score, expected
  score-outer-product information, and selected numerical derivatives.
  Missing rows shorten the retained design; nonunit weights and combinatorial
  overflow receive explicit not-evaluated states. This exhaustive-pattern
  rank is still a retained-point diagnostic and does not establish global
  identification, weak-information status, readiness, or a capacity claim.
  Exact duplicate Person observation designs are evaluated once and
  reconstructed by their group multiplicity. Active latent-regression
  covariate rows participate in the design identity, so different population
  designs are not silently pooled. The audit records conceptual and evaluated
  workload counts without retaining identifiers, covariates, or response
  patterns.

* Added a versioned information-criterion contract for fitted MML objects.
  BIC now uses the number of independent Persons rather than response rows or
  summed observation weights, while response-row, weighted-total, and legacy
  fields remain explicit. JML, non-unit observation weights, legacy objects,
  incompatible likelihood contracts, and insufficient quadrature evidence
  fail closed for automatic model ranking.

* Propagated numerical-readiness and information-criterion eligibility through
  fitted objects, summaries, comparisons, reports, exports, and replay
  metadata so a converged optimizer cannot silently become an inference-ready
  or model-preference claim.

* Corrected Person-involving bias-screen collection so explicit facet pairs
  are accepted and their screening-only status is preserved through result
  summaries.

* Expanded `facets_feature_coverage()` into a machine-readable support
  contract separating surface availability, statistical contract, validation
  evidence, and operational status. Imported frozen-calibration scoring,
  general threshold anchors, multiple observed scales, native
  multidimensional estimation, and unrestricted GPCM remain explicitly
  outside the current public scope.

# mfrmr 0.2.2

* Standardized the package's canonical joint-maximum-likelihood label as
  `"JML"` across fitted objects, engine state, manifests, and replay scripts.
  `method = "JMLE"` remains accepted only as a backward-compatible input alias
  and now resolves immediately to `"JML"`.

* Revised first-contact guides and result guidance to use reader-facing
  wording while retaining documented API and status vocabulary.

* Clarified that `maxit` is a prespecified computational ceiling rather than a
  result-selection control. Iteration-limited fits now direct users to keep the
  specification fixed, follow a prespecified ceiling sequence, and withhold
  interpretation until the numerical-readiness gate passes.

* Replaced blanket `\dontrun{}` and `@examplesIf interactive()` guards with
  checkable examples or `\donttest{}` blocks. Only the two workflows that need
  separately generated ConQuest files remain `\dontrun{}`, and only the local
  Shiny viewer remains interactive-only. The release-readiness review now
  enforces that allowlist and flags CRAN-side package workload above ten
  minutes, based on ordinary examples, `donttest` examples, tests, and vignette
  rebuilding. Other top-level check components remain visible as diagnostics
  but do not inflate that package-controlled threshold.

- Added one authoritative repository roadmap and aligned release metadata and
  validation notes with the accepted 0.2.2 boundary. External numerical
  comparison and calibrated MML joint-stationarity gates are explicitly 0.2.3
  work rather than retroactive 0.2.2 requirements.
- Corrected bounded-GPCM score-side delta-method uncertainty to use the
  expected-score derivative `ScoreSlope * Var`. `ScoreSideLogitSE` remains the
  logit-side component SE, while `ScoreSideSE` and its interval columns now
  apply `ScoreSlope * Var * ScoreSideLogitSE` on the expected-score scale.
- Refit DFF/DIF contrasts are now explicitly exploratory: separate-subgroup
  plug-in standard errors are labeled as conditional on baseline anchors and
  as omitting baseline-anchor uncertainty and cross-refit covariance. Refit
  rows no longer receive ETS A/B/C, formal-inference, or primary-reporting
  eligibility.
- Bias summaries and multi-pair bias collections now use `ScreenPositive` as
  the primary label and expose explicit screening-only eligibility metadata.
  Historical `Significant` names remain as compatibility aliases.
- `import_erm_fit()` now reads the current `eRm` `Person Parameter` /
  `Std.Error` schema as well as historical estimate labels, preserves usable
  person IDs, and rejects ambiguous or misaligned schemas instead of silently
  returning empty or recycled person rows.
- `q3_statistic()` and its print method now identify the result as mfrmr's
  standardized, Person-by-level aggregated-residual Q3-style screen. Legacy
  `YenFlag` names remain for compatibility, while fixed 0.20/0.30 rules are
  explicitly described as uncalibrated heuristics rather than raw-residual
  Yen Q3 critical values.
- `as_kable.apa_table(format = "pipe")` now appends an APA note once after the
  complete Markdown table. Previously the vectorized append could repeat the
  same note after every rendered table line.
- Added the package hex sticker to the README and pkgdown-standard
  `man/figures/logo.png` location, while retaining the editable SVG source.
- Tightened the FACETS positioning contract against the current 64-bit 4.5.1
  software target: coverage rows describe package-native surfaces, not
  external numerical equivalence, and mixed models, multiple scales,
  threshold anchoring, and fixed-calibration scoring remain outside 0.2.2.
- Corrected the `interrater_agreement_table()` documentation: `ExpectedExact`
  is computed from fitted category-probability vectors, not marginal-frequency
  chance agreement. A focused regression test now guards that definition.
- Clarified that exact Person-by-facet duplicate rows are retained but place
  Data readiness under review; legitimate repeated ratings should carry a
  distinguishing event or occasion facet.

- Design, signal-detection, and population-prediction summaries now expose a
  deterministic named-facet review as `structural_design_review`. The review
  reports design balance, coverage, connectivity, and readiness without
  implying Monte Carlo performance or arbitrary-facet simulation support.

## Estimation performance

- A code-zero solution whose terminal gradient still requires review now
  triggers a bounded warm-started polish ladder when the portable tolerance
  setting is at least as strict as the public default. Each stage records its
  optimizer, portable setting, native L-BFGS-B controls when applicable,
  objective, terminal gradient, maximum parameter change, evaluations, and
  elapsed time; the best non-worsening stage is retained rather than assuming
  that stricter controls improve every fit monotonically.
- Direct, hybrid, and EM MML engines now apply the same terminal-gradient gate
  to `InferenceReady`. EM relative log-likelihood convergence remains visible
  as an engine-specific stopping condition but no longer overrides the common
  numerical-readiness contract.
- `fit_mfrm()` now shares likelihood and analytical-gradient work at an
  identical parameter vector. MML direct and EM paths reuse quadrature
  probabilities and posterior quantities, while JML reuses category
  probabilities and stable observed log probabilities.
- The compiled cpp11 probability kernels are now the default for supported
  RSM/PCM MML work, with automatic pure-R fallback. Set
  `options(mfrmr.use_cpp11_backend = FALSE)` for an explicit reference-path
  comparison; GPCM continues to use its validated R kernel.
- `optimizer = "auto"` selects limited-memory L-BFGS-B for MML and for large
  JML parameter vectors; `"BFGS"` and `"L-BFGS-B"` remain explicit choices.
  The requested and actual methods are recorded for summaries, exports, and
  replay. The portable `reltol` setting is mapped to L-BFGS-B `factr` and
  `pgtol`; actual stage controls are recorded alongside the requested and
  selected-stage settings.
- Per-fit workspaces are local to one optimization and are discarded with the
  fit evaluator. They are not global, are not shared across parallel fits,
  and are not stored as large probability arrays in the returned fit object.
- Measurement-graph component detection now avoids repeated row-wise lookups
  while preserving the established subset labels and ordering. This reduces
  first-fit overhead for larger long-format rating designs.

## Summary workflow

- Fit summaries now separate Numerical, Data, Design, Stability, Diagnostics,
  and Reporting readiness. Disconnected measurement graphs and
  boundary-constant or single-level facet support remain explicit reporting
  holds even when numerical optimization succeeds.
- Wright, FACETS-style Wright, pathway, and related fit plots carry additive
  fit-readiness metadata. Review-only displays remain available for diagnosis
  but warn, mark their returned subtitle and drawn title, and do not silently
  promote availability to interpretability.
- `plot_apa_figure_one()` now emits one consolidated readiness warning per
  call, retains the readiness table and interpretation note on the composite,
  and visibly labels a non-ready result as a manuscript-oriented draft for
  review rather than a finished publication figure.
- Native and FACETS-style Wright maps now share a robust automatic range when
  boundary-separated facet levels are diagnosed. Exact estimates and CI bounds
  remain in the returned tables; ruler-end triangles, clipping metadata, and
  plot footers prevent truncated intervals from being read as complete, while
  the native returned legend uses the same keys as the rendered legend.
- `summary(fit)` now supports `profile = "fit"`, `"facets"`, and
  `"reporting"`. The default fit profile remains fast and does not compute
  diagnostics. The opt-in FACETS profile organizes fitted measures, fit,
  precision, categories, steps, and plot routes in a familiar reading order;
  it does not imply that FACETS was run or that its estimates are numerically
  equivalent.
- FACETS and reporting profiles can reuse a matching `mfrm_diagnostics`
  object. The returned summary records provenance and section availability,
  and `compute = "never"` prevents automatic diagnostic computation.
- Bias/DIF, residual PCA, and anchor-drift or linking analyses remain explicit
  follow-up decisions because their interpretation depends on the study
  design.
- `detail = "brief"` gives a selective console view without person
  identifiers. Full structured results remain available through the returned
  object.
- The concise summary presents the visual workflow in order: the required
  native Wright map with facet uncertainty and labelled step locations, the
  optional FACETS-style Wright ruler, and the optional Infit pathway. Person
  rows in the pathway remain opt-in.

## Examples and teaching data

- `example_operational` adds a reproducible 48-person teaching dataset with a
  connected two-rater assignment, moderate workload imbalance, and six
  planned omissions. It is the primary applied tutorial dataset;
  `example_core` remains an explicitly idealized complete-crossing
  example, and `example_bias` remains the planted-effect diagnostic example.
- `mfrmr_example_operational_design` declares the 288 planned assignment cells
  separately from the 282 observed scores. `describe_mfrm_data()` can compare
  an explicit `expected_design` with observed cells, report planned omissions
  and unexpected observations, review Person-facet graph components, summarize
  sparse links and duplicate cells, and keep person labels out of its default
  compact output. Without a roster, structural missingness is reported as not
  assessed rather than inferred from a hypothetical complete crossing.
- `list_mfrmr_data(details = TRUE)` now explains the design and intended role
  of every bundled synthetic dataset. Fixed-seed generators for the compact
  examples are tracked in the public source repository. Combined-study
  objects now explain that relabeling prevents identifier collisions but does
  not establish a common scale without an explicit anchor/linking design.
- Precomputed vignette tables now follow the same successful operational MML
  route as the displayed workflow and record their source dataset, schema,
  MD5 checksum, and package version.

## Safer first analyses

- The public default remains `reltol = 1e-9` for the initial optimizer stage;
  bounded polishing is invoked only when `reltol <= 1e-9` and code zero
  precedes the terminal-gradient gate. The fitted object records requested and
  selected-stage controls for replay. Model specification, design,
  identification, and inferential assumptions remain separate review
  questions.
- Non-finite scores or weights, blank person/facet identifiers, and fractional
  `maxit` or `quad_points` values now fail before expensive optimization with a
  focused correction. Duplicate Person-by-facet cells warn once per fit,
  report both affected rows and duplicate cells, and propagate a Data review
  state downstream.
- `missing_codes = TRUE` now applies the conventional sentinel set to scores
  while preserving person and facet IDs. An explicit character vector remains
  an explicit request to apply those codes across all selected model columns;
  the review records the scope used for each column.
- On-the-fly ConQuest overlap examples now use the same `1e-9` tolerance.
  Their bundle summaries, settings, written README files, and compact console
  summaries report the actual mfrmr fit controls, MML engine, terminal
  gradient, convergence state, and inference readiness. A fit requiring
  convergence review is clearly withheld from the external comparison step.
- `fit_mfrm()` now gives focused guidance for common undeclared missing-value
  codes and records score-category recoding in the fitted object. It also
  distinguishes an explicitly silent anchor policy from policies that report
  anchor review information.
- Partial-credit fits infer the step facet only when a familiar item-like role
  is unambiguous. Otherwise, the warning shows how to set `step_facet`
  explicitly. Rating-scale fits report that `step_facet` and `slope_facet` are
  not used.
- Direct data-frame input to `mfrm_results()` is limited to data with
  recognizable measurement roles. Ambiguous columns now lead to an explicit
  `fit_mfrm(..., method = "MML")` instruction instead of a guessed analysis.
- `describe_mfrm_data()` computes agreement automatically only when a
  rater-like facet is present. Agreement output names the facet actually used
  and avoids presenting a generic facet as a rater.
- Latent regression rejects a non-person-centered parameterization that would
  confound the population intercept with the measurement scale.
- CRAN checks now exercise the complete introductory workflow once and
  use the exact README/default MML controls rather than a reduced quadrature
  setting. They retain lightweight compatibility/backend/artifact contracts.
  Repeated
  estimation, detailed plotting, simulation, and broad regression coverage
  remain in the complete local and GitHub Actions suite.
- A repository-level first-use workflow stress protocol covers linked, sparse,
  disconnected, shared-link, PCM, bounded-GPCM, extreme-score, separation,
  missing-code, and weighted scenarios across deterministic seeds. It keeps
  expectation matching separate from actual report readiness and is excluded
  from routine CRAN checks.

## Interpretation and compatibility boundaries

- Optimizer code zero is no longer treated as sufficient evidence of a clean
  solution when the terminal gradient remains large. Summaries label this
  state as requiring review and explain the diagnostic basis.
- `facets_feature_coverage()` and `gpcm_capability_matrix()` now present concise
  user-facing capability, limitation, and recommended-route information.
  Only documented user-facing columns are returned.
- FACETS-style plots reproduce a reading convention, not FACETS numerical
  estimation. ConQuest comparison helpers cover documented unidimensional MML
  overlap and do not automate ConQuest or claim general numerical equivalence.
- The generated ConQuest overlap command now states quadrature MML explicitly
  and requests four machine-readable CSV outputs.
  `normalize_conquest_overlap_exports()` reads those files, reconstructs the
  sum-constrained item location, trims fixed-width person identifiers, and
  prepares them for `review_conquest_overlap()`.
- A matched 31-node run with ConQuest 5.47.5 Demonstration Version is recorded
  in the public source repository's validation record (excluded from the
  installed CRAN package) for the documented binary, item-only, one-covariate
  MML overlap case. The result supports that narrow handoff and is not a claim
  of general numerical equivalence.
- `export_mfrm_results()` now labels every preset as a potentially identifying
  analysis archive, warns before writing unless the risk is explicitly
  acknowledged, and records privacy status in its summary, HTML index, and
  written-files manifest. Fit-level `export_mfrm_bundle()` archives follow the
  same warning and metadata contract, and the lower-level `export_mfrm()` CSV
  writer now records per-file handling metadata. ConQuest overlap bundles
  likewise warn on file export and include an artifact-level privacy inventory
  for response, covariate, and case-EAP files.

## First-use workflow

- The recommended workflow is now data -> `fit_mfrm()` -> fit summary ->
  required Wright map -> focused diagnostics -> `mfrm_report()` or
  `export_mfrm_results()`.
- `summary(mfrm_results(...), view = "brief")` and
  `summary(mfrm_report(...), view = "reader")` provide stable, concise views
  over the corresponding structured objects.
- `export_mfrm_results(preset = "starter")` writes a reader-first result
  folder with an index, required Wright-map image, selected tables, report
  files, replay code, and a reproducibility manifest.
- The README, workflow vignette, and help pages now begin with the same compact
  analysis route and direct specialist questions to focused follow-up
  helpers.

## Wright maps and fit pathways

- Wright maps retain the native renderer as the default. Native maps can show
  facet SE or confidence-interval whiskers alongside fitted step locations with
  `show_ci = TRUE`, while fitted coordinates remain unchanged.
- `renderer = "facets"` adds an opt-in FACETS Table 6-style visual grammar:
  a shared logit ruler, person-frequency asterisks, signed facet columns, all
  fitted facet levels, horizontal score-transition lines, and optional rubric
  labels. The renderer reproduces a display convention, not FACETS estimation
  or numerical output.
- Both Wright renderers return tidy draw-free data for custom graphics. The
  native `top_n` display remains compact; the FACETS-style data retain every
  fitted location.
- `plot(..., type = "fit_pathway")` adds a separate fit-oriented display with
  Infit or Outfit on the x-axis and measure logits on the y-axis. Screening
  bands, measure intervals, and optional ZSTD companions are explicit.
- Person rows can be added to the fit pathway with bounded selection and
  independent person/facet label controls. The existing expected-score
  `type = "pathway"` is unchanged.

## Reporting and migration support

- `facets_term_crosswalk()` and `facets_visual_contract()` document the
  correspondence between FACETS terminology and mfrmr outputs while keeping
  visual compatibility separate from numerical equivalence.
- `plot_data()`, `plot_data_components()`, and `as_ggplot()` make plot
  coordinates, annotations, reference lines, and guidance available for
  custom R graphics.
- Plot helpers consistently support `preset = "monochrome"` for
  print-friendly figures.
- `export_mfrm_bundle(..., include = "html")` provides a fit-level
  HTML/CSV/replay bundle without first creating an `mfrm_results` object.
- Model-comparison output can be routed through
  `build_model_choice_review()` and `build_summary_table_bundle()`, with
  explicit guidance for equal-weighting RSM/PCM models, bounded GPCM
  sensitivity analyses, and latent-regression reporting.

# mfrmr 0.2.1

## Results, reports, and export

- `mfrm_results()` adds a comprehensive first-screen object for an existing
  fit, a `run_mfrm_facets()` result, or a long-format data frame. It gathers
  diagnostics, available tables, plot routes, status information, next
  actions, and reproducible code without replacing the lower-level helpers.
- `mfrm_results(include = ...)` supports purpose presets for publication,
  FACETS migration, validation, bias, local misfit, linking, network review,
  and bounded GPCM review.
- `mfrm_report()` converts an `mfrm_results` object into a navigable reporting
  plan. Its first screen, report index, template index, evidence boundaries,
  cautious wording, and next actions keep detailed tables available without
  turning diagnostics into pass/fail decisions.
- `export_mfrm_results()` writes selected result tables, report files,
  draw-free plot data, images, replay code, RDS output, and a written-files
  manifest. `export_mfrm_bundle()` remains the broader fit-centered archive.
- `launch_mfrmr_viewer()` provides an optional Shiny reader over an existing
  `mfrm_results` object. It displays stored results and does not refit the
  model or change diagnostics.
- `mfrmr_output_guide("public")` maps the shortest fit, results, report,
  viewer, export, and specialist routes. Additional guides cover FACETS,
  ConQuest, binary data, simulation, linking, response time, and R-first
  visualization.

## Interpretation and reporting accuracy

- APA output now describes mean-square fit relative to the selected screening
  band instead of labeling overall fit “acceptable” or “elevated.” Band
  position is presented as a review signal, not a validity decision.
- MML reports state that person measures are EAP estimates and that
  residual-based fit statistics are evaluated at those measures. Comparisons
  intended to match JMLE-based FACETS output should use `method = "JML"` and
  aligned settings.
- Small-df ZSTD values are withheld when the transformation is unstable.
  FACETS/Winsteps output may still show a value under different sparse-cell
  conventions; such pairs are labeled as availability or standardization
  differences rather than automatically as fit differences.
- MML person separation and reliability are based on EAP measures and
  posterior SDs. They are kept distinct from JMLE-based FACETS reliability and
  from observed inter-rater agreement.
- APA tables and narratives report the measure-CI basis and fitted sign
  convention when available. Separation reliability, agreement, fit, and
  validity remain separate reporting claims.
- `precision_review_report()`, `fit_measures_table()`, and
  `facets_fit_review()` expose the fit, ZSTD, df, separation, and uncertainty
  bases needed before drafting technical conclusions.

## Focused review and planning

- Result and report objects can carry explicit bias, local-misfit/pathway,
  linking/anchor, precision, network, and response-time sections. Missing or
  unrequested sections remain visible as such.
- Recovery summaries expose `reading_order`, `condition_review`, and
  fit/separation operating characteristics. Bounded-GPCM `slope_regime`
  labels and extended sensitivity evidence remain separate from recovery
  metrics, convergence, and uncertainty availability; they are not automatic
  adequacy decisions.
- Resampling and simulation tools add person-clustered subsampling/bootstrap,
  sparse linked rating designs, connectedness summaries, and peer-assessment
  assignment checks. These are stability, design, or operating-characteristic
  diagnostics rather than calibrated tests or automatic decisions.

# mfrmr 0.2.0

## Scope and compatibility

- This version strengthens mathematical identification, uncertainty
  reporting, diagnostic tables, recovery tools, and draw-free visual output
  for RSM, PCM, and the documented bounded GPCM implementation.
- Breaking change: former exported `*_audit*` helper names, compatibility
  classes, and duplicate output fields were removed in favor of the canonical
  `*_review*` names. Stable accessors include `anchor_review()` and
  `precision_review()`.
- `facets_positioning_guide()`, `facets_feature_coverage()`, and
  `facets_output_contract_review()` describe supported FACETS-style tables,
  migration routes, and known differences. mfrmr estimates remain
  package-native unless external FACETS output is supplied for comparison.
- `mfrmr_output_guide("facets")`, `mfrmr_output_guide("conquest")`, and
  `mfrmr_output_guide("r")` provide focused entry points for users moving from
  FACETS or ConQuest and for users who want reusable R plot data.
- `write_mfrm_residual_file()` and `write_mfrm_subset_file()` add standalone
  residual and connected-subset files for external review.

## Estimation and fit statistics

- RSM, PCM, and bounded GPCM step profiles now use the correct sum-to-zero
  parameter count. MML structural covariance output provides uncertainty for
  non-person facets, steps, and bounded-GPCM slopes when the observed
  information is available.
- Measure tables record confidence level, interval method, eligibility, and
  interpretation basis. `compare_mfrm()` records the BIC sample-size basis,
  including weighted fits, and withholds unsupported likelihood-ratio tests
  with an explicit reason.
- Bounded-GPCM simulation and fitting use the same geometric-mean-one
  relative-slope identification. Expected scores, information, category
  curves, fair averages, and bias screening use slope-aware probabilities.
- `fair_average_table(fair_se = TRUE)` adds structural delta-method
  uncertainty where supported. `estimate_bias()` uses slope-aware information
  and can report conditional profile-likelihood screening quantities.
- `diagnose_mfrm(fit_df_method = "engine" | "facets" | "both")` exposes the
  package and FACETS-style df/ZSTD conventions separately.
  `facets_fit_review()` and `read_facets_fit_table()` support row-aligned
  comparison with existing FACETS tables without treating convention
  differences as estimation errors.
- `compute_person_fit_indices()` computes polytomous `lz` from observed
  category probabilities. Snijders-corrected `lz_star` is reported for
  compatible JML/fixed-effect person estimates and remains unavailable for
  MML/EAP scores. The incorrectly named `ECI4` output was removed; use
  `OutfitZSTD` for the corresponding standardized chi-square quantity.

## Diagnostics and visualization

- `fit_measures_table()` adds FACETS-style element fit tables, configurable
  threshold profiles, measure intervals, df-sensitivity summaries, and
  draw-free fit plots.
- `data_quality_report()` reports row retention, score-support gaps,
  zero/sparse category use by facet level, restricted response patterns,
  quality flags, original-to-internal score mapping, and dashboard plot data.
- `analyze_residual_pca(parallel = TRUE)` adds residual-permutation parallel
  analysis and dedicated plots. It remains exploratory dimensionality
  evidence.
- `category_curves_report()` adds category probabilities, cumulative
  probabilities, total information, category-specific information, boundary
  summaries, and overview/focused plots.
- `plot_data()` and `plot_data_components()` expose long-form data,
  annotations, styles, and settings from supported `draw = FALSE` plots;
  monochrome and interval guides support print-oriented reporting.
- Response-time QC, design connectedness, rater-effect networks, and halo
  screening receive dedicated summaries and plots. They remain descriptive
  evidence, not speed parameters, logit estimates, or automatic exclusions.
- `mfrm_d_study()` extends observed-score generalizability output to planned
  rater/facet-count comparisons. Its residual-scaling assumptions are
  reported explicitly; it is not a substitute for an unidentified
  interaction decomposition.

## Recovery, model choice, and reporting

- `evaluate_mfrm_recovery()` and `assess_mfrm_recovery()` report parameter
  recovery, convergence, coverage, Monte Carlo precision, uncertainty
  availability, score support, and user-specified practical thresholds in
  separate summaries and plots.
- `build_model_choice_review()` combines fitted-model comparisons, model-role
  guidance, downstream support, cautious wording, and optional weighting
  review for RSM, PCM, and bounded GPCM candidates.
- `build_summary_table_bundle()` and `export_summary_appendix()` accept a
  broader set of fit, recovery, person-fit, precision, and comparison objects
  for report and appendix handoff.
- DIF plots add comparable scales, value labels, flag thresholds, confidence
  intervals, and interpretation metadata. Input validation for DFF/DIF
  helpers now fails earlier with clearer messages.
- Citation and interpretation corrections clarify mean-square screening
  ranges, Q3 residual conventions, sample-size guidance, ICC bands,
  shrinkage uncertainty, and the limits of pairwise bias SE approximations.

## Bounded GPCM boundary

- `gpcm_capability_matrix()` is the authoritative support map. Supported,
  caveated, and unavailable routes include a recommended alternative and the
  evidence needed for broader use.
- Direct fitting, posterior scoring, information, category plots, recovery,
  fair averages, conditional bias screening, and selected reporting/planning
  helpers are available where marked.
- Full unrestricted discrimination structures, full FACETS score-side
  equivalence, posterior-predictive checks, and heavy Bayesian backends are
  outside this version's supported scope.
- Structured `mfrmr_gpcm_scope_error` conditions identify the unsupported
  area and recommended route instead of returning a partial result.

## Defaults and performance

- No defaults changed from 0.1.6:
  `quad_points = 31`, `diagnostic_mode = "both"`,
  `plot(fit)` showing the Wright map, and `keep_original = FALSE`.
- Users upgrading directly from 0.1.5 should note that these defaults were
  introduced in 0.1.6.
- The cpp11 MML backend is used by default for supported RSM and PCM work;
  `options(mfrmr.use_cpp11_backend = FALSE)` selects the pure-R reference
  path. Unsupported kernels fall back automatically.

## 0.1.6

- Changed the default diagnostic mode from legacy-only to both legacy and
  strict-marginal diagnostics, increased MML quadrature points from 15 to 31,
  and made the Wright map the default `plot(fit)` output. The former overview
  remains available with `type = "bundle"`.
- Added estimated facet interactions, empirical-Bayes shrinkage,
  hierarchical/sample-adequacy review, missing-code preprocessing, APA output
  adapters, confidence intervals across major plots, Q3 diagnostics, expanded
  person-fit indices, observed-score generalizability helpers, import adapters
  for mirt/TAM/eRm, resumable MML fits, and additional diagnostic plots.
- Improved fit summaries, replay scripts, input validation, examples,
  large-design diagnostics, and the printable cheatsheet.

## 0.1.5

- Simplified the first-use fit, diagnostic, and reporting workflow.
- Added MML latent regression with EAP scoring, the first bounded-GPCM
  fitting route, binary and non-consecutive score support, strict-marginal
  follow-up plots, report/appendix helpers, and clearer uncertainty and
  support boundaries.
- Added focused overlap and handoff guidance for FACETS, ConQuest, mirt, TAM,
  and eRm.

## 0.1.4 to 0.1.1

- Improved metadata, references, help-page examples, output documentation,
  and cross-platform portability while preserving the public analysis
  workflow.

## 0.1.0

- Introduced package-native many-facet RSM/PCM estimation with MML and JML,
  arbitrary facet counts, FACETS-style bias and fixed-width reports,
  APA-oriented summaries, residual-PCA diagnostics, visual summaries,
  anchoring helpers, and synthetic example data.
