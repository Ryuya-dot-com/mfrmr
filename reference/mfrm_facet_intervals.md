# Pointwise intervals for fixed facet estimates and contrasts

Describe uncertainty about a fixed facet estimate, such as rater
severity, or a specified difference between two raters. Start from a
supported fitted model; the point estimates stay the same when you
change the interval method.

## Usage

``` r
mfrm_facet_intervals(
  fit,
  facet = NULL,
  contrasts = NULL,
  method = c("model", "sandwich"),
  clusters = NULL,
  adjust = FALSE,
  level = 0.95,
  scale = c("native", "standardized"),
  comparison_review = NULL,
  anchor_covariance = NULL,
  independent_anchors = FALSE,
  interaction = NULL
)

# S3 method for class 'mfrm_facet_intervals'
print(x, ...)

# S3 method for class 'mfrm_facet_intervals'
summary(object, ...)

# S3 method for class 'mfrm_facet_intervals'
vcov(object, ...)
```

## Arguments

- fit :

  An inference-ready RSM/PCM MML fit from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
  using a fixed standard-normal person distribution, fixed quadrature
  and unit observation weights. A fit whose category review concerns
  singleton counts can additionally use `method = "model"` after the
  separate checks described under "Small samples and singleton
  categories". Experimental two-family GPCM MML also supports
  `method = "model"` with fixed-grid EM or direct adaptive integration;
  see "Two-family location targets" below. Direct MML native locations
  additionally support estimated normal RSM/PCM populations, including
  conditional-normal latent regression, and one-family GPCM with fixed
  N(0,1) or an estimated intercept-only normal population, using fixed
  or adaptive integration; see "Native locations" below for their scope
  and separate numerical checks. Native RSM/PCM CML results additionally
  support `method = "model", scale = "native"`, including the saved
  targets from `fit_scope = "comparisons"`. Matching full RSM/PCM MML
  interaction fits use the `comparison_review` extension below; their
  explicit model and source checks remain separate.

- facet :

  A non-person facet, for example `"Rater"`. May be omitted when
  `comparison_review` supplies a facet-by-origin interaction target, or
  for a CML comparison-only fit, which already retains its targets.

- contrasts :

  Optional numeric matrix with distinct target row names and columns
  named by every level of `facet`. Columns are aligned by name. A row
  with coefficients `c(1, -1, 0)` estimates the first level minus the
  second. By default, each level is reported.

- method :

  `"model"` (default) uses ordinary observed information; `"sandwich"`
  uses independent-cluster marginal-likelihood scores. The
  native-location and experimental two-family extensions support only
  `"model"`; sandwich support remains limited to the ordinary
  fixed-population RSM/PCM route.

- clusters :

  For sandwich inference, an optional data frame with exactly one row
  per fitted person and complete `Person` and `Cluster` identifiers.
  Without it, persons are the independent units. A larger cluster could
  be a school or clinic if different schools or clinics are independent.
  A person cannot be split across clusters. Supply original person
  labels, even when the input person column has another name.

- adjust :

  Logical; with `method = "sandwich"`, optionally multiply the
  covariance by `G/(G-1)`, where `G` is the cluster count. Default
  `FALSE`. This scaling does not guarantee small-sample coverage.

- level :

  Pointwise confidence level, strictly between zero and one.

- scale :

  `"native"` (default) retains the fitted ability units.
  `"standardized"` divides an explicit within-facet zero-sum contrast,
  or the interaction contrasts declared by `comparison_review`, by the
  population SD, using full joint delta-method uncertainty. Requires
  `method = "model"` and a fixed N(0,1) or estimated intercept-only
  normal population; individual locations and latent regression are not
  supported.

