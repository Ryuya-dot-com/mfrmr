# Fixed-calibration G5 lane disposition for mfrmr 0.2.4

Status: `G5_complete_public_scope_narrowed`, 2026-08-23.

## Decision

The 0.2.4 portable-calibration release proceeds with the independently
confirmed one-scale RSM/PCM MML core under its fixed N(0,1) scoring basis. The
four optional lanes are unavailable for portable calibration in 0.2.4. This is
a scope decision, not a statement that their existing fitted-object analysis
routes have been removed.

| Lane | 0.2.4 portable-calibration disposition | Executable reason | Existing fitted-object route |
| --- | --- | --- | --- |
| Estimated-population/latent-regression MML | Unavailable | Draft extraction rejects an active population model, and schema v1 accepts only the fixed-standard-normal basis. | Population-model prediction remains available through the fitted model under its documented conditions. |
| Bounded GPCM MML | Unavailable | Draft extraction rejects GPCM; schema v1 has no relative-slope coordinate/owner contract; the artifact-only scorer reconstructs RSM/PCM, not GPCM. | Bounded aligned single-owner GPCM fitting, summaries, diagnostics, plots, comparisons, information, and fitted-object posterior scoring remain available under their existing boundaries. |
| JML with a post-hoc scoring prior | Unavailable | Draft extraction rejects JML, and the core artifact does not promote a post-hoc prior into an operational scoring basis. | Fitted-object post-hoc posterior summaries remain distinct from original JML Person estimates. |
| Bounded GPCM JML | Unavailable | Both the GPCM artifact contract and the explicit JML scoring-prior parent requirements are outside 0.2.4. | Existing GPCM/JML fitting remains subject to its boundary and readiness reporting. |

## GPCM maturity assessment

GPCM is already a substantial fitted-model capability. The public model is the
aligned single-owner relative-slope GPCM (`slope_facet == step_facet`) with
geometric-mean-one relative slopes. MML and JML fitting, summaries, probability
and category views, numerical-readiness reporting, same-basis comparison,
diagnostic/reporting routes, and fitted-object posterior scoring exist, with
route-specific caveats. It is not an unrestricted or multiplicative
many-facet GPCM.

The 0.2.4 gap is narrower but foundational: a portable GPCM artifact would need
to store and validate the slope owner, step owner, relative slopes, population
scale, identification transformation, parameter-level readiness, and exact
probability reconstruction. It would also need independent artifact-only
posterior oracles and save/load mutation tests. None of those semantics may be
inferred from the source fit after freezing. Because schema v1 and the current
pure scorer deliberately omit that layer, existing fitted-object GPCM support
cannot be relabelled as portable GPCM calibration.

## Public-document boundary

Public help, README, vignettes, runtime messages, and NEWS should say only that
portable calibration in 0.2.4 supports the promoted RSM/PCM MML envelope and
should direct GPCM users to the existing fitted-object routes. Gate names,
claim-ledger rows, CI run IDs, hashes, authorization mechanics, test
denominators, and internal helper names remain in the roadmap and validation
records. NEWS records the completed user-visible result, not this adjudication
history.

## Consequence

- `G5Complete=TRUE`
- `PortableCalibrationCore=RSM_PCM_MML_FIXED_N01`
- `OPT01PortableCalibration=UNAVAILABLE_0_2_4`
- `OPT02PortableCalibration=UNAVAILABLE_0_2_4`
- `OPT03PortableCalibration=UNAVAILABLE_0_2_4`
- `OPT04PortableCalibration=UNAVAILABLE_0_2_4`
- `ExistingFittedObjectGPCMUnchanged=TRUE`
- `PublicAPIAuthorized=FALSE`
- `NextGate=G6-release-candidate-hardening`
