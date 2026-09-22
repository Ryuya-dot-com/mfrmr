# FACETS/GPCM JML comparison-role contract record for mfrmr 0.2.3

Status: deterministic no-fit structural contract. This record runs no FACETS
or other external program, freezes no numerical tolerance, authorizes no new
simulation, and promotes no GPCM capability or equivalence claim.

## Decision

FACETS has one direct role in the current JML comparison portfolio: its
Rasch-family PCM/JMLE route may be compared with mfrmr PCM/JML after the
observation, category, retained-step, constraint, coordinate, identification,
boundary, and source-precision contracts pass. FACETS does not supply a direct
free-slope comparator for mfrmr's aligned single-owner GPCM JML.

The FACETS Table 7 `Estimated Discrimination` field remains a post-fit
diagnostic. FACETS documents that the statistic is computed using a 2PL/GPCM
approach without allowing it to alter the other fitted estimates. It may
therefore enter a separately labelled rank, direction, or diagnostic-
calibration analysis, but it cannot be normalized as an estimated mfrmr GPCM
slope or enter a free-slope parameter-agreement tolerance.

The contract consequently defines eight separate lanes:

1. direct common-estimand FACETS PCM/JMLE versus mfrmr PCM/JML;
2. the exact internal unit-slope GPCM/PCM kernel reduction;
3. non-unit mfrmr GPCM/JML recovery against known generating truth, with a
   FACETS PCM fit only as a deliberate misspecification control;
4. FACETS Table 7 discrimination as a diagnostic association;
5. extreme-Person low/high status and separately matched display conventions;
6. Wijayanto-style penalized GPCM JML as a different-objective sensitivity;
7. Rirt finite-box GPCM JML as a different-parameter-space sensitivity; and
8. Muraki MML-EM as a different-person-treatment sensitivity.

No result may move between these lanes merely because it is finite, close to
another estimate, or labelled JML or discrimination.

## Source boundary

The source registry binds the official FACETS product, model, Table 7, and
JMLE/UCON convergence pages; Muraki's GPCM DOI; Wijayanto et al.'s penalized
JML DOI; Hessen's fixed/random-effects and incidental-parameter qualification;
and the CRAN Rirt reference manual. FACETS 4.5.1 is the current upstream
version at the 2026-08-12 review. Historical local FACETS 4.5.0 output remains
pilot-only and is not reclassified as 4.5.1 execution evidence.

This contract records comparison roles, not a complete source audit of every
algorithmic default. A future numerical lane must still bind the exact
executable or package version, loaded implementation, control values,
parameter map, raw source precision, input, output, locale, and run date.

## Relation to the current GPCM estimator

mfrmr GPCM/JML is an identified, unpenalized fixed-effects joint likelihood.
Its positive selected-owner log slopes have a sum-zero constraint, hence
geometric mean one. It uses no statistical penalty and no finite parameter
box. `bounded GPCM` continues to describe the deliberately restricted model
and workflow scope rather than a box-constrained estimator.

Wijayanto penalized JML can select a finite point through ridge penalties on
Person coordinates and log discriminations. Rirt JML can select a constrained
point at a finite box endpoint. Muraki MML integrates Person ability rather
than fitting one coordinate per Person. These are relevant sensitivity
estimators but are not numerical implementations of mfrmr's original JML
objective.

## Portfolio consequence

The existing FACETS RSM/PCM candidate lane remains a release-spine external
dependency. This contract neither executes nor closes it. Free-slope GPCM
continues through estimator-specific local-rank, boundary, fixed-objective
stability, recovery, and uncertainty gates before any external numerical
extension is considered. The absence of a direct FACETS free-slope route is a
model-identity result, not evidence for or against mfrmr numerical quality.

## Machine-readable disposition

```text
StructuralRoleContractComplete = TRUE
FacetsPcmJmlDirectLaneDefined = TRUE
FacetsDirectFreeSlopeGpcmRouteExists = FALSE
FacetsDiscriminationDiagnosticOnly = TRUE
MfrmrUnpenalizedJmlSeparatedFromPjml = TRUE
MfrmrUnpenalizedJmlSeparatedFromFiniteBoxJml = TRUE
ExternalFitsRun = 0
ExternalExecutionAuthorized = FALSE
NumericToleranceFrozen = FALSE
BroadSimulationAuthorized = FALSE
ConfirmationAuthorized = FALSE
GpcmCorePromotionAuthorized = FALSE
```

## Identity and tests

| Artifact | SHA-256 |
| --- | --- |
| `facets-gpcm-jml-comparison-role-contract-0.2.3.R` | `e97d0ad26bfb99ebb5573ca5004d81b029bdfc2b14f22ee7a3546145a124c0b5` |
| `test-facets-gpcm-jml-comparison-role-contract.R` | `0b25f57f35fa9f424dfb2fbc097b9c7bf2ac150a4cb2e090008d3b04f4818311` |

Focused tests freeze the seven estimator identities, eight lane roles, the
PCM-only direct FACETS comparison, Table 7 diagnostic boundary, separation of
unpenalized/PJML/finite-box/MML estimators, and non-authorization state. They
also mutate FACETS slope semantics, the direct lane, and execution authority
to verify fail-closed behavior.
