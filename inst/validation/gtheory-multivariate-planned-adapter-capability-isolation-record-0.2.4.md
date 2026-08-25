# Draft.85c4n planned-adapter capability-isolation record

Date: 2026-08-25  
Status: completed internal preflight  
Public support: none

## Result

Draft.85c4n passed. The exact four-function c4m adapter was loaded by a
five-function wrapper in nine separate fresh macOS default-deny processes.
Three canonical lane receipts matched byte-for-byte at the R-object level, and
six attempted capabilities were unavailable.

This result qualifies only the non-attempt adapter process. It does not qualify
a fit-capable truth-blind worker, does not transition a c3 prerequisite, and
does not authorize study execution.

## Implemented artifacts

- `gtheory-multivariate-planned-adapter-capability-worker-0.2.4.R`:
  five-function fresh-process wrapper;
- `gtheory-multivariate-planned-adapter-capability-isolation-preflight-0.2.4.R`:
  22-function controller, runtime binder, profile builder, evidence validator,
  and closed dispatch guard;
- `test-gtheory-multivariate-planned-adapter-capability-isolation-preflight.R`:
  ten tests and 59 expectations; and
- this contract and record.

No public R, help, vignette, NEWS, or ROADMAP surface was changed.

## Live control outcome

| Ordinal | Mode | Expected result | Observed |
| ---: | --- | --- | --- |
| 1 | normal pilot | canonical adapter receipt | pass |
| 2 | normal confirmation | canonical adapter receipt | pass |
| 3 | normal negative control | canonical adapter receipt | pass |
| 4 | protected-vault read | sandbox denial | pass |
| 5 | repository read | sandbox denial | pass |
| 6 | outside write | sandbox denial | pass |
| 7 | parent environment | variable absent | pass |
| 8 | unlisted executable | sandbox denial | pass |
| 9 | external network | sandbox denial | pass |

All child exit statuses were zero because each denial was captured into a
typed result. All process-output channels were empty. No parent secret was
visible. The forbidden output file was not created.

## Normal lane identity

The exact c1 denominators were retained:

| Lane | Expected | Observed | Exact canonical receipt |
| --- | ---: | ---: | --- |
| pilot | 960 | 960 | yes |
| confirmation | 19,200 | 19,200 | yes |
| negative control | 8 | 8 | yes |

All three remain non-attempt receipts: no candidate response data was received
and no backend was invoked.

## Runtime and policy

The live runtime bound Darwin, R 4.6, the direct R executable, sandbox launcher,
environment launcher, system profile, locale, both workers, and the complete
digest package identity. The policy audit passed all 21 rows.

During development, the first profile correctly denied nested sandbox startup
under the ordinary managed runner. The approved host-level run then exposed a
different issue: R's `normalizePath()` requires explicit metadata traversal for
the parents of its staged library. The final profile grants only those parent
literals and retains content-read denial for the protected vault and
repository.

The final staging uses a verified physical digest copy. A symlink was rejected
as an unnecessary dependency on seatbelt `realpath` behavior. The DESCRIPTION
and native binary hashes of the staged copy match the bound origin.

## Protected-material accounting

The synthetic vault contains no real study material. The evidence records all
of the following false:

- candidate data included;
- planned seed material included;
- scenario identity included;
- reference identity included;
- reference truth included;
- accuracy threshold included; and
- ConQuest route included.

The c4m payload-blindness claim and the c4n capability claim are independent:
the former concerns request content; the latter concerns what the exact child
process can reach.

## Readiness decision

The controller sets these narrow results true:

- default-deny profile and sanitized environment ready;
- exact digest runtime ready;
- three fresh-process receipts ready;
- all six denial controls ready;
- payload truth-blind ready;
- backend qualification inherited ready; and
- planned-adapter process capability isolation ready.

It keeps `TruthBlindProcessBoundaryReady` false. This is not a contradiction.
The c4m adapter cannot consume candidate data and cannot run the backend, while
the eventual operational candidate worker must do both. Capability evidence is
not safely transferable from a narrower program to a wider one.

The c3 satisfied-prerequisite count therefore remains 2 of 8, with zero c4n
transitions. All candidate, lane, completion, truth-release, recovery,
estimation, inference, decision, and public gates remain closed.

## Hash record

| Object | SHA-256 or semantic hash |
| --- | --- |
| evidence | `c1a848be7defca729d3f849bb154c80d507a10291f61095d30daf2fd551f19dd` |
| evidence file | `124f4a27b78ebf7786fa14a4031422ccce7213d9c9fa534e91f32d2ed60f9deb` |
| c4m manifest | `32412c99d51ca5e95b1cdcc6f0cd4cff628c5fb4936de6abf591d7439515a184` |
| c4l receipt | `b616611ad7455ae79f948a10c71eefaa27e9fd2e92de277a64b477a560022c6e` |
| runtime identity | `8aea03cf792ccafbd790fefbe69794c5f5a970201204724a4d4efa748210e91b` |
| staged runtime | `def2b90466fe9b12dd4d31652603e57315d148ae621d5ed535bbda798878fd37` |
| profile semantic | `608b7e829127874093d0ddcd760fb7f74c4af70fea35e64a7fa597d30632b407` |
| policy audit | `16a6ebb4ee4e85bd329d17f5c2e39e412394f5b7e26b6f351b3c8b6d52f12292` |
| control registry | `8cac0ab4c09eb96217f0ee3b0250792ef04791405b4d3b9c9fb9c4e438e659bf` |
| control results | `ba6888e64f1a966801c36852cf1a5036cf574dd4826e153665b328ae4272a061` |
| normal receipts | `9e724572d4062278d9db4d25ca1121620ab2d05ea7b24b9fed7f15147f430ff7` |
| synthetic vault | `e33b69784ba0c72779dcd05772158088c7052ce0618ab3ce9ec83c4c75c3e3ee` |
| prerequisite projection | `0b2c57c0495f9020859d7c78723cce879b577cba03337f1d4c12c6e3aad579a4` |
| capability-worker identity | `256ef984ed6a281e0cd2bfd8b1fcf73b649b0c14b9c6363f3fdd91ad87993cba` |
| implementation identity | `b013e5790a5f8d25a1d5e652d19b11a38a326fc1b883603816c81da621011561` |
| worker source file | `8a605d71af0ecb2e9b4dca81eabff2b1a8b8f507ee56a87356da3186de591798` |
| controller source file | `88939d548c48fbe20c2355589c66b3aaf696548d57e2e0ad297e65cc1785cdd0` |

The retained evidence is
`/private/tmp/mfrmr-c4n-planned-adapter-capability-evidence-0.2.4.rds`.
It is an ephemeral validation receipt, not a package artifact.

## Multi-angle review

- Statistical: denominators and opaque lane topology are preserved, but no
  responses or estimates exist.
- Security: denial is demonstrated for six capabilities; metadata traversal is
  explicit and synthetic protected data only are staged.
- Software: worker and controller namespaces, runtime files, registries, and
  implementation bodies are hash-bound.
- Operational: the dispatcher remains fail-closed even with authorization true.
- Epistemic: evidence from a non-attempt program is not generalized to the
  materially wider fit-capable program.
- Documentation: all language remains repository-internal.

## Next slice

Draft.85c4o should define a sealed fit-capable candidate-data envelope and
worker without executing planned study candidates. It must separate the
data-generating authority from the candidate-fitting authority, bind the
qualified backend route, preserve the c1 denominator ledger, and exclude
scenario, seed, reference, truth, and threshold material. The exact resulting
worker must receive its own live capability run before the c3 truth-blind row
can transition.
