# Core literature and R-manual page review for G theory and measurement extensions

Status: internal evidence review; not public support, release authorization, or
an API promise

Review date: 2026-08-29

## Outcome

Fourteen PDFs were reviewed page by page: seven core Zotero sources and seven
R-package manuals or PDF vignettes. Coverage is **1,538/1,538 PDF pages**
(996 package-documentation pages and 542 literature pages), with **0 unreadable
pages**. The current `lme4` covariance-structures R Markdown vignette was also
reviewed section by section because its installed official form is HTML/Rmd,
not a paginated PDF.

The main implementation conclusion is narrower than a package-capability
inventory:

1. multiple observed facets, multiple fixed G-theory strata, multiple response
   families, and multiple latent dimensions are four different model axes;
2. multivariate-G covariance and prospective D-study operators must follow the
   sampling and observation-event design, not a convenient backend syntax;
3. current `lme4 2.0.6` can express selected **random-effect** covariance
   structures (`us`, `diag`, `cs`, and `ar1`), correcting an outdated blanket
   limitation in the 2020 article and older lmer paper;
4. `lme4` still represents the level-1 residual as one scale times a known
   diagonal inverse-weight matrix, so it is not a general route for linked
   cross-stratum residual covariance;
5. `glmmTMB` remains the conditional general multivariate-G candidate only
   when each covariance block and observation-event identity are explicitly
   encoded and redundant Gaussian dispersion is removed;
6. `mirt`, `TAM`, and `brms` are best treated first as independent external
   oracles or integration routes. Their feature lists do not prove that GPCM,
   facets, LLTM design, latent dimensions, mixed formats, and response time can
   be composed safely inside `mfrmr`.

No new model implementation and no simulation run are authorized by this
review. D-SIM-0 remains an owner-input and design-identity gate.

## Reproducible review record

- `gtheory-measurement-core-page-review-manifest-0.2.4.csv` freezes document
  identity, versions, Zotero keys, page or section counts, hashes, source
  locators, evidence roles, and claim ceilings.
- `gtheory-measurement-core-page-review-0.2.4.csv` has one row per PDF page. It
  records section, extracted character and line counts, visual status, review
  depth, keyword hits, implementation-critical findings, and claim ceiling.
- `gtheory-multivariate-zotero-literature-audit-0.2.4.csv` is the compact
  seven-source contract traceability record.

Review depth is deliberately explicit. All 1,538 pages were rendered and
visually checked against layout-preserving extracted text. The 286 pages that
directly control model identity or implementation were line-by-line close-read.
The remaining substantive article or monograph pages received full text and
visual review; package reference entries received entry-level text and visual
review. Covers, contents, reference lists, blank pages, and indexes received a
structural check. This avoids claiming that a 430-page bibliography or index
was interpreted as a technical argument.

The four text-empty pages in the Cronbach attachment are intentional front or
end matter and were readable in the render. No Zotero item, attachment, tag,
collection, or PDF was modified.

## Sources and controlling pages

### Multivariate G theory, profiles, and composites

Cronbach et al. (1972), PDF pp.283--312, distinguish multivariate variables,
profiles, and composites from sampled facets. Variables are fixed; the
admissible conditions associated with each variable and the decision's
sampling rule determine the covariance decomposition. Independent sampling
and joint sampling can retain the same variance components but imply different
cross-variable covariance contributions. A linked residual covariance is
therefore neither universally zero nor automatically free: it follows whether
the same observation event yields multiple scores.

PDF pp.303--312 and 329--352 make the composite implication explicit. A
composite universe score must be defined before its reliability or
dependability is evaluated. Nominal weights are fixed features of that
definition. Observed profiles, correlations, and difference scores can change
with the measurement design even when universe-score relations do not.
Difference-score error under joint sampling must include the relevant
covariance terms.

Jiang et al. (2020), PDF pp.3--5, provide two canonical cases:

- disjoint condition sets across fixed strata: person covariance can be
  unstructured, while condition and residual cross-stratum blocks are
  diagonal; and
- identical conditions scored across strata: shared-condition and
  observation-event blocks can require unstructured cross-stratum covariance.

