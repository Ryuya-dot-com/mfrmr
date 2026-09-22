# JML extreme-Person profile-limit prototype record for mfrmr 0.2.3

Status: Draft.73 repository-only verification record, 2026-08-09.

## Implementation

`jml-extreme-profile-limit-prototype-0.2.3.R` constructs the exact reduced JML
objective after removing only independently free typed extreme Persons. It
starts the reduced optimizer from the raw finite fit, preserves every
structural coordinate basis, reconstructs a sequence of finite original-JML
vectors at ability caps 4, 8, 12, 16, 24, and 32, and compares those values
with the reduced supremum. Public fits, estimates, defaults, and readiness are
unchanged.

The fixed verification used R 4.6.1 and development mfrmr 0.2.3. The RSM
fixture has 16 Persons and 144 rows; the PCM/GPCM fixtures use the synthetic
`example_core` data with 48 Persons and 768 rows. In each model the first
Person was forced to the maximum and the second to the minimum.

## Selected results

| Model | Excluded Persons | Excluded rows | Raw finite log L | Profile-limit log L | Gain | Cap-32 gap | Maximum absolute structural change |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| RSM | 2 | 18 | -172.8268849686943 | -172.8268849449448 | 2.37495e-8 | 2.27374e-13 | 5.32003e-7 |
| PCM | 2 | 32 | -779.8628827027981 | -779.8628826233647 | 7.94333e-8 | 1.81899e-12 | 1.61526e-7 |
| GPCM | 2 | 32 | -779.5419272471615 | -779.5419270587302 | 1.88431e-7 | 5.91172e-12 | 2.23247e-7 |

All three finite-cap paths were nondecreasing, stayed below the reduced
objective within the declared tolerance, and ended within `1e-8`. All three
reduced optimizers had package severity `pass`; terminal free-gradient sup
norms were about `3.50e-5`, `1.31e-5`, and `2.26e-5` for RSM, PCM, and GPCM.
Each result was `profile_limit_refit_verified`.

The very small structural changes are fixture results, not a general claim
that finite traces are harmless. They quantify why raw structural estimates
can look stable even though the full finite JML maximum does not exist.

## Negative controls

- A Person fixed at 0.5 with an all-maximum pattern remained `fixed`; no row
  was profiled and the result was `no_free_extreme_persons`.
- An all-maximum Person under a Person-centering constraint remained
  `weak_information`; the prototype returned
  `constraint_coupled_extreme_not_profiled` without fitting a reduced
  objective.
- MML input and nonpositive caps were rejected.
- Raw fit fields and readiness were not changed.

The repository test
`tests/testthat/test-jml-extreme-profile-limit-prototype.R` passes all selected
RSM/PCM/GPCM and negative controls. The pre-existing typed-boundary test also
continues to pass.

## Interpretation

This closes one semantic and computational gap: for independently free
extreme Persons, mfrmr can now demonstrate the boundary supremum separately
from the finite optimizer trace. It does not make the corrected/profile value
a maximizer of the original finite JML likelihood. It does not correct the
incidental-parameter bias of the remaining structural estimates, provide a
profile Hessian, validate coverage, or authorize a public option.

The next JML estimator-maturity slice is a prespecified simulation comparison
among raw finite traces, extended profile-limit structural estimates, external
extreme-score adjustments, and finite-item-bias-corrected modes. Extreme
adjustment and bias correction must remain separate factors.
