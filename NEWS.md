# mfrmr 0.2.4.9000 (development version)

* Saved two-family GPCM results now load their required sparse-matrix methods
  when the package is attached in a fresh R session. Reports and score exports
  no longer depend on Matrix having been loaded by an earlier fit or another
  package; replay still performs no fitting or scoring.

* Latent-regression scoring now preserves the fitted basis for `scale()`,
  `poly()` and prediction-aware spline terms. Previously the same Person's
  conditional prior could change with the other Persons in the scoring batch,
  and a single-Person batch could fail. Saved fits retain the training terms;
  older fits reconstruct them from matching retained training data or stop
  explicitly when that basis cannot be recovered. Scoring batches need not
  have a full-rank covariate matrix because they do not re-estimate coefficients.
  Estimation, population-parameter inference and source-readiness rules are
  unchanged.

* `fit_mfrm()` help clarifies that extreme Persons are retained: ordinary
  JML distinguishes infinite Person estimates from optimizer traces, corrected
  JML uses profile-boundary contributions, and MML integrates their responses
  and reports posterior EAPs. The `has_exclusions` Person-boundary label does
  not mean input deletion. New-Person posterior scoring is distinguished from
  calibration. This is a documentation clarification, with no estimator change.

* `predict_mfrm_units()` now checks EAP and posterior-SD integration for every
  native scoring batch, including ordinary RSM/PCM with the retained prior.
  Previously that route could return a coarse-grid score even when supplying
  the identical prior explicitly required a finer grid. Failed checks stop
  under the default policy; increasing `scoring_quad_points` changes only
  scoring, and explicit review output retains the failure labels. New saved
  scores must retain their numerical checks for summary/export. Legacy scores
  keep their recorded procedure. Calibration and posterior interval definitions
  are unchanged; these intervals still exclude calibration uncertainty.

* `mfrm_facet_intervals()` adds experimental native-scale model intervals for
  estimated intercept-only normal RSM/PCM and one-family GPCM MML, including
  the latter's explicit fixed-N(0,1) restriction. Direct fixed/adaptive fitting,
  unit weights and centered additive facets/steps are required. Full joint
  information and same-point finer-grid checks retain nuisance uncertainty;
  numerical refusals preserve points with unavailable bounds. Results, plots,
  reports and exports retain these checks and the native scale. The fixed-normal
  GPCM branch now recognizes its actual saved population metadata instead of
  rejecting a valid fit. Sampling coverage remains unqualified; no standardized
  contrasts, sandwich extension or formal JML intervals are added.

* Two-family GPCM fitted-curve plots now state once that calibration intervals
  are unavailable, instead of covering every curve point with a cross. Facet
  labels use separate lines so rating contexts are easier to read. All saved
  values, contexts and unavailable bounds remain unchanged; one-family curves
  still mark individual unavailable intervals and preserve gaps in ribbons.

* Help and output guides now consistently describe experimental two-family
  GPCM Person scoring, saved-score attachments, location/contrast intervals
  and posterior residuals. Portable-calibration guides distinguish corrected
  JML reference-prior scoring from two-family MML's fixed N(0,1) prior, which
  cannot be overridden. Obsolete statements that these routes were
  unavailable have been corrected. Conditional scoring still excludes
  calibration uncertainty, and interval coverage remains unqualified.

* Saved response diagnostics now distinguish complete, partial and unavailable
  residual output in `mfrm_results()`. The `response_overview` table reports
  selected, available, unresolved, missing-score, zero-variance and unselected
  source rows. Two-family GPCM, testlet and shared-rater reports show these counts
  on their first screen; incomplete numerical results no longer receive an
  unconditional available label.
  Saved estimates and the numerical acceptance checks are unchanged.
  Older saved `mfrm_results` objects without the overview recover it from their
  retained diagnostic rows when summarized, reported, exported or opened in a
  supported results viewer, without re-estimation.

* `mfrm_facet_intervals()` now supports experimental two-family GPCM MML
  location estimates and within-facet contrasts with `method = "model"`.
  It transforms the inverse full marginal information under the fitted location
  constraints, retaining slope/step nuisance uncertainty. Source, stationarity,
  information and quadrature checks must pass; otherwise points and reasons
  remain with missing intervals. Plots, result attachments, reports and exports
  preserve the fixed N(0,1) scale and experimental status. Sampling coverage is
  unqualified, and location differences do not imply uniform rating differences
  when slopes or steps differ. No sandwich, step/curve or rater-quality inference
  is added; individual rater sheets continue to display slope intervals only.

* Multivariate D-study printing now separates observed source counts and row
  usage from complete future plans and displays composite weights. Saved paired
  plan comparisons retain this source context without raw ratings or identifiers;
  older comparisons explicitly report when it is absent. Comparison plots now
  default to G/Phi or SEM on their original scale for every plan, including a
  marked reference, connected in supplied plan order. Use `view = "differences"`
  for the previous paired difference intervals. Both views identify future
  complete crossed plans; point projections do not acquire confidence intervals
  from the difference intervals. Coefficients, intervals and `summary()`
  tables are unchanged. Save full objects with `saveRDS()`;
  a coefficient CSV alone does not retain the design and interpretation context.

* `mfrm_report(..., style = "rater")` now creates experimental individual
  feedback sheets for two-family GPCM MML. The sheet separates location,
  component slope, step offsets, category use and assignment exposure, and
  reuses matching saved slope intervals and posterior residuals when supplied.
  Unresolved and unselected rows remain counted; location/step intervals and
  diagnostic cutoffs remain unavailable. Object, tables, Markdown and standalone
  HTML omit source identifiers and free-form source notes. No fitting or new
  inference occurs, and no rater-quality or training-effect claim is added.

* Saved two-family scores now reject inconsistent interval levels or algorithm
  labels before summary and result collection. Result attachments also compare
  their saved calibration values and coding with the supplied fit, so a retained
  source identity cannot make a changed calibration match. These checks require
  no fitting, integration or rescoring.

* Two-family `mfrm_results(fit, scores = scores)` now accepts saved native
  new-Person predictions and format-6 portable scores with matching source
  identity. Results, reports, CSV and replay retain unrounded EAP/SD/intervals,
  source/batch checks, omissions and review-only labels without rescoring.
  Older outputs without source identity remain standalone-readable but need
  regeneration before attachment; older portable calibrations must also be
  re-extracted. No refitting is required. These conditional intervals exclude
  calibration uncertainty and do not qualify coverage or population transport.

* The existing portable calibration workflow now supports experimental
  two-family GPCM MML in file format 6. It preserves ordered slope components,
  location/step constraints, category codes, fixed N(0,1) prior and source
  checks without training responses or Person estimates. Saved artifacts score
  new batches in a fresh session with separate integration checks. Unobserved
  combinations of known levels are flagged; prior overrides and repeated-event
  extensions are unsupported. Formats 1--5 retain their original meaning.
  Validation/freezing does not qualify coverage or population transport, and
  posterior intervals still exclude calibration uncertainty.

* `predict_mfrm_units()` now supports experimental conditional new-Person
  EAP, posterior SD and continuous posterior intervals for two-family GPCM
  MML. Both slope owners and original category steps are retained, with known
  levels, unit weights and the fixed N(0,1) prior. Source identity/convergence,
  finer source integration and each scoring batch are checked separately.
  Review-only results remain flagged; invalid calibrations cannot be enabled
  by review. Save/reopen and summaries retain the calibration and checks.
  Intervals exclude calibration uncertainty; coverage and population transport
  remain unqualified. Portable calibration follows the separately validated
  format 6 route above.

* Two-family results now collect all fitted non-Person locations, category
  steps and component slopes for tables and CSV export. Reports include
  location and step values alongside slopes, preserving facet identities,
  centering references and unavailable intervals without recalculation.
  Category steps are identified as centered offsets, not standalone thresholds.

* Two-family result summaries no longer recommend unsupported ordinary
  diagnostics or flag a Wright map as a missing required figure. `plot(res)`
  uses the sole available saved curve, slope-interval or response-diagnostic
  plot; multiple saved plots require an explicit `type`. Missing plots are
  explained without calculating new results, and unavailable intervals stay
  visible in the selected saved display.

* `mfrm_results(fit)` now accepts two-family GPCM fits with its default
  arguments, collecting saved estimates and numerical status without new
  fitting or diagnostic calculations. Saved curves, intervals and response
  diagnostics can still be attached explicitly; unsupported section requests
  remain errors. Replay instructions preserve the complete saved result even
  when no additional inference is attached.

* Adaptive GPCM MML can now use the existing bounded curvature restart when
  ordinary optimizer polishing leaves a failed gradient review. This uses
  the same adaptive likelihood with a fixed population and at most 64 free
  parameters. A proposal needs positive, well-conditioned curvature, a smaller
  gradient and no objective deterioration beyond roundoff; failures remain in
  the stage history. Information and interval checks are unchanged.
  Weak-information refusals now show the curvature-change, inverse-residual
  and standardized-displacement values with their limits.

* Two-family adaptive direct MML now compares neutral and same-data EM-derived
  starts using the same adaptive likelihood. This repairs an observed failure
  where a neutral start reached a poor, nearly flat solution despite a small
  gradient. `gpcm_mml_start = "neutral"` retains the earlier procedure.
  Selection preserves a better unfinished candidate's convergence status;
  starts, failures, seed and optimizer histories and costs remain saved.
  Summaries, results, reports and quadrature refits retain the initialization
  policy. Interval checks remain separate and sampling coverage is unqualified.

* `mfrm_response_diagnostics()` now accepts two-family adaptive direct MML
  fits. Source likelihood and gradient checks use the adaptive objective;
  prediction integrates each Person's complete observed record with both
  slope families and calibration fixed. Higher-order row checks preserve
  unresolved probabilities and groups. Selecting output rows does not shorten
  the conditioning record. Existing plots, reports, exports and saved replay
  retain the integration method and descriptive interpretation, without
  expectation-one references, fit cutoffs or calibration-uncertainty propagation.

* Two-family adaptive direct MML now supports experimental component log-Wald
  intervals through `confint(fit)`. Full observed information differentiates
  the moving-node likelihood, including all nuisance parameters. Fresh source,
  convergence, score-rank, stationarity and higher-order adaptive-integration
  checks retain estimates with missing bounds when unsuccessful. Saved interval
  settings, plots, reports and exports retain the actual integration method.
  These numerical checks do not establish sampling coverage. Adaptive profile
  intervals remain unavailable.

* Two-family GPCM now permits `mml_engine = "direct"` with
  `mml_integration = "adaptive"` in `fit_mfrm()`. This uses the existing
  moving-node likelihood and gradient while retaining the fixed N(0,1)
  population and both slope owners. Summaries, conditional curves, saved
  reports and quadrature-order refits retain the actual engine and integration
  method. Fixed-grid EM remains available. Adaptive two-family profile
  intervals are unavailable; numerical
  convergence does not establish identification or interval coverage.

* `mml_quadrature_sensitivity()` and its GPCM alias now accept
  `adaptive_quad_points` for two slope families. The existing adaptive
  integration calculation uses both slope components and compares integrals
  at unchanged calibration parameters. Per-Person results distinguish
  integration error from changes introduced by refitting. Summaries and saved
  results retain these diagnostic quantities without adding Person scoring
  or adaptive EM; the fixed-calibration review alone does not change interval eligibility.

* The GPCM guide adds a judged-sport example based on official Olympic score
  protocols. It distinguishes competition totals from latent ability, preserves
  judge identities and advancement, and explains the additional uncertainty
  needed for winner selection. GPCM and multivariate D-study help clarify that
  individual intervals and reliability coefficients do not supply winner
  probabilities or simultaneous rank confidence sets. No new ranking estimator
  or changes to fitted scores are introduced.

* The GPCM guide adds an empirical writing-data workflow using the separately
  available `sirt::data.ratings1` dataset. It explains uneven assignment,
  unused factor levels, absent categories and unknown planned assignments,
  and shows why numerical convergence alone is insufficient for rater
  feedback. It also distinguishes the supported model from published OSCE
  extensions and clarifies experimental two-family interval availability.

* Corrected-JML summaries, reports and exports now explain which repeated
  sampling the reported `RootSE` describes. Fixed assignment counts still
  allow the composition of a new cohort to vary. This uncertainty does not
  describe reassessing the same Persons at fixed abilities. Help clarifies
  the sampling assumptions and small-sample limits; estimates and covariance
  calculations are unchanged.

* Adaptive MML fitting and calibration checks perform fewer repeated matrix
  calculations for RSM, PCM and GPCM. The likelihood, integration rules and
  numerical accuracy requirements are unchanged.

* Numerical integration sensitivity checks for RSM and PCM no longer emit
  an unnecessary warning about a missing slope column.

* `recommend_mfrm_design()` avoids building unrelated planning tables when
  selecting a design. Recommendations still use unrounded results and retain
  failed replications in the convergence and workload checks.

* Two-family GPCM MML--EM now supports an explicitly selected component profile
  through `confint(fit, method = "profile", slope = c(Task = "t1"))`, using
  the fitted facet and level names. Other slopes, locations and steps are
  reoptimized while the population and identification constraints remain fixed.
  Saved results retain owner identity, numerical checks, unresolved endpoints,
  the same-target Wald comparison and profile plots/reports/exports. This is
  an experimental local likelihood-ratio interval; better coverage is not
  established. No default estimator or interval method changes.
  Profile calculations are faster and more reliable when starting estimates
  differ substantially. After an inaccurate outward trial, the search can
  find an endpoint closer to the fitted slope, while retaining the failed
  trial in tables and plots. Failures inside the interval search still leave
  the affected endpoint unavailable. Numerical accuracy requirements are
  unchanged; profiles remain optional sensitivity analyses, not a routine
  replacement for Wald intervals.
  A failed optimization can also retry with rescaled search coordinates when
  a small slope makes other coefficients difficult to estimate. The same
  model, parameter constraints and numerical checks apply; unsuccessful
  searches still leave the affected endpoint unavailable.

* Two-family MML--EM more reliably reaches the accuracy requested by
  `em_score_tol` when an M step stops too early. Accepted steps still preserve
  likelihood ascent, and `fit$opt$em_trace` records convergence and numerical
  difficulties. Improved numerical convergence does not guarantee reliable
  confidence intervals, particularly when slopes are poorly determined.

* Two-family GPCM MML--EM fits now connect to `mfrm_response_diagnostics()`.
  The existing response model integrates each Person's ability posterior while
  holding both slope families, locations and steps fixed. Original observed
  assignments and row identities are retained; selecting rows does not shorten
  the conditioning record. Category probabilities, expected scores, mixture
  variances and descriptive Infit/Outfit receive row-level integration checks.
  Unresolved rows remain visible and are not silently excluded from groups.
  Saved results support paired/scatter plots, ggplot conversion, reports and
  exports without refitting. There is no expectation-one reference, automatic
  fit cutoff, formal fit test or calibration-uncertainty propagation.

* Corrected shared-owner GPCM JML now connects to `predict_mfrm_units()` and
  the portable calibration lifecycle. New-Person EAP uses the corrected point
  calibration and a separate normal reference prior. File format 5 preserves
  the explicit correction order, assignment-sampling assumption and fresh
  adjusted-equation/root checks, without training responses or Person
  estimates. It does not apply ordinary JML likelihood checks to a corrected
  root. Covariance failure does not suppress a valid calibration. Score tables,
  summaries and portable score plots retain the experimental estimator and
  conditional uncertainty; residual calibration bias may remain. Structural
  intervals and corrected Person ML/WLE are not added. Formats 1–4 retain their
  existing meaning, and every score batch still receives integration checks.

* `mfrm_response_diagnostics()` now supports corrected GPCM JML. It uses
  saved corrected calibration and reprofiled Person abilities to compute
  conditional probabilities, expected scores, variances and descriptive
  residuals on observed rows. It performs no posterior integration and
  excludes calibration/Person estimation uncertainty. Extreme-score
  probabilities remain available when zero variance makes standardization
  undefined. Infit is retained when its aggregate ratio is defined, even if
  Outfit is unavailable; no rows are silently dropped. Paired/scatter plots,
  ggplot conversion, results, reports and saved exports preserve this
  distinction without cutoffs or rater-quality flags. Saved attachments
  must match the slopes, Person profiles and exact fitted roster.

