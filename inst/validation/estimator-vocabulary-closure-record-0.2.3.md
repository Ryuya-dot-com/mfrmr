# Estimator-vocabulary structural closure for 0.2.3

Status: release-spine row 71 structural closure, 2026-08-11. This record closes
only `estimator_vocabulary`. It does not assert equal maturity of MML and JML,
establish external-engine equivalence, add an MMLE method, close ecosystem
positioning, or bind the eventual release candidate.

## Contract

The public fitting vocabulary has exactly two canonical estimator labels:

- `MML` for marginal maximum likelihood; and
- `JML` for joint maximum likelihood.

`JMLE` is accepted only as a backward-compatible input alias for `JML`. It is
normalized before a newly fitted object is constructed. `MMLE` may occur as a
statistical abbreviation in explanatory prose, but it is not an accepted
`fit_mfrm()` method value or a third package method label. Internal fields such
as `MMLEngineUsed` name an MML computational engine and do not create an MMLE
estimator route.

## Gap found and corrected

New `method = "JMLE"` fits already stored `JML` in the fit summary, resolved
method, replay inputs, and configuration. A legacy or manually reconstructed
object could nevertheless retain `JMLE` in `summary$MethodUsed`,
`config$method`, `config$method_input`, or `config$replay_inputs$method`.
Before this closure, summary, manifest, or replay generation could re-expose
one of those legacy strings.

Public summary construction now canonicalizes both `Method` and `MethodUsed`.
Manifest and replay construction independently canonicalize their method
input and resolved-method fields. This is an output-boundary normalization;
it changes no likelihood, optimizer, estimate, covariance, or readiness
decision.

## Deterministic audit

The focused audit verifies:

1. ordinary `JML` and alias-input `JMLE` fits have identical parameter and
   log-likelihood results;
2. a deliberately mutated legacy object containing `JMLE` in all retained
   method fields produces `JML` in summary, console, manifest, and replay
   output;
3. the generated replay call contains `method = "JML"`, never
   `method = "JMLE"`;
4. public help presents `MML` and `JML` as canonical and describes `JMLE` as a
   compatibility alias; and
5. no public document contains standalone `MMLE` or `method = "MMLE"`.

Both focused test files pass with zero failures, warnings, or skips under the
normal compiled package load. A compile-disabled trial was not used as
evidence because its expected C++ symbols were unavailable.

## Bound development sources

| Artifact | SHA-256 |
| --- | --- |
| `../../R/utils-method-labels.R` | `8c18e671864d719eb0eb988ce077e2d6bbe80dfc5106b8fe1ba64726f8a1810f` |
| `../../R/api-estimation.R` | `a1a78c3ac18274b56c8583ba298799acb829f66f1ce3a82b89576a49efd5705e` |
| `../../R/api-methods.R` | `cd95351a8d4ec93b771d5946e45646af1852fcfa4dd3914031abf15654e0c42d` |
| `../../R/api-export-bundles.R` | `cd364b63a032b149f27e080c66e51223bee1bef19907d555e005e9f5a0798d91` |
| `../../tests/testthat/test-compatibility-aliases.R` | `1636b7d665834d285ac6af137681d7598e2f16ba34f71bfac3de1c6d5aa5f820` |
| `../../tests/testthat/test-documentation-terminology.R` | `49fa0cd77c121a2e96085f80cc142cc7f7d5f008d111484c043444b5f085ebca` |

These are development-source identities. Wave E must still rerun the tests
against the exact candidate, but no estimator-vocabulary calibration or
simulation is required.

## Decision

Checklist row 71 changes from `not_run` to `ok`. The criterion is
`frozen_structural`, every accepted alias resolves to a canonical label, and
the newly covered legacy surfaces fail closed to `JML` rather than preserving
an ambiguous third method state.

Rows 72--76 remain open. In particular, vocabulary closure does not prove
ecosystem positioning, current/future scope alignment, unsupported-route
coverage, or candidate-bound support-envelope completeness.
