# Draft.85c4h multivariate G-theory qualification-refusal capability record

Date: 2026-08-24  
Scope: macOS default-deny c4g refusal path and six live controls  
Result: hash-only refusal capability isolation ready; qualification closed

## Outcome

The exact c4g hash-only request completed its normal refusal-receipt path under
the c4h default-deny profile. Five separate negative invocations returned typed
results while denied-vault read, repository read, outside write, parent-secret
inheritance, and unlisted executable use remained unsuccessful.

Ten focused tests and 68 expectations pass without failure, error, warning, or
skip when `MFRMR_RUN_C4H_MACOS_SANDBOX=true`. The c4g+c4h boundary subset is 20
tests and 148 expectations. Together with the previously completed a0-c4g
chain, Draft.85a0 through c4h covers 15 test files, 142 tests, and 1,543
expectations with no failure, error, warning, or skip under the required live
switches.

The managed outer sandbox rejected nested `sandbox-exec` with
`sandbox_apply: Operation not permitted`. The successful observation was
therefore rerun outside that containing sandbox while retaining the target c4h
profile. This is a host nesting constraint, not a relaxation of the worker
profile.

No package installation, native rebuild, backend fit, full b1 object, planned
response, diagnostic override, trusted receipt, ConQuest launch, or external
service call occurred. Deterministic staging was removed after the run.

## Bound runtime and controls

The observed runtime is Darwin 25.5.0 on arm64 with R 4.6.1 (2026-06-24).
The evidence also binds the exact `sandbox-exec`, `env`, direct R binary,
Apple `system.sb`, digest installation, c4g refusal worker, and c4h capability
wrapper.

| Mode | Sandbox status | Action succeeded | Parent secret visible | Denial class |
| --- | ---: | --- | --- | --- |
| `normal` | 0 | true | false | `normal_refusal_receipt` |
| `probe_vault_read` | 0 | false | false | `sandbox_operation_denied` |
| `probe_source_read` | 0 | false | false | `sandbox_operation_denied` |
| `probe_outside_write` | 0 | false | false | `sandbox_operation_denied` |
| `probe_parent_environment` | 0 | false | false | `parent_environment_absent` |
| `probe_unlisted_exec` | 0 | false | false | `sandbox_operation_denied` |

All six typed outputs existed, all controls passed, and no forbidden output
file was created. The synthetic denied vault contained only a request-bound
token and three explicit false content flags; no truth-side or execution
material was created for this test.

## Replay identities

```text
C4GManifestHash                  c62906de666c4de1f6a00f07009e84fc859165486a859cbb2db406e679be7a97
ProtocolManifestHash             89044060c10c55321e61d2214fc85484aca30c4eafc413f67fc26f00edc6d1fb
QualificationPolicyHash          83947af1c57e62f281c54a4216bc4c384c483a83b482e07be013b31fb86e985a
EnvironmentIdentityHash          a5c1a7dd6f7f87098ee6ef5766fc96d352af63e3ac3140107be00766d4f696a0
BundleRegistryHash               897579b6991f354d459725e64758edc011e1baf7f6ebbbcf1256f4a0c67911da
RefusalWorkerSourceSHA256         a13ef63611a1e96048de3fd5a4b59bf4dddc53d225c6cd3f5808c65876a21daa
RequestHash                      bfe17f910784d32016a926ff974bc727ad8a4ed7ac58f6ca69f8dd492ac052bb
CapabilityWorkerSourceSHA256      4387bc63f86cd5c77454e3767077ec11b31603b55733cadcb2805d0bee2ec7c0
RuntimeIdentityHash              b49af41fbf00c406e33d8047a63887252fe1172f0d716037ced35c6422dbbf9c
ProfileHash                      5736004f62b72d160c0029b30773efe5993775ab9dd8c5ee8b659022c6f18efa
ProfileSemanticHash              35a33e747284d764cb4902228e22770596b7a71c41a3f4dcfe33d409b6f59186
PolicyAuditHash                  3d4ae1ce2cd68d3582bd467cac2356f90271cb65dfad676bba6a6ea05f8cf5f0
ControlRegistryHash              f9c2db1a3b82af3ddcaa63010717e3612925e42f4fef88a01bc5eea3e6539e63
NormalRefusalReceiptHash          2d43de546694c99b9760554b6a4f079c84a04a44faf0cb61309e4d3f8582070c
SyntheticVaultHash               583c7beb10121c2a72129376d704b42b45c9082078c54a3794e2b70eba5b5960
CapabilityWorkerIdentityHash      c1864dad50186f0fc0e76ee5e654fddcd8100b70d18d67910df709a67aa0e9bb
ImplementationIdentityHash       c6aee11b985c0442e3b4cac8c12a128c262c5f3fcab966acd49e854a4ecc3a0a
EvidenceHash                     5cd3d148d28cdf59846c5108e21ddd55094da1e006829104a79104e5c08fe103
```

The concrete profile hash includes the deterministic staging path. The
semantic profile hash replaces that path with `<STAGING_ROOT>`, separating
policy meaning from run-local identity.

## Disposition

`ProcessCapabilityIsolationReady` and `HashOnlyRefusalBoundaryReady` are true
only for this exact refusal-only worker, request, profile, and runtime. The
result closes the capability gap recorded by c4g for its non-attempt transport;
it does not promote `QualificationWorkerImplemented`.

ABI repair, a capability-isolated full-object worker, four route receipts, two
pair receipts, backend qualification, every planned execution lane, recovery
evidence, and public support remain false. Draft.85c4h adds no export, help
topic, vignette, NEWS entry, or public-roadmap claim. Multivariate G-theory
remains unsupported publicly.
