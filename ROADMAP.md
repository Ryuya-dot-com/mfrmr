# mfrmr roadmap

Updated 2026-10-26. **mfrmr 0.2.4 is a release candidate and has not been released.** Its purpose is to
connect rating-based measurement, assessment planning and useful feedback.
The immediate priority is to finish these workflows with their meanings intact,
then qualify and publish the matching package and documentation.

| User question | Available in the candidate | Remaining boundary or next work |
| --- | --- | --- |
| What can be measured after accounting for the rating process? | RSM/PCM and bounded GPCM workflows; estimates, diagnostics, target-specific uncertainty, figures and saved scoring. | Two-family GPCM and common-plan inference retain their experimental scope. Numerical delivery is not a coverage guarantee. |
| How many ratings are needed for the intended score? | Supported G/D studies, fixed score components/composites, plan comparisons, uncertainty and reports. | Future plans are complete balanced projections; arbitrary sparse future rosters and automatic cost-optimal allocation are not implemented. |
| What should raters or assessment developers review? | Severity, fit, agreement, specified bias screens, anchor/link reviews, model-choice reports and individual feedback. | Screens are not fairness verdicts. Anchor readiness is not invariance; the review cannot supply missing drift evidence. |
| Can the analysis be reported and reused faithfully? | Shared report/appendix routes, long plot tables, editable measurement/G/D/review templates and user-declared study context. | Explain data transformations and score direction across analyses. Shared metadata does not make raw G-study scores equivalent to latent measures. |
| What must happen before release? | A matching local candidate, scoped numerical/workflow evidence, distributed regression and attributed repairs. | Integrate the selected source, finish remaining platform/external-link/website checks and verify authorized publication. Source identification remains separate from release qualification. |

Recent network extensions are one part of feedback, not the organizing goal of
the package. Design graphs, signed agreement, SWS/PUS, halo contrasts and binary
ERGMs answer different questions and retain their documented limitations.

