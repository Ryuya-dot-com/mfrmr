# Plot applicability review — 2026-09-10

This review asks whether the native plot repairs work when data shape and
label content change. It follows the [dense-label repair](plot-label-ux-record-0.2.4.md).
The checks concern rendering, not parameter recovery, standard-error validity,
TAM equivalence, or release approval.

## Conditions and scope

The [runner](plot-generality-0.2.4.R) generates six small datasets with 60
persons each, using seeds 9301–9306, and fits each with RSM and PCM JML
(`maxit = 25`). These are six datasets fitted twice, not twelve independent
simulation conditions or repeated-sampling evidence. Fits remain labelled
review-only; convergence and inferential validity are not acceptance criteria
for these rendering fixtures.

| Dataset | Raters | Items | Categories | Purpose |
| --- | ---: | ---: | ---: | --- |
| minimal | 2 | 2 | 2 | Small dimensions |
| many_levels | 12 | 12 | 4 | Many facets and PCM thresholds |
| many_categories | 4 | 4 | 10 | Threshold density and complete CCC legends |
| coincident | 6 | 6 | 5 | Closely clustered facet estimates |
| long_english | 4 | 4 | 4 | Long names sharing the same prefix |
| japanese | 4 | 4 | 4 | Wide characters and distinct terminal IDs |

For `coincident`, every rater/item gives each person the same score, with
person scores cycling through 1–5. This deliberately difficult input also
creates extreme-score persons; the Wright histogram retains the existing
finite-person policy and displays 36 persons in the archived PCM example.
No fitted coordinates were manually moved to create the fixture.

Each of the 12 fits is drawn with native Wright, expected-score pathway,
and CCC plots at 5 × 4, 7 × 5, and 12 × 8 inches, in PNG and PDF, using
`preset = "publication"`: **216 drawings**. The [conditions](plot-generality-0.2.4/conditions.csv)
and [per-drawing results](plot-generality-0.2.4/results.csv) are archived.

## Defects and changes

* **Missing facets:** PCM thresholds previously consumed the native Wright
  `top_n` budget. With 36 thresholds, the default limit of 30 removed all 24
  rater/item locations. `top_n` now limits non-person facet locations; all
  thresholds are retained separately. The same case now shows 24 facets and
  36 thresholds. This intentionally changes returned locations, their layout,
  and retention counts. `top_n = Inf` still requests all locations.
* **Indistinguishable names:** the shared abbreviation helper now measures
  display width and retains distinguishing suffixes when shortened prefixes
  collide. If shortening remains ambiguous, it retains full names. CCC panel
  titles are shortened together so their identities remain distinguishable.
* **Crowded labels:** placement gives fitted-point avoidance priority over
  label separation. If its greedy placement cannot separate the labels, it
  retains them and warns that a larger figure is needed. The warning concerns
  readability; it is independent of the fit-readiness warning.
* **Clipped/repeated CCC keys:** more than five categories now use one margin
  legend, and colour presets beyond eight categories use distinct default
  colours. A single-group CCC keeps its legend inside the caller's panel.
  Native Wright legend offsets now use physical spacing so larger figures
  do not push the keys beyond the right page edge.

No estimation code changed in this follow-up. The [numerical comparison](plot-generality-0.2.4/numerical-comparison.csv)
contains 36 exact comparisons against saved pre-change payloads. Person tables,
matched Wright estimates/SEs/CI limits, expected-score tables, step tables,
long pathway tables, category probabilities, and curve-basis tables match.
The [paired payloads](plot-generality-0.2.4/payload-comparison.rds) retain both
versions. This is not equality of every returned field: Wright selection and
display metadata, abbreviations, and large-category CCC legend colours change.

## Results and visual inspection

All 216 drawings completed without errors. Geometry instrumentation checks
the text boxes managed by the native Wright/pathway placement helper: 144
drawings in total. It does not measure CCC text or every decorative element.

| Size (inches) | All drawings | Wright/pathway checked | Drawings with overlapping label boxes | Capacity warnings | Covered point centres | Boxes outside plot |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 5 × 4 | 72 | 48 | 4 | 4 | 0 | 0 |
| 7 × 5 | 72 | 48 | 10 | 10 | 0 | 0 |
| 12 × 8 | 72 | 48 | 0 | 0 | 0 | 0 |

Thus, small and ordinary devices are **not uniformly readable**. Each measured
overlap is accompanied by the capacity warning. Every measured label-box
overlap disappears at 12 × 8 inches in this grid; these examples do not imply
that greedy placement improves monotonically at every intermediate size.

