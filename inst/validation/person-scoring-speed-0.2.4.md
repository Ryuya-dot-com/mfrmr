# Person scoring speed and numerical equivalence — 0.2.4

## Question and design

Continuous posterior intervals corrected the inaccurate grid-based bounds, but
public scoring of 768 Persons with six ratings each took about 35 seconds.
Can the existing compiled likelihood reduce that cost while retaining the
continuous CDF, its tail controls and all other scoring behavior?

The change routes likelihood-only RSM/PCM evaluations through the existing
C++ backend when enabled, and avoids unused category probabilities in the R
fallback (including GPCM). Moment, derivative and adaptive fitting evaluations
retain their R path. No new dependency, likelihood formula, cache, integration
tolerance or scoring algorithm identifier is introduced.

Versions are timed sequentially in separate R processes, using the same saved
RSM calibration and seeded cohorts as the preceding study: 48, 192 and 768
Persons, six ratings each, Q61, three repeats. Medians describe this machine
and design; no minimum speedup is used to select numerical results.

Numerical verification reuses the independent 2,880-interval audit (RSM/PCM,
3/6/30 ratings, fixed/adaptive Q31/61/121, 80%/95% intervals). Its original
tail-CDF criterion is 1e-4; before/after endpoint differences must also be below
1e-8. Moment estimates must be unchanged. Public replays additionally compare
RSM/PCM with unit and positive fractional response weights, 192 Persons per
case, and seeded plausible-value draws. Public scoring requires strictly
positive weights; its rejection of zero weights is checked separately.
Saved v1 and v2 calibrations are replayed in
fresh processes. Weighted GPCM and shifted/scaled prior checks exercise the
R fallback and the compiled path. These checks concern numerical equivalence,
not a new sampling-coverage or prior-misspecification study.

## Results

The change reduces scoring time by about **10.4–10.6×** in this RSM benchmark.
For 768 Persons, the median fell from **38.603 to 3.697 seconds** (90.4% less
elapsed time). These are fresh, installed-package measurements from this
verification; the preceding study's 35.324-second baseline and the preliminary
source-loaded probe are retained separately, not mixed into these medians.

| Persons | Ratings | Before median, s | After median, s | Speedup |
| ---: | ---: | ---: | ---: | ---: |
| 48 | 288 | 2.417 | 0.229 | 10.55× |
| 192 | 1152 | 9.533 | 0.901 | 10.58× |
| 768 | 4608 | 38.603 | 3.697 | 10.44× |

All runs matched their assignment/total profile reference within 1.56e-15.
The measured speedup applies to this six-rating RSM design on this machine;
GPCM uses the R fallback and is not assigned this speedup.

* The independent numerical audit passed **2,880/2,880** intervals. Maximum
  tail-CDF error was **3.25e-12**; the maximum endpoint change from the preceding
  continuous-CDF version was **5.78e-15**. Moment differences against its saved
  decimal CSV were at most 5.33e-15 (serialization precision).
* Four public RSM/PCM replays (192 Persons each, unit or positive fractional
  weights) had **bitwise identical estimates, SDs, bounds, other estimate
  fields, settings and seeded plausible-value draws**. Both versions rejected
  zero weights through the existing public input contract. Zero weights remain
  covered separately by internal numerical tests. The first public replay
  probe encountered that expected rejection; the corrected validation runner
  distinguishes the two contracts, without changing production validation.
* Same-platform v1 replay retained bitwise identical legacy estimate tables,
  prediction moments and draws on macOS and Linux. Linux-versus-original-Mac
  comparisons retain their expected last-bit differences (at most 6.67e-16
  in legacy estimates); those are not same-platform reproducibility failures.
* Eight saved v2 calibrations on macOS (27 profiles each) retained identical
  scoring/prediction estimate fields and settings. The two Linux replays
  changed bounds by at most **4.45e-16**, with all other estimate fields and
  settings identical. The profiles include three-rating assignments and
  extreme totals. Fresh-process creation/save/load/scoring also passed for
  RSM/PCM adaptive v2 on both systems.
* On **each** platform, 756 assertions passed in six targeted suites
  (prediction, calibration lifecycle/public API, adaptive fitting/review,
  posterior intervals), with zero failures, errors, warnings or skips.
  Package checks separately passed 673 assertions with three intended CRAN
  skips. These suites overlap and their counts should not be added.

`R CMD check --no-manual` returned **OK on macOS** (R 4.6.1, arm64, Tahoe 26.6.2).
Linux (R 4.3.2, arm64, Ubuntu 22.04.4) returned **zero errors/warnings and the
existing one installed-size NOTE (9.3 MB)**. The package's 498 tracked source,
help and test files match the checked archive. Relative to the preceding
archive, only the shared kernel, its regression test and NEWS changed, plus
the generated `Packaged` timestamp.

The numerical and replay results support using the faster likelihood path
with the current CDF controls. They do not extend the earlier calibration
coverage study to misspecified priors or certify new model/design conditions.
No additional sampling simulation was needed to answer this implementation
comparison.

## Reproduction and evidence

Source archive SHA256:

* Before: `2a00ab9bbbec1b65bfb50086dfc9757e51b2d6803b1921f88fba7f7030fcea72`
* After: `be3119fcf18d62f86145f8c2826794b3dc202c489d16f9da77ed7d77121d6b4f`

The [runner](person-scoring-speed-0.2.4.R),
[timing repetitions](person-scoring-speed-0.2.4-timing.csv) and
[source hashes](person-scoring-speed-0.2.4-source.csv) accompany this record.
Full inputs, raw before/after outputs, checks, numerical references, helper
sources and both actual package archives are retained in
`validation-results/person-scoring-speed-20260914/`; see its `COMMANDS.md`
and SHA256 `manifest.csv`. The earlier large calibration simulation remains
in its own immutable evidence bundle.
