# Weak-information RNG-hardened generator contract

## Identity

- Version: `0.2.3-draft.83d2b2b1g17`
- Scope: repository-internal, nonreserved G-theory generator replay
- Parent hardening contract:
  `9ea428bfec87509cacdadba6250d837aef5090c07550f2c0603b79164f2c58c0`
- Parent portable blocker decision:
  `e4e32bc3fc93c4469ce88ccf46e91866b6a22ef3e81d71a9a3dc483d767f1799`
- RNG policy:
  `9d54aeee4e7cf9bc3b20e8e96fa99dfa79febf070cc0d732377287ce897e20a9`
- Hardened-generator contract:
  `90869c6874e2884b7bf5bc96c1939bd95d1b41603ea76a1d2b1c617f32c700d2`

## Purpose and boundary

Draft.83d2b2b1g16 demonstrated that the historical b1g2a generator is not
self-contained: the same integer seed can generate different data when the
ambient uniform RNG kind changes. Replacing that historical function would
invalidate its scientific hash and all descendant evidence without preserving
the counterexample.

Draft.83d2b2b1g17 therefore leaves the historical function untouched and adds
a separately versioned wrapper. The wrapper explicitly fixes all three R RNG
coordinates to `Mersenne-Twister`, `Inversion`, and `Rejection`, records them
in generator identity, retains the complete historical identity as its parent,
and restores the caller's RNG kind and `.Random.seed` on success or error.

This is not a reserved runner. The wrapper rejects calibration replicates
201--300 and confirmation replicates 501--700. It cannot issue an authorization
record. Its purpose is to establish a stable future generator dependency before
the production adapters and runtime contract are rebuilt.

The historical function-body hash is consumed from the frozen b1g16 parent
contract, not recomputed after exercising the function. In this R environment,
serialized closure-body digests can change across execution state even when
the language bodies remain `identical()`. New b1g17 scientific function hashes
therefore use canonical deparsed formals and bodies and reproduce whether the
replay runs before or after contract construction. The wrapper is additionally
bound by its generated identity and independently recorded source-file SHA;
source content, portable scientific identity, and site execution state are not
silently collapsed into one hash.

## Source basis

R documents uniform, normal, and sample RNG kinds as distinct reproducibility
coordinates and recommends specifying them explicitly when reproduction under
a later R version is required:
<https://stat.ethz.ch/R-manual/R-devel/library/base/help/Random.html>.

An integer seed alone is therefore not the complete random-generation
identity. This contract treats the three RNG kinds, seed, generator function
hash, historical parent identity, scenario identity, design hash, and generated
data hashes as one scientific dependency.

## Frozen replay

All 30 registered weak-information scenarios are regenerated at nonreserved
replicate 901 under two caller states:

1. `Mersenne-Twister/Inversion/Rejection`; and
2. `Wichmann-Hill/Inversion/Rejection`.

The wrapper resets its internal state to the required first configuration in
both cases. For every scenario, the hardened generator hash, historical parent
hash, and analysis-data hash agree exactly across caller states. Both caller
states are restored byte-for-byte after each call. Separate tests also cover a
caller with no pre-existing `.Random.seed` and the reserved-access error path.

The replay uses 60 nonreserved generated datasets. These are deterministic
engineering fixtures, not Monte Carlo evidence, and they do not contribute to
calibration, coverage, bias, RMSE, or D-study operating-characteristic claims.

## Component gates

| Gate | Result | Interpretation |
|---|---|---|
| `RNG-GEN-01` | pass | all three RNG kinds are fixed and recorded |
| `RNG-REPLAY-01` | pass | all 30 scenarios agree across ambient RNG kinds |
| `RNG-STATE-01` | pass | caller RNG kind and seed are restored |
| `RNG-IDENTITY-01` | pass | hardened and historical identities are retained |
| `RNG-BAND-01` | pass | reserved calibration and confirmation are rejected |
| `RNG-ADAPTER-01` | block | existing fitting/reference adapters still use the historical generator |

`HardenedGeneratorReady=TRUE` and `RNG01ProspectivelyResolved=TRUE` refer only
to the separately identified nonreserved wrapper. The b1g16 authorization gate
`RNG-01` remains open until every downstream candidate, reference, manifest,
checkpoint, and preflight dependency is rebuilt against the hardened identity.

## Required next work

1. Rebase the nonreserved production candidate/reference adapters on the new
   generator identity and prove exact candidate/reference data agreement.
2. Rebuild, rather than edit, every affected manifest and contract hash.
3. Repeat nonreserved dry execution and exact-resume/corruption controls.
4. Only after that integration succeeds may `AuthorizationRNG01Closed` become
   true; runtime, thread, process, runner, lock, root, and capacity gates still
   remain separate blockers.
5. Do not open replicate 201 or create the reserved target during this work.

Accordingly, `AuthorizationActivationEligible=FALSE`,
`LargeSimulationMayStart=FALSE`, and `Replicate201MayBeOpened=FALSE` remain
frozen.
