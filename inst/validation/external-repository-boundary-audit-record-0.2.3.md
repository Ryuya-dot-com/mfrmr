# External repository privacy and license boundary audit

Status: deterministic structural closure of release-spine row 66
`external_privacy_and_license_boundary`, 2026-08-11. This record authorizes no
external execution, numerical comparison, tolerance, candidate freeze,
confirmation, or release.

## Decision

The tracked repository boundary is ready for the current external-evidence
scope. The audit found zero proprietary executables or disk images, license or
activation-key files, assigned key material, identifier-bearing external case
formats, unapproved local absolute paths, or absolute/parent-traversing
symlinks. Every retained external source, contract, regression test,
documentation page, and aggregate record selected by the audit exists and has
a recomputable SHA-256.

Accordingly, checklist row 66 moves from `not_run` to `ok`. This is a
repository-content result only. It does not say that ignored local result
directories are shareable, that an external estimator is matched, or that any
ConQuest, FACETS, TAM, or immer numerical claim has passed.

## Recomputed inventory

| Quantity | Result |
| --- | ---: |
| External artifact paths | 97 |
| External software families | 4 |
| Classified tracked data assets | 34 |
| Unclassified tracked data assets | 0 |
| Allowed synthetic local-path fixtures | 1 |
| Prohibited findings | 0 |
| Missing retained artifacts | 0 |
| Non-relative tracked paths | 0 |

The four separately retained families are ConQuest, FACETS, TAM, and immer.
The 34 data assets are explicitly limited to documented synthetic package
data, synthetic vignette aggregates, schema/contract fixtures, and one
synthetic compatibility fixture; an unclassified CSV, R data object, or
serialized table fails closed.
The one allowed path fixture is the deliberately fictitious negative case in
`test-bundle-summary-privacy.R`; it verifies console/output path suppression
and is not evidence or a real local identity.

The canonical path/family/role/file-hash manifest has SHA-256
`5ce7b5307d4a4e4728cc1000e752511efd12fb36d6c91c6fe8e2aa2d33008c60`.
Paths use bytewise radix order so locale cannot change the identity. The
manifest is reconstructed in memory so a newly tracked or changed external
artifact cannot inherit an earlier hash.

## Audit rules

The audit obtains the repository inventory from `git ls-files` and fails
closed when the inventory is unavailable. It then checks:

1. every tracked path is repository-relative, resolves, and avoids parent
   traversal;
2. external-program artifacts are classified by family and role and receive a
   current SHA-256;
3. proprietary executable/disk-image and key/certificate extensions are
   absent, and MZ, ELF, or Mach-O executable magic cannot hide behind a
   renamed file;
4. license-, serial-, or activation-key filenames and assigned key material
   are absent;
5. external raw-case formats that could retain identifiers are absent;
6. every tracked CSV/TSV/R data asset belongs to an explicit synthetic,
   schema, contract, or compatibility-fixture class;
7. real local user paths are absent, with only the named synthetic negative
   fixture allowed; and
8. tracked symlinks cannot escape the repository.

The scanner reports only finding types and repository-relative paths. It never
copies a matched value into its result or test output.

## Source binding and tests

| Artifact | SHA-256 |
| --- | --- |
| `external-repository-boundary-audit-0.2.3.R` | `ca4a9ae6556bc6e1ff7c8d612f65a8f1d329ac2851872aace8381a0ef0cd199e` |
| `test-external-repository-boundary-audit.R` | `545dfc06e0693e6de9eb3dd90fa6c112e268e45f7d279dec999e8a7ee7bcb6d6` |
| sanitized portfolio/ConQuest audit | `2fdaa8f70add2f2da5122f2e68f879d27711fab18e1231931249254e7b0b7358` |

Twenty-six expectations passed. The negative fixture combines a mock
executable, identifier-bearing case extension, local absolute path, activation-key
filename, and assigned key value. The audit returns only the corresponding
finding classes and paths and never exposes the value.

## Residual boundary

`validation-results/` and local external installations remain ignored and are
outside this repository-content closure. Any candidate evidence retained
outside Git must receive a separate manifest/privacy review before release.
Rows 59 and 64 remain open: repository hygiene cannot substitute for complete
tool identity or metric-specific comparison eligibility.
