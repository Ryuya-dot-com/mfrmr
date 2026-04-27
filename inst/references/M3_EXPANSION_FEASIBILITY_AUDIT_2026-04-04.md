# M3 Expansion Feasibility Audit

Date: 2026-04-04  
Package baseline: `mfrmr` 0.1.5

Related references:

- `inst/references/M3_ECOSYSTEM_COVERAGE_PLAN_2026-04-04.md`
- `inst/references/M3_GPCM_SPEC_2026-04-04.md`

## 1. Why this note exists

The current roadmap is already broad. Before expanding beyond `GPCM`, this
note evaluates whether adjacent requests are:

1. mathematically grounded in established literature;
2. compatible with `mfrmr`'s current non-Bayesian, native-R architecture; and
3. worth the maintenance cost relative to the package's many-facet product
   identity.

The decision rule is conservative:

- adopt only if the feature has both a defensible statistical basis and a
  clear product payoff for a many-facet-first package;
- defer if the theory exists but the present architecture would be stretched
  too far;
- reject or isolate if the feature would turn `mfrmr` into a generic
  everything-in-IRT package.

## 2. Current baseline relevant to this audit

Two facts constrain the decision:

1. `mfrmr` already supports ordered binary and ordered polytomous responses
   under an additive many-facet linear predictor with arbitrary facet count.
2. The plotting layer already exposes reusable plotting payloads through
   `mfrm_plot_data` and `draw = FALSE`, which means an optional interactive
   rendering layer could be added without rewriting the whole visualization
   API.

This means some "expansions" are not equally disruptive. For example,
arbitrary-facet ordered `GPCM` is a natural extension of the existing ordered
core, whereas native continuous-response modeling is not.

## 3. Candidate-by-candidate judgment

### 3.1 Interactive visualization (`plotly`, htmlwidgets, optional 3D)

#### Evidence base

- `htmlwidgets` provides the standard R framework for JavaScript-backed
  widgets.
- Plotly documents interactive `scatter3d` support for R.
- Plotly has also announced retirement of its R-specific documentation, which
  is a real maintenance signal even though the package remains usable.

#### Feasibility in `mfrmr`

Two-dimensional interactive wrappers are technically feasible with low model
risk because the plotting layer already emits structured payloads rather than
only drawing directly to the graphics device.

Three-dimensional plots are also technically feasible, but they are much less
aligned with the package's current diagnostics. Most current visuals are
tables, Wright maps, fit comparisons, drift summaries, interaction screens,
and planning curves. These are naturally 2D and annotation-heavy.

#### Benefits

- Better drill-down for QC, bias, drift, and design-planning summaries.
- Natural fit for `draw = FALSE` payloads and export bundles.
- Can remain optional through `Suggests` rather than forcing a hard
  dependency.

#### Costs and risks

- New dependency surface (`plotly`, likely `htmlwidgets`, possibly widget
  snapshot tools for testing).
- Harder visual regression testing than current base-R plots.
- 3D plots risk high implementation effort with weak inferential benefit.
- Plotly's reduced R documentation support lowers long-run maintenance
  confidence.

#### Decision

- **Adopt candidate:** optional interactive **2D** layer.
- **Not a near-term priority:** native **3D** layer.

Recommended scope:

- keep base-R plots as the stable default;
- add `as_plotly()`-style wrappers for selected high-value payloads only;
- treat 3D as experimental, not roadmap-critical.

### 3.2 Binary / polytomous outcomes with 3 or more facets

#### Evidence base

The current ordered-response many-facet formulation already generalizes to any
number of additive facets. FACETS documentation likewise treats the number of
facets as a modeling specification issue rather than a separate model family.

#### Feasibility in `mfrmr`

This is not a speculative expansion for ordered data. It is already the
package's basic modeling frame. The main future task is to make sure new model
families such as `GPCM` preserve this arbitrary-facet logic instead of
silently regressing to a 2-facet or 3-facet special case.

#### Benefits

- Strongly aligned with the package's core identity.
- Directly useful to users moving from FACETS-style workflows.
- Reuses the current indexing, diagnostics, and long-format API.

#### Costs and risks

- More facets increase sparsity and identifiability pressure.
- Helper layers, summaries, and simulation routines must continue to avoid
  hidden literal-name assumptions.

#### Decision

- **Already in scope** for ordered binary and ordered polytomous models.
- **Must remain a design rule** for `GPCM`, nominal, and future
  multidimensional extensions.

### 3.3 Frequency data: binomial and Poisson count models

#### Evidence base

FACETS documents binomial-trials (`Bn`) and Poisson-count (`P`) models as
implemented model types, including their use in many-facet settings.

