# mfrmr roadmap

Updated 2026-10-23. mfrmr `0.2.4` is a release candidate and has not been
released. Features described below refer to this candidate unless stated
otherwise. Previously reviewed inference and user workflows retain their
scoped evidence. The subsequent critical review has repaired saved-result
identity checks and numerical defects, added explicit standard R extraction
contracts, and settled primary-entry and naming decisions with migration
guidance. The FACETS manual review has corrected fit standardization, PTMEA,
facet displacement and chi-square df, PCM fair averages, bias expectations and
summary tests, anchor validation/display, and unexpected-response screening.
PCM fair-average plot intervals use the same weighted administered-scale
expectation as their point estimates, retaining conditional uncertainty limits.
The fit-table and ZSTD pathway defaults use the same df convention as diagnostics;
refreshing their comparison columns preserves the recorded WHEXACT choice.
Saved diagnostics and bias results require recreation from their original fit.
An executed FACETS 4.5.0 binary JML comparison agrees within printed precision
for the checked measures, fit and bias summaries. Its bias-cell df differs from
the web manual; the version-specific distinction is documented. The modified Rasch-Welch pairwise reference and integer truncation also
match an unequal-count example; the earlier classical reference remains
selectable. General FACETS equivalence is not established. Native conventions and remaining limits are explained in
the migration guide. GENOVA 3.1, mGENOVA 2.1 and urGENOVA 2.1 comparisons support
the checked balanced G/D-study examples and distinguish negative-component
options from calculation defects. These corrections do not by themselves close
final package and environment qualification.
Native MML residual MnSq
uses EAP plug-in scores and is not equivalent to posterior-averaged TAM or
ConQuest item/parameter fit. ConQuest comparison exports now check the supported model and
declare independent external numerical controls and reversible names; import
validates coefficient coordinates, and incomplete item comparisons use a common
centering set. Imports preserve factor labels and flag nonnumeric case estimates
from native CSV exports. Reviews retain stopping status, flag surplus IDs, and require
an established origin for EAP/intercept errors. Numerical precision still
requires refinement or an independent reference. These repairs
preserve descriptive comparison scope and do not establish general ConQuest
fit, scoring or uncertainty equivalence. The other reviewed claims retain their scoped
acceptance and are matched to their assumptions, derivations,
independent numerical checks and applicable statistical evidence. User workflows
preserve those meanings through results, plots, reports and saved reuse.
Exact, asymptotic, approximate, experimental and descriptive procedures retain
their distinct qualifications; this is not a general finite-sample accuracy or
coverage guarantee. A local Windows package-check attempt on an intermediate candidate passed
examples and tutorials but exposed diagnostic-consumer and Unicode-handling
defects. That repaired Windows integration candidate passed the ordinary installed regression
selection with affected-route reruns, static analysis, changed help examples
and saved-result replay. This combines a completed check attempt with scoped
repairs; it is not a second complete package check of the corrected archive.
The subsequent fair-average plot and ConQuest import corrections have scoped
source checks and fresh-session plot replay; they are not a new full check.
Earlier exhaustive regression, example, dependency and documentation checks
retain their original scope and source attribution. Final specification and
source selection, supported-environment, execution-cost and hosted-site
qualification remain open; local checks do not establish release completion.
No release date is promised.
See [NEWS](NEWS.md) for changes and [README](README.md)
for analysis examples.

Ordinary direct MML offers opt-in automatic integration checking and adaptive
refitting. The checks include individual log marginal likelihoods, posterior
moments and the marginal gradient; failures retain their numerical history.
The final integration rule also governs information and scoring. This covers
RSM, PCM and one-family GPCM with their existing model restrictions. Changing
the default, improving repeated-design efficiency and extending latent-regression
EM remain separate development decisions. Numerical checks do not establish
global optimality, formal identification or interval coverage.

Small supported datasets now reach model-specific checks without a blanket
ten-rating-row minimum. For RSM/PCM MML, singleton category counts can retain
model-information intervals after category, convergence, full-information and
finer-quadrature review. The interval result explains its eligibility and
small-sample caution while the source fit retains its category review. This
does not guarantee finite-sample coverage or waive empty-category,
identification or numerical failures. See `mfrm_facet_intervals()` help.
Full RSM/PCM JML, CML and fixed-population MML also admit one-Person calibration
after the applicable checks; JML/MML requires an additive recession check before
fitting. A finite solution is possible for some informative response patterns,
but does not establish interval coverage or empirical between-Person variation.
Results retain this caution. Other calibration routes retain their current
at-least-two-Person software limit; Person-cluster sandwich uncertainty cannot
be estimated from one Person.
CML now also separates finite numerical point estimates from conditional
information failures. When its identification, finite-MLE and stationarity
checks pass, unavailable covariance no longer discards the point; summaries
and intervals retain missing uncertainty and its reason. The information
warning remains relevant to point accuracy and prevents formal inference.
Eligible ordinary fixed-population RSM/PCM MML interval results likewise retain
finite points when joint information fails, with missing model/sandwich
uncertainty and explicit reasons. Source qualification remains required;
information failure is not a new guarantee of point accuracy or coverage.

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

