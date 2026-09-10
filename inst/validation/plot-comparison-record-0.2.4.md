# Paired Wright/CCC views following the JLTA review — 2026-09-10

The question is whether two fitted models produce similar distributions,
matched locations and conditional category probabilities, and where their
differences occur. Following the review of JLTA slide pages 13–14,
`plot_compare_mfrm()` now provides two plot types with comparison and
difference views. It reuses native plot data, the existing probability engine,
comparison signatures and the optional ggplot2 renderer. No dependency is added.

```r
plot_compare_mfrm(fit_rsm, fit_pcm, type = "wright",
                  labels = c("RSM", "PCM"), curve_groups = "Accuracy")
p <- plot_compare_mfrm(fit_rsm, fit_pcm, type = "ccc",
                      view = "difference", labels = c("RSM", "PCM"),
                      curve_groups = "Accuracy", preset = "monochrome",
                      show_title = FALSE, show_notes = FALSE)
p$data$differences
p$data$summary
p$data$notes
g <- as_ggplot(p)
```

`Accuracy` is an example group in the packaged example data; callers select
their own step-facet levels. `draw = FALSE` needs no ggplot2 installation.
Drawing and `as_ggplot()` use the existing optional ggplot2 dependency. The
selected view is a single customizable ggplot object, not a preassembled
multi-figure report. No source model is refitted by plotting.

## Display and returned information

Wright comparisons place models side by side within person, facet and
selected step panels on a shared vertical scale. Persons have both raw points
and violins when at least two distinct eligible estimates exist; otherwise
only points are drawn. These are distributions of fitted person point
estimates, not posterior or population densities. Step labels identify actual
adjacent original-score transitions and connect to the corresponding points.
Only annotation positions and horizontal point spacing are adjusted.

The Wright difference view joins by `(Kind, Facet, Level)` and plots signed
differences against the means of the paired locations. RSM shared steps are
explicitly reused for each selected PCM/GPCM group. Unmatched, non-finite,
boundary-separated and source-excluded rows remain in `data$differences` with
status fields and unavailable differences. An empty matched panel is labelled
as unavailable rather than filled with zero differences. The raw source
estimates and native source payloads remain available for audit.

CCC comparisons use category colour and model line type. By default,
monochrome or more than five categories uses category panels; four categories
use a 2 by 2 arrangement. Each panel labels the group and original category.
CCC difference views use a zero reference and symmetric probability-difference
limits. `panel = "group"` explicitly requests overlays; monochrome overlays
with multiple categories warn about ambiguity. More than eight panels warn
about display size without silently dropping panels.

| Payload | Meaning |
| --- | --- |
| `locations` | Wright estimates, source estimates, availability statuses and identities for each fit |
| `probabilities` | CCC coordinates with source group, comparison group, slope and fit identity |
| `differences` | Comparison minus reference, with source values and matching keys |
| `summary` | CCC maximum absolute difference on the requested grid, its signed value and the first maximizing row's predictor/category |
| `group_selection` | Available, selected and unselected groups; explicit RSM-to-PCM/GPCM group pairing |
| `category_labels` | Internal code to original-score mapping; CCC tables also include `OriginalCategory` |
| `basis`, `scale_contracts` | Recorded comparison-setting matches and source coordinate/population/slope contracts |
| `fit_readiness`, `notes`, `source_plots` | Per-fit readiness, interpretation notes and original native plot payloads |

`Category` retains the native internal code. Display labels and
`OriginalCategory` use the original score. `ExpectedScoreDifference` is the
difference between native expected scores on the internal score coding;
it must not be read as an original-score difference when recoding changed
category increments. A grid maximum is not a continuous-domain supremum.

## Statistical boundaries

