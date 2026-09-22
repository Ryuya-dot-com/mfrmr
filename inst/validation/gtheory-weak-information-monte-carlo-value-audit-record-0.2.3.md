# Draft.83d2b2b1g15a Monte Carlo value and precision audit record

Status: completed repository-only response-free audit, 2026-08-10. No
calibration or confirmation response was generated, read, summarized, or
used, and no execution authorization was issued.

## Frozen identities

| Identity | SHA-256 |
| --- | --- |
| upstream b1g15 authorization-preflight contract | `44a6d4e2677af111e6eeeae8b7b3143ce8521db34da1769a86b85f32c63ca551` |
| upstream b1g11 acceptance policy | `7962e47df285812d8c785f206d51925b44a13d02037b7b40a619cb80ce833a62` |
| b1g15a precision-purpose policy | `f91a2b54fd766a35255097feaaf27e0be446a2e5f454c6b19f7eb85686a5e58d` |
| b1g15a function registry | `c1c95b4f1301cdb019baad61069aa8222160a601c4d1e7a62a5789085c9b0ab7` |
| b1g15a contract object | `9695149f99885bd4647c40466fef37e99cf321aa7786e232476586730f4fa1d8` |
| b1g15a audit object | `67987463d2fa587441714da5b6a8fc9046f6c2cc3ec604a416a264762d868f45` |
| source artifact | `97d9798e3e190a62d39b596916020f72b7ae71eebd3e6a8f92c53e2ebe3d0f85` |
| contract artifact | `cfd6c59c2c2857a1a6f48166c9ca415a6526bde863b1232b340bd538f33974bb` |
| focused test artifact | `63036786f1474efa84dc4ed67d623d2955c5eef3d6f844d46c6af92530c1db98` |

## Effective simulation size

The audit independently reconstructs 3,000 generated datasets, 108,000
candidate-fit rows, 576,000 candidate-decision rows, and 24,000 reference
rows. Only the 3,000 datasets are independent Monte Carlo units, and the
primary denominator is not 3,000: it is at most 100 within each
`scenario x method x model-role` cell.

The candidate-fit count is 36 times the independent-dataset count. Methods
are paired within each generated dataset; roles, optimizer profiles,
candidates, and references are repeated computations. The audit therefore
rejects any interpretation of 108,000 fits or 576,000 decisions as independent
replications.

## Precision result

| Phase | Planned n/cell | Worst-case Bernoulli MCSE | 0-event one-sided 95% upper |
| --- | ---: | ---: | ---: |
| feasibility | 25 | 0.100000 | 0.112928 |
| calibration | 100 | 0.050000 | 0.029513 |
| confirmation | 200 | 0.035355 | 0.014867 |

For a complete 100-trial calibration denominator, the probability of seeing
at least one event is 0.633968 at a true 1% rate, 0.867380 at 2%, 0.952447 at
3%, and 0.994079 at 5%. At event rates 0.05/0.95, the MCSE is 0.021794; at
0.80 it is 0.040000.

The 3% rate, 3% upper-bound benchmark, and 95% detection benchmark belong only
to the response-free purpose audit. They do not change or enter the b1g11
candidate-selection rule and are not a production error tolerance.

All figures in this section assume a complete resolved denominator. They are
not yet empirical precision. Reference-unresolved rows reduce the binary
denominator and must cause cell-specific recomputation. Therefore
`CalibrationPrecisionEvidenceReady=FALSE` remains correct even though the
design-purpose audit passes.

## Broad-performance comparison

The audit records these simple binomial planning requirements:

| Probability | n for MCSE <= 0.01 | n for MCSE <= 0.005 | n for approximate 95% half-width <= 0.01 |
| ---: | ---: | ---: | ---: |
| 0.05 | 475 | 1,900 | 1,825 |
| 0.95 | 475 | 1,900 | 1,825 |
| 0.80 | 1,600 | 6,400 | 6,147 |
| 0.50 | 2,500 | 10,000 | 9,604 |

Bias, RMSE, rank recovery, facet separation, and D-study stability require
their own empirical variance and precision targets, so the table is not a
universal sample-size rule.

## Decision

The audit conclusion is
`proportionate_for_numerical_calibration_only_not_broad_validation`.
The 30-by-100 calibration is retained because its purpose is candidate
numerical-rule selection, safety-error rejection, and a valid negative result.
It is not promoted to general estimator validation.

The following are true:

- `PrecisionPurposeContractFrozen`;
- `NumericalCalibrationDesignPurposeJustified`;
- `MonteCarloValueAuditReady`;
- `CurrentCalibrationDesignRetained`; and
- `BroadClaimsRequireSeparatePrecisionDesignedStudy`.

The following remain false:

- `CalibrationPrecisionEvidenceReady`;
- broad bias/RMSE/coverage support;
- D-study operating-characteristic support;
- a universal sample-size rule;
- activation-eligibility change or execution-authorization issuance;
- calibration execution, generation, and result viewing;
- confirmation, inference, coefficient, and decision readiness.

Five focused tests with 87 explicit assertions pass. They reproduce binomial
MCSE, exact zero-event bounds, event-detection probabilities, replication
requirements, paired-difference MCSE, exact upstream and object identities,
workload decomposition, purpose-limited flags, and mutation rejection.

The next admissible gate remains a separately reviewed b1g16 immutable
activation artifact and authorized single-shard runner. It must report actual
resolved denominators after the complete run; nominal `n=100` cannot rescue a
noninformative cell, and no calibration outcome may drive early stopping.
