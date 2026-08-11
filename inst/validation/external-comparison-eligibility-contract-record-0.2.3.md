# External-comparison metric eligibility contract

Status: deterministic structural evidence under review for release-spine row 64
`metric_specific_comparison_eligibility`, 2026-08-11. This record does not
close row 64, run an external program, compare numerical estimates, define a
tolerance, freeze a candidate, authorize a pilot, or promote an equivalence
claim.

## Decision

The repository now has one fail-closed row-level contract for deciding whether
an external result may enter a particular metric aggregate. The unit of the
decision is not a whole fit or software family. It is the exact combination of
scenario, program, expected family, estimator, correction mode, metric, and
parameter class.

The structural contract passes its deterministic accepted and rejected
fixtures and always derives `IncludeInAggregate` from eligibility. A caller's
pre-existing inclusion flag is overwritten. The checklist evidence status
therefore moves from `not_run` to `review`, not `ok`: ConQuest, FACETS, TAM,
and immer normalizers still have to populate this schema from bound external
outputs before the WP7 new-seed pilot can use it.

## Required identity axes

An observed, successful row is eligible only when it has a finite metric value
and independently establishes all of the following:

1. expected versus observed model family, estimator, and correction mode;
2. identical observation set and weights;
3. identical active facets and sign/orientation convention;
4. compatible category map and step dimension;
5. compatible anchor, constraint, and coordinate conventions; and
6. explicit identification, conditioning, and boundary conventions.

Each dimension has only four structural states: `match`, `not_applicable`,
`mismatch`, or `unknown`. Both `mismatch` and `unknown` reject an otherwise
observed successful row. `not_applicable` must be explicit; a blank never
silently behaves as agreement.

## Dispositions and denominators

The contract applies this precedence:

| Disposition | Meaning | Included in aggregate |
| --- | --- | --- |
| `unexpected` | An observed row has no expected registry row. | No |
| `missing` | An expected row has no observed result. | No |
| `failed` | The expected row was observed but its external fit failed. | No |
| `rejected` | The fit succeeded but at least one identity axis or metric value is invalid. | No |
| `eligible` | Every required axis matches or is explicitly not applicable and the value is finite. | Yes |

Every exact stratum reports expected, eligible, rejected, missing, failed,
unexpected, included, and ineligible-included row counts. Expected-row
accounting must satisfy

`expected = eligible + rejected + missing + failed`.

Unexpected rows are reported separately because they are outside the expected
denominator. A row may have several rejection reasons, so reason counts are
diagnostic counts and need not sum to the rejected-row count. A companion
reason-count table retains the same exact stratum keys, disposition, reason
code, and row count. The aggregate is computed only from finite eligible
values and must contain zero ineligible rows.

## Deterministic fixture result

The 20-row fixture spans all four retained external-program families. It
contains four eligible rows, 13 rejected rows, one missing row, one failed row,
and one unexpected row. Every identity axis has an explicit negative fixture.
In the common ConQuest stratum, four expected rows partition exactly into one
eligible, one rejected, one missing, and one failed row; one additional
unexpected row is reported outside that denominator. Although the rejected
ConQuest value is finite and much larger than the eligible value, the reported
aggregate is exactly the eligible value, 0.10.

The FACETS common stratum similarly contains one eligible and ten rejected
rows. Its aggregate is 0.05, proving that finite contract failures do not
enter the result. Reversing input order leaves the row ledger, denominator
table, and reason ledger identical. Missing schema columns, duplicate row IDs,
unknown software families, and unrecognized status vocabulary fail closed.

## Source binding and tests

| Artifact | SHA-256 |
| --- | --- |
| `external-comparison-eligibility-contract-0.2.3.R` | `0d6344322e386cfab1ad36d36806d353c3dc428a22e26664c86f532610c487c4` |
| `external-comparison-eligibility-fixtures-0.2.3.csv` | `7bf3af467bfa494872f3aa3eb3ecf604024a4a07fc5877c50824c2a6a31d2392` |
| `test-external-comparison-eligibility-contract.R` | `8c17ad7cd49317134a42d869a7fbbc48e3a89f7b92dae7305197ad4c7feee0e5` |

Forty-two expectations cover exact fixture dispositions and reason codes,
denominator arithmetic, finite rejected-value exclusion, input-order
invariance, stratum and reason-count isolation, malformed-registry rejection,
caller-supplied inclusion-flag replacement, and source binding.

## Residual work before closure

Row 64 can move to `ok` only after each actual external normalizer constructs
the expected registry before reading results, populates every identity axis
from bound input/output metadata, and routes every bias, RMSE, coverage, rank,
facet-separation, and convergence aggregate through this contract. Because
FACETS is unavailable in the current environment, the first actual adapter
binding is the available ConQuest core; it must retain the unresolved
prospective tolerance boundary. TAM/immer follow with separate estimator and
correction strata. FACETS may enter only through a future portable bundle
created in a licensed environment, and its historical 4.5.0 pilot or an
unavailable-engine placeholder cannot become eligible. No WP7 FACETS new-seed
pilot should start before that bundle and row 59 tool identity are resolved.
