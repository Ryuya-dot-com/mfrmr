# FACETS multifacet and displayed-precision contract record (0.2.3)

Status: prospective external contract, completed internal one-seed smoke,
completed external three-facet output-precision qualification, and completed
one-seed fixed-information 3--5 facet common-element qualification. The full
multifacet registry was not executed in FACETS, and no tolerance, replication
count, confirmation, or equivalence claim is authorized.

## Essential distinction

“More facets” has two different meanings and the comparison must not combine
them:

1. more facet dimensions, such as Person + Rater + Criterion, then adding Task
   and Occasion; and
2. more levels inside an existing facet, such as increasing Raters from 8 to
   20.

The declared registry therefore varies total facet count, level count, row
count, and topology in separate strata. `TotalFacets` includes Person and
`NonPersonFacets` does not. The fixed-information dimension cells retain the
same Person count, target rows, and intended Person exposure for total facet
counts 3, 4, and 5. Separate cells cover level growth, 1,000-Person row growth,
distributed sparsity, a weak bridge, and a disconnected negative control.

The executable contract is
`facets-multifacet-precision-contract-0.2.3.R`. Its 16 rows cross eight design
cells with RSM and Criterion-step PCM under JML. Every external row requires a
candidate-linked FACETS run and disjoint confirmation seeds. Scientific
file-byte equality is explicitly false.

## Displayed decimal contract

The primary comparison rule is to request more FACETS output decimals, not to
accept low-precision output and reconstruct hidden values. Each licensed run
must request eight decimals for configurable measure output (`Udecim=8`, or
the equivalent third `Umean=` value) and eight decimals in configurable
residual/response output. The run record must retain both the requested
setting and the number of decimals actually written for Measure, SE, MnSq,
ZSTD, and df. One setting must not be assumed to control every metric.

The current 64-bit score-file documentation specifically binds `Umean=`
decimal places to Measure, SE, and Displacement. It does not state that the
same setting changes the score-file MnSq, ZSTD, or df fields. The residual-file
selection dialog can increase decimals for observation-level residual fields,
but that is not itself a high-precision element-level ZSTD export. Thus the
comparison uses `Udecim=8` for Measure and SE, requests eight residual decimals
when residual reconstruction is needed, and probes the written precision of
MnSq, ZSTD, and df instead of inventing a control that FACETS does not document.

Some score-file fields or output routes can remain fixed-format. The score-file
documentation identifies fixed fields and says that measure decimals are
controlled by the output scale setting; the current manual also describes text
score-file fields as reported to displayed decimal precision. These statements
do not expose the hidden internal value or, for every field and version, a
machine-verifiable rounding rule.

Accordingly, `read_facets_fit_table()` now preserves the exact reported tokens
and displayed decimal counts for estimates, SE, MnSq, ZSTD, df, and N instead
of immediately discarding them after numeric conversion. Numeric-only data
frames are labelled `numeric_values_only`; they cannot establish reported
precision retrospectively.

Only when the actual ZSTD output remains fixed-precision, the conventional
absolute ZSTD threshold 2 is handled as follows:

- displayed values below 2 are `display_below_threshold`;
- displayed values above 2 are `display_above_threshold`; and
- displayed values exactly equal to 2, including `2.0`, `2.00`, `-2.0`, and
  `-2.00`, are `display_boundary_indeterminate`.

If an eight-decimal ZSTD is actually written and differs from 2, it is
classified normally. Boundary-indeterminate rows remain in the expected
denominator but cannot enter a threshold-agreement numerator. This avoids
silently deciding whether the unreported value was just below, exactly at, or
just above 2. The package's own full-precision review convention is
`|ZSTD| >= 2`; that convention does not turn a rounded external equality into
a hidden-value claim.

For ordinary parameter differences, the contract reports the absolute
difference and the difference in displayed decimal units. “Within one
displayed unit” is a resolution description, not an assumed rounding interval
or a hidden-value equality claim. A half-unit rounding interval may be used
only if the relevant FACETS output route and version document and reproduce
that rounding rule.

