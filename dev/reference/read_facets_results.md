# Read FACETS results for standalone visualization and fit review

Import reported element measures, fit statistics and optional Graphfile
curves without refitting a model. Use `plot.mfrm_facets_results()` to
inspect the saved results, or pass the returned object to
[`facets_fit_review()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/facets_fit_review.md)
for external FACETS-vs-mfrmr fit comparison.

## Usage

``` r
read_facets_results(
  file = NULL,
  facet = NULL,
  facet_map = NULL,
  format = c("auto", "delimited", "scorefile"),
  facet_col = NULL,
  level_col = NULL,
  delimiter = NULL,
  encoding = "UTF-8",
  source_version = NULL,
  measure_units = NULL,
  common_scale = FALSE,
  graph_file = NULL
)

# S3 method for class 'mfrm_facets_results'
summary(object, ..., component = c("elements", "curves"))

# S3 method for class 'mfrm_facets_results'
print(x, ...)

# S3 method for class 'mfrm_facets_results'
as.data.frame(
  x,
  row.names = NULL,
  optional = FALSE,
  ...,
  component = c("elements", "curves")
)

# S3 method for class 'mfrm_facets_results'
plot(
  x,
  type = c("measure", "wright", "fit", "infit_outfit", "ccc", "expected"),
  facets = NULL,
  statistic = c("infit", "outfit"),
  draw = TRUE,
  show_title = FALSE,
  show_notes = FALSE,
  show_legend = TRUE,
  scales = NULL,
  label_map = NULL,
  ...
)
```

## Arguments

- file:

  Scorefile input (a vector of file paths, a directory containing
  `score.N.txt` files, or a data frame), or `NULL` when only
  `graph_file` is supplied.

- facet:

  Optional facet name to assign when the file does not contain a facet
  column. Use this for one-facet CSV exports.

- facet_map:

  Optional character vector mapping FACETS score-file numbers to facet
  names, for example `c("1" = "Person", "2" = "Rater")`. If unnamed,
  positions are used as score-file numbers.

- format:

  File format. `"auto"` detects FACETS `score.N.txt` files from their
  name/header; `"delimited"` reads a CSV/TSV/semicolon table; and
  `"scorefile"` reads a FACETS score-file table, including comma, tab or
  semicolon exports with facet heading lines. Fixed-field input requires
  validated all-field headings with element number after the statistics;
  appended facet fields are separated from the element label.
  Headerless, element-first and selected-field fixed layouts are
  rejected. Use named delimited columns for those layouts and for
  non-ASCII labels.

- facet_col, level_col:

  Optional explicit column names for delimited tables when automatic
  detection is not sufficient. For score files, `level_col` can override
  the column immediately before `F-Number`.

- delimiter:

  Optional delimiter for delimited tables. If omitted, comma, tab, and
  semicolon are detected from the header line.

- encoding:

  Source file encoding, explicitly converted to UTF-8.

- source_version:

  Optional FACETS version recorded with these exports. Unknown versions
  remain `NA`; the reader does not infer a version.

- measure_units:

  Optional description of the reported measure units, after checking
  FACETS reporting transformations. Unknown units remain `NA`.

- common_scale:

  Logical; explicitly declare that the imported facets have compatible
  units and origins for a shared-axis Wright map. Defaults to false.
  This declaration does not transform, center or reverse measures.

- graph_file:

  Optional path to one FACETS Graphfile with headings, in CSV,
  tab-separated or validated ASCII fixed-width format. Supply an export
  from the same analysis when also importing element results. File
  identity is recorded, but the reader cannot certify that the exports
  belong together.

- object:

  A saved `mfrm_facets_results` object.

- ...:

  Must be empty.

- component:

  `"elements"` (default) or `"curves"` for Graphfile results.

- x:

  Saved output of `read_facets_results()`.

  Also for [`summary()`](https://rdrr.io/r/base/summary.html): A saved
  `mfrm_facets_results` object.

- row.names:

  Optional row names for the exported data frame.

- optional:

  Passed to
  [`as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html).

