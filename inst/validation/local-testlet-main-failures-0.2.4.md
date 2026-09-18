# Main-study numerical failures: bounded follow-up

2026-09-18. The scope below is fixed before new numerical evaluations. This
follow-up diagnoses the completed main study's unavailable cases; it does not
replace its failures, rescore its sample, or estimate a repaired success rate.

## Questions and fixed scope

The eight native code-52 fits have projected scores between 5.36e-6 and
8.77e-6: above the optimizer's 5e-6 target but below the unchanged final 1e-5
requirement. Their saved higher-order references agree. In each last twelve
qualified trial evaluations, log-likelihood ranges are at most 1.60e-12 and
coordinate deviations from the returned point at most 3.54e-12. This suggests
line-search stagnation near numerical precision, not a distant-trial
quadrature failure. The proposed comparison tests the stopping-policy cause;
it cannot prove the precise floating-point mechanism or global optimality.

Use all eight failed datasets plus the first ready dataset in each of the
four cells as successful controls. Run one alternative per dataset, from the
original start: change only `pgtol` from `5e-6/N` to `1e-5/N`. Preserve
`fnscale=N`, `factr=0`, maximum iterations, parameter bounds and integration
rules. This aligns the optimizer's target with the final score requirement;
it does not relax the latter. R's [optim documentation](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/optim.html)
specifies scaling of both objective and gradient by `fnscale`.

Each of these 12 fits gets the existing terminal-order+60 reference. Reuse the
main study's readiness function, including native code 0, projected/reference
scores <=1e-5, numerical reference tolerances, bounds and captured errors/
warnings. Compare all new points to saved points: absolute log-likelihood
change <=1e-7, maximum coordinate change <=1e-4, moment change <=1e-5 and
unchanged exact-zero/interior state. Retain every failure; do not try other
settings if this candidate fails. These selected cases cannot establish the
setting's general reliability.

The two unresolved score targets receive separate fixed-parameter probes:
`cell-04-rep-0237/P90` and `cell-04-rep-0282/P19_minus_P20`. Reuse the original
density and final local/midpoint orders 241/181. Recompute its normalizers for
the selected persons only and check their moments against the saved final
attempt. Change only outer continuous integration, first to absolute/relative
tolerances 1e-10, then 1e-12. A third 1e-12 probe partitions each integral
additionally at center +/- two posterior SDs and the center (where inside
the limits), dividing absolute tolerance across segments. Keep infinite tails
and subdivisions=200. This partition comparison helps detect a missed region
without changing the density or raising Gauss-Hermite orders again.

Require mass error <=1e-7, reported propagated integration error <=1e-6, and
CDF agreement within 1e-9 across the three probes. Report individual integral
values, errors, subdivisions and messages; `integrate()` returns an error
estimate, not a guaranteed bound ([R documentation](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/integrate.html)).
Keep the original 1e-6 cutoff ambiguity rule separate. A stable CDF remaining
inside that band is an intentional unresolved coverage classification, not
evidence that larger quadrature orders are needed. No narrower band will be
selected from these outcomes.

## Reproducibility and stopping

The [runner](local-testlet-main-failures-0.2.4.R) freezes this pre-run text,
selected input hashes, unchanged numerical sources, controls and session;
checkpoints each fit before its reference; and retains all raw comparisons
in portable evidence. Existing numerical helpers and acceptance rules are
reused. The saved main-study evidence and tables must retain their identities.
Only these 12 fits and six scoring probes are authorized by this plan. No
new response generation, broad test suite or aggregate coverage calculation
is needed. Interpret the findings before selecting any further numerical or
calibration-uncertainty work.

## Results and their implications

Completed 2026-09-18 at 10:53:56 JST. All eight optimizer stops resolve under
the single planned change, and all four successful controls remain ready.
The final numerical acceptance criteria were unchanged. Every new optimizer
history is an exact prefix of its saved original history: the new setting
ends the same trajectory earlier, rather than finding a materially different
solution. All twelve now terminate on the projected-gradient criterion.

