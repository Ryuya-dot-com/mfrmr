# FACETS multifacet and displayed-precision contract record (0.2.3)

Status: prospective external contract plus completed internal one-seed smoke;
FACETS was not executed and no tolerance, replication count, confirmation, or
equivalence claim is authorized.

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

The next licensed-environment run should execute fixed-information facet-count
cells first. Level-growth, large-row, and sparse-topology cells follow as
separate strata; none may compensate for a failed lower-dimensional core.

## Official FACETS references

- Score-file fields and displayed decimals:
  <https://www.winsteps.com/facetman64/scorefileinvisible.htm>
- Output decimal setting:
  <https://www.winsteps.com/facetman64/modifyspecifications.htm>
- Current 64-bit manual:
  <https://www.winsteps.com/a/Facets64-Manual.pdf>
- FACETS tutorial discussion of ZSTD thresholds:
  <https://www.winsteps.com/a/ftutorial2.pdf>