Their `glmmTMB` construction represents the observation-event residual as a
random-effect block and suppresses the ordinary Gaussian dispersion. Adding a
second residual covariance for the same event would violate model identity.
Jiang et al. (2024), PDF pp.3--9, reach the same nonredundancy requirement in a
Bayesian mixed-format construction.

Vispoel et al. (2023), PDF pp.2--23, separate relative G, global absolute D,
and cut-score-specific D coefficients. Their nominal and effective weights
must not be conflated: nominal weights state the externally chosen composite;
effective weights describe the realized contribution of components under
that fixed composite.

### Facets, GPCM, and latent dimensions

Muraki (1992), PDF pp.2--5, defines the GPCM through adjacent-category
response functions with item discrimination and category steps. Steps need
not be ordered. The empirical application at PDF pp.14--18 is unidimensional;
the paper does not support interpreting a rater, rubric, or subtest label as a
latent dimension.

Uto (2021), PDF pp.4--12, writes the composition that is often blurred in
informal feature descriptions. The model has person ability vectors,
item-by-dimension discriminations, item and category parameters, and rater
severity, consistency, and category behavior. These are not interchangeable
parameter labels. PDF pp.12--14 add the identification obligations: ability
location and scale, summed rater severity, product rater consistency, and
exchangeable dimension labels all need constraints or postprocessing. A model
that merely accepts several facet columns is not multidimensional IRT.

Wind et al. (2023), PDF pp.1--12, show why G theory and many-facet Rasch
measurement should remain complementary. G-theory variance components support
design and dependability questions. MFR diagnostics more directly expose
individual rater severity, centrality, and bias, but sparse designs can reduce
their sensitivity. Neither result should count as an independent vote for the
other estimand, and an MFR diagnostic requires its own connectivity gate.

## R-package manuals

| Source | Pages close-read | What it establishes | What it does not establish |
| --- | --- | --- | --- |
| `glmmTMB 1.1.14` | 21--28, 42--43, 46--47, 50--53 | structured random blocks, correlation parameterization, Gaussian dispersion control, diagnostics, fitted/new-design simulation | a general native level-1 residual covariance API or a correct mG sampling design |
| `lme4 2.0.6` | 58--61; current covariance Rmd sections 1--5 | `us`, `diag`, `cs`, `ar1` random-effect structures and their parameter maps | estimated general cross-stratum level-1 residual covariance |
| lmer PDF vignette | 1--5 | LMM architecture and historical package comparison | current `lme4 2.0.6` random-structure capability; the article text is from the 1.1-7 era |
| `mirt 1.47` | 120--133, 157--164, 168--178, 209--212, 227--234 | GRM/GPCM kernels, MIRT, explanatory/random-effect IRT, groups, diagnostics, and mixed-family simulation | automatic composition of polytomous item design, arbitrary facets, and package-portable scoring |
| `TAM 4.3-25` | 36--37, 54--56, 113--120, 127--130, 134--135, 140--141, 150--151, 171--175 | design matrices, GPCM, multidimensional models, multifacet examples, simulation and fit checks | direct item-slope estimation in `tam.mml.mfr` or a universal one-call multifacet GPCM |
| `brms 2.23.0` | 25--27, 34--50, 162, 216--221, 245--246 | ordinal and response-time families, multivariate formulas, correlated group effects, priors | native GPCM/MFRM or general non-Gaussian residual correlation; true residual correlation is limited to multivariate Gaussian/Student models |
| archived `gtheory 0.1.2` | 1--6 plus source audit | basic uni/multivariate G/D interface and composites | joint estimation of general cross-stratum component covariance |

### Correction to the `lme4` claim

The current manual, PDF pp.58--61, is controlling evidence for version 2.0.6.
It documents four random-effect covariance structures. The installed current
covariance vignette confirms that the structures attach to random-effect
grouping terms, are homogeneous over levels, and depend in some cases on
contrast/intercept coding. It also notes parameter-scale differences from
`glmmTMB` for compound symmetry.

The lmer PDF vignette, p.2, says that residual and random-effect covariance
structure is an `nlme` advantage. That paper reflects an older lme4 era and
cannot override the current manual for random effects. Its LMM equation at
p.3 remains informative for the residual: the conditional covariance is
sigma squared times a known diagonal inverse-weight matrix. The corrected
backend rule is therefore:

