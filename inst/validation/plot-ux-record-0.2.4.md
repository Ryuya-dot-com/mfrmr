# Plot UX review — 2026-09-10

The question was whether users can draw Wright, pathway, and CCC plots in
sequence without inheriting an unintended panel size, and whether the figures
remain readable at ordinary device sizes. No recovery simulation was started.

## Reproduction and correction

With `par(mfrow = c(2, 2))`, four single-panel calls (`pathway`, `person`,
`step`, `fit_pathway`) produced four pages with each plot in the upper-left
cell. After every call, the old implementation restored `mfg = c(2, 2, 2, 2)`.
The next plot therefore started another page instead of advancing one cell.
The [first page before the repair](plot-ux-0.2.4/before-grid-first.png) records
that behavior. The [repaired grid](plot-ux-0.2.4/grid.png) contains all four
plots on one page.

The shared `apply_plot_preset()` restored every writable `par()` value,
including panel position and plot coordinates. Local renderers repeated the
same pattern. Restoration now covers only the settings each function changes.
This follows the graphics distinction between style, layout, and panel cursor;
the [R graphics documentation](https://stat.ethz.ch/R-manual/R-devel/library/graphics/html/par.html)
describes `mfg` and the side effects of restoring graphical parameters.

A fresh-device Wright → pathway → CCC sequence already occupied full pages
before this repair. The user's exact preceding calls and interactive device
were not supplied, so the reproduced caller-grid failure is the established
cause here, not a claim that every possible upper-left display had that cause.

Native Wright and multi-group CCC renderers now clean up their page layouts;
single-panel renderers preserve caller-defined unequal column widths. The
data-quality dashboard explicitly restores the grid it creates. The APA
composite uses the existing single-panel FACETS-style Wright renderer without
CI whiskers, and its returned Wright payload records that renderer choice.
The public help describes which renderers own a page layout.

## Readability changes and visual checks

- [Wright map, 7 × 5 inches](plot-ux-0.2.4/RSM-7x5-01.png): shared title,
  separate panel headings, measured legend space, and outer footnotes.
- [PCM pathway, 7 × 5 inches](plot-ux-0.2.4/PCM-7x5-02.png): endpoint labels
  have reserved space and leader lines; vertical spacing accounts for text
  height. Dominant-category strips no longer share numeric score ticks.
- [CCC, 7 × 5 inches](plot-ux-0.2.4/RSM-7x5-03.png): the reference-profile
  note wraps within the figure instead of disappearing off the right edge.
- [APA composite, 12 × 9 inches](plot-ux-0.2.4/apa.png): four distinct panels,
  wrapped summary, and subtitles below axis labels.
- [Wright subgroup curves](plot-ux-0.2.4/wright-groups.png): densities now draw
  in the person histogram panel, with an explicit scaled-density legend.
- [Small Wright](plot-ux-0.2.4/RSM-5x4-01.png) and
  [small PCM pathway](plot-ux-0.2.4/PCM-5x4-02.png): font and margin scaling
  checked at 5 × 4 inches.

Dense PCM threshold labels still collide within the plotting area, especially
when several transitions nearly coincide. More selective annotation or separate
panels is the next readability task. Arbitrary long labels, extremely small
panels, and interactive RStudio/Quartz resizing have not been certified by this
review. Native multi-panel plots should be drawn outside a custom `layout()`;
the single-panel FACETS renderer is the supported Wright option inside one.

## Validation and scope

The [focused test results](plot-ux-0.2.4/tests.csv) contain 123 test blocks and
631 successful expectations across 11 files, with no failures, errors,
unexpected warnings, or skips. New device-state tests verify panel progression,
style restoration, unequal caller layouts, standalone RSM/PCM sequences, and
four actual plot regions in the APA composite. Existing tests cover drawing,
fit pathways, customization, FACETS rendering, secondary/screening plots,
ggplot conversion, expanded summaries, and facet equivalence.

For the same saved RSM and PCM fits, all four draw-free payloads (`wright`,
`pathway`, `fit_pathway`, `ccc`) were identical before and after the drawing
changes. The explicit APA renderer selection is the intended composite-payload
change. This is a rendering check, not new statistical validation or evidence
of TAM/FACETS numerical equivalence.

Reproduce the figures from the package root with
`Rscript inst/validation/plot-ux-0.2.4.R /tmp/mfrmr-plot-review`.
Run the new regression check after `pkgload::load_all()` with
`testthat::test_file("tests/testthat/test-plot-device-state.R")`.
The [session information](plot-ux-0.2.4/session-info.txt) and
[R source hashes](plot-ux-0.2.4/source-md5.csv) identify the visual review source.
Historical simulation archives remain unchanged; their previous full-source
hashes do not identify this revised source. A complete package/release check
and platform-wide visual review were not performed in this focused pass.
