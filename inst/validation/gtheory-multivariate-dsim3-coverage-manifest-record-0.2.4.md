# D-SIM-3 v4 outcome-blind coverage-manifest record

Status: coverage manifest complete; execution contract frozen and qualification audited, response generation closed
Date: 2026-08-30
Contract: `MFRMR-GTHEORY-MV-DSIM3-COVERAGE-V1`
Parent D-SIM-2 contract hash: `5202fcbe1975c3fc898f557b06c50f6fdcbb1cd248b745eb4500d42b163d960b`
Parent D-SIM-2 observed run hash: `ff30e8e4ea321b18476eb031f4d43ccd3029f9f286c1b362ff656dad4bb658bc`
Contract hash: `39b4b542f3afe617cc8f2912a23aa4211790460c8765d4ad38f9cd95575c508f`
Manifest hash: `4c6958f00aac7598d777387ec113cd43474031430492e83e6183d19dcedf7197`

## Purpose and unit of coverage

D-SIM-3 freezes an outcome-blind coverage design before any multiverse
response exists. Its 21 scenario rows are **design cells**, not generated or
independent datasets. The generated-dataset count is exactly zero.

The v4 estimand and route axes are not crossed as new datasets:

- 12 dataset-generating axes select the scenario profiles;
- `ABS-PHI` and `REL-G` are two separate, nonvoting projections over each
  scenario, giving 42 estimand-projection rows; and
- five analysis routes are qualification projections over each scenario,
  giving 105 route-projection rows.

This distinction prevents the presence of multiple facets, outcomes, G/Phi
estimands, or backend routes from being miscounted as latent dimensions or
independent simulated samples.

## Frozen coverage result

The canonical registry contains one full multivariate anchor, one fixed
one-stratum closure profile, and 19 multivariate coverage profiles. The
profiles were selected without outcomes and are now explicit data in the
contract implementation rather than recomputed by an exploratory optimizer.
Every replay audits the frozen profiles against the v4 level and pair universe.

| Quantity | Count | Disposition |
|---|---:|---|
| v4 axes | 14 | 12 dataset-generating; 2 projected |
| v4 levels | 44 | 44 covered |
| dataset design cells | 21 | frozen; none executed |
| generated datasets | 0 | response generation closed |
| estimand projections | 42 | two per design cell; no voting |
| route projections | 105 | five per design cell; no dataset multiplication |
| possible dataset-axis level pairs | 626 | audited structurally |
| feasible dataset-axis level pairs | 603 | 603 covered |
| excluded structural pairs | 23 | all reason-coded |
| negative controls | 3 | registered; none executed |

The 23 exclusions arise only from the rule that `stratum_count = one` is a
single fixed univariate closure profile, not another stress factor to cross
with multivariate sharing, missingness, covariance, or distribution levels.
Every excluded pair is labelled
`one_stratum_reserved_for_fixed_univariate_closure`.

Coverage roles are complete for all 20 `all`, six `pairwise`, nine `targeted`,
seven `boundary`, one `closure`, and one `negative_control` level. Coverage of
a role means that its declared level appears in the frozen design or the
appropriate projection; it is not a vote or a claim that each row is a new
dataset.

## Controls and route qualification

The manifest keeps three controls distinct:

1. naive pooling is an estimand-invalid analysis-route control;
2. disconnected incidence must be rejected before fitting; and
3. an indefinite covariance must be rejected before fitting.

The other route rows record only conditional representability or the need for
a design-specific/custom covariance contract. No route is selected for
execution, and no route count promotes maturity.

## Readiness boundary

The manifest permitted only the next design action: freeze a separate D-SIM-3
exploratory execution contract. That contract subsequently bound two isolated
855-band identities per cell, 42 dataset attempts, 210 route units, 420 route-
estimand coordinates, terminal-state denominators, and resource limits. It
remains unopened. The subsequent qualification audit found that a shared typed
semantic execution substrate is required before full-profile execution can be
considered. Its typed design-compiler layer subsequently qualified all 21
profiles without responses, and the next shared layer bound 84/84 PSD
component factors and 21/21 response-kernel contracts. A third shared layer
subsequently generated and replayed one nonreserved shadow fixture for every
profile. A fourth shared layer then qualified 50/50 route admissions and all
13 terminal semantics, retaining 181 exactly-once current receipts and 92
correctly open units. Resource enforcement and reserved execution remain open.

Still false are response generation, RNG access, fitting, exploratory
execution, recovery evidence, simulation validation, reference validation,
inference, decision, and public support. Overall feature maturity therefore
remains `specified`; the next action is five-scope resource-controller
qualification without opening 855 or calling a backend.
