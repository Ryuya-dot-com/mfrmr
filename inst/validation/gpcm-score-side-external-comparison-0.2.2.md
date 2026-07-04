# Bounded-GPCM score-side external comparison evidence (0.2.2)

This fixed evidence artifact strengthens the bounded-GPCM score-side
contract by comparing the package's adjacent-category probability kernel
with external GPCM probability traces from `mirt` and `TAM`. The comparison
is intentionally kernel-level: it does not claim full many-facet parameter
equivalence, FACETS score-side equivalence, operational scoring equivalence,
or calibrated uncertainty coverage.
`mirt`, `TAM`, and `eRm` are not treated as many-facet MFRM comparators.

- `GPCMScoreSideExternalComparisonStatus = "ok"`;
- `ExternalComparisonRows = 32`;
- `FailedChecks = 0`.

## Package Roles

```
 Package Version                                                     Role
   mfrmr   0.2.2            bounded-GPCM score-side contract under review
    mirt  1.46.1    external GPCM probability trace via gpcmIRT/probtrace
     TAM  4.3.25   external GPCM probability trace via tam.mml.2pl/rprobs
     eRm  1.0.10 PCM/CML boundary evidence; no free-slope GPCM comparison
```

## Gate Checks

```
                               Check     Value Threshold Passed
                      mirt_available 1.000e+00     1e+00   TRUE
                       TAM_available 1.000e+00     1e+00   TRUE
          eRm_pcm_boundary_available 1.000e+00     1e+00   TRUE
     external_probability_trace_rows 3.200e+01     1e+00   TRUE
 external_probability_trace_max_diff 5.345e-06     5e-04   TRUE
                                                                                 Detail
                                                                         version=1.46.1
                                                                         version=4.3.25
 version=1.0.10; eRm is used as PCM/CML boundary evidence, not free-slope GPCM evidence
                                                 mirt/TAM mapped-kernel comparison rows
                       all external mapped-kernel comparisons pass their row thresholds
```

## Comparison Rows