| Purpose | Included in 0.2.4 within its documented scope | Incomplete or experimental | Planned after 0.2.4 |
| --- | --- | --- | --- |
| Measurement | RSM/PCM MML and JML; RSM/PCM CML structural estimates and identified interaction contrasts with conditional-information intervals; one-slope-family GPCM; supported diagnostics, category outputs, reliability/strata, scoring and calibration reuse. | Two-family GMFRM estimation, conditional scoring and available intervals; corrected GPCM JML point/scoring results; population intervals whose performance is not fully established. | MML fixed Person anchors, initially RSM/PCM; broader GMFRM/population uncertainty evaluation; more flexible population and facet structures. |
| G-theory planning | Supported crossed/nested G/D studies, identifiable incomplete-source estimation, composites/differences, complete future plans, plots including signed error-source contributions by plan, balanced ANOVA component SEs/intervals and SEM intervals, one-facet G/Phi intervals, approximate MLS individual-plan G/Phi intervals for balanced two-crossed-facet sources, and scoped paired plan-difference intervals. | Explicit delta coefficient SEs/normal-reference intervals; experimental approximate-F and mean-square-region coefficient intervals; target-REML variance/covariance component, G/Phi and SEM intervals for balanced/identifiable incomplete sources; signed balanced-source covariance intervals. Plots retain original points, numerical failures and method-specific qualifications. General small-sample calibration remains incomplete. | General bootstrap alternatives, robust/simultaneous inference and sparse or unequal future rating plans. |
| Feedback and decisions | Supported individual reports, agreement/reference comparisons, criterion accuracy, centrality, DFF sensitivity checks, exploratory all-pair bias summaries and plots with explicit availability, conditional cut probabilities and fixed-plan classification/SEM. | GMFRM feedback and descriptive diagnostics; general screening accuracy and performance under estimated or shifted ability distributions are not established. Conditional bias screens do not supply collection-wide multiplicity control. | Calibration-inclusive decisions, broader diagnostic evaluation, additional-rating allocation and rank/winner uncertainty. |

Anchors, linking/imports, feature analysis, assigned-score imputation and
eligible pooling, and separate random-rater/testlet models remain included
within their documented restrictions. Stan/brms code export supports its
implemented combinations: RSM/PCM in both formats, and two-family GPCM in
Stan. Code export is not a native Bayesian estimator or a guarantee about
prior choice or credible intervals.

Location anchors use internal coordinates and condition on their supplied
values. Person direct/group anchors require JML; MML rejects them. New ordinary
fits center each declared facet across all levels, including anchors and group
totals. Use `centering_scope = "remainder"` to reproduce the earlier convention.
Neither mode automatically disables centering as FACETS can do. Thresholds
and slopes are not carried by the location-anchor
table. See the [linking tutorial](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-linking-and-dff.html)
for a complete example and the distinction from fixed-calibration scoring.

## Anchor alignment before 0.2.4: incomplete

Ordinary fitting and anchor review now accept `centering_scope = "facet"`
(default) and `"remainder"` (legacy reproduction). The new convention centers
the whole declared facet, including fixed values. An anchor does
not implicitly select the population mean, variance, threshold structure or
uncentered facet. These choices must match before results can be compared with
TAM or ConQuest. Ordinary fitting, saved refit settings and the scoped
population-model correspondence and the migration workflow are checked;
release integration remains incomplete. Anchored estimated-population facet-location intervals
remain unavailable even when point estimation and local numerical checks
succeed. One-family GPCM slope and curve intervals have a separate supported
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
  exclusions. Corrected JML, two-family GPCM, testlet/random-rater models and
  Stan/brms export do not accept anchors.
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
re-estimation. This work does not add uncertainty from estimating anchors in
their source calibration, nor promise equivalent defaults across programs.
`make_anchor_table()` preserves fitted numeric values by default. Rounding
individual anchors can break their joint zero sum; use `digits` explicitly
for a display copy and review any rounded values before recalibration.