> Use `lme4` only as a design-qualified sensitivity route when every random
> block maps to a supported current structure and the level-1 residual needs
> no estimated cross-stratum covariance beyond one scale times known diagonal
> weights. Never treat that route as evidence of general multivariate-G
> support.

### `glmmTMB` is conditional, not automatic

The `glmmTMB` manual documents broader structured random effects and the
ability to suppress Gaussian dispersion. It does not itself define the
observation-event identity needed by multivariate G theory. The Jiang
construction works because the residual event is encoded as a random block
with an appropriate covariance structure and the ordinary residual is made
nonredundant. Thus `dispformula = ~0` is an implementation consequence of a
declared statistical model, not a generic recipe.

`simulate()` includes random effects and does not condition on their fitted
values. `simulate_new()` accepts a parameterized new design but is marked
experimental. Either API can support a bounded implementation check; neither
is an independent data-generating oracle for D-SIM.

### Archived `gtheory` source audit

The package was archived at version 0.1.2. The reviewed six-page manual was
generated from the archived source tarball (source SHA-256
`7a52d3f8d6ed68f8d9151d5c83a50b9471358a1ea8c33131559a959f0c9581f5`).
It says the package was designed for uni- and multivariate G/D studies. Source
inspection narrows that claim:

- `gstudy.multivariate()` splits the data by stratum and calls separate
  univariate `lmer` fits;
- cross-stratum information is the observed covariance of per-object mean
  scores; and
- `dstudy()` constructs diagonal error matrices before computing composite
  quantities.

It therefore cannot serve as an oracle for joint recovery of arbitrary
cross-stratum Object, Rater, Object:Rater, or observation-event covariance
blocks. It remains useful as historical API and simple-design comparator
evidence only.

### `mirt`, `TAM`, and `brms` boundaries

`mirt 1.47` is the strongest maintained external IRT oracle in this set. Its
manual makes the axes visible: response family (`graded`, `gpcm`, and others),
latent loading/covariance structure, item-parameter design, multiple groups,
and mixed/random effects are separate specifications. `mixedmirt()` supports
crossed random effects and explanatory IRT, but its polytomous documentation
does not permit treating all item intercept designs as freely composable.

`TAM 4.3-25` is valuable precisely because it documents the difficulty. The
manual states that item slopes cannot be estimated with faceted designs via
`tam.mml.mfr`. Its examples use pre-specified design matrices or a staged
route through `tam.mml.2pl`. This is evidence for an explicit transformed-
design contract and parameter-equivalence tests, not evidence that a native
many-facet GPCM is a small switch.

`brms 2.23.0` supplies promising Bayesian prototypes for ordinal,
shifted-lognormal/ex-Gaussian response time, Wiener diffusion, distributional,
and multivariate models. Shared group IDs correlate group effects across
responses, but this is not the same as a general residual covariance. A future
joint response/response-time model would still require an event schema,
missingness semantics, process likelihood, prior contract, and prediction
target.

## Refined internal roadmap

The order below is dependency-driven, not a feature queue.

### 0. Preserve the current release boundary

Keep `0.2.4` public support unchanged. The existing bounded one-dimensional
GPCM route is not promoted to portable GPCM, general many-facet GPCM, or MIRT.
No GRM, LLTM/LPCM, mixed-format, or response-time public promise follows from
this review.

### 1. D-SIM-0 package-capability scope is complete

The v4 correction assigns responsibility at the R-package scale. Before any
response generation, the package contract requires all of the following:

- fixed stratum meanings and common direction/unit;
- condition sharing and observation-event identity across strata;
- covariance mask for every random component and residual event;
- both ABS-PHI and REL-G as separate validation estimands, without a universal
  package target or action mapping; and
- route eligibility, including the corrected `lme4` residual rule.

The earlier v3 contract represented these choices through 13 owner inputs and
a 21-row adjudication plan. That is retained as an unexecuted applied-project
proposal, but its operational workflow, target, consequence, owner, and
sign-off fields no longer block package validation. V4 instead fixes 14
validation axes, 44 levels, ten acceptance criteria, and a five-state maturity
scale. Both coefficient families are in scope automatically.

