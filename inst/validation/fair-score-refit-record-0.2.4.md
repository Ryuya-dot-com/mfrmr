# Fair Score plotting and full-refit preflight

Date: 2026-09-10. Status: implemented and bounded pilot executed; no
coverage confirmation or release approval. See the
[prespecified protocol](fair-score-refit-protocol-0.2.4.md).

## What changed and why

The existing `plot_fair_average()` now offers `plot_type="measure"` alongside
observed-versus-fair scatterplots and ranked gaps. Person selection gives an
ability-to-score view. Values come directly from the existing fair table;
there is no new probability engine or fitted trend through heterogeneous
reference profiles. Full rows, displayed coordinates, exclusions, reference,
readiness and uncertainty notes are returned. Base and ggplot renderers share
colours and six point shapes, including grayscale; titles and notes can be
hidden independently. Shapes repeat after six facets, with a returned note
to select facets. Dense/coincident points may overlap; point count should be
read from the returned data, not estimated from visible symbols.

The source audit found and repaired these issues:

* FairZ had been described as a within-facet z-score. It is an expected score
  at zero reference measures. The established `StandardizedAdjustedAverage`
  alias is retained with its actual meaning documented. FairM uses mean
  reference measures, not an average of predictions over observed assignments.
* RSM/PCM interval derivatives used signed reporting-scale Measure, ignoring
  the FairM reference shift and mishandling Person sign. For non-step PCM rows
  they averaged variances rather than evaluating at the mean thresholds used
  by the table. The replacement resolves the same reference distribution from
  its reported expected score, computes its variance and removes `uscale`
  from the measure SE. The shared score-to-eta inverse now uses tolerance 1e-10.
* GPCM bundle intervals could retain 95% bounds while the annotation said 90%.
  Current bundles store the internal rating bounds and recompute bounds at the
  requested level. Older bundles can reuse only their recorded level.
* The new ggplot conversion initially fell through to the generic table
  converter during visual QA; the final dispatch and a coordinate-level
  regression check now ensure the requested relationship is actually drawn.

RSM/PCM intervals remain **focal-measure conditional approximations**, not
joint-calibration intervals. `xtreme` changes the displayed Measure but not
the Fair Score, so these conditional intervals are unavailable when it is
used; zero measure scaling also makes them unavailable. GPCM structural SEs
condition on the source person EAP/reference mean and omit Person rows.
Gap whiskers treat observed averages as fixed and are not gap confidence
intervals. None of these limitations is hidden by `show_notes=FALSE`:
the notes remain in the return value and ggplot attribute.

## What the full-refit pilot answers

Forty independent generated datasets (20 RSM, 20 PCM) were fitted from scratch,
including fresh Person scoring. Both first datasets were also fully optimized
again at q121, giving **42 completed fits**. All 40 q61 fits were inference-ready
with unregularized structural covariance and no recorded errors or warnings.
The independently implemented fixed-reference FairZ and analytic joint gradient
agreed with the public values and finite differences within the prespecified
tolerances. Five targets per model were checked; targets within a dataset do
not count as independent replications.

On the two actual q61/q121 refit comparisons, maximum absolute FairZ change was
4.75e-11, relative joint-SE change 2.56e-10, interval-endpoint change 5.88e-11,
structural-parameter change 1.71e-10 and Person EAP change 1.28e-9. This supports
numerical stability of those two refits only.

The pilot does **not** support a coverage conclusion. Nominal 95% coverage
ranged from 80% to 100% over the 20 replicates for each target, for both the
conditional and joint candidate intervals. In particular, RSM Rater R3 covered
16/20, with an exact Monte Carlo interval of 56.3%–94.3%; retain this signal for
fresh-seed confirmation rather than declaring correct coverage. Joint-candidate
RMS-SE/empirical-SD ratios ranged about 0.705–1.244. The small changes between
the two interval methods in this design do not establish equivalence, and
adding parameter covariance need not make every interval wider.

The candidate joint SE is repository-only and is not enabled as a new public
RSM/PCM inference option. FairM with reestimated means, Person Fair Score
coverage, paired anchor/model changes, DRF/interactions, GPCM and JML remain
separate required studies. Prior 20,000-dataset structural evidence does not
cover those targets. Full-model TAM matching remains subject to identical
model/constraint/uncertainty definitions.

## Verification and replay

Two focused test runs passed without failures, warnings or skips:

* 604 expectations: bundle dispatch, CI consistency, drawing contracts,
  Fair Score plots and existing GPCM fair-average checks.
* 848 expectations after final ggplot/coordinate checks: Fair Score plots,
  ggplot, output stability, graphics-device state and regression edge paths.
  The Fair Score test file overlaps between runs; these are not additive counts.

The final replay generated **48 drawings**: RSM/PCM × three views × annotated
colour with conditional intervals / clean monochrome without intervals ×
base/ggplot × PNG/PDF. There were no drawing errors or warnings. Visual checks
covered clean measure relationships, observed-score intervals and labelled gap
plots, including a rasterized PDF. Default title/note suppression and preserved
coordinates were also checked programmatically. Whole-package R CMD check and
large-sample coverage confirmation were not run for this change.

Replay from the package root:

```sh
Rscript inst/validation/fair-score-refit-0.2.4.R /tmp/fair-score-refit
```

The [archive](fair-score-refit-0.2.4/) contains per-dataset runs and warnings,
400 target/method rows (not 400 independent datasets), performance summaries,
high-grid full-refit differences, fit objects for the two paired checks, plot
payloads, drawings, exact source hashes and session information. Execution
checks that the source hashes have not changed during the run. Runtime is
recorded per dataset in `runs.csv`; first replicates include high-grid refitting
and figure generation and should not be used as ordinary-fit timing estimates.