- comparison_review :

  Optional
  [`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md)
  review or its `$comparison_review` for a matching full native RSM/PCM
  MML interaction fit. Uses its declared facet-by-origin contrasts
  instead of facet locations; omit `contrasts` and optionally `facet`.
  Requires `method = "model"`. See "MML interaction contrasts" for scope
  and assumptions. Omit this argument for a CML comparison-only fit; its
  saved review is reused.

- anchor_covariance :

  Optional full sampling covariance of the supplied anchor estimates,
  including their correlations, in native ability units squared. Row and
  column names must match every directly anchored level on the one
  noncentered facet. Requires the fixed-grid direct RSM/PCM
  anchor-origin route with an intercept-only population and fixed SD.
  `NULL` retains the existing conditional-on-anchors calculation.

- independent_anchors :

  Logical, default `FALSE`. Set `TRUE` with `anchor_covariance` only
  when source calibration and receiving responses are independent.
  Shared respondents or dependent clusters require cross-sample
  covariance and are unsupported. This is an explicit assumption, not a
  check inferred from different Person identifiers.

- interaction :

  Optional exact name of one fitted two-facet interaction, for example
  `"Rater:Criterion"`. Omit `facet` and `comparison_review`. This
  selects jointly fitted cell effects rather than fixed-baseline bias
  screens. Requires `method = "model"`, `scale = "native"`, full direct
  fixed-grid RSM/PCM MML with fixed N(0,1), one interaction, no anchors,
  groups, dummy facets or shrinkage. See the joint-cell section below.

- x, object :

  An object returned by `mfrm_facet_intervals()`.

- ... :

  Unused by print and summary methods.

## Value

An `mfrm_facet_intervals` object with `table`, selected target
`covariance`, `model_covariance`, free-parameter `parameter_covariance`,
`model_parameter_covariance`, `person_scores`, `cluster_scores`, the
`clusters` mapping, exact `contrasts`, `settings`, and source `fit`. The
model-based SE and interval remain alongside the selected method. If
ordinary MML joint information is unavailable, free-parameter
covariances are `NULL` and target covariances contain `NA` (zero for
constraint-fixed rows/columns); `unavailable_reason` and `checks`
explain the failure. Sandwich scores and their rank are then uncomputed,
not zero. Score rows are derivatives of a person's marginal log
likelihood, not observed category scores or ability estimates. Scores
are absent for `method = "model"`. When weak information passes
numerical refinement, `cautions` and `information_review` retain the
warning and checks. `InferenceCaution` also accompanies the interval
table when applicable. Each row retains `Status`, `CIEligible` and a
plain-language `InferenceReview`. `CIEligible` concerns the selected
interval, not the validity of the point estimate or a guarantee of
coverage. `fixed` means the target is fixed by constraints, with no
inferential interval. `insufficient_cluster_rank` withholds sandwich
bounds because independent cluster scores do not span all free
parameters. The point and separate `ModelSE`/`ModelLower`/`ModelUpper`
are retained; those model bounds are not a replacement robust interval.
Review the independent sampling units and model dimension; do not split
dependent clusters to obtain an interval. `nonpositive_variance` or
`nonfinite_bounds` denotes an unusable target-specific calculation.
Missing bounds are not zero uncertainty. Two-family results additionally
retain `checks`, `numerical_checks`, `score_rank`, source identity,
scale references and interval refusal reasons. Their table includes
`CIEligible`; failed numerical checks leave bounds and SEs missing while
preserving the fitted point estimates. Native-location results retain
checks, numerical comparisons, full and target covariance, target
Jacobian and source identity, without an empirical Person-score rank
requirement. Standardized results also retain `NativeEstimate`, the
population SD, whether it was estimated, and the full transformation
Jacobian. `CIEligible` describes numerical availability;
`CoverageQualified = FALSE` does not claim finite-sample coverage for
the transformed interval.

## Details

Compare ordinary observed-information intervals with a sandwich
covariance that treats a person's complete response vector, or an
explicitly declared larger cluster, as the independent sampling unit.
Estimates are not refitted.

For cluster score `s_g` and observed negative-log-likelihood Hessian
`H`, the unadjusted sandwich is
`solve(H) %*% sum_g(s_g %*% t(s_g)) %*% solve(H)`. Scores aggregate all
responses of a person before forming the outer products; grouping
individual rating rows would be a different and incorrect calculation
for this marginal likelihood. The full covariance is transformed through
the fitted constraints and requested contrasts. Both methods use normal
critical values. No automatic method selection, multiplicity adjustment
or significance flag is supplied.

The sandwich requires many independent sampling units and appropriate
regularity. It permits dependence within the declared unit but does not
establish independence between units. A small number of units can give
poor intervals even with nonsingular covariance. If their scores do not
span the free-parameter space, sandwich intervals are unavailable; point
estimates and the reason remain. For ordinary fixed-population RSM/PCM,
an ineligible source fit still causes an error. If the source is
eligible but joint information is unavailable, nonpositive or
regularized, finite points remain with
`Status = "information_unavailable"`, `CIEligible = FALSE`, missing
model and sandwich uncertainty, and the explanation in
`InferenceReview`. This includes information-workspace limits. A
sandwich also needs the inverse information; switching methods cannot
repair its absence. Failed information can limit confidence in point
accuracy along weak directions. No inverse is regularized for this
output. Invalid arguments and cluster mappings remain errors. Targets
fixed by constraints have no inferential interval. Known anchors exclude
anchor uncertainty. An ill-conditioned but numerically verified
unregularized inverse can be used with a warning. Successful inversion
does not establish reliable normal intervals. Review interval width,
boundary proximity and quadrature sensitivity; changing to sandwich
covariance does not remove this concern.

## Jointly fitted interaction cells and contrasts

Fit a prespecified two-facet interaction with
`fit_mfrm(facet_interactions = "Rater:Criterion")`, then use
`mfrm_facet_intervals(fit, interaction = "Rater:Criterion")`. The
default returns all fitted cells, including the dependent last row and
column. Cell labels, counts, sparse flags and identification constraints
are retained in `interaction_cells`. This bounded route uses a fixed
standard-normal ability population; latent regression, estimated
population variance, adaptive integration, JML, CML, GPCM and multiple
fitted interaction terms are outside this extension.

An interaction effect is an additive predictor shift after jointly
fitting the main effects. Positive values increase expected coded
ratings; they do not automatically imply favorable performance or
unfairness. Effects have zero row sums and zero column sums across the
declared levels, without weighting those constraints by cell counts.
Their values depend on that definition and the included main effects.
This differs from
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md),
which holds the fitted calibration and person measures fixed while
estimating an additional residual shift. Neither result proves
substantive rater bias.

Write free interaction coordinates as gamma and their expansion to all
cells as G gamma. Cell covariance is G V_gamma G', where V_gamma is the
interaction block of the inverse full marginal information, including
main effects and thresholds. It is not the inverse of only the
interaction information block. Dependent cells consequently have
correlated estimates and a singular joint cell covariance; this alone
does not invalidate individual pointwise intervals. For a prespecified
cell contrast C, the covariance is C G V_gamma G' C'. Supply every cell
`Target` as a named column of `contrasts`, including zeros. A contrast
fixed at zero by the row/column constraints has `Status = "fixed"` and
no inferential interval; it is not evidence for a null interaction.

Source consistency, identification/boundary records, full information,
stationarity and finer-quadrature checks must pass. Unavailable
intervals retain finite point estimates and reasons. Sparse-cell flags
are descriptive, not a sample-size guarantee. Full-design identification
and numerical success do not establish nominal coverage. These are
pointwise Wald intervals, not simultaneous bounds or
multiplicity-adjusted cell decisions. Saved tables, plots,
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md)
and
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)
retain the same values and cautions.

A bundled-data example uses the existing estimation and interval APIs:

    ratings <- load_mfrmr_data("example_core")
    fit <- fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score",
      model = "PCM", step_facet = "Criterion", noncenter_facet = "Criterion",
      facet_interactions = "Rater:Criterion", quad_points = 61)
    cells <- mfrm_facet_intervals(fit, interaction = "Rater:Criterion")
    summary(cells)[, c("Target", "Estimate", "SE", "Lower", "Upper", "Status")]
    plot(cells)
    # Compare the first two displayed cells; choose the scientific contrast first.
    C <- matrix(0, 1, nrow(cells$table),
      dimnames = list("First minus second", cells$table$Target))
    C[1, 1:2] <- c(1, -1)
    difference <- mfrm_facet_intervals(fit, interaction = "Rater:Criterion",
      contrasts = C)
    vcov(difference) # Uses covariance between both cells

## Uncertainty from independently estimated anchors

The default intervals condition on the exact anchor values. Supplying
`anchor_covariance` and `independent_anchors = TRUE` adds
source-calibration uncertainty without changing any point estimates. Use
the full covariance, not only a vector of SEs or a diagonal replacement
for correlated anchors. Its numerical validity is checked; its
statistical validity, units and correspondence to the supplied anchor
values remain the analyst's responsibility.

Write the free receiving parameters as u, supplied anchors as a, and the
negative log likelihood Hessian blocks as H_uu and H_ua. Implicit
differentiation gives S = -inverse(H_uu) H_ua. For a reported target
t(u,a), its source derivative is D = t_u S + t_a. The selected target
covariance is t_u V_conditional t_u' + D V_anchor D'. The direct
derivative t_a matters for targets containing anchored elements; adding
variance only to the free parameters would omit that contribution and
their cross-covariance. This is a first-order approximation for
independent samples, not joint recalibration, a bootstrap or a
correction for anchor drift or biased anchors.

Source derivatives use central differences of the analytic marginal
score, checked by halving the difference step and refining the
quadrature. Failed source-derivative checks preserve point estimates and
the conditional results, with unavailable selected uncertainty.
`ConditionalSE`, `ConditionalLower`, `ConditionalUpper` and
`ConditionalStatus` retain that separate calculation; facet `Model*`
columns also retain it. `AnchorSourceSE` is the square root of the added
variance contribution, not a separate confidence interval. The selected
`SE`, bounds and [`vcov()`](https://rdrr.io/r/stats/vcov.html) include
both components. A conditionally fixed anchor may therefore have a
selected interval for its source-estimated value. A zero covariance
contribution does not create an interval for a target fixed under both
specifications.

`anchor_uncertainty` retains the supplied and numerically
symmetrized/PSD covariance, any floating-point adjustment, anchor
values, sensitivity, independent-sample assumption and derivative
checks. Singular PSD matrices are allowed. The free-parameter covariance
includes source propagation; it does not include anchored values as
extra optimizer coordinates. Saved population intervals can reuse this
sensitivity and the conditional information:
`mfrm_population_intervals(rater_ci)` propagates it once, without
refitting or differentiating again. Reports and exported tables retain
the supplied covariance and source-derivative checks; RDS retains the
full result.

Only fixed-grid direct RSM/PCM MML with unit weights, no interactions,
shrinkage or groups, an intercept-only population, fixed SD and all
anchors on its noncentered facet is supported. Adaptive integration,
free population variance, GPCM, dependent calibration samples and
uncertainty in the supplied SD are outside this extension. No nominal
coverage guarantee follows from numerical agreement or positive
covariance. Other facets retain their centering; changing an item pool
still requires a defensible scale link.

A complete interface example starts from bundled ratings. This split is
illustrative: independent Persons and stable anchors must be justified
for the actual sampling design, and different IDs alone do not establish
them.

    ratings <- load_mfrmr_data("example_core")
    ids <- unique(ratings$Person)
    source <- ratings[ratings$Person %in% ids[1:20], ]
    receiving <- ratings[!ratings$Person %in% ids[1:20], ]
    baseline <- fit_mfrm(source, "Person", c("Rater", "Criterion"), "Score",
      model = "RSM", noncenter_facet = "Rater", quad_points = 61)
    baseline_ci <- mfrm_facet_intervals(baseline, "Rater")
    common <- c("R01", "R02")
    anchors <- data.frame(Facet = "Rater", Level = common,
      Anchor = baseline_ci$table$Estimate[match(common, baseline_ci$table$Target)])
    cohort <- fit_mfrm(receiving, "Person", c("Rater", "Criterion"), "Score",
      model = "RSM", anchors = anchors, noncenter_facet = "Rater",
      population_formula = ~1, person_data = unique(receiving["Person"]),
      population_sd = 1, quad_points = 61)
    rater_ci <- mfrm_facet_intervals(cohort, "Rater",
      anchor_covariance = vcov(baseline_ci)[common, common], independent_anchors = TRUE)
    summary(rater_ci) # Selected and conditional intervals side by side
    population_ci <- mfrm_population_intervals(rater_ci)

## Small samples and singleton categories

A small sample or a wide interval is not, by itself, a reason to
suppress an estimate or an otherwise available asymptotic interval.
RSM/PCM model intervals can retain singleton categories (one observed
response in a fitted or local category cell) when all declared
categories are represented in the fitted and local scopes. They require
fresh category review, source and convergence checks, positive
unregularized joint information and a finer-quadrature score/covariance
comparison. Empty categories, unsupported coordinates, known
identification failures and failed numerical checks are not excused by
this route. Failed interval checks retain the point with unavailable
uncertainty and a reason.

The fit keeps its category-review state and can still have
`InferenceReady = FALSE`. Inspect this interval object's `CIEligible`,
`checks`, `numerical_checks` and `InferenceCaution` for the specific
calculation. This does not qualify other analyses or guarantee
small-sample coverage. The same model covariance is used by `vcov(fit)`
and default `confint(fit)`. Singleton counts do not gain a sandwich or
GPCM Wald extension here. For supported one-Person RSM/PCM calibration,
model-information intervals may be available after the same numerical
checks. Returned `cautions` and `InferenceCaution` state that
calibration relies on one response vector and its assumed conditional
independence; `CoverageQualified` is `FALSE`. A finite point or
information matrix does not establish small-sample coverage or
between-Person variation. One Person cannot provide sandwich
uncertainty; its ratings must not be relabeled as independent Persons.

## MML assumptions and numerical approximation

MML integrates each Person's joint response probability under the
declared ability distribution. Model-information intervals require the
response and population models to hold for the actual rating assignments
and covariates, including local independence given ability. An overall
normal ability distribution does not by itself justify using the same
distribution within rosters selected according to ability.
Response-dependent assignment, stopping or missingness requires a
separate justification of the likelihood.

The regular asymptotic interpretation requires independent Persons, an
identifiable fixed-dimensional marginal model, a consistent interior
solution, smooth likelihood derivatives and information growing in every
free direction. With bounded ratings per Person and stable design
proportions, a positive-definite limiting information per Person is a
sufficient information-growth condition. Correctly specified MML can
then support inference with fixed exposure per Person; increasing Person
count alone cannot repair misspecification or an unidentified design. A
positive observed Hessian at one fitted vector does not prove global
identification.

The continuous-normal likelihood is evaluated numerically. A fixed
finite quadrature order can retain approximation error as Person count
grows. Optimizer and integration error must be negligible relative to
sampling uncertainty for the continuous-model Wald interpretation.
Agreement at two quadrature orders is a sensitivity diagnostic, not an
error bound or a proof of asymptotic equivalence. Standardization does
not remove either numerical approximation error or bias from a
misspecified population model. The ordinary sandwich route can estimate
variation around a working-model target under its own regularity
conditions; that target need not be the true structural parameter.

## Conditional likelihood

Native `fit_mfrm(method = "CML")` results use the inverse full
conditional information, transformed through the fitted facet
constraints and requested contrasts. Other facets and steps remain
estimated. Only `method = "model"`, `clusters = NULL`, `adjust = FALSE`
and `scale = "native"` are supported. CML estimates no ability
population SD: `scale = "standardized"` cannot be computed from that
fit. For MML with an estimated intercept-only normal population, that
option divides by the same fit's estimated SD and includes its
covariance with the contrast; see "Population-SD-standardized
contrasts". A full CML fit can retain finite numerical point estimates
when its identification, finite-MLE and stationarity checks pass but
conditional information fails. Its non-fixed targets have
`Status = "information_unavailable"`, missing SE/bounds,
`CIEligible = FALSE` and the reason in `InferenceReview`. The fit's
`checks$information_status` and `checks$information_reason` record the
information decision. Constraint-fixed targets retain zero SE and no
inferential interval. An information warning also limits confidence in
the numerical accuracy of points along weak directions; retaining a
point does not qualify it for inference. CML intervals are asymptotic,
requiring the correct conditional response law, independent Persons and
information growing in every free direction of a fixed-dimensional
identified model. More Persons alone is insufficient; extreme totals add
no information. Response-dependent assignment, stopping or missingness
requires justification that the conditional law is preserved. See the
sufficient regular regime in
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).
Neither numerical acceptance nor a distribution-free ability treatment
ensures small-sample coverage. `plot(ci)`, `summary(ci)` and RDS reuse
apply to CML interval objects; attaching them to ordinary
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)
is not supported. Non-fixed CML targets require finite, strictly
positive representable variance. Rescale contrast coefficients if their
units cause variance underflow or overflow; numerical zero variance is
not a constraint-fixed target.

For `fit_scope = "comparisons"`, call `mfrm_facet_intervals(fit)`
without new `contrasts` or `comparison_review`. The saved estimates,
joint target covariance and qualifications are reused without
optimization or information recalculation. `level` changes only the
pointwise normal critical value. Unidentified, boundary or
unqualified-stationarity comparisons keep missing estimates and
intervals. If only information failed, identified numerical points
remain, with missing uncertainty, their reasons and
`CIEligible = FALSE`; no unavailable value is zero-filled.
`parameter_covariance` is the covariance of the fit's identified
subspace, not of separately identified cell effects. Use `summary(ci)`,
`plot(ci)`, `apa_table(ci)` and `saveRDS(ci)`; the saved review retains
group order, contrast weights and observed/empty cells. JML/MML
comparison-only fits remain descriptive and are not covered by this
interval route.

## Anchors and group means

The ordinary fixed-population RSM/PCM route supports location anchors
and group means. Write the fitted facet locations as \\b=b_0+J\eta\\ and
a requested comparison as \\Cb\\. Its covariance is \\CJ V\_\eta
J^{\mathsf T}C^{\mathsf T}\\, where \\V\_\eta\\ is extracted after
computing the full joint covariance. Other facets and thresholds remain
estimated; inverting only the selected facet's information would omit
their estimation uncertainty. The affine offset \\b_0\\ affects
estimates, but has no variance when its supplied values are treated as
exact.

A comparison with \\CJ=0\\ is fixed: its `Status` is `"fixed"`, `SE` is
zero, and interval bounds are missing. This includes values implied by
centering, not only rows in an anchor table. For example, with four
raters, whole-facet centering and a fixed mean of 0.10 for the first
three, the fourth rater is fixed at -0.30. The three group members can
still differ unless other constraints fix them; their mean has no
inferential interval. A difference between a free rater and an anchored
rater can remain uncertain. These are conditional statements, not
evidence that the source calibration or group-mean assumption is
error-free. Native-location anchors use only the fixed-SD RSM/PCM
extension below; groups remain excluded there.

## Native locations

For estimated normal RSM/PCM and intercept-only normal one-family GPCM
MML, `method = "model"` supplies pointwise Wald intervals for locations
or contrasts on the model's native ability scale. One-family GPCM also
admits the explicit fixed-N(0,1) restriction
(`gpcm_mml_identification = "fixed_standard_normal"`). Shared or
separate slope/step owners are supported, with geometric-mean-one
relative slopes. Use direct MML, fixed or adaptive integration, unit
weights, additive centered facets and centered steps. RSM/PCM also
accepts a fitted full-rank conditional-normal regression, retaining its
coefficient and residual-variance cross-information when computing
structural uncertainty. The saved population table identifies
coefficients and residual variance; it does not label regression
coefficients as marginal population means. GPCM latent regression and
sandwich covariance remain unavailable here. The native location
procedure performs its own qualification even when the source fit has
`InferenceReady = FALSE`. Read `CIEligible`, `Status`, `checks`,
`numerical_checks` and cautions on this result; interval availability
does not change the source fit's overall readiness or qualify other
procedures. Interactions use the separate `comparison_review` route
below. Population-coefficient and variance intervals are separate
targets and are not returned by this helper. RSM/PCM populations may fix
residual SD with `population_sd`. For an intercept-only population
(`population_formula = ~1`), a direct anchor on the selected non-Person
`noncenter_facet` identifies the origin while free levels on that facet
remain uncentered. These anchored intervals require no groups or dummy
facets and condition on the supplied anchors and SD; their
source-calibration uncertainty is not propagated. Other facets keep
their declared centered constraints. Fixed SD has no variance coordinate
in the joint information.

The covariance transforms the inverse full joint marginal information,
including all estimated population, slope and step coordinates. A
location-only inverse or independent printed SEs cannot replace it. The
source, category support, local solution and unregularized information
must pass checks; covariance and score changes are also checked at a
finer integration order at the same fitted parameter vector. This
model-information procedure has no empirical Person-score rank
requirement. For RSM/PCM populations with estimated variance, a
zero-residual-variance candidate at the retained nuisance estimates is
compared with the fitted likelihood. A higher boundary likelihood beyond
the numerical allowance prevents intervals. This check does not optimize
or exclude the entire boundary. A numerical refusal preserves the native
point and its reason with unavailable SE/bounds. Constraint-fixed
targets have no inferential interval.

The asymptotic justification requires independent Persons, a correctly
specified response and population model, an identified interior true
parameter, a fixed number of structural parameters, nonsingular limiting
information and sufficiently accurate integration and optimization.
Information must grow in all target directions as Persons are added;
connected facet labels alone do not establish this condition. These
numerical checks do not establish finite-sample coverage, global
identification or robustness to misspecification. Native locations are
not divided by the estimated population SD unless
`scale = "standardized"` is requested for a zero-sum contrast (see
below). A location difference need not produce a uniform rating
difference with unequal slopes or steps. The calculation does not refit
or change the saved fit/readiness. Save and attach `ci` with
`mfrm_results(fit, intervals = list(locations = ci), compute = "never")`;
select `plot(res, type = "facet_locations")` for RSM/PCM or
`"gpcm_locations"` for one-family GPCM. Reports and exports retain the
native scale, inferential qualifications and unavailable outputs.

## Population-SD-standardized contrasts

Set `scale = "standardized"` and supply explicit contrast rows whose
coefficients sum to zero. For native contrast \\d\\, population SD
\\\sigma\\ and free log-variance \\\lambda = \log(\sigma^2)\\, the
target is \\t = d/\sigma\\. Its Jacobian has location entries
\\J_d/\sigma\\ and log-variance entry \\-t/2\\. The covariance is
transformed from the inverse full joint observed information, including
the covariance between the contrast and log-variance. Dividing native
interval endpoints by the fitted SD omits this uncertainty. In scalar
form, \$\$\widehat{\mathrm{Var}}(\widehat t) =
\frac{\widehat{\mathrm{Var}}(\widehat d) + \widehat
d^2\widehat{\mathrm{Var}}(\widehat\lambda)/4 - \widehat
d\widehat{\mathrm{Cov}}(\widehat d,\widehat\lambda)}
{\widehat\sigma^2}.\$\$ The covariance term can increase or decrease the
SE relative to dividing the native SE by the fitted SD. A zero estimated
contrast can still have positive variance. With fixed N(0,1), the result
equals the native contrast because the known SD is one. With an explicit
fixed `population_sd`, divide the native contrast and SE by that SD; no
estimated-SD derivative or uncertainty is introduced. Conditional-normal
regression is excluded: its residual SD is not a marginal population SD.
Standardization does not equate expected ratings across models with
different slopes or category steps.

The existing source and numerical checks still apply. These are
pointwise normal delta-method intervals, not profile intervals or
finite-sample coverage guarantees. The regular delta method assumes a
fixed true population SD strictly above zero and an identifiable,
interior joint solution under the stated marginal model. A positive
fitted SD alone does not establish these conditions. At zero SD the
target is undefined; near zero the ratio and normal approximation can be
unstable. No universal SD cutoff certifies validity. Standardization
does not resolve weak identification or boundary problems; see the MML
assumptions above.

## MML interaction contrasts

Supply `comparison_review` to obtain native or
population-SD-standardized intervals for its explicitly weighted
facet-by-origin interaction contrasts. The review must match the fitted
responses, group identities, constraints, model, PCM step owner, signs
and population design. Its model has one interaction, zero origin main
facet and centered remaining facets and interaction margins. This
extension requires a full, unadjusted RSM/PCM direct MML fit, unit
weights and preserved categories, without shrinkage or additional
anchors. Comparison-only MML fits, JML and GPCM are not admitted. CML
comparison intervals remain available through
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
but cannot estimate a population SD.

Full conditional-map identification is necessary here. Source tables,
categories, local solution, unregularized full information and
finer-grid stability must pass the native-location checks above. A
failed numerical check retains the point estimate with missing SE/bounds
and a reason. Positive conditional rank and local information do not
establish global marginal identification or finite-sample interval
coverage; the output retains `MarginalIdentificationState` and
`CoverageQualified = FALSE`. These are model-based asymptotic intervals,
not a calibrated DFF classification.

For `scale = "standardized"`, the denominator is the SD estimated in the
**same intercept-only normal MML fit** (`population_formula = ~1`). Such
a fit assumes one common ability distribution across the declared origin
groups. It is a different model from `~Group`, which allows group means.
For `~Group`, native interaction intervals are supported, but its
residual SD is not substituted for a marginal population SD. A fixed
N(0,1) fit has known SD one; no estimated-SD uncertainty is introduced
in that case.

The joint delta method uses interaction derivatives divided by the
fitted SD and derivative `-Estimate/2` for log population variance. All
population, step and structural nuisance coordinates remain in the full
information inverse. It includes the covariance between the numerator
and denominator; dividing the native endpoints or SE by the fitted SD is
insufficient.

Read `table` with `comparison_review`: group subtraction order, panel
weights, observed/empty cells and assumptions are retained. Use
`plot(ci)`, `saveRDS(ci)` to retain `IdentificationBasis` and its
explanation with the intervals. A free-Person response-map basis does
not establish distribution-free MML inference; population-dependent
conditional identification does not establish global marginal
identification. Display the result directly or attach it as
`mfrm_results(fit, intervals = list(school = ci), compute = "never")`.
Plotting and reports reuse the saved uncertainty; they do not refit or
recalculate information. These results do not extend the separate
[`mfrm_population_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_population_intervals.md)
consumer to models with fitted interactions.