The deterministic backend qualifier treats the binding as necessary but not
as execution authority. Distinct events with supported random blocks can make
both `glmmTMB` and `lme4` conditional candidates. One event yielding several
stratum scores excludes `lme4` because it needs cross-stratum level-1 residual
covariance; `glmmTMB` remains conditional through a nonredundant
observation-event random block. Any explicit condition/event mask or other
random structure fails closed to `custom_contract_required`. Every derived
row retained `ExecutionAllowed = FALSE` in v3. In v4 these mappings are D-SIM-1
deterministic design qualifications, not owner confirmations or execution
authority.

The multiverse remains preferable to a single favored scenario. V4 changes its
unit from decision policies to package-capability domains: estimand, design,
event identity, information, variance/covariance, response distribution, and
analysis route. Anchors, pairwise stresses, targeted structural cases,
boundaries, closure cases, and negative controls have distinct roles.
Post-outcome scenario selection and dropping failed runs remain prohibited.

### 2. D-SIM-1 through D-SIM-3 qualification complete; shared execution substrate is next

D-SIM-1 generated no responses and performed no fitting. It closed seven
deterministic criteria with 39 unique evidence rows (43 criterion-to-evidence
assignments) over five canonical anchors:

1. univariate public-algebra closure (`U1-CLOSURE`);
2. two disjoint strata with distinct events (`S2-DISJOINT-DISTINCT`);
3. two linked strata sharing an event (`S2-SHARED-LINKED`);
4. three partially linked strata with an explicit mixed incidence pattern
   (`S3-PARTIAL-MIXED`); and
5. a disconnected structural negative control
   (`S2-DISCONNECTED-NEGATIVE`).

The independent oracles cover univariate `G`/`Phi` closure, stratum-label
invariance, positive-semidefinite acceptance and rejection, incidence
connectivity, observation-event identity, and route eligibility. Across the
20 design-by-route rows, `glmmTMB` is conditional only for representable
diagonal or linked-event structures; `lme4` is restricted to the distinct-event
diagonal-residual sensitivity; explicit masks require a custom covariance
contract; and the disconnected negative control is rejected everywhere.
Backend agreement in an overlap remains a parity check, not two estimand
votes.

D-SIM-2 subsequently terminally counted exactly one 720-row nonreserved
fixture through generator -> lme4 REML fit -> separate nonvoting G/Phi metric
-> terminal state, then reproduced the semantic identities on exact replay.
The exercised shared-rater/distinct-event cell is the narrow diagonal-residual
C1 intersection, not the linked-event residual anchor. Its finite coefficient
values were compared with neither truth nor a target. This closes interface and
state propagation only; it does not estimate operating characteristics or
support a public model claim.

D-SIM-3 subsequently froze an outcome-blind registry of 21 design cells. The
registry covers all 44 v4 levels and all 603 feasible pairs among the 12
dataset-generating axes; 23 impossible crossings with the fixed one-stratum
closure profile retain explicit reasons. The 21 rows are not generated
datasets. `ABS-PHI`/`REL-G` and the five analysis routes are projections over
shared scenario datasets, so their 42 and 105 rows do not multiply the sample
denominator. Generated datasets, responses, RNG streams, and fits remain zero.

The separate exploratory execution contract subsequently bound two 855-band
identities per cell: 42 dataset attempts, 210 shared-dataset route units, 84
dataset-estimand units, and 420 nonvoting route-estimand coordinates. Fifty
route units remain qualification candidates, while 40 are negative-control
prefit rejections, eight are inapplicable, and 112 retain missing/custom-
contract blocks. Passing either contract does not authorize generation. The
subsequent pre-execution audit completed without opening 855. It retained
18/37 reusable legacy generator primitives but qualified 0/37 exact levels,
0/21 complete profiles, 0/50 candidate route units, 0/13 terminal states, and
0/5 resource scopes; two of three deterministic controls qualify. This no-go
is an implementation gap map, not failed simulation evidence. The next
permissible work was one shared typed design/generator/route/receipt/resource
substrate, not scenario-specific patches. Its first 22-rule compiler layer now
qualifies all 21 profiles over nine design axes and 147,948 structural row
identities without RNG or responses. Its second shared layer qualifies variance
regime, cross-stratum covariance, and response distribution through 84/84 PSD
component factors and 21/21 response-kernel contracts. The ordinal aggregate
is a thresholded distributional stress, not an IRT model. Complete stochastic
generator semantics subsequently qualified for 21/21 profiles on nonreserved
shadow stream identities, with 84/84 unit-to-effective covariance implications
and nine outcome-independent fixed-count MCAR masks. The next shared layer then
qualified 50/50 route admissions and all 13 terminal semantics, while retaining
181 exactly-once current terminal receipts and correctly leaving 92 unopened
units with zero. Admission is not a fabricated terminal outcome. The next
dependency is the five-scope resource controller; reserved 855 remains
unopened.