`facets_fit_review()` now reports retained-token, numeric-only, and displayed
ZSTD-boundary row counts. Numeric tolerances remain separate from threshold
classification.

## Completed external output-precision qualification

On 2026-08-14, the local FACETS 4.5.0 executable ran four balanced synthetic
qualification cases generated with seed 452023: RSM and PCM in the canonical
three-facet specification, plus the legacy four-column specification as a
formatting control. All four processes returned code zero and all reports
echoed `Umean = 0, 1, 8`.

The legacy fourth Task facet had only one observed level (`pilot`). It adds no
free contrast and is **not** evidence about four-facet dimension growth. Only
the Person + Rater + Criterion runs enter the numerical comparison below.

FACETS wrote these decimal counts in every reviewed score file:

| Measure | SE | Infit MnSq | Infit ZSTD | Outfit MnSq | Outfit ZSTD | Infit df | Outfit df |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 8 | 8 | 2 | 2 | 2 | 2 | 2 | 2 |

This directly confirms that `Udecim=8` resolves Measure and SE precision but
does not increase the element-level score-file MnSq, ZSTD, or df precision in
this FACETS version and output route. Exact reported-token retention remains
necessary for those fixed two-decimal fields.

For the canonical three-facet runs, the current mfrmr candidate and FACETS
common element measures agreed as follows after label and coordinate matching:

| Model | Facet | Matched | MAE | Maximum absolute difference |
| --- | --- | ---: | ---: | ---: |
| RSM | Person | 60 | 0.004749 | 0.014351 |
| RSM | Rater | 8 | 0.004405 | 0.011889 |
| RSM | Criterion | 5 | 0.002165 | 0.003666 |
| PCM | Person | 60 | 0.004564 | 0.010552 |
| PCM | Rater | 8 | 0.002683 | 0.004974 |
| PCM | Criterion | 5 | 0.002428 | 0.003894 |

These are qualification observations, not a frozen tolerance. They use one
seed, FACETS 4.5.0 rather than 4.5.1, and do not compare PCM steps, bias terms,
or sparse designs. The legacy four-column control in this qualification does
not test genuine four-/five-facet dimensions; those dimensions are tested
separately in the next section. Raw proprietary output remains outside the
package repository; the record intentionally does not turn machine-specific
file hashes into scientific acceptance criteria.

## Completed external fixed-information 3--5 facet qualification

On 2026-08-14, the local FACETS 4.5.0 executable ran six genuine dimension
cases: RSM and Criterion-step PCM at total facet counts 3, 4, and 5. Total
facets include Person. The cases used 40 Persons, 4 Raters, 4 Criteria, three
Task levels when present, two Occasion levels when present, and exactly 640
observations in every case. The runner used seed 451002 for RSM and 451003 for
PCM so that adding Task and Occasion did not add observations or change the
model-specific generating seed.

All six FACETS processes returned code zero, all six mfrmr JML fits returned,
and neither path emitted a recorded warning or error. Before any numerical
comparison, a fail-closed coordinate contract required the imported FACETS
facet/level keys to equal the complete expected set with no duplicates,
missing keys, or unexpected keys. It passed at 48/48 coordinates for three
facets, 51/51 for four facets, and 53/53 for five facets in both models.

The largest facet-block MAE and the largest individual absolute difference
among the matched common element measures were:

| Model | Total facets | Compared blocks | Matched coordinates | Maximum block MAE | Maximum absolute difference |
| --- | ---: | ---: | ---: | ---: | ---: |
| RSM | 3 | 3 | 48 | 0.007755 | 0.023244 |
| RSM | 4 | 4 | 51 | 0.005679 | 0.017373 |
| RSM | 5 | 5 | 53 | 0.007808 | 0.024790 |
| PCM | 3 | 3 | 48 | 0.010638 | 0.024784 |
| PCM | 4 | 4 | 51 | 0.013882 | 0.034163 |
| PCM | 5 | 5 | 53 | 0.006960 | 0.008866 |