## Two-family location targets

For native two-family GPCM MML, select either modeled non-Person facet.
The first slope owner's locations sum to zero; the second owner's
locations are uncentered on the fixed N(0,1) ability scale. These
locations are measured before multiplication by both slope components.
Increasing a location lowers expected ratings when ability, slopes and
other effects stay fixed. A contrast between actual raters need not
imply a uniform difference in expected ratings: their slopes and
category-step offsets may also differ. Neither zero nor a location
difference defines rater quality or accuracy.

Let `J` expand the free location coordinates under their fitted
constraints and `C` be the requested contrast matrix. The target
covariance is `C J V J' C'`, where `V` is the location block extracted
*after inverting the full joint marginal information*. Slopes, steps and
the other facet remain estimated nuisance parameters. Inverting a
location-only Hessian, adding independent printed SEs, or using the EM
conditional-objective Hessian would omit their joint estimation
uncertainty.

The source fit must pass the same identity, category support, score
derivative, stationarity, full-information and finer-quadrature checks
used for experimental two-family slope intervals in
[`confint.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_fit.md).
The full covariance is checked; deficient empirical Person-score rank is
a retained diagnostic and warning, not a veto on the
inverse-observed-information method. Passing these numerical checks does
not establish repeated-sample coverage for locations or contrasts.
Evidence for component slope intervals does not qualify these different
targets. These are reported separately as `CIEligible` (numerical
interval availability) and `CoverageQualified = FALSE` in `table`. The
latter means that nominal sampling coverage has not been established for
the target and design; it is neither a coverage estimate of zero nor a
numerical-failure flag. Saving, reporting or exporting the result
retains both fields. These are experimental pointwise normal
approximations, with no sandwich, profile, multiplicity or automatic
significance decision. A failed check retains estimates and reasons with
unavailable intervals, even if the coarse-grid information could be
inverted. Constraint-fixed targets have no interval. The calculation
does not refit or change quadrature in the saved fit.

For example, use `ci <- mfrm_facet_intervals(fit, "Rater")`, or supply a
named zero-sum row of `contrasts` for a difference. Plot and save `ci`
directly, or attach it with
`mfrm_results(fit, intervals = list(locations = ci))` and select
`plot(res, type = "gpcm_locations")`. The model must actually contain
the specified facet. Location intervals do not add category-step/curve
bands, Person uncertainty, Wright maps or tests of rater competence.
Individual two-family rater sheets currently display component-slope
intervals only; use the analyst report for these location and contrast
results.

## What robustness means here

Under model misspecification, the sandwich describes sampling variation
around the working model's limiting parameter (its pseudo-true target).
That target need not equal the generating rater severity or criterion
difficulty. Changing the SE does not correct a biased estimate,
informative assignment, unmodeled population differences or MNAR
nonresponse. Check the model and assignment before interpreting a
severity contrast.

These intervals condition on the observed fixed facet levels. They do
not generalize to replacement raters sampled from a rater population.
They are not multiway crossed-cluster, G/D-study, variance-boundary, EAP
or multiple-imputation intervals. Shared random rater/task effects
spanning the declared clusters violate this one-way independence
assumption. Numerical success is not a general coverage or
rater-diagnosis guarantee. Review quadrature sensitivity separately; the
helper reuses the fitted grid.

## Bounded evaluation

For the RSM/PCM route, a 1,600-dataset comparison used 80/320
independent persons, three fixed raters and two criteria. In its
combined skewed-ability/sparse-design scenario, sandwich coverage of
generating contrasts ranged from 87.0 to 95.5 percent despite all
intervals being available. Coverage of the independently calculated
working-model targets ranged from 93.0 to 97.5 percent. These are ranges
across conditions/contrasts, not uncertainty bounds or universal
operating characteristics. At 200 datasets per condition, MCSE near 95
percent is about 1.54 percentage points. See
[`vignette("mfrmr-facet-intervals", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-facet-intervals.md)
for the design, interpretation and a complete rater-feedback example.

## Save, display and report the selected intervals

Use [`plot()`](https://rdrr.io/r/graphics/plot.default.html),
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
and
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
to display or extract the saved result, and
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md)
for tables. Set `title = NULL`, `subtitle = NULL` or `caption = NULL` in
the plot to omit that text. For supported RSM/PCM MML fits, attach one
result or a named list to
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md),
for example
`mfrm_results(fit, intervals = list(raters = intervals), include = c("fit", "plots"), compute = "never")`.
The route `plot(res, type = "facet_raters")` shows the selected
intervals. For two-family GPCM, the corresponding plot type is
`"gpcm_raters"`.
[`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)
and
[`export_mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_results.md)
retain the method, level, contrast coefficients, cluster mapping and
unavailable outcomes. The source fit must match; replay reloads the
saved results without refitting or recomputing covariance. These
intervals do not replace uncertainty in ordinary Wright maps, fit
diagnostics or Person scores. For CML, keep the interval object itself:
use `summary(intervals)`, `plot(intervals)`, `apa_table(intervals)` and
`saveRDS(intervals, file)`. Reopen it with `readRDS(file)`. Ordinary
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md),
[`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)
and
[`export_mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_results.md)
do not accept CML fits or their intervals.