* `fit_mfrm()` adds an explicit, experimental `jml_correction_order` for
  shared-owner GPCM JML with centered fixed facets and observed unit-weight
  ratings. It solves a profile-score-adjusted equation and retains numerical
  attempts, unresolved roots, point estimates and covariance failures
  separately. `RootSE` describes local adjusted-equation variation; residual
  structural bias may remain, and no confidence limits are supplied. Summary,
  point/distribution plots, ggplot conversion, results, reports and saved
  exports preserve this interpretation. Unsupported ordinary diagnostics,
  likelihood comparison are refused; conditional post-hoc EAP and portable
  scoring use the distinct corrected-equation checks described above. The default MML
  and uncorrected JML calls are unchanged; correction order is not selected
  automatically. Help and the scope guide explain the sampling assumptions,
  supported assignments and remaining inferential limits.

* `mml_quadrature_sensitivity()` and its GPCM entry point now support two
  slope families with fixed-grid MML--EM. Refits preserve owner order,
  the score ladder and EM controls; comparisons use both slopes in category
  probabilities and full joint information for raw diagnostic SEs. Saved
  component intervals retain their numerical checks and connect to existing
  plots and tables. Person-score comparisons are explicitly unavailable. Adaptive
  direct refits and fixed-calibration integration comparisons are now supported
  as described above. No fixed
  number of integration points is sufficient for every dataset; compare
  estimates and intervals across grids before interpreting sensitive results.

* Two-family slope intervals now retain a warning for a small optimization
  residual instead of automatically withholding every interval. The
  standardized Newton displacement must be at most 0.01; values above 1e-4
  carry the additional caution and remain visible in saved numerical checks,
  plots and reports. The fit, estimates and EM stopping rule are unchanged.
  Mean-score, information, local-rank and quadrature checks still apply.
  This numerical approximation does not establish sampling coverage.
  Sparse assignments can leave slopes poorly determined even when numerical
  checks pass. Bias and underestimated uncertainty remain possible.

* `fit_mfrm()` now accepts an ordered pair of slope facets for a provisional
  two-family GPCM MML--EM route. It requires explicit fixed-standard-normal
  identification, exactly two facets, second-owner steps, unit weights and no
  anchors or population covariates. The first family's slopes have geometric
  mean one; the second is free on the fixed ability scale. Original facet
  names and owner-level identities are retained. `em_score_tol` controls the
  marginal-score stopping rule per Person; unsupported options are rejected.
  Summary and conditional probability/information curves connect to plots,
  saved results, reports and exports. These curves have no calibration
  intervals. Ordinary diagnostics, Wright/Pathway maps, other parameter intervals,
  and model ranking remain unavailable. Conditional new-Person and portable
  scoring are provided by the later extensions described above. The
  capability table and workflow guide distinguish this scope from one-family
  GPCM. Existing single-family defaults and EM-to-direct fallback are unchanged.

* `confint()` now offers explicitly experimental component-slope intervals for
  the two-family fixed-standard-normal MML--EM model. Full joint marginal
  information includes nuisance parameters and cross-family covariance.
  Source, local score rank, stationarity and higher-order quadrature checks
  are retained through plots, tables, reports and exports. Failed checks keep
  estimates with missing bounds and reasons. Both families retain their own
  scale reference; no unit-slope p-values or automatic rater-quality decisions
  are supplied. The default scale for two families is `"standardized"` (SD fixed
  at one). One-family defaults are unchanged. These numerical checks do not
  establish global identification, boundary absence or sampling coverage.

* Summary help now distinguishes slope owners, primary estimates and numerical
  optimizer values, and explains why a scale constraint alone does not establish
  inferential reliability. It identifies the fields for the actual MML engine,
  iteration count and numerical stopping rule. Corrected JML now has the
  explicit experimental workflow above; its formal structural intervals remain
  unavailable.

* `as_ggplot()` now converts residual-PCA scree, reference, excess and loading
  plots explicitly. Previously, reference plots could become unrelated bars
  through generic column guessing. Conversions retain the saved numerical
  values, styles and replay data; incomplete payloads fail clearly. Base
  reference plots now show a legend. Summaries and reference plots explain
  that scanning componentwise cutoffs does not control the chance of any false
  flag, and bootstrap status distinguishes unavailable observed PCA from a
  failed refit.

* Residual PCA from a fitted object now skips unrelated marginal-fit tables,
  reducing repeated diagnostic work during the model bootstrap while preserving
  observation residuals and PCA results. The visual guide now distinguishes
  shared-Person links from fixed parameter anchors, explains why a connected
  sparse design can still lack usable residual correlations, and describes
  when testlet and correlated-trait interpretations yield the same ratings.

* `analyze_residual_pca()` adds `parallel_method = "model_bootstrap"` for
  RSM/PCM MML fits with fixed standard-normal population, fixed quadrature,
  additive facets, unit weights and no anchors or shrinkage. Ratings are
  regenerated on the retained assignment and the model is refitted once per
  replicate for all requested PCA scopes. Every attempt and warning is saved;
  an affected comparison is unavailable if any replicate fails. Existing
  summary, scree/excess plots and ggplot conversion distinguish this reference
  from the unchanged default residual permutation. Both remain exploratory,
  without calibrated dimensionality decisions or multiplicity adjustment.

* The visual diagnostics guide and residual-PCA/Q3 help now explain how to
  examine a one-ability assumption before fitting a multidimensional model.
  They distinguish current exploratory screens from model-generated reference
  tests and residual-network/EGA methods, clarify sparse-overlap and
  community-count interpretation, and identify external comparison requirements.
  No calibrated dimensionality test or residual-network estimator is added.

* Testlet result/report exports now retain the complete saved scoring roster,
  including explicitly omitted responses and original column names, alongside
  observed block counts. Testlet scores and random-rater probability predictions
  also record effect-sharing and integration meanings in their settings;
  observed-rater conditional distributions remain distinct from new-rater
  population predictions. Older saved scores without a roster remain readable.

* GPCM, testlet and random-rater help now distinguish discrimination from local
  dependence and identify which ratings share a latent effect. The guide
  explains performance versus rating-occasion blocks, observed/new-effect
  prediction and why local variance does not by itself establish halo or
  equal task weights. Existing model availability is unchanged.

* The GPCM guide and workflow help now explain proposed two-slope applications
  for task review and assessor feedback, with speaking, music and clinical
  assessment examples. They distinguish response models from MML/JML estimation
  and EM/direct optimization, and explain why the former "bounded GPCM" label
  should be replaced by explicit structural and output restrictions. The
  provisional two-family workflow above has its own narrower output scope.

* The GPCM guide clarifies ability-SD changes, scale identification and the
  difference between common rated performances and fixed parameter anchors.
  Multivariate D-study plot help explains when to use 2D comparisons, why SEM
  is not a confidence band, and why a higher G/Phi in a more heterogeneous
  population need not mean lower measurement error. Existing plot methods
  and model availability are unchanged.

* GPCM predictions and probability-based diagnostics now share the conditional
  probability calculation used by likelihood evaluation. Full category log
  probabilities are retained directly, including when an extremely small
  probability rounds to zero.
  Curve interval results now retain a `contexts` table identifying predictions
  for combinations of known facet levels not observed together in the retained
  rating data. Printed output, default plot captions and report tables preserve
  this distinction; it does not certify interval reliability.

* The GPCM guide explains how MML--EM can estimate task and rater slopes
  together and why the response equations of `sirt::rm.facets()` and the
  Uto--Ueno model generally differ. The provisional two-family `fit_mfrm()`
  route uses the whole-predictor slope product; this does not establish
  free-estimator equivalence with sirt.
  For the two-family formulation, it distinguishes the task-family geometric
  reference from free rater slopes: a rater slope of one does not mean the
  average rater or provide a competence threshold.
  Facet names are distinguished from model roles: example labels such as
  Task/Rater are not mandatory column names, and labels alone do not determine
  the slope reference or step owner.
  The guide also connects Wang and Liu's latent-regression formulation to
  `population_formula` and distinguishes ability-dependent response sensitivity,
  information and external scoring accuracy when interpreting rater feedback.
  It explains why complete task-rater crossings alone do not establish
  identification of two slope families when persons contribute too few ratings.
  The GPCM and workflow guides also distinguish multivariate observed-score
  G/D studies from multiple GPCM slopes, with literature on complementary and
  joint IRT/G-theory approaches. No automatic conversion or joint fitter is added.

* The linking guide now starts with assignment checks before fitting and
  distinguishes common-person links from fixed parameter anchors. Runnable
  examples cover common persons, rotating subsets and random subsets, with
  task-specific skeletons explained separately. The workflow guide clarifies
  that MML is a default rather than an automatically selected estimator.
  The GPCM explanation uses separate slope-owner and step-owner indices to
  match the supported MML model. Estimation behavior is unchanged.

* `analyze_facet_equivalence()` now marks fixed locations explicitly and omits
  their marginal intervals. Contrasts with estimated levels and deviations
  from the estimated facet mean retain their covariance-based uncertainty.
  Matching diagnostics with fixed-value labels now give the same results as
  the direct fit route. This also fixes an MML path that could still display
  a zero-width interval for an anchor after the general diagnostic repair.

* `fit_measures_table()` now carries SE methods and interval interpretation
  through its report tables, summaries and table exports. JML normal bands
  retain their exploratory status; missing provenance in older inputs is
  explicit. The `measure_ci` plot preserves these labels when changing the
  interval level and displays finite fixed/no-interval estimates instead of
  dropping them. Captions can be hidden with `show_notes = FALSE` while their
  explanation remains in saved plot data. Estimation and SE formulas are unchanged.

* Diagnostic tables now identify location values fixed by anchors or
  identification constraints. Such values no longer receive exploratory JML
  SEs or zero-width MML confidence intervals. Sampling SEs and intervals are
  marked not applicable, including attached diagnostics, reports and Wright
  maps. Facet reliability/separation and variability tests involving fixed
  values are unavailable; free-level SEs and response-fit statistics remain
  available. Supplied-anchor uncertainty is not estimated.

* Category variance now uses centered moments in information curves, curve
  intervals, response diagnostics, posterior category summaries and the
  shared-rater/testlet derivative calculations. The R and compiled posterior
  paths agree. This fixes cancellation that could turn small positive upper-tail
  information into zero and disagree with summed category information.
  Existing diagnostic variance thresholds and inference eligibility rules remain
  unchanged; this numerical repair is not a new interval-coverage guarantee.

* JML estimation help corrects the displayed facet/location SE formula to
  include observation weights and squared GPCM slopes, matching the existing
  calculation. It distinguishes exploratory SEs, local curvature checks for
  portable scoring, and formal inference, with a binary Rasch reference for
  the incidental-parameter limitation. Estimates and SE calculations are
  unchanged; formal JML slope intervals remain unavailable. The help also
  explains why applying a common item-bias multiplier to all relative GPCM
  slopes cannot correct their ratios.

* Calibration and prediction help now distinguish the literature basis for
  fixed-calibration EAP from checks of numerical accuracy and
  JML estimation. Fixed-score agreement with external software does not imply
  matching free estimators, calibration bias or interval coverage. The
  `quadrature_review` help now specifies that its RSM/PCM requirement applies
  to MML, not JML.

* Shared-owner GPCM JML now supports conditional fitted-object and portable
  EAP scoring with a post-hoc reference prior (file format 4). Fresh joint
  likelihood, gradient and unregularized full-curvature checks are separate
  from the retained global audits. Known Person/additive/slope boundary
  certificates prevent automatic scoring even when optimizer traces and local
  curvature are finite. Incomplete global audits stay labelled as incomplete
  through saved artifacts and score summaries. Unit weights and no anchors or
  interactions are required. This does not supply formal JML slope intervals,
  global-optimum or calibration-bias guarantees. Frozen scoring reuses the
  existing kernel and does not repeat source curvature calculations.

* RSM/PCM JML now supports the existing portable calibration lifecycle, using
  file format 3 and a post-hoc standard-normal reference prior. Extraction
  requires a finite identified source, unit weights, no anchors/interactions,
  and passing fresh joint-likelihood/gradient checks. Each new batch checks
  EAP/SD integration; summaries retain source evidence and distinguish the
  reference prior from a distribution estimated by JML. Explicit scoring-prior
  sensitivity remains available. JML calibration bias and uncertainty are not
  included in posterior intervals. Formal JML slope inference remains
  unavailable. Existing MML file formats are unchanged.

* Portable score summaries distinguish checks on the reported EAP/SD from
  comparisons of alternative integration grids. With adaptive scoring, the
  fixed grid in the comparison is explicitly identified as unused for the
  reported scores. The GPCM tutorial now connects calibration, a fresh scoring
  session, prior sensitivity and saved score/review tables, including people
  without valid responses. Score plots state how many people have no score;
  their zero reference is labelled as the scale origin, rather than assuming
  it equals an estimated or explicitly changed prior mean.

* `confint()` now offers experimental `method = "profile"` for one explicitly
  named GPCM relative `slope`. Nuisance calibration and population parameters
  are reoptimized under the sum-zero log-slope constraint. Two-start, gradient
  and integration checks preserve unresolved endpoints; a finite search limit
  is not labelled an infinite confidence bound. Shared and separate owners
  are supported within the estimated-normal, unit-weight scope without anchors
  or interactions. Saved curves, Wald comparisons and numerical records connect
  to `plot(..., type = "profile")`, ggplot conversion, tables and reports without
  refitting. Model/sandwich defaults are unchanged. Profile coverage, global
  optimality and superiority over Wald are not established. A small-sample
  saved-fit comparison found substantially lower profile interval availability;
  the method remains for explicitly requested sensitivity analysis, not a
  routine replacement for Wald intervals.

* Portable GPCM MML calibration now uses the existing extract/validate/freeze/
  save/load/score API. It retains both slope/step owners, one relative-slope
  family, an estimated intercept-only normal prior and passing conditional
  source-check evidence. Unit weights and no anchors/interactions are required.
  Shared and separate owners are supported. Replay validates the stored source
  evidence without refitting; each batch must pass numerical scoring checks.
  Failed integration stops instead of returning review-only numerical scores.
  `score_mfrm_calibration()` also accepts an explicit common normal scoring
  prior for current artifacts, preserving original and actual priors through
  summaries and plot data. Existing RSM/PCM default artifact semantics remain
  unchanged. These are conditional posterior scores, not a global-maximum,
  population-transport or interval-coverage guarantee.

* `predict_mfrm_units()` and `sample_mfrm_plausible_values()` now accept
  `scoring_prior = list(mean = ..., sd = ...)` for sensitivity to a common
  normal scoring prior. For MML the default retains the fitted prior; JML uses
  a post-hoc standard-normal reference prior. The calibration
  stays fixed, its source checks remain in force, and numerical checks use the
  specified prior. Original and scoring prior values remain unrounded through
  estimates, summaries, draws and exports. Background-covariate population
  overrides are refused. Help includes a plot comparing identical response
  patterns under two priors; this does not establish a new cohort's distribution
  or estimate its distribution.

* Fitted-object scoring now distinguishes local calibration eligibility from
  global inference readiness. GPCM MML and intercept-only normal population
  models can return conditional scores after fresh likelihood, gradient,
  unregularized-information and integration checks. Per-person checks compare
  reported EAP/SD with adaptive references; unresolved scores require explicit
  review and retain their labels through summaries, draws and exports. Invalid
  calibrations or inconsistent stored priors cannot be enabled by review.
  Unevaluated boundary audits are labelled as unevaluated. These changes do not
  validate a prior for a new cohort.
  The scoring help explains the retained-prior default for a later cohort,
  distinguishes prior sensitivity from recalibration, and clarifies why a
  narrower interval from a narrower prior is not additional rating evidence.

* Adaptive MML fitting now rejects numerically unevaluable trial values,
  including overflow with finite GPCM slopes, so the optimizer can shorten
  its step. Failed evaluations cannot reuse an earlier likelihood from the
  cache. Invalid starting values still fail explicitly, and final convergence
  checks remain unchanged; this does not impose an upper discrimination limit
  or establish that a fitted model has a finite global maximum.

* Ordinary fitted-model plots now accept named `level` as an alternative to
  `ci_level`, also through results and ggplot entry points. Previously `level`
  could be silently ignored. Supplying both names is an error; the default
  remains 0.95 and old positional calls retain their meanings. Saved interval
  results retain their original confidence level.

* Conversion of saved core plot payloads now rejects unsupported settings
  instead of silently ignoring them, including attempted title or interval
  changes. All saved plot-data views also reject a new `type`, including
  extended-model and D-study converters. Create a new payload from the fit/result to change plot settings,
  or use ggplot label controls after conversion. Complete CCC views retain
  their documented conversion-specific appearance options.

* The reporting guide now starts from saved results, figures, reports and
  analyst archives, with specialist manuscript tools described separately.
  The fixed-rater tutorial explains report-purpose and output-format defaults,
  explicitly selects a saved interval for recipient sheets, and demonstrates
  exporting and reopening an analysis without recalculating its intervals.
  Export presets select files; plotting presets select appearance.

