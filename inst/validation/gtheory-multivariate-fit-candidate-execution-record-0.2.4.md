# Draft.85c4p nonreserved fit-candidate execution record

Date: 2026-08-25  
Status: completed internal preflight  
Public support: none

## Result

Draft.85c4p passed. The revised c4o observation-linked envelope was fitted in
four distinct fresh processes through the exact c4l-qualified lme4/glmmTMB by
ML/REML routes. Every fit returned `identified_point_fit`, every point gate
passed, all 40 route-coordinate rows were finite, and both matched-backend
comparisons passed.

Eight tests and 48 expectations passed without failure, error, warning, or
skip. No public R, help, vignette, NEWS, or ROADMAP surface was changed.

## Observation-link correction

Metacognitive review before implementing the worker found that c4o had removed
an input needed by b1. c2 `Replicate` is the within-cell observation ordinal;
it is not the planned dataset replicate. c4o was revised to replace the raw
ordinal with an opaque `ObservationLink` rather than deleting its pairing
function.

The exercised b1 specification reports:

| Check | Result |
| --- | ---: |
| response rows | 720 |
| duplicate within-stratum observation keys | 0 |
| shared A/B observation links | 360 |
| extracted coordinates per route | 10 |

This correction changes c4o identities but does not alter the c1 plan or its
5,042-dataset/20,168-method-unit denominator.

## Route results

| Method | Status | log likelihood |
| --- | --- | ---: |
| lme4 REML | identified point fit | -801.2802 |
| glmmTMB REML | identified point fit | -801.2802 |
| lme4 ML | identified point fit | -800.1690 |
| glmmTMB ML | identified point fit | -800.1690 |

All route diagnostics contain zero captured warnings and zero captured
messages. Each route used its c1 default-control contract. No glmmTMB/TMB ABI
override was allowed.

## Backend parity

| Pair | max covariance absolute difference | max fixed absolute difference | log-likelihood absolute difference | passed |
| --- | ---: | ---: | ---: | --- |
| REML | 8.714105e-06 | 8.992806e-14 | 1.019089e-09 | yes |
| ML | 3.879108e-05 | 3.359130e-07 | 2.333877e-08 | yes |

These are implementation checks on one nonreserved fixture. They are not
finite-sample recovery accuracy, coverage, or general backend-equivalence
claims.

## Process and least-privilege result

Four distinct child process identities were observed, all with exit status
zero and no output lines. The repaired c4i overlay was first in library order.
lme4 routes recorded only `digest` and `lme4`; glmmTMB routes recorded only
`digest`, `glmmTMB`, and `TMB`. The controller independently revalidated every
normalized fit and receipt.

The exact nonreserved request and output artifacts are retained under:

```text
/private/tmp/mfrmr-c4i-f78ac8f5f9c79ecd/fit-candidate-c4p-bb7dff64bd9f6d34
```

They contain candidate data but no planned identity, reference truth, or
accuracy threshold. They are ephemeral validation artifacts, not package
artifacts.

## Readiness decision

Ready at c4p:

- exact fit-capable worker implementation;
- observation-link fit contract;
- four qualified nonreserved route executions;
- ten-coordinate extraction for every route;
- two matched-backend parity checks; and
- independent controller-side fit and receipt validation.

Still false:

- fit-process capability isolation;
- c3 truth-blind process boundary;
- every planned execution lane;
- candidate completion and truth release;
- denominator accounting and recovery evidence; and
- estimation, inference, decision, ConQuest, and public support.

Exactly zero c3 prerequisites transition and the satisfied count remains 2 of
8.

## Hash record

| Object | SHA-256 or semantic hash |
| --- | --- |
| c4p manifest | `25ec52dd17e91768fe58a2720af25b05c71660d8d5813273c1edd6ce7dc9bf43` |
| c4p manifest file | `b7ccea5d4fa6e950aa456f59a634cc35c24d126fce4b82410bad7a0264b547a8` |
| c4o manifest | `e904377914952dbc2de3c76ddc446f1dccd101c7776a34b066985c93517219bf` |
| c4l receipt | `b616611ad7455ae79f948a10c71eefaa27e9fd2e92de277a64b477a560022c6e` |
| c4i receipt | `4a7c4ac0eca775e6efef8fa2713fa343c9bec4db3eec9464f0d3c7767058e3af` |
| candidate data | `318f8155deea20790e37c329730721cda231b5dddb9fbf40a1bd81eea27126d9` |
| candidate schema | `81ffde7843c881f383adb90d8d413d955c6b8e539d0307803f271d707baa512a` |
| worker source | `b4662e8bc72ad86bb28a724f3161e737d5e22185bb91409ba4d334fde7584d3c` |
| worker identity | `685f0234d5830ad04b2b87736ec1098aa4d9d1b0abb8b519792e3cb1ea3ce11c` |
| source registry | `867c1a5f044d99da24cf486dc200c9cdbd8110e8831bf8ec759090b6b136d3c4` |
| route registry | `4482b962b61e3eaadbd936c7a9d6e3136b190be88bbfb7f94e1055cfb53cb283` |
| coordinate registry | `096e93ed9f834b6ce2f8a9eb188e85740dbff9f8b441a4c1aa2e23e50e993e41` |
| backend parity registry | `8c8fe090ffa5c234d86db62d05fa730e3a2f7063835967d725bfbafc8e4b07ad` |
| process registry | `5e5c93673f30aeb63554648e75a950b0ea3273fcfa69ef71a4350134405045b6` |
| prerequisite projection | `e2468f559638d227978a1c6b022b3de5569a1261560e37514e7466d4c00af173` |
| implementation identity | `2dc7da0b81ce8d0fa6bcdadaf2e1de4b04833fc41d87007011526fc744d3472f` |
| controller source | `484ddc2a45e21cc26a3bb03b7e964017fdf9a414a2b045a4729bf6a5b4faf242` |
| test source | `262f5970aba671980b3e3091f2a3db97ed6d850ff2f0464f3645b82ddac77ba6` |

The retained manifest is
`/private/tmp/mfrmr-c4p-fit-candidate-execution-manifest-0.2.4.rds`. It is
ephemeral validation state, not a package artifact.

## Next slice

Draft.85c4q should execute this unchanged worker under a default-deny profile,
reproduce all four exact receipts, and pass denial controls appropriate to the
wider fit-capable program. c3 must not transition before that separate result.
