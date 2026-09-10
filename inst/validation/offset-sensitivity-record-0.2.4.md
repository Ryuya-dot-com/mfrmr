# Conditional linking-offset sensitivity — 2026-09-10

The question is how the recorded linking offsets change when one common
element is unavailable. `plot(chain, type = "offset_sensitivity")` now removes
each `(Facet, Level)` identity from every adjacent link and reruns the existing
preliminary offset, screening, final offset and cumulative-offset calculation.
Source fitted estimates and their SEs remain fixed. The implementation reuses
`compute_equating_offset()` and the existing support/identity helpers, with no
new dependency.

```r
p <- plot(chain, type = "offset_sensitivity", preset = "monochrome",
          show_title = FALSE, show_notes = FALSE)
p$data$data$removal
p$data$data$links
p$data$data$retention_changes
p$data$notes
```

## What is computed

Each deletion starts independently from the unchanged source chain. This
differs from `type = "anchor_removal"`, which holds screening decisions fixed
and counts graph disconnections. Here, removing an element can change the
preliminary offset and cause other elements to enter or leave the retained
set. The existing fallback to all finite differences when screening would
exclude every element is preserved and reported as `ScreeningFallback`.

The method requires an ordered adjacent chain, recorded screening settings,
and numeric source estimates/SE columns. Recomputed baseline link offsets must
agree with recorded offsets within `1e-8 * max(1, abs(recorded_offset))`.
Missing settings, incompatible link order or stale offsets give an actionable
error. Non-finite preliminary offsets now return an unavailable calculation
from the shared helper rather than failing during the subsequent screening
condition. This guard does not replace a general numerical-stability audit.

The `data$data` payload contains:

| Table | Meaning |
| --- | --- |
| `settings` | Recorded method, screening threshold, support guideline, baseline tolerance and fixed-source scope |
| `removal` | Per-element maximum absolute link/cumulative changes, retention changes, fallback counts, unavailable links and comparison completeness |
| `baseline_links`, `baseline_cumulative` | Recomputed reference offsets and link availability/support |
| `baseline_elements` | Source estimates/SEs, element identities and recalculated retention, contribution and residual flags |
| `links`, `cumulative` | Each deletion's offsets, baseline offsets and signed `Change = after - before` |
| `retention_changes` | Remaining elements whose retention, actual contribution or residual flag changes; the deleted element itself is omitted |
| `common_by_facet` | Per-link support after deletion, retaining a zero-count row when a facet loses its final element |

`RemovedAnchorId` joins scenario tables to `removal$AnchorId`. Retention and
contribution are distinct: under inverse-variance weighting, retained elements
with unusable SEs do not contribute to the offset. `RetentionChanges` counts
changes in the retention decision only; the detailed table also includes
contribution/flag changes. The support guideline counts retained elements and
does not prevent offset calculation when support is inadequate.

Unavailable link offsets propagate to later cumulative offsets. Maxima use
finite before/after comparisons only, and the first wave's fixed zero is
excluded from cumulative maxima. A missing maximum is `NA`, never zero.
Three point shapes distinguish complete comparisons, partial comparisons and
no finite cumulative comparison in both colour and monochrome. An entirely
unavailable figure has no numeric horizontal axis. Full notes and names remain
in the returned object when titles/notes are hidden or labels are shortened.

## Hand-checkable examples

With unweighted source differences `0, 0.4, 0.8, 2` and threshold `0.5`, the
baseline preliminary offset is `0.8`; I2 and I3 are retained, giving final
offset **0.6**. Deleting the originally excluded I4 changes the preliminary
offset to `0.4`, re-admits I1 and gives final offset **0.4**, a signed change of
**-0.2 logits**. Thus, deletion of a previously excluded element can still
matter when screening is rerun. See the
[link calculations](offset-sensitivity-0.2.4/rescreen-links.csv),
[changed decisions](offset-sensitivity-0.2.4/rescreen-retention_changes.csv) and
[colour figure](offset-sensitivity-0.2.4/rescreen-publication-annotated.pdf).

Adding B-C supported only by I1 with offset `0.25` gives baseline cumulative
offsets `0, 0.6, 0.85`. Deleting I1 from both links gives `0, 0.8, NA`: A-B is
recomputed, while B-C has no remaining common element. The reported maximum
finite cumulative change is `0.2`, explicitly marked as a **partial**
comparison. It does not quantify the unavailable change at C. See the
[cumulative table](offset-sensitivity-0.2.4/partial-cumulative.csv) and
[clean monochrome figure](offset-sensitivity-0.2.4/partial-monochrome-clean.pdf).

Weighted checks use differences `0, 1, 2` with paired source SEs `1, 2, NA`.
All three elements are retained with screening disabled, but only the first
two contribute: the baseline offset is `0.2`. Their independent deletion
offsets are `1, 0, 0.2`. Tests also cover switching to unweighted calculation,
screening fallback, no finite differences, numerical failure, a sole common
element and no candidates. Sole-element deletion produces unavailable changes
rather than a false zero-effect result.

These examples are deterministic input calculations, not simulated response
studies or empirical evidence of invariance. Removing a common element from
this alignment calculation does not alter fixed-anchor constraints in a
source model. No item, rater or person model is refitted; no new SE, covariance
or confidence interval is estimated. Small changes and retained connections
do not establish comparable scales or inferential readiness.

## Verification

The [replay script](offset-sensitivity-0.2.4.R) creates **48 drawings**: six
cases (rescreening, partial availability, unavailable, weighted, empty and
public builder), two presets, annotated/clean variants and PNG/PDF at 5 by 4
inches. All completed without errors or warnings, with identical drawn and
draw-free payloads. See [drawings.csv](offset-sensitivity-0.2.4/drawings.csv) and
[drawings.log](offset-sensitivity-0.2.4/drawings.log). The public-builder case
uses the same archived review-only PCM interaction fit for both waves to
exercise integration and rendering; its zero changes provide no evidence
about empirical linking stability.

Representative PNGs from all six cases were visually inspected. PDF raster
previews of partial/clean monochrome and unavailable/annotated monochrome
figures confirm visible labels, symbols and legends, correct omission of
title/footer, and no numeric axis for the fully unavailable case.

Relevant checks passed **389 expectations in 75 blocks across four files**,
with zero failures, errors, warnings or skips:
[combined results](offset-sensitivity-0.2.4/tests.csv). The
[initial run](offset-sensitivity-0.2.4/initial-tests.log) covered anchor-equating,
equating-graph, offset-sensitivity and plotting-extras. The
[final targeted run](offset-sensitivity-0.2.4/final-tests.log) repeated all 63
offset-sensitivity expectations after the final display/payload refinements.
The combined table replaces the earlier offset-sensitivity rows with that
final run and retains the unaffected results from the other three files.
`tools::checkRd()` and `git diff --check` also passed. A full package check was
not part of this bounded addition.

Replay from the package root with
`Rscript inst/validation/offset-sensitivity-0.2.4.R <output-directory>`.
[Source hashes](offset-sensitivity-0.2.4/source-md5.csv),
[test hashes](offset-sensitivity-0.2.4/test-source-md5.csv) and
[session information](offset-sensitivity-0.2.4/session-info.txt) record the
checked environment. Earlier graph/topology archives remain unchanged.

## Remaining scope

Full refitting and uncertainty require a specified intervention: dropping
observations, releasing fixed-anchor constraints and excluding elements from
an alignment step answer different questions. They need separate calculation
and validation. The current independent deletion loop also stores all scenario
tables; batch optimization or selective export can be added if large chains
make this costly. This work does not resolve the separate TAM equivalence or
release-readiness gates.