## References

White, H. (1982). Maximum likelihood estimation of misspecified models.
*Econometrica*, 50(1), 1–25. Zeileis, A. (2006). Object-oriented
computation of sandwich estimators. *Journal of Statistical Software*,
16(9), 1–16.
[doi:10.18637/jss.v016.i09](https://doi.org/10.18637/jss.v016.i09) .
Zeileis, A., Koell, S. and Graham, N. (2020). Various versatile
variances: An object-oriented implementation of clustered covariances in
R. *Journal of Statistical Software*, 95(1), 1–36.
[doi:10.18637/jss.v095.i01](https://doi.org/10.18637/jss.v095.i01) .

## See also

[`analyze_facet_equivalence()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_facet_equivalence.md),
[`pool_mfrm_imputed()`](https://ryuya-dot-com.github.io/mfrmr/reference/pool_mfrm_imputed.md),
[`plot.mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_facet_intervals.md),
[`mfrm_population_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_population_intervals.md)

## Examples

``` r
ratings <- load_mfrmr_data("example_core")
fit <- fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score",
  model = "RSM", method = "MML", rating_min = 1, rating_max = 4,
  category_policy = "preserve")
intervals <- mfrm_facet_intervals(fit, "Rater", method = "sandwich")
summary(intervals)
#>   Target   Estimate         SE       Lower       Upper    ModelSE  ModelLower
#> 1    R01 -0.1838153 0.08409258 -0.34863371 -0.01899684 0.08209147 -0.34471159
#> 2    R02 -0.3088478 0.07488878 -0.45562708 -0.16206847 0.08298771 -0.47150069
#> 3    R03  0.1795027 0.08434452  0.01419045  0.34481490 0.08202273  0.01874108
#> 4    R04  0.3131604 0.09478720  0.12738087  0.49893987 0.08294736  0.15058652
#>    ModelUpper    Status CIEligible
#> 1 -0.02291895 available       TRUE
#> 2 -0.14619486 available       TRUE
#> 3  0.34026428 available       TRUE
#> 4  0.47573421 available       TRUE
#>                                                                                                            InferenceReview
#> 1 Pointwise normal approximation under the selected covariance method; numerical availability does not guarantee coverage.
#> 2 Pointwise normal approximation under the selected covariance method; numerical availability does not guarantee coverage.
#> 3 Pointwise normal approximation under the selected covariance method; numerical availability does not guarantee coverage.
#> 4 Pointwise normal approximation under the selected covariance method; numerical availability does not guarantee coverage.
plot(intervals)


# Compare two selected raters, rather than each rater against the origin.
# Here choose the first two example labels; prespecify your own comparison.
raters <- unique(as.character(ratings$Rater))
contrast <- matrix(0, 1, length(raters), dimnames = list(
  paste(raters[1], "minus", raters[2]), raters))
contrast[1, 1:2] <- c(1, -1)
difference <- mfrm_facet_intervals(fit, "Rater", contrasts = contrast)
summary(difference)[, c("Target", "Estimate", "SE", "Lower", "Upper", "Status")]
#>          Target  Estimate        SE      Lower     Upper    Status
#> 1 R01 minus R02 0.1250325 0.1337755 -0.1371626 0.3872276 available
# With the default negative rater sign, a positive contrast means the first
# rater is stricter. Units are native logits. An interval containing zero
# leaves the direction uncertain; it does not establish equivalence.

# Estimate the population SD in this same model before standardizing.
# Even an intercept-only population model needs one row per person.
persons <- unique(ratings["Person"])
population_fit <- fit_mfrm(ratings, "Person", c("Rater", "Criterion"),
  "Score", model = "RSM", method = "MML", population_formula = ~ 1,
  person_data = persons, person_id = "Person",
  rating_min = 1, rating_max = 4, category_policy = "preserve", quad_points = 61)
standardized <- mfrm_facet_intervals(population_fit, "Rater",
  contrasts = contrast, scale = "standardized")
#> Warning: Population-SD-standardized contrasts use full joint delta-method uncertainty; sampling coverage is not qualified. Regular inference requires a correctly specified, identified marginal model and a true population SD strictly above zero. A positive fitted SD alone does not establish these conditions; near-zero SD can make the ratio unstable. Quadrature agreement is a numerical diagnostic, not an error bound. Unequal slopes or steps can make expected-rating differences vary with ability.
summary(standardized)
#>          Target  Estimate       SE      Lower     Upper  ModelSE ModelLower
#> 1 R01 minus R02 0.1284989 0.138447 -0.1428523 0.3998501 0.138447 -0.1428523
#>   ModelUpper    Status CIEligible
#> 1  0.3998501 available       TRUE
#>                                                                                                                 InferenceReview
#> 1 Population-SD-standardized pointwise delta-method interval; source numerical checks passed, sampling coverage is unqualified.
#>                                   ScaleReference NativeEstimate
#> 1 within-facet zero-sum contrast / population SD      0.1244346
#>   CoverageQualified
#> 1             FALSE
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            InferenceCaution
#> 1 Population-SD-standardized contrasts use full joint delta-method uncertainty; sampling coverage is not qualified. Regular inference requires a correctly specified, identified marginal model and a true population SD strictly above zero. A positive fitted SD alone does not establish these conditions; near-zero SD can make the ratio unstable. Quadrature agreement is a numerical diagnostic, not an error bound. Unequal slopes or steps can make expected-rating differences vary with ability.
# Estimate is now in fitted ability-population SD units; its delta-method
# interval includes uncertainty in that SD. It is not a Wald z statistic.

# CML estimates the native contrast without an ability distribution.
if (requireNamespace("lpSolve", quietly = TRUE)) {
  cml_fit <- fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score",
    model = "RSM", method = "CML", rating_min = 1, rating_max = 4,
    category_policy = "preserve")
  cml_ci <- mfrm_facet_intervals(cml_fit, "Rater", contrasts = contrast)
  summary(cml_ci)
  apa_table(cml_ci)
  file <- tempfile(fileext = ".rds") # Choose a lasting path for your analysis
  saveRDS(cml_ci, file)
  saved <- readRDS(file)
  summary(saved) # Same conditional-information result, without refitting
  # Use plot(saved) for a figure; ordinary mfrm_results() does not accept CML.
}
#>          Target Estimate        SE      Lower     Upper    Status CIEligible
#> 1 R01 minus R02 0.124638 0.1335936 -0.1372007 0.3864767 available       TRUE
#>                                                                                                             InferenceReview
#> 1 Pointwise conditional-information normal approximation; numerical availability does not guarantee finite-sample coverage.
#>     ModelSE ModelLower ModelUpper
#> 1 0.1335936 -0.1372007  0.3864767
```
