# JML extreme-Person paired recovery pilot record for mfrmr 0.2.3

Status: Draft.74 repository-only calibration record, 2026-08-09.

## Execution

The frozen Draft.74 pilot ran all 90 datasets from
`jml-extreme-profile-recovery-contract-0.2.3.md` with R 4.6.1 and development
mfrmr 0.2.3. It produced 2,700 recovery rows: 1,350 matched structural truth
rows for each of `raw_finite_jml` and `extended_profile_limit`. Person rows
were excluded by construction.

All 90 raw fits returned; all forced extremes had the requested signed typed
state; all paired structural keys matched; no run errored; and no fit with a
free extreme Person was marked inference-ready. Sixty-eight datasets required
and passed the finite-cap profile verification. Twenty-two datasets had no
free extreme Person and used the declared profile no-op. The remaining eight
zero-forced-fraction datasets contained spontaneous extreme Persons and were
therefore profiled rather than treated as no-ops.

Fit return is not the same as convergence or inference eligibility. Raw
convergence severity was `pass` for 30/30 RSM, 29/30 PCM, and 29/30 GPCM
runs; one PCM and one GPCM run remained `review`. Raw fit readiness was
`ready` for 6 RSM and 9 PCM datasets, all without free extreme Persons;
`ready_with_exclusions` covered 24 RSM and 20 PCM runs; all 30 GPCM runs and
one PCM run were `review`. Thus 15 raw fits were inference-ready, but none of
the 68 datasets with a free extreme Person was. Review rows remain in the
declared denominators and descriptive recovery output; `ContractPassed`
denotes execution and pairing feasibility, not estimator acceptance.

## Boundary and paired-estimate diagnostics

| Model | Runs | Forced extremes | Actual free extremes | Spontaneous extremes | Maximum cap-64 gap | Maximum raw/profile structural change |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| RSM | 30 | 280 | 292 | 12 | 0 | 1.83e-6 |
| PCM | 30 | 280 | 286 | 6 | 0 | 5.94e-6 |
| GPCM | 30 | 280 | 295 | 15 | 1.94e-11 | 3.23e-6 |

The global largest paired aligned-coordinate change was `5.935103e-6`.
Across cells the paired RMS change ranged from zero to about `1.22e-6`.
These small differences show that the finite optimizer traces were already
far along the extreme-Person likelihood rays in this design. They do not show
that the original full-vector likelihood attained a finite maximum.

The 90 raw fits used about 41.4 elapsed seconds and the profile operations
about 1.9 elapsed seconds in this single local run. Those descriptive totals
are not a benchmark or runtime threshold.

## Descriptive structural recovery

The table reports RMSE after the prespecified facet/step alignment and GPCM
log-slope transformation. Raw and profile values agree at the shown precision;
this is not an equivalence threshold.

| Model | Information | Extreme fraction | Raw RMSE | Profile RMSE |
| --- | --- | ---: | ---: | ---: |
| RSM | high | 0 | 0.0992 | 0.0992 |
| RSM | high | 0.10 | 0.0767 | 0.0767 |
| RSM | high | 0.25 | 0.0858 | 0.0858 |
| RSM | low | 0 | 0.228 | 0.228 |
| RSM | low | 0.10 | 0.313 | 0.313 |
| RSM | low | 0.25 | 0.293 | 0.293 |
| PCM | high | 0 | 0.128 | 0.128 |
| PCM | high | 0.10 | 0.179 | 0.179 |
| PCM | high | 0.25 | 0.169 | 0.169 |
| PCM | low | 0 | 0.253 | 0.253 |
| PCM | low | 0.10 | 0.301 | 0.301 |
| PCM | low | 0.25 | 0.315 | 0.315 |
| GPCM | high | 0 | 0.165 | 0.165 |
| GPCM | high | 0.10 | 0.127 | 0.127 |
| GPCM | high | 0.25 | 0.167 | 0.167 |
| GPCM | low | 0 | 0.289 | 0.289 |
| GPCM | low | 0.10 | 0.291 | 0.291 |
| GPCM | low | 0.25 | 0.350 | 0.350 |

With five replicates per cell, nonmonotone entries are expected and cannot
support a sample-size or extreme-fraction rule. In particular, the table does
not establish that an extreme fraction improves or worsens recovery in
general.

## Interpretation

This pilot separates two problems that are often conflated. The profile route
addresses likelihood non-attainment caused by independently free extreme
Persons and gives structural estimates at the extended boundary supremum.
The near-identical recovery summaries show that this operation does not, by
itself, repair the ordinary JML incidental-parameter bias induced by estimating
many Person effects from finite response panels.

Accordingly, neither the raw finite trace nor the profile-limit result is
relabelled as a finite original-likelihood MLE, a corrected JML estimator, or
a preferred estimator. Profile standard errors and coverage remain
unavailable. The pilot has no evidence-readiness, checklist, public API,
default, candidate, or confirmation effect.

## Next decision slice

The next comparison must add external adjustment and finite-item-bias-
correction modes as separate factorial identities, then expand replication
and sparse/weak-link, weighting, missingness, workload, category, interaction,
anchor, and owner strata. Only a prospectively frozen grid with supported
uncertainty and retained failures can answer whether any correction improves
bias or RMSE without unacceptable coverage or stability costs.