* GPCM MML now allows different slope and step facets, for example criterion
  discrimination with rater-specific category steps. One slope family retains
  geometric-mean-one identification and multiplies the entire adjacent-category
  predictor. Fitted-object scoring, information, eligible slope/curve intervals,
  matched PCM comparison, same-design bootstrap, and saved results preserve both
  owners. CCC and expected-score pathway plots show labeled step/slope pairs;
  single-facet fit flags are not assigned to those joint profiles. JML, weighting
  reviews and simulation/design workflows still require a shared owner. This
  extension does not establish finite-sample coverage or provide simultaneous
  criterion/rater slope families.

* Random-rater interval help now explains why increasing bootstrap size alone
  cannot resolve unbounded limits: at 95% with 499 planned draws, 13 unresolved
  studentized errors for a rater make both endpoints infinite. This describes
  the existing failure-preserving rule, not a new acceptable-failure threshold
  or a coverage guarantee.

* Random-rater bootstrap trial records now retain the optimizer code,
  numerical/information checks, Person quadrature orders and discrepancies,
  and separate variance-boundary checks. Missing check values remain missing
  when a refit fails. These records carry through existing result tables,
  reports and exports, helping distinguish numerical problems from interval
  performance. Interval formulas, eligibility rules and saved older results
  are unchanged; additional historical checks cannot be reconstructed by
  reopening an old result.

* The feedback and external-feature tutorials now show how to save and reopen
  analyses and retain a reviewed HTML sheet. They distinguish the recipient's
  standalone sheet from analyst archives, and a single-completion PCA view
  from the full imputed analysis. Saved results reuse their original estimates
  and display choices; reopening does not update them for new data.

* `as_ggplot()` now converts pooled fixed-facet multiple-imputation intervals.
  It uses saved t-interval endpoints, preserving target order, contrasts,
  degrees of freedom and complete-data information cautions. Fixed targets
  have no inferential interval; missing intervals use crosses and infinite
  bounds use arrows. Default and explicit table conversion retain the full
  view, without refitting, repooling or recalculating confidence limits.

* `as_ggplot()` now converts silhouette and numeric/categorical feature-profile
  views. Silhouettes preserve negative widths, saved order and the overall
  mean line. Numeric profiles retain original-unit means, medians and counts,
  with separate symbols and small vertical offsets. Categorical profiles retain
  group counts, unused levels and original level order on a fixed proportion
  scale. Default and explicit table conversion preserve the complete view;
  source data remain extractable. No groups or intervals are estimated.

* `as_ggplot()` now converts imputation co-membership heatmaps with the saved
  ID order, all-imputation fractions and a fixed zero-to-one scale. Grey fill
  plus crosses distinguish unavailable pairs from zero. Default and explicit
  `component = "matrix"` retain the same view; imputation count, exclusions,
  selected IDs and source values remain available through `plot_data()`.
  Selecting IDs or hiding labels does not renormalize or sample values.

* `as_ggplot()` now converts saved external-feature dendrograms. Merge heights,
  leaf order, requested group boxes and label settings are retained, including
  tied-height cuts and excluded-ID records. The default and `component = "tree"`
  use the same complete view. No clustering or partition is recomputed;
  heights do not measure significance or branch support.

* `as_ggplot()` now converts external-feature PCA scree, scores and loadings
  views using saved components, group colours/shapes and label settings.
  Scree plots distinguish retained components, scores keep equal axis units,
  and loadings keep feature order and the zero reference. The default and
  `component = "table"` use the same dedicated view; transformation metadata
  and excluded IDs remain available through `plot_data()`. No PCA or grouping
  is refitted.

* `options(mfrmr.plot_preset = "publication")` now sets the session default
  for plots using the common preset controls. Explicit call settings take
  precedence; removing the option restores `"standard"`. Supported conversions
  of saved plot payloads retain their saved preset when the option changes.
  Plots with separate palette controls keep their own settings. Estimates,
  intervals, screening thresholds and the global ggplot theme are unchanged.

* Bubble-chart ggplot conversion now uses saved circle radii, facet colours
  and facet order instead of equal-sized points and a new default palette.
  The native bubble plot also honours the monochrome preset; explicit palette
  overrides remain supported. Relative radii and reference lines are retained,
  while physical sizes can differ between base graphics and ggplot.

* Eight plotting functions now accept `title` alongside the supported
  legacy `main` spelling: marginal fit/pairwise, unexpected responses,
  interrater agreement, facet chi-square, bubble, bias interaction and facet
  dashboard plots. `title = NULL` suppresses the heading; omission and legacy
  `main = NULL` retain the default. Supplying both names is an error. Existing
  positional calls, numerical data, screening settings and interpretation
  notes remain unchanged. See `?mfrmr_visual_diagnostics` for the exact routes.

* `mfrm_report(..., style = "rater")` now prepares an individual feedback
  sheet from saved native additive RSM/PCM results. HTML includes category-use
  bars, numerical tables and print styling; plain-language and researcher
  presentations share the same selected values. Missing diagnostics and
  individual intervals are explained without new calculations. All four
  output formats omit the source fit and source identifiers. Rater selection
  and ambiguous interval choices are explicit; fit statistics do not trigger
  automatic quality labels or exclusion.

* The visual-diagnostics tutorial now offers six linked figure previews with
  accessible labels, executed examples and data-extraction code. The gallery
  uses the plot guide for purposes and ggplot support, including a new subset
  coverage route. Coverage help distinguishes relative observed facet-level
  counts from completion of planned assignments. External-feature trees and
  composite D-study planning have compact examples with interpretation limits.

* `mfrmr_output_guide("plots")` now maps selected figure purposes to result
  classes, plot calls, reusable data and ggplot routes. It distinguishes
  dedicated converters, plots that already return ggplot, generic table views
  and unavailable conversions with alternatives. Existing guide scopes retain
  their table format. This adds guidance; estimators and renderers are unchanged.

# mfrmr 0.2.4

Unreleased release candidate. This version combines reusable calibration and
new-Person scoring, external-feature clustering and multivariate G/D-studies,
with corrections to uncertainty, subgroup comparisons and design planning.

## Getting started

* Results now reject unsupported prediction attachments before routing interval
  inputs. An incomplete fit object receives an explanatory input error instead
  of an internal missing-logical-value error. Valid fitted analyses and their
  numerical results are unchanged.

* GPCM bootstrap output now preserves recorded selected-refit history in
  interval cautions, printed output and reporting tables. An assembled
  reanalysis is no longer displayed as though it were a complete rerun under
  one procedure. Saved draws, interval values and acceptance decisions are
  unchanged. The GPCM guide distinguishes the evidence for each inference
  target and retains the adverse probability-coverage findings; bootstrap
  coverage and a general finite-sample guarantee remain unestablished.

* The GPCM guide now reports a reanalysis of 800 saved fits for standardized
  slope differences, category probabilities and per-rating information.
  Probability intervals showed undercoverage in small incomplete designs,
  including Bonferroni-adjusted grid families. Refitting all 100 datasets in
  one affected condition with the updated optimizer left every parameter and
  interval endpoint unchanged; these are matched reanalyses, not additional
  independent replications. Curve printing and default figure subtitles now
  explicitly identify approximate intervals. Help distinguishes numerical
  availability from nominal coverage and historical fitted estimates from a
  new evaluation of the current estimator. These findings do not change the
  interval formulas or remove the APIs.

* Ordinary result summaries and report decisions now use the saved diagnostic
  precision assessment instead of describing it as unevaluated. Reports also
  retain that assessment when a separate precision-review section was not
  requested. Missing assessments remain unreviewed, and a positive assessment
  cannot override restrictions on the source fit. No estimates, intervals or
  eligibility rules change.
  The introductory workflow now uses explicit rubric bounds and
  `category_policy = "preserve"`, demonstrates reopening saved results, explains
  session-dependent screening bands, and links rater differences, missing-score
  imputation, external-feature groups and observed-score G/D planning to their
  dedicated workflows.

* GPCM curve plots now mark estimates with unavailable intervals using crosses
  and report their count in a caption. Ribbons stop at unavailable grid points.
  Long numerical cautions wrap within the default figure. `caption = NULL`
  removes the caption while retaining markers and saved failure reasons.
  The plotting guide explains how to use a logarithmic axis for very wide
  positive slope/ratio intervals; interval calculations are unchanged.
  Markdown report summaries now retain GPCM interval counts (finite,
  unbounded and unavailable) and saved inference cautions/reasons, matching
  the information already retained in result tables.

* MML information calculations now distinguish poor conditioning from an
  unusable inverse. Positive ill-conditioned information receives two levels of
  numerical refinement and checks of curvature stability, unregularized
  inversion and the curvature-scaled gradient. A verified inverse can support
  GPCM intervals and local IC/bootstrap checks with an explicit caution;
  failed verification leaves inference unavailable. No eigenvalue floor is
  used for the accepted inverse. This common MML calculation also applies to
  RSM/PCM. Weak information can still produce extremely wide or unreliable
  intervals. Cautions follow slope/curve intervals, plots, tables and reports;
  bootstrap checks retain refinement diagnostics. The existing information
  workspace budget also checks the additional refinement allocation.

* Fixed-facet intervals, practical-equivalence analyses and pooled imputation
  results now retain weak-information cautions when a numerically verified
  inverse is used. Warnings remain with tables, saved results and plot data;
  fixed-facet reports also retain the numerical review. Pooling identifies the
  affected imputations and never discards a failed completion. These warnings
  do not change point estimates, covariance formulas or eligibility criteria.
  Pooled plots now accept optional `title` and `subtitle`, including `NULL`;
  hiding plot text does not remove the saved caution. Quadrature reviews also
  retain the covariance calculation's explanation alongside its status.

* Small fixed-grid GPCM MML fits now review negative numerical curvature even
  after a small terminal gradient. Up to three BFGS restarts can rescale the
  search coordinates to recover a better finite solution; failed recovery
  retains the original estimate with a numerical warning. The complete stage
  history records curvature and any review error. This does not regularize the
  information matrix. Retained solutions undergo separate interval,
  information-criterion and bootstrap checks. Quadrature accuracy remains a
  separate requirement.

* GPCM bootstrap checks now retain the population SD and the minimum/maximum
  population-SD-standardized optimizer slopes, without additional fitting or
  information calculations. These diagnostics help separate changes in scale,
  near-zero discrimination and category-support problems. Help explains why
  stable slopes do not establish finite thresholds or valid Wald intervals.
  APA check tables preserve small scale, slope, gradient and information
  values using significant digits, including in HTML/LaTeX table conversion,
  instead of displaying a small positive value as zero. Raw checks stay numeric.
  The additional diagnostics do not change replicate admission or certify
  a boundary solution.

* GPCM bootstrap results now distinguish refit errors from returned estimates
  withheld by eligibility checks. `trials` records the last stage and which
  model fits returned; `checks` retains category support, numerical status and
  already-computed information diagnostics. `refit_draws` saves returned
  alternative-model parameters for diagnosis, including rejected estimates;
  these are never substituted for accepted `draws` in confidence intervals.
  Saved checks connect to APA tables, reports and exports.
  A confirmed singleton-only category warning no longer excludes a GPCM
  point estimate from basic slope bootstrapping when the remaining identity,
  convergence and unregularized-information checks pass. The source fit uses
  the same rule. `BootstrapEligible` and `WaldEligible` remain separate;
  cautions persist in intervals, printed output, default plot subtitles and
  reports. Wald, IC and LRT rules are unchanged. This does not establish
  finite-sample coverage or admit singular-information estimates.

* Results with attached inference now show complete-result save/reload code
  in summaries and HTML. This prevents the displayed reproduction route from
  omitting saved RSM/PCM intervals, GPCM inference or posterior diagnostics.
  Exported replay continues to reload the saved RDS. Starter export indexes
  now show saved RSM/PCM and GPCM inference figures with descriptions, keeping
  their targets separate from ordinary Wright/Pathway uncertainty.

* Saved RSM/PCM fixed-facet intervals now connect to `apa_table()`,
  `mfrm_results(intervals = ...)`, reports and exports. Named results have
  `facet_` plot routes. Source matching checks the fitted data, parameters,
  constraints, population and integration settings; replay reloads saved
  results without refitting or recomputing covariance. Method, confidence
  level, contrast coefficients, cluster mapping and unavailable outcomes
  remain available. `as_ggplot()` supports the same interval comparisons,
  with line types and offsets as well as color. Titles, subtitles, captions,
  reference lines and legends are optional; noninteger confidence levels are
  displayed without rounding to a different level. The estimator and interval
  calculations are unchanged, and ordinary Wright/Pathway displays retain
  their own uncertainty and fit meanings.

* Fixed-grid GPCM response-pattern checks now reuse cumulative category
  probabilities within each rating design and parameter vector. All response
  patterns, posterior weights and information checks are retained; the point
  estimator and default interval calculation are unchanged. Adaptive nodes
  are excluded from this reuse.

* Saved GPCM slope/curve intervals and bootstrap results now connect to
  `apa_table()`, `mfrm_results(intervals = ...)`, reports and exports.
  `plot()`, `as_ggplot()` and `plot_data()` preserve the selected target,
  method, level and multiplicity adjustment. Plots retain unavailable and
  unbounded outcomes, use non-color cues, and allow titles/annotations to be
  removed. Named saved results provide matching result-plot routes. Exact
  fitted-source matching prevents mixing analyses; export replay reloads
  the saved results without refitting. These displays supplement location
  and fit diagnostics and do not classify raters or select scoring weights.

* GPCM help now relates the fitted model and inference targets to ConQuest and
  TAM, including TAM's documented many-facet slope construction. It explains
  why shared additive rater effects need not match mfrmr's slope-scaled rater
  effects, and why standardized-slope uncertainty needs a joint covariance
  transformation. Existing item-only numerical comparisons are distinguished
  from unverified interval comparisons and public import/export support.
* `confint(fit, parm = "slopes", level = 0.95)` supplies approximate pointwise
  relative-slope intervals for eligible GPCM MML solutions. `diagnose_mfrm()`
  uses the same joint-information log-Wald calculation; attached diagnostics
  carry its decision into the fit and weighting-review slope tables. Current
  likelihood, gradient, category, integration and unregularized-information
  checks replace the blanket interval restriction. Missing bounds retain
  reasons. The default retains geometric-mean-one relative slopes. Explicit
  options provide population-SD-standardized slopes, named ratios/differences
  with Wald tests, Bonferroni adjustment, and Person or larger independent-cluster
  sandwich covariance. Standardized intervals include scale cross-covariances;
  sandwich intervals do not repair bias or informative rating assignment.
* `bootstrap_mfrm_gpcm()` simulates independent Persons and scores under the
  fitted population on the analyzed assignment. Saved draws support basic
  bootstrap slope intervals; a matched PCM null instead supplies a bootstrap
  LRT. Every planned refit, warning and failure remains in the result. Unresolved
  draws widen interval limits and bound p-values rather than being discarded.
  Small-sample accuracy and misspecification robustness are not guaranteed.
* `mfrm_curve_intervals()` supplies logit/log delta intervals for category
  probabilities and per-rating information at specified ability values. Plots
  use lines and ribbons, color plus line types, and optional titles/notes.
  Bonferroni adjustment covers the requested grid, not a continuous band.
* IC/LRT and slope intervals now share the joint information calculation and
  a configurable dense-matrix workspace budget, replacing the IC/LRT-specific
  80-coordinate cutoff. `mml_quadrature_sensitivity()` preserves explicit
  population formulas, covariates and coding, and reports changes in slope
  interval endpoints and availability. A workspace estimate is not a total
  memory or capacity guarantee.

* `compare_mfrm(..., nested = TRUE)` now provides a PCM/GPCM equal-slope
  likelihood-ratio test for eligible MML pairs. It verifies the same population
  design, step/facet constraints and interactions, G-1 relative slope contrasts,
  and regular numerical solutions. The ordinary chi-square reference is
  asymptotic. Incompatible settings, non-unit weights, unstable solutions and
  negative likelihood gains retain explicit reasons instead of a p-value.
  `build_weighting_review(..., nested = TRUE)` carries the same test and status;
  its default remains `FALSE`. Slope intervals use their own checks.
* `compare_mfrm()` now separates GPCM MML information-criterion comparison
  from slope-interval eligibility. It reevaluates the retained likelihood,
  gradient and unregularized local information, while preserving the existing
  data, likelihood, parameter-count and integration checks. `ICFitEligible`
  and `ICFitReview` explain the solution decision; `ICComparable` controls
  deltas, weights and preferred candidates. Weighting/model-choice reviews
  retain that decision. These local checks do not prove global optimality or
  enable slope intervals or establish the nesting required by a likelihood-ratio test.
