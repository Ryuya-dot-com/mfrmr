# MML metamorphic grid record for mfrmr 0.2.3

Status: repository-only draft.45 pilot evidence, 2026-08-05. This record is
calibration evidence. It does not freeze the screening tolerances, authorize
confirmation, establish recovery or coverage, or validate an external-software
comparison.

## Decision

The prespecified RSM/PCM/GPCM MML grid passed 30 of 30 semantic-equivalence
comparisons under the public production convergence controls used by this
pilot (`maxit = 400`, `reltol = 1e-9`) and a seven-point screening quadrature.
Every comparison retained the same effective observations, matched every
semantic output key, reached `NumericalState = ready` in both fits, preserved
the model-result status fields, and stayed inside all pilot screening
tolerances.

This closes the small-design MML metamorphic slice of WP6. It does not close
target-size sparse performance, JML property testing, serialization/replay,
active latent-regression, interaction, anchor, external-normalization, or
statistical operating-characteristic work.

## Prespecified transformations

One generated four-category crossed dataset (24 Persons, 3 Raters, 3
Criteria, 216 observations) was fitted with RSM, criterion-specific PCM, and
criterion-specific bounded GPCM. Each model was compared under ten
transformations:

1. reversed row order;
2. deterministic row permutation;
3. reordered factors with unused levels;
4. nonlexical Person identifiers;
5. nonlexical Rater and Criterion identifiers;
6. missing outcomes versus explicit row removal;
7. zero weights versus explicit row removal;
8. appended zero-weight rows carrying otherwise unseen levels;
9. permuted positive non-unit weights; and
10. combined missing/zero-weight filtering, identifier changes, factor-level
    changes, and row permutation.

Challenge identifiers were mapped back to the reference semantic IDs before
comparison. Person estimates and posterior SDs, facet estimates, steps,
GPCM log/natural slopes, retained-observation expectations and residual
quantities, log likelihood, deviance, key sets, and readiness states were
checked.

Input provenance was deliberately separated from model-result invariance.
For missing-outcome, zero-weight, appended-zero-level, and combined encodings,
the input/readiness audit is allowed to record the different original input.
It is not allowed to change retained rows, numerical readiness, estimability,
category/boundary/numerical result states, or fitted quantities. Twelve model
comparisons therefore had an expected provenance difference while all 30 had
equal retained-row counts and result statuses.

## Pilot criteria and results

The thresholds are screening inputs with state
`pilot_required_not_frozen`, not release criteria:

| Quantity class | Pilot tolerance | Maximum observed RSM | Maximum observed PCM | Maximum observed GPCM |
| --- | ---: | ---: | ---: | ---: |
| objective (`LogLik`, `Deviance`) | `1e-6` | `6.093615e-11` | `4.720846e-10` | `3.112007e-09` |
| parameter | `5e-5` | `1.664461e-06` | `6.306872e-06` | `1.862395e-05` |
| retained-observation quantity | `5e-5` | `1.792162e-06` | `3.271013e-06` | `6.113984e-06` |

The authoritative v3 bundle contains 30 comparison rows and 380 metric rows.
It has zero fit errors, zero captured warnings, zero key-set failures, zero
non-ready numerical pairs, and zero pilot-screen failures. Every manifest and
result row retains `ConfirmationAuthorized = FALSE`.

## Adversarial convergence control

An initial v1 execution used `maxit = 100` and `reltol = 1e-7`. It completed
but passed only 25 of 30 comparisons. All five failures involved non-Person
facet relabelling; the largest retained-observation difference was about
`6.66e-4`. Both members of those pairs had optimizer code zero but
`NumericalState = review` because their terminal gradients exceeded the
common readiness tolerance.

The failure was not resolved by widening a metamorphic tolerance. The runner
was corrected to use the public production defaults, which activate the
bounded gradient-polish path, and to require both fits to have
`NumericalState = ready`. Under those controls the relabelling pairs passed
without warnings. A subsequent evidence-integrity review made duplicate model
requests idempotent and required a previously nonexistent output directory so
an older bundle cannot be overwritten. The authoritative v3 rerun reproduced
all v2 metric maxima. The v1 directory is retained only as a superseded
diagnostic showing why optimizer code zero is insufficient; v2 is an
intermediate pre-overwrite-guard bundle.

## Evidence identity

The authoritative bundle is stored outside the package source tree at
`mfrmr/mml-metamorphic-grid-20260805-v3`. Its identities are:

| Field | SHA-256 |
| --- | --- |
| Declared/selected 30-cell manifest | `889552dc8f5d18f3daa84e1bbfdcbc11b729b5fd2226265a400b14babce9f180` |
| Loaded mfrmr runtime package | `28d3bb9d2a30c519f0d092be2149a819ab4de2dd03c27fb157c09bf7bf4038f8` |
| Capability manifest | `e7448ae6361dc97e367049b89ae3bd68cfa38799dd53fddb2d6596a077e9bada` |
| Metamorphic runner | `2fc9e48a6722a77b2b0b5f95385fd9815533ef93327a38345fe0fa544d3cbefb` |
| Complete execution identity | `f777d9f9fd8a5a26630d947367de324ecb8fdd51afc47c0d89f58f016cc248cb` |
| Result CSV | `1beb612e680780a97481495fbe10c5023bf46c6e9cac7a43b2bd5accba823022` |
| Metric-result CSV | `6683f2b2326ecfd4581bcb9c27b6243e4b0535c873f78fb274e87b4beeed6416` |
| Complete RDS | `ee0b9367a550611a5ad4cfc01a165e7ff3451bef7e321f2dbcfa9e9293ecfcbd` |

The execution used R 4.5.1 on `x86_64-w64-mingw32`, mfrmr 0.2.3, `digest`
0.6.39, `Matrix` 1.7-3, `lpSolve` 5.6.23, and `psych` 2.6.5. The capability
identity is inherited from the draft.44 evidence helpers; absolute paths do
not enter the composite execution hash.

The public package remains the exact previously checked draft.43 payload:

- tarball SHA-256:
  `88EBD28817AD1924A9AE235F56301264D5EC47FD06A9416D6A4BA55C5C59DFA6`;
- `R CMD check --as-cran` log SHA-256:
  `B3956B95ABCB26BDE6D9CBD1A675ED9DE4C5365970B3F86FAEAA0B7FBDB8AA3D`;
- status: `OK`.

The runner, record, protocol tests, and internal roadmap are excluded from the
source-package payload. No public API or package byte changed in draft.45.

## Remaining boundary

This single generated design demonstrates a required software property; it is
not a Monte Carlo operating-characteristic study. The next WP6 work is a
target-size sparse/runtime and memory envelope plus malformed-input and replay
properties. WP7 still requires a prespecified replication/precision design,
new pilot seeds, external normalization, and criterion review. FACETS 4.5.0,
TAM, and immer evidence cannot override a future internal metamorphic failure,
but this pass does not make any external result eligible by itself.
