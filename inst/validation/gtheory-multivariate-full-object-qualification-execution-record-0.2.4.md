# Draft.85c4j multivariate G-theory full-object qualification record

Date: 2026-08-24  
Scope: lme4/glmmTMB ML/REML complete-object qualification  
Result: all numerical route and pair checks pass; capability trust remains closed

## Outcome

The exact c4j worker ran in a fresh `Rscript --vanilla` process with the c4i
repair overlay first in the library order. It received the fixed b1 synthetic
fixture, fit all four policy routes, and returned four complete fit objects and
two complete parity objects. The parent revalidated all six objects and
materialized four route receipts and two pair receipts.

All four routes have `identified_point_fit`, pass the b1 point-estimation gate,
preserve the exact backend rows, report zero fit warnings, use no diagnostic
override, and observe matching glmmTMB/TMB dependency identity. Both ML and
REML pairs pass the frozen b1 combined covariance, fixed-effect, and
log-likelihood comparisons.

Eleven focused tests and 65 expectations pass without failure, error, warning,
or skip using the retained c4i/c4j switches. Exact receipt reuse also passes.

The worker records 38 loaded namespaces and 27 loaded native binaries after
the fits. Each package path, version, DESCRIPTION hash, native path, and native
hash is retained so the next capability profile can use an exact read
allowlist instead of the whole user library.

## Route results

| Route | Fit status | Warnings | Result hash |
| --- | --- | ---: | --- |
| lme4 ML | `identified_point_fit` | 0 | `2c3a75eb6f3bc0ec209d5847ee2a3137ff799b428bdca2fab3b8e791a3b28d7d` |
| lme4 REML | `identified_point_fit` | 0 | `bf121ae599771418b6a9a458d79fd626d07afc29659b959f94ad46b9ef465ebf` |
| glmmTMB ML | `identified_point_fit` | 0 | `adca5383de0b1ca2926493c23ca9e87789afccfb23afe105893507565ee912ff` |
| glmmTMB REML | `identified_point_fit` | 0 | `77aac47465ccdcb5082da6ac0f65a7dcfbf8d979e65510e36d8014accc4a89a9` |

## Pair results

| Pair | Maximum covariance absolute difference | Maximum covariance relative difference | Maximum fixed absolute difference | LogLik absolute difference | Passed |
| --- | ---: | ---: | ---: | ---: | --- |
| ML | `7.021595e-05` | `1.005769e-04` | `3.806434e-05` | `2.744036e-08` | yes |
| REML | `8.762925e-05` | `1.040517e-04` | `1.793843e-13` | `7.106848e-08` | yes |

The maximum relative differences slightly exceed `1e-4`, but the c4f/b1 rule
is the prespecified combined absolute-plus-relative bound, not a separate
relative-only threshold. Every covariance cell satisfies that combined rule.

## Evidence identities

```text
C4IRepairReceiptHash       4a7c4ac0eca775e6efef8fa2713fa343c9bec4db3eec9464f0d3c7767058e3af
C4FPolicyHash              83947af1c57e62f281c54a4216bc4c384c483a83b482e07be013b31fb86e985a
WorkerSourceSHA256         45d4ff14ba7db53d53a92652f45ef18fad7934c6ca1ac17b3bf5d5daef9898fb
WorkerIdentityHash         1b7005999cf720e62ed8dc3bdb937c07c18d9d7dff0a05472de6881d89a02798
SourceRegistryHash         e405273826b023eeafdad1b8d65a0f26a8e6370b02201d46df3dc373d6fb2ff4
RequestHash                706e0cfbf43d06d88c390823edfd11e85aa998248d776593f9c263d78f1b88e0
FreshProcessReceiptHash    8eee1eafa99388b2051ff7c75a6d5f0b72684b16fd5a28753f797ded2f8874c4
PackageRegistryHash        cf6eb13db5567bc3c6c07536ba2281ebf259050c4d667f7f10baf2c04de52b9d
LoadedNamespaceRegistryHash 8add7a9f580edfdb3155785e8f68f200c0ec075bdb00b39ace61034ce43a984e
LoadedNativeRegistryHash   9fd9ed0b855c437b60442697e53eef2bfda0eaa2abf7cf1df0e2f596db768172
FixtureDataHash            fb89b9acd7adcb02d6c411e19ae4c047eecbf231a20e7fb24e763ceb65bfb0e7
SpecificationHash          540dc4f390d3b5255147374aa5b9bc0e03d9924d71d48577d4ad88512a7e0195
RouteObjectRegistryHash    954b8176d69122c5b59224ab3abafa0523c7589573e50ec229df6b7e5814863f
PairObjectRegistryHash     b9f454b0f276e85b8d34ece08c787624053f7cf830f4e0838b5297160470ecfe
FullFitObjectsHash         e70d964f63d0b62cc8d5a3caede119b9ac10612bda35e7a2be5bc84880ca8df0
FullParityObjectsHash      629fa700ff310fa4d6163d4e3988762c09656cc0876930f2a332240e9a48bbcb
RouteReceiptsHash          78f03554e0339d115eedd9ebf18d4e19b7e37b5fe429b78173d67b5f49807829
PairReceiptsHash           1e8f983e253c43520b1fde9792e655091571939ca49ee653f0e0d39160b4d80e
ImplementationIdentityHash 78bc7e032dc6adfe075f169eb804ed502809b231b7b039df7fcbf62289f62e98
QualificationReceiptHash   ee5e69982e3833a7fe80d83f170bff3685de7ba45e4dee5cbf8eef742c18a233
```

The retained receipt is
`/private/tmp/mfrmr-c4i-f78ac8f5f9c79ecd/qualification-c4j-52ad5a18b630c835/qualification-receipt.rds`.
It is ephemeral and platform-specific.

## Metacognitive boundary audit

- Statistical: numerical backend agreement passed only for the exact b1
  overlap fixture. It is not recovery, uncertainty, D-study, or general
  multivariate-design evidence.
- Numerical: the covariance rule is combined absolute plus relative; reporting
  only the largest relative difference would falsely label both passing pairs.
- Software: complete typed objects were revalidated rather than trusting
  summary booleans. Raw backend model pointers are intentionally not retained;
  the b1 fit payload and all extracted numerical identities are retained.
- Dependency: qualification is bound to lme4 2.0.6, glmmTMB 1.1.14, TMB
  1.9.25, Matrix 1.7.6, RcppEigen 0.3.4.0.2, R/native hashes, and the repaired
  library order.
- Process: the parent proves a separate process and empty output. It does not
  prove that the process lacked ambient read, write, environment, or execution
  capabilities.
- Security: c4h's refusal-only sandbox cannot be inherited by this larger
  worker. A new default-deny profile and negative controls are required.
- External validity: ConQuest is an independent comparator, not one of these
  four routes, and was not launched.
- Release: no exported function, help topic, vignette, NEWS item, or public
  roadmap claim changed. Multivariate G-theory remains unsupported publicly.

## Disposition and next gate

The four-route/two-pair numerical evidence is complete and internally
revalidated. It remains candidate evidence because full-object capability
isolation has not been assessed. The next gate must bind this exact worker,
R executable, package/DLL allowlist, staged source, repair overlay, request,
and output path to a new capability profile. It must demonstrate successful
normal qualification plus denied repository read outside the staged bundle,
denied synthetic-vault read, denied outside write, denied parent-secret
inheritance, and denied unlisted executable use.

Until that gate passes, trusted receipts, backend qualification, planned study
execution, recovery evidence, estimation, inference, decision use, and public
support remain false.
