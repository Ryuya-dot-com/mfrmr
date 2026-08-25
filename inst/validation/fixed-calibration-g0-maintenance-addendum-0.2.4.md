# Fixed-calibration G0 maintenance-baseline addendum for mfrmr 0.2.4

Status: `cran_0.2.3.1_source_bound_hotfix_integrated`, 2026-08-25.

## Public predecessor

- CRAN version: `0.2.3.1`
- Publication date: `2026-08-25`
- CRAN source SHA-256:
  `d3d2b00638fcbd8407dfabd5206eb670b2a3470e0e30e0079ca64a2e7a77b67a`
- CRAN source MD5: `626a948a1b338e004c85b3c691be71e5`
- Release-line commit: `be5611ed9a9390ac6d33997f28e16be041aec56f`

The published source was compared with a source package rebuilt from the
release-line commit. Common payload files were byte-identical after CRAN-added
`DESCRIPTION` fields and `MD5` were separated. The published tarball completed
the full `NOT_CRAN=true R CMD check --no-manual` path with `Status: OK`.

## Maintenance bridge into 0.2.4

The two material release patches have exact stable patch-id matches:

| 0.2.3.1 commit | 0.2.4 integration commit | Stable patch-id | Scope |
| --- | --- | --- | --- |
| `69cc7a0` | `dc4a337` | `8744a9894ab0a02186cab16ef3e337b067abbbeb` | Remove the local `HAVE_ENUM_BASE_TYPE` override and add its source regression contract. |
| `3eda09f` | `7fa91a1` | `b99133ae6ab40c1496e9b7550b2b98097cd194d8` | Remove the expired FACETS/Winsteps documentation targets without changing model claims. |

Neither patch changes an exported R signature, likelihood expression,
gradient expression, parameter layout, scoring algorithm, calibration schema,
or fitted-model contract. The original G0 behavior inventory for 0.2.3
therefore remains historical substantive evidence, while this addendum binds
the latest public source and its compiled/documentation maintenance delta.

## Evidence consequence

The 0.2.3.1 compiled sources and compiled-header regression contract are
identical to the corresponding integrated 0.2.4 files. This permits the
0.2.3.1 GCC-LTO result to remain exact source-level maintenance evidence.
It does not authorize carrying the 0.2.4 fixed-calibration G4 close across the
new package payload: the v5 result remains historical for commit `bcf8619`,
and a successor source-bound confirmation is required before G6.

- `PublicPredecessorBound=TRUE`
- `MaintenancePatchIdsMatched=TRUE`
- `PublicAPIChanged=FALSE`
- `FittedModelContractChanged=FALSE`
- `G0SubstantiveInventoryReopened=FALSE`
- `G4V5RetainedAsHistorical=TRUE`
- `PostMaintenanceG4Complete=FALSE`
- `G6Authorized=FALSE`
