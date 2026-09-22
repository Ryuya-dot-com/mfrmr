# Draft.85c4i multivariate G-theory isolated ABI-repair record

Date: 2026-08-24  
Scope: pinned source build, retained overlay, and fresh-process ABI identity  
Result: ABI repair ready for qualification intake; qualification remains closed

## Outcome

TMB 1.9.25 and glmmTMB 1.1.14 were rebuilt from the two pinned CRAN source
tarballs into `/private/tmp/mfrmr-c4i-f78ac8f5f9c79ecd/library`. Neither the
existing user library nor the system library was modified.

The first read-only/probe build exposed a broken default R Fortran linkage:
R's `FC`/`FLIBS` pointed at absent `/opt/gfortran` paths and the TMB link failed
on `libemutls_w`. The formal build used the existing Homebrew GCC 15.2.0_1
runtime through a temporary hashed Makevars. Both formal installs returned
status zero.

The formal TMB build had zero compiler warnings. The glmmTMB build had exactly
three RcppEigen `unused-but-set-variable` warnings and no other warning class.
These diagnostics are retained and classified rather than suppressed.

A fresh `Rscript --vanilla` process resolved TMB and glmmTMB from the overlay,
observed build-time/runtime TMB 1.9.25, and observed glmmTMB ABI 2. It resolved
lme4 2.0.6, Matrix 1.7.6, and RcppEigen 0.3.4.0.2 from the existing user
library and hashed their package/native identities.

Ten focused tests and 71 expectations pass without failure, error, warning, or
skip with the retained-repair switch. No fit, full b1 object, diagnostic
override, trusted qualification receipt, planned response, ConQuest process,
or external service call was executed by the repair controller.

## Source and runtime identities

```text
C4EManifestHash                   cb8214df9c468858ca3e4e267e815eab99918f880fb99ed6a336a2b053ef80ce
C4HCapabilityEvidenceHash         5cd3d148d28cdf59846c5108e21ddd55094da1e006829104a79104e5c08fe103
SourceArtifactRegistryHash        c26f8ea9102fdbf55f30ddb1266ee8fe219182a5fb1b8b7e69c2e8089ef3fb36
ToolchainIdentityHash             84529b8c634614bef56267a3dcedfb4b0c69b904da2e36705d82fb402cad4d99
ToolchainAuditHash                2a00c35c0cdd57d1454b042bb910b03cb31e1da40cee8b50d8c083377b253159
MakevarsSHA256                    6cb155e912126a9e6236d5d5d3c0d862594b1b9de0a2030652fac853968d0b66
BuildReceiptRegistryHash          3c13c461c2630418759258e21f2634cc5751b47290e24ded54c9c7fe476d605c
IdentityWorkerSourceSHA256        7130738bec5d7fe3172906e7d428ea182c6941a13381cf11a1c12c5d101667db
IdentityWorkerIdentityHash        450aef6861edbdd37207865a48109afe19fc4cd95694a53c9c8217933901a9b1
FreshProcessPackageRegistryHash   c868e9cfeb3d4a9ea14e717b916a599adf54575f20e956b7de662f44c4739c52
FreshProcessReceiptHash           5eb6e5c353364a303317d6e335768808a4d9c85676618da269c589a725a03ab2
ImplementationIdentityHash        e85212efaf04efadac4da225e1394a74166e111b180c791e40a4410f9fa6016c
RepairReceiptHash                 4a7c4ac0eca775e6efef8fa2713fa343c9bec4db3eec9464f0d3c7767058e3af
```

## Fresh-process package identities

| Package | Version | DESCRIPTION SHA-256 | Native DLL SHA-256 |
| --- | --- | --- | --- |
| lme4 | 2.0.6 | `00314a8e8a3e222bd2a21884d5821a814c491b912d53feac6c33dfcfc1b0e181` | `c6aa4ff473eca680451d45408030438c13ead2a71c263995cbd3ed7ecb0243a1` |
| glmmTMB | 1.1.14 | `d7fe91dc91d0a009b5e3b9e9f33df0890d6246e2b4344ed05843b1747609b80a` | `877c0150a0dcae31d6da5f8a8b6c6d8ba2a7d2de2f589c450c30907b041cddfa` |
| TMB | 1.9.25 | `32927dc02f9db0448c8109c6f854b0207629e760ff8fbd80ba186bf614a3fe8d` | `8ed917720feeaa0c9eb89df6d4f5fc9bc5ca67e82a46635182c70a97a135d8cc` |
| Matrix | 1.7.6 | `1f3cd03f517f0be0f4dabc48ac34fee7d924a6333b9a7771a8adddf692948bd2` | `dcaee28babb180785688edb2d3a3693cd165962c9f8ca4e0583aed2c5f20fac1` |
| RcppEigen | 0.3.4.0.2 | `2ca257a4749b9aa802d1095ac9be31ea4b6f52a18d3afbff223027086a7d0658` | `a1edb1adc691d8d64f5e091c01ed32c4bcbf40c652c0497f0af4a916f7fa4307` |

## Build identities

| Package | Log SHA-256 | Warning count | Warning class | Installed DLL SHA-256 |
| --- | --- | ---: | --- | --- |
| TMB | `ac5c9db00013b1c6dd6a198e1296b61a70699513fa19f5a0d97f2f4c0c77dc3b` | 0 | `none` | `8ed917720feeaa0c9eb89df6d4f5fc9bc5ca67e82a46635182c70a97a135d8cc` |
| glmmTMB | `8fd5843b59852de0eeff0d8a572f5312839ee823298e8917c68ce0423fde9a46` | 3 | `rcppeigen_unused_but_set_only` | `877c0150a0dcae31d6da5f8a8b6c6d8ba2a7d2de2f589c450c30907b041cddfa` |

## Metacognitive boundary audit

- Statistical: no likelihood or parity result was produced; ABI agreement is
  not numerical qualification.
- Software: the retained overlay is reproducible from exact source and
  toolchain bytes, but is platform- and R-build-specific.
- Security: write isolation passed; OS capability isolation of the build and
  future full-object worker was not tested.
- Provenance: child freshness is asserted by the parent, and implementation
  hashing is normalized against R JIT state.
- Diagnostics: three compiler warnings remain visible and separately typed;
  they are not counted as zero fit warnings.
- Release: all public, inferential, recovery, and execution states remain
  false.

## Disposition

The repaired environment is ready to enter a separately identified backend-
qualification worker. It is not itself backend-qualified. Four route receipts,
two pair receipts, full-object revalidation, capability isolation for that
larger worker, and every planned execution lane remain incomplete.

The retained `/private/tmp` artifact is ephemeral and must not be packaged or
treated as a portable binary. Draft.85c4i adds no export, help topic, vignette,
NEWS entry, or public-roadmap claim. Multivariate G-theory remains unsupported
publicly.
