# Fixed-reference FairZ confirmation results

Completed and adjudicated: 2026-09-17. All **20,000 planned independent
datasets** were retained: 2,500 in each of eight cells. The frozen rules yield
**five supported primary cells and three review cells**. No cell is classified
as concern. This is bounded evidence for the repository joint-covariance
candidate, not general or public interval eligibility. `FairCIEligible`
remains false.

## Question and evidence identity

Does joint structural covariance give appropriately calibrated uncertainty
for fixed-reference, non-Person FairZ under the declared RSM/PCM model?
The [frozen protocol](fairz-coverage-protocol-0.2.4.md) specifies the response
model, five targets, unit weights, standard-normal Persons, known allocation,
zero reference values, estimators, intervals, seeds and decision rules.
Person/FairM, estimated populations, anchors, DRF, GPCM and random-facet
generalization are outside this confirmation.

The study resumed from 450 retained datasets after the user's September 17
instruction. All eight final checkpoint states and the matching preflight
passed the existing source/backend/plan/seed/result-shape validator before
the existing summarizer was run. Executable source remains the reviewed
`fe8220ce` payload, native-library MD5
`59d00f20719463739c7fcd191e4d28da`, R 4.6.1,
`aarch64-apple-darwin23`. No targets, seeds, thresholds, estimation retries,
replication counts or methods were changed after outcomes were observed.
The 40 preflight datasets are excluded from the 20,000.

## Primary results

| Cell | Model | Persons | Ratings per Person | Available per target | Supported targets / 5 | Cell disposition |
| ---: | --- | ---: | ---: | ---: | ---: | --- |
| 1 | RSM | 80 | 3 | 2,498 | 2 | review |
| 2 | RSM | 80 | 6 | 2,500 | 4 | review |
| 3 | RSM | 320 | 3 | 2,500 | 5 | supported |
| 4 | RSM | 320 | 6 | 2,500 | 5 | supported |
| 5 | PCM | 80 | 3 | 2,500 | 4 | review |
| 6 | PCM | 80 | 6 | 2,500 | 5 | supported |
| 7 | PCM | 320 | 3 | 2,498 | 5 | supported |
| 8 | PCM | 320 | 6 | 2,500 | 5 | supported |

All 40 primary target/method coordinates pass the prespecified SE-ratio,
standardized-bias, availability and numerical criteria. Thirty-five pass
the coverage criterion; five remain review. The five targets within a cell
share datasets and are not independent experiments.

| Review coordinate | Covered / available | Coverage | Exact 95% Monte Carlo interval |
| --- | ---: | ---: | --- |
| RSM, 80, 3; R1 | 2,347 / 2,498 | 0.939552 | [0.929479, 0.948578] |
| RSM, 80, 3; C1 | 2,334 / 2,498 | 0.934347 | [0.923915, 0.943746] |
| RSM, 80, 3; C2 | 2,334 / 2,498 | 0.934347 | [0.923915, 0.943746] |
| RSM, 80, 6; R2 | 2,350 / 2,500 | 0.940000 | [0.929964, 0.948989] |
| PCM, 80, 3; R2 | 2,347 / 2,500 | 0.938800 | [0.928679, 0.947877] |

The protocol requires the entire coverage Monte Carlo interval to lie inside
[0.93, 0.97]. Each interval above overlaps the lower boundary rather than
lying wholly on its adverse side, hence review rather than concern. In
particular, rounding 0.929964 to 0.930 must not turn the RSM 80/6 result into
a pass. These intervals quantify Monte Carlo uncertainty about repeated
coverage, not uncertainty about an individual person's score. They are
coordinatewise, not simultaneous bands.

The pattern provides support in the tested N=320 cells and the PCM N=80/6
cell. It leaves unresolved small-sample coverage in three cells; it does not
establish a universal minimum sample size. There is no coverage-driven
extension of this finished study.

## Availability, numerical checks and comparison method

All 20,000 datasets retained finite point estimates. Four fits were not
inference-ready: cell 1 replicates 1,459 and 2,447 (seeds 77011459 and
77012447), and cell 7 replicates 2,075 and 2,418 (77072075 and 77072418).
They reported optimizer code 52 with `reviewable_warning`: a nonzero
optimizer code despite a terminal gradient within the review tolerance.
Their point estimates remain in finite-estimate summaries, their intervals
remain unavailable, and their assigned identities remain in the denominators.
They were not regenerated or refitted with a different rule.

There were zero execution errors, four warning-bearing datasets, zero ready
numerical conflicts and zero verification failures. Zero conflicts does not
prove a zero population rate: the exact upper bound per 2,500-dataset cell is
0.001474464. All availability lower bounds exceed 0.99. No primary intervals
required endpoint clipping in this study.

The secondary conditional-measure comparator has 36 supported and four
review coordinates. It cannot substitute for the primary cell decisions.
Across the 40 paired coordinates, primary-minus-secondary coverage changes
range from -0.0068 to 0.0056, and mean clipped-width changes from -0.002960
to 0.004122 score units. These are coordinate-specific descriptive ranges;
the [paired table](fairz-confirmation-0.2.4/paired.csv) supplies the MCSEs.
This study does not show uniform superiority of the joint method.

## Output verification and practical limit

The existing output audit passed again on the eight saved preflight fits
with native/legacy/both labels: 24 reporting configurations, not 24 new
datasets. It checked values, conditional endpoints, CSV round trips, saved
objects/replay and retained diagnostic-only eligibility. All reported
`FairCIEligible` values remain false. The public conditional plot route is
not silently replaced by the joint-covariance candidate.

At confirmation completion, the separate full package check had six failures: five fit-plot
diagnostic-identity errors and one GPCM extreme-score optimization error.
The [subsequent repair](package-check-repair-0.2.4.md) resolves those failures
and passes the complete packaged regression check. It also records 12 same-data
comparisons against the changed source, preserving the historical confirmation
and all four non-ready results. The successful FairZ output audit and bounded
confirmation do not constitute a release pass.

## Retained records

- [Cell execution and dispositions](fairz-confirmation-0.2.4/runs.csv).
- [All 80 target/method summaries](fairz-confirmation-0.2.4/summary.csv),
  including all denominators, Monte Carlo intervals and component decisions.
- [Forty paired comparisons](fairz-confirmation-0.2.4/paired.csv).
- [Twenty-four output checks](fairz-confirmation-0.2.4/output-checks.csv).
- [Evidence manifest and CSV SHA-256 values](fairz-confirmation-0.2.4/manifest.json).
- [Execution/resumption and historical pause](fairz-confirmation-status-0.2.4.md).

Full immutable cell records, source snapshots and retained adverse details
remain in `validation-results/fairz-current-20260915/final-current/confirmation/`.
Completion logs are in `validation-results/checkpoint-20260917/` as
`fairz-completion-summary.log`, `fairz-completion-output-audit.log`, and
`fairz-progress-latest.csv`. Historical suspension and invocation times remain
separate; the summed per-fit timing is not end-to-end wall time.
