# 0.2.3 conditional-fallback coverage audit

Status: completed deterministic source/public-surface audit, 2026-08-11.
This record changes no evidence status, promotes no conditional claim, and
authorizes no simulation, external-program run, confirmation, candidate
freeze, or release. It audits the nine fallback classes in
`claim-disposition-profile-0.2.3.csv` against the current source tree.

## Decision

All nine conditional fallback classes now have a fail-closed public route.
Seven were already enforced in the relevant decision surfaces. This audit
closed two propagation gaps and corrected one overly restrictive description:

- fitted GPCM boundary tables and fit summaries now expose the exact
  `SlopeOwner` and `StepOwner`, and state that the owner is
  model-conditional discrimination rather than evidence of rater consistency;
- residual-PCA result, summary, and plot payloads now carry machine-readable
  exploratory/non-primary/no-automatic-dimensionality-decision fields; and
- the JML fallback now accurately permits the already-labelled exploratory
  observation-table SEs while continuing to prohibit a profile-likelihood SE,
  finite-item correction, or ordinary corrected-JML interpretation.

No numerical experiment was needed. These are output-contract questions, so
source inspection and deterministic tests are the proportionate evidence.

## Meaning of enforcement

`enforced` does not mean that the conditional claim has passed. It means that
the current public decision route cannot silently promote it while its
evidence row remains incomplete. Raw numerical components may remain visible
when they are explicitly labelled as optimizer traces, native descriptive
fields, screening quantities, or separate method modes. Visibility is not
promotion.

The audit concentrates on claim-bearing surfaces. A generic plot need not
duplicate every fit field, but it must not convert an ineligible parameter or
screen into a primary estimate, formal decision, automatic ranking, dimension
selection, or equivalence conclusion. Exact fit/configuration metadata remain
available for provenance.

## Coverage result

| Fallback | Rows | Result | Enforcing public contract | Residual boundary |
| --- | ---: | --- | --- | --- |
| `retain_jml_point_estimates_and_exploratory_observation_table_se_no_ordinary_uncertainty_adjustment_or_correction` | 1 | `enforced_after_vocabulary_correction` | `fit_mfrm()` keeps JML as its own estimator identity; extreme Persons receive typed extended states; `summary()`/precision output labels JML SEs as exploratory observation-table information; documentation says no `(L-1)/L` correction is applied. | JML structural point estimates remain susceptible to incidental-parameter bias. The fallback is acceptable only for explicitly JML-labelled descriptive/exploratory use. |
| `suppress_gpcm_primary_slope_and_ordinary_uncertainty` | 12 | `enforced` | `mfrmr_readiness_gpcm_slope_parameters()` separates `Primary*` from `Optimizer*`, leaves free slopes non-primary while global status is open, sets `SEEligible=FALSE` and `CIEligible=FALSE`, and the uncertainty builder suppresses ordinary slope SE/CI while retaining labelled optimizer traces. `summary()` reports both bases separately. | Fixed unit slopes and certified extended boundary values retain their typed meanings; neither creates a finite free-slope MLE claim. |
| `disable_automatic_ic_ranking_retain_raw_components` | 2 | `enforced` | `compare_mfrm()` requires the same data, MML method, current consistent IC contract, selectable integration tier/identity, formula and constraint basis, and inference readiness. Otherwise deltas, weights, preferred labels, evidence ratios, and LRT are suppressed while labelled raw components remain. | A future external/common IC claim still needs metric-specific normalizers and candidate-bound integration evidence. |
| `retain_unidimensional_scope_no_dimension_selection_or_subscores` | 10 | `enforced` | The native estimator is one-dimensional; `import_tam_fit()` rejects `ndim != 1`; residual PCA is documented and now machine-labelled as exploratory screening with `DecisionUse=no_automatic_dimensionality_decision`; no public dimension-selection or dimension-specific subscore estimator exists. | External multidimensional challenge evidence may test the adequacy of the one-dimensional scope but cannot be flattened into a native score. |
| `retain_diagnostic_as_exploratory_no_inferential_decision` | 2 | `enforced_after_pca_metadata_gap_closed` | Bias/interaction tables already return `SupportsFormalInference=FALSE`, `PrimaryReportingEligible=FALSE`, and `ReportingUse=screening_only`. Residual-PCA objects, summaries, and all four plot payloads now carry the analogous exploratory/no-decision fields. | Null/non-null operating characteristics remain necessary before any design-specific diagnostic promotion or cutoff claim. |
| `exclude_secondary_external_numeric_aggregation` | 2 | `enforced` | `import_tam_fit()` accepts only unidimensional TAM MML and marks native IC values descriptive/ineligible for `compare_mfrm()`. TAM JML is rejected from that importer. Repository TAM/immer work preserves raw, adjusted, bias-corrected, CML/CCML, package-version, and method-mode identities separately; the contracts prohibit pooling or voting among programs. | TAM/immer remain useful estimator-convention and adversarial references, not a second vote that can override retained-core evidence. |
| `disable_rater_owned_gpcm_primary_route` | 1 | `enforced_after_owner_propagation_gap_closed` | Free GPCM slopes are already non-primary regardless of owner. Fit summaries now show exact owner fields and the non-consistency interpretation. `gpcm_capability_boundary_table()` adds the same owner, primary-slope, and uncertainty status to the central boundary object reused by APA, QC, manifest, export, DFF, linking, and related bundles. | The aligned rater-owned likelihood remains callable with caveats, but rater consistency, recovery, support, and uncertainty claims remain unavailable until their own gate passes. |
| `retain_gpcm_fit_as_exploratory_no_decision` | 1 | `enforced` | The GPCM capability registry labels residual/infit/outfit-like results exploratory, keeps free-slope readiness open, and routes reporting/export bundles through `gpcm_boundary`; fit summaries separate primary values from optimizer traces. | Fitted probabilities and supported descriptive plots may be used, but no universal fit cutoff or automatic model-fit conclusion is validated. |
| `disable_gpcm_dff_inferential_promotion` | 1 | `enforced` | `analyze_dff()` and related tables label results screening/descriptive, set formal and primary eligibility false, prohibit ETS classification, and attach the GPCM boundary. Refit contrasts retain linking and plug-in limitations. | Uniform/nonuniform DFF operating characteristics, multiplicity, linking uncertainty, and owner-specific attribution remain open. |