- type:

  `"measure"` for labelled element locations by facet; `"wright"` for
  points by facet on one measure axis; `"fit"` for measure versus mean
  square; or `"infit_outfit"` for Infit versus Outfit. Wright maps
  require the explicit `common_scale = TRUE` declaration at import.
  `"ccc"` plots Graphfile category probabilities and `"expected"` plots
  Graphfile expected scores, each in separate scale panels.

- facets:

  Optional character vector of facet names to display.

- statistic:

  `"infit"` or `"outfit"`, used for `type = "fit"`.

- draw:

  Logical; print the `ggplot` figure when true.

- show_title, show_notes:

  Logical; show title/interpretation notes in the plot, off by default.
  Notes always remain in the returned data.

- show_legend:

  Logical; display the source-status symbol key or category curve key
  below the panels. Defaults to true.

- scales:

  Optional vector of Graphfile scale numbers for curve plots. Facet
  selectors do not apply to curves, and scale selectors do not apply to
  element plots.

- label_map:

  Optional data frame with character columns `Facet`, `ElementID` and
  `DisplayLabel` for element plots. Keys must match exported IDs in `x`,
  including any leading zeros, and must be unique within a facet. A
  partial map is allowed; unmapped rows retain their source labels.
  Mapping is checked against the full result before `facets` selection.
  This changes display labels only, not source labels or element
  identity. Curve plots do not accept this map. Only `type = "measure"`
  draws element labels; the other element plots retain them in returned
  plot data.

## Value