* User-facing model names, messages and help now use "GPCM" instead of
  "bounded GPCM". The single slope/step facet and each unavailable operation
  are described separately. The GPCM guide distinguishes slope intervals,
  information-criterion comparison and the PCM/GPCM likelihood-ratio test,
  including their distinct eligibility conditions. Unidimensionality is not a reason
  to prohibit these methods, and unit slopes are not a boundary null.
  The terminology change itself does not alter statistical eligibility.
* `mfrmr_output_guide("feedback")` now connects rater-feedback questions to
  fixed-facet intervals, ordinary or extended-model residual review,
  shared-rater uncertainty and known-truth screening evaluation. Each route
  identifies its required inputs, follow-up tables/plots and interpretation
  limits. This adds guidance for existing functions, not a new estimator or
  a rater-quality classification rule.
* The package description and MML tutorial now state the GPCM slope/step
  structure and its separate inference limits.
* GPCM diagnostics no longer treat missing or outdated slope-eligibility
  records as permission to report ordinary SEs or confidence intervals.
  Local covariance calculations remain in explicitly named `Optimizer*`
  diagnostic columns; regularized covariance does not authorize primary
  slope uncertainty. SE and interval eligibility are checked separately.
  Re-run `diagnose_mfrm()` or `confint()` on saved fits to refresh these tables;
  available slope intervals do not resolve other warnings about the fitted model.
* Use `mfrm_cluster_pam()` for Gower/PAM grouping and
  `review_mfrm_imputations(..., impute_ids = ...)` to check supplied score
  completions. The older `mfrm_cluster()` and `mfrm_response_imputations()`
  calls remain supported with their original arguments. Computations and
  saved-result classes are unchanged; guides, examples and the compatibility
  table identify the recommended names.
* `fit_mfrm()`, `describe_mfrm_data()` and `review_mfrm_anchors()` now accept
  `category_policy = "preserve"` or `"collapse"`. These choices correspond to
  `keep_original = TRUE` and `FALSE`; the default behavior is unchanged.
  Conflicting explicit old/new choices stop. A preserved, unobserved internal
  category still prevents fitting an unsupported step; this option does not
  estimate missing category information. Saved fits retain the existing replay
  representation.
  Data-review overviews and fit settings now report `CategoryPolicy` and
  `ScoreRecoded`, distinguishing the selected rule from actual recoding.
  Older saved results with missing records report an unknown policy or mapping
  rather than infer the choice from the observed categories.
* Fitting help groups arguments by data, rubric, model, computation and output.
  GPCM availability guidance separates its one-facet slope/step structure
  from limits on formal uncertainty and model comparison, without changing
  estimation or statistical eligibility.
* The GPCM tutorial and comparison help describe the separate checks for
  information-criterion ranking, the matched PCM/GPCM likelihood-ratio test
  and relative-slope intervals. A larger quadrature grid alone does not
  qualify any of these outputs. The weighting-review examples retain the
  corresponding output-specific decisions.
* Linking, reporting, workflow and visual-diagnostic tutorial figures now have
  descriptive alternative text, including both response-time views. Source
  archives include executed output and figures for all fifteen tutorials.
* Extended-model help examples now reuse packaged synthetic fits, scores,
  diagnostics and bootstrap results. Summaries, figures and interval-level
  changes run immediately; expensive recomputation calls remain visible as
  comments, with a complete regeneration script. Data, quadrature settings
  and numerical checks are preserved. The 19 bootstrap trials illustrate
  the workflow, not accurate tail quantiles or a coverage guarantee.
* JML help examples that previously stopped after 30 iterations now allow
  sufficient iterations for their example data to converge. Their estimator,
  data and model specification are unchanged; convergence warnings are not
  suppressed.
* ConQuest export help now explains the local command-file workflow and the
  separate controls used for posterior EAP calculations. Bundle guidance no
  longer treats every inference-readiness restriction as optimizer failure;
  numerical comparison remains distinct from validation of standard errors.
* The workflow guide now distinguishes defaults that change the statistical
  analysis from calculation and display controls. The opening example declares
  its rubric bounds, preserved categories and fixed ability population.
  Help clarifies that testlet membership does not automatically add fixed
  difficulty effects, and that an explicit dashboard `misfit_warn` replaces
  both review bounds. Existing defaults are unchanged.
* The workflow guide and README now explain function names and show how to
  choose an analysis from a concrete question. Extended-model scoring guidance
  points to `score_mfrm_persons()` for people already in the fitted model and
  distinguishes the model-specific meanings of `predict()`.
* Help introductions clarify which functions review supplied imputations,
  evaluate simulations, summarize attributes or plan G/D studies. The beginner output guide
  uses plainer questions and no longer describes a particular plot as mandatory.

## Design decisions and saved output

* Plot conversion now refuses unsupported PCA, clustering, pooled-MI,
  fixed-facet interval, screening-performance and D-study difference views
  even when `component` is specified. Previously, that option could silently
  replace the intended axes or intervals with a generic bar chart.
  Multivariate D-study scenario conversion retains its dedicated panels with
  `component = "series"`; use `plot_data()` for other tables and custom graphics.
  Non-supported views give that guidance even when ggplot2 is not installed.
* PCA score plots distinguish groups by both colour and point shape and retain
  the encoding in `plot_data()`. Scree plots distinguish retained and omitted
  components with filled and open points, including monochrome output.
  Tutorial figures now include alternative text describing the plotted target
  and the meaning of intervals, missing results and descriptive groups.
* `mfrmr_output_guide()` now includes `"features"`, `"imputation"` and
  `"gtheory"` routes, distinguishing their dedicated tables, plots and RDS
  saving from the fitted-model `mfrm_results()` reporting workflow.
* Extended-model interval plots and testlet Person scoring now also work in
  R sessions where the stats package is installed but not attached.
* Help for `fit_mfrm_imputed()` and `pool_mfrm_imputed()` now renders function
  links and code formatting correctly.

* Design-evaluation summaries retain full-precision metrics; `digits` now
  controls printing only. Rounding can no longer turn a value just below a
  minimum, or above a maximum, into a passing design recommendation.
  Rebuild older saved summaries from the original evaluation before requesting
  recommendations; no new simulation or model fitting is required.
* The default fit-level archive works without optional prediction objects.
  Predictions are included by default when supplied; explicitly requesting
  them without supplying an object still gives an explanatory error.
* Design-planning help distinguishes generating assumptions from analysis
  settings and explains numerical failures and separation reliability.

## Rater feedback

* Shared-rater and testlet calibration now show point estimates and approximate
  SEs with missing bounds by default. Explicit pointwise normal approximations
  remain available through `confint(fit, parm = "calibration", level = ...)`,
  `summary(fit, calibration_intervals = "normal", level = ...)`, and
  `mfrm_results(fit, calibration_intervals = "normal", calibration_level = ...)`.
  Testlet plots accept `intervals = "normal", level = ...`; common results
  preserve this choice in plots, reports and saved replay. Numerical failures
  and estimated variance boundaries still withhold bounds. This change does
  not improve or qualify finite-sample coverage. Rebuild outputs from older
  saved fits to apply it without refitting; existing result bundles keep their
  stored tables. Population-SD and conditional Person intervals retain their
  separate methods and interpretation.

* Shared-rater fitting help now includes a bounded independent comparison of
  local calibration-likelihood changes using saved joint posterior samples.
  The tested changes met the stated numerical tolerance; this does not qualify
  interval coverage, full population-SD profiles or variance boundaries.
  Extended-model reports and testlet summaries/figures now identify fixed-facet
  and step intervals explicitly as observed-information normal approximations.

* Testlet fitting now selects a converged optimization start when a failed
  start has an indistinguishable objective within floating-point precision.
  Gradient, integration, search-bound and information checks are unchanged.
  A 480-dataset comparison exposed fourteen such failures; all fourteen
  passed targeted refits, while four controls retained identical estimates
  and scores. Refit affected saved models and regenerate their scores;
  printing an older unavailable result does not repair it.
* The testlet tutorial now reports an estimated-population comparison with
  ordinary RSM, including original failures, their separate numerical repair,
  Monte Carlo uncertainty and known-calibration references. Corrected Person
  coverage was 94.4% versus 84.9% with 120 Persons and positive local dependence,
  and 91.7% versus 83.3% with 24 Persons. Testlet EAP mean squared error was
  higher in those two balanced conditions. Conditional intervals retain their
  stated interpretation; neither a universal 95% coverage guarantee nor a
  uniformly more accurate model is established.
* Shared-rater fits now report `checks$PersonQuadratureStable` separately
  from overall numerical readiness. When Person integration is insufficient,
  the warning identifies it and explains refitting with more quadrature
  points; the tutorial gives the corresponding workflow. Integration
  tolerances, default order, estimators and interval restrictions are unchanged.
* Added a testlet application tutorial connecting task/criterion allocation,
  unequal rubric lengths, possible halo and task-specific dependence to the
  existing fit and scoring APIs. A complete four-rating enumeration compares
  model-conditional posterior precision and marginal EAP reliability; a
  five-versus-two-criterion example compares the influence of one-point changes.
  Saved scoring results provide plots, tables and report connections. Help
  distinguishes dependence from halo causation, task difficulty from local
  variance, and likelihood adjustment from equal task weighting. The current
  model still estimates one common local variance; no task-specific variance
  model, general planning API or new coverage claim is introduced.
* Individual shared-rater prediction intervals are no longer supplied
  automatically in fits, summaries, plots or report tables. Point estimates,
  conditional SDs and first-order `PredictionSE` remain available.
  `confint(fit, parm = "raters")` and `plot(fit, intervals = "normal")`
  explicitly inspect the normal approximation without refitting. The
  interval-width view and sorting require that explicit selection. New
  summaries/reports of earlier saved fits follow this default; raw saved
  objects and historical plot payloads retain their values. This restriction
  does not correct coverage or promote bootstrap intervals as a replacement.
  In a prespecified 800-dataset estimated-population study, conditional rater
  coverage was 91.6--91.8% with six raters and 94.0--94.1% with 24; finite
  interval availability was 99% and 87--88%, respectively. None met the joint
  coverage/availability criterion. All optimizers and information checks
  passed, but 53 fits failed higher-order Person quadrature checks, and one
  additional fit estimated zero rater variance. The tutorial reports Monte
  Carlo uncertainty and paired ordinary-MFRM point comparisons. These results
  do not qualify Person/testlet intervals or a minimum rater count.
* `score_mfrm_persons()` scores the complete source roster under ordinary
  RSM MML, testlet or shared-rater calibration, with optional Person selection.
  Ordinary scores use continuous posterior moments and equal-tail endpoints,
  retaining the fitted normal mean/variance. Missing-only Persons remain
  prior-only; zero ability variance does not produce zero-width intervals.
  `compare_mfrm(..., person_scores = ...)` checks matching rosters and compares
  EAPs after population-origin alignment, retaining conditional endpoints and
  unavailable rows without model-difference intervals or automatic ranking.
* Saved extension results support model-aware Wright maps and descriptive
  fit pathways through `type = "wright"` and `"fit_pathway"`. Facet/rater
  positions include the mean step at a zero-other-effect reference; only
  Person conditional intervals are drawn. The fit pathway uses posterior
  residual summaries, with no ordinary fit cutoffs. English labels, shapes,
  monochrome, text alternatives, panel/Person selection and optional
  annotations are available in native and ggplot views. Maps and their tables
  join static reports and saved replay without new scoring. Older testlet
  scores without roster metadata need rescoring from the existing fit.

* `mfrm_response_diagnostics()` now integrates latent uncertainty for ordinary
  RSM MML, testlet and shared-rater fits before computing category probabilities, predictive
  means/variances and descriptive Infit/Outfit. Output selection preserves the
  full conditioning roster; missing or unresolved rows remain explicit.
  Shared-rater predictions use normalized category-specific joint Laplace
  integrals and retain the normalization defect; numerical agreement does not
  certify approximation accuracy. Paired/scatter displays support ggplot,
  distinct symbols, monochrome, text alternatives and optional annotations.
  Saved diagnostics attach to `mfrm_results()` for reports and replay.
  These same-data summaries have no expectation-one reference, cutoffs, ZSTD
  or p-values; ordinary plug-in fit indices are not directly comparable.

* `compare_mfrm()` accepts matching saved `response_diagnostics` for an
  ordinary RSM versus a testlet/shared-rater model. Category probabilities,
  means, full variances and descriptive Infit/Outfit share one definition.
  Selected events are matched by contents and multiplicity, including missing
  scores, rather than row numbers. Paired/difference plots offer metric and
  category selection, monochrome and optional annotations. Saved comparison
  tables and figures connect to reports and replay without recomputation.
  The results are same-data descriptions, with no model preference or fit
  cutoffs. Ordinary plug-in diagnostics retain their existing definition.

* `fit_measures_table()` now uses mean squares for its default directional
  screen. ZSTD values and df comparisons remain visible; `ZSTDOnly` identifies
  additional combined-rule flags. Use `flag_basis = "mnsq_or_zstd"` for the
  earlier combined rule. Missing indices no longer establish a negative
  screen; `ScreenComplete` identifies incomplete rows. Low mean squares are
  described as low residual variability, not poor rater quality or grounds
  for automatic exclusion. Console follow-up prioritizes high mean squares.
  Saved reports identify the actual rule; earlier stored tables retain their
  combined-rule interpretation.
* `mfrm_screening_sensitivity()` compares declared threshold bands on saved
  simulation statistics, separating underfit, overfit and their union. It
  preserves planned trials, unknown outcomes and replication-level Monte
  Carlo intervals. Labelled tile and curve views support ggplot, monochrome
  output, text alternatives and optional titles/notes. ZSTD is an explicit
  alternative rule; no best threshold or universal error guarantee is selected.

* `compare_mfrm()` now accepts one ordinary RSM MML fit and one testlet or
  shared-rater fit for descriptive, matched-event facet comparisons. It checks
  category/population/constraint compatibility and repeated or omitted events,
  centers effects over the same facet levels, and retains raw values and failed
  checks. Paired and mean-versus-difference plots support ggplot conversion,
  custom/hidden annotations and text alternatives. Matching comparisons attach
  to `mfrm_results(..., comparison = ...)` for reports and saved exports.
  No automatic ranking or difference intervals are implied. Person-score
  comparison requires the saved scoring outputs described above. Predictive comparisons require the separately supplied diagnostics
  described above. Ordinary fits now retain omitted events and input-row
  indices; older fits with unrecorded omissions require refitting for this route.

* Shared-rater and testlet estimate plots now offer interval, precision
  (estimate versus interval width), and empirical cumulative-distribution
  views. Shared display controls cover sorting, monochrome output, point/text
  size, labels, reference lines and custom or hidden titles/captions. Colours
  are supplemented by symbols; plot data retain text alternatives, complete
  tables and exclusion reasons. Cumulative distributions exclude prior-only
  scores and do not estimate a latent population distribution. Shared-rater
  severity and bootstrap intervals now also convert to ggplot; bootstrap
  comparisons retain dashed ordinary intervals and arrows for infinite ends.
  These presentation changes reuse saved estimates without refitting.

* `score_mfrm_random_rater()` supplies conditional Person EAPs, posterior SDs
  and continuous equal-tail intervals with joint shared-rater integration.
  Selecting Person IDs retains the full scoring roster; supplied new data
  replace the roster. Prior-only and unavailable rows stay explicit. The
  conditional Laplace approximation holds calibration fixed and does not
  establish general approximation accuracy or interval coverage. Saved scores
  support plots, ggplot conversion and `mfrm_results(fit, scores = scores)`
  alongside response predictions and rater bootstrap intervals. Numerical
  checks, omitted rows and the complete scoring roster remain in the result.
  A fixed-calibration joint-posterior comparison now supports the stated
  numerical tolerances for 48 selected scores on twelve linked and reduced
  three-category RSM rosters. Help separates approximation accuracy from
  interval coverage, retains the reference-precision limitations, and explains
  how to select a few output Persons while keeping the full scoring data.
* `fit_mfrm_random_rater()` now estimates normal ability variance by default.
  Use `person_sd = 1` for a known standard normal population, or another
  positive known SD. Calibration-adjusted rater uncertainty includes the
  ability-SD coordinate; rater-SD profiles re-estimate it, and bootstrap
  generation/refits preserve the fitted population and known/estimated choice.
  Both estimated zero variances and the ability search bound are checked.
  Up to 241 Person quadrature points can be requested when lower orders fail
  the unchanged accuracy checks.
  An estimated ability boundary withholds regular intervals and rater-SD
  profiling. Reports distinguish both variance components; earlier saved fits
  retain their known N(0,1) population. Existing fixed-population coverage
  evidence does not qualify this estimated-population workflow.
