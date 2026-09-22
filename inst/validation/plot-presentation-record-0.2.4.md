# Plot presentation and returned notes review — 2026-09-10

This review separates figure presentation from interpretation information in
`plot.mfrm_fit()` and its ggplot conversion. It also checks visibility on small
devices. It does not change estimates or establish statistical validity.

## API

```r
p <- plot(fit, type = "wright", show_title = FALSE, show_notes = FALSE)
p$data$notes
print(p)

g <- as_ggplot(p)
attr(g, "mfrmr_notes")

# The same flags can be passed when converting a fit directly.
g <- as_ggplot(fit, type = "pathway", show_title = FALSE, show_notes = FALSE)
```

Both flags default to `TRUE` and are validated as non-missing scalar logicals.
They control main titles and explanatory annotations, including review-only
title markers. Axis labels, legends, data labels, and structural panel headings
remain visible. Bundle components inherit the settings.

`data$display` records the flags; `data$notes` is a `Type`/`Text` table containing
available interpretation, reference-profile, retention, and display notes.
The original title/subtitle, numerical coordinates, readiness status, and
other plotting payloads remain available. `print()` prints the notes, and
ggplot conversion retains them as an attribute while returning an ordinary,
composable ggplot. See the [example notes](plot-presentation-0.2.4/notes-example.csv).

These are model/display explanations, not automatic substantive conclusions.
Device-dependent layout warnings are issued during drawing, not captured in
the draw-free notes table. Hiding annotations does not suppress R warnings or
authorize interpretation of a review-only fit.

## Visibility repairs

- Clean native expected-score pathways retain sufficient bottom margin for
  the theta-axis title. Title-only and fully unannotated variants were inspected.
- FACETS-style Wright headings use explicit text placement instead of an axis
  that silently omits nearby headings. Scale headings occupy two lines, and
  text size accounts for column width. Facet-cell text wraps to column width.
- FACETS-style footnotes now wrap within the figure, with a corresponding
  bottom margin. The displayed notes and returned Wright explanations share
  one helper, including interval clipping and boundary information.
- Frequency stars that extend beyond their column trigger a specific warning
  recommending more width or a larger `persons_per_star`. This is a detected
  capacity limit, not automatic removal or reassignment of persons.
- The shared ggplot helper uses exact lookup for the presentation settings.
  Regression testing caught and fixed partial matching to the simulation
  payload's `display_metric`, which initially broke signal-detection conversion.

## Evidence

The [runner](plot-presentation-0.2.4.R) reuses the archived PCM interaction MML
and GPCM Rater-owner MML fits from the
[model/assignment review](plot-models-record-0.2.4.md). Both are deliberately
short, review-only rendering fixtures with incomplete assignments and missing
scores. They are not newly approved analysis results.

Two fits × four views (native Wright, FACETS-style Wright, expected-score
pathway, CCC) × four title/note combinations × two renderers × two sizes
(5 × 4 and 7 × 5 inches) produced **128 PNG drawings without errors**.
The runner also verifies that the complete returned payload, excluding only
`display`, is identical across the four presentation settings.
The [drawing log](plot-presentation-0.2.4/drawings.csv) retains drawing warnings:
16 FACETS-style cases report frequency-column overflow. Review-only warnings
remain on base drawing calls; ggplot conversions reuse previously created
payloads and do not repeat fit warnings.

Selected PNGs are archived. Four 5 × 4 inch PDF exports were rasterized with
Poppler and visually inspected for axes, headings, legends, and clipping:

- [Native Wright PDF](plot-presentation-0.2.4/PCM-interaction-MML-wright-base-clean.pdf)
- [Expected-score pathway PDF](plot-presentation-0.2.4/PCM-interaction-MML-pathway-base-clean.pdf)
- [GPCM ggplot CCC PDF](plot-presentation-0.2.4/GPCM-Rater-MML-ccc-ggplot-clean.pdf)
- [FACETS-style PDF](plot-presentation-0.2.4/PCM-interaction-MML-facets-base-clean.pdf),
  using `persons_per_star = 4` to keep its frequency column inside the small page.

The [annotated FACETS example](plot-presentation-0.2.4/PCM-interaction-MML-facets-TRUE-TRUE-base-5x4.png)
shows wrapped footnotes and every heading, as well as the remaining frequency
overflow under the default star scale. Small dense figures still need an
appropriate width or frequency setting. The 128 successful drawing calls are
not a claim that every possible label or dataset is readable on every canvas.
ggplot explanatory text still uses the documented 72-column wrapping rule;
narrow exports may require `ggplot2::labs()` adjustments or separate captions.

Focused regression checks passed **793 expectations in 133 test blocks across
eight files**, with zero failures, errors, unexpected warnings, or skips.
They cover independent visibility flags, return-data equality, printed notes,
ggplot attributes, flag validation, retained R warnings, bundle propagation,
graphics-state restoration, Wright/fit pathways, public method contracts,
simulation ggplot conversion, and mathematical consistency. See the
[results](plot-presentation-0.2.4/tests.csv),
[log](plot-presentation-0.2.4/tests.log), and
[test driver](plot-presentation-0.2.4/tests.R).
Both edited Rd files parsed and passed `tools::checkRd()`; `git diff --check`
passed. This is a focused check, not a new full package or cross-platform check.

Reproduce from the package root:

```sh
Rscript inst/validation/plot-presentation-0.2.4.R /tmp/mfrmr-plot-presentation
Rscript inst/validation/plot-presentation-0.2.4/tests.R
```

The archive includes [source hashes](plot-presentation-0.2.4/source-md5.csv),
[test/help hashes](plot-presentation-0.2.4/review-md5.csv), and
[session information](plot-presentation-0.2.4/session-info.txt).
Earlier validation archives remain unchanged. Release approval and broader
statistical and cross-platform review remain separate work.
