# immer conditional-estimand eligibility record for mfrmr 0.2.3

Status: deterministic boundary ready, 2026-08-12. No estimator was run. This
record identifies the structural estimands that could enter a later CML/CCML
reference and prevents conditioned-out quantities or unlike objectives from
being presented as mfrmr MML/JML agreement.

## Runtime and documentation identity

| Route | installed version | function | loaded-function SHA-256 | local help basis |
| --- | --- | --- | --- | --- |
| CML | immer 1.5.13 | `immer_cml` | `4fd1943ef2929ca970df224003828d713c81bf53231dc207b5607f45c0178bc5` | Conditional maximum likelihood for the linear logistic PCM; conditions on the Person score. |
| CCML | immer 1.5.13 | `immer_ccml` | `df46616ffccb99dbda4f461ad2677b39af97468f0c744889aec040d2ad6f78b8` | Pairwise composite conditional likelihood; conditions on each item-pair score. |

The CML help documents fixed integer discrimination values through `a`; it
does not estimate free GPCM slopes. CCML uses a fixed unit trait coefficient.
Both can encode structural item, step, and rater contrasts through an exact
`W` or `A` design, but that algebraic availability is not yet a fitted
comparison.

## Eligibility boundary

The 22-row registry contains 11 estimand classes for each route. Eight rows
(four structural classes per route) are conditionally eligible:

- item-location contrasts;
- shared-step contrasts;
- criterion-specific step contrasts; and
- rater-severity contrasts.

Each requires exact category support, design-matrix, rank, constraint, and
coordinate-transformation identity. None is eligible merely because its label
or numerical value resembles an mfrmr output.

The following are explicitly ineligible for direct current-mfrmr comparison:

| Quantity | CML | CCML | Reason |
| --- | --- | --- | --- |
| Person ability | ineligible | ineligible | eliminated by conditioning |
| Population intercept/regression/variance | ineligible | ineligible | no population distribution is estimated after conditioning |
| Free discrimination | ineligible | ineligible | CML accepts fixed integer values; CCML fixes the trait coefficient |
| Objective value | not comparable with MML/JML | not comparable with MML/JML or full CML | conditional versus joint/marginal objective; CCML is composite |
| Structural covariance/SE | held | held | the conditional or composite covariance basis needs its own normalization contract |

Thus an immer CML/CCML result can later serve as a structural Rasch-family
reference. It cannot validate mfrmr person scores, latent regression,
population variance, free-slope GPCM, or MML/JML information criteria. It also
does not create native CML or CCML methods in mfrmr.

## Disposition

| Field | Value |
| --- | --- |
| `BoundaryReady` | `TRUE` |
| `StructuralEstimandRows` | `8` |
| `ExactObjectiveRows` | `0` |
| `FittedComparisonRun` | `FALSE` |
| `ToleranceFrozen` | `FALSE` |
| `CandidateBound` | `FALSE` |
| `ComparisonPassed` | `FALSE` |
| `ScientificEquivalenceInferred` | `FALSE` |
| `NativeMfrmrCMLClaim` | `FALSE` |
| `NativeMfrmrCCMLClaim` | `FALSE` |
| `FreeGPCMSlopeClaim` | `FALSE` |
| `DFFFitRankInvarianceEvaluated` | `FALSE` |
| `LargeSimulationAuthorized` | `FALSE` |
| `ReleaseAuthorized` | `FALSE` |

The next bounded action is to construct positive and adversarial fixtures for
the four structural classes: exact versus rank-deficient design matrices,
matched versus missing categories, and correct versus deliberately shifted
constraint coordinates. Only after those pass should a small fitted CML/CCML
reference be considered. No simulation is needed for this boundary step.

## Source identities

| Artifact | SHA-256 |
| --- | --- |
| `immer-conditional-estimand-eligibility-0.2.3.R` | `393215437cbc2246df367ddee865b3a85ae048fcb90dcedbd9a19addcfcde85c` |
| `test-immer-conditional-estimand-eligibility.R` | `06b17ae2608c3614479c06db7cd3cb068b421cfdcf5ce38230138a6da6b90f3d` |