* `fit_mfrm_testlet()` now estimates normal ability variance by default,
  alongside the common local variance. Use `person_sd = 1` for the earlier
  fixed N(0,1) model, or specify another known positive SD. Both estimated
  zero-variance boundaries are checked explicitly. Zero ability variance
  withholds individual scores; search-bound failures retain their checks.
  Conditional scoring, prior-only rows, summaries, reports and saved results
  use the matching population. Earlier saved fits retain N(0,1); changing
  that assumption requires refitting and regenerating scores. Person intervals
  exclude uncertainty in estimating both variances; earlier fixed-population
  coverage studies do not qualify this new fit.
* Random-rater and testlet help now connects the effect-sharing assumptions
  to measurement-model research, distinguishes the fixed ability-variance
  restriction from scale identification, and explains which ordinary-MFRM
  comparisons preserve the data and statistical target. Descriptive matched-facet
  comparison uses `compare_mfrm()`; predictive diagnostics and their cross-model
  comparisons use the matching response-probability definition.
* Testlet and random-rater fits now connect to `mfrm_results()`,
  `mfrm_report()` and `export_mfrm_results()`. Reports retain calibration,
  numerical checks, omitted-score accounting and interval meanings, plus
  explicitly supplied matching predictions and random-rater bootstrap results.
  CSV/RDS exports preserve prior-only and unavailable rows, failed bootstrap
  trials and infinite interval endpoints. Replay reloads saved results without
  fitting, scoring or resampling. Older predictions must be regenerated from
  their saved fit to attach source metadata; no model refit is needed.
  Numerical checks are not model-fit diagnostics or general coverage evidence.
* Testlet results now connect to `as_ggplot()` and the common plot-data
  accessors, preserving interval labels, prior-only symbols and unavailable
  rows. `mfrmr_output_guide("models")` and the workflow help compare fixed
  facets, shared random raters and testlets, including their different
  prediction targets. The tutorial covers figure and table export. Ordinary
  diagnostics and the Shiny viewer remain unsupported for the extended
  models and provide targeted guidance. Replot or convert saved results
  to use the display changes; no refit or rescoring is required.
* Added `fit_mfrm_testlet()` for an RSM with explicit, non-overlapping
  Person-specific testlet memberships, additive fixed facets and a common
  normal local-effect variance. Nested quadrature, analytic gradients,
  multiple starts, an exact zero-variance submodel and information checks
  support calibration; unequal observed block sizes are allowed. `predict()`
  provides continuous conditional Person intervals, retaining unavailable
  and prior-only rows. Saved fits, English plots, an interval-guide entry and
  a complete tutorial cover fitting, feedback, missing assigned scores and
  reuse. Estimated zero variance withholds regular calibration intervals.
  Person intervals hold calibration fixed and do not propagate its estimation
  uncertainty. This local effect is distinct from a rater shared across
  persons. The separate result class does not support ordinary-model
  diagnostics, response-MI pooling or portable calibration conversion.
  Earlier models require a new fit with explicit membership. General coverage,
  calibration-aware Person intervals and correlated/heterogeneous testlets
  remain unfinished.
* Added `mfrm_random_rater_intervals()` to compare model-based bootstrap
  prediction intervals with ordinary intervals for observed random raters.
  It generates shared rater effects, persons and scores on the analyzed
  assignment and refits the same model. Saved prediction errors support
  studentized and unscaled intervals and different levels without refitting.
  Failed refits and unavailable studentizers remain in the planned count;
  uncertainty about their roots widens limits, possibly to infinity.
  Plots distinguish unbounded endpoints from finite ordinary intervals.
  Positive source SD and prediction SEs are required. This candidate does
  not replace population-SD profiles or establish general coverage; boundary
  sources, simultaneous classification and missingness-model uncertainty
  remain outside its scope. In a separate 24-dataset comparison (12 per
  condition, 99 refits each), six-rater coverage was 91.7% for ordinary and
  100% for studentized intervals, with 40% greater mean width. The improvement
  occurred in one dataset; its paired change had MCSE 8.3 percentage points.
  With 24 raters, coverage was 95.5% and 95.1%. All intervals were finite.
  This small comparison does not qualify 95% coverage or justify making
  bootstrap intervals the default. The interval guide and tutorial distinguish these
  realized-rater intervals from population-SD profiles.
* Added `fit_mfrm_random_rater()` for an RSM with one normal rater effect
  shared across all persons rated by that rater. Frequentist approximate MML
  uses Person quadrature and a joint rater Laplace integral through optional
  RTMB (>= 2.0). The distinct result class retains numerical checks, full
  covariance, observed-rater feedback, plots and saved-result support.
  `confint()` profiles the population SD, including zero. Estimated variance
  boundaries withhold ordinary calibration and rater intervals. `predict()`
  distinguishes observed raters from replacement raters at specified abilities;
  it returns marginal score probabilities conditional on calibration, not
  joint predictions, person scoring or parameter-uncertainty intervals.
  A complete tutorial explains population assumptions, missing assigned scores,
  numerical failures and interpretation. PCM, anchors, testlets, latent
  regression and multidimensional abilities are outside this route. Earlier
  fixed-rater analyses require a new fit for this model; changing a saved
  object's class is not a migration. A bounded 160-dataset normal-population
  pilot returned all population-SD profile intervals. At true SD 0.7,
  individual-rater interval coverage averaged 84.2% with six raters and 94.4%
  with 24 raters (40 datasets each). Few-rater interval calibration remains
  unresolved; these results do not establish general coverage.
* Added `mfrm_screening_performance()` and its plot for evaluating declared
  screening rules against known simulation truth. A complete planned roster
  retains failed and incomplete trials. Per-target and any-target family rates
  keep separate denominators, exact Monte Carlo intervals and bounds for
  unresolved outcomes. A tutorial connects simulated ratings to rater flags.
  In a bounded matched-budget study, the specified Infit/Outfit union detected
  only 6/100 and 2/100 contaminated-rater cases under two sparse assignments;
  absence of a warning cannot certify rater quality.
* Corrected `evaluate_mfrm_signal_detection()` so unavailable bias statistics
  and descriptive-only DIF classifications remain unavailable rather than
  counting as negative screens. Target summaries retain full precision,
  planned/available counts and Monte Carlo bounds; non-target results retain
  cell availability. Rebuild saved summaries and plots from the original
  evaluation for target corrections. Earlier non-target averages lack the
  required cell counts and are withheld; recovering them requires rerunning
  the simulation. These are conditional screening rates, not general accuracy
  guarantees or familywise error control.
* Added `mfrm_facet_intervals()` for pointwise intervals on fixed facet estimates
  and named linear contrasts, including rater differences. For inference-ready
  fixed-standard-normal RSM/PCM MML fits with unit weights, compare ordinary
  observed-information covariance with a one-way sandwich using whole persons
  or explicitly declared larger independent clusters. The full covariance
  preserves fitted constraints and covariance between facet levels.
  A plot and complete tutorial compare methods on the same estimates and
  retain unavailable intervals. The sandwich describes variability around the
  working model's target; it does not correct misspecification bias or provide
  general coverage, small-cluster, random-rater or diagnostic-accuracy guarantees.
  `mfrmr_interval_guide()` includes this route and assigned-score MI pooling.
* The introductory CSV examples preserve literal `NA` identifiers and recode
  missing-score markers only in the score column. If an earlier import
  removed valid IDs, reimport the original file and rerun the analysis.
* The workflow tutorial connects coverage and category review to rater
  severity, uncertainty and screening flags, with focused tables and guidance
  on interpreting individual ratings separately from rater-level summaries.
* Reduced overhead when assembling strict pairwise diagnostic summaries for
  large rating datasets, preserving statistics and unavailable-result flags.

* Facet dashboards identify unavailable diagnostics and preserve fit-readiness
  restrictions in summaries and plots. Zero observed flags is not a complete
  diagnostic pass. Rater severity profiles label restricted fits `REVIEW ONLY`.
  A nonfinite Infit or Outfit value cannot hide a flag from the other,
  finite index or create a flag on its own.
  Rebuild saved dashboards from existing fits and diagnostics to obtain the
  added availability and readiness fields; a model refit is unnecessary.
* Dashboard plots now use the same default misfit band as dashboard tables and
  retain a saved dashboard's thresholds for their guide lines. Recreate plots
  to correct earlier defaults or guide lines; no model refit is needed.
* Dashboard exports include screening settings and interpretation notes in
  CSV/text and HTML. Re-export existing fits to retain this context.
  HTML also shows unflagged levels with unavailable diagnostics and uses
  focused columns; the CSV files retain the full diagnostic detail.

## Multivariate G-theory and assessment planning

* Added a fixed-task-set example using existing multivariate score components
  and a random-rater facet. It connects task-specific scores, prespecified
  weights, rater-count scenarios and plots, and checks the result against a
  directly weighted score. Help distinguishes this target from sampling new
  tasks, explains workload and common-rater requirements, and retains whole-row
  omission accounting for incomplete score vectors. No general fixed-facet
  estimator is added.
* Added `mfrm_multivariate_gstudy()` and `mfrm_multivariate_d_study()` for
  numeric observed scores with fixed score components and one or two random
  measurement facets. A single score is also supported. Select common tasks,
  raters or other named facets through `rater`/`task` or `facets`. ANOVA handles
  complete balanced data; explicit `method = "minque0"` also handles incomplete
  designs whose moment equations separate the covariance components.
* Specify `nesting = c(Rater = "Task")` for persons crossed with task-specific
  rater teams. This estimates five components, with child identities local to
  each parent and shared across persons and scores. MINQUE(0) also permits
  unequal observed team sizes. D-studies preserve the fitted nesting and
  project complete balanced plans; `Raters` means raters per task. Nesting
  within persons, partly shared children, score-specific identities and unequal
  future allocations remain unsupported.
* D-studies report original scores and named weighted composites, including
  signed differences. Vector or matrix weights are used without normalization;
  between-score covariances enter composite projections. Incomplete or unequal
  source designs require an explicit future grid. Observed pool counts are not
  future per-person replication or the reliability of a sparse roster.
* Raw negative or indefinite covariance estimates are retained. Each score,
  composite and metric has its own availability status: a non-PSD component
  no longer suppresses every G/Phi/SEM. `ComponentPSD` separately flags the
  component matrices for review. Zero universe variance gives zero G/Phi when
  the corresponding error is positive; zero total variance is undefined.
  Recompute saved D-studies from their G-studies to adopt these rules.
* Added `mfrm_multivariate_d_compare()` for prespecified differences in G, Phi
  and SEM between future plans from the same two-crossed-facet G-study.
  Explicit `assumption = "normal"` requests approximate pointwise paired-delta
  intervals, preserving dependence between plans. Complete ANOVA and incomplete
  MINQUE(0) sources are supported. Nonnormal-robust, one-facet, nested and
  simultaneous intervals are not provided. Unavailable intervals retain their
  reasons; a returned point estimate need not have an available interval.
* G/D-study help provides runnable examples, including task-only, named-facet,
  nested-team and composite planning. It distinguishes ranking from absolute
  decisions, measurement error from sampling uncertainty, planned assignments
  from missing scores, and component identification from precision. G/Phi are
  not pass/fail accuracy or latent MFRM reliability. Omitting missing rows does
  not impute scores or correct informative assignment. Guidance explains raw
  negative-component conventions when comparing GENOVA-family results.
  Updating only future counts or composite weights reuses the G-study;
  changing its source data or model requires a new G-study. Saved-result
  guidance distinguishes these actions from replotting stored values.
* D-study base plots and ggplot exports preserve selected scores, weights,
  planned counts, metric-specific omissions and component diagnostics. Nested
  child counts are labeled per parent. Plan-comparison plots show differences
  and intervals against zero; `plot_data()` supplies their exact values.
  Automatic ggplot conversion is unsupported for plan-comparison plots.
* Corrected single-score MINQUE(0) matrix handling and kept distinct interaction
  IDs containing periods separate. Rerun affected G-studies. Main-effects
  D-study curves now distinguish every other facet count and retain missing
  estimates; surface plots require other conditions to be fixed within panels.
  Their automatic ggplot fallback is disabled because it could misrepresent
  the selected quantities.
* `mfrm_generalizability()` now requires explicit `missing = "omit"` for missing
  scores or selected facet values, refuses malformed scores, and retains input,
  used and excluded row accounting. Older saved results require a new G-study
  from original data to obtain that accounting; an MFRM refit is unnecessary.

## Missing scores on assigned ratings

* A paired repeated-sampling assessment of joint-RSM imputations now informs
  the help. In 200 datasets with 80 Persons, three raters and two criteria,
  MI coverage of a fixed-rater contrast was 96.5% under observed-score-dependent
  MAR missingness (198 available intervals; 95% Monte Carlo bounds 92.9--98.6%).
  Low-score-dependent MNAR missingness reduced coverage to 26.0% and introduced
  +0.574-logit bias despite a similar overall missing fraction near 14%.
  Direct MML and Bayesian inference showed the same vulnerability. Two MAR
  posteriors missed the sampling-diagnostic threshold and remain counted as
  unavailable. These are bounded results for the specified imputer and design;
  the generic supplied-imputation and pooling calculations are unchanged.
* The assigned-score tutorial now uses a joint RSM imputation example with
  uncertainty in calibration and shared Person abilities. Forty supplied
  posterior predictive completions run without a Bayesian toolchain; an
  accompanying R/Stan script regenerates them and retains sampling diagnostics.
  A probability display, direct observed-score comparison and separate
  lower-score sensitivity analysis connect missing-score assumptions to a
  fixed-rater contrast. The example preserves unassigned cells and observed
  scores. Agreement in one example does not establish repeated-sampling
  coverage or exact compatibility between Bayesian imputation and MML analysis.
* Pooling help distinguishes uncertainty in an imputation model from bootstrap
  inference for the entire analysis. Imputer resampling or a common response
  likelihood alone does not establish valid Rubin intervals. The pooling
  calculation is unchanged. Direct observed-score MML can estimate the same
  target under the same likelihood and ignorable missingness assumptions;
  imputation creates no additional observed information.
* Added `mfrm_response_imputations()` to review supplied score completions from
  a retained imputation model. Explicit event IDs and eligible missing-score
  selections preserve observed scores, person/facet identities and assignment.
  Unassigned rows remain unassigned; no complete rating grid is constructed.
  Unselected assigned nonresponse requires an explicit omission decision.
* `fit_mfrm_imputed()` fits every completion with a common RSM/PCM MML
  specification, category ladder and fixed-standard-normal person scale.
  All fits, failures and warnings remain available; incomplete or ineligible
  analyses cannot be silently omitted from subsequent pooling.
* `pool_mfrm_imputed()` combines eligible non-person facet estimates or
  prespecified linear contrasts with full observed-information covariance and
  Rubin's rules. Results retain within/between/total covariance, reference
  degrees of freedom and Monte Carlo SEs. A plot displays the stored pointwise
  intervals and identifies fixed targets without inferential intervals.
  Person EAPs and posterior SDs are not eligible for this pooling route.

## External features and exploratory groups

* Added `mfrm_pca()` and `mfrm_cluster_kmeans()` for explicitly selected
  numeric external attributes. They retain scaling, feature weights, PCA
  component choices, initialization settings, original-unit profiles, omitted
  IDs and missingness reasons. PCA input to k-means is used without whitening
  or rescaling; factors and arbitrary category codes are not converted.
* PCA provides scree, score and loading plots with exact plotted tables;
  matching group results can annotate the score view. Existing profiles,
  silhouettes, saved results and group comparisons support k-means. Comparison
  summaries identify each analysis's distance, fitted space, scaling and
  retained component count. Recreate comparisons from saved analyses to add
  these columns; the existing analyses need no refit. Different geometries do
  not make silhouettes a common-scale criterion for choosing a feature set.
* `mfrm_cluster_imputed(method = "kmeans")` supports direct numeric features or
  explicit PCA reduction within each retained completion. It reuses the same
  reviewed `mice` model and preserves all completions and their transformations.
  No PCA basis, component scores or group labels are pooled. Updated examples
  connect numeric preprocessing, paired comparisons and original-unit profiles.
* K-means can omit silhouettes explicitly to avoid their pairwise distance
  allocation. Uncomputed values remain unavailable in summaries and plots.
  Imputation co-membership matrices still require quadratic memory. Seeds
  preserve the caller's random state; optimization failures are reported.
* The external-feature tutorial now uses `mice` chain plots to review
  imputation behavior, so the basic example does not require `rstan`.
