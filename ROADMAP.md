# mfrmr roadmap

`mfrmr` connects three tasks in performance assessment:

1.  **Measurement models:** estimate person ability while accounting for
    rater severity, task or criterion difficulty, category thresholds,
    and supported discrimination or dependence structures.
2.  **G-theory assessment planning:** separate observed-score variance
    components in a `G-Study` and project reliability, generalizability
    (`G`), dependability (`Phi`), and standard errors across candidate
    rating designs in a `D-Study`.
3.  **Rater feedback and decision support:** turn agreement, fit,
    residual, network, bias/DFF, and conditional classification analyses
    into structured, reviewable evidence without automating high-stakes
    rater exclusion or causal fairness claims.

This document outlines the planned capability sequence across
**`0.3.0`**, **`0.3.x`**, and **`0.4.x`**, together with the statistical
and software boundaries that govern each stage. For changes already
implemented in the current development tree (`0.2.4.9000`), see
[NEWS](https://ryuya-dot-com.github.io/mfrmr/NEWS.md) and the
`help("mfrmr_api_migration_030")`.

## Starting from the published 0.2.4 release

CRAN published **0.2.4 on 2026-10-30**. It is the stable reference for
this roadmap; `0.2.4.9000` is development toward **0.3.0**, not a
replacement already available from CRAN.

| Area | Published 0.2.4 | Intended change in 0.3.0 |
|----|----|----|
| Public entry points | 189 exports | 163 exports: consolidate 28 names into shared routes and add `facets_guide()` / `import_irt_fit()`. Follow the migration guide for exact replacements. |
| Two-family GPCM | Experimental two-facet MML | Choose two slope facets among fixed additive facets, with separate step ownership and a named slope reference; retain experimental inference limits. |
| Model specification | Flat [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md) arguments | Group advanced model choices in `spec` and numerical settings in `control`, with validated legacy calls. |
| Figures and saved results | Existing S3 routes and legacy plot payloads | Return `ggplot` objects consistently; use [`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md) for numerical payloads. Preserve saved-result classes and supported methods. |
| Bayesian workflows | Export and posterior-summary review | Direct data/spec export, optional CmdStanR execution, joint-draw contrasts and new-Person scoring with separate predictive-precision checks. |
| Assessment planning | G-Study / D-Study and paired contrasts | Review a declared finite set of plans against costs, limits and targets, preserving pointwise uncertainty and avoiding an automatic optimum claim. |
| Learning and reference | Extensive reference help and tutorials | A visual entry page, five core offline tutorials, specialist website articles and shorter task-focused reference navigation. |

Reliability plots and
[`compute_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_information.md)
already exist in 0.2.4; they are not new statistical capabilities in
0.3.0. Improve their visibility and interpretation: distinguish
Person/rater separation, observed agreement, G/Phi and ability-dependent
information. The current information total uses all observed rating
exposures; it must not be presented as an individual person’s test
information or EAP uncertainty. A future explicit rating-roster
interface requires its own design specification and numerical
validation.

The release remains conditional on cross-platform checks and acceptable
check duration. An implemented feature or a successful local check alone
does not establish release readiness.

## What should become easier in 0.3.0?

The intended benefit is a connected assessment workflow: start with a
rating table, understand the design and diagnostics, and use the results
to prepare feedback or compare a future rating plan. The [interactive
tour](https://ryuya-dot-com.github.io/mfrmr/dev/articles/mfrmr.html)
shows this sequence with data, figures, explanations and a saved
analysis.

| Your question | The workflow should help you do this |
|----|----|
| Can I compare people rated by different panels? | Inspect who rated whom, distinguish missing assignments from zero scores, and review model identification. A connected graph alone is insufficient. |
| What should I discuss with a rater? | Read severity together with consistency, exposure and uncertainty; prepare a reviewable report without automatic rater exclusion. |
| Should I add raters or tasks? | Compare declared plans using G/Phi, uncertainty and resource constraints. A D-Study is a separate observed-score analysis, not a transformation of an MFRM coefficient. |
| Can I reproduce this result later? | Save the analysis, diagnostics and numerical plot data together, and reload them for reporting. |

TAM or FACETS can remain the right choice for a particular model or
established workflow. mfrmr’s aim is to reduce the work between analysis
and an interpretable assessment decision. More model options alone would
not achieve that aim; beginner comprehension and successful use still
need evaluation.

## 0.3.0: migration and release conditions

The capabilities in the comparison table are implemented in the
development source. They are not yet a CRAN release. The next release is
**0.3.0** because consolidating public names and changing
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) returns require
script updates:

- Replace retired entry points using the
  `help("mfrmr_api_migration_030")`.
- Extract plotted numerical values with
  [`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md);
  [`plot()`](https://rdrr.io/r/graphics/plot.default.html) returns a
  `ggplot` object. Supported saved `0.2.x` result classes and legacy
  plot payloads retain their documented methods.
- Use complete argument names with
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  and [`do.call()`](https://rdrr.io/r/base/do.call.html). Only the first
  four positional arguments retain their old positions. Abbreviations
  for names now passed through `...` are not supported; the migration
  guide gives before/after calls.

Interface changes and faster numerical kernels retain the documented
statistical targets, quadrature rules, convergence criteria and
independent checks. They do not establish finite-sample inference
validity for additional models or rating designs. Shared `spec` lists
remain subject to each function’s scope, including the export limits
below.

Remaining release work is to resolve cross-platform check failures and
duration, verify saved-object and reporting workflows against the final
archive, and publish documentation that matches the released source. A
successful local check or completed implementation does not close these
conditions. Version milestones express dependencies and evidence
requirements, not calendar dates.

Alternative response equations and later model candidates below are
outside `0.3.0`. Errors or misleading claims within its supported scope
still require correction. Later extensions are selected for a concrete
assessment decision and the evidence needed to support it; they are not
a commitment to implement every branch.

## Measurement models: current limits and extension order

Model choice and estimation method are separate decisions. Current
native support in `0.2.4.9000` is bounded as follows; consult
`help("mfrmr_gpcm_scope")` and `help("fit_mfrm_technical_details")` for
the complete conditions.

| Response model | Native estimation paths | Boundary that extensions must preserve |
|----|----|----|
| Ordinary RSM / PCM | MML, ordinary JML and CML within their documented scopes; a separate Jeffreys-penalized JML path | Fixed versus estimated ability populations change the MML model. Numerical admissibility alone does not validate small-sample intervals. |
| One-family GPCM, shared step and slope facet | MML, ordinary JML and experimental profile-score-adjusted JML | The adjustment is not a general small-sample correction for every model; its root-variation SE does not establish structural-parameter interval coverage. |
| One-family GPCM, separate step and slope facets | MML | JML and its profile-score adjustment are not supported for this specification. |
| Two-family GPCM | Experimental fixed-grid EM or adaptive-direct MML | Two named slope facets among the declared fixed additive facets; step ownership, the noncentered location facet and the geometric-mean-one slope reference are separately specified. Ability remains fixed to N(0,1). |

The development implementation retains the current response equation, in
which both slope factors multiply the whole
ability-minus-location-and-step expression. For example, Task and Rater
can own slopes while Criterion owns steps. Use `slope_reference` to name
the slope family with geometric mean one and `noncenter_facet` to name
the sole uncentered location facet. Additional Occasion or Venue effects
remain fixed additive effects, not extra ability dimensions. The old
two-facet defaults and saved fits retain their meaning. Extended
portable calibrations use format 7; the original two-facet structure
retains format 6.

Three- and five-facet calculations and representative workflows are
checked. These checks do not guarantee identification, convergence or
interval coverage for every design. In particular, an optimizer can
converge while the integration checks refuse intervals or portable
scoring. Extended-role Stan export from an existing fit supports
posterior reload, contrasts, plots and reports. Two-family simulation,
direct data/spec export and new-Person posterior scoring remain
unsupported. Changing the slope reference with fresh independent priors
changes the Bayesian model. This extension is included in **0.3.0**. Its
point-estimation review separates identification, numerical accuracy and
sampling error; adding support does not remove experimental interval
restrictions.

A bounded three-facet study now separates Person count from ratings per
Person. All numerical checks passed, but the 60-Person, four-rating
Task-slope interval covered its true value in 183/200 replications. The
design, Monte Carlo uncertainty and precision results are described in
the [development GPCM
guide](https://ryuya-dot-com.github.io/mfrmr/dev/articles/mfrmr-gpcm-scope.html#three-facets-person-count-and-rating-exposure).
They do not establish a general minimum sample size or remove
experimental interval restrictions. The number of levels of each facet
was fixed at two.

The 0.3.0 review distinguishes reliable computation from inferential
recommendations:

1.  **Specify the model and supported designs.** Keep the response
    equation, category support, population, location constraints and
    slope normalization explicit. Changing a reference must preserve
    probabilities; changing the step owner generally changes the model.
    Identify confounded or insufficient rating designs before promising
    estimation.
2.  **Verify point estimation before recommending intervals.** Check
    objective values and estimates under independent starting values and
    integration refinement; separate local curvature from existence of a
    finite, unique optimum. Assess bias and RMSE on each parameter’s
    stated scale, with Monte Carlo uncertainty, retaining failed
    attempts in the denominator.
3.  **Complete the supported workflow.** Connect estimation and
    numerical audits to intervals, prediction, saved-result reload,
    reporting and calibration export. Document and reject unsupported
    simulation or Bayesian-export combinations. Existing saved fits must
    retain their original equation and owner conventions.
4.  **Evaluate the intended inference.** Use independent calculations
    and targeted finite-sample studies for the adopted model, estimand
    and rating design. Successful reference calculations are not
    production implementation, and new computational support does not
    remove experimental interval limits.

Two-family JML, its bias correction, alternative slope placement and the
[Uto (2021)](https://doi.org/10.1007/s41237-021-00144-w) response
equation are separate candidates. They require their own identification
and estimation contracts. A Bayesian implementation must specify the
link coefficient, ability scale and constrained prior density;
reproducing the published appendix and adopting a different symmetric
prior are distinct choices. A logistic link with coefficient 1.7 is not
an exact normal-ogive link. Metric conversion must preserve
probabilities and transform covariance and priors consistently.

These candidates are considered alongside ordinary-model needs: mixed
binary and polytomous category sets, rubric differences, and uncertainty
in linked calibrations. Current native fits use one declared category
range; a step facet does not provide facet-specific category support.
The choice to extend `mfrmr` or use a supported TAM/ConQuest workflow
depends on the required model and outputs, not a goal of reproducing
every external modeling option.

## Current Bayesian export scope and 0.3.x extensions

| Capability | Native `mfrmr` path | Stan / brms export in `0.2.4.9000` | Planned extension |
|----|----|----|----|
| Ordinary RSM / PCM | Supported within documented MML, JML, and CML scopes | Direct `data` + `spec` or `mfrm_fit` export (`stan` and `brms`, plus optional `run_cmdstan = TRUE` in `stan`) with fixed $`\mathcal{N}(0,1)`$ ability population and permitted fixed anchors / group means; checksum-bound joint-draw contrasts, arbitrary credible levels, out-of-sample new-Person scoring via [`predict()`](https://rdrr.io/r/stats/predict.html), and reporting via [`read_mfrm_posterior()`](https://ryuya-dot-com.github.io/mfrmr/reference/read_mfrm_posterior.md) | Connect posterior-predictive rating-plan comparisons where applicable |
| One-family GPCM | MML; JML only with a shared step/slope facet | Direct `data` + `spec` or `mfrm_fit` export: estimated intercept-only normal population (`stan`, with optional `run_cmdstan = TRUE`) or fixed $`\mathcal{N}(0,1)`$ population (`stan` and `brms`), with permitted fixed anchors / group means; checksum-bound joint-draw contrasts, arbitrary credible levels, out-of-sample new-Person scoring via [`predict()`](https://rdrr.io/r/stats/predict.html), and reporting via [`read_mfrm_posterior()`](https://ryuya-dot-com.github.io/mfrmr/reference/read_mfrm_posterior.md) | Connect posterior-predictive rating-plan comparisons where applicable |
| Two-family GPCM | Experimental MML within the named-role scope above | Fixed-population Stan export from an explicit `mfrm_fit`, including additional fixed facets and separate step/location roles; named roles and the prior reference follow posterior reload, contrasts, intervals, plots and reports. Direct data/spec, brms and new-Person posterior scoring remain unsupported | Integrate only explicitly supported model extensions; assess interval validity separately from computational support |
| Person-level latent regression | Conditional-normal MML via `population_formula` | Rejected explicitly | Bounded `0.3.x` extension of [`export_mfrm_model()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_model.md) |
| Non-Person facet interactions | Supported two-way fixed effects in RSM/PCM via `facet_interactions` | Rejected explicitly | Bounded `0.3.x` extension of [`export_mfrm_model()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_model.md) |

Covariate interactions inside `population_formula` and rating-facet
interactions in `facet_interactions` represent different statistical
terms with different identification constraints; they will be specified
and validated separately rather than merged. Exported Bayesian models
share the measurement model’s response equation and add explicit priors;
their posterior summaries and credible intervals are not native MML
point estimates, Wald intervals, or likelihood-ratio tests. See
[`help("export_mfrm_model")`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_model.md),
[`help("read_mfrm_posterior")`](https://ryuya-dot-com.github.io/mfrmr/reference/read_mfrm_posterior.md),
and `help("predict.mfrm_posterior_summary")`.

## Assessment planning, rater assignment, and feedback principles

### G-theory planning and operational design comparison

Univariate and multivariate `G-Study` and `D-Study` workflows, paired
multivariate D-study comparisons, and design simulations remain
first-class capabilities that do not require Bayesian software.
Classical observed-score generalizability and IRT/MFRM latent-scale
precision answer complementary questions and keep distinct labels,
variance denominators, and interval assumptions. Beyond the finite
feasible plan comparison in `0.3.0`, broader sparse future rosters,
adaptive rater allocation, and post-selection plan adjustments remain
separate research-backed extensions so single-plan intervals are never
overstated as optimal-design guarantees. See
[`help("mfrmr_methods_reference")`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_methods_reference.md),
[`help("mfrmr_workflow_methods")`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_workflow_methods.md),
and the
[`vignette("mfrmr-gtheory", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-gtheory.md).

### Rater assignment, linking, and anchors

Guidance and diagnostics for complete and incomplete rating networks
distinguish direct parameter anchors, group-mean anchors, and unanchored
common-person/common-rater linking. No single percentage of common
ratings guarantees a stable common scale across designs: graph
connectivity, overlap geometry, anchor fit, and empirical drift all
matter. Fixed anchors impose exact scale constraints and do not by
themselves establish invariance or propagate prior calibration
uncertainty; cohort shifts, panel-wide severity shifts, and individual
rater drift require identifiable comparisons (`0.3.x` and later). See
[`help("fit_mfrm")`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
and the
[`help("mfrm_calibration_workflow")`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_workflow.md).

Sample-size guidance must distinguish Persons, raters, tasks, common
recordings and ratings per Person, and name the target: ability,
severity contrast, cohort difference or population variance. Existing
evidence does not establish one minimum sample size for all RSM/PCM
uses. Further interval work must distinguish variance-boundary behavior,
population misspecification and prior-calibration uncertainty; adding
observations cannot resolve a confounded rubric or recording mode.
Compare coverage, interval width and unavailable results together before
recommending a correction or resampling method.

### Rater feedback and diagnostic screening

Severity estimates, infit/outfit `MnSq` and `ZSTD`,
centrality/restriction indices, exact and weighted agreement, bias/DFF
screens, residual networks, and exploratory clustering help assessment
teams decide which ratings, criteria, or raters warrant substantive
review. They are not automatic judgments of test fairness, rater
competence, or training causal effects. Future feedback improvements
prioritize clearer diagnostic explanations and cohesive
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)
/
[`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)
synthesis. Evaluate whether intended users can interpret these outputs;
working examples and readable figures alone do not establish that
outcome.

## 0.4.x and later model branches

New model families will be introduced only when their identification
rules, independent numerical reference checks, inferential properties,
and practical reporting workflow are established for a concrete
assessment question.

| Target series | Intended capability | Initial scope and methodological boundary |
|----|----|----|
| `0.4.x`: Multidimensional rubric profiles | Low-dimensional domain profiles, domain correlations, joint profile contrasts, and criterion/rater feedback | Start with a prespecified simple between-item binary loading matrix $`Q`$ on one rubric facet and unit slopes. Evaluate native MML initially for $`D \in \{2, 3\}`$ and Stan HMC for explicitly supported dimensions, with measured accuracy and resource limits. Verify reduction to the corresponding unit-slope model with matching step, link and scale conventions. Define and validate subscore added value for the intended score before recommending domain reporting. |
| `0.4.x+`: Rating-process and response/scoring time models | Joint or linked review of rating outcomes with timing observations | Model person production/response time and rater scoring time as distinct observation processes; never duplicate one event duration across multiple criterion rows as independent likelihood contributions. |
| `0.4.x+`: Direct rater-effect and latent-class extensions | Bounded parametric centrality, halo, or restricted rater-class models for targeted operational questions | Establish label-switching/scale identification and compare against simpler additive + diagnostic workflows under sparse designs before public adoption. |
| `0.4.x+`: Attribute-based cognitive diagnosis | Bounded rater-effects cognitive-diagnosis workflow with an explicit discrete skill-$`Q`$ matrix | Restrict initial support to small, prespecified binary attribute profiles; keep discrete skill-$`Q`$ cognitive diagnosis strictly separate in parameterization and interface from continuous multidimensional loading-$`Q`$ MFRM and exploratory clustering. |

The initial simple-loading model is not a reproduction of Uto (2021)’s
freely varying positive loadings. General cross-loadings require
explicit axis and rotation constraints; a prior that selects an
orientation is not likelihood identification. Nor does setting one
dimension make Uto (2021)’s equation identical to the current Uto & Ueno
(2020) type two-family equation. These distinctions must be resolved
before implementation or performance studies.

Foundational references for these extensions include [Uto & Ueno
(2020)](https://doi.org/10.1007/s41237-020-00115-7), [Uto
(2021)](https://doi.org/10.1007/s41237-021-00144-w), [Haberman
(2008)](https://doi.org/10.3102/1076998607302636), [Shan & Wang
(2020)](https://doi.org/10.3389/fpsyg.2020.00525), and [Ulitzsch et
al. (2023)](https://doi.org/10.3758/s13428-023-02259-2). Haberman’s
PRMSE framework motivates the subscore question; its applicability and
estimator must be specified for the chosen score target. Better global
fit alone does not establish useful subscores. Because these model
classes exist in the psychometric literature, `mfrmr` evaluates
contributions by transparency of assumptions, numerical reliability, and
end-to-end usability rather than model-name count.

## Interoperability, ergonomics, and release-readiness standards

Existing external-software routes provide a baseline; the `0.3.x` work
is bounded extension of those routes, not the introduction of
interoperability:

| Software | Existing route | Candidate change after 0.3.0 | Acceptance boundary |
|----|----|----|----|
| FACETS | Scorefile/fit-table reading, fit review and terminology guides | No new general-equivalence promise; retain explicit convention differences | Extreme scores, weights, anchors and fit-statistic degrees of freedom must be compared under matching conventions. |
| TAM; eRm and mirt | Import documented fitted components on the source scale through `import_irt_fit()` | Extend reporting for supported TAM outputs while retaining their source-model meaning | `DesignCell` locations do not identify separate facet effects or their joint covariance without the underlying design mapping. No new generic eRm/mirt importer is planned here. |
| ConQuest | Export bundles and normalization for demonstrated additive overlap specifications | Extend comparisons for bounded polytomous additive RSM/PCM specifications | Match response equations, scale constraints and uncertainty definitions; retain unsupported cases explicitly. |

Do not merge MML, unpenalized JML, bias-corrected JML, CML, G-theory
ANOVA/MLS, and Bayesian HMC outputs merely because they produce
similarly shaped tables. See the `help("mfrmr_gpcm_scope")`,
[`help("build_conquest_overlap_bundle")`](https://ryuya-dot-com.github.io/mfrmr/reference/build_conquest_overlap_bundle.md),
and `help("import_irt_fit")`.

`mfrmr` separates four distinct readiness layers rather than treating
implementation completion as universal inferential validity:

1.  **API and reference-oracle integration:** the response equation,
    scale/sign orientation, and identification constraints are enforced
    before computation; point estimates, derivatives/intervals, and
    fail-closed rejections agree with an independent reference
    calculation; and all public entry points are covered by behavioral
    regression tests.
2.  **Saved-object compatibility and external-software boundaries:**
    archived `0.2.x` RDS results reload cleanly across R sessions,
    checksum/basis provenance is verified, and structural
    non-equivalences with external software are stated explicitly.
3.  **Runtime numerical admissibility:** for a specific dataset and
    rating design, graph connectivity, boundary existence,
    positive-definite curvature, quadrature stability, or MCMC mixing
    gates govern whether quantities are reported as `available`,
    `unavailable`, or requiring review.
4.  **Finite-sample inferential and decision acceptance:** frequentist
    coverage or simulation-based calibration (counting failed or
    inadmissible replicates in the denominator), subscore added value,
    and protection against practical misinterpretation are evaluated
    separately from numerical convergence.
