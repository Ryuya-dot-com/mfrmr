# mfrmr Master Plan

Date: 2026-04-03  
Package baseline: `mfrmr` 0.1.5

## 1. Purpose

This document defines the **final goal, scope boundary, delivery logic, and
definition of done** for the current `mfrmr` development program.

It is stricter than the checklist file. The checklist tracks tasks; this file
defines what the project is trying to become, what it will not try to become,
and how each phase must be executed and validated.

Companion audit:
See `inst/references/M1_AUDIT_FACETS_CONQUEST_THEORY_PERFORMANCE_2026-04-03.md`
for the current source-backed audit of official-software overlap, mathematical
boundaries, and performance priorities.
Execution protocol:
See `inst/references/MFRMR_EXECUTION_PROTOCOL_2026-04-03.md` for the
feature-classification rules, evidence ladder, claim-control rules, and
milestone-specific execution queue.
Ecosystem comparator audit:
See `inst/references/M3_TAM_SIRT_MIRT_ECOSYSTEM_AUDIT_2026-04-04.md` and
`inst/references/M3_ECOSYSTEM_COVERAGE_PLAN_2026-04-04.md` for the
source-backed open-source comparator matrix and the post-M2 coverage queue.
GPCM implementation spec:
See `inst/references/M3_GPCM_SPEC_2026-04-04.md` for the smallest defensible
post-M2 model-family expansion target.
Priority execution queue:
See `inst/references/M3_PRIORITY_EXECUTION_QUEUE_2026-04-04.md` for the
post-audit execution order, stop/go gates, and current one-branch-at-a-time
rule.

## 2. Final goal

The final goal of the current roadmap cycle is:

> Make `mfrmr` a **research-grade, non-Bayesian, CRAN-ready R package for
> ordered-category many-facet Rasch measurement**, with reliable estimation,
> scoring, simulation, planning, diagnostics, and reporting for the
> `RSM` / `PCM` family, plus literature-backed help pages that clearly
> distinguish implemented theory, practical approximation, and future work.

In practical terms, this means the package should be able to serve as:

- a defensible open alternative for the **ordered-response overlap** of
  ConQuest and FACETS, without claiming full parity with either package; and
- a many-facet-first workflow package whose relevant feature envelope can be
  compared credibly with TAM, sirt, and mirt without pretending to replace
  every one of those packages wholesale.

## 3. What counts as "done" for this roadmap cycle

The roadmap cycle is complete only when all of the following are true:

1. `R CMD check --as-cran` is stable at a clean package baseline aside from
   external environment notes not caused by package source.
2. The ordered-response workflow (`RSM` / `PCM`) is internally consistent
   across:
   - estimation,
   - diagnostics,
   - simulation,
   - design evaluation,
   - prediction/scoring,
   - and reporting helpers.
3. Binary responses are explicitly documented and tested as ordered
   two-category inputs.
4. User-facing documentation for the ordered-response workflow explains:
   - model assumptions,
   - interpretation,
   - limitations,
   - and source-backed theoretical footing.
5. Population-model work is upgraded from "approximate helper behavior" to a
   clearly specified and validated design, starting with unidimensional latent
   regression under `MML`.
6. The package has a written validation boundary that says exactly which
   ConQuest/FACETS comparisons are legitimate, and which are not.

## 4. What this project is not trying to do

The following are **explicit non-goals** for the current cycle:

- Full ConQuest parity.
- Full FACETS parity.
- Any Bayesian estimation layer via Stan.
- Unordered nominal response modeling before the ordered-response core is
  theoretically documented and operationally stable.
- Multidimensional or imported-design generalization before latent regression
  and ordered-response validation are in place.
- Broad feature claims that are not backed by tests, help pages, and sources.

## 5. Product positioning

`mfrmr` should be positioned as:

- an **open, native-R, non-Stan implementation** for many-facet Rasch work;
- strongest in the **ordered-category** space;
- progressively expanding toward selected ConQuest/FACETS capabilities;
- conservative about theoretical claims;
- explicit whenever an output is an approximation, not a full population-model
  implementation.

It should **not** be positioned as a drop-in replacement for commercial
software across all response families.
It should also **not** be positioned as a generic all-of-IRT replacement for
TAM or mirt. Its comparative advantage must remain many-facet workflow
coherence.

## 6. Guiding principles

Every feature decision should follow these rules:

1. Prefer **ordered-category completeness** over premature breadth.
2. Prefer **shared infrastructure** over feature-specific hacks.
3. Prefer **small validated releases** over large speculative jumps.
4. Prefer **official documentation and primary literature** over secondary
   summaries.
5. Do not widen user-facing claims faster than tests and documentation.
6. If a comparison with ConQuest/FACETS is made, it must be restricted to
   overlapping implemented functionality.

## 7. Evidence base

The roadmap is anchored in official manuals and primary references:

- ACER ConQuest Manual: <https://conquestmanual.acer.org/index.html>
- ACER ConQuest Tutorial: <https://conquestmanual.acer.org/s2-00.html>
- ACER ConQuest Technical Matters: <https://conquestmanual.acer.org/s3-00.html>
- FACETS Help Manual (official PDF): <https://www.winsteps.com/ARM/Facets-Manual.pdf>
- FACETS fair average notes: <https://www.winsteps.com/facetman/fairaverage.htm>
- FACETS bias analysis notes: <https://www.winsteps.com/facetman/biasanalysis.htm>
- Adams, Wilson, & Wang (1997), MRCMLM:
  <https://doi.org/10.1177/0146621697211001>
- Muraki (1992), GPCM:
  <https://www.ets.org/research/policy_research_reports/publications/report/1992/ihkr.html>
- Muraki (1993), information functions for the generalized partial credit model:
  <https://www.ets.org/research/policy_research_reports/publications/report/1993/ihfu.html>
- Bock (1972), nominal response model:
  <https://doi.org/10.1007/BF02291411>
- Mislevy (1991), plausible values:
  <https://doi.org/10.1007/BF02294457>
- Bock & Aitkin (1981), MML/EM:
  <https://doi.org/10.1007/BF02293801>
- TAM `tam.mml` manual:
  <https://search.r-project.org/CRAN/refmans/TAM/html/tam.mml.html>
- TAM `tam.latreg` manual:
  <https://search.r-project.org/CRAN/refmans/TAM/html/tam.latreg.html>
- TAM `tam.pv` manual:
  <https://search.r-project.org/CRAN/refmans/TAM/html/tam.pv.html>
- mirt `mirt` manual:
  <https://search.r-project.org/CRAN/refmans/mirt/html/mirt.html>
- mirt `mixedmirt` manual:
  <https://search.r-project.org/CRAN/refmans/mirt/html/mixedmirt.html>
- mirt `fscores` manual:
  <https://search.r-project.org/CRAN/refmans/mirt/html/fscores.html>
- sirt `rm.facets` manual:
  <https://rdrr.io/cran/sirt/man/rm.facets.html>

## 8. Strategic reading of ConQuest and FACETS

The manuals imply the following prioritization logic:

- ConQuest’s main strategic strengths are:
  arbitrary linear design, latent regression, multidimensional models,
  plausible values, GPCM, and Bock nominal response modeling.
- FACETS’ main strategic strengths are:
  many-facet operational reporting, bias interactions, fair averages,
  count-model variants, and flexible `Model=` specifications.

Therefore, the open-source roadmap should proceed in this order:

1. finish the ordered-category many-facet core;
2. add the highest-value population model layer (`latent regression`);
3. add the nearest post-Rasch ordered extension (`GPCM`);
4. only then move to unordered nominal models;
5. keep higher-complexity families as later work.

## 8.1 Strategic reading of TAM, sirt, and mirt

The open-source ecosystem changes the positioning logic:

- TAM is already broad in many-facets, latent regression, `GPCM`, nominal,
  multidimensional IRT, plausible values, and weighted-likelihood scoring.
- mirt is already broad in generalized item families, multidimensionality,
  explanatory predictors, mixed effects, and posterior scoring.
- sirt is a narrower but relevant comparator for focused rater-facets
  extensions such as rater slopes and rater-item interactions.

Therefore the post-M2 roadmap cannot be framed only as "catch up to commercial
software". It must answer two questions simultaneously:

1. Which estimation/scoring families from the open-source comparator set are
   essential to cover?
2. Which workflow capabilities should make `mfrmr` distinct even when TAM or
   mirt already cover parts of the model space?

The companion ecosystem audit fixes the current answer:

- cover the relevant comparator envelope;
- do not attempt literal package-for-package imitation;
- strengthen long-format many-facet workflow, planning, QC, reporting, and
  external auditability as deliberate differentiators.

## 9. Workstreams

The project is split into five workstreams.

### Workstream A. Quality baseline

Objective:
Maintain CRAN-quality discipline and prevent research feature work from running
ahead of package stability.