#### Feasibility in `mfrmr`

Mathematically feasible, but not a small increment on top of `PCM/GPCM`.
These models require new likelihoods, new sufficient-statistic logic, new
residual/fit semantics, and likely new simulation and plotting conventions.

Binomial models are conceptually closer to the present ordered/dichotomous
machinery than Poisson counts, but both are distinct response families rather
than minor options.

#### Benefits

- Real overlap with FACETS capabilities.
- Useful for performance counts, attempts/successes, and certain operational
  scoring contexts.

#### Costs and risks

- Broadens the package from ordered categorical response modeling into a more
  general measurement-model engine.
- QC, fit, and interpretation layers would need family-specific rules.
- Could dilute effort away from `GPCM`, nominal, and multidimensional work.

#### Decision

- **Conditional later candidate**, not immediate post-`GPCM` work.

Recommended scope:

- if demand is real, implement **binomial first**, then evaluate Poisson;
- do not mix count-family work into the first `GPCM` milestone.

### 3.4 Continuous or decimal response data

#### Evidence base

There is literature on continuous Rasch formulations, and Winsteps discusses
continuous-percentage approximations. At the same time, Winsteps explicitly
states that it analyzes ordinal data, not decimal data, and recommends
converting decimal observations to exact integer categories for ordinary
rating-scale or partial-credit analysis when appropriate.

#### Feasibility in `mfrmr`

Possible only by opening a substantially different modeling branch.
This is not a natural extension of the current ordered-category likelihood
engine.

#### Benefits

- Could attract unusual use cases with percentages or fine-grained scoring.

#### Costs and risks

- Weak fit with the package's present ordered-category architecture.
- Harder interpretation and validation story than standard ordinal IRT.
- High risk of scope drift for a relatively niche payoff.

#### Decision

- **Do not adopt as a native core model now.**

Recommended alternative:

- provide preprocessing guidance or helper utilities for defensible recoding to
  ordered integer categories when that is substantively justified.

### 3.5 Uto-style generalized many-facet Rasch models with rater drift

#### Evidence base

The literature clearly exists. Uto's papers cover:

- generalized many-facet models with rater consistency and task
  discrimination;
- multidimensional generalized many-facet models; and
- a Bayesian many-facet Rasch model with Markov modeling for rater severity
  drift.

However, these papers are explicitly Bayesian and rely on MCMC / HMC / NUTS.

#### Feasibility in `mfrmr`

There are two very different interpretations of this request:

1. **Full Uto-style model family** with Bayesian dynamic estimation.  
   This is misaligned with the current project constraints because the package
   has intentionally avoided Stan/Bayesian estimation.
2. **Simplified non-Bayesian time-aware extension** such as:
   - adding `Time` as an ordinary facet,
   - adding rater-by-time interaction screening,
   - or strengthening the existing drift workflow.

The second is feasible and consistent with `mfrmr`'s workflow orientation.
The first is not a good near-term target.

#### Benefits

- Very high substantive value in rater-mediated assessment.
- Strong differentiator if implemented in a non-Bayesian workflow-oriented way.
- Natural connection to the package's existing anchor/drift/linking tools.

#### Costs and risks

- Full dynamic latent-state modeling is a large methodological jump.
- The strongest available reference implementations in this line are Bayesian,
  which weakens direct architectural reuse.
- Easy to overclaim parity if only a simplified drift layer is implemented.

#### Decision

- **Adopt candidate only in simplified non-Bayesian form**:
  time facet + drift screening + targeted interaction extensions.
- **Defer full Uto-style Bayesian dynamic models.**

### 3.6 Multidimensional models

#### Evidence base

The theory and software base is strong:

- TAM documents uni- and multidimensional MML estimation, including many
  adjacent response families.
- `mirt` treats multidimensional modeling as core territory.
- Uto provides a multidimensional generalized many-facet formulation for
  rubric-based assessment.

#### Feasibility in `mfrmr`

Feasible, but expensive. The current `mfrmr` MML implementation is
one-dimensional and Gauss-Hermite based. A multidimensional branch will
require:

- multidimensional quadrature or alternative approximation;
- Q-matrix or equivalent design specification;
- reworked scoring, plausible values, information functions, and diagnostics.

The best first step remains the existing roadmap decision:

- **between-item multidimensional ordered models first**;
- no within-item multidimensional or highly generalized multidimensional branch
  until the baseline is stable.

#### Benefits

- High scientific payoff.
- Clear overlap with TAM / mirt expectations.
- Especially relevant for rubric-based performance assessment, which is a
  natural `mfrmr` use case.

#### Costs and risks

