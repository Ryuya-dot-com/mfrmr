# Draft.85c4o fit-candidate envelope preflight record

Date: 2026-08-25  
Status: completed internal preflight  
Public support: none

## Result

Draft.85c4o passed after correcting the observation-identity release design.
One c2 nonreserved fixture was transformed from a seven-column raw table to a
seven-column observation-linked table and presented through four separately
bound route envelopes to a sealed contract worker. All envelopes were
accepted, while every receipt reported no attempt, no backend invocation, no
fit, and no implemented fit-capable worker.

Ten tests and 87 expectations passed without failure, error, warning, or skip.
No public R, help, vignette, NEWS, or ROADMAP surface was changed.

## Implemented artifacts

- `gtheory-multivariate-fit-candidate-envelope-worker-0.2.4.R`: exact
  five-function contract worker;
- `gtheory-multivariate-fit-candidate-envelope-preflight-0.2.4.R`: 24-function
  controller, release transform, four-route binder, topology audit, and closed
  dispatch guard;
- `test-gtheory-multivariate-fit-candidate-envelope-preflight.R`: ten tests;
- the c4o contract; and
- this record.

## Candidate release

The exercised nonreserved fixture had 720 response rows. Its source candidate
table contained:

```text
RowId Stratum Object Rater ObjectRater Replicate Score
```

The released table contained:

```text
RowId Stratum Object Rater ObjectRater ObservationLink Score
```

The raw `Replicate` column is a within-cell observation ordinal rather than a
planned dataset replicate. It is removed, but its necessary pairing function
is retained through a deterministic opaque `ObservationLink`. This correction
prevents the two observations in each Object-by-Rater-by-Stratum cell from
collapsing to one ambiguous b1 observation identity. The manifest retains the
release audit and data and schema hashes, not the 720-row table or the
controller-only protected source fields.

Adversarial tests changed an opaque exercise ID, changed an `ObjectRater`
value, and collapsed two observation links while recomputing the available
data, opaque, and envelope hashes. The worker rejected all three. Identity,
grouping, and observation-pair constraints are therefore semantic checks
rather than hash-presence checks.

## Route outcome

| Method | Qualification route | Accepted | Attempted | Backend | Fit |
| --- | --- | --- | --- | --- | --- |
| lme4 REML | `lme4_reml` | yes | no | no | no |
| glmmTMB REML | `glmmTMB_reml` | yes | no | no | no |
| lme4 ML | `lme4_ml` | yes | no | no | no |
| glmmTMB ML | `glmmTMB_ml` | yes | no | no | no |

All method-control hashes match c1. All route qualification receipt,
specification, semantic-model, and process-capability identities descend from
c4l. This is route-contract evidence, not new backend qualification.

## Denominator outcome

c4o reconstructed the c1 candidate-unit root and matched c4m exactly:

| Lane | datasets | method units |
| --- | ---: | ---: |
| pilot | 240 | 960 |
| confirmation | 4,800 | 19,200 |
| negative control | 2 | 8 |
| total | 5,042 | 20,168 |

Every dataset maps to four routes. No second denominator was created, and the
nonreserved c4o exercise is ineligible for recovery accounting.

## Authority and access review

The generator vault, release transform, and candidate-fit contract are three
distinct authorities in the schema. The first two were exercised within the
controller; the candidate-fit authority remains unimplemented. No authority
receives both protected generator material and backend invocation authority in
the contract.

All five protected access classes are absent from the released envelope:
scenario, seed/replicate, reference, truth/generating state, and threshold.
This is payload evidence. It does not establish process denial for a future
fit worker.

## Readiness decision

The envelope schema, release transform, all four route contracts, c1 topology,
backend qualification binding, authority-separation contract, and protected-
field exclusion are ready.

The fit-capable worker is explicitly not implemented. Consequently:

- fit-capable process isolation is false;
- the c3 truth-blind process boundary is false;
- exactly zero c3 prerequisites transition;
- the satisfied count remains 2 of 8; and
- every execution, completion, truth-release, recovery, inference, decision,
  and public gate remains closed.