| Comparison across the 12 datasets | Largest absolute value | Required bound |
|:---|---:|---:|
| Final projected score | 8.7714e-6 | 1e-5 |
| Higher-order projected score | 8.7714e-6 | 1e-5 |
| Higher-order log-likelihood discrepancy | 3.4106e-13 | 1e-7 |
| Higher-order moment discrepancy | 5.5511e-15 | 1e-7 |
| Higher-order score discrepancy | 6.1329e-13 | 1e-6 |
| New versus original log-likelihood change | 1.7906e-12 | 1e-7 |
| New versus original coordinate change | 3.1804e-7 | 1e-4 |
| New versus original moment change | 2.5331e-7 | 1e-5 |

All exact-zero/interior classifications are preserved. There are no captured
fit/reference errors or warnings. These results support using the aligned
`pgtol=1e-5/N` as the next candidate for this research fitting path, while
retaining the independent final score and higher-order checks. They do not
establish a general failure rate: the sample deliberately includes failures,
and the other main-study datasets were not refitted. Native code 52 is still
a failure in the original study; it has not been reinterpreted as success.

The scoring probes separate two different causes:

| Saved target | Original mass error | Largest mass error in new probes | Refined CDF at truth | Original ambiguity band |
|:---|---:|---:|---:|:---|
| 0237 / P90 | 3.3307e-15 | 2.5535e-15 | 0.974999546843482 | Still inside |
| 0282 / P19 minus P20 | 1.1307e-7 | 2.2204e-16 | 0.345674297389884 | Outside |

For the pair, the discrepancy is in the outer integral from the posterior
center to infinity: the saved value was 0.49860945044590, whereas the tighter
integrals give 0.49860956351903. The original reported absolute-error estimate
was only 1.3294e-9. Both tighter tolerances and the alternative partition agree;
the largest CDF difference among them is 5.55e-17. The normalizer, density and
Gauss-Hermite orders were held fixed. Thus increasing those orders was not
addressing the failing layer: refining the continuous integral resolves the
mass discrepancy. The original mass guard correctly prevented acceptance of
that attempt despite its small reported error estimate.

The resulting pair CDF changes by -3.90865e-8 and is far from either coverage
cutoff. Future scoring refinement should tighten the outer integral when its
mass check fails, keeping that check and the cutoff rule. A 1e-10 tolerance
was sufficient in this case; this is a supported refinement candidate, not
a universal accuracy guarantee for all targets.

For P90, all three refined CDFs agree and remain 4.53157e-7 below .975. Its
numerical integration is stable, but the original 1e-6 ambiguity band
intentionally leaves classification unresolved. Further quadrature escalation
is not indicated by these results. Any future error-based classification rule
would need its own definition and validation; the current band is unchanged.

## Decision and retained evidence

The bounded numerical investigation is complete. It identifies an optimizer
stopping-policy mismatch and an outer-integration refinement need, while
distinguishing the intentional cutoff ambiguity. No additional control search,
response generation or main-study coverage rerun follows from these findings.
The main study remains at 1,192 ready fits and two additional unresolved
targets. This selected-case follow-up does not supply corrected coverage or
calibration-aware intervals.

The substantive next decision is how to account for estimated calibration in
the uncertainty of the same observed people and their differences. Specify
the inferential target and refitting or joint-posterior construction before
implementing that method; a numerical stopping repair is not an uncertainty
correction. Use the existing main study and sensitivity evidence to motivate
that work, preserving shared calibration covariance for pair differences.

The [fit comparisons](local-testlet-main-failures-0.2.4-fits.csv) and
[scoring probes](local-testlet-main-failures-0.2.4-scoring.csv) contain all
planned outcomes. The [portable evidence](local-testlet-main-failures-0.2.4-evidence.rds)
(524,401 bytes; MD5 `f53a9c0ee40a7cafe55a71d90ca437e4`) retains selected
generated data, old/new fit histories, references, scoring attempts, the
pre-run plan, source/input identities and results. Checkpoints remain under
`validation-results/local-testlet-main-failures-20260918/`.

The runner's targeted acceptance checks passed, and subsequent read-only
review confirmed exact history prefixes and the integral-level discrepancy.
Original source, selected data/result, main evidence and primary table hashes
are unchanged. No public package code, optimizer implementation, numerical
kernel or full-package tests were changed or repeated. The existing build
exclusion keeps these research records out of the CRAN source package.