## Surface audit

| Surface | Audit result |
| --- | --- |
| fit/configuration | Estimator, GPCM owner, parameter readiness, and external-source identity remain explicit; unsupported dimensions and imported estimator relabelling fail closed. |
| summary/print | JML precision basis, GPCM primary-versus-optimizer slope status, exact slope/step owner, and screening status are visible. |
| plot | Residual-PCA plot payloads now retain exploratory and no-automatic-decision metadata; GPCM plots remain within the capability registry's stated fitted/descriptive boundary. |
| export/report | Central `gpcm_boundary` propagation covers fit-based APA, QC, manifest, replay, export, score-side, DFF, and linked review bundles; raw external modes remain labelled and separate. |
| capability/documentation | `gpcm_capability_matrix()`, import documentation, IC documentation, JML estimator documentation, residual-PCA documentation, and the model-family ladder state the corresponding boundary. |

## Tests and non-actions

The focused GPCM capability test passes 209 assertions. The output-stability
test exercises the fit-summary owner fields and residual-PCA result/plot
guards. Profile integrity is checked separately against all 106 checklist
items and the nine fallback codes. No simulation, external engine, reserved
G-theory shard, or release-readiness status mutation is part of this audit.

## Roadmap consequence

The deterministic fallback audit is complete. The next work returns to the
53-row release spine, ordered by decision value:

1. finish deterministic numerical/readiness and public-contract gaps that can
   invalidate many downstream rows;
2. add candidate-bound, raw-token-preserving ConQuest binary/RSM/PCM
   replication and exact additive MFRM microcases;
3. calculate precision only for retained-core recovery cells that remain
   decision-relevant after deterministic and external checks; and
4. proceed to candidate identity and release engineering only after those
   retained claims close.

Conditional simulations remain dormant unless maintainers reject a fallback
for the intended 0.2.3 scope and write down the exact promotion decision and
precision required. Deferred G-theory R0201 remains unexecuted.