This avoids transferring c4n's non-attempt adapter result to the materially
wider future fit program.

## Hash record

| Object | SHA-256 or semantic hash |
| --- | --- |
| manifest | `e904377914952dbc2de3c76ddc446f1dccd101c7776a34b066985c93517219bf` |
| manifest file | `0d5a75e87c707aee21bd6d6e30ee169a7c4cb0cf5410f7f8f36ac18810e496d1` |
| c4n evidence | `c1a848be7defca729d3f849bb154c80d507a10291f61095d30daf2fd551f19dd` |
| candidate-unit manifest | `fd50018230259104f79fe6b59e4dc37e7b3d0da8c7f848b2463891f79ddd07f9` |
| worker source | `0bac4f665e3426516f5136e2ff11ac70114adb6ffb41ed40e07f945a874cafd1` |
| worker identity | `c3485680bef4512be0d41ac666aed14484d4df41b95082495f6d1aaeb9bf6e1f` |
| worker static audit | `0b8455b140cecc17cbe4664185b44e769a87319d87feef5b9209da464f4405b9` |
| candidate schema | `81ffde7843c881f383adb90d8d413d955c6b8e539d0307803f271d707baa512a` |
| envelope schema | `1f5033e74de2315e9bbb3f5d80e275c7fefaacd3dbb70d16a0cad2567fde0e9d` |
| receipt schema | `3c78e51fb1e53e2d75299b7de1d5268b874119f75c154b561aa4735c2b408996` |
| route exercise | `7158f96f828493bc35a854897687d02becfd0a1a399e16b0ec474b0b90494eb6` |
| release audit | `329276b082723a938fbd1379be4b5a383f7eea2b8c6f94c7b9eaa26f636516d8` |
| protected-source audit | `c5e28db26577d63bacc9a948b8e9934dc11fca998940ed3518f46dd2992c45d5` |
| route contract | `3ac7500d98548d461f5875c1ba3e41d2adac5e78f7f7871fedf4d74cc362cd9d` |
| planned topology | `14a546ea2cb93f7c4e2bda7fbe2bebcbc794bebbceee64e892a5c55892921a72` |
| access questions | `44446fa3ef708ae426b50de2daf82868f45b9c80b30a59819e32146931cc14b0` |
| authority separation | `1bfa91b8f15fadb96c0df1523faa3672f231ca1619bb1e53f70d1582937a3736` |
| prerequisite projection | `733509ed0c0067c5d5ac6f257cbbe6b76566ae65b577449c6b81f4e4661bd0bb` |
| implementation identity | `351b16ba713a091d53a2cad5cb39cadf3853df5861ef9e15ecf6909bf1885994` |
| controller source | `a765847b76439a1a6bcfa1699835702748fdf9043c8a8470f93fd56a915c1efb` |
| test source | `594772d55a55f29a62f2b122d4be3df1f77d88e7dd6628de95041d2eb1e248bf` |

The retained manifest is
`/private/tmp/mfrmr-c4o-fit-candidate-envelope-manifest-0.2.4.rds`. It is
ephemeral validation state, not a package artifact.

## Multi-angle review

- Statistical: one dataset maps to four matched routes; the 5,042/20,168
  denominator remains unchanged.
- Security: protected fields are removed, but fit-process capability has not
  yet been assessed.
- Software: identities, controls, schemas, route roots, and implementation
  bodies are hash-bound and recomputed.
- Operational: the contract worker cannot fit and the dispatcher always
  refuses.
- Epistemic: interface completeness is not confused with worker or isolation
  completeness.
- Documentation: all c4o language remains internal.

## Next slice

Draft.85c4p should implement the four-route fit worker and execute it only on
nonreserved fixture data. It must return typed fit receipts compatible with
c4o without entering c1 pilot, confirmation, negative-control, or recovery
denominators. A separate successor capability run remains necessary before
the c3 truth-blind process prerequisite can change.