The following archived examples were visually inspected. Both archived PDFs
were also rendered with `pdftoppm` and their page images inspected.

| Example | Inspected output |
| --- | --- |
| 24 facet locations plus 36 thresholds | [Crowded 7 × 5](plot-generality-0.2.4/many_levels-PCM-wright-7x5-png.png), [12 × 8](plot-generality-0.2.4/many_levels-PCM-wright-12x8-png.png) |
| Long English names | [Wright, 12 × 8](plot-generality-0.2.4/long_english-PCM-wright-12x8-png.png) |
| Japanese names | [Wright PDF](plot-generality-0.2.4/japanese-PCM-wright-12x8-pdf.pdf), [rendered preview](plot-generality-0.2.4/japanese-PCM-wright-12x8-pdf-preview.png), [pathway PNG](plot-generality-0.2.4/japanese-PCM-pathway-7x5-png.png) |
| Ten categories | [PCM 5 × 4](plot-generality-0.2.4/many_categories-PCM-ccc-5x4-png.png), [PCM PDF 12 × 8](plot-generality-0.2.4/many_categories-PCM-ccc-12x8-pdf.pdf), [rendered preview](plot-generality-0.2.4/many_categories-PCM-ccc-12x8-pdf-preview.png), [RSM 7 × 5](plot-generality-0.2.4/many_categories-RSM-ccc-7x5-png.png) |
| Clustered facet estimates | [Wright, 12 × 8](plot-generality-0.2.4/coincident-PCM-wright-12x8-png.png) |

## Devices and Japanese text

This pass used R 4.6.1 on macOS, Quartz PNG at 110 dpi, base PDF for Latin
cases, and Quartz PDF for Japanese cases. Japanese output uses registered
Hiragino Sans faces and `par(family = "Japanese")`. The runner deliberately
requires Quartz for reproducing this specific archive; the package API does
not require macOS or that font.

Local probes found that `cairo_pdf()` could not open because an XQuartz
library was missing despite Cairo capability being reported. Base PDF with
`Japan1` produced badly spaced Latin text in mixed Japanese/Latin labels.
Those failed probes are excluded from the 216-drawing record. The final
runner checks that the requested device opened and uses the working Quartz
route for Japanese output. For example, on this Mac:

```r
quartzFonts(Japanese = quartzFont(c(
  "HiraginoSans-W3", "HiraginoSans-W6",
  "HiraginoSans-W3", "HiraginoSans-W6"
)))
quartz(type = "pdf", file = "wright.pdf", width = 12, height = 8)
par(family = "Japanese")
plot(fit, type = "wright", preset = "publication")
dev.off()
```

The package leaves font selection to the caller. Japanese rendering on
Windows/Linux and other graphics devices requires its own visual check.

## Regression checks and remaining work

The [focused tests](plot-generality-0.2.4/tests.csv) report **706 successful
expectations in 145 test blocks across eight files**, without failures,
errors, unexpected warnings, or skips (`NOT_CRAN=true`). The [test log](plot-generality-0.2.4/tests.log)
is retained. Checks cover device-state restoration, caller grids, Wright
retention, abbreviation identity/display width, crowding notification, CCC
legend bounds and category colours, and existing plot/ggplot/data contracts.

Reproduce the drawing grid from the package root:

```sh
Rscript inst/validation/plot-generality-0.2.4.R /tmp/mfrmr-plot-generality
```

Reproduce the focused tests after `Sys.setenv(NOT_CRAN = "true")` and
`pkgload::load_all(".")` by running `testthat::test_file()` for
`test-plot-device-state.R`, `test-draw-and-plot-contracts.R`,
`test-wright-facets-style.R`, `test-as-ggplot.R`,
`test-plot-customization.R`, `test-plotting-extras.R`,
`test-fit-pathway.R`, and `test-api-public-method-contracts.R` in
`tests/testthat/`.

The [source hashes](plot-generality-0.2.4/source-md5.csv),
[session information](plot-generality-0.2.4/session-info.txt), and
[execution log](plot-generality-0.2.4/execution.log) identify this pass.
The runner regenerates all figures; only inspected examples are archived.

Remaining scope includes other devices/OSs, interactive resizing, substantially
larger item/category counts, other scripts, GPCM and structured missingness/
interaction designs, and dense ggplot output. Curve/CI strokes and leader-line
crossings are not collision targets, and finite canvases can remain crowded.
The fixes are shared package code, but these bounded examples do not establish
arbitrary-dataset applicability. No full package check or release approval was
performed in this follow-up; earlier validation archives remain unchanged.