This closes only the first dimension-growth qualification cell: balanced,
fixed-information, one-seed agreement for common Person and facet-level
measures. It does **not** establish exact equality or FACETS replacement. PCM
step parameters were not extracted and matched, FACETS element fit statistics
remain fixed at two displayed decimals in this route, and no multi-seed,
large-data, sparse/weak-link, extreme-score, category-support, bias, or
30-facet comparison was run. FACETS 4.5.1 was not available locally. These
limitations keep numeric tolerance, confirmation, and equivalence authorization
false.

## Completed internal smoke

The internal preflight used one coupled generating seed per model and 640 rows
for every total-facet condition. Each Person had all 4 x 4 Rater-by-Criterion
pairs exactly once. Task and Occasion were assigned within those same rows, so
adding dimensions neither increased Person exposure nor introduced duplicate
cells.

| Model | Total facets | Converged | Inference ready | Person RMSE | Rater RMSE | Criterion RMSE | Step RMSE |
| --- | ---: | --- | --- | ---: | ---: | ---: | ---: |
| RSM | 3 | yes | yes | 0.3532 | 0.0329 | 0.0713 | 0.1291 |
| RSM | 4 | yes | yes | 0.3566 | 0.0220 | 0.0718 | 0.0841 |
| RSM | 5 | yes | yes | 0.4029 | 0.0217 | 0.0687 | 0.0992 |
| PCM | 3 | yes | yes | 0.4571 | 0.0999 | 0.1143 | 0.2266 |
| PCM | 4 | yes | yes | 0.4773 | 0.1204 | 0.1043 | 0.2030 |
| PCM | 5 | yes | yes | 0.4746 | 0.0430 | 0.0839 | 0.2327 |

All six fits returned, converged, were inference-ready, and emitted no
warnings. The added Task RMSEs were 0.0892/0.1028 for RSM and 0.0598/0.0433
for PCM at four/five total facets. Occasion RMSE at five facets was 0.1115 for
RSM and 0.0239 for PCM.

This establishes only that the generator and mfrmr JML paths remain usable in
one small balanced, fixed-information smoke. It does not estimate a facet-count
effect, prove monotone stability, address large or sparse operating
characteristics, or compare FACETS numbers.

## External execution requirements

Before a FACETS row can calibrate a tolerance, it must pass:

1. eight requested decimals plus a metric-specific probe of actual written
   decimals;
2. identical observations, active facets, signs, constraints, anchors,
   category map, and PCM step dimension;
3. constrained full-rank estimability and the intended topology state;
4. parameter-class-specific matching for nonextreme Person, Rater, other
   facets, Criterion, and steps;
5. exact reported-token retention plus an explicit boundary count for any
   ZSTD route that remains fixed-precision;
6. truth recovery for each program before between-program differences;
7. complete expected, failed, rejected, boundary-indeterminate, and eligible
   denominators; and
8. replication and Monte Carlo precision frozen before candidate results are
   inspected.

The next licensed-environment work should first extract and coordinate-match
PCM step parameters, then repeat the fixed-information 3--5 facet core over
prespecified seeds. Level-growth, large-row, sparse/weak-link, and eventually
30-facet capacity cells follow as separate strata; none may compensate for a
failed lower-dimensional core.

## Official FACETS references

- Score-file fields and displayed decimals:
  <https://www.winsteps.com/facetman64/scorefileinvisible.htm>
- Output decimal setting:
  <https://www.winsteps.com/facetman64/modifyspecifications.htm>
- Current 64-bit manual:
  <https://www.winsteps.com/a/Facets64-Manual.pdf>
- FACETS tutorial discussion of ZSTD thresholds:
  <https://www.winsteps.com/a/ftutorial2.pdf>
