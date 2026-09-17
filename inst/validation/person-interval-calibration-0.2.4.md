# Person posterior intervals: continuous mass, coverage, and compatibility

Date: 2026-09-14. Development version: 0.2.4.9000.

## Question, finding, and correction

Do the reported Person intervals contain their stated posterior probability,
even when the EAP and posterior SD have converged? This matters when users
report uncertainty for new Persons scored against a point calibration.

The previous grid-endpoint calculation could fail this requirement. For example,
with the known PCM calibration below, 30 ratings and total score 54, adaptive
Q31 recovered the independently integrated EAP and SD to floating-point
precision, but its nominal 95% interval contained only **90.6734%** of the
continuous posterior. Increasing the order improved moments without reliably
resolving the interval's step-CDF error. This is a different issue from zero
Hermite weights or the accuracy of the MML likelihood.

New `predict_mfrm_units()` intervals and newly extracted portable calibrations
now invert the continuous posterior CDF. The shared helper uses the existing
ordinal likelihood and normal-prior kernel, posterior mode/local scale,
`stats::integrate()` and `stats::uniroot()`. A concavity-based upper bound checks
omitted tails, and the upper endpoint solves the survival probability directly.
It fails explicitly if the omitted mass cannot be bounded. EAP, SD, fitting,
and quadrature-based plausible-value draws retain their previous calculation.

New scoring identifiers are `quadrature_eap_v2` and
`adaptive_quadrature_eap_v2`. Frozen v1 artifacts retain their original grid
intervals and identities, with an explicit note about their interval mass.
Loading a v1 artifact does not silently upgrade it. To obtain v2 intervals,
create and review a new calibration from the source fit; do not edit a frozen
artifact's identifier. The help pages, portable-calibration vignette and NEWS
describe these semantics.

## Design and numerical results

The [plan](person-interval-calibration-0.2.4-plan.md) was fixed before numerical
outcomes. The [runner](person-interval-calibration-0.2.4.R) crosses known RSM/PCM
calibrations with 3, 6 and 30 ratings, unit slopes/weights, categories 0--3 and
a correct N(0,1) prior. It examines every possible total for each assignment,
including both extremes: 240 design/total posteriors, fixed/adaptive Q31/61/121,
and 80%/95% intervals, giving **2,880 intervals per version**. Three ratings
provide little Person information; this does not test identification of a
disconnected calibration.

The reference independently convolves categorical probabilities and integrates
the resulting total-score likelihood times the prior. It uses neither the
package probability kernel nor a Hermite rule for its CDF, and checks moments
against a second existing continuous-integration reference. The largest
reference relative integration error was 4.94e-12; its largest omitted-tail
bound was 1.89e-53. All six total-probability distributions normalized within
the planned 1e-9 tolerance.

| Moment integration | Order | Old endpoint passes / 480 | Old max tail-probability error | New endpoint passes / 480 |
| --- | ---: | ---: | ---: | ---: |
| Fixed | 31 | 0 | 0.620009 | 480 |
| Fixed | 61 | 0 | 0.345642 | 480 |
| Fixed | 121 | 0 | 0.210289 | 480 |
| Adaptive | 31 | 0 | 0.056466 | 480 |
| Adaptive | 61 | 1 | 0.037392 | 480 |
| Adaptive | 121 | 1 | 0.027910 | 480 |

Both endpoint CDF errors must be <=1e-4. The old calculation passed 2/2,880;
the correction passed **2,880/2,880**, with maximum tail-probability error
**3.25e-12** and maximum endpoint-coordinate error **2.48e-11 logits**. New
interval endpoints are identical across the six moment-integration settings
for a given calibration, response total and level. EAP and SD entries in the
before/after tables are exactly unchanged.

This does not make a low-order fixed grid adequate for moments: in this audit,
fixed Q31 still had maximum EAP/SD errors 0.07079/0.08653, and fixed Q121 had
0.000108/0.000226. Adaptive Q31's corresponding errors were about 1e-10.
Users must still review order sensitivity for moments and fitted parameters.
The default integration mode remains fixed.

## Repeated-sampling coverage and its meaning

The runner generated **100,000 independent Persons per design, 600,000 total**,
with fresh normal abilities and independently sampled integer responses.
Before/after and integration-method comparisons use these same Persons and
unchanged seeds. Scoring uses each Person's total to look up the posterior
already checked above; there were no 600,000 calibration refits. This use of
total-score sufficiency applies to these known-calibration, unit-slope
assignments. Method comparisons are dependent and are not additional Persons.

| Model | Ratings | Empirical 80% coverage | Empirical 95% coverage | 95% Monte Carlo interval for the latter |
| --- | ---: | ---: | ---: | --- |
| RSM | 3 | 0.79886 | 0.95042 | [0.94906, 0.95176] |
| RSM | 6 | 0.80169 | 0.95046 | [0.94910, 0.95180] |
| RSM | 30 | 0.80047 | 0.94943 | [0.94805, 0.95078] |
| PCM | 3 | 0.79916 | 0.95008 | [0.94871, 0.95142] |
| PCM | 6 | 0.80036 | 0.95002 | [0.94865, 0.95136] |
| PCM | 30 | 0.80129 | 0.95130 | [0.94995, 0.95263] |

After correction, all six methods share these coverage values. Numerically
integrated prior-predictive coverage differs from its nominal level by at most
1.57e-13. Empirical differences are within 1.91 Monte Carlo SEs. Before the
repair, integrated 95% coverage ranged from 0.734459 to 0.951296 across settings;
for adaptive Q31 alone it ranged from 0.935255 to 0.944138. A seemingly acceptable
marginal coverage value did not override a failed conditional endpoint check.

