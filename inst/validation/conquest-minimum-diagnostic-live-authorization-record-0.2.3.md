# ConQuest minimum diagnostic live authorization record for mfrmr 0.2.3

Status: fresh data-free runtime observation and disclosed maintainer audit bound;
all fifteen fatal gates passed; only the exact two-row P2 diagnostic is
execution-authorized, with no evidence promotion, 2026-08-15.

- Specification:
  `0.2.3-conquest-minimum-diagnostic-live-authorization-v1`
- Contract: `mfrmr_conquest_minimum_diagnostic_live_authorization_v1`
- Status: `minimum_P2_diagnostic_live_authorization_active`
- Observation/authorization date: `2026-08-15`
- Run-not-after date: `2026-08-16`
- Executable path: `/Applications/ConQuest/ConQuest`
- Invocation route:
  `/usr/bin/arch -x86_64 '/Applications/ConQuest/ConQuest'`

## Live data-free observation

The explicit current runtime was launched outside the restricted sandbox with
only `quit;` as stdin. No assessment data were read, no model was estimated,
and no native candidate output was requested or created.

| Field | Observed value |
| --- | --- |
| Runtime status | `runtime_semantic_ready` |
| Version | `5.47.5` |
| Edition | `Demonstration Version` |
| Expiry | `2026-09-01` |
| Architecture | `Mach-O 64-bit executable x86_64` |
| Exit status | `0` |
| Terminal marker | `TRUE` |
| Registered semantic failures | `0` |
| Expected native outputs | `0` |
| Complete output set | `TRUE` |
| Model estimation attempted | `FALSE` |
| Scientific comparison authorized by runtime result | `FALSE` |

The non-proprietary transcript was:

```text
ConQuest version: 5.47.5
Demonstration Version
This version expires 1 September 2026
<End of Program
```

## Attestation

The minimum fatal-gate audit was completed as
`Codex maintainer audit 2026-08-15` with reviewer role `maintainer`.
Artifact-author overlap was explicitly declared `TRUE`. The auditor accepted
the exact two-row/q31--q61/4+4 fit cap and accepted that execution produces no
interpretive or confirmation claim. This is not an independent comprehensive
review and is not represented as one.

## Fatal-gate result

| Gate | Passed |
| --- | --- |
| Current runtime semantic sentinel | `TRUE` |
| Runtime not expired on authorization date | `TRUE` |
| Explicit executable path match | `TRUE` |
| P1 semantic and negative-control construction | `TRUE` |
| P2 fixture, matrix, and oracle construction | `TRUE` |
| P2 metric, denominator, and stop construction | `TRUE` |
| Exact two-row slice identity | `TRUE` |
| Candidate-output boundary empty | `TRUE` |
| Ordinary tests external-runtime-free | `TRUE` |
| Worktree clean before authorization | `TRUE` |
| Exact q and fit cap accepted | `TRUE` |
| Auditor identity present | `TRUE` |
| Author overlap explicitly declared | `TRUE` |
| No-interpretive-claim condition accepted | `TRUE` |
| Minimum fatal-gate checklist complete | `TRUE` |

## Authority boundary

| Authority | Value |
| --- | --- |
| `AllFifteenFatalGatesPassed` | `TRUE` |
| `SmallestP2DiagnosticExecutionAuthorized` | `TRUE` |
| `P0Closed` | `FALSE` |
| `P1Closed` | `FALSE` |
| `IndependentComprehensiveReviewPassed` | `FALSE` |
| `EvidencePromotionAuthorized` | `FALSE` |
| `WiderExecutionAuthorized` | `FALSE` |
| `P3ExecutionAuthorized` | `FALSE` |
| `PublicClaimAuthorized` | `FALSE` |
| `ScientificEquivalenceInferred` | `FALSE` |

Authorization covers only:

- `P2-RSM-CONNECTED-MULTIBRIDGE`, q31 and q61; and
- `P2-PCM-CONNECTED-MULTIBRIDGE`, q31 and q61.

This is four ConQuest fits and four mfrmr fits. No fifth fit, q121, substitute
row, rerun selected by observed results, P3 row, or replication is authorized.
The authorization becomes inactive after `2026-08-16`; a later run requires a
new data-free sentinel and binding.

## Next action

The next admissible action is to implement and dry-test an execution harness
that consumes this exact live authorization, creates one new isolated output
directory, refuses pre-existing files, writes unique prefixes for all four
ConQuest fits, and retains every expected success or failure outcome. The
harness itself must be reviewed and committed before the first model fit.

Native output remains diagnostic until independent post-output review. No hash
is a scientific acceptance criterion, and no public README or NEWS claim follows
from this authorization.