* Added `mfrm_features()` to prepare one row per Person, rater or task from
  selected external attributes, preserving types, IDs and missingness reasons.
  `mfrm_cluster()` uses Gower distances and PAM; `mfrm_cluster_hierarchical()`
  uses average or complete linkage and retains a dendrogram. Users choose
  features, weights and group counts. Results include profiles, silhouettes
  and, for PAM, representative entities. Groups do not establish latent classes,
  ability levels or rater quality.
* Missing features stop clustering by default; explicit complete-case selection
  preserves excluded IDs with unavailable memberships. Numeric-range overflow
  and relative-weight underflow are refused rather than silently changing
  feature contributions.
* `mfrm_cluster_imputed()` uses user-fitted `mice` completions and explicitly
  selected eligible missing cells. IDs, observed values, remaining missingness,
  reasons and model diagnostics are preserved. Pairwise co-membership proportions
  describe sensitivity to those completions, not membership probabilities or
  pooled inference. A failed analysis stops the comparison; hierarchical trees
  remain specific to each completion.
* `mfrm_cluster_compare()` compares fitted groupings across group counts,
  weights, feature selections and methods without refitting. It reports
  label-invariant pair changes, adjusted Rand indices, sizes and silhouettes.
  Analyses must contain the same entities, and shared features must retain their
  values and types. Imputation comparisons must reuse the same fitted `mice`
  object and preserve completion pairing; no setting is selected automatically.
* Plots show silhouettes, feature profiles, stored hierarchies and imputation
  co-membership heatmaps. `plot_data()` retains plotted values and exclusions,
  distinguishing unavailable pairs from zero co-membership. Automatic
  `as_ggplot()` conversion is refused because its generic fallback could display
  cluster numbers or mislabel the intended quantities.
* The external-feature tutorial uses fictional experience, workload, specialty,
  training and certification attributes. It covers separate Person/rater/task
  groupings linked to assignments, missingness and imputation choices, setting
  comparisons, sparse designs, and the roles and limits of PCA and k-means.

## Updating saved analyses

Keep the original objects and analysis settings. Installing this version does
not update saved numerical results or previously exported reports. See
"Updating saved analyses for 0.2.4" in
`help("mfrmr_workflow_methods", package = "mfrmr")` for the starting object
and action needed for each affected workflow.

* Reprinting updates display wording. Re-summarizing can update summaries
  derived from retained scores, draws or simulation runs; it cannot replace
  an old diagnostic calculation or grid-based interval.
* Most corrections below can reuse a fit with current estimation checks.
  Older native fits lacking those checks must be refitted from their original
  data and settings before inferential reuse. Recomputing diagnostics alone
  cannot supply missing fit checks.
* Recreate affected results before exporting again. Valid portable calibrations
  retain their recorded scoring algorithm; adopting continuous intervals
  requires a newly created calibration. External results can be re-imported
  from saved source-package fits without re-estimation.

## Portable calibration and scoring

* The separate-session CSV scoring example now preserves text identifiers
  such as `001`, `1` and literal `NA`. Earlier automatic CSV conversion could
  merge or replace identifiers before scoring. Reimport affected response
  files with the corrected column types and rescore; the calibration does
  not need refitting.

* Added portable calibration for one-scale RSM/PCM MML fits with a fixed
  standard-normal Person distribution. A reviewed calibration can be saved,
  transferred and used to score compatible new Persons without the source fit
  or training responses. Extraction, validation, freezing and scoring preserve
  categories, facet labels, anchors, supported two-way facet interactions and
  the scoring basis. Score intervals
  condition on the saved calibration and prior; they exclude uncertainty in
  the estimated calibration parameters.

* Portable calibration extraction now requires the reviewed object's exact
  highest-grid fit together with its quadrature-sensitivity result. Users
  choose the evaluated grids and judge the observed movement; response-linked
  fits remain outside the portable artifact and should be archived separately
  when needed. Extraction checks each retained fit's actual grid, convergence,
  score map, model and fitting settings, including anchors and integration
  mode; inconsistent review objects are rejected.

* Portable calibration artifacts now record an explicit scoring algorithm and
  a scoring grid independent of the source fit's integration grid.

* Portable score tables and summaries retain the estimate and uncertainty
  basis, calibration identifiers, scoring algorithm and requested interval
  level when exported to CSV. The interval level remains unrounded. Older
  score results recover the algorithm and level from their stored settings
  when re-summarized. Score estimates, SDs, and interval values are unchanged.

* Portable score `print()` and `summary()` output now stays compact at ordinary
  console widths, direct calibration-method help is available, and base and
  ggplot2 score displays both distinguish review states by colour and shape.

* Calibration displays describe the scoring prior, and score summaries explain
  reasons for review in plain language. Printed scores and interval plots state
  the requested interval level and distinguish continuous posterior quantiles
  from saved grid endpoints, whose posterior mass may differ from that level.
  Integration-review summaries explain that numerical comparisons do not
  automatically classify stability or change readiness, without internal codes.

* Portable calibration score batches now have concise `print()` and structured
  `summary()` methods plus interval, precision, and quadrature-edge review
  plots. The displays retain review and not-scored dispositions and state that
  posterior uncertainty excludes calibration-parameter uncertainty.

* FACETS-facing scope guidance now distinguishes the supported native
  portable-calibration workflow from unsupported FACETS or third-party
  calibration-file import, and removes stale version-number wording from
  current capability statements.

## Changes affecting existing analyses

* Reapplying empirical-Bayes shrinkage now replaces previous Person adjustments:
  `shrink_person = FALSE` removes stale Person shrinkage columns. Replay scripts
  retain the latest post-fit adjustment as a separate step after the original
  fit, including when diagnostic SEs were attached before shrinkage. Refresh
  older shrinkage results with the original prior and Person settings before
  regenerating replay scripts. Automatic replay selects fit mode for workflow
  objects with post-fit shrinkage.
* ICC calculations no longer reject positive variances using a fixed cutoff
  tied to score units, and returned variances are no longer rounded to six
  decimal places. Constant retained scores yield unavailable variances and
  ICCs. Constant-response bootstrap refits count as unavailable draws and
  withhold intervals; rerun saved bootstrap results to apply this check.
* Design-effect help and printed summaries now identify the per-facet,
  average-cluster-size approximation. `EffectiveN` is a descriptive equivalent
  row count, not a count of independent Persons or a precision estimate for
  the full crossed, nested, weighted, or unequal-cluster-size design. The
  design-effect formula itself is unchanged.
* ICC analyses now preserve numeric character/factor score labels and reject
  malformed scores. Missing scores or selected grouping values stop the
  analysis unless `missing = "omit"` is explicit. Results retain input, used,
  and excluded row counts, excluded row positions, and missing columns.
  Design effects use the ICC model's retained observation and grouping-level
  counts, so excluded rows no longer inflate cluster sizes or effective sample
  sizes. Rerun older ICC results before calculating design effects. Omission
  does not impute scores or correct missing-data bias.
* Withdrew `ci_method = "profile"` from `compute_facet_icc()` and
  `analyze_hierarchical_structure()`: transforming separate variance-component
  intervals while fixing the other components did not produce a
  profile-likelihood interval for the ICC ratio. Choose `"boot"` explicitly
  for parametric percentile intervals, subject to the fitted Gaussian model.
  The interval guide now also points to this explicit bootstrap route.
* ICC bootstrap results now retain all draws, requested and unavailable counts,
  convergence/singularity diagnostics, and refit warnings/errors. Any missing
  or nonconverged replicate, or a fit warning, withholds intervals; successful
  draws are not silently selected for quantiles. Converged boundary fits remain
  in the distribution. Invalid replicate counts, CPU counts, and seeds are
  rejected rather than truncated. Snow workers now load lme4 before refitting.
  Saved interval results must be rerun from
  their original data/settings before printing, summarizing, or plotting with
  this version. ICC plots explain unavailable intervals and no longer apply
  reliability-band reference lines to every facet's variance share.

* Selecting rows or columns from a D-study table now preserves its calculation
  and interpretation information. Printing selected columns no longer mistakes
  a newly computed result for an older saved result. Coefficients are unchanged;
  older results still require regeneration as described in the help.

* Interrater summaries now retain unavailable comparisons and report the number
  of classified pairs. Expected agreement is withheld when category probabilities
  are incomplete or repeated ratings have been averaged within a context.
  Context identifiers containing separators no longer merge distinct contexts.
  Plots retain unavailable pairs and omit unestimated self-agreement values.
  Agreement and network reports require diagnostics matching the supplied fit.

* Rater networks now exclude zero-weight edges and leave directional indices
  unavailable when a rater has no retained directional comparisons. Distances
  refer to reachable pairs. Design reviews distinguish selected subsets from
  the full observed design and withhold a complete assessment when checks are
  missing. Halo reviews retain unavailable comparisons and no longer provide a
  Welch test of dependent pair correlations; its compatibility columns are
  missing. Recreate older agreement and rater-network results from the existing
  fit, matching diagnostics and original settings; no model refit is needed.

* Response-time reviews now read numeric factor labels correctly, retain groups
  with no valid times, and report valid and excluded row counts. Quantiles are
  computed correctly when an explicitly supplied cutoff argument evaluates to
  `NULL`; reversed rapid/slow cutoffs are rejected. Printed flags explain the
  descriptive rules without internal codes. Rates use valid times only and do
  not establish rapid guessing or low effort. Recreate older reviews from the
  original timed-event data and settings; no MFRM refit is needed.

* Model summaries now give one consistent formal-inference decision. The full
  display no longer reports inference as ready solely because the fit checks
  passed when precision support remains unassessed. Optimizer success is
  reported from the stored return code.

* Fit and summary displays explain population assumptions, GPCM discrimination,
  diagnostic availability and information-criterion restrictions without
  internal implementation/status labels. JML summaries state that no normal
  population was estimated. Structured results and numerical values are
  unchanged; reprint saved summaries to use the revised display.

* Fitted-object Person scores and posterior draws now retain their prior,
  calibration method, weighting and conditional uncertainty meaning in exported
  tables; score tables also retain the interval level. Summaries and HTML output explain source-fit
  restrictions without internal status codes. JML-based scoring is labelled
  as posterior EAP with a standard normal prior, rather than a new JML estimate.
  HTML bundles show basic model details and the public interpretation decision
  in place of raw manifest dumps;
  detailed manifest files remain available for reproducibility.

* Plausible-value summaries now use the requested interval level for empirical
  draw quantiles, instead of always using 95%. These finite-draw limits are
  distinguished from the companion continuous posterior interval. Existing
  scores, posterior SDs, posterior interval bounds and draws are unchanged.
  Re-summarize saved results and recreate exports; no refit or resampling is
  needed. To retain numerical priors absent from older estimated-population
  results, re-score using the existing fit.

* Imported eRm item difficulties now reverse source easiness signs and convert
  cumulative category coefficients to adjacent thresholds. TAM imports derive
  item difficulties and thresholds from category logits instead of coefficient
  names. Multi-facet TAM imports report combined response-condition difficulties
  and retain the original coefficient table; they do not reconstruct separate
  facet measures. Transformed SEs remain missing when joint covariance is needed.

* mirt imports now include rating-scale offsets and require a supported
  unidimensional Rasch or partial-credit model with positive slopes. Additional
  factor scores can no longer be mistaken for SEs. EAP estimates and conditional
  posterior SDs are labelled explicitly. For TAM, source person-fit statistics
  use WLE scores while imported person estimates remain EAP.

* Imported summaries describe the source scale without assuming native mfrmr
  population or slope constraints. Wright maps show point estimates only, and
  source posterior SDs no longer produce separation reliability. Re-import
  existing source-package fits to update saved bundles and derived displays;
  no model re-estimation is needed. Native model curves, response-level QC and
  portable calibration require a native fit.

* Marginal category and agreement diagnostics retain unavailable probabilities,
  counts and classifications. Missing context pairs no longer disappear from
  agreement summaries, and complete-scope residuals/RMSDs are withheld when
  contributing inputs are missing. Known cutoff crossings remain flagged when
  a companion rule is unavailable. Summaries, reports and exported tables show
  classified and unclassified counts.

* GPCM marginal diagnostics now summarize each declared threshold family
  separately. Marginal plots select from all rows within the requested facet
  and metric, retain unavailable rows, and display availability counts. Supplied
  diagnostics must match the fit. Ordinary marginal output explains its basis
  without internal status or literature codes.

* Marginal expectations condition on the same responses through Person
  posteriors, with calibration held fixed. Help now explains that residual
  scales omit cross-response covariance and calibration uncertainty; the
  cutoffs remain descriptive review rules. Recreate older marginal diagnostics,
  summaries, plots and exports from the existing fit and original diagnostic
  settings. No model refit is required.

* Rating-scale tables, QC and report text retain unavailable category counts
  and threshold comparisons. Adjacent steps are compared within each threshold
  family without skipping missing estimates; missing families require review.
  A binary scale has no applicable adjacent-threshold comparison. Equal
  thresholds count as nondecreasing, a description of point estimates rather
  than evidence that categories function adequately. Threshold plots label
  families and connect only available adjacent steps within a family.

* Missing category fit statistics and expected counts no longer become zero
  flags or counts. Usage totals cover all declared categories even when unused
  rows are hidden. Printed category summaries explain availability in plain
  language. Recreate older rating-scale/category-structure results, QC and
  reports with the original fit, diagnostics and settings; no model refit is
  required.

* Mean-square and ZSTD summaries now retain classified and unclassified
  element counts consistently in diagnostic summaries, report text and output
  tables. Missing results no longer imply zero flags or an overall fit failure.
  A known threshold crossing remains flagged when the companion statistic is
  missing; overall flag rates require complete classification.

* Fit rankings no longer mix ZSTD values and mean-square deviations under one
  label. Rankings use complete paired ZSTD values, falling back to mean-square
  deviations only when no paired ZSTD is available. Report text describes
  interval availability without internal column names. Recreate older
  diagnostic summaries, reports and exports from existing diagnostics; no
  model refit is required.

* Person-fit calculations use small positive probabilities without a lower
  floor. Missing or invalid response information makes the affected person's
  statistic and flags unavailable, with response counts retained. The ability
  correction requires numerical convergence, a finite person estimate, unit
  observation weights and complete derivative information. Otherwise, the
  uncorrected index is labelled explicitly when it can be calculated.

* Person-fit summaries explain limitations in plain language, and plots retain
  persons whose Infit/Outfit values are missing when their likelihood-based
  index is available. Normal-reference cutoffs are screening aids; they do not
  guarantee individual or multiple-person false-positive rates. Recreate older
  saved person-fit results with the matching fit and diagnostics; no MFRM
  re-estimation is needed.

* Unexpected-response summaries retain evaluated and unclassified response
  counts. Overall rates and before/after reductions remain unavailable when
  classification is incomplete, and QC requests review. Older saved screening
  results and QC summaries require regeneration with the original settings and
  existing fit. No model refit is required.

* Q3-style screens now count each unordered pair once and retain unavailable
  pairs with their shared-person counts and reasons. Missing correlations and
  flags remain unavailable. Printed summaries distinguish available pairs
  from all candidate pairs, and supplied diagnostics must match the fit.

* Residual PCA no longer replaces undefined correlations with zero or smooths
  invalid correlation matrices. Affected analyses remain unavailable with an
  explanation, which the visual-diagnostics tutorial now checks before plotting.
  Residual-permutation comparisons also remain unavailable if
  any requested permutation fails, while retaining the successful count.
  Recreate older PCA and Q3 summaries with the original settings and existing
  fit or diagnostics; the MFRM fit does not need to be re-estimated.

* Residual-PCA plots and summaries now describe exploratory evidence without
  fixed-value claims about a second dimension. Permutation references explain
  that fitted-model uncertainty is omitted. Facet-equivalence summaries use
  plain-language decisions; plots clearly describe deviations from the facet
  mean, separately from pairwise equivalence tests. Equivalence calculations
  are unchanged.

* G-study variance components now retain full precision, so changing score
  units does not erase small components before G/Phi are calculated. Facet-level counts
  reflect rows actually used by the mixed model; numerical warnings remain
  visible as reasons to review the result.

* D-study projections no longer substitute zero for missing or invalid error
  components. Affected coefficients remain unavailable. Planned facet counts
  must be positive integers, including when supplied as numeric factor labels.
  G/D summaries and plots explain that the coefficients are conditional
  observed-score planning values with variance-estimation uncertainty omitted.
  Recreate older G/D results from the existing MFRM fit; the MFRM itself does
  not need to be re-estimated.

