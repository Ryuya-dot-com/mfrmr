# Weak-information hardened production-adapter rebase contract

## Identity

- Version: `0.2.3-draft.83d2b2b1g18`
- Parent b1g14 adapter contract:
  `baf48a948b86c1769aba8a574619c6ce57be17b4b5747ae935f0e430392518a1`
- Parent b1g17 hardened-generator contract:
  `90869c6874e2884b7bf5bc96c1939bd95d1b41603ea76a1d2b1c617f32c700d2`
- Adapter-rebase policy:
  `4a4d5ff4becc42e931806cc19d97449d8ec083b65b970d201230f4f4b5e19684`
- Adapter-rebase contract:
  `0373db563cd16c63693b02b968dbbd49221a77e1f666b87cc63b17cb6f786e64`

## Purpose

b1g17 made generation independent of ambient RNG but deliberately did not
connect that generator to the real fitting and high-accuracy-reference paths.
b1g18 creates separately identified descendants of b1g14 preparation,
candidate evaluation, reference evaluation, and the nonreserved dry manifest.
Historical b1g14 functions, hashes, execution, and evidence remain unchanged.

This is a paired exact-reduction test, not a calibration. The historical and
hardened paths both execute the same one nonreserved dataset at replicate 902
through glmmTMB/lme4 x ML/REML. Candidate and reference paths independently
prepare their input, so their hardened generator and pre-fit identities must
agree without sharing a mutable prepared object.

## Required equalities and intentional differences

The hardened wrapper preserves generated analysis data exactly. Consequently,
the following must agree between historical and hardened executions:

- all 36 candidate numerical and typed-state rows after excluding generator
  and pre-fit identity columns;
- all 192 candidate-selection decisions;
- all eight reference states and failures after excluding the reference
  sidecar, generator, and pre-fit identity columns;
- the complete fit/reference failure denominator; and
- cold execution versus exact checkpoint reuse.

The hardened generator hash and structural pre-fit hash must differ from their
historical counterparts because scientific lineage changed. Reference sidecar
hashes must also change because they bind those identities. Treating these
intentional hash changes as numerical disagreement would be incorrect.

## Access boundary

The b1g18 preparation path rejects calibration replicates 201--300 and
confirmation replicates 501--700 before generation. No reserved manifest is
rebuilt in this slice. `NonreservedAdapterRebaseReady=TRUE` therefore cannot
set `AuthorizationRNG01Closed=TRUE`.

Before the authorization-level RNG gate can close, a later response-free slice
must rebuild the prospective reserved manifest and shard identities against the
hardened adapters, then bind the extended runtime and isolated single-writer
runner. No reserved response may be opened during that work.
