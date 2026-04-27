# mfrmr Execution Protocol

Date: 2026-04-03  
Package baseline: `mfrmr` 0.1.5

## 1. Purpose

This protocol translates the master plan into operational rules for day-to-day
development. It answers five questions before any new work starts:

1. what kind of feature is this,
2. what is the smallest defensible scope,
3. what evidence is required,
4. what public language is allowed,
5. when must the task stop or be deferred.

This document is stricter than the roadmap checklist. The checklist tracks
tasks; this protocol defines how those tasks must be executed.

## 2. Final endpoint for the current cycle

The current roadmap cycle ends when `mfrmr` can be defended as:

- a CRAN-ready, non-Bayesian, native-R package,
- for ordered-category many-facet Rasch work,
- with stable `RSM` / `PCM` estimation, scoring, simulation, planning,
  diagnostics, and reporting,
- and with help pages that distinguish implemented theory, approximation, and
  future work without overstating ConQuest/FACETS comparability.

Everything below exists to protect that endpoint.

## 2.1 Ecosystem filter

The phrase "cover TAM / sirt / mirt" must be interpreted narrowly:

- cover the relevant comparator envelope for a many-facet-first package;
- do not interpret it as a requirement to clone every auxiliary utility or
  generic IRT feature in those packages;
- do not add breadth unless it supports either:
  - the estimation / scoring families users would reasonably expect in this
    niche, or
  - a workflow capability that is a strategic strength of `mfrmr`.

## 2.2 Priority filter

After the M3 feasibility audit, the package must also obey a stricter queue:

- one major model-family branch at a time;
- close `GPCM` before opening nominal, multidimensional, count, or dynamic
  branches;
- permit only low-risk workflow work in parallel with the current primary
  estimation branch.

## 3. Feature classification

Every task must be assigned to exactly one class before work starts.

### Class A. Ordered-core completion

Use when the task improves the already implemented ordered-response family
without changing the model family.

Examples:

- binary documentation and tests,
- `PCM` helper support,
- fit-derived custom two-facet names,
- planning metadata,
- low-risk performance cleanup.

Required evidence:

- regression tests,
- help-page update,
- and at least one workflow demonstration.

### Class B. Approximation-layer refinement

Use when the task improves a package-level approximation rather than adding a
new estimation model.

Examples:

- post hoc EAP scoring after `JML`,
- approximate plausible values under a fixed calibration,
- design-weighted information summaries,
- signal-screening summaries built on existing heuristics.

Required evidence:

- regression tests,
- explicit limitation statement,
- source-backed description of why the approximation is useful,
- source-backed statement of what it is not.

### Class C. New population-model capability

Use when the task changes the statistical model rather than only the helper
layer.

Examples:

- latent regression,
- population-model-aware plausible values.

Required evidence:

- specification document,
- synthetic recovery or calibration study,
- API-level tests,
- help pages with references,
- and explicit comparison against the current approximation path.

### Class D. New response-model family

Use when the task changes the response model family.

Examples:

- `GPCM`,
- nominal response,
- count models.

Required evidence:

- feature-specific specification,
- synthetic recovery,
- diagnostics boundary statement,
- and a written note explaining which current helpers remain valid, invalid,
  or not yet supported.
- plus explicit approval under the current priority queue when another major
  model-family branch is already open.

## 4. Claim-control rules

The package must not widen its public claims faster than its evidence. Use the
following language rules.

### Allowed phrases

- "aligned with"
- "conceptually aligned with"
- "inspired by"
- "fixed-calibration approximation"
- "design-weighted precision screen"
- "screening rate"
- "ordered two-category special case"

### Disallowed phrases unless full evidence exists

- "equivalent to ConQuest"
- "equivalent to FACETS"
- "full plausible values procedure"
- "textbook test information function"
- "arbitrary-facet planner"
- "formal inferential power" for bias-side screening summaries

### Required disclaimers for current M1 outputs

- `predict_mfrm_units()` and `sample_mfrm_plausible_values()`:
  fixed-calibration scoring; `JML` path is post hoc and approximate.
- `compute_information()`:
  design-weighted precision summary, not design-free TIF.
- planning alias/descriptor support:
  public naming layer over the current two-non-person-facet planner.
- ConQuest/FACETS comparisons:
  restricted to the ordered-response overlap actually implemented.

## 5. Evidence ladder

Use the smallest evidence set that is still convincing. Do not overbuild.

### Level 1. Contract evidence

Use for naming, object-structure, and guardrail changes.

Minimum:

- unit/regression test,
- help-page update,
- and one concrete example.

### Level 2. Approximation evidence

Use for helper outputs with inferential interpretations.

Minimum:

- Level 1 evidence,
- written limitation statement,
- source-backed interpretation note,
- and at least one targeted simulation or numerical check.

### Level 3. Estimation evidence

Use for new model-fitting behavior.

Minimum:

- Level 1 evidence,
- synthetic recovery,
- boundary-case tests,
- and explicit statement of unsupported downstream helpers.

### Level 4. External-overlap evidence

Use only where `mfrmr` and commercial software clearly overlap.

Minimum:

- Level 3 evidence,
- overlapping design and metric definition,
- and written restriction of the comparison to that overlap.

## 6. Performance-risk protocol

Every optimization must be labeled `low`, `medium`, or `high` risk before
coding.

### Low risk

Permitted immediately if behavior is intended to remain identical.

Examples:

- moving design-specific setup outside replicate loops,
- avoiding repeated filtering,
- caching single-pass counts inside a replicate,
- pre-splitting lookup tables.

Required verification:

- targeted tests,
- full relevant test file,
- and one local timing snapshot.

### Medium risk

Needs explicit justification because results, RNG consumption, or object shape
may change.

Examples:

- vectorized response sampling,
- keyed effect-application rewrites,
- cached summaries stored on objects,
- optional parallel Monte Carlo execution.

Required verification:

- low-risk verification,
- plus reproducibility note,
- plus before/after timing note,
- plus statement about whether numerical equality is expected.

### High risk

Do not start inside M1 unless it unblocks package correctness.

Examples:

- optimizer changes,
- likelihood changes,
- default inference changes,
- broad concurrency changes touching reproducibility.

Required action:

- reclassify as research/specification first,
- or defer to a later milestone.

## 7. M1 feature inventory

This table defines the present ordered-core boundary.

| Area | Current status | Public classification | Next action |
| --- | --- | --- | --- |
| `RSM` / `PCM` estimation | implemented | implemented theory | maintain |
| binary ordered responses | implemented | implemented theory | maintain docs/tests |
| `PCM` information | implemented | implemented theory plus design-specific interpretation | maintain wording |
| `JML` post hoc unit scoring | implemented | practical approximation | keep caveat explicit |
| approximate plausible values | implemented | practical approximation | defer full population-model version to M2 |
| planning aliases/descriptors | implemented | interface layer | keep two-facet scope explicit |
| arbitrary-facet planning | not implemented | future work | do not imply support |
| latent regression | implemented | active M2 branch | maintain conservative claim boundary |
| `GPCM` | first-release implemented | active M3 branch | information and direct simulation completed; keep planning/reporting gates closed until widened explicitly |
| nominal response | not implemented | later target | defer |

## 8. M1 remaining queue

The remaining M1 queue should be executed in this order.

### M1-Q1. Public-language sweep

Goal:
remove any remaining wording that overstates parity, formality, or scope.

Acceptance:

- no "equivalent" claim for ConQuest/FACETS overlap unless exact overlap is
  being named,
- no bias-side screening summary is described as formal power,
- no fixed-calibration approximation is described as a full population model.

### M1-Q2. Resampled/skeleton assignment speed cleanup

Goal:
remove repeated template filtering in empirical assignment builders.

Acceptance:

- no behavioral change in existing tests,
- local timing note shows improvement in the targeted path,
- RNG behavior remains unchanged.

### M1-Q3. Planning benchmark harness

Goal:
create a lightweight reproducible benchmark script for simulation/planning
helpers.

Status on 2026-04-03:
completed via `analysis/benchmark_planning_helpers.R` and
`inst/references/M1_PLANNING_BENCHMARK_2026-04-03.md`.

Acceptance:

- one script or documented command sequence,
- benchmark covers simulation, design evaluation, and signal detection,
- benchmark notes identify hardware-sensitive interpretation limits.

### M1-Q4. Bias-side metric naming review

Goal:
decide whether `screen_rate` should be more prominent than `power` in the plot
API for bias-side output.

Status on 2026-04-03:
completed conservatively. The API keeps `power` as a backwards-compatible
alias, but public wording now prefers `screen_rate` and explicitly interprets
bias-side summaries as screening behavior rather than formal inferential power.

Acceptance:

- either the current API is retained with stronger wording,
- or a clearer alias/presentation path is added without breaking users.

## 9. M2 preconditions

M2 work must not start until all of the following are written down.

Current working references:

- `inst/references/M2_LATENT_REGRESSION_READINESS_AUDIT_2026-04-03.md`
- `inst/references/M2_LATENT_REGRESSION_MASTER_PLAN_2026-04-03.md`
- `inst/references/M2_LATENT_REGRESSION_STATISTICAL_SPEC_2026-04-03.md`

### M2-P1. Statistical specification

- latent regression parameterization,
- covariate interface,
- identification constraints,
- estimation pathway under `MML`,
- and relationship to current EAP/JML helper outputs.

### M2-P2. Validation design

- what simulated data-generating mechanism will be used,
- what parameter-recovery metrics will be reported,
- what comparison baseline will be used,
- and what failure modes are expected.

### M2-P3. Documentation contract

- what help pages will change,
- how the difference between population-model outputs and fixed-calibration
  approximations will be explained,
- and what ConQuest overlap can be claimed legitimately.

## 10. Task card template

Every substantive task should be summarized in this format before coding:

```text
Task:
Class:
Milestone:
Why now:
Smallest defensible scope:
Main risks:
Required sources:
Required evidence:
Public language boundary:
Stop rule:
```

## 11. Stop rules

Stop or defer work immediately if any of these become true:

- the feature needs Stan or Bayesian machinery,
- the theory is too unclear to document honestly,
- the only justification is parity theater with commercial software,
- the helper layer would overpromise beyond the current model family,
- the optimization would likely change numerical behavior without a validation
  plan,
- or the package can only claim "it runs" rather than "it is defensible".

When a stop rule fires, the task must be relabeled as:

- deferred,
- research-only,
- or out of scope.

## 12. Operating instruction for future turns

For the remainder of M1, every turn should follow this order:

1. classify the task,
2. state the boundary,
3. implement the smallest defensible slice,
4. validate locally,
5. update help/notes,
6. update roadmap artifacts if the boundary changed.