* Shrinkage reports calculate mean shrinkage over eligible estimate/SE pairs,
  preserve unavailable factors, and validate supplied prior SDs. A zero prior
  variance means full pooling at zero; the previous help example stated the
  opposite. Zero plug-in SE after full pooling does not mean perfect precision.
  Plot whiskers are labelled descriptive plug-in bands, with their omitted
  uncertainty retained in returned tables. Reapply shrinkage with the original
  settings and regenerate saved reports, plots and exports; no MFRM refit is
  needed. Original estimates and predictions are unchanged.

* Reporting no longer recommends shrinkage solely because facet counts are
  small, or calls estimates stable solely because counts are large. Methods
  text explains the conditional adjustment and omits internal status codes.

* QC reliability/separation checks now require `separation_facets` to name
  facets whose levels should be distinguished. They are not assessed by
  default: similar rater severity is not automatically a quality failure.
  Unrequested checks do not affect the overall verdict. QC flags remain
  screening rules, not evidence of statistical validity.

* QC no longer replaces unavailable fit, element-misfit, unexpected-response
  or connectivity results with passing values. It verifies that supplied
  diagnostics match the fit, checks threshold order within each ladder, and
  avoids assuming that the first facet is a rater. Recreate saved QC results
  with `run_qc_pipeline()` using existing fits and current diagnostics; no
  model refit is required.

* Imported measurement diagnostics now retain finite-estimate/SE counts and
  withhold reliability when a required SE is missing. They no longer create
  joint facet chi-square statistics or p-values from imported marginal SEs
  alone. Source uncertainty conventions are retained. Re-import
  the existing source-package fit with `compute_fit = TRUE` to update saved
  diagnostics. Native QC requires a native fit with response-level diagnostics.

* Printed drift and linking reviews explain omitted source-fit, offset and
  cross-fit uncertainty, and identify `Offset_SD` as residual spread rather
  than an offset SE. They present review guidance without internal status
  codes. Linking calculations and flags are unchanged.

* Reliability and separation tables now show how many finite estimates and
  corresponding SEs were used. Non-finite estimates are excluded from both
  components; indices are unavailable when a finite estimate lacks its SE.
  QC no longer ignores an unavailable facet when taking the minimum index,
  and precision checks request review when no comparable values are available.
  Fit-adjusted values are described as companion indices, not confidence bounds.
  Recreate saved diagnostics with `diagnose_mfrm(fit)` and regenerate dependent
  reports and exports; no model refit is needed.

* Weighting and model-choice summaries distinguish numerical convergence from
  eligibility for inference and explain restrictions in plain language.
  GPCM ranking and PCM/GPCM tests now use separate eligibility checks. Rebuild saved reviews from the existing fits to obtain the
  revised explanations; older saved reviews request this recreation instead of
  displaying outdated guidance. Machine-readable status fields remain in the
  returned objects.

* JML fit summaries now state that fitting applies neither an extreme-score
  adjustment nor a finite-item bias correction. Free extreme Person estimates
  remain infinite; fixed anchors retain their values and JML uncertainty
  remains exploratory.

* Adjusted-score tables retain the original `PrimaryMeasure`, a readable
  `MeasureBasis`, and the exact `ExtremeAdjustment` amount alongside the
  displayed `Measure`, including in CSV exports. `xtreme` changes display
  values only. Measure SEs are now unavailable on replaced rows because the
  original SE does not describe the replacement. Fitting is unchanged.
  A display replacement is unavailable when its required Person-mean
  reference is unbounded.

* Non-Person FairM is unavailable when a free JML Person estimate is infinite.
  Its mean Person reference previously used finite optimizer traces, which
  do not define the mean of the primary estimates. FairZ uses a zero reference
  and is unchanged. Tables and CSV exports record `FairMReference`; summaries
  and plots explain unavailable values. Recompute older diagnostics and
  recreate saved fair-score tables from the existing fit and original options
  before summary or plotting; no model refit is needed.

* Facet SEs from a regularized Hessian or an observation-table fallback are
  now distinguished from ordinary model-based SEs and cannot authorize
  confidence-interval reporting. Their numerical bands remain available for
  diagnostic review. Recompute older diagnostics with `diagnose_mfrm(fit)` and
  recreate precision reports from the existing fit; no model refit is needed.

* Precision reviews distinguish numerical convergence from support for
  inference. JML guidance no longer implies that changing to MML alone makes
  uncertainty valid. Model comparisons explain withheld rankings and tests in
  plain language, with detailed status codes retained in the returned tables.
  GPCM rankings and PCM/GPCM tests use the separate comparison checks
  described above.

* Residual comparisons from `analyze_dff()` / `analyze_dif()` now report group
  differences in observed-minus-expected scores without SEs, p-values,
  confidence intervals or positive/negative classifications. These differences
  do not isolate differential functioning. Existing test columns remain as
  `NA` for compatibility. `plot_dif_summary()` refuses residual confidence
  intervals. Recreate older residual results, summaries and reports using
  the existing fit and original data; no model refit is needed.

* `dif_interaction_table()` retains observed/expected scores and descriptive
  scaled residuals, with `t`, `df`, p-values and `flag_t` set to `NA`.
  `flag_bias` compares absolute residual means in score units, not logits.
  The retained `p_adjust` and `abs_t_warn` arguments have no effect on residual
  outputs. Group-comparison plots and reports no longer imply a DFF test.

* Residual DIF detection and false-positive rates from
  `evaluate_mfrm_signal_detection()` are unavailable rather than counted as
  zero. Re-summarizing older evaluation objects applies this restriction
  without repeating their simulations; target residual contrasts remain
  available.

* New fitted-object Person intervals and newly created portable calibrations
  invert the continuous posterior CDF. Selecting interval endpoints directly
  from quadrature nodes could give incorrect posterior mass even with accurate
  EAP and SD. Scoring algorithm v2 identifies this change; saved v1 calibrations
  retain their original grid-interval calculation and an explicit note. EAP,
  SD, fitting and grid-based plausible-value draws are unchanged. Intervals
  remain conditional on the point calibration and exclude its uncertainty.

* Estimated-population individual scoring now requires explicit
  `readiness_policy = "review"`; an active population model no longer bypasses
  incomplete source-identification checks. The same guard applies to plausible
  values, whose notes now retain the source review restriction. Earlier
  population predictions claiming scoring readiness must be regenerated before
  summary, printing or structured export. Numerical calculations are unchanged;
  local rank and optimizer convergence do not establish population-scoring validity.

* Non-unit observation weights now prevent ordinary-inference approval in the
  shared fit-readiness record. Diagnostic SE/normal-band calculations remain
  available, but do not license formal inference or facet-equivalence decisions.
  Explicit all-unit weights preserve the unweighted estimation/inference path.
  Older saved fits and diagnostics must be refitted or rechecked, and old
  equivalence results recomputed, before using their inferential conclusions.

* Facet equivalence now requires an inference-ready MML fit, matching supplied
  diagnostics, and unregularized covariance with estimable joint contrasts.
  Contrast rank is checked from the model constraints so covariance roundoff
  cannot admit a singular anchored comparison.
  Pairwise TOST SEs include covariance between facet effects. The heterogeneity
  summary uses a joint Wald test; the former unsupported Bayes-factor heuristic
  is unavailable. Forest plots show deviations from the equally weighted facet
  mean with uncertainty in that mean included. Old equivalence bundles must be
  recomputed before summary, printing, or plotting. These corrections do not
  establish finite-sample coverage or extend GPCM/JML inference support.

* Anchor candidate export and baseline reuse now fail closed unless the source
  fit is inference-ready under the current readiness contract. Explicit
  `readiness_policy = "review"` extraction remains available for inspection,
  while anchor application and anchor CSV export retain the strict default.

* Design recommendations now require connected Person-rater and
  Person-criterion assignments by default (`require_connected = TRUE`).
  Evaluation records component counts before fitting, and the screen includes
  failed runs. Disconnected or unassessed designs cannot pass unless the
  requirement is explicitly disabled; saved objects without component counts
  are unassessed. Sparse overlap reviews are shown separately and now include
  failed runs. Indirect connections remain valid: a pair without common
  persons is not automatically a disconnected design, and connectedness alone
  does not establish model identification or sufficient precision.

* Fit summaries, precision reviews, APA tables, Wright/pathway plots, visual
  reports and fit-level export helpers now check that supplied diagnostics
  belong to the fit and its current readiness state. Previously, MML diagnostics
  could incorrectly give a JML summary a positive formal-inference decision.
  Custom table captions/notes cannot bypass the check. Matching saved
  diagnostics remain reusable; recompute diagnostics after refitting.

## Estimation and numerical accuracy

* Fixed-grid, fixed-standard-normal RSM/PCM MML fits with up to 64 free
  parameters can use a guarded curvature restart when ordinary optimizer
  polishing stalls. Convergence and gradient tolerances are unchanged;
  failed proposals retain the previous solution and their review history.
  Refit an affected saved analysis to recompute its numerical status.

* `fit_mfrm(mml_integration = "adaptive")` uses posterior-mode/curvature
  Gauss-Hermite integration with moving-node gradients for direct MML.
  Likelihood, covariance, person scoring, refit sensitivity and replay retain
  the integration mode; supported portable calibrations store an explicit
  adaptive scoring identity. Fixed integration remains the default. Adaptive
  integration is unavailable for EM estimation and its checkpoints. Some
  identification and boundary checks are also unavailable with adaptive
  integration; numerical convergence alone does not establish valid inference.

* Quadrature sensitivity, fitted-object prediction, and portable-calibration
  scoring accept optional `adaptive_quad_points`, comparing the fixed grid
  with posterior-mode/curvature-adapted grids at unchanged parameters and
  prior. Unrounded per-Person log-marginal, EAP and posterior-SD differences,
  adaptive-order changes, and failure reasons remain available for review.
  This diagnostic leaves estimates, intervals, draws, and readiness unchanged.

* Gauss-Hermite weights now use a scaled Hermite recurrence, preserving tiny
  positive weights lost by the eigensolver at high orders. Fitting, posterior
  scoring, and portable calibration share the corrected rule. New artifacts
  identify the revised algorithm; existing valid calibration grids remain
  readable. Orders whose weights cannot all be represented as positive finite
  doubles fail explicitly instead of silently dropping quadrature nodes.

* Added `mml_quadrature_sensitivity()` for explicit same-data RSM, PCM, and
  bounded-GPCM refits across user-selected integration grids. It reports
  continuous changes in likelihood, measurement coordinates, probabilities,
  EAP, and posterior SD without assigning a stability cutoff; the existing
  GPCM-specific function remains available.

* Fitted-object scoring now uses an explicit scoring quadrature grid rather
  than inheriting the fit-time grid. It refuses a one-point grid, rejects
  invalid weights, and fails closed when the source is not scoring-ready unless
  the user explicitly requests a labelled review-only calculation.

* Continuous RSM/PCM Person intervals reuse the existing compiled likelihood
  kernel when enabled. CDF evaluations omit unused category probabilities;
  integration tolerances and the moment/gradient calculations are unchanged.

* Direct MML optimization now rejects trial points whose population variance
  overflows or underflows after log-scale transformation. This fixes an abort
  in a five-category GPCM fit with all-maximum responses. L-BFGS-B can also
  request gradients at rejected slope/variance trials; those receive the
  constant penalty's gradient. Readiness still uses the actual terminal
  gradient, and invalid starting or retained parameters remain errors.

* MML `print()` and `summary()` output now states the optimization engine,
  fixed or adaptive Gauss--Hermite rule, quadrature order, one-dimensional
  latent structure, and the fitted population-scale identification.

* Automatic nesting review now checks that the population specification is
  shared. Adding a fixed interaction no longer passes this review when the
  population design also changes or cannot be verified. Person and column
  permutations are aligned, and nuisance estimates may differ between fits.

* Model-comparison warnings report the affected fits and recorded inference
  readiness reasons, distinguishing estimability review from numerical
  convergence. Likelihoods, comparison eligibility and LRT calculations are
  unchanged.

* MML EM checkpoints now bind the data, model, parameter layout, quadrature,
  package version, and engine stage. Incompatible checkpoints and completed
  pure-EM re-entry are refused, hybrid warm-start checkpoints are honored, and
  writes use checked same-directory replacement.

## Diagnostics, linking and design

* Design recommendations now require results for every requested facet in
  each candidate design. Previously, a design missing a requested facet
  could pass on its remaining facet alone. `FacetsMissing` identifies absent
  facets, and `FacetsRequired` counts the request rather than available rows.
  Default requests use stored facet names when available, so missing results
  no longer silently narrow the requested scope.

* `recommend_mfrm_design()` accepts `max_ratings` and
  `max_ratings_per_rater` to select designs within total and individual rater
  workload limits. Counts use actual generated rating rows, including linking
  assignments and failed fits, and limits apply to the maximum across all
  recorded replications. Missing workload records cannot pass an active limit;
  omitting the limits preserves the existing ranking behavior.

* Design-evaluation summaries, plots, and recommendations now include failed
  fits and diagnostic runs in the convergence-rate denominator. Previously,
  one successful run and nine failures could be reported as 100% convergence
  and pass a design recommendation. `Reps` now counts all recorded runs;
  `AvailableReps` counts returned facet results. Re-summarize an existing
  evaluation object to apply the correction without refitting.

* Design-evaluation notes now use aggregated run summaries. Passing raw facet
  results to the notes helper previously caused missing-column warnings and
  omitted the corresponding convergence and performance notes.

* `evaluate_mfrm_design(parallel = "future")` now dispatches replications
  through the active future plan while preserving the same preallocated
  design-replication seeds and stochastic inputs as serial execution.

* Fair-average tables and plots now also reject diagnostics from a different
  fitted analysis. This prevents mixing one fit's thresholds with another
  fit's measures and standard errors when computing FairM/FairZ.

* Fair-average summaries now use FairZ values and SEs when `reference = "zero"`,
  with an explicit `FairMetric`. Requested fair-score intervals carry separate
  diagnostic-only eligibility metadata through tables, summaries and plots.
  GPCM fair-score SEs remain unavailable if any gradient component is missing,
  rather than replacing the missing uncertainty with zero.

* `plot_fair_average(plot_type = "measure")` connects person/facet measures
  to Fair Scores alongside the observed-score and gap views. Base/ggplot
  share colours and six point shapes, grayscale, and title/note controls;
  full notes and excluded rows remain available in the returned data.
  FairZ documentation now correctly describes a zero-reference expected
  score, not a z-score. Conditional RSM/PCM interval derivatives now use the
  actual FairM/FairZ profile and undo measure-unit scaling. GPCM bundle
  intervals honor the requested confidence level. These approximate intervals
  do not establish full-refit coverage; gap whiskers hold observed means fixed.

* Unexpected-response counts and percentages now use all flagged observations
  before applying the table's `top_n` limit. This also corrects default
  diagnostic summaries and bias-adjustment comparisons, where truncation
  could previously understate prevalence or overstate the reduction in flags.

* Generalizability-study and D-study results now state explicitly that their
  G/Phi coefficients are estimated on the observed numeric score scale, not on
  the fitted MFRM latent scale. Ordered scores continue to use the documented
  Gaussian linear mixed-model approximation in this complementary analysis.

* Corrected the G/Phi interpretation example: under the implemented
  nonnegative main-effect decomposition, `Phi <= G`; `Phi < G`, not `G < Phi`,
  indicates that absolute decisions carry additional facet-main-effect error.
  A D-study regression check now preserves this ordering.

* Linking-chain plots add `type = "offset_sensitivity"`. Each common-element
  deletion reruns preliminary offsets, screening, weighted/unweighted offsets
  and cumulative offsets with source estimates/SEs fixed. Returned tables expose
  signed changes, rescreened elements, actual weight contributors, screening
  fallback and unavailable comparisons. Missing offsets propagate rather than
  becoming zero changes; plots distinguish complete, partial and unavailable
  comparisons. Inconsistent source offsets require rebuilding the chain. No
  source model is refitted and no new uncertainty interval is calculated.

* The shared link-offset helper records contributors and the all-finite-row
  screening fallback. Non-finite preliminary weighted offsets now return an
  unavailable result rather than failing during the subsequent screening test.

* Linking chains add `type = "links"` and `type = "anchor_removal"` plot views.
  They summarize recorded retained connections and remove each common-element
  identity across all comparisons, holding screening fixed. Returned tables
  distinguish lost direct links from newly disconnected wave pairs, preserve
  existing disconnections and unknown-retention information, and retain all
  waves. Monochrome line/point encodings and title/note controls are supported.
  These are graph calculations; offsets, estimates and SEs are not recomputed,
  and zero new disconnections does not establish negligible statistical impact.

