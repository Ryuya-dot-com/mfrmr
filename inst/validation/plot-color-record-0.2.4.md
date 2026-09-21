# Colour accessibility of core fit plots — 2026-09-10

The question is whether users can identify plotted quantities when some colours
are difficult to distinguish or the figure is printed in grey. Avoiding every
green or yellow is not a sufficient design rule: colour combinations, background
contrast, labels, line types, and symbols matter together. This review follows
the redundant-encoding principles in
[Okabe and Ito's Color Universal Design guidance](https://jfly.uni-koeln.de/color/)
and [W3C's explanation of using colour](https://www.w3.org/WAI/WCAG21/Understanding/use-of-color.html).
It is a rendering review, not a statistical-validation or accessibility-certification claim.

## Changes

- Base and ggplot Wright maps, expected-score pathways, fit pathways, and CCCs
  now use the same fit-family series palette. Previously, base CCCs used an
  Okabe-Ito palette but ggplot conversions used their automatic hue scale;
  pathways also used different defaults across renderers.
- The eight default line colours are `#0072B2`, `#D55E00`, `#009E73`,
  `#B56794`, `#222222`, `#666666`, `#A66F00`, and `#007F9E`. These are
  CUD-informed adaptations, not the unchanged Okabe-Ito palette: bright yellow
  is omitted and pink/amber/cyan are darker for light backgrounds. Beyond eight
  series, the existing palette helper uses the dark half of viridis HCL.
- Expected-score/CCC curves use six cycling line types in colour and monochrome.
  CCC empirical overlays also vary point shape. Wright locations retain their
  point shapes; person-density subgroups also use line types. Small data labels
  use neutral dark text instead of lighter coloured ink.
- `preset = "monochrome"` and custom `palette` overrides survive ggplot
  conversion. Supplied palettes are retained in `data$palette`. CCC categories
  retain source order, including numerical empirical-overlay category IDs.
  The latter need explicit categorical conversion for manual ggplot scales;
  the new overlay regression covers all four slope-aesthetic modes.
- With `slope_aes = "colour"`, ggplot CCC slopes use a continuous viridis
  scale (a grey gradient in monochrome); categories still use line types.

```r
# Colour and line-type distinctions are now defaults for these curves.
p <- plot(fit, type = "ccc", show_title = FALSE, show_notes = FALSE)
g <- as_ggplot(p)

# Grey printing retains line-type distinctions in both renderers.
g <- as_ggplot(fit, type = "ccc", preset = "monochrome")
```

## Checks and evidence

The [runner](plot-color-0.2.4.R) reuses the two archived, review-only MML fixtures
from the [model/assignment review](plot-models-record-0.2.4.md): PCM with fitted
interactions and GPCM with Rater-owned slopes. Both have incomplete assignments
and missing scores. No new estimation or recovery simulation was required.

Two fits × six views (native Wright, FACETS-style Wright, expected-score pathway,
fit pathway, CCC, and empirical CCC overlay) × five colour representations ×
two renderers produced **120 PNG drawings without errors** at 7 × 5 inches.
Representations were ordinary colour, `colorspace::protan()`, `deutan()`,
`tritan()` at their default full severity, and `desaturate()`. Only the data
palette is transformed; this is not a full-image or individual-vision simulator.
The [drawing log](plot-color-0.2.4/drawings.csv) retains the fit-review warnings.
The runner verifies that locations, curves, observed proportions, fit tables,
and readiness metadata remain identical when palettes change.

Selected images illustrate both the value and the limits of colour selection:

- [Ordinary GPCM CCC](plot-color-0.2.4/GPCM-Rater-MML-ccc-normal-ggplot.png)
- [Protan simulation](plot-color-0.2.4/GPCM-Rater-MML-ccc-protan-ggplot.png)
- [Deutan simulation](plot-color-0.2.4/GPCM-Rater-MML-ccc-deutan-base.png)
- [Tritan simulation](plot-color-0.2.4/GPCM-Rater-MML-ccc-tritan-ggplot.png)
- [Deutan empirical overlay](plot-color-0.2.4/PCM-interaction-MML-ccc_overlay-deutan-ggplot.png)
- [Deutan expected-score pathway](plot-color-0.2.4/PCM-interaction-MML-pathway-deutan-base.png)

Some simulated hues are similar. Distinct line patterns, symbols, and labels
are therefore part of the repair, not optional evidence that a palette alone
solves the problem.

The review also measured opaque line-ink/background contrast for 8- and
10-series palettes, all five representations, and white/`#fcfdff` backgrounds:
**180 measurements, minimum 3.069:1**. The [measurements](plot-color-0.2.4/contrast.csv)
pass the 3:1 check for this ink/background pairing. This does not
measure pairwise colour separation, faint reference lines, translucent bands,
CI whiskers, arbitrary custom palettes, or full-figure WCAG compliance.
The [W3C non-text contrast explanation](https://www.w3.org/WAI/WCAG21/Understanding/non-text-contrast.html)
informs the chosen check; it does not certify these scientific figures.

Eight additional 5 × 4 inch PDFs (CCC/pathway × base/ggplot × publication/
monochrome presets) were rasterized with Poppler and visually inspected:

| Figure | Colour | Monochrome |
| --- | --- | --- |
| Base CCC | [PDF](plot-color-0.2.4/ccc-base-publication.pdf) | [PDF](plot-color-0.2.4/ccc-base-monochrome.pdf) |
| ggplot CCC | [PDF](plot-color-0.2.4/ccc-ggplot-publication.pdf) | [PDF](plot-color-0.2.4/ccc-ggplot-monochrome.pdf) |
| Base pathway | [PDF](plot-color-0.2.4/pathway-base-publication.pdf) | [PDF](plot-color-0.2.4/pathway-base-monochrome.pdf) |
| ggplot pathway | [PDF](plot-color-0.2.4/pathway-ggplot-publication.pdf) | [PDF](plot-color-0.2.4/pathway-ggplot-monochrome.pdf) |

Focused tests passed **847 expectations in 134 test blocks across eight files**,
with zero failures, errors, unexpected warnings, or skips. They check native/
ggplot colour and line-type mappings, three presets, custom overrides, numerical
payload preservation, contrast, empirical overlays, presentation controls,
graphics state, public method contracts, and mathematical consistency. See the
[combined results](plot-color-0.2.4/tests.csv),
[eight-file log](plot-color-0.2.4/tests.log), and
[final targeted overlay regression](plot-color-0.2.4/tests-corrected.log).
A two-subgroup Wright ggplot smoke check also confirmed solid/dashed density
mapping. Both changed Rd files passed `tools::checkRd()` and `git diff --check`
passed. No new full package or cross-platform check is claimed.

## Reproduction and limits

```sh
Rscript inst/validation/plot-color-0.2.4.R /tmp/mfrmr-plot-color
Rscript inst/validation/plot-color-0.2.4/tests.R
```

`colorspace` is used only by the repository validation runner; no package
dependency was added. The archive includes
[source hashes](plot-color-0.2.4/source-md5.csv),
[test/help hashes](plot-color-0.2.4/review-md5.csv), and
[session information](plot-color-0.2.4/session-info.txt).
Earlier evidence archives remain unchanged.

This is the core fitted-plot family, not an audit of every auxiliary diagnostic
plot. Six line types and five empirical point shapes repeat in larger category
sets. Dense or nearly coincident curves still require suitable labels, panels,
and canvas size. Direct review with users with varied colour vision, other
devices, printing conditions, and remaining auxiliary plots remains future work.