- Large computational and documentation burden.
- Can easily destabilize the current one-dimensional MML code if attempted too
  broadly.
- Raises posterior-scoring and validation demands substantially.

#### Decision

- **Strong post-`GPCM` adoption candidate.**

### 3.7 Nonparametric Mokken scale analysis

#### Evidence base

Mokken scale analysis has an extensive literature and a mature CRAN package.
It is a nonparametric IRT family for dichotomous and polytomous items under
the monotone homogeneity and double monotonicity models.

#### Feasibility in `mfrmr`

Possible only by stepping outside the package's current parametric many-facet
estimation identity. Mokken is item-scale analysis, not a natural extension of
the additive many-facet latent-variable machinery used in `mfrmr`.

#### Benefits

- Strong independent methodology.
- Useful in exploratory scale development.

#### Costs and risks

- Weak conceptual fit with many-facet parameterization.
- Would blur the package identity.
- Existing specialized package support is already strong.

#### Decision

- **Out of scope for the core estimation roadmap.**

Recommended alternative:

- document interoperability or comparative workflow guidance rather than
  re-implementing Mokken methods inside `mfrmr`.

## 4. Adoption tiers

### Tier A: adopt or continue as core candidates

1. `GPCM` within the existing arbitrary-facet ordered-response frame.
2. Between-item multidimensional ordered models.
3. Optional interactive **2D** visualization wrappers built on
   `mfrm_plot_data`.

### Tier B: conditional later candidates

1. Binomial and then Poisson count models.
2. Simplified non-Bayesian time-aware rater drift extensions.

### Tier C: defer or keep out of scope

1. Native 3D plotting as a roadmap priority.
2. Native continuous-response model family.
3. Full Bayesian Uto-style dynamic generalized many-facet models.
4. Native Mokken estimation inside `mfrmr`.

## 5. Recommended order after the current `GPCM` milestone

The practical order should be:

1. finish unidimensional ordered `GPCM`;
2. add optional interactive 2D wrappers only where the existing payload
   contract is already stable;
3. choose between nominal and multidimensional based on user demand, but treat
   multidimensional as the stronger long-run scientific payoff for `mfrmr`'s
   niche;
4. evaluate count models only after the generalized ordered and scoring layers
   are stable;
5. expand drift work in a non-Bayesian direction before considering any
   full dynamic latent-state model.

## 6. Bottom line

The strongest next expansions are **not** "everything that other packages or
papers mention." The best candidates are the ones that preserve `mfrmr`'s
identity:

- generalized ordered many-facet models,
- multidimensional rubric-oriented many-facet models,
- workflow-centric visualization and drift tooling.

The weakest candidates are the ones that would turn the package into a generic
grab-bag:

- native 3D for its own sake,
- continuous-response modeling,
- and nonparametric Mokken estimation inside the core package.

## 7. Source list

- `htmlwidgets` package documentation:
  <https://search.r-project.org/CRAN/refmans/htmlwidgets/html/htmlwidgets-package.html>
- Plotly R 3D scatter documentation:
  <https://plotly.com/r/3d-scatter-plots/>
- Plotly documentation retirement notice:
  <https://community.plotly.com/t/retire-the-documentation-for-r-matlab-julia-and-f/94147>
- FACETS model specification:
  <https://www.winsteps.com/facetman64/models.htm>
- FACETS Rasch models overview:
  <https://www.winsteps.com/facetman64/raschmodels.htm>
- FACETS model matching note:
  <https://www.winsteps.com/facetman/modelmatchingdata.htm>
- Winsteps decimal / continuous data note:
  <https://www.winsteps.com/winman/decimal.htm>
- Linacre on percentages with continuous Rasch models:
  <https://rasch.org/rmt/rmt144a.htm>
- Uto and Ueno (2020), generalized many-facet Rasch model:
  <https://doi.org/10.1007/s41237-020-00115-7>
- Uto (2021), multidimensional generalized many-facet Rasch model:
  <https://doi.org/10.1007/s41237-021-00144-w>
- Uto (2023), Bayesian many-facet Rasch model with Markov rater drift:
  <https://doi.org/10.3758/s13428-022-01997-z>
- TAM `tam.mml` documentation:
  <https://search.r-project.org/CRAN/refmans/TAM/html/tam.mml.html>
- `mirt` documentation:
  <https://search.r-project.org/CRAN/refmans/mirt/html/mirt.html>
- `mixedmirt` documentation:
  <https://search.r-project.org/CRAN/refmans/mirt/html/mixedmirt.html>
- `mokken` package documentation:
  <https://search.r-project.org/CRAN/refmans/mokken/html/mokken-package.html>
