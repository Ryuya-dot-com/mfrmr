# mfrmr 0.2.3 M1 release-gate review

## Review state

| Field | Value |
| --- | --- |
| Review ID | `0.2.3-m1-review.1` |
| Date | 2026-07-27 |
| Input specification | `0.2.3-draft.1` |
| Resulting specification | `0.2.3-draft.2` |
| Review outcome | Planning contract accepted for M2 instrumentation |
| Confirmation authorized | No |

This is a source-grounded adversarial review of the draft gate, not release
evidence. It asks whether each proposed decision can be computed from the
current object, whether a misleading pass is possible, and whether the gate
would remain interpretable for old objects, weighted fits, different
integration settings, and external engines.

## Cross-gate result

| Gate | M1 finding | M2 consequence |
| --- | --- | --- |
| G0 candidate identity | The 0.2.2 readiness helper checks release files but does not yet bind every statistical result to a specification, candidate, scenario, and evidence hash. | Add a candidate/result manifest before any confirmation run. |
| G1 numerical stationarity | Optimizer diagnostics expose terminal gradients, but the current review tolerance is an implementation default and the reference is not independent for every model family. | Build independent score/objective fixtures and calibrate the numeric rule on pilot-only cells. |
| G2 recovery/design | Recovery and first-use stress helpers exist, but their convenience defaults are not frozen 0.2.3 release thresholds and do not exhaust the new sparse/bridge negative controls. | Create a versioned ADEMP registry and separate pilot and confirmation seeds. |
| G3 information criteria | The current fit summary uses response rows or summed row weights for BIC, while `Persons` is already retained separately. Weighted fits can currently enter ranking and comparison values are passed through from summaries. | Implement the person-basis contract and the fail-closed rules below before IC pilot work. |
| G4 dimensionality | Residual PCAR/Q3-style tools can generate hypotheses, but no locked discovery/confirmation partition, four-model TAM attribution grid, or boundary-bootstrap runner exists. | Keep all dimensionality claims exploratory until the external runner and synthetic controls are instrumented. |
| G5 external overlap | The retained ConQuest evidence covers a narrow binary MML overlap. It does not establish the mandatory 0.2.3 RSM and PCM rows or any blanket FACETS equivalence. | Add matched RSM/PCM pilots and promote FACETS rows only one at a time. |
| G6 public contract | Current comparison help describes IC weights as model probabilities and can imply that a significant LRT is a meaningful practical gain. Both exceed the draft interpretation boundary. | Rewrite these surfaces and add negative wording tests as package-payload work. |
| G7 engineering | Exact-tarball and CRAN timing checks exist, but the current readiness schema cannot reconstruct every new blocker from candidate-linked result rows. | Extend readiness tooling after the result schema is implemented. |

No finding justifies skipping M2. The review accepts the gate structure while
identifying implementation and pilot work needed before freeze.

## G3 source trace and decisions

| Review item | Current source behavior | Adversarial risk | Frozen 0.2.3 decision |
| --- | --- | --- | --- |
| Sampling unit | `build_estimation_summary()` computes BIC from `N`, where `N` is prepared response rows or their summed weights. `Persons` is stored separately. | Rating density changes the penalty even when the independent Person count does not change. | Preserve legacy `N`, add explicit row/weight fields, and use prepared unique Persons as `ICSampleSize` for eligible fixed-facet MML. |
| Free dimension | The summary uses `sum(unlist(sizes))`; comparison uses `length(fit$opt$par)`. | Two internally consistent but divergent counts could produce different penalties. | Store canonical `Npar`, require equality with the retained optimization-vector length and an independently counted fixture value, and retain `npar` only as an equal compatibility alias. |
| Stored criteria | `compare_mfrm()` reads AIC/BIC from each fit summary. | A stale, edited, or legacy summary can determine ranking. | Recompute the common panel from canonical `LogLik`, `Npar`, and `Persons`; suppress ranking on a stored/recomputed mismatch. |
| Explicit unit weights | Merely naming a weight column currently changes the sample-size basis label to `sum_weights`. | An all-one column can change provenance despite an identical likelihood. | Classify an all-one prepared weight vector as `explicit_unit` and treat it exactly like unweighted MML. |
| Constant non-unit weights | A row weight constant within Person enters each conditional response contribution before latent integration. | Calling it a Person-frequency weight suggests an equivalence that generally does not hold: integrating a powered conditional likelihood is not the same as independently replicating the marginal Person likelihood. | Suppress AIC/BIC/SABIC ranking for every non-unit observation-weight fit in 0.2.3, including weights constant within Person. |
| JML | Raw criteria are shown, while cross-model ranking is already suppressed. | Users can still read a marginal-MML interpretation into incidental-parameter JML criteria. | Keep any legacy raw quantities explicitly descriptive and set the common MML panel ineligible; never mix JML and MML ranking. |
| Integration | Comparability currently checks method, data, and readiness, but not quadrature/QMC identity. | Model ordering can be numerical integration drift. | Require a common evaluation identity and suppress ranking until the locked integration check passes. |
| Legacy objects | A saved 0.2.2 object has no IC contract version and carries row-basis BIC. | Loading it under 0.2.3 could silently relabel or mix formulas. | Classify it `legacy_or_unknown`; show legacy descriptive values only and require refitting for 0.2.3 ranking. |
| Small-N SABIC | No SABIC field or non-positive-penalty guard currently exists. | At 22 or fewer Persons, a nominal adjusted penalty cannot support automatic model selection. | Display with an explicit warning if desired, but set `SABICSelectable = FALSE` at `Persons <= 22`. |
| IC weights | Current help calls normalized IC weights model probabilities. | Candidate-set weights can be mistaken for unconditional posterior probabilities. | Describe them as relative candidate-set weights only; no probability-of-truth language. |

## M2 IC work order

1. Keep the exact arithmetic and policy fixtures in
   `ic-contract-fixtures-0.2.3.csv` independent of fitted package objects.
2. Use `ic-contract-audit-0.2.3.R` to verify the fixture registry and to show
   that an unmodified 0.2.2 object does not satisfy the new surface contract.
3. Implement one internal IC builder used by fit summaries, comparison,
   reports, and external normalization; do not duplicate formulas.
4. Add independent free-dimension fixtures for RSM, PCM, bounded GPCM,
   interactions, anchors, dummy facets, and latent regression.
5. Add unit/non-unit weight, JML, legacy-object, same-data, stored-value,
   constraint-signature, and integration-identity negative tests.
6. Only then run the quadrature/QMC ladder pilot and freeze
   `IC-INTEGRATION-TOL`.

The arithmetic fixtures are structural checks. They do not calibrate
`IC-INTEGRATION-TOL`, validate TAM or ConQuest likelihood constants, or
authorize a dimensionality decision.