Coverage averaged over the stated prior does **not** imply 95% coverage at
every fixed ability. After repair, empirical 95% coverage in the true-ability
strata below -2 or above 2 ranged from **0.6910 to 0.9231**. These descriptive
strata are retained, not excluded. Widths, EAP RMSE, posterior SD, exact binomial
Monte Carlo intervals and all 432 stratum rows per version are also retained.
The paired repair audit is not fresh independent confirmation.

## Regression, saved artifacts, and performance

One source archive was checked on macOS (R 4.6.1, arm64) and Linux (R 4.3.2,
Ubuntu 22.04.4, arm64). `R CMD check --no-manual` returned **OK on macOS** and
**one installed-size NOTE on Linux** (9.3 MB), with zero errors or warnings.
Each check ran 661 passing assertions and three explicitly CRAN-skipped GPCM
tests. These were the light package checks, not a claim that every repository
validation study was rerun.

On each installed package, a separate `NOT_CRAN=true` run passed **1,027
assertions**, with zero failures, errors, warnings or skips, covering prediction,
calibration lifecycle, adaptive fitting, interval calculation, public calibration
API, example policy and documentation terminology. These counts overlap the
light checks and must not be added as distinct tests. The interval regression
includes analytically known shifted/scaled normal priors at levels 0.8, 0.95
and 1-1e-10, reordered Person IDs, zero/fractional weights, and independent
RSM/PCM/GPCM likelihood CDFs. The GPCM cases test this numerical calculation,
not general GPCM inferential readiness.

Actual public RSM and PCM fits were extracted, reviewed, frozen, saved and
scored in fresh R processes on both platforms. New v2 scoring matched fitted-
object prediction through both interval endpoints (maximum error 8.89e-16),
and fresh-process artifact estimates were identical to same-process estimates.
The prior public workflow was reused, changing only its expected v1 identifier
to v2 in a retained derived runner; its historical source was not rewritten.

Two actual pre-repair v1 artifacts and saved results were replayed. On their
original macOS platform, all legacy estimate-table values, prediction EAP/SD
and seeded plausible-value draws were exactly identical. Reading the same
macOS evidence on Linux gave maximum legacy estimate error 6.67e-16, prediction
moment error 1.34e-15 and draw-value error 4.45e-16; draw Person/Draw labels were
identical. Cross-platform bitwise identity is not claimed.

Continuous inversion costs more than selecting grid nodes. A descriptive
three-run timing of the same public RSM prediction call on macOS, with 48
Persons and 282 ratings, gave median elapsed time **0.024 s before and 2.287 s
after**. This is a small-batch timing, not a large-batch throughput benchmark.
No caching or alternate interval approximation was added to conceal this cost.

## Evidence boundaries and reproduction

Existing evidence includes the historical
[20,000-dataset structural coverage study](mml-structural-coverage-record-0.2.4.md)
and [30,000-dataset bias confirmation](mml-structural-bias-confirmation-record-0.2.4.md).
It was too broad to describe interval coverage as wholly unverified. Those
studies address structural parameters with their archived fixed-grid source;
they do not automatically validate the newly introduced scoring algorithm.

The present finding is conditional on point calibration and the correct prior.
It does not include uncertainty in estimated calibration, estimated-prior
coverage, prior misspecification, linking/anchor transport, or a release
decision. Existing G-theory, anchor, sparse-identification and GPCM restrictions
are unchanged. Separating estimands and Monte Carlo uncertainty follows
[Morris, White and Crowther (2019)](https://doi.org/10.1002/sim.8086); the
prior-predictive interpretation is consistent with the
[Stan simulation-based calibration explanation](https://mc-stan.org/docs/stan-users-guide/simulation-based-calibration.html).
This is a posterior-CDF/coverage audit, not an SBC rank-uniformity study.

The compact [numerical summary](person-interval-calibration-0.2.4-summary.csv),
[coverage results](person-interval-calibration-0.2.4-coverage.csv),
[test ledger](person-interval-calibration-0.2.4-tests.csv) and
[archive/source comparison](person-interval-calibration-0.2.4-source.csv) accompany
this record. All **498** compared archive/source files were identical. Archive
SHA-256: `2a00ab9bbbec1b65bfb50086dfc9757e51b2d6803b1921f88fba7f7030fcea72`.

Raw evidence is in
`validation-results/person-interval-calibration-20260914/`: before/after
intervals, independent reference results, Monte Carlo/stratum tables, seeds
and runner, before source snapshots, both source archives, the isolated repair
diff, installed-check logs, fresh-process artifacts/readers, legacy replays,
timings, sessions and a SHA-256 manifest. Individual simulated abilities are
regenerated from the six recorded seeds rather than stored as another dataset.
Initial failed preflights are retained: an incorrect positional prior-basis
argument in the new helper, then a too-loose omitted-tail budget exposed by
the near-one interval test. Both were corrected before the completed after
audit; the frozen study conditions, samples and endpoint criterion were not
changed in response to numerical audit outcomes.

From the development root with the relevant package version loaded:

```r
source("inst/validation/person-interval-calibration-0.2.4.R")
run_person_interval_calibration("/tmp/person-interval-reproduction")
simulate_person_interval_coverage("/tmp/person-interval-reproduction")
```

The retained `installed-verification.R` takes the installed library directory,
source root and output directory as its three arguments. Use the old archive
to reproduce `before`, and the new archive to reproduce `after`. No package
release, commit or external publication was performed.
