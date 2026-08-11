# ConQuest/TAM/immer tolerance-source audit for 0.2.3

Status: repository-only source audit, 2026-08-11. This record selects no
numeric threshold and authorizes no confirmation.

Audit ID: `conquest-tam-immer-tolerance-source-audit-20260811-v1`.

## Audited identities

| Source | Version or SHA-256 |
| --- | --- |
| ConQuest executable | 5.47.5 Demonstration Version; `61d0b87f379f1578466b789866366c5cc633d31a6c3501e872861d44ff02da48` |
| ConQuest manual PDF | `60bce1a39f5430fd304178356fb943721f9f72c0ddee70a9866c28c87017459f` |
| TAM | 4.3-25 |
| loaded `TAM:::tam_mml_control_list_define` | `2700aeb3af7f8f40ad5ea34383110780ada138897fac9e824e95209bbe052e95` |
| immer | 1.5-13 |
| loaded `immer::immer_jml` | `31163e6eedba375989dbd14f7d4b270a9379839fddde25be43c5ee997a09692b` |

## Findings

- ConQuest documents optimizer stopping rules and quadrature-node controls.
  It also documents that screen `decimals` is ignored for file output. It
  does not define CSV significant digits, a file-rounding rule, or a
  cross-program scientific-equivalence threshold.
- TAM documents default MML controls including 21 quadrature nodes,
  `convD=0.001`, `conv=1e-4`, and `convM=1e-4`, and exposes controls for nodes,
  QMC, stochastic integration, and maximum iterations. These are within-fit
  algorithm controls, not tolerances for agreement with ConQuest or mfrmr.
- immer documents JML defaults including `conv=1e-5`,
  `conv_update=1e-5`, and `maxiter=1000`. These are also within-fit stopping
  controls, not cross-engine equivalence criteria.
- TAM's official examples include ConQuest-parameterized PCM/RSM and faceted
  models, but do not specify a numerical rule by which the two programs are
  declared scientifically equivalent.

Therefore no audited package manual supplies `EXT-CQ-TOL`. Optimizer stopping
tolerances, export lexical units, integration stability, and scientific
acceptance must remain separate. A prospective threshold may use the opened
calibration to estimate an engineering error budget, but requires an explicit
estimand-level rationale and must be frozen before the disjoint candidate
result is opened. The calibration cannot be relabelled as having passed that
new rule.