Recorded estimator method, facet definitions, centering, anchors, orientation,
score coding and coordinate basis must match. Non-RSM comparisons require the
same step owner, and every requested group must exist in both fits. Missing
groups require explicit valid selection; no automatic scale alignment, score
recode or probability interpolation is performed. Matching recorded settings
does not prove scale equivalence or that observations/assignments are identical.
Different population SDs remain visible and are not silently standardized.

All CCCs retain fitted GPCM slopes and fix additive facet effects and fitted
interactions at zero. They do not average over observed rater assignments.
Visual overlap and small differences do not establish model equivalence.
No difference SE, covariance, CI, significance test or equivalence threshold is
calculated. `compare_mfrm()` remains the separate information-criterion route.
External software import/adaptation and validated scale transformations remain
separate work. Source readiness is not upgraded by these plots.

## Verification

The [replay script](plot-comparison-0.2.4.R) fits RSM and PCM to the same
12-person slice of packaged example data, then constructs explicitly edited
fixtures for 11 categories with original scores 5–15, one person, unmatched
person IDs and a long group name. The edited fixtures test display contracts;
they are not refitted models or evidence of empirical model stability.

The archive contains **60 PNG/PDF drawings**, including paired comparison and
difference views, publication/monochrome presets and clean/annotated variants.
All drawings completed without errors or unexpected warnings, and drawn and
draw-free payloads were identical. Eight CCC drawings emitted the expected
many-panel advisory for 11 category panels. See
[drawings.csv](plot-comparison-0.2.4/drawings.csv) and
[execution log](plot-comparison-0.2.4/drawings.log). Ordinary figures use 9 by
5.5 inches; 11-category fixtures use 10 by 9 inches.

Representative Wright comparisons, differences, monochrome CCCs, probability
differences, 11-category, singleton, unmatched and long-label figures were
visually inspected. PDF raster previews of the paired Wright and 2 by 2 CCC
figures confirm readable transition labels, model encodings and omitted
titles/notes in clean mode:

- [Paired Wright map, monochrome](plot-comparison-0.2.4/paired-wright-comparison-monochrome-clean.pdf)
- [Paired CCCs, monochrome](plot-comparison-0.2.4/paired-ccc-comparison-monochrome-clean.pdf)
- [Probability differences, colour](plot-comparison-0.2.4/paired-ccc-difference-publication-annotated.pdf)
- [Eleven categories, monochrome](plot-comparison-0.2.4/eleven-ccc-comparison-monochrome-clean.pdf)

Relevant checks passed **316 expectations in 20 blocks across four files**,
with zero failures, errors, unexpected warnings or skips. The
[initial run](plot-comparison-0.2.4/initial-tests.log) covered as-ggplot,
namespace-contract, plot-comparison and plot-device-state. The
[final targeted run](plot-comparison-0.2.4/final-tests.log) repeated the
comparison checks after label/layout and original-category refinements.
[Combined results](plot-comparison-0.2.4/tests.csv) retain the unaffected
initial files and replace comparison rows with the final 83-expectation run.

Checks include known signed perturbations, probability normalization,
RSM-to-PCM pairing, missing identities, incompatible bases, original coding,
11-category GPCM probabilities against a separate direct softmax calculation,
and monochrome/title/note/device behavior. A one-person fixture exposed the
existing native Wright builder's undefined one-observation FD histogram rule;
the shared builder now uses a single bin, covering both ordinary and paired
Wright routes. Constant-coordinate step labels are spread without changing
the plotted estimates. `tools::checkRd()` and `git diff --check` passed. A full
package check and statistical release validation were not part of this addition.

Replay from the package root with
`Rscript inst/validation/plot-comparison-0.2.4.R <output-directory>`.
[Source hashes](plot-comparison-0.2.4/source-md5.csv),
[test hashes](plot-comparison-0.2.4/test-source-md5.csv),
[fit fixtures](plot-comparison-0.2.4/fits.rds) and
[session information](plot-comparison-0.2.4/session-info.txt) record the
checked environment. Earlier visualization archives are unchanged.
