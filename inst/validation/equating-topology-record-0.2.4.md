# Recorded wave links and common-element deletion — 2026-09-10

The question is which wave comparisons lose their recorded connection when
one common element is unavailable. The existing linking-chain plot method now
provides two additional views, using the repaired graph identity/screening
tables and the package's existing union-find helper. No dependency is added.

```r
plot(chain, type = "links")
p <- plot(chain, type = "anchor_removal", preset = "monochrome",
          show_title = FALSE, show_notes = FALSE)
p$data$data$removal
p$data$data$lost_pairs
p$data$notes
```

## What is computed

`type = "links"` displays recorded wave comparisons with counts of retained
common elements. A graph edge exists if at least one element has
`Retained = TRUE`; retained but flagged elements count. Unknown retention is
counted separately, not silently classified as retained or excluded. Dotted
comparisons have no recorded retained connection. Dot-dash connections retain
elements but have flagged/unknown residual checks or inadequate/unknown source
link support. All declared waves remain in the summary and figure.

`type = "anchor_removal"` independently removes each unique `(Facet, Level)`
identity from every recorded comparison. It holds other screening decisions
fixed. The figure counts **newly disconnected unordered wave pairs**, including
indirect paths, relative to the unchanged baseline graph. Pairs already
disconnected at baseline do not contribute. Three point shapes distinguish
new disconnection, no new disconnection, and no retained occurrence.

The `data$data` payload contains:

| Table | Meaning |
| --- | --- |
| `nodes`, `links`, `elements` | Stable wave/element identities, recorded comparisons, derived retention counts, and source screening information |
| `summary` | Wave/link/component counts, connected wave-pair count, and unknown-retention count at baseline |
| `removal` | Per-element retained/unknown occurrences, lost direct links, component count after deletion, and newly disconnected pair count |
| `lost_links` | Recorded comparisons losing their last retained element |
| `lost_pairs` | Previously connected wave pairs that become disconnected |
| `components_after` | Membership before/after each deletion for every wave, including isolated waves |

Join `AnchorId` to the removal table for facet/level names. Wave IDs distinguish
duplicate labels. Component numbers identify groups within a partition; their
numeric values must not be compared across Before, After or removal scenarios.
Full names remain in the tables when figures abbreviate labels or substitute
IDs. Ordinary layout warnings and returned interpretation notes are separate.

## Example and limits

In the synthetic illustration, A-B has retained I1 and I2, B-C has retained I1,
and D is already isolated. Removing I1 loses the direct B-C connection and
newly disconnects A-C and B-C: **two pairs**. A-B remains connected via I2.
Removing I2 causes no new disconnection. I3 is excluded and I4 has unknown
retention; neither contributes a recorded retained edge. D is never counted
as a new loss. See the [removal table](equating-topology-0.2.4/mixed-anchor_removal-removal.csv)
and [lost pairs](equating-topology-0.2.4/mixed-anchor_removal-lost_pairs.csv).

- [Recorded links, colour](equating-topology-0.2.4/mixed-links-publication-annotated.pdf)
- [Removal results, clean monochrome](equating-topology-0.2.4/mixed-anchor_removal-monochrome-clean.pdf)

The regression checks also include an alternative A-C path: deleting an A-B
edge then loses a direct comparison but causes no new pair disconnection.
A chain supported only by one shared element loses all three A/B/C pairs when
that element is removed. These cases distinguish edge loss from loss of any
path between waves.

These are graph examples, not simulated response data or empirical estimates.
Zero new disconnections does not imply negligible statistical influence,
anchor invariance, adequate support or common-scale comparability. No new links
are searched for. Screening is not rerun; offsets, estimates, SEs, confidence
intervals and source-fit readiness are not recalculated. The existing caveat
that retained elements may receive zero offset weight remains relevant.

## Verification

The [replay script](equating-topology-0.2.4.R) creates **64 drawings**: four cases
(mixed retention with an isolated wave, no links/elements, long/duplicate names,
and a public-builder example), two new views, colour/monochrome, annotated/clean
variants, and PNG/PDF devices at 5 by 4 inches. All completed without errors or
warnings, with identical drawn and draw-free payloads. See
[drawings.csv](equating-topology-0.2.4/drawings.csv) and
[drawings.log](equating-topology-0.2.4/drawings.log). The public-builder example
reuses an archived review-only PCM fit to exercise the plotting route only.

The mixed link figure, annotated/clean monochrome removal figures and long-name
figures were visually inspected. PDF raster previews of the link and clean
removal examples confirm visible legends, integer count ticks and omitted
title/footer in clean mode. An initial removal layout placed the legend too
low; physical margin spacing was corrected before archiving these figures.

Final relevant checks passed **351 expectations in 45 blocks across three
files**, with zero failures, errors, warnings or skips:
[combined results](equating-topology-0.2.4/tests.csv). The
[initial passing run](equating-topology-0.2.4/initial-tests.log) covered graph,
plot-device-state and plotting-extras tests; the
[final targeted run](equating-topology-0.2.4/final-tests.log) repeated the graph
file after label refinements and added the narrow-device ID fallback check.
The combined table keeps the final graph results and the unaffected earlier
device/extras results. `tools::checkRd()` and `git diff --check` also passed.
A full package check was not part of this bounded addition.

Replay from the package root with
`Rscript inst/validation/equating-topology-0.2.4.R <output-directory>`.
[Source hashes](equating-topology-0.2.4/source-md5.csv) and
[session information](equating-topology-0.2.4/session-info.txt) record the drawing
environment. [Test hashes](equating-topology-0.2.4/test-source-md5.csv) cover the
three checked files. Earlier graph-repair archives remain unchanged.

## Next work

The next statistical step must explicitly recalculate a specified linking
procedure after removal, including any rescreening and failure handling.
Uncertainty needs its own justified calculation. It must not be inferred from
component counts or common-element counts. Large graphs still need suitable
canvas sizes, and the explicit lost-pair table can become large; lazy pair
export or panelled views can be added when such workloads require them.
