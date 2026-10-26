# mfrmr Visual Diagnostics

Start with the [interactive ggplot2
gallery](https://ryuya-dot-com.github.io/mfrmr/articles/visual-gallery.html)
for three worked examples with Plotly views, static figures and
underlying values.

This vignette connects figures to questions about fitted ratings,
external attributes and observed-score planning. It is organized around
six practical questions:

- How well do persons, facet levels, and categories target each other?
- Which observations or levels look locally unstable?
- Is the design linked well enough across subsets or forms?
- Where do residual structure and interaction screens point next?
- How can external attributes describe groups of raters?
- How could changing the number of tasks affect an observed-score
  composite?

Model examples use packaged data; the feature hierarchy uses eight
fictional raters. The `"publication"` and `"monochrome"` presets
illustrate reusable styles, including views that remain interpretable
without colour.

If you are selecting figures for a report, use
[`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)
before or alongside this vignette. Its `"Visual Displays"` rows now
mirror the public plotting family shown here.

## Find a figure by purpose

Use [`plot()`](https://rdrr.io/r/graphics/plot.default.html) on the
fitted model or saved analysis result. In 0.2.4, the 33 former
standalone drawing helpers are no longer exported. For existing scripts,
[`help("mfrmr_plot_migration")`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_plot_migration.md)
gives every replacement and explains which `type`, `view` and `metric`
controls apply.

For observed rating agreement before model fitting, the
[rating-agreement
tutorial](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-rating-agreement.html#see-the-disagreement-then-compare-the-coefficients)
shows matched-score counts and pairwise QWK with retained sample sizes.
Those custom ggplots use
[`pairwise_kappa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/pairwise_kappa_table.md)
output. They are distinct from the fitted-workflow
exact-agreement/correlation heatmap below.

For group comparisons of a rater or task, the [DFF
tutorial](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-linking-and-dff.html#compare-group-residuals)
pairs a summary figure with response counts, display omissions and
exclusion reasons. It explains why residual differences and linked-refit
differences have different sign interpretations and what subgroup
linking can establish.

Use the plot guide before choosing a specialized function. It includes
rater feedback, category curves, external-feature groups and G/D-study
planning.

Open a preview for the full figure, interpretation and the values used
to draw it. These are different questions: a severe rater need not
misfit; feature groups describe backgrounds; a D-study plans an
observed-score measurement.

[![Wright map
preview](mfrmr-visual-diagnostics_files/figure-html/wright-1.png)**Compare
persons, facet levels and category steps**](#figure-wright)

Base R and dedicated ggplot conversion

[![Infit versus location
preview](mfrmr-visual-diagnostics_files/figure-html/fit-pathway-1.png)**Review
severity together with response fit**](#figure-fit-pathway)

Base R and dedicated ggplot conversion

[![Category probability curves
preview](mfrmr-visual-diagnostics_files/figure-html/category-curves-1.png)**Inspect
category functioning**](#figure-category-curves)

Base R and dedicated ggplot conversion

[![Subset coverage
preview](mfrmr-visual-diagnostics_files/figure-html/linking-1.png)**Inspect
observed coverage across rating subsets**](#figure-linking)

Base R; ggplot offers a different, table-based view

[![Feature dendrogram
preview](mfrmr-visual-diagnostics_files/figure-html/feature-hierarchy-1.png)**Inspect
a hierarchy of external-feature groups**](#figure-feature-hierarchy)

Base R and dedicated ggplot conversion

[![D-study coefficient curves
preview](mfrmr-visual-diagnostics_files/figure-html/d-study-planning-1.png)**Plan
reliability for a multivariate score or
composite**](#figure-d-study-planning)

Base R and dedicated ggplot conversion

Browse all selected plot routes

``` r

figures <- mfrmr::mfrmr_output_guide("plots")
knitr::kable(figures[, c("Question", "ResultFunction", "GGPlot")])
```

| Question | ResultFunction | GGPlot |
|:---|:---|:---|
| Inspect signed pairwise rater agreement | rater_network_analysis | unavailable |
| Compare weighted network inconsistency indices | rater_network_analysis | unavailable |
| Inspect conditional binary-network coefficients | fit_rater_network | unavailable |
| Compare a binary network with model simulations | fit_rater_network | unavailable |
| Compare persons, facet levels and category steps | fit_mfrm | dedicated |
| Show expected scores across ability | fit_mfrm | dedicated |
| Review severity together with response fit | fit_mfrm | dedicated |
| Compare facet locations and their uncertainty | fit_mfrm | dedicated |
| Inspect category functioning | fit_mfrm | dedicated |
| Review pooled category counts | rating_scale_table | dedicated |
| Review steps within their threshold owner | rating_scale_table | dedicated |
| Compare category curve families | category_curves_report | unavailable |
| Compare fixed-rater estimates and interval methods | mfrm_facet_intervals | dedicated |
| Review conditional interaction departures | bias_interaction_report | dedicated |
| Explore bias across all facet pairs | estimate_all_bias | dedicated |
| Read latent-regression coefficients and uncertainty | mfrm_population_intervals | dedicated |
| Read prespecified conditional population contrasts | mfrm_population_intervals | dedicated |
| Compare same-rater and other-rater score associations | rater_halo_network_analysis | dedicated |
| Show GPCM slope uncertainty | confint.mfrm_fit | native |
| Show GPCM probability or information uncertainty | mfrm_curve_intervals | native |
| Compare observed raters in a shared-rater model | fit_mfrm_random_rater | dedicated |
| Inspect testlet-model facet estimates | fit_mfrm_testlet | dedicated |
| Review conditional Person scores from a shared-rater model | score_mfrm_random_rater | dedicated |
| Review conditional Person scores from a testlet model | predict.mfrm_testlet | dedicated |
| Review response residuals under supported RSMs, two-family GPCM MML or corrected GPCM JML | mfrm_response_diagnostics | dedicated |
| Compare ordinary and extended model results | compare_mfrm | dedicated |
| Compare screening rules across known-truth conditions | mfrm_screening_sensitivity | dedicated |
| Show screening performance with uncertainty | mfrm_screening_performance | unavailable |
| Show pooled fixed-facet intervals after multiple imputation | pool_mfrm_imputed | dedicated |
| Report saved external posterior intervals | read_mfrm_posterior | dedicated |
| Inspect all residual associations and missing pairs | mfrm_residual_network | dedicated |
| Locate residual co-movement after model review | mfrm_residual_network | unavailable |
| Inspect exploratory groups of residual profiles | mfrm_residual_network | unavailable |
| Inspect separation of external-feature groups | mfrm_cluster | dedicated |
| Describe an external feature within groups | mfrm_cluster | dedicated |
| Inspect a hierarchy of external-feature groups | mfrm_cluster_hierarchical | dedicated |
| Inspect group stability across feature imputations | mfrm_cluster_imputed | dedicated |
| Choose how many external-feature components to inspect | mfrm_pca | dedicated |
| Locate entities on external-feature components | mfrm_pca | dedicated |
| Identify features contributing to a component | mfrm_pca | dedicated |
| Plan facet counts with an observed-score D-study | mfrm_d_study | unavailable |
| Inspect sources of observed-score variation | mfrm_g_study | dedicated |
| Plan reliability for a multivariate score or composite | mfrm_d_study | dedicated |
| Plan absolute or relative error in score units | mfrm_d_study | dedicated |
| Explain which error sources change across plans | mfrm_d_study | dedicated |
| Compare D-study plans including the reference | mfrm_multivariate_d_compare | unavailable |
| Inspect observed coverage across rating subsets | subset_connectivity_report | generic |
| Customize the underlying precision values | compute_information | generic |

Open the help for `ResultFunction` if you have not created the required
result. Choose a row and read `PlotCall`, `GGPlotCall`, `DataComponent`
and `Notes`. Replace `x` in `PlotCall` with the indicated result, and
save its return value as `p`. The call uses `draw = FALSE` to prepare
the figure without opening a window. Change it to `TRUE` to display it,
or follow `GGPlotCall` to customize it with ggplot2. A data component is
a table to inspect; passing that component to
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
may produce a different view from the full figure.

`dedicated` means there is a converter for the figure; `native` means
the plot already returns ggplot. `generic` describes a table-based
graphic that need not reproduce the original layout or annotations.
`unavailable` still allows the original plot and custom graphics from
`plot_data(p)`. This is a selected map, not a claim that every plot or
component has been covered. Graphical support does not extend the
model’s statistical assumptions.

## Latent regression: coefficients and specified comparisons

Latent regression asks how the conditional mean of ability relates to
Person predictors. It differs from a residual PCA or a plot of rater
attributes. An example coefficient might describe a group difference
under the fitted coding, rather than an individual learner’s score or a
rater’s severity.

The bundled-data example in
[`?mfrm_population_intervals`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_population_intervals.md)
fits an RSM model with a clearly labeled fictional predictor, calculates
intervals once and creates `ci`. After running that example, inspect the
result as follows:

``` r

summary(ci)                           # estimates, intervals and status
p <- plot(ci, type = "contrasts")     # the saved comparison, without refitting
plot_data(p, "contrast_weights")      # which conditional means were compared?
plot_data(p, "population_coding")     # factor levels and coding, if applicable
plot_data(p, "notes")                 # assumptions and experimental limits
as_ggplot(p)                          # the same saved values for customization
```

Use `plot(ci)` for coefficients. A coefficient for a continuous
predictor is per unit of its fitted predictor; the intercept depends on
zero values and factor coding. Read the saved formula and trained terms
in `plot_data(p, "population_spec")` when transformations or
interactions are involved. Different predictor units prevent a simple
ranking of importance by coefficient magnitude. A positive mean
difference predicts higher *coded* ratings; the rubric determines
whether higher ratings are favorable.

Filled points and lines show available pointwise intervals. A cross and
`CI unavailable` label retain a point whose interval could not be
supplied; inspect its `Status`, `InferenceReview` and saved checks. A
wide interval is still shown. Numerical availability does not establish
coverage, and crossing zero is not an automatic practical decision.
These RSM/PCM intervals remain experimental. Residual variance stays in
`summary(ci)` because its units differ from coefficients and mean
contrasts. Save `ci` to preserve all targets and numerical checks, and
save `p` when retaining this particular display.

## Connect a figure to a claim

Choose the proposed score interpretation before choosing a figure. The
[methods
guide](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_methods_reference.html#use-results-as-evidence-about-a-construct)
shows how to connect that claim to a design, expected pattern, competing
explanation and conclusion. These are complementary views; a report need
not include every figure.

| Figure | What to read | What the figure does not establish |
|----|----|----|
| Wright map | Whether fitted persons and rubric transitions occupy comparable parts of the scale, with the stated uncertainty | Coverage of all intended content or proof of one latent dimension |
| Category curves and counts | Predicted category use alongside actual category support for the relevant owner | That a rarely dominant category should automatically be merged |
| Fit pathway and residual displays | Where the selected model leaves unexpected variation | A psychological cause, halo/horn, or a rule for excluding a rater |
| G-study component/covariance plots | Where score variation and relations arise, including interactions and combined residual | A correlation scale, a latent factor solution, or which individual judge caused an effect |
| D-study curves and interval forests | Dependability/SEM for specified plans, or a separately requested paired difference | A winner, a universally adequate cutoff, or a paired test inferred from marginal interval overlap |

For example, satisfactory fit and a high G coefficient can coexist with
uncertain relations between criteria. Those results address different
claims; one does not override the other. Read the [worked covariance
example](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-gtheory.html#examine-a-construct-claim)
for an unresolved result and a reporting example. Keep methods,
unavailable states and notes with saved figures. A colour change or a
new panel layout does not change their inferential scope.

## Minimal setup

``` r

library(mfrmr)

toy <- load_mfrmr_data("example_operational")

fit <- fit_mfrm(
  toy,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  method = "MML",
  model = "RSM"
)

diag <- diagnose_mfrm(fit, residual_pca = "none")
checklist <- reporting_checklist(fit, diagnostics = diag)
subset(
  checklist$checklist,
  Section == "Visual Displays",
  c("Item", "Available", "NextAction")
)
#>                                   Item Available
#> 25                          Wright map      TRUE
#> 26                QC / facet dashboard      TRUE
#> 27                Residual PCA visuals     FALSE
#> 28 Connectivity / design-matrix visual      TRUE
#> 29  Inter-rater / displacement visuals      TRUE
#> 30             Strict marginal visuals      TRUE
#> 31                  Bias / DIF visuals     FALSE
#> 32      Precision / information curves      TRUE
#> 33                Fit/category visuals      TRUE
#>                                                                                                                       NextAction
#> 25                                      Include a Wright map when the manuscript benefits from a shared-scale targeting display.
#> 26                     Use the dashboard as a first-pass triage view, then move to the specific follow-up plot behind each flag.
#> 27                                         Run residual PCA if you want scree/loadings visuals for residual-structure follow-up.
#> 28                                                       Use the design-matrix view to support linkage and comparability claims.
#> 29                                       Use displacement and inter-rater views to localize QC issues after dashboard screening.
#> 30 Treat strict marginal plots as exploratory corroboration screens, then corroborate with design review and legacy diagnostics.
#> 31                                                        Run bias or DIF screening before discussing interaction-level visuals.
#> 32                                Use information curves to describe precision across theta when that is the reporting question.
#> 33                                        Use category curves and fit visuals as local descriptive follow-up after QC screening.
```

## 1. Targeting and scale structure

### Establish what higher scores mean

A logit value needs a rubric direction and a model role. For
comprehensibility, 1 = difficult / 4 = easy makes higher Person
locations mean easier speech; 1 = easy / 4 = difficult makes them mean
more difficult speech. In both cases, higher Person locations predict
higher coded scores. With the default negative Rater orientation, higher
Rater locations predict **lower** coded scores, so “stricter” is
appropriate only when higher scores are more favorable.

Record both endpoint labels with the analysis. `positive_facets` changes
the orientation of the selected facet parameters; it does not reverse
the outcome categories. Renaming categories in a figure also leaves the
model unchanged. The [visual-diagnostics
help](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.html#read-score-direction-and-diagnostic-terms-first)
explains recoding, anchors and the terms used below. The package can
report the fitted signs but cannot infer the substantive meaning of your
rubric.

### Wright map

Use the Wright map first when you want one shared logit view of persons,
facet levels, and step thresholds.

``` r

wright <- plot(fit, type = "wright", preset = "publication", show_ci = TRUE)
```

![Wright map of person abilities, facet levels and category steps on the
fitted logit scale, with requested uncertainty intervals. Higher facet
locations indicate stricter scoring or greater
difficulty.](mfrmr-visual-diagnostics_files/figure-html/wright-1.png)

Interpretation:

- Compare person density on the left to facet and step locations on the
  right.
- Large gaps suggest weaker targeting in that logit region.
- Wide overlap in marginal confidence whiskers suggests imprecision;
  estimate the relevant pairwise contrast directly before claiming that
  two levels are separated or indistinguishable.

The locations used in the figure remain available as a table:

``` r

head(plot_data(wright, component = "locations"))
#> # A tibble: 6 × 39
#>   Group Label PlotType    Estimate    SE Fixed CI_Level SE_Method  PrecisionTier
#>   <fct> <chr> <chr>          <dbl> <dbl> <lgl>    <dbl> <chr>      <chr>        
#> 1 Rater R01   Facet level   -0.606 0.181 FALSE     0.95 Observati… exploratory  
#> 2 Rater R02   Facet level   -0.382 0.166 FALSE     0.95 Observati… exploratory  
#> 3 Rater R04   Facet level    0.180 0.185 FALSE     0.95 Observati… exploratory  
#> 4 Rater R05   Facet level    0.184 0.199 FALSE     0.95 Observati… exploratory  
#> 5 Rater R03   Facet level    0.212 0.179 FALSE     0.95 Observati… exploratory  
#> 6 Rater R06   Facet level    0.412 0.219 FALSE     0.95 Observati… exploratory  
#> # ℹ 30 more variables: SupportsFormalInference <lgl>, SEUse <chr>,
#> #   CIBasis <chr>, CIUse <chr>, CIEligible <lgl>, CILabel <chr>,
#> #   Measure_Source <chr>, CI_Lower <dbl>, CI_Upper <dbl>, Step <chr>,
#> #   StepIndex <int>, BoundarySeparated <lgl>, Highlighted <lgl>, XBase <dbl>,
#> #   X <dbl>, OriginalEstimate <dbl>, BelowRange <lgl>, AboveRange <lgl>,
#> #   DisplayEstimate <dbl>, DisplayLabel <chr>, OriginalCI_Lower <dbl>,
#> #   OriginalCI_Upper <dbl>, DisplayCI_Lower <dbl>, DisplayCI_Upper <dbl>, …
```

Read the accompanying definitions and fitted directions outside the
figure:

``` r

knitr::kable(plot_data(wright, "notes"), row.names = FALSE)
```

| Type | Text |
|:---|:---|
| interpretation | Stored fit readiness plus numerical, data-support, connectivity, and stability checks passed. Treat this display as diagnostic evidence, not automatic publication approval. |
| description | Shared logit scale for persons, facets, and thresholds |
| display | Persons: N=48; mean=-0.16; median=-0.21. |
| score_coding | Score meaning is supplied by the rubric: higher coded scores need not mean better performance. Reversing category labels alone does not reverse the fitted scale. |
| orientation | Higher Person locations increase expected coded scores in these positive-discrimination models, holding other effects fixed. |
| orientation | Rater: higher locations reduce expected coded scores, holding other effects fixed. |
| orientation | Criterion: higher locations reduce expected coded scores, holding other effects fixed. |
| step | A Step describes the transition between adjacent score categories, not a learning stage or a pass/fail cut. At the corresponding predictor value, the two categories have equal probability, not necessarily probability 0.5 each. Stored step offsets and full ability-axis crossings differ when other facet effects or interactions are included; check the reference profile and step owner. |

To find a particular judge, use their ID from the fitted data. The `>`
prefix marks your selection in color or monochrome; it does not flag a
statistical problem. Use another facet name in the list to select its
levels instead.

``` r

judge <- as.character(toy$Rater[1])
focused <- plot(fit, type = "wright", highlight = list(Rater = judge),
                draw = FALSE)
subset(plot_data(focused, "locations"), Highlighted)
#> # A tibble: 1 × 39
#>   Group Label PlotType    Estimate    SE Fixed CI_Level SE_Method  PrecisionTier
#>   <fct> <chr> <chr>          <dbl> <dbl> <lgl>    <dbl> <chr>      <chr>        
#> 1 Rater R01   Facet level   -0.606 0.181 FALSE     0.95 Observati… exploratory  
#> # ℹ 30 more variables: SupportsFormalInference <lgl>, SEUse <chr>,
#> #   CIBasis <chr>, CIUse <chr>, CIEligible <lgl>, CILabel <chr>,
#> #   Measure_Source <chr>, CI_Lower <dbl>, CI_Upper <dbl>, Step <chr>,
#> #   StepIndex <int>, BoundarySeparated <lgl>, Highlighted <lgl>, XBase <dbl>,
#> #   X <dbl>, OriginalEstimate <dbl>, BelowRange <lgl>, AboveRange <lgl>,
#> #   DisplayEstimate <dbl>, DisplayLabel <chr>, OriginalCI_Lower <dbl>,
#> #   OriginalCI_Upper <dbl>, DisplayCI_Lower <dbl>, DisplayCI_Upper <dbl>, …
```

Selected levels remain visible even if the compact `top_n` selection
would omit them. They are added to the usual selection, so inspect
`plot_data(focused, "retention")` for the displayed and omitted counts.
`top_n = Inf` retains all levels. Selection does not recenter or refit
the model, and the automatic logit range is determined before
compaction.

Here **Step** means a transition between adjacent score categories: 1 to
2, 2 to 3, or 3 to 4. At a transition’s crossing, those two categories
are equally probable; other categories remain possible, so this does not
mean 50 percent each. The displayed reference sets other additive facet
effects to zero. For a particular judge and criterion, their effects
shift the crossing along the Person scale. A Step is not a developmental
stage or a contest pass mark.

The native view above remains the recommended analytic figure because it
keeps facet uncertainty and fitted step locations visible. For a closer
FACETS-facing handoff, switch the renderer and leave `show_ci` at its
default `FALSE`. The fitted coordinates do not change.

Every retained native facet level is labelled. Only label coordinates
are displaced for collision avoidance, with leader lines back to the
fitted points. Step thresholds form one vertical ladder and their labels
include the fitted transition logits.

``` r

plot(
  fit,
  type = "wright",
  renderer = "facets",
  category_labels = c(
    `1` = "Beginning", `2` = "Developing", `3` = "Secure", `4` = "Advanced"
  )
)
```

![Text-style Wright display with rubric labels Beginning, Developing,
Secure and Advanced. Locations share a fitted logit scale; labels
describe ordered categories rather than equal observed-score
intervals.](mfrmr-visual-diagnostics_files/figure-html/wright-facets-style-1.png)

This renderer uses one common logit ruler, a `*` person-frequency
column, signed facet headers, every facet level, and short labeled
score-transition lines. It is FACETS-style visual correspondence, not a
claim that `mfrmr` and FACETS produce numerically identical estimates. A
numerical comparison requires output from a documented FACETS version
and aligned estimator, identification, score, and orientation settings.
Set `show_ci = TRUE` only when you deliberately want a hybrid
FACETS-style ruler with the mfrmr uncertainty extension. Use
`draw = FALSE` and inspect the `facets_style` tables when rebuilding the
display with ggplot2 or another graphics system.

Next, use the pathway map when you want to see how expected scores
progress across theta.

``` r

plot(fit, type = "pathway", preset = "publication")
```

![Pathway display of fitted response probabilities across ability,
separated by display layer. It shows model predictions rather than tests
of rater
bias.](mfrmr-visual-diagnostics_files/figure-html/pathway-1.png)

Interpretation:

- Steeper rises indicate stronger score progression.
- Dominant-category strips show where each category is most likely to
  govern the score.
- Flat or compressed regions suggest weaker category separation.

### Fit pathway

The expected-score pathway is not a fit pathway. To review measure
against Infit, place Infit on the horizontal axis. This focused view
retains all facet levels and the 12 persons furthest from expected fit.
It is a review screen, not a representative sample of person fit. Labels
are limited to flagged facet levels; the table below identifies every
displayed row.

``` r

fit_pathway <- plot(
  fit,
  type = "fit_pathway",
  diagnostics = diag,
  fit_stat = "Infit",
  fit_scale = "mnsq",
  include_person = TRUE,
  top_n_person = 12,
  person_labels = "none",
  facet_labels = "flagged",
  show_ci = TRUE,
  preset = "publication"
)
```

![Infit mean squares against fitted locations for all facet levels and
the 12 persons furthest from expected fit, with requested location
intervals. Labels are limited to flagged facet levels; the accompanying
table identifies the points. Mean-square bands are descriptive review
thresholds, not automatic
decisions.](mfrmr-visual-diagnostics_files/figure-html/fit-pathway-1.png)

Interpretation:

- The vertical axis remains the fitted measure in logits.
- The horizontal axis is Infit MnSq; the 1.0 line is the
  model-expectation reference.
- Vertical whiskers show measure uncertainty; person and non-person rows
  have distinct uncertainty bases, recorded in the draw-free payload
  metadata.
- Treat displaced or flagged rows as review prompts, not automatic
  exclusions.

**Overfit** means less residual variation than the model expects (mean
square below 1); **underfit** means more (above 1). The selected bands
determine screening flags, so not every deviation from 1 triggers a
flag. Infit and Outfit weight residuals differently; ZSTD has a
zero-centered reference. Calibrated speech-contest judges can agree or
have similar severity without overfit. If low fit values occur, inspect
actual residual patterns, category use and rating independence before
attributing them to training. Shared discussion/copying and consistent
independent rubric use are different processes. Neither a low nor a high
value alone establishes the cause or justifies removing a judge. See the
linked help for the definitions and sources.

``` r

fit_values <- plot_data(fit_pathway, component = "table")
fit_values[, c("Facet", "Level", "FitValue", "Measure", "CIEligible")]
#>        Facet        Level  FitValue      Measure CIEligible
#> 55 Criterion      Content 0.7295356 -0.344147050       TRUE
#> 56 Criterion     Language 0.8547918  0.120452036       TRUE
#> 57 Criterion Organization 1.0155312  0.223695014       TRUE
#> 8     Person         P008 0.2514112 -0.369228192       TRUE
#> 12    Person         P012 2.0077834 -0.439367429       TRUE
#> 15    Person         P015 0.3309507  1.487872643       TRUE
#> 16    Person         P016 2.6629689 -1.341859510       TRUE
#> 17    Person         P017 0.2647010 -0.646956804       TRUE
#> 22    Person         P022 0.1263086 -0.008356172       TRUE
#> 24    Person         P024 1.7224340  0.122958029       TRUE
#> 25    Person         P025 2.2211574  0.772733413       TRUE
#> 26    Person         P026 0.1258653 -0.208437027       TRUE
#> 35    Person         P035 0.2390979  0.369651193       TRUE
#> 42    Person         P042 0.3770112 -0.337165623       TRUE
#> 48    Person         P048 1.7985777  0.149302429       TRUE
#> 49     Rater          R01 0.7724951 -0.605977633       TRUE
#> 50     Rater          R02 0.9544573 -0.382035616       TRUE
#> 51     Rater          R03 1.0111085  0.212038798       TRUE
#> 52     Rater          R04 0.9169785  0.179946170       TRUE
#> 53     Rater          R05 0.6478860  0.184236533       TRUE
#> 54     Rater          R06 0.8195287  0.411791747       TRUE
```

`CIEligible = FALSE` means that a location interval is unavailable under
the stored inference rules, not that its uncertainty is zero. Inspect
`CIBasis` and `CIUse` in the same table before interpreting whiskers.
Set `top_n_person = Inf` to retain all persons, or
`include_person = FALSE` to focus on facet levels. A crowded view can be
read through its table without changing the model or the fit-screening
rules.

### Category probabilities

Category curves ask which ordered score is most probable at each
ability. They complement the expected-score pathway: a single expected
score can hide which categories contribute to it.

``` r

category_curves <- plot(fit, type = "ccc", preset = "monochrome")
```

![Predicted category probabilities across ability for the fitted rating
scale. Line patterns and colours identify categories; the curves use a
reference profile with other additive facet effects fixed at
zero.](mfrmr-visual-diagnostics_files/figure-html/category-curves-1.png)

These are reference-profile probabilities, not observed category
frequencies or uncertainty bands. For PCM/GPCM, select and interpret the
relevant step/slope owner. A rarely dominant category is a reason to
inspect counts and rubric meaning, not automatic evidence that
categories should be merged.

``` r

head(plot_data(category_curves, component = "probabilities"))
#> # A tibble: 6 × 13
#>   Theta Probability ExpectedScore ScoreVariance Information CategoryInformation
#>   <dbl>       <dbl>         <dbl>         <dbl>       <dbl>               <dbl>
#> 1 -6          0.992          1.01       0.00835     0.00835           0.0000697
#> 2 -5.95       0.991          1.01       0.00878     0.00878           0.0000770
#> 3 -5.9        0.991          1.01       0.00922     0.00922           0.0000850
#> 4 -5.85       0.990          1.01       0.00969     0.00969           0.0000939
#> 5 -5.8        0.990          1.01       0.0102      0.0102            0.000104 
#> 6 -5.75       0.989          1.01       0.0107      0.0107            0.000114 
#> # ℹ 7 more variables: CategoryInformationShare <dbl>, Slope <dbl>, Model <chr>,
#> #   Category <chr>, CurveGroup <chr>, CurveBasis <chr>, PredictorOffset <dbl>
# Optional customization without refitting:
# as_ggplot(category_curves)
```

For observed counts and stored step points, save
`rating_scale_table(fit, diag)` and use `plot(result, type = "counts")`
or `type = "thresholds"`; both support
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md).
Counts in that figure are pooled: inspect `owner_category_table` for
each step owner’s denominator and category support. Stored step SEs are
not curve or gap intervals. The separate
[`category_curves_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/category_curves_report.md)
bundle uses base graphics for its multi-family overview and selected
curve views; custom graphics from
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
must retain the curve family and group.

## 2. Local response and level issues

Unexpected-response screening is useful for case-level review.

``` r

plot(fit, type = "unexpected", diagnostics = diag, abs_z_min = 1.5, prob_max = 0.4, view = "scatter", preset = "publication")
```

![Observed ratings screened by standardized residual size and fitted
response probability. Highlighted observations merit contextual review
rather than automatic
deletion.](mfrmr-visual-diagnostics_files/figure-html/unexpected-1.png)

Interpretation:

- Upper corners combine large residual mismatch with low model
  probability.
- Repeated appearances of the same persons or levels are more
  informative than a single extreme point.

Displacement focuses on level movement rather than individual responses.

``` r

plot(fit, type = "displacement", diagnostics = diag, anchored_only = FALSE, view = "lollipop", preset = "publication")
```

![Level-specific displacement summaries for the fitted facets, including
unanchored levels. The displayed shifts are diagnostic summaries, not
evidence that a level changed over
time.](mfrmr-visual-diagnostics_files/figure-html/displacement-1.png)

Interpretation:

- Large absolute displacement indicates stronger tension between
  observed data and current calibration.
- For anchored runs, this is especially useful as an anchor-robustness
  screen.

### Strict marginal follow-up

When you need the package’s latent-integrated follow-up path, switch to
`MML` and request `diagnostic_mode = "both"` so the legacy and strict
branches stay visible side by side. The chunk below uses compact
quadrature for a shorter runtime; final reporting should be based on a
refit with the package default or a higher quadrature setting.

``` r

fit_strict <- fit_mfrm(
  toy,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  method = "MML",
  model = "RSM",
  quad_points = 7,
  maxit = 40
)

diag_strict <- diagnose_mfrm(
  fit_strict,
  residual_pca = "none",
  diagnostic_mode = "both"
)

strict_checklist <- reporting_checklist(fit_strict, diagnostics = diag_strict)
subset(
  strict_checklist$checklist,
  Section == "Visual Displays" &
    Item %in% c("QC / facet dashboard", "Strict marginal visuals"),
  c("Item", "Available", "NextAction")
)
#>                       Item Available
#> 26    QC / facet dashboard      TRUE
#> 30 Strict marginal visuals      TRUE
#>                                                                                                                       NextAction
#> 26                     Use the dashboard as a first-pass triage view, then move to the specific follow-up plot behind each flag.
#> 30 Treat strict marginal plots as exploratory corroboration screens, then corroborate with design review and legacy diagnostics.

plot(diag_strict, type = "marginal_fit", top_n = 12, preset = "publication")
```

![Marginal fit summaries using posterior-averaged response
probabilities. These diagnostics have a different probability basis from
conditional residual
screens.](mfrmr-visual-diagnostics_files/figure-html/strict-marginal-1.png)

Interpretation:

- Treat strict marginal plots as exploratory corroboration screens, not
  as standalone inferential tests.
- Use the checklist rows to confirm that the current run actually
  supports the strict branch before routing figures into a report.
- When pairwise follow-up is needed, continue with
  `plot(diag_strict, type = "marginal_pairwise", preset = "publication")`.

## 3. Linking and coverage

When the design may be incomplete or spread across subsets, inspect the
coverage matrix before interpreting cross-subset contrasts.

``` r

sc <- subset_connectivity_report(fit, diagnostics = diag)
coverage <- plot(sc, type = "design_matrix", preset = "publication")
```

![Observation shares above a matrix of relative facet-level coverage
across observed subsets. Matrix cells compare each subset with the
largest observed count for that facet; they are not completion rates for
planned
assignments.](mfrmr-visual-diagnostics_files/figure-html/linking-1.png)

The cells divide each subset’s observed number of facet levels by the
largest such count for that facet among the observed subsets. They do
not show the proportion of planned ratings that were completed. A single
connected subset can therefore have coverage values of one even with a
sparse rating design. Low relative counts invite a closer assignment
review; they do not alone establish weak linking, informative
missingness, or random missingness.

``` r

plot_data(coverage, component = "matrix")
#>           1
#> Criterion 1
#> Person    1
#> Rater     1
head(plot_data(coverage, component = "table"))
#> # A tibble: 3 × 9
#>   Subset Facet    LevelsN Levels Observations ObservationPercent Ruler MaxLevels
#>   <fct>  <fct>      <int> <chr>         <int>              <dbl> <chr>     <int>
#> 1 1      Criteri…       3 Conte…          282                100 [===…         3
#> 2 1      Person        48 P001,…          282                100 [===…        48
#> 3 1      Rater          6 R01, …          282                100 [===…         6
#> # ℹ 1 more variable: CoverageRatio <dbl>
# Only the matrix is converted; the observation-share panel is not included.
# as_ggplot(coverage, component = "matrix")
```

Compare an explicit assignment roster with observed ratings when
distinguishing unassigned cells from missing assigned scores. Neither
should be coded as zero.

Keep three uses of *network* separate.
[`mfrm_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_network_analysis.md)
analyzes the assignment/co-observation graph and can expose disconnected
measurement subsets.
[`rater_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/rater_network_analysis.md)
analyzes pairwise score relations, and
[`rater_halo_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/rater_halo_network_analysis.md)
analyzes rater-by-criterion score-profile correlations. The latter two
do not establish assignment connectedness or a common scale. Their
centrality statistics are graph-theoretic quantities, not rating-scale
central tendency, MFRM severity logits, or causal halo evidence.

For a severity comparison, use
`plot(fit, type = "rater_severity", diagnostics = diagnostics, draw = FALSE)`
and inspect its returned `data` component with
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md).
`CIUse`, `SE_Method` and `IntervalStatus` explain whether the whiskers
support reporting, screening or further review. They are normal
uncertainty bands; “severity profile” does not mean a likelihood-profile
interval. Ordinary JML bands remain exploratory. Fixed values use
diamonds, points without intervals use crosses, and unavailable
estimates keep their rows.
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
preserves the saved endpoints and notes. Comparing two individual
whiskers does not replace an interval for their contrast.

No magnitude bands are drawn by default. Explicit `show_bands = TRUE`
adds gray distance-from-zero guides; their numerical ranges are retained
in the `Band` column. They are not homogeneity or equivalence decisions.
Locations of -0.5 and +0.5 are one logit apart even though both lie in
the central range. An origin shift can change the ranges without
changing that difference. Use
[`analyze_facet_equivalence()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_facet_equivalence.md)
with a substantively justified bound and eligible MML contrast
uncertainty for a separate equivalence analysis. An insignificant
difference or overlapping individual intervals is insufficient. Older
saved plots retain their original colors and labels; redraw from the
saved fit and matching diagnostics to adopt the new default.

If you are working across administrations, follow up with anchor-drift
plots:

``` r

drift <- detect_anchor_drift(current_fit, baseline = baseline_anchors)
plot(drift, type = "heatmap", preset = "publication")
```

## 4. Residual structure and interaction screens

Residual PCA is a follow-up layer after the main fit screen.

``` r

diag_pca <- diagnose_mfrm(fit, residual_pca = "none")
pca <- analyze_residual_pca(diag_pca, mode = "both", pca_max_factors = 4)
summary(pca)
#> Residual PCA summary
#> 
#> Overview
#>  Analysis Facets Overall components Facet component rows
#>      both      2                  0                    3
#> 
#> Residual eigenvalues
#>      Facet PC Eigenvalue Proportion
#>  Criterion  1      1.518      0.506
#>  Criterion  2      1.240      0.413
#>  Criterion  3      0.243      0.081
#> Residual PCA is exploratory residual-structure screening (overall and/or by facet), not a standalone dimensionality test or an automatic decision about dimensions or subscores. 
#> Overall: Residual correlations are unavailable for one or more columns or pairs. Check shared-person counts and residual variation; missing correlations are not replaced with zero. 
#> Rater: Residual correlations are unavailable for one or more columns or pairs. Check shared-person counts and residual variation; missing correlations are not replaced with zero.
if (nrow(pca$overall_table) > 0L) {
  plot(pca, type = "residual_pca", mode = "overall", view = "scree", preset = "publication")
}
```

The incomplete rating design in this example leaves some pairs without
enough shared Persons to compute their residual correlation, so the
overall PCA is unavailable. The summary retains the reason and any
available facet-specific results. Inspect shared-Person counts and
residual variation; do not replace missing correlations with zero or
interpret the absence of a scree plot as evidence for one dimension. A
facet-specific PCA describes its own residual matrix and cannot replace
the unavailable overall analysis.

Interpretation:

- Early components with noticeably larger eigenvalues deserve follow-up.
- Scree review should usually be paired with loading review for the
  component of interest.

### Checking one substantive dimension without fitting a multidimensional model

A single intended construct is a substantive hypothesis, not a result of
choosing a one-dimensional estimator. Ask whether one ability provides a
useful account of the ratings for the intended score and decision. Also
ask whether remaining associations arise from common tasks,
performances, assessors or category use. Several slopes do not create
several abilities, and one ability plus a testlet effect is not the same
hypothesis as two substantive abilities.

Current diagnostic entry points are available, but there is no dedicated
API that certifies unidimensionality or selects a latent dimension
count:

| Question | Current mfrmr route | Interpretation |
|----|----|----|
| Is there organized residual variation? | [`analyze_residual_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_residual_pca.md) and [`plot()`](https://rdrr.io/r/graphics/plot.default.html); optionally `parallel = TRUE`. | Exploratory PCA of standardized residuals. The default reference permutes residual columns. `parallel_method = "model_bootstrap"` generates ratings and refits supported RSM/PCM MML models; it is not yet a calibrated dimensionality test. |
| Which levels have associated residuals? | `q3_statistic(fit, facet = "Criterion")` and `plot(fit, type = "local_dependence", facet = "Criterion")`; use your intended facet. | Standardized residuals are averaged within Person/level cells and correlated across shared persons. This differs from original raw-residual Yen Q3. Default facet Rater asks about raters, not automatically about rubric dimensions. |
| Which category or rating-context margins are poorly reproduced? | `diagnose_mfrm(..., diagnostic_mode = "both")`, then `plot(diag, type = "marginal_fit")` or `plot(diag, type = "marginal_pairwise")`. | Descriptive marginal screens. Their scales omit parts of joint/calibration uncertainty; they are not a calibrated M2/C2 omnibus test. |
| Is a substantive two-dimensional model preferable? | No native multidimensional GMFRM fitting/comparison route yet. | Requires a specified alternative and comparable likelihood or predictive targets; PCA does not supply that comparison. |

A supported first-pass workflow, with the paired facet chosen to match
the question, is:

``` r

diag <- diagnose_mfrm(fit, residual_pca = "none", diagnostic_mode = "both")
pca <- analyze_residual_pca(diag, mode = "both", parallel = TRUE,
                           parallel_reps = 200, seed = 9028)
summary(pca)
# Replace Criterion with the fitted facet relevant to the question.
q3 <- q3_statistic(fit, diagnostics = diag, facet = "Criterion")
q3$pairs
q3$notes
```

`plot(pca, type = "scree")` draws the saved overall PCA;
`plot(pca, type = "loadings", mode = "facet", facet = "Criterion")` uses
its saved facet analysis. Preserve the full `pca` result with
[`saveRDS()`](https://rdrr.io/r/base/readRDS.html) so its reference,
unavailable scopes and warnings accompany the figure. There is no
dedicated `plot(q3)` method: obtain the companion heatmap from `fit`
with the same `diagnostics`, `facet` and `min_pairs`, and save its
draw-free payload.
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
can then convert that payload without recalculating residuals;
`plot_data(p, "notes")` retains the qualifications outside the figure.

Two hundred permutations are an example setting, not a qualification
threshold. Check missing comparisons, overlap counts, aggregation and
the reported reference method before interpreting a cutoff. A small
first component or few flags can reflect low power or restricted
exposure. A large component does not identify its cause. Neither
counting eigenvalues above one/two nor adding one to the number of
residual components estimates the number of substantive abilities. The
extended testlet/shared-rater models use their own posterior response
diagnostics; the ordinary residual-PCA/Q3 contract is not inherited.

For a supported RSM/PCM MML fit, a second reference asks: **would
similar residual structure arise when this fitted one-ability model
generates the ratings and is estimated again?** The Person’s generated
ability is shared across their rating rows; it is not redrawn separately
for every rating.

``` r

# fit must be an RSM/PCM MML fit with fixed standard-normal population,
# fixed quadrature, additive facets, unit weights, and no anchors or shrinkage.
reference <- analyze_residual_pca(
  fit, mode = "both", parallel = TRUE,
  parallel_method = "model_bootstrap", parallel_reps = 200, seed = 9028
)
reference$bootstrap_settings
reference$bootstrap_trials       # All attempts, including failures and warnings
reference$parallel_status        # Availability separately for each PCA scope
plot(reference, type = "overall_parallel_scree")
# If the reference is available:
# as_ggplot(plot(reference, type = "overall_parallel_scree", draw = FALSE))
```

This is more expensive than permuting residuals: 200 replicates mean 200
model refits, shared across the requested overall/facet analyses. It is
an example, not a universal recommended budget or an error-rate
guarantee. The method currently excludes GPCM, JML, estimated population
models, adaptive quadrature, anchors and extended testlet/shared-rater
fits. Generating parameters are fitted point estimates; refitting
propagates their sampling variation under that null.

The existing analyzed assignment is held fixed. Missing scores and
unassigned ratings are not filled, so this does not test or correct a
missingness mechanism. All source/replicate fits must pass numerical
convergence checks. Every planned replicate is recorded; if a scope
cannot be calculated in any replicate, its reference cutoff is withheld.
Inspect the recorded reason instead of dropping failed replicates.
Undefined or indefinite sparse correlation matrices remain unavailable.
Increasing the replicate count does not repair them.

The plotted cutoff is a **componentwise exploratory reference**, not a
multiplicity-adjusted decision across components or facets. A component
above it motivates investigating task dependence, rater effects,
assignment and substantive dimensions; it does not identify which
explanation is correct. The first component and an any-component rule
answer different questions: one can miss a departure that the other
flags. Choosing whichever rule looks most striking after viewing the
results changes the decision procedure. General false-flag rates and
sensitivity across those scenarios still require qualification. Q3 and
residual-network references are not supplied by this PCA option.

#### Shared Persons, sparse assignment and the choice of PCA columns

A **shared Person** rated by several assessors connects observations. A
**fixed parameter anchor** constrains a parameter to a supplied
numerical value. These are different uses of the word anchor: the
model-bootstrap route supports the former through the retained
assignment, but currently excludes the latter. No generated Person
ability is fixed to an observed estimate.

Consider four assessors. Rotating pairs R1/R2, R2/R3, R3/R4 and R4/R1
connect all assessors, but R1/R3 and R2/R4 have no Persons in common. An
estimable MFRM can therefore have an unavailable residual PCA across
assessors or across combined assessor/criterion columns. A few Persons
rated by everyone define those pairs, yet correlations based on
different small overlaps can still produce a matrix that is not positive
semidefinite. Neither connectedness nor one shared Person certifies that
a residual-correlation matrix is usable.

If the question concerns rubric criteria and every Person has all
criteria, a Person-by-Criterion matrix may remain available. It averages
residuals over the available assessors; it answers a different question
and may conceal assessor-specific structure. Choose this aggregation for
its scientific target, not after another analysis happens to fail:

``` r

reference$parallel_status
# For a prespecified criterion-level question, if that reference is available:
plot(reference, type = "facet_parallel_scree", facet = "Criterion")
```

#### A residual block is not automatically another substantive ability

The same response distribution can sometimes have both a testlet and a
multiple-trait interpretation. For example, with independent
standard-normal variables, set

``` math
z_b = \sqrt{\rho}\,\theta + \sqrt{1-\rho}\,u_b,
\qquad b=1,2,\quad 0<\rho<1.
```

Each block predictor has variance one and their correlation is $`\rho`$.
Using $`z_b`$ for the criteria in block $`b`$ gives either a shared
component plus Person-by-block effects, or two correlated block traits
with the same response probabilities. This equality holds for this
specified structure; it does not equate all testlet and multidimensional
models. The broader relationships are discussed by [Rijmen
(2010)](https://doi.org/10.1111/j.1745-3984.2010.00118.x).

Consequently, even an excellent residual screen cannot decide from these
ratings alone whether the blocks represent two intended constructs,
common performance effects or another shared influence. Task design,
theory, external variables and additional measurements distinguish
interpretations. A positive residual flag is evidence to investigate the
fitted model; a small or absent flag can also reflect limited
sensitivity. Fitting a multidimensional model is useful for a specified
alternative, but does not automatically resolve this interpretation
problem.

Other approaches address different parts of this question:

- **Model-generated reference checks:** simulate complete person
  response patterns under the fitted one-dimensional model, preserve the
  declared assignment/observation pattern, refit and recompute a
  prespecified residual statistic. This can assess whether the residual
  structure exceeds that expected after estimation. A design-specific
  calibrated workflow is not yet provided by the residual-PCA/Q3 API;
  more residual permutations cannot replace it. [Christensen, Makransky
  and Horton (2017)](https://doi.org/10.1177/0146621616677520)
  demonstrate why a universal Q3 cutoff is unsuitable and discuss
  parametric bootstrap references. Their raw-residual statistic is not
  mfrmr’s adaptation.
- **Limited-information fit:** tests such as M2/M2\*/C2 compare fitted
  low-order margins with observed margins. They can challenge a
  one-dimensional model without fitting a multidimensional alternative,
  but rejection is not a diagnosis of multidimensionality. See the [mirt
  M2
  documentation](https://philchalmers.github.io/mirt/docs/reference/M2.html)
  for model/category-specific availability. A valid many-facet
  adaptation must address repeated ratings, sparse opportunity counts
  and parameter uncertainty.
- **Prespecified subdomain and external-variable checks:** examine
  whether person ordering, score precision or substantive conclusions
  change across theoretically defined task/criterion subsets. Put scores
  on a justified common scale and account for their dependence and
  unequal precision. A naive t-test on separately estimated EAPs,
  especially after selecting subsets from the same residuals, is not a
  calibrated dimensionality test.
- **Explicit alternative models:** ordinal factor analysis or
  multidimensional IRT can compare theoretically justified loading
  structures. They require a defensible response unit and treatment of
  rater/testlet dependence. TAM or mirt can be used for matched
  structures externally; a generic factor model of averaged scores is
  not automatically an alternative fit to the same many-facet
  likelihood. Native multidimensional GMFRM is a later extension.

Thus a multidimensional fitter is needed to estimate and compare that
specific alternative, but **it is not a prerequisite for checking the
adequacy of the one-dimensional model**. Even after fitting
alternatives, do not assume an ordinary parameter-count chi-square test:
a one-dimensional reduction can put a latent correlation at one or leave
added loadings unidentified. Match scales, response events, populations
and numerical integration, and separate exploratory model discovery from
confirmation on new data or held-out complete units.

### Residual networks, EGA and the assignment graph answer different questions

A graph consists of nodes and edges, but their meanings must be
specified. The assignment graph records who rated what; its connectivity
concerns linking. A score-correlation graph describes observed
associations. A residual graph instead describes associations left after
a fitted response model. A residual Pearson correlation edge and a
partial-correlation edge conditional on all other residual variables are
different estimands. None is automatically causal.

[Exploratory Graph Analysis (EGA; Golino and Epskamp,
2017)](https://doi.org/10.1371/journal.pone.0174035) uses estimated
networks and community detection to explore dimension structure.
Applying the idea to fitted residuals asks about *remaining* structure
and is not the same procedure as EGA on the original item responses. The
existing
[`mfrm_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_network_analysis.md),
[`rater_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/rater_network_analysis.md)
and
[`rater_halo_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/rater_halo_network_analysis.md)
do not implement a residual EGA procedure.
[`mfrm_residual_network()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_residual_network.md)
now supplies a native **signed correlation network** and optional
hierarchical clustering, using standardized residual means per Person
and facet level. It is not EGA, which uses a different network and
community estimation procedure.

``` r

# Reuse a fitted model and its matching diagnostics.
net <- mfrm_residual_network(fit, diagnostics = diag, facet = "Criterion",
  missing = "complete", clusters = 2, min_abs = .2)
net$settings
net$pairs                    # include unavailable pairs and shared-person N
net$person_usage             # complete-person inclusion, not rating-row N
plot(net, type = "network")  # sign/strength; circular layout is not a distance
plot(net, type = "matrix")   # all correlations, before the display threshold
if (net$clustering$status == "available") plot(net, type = "dendrogram")
report <- mfrm_report(net)
export_summary_appendix(report, output_dir = "residual-review")
saveRDS(net, "residual-review/network.rds")
```

Clustering uses `sqrt(2*(1-r))` distances between centered unit-length
residual profiles on a common complete-person sample. Average or
complete linkage and the supplied number of groups define an exploratory
partition. Strong negative correlations are dissimilarity, not
similarity by absolute value. The display threshold never changes the
groups. Without a common usable sample or variation at every level,
clustering is unavailable; the network retains that reason. Use
`missing = "pairwise"` without clustering when pair-specific overlap is
the intended descriptive analysis. Neither route estimates group
stability.

Random forests belong to a separately designed prediction stage.
[Wesolowski (2019)](https://doi.org/10.1111/jedm.12227) formed rater
groups by k-means on differential-rater-functioning indices and then
predicted those labels with random forests. Predicting exploratory
labels does not validate latent classes. The [function
help](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_residual_network.md)
explains unsupervised learning, supervised prediction, leakage,
resampling and why out-of-bag accuracy alone cannot validate labels
discovered on all data.

For example, residual associations among accuracy criteria across
different tasks and assessors may motivate a second substantive-domain
hypothesis. Associations confined to one performance may instead
motivate a testlet model. Associations organized by assessor or
assignment panel require review of those effects. These patterns guide
follow-up; the graph alone cannot distinguish all competing
explanations. Communities, centrality and edge density are not proof of
dimensions, rater quality or an omitted causal mechanism. No edges can
also reflect regularization or weak data rather than independence.

For any residual-network workflow, specify nodes (criterion,
task-by-criterion, or another justified unit), residual type,
aggregation and pairwise person counts. Sparse pairwise correlations may
be undefined or form an invalid correlation matrix. Do not encode
unassigned cells as zero, treat a missing edge as a zero association, or
silently repair a matrix and then claim the same estimand. Record
regularization and community choices; examine edge and community
stability with resampling appropriate to the shared effects. A single
nominal sample size can misrepresent strongly unequal pair overlap.

[bootEGA](https://r-ega.net/reference/bootEGA.html) offers
network/dimension stability analyses, but applying it to a fixed
residual matrix does not propagate uncertainty from fitting the MFRM.
Its empirical-correlation bootstrap is not a one-dimensional MFRM null
simulation. Finally, [residual network modeling (Epskamp, Rhemtulla and
Borsboom, 2017)](https://doi.org/10.1007/s11336-017-9557-x) models
residual dependencies jointly with latent variables. Drawing a graph
from fitted residuals does not fit such a joint model or produce its
likelihood. A future mfrmr network view should reuse the checked
residual/overlap outputs and provide a signed heatmap/table alongside
the network, with the same edge values and uncertainty. It should remain
exploratory until its statistical reference is qualified.

For interaction screening, use the packaged bias example.

Here **bias** means an additional departure for a particular
combination, such as one judge scoring Content, after accounting for the
fitted baseline. It is distinct from overall rater severity or proof of
unfairness. A positive `Bias Size` increases expected coded scores; with
high-is-good scoring this favors the combination, whereas a positive
default Rater severity reduces scores. Reverse-coded rubrics reverse
that substantive interpretation. The profile below uses mean
**absolute** bias, so it describes magnitude; inspect signed rows in
`bias$table` to see direction. Its uncertainty holds the baseline
calibration fixed.

``` r

bias_df <- load_mfrmr_data("example_bias")

fit_bias <- fit_mfrm(
  bias_df,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  method = "MML",
  model = "RSM",
  quad_points = 7
)

diag_bias <- diagnose_mfrm(fit_bias, residual_pca = "none")
bias <- estimate_bias(fit_bias, diag_bias, facet_a = "Rater", facet_b = "Criterion")

bias_figure <- plot(bias, type = "bias", view = "facet_profile", preset = "publication")
```

![Rater-by-criterion interaction profiles from the fitted bias analysis.
Differences identify combinations for review and do not establish a
causal
explanation.](mfrmr-visual-diagnostics_files/figure-html/bias-1.png)

The definition, sign, magnitude-only profile and uncertainty
qualifications are retained in `plot_data(bias_figure, "notes")` and
shown by `print(bias_figure)`.

Interpretation:

- Facet profiles are useful for seeing whether a small number of levels
  drives most flagged interaction cells.
- Treat these plots as screening evidence and inspect the corresponding
  tables, cell counts and calibration limitations. Several views of the
  same estimates are not independent confirmation of bias.

For repeat plotting, save `bias_interaction_report(bias, ...)` after
choosing the review thresholds. `plot(result, type = "scatter")`
compares the observed-minus-expected score average with conditional bias
in logits; `type = "ranked"` shows saved interaction estimates. These
two views support
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md),
including conditional bounds when `show_ci = TRUE`. They hold
calibration fixed. The other bias views use base or custom graphics.

Rater centrality and halo have different targets.
[`rater_centrality_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/rater_centrality_table.md)
returns indirect indices in a plain list; save the list and review
source status and unavailable-index reasons alongside its data frames.
[`rater_halo_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/rater_halo_network_analysis.md)
returns observed-score profile correlations. Its `edge_distribution`,
selected `halo_summary` metric and retained-edge `matrix` views support
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md);
use base graphics for the network. Save the whole halo result to retain
its pair counts, edge filters and caveats. Neither result is
automatically added to an aggregate
[`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md).
These views do not distinguish halo from horn effects: a negative
impression can lower several criterion ratings together without creating
a negative correlation. For a beginner explanation of severity,
centrality, halo/horn and local dependence, see
[`help("mfrmr_methods_reference")`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_methods_reference.md).

## 5. Custom figures without losing the evidence boundary

The built-in plots are intended as safe defaults. Use
`preset = "monochrome"` when a journal, accessibility review, or print
workflow needs grayscale output. For journal figures, teaching material,
dashboards, or lab-specific styles, use `draw = FALSE` and the plot-data
accessors instead of editing screenshots.

``` r

plot(fit, type = "wright", preset = "monochrome")
```

![Monochrome Wright map of person, facet and step locations on the
common logit scale. The accompanying code extracts the plotted locations
for custom
displays.](mfrmr-visual-diagnostics_files/figure-html/custom-plot-data-1.png)

``` r


wright_payload <- plot(fit, type = "wright", draw = FALSE, preset = "publication")
plot_data_components(wright_payload)
#>      PlotName             Component                Role     ObjectType Rows
#> 1  wright_map          wright_style               style      character   NA
#> 2  wright_map              renderer    scalar_or_vector      character   NA
#> 3  wright_map       visual_contract    scalar_or_vector      character   NA
#> 4  wright_map                person          table_data     data.frame   48
#> 5  wright_map     person_exclusions          table_data     data.frame    0
#> 6  wright_map           person_hist            metadata list:histogram   NA
#> 7  wright_map          person_stats          table_data     data.frame    1
#> 8  wright_map             locations          table_data     data.frame   12
#> 9  wright_map          label_points          table_data     data.frame   12
#> 10 wright_map         group_summary summary_or_guidance     data.frame    3
#> 11 wright_map          group_levels            settings      character   NA
#> 12 wright_map               y_range            settings         double   NA
#> 13 wright_map      display_settings            settings     data.frame    1
#> 14 wright_map           label_limit    scalar_or_vector        integer   NA
#> 15 wright_map             highlight    scalar_or_vector           NULL   NA
#> 16 wright_map             retention          table_data     data.frame    3
#> 17 wright_map        retention_note summary_or_guidance      character   NA
#> 18 wright_map                 title    scalar_or_vector      character   NA
#> 19 wright_map              subtitle    scalar_or_vector      character   NA
#> 20 wright_map               show_ci    scalar_or_vector        logical   NA
#> 21 wright_map   uncertainty_display    scalar_or_vector      character   NA
#> 22 wright_map                 group    scalar_or_vector           NULL   NA
#> 23 wright_map                preset            settings      character   NA
#> 24 wright_map                legend               style     data.frame    5
#> 25 wright_map       reference_lines          annotation     data.frame    1
#> 26 wright_map        scale_contract          table_data     data.frame    1
#> 27 wright_map             plot_name    scalar_or_vector      character   NA
#> 28 wright_map                 notes summary_or_guidance     data.frame    8
#> 29 wright_map         fit_readiness          fit_review     data.frame    6
#> 30 wright_map interpretation_status summary_or_guidance      character   NA
#> 31 wright_map   interpretation_note summary_or_guidance      character   NA
#> 32 wright_map               display            metadata      list:list   NA
#>    Columns Length IsTabular                                          Accessor
#> 1       NA      1     FALSE          plot_data(x, component = "wright_style")
#> 2       NA      1     FALSE              plot_data(x, component = "renderer")
#> 3       NA      1     FALSE       plot_data(x, component = "visual_contract")
#> 4       22     22      TRUE                plot_data(x, component = "person")
#> 5       22     22      TRUE     plot_data(x, component = "person_exclusions")
#> 6        6      6     FALSE           plot_data(x, component = "person_hist")
#> 7        7      7      TRUE          plot_data(x, component = "person_stats")
#> 8       39     39      TRUE             plot_data(x, component = "locations")
#> 9       45     45      TRUE          plot_data(x, component = "label_points")
#> 10      16     16      TRUE         plot_data(x, component = "group_summary")
#> 11      NA      3     FALSE          plot_data(x, component = "group_levels")
#> 12      NA      2     FALSE               plot_data(x, component = "y_range")
#> 13       8      8      TRUE      plot_data(x, component = "display_settings")
#> 14      NA      1     FALSE           plot_data(x, component = "label_limit")
#> 15      NA      0     FALSE             plot_data(x, component = "highlight")
#> 16       6      6      TRUE             plot_data(x, component = "retention")
#> 17      NA      1     FALSE        plot_data(x, component = "retention_note")
#> 18      NA      1     FALSE                 plot_data(x, component = "title")
#> 19      NA      1     FALSE              plot_data(x, component = "subtitle")
#> 20      NA      1     FALSE               plot_data(x, component = "show_ci")
#> 21      NA      1     FALSE   plot_data(x, component = "uncertainty_display")
#> 22      NA      0     FALSE                 plot_data(x, component = "group")
#> 23      NA      1     FALSE                plot_data(x, component = "preset")
#> 24       4      4      TRUE                plot_data(x, component = "legend")
#> 25       5      5      TRUE       plot_data(x, component = "reference_lines")
#> 26      15     15      TRUE        plot_data(x, component = "scale_contract")
#> 27      NA      1     FALSE             plot_data(x, component = "plot_name")
#> 28       2      2      TRUE                 plot_data(x, component = "notes")
#> 29       2      2      TRUE         plot_data(x, component = "fit_readiness")
#> 30      NA      1     FALSE plot_data(x, component = "interpretation_status")
#> 31      NA      1     FALSE   plot_data(x, component = "interpretation_note")
#> 32       2      2     FALSE               plot_data(x, component = "display")
#>                                                                     Notes
#> 1                                                                        
#> 2                                                                        
#> 3                                                                        
#> 4                                                                        
#> 5                                                                        
#> 6                                                                        
#> 7                                                                        
#> 8                                                                        
#> 9                                                                        
#> 10                           Use for captions, QA checks, or report text.
#> 11                                                                       
#> 12                                                                       
#> 13                                                                       
#> 14                                                                       
#> 15                                                                       
#> 16                                                                       
#> 17                           Use for captions, QA checks, or report text.
#> 18                                                                       
#> 19                                                                       
#> 20                                                                       
#> 21                                                                       
#> 22                                                                       
#> 23                                                                       
#> 24                 Use to reproduce color, line-type, or legend mappings.
#> 25 Use with primary data to draw thresholds, labels, and reference lines.
#> 26                                                                       
#> 27                                                                       
#> 28                           Use for captions, QA checks, or report text.
#> 29                                                                       
#> 30                           Use for captions, QA checks, or report text.
#> 31                           Use for captions, QA checks, or report text.
#> 32                                                                       
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    ColumnNames
#> 1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
#> 2                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
#> 3                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
#> 4                                                                                                                                                                                                   Person, Estimate, SD, PosteriorSD, SE, Extreme, PrimaryEstimate, OptimizerEstimate, DisplayEstimate, DisplayAdjustment, ParameterStatus, BoundaryDirection, ResponseExtreme, ResponseRows, WeightedResponseTotal, PrimaryEstimateBasis, OptimizerEstimateUse, ReasonCodes, ReadinessContractVersion, SourceFitReadiness, SourceInferenceReady, EstimateUse
#> 5                                                                                                                                                                                                   Person, Estimate, SD, PosteriorSD, SE, Extreme, PrimaryEstimate, OptimizerEstimate, DisplayEstimate, DisplayAdjustment, ParameterStatus, BoundaryDirection, ResponseExtreme, ResponseRows, WeightedResponseTotal, PrimaryEstimateBasis, OptimizerEstimateUse, ReasonCodes, ReadinessContractVersion, SourceFitReadiness, SourceInferenceReady, EstimateUse
#> 6                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               breaks, counts, density, mids, xname, equidist
#> 7                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             N, ReviewExcludedN, FiniteN, BoundaryExcludedN, Mean, Median, SD
#> 8                                                                    Group, Label, PlotType, Estimate, SE, Fixed, CI_Level, SE_Method, PrecisionTier, SupportsFormalInference, SEUse, CIBasis, CIUse, CIEligible, CILabel, Measure_Source, CI_Lower, CI_Upper, Step, StepIndex, BoundarySeparated, Highlighted, XBase, X, OriginalEstimate, BelowRange, AboveRange, DisplayEstimate, DisplayLabel, OriginalCI_Lower, OriginalCI_Upper, DisplayCI_Lower, DisplayCI_Upper, CIClippedLower, CIClippedUpper, CIClipped, BoundaryEnd, CISuppressed, CIDisplayStatus
#> 9  Group, Label, PlotType, Estimate, SE, Fixed, CI_Level, SE_Method, PrecisionTier, SupportsFormalInference, SEUse, CIBasis, CIUse, CIEligible, CILabel, Measure_Source, CI_Lower, CI_Upper, Step, StepIndex, BoundarySeparated, Highlighted, XBase, X, OriginalEstimate, BelowRange, AboveRange, DisplayEstimate, DisplayLabel, OriginalCI_Lower, OriginalCI_Upper, DisplayCI_Lower, DisplayCI_Upper, CIClippedLower, CIClippedUpper, CIClipped, BoundaryEnd, CISuppressed, CIDisplayStatus, LabelY, LabelSide, LabelX, LabelHjust, LabelText, LabelDisplaced
#> 10                                                                                                                                                                                                                                                                                                                                                                                                               Group, PlotType, Min, Q1, Median, Q3, Max, DisplayMin, DisplayQ1, DisplayMedian, DisplayQ3, DisplayMax, N, XBase, TargetGap, DisplayTargetGap
#> 11                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
#> 12                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
#> 13                                                                                                                                                                                                                                                                                                                                                                                                                           Renderer, LowerLogit, UpperLogit, AutoRangePolicy, BoundaryLevelsAtEnds, CIClippedCount, BoundaryCIEndpointCount, CIDisplayPolicy
#> 14                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
#> 15                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
#> 16                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   Component, Shown, Total, Omitted, RequestedTopN, Complete
#> 17                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
#> 18                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
#> 19                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
#> 20                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
#> 21                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
#> 22                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
#> 23                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
#> 24                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               label, role, aesthetic, value
#> 25                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          axis, value, label, linetype, role
#> 26                                                                                                                                                                                                                                                                    Model, Method, CoordinateBasis, PopulationSD, SlopeBasis, GpcmModelFamily, GpcmSlopeAction, GpcmSlopeComposition, GpcmLatentDimensionCount, GpcmMmlIdentification, GpcmEstimatorFamily, GpcmStatisticalPenalty, GpcmFiniteParameterBox, GpcmExtremePersonPolicy, FixedLatentSDSlopeField
#> 27                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
#> 28                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  Type, Text
#> 29                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              Domain, Status
#> 30                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
#> 31                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
#> 32                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      show_title, show_notes

locations <- plot_data(wright_payload, component = "locations")
head(locations)
#> # A tibble: 6 × 39
#>   Group Label PlotType    Estimate    SE Fixed CI_Level SE_Method  PrecisionTier
#>   <fct> <chr> <chr>          <dbl> <dbl> <lgl>    <dbl> <chr>      <chr>        
#> 1 Rater R01   Facet level   -0.606 0.181 FALSE     0.95 Observati… exploratory  
#> 2 Rater R02   Facet level   -0.382 0.166 FALSE     0.95 Observati… exploratory  
#> 3 Rater R04   Facet level    0.180 0.185 FALSE     0.95 Observati… exploratory  
#> 4 Rater R05   Facet level    0.184 0.199 FALSE     0.95 Observati… exploratory  
#> 5 Rater R03   Facet level    0.212 0.179 FALSE     0.95 Observati… exploratory  
#> 6 Rater R06   Facet level    0.412 0.219 FALSE     0.95 Observati… exploratory  
#> # ℹ 30 more variables: SupportsFormalInference <lgl>, SEUse <chr>,
#> #   CIBasis <chr>, CIUse <chr>, CIEligible <lgl>, CILabel <chr>,
#> #   Measure_Source <chr>, CI_Lower <dbl>, CI_Upper <dbl>, Step <chr>,
#> #   StepIndex <int>, BoundarySeparated <lgl>, Highlighted <lgl>, XBase <dbl>,
#> #   X <dbl>, OriginalEstimate <dbl>, BelowRange <lgl>, AboveRange <lgl>,
#> #   DisplayEstimate <dbl>, DisplayLabel <chr>, OriginalCI_Lower <dbl>,
#> #   OriginalCI_Upper <dbl>, DisplayCI_Lower <dbl>, DisplayCI_Upper <dbl>, …

pathway_long <- plot_data(
  fit,
  type = "pathway",
  component = "pathway_long",
  preset = "publication"
)
head(pathway_long[, c("Layer", "CurveGroup", "Theta", "Value")])
#>            Layer CurveGroup Theta    Value
#> 1 expected_score     Common -6.00 1.008386
#> 2 expected_score     Common -5.95 1.008814
#> 3 expected_score     Common -5.90 1.009264
#> 4 expected_score     Common -5.85 1.009736
#> 5 expected_score     Common -5.80 1.010233
#> 6 expected_score     Common -5.75 1.010755
```

When you build a custom figure, keep the helper’s guidance tables with
the plot data:

``` r

names(wright_payload$data)
#>  [1] "wright_style"          "renderer"              "visual_contract"      
#>  [4] "person"                "person_exclusions"     "person_hist"          
#>  [7] "person_stats"          "locations"             "label_points"         
#> [10] "group_summary"         "group_levels"          "y_range"              
#> [13] "display_settings"      "label_limit"           "highlight"            
#> [16] "retention"             "retention_note"        "title"                
#> [19] "subtitle"              "show_ci"               "uncertainty_display"  
#> [22] "group"                 "preset"                "legend"               
#> [25] "reference_lines"       "scale_contract"        "plot_name"            
#> [28] "notes"                 "fit_readiness"         "interpretation_status"
#> [31] "interpretation_note"   "display"
wright_payload$data$reference_lines
#>   axis value                    label linetype      role
#> 1    h     0 Centered logit reference   dashed reference
```

Those metadata are the guardrails for captions and interpretation. They
let you change colors, labels, panels, or rendering technology while
preserving the same measurement scale, reference lines, caveats, and
reporting role used by the package-native plot.

### Save a figure with its values and notes

Saving only a PNG loses the underlying values and interpretation notes.
Save the complete returned object as well. This example uses a temporary
filename; choose a project filename to keep it beyond this R session.
Keep the rubric alongside the plot: the labels below are the
illustrative labels used earlier, not wording that mfrmr inferred from
the scores. Use your actual rubric wording.

``` r

figure_file <- tempfile(fileext = ".rds")
figure_record <- list(plot = wright,
  rubric = c(`1` = "Beginning", `2` = "Developing", `3` = "Secure", `4` = "Advanced"))
saveRDS(figure_record, figure_file)
saved_record <- readRDS(figure_file)
saved_figure <- saved_record$plot
saved_record$rubric
#>            1            2            3            4 
#>  "Beginning" "Developing"     "Secure"   "Advanced"
print(saved_figure)
#> <mfrm_plot_data>
#>   name     : wright_map
#>   title    : Wright map
#>   subtitle : Shared logit scale for persons, facets, and thresholds
#>   notes    :
#>     [interpretation] Stored fit readiness plus numerical, data-support,
#>     connectivity, and stability checks passed. Treat this display as
#>     diagnostic evidence, not automatic publication approval.
#>     [display] Persons: N=48; mean=-0.16; median=-0.21.
#>     [score_coding] Score meaning is supplied by the rubric: higher coded
#>     scores need not mean better performance. Reversing category labels
#>     alone does not reverse the fitted scale.
#>     [orientation] Higher Person locations increase expected coded scores in
#>     these positive-discrimination models, holding other effects fixed.
#>     [orientation] Rater: higher locations reduce expected coded scores,
#>     holding other effects fixed.
#>     [orientation] Criterion: higher locations reduce expected coded scores,
#>     holding other effects fixed.
#>     [step] A Step describes the transition between adjacent score
#>     categories, not a learning stage or a pass/fail cut. At the
#>     corresponding predictor value, the two categories have equal
#>     probability, not necessarily probability 0.5 each. Stored step offsets
#>     and full ability-axis crossings differ when other facet effects or
#>     interactions are included; check the reference profile and step owner.
#>   data     :
#>     $wright_style : character [1]
#>     $renderer : character [1]
#>     $visual_contract : character [1]
#>     $person : data.frame [48 x 22]
#>     $person_exclusions : data.frame [0 x 22]
#>     $person_hist : list (6 slots)
#>     $person_stats : data.frame [1 x 7]
#>     $locations : data.frame [12 x 39]
#>     $label_points : data.frame [12 x 45]
#>     $group_summary : data.frame [3 x 16]
#>     $group_levels : character [3]
#>     $y_range : double [2]
#>     $display_settings : data.frame [1 x 8]
#>     $label_limit : integer [1]
#>     $highlight : NULL
#>     $retention : data.frame [3 x 6]
#>     $retention_note : character [1]
#>     $show_ci : logical [1]
#>     $uncertainty_display : character [1]
#>     $group : NULL
#>     $preset : character [1]
#>     $scale_contract : data.frame [1 x 15]
#>     $plot_name : character [1]
#>     $fit_readiness : data.frame [6 x 2]
#>     $interpretation_status : character [1]
#>     $interpretation_note : character [1]
#>     $display : list (2 slots)
#>   legend   : 5 entries
#>   ref lines: 1
#> Use `plot_data()` to extract the saved values and notes.
#> For supported views, `as_ggplot()` redraws this saved result.
identical(plot_data(saved_figure, "locations"), plot_data(wright, "locations"))
#> [1] TRUE
```

For the supported Wright-map conversion, redraw the saved values without
refitting or recalculating uncertainty:

``` r

as_ggplot(saved_figure)
```

[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
requires the optional ggplot2 package. Save the fit and matching
diagnostics too if you want to choose a different analysis view later.
The plot guide above distinguishes dedicated conversions, different
table-based views and plots without automatic conversion. This example
does not promise the same layout for every renderer or conversion of
every plot family.

### Set an appearance once for several plots

Use `options(mfrmr.plot_preset = "monochrome")` to set a common default
in the development version. This example restores the previous option
when it ends:

``` r

local({
  old <- options(mfrmr.plot_preset = "monochrome")
  on.exit(options(old))
  saved <- plot(fit, type = "ccc", draw = FALSE)
  special <- plot(fit, type = "ccc", preset = "publication", draw = FALSE)
  c(session_default = saved$data$preset, explicit_override = special$data$preset)
})
#>   session_default explicit_override 
#>      "monochrome"     "publication"
```

The choices are `"standard"`, `"publication"`, `"compact"` and
`"monochrome"`. Explicit `preset` wins over the option; omitting both
retains `"standard"`. Explicit `preset = NULL` also selects the package
default. Remove the session setting with
`options(mfrmr.plot_preset = NULL)`.

A supported `as_ggplot(saved)` conversion uses the saved preset, whereas
a new `plot(fit, ...)` call uses the current option. Set the option in a
script or use explicit arguments to reproduce its appearance in another
session. This applies to the common preset controls, including category,
coverage and network report plots. Extended-model plots with separate
`palette` controls retain their own settings. It does not change
estimates, confidence levels, screening thresholds or the user’s global
ggplot theme.

### Use a common title argument

In the development version, eight existing helpers accept `title`:
[`plot()`](https://rdrr.io/r/graphics/plot.default.html),
[`plot()`](https://rdrr.io/r/graphics/plot.default.html),
[`plot()`](https://rdrr.io/r/graphics/plot.default.html),
[`plot()`](https://rdrr.io/r/graphics/plot.default.html),
[`plot()`](https://rdrr.io/r/graphics/plot.default.html),
[`plot()`](https://rdrr.io/r/graphics/plot.default.html),
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) and
[`plot()`](https://rdrr.io/r/graphics/plot.default.html).

``` r

plain <- plot(fit, type = "bubble", diagnostics = diag, view = "infit_outfit", title = NULL, preset = "monochrome", draw = FALSE)
as_ggplot(plain)
```

![Infit and Outfit mean squares for fitted facet levels, with the title
omitted. Bubble sizes reflect rating counts; reference lines and the
saved descriptive review band remain
unchanged.](mfrmr-visual-diagnostics_files/figure-html/title-controls-1.png)

``` r

# Reuse the saved values, screening references and interval settings.
plain$data$reference_lines
#>   axis value                 label linetype      role
#> 1    h   0.5 Lower fit review band   dashed threshold
#> 2    h   1.0          Ideal Outfit   dashed reference
#> 3    h   1.5 Upper fit review band   dashed threshold
#> 4    v   0.5 Lower fit review band   dashed threshold
#> 5    v   1.0           Ideal Infit   dashed reference
#> 6    v   1.5 Upper fit review band   dashed threshold
```

Omit `title` for the default heading, supply
`title = "Scoring patterns"` to replace it, or use `title = NULL` (or
`""`) to hide it. This does not remove subtitles, legends, screening
settings or interpretation notes. The dashboard method also accepts
`plot(dashboard, title = NULL)`. Keep review-only limitations in the
figure caption or accompanying report if its heading is hidden.

Existing `main` calls and positional arguments still work without
deprecation warnings. `main = NULL` retains its earlier meaning of “use
the default heading”. Do not supply both `main` and `title`, even with
the same value. These aliases do not imply that every plot has an
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
converter; consult `mfrmr_output_guide("plots")` for the supported
route.

### Fair Scores and annotations outside the figure

Use `view = "measure"` to relate measures to fair scores, `"scatter"` to
compare observed and fair scores, or `"difference"` to rank their gaps.
FairM uses mean reference measures; FairZ uses zero reference measures.
FairZ is an expected score on the internal score scale, not a z-score.
Observed-minus-fair gaps also reflect assignment and person mix, so they
do not by themselves establish rater bias.

``` r

p_fair <- plot(fit, type = "fair_average", diagnostics = diag, facet = "Rater", metric = "FairZ", view = "measure", show_ci = TRUE, preset = "monochrome", show_title = FALSE, show_notes = FALSE, draw = FALSE)
p_fair$data$notes
p_fair$data$plot_data
p_fair$data$excluded
# Requires ggplot2:
g_fair <- as_ggplot(p_fair)
g_fair
attr(g_fair, "mfrmr_notes")
```

Use `draw = TRUE` to draw the base-R version. Titles and notes remain in
the returned object when hidden in the figure. The same annotation
controls apply to Wright, expected-score pathway, and CCC plots; they do
not change readiness or interval eligibility. Keep the applicable notes
in the surrounding caption or report. Other plotting helpers have their
own documented options.

Fair-score intervals remain diagnostic-only (`CI_Eligible = FALSE`),
with full-refit coverage unverified. RSM/PCM plots propagate only the
focal measure SE, holding thresholds and reference measures fixed; they
require a fitted model, not just a stored fair-average bundle. GPCM-MML
plots use available structural delta-method SEs for non-Person rows,
conditioning on Person EAP/reference means. The table option
`fair_se = TRUE` supplies the GPCM route, not RSM/PCM fair-score SEs.
Historical table `SE` columns describe measures. Difference-view
whiskers hold observed means fixed and are not confidence intervals for
the observed-minus-fair gap.

Expected-score and CCC curves use six line types: solid, dashed, dotted,
dotdash, longdash, and twodash. Fair-score plots use six point shapes.
These encodings repeat for larger sets; select facets or use panels to
keep a grayscale figure readable. Check labels and line separation at
the intended output size rather than relying on color or gray levels
alone.

## 6. Secondary visual layer

The package ships a complementary visual layer for teaching and
diagnostic follow-up. These helpers are not default reporting figures;
use them after the main screens above.

- `plot(fit, type = "guttman", diagnostics = diagnostics)` renders a
  person x facet-level response matrix with an unexpected-response
  overlay, for teaching-oriented scalogram intuition and local triage.
- `plot(fit, type = "residual_qq", diagnostics = diagnostics)` plots a
  Normal Q-Q of person-level standardized residual aggregates as
  exploratory follow-up on residual tail behavior.
- `plot(fit_a, type = "trajectory", comparison = list(T2 = fit_b), labels = c("T1", "T2"))`
  tracks rater severity across named waves. The helper does not perform
  linking; supply waves that have already been placed on a common
  anchored scale (see
  [`vignette("mfrmr-linking-and-dff")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-linking-and-dff.md))
  before interpreting movement as rater drift.
- `plot(fit, type = "agreement", view = "heatmap", diagnostics = diagnostics)`
  renders a compact pairwise rater x rater agreement matrix; pass
  `metric = "correlation"` to colour by the Pearson-style `Corr` column
  instead of exact agreement.
- `response_time_review(data, person, facets, time)` summarizes
  response-time metadata by person, facet, and score category. Pair it
  with [`plot()`](https://rdrr.io/r/graphics/plot.default.html) for
  distribution and grouped timing plots. This is a descriptive QC layer,
  not a joint speed-accuracy model.
- `plot(fit_eb, type = "shrinkage", view = "funnel", show_ci = TRUE)`
  draws raw and empirical-Bayes shrunken facet estimates on the same
  row, with optional confidence whiskers for both estimates. Use this
  only after
  [`apply_empirical_bayes_shrinkage()`](https://ryuya-dot-com.github.io/mfrmr/reference/apply_empirical_bayes_shrinkage.md)
  or `fit_mfrm(..., facet_shrinkage = "empirical_bayes")`.

### Save the agreement result and its review rules

Keep the agreement table when drawing several views. Its matched-context
counts and saved thresholds explain the figure; correlation describes
score ordering, while exact agreement describes equal scores. Neither
supplies an automatic rater-quality decision. Model-expected agreement
is a fitted-model baseline, not chance agreement.

``` r

agreement <- interrater_agreement_table(fit, diagnostics = diag, rater_facet = "Rater")
p_agreement <- plot(agreement)
```

![Exact agreement for matched rater pairs with the fitted-model expected
agreement overlaid. Review flags and the horizontal guide use the
thresholds saved in the agreement
result.](mfrmr-visual-diagnostics_files/figure-html/saved-agreement-view-1.png)

``` r

# Alternative saved view: plot(agreement, type = "agreement", metric = "correlation")
# Optional ggplot conversion: as_ggplot(p_agreement)
```

Save `agreement` with [`saveRDS()`](https://rdrr.io/r/base/readRDS.html)
to choose another pair view after reopening, or save `p_agreement` to
retain the selected view and its appearance. Inspect
`plot_data(p_agreement, "notes")` for the qualifications outside the
figure. Bar colors follow the combined exact/correlation flag, so a bar
above its displayed threshold can still be flagged by the other rule. To
change the rules, recreate `agreement` from the existing fit with
explicit `exact_warn` and `corr_warn`; changing a reference line alone
would contradict the flags.

### Response-time QC context

If your rating-event data include response times, review them separately
from the MFRM likelihood. Rapid and slow response-time flags are
descriptive quality-control prompts; they do not change measures and
should not be treated as proof of disengagement, cheating, or
speededness.

``` r

toy_rt <- toy
toy_rt$ResponseTime <- 12 + (seq_len(nrow(toy_rt)) %% 7) +
  as.numeric(toy_rt$Score)
toy_rt$ResponseTime[1] <- 2
toy_rt$ResponseTime[2] <- 38

rt <- response_time_review(
  toy_rt,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  time = "ResponseTime",
  rapid_quantile = 0.10,
  slow_quantile = 0.90
)

summary(rt)
#> mfrmr response-time review
#> 
#>  Rows ValidRows DroppedRows Persons Facets   TimeColumn ScoreColumn TimeUnit
#>   282       282           0      48      2 ResponseTime       Score  seconds
#>  MedianTime MeanLogTime RapidThreshold SlowThreshold RapidRate  SlowRate
#>        17.5    2.841728             14            20 0.1205674 0.1950355
#>  FlaggedGroups Flags UnassessedPersons
#>             27    27                 0
#>                                                                               InterpretationBoundary
#>  Descriptive response-time screening; not a joint speed-accuracy model and not a fit/pass-fail rule.
#> 
#> Thresholds:
#>  Threshold Value                 Basis TimeUnit
#>      rapid    14 Observed quantile 0.1  seconds
#>       slow    20 Observed quantile 0.9  seconds
#> 
#> Flagged groups:
#>  Source Group                                   Flag      Rate N ThresholdRate
#>  person  P014 High fraction at or below rapid cutoff 0.3333333 6          0.25
#>  person  P016 High fraction at or below rapid cutoff 0.3333333 6          0.25
#>  person  P023 High fraction at or below rapid cutoff 0.3333333 6          0.25
#>  person  P033 High fraction at or below rapid cutoff 0.3333333 6          0.25
#>  person  P040 High fraction at or below rapid cutoff 0.3333333 6          0.25
#>  person  P041 High fraction at or below rapid cutoff 0.3333333 6          0.25
#>  person  P002  High fraction at or above slow cutoff 0.3333333 6          0.25
#>  person  P003  High fraction at or above slow cutoff 0.3333333 6          0.25
#>  person  P005  High fraction at or above slow cutoff 0.3333333 6          0.25
#>  person  P006  High fraction at or above slow cutoff 0.6000000 5          0.25
#> 
#> Notes:
#> - Response-time review is descriptive; it does not change fit_mfrm estimates.
#> - Each row must represent one timed event. Do not duplicate one response-production time across its raters or criteria; rater scoring time is a different event.
#> - Rates describe valid timed rows only; each group retains input and excluded counts. A group without valid times is unassessed.
#> - Sample quantiles describe the observed distribution, not validated rapid-guessing, low-effort or speed cutoffs. Missing times and censoring are not modeled.
#> - Score-level summaries are descriptive and should not be read as response-time model parameters.
plot(rt, type = "distribution", preset = "publication")
```

![Distribution of synthetic response times with selected lower and upper
quantile screens. These thresholds describe this example and do not
diagnose careless
responding.](mfrmr-visual-diagnostics_files/figure-html/response-time-review-1.png)

``` r

plot(rt, type = "person", preset = "publication")
```

![Person-level summaries of synthetic response times. Compare flagged
patterns with their rating counts and context before drawing substantive
conclusions.](mfrmr-visual-diagnostics_files/figure-html/response-time-review-2.png)

Interpretation:

- Start with the distribution plot to see whether the rapid/slow
  thresholds are sensible for this administration.
- Inspect person and facet summaries for concentrated rapid or slow
  rates rather than isolated events.
- Keep timing flags separate from fit, bias, and validity claims unless
  the study design explicitly supports stronger speed-accuracy modeling.

### Small-N shrinkage with uncertainty

When a non-person facet has few levels or sparse observations, a large
raw severity estimate can be a noisy estimate rather than a stable facet
signal. The shrinkage funnel shows how far empirical-Bayes pooling moved
each level toward the facet mean and whether the uncertainty remains
wide after pooling.

``` r

fit_eb <- apply_empirical_bayes_shrinkage(fit)

shrink <- plot(fit_eb, type = "shrinkage", view = "funnel", show_ci = TRUE, ci_level = 0.95, preset = "publication", draw = FALSE)

head(shrink$data$table[, c(
  "Facet", "Level", "RawEstimate", "RawCI_Lower", "RawCI_Upper",
  "ShrunkEstimate", "ShrunkCI_Lower", "ShrunkCI_Upper",
  "ShrinkageFactor"
)])
#>   Facet Level RawEstimate RawCI_Lower RawCI_Upper ShrunkEstimate ShrunkCI_Lower
#> 1 Rater   R01  -0.6059776 -1.04569977 -0.16625550     -0.3739155     -0.7193270
#> 3 Rater   R02  -0.3820356 -0.79078871  0.02671748     -0.2486748     -0.5784554
#> 6 Rater   R04   0.1799462 -0.25645356  0.61634590      0.1116787     -0.2321154
#> 5 Rater   R05   0.1842365 -0.27475809  0.64323116      0.1099118     -0.2446091
#> 4 Rater   R03   0.2120388 -0.21248930  0.63656689      0.1343311     -0.2035680
#> 2 Rater   R06   0.4117917 -0.07719839  0.90078189      0.2329807     -0.1348274
#>   ShrunkCI_Upper ShrinkageFactor
#> 1    -0.02850402       0.3829550
#> 3     0.08110572       0.3490794
#> 6     0.45547282       0.3793770
#> 5     0.46443264       0.4034204
#> 4     0.47223032       0.3664785
#> 2     0.60078878       0.4342269

plot(fit_eb, type = "shrinkage", view = "funnel", show_ci = TRUE, ci_level = 0.95, preset = "publication")
```

![Raw and empirically shrunken facet estimates with their displayed
uncertainty. Movement toward a facet center reflects shrinkage, not a
change in observed
ratings.](mfrmr-visual-diagnostics_files/figure-html/shrinkage-funnel-1.png)

Interpretation:

- Long raw-to-shrunken segments identify levels most affected by the
  partial-pooling prior.
- Wide raw whiskers that narrow after pooling indicate estimation
  instability, not automatic rater-quality failure.
- Report the shrinkage method and keep this display separate from bias,
  fit, or validity claims.

## 7. Attributes and assessment planning

### External-feature hierarchy

A hierarchy can summarize raters’ backgrounds before discussing
training. These eight fictional raters illustrate the mechanics; their
groups are not estimates of severity, ability or rater quality. Choose
attributes and their coding for the substantive question before
interpreting a tree.

``` r

backgrounds <- data.frame(
  Rater = paste0("R", 1:8),
  Years = c(1, 2, 4, 6, 8, 10, 12, 15),
  Training = ordered(c("Basic", "Basic", "Advanced", "Basic",
    "Advanced", "Advanced", "Specialist", "Specialist"),
    levels = c("Basic", "Advanced", "Specialist")))
features <- mfrm_features(backgrounds, "Rater", c("Years", "Training"))
hierarchy <- mfrm_cluster_hierarchical(features, k = 3, linkage = "average")
```

``` r

hierarchy_plot <- plot(hierarchy, preset = "monochrome")
```

![Average-linkage dendrogram for eight fictional raters, based on Gower
dissimilarities in experience and ordered training level. Labelled
leaves identify raters and boxes show the requested three groups;
heights are dissimilarities, not significance
levels.](mfrmr-visual-diagnostics_files/figure-html/feature-hierarchy-1.png)

Three groups were requested; the diagram does not select that number or
establish that the groups are real. Feature weights, coding and linkage
can change the branches. The full tree and memberships in leaf order are
available for inspection. The development version supports both the base
plot and a dedicated ggplot conversion of this saved tree.

``` r

plot_data(hierarchy_plot, component = "table")
#>   ID Cluster Silhouette
#> 7 R7       3  0.7428571
#> 8 R8       3  0.7954545
#> 4 R4       1  0.5344828
#> 1 R1       1  0.7750000
#> 2 R2       1  0.7972973
#> 3 R3       2  0.4642857
#> 5 R5       2  0.7500000
#> 6 R6       2  0.6190476
tree <- plot_data(hierarchy_plot, component = "tree")
```

``` r

if (requireNamespace("ggplot2", quietly = TRUE)) {
  hierarchy_figure <- as_ggplot(hierarchy_plot, component = "tree") +
    ggplot2::labs(title = NULL, subtitle = NULL)
  print(hierarchy_figure)
}
```

![The same saved hierarchy of eight fictional raters rendered with
ggplot. Leaf order, Gower merge heights and the three group boxes are
unchanged. The caption explains that heights are not branch
support.](mfrmr-visual-diagnostics_files/figure-html/hierarchy-ggplot-1.png)

The conversion keeps the saved label setting and preset. Use
`labels = FALSE` when creating a crowded tree to hide IDs without
removing leaves. Where heights tie, boxes follow the stored merge-order
groups; they need not correspond to a unique horizontal height cut.
Removing titles or captions with
[`ggplot2::labs()`](https://ggplot2.tidyverse.org/reference/labs.html)
leaves the tree and memberships in
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md).

For imputed features, group comparisons and PCA, continue with
[Exploring person, rater, and task
attributes](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-external-features.md).

### D-study planning

For data preparation, interpretation of plan differences and saved
reopening, start with [Plan an assessment with G
theory](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-gtheory.md).
For several score criteria in a single panel, use
`plot(d, score = c("V", "W"), metric = "Phi")`, with names from your
result. Select named composites with
`composite = c("Equal", "Difference")`. For two-facet results, add
`x_var = "Tasks", panel_by = "Raters", ncol = 2` to separate the rater
counts into panels with shared axes and score colors; reverse `x_var`
and `panel_by` to separate task counts.
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
retains this layout using `facet_wrap()`. Panels retain unavailable
results and nested count labels such as “Raters per Task”. Add
`reference = 0.8` only if that is your chosen criterion; guides are not
universal adequacy rules. Both plot families omit reference lines by
default; `plot(main_effects_d, reference = c(0.7, 0.8))` restores its
earlier guides.

Use three complementary views: `plot(g, weights = ...)` shows the
G-study’s raw sources of score variation; `plot(d)` and
`plot(d, type = "sem")` show future plan projections;
`plot(comparison, view = "differences")` shows the eligible paired
differences with uncertainty. Raw components are in squared score units
and retain negative estimates. They are not percentages or future-plan
error contributions. G-study component and D-study projection plots
support
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
for editing; retrieve cautions with `plot_data(p, "notes")` and preserve
them outside the figure.

A D-study asks how a specified measurement design would perform if we
changed facet counts. The packaged MGENOVA manual example has two
scores, V and W, observed for Persons crossed with Tasks. Here the
target is their equal-weight composite. There is no rater facet in this
example.

``` r

tasks <- read.csv(system.file("extdata", "mgenova-table12.csv", package = "mfrmr"))
gstudy <- mfrm_g_study(tasks, c("V", "W"), rater = NULL)
planned <- mfrm_d_study(gstudy,
  data.frame(Tasks = c(3, 6, 12)), weights = c(V = 0.5, W = 0.5))
```

``` r

planning_plot <- plot(planned, type = "coefficients", preset = "monochrome")
```

![G and Phi coefficients for an equally weighted V and W composite at
three, six and twelve planned Tasks. Separate panels distinguish
relative and absolute decisions; points identify requested designs, and
lines guide the
eye.](mfrmr-visual-diagnostics_files/figure-html/d-study-planning-1.png)

G concerns relative comparisons among Persons; Phi concerns absolute
score interpretation. More tasks reduce the modeled task-related error
while holding the estimated covariance components and composite weights
fixed. These are observed-score projections, not MFRM ability
reliability or a guarantee for a new task population. Uncertainty in the
estimated components is omitted.

``` r

plot_data(planning_plot, component = "table")
#>   Scenario Tasks      Kind     Score UniverseVariance RelativeErrorVariance
#> 3        1     3 Composite Composite        0.3438889            0.34987654
#> 6        2     6 Composite Composite        0.3438889            0.17493827
#> 9        3    12 Composite Composite        0.3438889            0.08746914
#>   AbsoluteErrorVariance         G       Phi RelativeSEM AbsoluteSEM    Status
#> 3             0.4205556 0.4956847 0.4498547   0.5915036   0.6485025 Available
#> 6             0.2102778 0.6628198 0.6205514   0.4182562   0.4585605 Available
#> 9             0.1051389 0.7972238 0.7658521   0.2957518   0.3242513 Available
#>     GStatus PhiStatus RelativeSEMStatus AbsoluteSEMStatus ComponentPSD
#> 3 Available Available         Available         Available         TRUE
#> 6 Available Available         Available         Available         TRUE
#> 9 Available Available         Available         Available         TRUE
#>   ComponentTreatment
#> 3                raw
#> 6                raw
#> 9                raw
# Customizable conversion of this selected score/composite:
# as_ggplot(planning_plot)
# Error in score units is a different view:
# plot(planned, type = "sem")
```

Use
[`?mfrm_d_study`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md)
for score/composite selection and supported crossed or nested designs.
An ordinary `mfrm_d_study` object has its own base plot; its automatic
ggplot conversion is currently unavailable.

## Portable score-batch review

A batch returned by
[`score_mfrm_calibration()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_workflow.md)
is not a fitted-model diagnostic object. Review it through its own
methods:

``` r

summary(scores)
plot(scores, type = "interval", preset = "publication")
plot(scores, type = "precision", preset = "publication")
plot(scores, type = "edge_mass", preset = "publication")
```

The interval view highlights `scored_review` Persons. The precision view
shows valid response rows against posterior SD, and the edge-mass view
compares outer-node posterior mass with the artifact’s recorded review
threshold. Persons with no valid responses remain in the summary and
draw-free plot payload rather than being assigned an artificial
coordinate. These displays do not replace source-fit diagnostics, and
their uncertainty is conditional on the frozen point calibration. See
[`vignette("mfrmr-portable-calibration", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-portable-calibration.md)
for the complete fresh-session workflow.

## Recommended sequence

For a compact visual workflow:

1.  [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)
    when you want the package to route which figures are already
    supported.
2.  [`plot()`](https://rdrr.io/r/graphics/plot.default.html) for
    one-page triage.
3.  [`plot()`](https://rdrr.io/r/graphics/plot.default.html),
    [`plot()`](https://rdrr.io/r/graphics/plot.default.html),
    [`plot()`](https://rdrr.io/r/graphics/plot.default.html), and
    [`plot()`](https://rdrr.io/r/graphics/plot.default.html) for local
    follow-up.
4.  `plot(fit, type = "wright")` and `plot(fit, type = "pathway")` for
    targeting and scale interpretation.
5.  [`plot()`](https://rdrr.io/r/graphics/plot.default.html),
    [`plot()`](https://rdrr.io/r/graphics/plot.default.html), and
    [`plot()`](https://rdrr.io/r/graphics/plot.default.html) for deeper
    structural review.
6.  [`response_time_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/response_time_review.md)
    and [`plot()`](https://rdrr.io/r/graphics/plot.default.html) when
    response-time metadata are available.
7.  `plot(show_ci = TRUE, type = "shrinkage", view = "funnel")` when
    empirical-Bayes shrinkage was applied.
8.  `summary(scores)` and `plot(scores)` for a separately created
    portable score batch; do not use these as source-fit diagnostics.
9.  [`plot()`](https://rdrr.io/r/graphics/plot.default.html),
    [`plot()`](https://rdrr.io/r/graphics/plot.default.html),
    [`plot()`](https://rdrr.io/r/graphics/plot.default.html), and
    [`plot()`](https://rdrr.io/r/graphics/plot.default.html) as the
    teaching / drift / agreement-heatmap follow-up layer.

## Related help

- [`help("mfrmr_visual_diagnostics", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)
- [`help("mfrmr_workflow_methods", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_workflow_methods.md)
- `mfrmr_interval_guide("shrinkage")`