```
 Package Item                     Comparison MaxAbsDiff Threshold Passed
    mirt   I1      probtrace_vs_local_kernel  3.331e-16     1e-10   TRUE
    mirt   I1 expected_score_vs_local_kernel  8.882e-16     1e-10   TRUE
    mirt   I1       variance_vs_local_kernel  2.220e-16     1e-10   TRUE
    mirt   I1      derivative_identity_local  4.151e-11     1e-06   TRUE
    mirt   I2      probtrace_vs_local_kernel  2.220e-16     1e-10   TRUE
    mirt   I2 expected_score_vs_local_kernel  4.441e-16     1e-10   TRUE
    mirt   I2       variance_vs_local_kernel  1.943e-16     1e-10   TRUE
    mirt   I2      derivative_identity_local  4.084e-11     1e-06   TRUE
    mirt   I3      probtrace_vs_local_kernel  2.220e-16     1e-10   TRUE
    mirt   I3 expected_score_vs_local_kernel  4.441e-16     1e-10   TRUE
    mirt   I3       variance_vs_local_kernel  1.110e-16     1e-10   TRUE
    mirt   I3      derivative_identity_local  5.027e-11     1e-06   TRUE
    mirt   I4      probtrace_vs_local_kernel  3.331e-16     1e-10   TRUE
    mirt   I4 expected_score_vs_local_kernel  8.882e-16     1e-10   TRUE
    mirt   I4       variance_vs_local_kernel  1.665e-16     1e-10   TRUE
    mirt   I4      derivative_identity_local  6.155e-11     1e-06   TRUE
     TAM   I1         rprobs_vs_local_kernel  1.797e-06     5e-04   TRUE
     TAM   I1 expected_score_vs_local_kernel  2.878e-06     5e-04   TRUE
     TAM   I1       variance_vs_local_kernel  2.947e-06     5e-04   TRUE
     TAM   I1      derivative_identity_local  3.873e-11     1e-06   TRUE
     TAM   I2         rprobs_vs_local_kernel  1.672e-06     5e-04   TRUE
     TAM   I2 expected_score_vs_local_kernel  2.572e-06     5e-04   TRUE
     TAM   I2       variance_vs_local_kernel  2.594e-06     5e-04   TRUE
     TAM   I2      derivative_identity_local  3.217e-11     1e-06   TRUE
     TAM   I3         rprobs_vs_local_kernel  5.345e-06     5e-04   TRUE
     TAM   I3 expected_score_vs_local_kernel  7.246e-06     5e-04   TRUE
     TAM   I3       variance_vs_local_kernel  1.043e-05     5e-04   TRUE
     TAM   I3      derivative_identity_local  3.932e-11     1e-06   TRUE
     TAM   I4         rprobs_vs_local_kernel  1.600e-06     5e-04   TRUE
     TAM   I4 expected_score_vs_local_kernel  2.677e-06     5e-04   TRUE
     TAM   I4       variance_vs_local_kernel  2.392e-06     5e-04   TRUE
     TAM   I4      derivative_identity_local  2.780e-11     1e-06   TRUE
                                                   Detail
          mirt gpcmIRT IRTpars mapping: local tau_k = b_k
      expected score from mirt::probtrace() probabilities
      score variance from mirt::probtrace() probabilities
 dE/dtheta = a * Var under the mapped external parameters
          mirt gpcmIRT IRTpars mapping: local tau_k = b_k
      expected score from mirt::probtrace() probabilities
      score variance from mirt::probtrace() probabilities
 dE/dtheta = a * Var under the mapped external parameters
          mirt gpcmIRT IRTpars mapping: local tau_k = b_k
      expected score from mirt::probtrace() probabilities
      score variance from mirt::probtrace() probabilities
 dE/dtheta = a * Var under the mapped external parameters
          mirt gpcmIRT IRTpars mapping: local tau_k = b_k
      expected score from mirt::probtrace() probabilities
      score variance from mirt::probtrace() probabilities
 dE/dtheta = a * Var under the mapped external parameters
     TAM GPCM IRT mapping: local tau_k = beta + tau.Cat_k
                           expected score from TAM rprobs
                           score variance from TAM rprobs
 dE/dtheta = a * Var under the mapped external parameters
     TAM GPCM IRT mapping: local tau_k = beta + tau.Cat_k
                           expected score from TAM rprobs
                           score variance from TAM rprobs
 dE/dtheta = a * Var under the mapped external parameters
     TAM GPCM IRT mapping: local tau_k = beta + tau.Cat_k
                           expected score from TAM rprobs
                           score variance from TAM rprobs
 dE/dtheta = a * Var under the mapped external parameters
     TAM GPCM IRT mapping: local tau_k = beta + tau.Cat_k
                           expected score from TAM rprobs
                           score variance from TAM rprobs
 dE/dtheta = a * Var under the mapped external parameters
```

## Interpretation boundary

- `mirt`: `gpcmIRT` IRT parameters map to the local kernel with
  `tau_k = b_k`; `mirt::probtrace()` is the external probability target.
- `TAM`: `tam.mml.2pl(..., irtmodel = "GPCM")` IRT parameters map to
  the local kernel with `tau_k = beta + tau.Cat_k`; `rprobs` is the
  external probability target.
- `eRm`: `PCM()` is retained as unit-slope/CML boundary evidence only.
  It is not treated as a free-slope GPCM score-side comparator.
- The comparison supports probability, expected-score, score-variance,
  and `dE/dtheta = a * Var` contract rows. It does not validate FACETS
  raw-score-to-measure scorefile semantics under free discrimination.

## Files

- `gpcm-score-side-external-comparison-0.2.2-results.csv`
- `gpcm-score-side-external-comparison-0.2.2-checks.csv`
