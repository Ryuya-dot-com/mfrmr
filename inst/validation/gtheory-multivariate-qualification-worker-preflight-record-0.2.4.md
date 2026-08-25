# Draft.85c4g multivariate G-theory qualification-worker preflight record

Date: 2026-08-24  
Scope: refusal-only worker bundle, request, child process, and receipt  
Result: fresh-process refusal ready; qualification worker not implemented

## Outcome

Draft.85c4g seals the c4f protocol, eight-file future worker bundle, and
seven-function refusal worker. A fresh `Rscript --vanilla` process accepted a
hash-only request, returned exit status 0, and produced the exact typed
`environment_not_ready_no_backend_attempt` receipt.

Ten focused tests and 80 expectations pass without failure, error, warning, or
skip. Temporary request/receipt staging was removed after each process. No
package installation, native rebuild, fit specification, response payload,
backend call, diagnostic override, trusted receipt, planned seed, ConQuest
launch, or external service call occurred.

The c4f+c4g boundary subset passes 20 tests and 185 expectations. Combined
with the same-turn upstream regression and c4b/c4c live evidence, Draft.85a0
through c4g covers 14 files, 132 tests, and 1,475 expectations with zero
failure, error, warning, or skip.

## Observed receipt

```text
WorkerExitStatus             0
RefusalOnlyWorkerReady       TRUE
FreshProcessRefusalObserved TRUE
ProcessCapabilityIsolation  FALSE
QualificationWorker         FALSE
FullB1ObjectsReceived       FALSE
BackendExecutionOccurred    FALSE
TrustedReceiptProduced      FALSE
QualificationEvidenceReady  FALSE
BackendQualificationReady   FALSE
ExecutionGateClosed         TRUE
```

Fresh-process observation is assigned by the parent controller, not trusted
from a child-reported flag. Capability isolation remains false because this
preflight did not use the c4b macOS sandbox profile.

## Replay identities

```text
ProtocolManifestHash          89044060c10c55321e61d2214fc85484aca30c4eafc413f67fc26f00edc6d1fb
QualificationPolicyHash       83947af1c57e62f281c54a4216bc4c384c483a83b482e07be013b31fb86e985a
EnvironmentIdentityHash       a5c1a7dd6f7f87098ee6ef5766fc96d352af63e3ac3140107be00766d4f696a0
BundleRegistryHash            897579b6991f354d459725e64758edc011e1baf7f6ebbbcf1256f4a0c67911da
WorkerSourceSHA256             a13ef63611a1e96048de3fd5a4b59bf4dddc53d225c6cd3f5808c65876a21daa
WorkerIdentityHash             211b0dab392ed055ae195521e0ef2550659af36b48359d57cc1264725b13d32c
RequestHash                    bfe17f910784d32016a926ff974bc727ad8a4ed7ac58f6ca69f8dd492ac052bb
RefusalReceiptHash             2d43de546694c99b9760554b6a4f079c84a04a44faf0cb61309e4d3f8582070c
RscriptSHA256                  e985928bd58bee1f2454916e59a97338288b2eeec3610caa9d1135ae04e3b393
ProcessEvidenceHash            5066e9d63923dc649dc1b811d4b8fdc97889d199270bb7a20159a8206c04cb7a
ImplementationIdentityHash     5f07c36da3805a481882fc684c31e5856568d2a9800aacbeacd1138829fb699c
ManifestHash                   c62906de666c4de1f6a00f07009e84fc859165486a859cbb2db406e679be7a97
```

These are source, process, request, and refusal identities only. They are not
ABI-repair, capability-isolation, full-object validation, route, pair,
qualification, recovery, external-freeze, or execution receipts.

## Adversarial controls

The suite rejects a rehashed environment-ready request, rehashed backend
authorization, changed process evidence, changed manifest readiness, unknown
worker actions, and both caller authorization values. The worker namespace and
bundle allowlist must remain exact. Public and estimator entry-point scans are
clean.

## Disposition

The source bundle, refusal request, fresh-process transport, and typed
non-attempt receipt are ready. ABI repair, capability-isolated qualification,
full b1 object intake, a qualification-capable trusted worker, four route
receipts, two pair receipts, backend qualification, every execution lane,
recovery evidence, and public support remain incomplete.

Draft.85c4g adds no export, help topic, vignette, NEWS entry, or public-roadmap
claim. Multivariate G-theory remains unsupported publicly.