A `mfrm_facets_results` list with `table` (all imported rows, source
tokens, IDs, status and per-quantity availability), `sources` (file
paths, MD5 checksums and encoding; unavailable for data frames),
`metadata` (source declarations) and `notes`. When supplied, `graph`
contains the original character `table`, long `curves` with raw tokens,
precision and availability, row-level `diagnostics`, `categories` and
detected `layout`. Graph `metadata` identifies its separate coordinate
system; its units remain unknown rather than inheriting element
`measure_units`. [`summary()`](https://rdrr.io/r/base/summary.html)
counts available rows by facet. `AnchorFlagged` counts
`SourceStatus = "anchored"` rows, not individually fixed parameters; it
replaces the earlier candidate's ambiguous `Anchored` summary column.
[`as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html) exports
the element table. Use `component = "curves"` with either method to
inspect Graphfile curves. Use
[`saveRDS()`](https://rdrr.io/r/base/readRDS.html) to retain the full
object.

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Invisibly
a `ggplot` object whose underlying payload (accessible via
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data.md))
retains every selected row in `plot_data` with `X`, `Y`, `Available` and
`Reason`; element plots also have `Symbol`, and curves have `Series`,
`Color`, `LineType` and `Segment`. Unavailable numerical coordinates are
`NA` (measure plots retain label positions). Original reported
values/status remain in the same rows. `notes`, `sources` and `metadata`
describe interpretation and origin. `label_map` retains a supplied
display map. Filtering and display labels do not change the saved
results.

## Details

Each file must describe one analysis. Supply a vector of facet files or
a directory containing `score.N.txt` files, or a named delimited table.
Comma, tab and semicolon Scorefiles retain their native facet heading
lines. Numeric facet numbers default to `Facet1`, `Facet2`, etc.; supply
`facet_map` to name them. A data frame is also accepted. Validated
fixed-field Scorefile layouts and named delimited tables are supported;
use named delimited files for non-ASCII labels because byte and
character widths can differ. For text output from FACETS, request
`Scorefile=score.txt`, `Heading lines=Yes`, `QM=Double` and
`CSV=Commas`, `Tabs` or `Semicolons`. Check that the files were actually
generated; a zero process exit code alone does not establish a
successful export. Specify the encoding of the existing file; the reader
does not configure FACETS input encoding or repair labels already lost
during export. Element IDs are preserved separately from display labels.
Where no ID was exported, the label is the key; ambiguous duplicate keys
are rejected, not averaged. Unknown source status remains unknown.

FACETS status codes distinguish anchor-flagged, estimated, extreme,
no-data, unmeasurable and single-observation elements. `StatusRaw = "1"`
and the retained `SourceStatus = "anchored"` mean an anchor flag, not
proof that the individual measure was fixed. FACETS 4.5.0 uses this flag
for estimated group-anchor members as well as direct anchors and
singleton groups. `GroupRaw` can also describe a reporting group; it
does not establish the anchor subtype. Neither a group's imported size
nor a reported SE resolves that ambiguity. Check the original `Labels=`
specification for the anchor mode and Table 7 for row annotations. A
Table 7 G annotation alone need not distinguish the G and X input modes.
This reader does not parse those sources or infer a subtype. Extreme
group members can instead carry Status -2/-3, so `AnchorFlagged` does
not count every member of an anchored group. Finite extreme measures are
retained as reported locations, not ordinary finite maximum-likelihood
estimates. The status alone does not identify their adjustment rule:
native X group anchoring can report a different location from G
anchoring. Reported fit values for extremes can be placeholders, so
their fit plots are unavailable. No-data and unmeasurable elements
remain in the returned table. Missing or censored values are never
replaced with zero. Marginal source SEs are retained for inspection, but
do not supply joint covariance or validated confidence intervals. The
object contains no likelihood, response data, inferred thresholds,
new-person scoring or calibration-inclusive inference.

Source measures, signs and rounding are retained. A positive or negative
sign describes the source model contribution; the plot does not multiply
measures by that sign. Check the original specification before
interpreting severity, ability or comparing facet origins. Reading
results does not validate their convergence, model fit or substantive
interpretation.

Graphfiles preserve the reported `Scale`, `Measure`, `Expected`,
`ExpCat` and `Prob:<category>` fields. Scale numbers identify Table 8
subtables, not automatically items or facets. Category labels can differ
from response codes (including binary exports labelled 1/2); no recoding
is performed. `Expected` is used directly, not recomputed from
probabilities or `ExpCat`. The Graphfile Measure axis is not
automatically a Person ability axis or the coordinate system of
Scorefile measures; `measure_units` and `common_scale` apply only to
element plots.

Graph imports require unambiguous headings and strictly monotone
distinct finite measures within each scale. Missing coordinates/values
are retained with reasons and break curve lines. Probability sums are
checked against the sum of half the printed units of precision, plus
floating-point tolerance; sums outside that rounding allowance are
withheld from probability plots. Incomplete probability vectors remain
flagged, with available individual probabilities retained. Nothing is
renormalized, smoothed or extrapolated. These are source-consistency
checks, not validation of the fitted model.

[`plot()`](https://rdrr.io/r/graphics/plot.default.html) method: Plot
imported FACETS measures, fit statistics and curves

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Each
measure panel has its own axis; the Wright display shares one measure
axis without centering, reversing signs or inventing category
thresholds. Filled circles denote estimated elements, squares
direct/group anchor flags, downward/upward triangles extreme low/high
source status, diamonds single observations and open circles unknown
source status. The symbol key is in `plot_data(p, "legend")`. A square
marks source Status 1; it does not identify an individually fixed
measure. Group-anchor members can vary around a fixed group mean, and
`GroupRaw` may instead be a reporting group. Check the original
specification or Table 7 to distinguish direct and group anchors.
Returned notes retain this limitation, also when plotting imports saved
by an earlier version; the source object is not changed. Recreate saved
plot-data objects with
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) to obtain the
revised legend and notes. Duplicate display labels are disambiguated by
element key in measure plots. Use `label_map` to display local names
while retaining the original FACETS labels and IDs. It cannot recover
names lost in an export; supply the known correspondence yourself.
Character preservation and font rendering are separate: choose an
installed font with the required glyphs on the graphics device. With
Cairo support,
[`grDevices::png()`](https://rdrr.io/r/grDevices/png.html) with
`type = "cairo"` and
[`grDevices::cairo_pdf()`](https://rdrr.io/r/grDevices/cairo.html)
accept a `family` such as `"Meiryo"` on Windows when installed. Font
availability differs across systems. The plot does not install fonts or
change global font settings. Infit/Outfit reference lines at one
describe the model reference, not a fairness or acceptability cutoff. No
confidence bars are calculated. Extreme/single-observation fit
placeholders and unmeasurable/no-data elements are retained as
unavailable. A plot can have no usable points; inspect its row-level
reasons. Unknown status is displayed explicitly, not certified.
Graphfile curves join consecutive exported coordinates with straight
line segments; this does not calculate new model predictions. Missing or
invalid rows break the lines. The legend identifies source category
labels. Expected scores and category labels retain their source coding.
Each panel has its own reported Measure axis, independent of
element-plot scale declarations. For curves, `plot_data(p, "data")`
holds the raw Graphfile table, `plot_data(p, "plot_data")` the selected
long rows, and `plot_data(p, "diagnostics")` the probability-sum checks.

## References

FACETS Scorefile specification:
<https://www.winsteps.com/facetman64/scoreoutput.htm>. FACETS Graphfile
specification: <https://www.winsteps.com/facetman64/graphfile.htm>.
FACETS element and Table 7 anchor annotations:
<https://www.winsteps.com/facetman64/elements.htm> and
<https://www.winsteps.com/facetman64/table7.htm>.

## Examples

``` r
# Small synthetic binary-rating analysis exported by FACETS.
# Each row in result$table is one Person, Rater or Task element.
path <- system.file("extdata", "facets-example", package = "mfrmr")
result <- read_facets_results(path,
  facet_map = c("Person", "Rater", "Task"), source_version = "4.5.0")
summary(result) # Availability, not a model-adequacy assessment.
#>    Facet Rows Measures Infit Outfit AnchorFlagged Extreme UnknownStatus
#> 1 Person    6        6     3      3             1       3             0
#> 2  Rater    2        2     2      2             2       0             0
#> 3   Task    3        3     3      3             3       0             0
result$table[, c("Facet", "ElementID", "Label", "Estimate", "SourceStatus")]
#> # A tibble: 11 × 5
#>    Facet  ElementID Label Estimate SourceStatus
#>    <chr>  <chr>     <chr>    <dbl> <chr>       
#>  1 Person 1         1      -1.80   extreme_low 
#>  2 Person 2         2      -3.10   extreme_low 
#>  3 Person 3         3       5.49   extreme_high
#>  4 Person 4         4      -0.0623 estimated   
#>  5 Person 5         5      -1      anchored    
#>  6 Person 6         6       1.30   estimated   
#>  7 Rater  1         1      -0.4    anchored    
#>  8 Rater  2         2       0.4    anchored    
#>  9 Task   1         1      -0.8    anchored    
#> 10 Task   2         2       0      anchored    
#> 11 Task   3         3       0.8    anchored    
plot(result, type = "measure", facets = "Rater", draw = FALSE)
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("plot.mfrm_facets_results", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
path <- system.file("extdata", "facets-example", package = "mfrmr")
result <- read_facets_results(path,
  facet_map = c("Person", "Rater", "Task"), source_version = "4.5.0")
plot(result, type = "measure", facets = "Person")
p <- plot(result, type = "infit_outfit", facets = "Rater", draw = FALSE)
plot_data(p, "plot_data")[, c("Label", "X", "Y", "Available", "Reason")]
plot_data(p, "notes")
# Display names are joined by facet and exported ID, never by row order.
labels <- data.frame(Facet = "Person", ElementID = c("1", "2"),
  DisplayLabel = c("Participant A", "Participant B"))
labelled <- plot(result, facets = "Person", label_map = labels, draw = FALSE)
plot_data(labelled, "plot_data")[, c("ElementID", "Label", "DisplayLabel")]
# A separate synthetic PCM analysis, with four exported scale curves.
graph_path <- system.file("extdata", "facets-graph-example", "graph.txt",
  package = "mfrmr")
curves <- read_facets_results(graph_file = graph_path, source_version = "4.5.0")
summary(curves, component = "curves")
plot(curves, type = "ccc", scales = 1)
expected <- plot_data(curves, "plot_data", type = "expected", scales = 1)
head(expected[, c("Scale", "Measure", "Value", "Available")])
} # }
```