Conditional intervals for supported ordinary RSM/PCM MML facet estimates
already exist; verifying them under the revised constraints is part of this
release work. This differs from propagating uncertainty in externally
estimated anchors. Bias-screening SEs and conditional bounds retain their
screening interpretation. Jointly fitted interaction effects currently have
no public cell-level SE/CI output; adding that inference is a separate
extension, not an automatic consequence of anchor alignment.

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

## Rater feedback across application areas

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
| Measurement | Model and derived-output checks, anchor migration, native RSM/PCM CML and identified comparisons, MML population-SD contrasts, estimator-specific guides and saved reuse. | Assess whether existing mathematical and statistical evidence supports each final claim, then qualify the matching release source and supported environments. |
| G-theory planning | Scoped component, individual-plan and paired-plan uncertainty; integrated summaries, figures and saved workflows; scoped maintenance checks. | Confirm the sufficiency of design-specific derivations and calibration evidence for the final claims and method recommendations. Broader research is separate. |
| Feedback and decisions | Supported diagnostics, reports, fixed-calibration decision summaries, interpretation guidance and saved workflows. | Confirm estimator-specific targets, conditional uncertainty and interpretation against their mathematical basis, then complete final-source delivery checks. |

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
| Final API, mathematical and inferential specification | Each supported target and procedure has explicit model assumptions, identification/existence conditions, an applicable derivation, independent implementation checks, numerical eligibility and evidence adequate for its statistical claims. Inputs, defaults, uncertainty and unavailable operations agree. Resolve required gaps; justify experimental and later allocations. | Partially accepted. Existing method reviews and the bounded diagnostic/manual corrections retain their acceptance. Final MML numerical-default, downstream-eligibility and diagnostic-adoption decisions remain open. Exact, asymptotic, approximate and descriptive claims remain distinct; broader inference research is not automatically a release requirement. |
| Complete supported user workflows | The declared entry points lead to interpretable results, supported plots/tables, export and fresh-session reuse. Errors and unavailable results preserve their meaning; help and examples agree with the accepted mathematical specification. | The implemented teaching, reporting, plotting and saved-result workflows retain their scoped acceptance, including affected-route repairs. Final acceptance must follow any remaining specification changes. These checks do not establish a fresh complete run of every example or measured novice comprehension. |
| Substantive specification and source freeze | The preceding outcomes are accepted; functionality, inference, numerical procedures and migration behavior are settled. One identified source and candidate archive agree with metadata, help, examples and release notes. | Open. Earlier candidate archives retain their own build and validation evidence. The subsequent diagnostic, compatibility and documentation corrections require a replacement source/archive decision after the remaining substantive decisions are settled. A previously checked archive is not the current final source. |
| Final package and environment qualification | The selected source has attributable package, supported-platform, dependency, saved-result and documentation checks. Remaining failures and execution-time requirements are resolved; the package and website represent the same accepted behavior. | Open. Earlier complete checks and regression runs retain their source-specific evidence. The later Windows integration combines a completed check attempt with scoped repairs, installed regression and saved-result replay; it is not a complete check of the latest source. Final supported-platform, dependency, website and execution-cost qualification follow substantive freeze. |
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
and reviewed workflows. Final specification and replacement-source acceptance
remain open after the subsequent corrections and outstanding substantive
decisions; package/platform and publication qualification follow them.
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
- [ ] Settle the API, mathematical and inferential specification for the current
  release allocation, including CML and identified comparisons. The review
  connects supported claims to assumptions, derivations, independent checks,
  numerical admissibility and appropriately scoped performance evidence.
  General finite-sample guarantees and the listed later research are excluded.
  The scoped FACETS ZSTD, displacement, chi-square, PTMEA/PCM fair-average,
  bias-table, anchor and extreme-display corrections are implemented and
  checked within their documented limits. Residual executable differences
  remain explicit; general FACETS equivalence is not established. Settle the
  remaining MML numerical-default, downstream-eligibility and diagnostic
  decisions, including what belongs in this release. Unaffected specification
  reviews retain their acceptance.
- [ ] Close the implemented user workflows against that specification, retaining
  valid examples and saved reuse with the affected-route corrections. Model,
  target, scale and unavailable states remain explicit. Final package/platform
  qualification is separate from this workflow and interpretation acceptance.
  Affected diagnostic help, method labels, reports and saved-result reuse have
  scoped repairs and checks. Revisit only workflows affected by the final
  specification; retain the valid completed evidence.
- [ ] Freeze the substantive specification and identify its matching source,
  metadata and migration notes before execution-time qualification. The
  previous archive retains its local build and installed integration evidence.
  Identify a replacement after the diagnostic/compatibility corrections; earlier
  evidence retains its original source attribution.
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