* The screened linking-chain graph retains isolated waves and handles no-common-
  element cases. Elements are shown separately for each reviewed link so that
  retained/excluded decisions cannot be merged across comparisons. Returned
  node/edge tables preserve source IDs, screening flags and interpretation notes;
  explicit IDs handle repeated names and punctuation. Four line types distinguish
  retention states in colour and monochrome. `show_title` and `show_notes` allow
  clean figures while notes remain printable. Drawing now uses base graphics
  without requiring `igraph`. This graph does not establish anchor invariance,
  precision or common-scale comparability.

* Facet-level category avoidance is now documented separately from global
  score support and from GPCM model choice. The legacy facet-dashboard
  `CentralTendencyFlag` is disabled by default because proximity of a severity
  estimate to the fitted origin does not diagnose restricted category use;
  `data_quality_report()` remains the response-based screening route.

* Adjusted-score summaries and plot notes explain the interval assumptions
  in plain language. Interval values and uncertainty metadata in extracted
  tables are unchanged. These approximate intervals remain unsuitable for
  confidence-interval decisions.

## Plots and reporting

* Report narratives now describe numerical convergence separately from formal
  inference readiness. A converged fit awaiting statistical review no longer
  has its convergence described as unknown.

* `plot_compare_mfrm()` adds paired Wright distributions/locations and CCCs,
  plus matched-location and probability-difference views. Existing source
  coordinates and probability calculations are reused, with explicit group
  selection, original score labels, source readiness and returned notes.
  Monochrome/many-category CCCs use category panels by default. Incompatible
  recorded comparison bases fail without automatic alignment. Drawing uses
  optional ggplot2; draw-free data need no renderer. No difference SEs or CIs
  are calculated. The shared Wright builder also handles a single person
  without calling the undefined one-observation FD histogram rule.

* Rater-severity profiles reserve space for complete labels and explain when
  the device is too narrow. FACETS-style maps warn about crowded facet labels;
  visual help explains font selection for non-Latin text.

* Rater-severity profiles omit band descriptions and legend entries when
  `show_bands = FALSE`. Band guidance is descriptive and no longer implies
  operational interchangeability or a training decision.

* Category-count plots in rating-scale, category-structure, and QC displays
  now include expected counts in the vertical range, preventing the expected
  line from being clipped when it exceeds the tallest observed bar.

* Fit-family Wright, pathway, and CCC plots now share CUD-informed series
  colours across base and ggplot. Bright yellow is omitted from line defaults;
  small data labels use neutral dark text. Expected-score/CCC curves vary line
  type even in colour, CCC overlays vary point shape, and Wright subgroup
  densities vary line type. ggplot conversion preserves category order, custom
  palettes, and monochrome presets. Large series sets still need suitable
  labels, panels, and canvas size; a palette alone cannot ensure readability.

* Fit plots accept `show_title` and `show_notes` (both default to `TRUE`).
  Users can omit figure titles and explanatory annotations while retaining
  axes, legends, and structural panel headings. Interpretation, curve-profile,
  and retention/display notes remain in `data$notes` and are printed by
  `print()`; ggplot conversions honor the flags and retain a `mfrmr_notes`
  attribute. Readiness and R warnings are unchanged by these display flags.

* Clean native pathways reserve enough bottom space for their axis title.
  FACETS-style Wright maps retain every column heading, split scale headings
  over two lines, and wrap facet cells and footnotes to the available width. Crowded headings and
  overflowing frequency stars warn about the needed width or star-count setting.

* Expected-score pathways now display the same reference-profile condition as
  CCC plots: fitted steps/slopes are retained and additive facet main effects
  and interactions are fixed at zero. Their returned `curve_basis` tables
  match, including in plot bundles; numerical curves are unchanged.

* ggplot conversions wrap titles, subtitles, and captions at 72 text columns
  and omit missing labels, preventing ordinary-width subtitle clipping and
  spurious `NA` captions. Users can override labels with `ggplot2::labs()`.
  Multi-group native CCC plots now share a margin legend even with five or
  fewer categories, keeping repeated keys off the fitted curves.

* Native Wright `top_n` now limits non-person facet locations independently
  of step thresholds. Many PCM thresholds no longer consume the limit and
  silently remove every item/rater location; returned locations and retention
  counts reflect this corrected selection.

* Plot label abbreviations now respect display width and distinguish long
  common-prefix names, including Japanese. Crowded native Wright/pathway
  labels prioritize fitted-point visibility and warn when more space is
  needed. Wider Wright maps keep their legend inside the page.

* Native CCC plots use a shared margin legend beyond five categories and
  distinct default colours beyond eight categories. Long panel names remain
  distinguishable, and single-group legends stay within the caller's panel.

* Native Wright and expected-score pathway labels now account for text width,
  text height, nearby labels, and fitted points when choosing their positions.
  Leader lines retain the link to each unchanged estimate; off-screen pathway
  thresholds stay off-screen. Drawing moves text without changing fitted
  coordinates; initial annotation positions remain available to custom renderers.

* Plot styling now restores only the graphical settings it changes, allowing
  single-panel plots to advance through a caller's grid. Native Wright maps
  and multi-group CCC plots clean up their own layouts before subsequent plots.
  Wright titles, pathway endpoint labels, and plot footnotes have more room;
  subgroup densities now draw in the Wright map's person panel.
  `plot_apa_figure_one()` uses a single-panel FACETS-style Wright map without
  CI whiskers (also reflected in its returned Wright payload), so all four
  panels share one page; its summary text wraps within the panel.

* Weighted APA reports distinguish retained rating rows from the sum of
  observation weights. Visual count summaries use retained rows as well.

* APA design text now reports each facet's own level count. APA and visual
  reporting reuse stored residual PCA results without silently computing
  omitted overall or facet-specific analyses.

## Reproducibility and documentation

* Replay CSV imports preserve literal identifiers (including leading zeros and
  `"NA"`), non-syntactic column names, and latent-regression factor levels and
  contrasts. Background-data paths also work with spaces in command-line runs.

* Diagnostics retain their replay settings, including fit standardization,
  interaction selection, and PCA limits. FACETS-workflow replay uses supported
  arguments and preserves the requested MML engine.

* Identifier text is normalized to UTF-8 during data preparation so native-encoded
  non-Latin labels do not fail in marginal diagnostic sorting.

* Results and summary-table archives omit tables with no column definitions instead of writing
  empty CSVs that `read.csv()` cannot read. Defined zero-row tables retain
  their column headers.

* Replay scripts with person-data CSV files now locate those files beside the
  replay script when invoked through nested `source()` or `sys.source()`.
  They no longer mistake the outer Rscript driver for the replay file.

* Replay scripts now preserve facet-interaction specifications and their
  support policy.

* Latent-regression reference benchmarks no longer attempt Person scoring when
  their fitted model is not scoring-ready. The posterior-shift check is kept as
  an explicit unevaluated warning instead of using a review-only score.

* Manuscript examples now pass the same diagnostics to tables and Wright maps,
  save full-precision CSVs with separate captions/notes and a PNG, and include
  input data for fit replay. Results-archive guidance distinguishes rebuilding
  results from refitting the original analysis.

* Introductory help examples, README, and the workflow vignette now start with
  loading data, fitting with default MML settings, `plot(fit)`, and
  `summary(fit)`. Overview tables are distinguished from individual estimates;
  diagnostic and reporting routes follow the basic example.

* Beginner examples now show the input rows, explain saved summaries, and
  select person, rater, and criterion estimates explicitly. Follow-up examples
  use the same default MML setup, draw the intended figures, distinguish basic
  summaries from comprehensive results, and show where exported files are saved.

* Follow-up examples now connect default MML fits to model comparison,
  diagnostic plots, score summaries, APA tables, and CSV export. Reporting
  checklist examples use logical flags and describe draft availability rather
  than permission to paste text unchanged. Agreement-plot guidance now matches
  the observed-score difference direction and model-expected agreement baseline.

* README and the workflow vignette now connect the packaged example to a user's
  own CSV: rating-row layout, identifier preservation, column mapping, declared
  score categories, missing-data review, and interpretation of individual
  estimates. The vignette adds a runnable CSV round trip, wide-to-long example,
  and input troubleshooting before the advanced workflow.

* Data-check and missing-code help now distinguish input missingness,
  replacement counts, retained rows, and full versus summary table names.
  Examples show which data to reuse after cleaning. Guidance on extreme scores
  now distinguishes MML posterior person scoring from fixed non-person facets.

* The workflow and reporting vignettes reuse one fit for actual diagnostic
  tables and figures. A manuscript coverage map connects reporting topics to
  package outputs and author-supplied study information. Worked reporting
  examples show estimates with uncertainty and distinguish severity, fit,
  separation reliability, and agreement; the example rubric is correctly 1–4.

* Reporting examples now include a short Methods and Results write-up,
  residual denominators, MML step SEs and intervals from existing diagnostics,
  and observed-versus-fair scores with an explicit reference. Guidance based
  on published reporting examples distinguishes separation, strata, and
  posterior-variance EAP reliability and identifies the relevant score units.

* Front-door and first diagnostic help examples now follow one explicit,
  inference-ready workflow: the applied synthetic data, named column roles and
  score support, RSM-MML fitting, fit review, Wright map, diagnostic summary,
  data/rating-scale/precision review, results, and report/export handoff. The
  historical `profile = "facets"` name no longer assumes experience with
  FACETS, TAM, or sirt, and examples no longer choose JML merely for speed.

# mfrmr 0.2.3.1

mfrmr 0.2.3.1 was a focused CRAN maintenance release. It did not change the
public R API or fitted-model contracts introduced in 0.2.3.

* Corrected the compiled-header configuration used under link-time
  optimization so all C++ translation units use R's configured `Rboolean`
  definition.
* Removed expired FACETS/Winsteps hyperlinks while retaining the substantive
  model distinctions and bibliographic references.

# mfrmr 0.2.3

mfrmr 0.2.3 improves the reliability and interpretation of the existing
many-facet workflows, with particular emphasis on the bounded GPCM introduced
before this release. No existing exported function has been removed.

## Bounded GPCM

* Clarified the supported GPCM as an aligned, single-owner relative-slope
  model. A slope multiplies the complete adjacent-category predictor, including
  the ability, facet, interaction, and owned-step terms. This is distinct from
  loading-only GPCM variants and multiplicative generalized MFRM families.
* Corrected the default scale identification for GPCM marginal maximum
  likelihood fits. When no population formula is supplied, an intercept-only
  population model now provides the latent location and scale while relative
  slopes use their documented geometric-mean constraint.
* Added parameter-level status for free GPCM slopes. Standard errors and
  confidence intervals are reported as ordinary inferential results only when
  the fitted solution and the parameter both satisfy the relevant readiness
  checks. Optimizer- and Hessian-based quantities remain available as clearly
  labelled diagnostic evidence when formal inference is not supported.
* Improved handling of extreme response patterns. Free JML Person estimates
  remain infinite for all-minimum or all-maximum responses; finite optimizer
  values are computational traces. Optional adjusted-score tables and plot
  placements do not replace the fitted estimates. Prior-regularized marginal
  EAP estimates remain available but do not override a blocked source fit.
* Added `gpcm_mml_quadrature_sensitivity()` for explicit same-data comparison of
  a fitted GPCM-MML result across quadrature grids. It reports changes in the
  marginal likelihood, relative slopes, raw observed-information quantities,
  population scale, and fitted probabilities without silently refitting during
  `summary()` or `print()`. Results support `summary()`, `print()`,
  `as.data.frame()`, and `apa_table()`.

## Estimation and readiness

* Added pre-fit checks for category and step support and strengthened
  constrained-estimability checks for sparse many-facet designs. Unsupported
  step contrasts and structurally unidentified comparisons now stop or fail
  closed before they can be presented as ordinary estimates.
* Strengthened numerical and boundary reporting for JML and GPCM fits.
  Optimizer convergence, terminal gradients, local rank, curvature, boundary
  evidence, and formal inference readiness are retained as separate concepts.
* Corrected the alignment of MML Person EAP estimates and posterior standard
  deviations when observations or Person rows are filtered during fitting.
* Fit-level readiness is propagated to Person results, plots, model-choice
  reviews, reports, and exported tables. A finite value from a blocked fit is
  no longer presented as an unrestricted inferential estimate.

## Summaries, diagnostics, and plots

* `print()` and `summary()` for fitted models now begin with a plain-language
  interpretation status, the availability of formal inference, the main reason
  for any hold, and a suggested next action.
* Formal-inference reporting now distinguishes satisfied fit-readiness
  requirements from the
  separate precision contract. A fit-only summary does not claim formal
  inference until matching diagnostics support the standard-error,
  confidence-interval, and reliability basis.
* GPCM uncertainty labels are consistent across fitted objects, summaries, and
  plots. Intervals calculated for observation-table Wright or facet displays
  are labelled `screening_only` and are not described as confidence intervals.
* PCM/GPCM model-choice reviews retain comparison warnings and keep information
  criteria, automatic preferences, and likelihood-ratio results unavailable
  when the compared fits do not share an eligible basis. Model-choice warnings
  can also be included in exported summary appendices.
* Differential-facet-functioning refits now replay the baseline response
  family, scoring range, estimator, weighting, and numerical settings. They
  fail closed for model structures that do not yet have a valid subgroup replay
  and linking contract. `min_obs` remains a computability guard rather than a
  claim about power or adequate sample size.
* Residual-PCA results now carry machine-readable exploratory-use guards.
  Returned components and warnings are descriptive diagnostics and do not
  automatically support dimensionality or subscore decisions.
* Corrected Person-involving bias-screen collection for explicitly requested
  facet pairs and expanded machine-readable FACETS feature-coverage guidance.
* FACETS table import retains the reported numeric text and displayed decimal
  precision so rounded output is not silently treated as hidden full-precision
  data.
* The Infit-versus-measure pathway now places Infit on the horizontal axis and
  the fitted measure on the vertical axis by default. GPCM category curves
  retain estimated step-facet slopes and now state
  explicitly that additive facet effects and interactions are fixed at zero.
  Multiple GPCM curve groups are shown in separate panels with category
  legends instead of as unlabelled overlaid traces.
* Native Wright maps label every retained facet level using displaced text and
  leader lines. Step thresholds are displayed as a vertical ladder with the
  score transition and fitted logit in each label.

## Reporting and reproducibility

* Reproducibility manifests describe inputs through semantic summaries such as
  class, dimensions, fields, and missingness instead of environment-sensitive
  serialization hashes. The `digest` package is no longer required by the
  distributed package.
* Reporting, APA tables, model summaries, and plots use the same readiness and
  estimate-use vocabulary. Added fields may affect code that assumes an exact
  number of rows or columns in a summary component; selecting fields by name is
  recommended.
* APA output is described as an APA/JARS-informed drafting aid rather than a
  compliance certificate. The reporting guide now lists study-level fields
  that the fitted model cannot supply, and weighted-method prose distinguishes
  row-level likelihood weighting from replicated Person response patterns.
* External programs are not required to install or use mfrmr. Comparisons with
  FACETS, ConQuest, TAM, or immer remain model- and estimator-specific and are
  not general interchangeability claims.

## Scope

* This release does not add unrestricted GPCM, loading-only or multiplicative
  generalized MFRM estimation, native multidimensional estimation, or new
  public multivariate G-theory and D-study functionality.

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
  interpretation until the numerical-readiness criteria are satisfied.

* Replaced blanket `\dontrun{}` and `@examplesIf interactive()` guards with
  checkable examples or `\donttest{}` blocks. Only the two workflows that need
  separately generated ConQuest files remain `\dontrun{}`, and only the local
  Shiny viewer remains interactive-only. This makes most examples executable
  while keeping workflows that require separately generated files clearly
  marked.
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
  chance agreement.
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
- Direct, hybrid, and EM MML engines now apply the same terminal-gradient check
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
  of every bundled synthetic dataset. The compact examples can be regenerated
  with fixed seeds. Combined-study
  objects now explain that relabeling prevents identifier collisions but does
  not establish a common scale without an explicit anchor/linking design.
- Precomputed vignette tables now follow the same successful operational MML
  route as the displayed workflow and record their source dataset, schema,
  MD5 checksum, and package version.

## Safer first analyses

- The public default remains `reltol = 1e-9` for the initial optimizer stage;
  bounded polishing is invoked only when `reltol <= 1e-9` and code zero
  precedes the terminal-gradient check. The fitted object records requested and
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
- The documented binary, item-only, one-covariate MML handoff was compared in
  a matched 31-node run with ConQuest 5.47.5 Demonstration Version. The result
  supports that narrow handoff and is not a claim of general numerical
  equivalence.
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
