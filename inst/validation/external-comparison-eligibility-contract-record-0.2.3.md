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
scenario, program, expected family, estimator, correction mode, penalty mode,
finite-parameter-box contract, metric, and parameter class.

The structural contract passes its deterministic accepted and rejected
fixtures and always derives `IncludeInAggregate` from eligibility. A caller's
pre-existing inclusion flag is overwritten. The checklist evidence status
therefore remains `review`, not `ok`: ConQuest, FACETS, TAM, immer, and sirt
normalizers still have to populate this schema from bound external outputs
before the WP7 new-seed pilot can use it.

## Required identity axes

An observed, successful row is eligible only when it has a finite metric value
and independently establishes all of the following:

1. expected versus observed model family, estimator, correction mode,
   statistical-penalty mode, and finite-parameter-box contract;
2. identical observation set and weights;
3. identical active facets and sign/orientation convention;
4. compatible category map and step dimension;
5. compatible anchor, constraint, and coordinate conventions;
6. explicit identification, conditioning, and boundary conventions; and
7. use of a source whose retained numerical precision is adequate for the
   metric, rather than an unlabelled screen- or report-rounded value.

Each dimension has only four structural states: `match`, `not_applicable`,
`mismatch`, or `unknown`. Both `mismatch` and `unknown` reject an otherwise
observed successful row. `not_applicable` must be explicit; a blank never
silently behaves as agreement.

## Source- and version-bound estimator audit

The installed help pages, formal arguments, and loaded function bodies were
checked on 2026-08-11. These identities describe the local comparison
environment; future package versions require a new audit.

| Route | Local version and documented default | Contract consequence |
| --- | --- | --- |
| mfrmr GPCM JML | Development 0.2.3: `unpenalized_identified_jml`, no statistical penalty, no finite parameter box, typed post-fit recession policy. | Expected `PenaltyMode = none` and `FiniteParameterBox = none`; finite optimizer traces cannot be substituted for typed primary boundary results. |
| `TAM::tam.jml()` | TAM 4.3-25: `adj = 0.3` adjusts zero/maximum scores and `bias = TRUE` multiplies estimated item parameters by `(I - 1) / I`. | Raw, extreme-adjusted, classically bias-corrected, and combined modes remain different `CorrectionMode` strata even though all use JML. |
| `immer::immer_jml()` | immer 1.5-13: `est_method = "eps_adj"`, `eps = 0.3`; alternatives are `"jml"` and `"jml_bc"`. | Each mode receives its own correction identity; `"jml"` still has its documented extreme-score handling and must not be inferred from the function name alone. |
| `sirt::rm.facets()` | sirt 4.2-133: marginal rater-facets model on `theta.k = seq(-9, 9, length = 30)`; optional item/rater slopes are product-centred and are estimated within `a_lower = 0.05`, `a_upper = 10`. | Equal-discrimination PCM is a possible structural comparison lane. Default free-slope GPCM is rejected as an exact mfrmr match by `FiniteParameterBox` before numeric aggregation; the general item-by-rater product-slope model also remains a different family. |

`SourcePrecisionStatus = match` requires native in-memory values or documented
machine-readable exports with adequate retained digits. Values copied from
rounded console output, PDF, or a display table are `mismatch` or `unknown`
until a rounding-aware error budget is prespecified. A small printed difference
cannot pass this structural check by choosing a tolerance after inspection.

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

The 25-row fixture spans all five retained external-program families. It
contains five eligible rows, 17 rejected rows, one missing row, one failed row,
and one unexpected row. Every identity axis has an explicit negative fixture.
In the common ConQuest stratum, four expected rows partition exactly into one
eligible, one rejected, one missing, and one failed row; one additional
unexpected row is reported outside that denominator. Although the rejected
ConQuest value is finite and much larger than the eligible value, the reported
aggregate is exactly the eligible value, 0.10.

The FACETS common stratum similarly contains one eligible and 12 rejected
rows. Its aggregate is 0.05, proving that finite contract failures do not
enter the result. The sirt fixtures admit an equal-discrimination PCM/MML row
but reject the otherwise matched free-slope GPCM row because its documented
`0.05--10` slope box differs from mfrmr's parameter space. Reversing input
order leaves the row ledger, denominator table, and reason ledger identical.
Missing schema columns, duplicate row IDs, unknown software families, and
unrecognized status vocabulary fail closed.

## Source binding and tests

| Artifact | SHA-256 |
| --- | --- |
| `external-comparison-eligibility-contract-0.2.3.R` | `934ddd21aac7ba1ddd28879d9aa5af5e6de5a85f40bbc05579988bf57eefb5e3` |
| `external-comparison-eligibility-fixtures-0.2.3.csv` | `d8a37c2cfb29d7ef1fb1493e0eb84adefe3fb88aecbc76296f8f61002a58372d` |
| `test-external-comparison-eligibility-contract.R` | `ed62d61cb928e3a46b717844a9e8ed5a8b4158d921896e12f1eaa2ad4996fc9e` |

The deterministic tests cover exact fixture dispositions and reason codes,
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
correction strata. The sirt lane begins with equal-discrimination and item-only
GPCM structural mappings, but its finite slope bounds and product-slope rater
model must stay explicit. FACETS may enter only through a future portable bundle
created in a licensed environment, and its historical 4.5.0 pilot or an
unavailable-engine placeholder cannot become eligible. No WP7 FACETS new-seed
pilot should start before that bundle and row 59 tool identity are resolved.
