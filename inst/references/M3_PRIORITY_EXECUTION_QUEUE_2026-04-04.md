# M3 Priority Execution Queue

Date: 2026-04-04  
Package baseline: `mfrmr` 0.1.5

Companion notes:

- `inst/references/M3_ECOSYSTEM_COVERAGE_PLAN_2026-04-04.md`
- `inst/references/M3_GPCM_SPEC_2026-04-04.md`
- `inst/references/M3_EXPANSION_FEASIBILITY_AUDIT_2026-04-04.md`
- `inst/references/M3_ARBITRARY_FACET_PLANNING_AUDIT_2026-04-04.md`

## 1. Purpose

This note fixes the **practical execution order** after the feasibility audit.
It is not another broad wishlist. Its purpose is to answer:

1. what to do next,
2. what to delay even if it looks attractive,
3. and what must be true before the roadmap is allowed to widen.

## 2. Core rule

From this point forward, `mfrmr` should follow a **one-major-branch-at-a-time**
rule:

- only one new estimation family may be active at a time;
- workflow improvements may proceed in parallel only when they do not change
  the statistical model;
- no secondary branch may open if it would weaken validation or documentation
  for the current primary branch.

This rule exists to prevent scope drift.

## 3. Final endpoint for the current cycle

The current cycle should now be interpreted as:

> Make `mfrmr` a validated many-facet-first package with
> `RSM` / `PCM` + latent regression + first-release `GPCM`,
> while preserving clear room for later nominal and multidimensional work.

This is narrower than "cover everything in TAM, sirt, and mirt," and that is
intentional.

## 4. Priority tiers

## 4.1 Priority A: execute now

These are the tasks that should receive immediate engineering time.

### A1. Finish first-release `GPCM`

Why first:

- it is the nearest mathematically and architecturally to the current `PCM`;
- it is already documented in TAM and mirt;
- it extends the current ordered many-facet identity rather than diluting it.

Definition of done:

- parameter scaffold for `slope_facet`;
- `category_prob_gpcm()` with exact `PCM` reduction when all slopes equal 1;
- `MML` path support;
- `JML` support only if validated, otherwise explicit rejection;
- posterior scoring support or explicit guarded rejection;
- information support;
- simulation support;
- help-page separation of `PCM` and `GPCM` interpretation;
- synthetic recovery and reduction tests.

Current state:

- parameter scaffold: completed
- probability engine and exact `PCM` reduction tests: completed
- `MML` support: completed
- `JML` support: completed for the narrow first-release branch
- fixed-calibration posterior scoring: completed
- information: completed for the design-weighted precision screen
- fit-level Wright/pathway/CCC plots: completed
- category curve/structure reports and graph-only output bundles: completed
- direct simulation: completed for slope-aware sim-spec generation and
  `simulate_mfrm_data()`
- synthetic recovery and package-native benchmark coverage: completed
- planning / forecasting simulation: still intentionally restricted
- planning / forecasting scope metadata: completed via explicit
  `planning_scope` objects
- fair-average score-side semantics: intentionally restricted after the
  source-backed audit recorded in
  `inst/references/M3_GPCM_FAIR_AVERAGE_AUDIT_2026-04-04.md`
- broader reporting/diagnostics: still intentionally restricted

### A2. Keep arbitrary-facet logic intact while `GPCM` lands

Why:

- this is part of the package's identity, not optional breadth;
- losing arbitrary-facet coherence would make the expansion self-defeating.

Definition of done:

- no new helper can silently assume a literal 2-facet or 3-facet design;
- tests cover nontrivial multi-facet `GPCM` indexing, even if the first public
  examples stay narrow.

### A3. Prepare optional interactive 2D wrappers only at the payload layer

Why now:

- low model risk;
- uses existing `mfrm_plot_data` payloads;
- strengthens `mfrmr`'s workflow advantage without opening a new model family.

Definition of done:

- no hard dependency in `Imports`;
- `Suggests`-based optional wrappers only;
- selected high-value plots only;
- no 3D requirement;
- no change to the current base-R default.

## 4.2 Priority B: execute only after Priority A is closed

### B1. Between-item multidimensional ordered models

Why:

- strongest long-run scientific payoff after `GPCM`;
- strongest overlap with TAM / mirt expectations that still fits the package's
  rubric-oriented use case.

Gate before start:

- first-release `GPCM` complete;
- posterior scoring and simulation contracts stable enough to generalize;
- a specific multidimensional spec exists before coding starts.

### B2. Strengthen plausible-values / scoring workflow further

Why:

- this remains a meaningful comparator gap against TAM and mirt;
- but it should follow, not interrupt, the current `GPCM` branch unless a
  concrete scoring blocker appears.

## 4.3 Priority C: later conditional candidates

These are plausible, but only if there is real user demand and the earlier
branches are stable.

### C1. Nominal response branch

Adopt only after:

- ordered `GPCM` is stable;
- multidimensional direction is clearer;
- diagnostics boundaries for cross-family comparison are specified.

### C2. Binomial and Poisson count models

Adopt only after:

- generalized ordered and scoring layers are stable;
- family-specific fit/reporting semantics are specified;
- demand is clear enough to justify the added maintenance burden.

### C3. Simplified non-Bayesian time-aware drift extensions

Adopt only after:

- the generalized ordered layer is stable;
- the package can clearly describe the difference between:
  - time as a facet,
  - drift screening,
  - and full dynamic latent-state modeling.

## 4.4 Priority D: explicitly out of scope for the current cycle

- native 3D visualization as a roadmap requirement;
- native continuous-response family;
- full Bayesian Uto-style dynamic generalized many-facet models;
- native Mokken estimation inside `mfrmr`.

## 5. Stop/go gates

The roadmap may widen only if every gate for the current branch is green.

### Gate 1. Statistical core

- likelihood/probability engine implemented;
- identification documented;
- boundary cases tested.

### Gate 2. Downstream coherence

- scoring either works or rejects explicitly;
- simulation either works or rejects explicitly;
- information/reporting language is updated.

### Gate 3. Validation

- synthetic recovery complete;
- reduction checks complete where applicable;
- no overclaiming in user-facing docs.

### Gate 4. Workflow integrity

- planning, QC, export, and reporting remain coherent;
- the new feature strengthens rather than fragments the many-facet workflow.

If any gate fails, stop widening the roadmap and close the current branch
first.

## 6. Immediate execution sequence

The next concrete queue should be:

1. keep direct `GPCM` simulation active while preserving explicit stops for
   planning/forecasting helpers;
2. widen reporting only where the generalized semantics are validated;
3. only then start optional interactive 2D wrappers.

This sequence is intentionally narrow.

## 7. Question discipline

The package should ask, before every new candidate:

1. Does this strengthen the ordered many-facet core?
2. Does this strengthen a many-facet workflow advantage?
3. Is there a source-backed theory and a realistic validation path?
4. Would adding it now delay `GPCM` or destabilize the current branch?

If the answer to Question 4 is yes, defer it.

## 8. Bottom line

The near-term roadmap is now fixed:

- **finish `GPCM`;**
- **preserve arbitrary-facet coherence;**
- **add only low-risk workflow improvements in parallel;**
- **defer breadth until the current generalized ordered branch is fully closed.**
