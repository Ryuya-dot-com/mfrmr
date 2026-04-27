# M3 Ecosystem Coverage Plan

Date: 2026-04-04  
Package baseline: `mfrmr` 0.1.5

Companion audit:
See `inst/references/M3_TAM_SIRT_MIRT_ECOSYSTEM_AUDIT_2026-04-04.md`.
See `inst/references/M3_EXPANSION_FEASIBILITY_AUDIT_2026-04-04.md` for the
triage of adjacent expansion requests beyond the current `GPCM` scope.

## 1. Goal

The next roadmap cycle should not chase breadth for its own sake.
Its goal is:

> Make `mfrmr` cover the relevant open-source feature envelope represented by
> TAM, sirt, and mirt while strengthening the many-facet workflow features
> that those packages do not integrate as tightly.

In practical terms, the target is:

- ecosystem-credible estimation breadth,
- plus `mfrmr`-specific workflow depth.

## 2. Final endpoint for this cycle

This cycle is complete only when all of the following are true:

1. `mfrmr` supports the major model families that users would reasonably
   expect after comparing it with TAM, sirt, and mirt in the many-facet /
   adjacent IRT space.
2. `mfrmr` can explain exactly where it overlaps with those packages and where
   it differs.
3. `mfrmr` still has clear product strengths in long-format many-facet
   workflow, planning, QC, and reporting.

## 3. Coverage target

The target is not "all functions in TAM / sirt / mirt".

The target is the following feature envelope:

### 3.1 Estimation families to cover

- ordered many-facet Rasch (`RSM` / `PCM`) and latent regression;
- `GPCM`;
- nominal response;
- between-item multidimensional models;
- selected explanatory / constrained design extensions;
- selected rater-slope / rater-item interaction extensions.

### 3.2 Scoring and posterior tools to cover

- EAP / MAP / fixed-calibration scoring as appropriate to the model family;
- plausible values with a clear multiple-imputation interpretation;
- scoring interfaces that condition on fitted population models when present.

### 3.3 Workflow strengths to amplify

- long-format many-facet API;
- descriptor-first planning and design tools;
- QC dashboards;
- anchor, linking, and drift workflow;
- FACETS / ConQuest / future open-source overlap audits;
- report bundles and reproducibility helpers.

## 4. Work packages

### WP-A. Comparator matrix and claim control

Objective:
Keep the roadmap anchored in documented ecosystem reality.

Deliverables:

- source-backed TAM / sirt / mirt comparison note;
- public claim rules that avoid implying generic parity;
- milestone-specific overlap statements.

Status:
Started by the present audit note.

### WP-B. Generalized ordered core (`GPCM`)

Rationale:
Both TAM and mirt already document `GPCM`. It is the closest next model
family to the current `PCM` code path.

Definition of done:

- `fit_mfrm()` supports a slope-varying ordered extension;
- prediction, information, and simulation either support `GPCM` or fail with
  explicit boundaries;
- recovery studies confirm parameter and category-function behavior;
- help pages separate Rasch-family assumptions from `GPCM` assumptions.

### WP-C. Population-model scoring upgrade

Rationale:
TAM and mirt both treat plausible values as more than a light helper.
`mfrmr` now has a first latent-regression baseline but still needs a stronger
posterior / MI story.

Definition of done:

- plausible values clearly framed as multiple-imputation style draws;
- parameter-uncertainty strategy specified and, if implemented, validated;
- workflow guidance on when to use EAP, MAP, and plausible values;
- recovery / numerical checks that compare posterior summaries under the
  strengthened workflow.

### WP-D. Nominal response branch

Rationale:
TAM and mirt both document nominal models. Users comparing packages will
expect an answer for true unordered multinomial data.

Definition of done:

- a nominal interface clearly separated from the current ordered interface;
- recovery studies and interpretation documentation;
- diagnostics boundary note explaining which current ordered helpers do not
  transfer automatically.

### WP-E. Multidimensional baseline

Rationale:
TAM and mirt both treat multidimensionality as standard territory.

Definition of done:

- between-item multidimensional support first;
- scoring and population-model interfaces updated consistently;
- explicit deferral of within-item multidimensional or higher-complexity
  variants if not yet supported.

### WP-F. Explanatory / design-matrix layer

Rationale:
TAM documents `A`, `B`, `E`, `Q`, and formula-driven population inputs.
mirt documents `itemdesign`, fixed effects, and random effects through
`mixedmirt`.

Definition of done:

- a specification for the smallest defensible constrained-design layer in
  `mfrmr`;
- implementation only for the subset that fits the native-R, non-Bayesian
  architecture;
- no claim of full `mixedmirt`-style random-effects coverage unless actually
  implemented.

### WP-G. Selected sirt-style rater extensions

Rationale:
`sirt::rm.facets()` documents item slopes, rater slopes, and rater-item
interactions in a focused rater-facets setting.

Definition of done:

- explicit decision on which of these belong in `mfrmr`;
- one narrow extension at a time;
- strong guardrails on identifiability, interpretation, and downstream helper
  support.

### WP-H. `mfrmr`-specific strengths

Rationale:
Breadth alone will not beat TAM or mirt. `mfrmr` must also become the best
workflow package in its niche.

Required outcomes:

- descriptor-first arbitrary-facet planning design;
- stronger QC dashboards and report synthesis;
- linking / anchoring / drift workflows that remain coherent across model
  families;
- open-software overlap audit paths that can eventually extend beyond
  ConQuest-only comparisons where defensible.

## 5. Execution order

The execution queue should be:

1. finalize comparator-aware roadmap and claim rules;
2. implement `GPCM`;
3. strengthen plausible-values workflow;
4. implement nominal response;
5. implement between-item multidimensional support;
6. design the constrained / explanatory layer;
7. evaluate selected sirt-style rater extensions;
8. continue strengthening `mfrmr`-specific workflow capabilities in parallel.

## 5.1 Adjacent-expansion triage

The feasibility audit adds four important scope rules:

- optional interactive **2D** visualization is a valid workflow extension;
- native **3D** visualization is not a roadmap priority;
- ordered binary / ordered polytomous data with arbitrary facet count remain a
  design rule rather than a new feature family;
- count models, simplified time-aware drift extensions, and multidimensional
  models are all plausible, but they should enter only in that order of
  architectural readiness, not all at once.

This means the roadmap after the first `GPCM` release should stay narrow:

1. finish `GPCM`;
2. optionally add interactive 2D wrappers where the payload contract is
   already stable;
3. then choose the next model-family expansion deliberately instead of opening
   count, continuous, multidimensional, dynamic, and nonparametric branches
   simultaneously.

## 6. Stop rules

Stop or defer a task when:

- it requires generic breadth with no many-facet product gain;
- the only justification is "TAM or mirt already has it";
- the implementation would force overclaiming parity;
- or the workflow/documentation layer cannot remain coherent after the change.

## 7. Immediate next action

The next implementation milestone should be:

> `GPCM` specification and internal seam audit, with explicit attention to
> how current information, prediction, simulation, and reporting helpers must
> change once item slopes are allowed to vary.
