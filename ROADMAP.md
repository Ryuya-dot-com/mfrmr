# mfrmr roadmap

`mfrmr` connects three tasks in rater-mediated performance assessment:

1. **Measurement models:** estimate person ability while accounting for rater severity, task or criterion difficulty, category thresholds, and supported discrimination or dynamic rater-drift structures.
2. **G-theory assessment planning:** separate observed-score variance components in a `G-Study` and project reliability, generalizability (`G`), dependability (`Phi`), and standard errors across candidate rating designs in a `D-Study`.
3. **Rater feedback and decision support:** turn agreement, fit, residual, bias (`RajuSA-Welch`), differential facet functioning (`DFF`), and conditional classification analyses into structured, reviewable evidence without automating high-stakes rater exclusion or causal fairness claims.

An assessment team should be able to explain whose scores are comparable under a stated reference panel, how much precision a different rating plan would buy, and which original ratings warrant review. Each workflow can be used independently; see [NEWS](NEWS.md) for the consolidated `0.3.2` interface.

## Public architecture in `mfrmr 0.3.2`

`mfrmr 0.3.2` provides direct numerical functions and standard R S3 generics (`predict()`, `coef()`, `vcov()`, `confint()`, `anova()`, `plot()`, `fitted()`, `residuals()`, `logLik()`, `AIC()`, `BIC()`, `nobs()`, `summary()`, and `print()`), backed by a unified C++ engine (`cpp11`):

- **Design & connectivity:** `describe_mfrm_data()`, `check_mfrm_connectivity()`, `load_mfrmr_data()`
- **Measurement & longitudinal drift:** `fit_mfrm()`, `fit_mfrm_drift()`, `mfrm_batch_fit()`, `compare_mfrm()`, `compute_information()`, `apply_empirical_bayes_shrinkage()`
- **Diagnostics, Fair(M), bias, DFF, & classification:** `diagnose_mfrm()`, `fair_average_table()`, `estimate_bias()`, `analyze_dff()`, `compute_person_fit_indices()`, `classification_table()`, `interrater_agreement()`
- **Equating & scale linking:** `make_anchor_table()`, `anchor_to_baseline()`, `detect_anchor_drift()`
- **Generalizability & Decision Studies:** `mfrm_g_study()`, `mfrm_d_study()`

The same package provides:

- Single-call (`mfrm_analysis()`) and pipeable (`mfrm_workflow()` |> `step_mfrm_measure()` |> `step_mfrm_gtheory()` |> `step_mfrm_diagnose()`) orchestration across all three pillars,
- `tidy()`, `glance()`, and `augment()` tibble extractors, and
- Reproducible APA-style Markdown, HTML, and optional `docx` / `flextable` / `kableExtra` reports (`render_mfrm_report()`, `format_mfrm_table()`).

External-software wrapper functions (`TAM`, `ACER ConQuest`, and `FACETS` file importers/exporters) were removed in `0.3.2` to keep the core package lean, self-contained, and fast.

## Supported measurement models and estimation paths (`0.3.2`)

The **Generalized Many-Facet Rasch Model (GMFRM)** extends the ordinary
many-facet Rasch model by estimating discrimination. Following Uto and
Ueno (2020), `mfrmr` uses this name for the supported many-facet GPCM
and its shared-step rating-scale form (many-facet RS-GPCM). Select
`model = "GPCM"` and specify which facets carry discrimination and steps.

