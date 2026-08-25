# Draft.85c4e multivariate G-theory backend-qualification admission record

Date: 2026-08-24  
Scope: local package/native identity and closed four-route admission  
Result: repair required; qualification and execution remain closed

## Outcome

Draft.85c4e extends the c3 version snapshot to the installed package and native
binary level. lme4, glmmTMB, and TMB DESCRIPTION files and shared libraries are
present and content-addressed. The c3 build-TMB value agrees with the loaded
glmmTMB namespace, but glmmTMB was built with TMB 1.9.23 while runtime TMB is
1.9.25. The exact local environment is therefore not eligible for formal
four-route qualification.

Ten focused tests and 78 expectations pass without failure, error, warning, or
skip. No installation, rebuild, library mutation, fit, planned response,
ConQuest launch, or external service call occurred.

## Package and native identities

| Package | Version | DESCRIPTION SHA-256 | Native DLL SHA-256 |
| --- | --- | --- | --- |
| lme4 | 2.0.6 | `00314a8e8a3e222bd2a21884d5821a814c491b912d53feac6c33dfcfc1b0e181` | `c6aa4ff473eca680451d45408030438c13ead2a71c263995cbd3ed7ecb0243a1` |
| glmmTMB | 1.1.14 | `d18dfbd8bfb7ba1067474e3106d5f15b975d26bdc02577759baaf91db0fcc1d9` | `c071fa6dcf5ebd31a7f74108c56d8993f38325cbac575313db02fd58095a7309` |
| TMB | 1.9.25 | `a4cb112534dd51eb95d8734e10a531a1186020f32e162e695f412a8c45b7231c` | `7628cae9c3065bcd1e5bd89f76b293e2625bacaee08669b54d4742c734659932` |

## Replay identities

```text
C3EnvironmentSnapshotHash             02fa5345de47a08251315bae7d98cb4e9f824d40908c23a5d6abd27440d58079
EnvironmentIdentityHash                a5c1a7dd6f7f87098ee6ef5766fc96d352af63e3ac3140107be00766d4f696a0
PackageRegistryHash                    ef4ef271c7da91928714f69ba194022bfb0635686047067f743884a0318346e4
MatchedBackendSourceSHA256              981f203e9f4a5c5d8298f37031c6502fd78a31f609d8f1a0fdcd52fae8b76b95
UpstreamRootRegistryHash                707795e2c337134d69ea7719cb4f82bc435cdca34bf179531e96b6d4649cf772
RepairPlanHash                          0dcb71afc2b1fbad463d22105ab9c76157f50cd376bc8be1537c077e90450742
QualificationRouteRegistryHash          a5fc8c5a169dfd4cbbb208f1cd0500510a87b7a6be2d55c5c38f75a7e0536c19
QualificationReceiptTemplateHash        baf6fe4454aea4fba0a57eeaa95ee38e78a5e5dc60e67bb057c3ae2f968c50e2
ImplementationIdentityHash              04515f7038f44efb2d2e834d776579b9042d0596c5f828a94573fe79df7700f8
ManifestHash                            cb8214df9c468858ca3e4e267e815eab99918f880fb99ed6a336a2b053ef80ce
```

These are local replay identities. They are not package-source receipts,
installation receipts, completed backend qualification receipts, an external
source freeze, or execution authority.

## Adversarial controls

A synthetic c3 snapshot whose build-TMB value is changed to 1.9.25 is
self-consistent at the c3 level. At c4e it contradicts the build identity read
from the loaded glmmTMB binary, so both candidate eligibility and live
readiness remain false. Changed DLL hashes, upstream roots, readiness flags,
and both caller authorization values are also rejected without calling a
repair or fit callback.

## Disposition

Package/native identity and a declarative repair plan are ready. Environment
repair, a fresh-process matched identity, all four route receipts, source
freezing, backend qualification, every execution lane, recovery evidence, and
public support remain incomplete.

Draft.85c4e adds no export, help topic, vignette, NEWS entry, or public-roadmap
claim. Multivariate G-theory remains unsupported publicly.