After 0.2.4, prioritize reusable inference and score/event specifications, then
bounded multidimensional rubric measurement. Response/production time and
rater scoring time remain distinct observations; continuous-dimension Q
matrices and discrete-attribute Q matrices remain distinct specifications.
Bayesian fitting, latent classes and cognitive diagnosis are staged research
and implementation plans, not capabilities established by their inclusion here.
See [staged delivery](#direction-and-staged-delivery).

The detailed scope below records method-specific conditions. Start with the
[workflow requirements](#application-workflows-and-completion-conditions),
[three pillars](#pillar-milestones-and-progress), or
[release milestones](#completion-milestones-for-024).
Use [NEWS](NEWS.md) for changes and migration and [README](README.md) for a first analysis.

## Focus for 0.2.4

The release has three complementary purposes:

| Purpose | Question it helps answer | Current priority |
| --- | --- | --- |
| Measurement models | How do ability, rater severity, category use and discrimination explain ratings? | Make the implemented models, diagnostics and uncertainty estimates usable with explicit limits. |
| G-theory assessment planning | How would tasks, raters and score weights affect assessment dependability? | Preserve the completed, scoped estimates, intervals and plan comparisons in the final API and release. |
| Rater feedback and assessment decisions | Which rating patterns need review, and how uncertain is a conclusion? | Connect supported diagnostics, individual reports and decision summaries. |

The G-theory interval requirements are reconciled within the documented
designs and assumptions, with experimental methods distinguished from
qualified defaults. Anchor alignment and its migration workflow are
checked within the supported scope. Final package and environment verification
follows the required feature work. Measurement and feedback remain part of
0.2.4, with unfinished research distinguished from implemented features.
The earlier numerical and help corrections remain accepted within their
scope. The final API decisions now include consistent validation of the reviewed
saved-result consumers and settled primary-entry and naming conventions.
The candidate includes breaking API changes. The compatibility guide maps
replaced calls, arguments and result structures to the supported interfaces
and explains effects on saved-result reuse. The review of mathematical validity,
numerical accuracy, stability and algorithmic efficiency now supports the
documented claims and restrictions. Experimental methods have a checked
calculation basis while retaining their unresolved inference limitations;
the label alone is not their justification.
Check, CI and documentation-build execution-time requirements follow substantive
specification freeze. See the [completion milestones](#release-completion-milestones)
for their dependencies and acceptance conditions.
The package is intended for different assessment settings whose
rating designs match the selected method's assumptions.

<a id="open-facets-and-genova-compatibility-decisions"></a>

### FACETS and GENOVA compatibility: release scope and follow-up

The implemented compatibility options below belong to 0.2.4 within their
checked scope. Unchecked investigations remain unfinished and are identified
as follow-up work; they are not claims of software equivalence. Their release
allocation rests on the independent calculation checks and explicit model
restrictions below. A wrong calculation within the supported scope, an
unimplemented promised option or a misleading comparison remains a release
blocker. Documenting a difference does not complete its numerical explanation.

Compatibility is assessed per quantity. Independently derived model calculations
remain the statistical basis; verified ordinary-JML reporting conventions can
match FACETS to support migration and comparison. Unexplained version-specific
outputs are not reproduced by empirical corrections. Compatibility options must
retain the estimand, primary estimates and inference qualifications; they do
not imply that FACETS defines G-theory or all supported estimation methods.

- [x] Select and implement the checked bias-cell df/probability convention.
  Retain frequency count minus one and the continuous Student tail; the manual's
  count-minus-two description is not adopted as the executable convention.
  FACETS 4.5.0 fractional-count tails in the checked examples are reproduced by
  extending an integer-df finite sum outside its valid domain. This differs from
  the Student distribution and can change a 0.05 screen. mfrmr retains the
  independently integrated Student reference, with `ProbabilityReference`,
  `ProbabilityStatus`, `ProbabilityReason` and separate display df. Nonpositive
  df withhold the probability without discarding a finite conditional estimate.
  This scoped decision does not establish other versions' behavior or calibrated
  finite-sample screening; uncertainty evaluation remains open below.
- [x] Add the scoped ordinary-JML expected point-measure reference to
  diagnostics and fair-average tables. `PTMEAExpected` uses the published
  finite-count factor `(N-2)/N`, with frequency count `N`; the unadjusted
  reference and unavailable states are retained separately. Fixed-calibration
  PCM comparisons support this convention with missing assignments and unequal
  weights. This is an approximate conditional reference, not an exact expected
  sample correlation or inference with calibration uncertainty.
- [ ] **Follow-up comparison:** explain four remaining PCM Outfit-df
  discrepancies. For 0.2.4, retain the independently checked Wright--Masters
  calculation and disclose the native disagreement. Infit df agrees
  in the retained comparison, but agreement of fair averages, MnSq, correlations
  and additional small cases does not explain these Outfit-df differences.
  Fixed-distribution reflection probes reveal small native deviations under
  mathematically equivalent score reversal. mfrmr retains stable central moments,
  checked against independent high-precision arithmetic and reversal invariance;
  it does not introduce a numerical perturbation to copy unexplained output.
- [x] Implement explicit conditional total-score extrapolation for ordinary
  additive RSM/PCM JML: `fair_average_table(..., xtreme = .3,
  xtreme_method = "facets")` and `estimate_bias(..., xtreme = .5)`. Retain
  primary estimates, fixed anchors and the old average-score display default;
  distinguish corrected-total SEs and downstream fair scores. Unit/replication
  weights, a fixed-scale PCM kernel and public consumers have scoped checks.
- [ ] **Follow-up comparison:** evaluate native extreme-score equivalence under
  broader anchoring and exclusion designs. For 0.2.4, retain the checked
  conditional reporting option and its supported anchor restrictions;
  broader calibration equivalence is not claimed. Interior partial-anchor differences are resolved by
  matching the origin constraints, but this does not validate every extreme
  calibration design. The implemented reporting calculation conditions on
  the saved calibration.
  Same-boundary Person anchors expose a substantive difference: FACETS can
  report finite values where the ordinary likelihood has no finite maximum.
  mfrmr detects this configuration before optimization and does not reproduce
  it as ordinary JML. With additional interior-anchor support, conditional
  fair scores and bias calculations have matched-calibration checks, and
  finite direct anchors remain in fair-score filtering under both display
  conventions. Main calibration differences and broader exclusion designs
  remain unresolved; reporting agreement does not imply estimator equivalence.
  Group-mean anchors and fitted interactions remain outside this route.
- [x] Implement explicit `centering_scope = "anchor_origin"` for ordinary
  additive RSM/PCM JML, with direct or group-mean anchors replacing their facet's centering
  and an unanchored noncenter facet. Sparse interior partial-anchor cases
  agree with native FACETS under these constraints. Preserve existing defaults
  and distinguish fixed anchors from estimated-calibration uncertainty.
- [x] Cross-check ordinary RSM/PCM JML against TAM with matched category
  support, identification and corrections, including sparse assignments and
  supported partial Person anchors. Distinguish default coefficient shrinkage,
  calibration-score adjustments, MLE/WLE, conditional information and weighted
  fit definitions. This scoped agreement does not qualify broader extreme
  anchor configurations or calibration-inclusive inference.
- [ ] **Post-release inference research:** qualify general fair-average and
  bias-comparison uncertainty when calibration is estimated, including dependence between compared results
  and fixed versus estimated anchors. Select an inference method appropriate
  to the estimand and sampling design; enlarging an ordinary-JML covariance
  alone does not solve incidental-parameter bias. Assess coverage, screening
  errors and unavailable results under declared conditions. In 0.2.4,
  common-plan refit/delta intervals remain experimental and ineligible for
  qualified confidence-interval decisions. Existing scoped MML source-anchor
  and joint-cell uncertainty retain their own accepted assumptions and checks;
  this research item does not withdraw or generalize those outputs. Existing
  conditional bias intervals remain diagnostic-only; neither coverage nor a bias screen alone
  establishes fairness of an assessment.
- [x] Add an explicit D-study component-treatment choice that preserves raw
  estimates and distinguishes GENOVA `ALGORITHM` zero substitution from `EMS`
  recalculation. `negative_components` now supports `"raw"` (default),
  `"genova_algorithm"` and `"genova_ems"` for complete balanced univariate ANOVA
  sources with supported crossed or nested facets. Matched executable output
  checks effective components, G/Phi and SEM. Saved results, summaries and
  plots retain the choice and original components. `confint()` pairs adjusted
  points with original-source population intervals and supported plan-difference
  intervals, recording their separate bases without recentering bounds.
  Sampling uncertainty of the adjusted estimator itself remains unqualified;
  the separate delta-estimator comparison API requires raw components.
  Multivariate and incomplete sources retain the raw-only route.

## Intended uses and evidence

mfrmr aims to help users explain ratings, plan assessments and communicate
the uncertainty of their conclusions. The same three purposes serve practical
assessment and research on theoretical constructs. Language assessment is the
main teaching context; configurable facet roles and score definitions support
other applications without requiring separate domain-specific analysis APIs.

| Setting | A question worth answering | Relevant evidence and limits |
| --- | --- | --- |
| Language assessment and speech contests | Would more tasks or raters improve a specified score, and which rubric or rating patterns need review? | G/D-study components and plan comparisons, MFRM category/fit diagnostics and supported feedback. Define whether the target is performance on this speech or proficiency across tasks. Annual comparisons require the separate [common-recording workflow](#across-year-assessments-with-common-recordings). |
| Music performance assessment | How much do pieces, judges and their interactions affect scores for technique or expression? | Map performers, judges, pieces and fixed score components to the supported design. State whether pieces are sampled or fixed. An example of the mapping is not empirical validation in music. |
| Judged sports | How sensitive is a judged performance score to judges, routines and rubric weights? | Use the observed-score or ordered-category route appropriate to the scoring rules. Reliability and severity estimates do not provide winner probabilities, and these models do not automatically apply to race times or match outcomes. |
| Construct-focused research | Are rubric categories, criterion relations and task/rater dependencies consistent with a stated interpretation of the score? | Category, fit, residual and variance-covariance results can inform an argument about internal structure. They cannot alone establish construct validity, explain the cause of an association or distinguish halo from genuine criterion covariance. |

The measurement route fits unidimensional ordered-response models. The
multivariate G-theory route decomposes variation and covariance in observed
scores; it is not a multidimensional latent-variable model. Its current scope
is one or two random measurement facets, with supported crossing/nesting and
fixed score components. More column names do not extend that scope. Criterion
facets, fixed subscore columns and random tasks represent different questions
and must not be interchanged just to fit an example. In each application,
define the rated unit, target population, score coding and generalization
conditions before choosing the analysis.

For readers of *Language Testing*, the intended value is a reproducible path
from an assessment question to interpretable measurement, planning and
feedback evidence. The journal's [author guidance](https://journals.sagepub.com/author-instructions/ltj)
welcomes empirical and theoretical language-assessment research and requires
a contribution to knowledge. Accordingly, the examples should explain what
an analysis changes about score interpretation or assessment design. A list
of functions, an attractive plot or a software comparison alone does not
establish that contribution. Journal publication is a separate research
objective, not a condition for releasing the package.

### Application workflows and completion conditions

The following track 0.2.4 workflow requirements. They extend the
existing examples and result interfaces; they do not replace unresolved
statistical requirements or imply that new estimators have been implemented.

- [x] **Design review before fitting, with reusable figures.**
  Assignment networks accept observed ratings or a planned roster, retain
  unscored isolates and row inclusion, and distinguish graph links from model
  identification. Network plots expose layouts, display-only filters and
  node/edge/coordinate tables. Cluster profiles expose original-unit values
  with inclusion/missingness for custom distribution plots; selected plot
  tables and matrices can be exported in long form.
- [x] **Literature-connected reporting and exploratory interpretation.**
  The network/reporting lesson connects Lamprianou's complementary views,
  FACETS/ConQuest output and L2 speaking/writing applications to existing
  reporting modules. Clustering help defines distances, silhouettes and
  squared-error summaries. The examples retain differences between observed
  scores, latent estimates, agreement and dependability; no new network model
  or cross-analysis validity guarantee is implied.

- [x] **An interval-aware assessment-plan summary.**
  `summary(d, intervals = TRUE, assumption = "normal")` collects supported
  G, Phi and relative/absolute SEM results with facet counts, score weights,
  methods, source context and availability reasons. `parm` selects metrics;
  `reference` uses the existing paired inference. Original estimates and any
  separate REML center are retained. Saved interval results can be supplied
  without recalculation, with checks of their source, plans, weights and
  point estimates. Ordinary `summary(d)` retains its coefficient table.
  Help/tutorial execution, existing plot reuse and fresh-session replay are
  checked; this does not qualify any additional interval method.
- [x] **A connected language-assessment reading path with transferable
  examples.** The G-theory tutorial now leads from bundled data through a
  stated question, design check, analysis, figure, interpretation and saved
  result, with links to the measurement and feedback workflows when those
  answer the question instead. Short music and judged-sport mappings explain
  the same supported roles. Synthetic teaching data are clearly identified;
  current continuous G-theory examples must not be presented as ordered
  MFRM responses or real contest records. New empirical collections in all
  three domains are not prerequisites for this workflow. Basic operations
  precede optional designs/methods; detailed mathematics remains in linked
  help. Execution and editorial checks do not measure novice understanding.
- [x] **Figures that answer an assessment question.** Connect the reading
  path to existing `plot()` methods: component and covariance plots explain
  variation and score relations, including interactions and combined residuals;
  planning curves with
  pointwise interval ribbons compare specified counts; forest plots compare
  interval methods or supported plan differences on a common scale; category,
  Wright-map and diagnostic plots support measurement interpretation. Use
  color with redundant line/shape distinctions and a usable monochrome
  option. Panels should isolate a meaningful facet or score, with comparable
  axes, rather than multiply every method-by-score combination. Retain exact
  plotted values and notes outside the figure, including absent intervals.
  Completion includes readable standard-size output and saved-result reuse;
  a new 3D interface is not required.
  The selected teaching paths now connect these views to their questions,
  exact values and notes. Measurement examples include a focused fit screen
  and its identifying table; saved plots redraw through their documented
  conversion routes. Color/monochrome figures and saved reuse were checked
  within this scope. This is not an audit of every specialized plot at every
  display size or a study of novice understanding.
  Measurement notes distinguish coded-score direction from favorable
  performance, fit from judge agreement, conditional interaction bias from
  unfairness, and adjacent-category Steps from decision cuts. The tutorial
  keeps explicit rubric wording alongside saved figures; the package does
  not infer a construct's direction from its name.
- [x] **A construct-evidence interpretation guide.** In existing methods/help
  pages, connect a substantive hypothesis to its design, observable output,
  possible competing explanation and justified conclusion. For example,
  examine whether fluency/accuracy covariance occurs between persons or also
  in task/rater components, and what this implies for reporting separate
  scores or a composite. State expected patterns before examining results and
  explain conflicting findings as well as supportive ones. Explain why high
  G/Phi, good fit, rater separation and observed criterion covariance answer
  different questions. Fixed composite weights require a substantive
  rationale; selecting them only to maximize reliability can change the
  construct. Separate evidence from the ratings from external validity
  evidence and from unimplemented multidimensional or direct halo models.
  The methods guide now supplies this claim-to-evidence structure and its
  references. The G-theory lesson works through an unresolved covariance
  result, with a figure, uncertainty, reporting language and saved reuse;
  the visual guide maps figures to their interpretive limits. These are
  checked teaching materials, not an empirical construct-validation study.

For plan selection, retain source-design and future-plan differences, score
units and user-specified decision criteria. A pointwise ribbon is not a
simultaneous confidence band; overlap is not a paired test. Screening many
plans does not provide selection-adjusted uncertainty or establish an optimal
plan. The meaning of relative versus absolute decisions and the practical
burden of tasks and raters must accompany any recommendation. There is no
universal adequate-reliability cutoff or automatic winner rule.

### Remaining visualization refinements

The following track refinements to existing result interfaces before adding
another graphics system. Unchecked items remain planned work:

- [x] Make facet-location plots neutral by default: remove automatic
  magnitude bands and judgmental labels that could be mistaken for
  equivalence or calibration decisions. Practical equivalence uses an
  explicitly justified contrast bound and its uncertainty. New rater profiles
  omit bands; explicit guides use gray and `Band` records numerical ranges.
  Saved older plots retain their display; redraw from the saved fit and
  matching diagnostics to adopt the new convention without refitting.
- [x] Let users focus on named facet levels in a Wright map while preserving
  fitted coordinates, a shared scale and disclosure of omitted levels.
  `plot(fit, highlight = list(Rater = c("R01", "R02")))` marks selected
  labels with `> ` and retains them in addition to the usual compact selection.
  Both renderers and saved ggplot conversion preserve the selection; this is
  a display control, not a statistical flag or a change to estimation.
- [x] Display saved latent-population coefficient and contrast intervals
  through `plot()`, retaining unavailable bounds, predictor coding and
  experimental qualifications. Use `plot(ci)` for coefficients or
  `plot(ci, type = "contrasts")` for saved linear combinations; `as_ggplot()`
  preserves the same values. Residual variance remains in the original table
  on its own scale. General prediction curves are a separate step.

Dense integer-count D-study grids and residual PCA displays already exist;
their teaching paths should expose those capabilities. MFRM simulation and
G theory answer different score and planning questions, so using both is not
mandatory. A general Plotly renderer and arbitrary-facet simulation planner
are later extensions, not prerequisites for these refinements. Common-recording
school comparisons share the linking assumptions and unverified workflow
boundary described below for annual assessments.

## Version allocation: 0.2.4 and later

Three descriptions distinguish availability from scientific maturity:

- **Available within the stated scope:** implemented for the documented model,
  design and assumptions. This does not imply suitability for every dataset.
- **Incomplete / experimental:** a result can be calculated, but a named aspect
  of its statistical performance or interpretation remains unestablished.
- **Unavailable:** the operation is not implemented or is not supported for
  the selected model or data. An experimental label does not supply a missing
  method.

An experimental method may pass numerical checks. Conversely, a supported
method may fail on particular data. Keep numerical status, uncertainty type
and interpretation notes with saved results and exported tables.

The unresolved issue depends on the procedure. Two-family GPCM retains
incomplete general identification and boundary qualification; available local
intervals do not settle those questions. An integration failure may be repaired
by explicit higher-order refitting. A slope approaching zero while its location
and steps diverge is a different problem: response probabilities can remain
finite, and more integration points do not supply valid intervals for those
original coordinates. The component-interval help explains this distinction;
boundary-aware estimation and inference remain separate development work.
Corrected GPCM JML estimates an
adjusted-equation root, and its root covariance does not establish centering
at the structural truth. Common-plan refit/delta intervals have demonstrated
small-sample undercoverage and remain ineligible for inferential use.
Population intervals, slope profiles, REML target profiles and the extended
G-score method retain their stated asymptotic or experimental calibration.
Increasing simulation repetitions alone cannot resolve a wrong target,
remaining bias or an unsuitable reference distribution.

Conservative regions have a different basis. The mean-square region has a
joint coverage lower bound for its declared fixed-score future plans under
independent normal ANOVA strata; the signed covariance regression region has
its own pointwise conservative argument. Their numerical checks do not prove
all floating-point errors harmless, and their bounds can be uninformatively
wide. Approximate F has no corresponding exact pivot and has documented
undercoverage in small sources. The `Validation` column distinguishes the
approximation from the experimental numerical projection of a conservative
region. Conditional Person posterior intervals instead condition on their
calibration/prior; they do not become calibration-inclusive confidence
intervals by passing integration checks.

| Purpose | Included in 0.2.4 within its documented scope | Incomplete or experimental | Planned after 0.2.4 |
| --- | --- | --- | --- |
| Measurement | RSM/PCM MML and JML; RSM/PCM CML structural estimates and identified interaction contrasts with conditional-information intervals; one-slope-family GPCM; supported diagnostics, category outputs, reliability/strata, scoring and calibration reuse. | Two-family GMFRM estimation, conditional scoring and available intervals; corrected GPCM JML point/scoring results; Jeffreys-penalized RSM/PCM point estimation; population intervals whose performance is not fully established. | MML fixed Person anchors, initially RSM/PCM; broader GMFRM/population uncertainty evaluation; scoped native Bayesian estimation and multidimensional rubric models; later population, timing and attribute extensions as described in the post-release priorities. |
| G-theory planning | Supported crossed/nested G/D studies, identifiable incomplete-source estimation, composites/differences, complete future plans, plots including signed error-source contributions by plan, balanced ANOVA component SEs/intervals and SEM intervals, one-facet G/Phi intervals, approximate MLS individual-plan G/Phi intervals for balanced two-crossed-facet sources, and scoped paired plan-difference intervals. | Explicit delta coefficient SEs/normal-reference intervals; experimental approximate-F and mean-square-region coefficient intervals; target-REML variance/covariance component, G/Phi and SEM intervals for balanced/identifiable incomplete sources; signed balanced-source covariance intervals. Plots retain original points, numerical failures and method-specific qualifications. General small-sample calibration remains incomplete. | General bootstrap alternatives, robust/simultaneous inference and sparse or unequal future rating plans. |
| Feedback and decisions | Supported individual reports, agreement/reference comparisons, criterion accuracy, centrality, DFF sensitivity checks, exploratory all-pair bias summaries and plots with explicit availability, conditional cut probabilities and fixed-plan classification/SEM. | GMFRM feedback and descriptive diagnostics; common-plan refit/delta intervals, including their Jeffreys routes, remain numerically available but inferentially unqualified. General screening accuracy and performance under estimated or shifted ability distributions are not established. Conditional bias screens do not supply collection-wide multiplicity control. | Qualified calibration-inclusive decisions, broader diagnostic evaluation, additional-rating allocation and rank/winner uncertainty. |

Standalone FACETS-result visualization uses `read_facets_results()` and `plot()`
for reported element measures and fit statistics. Source IDs, labels, precision,
status and unavailable rows remain available for inspection and export.
Shared-axis Wright maps require compatible source coordinates to be declared.
This descriptive import does not provide external frozen-calibration scoring,
joint uncertainty or a validation of the source analysis. Optional Graphfile
imports redraw reported category-probability and expected-score coordinates,
preserving scale/category identity, precision and unavailable points. They do
not align curves with element measures or reconstruct an external calibration.
Broader external-calibration reuse remains a later extension.

Anchors, linking/imports, feature analysis, assigned-score imputation and
eligible pooling, and separate random-rater/testlet models remain included
within their documented restrictions. Stan/brms code export supports its
implemented combinations: RSM/PCM and fixed-population one-family GPCM in both formats,
and two-family GPCM in Stan. Default one-family GPCM fits can retain an
estimated intercept-only normal population in Stan, with explicit priors and
population mean/SD summaries connected to plots, intervals and reports.
Population regression, estimated-population brms and joint-draw scoring remain
later extensions. Supported fixed facet/group and retained step constraints
are preserved. Code export is not a native Bayesian estimator or a guarantee about
prior choice or credible intervals.

Location anchors use internal coordinates; ordinary fit uncertainty conditions
on their supplied values. The bounded source-covariance interval extension
above is opt-in. Person direct/group anchors require JML; MML rejects them. New ordinary
fits center each declared facet across all levels, including anchors and group
totals. Use `centering_scope = "remainder"` to reproduce the earlier convention.
For ordinary additive RSM/PCM JML, `centering_scope = "anchor_origin"` instead
lets direct or group anchors replace their facet's centering, as FACETS does.
This needs an unanchored, active noncenter facet. Group targets are repeated
means, not native per-element contributions. The ordinary constrained
likelihood is retained: native multi-group numerical results and general
extreme handling are not reproduced automatically. Thresholds
and slopes are not carried by the location-anchor
table. See the [linking tutorial](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-linking-and-dff.html)
for a complete example and the distinction from fixed-calibration scoring.

## Anchor alignment and its qualification

Ordinary fitting and anchor review now accept `centering_scope = "facet"`
(default), `"remainder"` (legacy reproduction), and `"anchor_origin"`
(direct or group anchors replace centering in ordinary additive RSM/PCM JML).
The default convention centers the whole declared facet, including fixed values. An anchor does
not implicitly select the population mean, variance, threshold structure or
uncentered facet. These choices must match before results can be compared with
TAM or ConQuest. Ordinary fitting, saved refit settings and the scoped
population-model correspondence and the migration workflow are checked;
release integration remains incomplete. The fixed-SD, intercept-only RSM/PCM
anchor-origin route has conditional facet/population intervals and optional
independent-source covariance propagation. Broader anchored population
specifications remain outside that interval extension. One-family GPCM slope and curve intervals have a separate supported
scope, described below.

Completion requires more than matching a few estimates:

- [x] Define the constraint equations, external comparison settings and
  affected workflows.
- [x] Verify direct and group constraints, contradictions, free dimensions
  and derivatives in the shared calculation.
- [x] Integrate the convention into ordinary RSM/PCM fitting, including
  matched MML/JML settings and an explicit route for reproducing old behavior.
  Public fitting, review and legacy refitting are implemented. Fixed-population
  RSM/PCM comparisons pass. The estimated-population configuration has a
  checked identifying design and matched response probabilities/likelihoods;
  its interval restrictions remain. This does not assert agreement of external
  estimated-population optimizers or equivalent software defaults.
- [x] Verify SEs and affected scoring, diagnostic, reliability, linking and
  calibration outputs; qualify supported extensions separately.
  Conditional fixed-population model/sandwich covariance and facet contrasts
  are checked, including fixed group means and implied fixed levels.
  Anchored RSM/PCM portable calibration, saved reuse and conditional scoring
  are checked. Ordinary fit/bias and reliability/strata now have independent
  calculation checks. Linked refits preserve direct target and JML Person
  anchors; fixed target rows retain values without a contrast or test.
  Group-anchored refit DFF remains unsupported. One-family GPCM model/sandwich
  slope and curve uncertainty is checked for shared or different step/slope
  owners, direct/group anchors and fixed/estimated normal populations.
  These intervals condition on fixed anchors; their availability does not
  certify fitted-object scoring, which has separate integration checks.
  Profile-slope, native-location and portable GPCM routes retain their anchor
  exclusions. Corrected JML, native two-family GPCM and testlet/random-rater
  fitting do not accept anchors. Stan/brms export retains supported fixed
  facet/group anchors in RSM/PCM and one-family GPCM specifications; their
  uncertainty is conditional on the supplied values.
- [x] Provide beginner examples and migration instructions; preserve the
  original meaning of saved results and exported calibrations.
  Summaries, specification tables and reproducibility records expose the
  centering convention. The linking tutorial distinguishes reopening,
  reproducing and changing an analysis. Existing calibration files retain
  their original values and labels; new extraction requires its current
  source-validation checks.
- [ ] Complete the affected package, example, website and environment checks.
  The development website's executable examples and tutorials have been
  checked locally. Final release-source and supported-environment checks remain.

Existing results will not be converted merely by changing their labels or
reloading a file. A fit under a different constraint system generally needs
re-estimation. Anchor alignment alone does not add uncertainty from estimating
anchors; the bounded source-covariance extension requires explicit arguments.
Neither promises equivalent defaults across programs.
`make_anchor_table()` preserves fitted numeric values by default. Rounding
individual anchors can break their joint zero sum; use `digits` explicitly
for a display copy and review any rounded values before recalibration.

Conditional intervals for supported ordinary RSM/PCM MML facet estimates
already exist; verifying them under the revised constraints is part of this
release work. This differs from propagating uncertainty in externally
estimated anchors. Bias-screening SEs and conditional bounds retain their
screening interpretation. For one fitted two-facet interaction in fixed-N(0,1),
fixed-grid direct RSM/PCM MML, `mfrm_facet_intervals(interaction = ...)` now
provides joint-information cell and contrast intervals. This separate extension
uses all nuisance-parameter uncertainty; it is not automatic anchor alignment,
a replacement for screening, or a guarantee of simultaneous inference.
Anchors, GPCM, population regression and multiple interaction terms remain
outside this joint-cell interval route.

## Across-year assessments with common recordings

An annual speech contest can have different contestants but use the same
recorded speeches for rater calibration. The recorded performance, rather
than the identity of a returning judge, can connect years. The intended
outcomes are changes in each judge's severity, a panel-wide shift in scoring,
and differences between annual contestant groups on a defensible common scale.
This is not a study of individual contestant growth.

Two approaches need different qualifications: jointly estimate years with a
shared unknown measure for each common recording, or fix previously estimated
recording measures in later calibrations. Shared performances do not require
known anchor values. Fixing estimated values excludes their source uncertainty
unless that uncertainty is separately propagated. A common three-minute task
format or unchanged criterion names alone does not establish scale invariance.

Existing functions provide parts of this analysis, but a complete common-recording
workflow and its year-difference intervals are **not yet verified**. Person
anchors require JML; current MML rejects them. `detect_anchor_drift()` removes
a common-element offset: using the judges themselves as the linking set can
remove a panel-wide severity change. Its SE ratios are descriptive screens,
not formal tests of longitudinal change. `anchor_to_baseline()` checks that
fixed values were retained; that check does not establish their stability.

The [linking guide](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_linking_and_dff.html)
and [speech-contest design example](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-linking-and-dff.html#annual-speech-contests-with-common-recordings)
explain these choices and current limits in the development documentation.
A new longitudinal estimator or formal uncertainty procedure is not a release
prerequisite. The later workflow must preserve
individual ratings before consensus, distinguish training from operational
ratings, and review video-versus-live scoring and the stability of criteria
and categories. It must allow annual severity to change without imposing
the same panel mean separately in every year.

### Comparison-specific identification review

Native RSM/PCM CML now supplies full-rank structural estimates and conditional
information intervals through `fit_mfrm(method = "CML")` and
`mfrm_facet_intervals()`. It conditions on Person totals and requires no ability
population distribution. This addresses fixed-exposure incidental-parameter
bias under the documented conditional-model and information-growth assumptions;
a more accurate JML covariance would not do so. Increasing Person count alone
does not supply information in every identified structural direction. The
model must remain valid for the actual rating assignment and missingness process.
Its separate result class has no ability estimates or population SD.
The existing population-SD-standardized contrasts use the full joint MML delta
method, including uncertainty in the fitted SD. Matching full RSM/PCM MML
interaction fits now support this transformation via `comparison_review` in
`mfrm_facet_intervals()`, under an explicitly declared common intercept-only
normal population; native intervals also support origin-specific means.
Regular standardized inference requires an identifiable, correctly specified
marginal model and a true population SD strictly above zero. Finite-quadrature
agreement diagnoses numerical sensitivity; it does not establish these
assumptions or guarantee continuous-model inference as sample size grows.
General GPCM inference follows
MML; JML remains useful for descriptive estimates and FACETS comparisons.
Explicit comparison-only CML also supplies intervals for identified interaction
contrasts in deficient models. Neither route guarantees arbitrary finite-sample
coverage or completes the broader school/annual calibration workflow.

The common-recording workflow must distinguish a shared measurement scale
from an identifiable differential-facet comparison. For example, a judge who
only rates School A may contribute to a linked calibration while their
School A-versus-B effect remains unobserved. Shared recordings supply that
particular comparison only when their group identities and rating contexts
support it, or when additional assumptions are explicitly imposed.

The comparison contract distinguishes a rater's school difference relative
to a declared panel, the difference between two raters' school differences,
and a separately modeled population contrast. The panel and its weights must
remain explicit. PCM response comparisons also depend on the step owner.
Bounded RSM/PCM checks support this distinction, including partial identification
and comparisons that remain unidentified after adding neutral common recordings.
`describe_mfrm_data(comparisons = ...)` now exposes a bounded prospective
RSM/PCM interaction review with explicit contrast weights. It distinguishes
full, partial and target nonidentification under the conditional response model;
positive MML conditional ranks remain separate from marginal identification.
`IdentificationBasis` distinguishes unrestricted-Person response-model
identification, conditional identification relying on population restrictions,
and CML conditional support. The accompanying explanation separates common
population assumptions from scale coding; a free-Person map does not make
MML inference distribution-free. Unsupported external-reference and broader
invariance workflows remain outside this scoped review.
Its results can accompany DFF summaries, plots and reports after response/origin
alignment checks. They do not classify the residual/refit effects themselves.
For matching joint fits, `interaction_effect_table(fit, comparison_review = ...)`
and `summary(fit, comparison_review = ...)` return descriptive interaction
contrasts after full conditional-rank and numerical checks. The executed
teaching example allows group-specific population means; MML's positive
conditional rank remains distinct from global marginal identification.
Explicit `fit_mfrm(fit_scope = "comparisons", comparison_review = ...)` now
provides a separate descriptive result for invariant targets in rank-deficient
RSM/PCM models. It preserves the observed likelihood and retains unavailable
targets, with recession/numerical checks and the same MML identification limits.
With a CML review, it instead uses conditional support at observed Person totals,
optimizes only identified directions and supplies conditional-information SEs,
pointwise 95% Wald intervals and joint covariance for identified targets.
Unidentified targets remain missing. Broader school-calibration qualification
and finite-sample interval performance remain separate work.
Saved CML comparison fits now use `mfrm_facet_intervals(fit)` for a selected
confidence level, existing interval plots and APA tables. Missing estimates
retain labeled rows without points; the same fit and review remain in the
saved result. This display route does not add Person scoring or ordinary
fit diagnostics to comparison-only objects.

Bounded GPCM checks distinguish location, component-slope, effective-product
and response-curve comparisons. Unequal slopes can reverse a response contrast
across ability even when the parameters are locally identified. The reviewed
one-family JML/MML and two-family MML maps have explicitly limited local
numerical evidence; disconnected-product counterexamples retain the existing
fit rejection. Predicting an unobserved crossing requires the product-model
assumption. These checks do not add school interactions to GPCM, establish
global identification, or provide automatic GPCM comparison reporting.

- [x] For the supported prospective RSM/PCM interaction review, specify the
  requested comparison and distinguish identification of all
  free model parameters, identification of selected comparisons despite other
  unidentified parameters, and nonidentification of the requested comparison.
  Keep an unchecked case separate from demonstrated nonidentification.
- [ ] Report the identification basis: observed overlap under the response
  model, fixed external references, common-population restrictions or other
  invariance assumptions. Separate arbitrary scale coding from restrictions
  that supply substantive information. A returned number is not evidence that
  the observed design identifies its sign.
- [ ] Establish comparison-level checks first for RSM/PCM, including step
  ownership and JML/MML differences. Review one- and two-family GPCM through
  their actual nonlinear probability maps and supported configurations;
  a local rank check does not establish global identification. Component
  discriminations and effective products at observed crossings are distinct
  targets. Record unsupported combinations rather than fitting another model
  under the requested name.
- [x] Carry the scoped prospective comparison states and assumptions separately
  into existing DFF summaries, plots and reports. Keep finite-estimate existence, numerical convergence,
  interval availability and sensitivity of effect direction separate from
  identification. For varying response curves, define the ability range and
  effect scale instead of reporting an unconditional positive/negative label.
- [x] Deliver descriptive fitted interaction contrasts for matching native
  RSM/PCM joint models with full conditional rank, preserving the declared
  population assumptions, source alignment, numerical checks and unavailable
  states in the table and summary. No formal DFF uncertainty is supplied.
- [x] Deliver descriptive partial estimates for the scoped RSM/PCM interaction
  targets through explicit comparison-only estimation. Preserve the observed
  likelihood, invariant targets, full-fit guards and unavailable rows; check
  JML recession and numerical adequacy without reporting arbitrary cell effects.
- [x] Supply CML conditional-information intervals for identified RSM/PCM
  interaction contrasts in deficient assignments, preserving unavailable rows
  and checking conditional support, finite-MLE existence and information.
- [ ] Qualify broader school/annual inference for the declared targets and
  assumptions. Descriptive partial estimates and conditional MML ranks do not
  establish global marginal identification or interval/test performance.

The remaining items are prerequisites for the later verified common-recording/DFF
workflow. The prospective review, descriptive JML/MML estimates and asymptotic
CML intervals remain distinct. They do not establish global marginal
identification or calibrated DFF classification, and no new 0.2.4 release gate is added. The remaining work does not
authorize arbitrary constraints to make a deficient model fit.

### Planned MML Person anchors

Fixed Person anchors are a requested extension after 0.2.4, initially for
RSM/PCM. They remain **unavailable in MML** until the following conditions are
met; shared unknown recordings in a joint fit are a different design.

- [ ] Define a likelihood that conditions on the known measures of reference
  performances and integrates over the abilities of unanchored participants.
  Specify which participants inform the population distribution; reference
  recordings must not silently become a random sample from that population.
- [ ] Establish compatible location/scale constraints, anchor checks and
  population-parameter identification. Retain the same performance ID across
  panels, without forcing each panel's mean severity to zero separately.
- [ ] Verify the objective, derivatives and optimization with independent
  small calculations before broader numerical studies. Check a connected
  two-school design, insufficient links, extreme responses and conflicting
  constraints; distinguish numerical success from inferential performance.
- [ ] Report structural SEs/intervals conditional on fixed reference values,
  retaining unavailable uncertainty. Propagation of estimated reference-value
  uncertainty and formal school/year population contrasts are separate
  deliverables, not implied by accepting anchors.
- [ ] Align fitting, scoring, reports, saved reuse and beginner examples.
  Qualify GPCM and other model extensions separately before advertising them.

### Differential facet functioning: displays and remaining inference

- [x] Offer existing `plot(dff, type = "summary")` and
  `plot(dff, type = "heatmap")` routes for `analyze_dff()` results, with saved
  data and interpretation notes. Contrast heatmaps use `metric = "contrast"`;
  residual-cell heatmaps use `"obs_exp"` or the descriptive `"t"` metric.
- [x] Distinguish residual differences in score units from linked-refit
  differences in logits. Residual comparisons have no confidence intervals;
  optional refit intervals omit estimated-anchor uncertainty and cross-refit
  covariance. Neither route establishes a formal DFF decision.
- [x] Pair figures with group direction, cell counts, response exclusions,
  unavailable comparisons and linking support in the help and tutorial.
  Summary plot data retain every source comparison and its display status;
  both views preserve method settings and available response-matching records.
  Connectivity for joint calibration does not alone identify every
  rater-by-school comparison, particularly when raters work in only one school.
- [ ] Evaluate formal DFF uncertainty after the linking/anchor target is
  established. Keep method-specific matching and assumptions visible in
  Mantel--Haenszel and ordinal-logistic sensitivity comparisons; do not pool
  their effect scales into a common axis without justification.

The displays are existing 0.2.4 capabilities. Formal DFF uncertainty and MML
Person anchors are later work, not newly completed estimators or new release
requirements. See the [DFF plot help](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_dif.html)
and the linking guide above for the current interpretation boundaries.

## Model scope

RSM uses shared category steps. PCM uses steps belonging to the declared
`step_facet`; GPCM additionally declares the facet whose levels have slopes.
These roles may differ where supported. The two-family product-slope model
has its own restrictions, including second-owner steps. Multiple independent
threshold owners and arbitrary combinations of model extensions are not
implied by accepting arbitrary column names.

Saved one-family GPCM Person scores from `predict_mfrm_units()` can now be
attached to `mfrm_results(..., scores = ...)` for reports, export and saved
replay. EAP, posterior SD and continuous conditional posterior intervals retain
the actual scoring priors and numerical review states. They exclude calibration
and population estimation uncertainty and do not replace diagnostic normal bands.

Explicit rating contexts in `category_curves_report(fit, newdata = contexts)`
now support native one- and two-family GPCM MML curves and cumulative 50%
thresholds, with source readiness and unavailable intervals retained. This
extends descriptive calculation; two-family inference remains provisional.

Read the [GPCM guide](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-gpcm-scope.html) and
[interval guide](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_interval_guide.html) before selecting an uncertainty
method. Current distinctions include:

- Ordinary JML location SEs are exploratory. Corrected-JML local root SEs
  do not supply formal confidence intervals for structural parameters.
- Computed GMFRM bounds do not establish their repeated-sample coverage.
  Partial or unavailable results retain their reasons.
- Two-family step/curve intervals, ordinary fit/bias tests and Wright/Pathway
  maps are unavailable. Other supported outputs have their own interpretation.
- Conditional Person scoring holds calibration fixed and excludes uncertainty
  from estimating those calibration parameters. A prior appropriate for one
  cohort may be inappropriate for another.
- High rater separation reliability indicates distinguishable severity
  differences; it is not evidence that raters agree.

Incomplete assignments, extreme scores, missing categories and weak links
can affect estimation and precision differently. A connected rating graph
alone does not establish identification. No single sample-size threshold
establishes that all supported methods will work well.

## Generalizability theory

`mfrm_g_study()` and `mfrm_d_study()` support one or
two named random facets, crossed or with one nested within the other while
Persons are crossed. Score components are fixed. ANOVA handles complete
balanced data; MINQUE(0) handles identifiable incomplete or unequal sources.

D-studies project complete balanced future plans, including weighted
composites and signed score differences. They do not estimate the reliability
of an arbitrary sparse future roster. Negative or indefinite component
estimates remain visible; availability is assessed separately for each metric.

`mfrm_multivariate_d_compare()` provides approximate paired-delta intervals
for prespecified plan differences with two crossed facets under an explicit
normal-random-effects assumption. These intervals do not supply component
confidence intervals or uncertainty bands around each D-study curve.
Measurement SEM and sampling uncertainty in an estimated variance component
are different quantities.

For balanced ANOVA, `confint()` now provides component sampling SEs and
pointwise Ting MLS intervals for one score or a fixed composite, under an
explicit normal-random-effects assumption. One or two crossed random facets
and the supported balanced nested design are included. Negative estimates
and unrestricted endpoints are retained alongside the interval's intersection
with nonnegative variances. For two original scores, explicit `gci` and
`regression_region` methods now supply signed covariance-component intervals.
The generalized method has approximate coverage and separate endpoint Monte
Carlo diagnostics; the conservative enclosure can be extremely wide with few
facet levels. SE and interval availability are reported separately. Scalar
component intervals also have an explicit experimental `reml_profile` option
for identifiable incomplete sources. Original MINQUE points remain unchanged;
separate REML centers and numerical diagnostics accompany squared-unit bounds.
This inversion does not calculate a sampling SE or qualify nominal coverage.
Two-score covariance also has an explicit experimental joint `reml_profile`
option for identifiable incomplete sources, preserving signed endpoints and
separate REML centers. Its chi-square calibration can under-cover with few
facet levels; incomplete-source coverage is not established. It does not
replace the balanced methods or become an automatic default.

For one-facet G, explicit `spectral_f` intervals additionally accept retained
incomplete or unequal source ratings. They project out facet effects and
invert an exact F pivot under independent normal Person effects and residuals,
with positive residual variance and residual degrees of freedom. Paired plan
differences map the same confidence set. Original MINQUE points and unavailable
states remain visible. Removing facet directions can lose information; exact
coverage does not imply narrow intervals or robustness to selective missingness.
This is not a Phi, SEM, nested or multifacet method, and is not an automatic default.

G/Phi additionally have explicit `method = "delta"` sampling SEs and
normal-reference intervals for the original ANOVA/MINQUE estimator, including
supported nested and incomplete sources. This is a first-order approximation,
with documented undercoverage and unavailable estimates in some small or
incomplete sources. The full component sampling covariance is propagated;
coefficient SE is distinct from measurement SEM. Tables, forests and ribbons
retain wide bounds outside `[0,1]` and their qualifications. It does not
replace existing defaults or supply SEM or paired-difference intervals.

G/Phi and measurement SEM have an explicit experimental `reml_profile` option for identifiable
incomplete or unequal sources as well as balanced sources. It fits the used
ratings under normal effects and preserves the original ANOVA/MINQUE points,
reporting the separate REML estimates and numerical diagnostics. Its
chi-square calibration is approximate; finite-sample and boundary checks do
not yet justify an automatic default. Broader incomplete-source plan-difference
inference remains separate. SEM limits
come from a direct error-variance profile and a square-root transformation.
They describe an interval around the REML center, without enumerating remote
disconnected accepted regions. Limited boundary checks showed below-nominal
inclusion; providing this explicit approximation does not qualify a default.
`plot(g, intervals = TRUE, assumption = "normal")` shows the existing component
intervals for one score, multiple score panels or a fixed composite, retaining
negative estimates and unavailable reasons in base and ggplot outputs.
For individual D-study plans
from a balanced one-facet source, `confint()` now supplies exact F intervals
for G under independent normal random effects. The source degrees of freedom
are retained when transforming to different future counts. Phi now uses a
generalized confidence interval with separate Monte Carlo endpoint diagnostics;
it does not guarantee exact frequentist coverage. For balanced two-crossed-
random-facet sources, individual-plan G/Phi intervals now default to approximate
MLS null inversion. Undefined widths are conservatively retained and flagged
separately from numerical availability. Normal-model checks support this choice
within the evaluated designs; it does not guarantee uniform coverage or narrow
intervals in small sources. Alternative explicit experimental choices remain:
`"approximate_f"`, `"mean_square_region"` and `"reml_profile"`. None is selected
automatically. The mean-square region requires lpSolve and can be very
conservative. The first two require a
complete balanced crossed ANOVA source and independent normal effects.
REML profiles use the normal likelihood of the used ratings and also accept
identifiable incomplete or unequal sources; they require lme4 and minqa.
A forest `plot()` compares methods within future plans on one shared axis,
with a common legend and retained unavailable results. Separate panels remain
optional.
For ordinary planning, `plot(d, metric = "Phi", intervals = TRUE,
assumption = "normal")` calculates and overlays coefficient intervals on the
existing D-study curves. One method is shown at a time; selected scores or
composites are handled together. Saved intervals can optionally be reused,
using a list when several scores/composites are selected.
Ribbons retain gaps, method limitations and numerical diagnostics. Their
appearance does not establish simultaneous coverage across scores or metrics.
Small normal-model evaluations of the approximate F method
found coverage, width and availability limitations, including at zero
components and changed future counts. Delta-method SE results do not alone
validate coefficient intervals. A preliminary comparison of joint-parameter
Monte Carlo and a basic parametric bootstrap found different limitations:
Monte Carlo intervals can be very wide, while the evaluated bootstrap rule
can withhold intervals at inadmissible point estimates and miss true values
even among returned intervals. These findings concern the specific procedures
evaluated, not all Monte Carlo or bootstrap methods. Neither alternative is
currently a public method or a qualified default. A missing point estimate
does not by itself make a confidence interval unavailable; the existing
methods keep these statuses separate. A joint-deviance confidence-region
candidate also showed width limitations in a bounded feasibility assessment:
mathematically justified joint coverage does not by itself ensure useful
coefficient precision. It remains a research construction. Further method
selection distinguishes G from Phi and retains boundary and nuisance-parameter
uncertainty. The MLS route adds a checked approximation for balanced individual
plans; incomplete-source calibration remains separate. Wide intervals remain visible even when they provide
limited help in choosing a plan. There is no universal acceptable coefficient
interval width. Specify the intended decision and acceptable precision before
comparing methods; a narrow interval is not evidence of accurate coverage.
Providing useful calculations does not require narrow intervals for every
small or sparse source. See the
[coefficient-interval help](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_multivariate_d_study.html)
and the G-theory tutorial for reasons, results and references. These limits
do not imply that all two-facet interval methods are invalid. Expanded
paired-plan intervals also remain under review.
For one-facet G differences, `confint()` with a reference plan now maps the
entire F confidence set, including interior extrema. This supplies
model-based coverage of at least the requested level, without extending the
two-facet delta approximation to other designs. One-facet Phi differences
now map the entire generalized interval, retaining approximate frequentist
coverage and joint Monte Carlo endpoint bands. Both retain the dependence
between plans; subtracting marginal limits is not the calculation.

SEM sampling intervals are now available from balanced one/two-facet crossed
and supported nested sources. `confint(d, parm = "RelativeSEM"` or
`"AbsoluteSEM", assumption = "normal")` combines the source mean squares,
uses chi-square or MLS error-variance limits, and takes square roots. The
single-term chi-square case is exact under its positive-variance normal model;
MLS remains approximate, with undercoverage/conservatism documented. One-facet
SEM differences map their common error-SD interval through `reference`.
SEM curve ribbons and saved interval forests use score units.

Balanced nested G/Phi intervals and comparisons now use the one-facet
distributional reduction when every future child count per parent equals
the source count. Parent counts may vary; both facets remain random. G
retains exact normal-model inference and Phi retains approximate GCI coverage.
Nested SEM differences need a common future child count across plans, which
may differ from the source count. They preserve the chi-square/MLS qualification
of the base interval. General balanced nested G/Phi intervals now accept
explicit experimental approximate-F and mean-square-region methods. The
F derivation uses expected mean squares, with discrepancies in printed
nested Phi formulas explained in help. Limited checks identify severe
boundary availability losses for approximate F and wide region intervals.
General crossed/nested two-facet G/Phi/SEM comparisons accept
`method = "mean_square_region"` with `reference`: the difference is enclosed
using projections of the same simultaneous source region. Coverage is
conservative under the stated normal model; the enclosure need not be the
tight image and can be very wide. The region method also supports individual
SEM intervals. These explicit choices do not qualify an automatic default.

Plots include source-component panels, covariance heatmaps, D-study curves
and facet-count panels, with colour and monochrome options. See the
[G-theory tutorial](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-gtheory.html). These observed-score analyses
do not estimate latent MFRM reliability or pass/fail classification accuracy.

G/D-study and paired-comparison objects now enter `mfrm_report()` and the
shared table/CSV/HTML export workflow directly. Supplied saved intervals retain
source checks, method qualifications and unavailable rows. The editable
`templates/gtheory-report.Rmd` joins source design, score weights, components,
G/Phi, error variances, SEM, plan contrasts and figures with manuscript prompts.

## Rater feedback across application areas

Rater networks now include signed pairwise alpha, magnitude-weighted network
severity/SWS/PUS, person-cluster halo contrast intervals and an optional binary
ERGM adapter using statnet. All connect to reports and full-table export.
These are complementary observed-score/network analyses: SWS/PUS have no
calibrated universal cutoffs, bootstrap intervals condition on the observed
rater set and withhold undefined resamples, and ERGM requires a declared tie
threshold, missing-dyad assumption and backend convergence/GOF review. Valued
ERGMs, estimated-edge uncertainty and general rater-population halo inference
remain outside this adapter's scope. See the network guide for examples.

`mfrm_residual_network()` connects fitted standardized residuals to signed
correlation networks, optional common-person hierarchical groups, three plot
views and the shared report API. Groups remain exploratory; EGA, jointly fitted
residual networks, automatic dimensionality decisions and group-stability
inference are not implemented by this route. The help explains validation and
the separate supervised role of random forests in rater-type research.

The supported reports distinguish severity, fit, category use, agreement,
residual dependence and accuracy against a supplied criterion. A screening
flag requires substantive review; it does not demonstrate rater incompetence
or justify automatic exclusion. Individual interval overlap is not a test
of the difference between two raters.

Centrality is currently described by RSM residual/fit indices and the spread
of rater-owned PCM thresholds. Halo networks describe observed-score
associations; they do not separate genuine criterion relationships from an
impression spreading across criteria. A horn effect is an unfavorable
impression spilling over into other ratings, not a negative correlation or
high severity alone. No dedicated horn classification is available.
Direct severity/centrality (FM-SC) and halo mixture (MRFM-H) models are not
implemented in 0.2.4. See the
[methods guide](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_methods_reference.html)
for the distinction between these targets and local dependence.

Conditional probabilities of being above a cut, fixed-plan classification
accuracy/consistency, and future performance are separate targets. Report
which decision rule and population were used, and whether calibration was
held fixed. The [reporting tutorial](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-reporting-and-apa.html)
explains denominators, uncertainty and the scope of available reports.

## Pillar milestones and progress

The three purposes share one release sequence. The table below preserves the
accepted capability and workflow outcomes; it does not turn counts of completed
items into a percentage of statistical validity, effort or release readiness.

| Purpose | Accepted baseline within the declared scope | Remaining finalization |
| --- | --- | --- |
| Measurement | Model and derived-output checks, anchor migration, native RSM/PCM CML and identified comparisons, MML population-SD contrasts, estimator-specific guides and saved reuse. | Preserve admitted mathematical/statistical claims and experimental boundaries through the latest report connections, then qualify the matching source and environments. |
| G-theory planning | Scoped component, individual-plan and paired-plan uncertainty; integrated summaries, figures, editable reports and saved workflows. | Preserve source/future design, score units, fixed weights and method-specific uncertainty. Arbitrary future rosters and allocation optimization remain later work. |
| Feedback and decisions | Supported diagnostics, report modules, fixed-calibration decision summaries, interpretation guidance and saved workflows. | Complete the selected workflow checks while retaining source context, unavailable evidence and conditional uncertainty. General calibration-inclusive decisions and direct rater-effect models remain later work. |

The 0.2.4 diagnostic allocation retains the recorded estimator-specific fit
statistics. In particular, EAP plug-in MnSq remains descriptive, without an
expectation-one guarantee. A new posterior-averaged parameter-fit statistic
requires a separate definition and validation and is allocated to later work.
It is not a prerequisite for publishing the existing descriptive diagnostics.

Practical two-family use now has a paired-study guide covering numerical
delivery, interval coverage, observed runtime, rater overlap, sample-size
interpretation and unavailable bias/anchor operations. `fit_mfrm(progress = TRUE)`
provides phase and elapsed-time feedback; iteration limits do not predict time
remaining. Exact probability reuse reduces duplicated EM work without changing
the target or admission criteria. The latest successful two-family automatic
fit also shares its complete numerical qualification with subsequent intervals
in the same R session, conditional on exact fit, memory-setting and numerical-
backend identity.
This transient reuse is absent from saved fits; fresh sessions recalculate.
Further numerical work should address information-check cost within each fit
and unresolved curvature/integration failures. New two-family adaptive fits
cap the total-gradient review at the interval procedure's per-Person scale,
activating the existing bounded finish when necessary. Older saved fits retain
their recorded rule, and independent interval checks remain mandatory. Stronger delivery
or inferential claims require matched validation; the existing experimental
allocation and source-specific evidence remain explicit.

The [application workflows](#application-workflows-and-completion-conditions)
remain accepted within their scope. The common-recording annual workflow,
calibration-inclusive decisions and direct centrality/halo models remain later
work. Documenting an unavailable output does not implement it. Executed examples
and editorial review do not establish measured novice comprehension.

<a id="release-completion-milestones"></a>

### Completion milestones for 0.2.4

Each milestone closes an outcome, with evidence for the declared scope. The
first two can proceed together; workflow corrections follow any changes to the
API or inferential specification. Their acceptance precedes substantive freeze,
which precedes final delivery qualification and publication.

| Milestone | Completion condition | Current state |
| --- | --- | --- |
| Final API, mathematical and inferential specification | Each supported target and procedure has explicit model assumptions, identification/existence conditions, an applicable derivation, independent implementation checks, numerical eligibility and evidence adequate for its statistical claims. Inputs, defaults, uncertainty and unavailable operations agree. Resolve required gaps; justify experimental and later allocations. | Accepted for the current release allocation. Capability guidance, help and user outputs agree with the accepted method-family evidence, including uncertainty and refusal labels. Fixed-default/opt-in-auto MML, descriptive diagnostics and experimental/later allocations are explicit. Native comparison follow-up and general coverage research remain unfinished. Exact, asymptotic, approximate and descriptive claims retain their distinct scope. |
| Complete supported user workflows | The declared entry points lead to interpretable results, supported plots/tables, export and fresh-session reuse. Errors and unavailable results preserve their meaning; help and examples agree with the accepted mathematical specification. | Accepted for the current release allocation, combining scoped teaching, reporting, plotting and saved-result evidence with affected-route corrections and fresh-session review. Saved intervals preserve targets, uncertainty, experimental qualifications and unavailable states. This is not a fresh complete run of every example or measured novice comprehension. |
| Substantive specification and source freeze | The preceding outcomes are accepted; functionality, inference, numerical procedures and migration behavior are settled. One identified source and candidate archive agree with metadata, help, examples and release notes. | A matching local candidate now includes G/D, network and anchor/bias/model-choice reports, study declarations and the bounded display/input corrections. Its source and distribution correspondence is verified. This local selection is separate from main-source integration, final environment qualification and publication. |
| Final package and environment qualification | The selected source has attributable package, supported-platform, dependency, saved-result and documentation checks. Remaining failures and execution-time requirements are resolved; the package and website represent the same accepted behavior. | Open, with the missing distributed regression completed and its affected repairs checked in an installed package. Current tutorials, targeted help/site generation and saved reports are verified. Earlier examples/manual checks retain their original source scope; combined evidence is not a fresh clean complete check of the successor. Remaining supported-platform, external-link, website and source-integration qualification stay explicit. |
| Verified publication | Authorized source, package and documentation are published consistently, with installed/downloaded outputs checked. GitHub availability, CRAN submission and CRAN acceptance have separate recorded states. | Not published; submission is not acceptance. |

RSM/PCM CML supplies conditional structural inference without a fitted ability
distribution; it supplies neither Person abilities nor a population SD. MML
supplies the supported population-model and general GPCM inference routes.
Population-SD-standardized contrasts use the same fit's SD and applicable joint
delta covariance. JML remains a point-estimation/FACETS-comparison route for
structural parameters; its numerical or root uncertainty is not automatically
a structural-truth confidence interval. Existing conditional scoring and
descriptive diagnostics retain their own documented scope. These roles do not
by themselves change the default estimator or make every downstream operation
available for every result class.

RSM-versus-PCM likelihood-ratio tests require the PCM to retain every fixed
interaction term in the RSM. More free category steps alone do not make a PCM
an extension of an RSM with omitted interactions. The nesting review now
withholds those tests while retaining otherwise eligible information-criterion
comparisons. Recreate affected saved comparisons from their fitted objects;
this correction does not require refitting the models.

Use accepted source- and scope-matched evidence to close these milestones.
Mathematical acceptance distinguishes four questions: whether a result follows
under the stated model and regularity conditions; whether the implementation
matches that result; whether the numerical solution is admissible; and whether
the evidence supports the claimed statistical performance. An asymptotic result
is not a universal finite-sample guarantee, and numerical agreement alone does
not establish coverage. Evaluate existing evidence against the actual claim
before deciding whether a derivation, correction or further study is needed.
Additional tests or numerical studies must address a changed behavior, missing
required evidence or unresolved finding; an untried condition alone does not
require another study. A warning cannot substitute for repairing an incorrect
supported calculation. If delivery repairs change an inferential procedure,
return to the affected substantive milestone and qualify the change before
selecting the replacement source. Unaffected evidence remains valid.

## Release completion checklist

Checked items are accepted within their stated scope and support the milestones
above; the detailed items are not additional milestones. Existing G-theory
derivations and design-specific checks retain their scope, as do the API repairs
and reviewed workflows. The selected specification and implemented workflows
are accepted with their stated qualifications. Candidate archives retain their source-specific evidence; the latest workflow
changes still require a matching source selection. Package/platform qualification
and publication remain open.
Research tasks below do not
delay release merely because they remain unfinished; incorrect calculations,
misleading claims or broken supported workflows do require correction.

- [x] Define which capabilities are available, experimental or unavailable
  for 0.2.4.
- [x] Make result-specific `plot()` methods the main figure interface, with
  documented replacements for the former standalone drawing functions.
- [x] Provide beginner reading paths and a question-to-method/reference guide.
- [x] Reconcile the revised anchor workflows, help, reports and exported
  calibrations; retain the accepted checks for unaffected features.
- [x] Explain the common-recording design in the existing linking guide and
  tutorial: shared versus fixed values, annual effects, returned tables and
  current uncertainty limits. This is design guidance, not a verified annual
  analysis recipe or evidence of interval performance.
- [x] Provide component SEs and intervals for one score or a fixed composite
  from balanced ANOVA, covering the supported crossed and nested designs,
  with justified methods, boundary handling, independent checks and usable
  result outputs, including opt-in component interval plots and saved replay.
  This does not complete broader G-theory uncertainty.
- [x] Provide G intervals for balanced one-facet D-study plans, with an exact
  normal-theory F derivation, arbitrary specified future counts and explicit
  handling of empty parameter-space intervals and zero residual mean squares.
- [x] Provide Phi intervals for balanced one-facet D-study plans, using the
  corrected generalized agreement-ICC pivot with explicit model assumptions,
  boundary handling, numerical precision diagnostics and future-count mapping.
  This is an approximate-coverage method, not an extension of G's exact F pivot.
- [x] Provide G-difference intervals for balanced one-facet plans by mapping
  the entire common F confidence set, preserving dependence and interior
  extrema, with explicit normal-model assumptions and conservative coverage.
- [x] Provide Phi-difference intervals for balanced one-facet plans through
  the whole generalized interval, retaining its approximate coverage, interior
  extrema, boundary states, joint numerical endpoint bands and saved plots.
  SEM uses the separate error-variance construction below.
- [x] Supply explicitly selected experimental two-facet G/Phi methods, with
  a shared result table, mathematical assumptions, negative-component and
  failure diagnostics, forest plots, bundled-data examples and numerical checks.
- [x] Provide individual-plan SEM intervals for balanced crossed/nested sources
  and one-facet SEM-difference intervals, distinguishing exact single-mean-square
  cases from MLS approximations, with error-variance diagnostics and saved plots.
- [x] Provide nested G/Phi intervals and comparisons for unchanged source
  child counts per parent, by reducing to the one-facet sampling law. Preserve
  the original source, parent/child units, exact versus approximate coverage
  and numerical diagnostics. Provide nested SEM comparisons when plans share
  a future child count, with the underlying chi-square/MLS qualifications.
- [x] Provide explicit experimental nested G/Phi intervals with changed child
  counts, independently derived from expected mean squares and evaluated
  separately from the unchanged-child reduction. Provide conservative
  shared-region G/Phi/SEM difference enclosures for general balanced two-facet
  plans, retaining source dependence, reference projections and limitations.
- [x] Provide explicit normal-model covariance-element interval choices for
  two original scores from balanced ANOVA. Retain signed generalized intervals
  and conservative enclosures, separate SE/interval/numerical diagnostics,
  documented small-df limitations and a single source-by-source interval plot.
- [x] Provide explicit experimental REML target-profile G/Phi and SEM intervals
  for balanced and identifiable incomplete sources, preserving original points,
  separate REML centers, score units, numerical diagnostics and saved graphics.
  State the observed boundary undercoverage and the limits of numerical
  inversion; this does not qualify an automatic or generally calibrated method.
- [x] Provide explicit scalar component REML intervals for balanced and
  identifiable incomplete sources, retaining original points, separate REML
  centers, squared-score units, SE availability and component plot diagnostics.
  Two-score covariances use the separate joint model below.
- [x] Provide explicit experimental joint REML covariance intervals for two
  original scores, including identifiable incomplete sources. Preserve signed
  endpoints, original estimates, separate centers, absent sampling SEs,
  numerical failures and saved plots. State the undercoverage risk with few
  facet levels and the unestablished incomplete-source coverage.
- [x] Provide normal-model sampling covariance and SEs for original MINQUE
  variance and covariance components, including incomplete and supported
  nested sources. Preserve negative or unidentified sampling variances,
  distinguish SEs from SEM and REML uncertainty, and verify balanced limits,
  independent moment calculations and saved user workflows.
  Explicit `residual_contrast` intervals additionally support the combined
  Residual from retained ANOVA/MINQUE ratings: exact normal-model variance
  limits or conservative signed covariance enclosures. They preserve original
  points and separate projected centers, with unavailable limits when no
  residual information remains. For one-facet D-studies, the same method
  maps that interval to RelativeSEM and paired plan differences, preserving
  the shared source event, original points, separate centers and saved
  summaries/ribbons. Other components, G/Phi, AbsoluteSEM and multifacet SEM
  require their own methods; general incomplete-source inference is unfinished.
- [x] Provide explicit delta-method G/Phi sampling SEs and normal-reference
  intervals for supported ANOVA/MINQUE sources, with unchanged defaults.
  Preserve original estimates, boundary/variance diagnostics, untrimmed
  endpoints, saved reuse and base/ggplot displays. Document the crossed-design
  derivation, nested/incomplete extensions and their limited coverage evidence.
- [x] Provide experimental shared-profile G/Phi/SEM differences for one-facet
  plans and nested plans with a common future child count, including incomplete
  sources. Preserve interior extrema, original points, separate REML centers,
  unavailable intervals and the base method's calibration limitations.
- [x] Provide explicit experimental direct REML profiles for other crossed
  and nested G/Phi/SEM plan comparisons, including incomplete sources.
  Retain the shared source likelihood, numerical diagnostics, detected
  accepted pieces and original points. General finite-sample calibration,
  especially at zero-difference singularities, remains unestablished.
- [x] Provide a default individual-plan G/Phi interval method for balanced
  sources with two crossed random measurement facets. Approximate MLS null
  inversion has finite-sample evaluation under independent normal effects,
  useful precision on the evaluated moderate sources, and documented wide
  intervals on small sources. Preserve formula-completion flags, numerical
  failures and original points in tables, help and saved forests/ribbons.
  This is a qualified model-based approximation, not uniform or exact coverage,
  incomplete-source inference, or a guarantee of precise small-source results.
- [x] Provide an explicit experimental score interval for balanced
  two-crossed-facet G, preserving original points, empty sets, numerical
  diagnostics and saved forests/ribbons. Keep its approximate calibration
  and finite-sample limits explicit; this does not qualify a G/Phi default.
- [x] Explain current coefficient-interval availability, the reasons for
  deferral, relevant evaluation results and literature in help and the
  G-theory tutorial. Distinguish computable approximations from undefined
  calculations; this documentation does not complete the interval method.
- [x] Reconcile other remaining G-theory uncertainty requirements and release
  allocation before source freeze, distinguishing component, individual-plan
  and paired-plan inference across supported designs. Prioritize a usable
  method-selection guide and the allocation of missing standard alternatives
  over additional specialized estimators. Existing incomplete-source REML
  intervals are available with explicit limitations; further calibration is
  distinct from implementing a missing calculation. New methods and universal
  small-sample precision guarantees are not automatic release requirements.
  The [methods guide](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_methods_reference.html)
  maps source designs and targets to the available methods. Component,
  individual-plan and paired results retain their distinct assumptions,
  diagnostics and saved plotting workflows. General bootstrap and broader
  calibration/robustness research remain later work; this does not mark
  package-wide application workflows or final delivery checks complete.
- [x] Complete the [application workflows](#application-workflows-and-completion-conditions):
  integrated plan summaries, transferable teaching paths, interpretable
  figures and the construct-evidence guide, with their stated acceptance checks.
  This completes the selected teaching and saved-result paths; package-wide
  maintenance and final release verification remain separate below.
- [x] Settle the API, mathematical and inferential specification for the current
  release allocation, including CML and identified comparisons. The review
  connects supported claims to assumptions, derivations, independent checks,
  numerical admissibility and appropriately scoped performance evidence.
  General finite-sample guarantees and the listed later research are excluded.
  The scoped FACETS ZSTD, displacement, chi-square, PTMEA/PCM fair-average,
  bias-table, anchor and extreme-display corrections are implemented and
  checked within their documented limits. Residual executable differences
  remain explicit; general FACETS equivalence is not established. Preserve the
  [FACETS and GENOVA release scope](#open-facets-and-genova-compatibility-decisions),
  preserving the implemented options and the explicit unresolved comparisons.
  The MML default, target-specific eligibility and diagnostic allocation are
  settled. The capability table, help and result labels preserve these
  decisions, experimental qualifications and refused outputs. The GPCM guide
  consistently describes fixed-grid EM and adaptive direct fitting, with
  opt-in automatic integration and unchanged defaults.
  Unaffected specification reviews retain their acceptance. The broader
  follow-up comparisons and inference research are not prerequisites for
  this source/claim reconciliation.
- [x] Close the implemented user workflows against that specification, retaining
  valid examples and saved reuse with the affected-route corrections. Model,
  target, scale and unavailable states remain explicit. Final package/platform
  qualification is separate from this workflow and interpretation acceptance.
  Affected diagnostic help, method labels, reports and saved-result reuse have
  scoped repairs and checks. Saved-result review preserves experimental and
  unavailable intervals, source-anchor and joint-cell uncertainty, and the
  distinct G-theory and common-plan qualifications through their supported
  reports, plots and exports. This acceptance combines source-matched evidence;
  it is not a complete package check on one final installation.
- [x] Freeze the substantive specification and identify its matching source,
  metadata and migration notes before execution-time qualification. The
  October 25 candidate includes the accepted diagnostic, compatibility,
  integration and model-comparison corrections, with matching installed help
  and tutorial contents. Earlier archives retain their original evidence;
  this selection does not establish final package/platform qualification.
- [ ] Complete maintenance and execution-cost review for measurement and
  feedback as part of delivery preparation, after substantive freeze.
  Assess measured costs against delivery requirements; any optimization must
  have a demonstrated benefit and retain independent numerical checks,
  required examples and model scope.
- [ ] Verify the final package, examples, website, saved-result compatibility
  and supported environments. Reuse unaffected evidence and check changed or
  missing portions; a scoped local check does not complete this item.
- [ ] Publish matching release files and documentation. GitHub publication,
  CRAN submission and CRAN acceptance are separate outcomes.

## Post-release priorities

These items remain unfinished. Listing them does not promise a particular
release date or assign them all to 0.2.5.

### Direction and staged delivery

The main purpose remains measurement involving ratings, assessment planning
and useful feedback. Extensions should answer concrete questions about a
rating process and its consequences: what a Person's profile means, which
rater or criterion findings need review, and whether another task, another
rater or additional scoring time would improve the intended decision.

Existing software already provides multidimensional IRT, Bayesian estimation,
response-time models and cognitive diagnosis. The development objective is
to make selected rating workflows usable together, preserving their different
estimands, assumptions and uncertainty. This is not a claim that these model
families originate in mfrmr. Named methodological starting points include
[Bayesian GMFRM](https://doi.org/10.1007/s41237-020-00115-7),
[multidimensional GMFRM](https://doi.org/10.1007/s41237-021-00144-w),
[rater-effects cognitive diagnosis](https://doi.org/10.3389/fpsyg.2020.00525)
and [joint ratings/rating-time models](https://doi.org/10.3758/s13428-023-02259-2).
Their response equations and inference targets require explicit mapping before
adoption. Matching a model name is not sufficient.

| Stage and tentative version range | Intended deliverable | Boundary for the first release of that capability |
| --- | --- | --- |
| Interoperability: first 0.2.5 candidates | Reusable model specifications and a checked path from joint external draws to new contrasts and posterior targets. Clarify supported TAM imports and ConQuest comparisons. | Extend the existing read-only saved-summary return for exported RSM/PCM/GPCM. An imported marginal summary is not a native calibration or joint uncertainty estimate. |
| Bayesian workflows: subsequent 0.2.5 candidates | Optional fitting and scoring through CmdStan/cmdstanr, with explicit priors and joint calibration uncertainty. | Build on the same export/result path. Add new-Person scoring, external calibration uncertainty and broader slope families as separately qualified increments; preserve current MML defaults. |
| Rubric profiles: 0.3.x candidates | Prespecified multidimensional MFRM/GMFRM, joint Person-profile uncertainty and criterion/rater feedback. | Start with low-dimensional simple structure and unit slopes, then admit free-slope variants. Identification, numerical accuracy and usefulness of subscores need separate evidence. |
| Rating processes: later 0.3.x / 0.4.x candidates | Direct centrality, restricted rater classes, and response-time/rating-time extensions chosen for specific assessment questions. | Qualify the branches separately. A combined model with every effect is not the initial goal. |
| Diagnostic attributes: 0.4.x and later candidates | Explicit skill-Q specifications and a bounded rater-effects CDM workflow for mastery/profile feedback. | Begin with a small specified skill structure and a matched established reference. Broader response scales and automatic Q/class selection are separate extensions. |
| Planning and decisions throughout | Broader future rating rosters, uncertainty in plan comparisons and, eventually, additional-rating allocation under cost constraints. | Specify the score, generalization population and decision loss. Keep classical G-theory and model-based predictive planning distinguishable. |

These ranges express a dependency order, not a release calendar. A useful
branch can be delivered without waiting for every other model in its stage.
Each delivery includes its supported scoring/reporting path and saved reuse,
with unavailable results retained. A converged fit alone does not complete a
feedback or assessment-planning workflow.

### ConQuest, TAM and Stan: use, compare and extend

The immediate benefit is to let an analyst reuse a supported external result,
inspect an exported model, or compare a matched calculation without losing the
meaning of its scores and uncertainty. These are different operations.

| Connection | Already available in 0.2.4 | Next useful increment |
| --- | --- | --- |
| TAM | `import_tam_fit()` imports supported unidimensional MML results for summaries and point-only Wright maps. Multifacet conditions become `DesignCell` locations; separate facet effects and their joint covariance are not reconstructed. | Extend source-aware reporting first; recover separate facets or transformed uncertainty only with an identified parameter map and the required joint covariance. |
| ConQuest | `build_conquest_overlap_bundle()` and `review_conquest_overlap()` support a narrow binary, single-facet latent-regression comparison. Broader research comparisons do not expand this public API. | Add matched polytomous additive RSM/PCM cases before more general GPCM exchange. Reuse `conquestr` where suitable for execution and reading, retaining original outputs and settings. |
| Stan/brms | `export_mfrm_model()` writes model bundles with supported fixed anchors. RSM/PCM and fixed-population one-family GPCM support both formats; default estimated-population one-family GPCM and two-family GPCM support Stan. `read_mfrm_posterior()` connects saved summaries, including population mean/SD, to figures, credible intervals and shared reports. | Extend population regression, joint-draw contrasts, new credible levels and prediction. Support data/specification input without a preliminary MML fit. |

[ConQuest](https://www.acer.org/au/conquest) already includes multidimensional,
multifaceted and Bayesian estimation. [TAM](https://alexanderrobitzsch.github.io/TAM/reference/tam.mml.html)
supports multidimensional models and faceted slope designs through selected
interfaces; the limits of `tam.mml.mfr()` do not describe all of TAM.
The aim is a well-supported rating workflow, with established engines as
references and optional connections. A larger model catalogue alone does not
establish methodological novelty or practical superiority.

Stan export currently requires a supported native MML fit, unit weights,
no interactions/shrinkage and either a fixed standard-normal Person population
or a one-family GPCM with an estimated intercept-only normal population.
Fixed anchors are exact constraints; uncertainty from an earlier calibration
is not propagated. Person anchors and native two-family anchored fitting
remain outside the source-model scope.
It preserves the response likelihood and adds explicit structural priors;
its posterior is not the original MML estimate or confidence interval.
The read-only `mfrm_posterior_summary` connects saved marginal summaries to
`summary()`, `plot()`, `confint()`, long plot tables and `mfrm_report()`.
It checks the matching model-data identity and retains sampling review;
`confint()` retrieves the stored 95% credible interval. It does not provide
native MML diagnostics, joint draws, new interval levels or scoring.

Further Bayesian result work should preserve joint draws and chain/iteration
identity for new posterior targets while extending the existing report route.
Priors, mappings and numerical diagnostics must remain explicit during reuse.
Classical G/D coefficients and model-based predictive planning keep separate
targets; shared data or reports do not make them interchangeable.

Later comparison and prediction must declare what is new: a rating from an
existing Person, a new Person, or a new rater. Existing row-level `log_lik`
conditions on sampled Person abilities and is not a ready-made new-Person
validation score. The [loo cross-validation guidance](https://mc-stan.org/loo/articles/online-only/faq.html)
explains why the held-out unit and latent-effect treatment must match the task.
These extensions are post-0.2.4 work, not additional release blockers.

### Model extensions and their acceptance conditions

- [ ] Develop a native Bayesian path using explicit constrained-scale priors,
  independent density/gradient checks, posterior sampling diagnostics, prior
  sensitivity, predictive checks and appropriately scoped simulation-based
  calibration. Propagate calibration uncertainty jointly into supported
  scores and decisions. Proper priors can regularize weak information; they
  do not establish likelihood identification or universal frequentist coverage.
- [ ] Support explicit continuous-dimension and discrete-attribute Q
  specifications. A loading restriction for a continuous trait differs from
  a skill requirement in a cognitive diagnosis model. Keep both distinct from
  the facet design matrix. Preserve simple formula/facet use for ordinary
  models, and validate dimension/attribute identity, response categories,
  constraints and the actual observation design.
- [ ] Develop a low-dimensional rubric workflow with declared loading patterns,
  scale/orientation constraints and latent correlations. Specify whether
  dimensions compensate for each other and where facet slopes act. Verify
  one-dimensional and unit-slope reductions where claimed, assess weak links
  and nearly indistinguishable dimensions, and report joint profile uncertainty.
  Exploratory residual PCA and multivariate G-theory do not implement this model.
- [ ] Develop separate joint-model paths for examinee response/production time
  and rater scoring time before combining them. A timed performance enters
  once even when several raters score it; a timed scoring session also enters
  once when it produces several criterion ratings. Specify repeated events,
  time units, censoring, pauses and missing times. Current response-time
  reviews remain descriptive. Fast or slow observations alone do not diagnose
  effort, guessing or rater quality.
- [ ] Develop a bounded latent-class workflow with an explicit class owner
  such as a Person, rater or rating episode. Preserve group-level membership
  in the likelihood, examine class collapse and competing continuous effects,
  and report membership uncertainty. A flexible population distribution or
  descriptive cluster does not establish a substantive rater type. Automatic
  exclusion and general class-count selection are outside the first workflow.
- [ ] Develop a rater-effects cognitive diagnosis workflow against a matched
  established CDM reference. Specify skill meaning, permitted profiles and
  the observation model; distinguish direct rater effects from a latent-score
  misclassification model. Evaluate Q misspecification, sparse assignments,
  rare profiles, classification uncertainty and the no-rater reduction.
  Dichotomizing continuous scores is not a substitute for fitting a CDM.

Computational choices must preserve the requested estimand and precision.
Tensor quadrature grows exponentially with the number of continuous dimensions;
enumerating unrestricted binary attributes also grows exponentially. Future
multidimensional controls therefore need explicit total computational budgets
and accuracy diagnostics. Existing one-dimensional point limits do not imply
the same cost or accuracy in multiple dimensions. Bayesian sampling is an
additional inference route, not an automatic speed improvement.

Assess additions against simpler models and established software with matching
response laws, scales and uncertainty targets. Evaluation should include useful
outputs, unavailable results, uncertainty, decision or prediction performance,
runtime and memory. Empirical applications and intended-user evaluation are
needed for claims about practical benefit. Preserve the following ongoing
priorities alongside the new model branches.

### Relationship to structural equation modeling

Structural equation modeling provides a related framework for connecting
measurement models to covariates, other constructs and longitudinal processes.
Selected IRT and categorical factor models coincide under matching response
laws, scales and constraints. Ordinary ordinal threshold CFA and PCM/GPCM,
however, use different category-probability constructions. A common path
diagram or a rescaled loading does not establish model or estimator equivalence.

[lavaan](https://lavaan.ugent.be/tutorial/cat.html) offers a useful CFA/SEM
reference within its supported response and estimation scope.
[Mplus](https://www.statmodel.com/irtanalysis.shtml) explicitly includes
PCM/GPCM, multidimensional and cross-classified IRT, mixtures and diagnostic
classification. Each proposed overlap needs its specific model/estimator
combination checked. SEM-based G-theory and dependability methods also exist;
these areas are not exclusive to mfrmr.

The planned connection is a bounded rating workflow: specify the measurement
and parameter mapping, relate supported latent profiles to a substantive
external variable, and preserve uncertainty in results exchanged with other
software. Current MML latent regression is a scoped starting point, not a
general structural-model API. Point-score export alone does not propagate
measurement or shared calibration uncertainty. Plausible-value analyses need
compatible downstream conditioning and uncertainty handling; existing
fixed-calibration draws do not automatically meet that requirement.

Prioritize matched reference calculations and selected interoperability
examples over a general SEM engine. Preserve observation/cluster identities,
constraints, uncertainty targets and unsupported states. Native Bayesian
development remains based on CmdStan/cmdstanr. Broader path, growth and
mediation analysis can use established software when the measurement and
uncertainty connection is justified; neither a path diagram nor model fit
alone establishes a causal effect or construct validity.

### Continuing application and inference priorities

- [ ] Develop empirical application studies in language assessment, music or
  judged sports when suitable data, permissions and substantive questions are
  available. Distinguish demonstrated workflows from evidence that a method
  performs well in a domain. Evaluate beginner comprehension with intended
  users; executable examples and editorial review are not usability results.
- [ ] Evaluate broader GMFRM/population-interval performance within the MML
  inference route, with method-specific identification and calibration checks.
  Any future ordinary/corrected-JML structural-inference research must first
  address the fixed-exposure incidental-parameter problem; increasing cohort
  size or computation alone does not establish truth-centered intervals.
  Such research is separate from JML's point-estimation/comparison role and
  is not a 0.2.4 completion requirement.
- [ ] Evaluate more flexible ability distributions, category/threshold
  structures, slope owners and supported combinations of model extensions.
- [ ] Evaluate tighter G/D plan-difference inference beyond the current
  one-facet/reduced-nested images, crossed paired-delta method and general
  balanced two-facet shared-region enclosures.
  Evaluate robust inference and guarantees across scores separately.
- [ ] Support broader future rating plans, including unequal allocations and
  component-specific partial sharing, with explicit generalization populations.
- [ ] Develop decisions that include calibration uncertainty and evaluate
  performance for small cohorts, estimated priors and changed populations.
- [ ] Verify a common-recording across-year workflow before recommending it:
  specify performance identities, annual rater effects and scale constraints;
  distinguish panel-wide drift, individual drift and cohort differences in
  bounded checks, then verify reports and saved reuse. A shared label alone
  is not evidence of invariant performance or a connected estimable model.
- [ ] Develop year-difference uncertainty that accounts for joint covariance
  or uncertainty in estimated reference recordings, as appropriate. Dynamic
  trajectories and changing criterion/category effects require separate
  identification and evidence; they are not implied by a year column.
- [ ] Evaluate stronger screening, centrality and dependence claims, including
  uncertainty in criterion ratings and repeated-rating DIF sensitivity.
- [ ] Assess direct severity/centrality (FM-SC) and halo mixture (MRFM-H)
  models before deciding which to implement. Specify the effect and identifying
  design, reproduce available reference calculations, and examine sparse
  ratings, few criteria, missing categories and competing explanations in
  small studies. Adoption requires a useful improvement in measurement or
  feedback with interpretable uncertainty; convergence or agreement with an
  existing screening flag alone is insufficient. Favorable and unfavorable
  impression effects require an explicit target, not an inferred edge sign.
- [ ] Investigate constrained additional-rating allocation and rank/winner
  uncertainty for clearly specified decisions.

## Compatibility principles

Preserve model, scale, category, anchor and uncertainty meanings across saved
results, tables, figures and exports. Breaking changes require migration
instructions. In 0.2.4 the former standalone drawing functions become private;
use the replacements in the [plot migration guide](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_plot_migration.html).
`plot_data()` and `plot_data_components()` remain public for extracting data.
Unavailable results and their reasons should remain visible rather than being
replaced with plausible-looking numbers.