| Response model | Supported estimators in `fit_mfrm()` | Scope and inferential notes |
| --- | --- | --- |
| Rating Scale (`RSM`) & Partial Credit (`PCM`) | `"MML"` (fixed or estimated normal population, `population_formula` latent regression, `EAP` and Warm's `WLE`), `"JML"`, `"JML_jeffreys"` (Jeffreys/Firth penalized JML with exact Block-Schur inverse-information `ModelSE` and `RealSE`), and `"CML"` (elementary symmetric polynomials with conditional covariance and `WLE`) | Supports fixed/group anchors (`anchors`, `group_anchors`), affine `step_constraints` (fixed values and shared thresholds with Wald, sandwich, and 1D profile `confint(..., se_type = "profile")` plus `anova()` LRTs), declarative `category_support`, and linear explanatory `facet_formulas` + `facet_data`. |
| GMFRM with discrimination by one facet | `"MML"` and `"JML"` (`EAP` and Warm GPCM `WLE`) | One `slope_facet` with geometric-mean-one identification (`sum(log(alpha)) = 0`), optional log-normal regularization (`control = list(slope_prior_sd = ...)`), `"full_predictor"` or `"ability_only"` slope placement, observed and person-clustered sandwich SEs, and nested LRTs against `PCM`/`RSM` via `anova()`. |
| GMFRM with discrimination by two facets | `"MML"` (`EAP` and Warm GPCM `WLE`) | Two named `slope_facet` columns with `spec = list(slope_reference = ...)` naming the reference facet whose slopes have geometric mean one (`Uto & Ueno, 2020`). Verify local Hessian conditioning (`vcov()`) and category exposure before interpreting small-sample slope intervals. |
| Dynamic Markov rater-severity drift | `fit_mfrm_drift()` (`"PCM"` or `"RSM"`) | Non-Bayesian Laplace-marginalized Empirical Bayes (`Louis, 1982`; `Kass & Steffey, 1989`; adapted from `Uto, 2023`) across ordered rating occasions (`time`), propagating log-drift-SD uncertainty into `TotalSE` alongside `ConditionalSE`. |

## Assessment planning (`G-Study` and `D-Study`)

Keep latent-scale IRT/MFRM conditional precision and classical observed-score generalizability distinct:

Henderson component covariance uses the actual assignment pattern and a Gaussian
plug-in model; Satterthwaite and delta intervals are approximate, especially near
variance boundaries. Unidentified component systems are rejected. Model inference
readiness is reported separately from optimizer convergence, and weighted common
reference-plan scores are conditional plug-in predictions. Use
`fair_se = TRUE` for original-scale intervals conditional on the calibration
and reference plan.

| Planning question | Public route | What the comparison supports |
| --- | --- | --- |
| Precision for **known calibrated** rater/task panels | `compute_information()` and `plot(..., type = "information")` | Conditional test information and `SEM(theta)` over the logit continuum under observed or planned calibrated exposures. Does not propagate calibration uncertainty or predict uncalibrated raters. |
| Sample-size allocation for **raters/tasks sampled from a future population** | `mfrm_g_study(..., method = "urgenova")`, `mfrm_d_study()`, `confint()`, and `plot()` | Crossed, nested (`nesting = c(Child = "Parent")`), and multivariate composite (`scores`, `weights`) Henderson Method 1 variance components, projected relative `G` and absolute `Phi`, and Satterthwaite / delta-method intervals (`Brennan, 2001`). |

## Rater diagnostics, bias, DFF, and visualizations

- **Rater fit and fair averages:** `diagnose_mfrm()` and `fair_average_table()` report `Infit`/`Outfit` `MnSq` and Wilson-Hilferty `ZSTD`, separation/reliability (using the Bayesian EAP variance decomposition under `MML`), `ModelSE` vs misfit-inflated `RealSE`, and reference-panel `FairM` alongside raw `ObsAvg`.
- **Pairwise bias (`estimate_bias()`):** Defaults to the `FACETS` 4.5.2/4.5.3 `RajuSA-Welch` convention (`df_method = "facets"`, integer-truncated Welch-Satterthwaite `df` capped at `min(N_a, N_b) - 1`; `von Davier, 2025`; `Raju, 1990`), with `"classical"` Welch-Satterthwaite and joint C++ interaction refits (`method = "joint"`) also supported.
- **Differential facet functioning (`analyze_dff()`):** Supports parallel warm-started C++ split-element `"mml_lrt"` (with optional latent-regression group-impact adjustment and sandwich SEs), `"cml_lrt"`, `"raju_welch"`, Mantel-Haenszel (`"mh"`), and ordinal logistic (`"logistic"`) tests.
- **Unified `ggplot2` graphics (`plot()`):** All `plot()` methods return editable `ggplot` objects (omitting canvas titles/footnotes by default and storing notes in `attr(p, "mfrm_notes")`) using color-vision-safe `"okabe_ito"`, `"viridis"`, or strict `R == G == B` `"monochrome"` palettes paired with distinct point shapes and line types.

## Bayesian ecosystem direction (0.4.0)

Version 0.3.2 does not import Bayesian posterior bundles or generate Stan or
brms models. Bayesian estimation is developed in `BayesianMGMFRM.jl`, with a
separate R interface planned for a later release. Existing bundles should be
read with the version of the software that created them.

The planned interface will preserve posterior draws and enough model metadata
to check that the parameterization matches the supported `mfrmr` scoring and
reporting methods. Initial support will focus on explicitly matched
unidimensional models. Prediction and diagnostics will be available only where
the imported model and observed-rating data support their interpretation;
multidimensional models will need dimension-aware summaries and plots.

## Future 0.4.x research candidates

New model families are introduced only after identification rules, independent numerical reference checks, and finite-sample inferential properties are established:

- **Multidimensional rubric profiles (`0.4.x`):** Prespecified between-item binary loading matrices $Q$ on rubric criteria, evaluated for subscore added value (`Haberman, 2008`) before recommending domain-level reporting.
- **Rating-process and scoring-time models (`0.4.x+`):** Joint review of rating outcomes and rater/examinee timing processes without duplicating single-event durations across multiple analytic criteria.
- **Graded response models (`0.4.x+`):** Cumulative-link ordinal alternatives kept distinct from adjacent-category `RSM`/`PCM`/`GPCM`.

## References

- Brennan, R. L. (2001). *Generalizability Theory*. Springer. https://doi.org/10.1007/978-1-4757-3456-0
- Eckes, T. (2015). *Introduction to Many-Facet Rasch Measurement* (2nd ed.). Peter Lang. https://doi.org/10.3726/978-3-653-04844-5
- Haberman, S. J. (2008). When can subscores have value? *Journal of Educational and Behavioral Statistics*, 33(2), 204-229. https://doi.org/10.3102/1076998607302636
- Linacre, J. M. (1989). *Many-Facet Rasch Measurement*. MESA Press.
- Raju, N. S. (1990). Determining the significance of estimated signed and unsigned areas between two item response functions. *Applied Psychological Measurement*, 14(2), 197-207.
- Uto, M. (2023). A Bayesian many-facet Rasch model with Markov modeling for rater severity drift. *Behavior Research Methods*, 55, 3910-3928. https://doi.org/10.3758/s13428-022-01997-z
- Uto, M., & Ueno, M. (2020). A generalized many-facet Rasch model and its Bayesian estimation using Hamiltonian Monte Carlo. *Behaviormetrika*, 47, 469-496. https://doi.org/10.1007/s41237-020-00115-7
- Warm, T. A. (1989). Weighted likelihood estimation of ability in item response theory. *Psychometrika*, 54(3), 427-450.
