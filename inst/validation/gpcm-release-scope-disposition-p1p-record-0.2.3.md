# GPCM release-scope disposition P1p record (0.2.3)

## Question

P1p decides whether P1o's finite-grid result should trigger further continuous
coefficient-ratio work, and which remaining GPCM gate has priority for 0.2.3.
It is a no-fit portfolio audit. It does not alter the frozen checklist,
claim-disposition table, public capability registry, or any numerical rule.

## Evidence boundary

P1o completed a 336-cell four-fixture finite-grid registry and verified all
1,362 stored reflection identities. The result remains explicitly finite:
`ContinuousGlobalProfileCertified` is false.

P1p then checks three independent scope sources:

1. the public GPCM capability registry;
2. the 106-row release-evidence checklist; and
3. the 106-row claim-disposition profile with exact item/order identity.

The public registry advertises no continuous ratio-profile or two-target-face
closure capability. The audited public rows retain these statuses:

| Capability | Public status |
| --- | --- |
| core fit and summary | `supported_with_caveat` |
| exploratory diagnostics | `supported_with_caveat` |
| DFF screening | `supported_with_caveat` |
| MCMC backends | `deferred` |
| full FACETS score-side review | `blocked` |

The continuous theorem is also not an independent release-spine checklist
item. It therefore cannot become an accidental 0.2.3 obligation merely because
the internal P1 lineage exposed an interesting boundary geometry.

## Priority decision

The next actual GPCM release-spine blocker is checklist row 88,
`gpcm_owner_evidence_partition`, whose status remains `review`. It requires
Criterion-owned and Rater-owned aligned GPCM evidence to retain separate slope
owner, step owner, slope composition, latent-dimension, estimator, ability-
scale, category-support, and runtime identities.

This is more consequential than extending the ratio grid. A successful
Criterion-owned fit cannot validate Rater-owned discrimination, while public
core wording currently remains caveated pending that distinction.

Fit and DFF promotion stay claim-conditional:

- incomplete GPCM fit operating characteristics use
  `retain_gpcm_fit_as_exploratory_no_decision`;
- incomplete GPCM DFF specificity uses
  `disable_gpcm_dff_inferential_promotion`.

No simulation is authorized by P1p. The next owner-specific step should first
reuse the existing 120-row identity pilot and locate deterministic propagation
gaps before deciding whether additional replication can change a retained
public decision.

## Machine-readable disposition

```text
FiniteGridClaimRetained = TRUE
ContinuousRatioTheoremAdvertisedPublicly = FALSE
ContinuousRatioTheoremRequiredForRetainedPublicScope = FALSE
ContinuousRatioWorkDeferred = TRUE
NextReleaseSpineItem = gpcm_owner_evidence_partition
NextReleaseSpineItemSelected = TRUE
FitAndDFFFallbacksPreserved = TRUE
ReleaseScopeDispositionComplete = TRUE
GPCMCorePromotionAuthorized = FALSE
ContinuousGlobalProfileCertified = FALSE
HessianInferenceAuthorized = FALSE
DFFFitRankAuthorized = FALSE
BroadSimulationAuthorized = FALSE
SelectionAuthorized = FALSE
ConfirmationAuthorized = FALSE
```

Thus the bounded finite-grid evidence is retained, continuous work is deferred,
and no public status is promoted. The finite result improves the foundation;
it does not erase the owner-specific, recovery, uncertainty, diagnostic, DFF,
external, or candidate gates.

## Reproduction

- runner: `inst/validation/gpcm-release-scope-disposition-p1p-0.2.3.R`;
- test: `tests/testthat/test-gpcm-release-scope-disposition-p1p.R`;
- runner SHA-256:
  `3859a0f9275928d034a100d2653d548780f751bebaae9f8b7a1f3b75e5271323`;
- test SHA-256:
  `8e18d4039441db4ba1c234a6f20e071c99d65c768f7051eefeb058627f4b8870`.

Routine tests freeze the checklist mapping, public status boundary, fallback
codes, and finite-versus-continuous disposition. A stored P1o replay is opt-in
through `MFRMR_RUN_P1P_PILOT=true` and `MFRMR_P1O_RESULT=<path>`.
