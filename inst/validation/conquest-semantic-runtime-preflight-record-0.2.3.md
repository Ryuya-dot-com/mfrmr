# ConQuest semantic runtime preflight record for mfrmr 0.2.3

Status: P0 implementation and live data-free sentinel complete; independent
review pending, 2026-08-15.

This record covers C0 runtime semantics only. It does not fit a model, read
assessment data, validate a likelihood, reopen Candidate 003, authorize P2/P3,
or establish scientific equivalence. The executable path is an explicit input
to the preflight and is not a default in the implementation.

## Live observation

The repository preflight was invoked outside the restricted filesystem sandbox
because earlier retained evidence shows that this ConQuest build may fail while
writing settings under the restricted launch context. The isolated working
directory was temporary and was removed by the preflight. The only stdin
command was `quit;`; the expected native-output count was zero.

| Field | Observed value |
| --- | --- |
| Specification | `0.2.3-conquest-semantic-runtime-preflight-v1` |
| Contract | `mfrmr_conquest_semantic_runtime_preflight_v1` |
| Run date | `2026-08-15` |
| Executable path | `/Applications/ConQuest/ConQuest` |
| Executable architecture | `Mach-O 64-bit executable x86_64` |
| Invocation route | `/usr/bin/arch -x86_64 '/Applications/ConQuest/ConQuest'` |
| Locale | `C.UTF-8/C.UTF-8/C.UTF-8/C/C.UTF-8/C.UTF-8` |
| Runtime version | `5.47.5` |
| Runtime edition | `Demonstration Version` |
| Runtime expiry text | `This version expires 1 September 2026` |
| Parsed expiry date | `2026-09-01` |
| Process exit status | `0` |
| Terminal marker present | `TRUE` |
| Registered semantic failures | `0` |
| Expected output count | `0` |
| Complete output set | `TRUE` |
| Command is data-free `quit;` | `TRUE` |
| Model estimation attempted | `FALSE` |
| Model-estimation success | `NA` |
| Semantic status | `runtime_semantic_ready` |
| Scientific comparison authorized | `FALSE` |

The complete non-proprietary console transcript was:

```text
ConQuest version: 5.47.5
Demonstration Version
This version expires 1 September 2026
<End of Program
```

The marker parser deliberately accepts a non-alphanumeric console prompt prefix
before the exact terminal phrase. It does not accept an arbitrary substring or
infer success from exit status alone.

## Deterministic failure controls

Ordinary repository tests use injected runners and stored non-proprietary
transcripts. They do not launch ConQuest. The following controls passed:

| Control | Required primary result | Observed test result |
| --- | --- | --- |
| Executable path unavailable | `runtime_unavailable_or_expired` | Passed |
| Explicit launcher unavailable | `runtime_unavailable_or_expired` | Passed |
| Unknown command with status zero and terminal marker | `semantic_execution_failure` | Passed |
| Missing/unreadable data file with status zero and terminal marker | `semantic_execution_failure` | Passed |
| Missing terminal marker | `semantic_execution_failure` | Passed |
| Incomplete expected output set | `semantic_execution_failure` | Passed |
| Nonzero process status with otherwise clean transcript | `semantic_execution_failure` | Passed |
| Expired demonstration runtime | `runtime_unavailable_or_expired` | Passed |
| Clean data-free transcript | `runtime_semantic_ready` | Passed |

The result schema keeps `RuntimeAvailable`, `SemanticSuccess`,
`ModelEstimationAttempted`, `ModelEstimationSuccess`, and
`ScientificComparisonAuthorized` separate. A clean C0 result therefore cannot
be mistaken for a successful model fit or a comparison result.

## Replacement-runtime rule

A new or otherwise changed ConQuest runtime must first pass this data-free
preflight. If a runtime change is declared, the replacement gate remains closed
until the smallest prospectively frozen numerical sentinel also passes. Passing
both gates makes broader prospective execution eligible; it does not
reclassify prior evidence or infer scientific equivalence. A hash may be
retained as an accidental-replacement alarm, but it is not a C0 pass rule.

The replacement rule is implemented as a pure policy function and is tested in
both blocked (`not_run`) and eligible (`passed`) states. The smallest numerical
sentinel itself belongs to P1/P2 specification work and has not been selected
or run by this preflight.

## Artifacts and independent-review boundary

- `conquest-semantic-runtime-preflight-0.2.3.R` contains the side-effect-free-on-
  source implementation, semantic-error registry, typed result schema,
  non-proprietary fixtures, injectable runner boundary, and replacement gate.
- `test-conquest-semantic-runtime-preflight.R` exercises all controls without
  an installed ConQuest dependency.
- This record preserves the live data-free observation and its scope limits.

P0 is not marked closed. An independent reviewer must still confirm that the C0
failure registry and negative controls fail closed, that the live record agrees
with the typed result, and that ordinary package tests do not require ConQuest.
That review cannot be replaced by the successful live transcript itself and
remains mandatory before evidence promotion or wider execution. The separate
minimum-diagnostic authorization contract permits only the first sealed,
non-interpretive P2 diagnostic after a fresh sentinel and all fatal gates pass;
it does not close P0.