Required outcomes:

- stable build/check behavior;
- no package-caused blocking errors;
- release notes that reflect user-facing changes only.

### Workstream B. Ordered Rasch-family completion

Objective:
Make `RSM` / `PCM` behavior consistent across the whole package.

Required outcomes:

- helper-layer generalization matches the estimation core;
- binary two-category support is explicit and tested;
- `PCM` support is not partial in downstream helpers that claim generality;
- automatic comparison logic remains conservative and theoretically defensible.

### Workstream C. Documentation and theory

Objective:
Keep the theoretical story synchronized with the implemented package.

Required outcomes:

- help pages updated for every substantive feature expansion;
- explicit "what this does not justify" sections for approximation-heavy APIs;
- references included for model families and scoring logic;
- internal roadmap text distinguishes:
  implemented,
  approximate,
  and planned.

### Workstream D. Population model extensions

Objective:
Add the highest-leverage ConQuest-style extension that still fits the
non-Stan architecture.

Required outcomes:

- unidimensional latent regression under `MML`;
- population-model-aware prediction and plausible values;
- tests showing why this is preferable to secondary regression on EAP/MLE
  point estimates.

### Workstream E. Post-Rasch model expansion

Objective:
Expand model families without abandoning the package’s validation discipline.

Current priority rule:

- finish first-release `GPCM` before opening any second major model-family
  branch;
- allow only low-risk workflow improvements in parallel;
- treat multidimensional work as the next major candidate only after the
  `GPCM` gates are closed.

Required outcomes:

- `GPCM` before nominal;
- nominal only after interface separation from ordered scoring;
- explicit diagnostic validity boundaries across model families.

### Workstream F. Ecosystem differentiation

Objective:
Keep `mfrmr` strategically coherent relative to TAM, sirt, and mirt.

Required outcomes:

- a source-backed comparator matrix for the relevant feature envelope;
- a prioritized queue for covering missing ecosystem-critical model families;
- and explicit reinforcement of `mfrmr`'s many-facet workflow strengths.

## 10. Milestones

### Milestone M0. Stable maintenance baseline

Status:
Substantially complete.

Exit condition:

- check baseline stabilized;
- Dropbox documentation artifact issue removed;
- package version reset onto a clean development baseline.

### Milestone M1. Ordered-category production baseline

This is the **current highest-priority milestone**.

Scope:

- helper generalization for fit-derived names and step facets;
- `PCM` information support;
- fixed-calibration scoring for `MML` and `JML`;
- explicit binary support;
- theory/help-page synchronization.

Exit condition:

1. Ordered-category user workflows do not silently narrow to legacy
   `Rater` / `Criterion` assumptions.
2. Binary `RSM` and binary `PCM` are tested and documented.
3. Help pages explain the package’s actual ordered-category scope.
4. Remaining `compare_mfrm()` nesting logic is either:
   - expanded with theory-backed support, or
   - intentionally frozen and documented as conservative.

Current assessment on 2026-04-03:
the second outcome is the correct one. No additional automatic nesting
relation beyond `RSM`-in-`PCM` is warranted in the current package model
space. The cross-cutting documentation track should therefore focus on
clarifying ordered binary support, design-weighted `PCM` information, and the
post hoc nature of fixed-calibration scoring after `JML` fits.

### Milestone M2. Population model baseline

Scope:

- unidimensional latent regression;
- proper population-model parameter interface;
- plausible values tied to the population model rather than only a fixed-grid
  helper approximation.

Detailed implementation plan:

- see `inst/references/M2_LATENT_REGRESSION_MASTER_PLAN_2026-04-03.md`
- and the readiness boundary in
  `inst/references/M2_LATENT_REGRESSION_READINESS_AUDIT_2026-04-03.md`

Exit condition:

1. A user can fit a latent regression model directly from item responses.
2. The package can explain and validate the difference between:
   - latent regression,
   - post hoc regression on EAPs,
   - and post hoc regression on MLE/JML scores.
3. Help pages and examples clearly state when outputs depend on a population
   model.

### Milestone M3. First ordered extension beyond Rasch

Scope:

- `GPCM` as the first non-Rasch ordered model;
- plus the seam audit needed so scoring, information, simulation, and
  reporting do not silently keep Rasch-only assumptions.

Exit condition:

1. The API separates Rasch-family assumptions from slope-varying assumptions.
2. Information, prediction, simulation, and diagnostics either support `GPCM`
   or clearly state that they do not.
