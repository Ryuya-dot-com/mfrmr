# ConQuest reported-output precision contract record for mfrmr 0.2.3

Status: exact reported-decimal stratum defined and source-bound, 2026-08-12.
The hidden ConQuest optimizer solution remains unresolved. No tolerance,
candidate comparison, scientific equivalence, or confirmation is authorized.

## Decision

ConQuest 5.47.5 writes finite decimal tokens to its native files, but the
manual does not state the file-output rounding rule or expose the unprinted
optimizer precision. These are two different comparison targets and must not
share one readiness flag.

For a valid token, the contract removes insignificant trailing zeros and
represents its exact decimal value as

`coefficient * 10^exponent`.

Thus `1.2300`, `1.23`, and `123e-2` have the same exact reported-output
identity, `123e-2`. This is an identity of the file token, not a claim about
the interval containing ConQuest's hidden optimizer solution.

The two strata are:

| Stratum | Source-precision status | Eligible rows | What remains open |
| --- | --- | ---: | --- |
| Exact reported decimal | `match` | 36 | tolerance, candidate identity, comparison, equivalence |
| Hidden optimizer solution | unresolved | 0 | file rounding rule or a full-precision export |

The reported-output metric is explicitly
`absolute_difference_to_exact_reported_decimal`. A future tolerance using this
metric must include file-reporting resolution in its interpretation and cannot
be relabelled as hidden-solution equivalence.

## Manual evidence

The SHA-bound `/Applications/ConQuest/conquestManual.pdf` was text-searched and
PDF page 394 was rendered and inspected visually. The page documents that
`decimals=n` controls printing to the screen and is ignored for file outputs.
It does not document a file rounding mode, a hidden-precision interval, or a
full-precision export guarantee.

| Field | Value |
| --- | --- |
| Manual SHA-256 | `60bce1a39f5430fd304178356fb943721f9f72c0ddee70a9866c28c87017459f` |
| Inspected PDF page | `394` |
| Screen `decimals` applies to files | `FALSE` |
| File rounding rule documented | `FALSE` |
| Hidden precision documented | `FALSE` |

## Retained four-arm result

The contract re-reads the final regression, covariance, parameter, and history
tokens for the retained RSM/PCM q31/q61 arms. Each row binds its source-file
SHA-256, lexical token, canonical exact decimal, numeric value, mfrmr reference
value, and signed/absolute reported difference. All 36 reviewed coordinates
agree exactly with the native values previously parsed by the four-arm
reviewer. The canonical row-content SHA-256 is
`ecd3fd026e43c44d072b4975c5ea5d323ea3f53eef83ebc2ea41e2cb55de852d`.

The common normalizer now has two deliberate modes. Its default preserves the
old hidden-solution interpretation and rejects all 36 rows. Supplying the
validated reported-output policy admits all 36 rows only to the reported-
decimal stratum and returns
`conquest_reported_output_rows_eligible_candidate_tolerance_missing`.

## Fail-closed controls

Tests reject invalid decimal grammar, changed lexical tokens, changed canonical
identities, changed file hashes, duplicate or missing coordinates, policy-ID
drift, and any attempt to promote hidden-solution equivalence. The prospective
tolerance binding now requires policy
`conquest-reported-decimal-estimand-v1`, scope `exact_reported_decimal`, and
`HiddenSolutionEquivalenceEligible = FALSE`.

## Source binding

| Artifact | SHA-256 |
| --- | --- |
| `conquest-reported-output-precision-contract-0.2.3.R` | `e0e80ebd96c48634ddd39231959bb0c5cfcd6c036c39c4e5bf8224e19164fd53` |
| `test-conquest-reported-output-precision-contract.R` | `adc3e2f2fb7c5ce701b8de934d38819678ac1212a527b41924dfb0f44bab4359` |
| `conquest-external-comparison-normalizer-0.2.3.R` | `4ad1d05c4a463e10ca334f2a7512f25389f9bc9dcecffecb8d390e491177a8b4` |

The focused contract test completed with 39 passing expectations. The complete
ConQuest-labelled slice completed with 594 expectations, zero failures, zero
errors, zero skips, and zero warnings. A clean source tarball including built
vignettes passed `R CMD check --no-manual` with `Status: OK`.

## Machine disposition

| Field | Value |
| --- | --- |
| `ReportedOutputPrecisionPolicyFrozen` | `TRUE` |
| `ReportedOutputEstimandReady` | `TRUE` |
| `ReportedOutputRowsStructurallyEligible` | `36` |
| `HiddenSolutionIntervalAvailable` | `FALSE` |
| `HiddenSolutionEquivalenceEligible` | `FALSE` |
| `ToleranceFrozen` | `FALSE` |
| `CandidateBound` | `FALSE` |
| `ComparisonReady` | `FALSE` |
| `ScientificEquivalenceInferred` | `FALSE` |
| `ConfirmationAuthorized` | `FALSE` |