### 3. GPCM: external-oracle identity ladder

If package support is extended beyond the current bounded GPCM, proceed in
this order:

1. reproduce Muraki adjacent-category probabilities and the binary special
   case independently;
2. freeze conversions among `mfrmr`, `mirt`, and `TAM` discrimination,
   location, and step parameterizations;
3. verify unidimensional facet-free GPCM likelihood and scoring parity;
4. add the current bounded slope-owner/facet structure one axis at a time;
5. evaluate a pre-specified `TAM` transformed-design route as an external
   multifacet comparator; and
6. consider portable calibration only after fresh-session artifact recovery,
   anchoring, migration, and scoring gates close together.

Stop or remain external if realistic incidence and category counts do not
recover the slope/facet structure, if conversion is not one-to-one in the
declared support, or if integration answers the user decision at lower
lifecycle cost.

### 4. GRM: separate kernel after cumulative-category scope is justified

GRM is not a GPCM parameter option. Reopen only when the intended category
semantics warrant cumulative boundaries and package-level demand justifies the
additional kernel and maintenance surface.
Implement an independent cumulative-difference oracle, ordered-threshold
transform, derivatives, and held-out scoring. Compare with `mirt` first. Do
not add facets, LLTM design, or latent dimensions in the first GRM slice.

### 5. LLTM/LPCM: parameter-design axis after family identity is stable

LLTM/LPCM defines a known item-parameter design, not a new response family.
Require a frozen operation matrix, row-key semantics, rank/null-space audit,
contrast identity, and a documented parameter-design interpretation. Test it
first with one already-qualified binary or adjacent-category kernel. `TAM` is
an external design-matrix oracle; package-native work remains unnecessary if
that route satisfies the workflow.

### 6. Response time: separate event/process programme

Do not attach a time column as another facet or latent dimension. Require
actor, item, attempt, occasion, clock/unit, censoring, timeout/not-reached,
omission, and missingness identities before a likelihood. Begin with external
`brms`, `mirt`, LNIRT, or custom Stan prototypes. Promote only if a joint model
adds reproducible inferential or predictive value beyond descriptive timing QC and passes
new-person/new-item/event prediction checks under a declared privacy and
computational support envelope.

### 7. Multidimensional generalized MFRM last

Only a substantive construct map can open this lane. Require an explicit
person ability vector, item-by-dimension loading/discrimination map,
location/scale constraints, rotation or label rule, rater constraints,
connectivity, and permutation-aware recovery. Multiple facets, subtests, or
response formats alone are insufficient. Start externally with `mirt`, `TAM`,
or a published Stan formulation and admit native code only if package-specific
portable-calibration value remains.

## Acceptance and stop rules

Every later slice must report:

- the exact estimand and user-controlled interpretation it supports;
- parameter/probability identity against an independent oracle;
- realistic-data identification and failure denominators;
- prediction target and resampling unit;
- artifact, scoring, migration, and fresh-session behavior;
- simpler external or documentation-only alternatives; and
- a falsifiable result that causes advance, narrow, external integration,
  documentation/refusal only, park, or kill.

Availability in an R package, successful optimization, a low error in one
simulation scenario, or agreement between two wrappers around the same model
is not promotion evidence.

## Non-claims

This review does not claim that:

- all 1,538 pages received identical word-level treatment; reference and index
  pages were structurally reviewed and the ledger records the distinction;
- the reviewed manuals validate `mfrmr` code;
- `lme4 2.0.6` is a general multivariate-G backend;
- `glmmTMB` automatically supplies a correct multivariate-G residual model;
- archived `gtheory` jointly estimates general cross-stratum components;
- `mirt`, `TAM`, or `brms` features are directly composable;
- multiple facets or fixed strata imply multidimensional IRT; or
- literature review authorizes response generation, fitting, release, or
  public support.
