# ConQuest additive MFRM microcase contract for 0.2.3

Status: repository-only no-fit Wave C design, 2026-08-11. It does not execute
ConQuest, fit mfrmr, freeze a tolerance, bind a release candidate, or establish
external equivalence.

## Matched estimand

For Person `p`, Rater `r`, Criterion `c`, and category `k = 0,...,3`, the
prospective common probability is

`P(Y_prc = k | theta_p) proportional to exp(k * (theta_p - rho_r - delta_c) - sum_{h=1}^k tau_ch)`.

The RSM restriction is `tau_ch = tau_h`; PCM uses Criterion-specific
`tau_ch`. The identification contract is

- `sum_r rho_r = 0`;
- `sum_c delta_c = 0`;
- `sum_h tau_h = 0` for RSM; and
- `sum_h tau_ch = 0` separately for every Criterion in PCM.

The population model is
`theta_p | X_p ~ Normal(beta_0 + beta_1 X_p, sigma^2)`.
ConQuest syntax is `rater + criterion + step` for RSM and
`rater + criterion + criterion*step` for PCM. This mapping is supported by the
5.47.5 manual's multifacet tutorial and model-command reference, but the native
parameter order was not assumed: the native run exported and verified the
`amatrix` before coordinate comparison.

## Fixed complete-crossing design

| Property | Value |
| --- | ---: |
| Persons | 96 |
| observations per Person | 4 |
| Raters | 2 |
| Criteria | 2 |
| categories | 4 (`0:3`) |
| total observations | 384 |
| observed Person-by-Rater-by-Criterion cells | 100% |
| RSM free dimension | 7 |
| PCM free dimension | 9 |

The deterministic fixture is generated once with seed `20260846`. Its numeric
latent-regression covariate has two balanced levels, `-1` and `1`. All 16
Rater-by-Criterion-by-category cells are nonempty; no Person has all minimum or
all maximum responses. RSM and PCM q=31/q=61 arms receive byte-identical input.
The q=61 arms are integration sensitivity, not a preferred-result search.
The 2-by-2 facet design is deliberate: an earlier 3-by-4 draft implied
`96 * 4^12` all-response-pattern evaluations under the current strict MML
estimability audit and therefore manufactured a readiness NO-GO unrelated to
cross-engine equivalence. The reduced design retains both facet constraints
while reducing the facet response space to `4^4 = 256` patterns. The balanced
two-level covariate yields only two distinct Person designs, so exact reuse
reduces the actual strict audit to `2 * 4^4 = 512` pattern/design evaluations.

The dimensions are counted independently as follows:

- two population regression coefficients plus one variance;
- one free Rater effect from two levels;
- one free Criterion effect from two levels;
- two shared free steps for RSM; or
- two free steps within each of two Criteria for PCM.

Thus `3 + 1 + 1 + 2 = 7` and `3 + 1 + 1 + 4 = 9`.

## Required external handoff

Every future arm must retain the complete console stream and native parameter,
design-matrix, regression, covariance, case-EAP, and matrixout-history files.
Before numeric conversion it must apply
`mfrmr_conquest_numeric_resolution_v1`, retaining raw tokens and file SHA-256.
The following checks are conjunctive:

1. exact input, command, executable, version, manual, source, and candidate
   identities;
2. model term, response ordering, category map, latent regression, constraints,
   nodes, stopping controls, termination reason, and complete denominator;
3. native `amatrix` reconstruction of Rater, Criterion, and step coordinates;
4. matrixout final-vector agreement with native exports;
5. common-vector probability and observed-data objective reconstruction;
6. independent q=31/q=61 integration assessment;
7. separate lexical, reported-resolution, prespecified-tolerance, and
   scientific decisions; and
8. review-only handling of any failed, incomplete, or resolution-limited arm.

## Base-design and augmented decisions

`mfrmr_validate_conquest_additive_design()` returns
`no_go_design_only`. The mathematical/input design is ready, but candidate
identity, source-bound mfrmr reference fits, native design matrices, and an
external execution decision are deliberately absent from the base no-fit
artifact. The separate source-bound reference preflight completed the mfrmr fit,
probability-oracle, and marginal-likelihood-oracle layer without changing this
base decision. Its augmented decision is
`no_go_native_matrix_and_candidate_missing` when considered alone.

The external four-arm review has now observed exact RSM/PCM native A matrices,
completed q31/q61 outputs, and raw tokens. Its combined decision is
`four_arm_native_outputs_ready_tolerance_and_candidate_missing`. Candidate
identity, a prespecified tolerance, and scientific equivalence remain absent.
The connected sparse and unequal-workload case remains separate and downstream
of a candidate-bound complete-crossing core.
