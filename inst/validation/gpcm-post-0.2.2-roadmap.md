# Post-0.2.2 bounded GPCM roadmap

This note tracks bounded-`GPCM` work that remains caveated, blocked, or
deferred after the 0.2.2 release boundary. It is a maintenance roadmap, not a
public support promise. The current public contract remains
`gpcm_capability_matrix()`.

## Current release boundary

0.2.2 supports bounded `GPCM` fitting, core summaries, fixed-calibration
posterior scoring, information, curve/category views, direct simulation-spec
generation, direct parameter-recovery checks, summary-table appendix routing,
fair-average review, residual-bias screening, package-native scorefile export,
report/QC bundles, linking synthesis, role-based design forecasting,
diagnostic/signal-detection design screening, and DFF/DIF screening within the
caveats documented in the help pages.

The bounded route still requires an explicit step facet and the current
`slope_facet == step_facet` contract. Direct recovery evidence is not design
operating-characteristic evidence, exploratory diagnostic screens are not
standalone fairness or validity decisions, and package-native scorefile output
is not FACETS score-side equivalence.

Every blocked or deferred capability row is tracked in
`gpcm_runtime_guard_coverage()`. Rows with public helper surfaces must stop
with `mfrmr_gpcm_scope_error`; rows without a public runtime surface are
marked `roadmap_only`. Caveated rows are not guard rows, but this roadmap
records the evidence needed before their wording can become stronger.

## Roadmap work packages

### GPCM score-side export contract

Capability rows:

- `FACETS output-contract score-side review` (`blocked`)
- `Score-side scorefile export under bounded GPCM`
  (`supported_with_caveat`; keep FACETS-equivalence wording out of scope)
- `APA writer and fit-based export bundles` (`supported_with_caveat`; keep
  operational wording constrained by this score-side contract)

Required evidence before unblocking:

- Keep `gpcm_score_side_contract()` synchronized with this roadmap,
  `gpcm_capability_matrix()`, and `gpcm_runtime_guard_coverage()`.
- Define the bounded-`GPCM` score-side estimand separately from Rasch-family
  measure-to-score semantics.
- Preserve unit-slope `GPCM` reduction tests against the `PCM` route.
- Add negative tests that fail if unsupported score-side rows are silently
  emitted.

### GPCM design operating characteristics and forecasting

Capability rows:

- `Design evaluation and population forecasting under bounded GPCM`
  (`supported_with_caveat`)
- `Diagnostic and signal-detection design screening under bounded GPCM`
  (`supported_with_caveat`)
- `Differential facet functioning screening under bounded GPCM`
  (`supported_with_caveat`)
- `Operational linking synthesis` (`supported_with_caveat`)

These helpers are available only for the current role-based design layer and
only when the requested design matches the bounded slope structure carried by
the simulation specification. They report design-level sensitivity evidence,
not operational scoring, calibrated inferential tests, fairness decisions, or
arbitrary-facet planning.

Required evidence before stronger wording:

- Expand multi-seed fixtures across slope regimes, sparse linkage patterns,
  sample sizes, score-support stress, local dependence, and
  step/slope-facet misspecification.
- Keep DFF and diagnostic/signal-detection rows labeled as screening evidence.
- Validate larger anchor, drift, and equating-chain fixtures before upgrading
  linking language beyond exploratory synthesis.

### GPCM posterior predictive checks and heavy backends

Capability row:

- `MCMC and heavy-backend extensions` (`deferred`)

Posterior predictive checks, MCMC, Docker-based advanced runtimes, and broad
backend promotion remain out of the 0.2.2 support boundary. They should be
designed only after the score-side contract and identification evidence are
stable.

Required evidence before implementation:

- Decide the posterior predictive targets and whether they belong in the R
  package or a later backend.
- Define runtime budgets and CRAN-safe examples before exposing public helper
  routes.
- Keep posterior predictive checks separate from ordinary residual screening
  until validation evidence exists.

## Stop conditions

- Do not call bounded `GPCM` complete while any advertised workflow remains
  blocked or deferred.
- Do not describe package-native bounded-`GPCM` scorefile output as FACETS
  score-side equivalence.
- Do not add complete GPCM, multidimensional estimation, posterior predictive
  checks, MCMC, or heavy backends to the 0.2.2 release boundary.