3. Recovery studies demonstrate correct behavior under simulated data.

### Milestone M4. Post-ordered expansion

Scope:

- nominal response model;
- multidimensional and imported-design work;
- FACETS-style count models only after the above are stable.

### Milestone M5. Ecosystem-aware many-facet platform

Scope:

- explanatory / constrained design layers where defensible;
- selected sirt-style rater slope / interaction work;
- reinforcement of `mfrmr`'s workflow advantages relative to TAM and mirt.

Exit condition:

1. `mfrmr` covers the relevant open-source comparator envelope for a
   many-facet-first package.
2. `mfrmr` still has clearly stronger workflow integration than the estimator-
   only reading of that same ecosystem.

Exit condition:

- this milestone should not begin until M1 and M2 are complete.

## 11. Definition of done for every feature

No feature is considered complete unless all of the following are done:

1. Code implementation.
2. Regression tests.
3. At least one source-backed help-page update.
4. At least one example or workflow demonstration.
5. A written limitation statement.
6. Validation evidence appropriate to the feature:
   synthetic recovery,
   nested reduction,
   internal benchmark,
   or external overlap benchmark.

## 12. Decision rule for `compare_mfrm()`

The plan should not assume that `compare_mfrm()` must support more automatic
nesting relations than it does now.

Instead, the correct question is:

> Are there additional nested model relations in the current package that are
> truly defensible on a shared likelihood basis?

If the answer is "no", the correct outcome is **not** expansion. The correct
outcome is to document the current conservative restriction.

## 13. Prompt templates for each development cycle

These prompts are intended to keep the project on-axis.

### 13.1 Research prompt

Use before implementation:

```text
Identify the exact overlapping functionality between mfrmr and the target
ConQuest/FACETS/TAM/sirt/mirt capability. State the model family,
assumptions, estimation basis, and whether the requested feature belongs to:
1. implemented theory,
2. a practical approximation, or
3. a future extension.
List the primary sources and the smallest defensible implementation target.
```

### 13.2 Specification prompt

Use after research:

```text
Write the minimum user-facing specification for the feature:
- input contract,
- output contract,
- failure conditions,
- interpretation boundary,
- backward-compatibility impact,
- and testable acceptance criteria.
Do not include extra options unless they are required by the theory or by
current package conventions.
```

### 13.3 Implementation prompt

Use before coding:

```text
Implement the smallest change set that makes the feature internally consistent
across estimation, helper APIs, and object structure. Prefer shared utility
functions over one-off patches. If theory does not support generalization,
keep the guardrail and improve the message instead of widening behavior.
```

### 13.4 Validation prompt

Use before closing the task:

```text
Demonstrate that the feature is correct by using the narrowest convincing
evidence:
- regression test,
- synthetic recovery,
- nested reduction,
- and, where overlap exists, external benchmark logic.
State explicitly what was validated and what remains unvalidated.
```

### 13.5 Documentation prompt

Use before release:

```text
Update the help pages so they explain:
- what the feature assumes,
- how to interpret it,
- what it does not justify,
- and which references support it.
Separate implemented behavior from approximation and from planned work.
```

## 14. Immediate next actions

The next planning-aware implementation sequence should be:

1. Audit `compare_mfrm()` and decide whether any valid automatic nesting
   relation beyond `RSM`-in-`PCM` truly exists in the current model space.
2. Expand theory/help coverage for the features already implemented in this
   cycle:
   binary support,
   `PCM` information,
   and fixed-calibration scoring after `JML`.
3. Design the unidimensional latent-regression interface before adding any new
   response family.
4. Delay nominal/multinomial work until the latent-regression and
   documentation track are both stable.
5. After M2, use the ecosystem audit to choose the next family in this order:
   `GPCM`, plausible-values strengthening, nominal, multidimensional,
   constrained/explanatory layer, selected rater-slope extensions.

## 15. Stop rules

Stop or defer a task if any of the following become true:

- the task requires Stan or another Bayesian layer;
- the theory/doctrine for the claimed feature is not clear enough to document;
- the only way to proceed is to overstate comparability with ConQuest/FACETS;
- the only way to proceed is to mimic TAM / mirt breadth without a coherent
  many-facet product reason;
- helper generalization would exceed what the underlying model family
  justifies;
- testing can show the feature runs, but not that it is defensible.

At that point, the task should be reclassified as:

- deferred,
- research-only,
- or out of scope for the current roadmap cycle.
