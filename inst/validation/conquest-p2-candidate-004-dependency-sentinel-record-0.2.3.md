# Candidate-004 semantic dependency sentinel for mfrmr 0.2.3

Status: `candidate_004_semantic_dependency_sentinel_frozen`, 2026-08-15.

- Specification:
  `0.2.3-conquest-p2-candidate-004-dependency-sentinel-v1`
- Contract: `mfrmr_conquest_p2_candidate_004_dependency_sentinel_v1`

## Purpose

Candidate 004 is a versioned historical observation, not a timeless property of
all future mfrmr or ConQuest builds. This sentinel separates two questions:

1. Is the historical candidate evidence still preserved and independently
   reviewable under its exact recorded source/runtime scope?
2. Does that evidence still attach to the current source and runtime?

The answers may differ. A changed likelihood does not erase the historical
result, but it does detach that result from the new implementation. A changed
parser need not trigger another proprietary fit; it requires reconstruction
from retained raw outputs. A changed ConQuest runtime does not retroactively
alter the recorded 5.47.5 result; a claim about the new runtime requires a new
sentinel and successor candidate.

## Semantic change checklist

Every proposed evidence use must declare whether any of these meanings changed:

- [ ] RSM/PCM MML likelihood, weights, population model, or deviance identity.
- [ ] Free coordinates, constraints, anchoring, A matrix, or ownership.
- [ ] Category support, score recoding, steps, or response layout.
- [ ] Quadrature, optimizer target, convergence, polishing, or q selection.
- [ ] External output selection, token parsing, termination, or schema meaning.
- [ ] Coordinate, variance, deviance, probability, or ordering transformation.
- [ ] ConQuest version, edition, architecture route, expiry, or runtime semantics.
- [ ] Frozen candidate budget, denominator, scope, or run-once binding.
- [ ] Retained response, command, output, fit, or journal semantics.
- [ ] Documentation/tests only, with none of the above meanings changed.
- [ ] Unknown or mixed impact requiring manual dependency classification.

File paths and commit identifiers may help locate a change, but they do not
decide its scientific effect. No byte-level equality is a scientific gate.

## Minimal consequences

| semantic change | historical evidence | next action |
| --- | --- | --- |
| Likelihood, constraint, category, integration, or optimizer | retain with exact historical scope | detach from current source; use a successor candidate for a current-source claim |
| Parser or coordinate transformation | retain raw artifacts | restart independent calculation from raw artifacts; do not rerun ConQuest |
| ConQuest runtime identity | retain the recorded runtime claim | run a data-free sentinel and a successor only if a new-runtime claim is needed |
| Frozen acceptance contract | retain but stop | resolve a prospective-contract integrity incident; never rewrite the opened candidate post-output |
| Raw evidence semantics | retain records but quarantine primary evidence | block review; do not repair or rerun candidate 004 |
| Documentation/tests only | retain and continue | no scientific reset |
| Unknown or mixed | retain pending classification | block until a semantic reviewer classifies it |

Worst-case consequences compose. Evidence or frozen-contract incidents take
precedence over current-source detachment; unknown impact fails closed. No
classification authorizes a candidate-004 rerun, wider execution, P3, a public
claim, or scientific equivalence.

## Current decision

- `SemanticDependencySentinelFrozen=TRUE`
- `SemanticChangeDeclarationRequired=TRUE`
- `ByteIdentityIsScientificGate=FALSE`
- `PathChangeAloneIsScientificDecision=FALSE`
- `Candidate004RerunAuthorized=FALSE`
- `EvidencePromotionAuthorized=FALSE`
- `PublicClaimAuthorized=FALSE`
- `ScientificEquivalenceInferred=FALSE`
