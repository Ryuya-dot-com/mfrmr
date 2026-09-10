# Native plot label placement — 2026-09-10

This follow-up addresses the dense PCM labels left open by the
[initial plot UX review](plot-ux-record-0.2.4.md). It is a rendering repair;
no recovery simulation or new numerical-equivalence study was run.

## Problem and resulting behavior

Wright label placement previously considered each column separately, although
long threshold labels extended into neighboring columns. Expected-score
pathways placed labels for nearby thresholds at essentially the same height.
The earlier [Wright](plot-ux-0.2.4/PCM-7x5-01.png) and
[pathway](plot-ux-0.2.4/PCM-7x5-02.png) images retain these failures.

Both native renderers now share a small placement helper that measures text on
the current device, checks nearby labels and fitted points, and chooses a
nearby vertical position with less overlap. Text stays within the plotting
region where space permits; leader lines connect it to the original point.
Numerical roundoff in touching text boxes is treated as zero overlap so it
cannot force a label unnecessarily far from its point.

Every retained native Wright label remains present, including all threshold
values. Pathway thresholds outside the visible theta/score window remain
outside that window; their data are retained rather than moving their labels
onto the visible boundary. Estimated locations, curves, and initial annotation
coordinates are unchanged. Public help distinguishes initial annotation
coordinates from the device-specific text placement.

## Review examples

| Figure | 7 × 5 inches | 5 × 4 inches |
| --- | --- | --- |
| PCM Wright | [Image](plot-label-ux-0.2.4/PCM-7x5-01.png) | [Image](plot-label-ux-0.2.4/PCM-5x4-01.png) |
| PCM pathway | [Image](plot-label-ux-0.2.4/PCM-7x5-02.png) | [Image](plot-label-ux-0.2.4/PCM-5x4-02.png) |

These images were visually inspected. The RSM bundle, CCC panels, caller grid,
APA composite, and subgroup Wright map are also retained in the same output
directory as workflow checks.

## Validation and limits

The [focused results](plot-label-ux-0.2.4/tests.csv) report 89 test blocks and
484 successful expectations across seven files, with no failures, errors,
unexpected warnings, or skips. The new check observes the placement used by
the actual public plotting calls on PDF devices at both sizes. It checks
RSM/PCM label retention, text-box separation, visible point preservation,
plot bounds, bounded displacement, restricted theta windows, and equality of
drawn and draw-free payloads. The saved pre-change PCM Wright/pathway payloads
also match the revised source exactly.

This helper uses greedy vertical placement. A canvas containing too many or
very long labels can still require more space; it does not guarantee a perfect
layout for arbitrary data. Curve/CI strokes and leader-line crossings are not
included in its collision checks. This change applies to native base graphics;
ggplot conversion retains its existing initial annotation coordinates.
Interactive resizing on other device backends remains outside this check.

Reproduce the images from the package root with:

```r
# Shell: Rscript inst/validation/plot-ux-0.2.4.R /tmp/mfrmr-label-review
pkgload::load_all(".", quiet = TRUE)
testthat::test_file("tests/testthat/test-plot-device-state.R")
```

The [source hashes](plot-label-ux-0.2.4/source-md5.csv) and
[session information](plot-label-ux-0.2.4/session-info.txt) identify this visual
review source. Earlier plot and simulation evidence is retained unchanged;
its source hashes do not identify this revision. This focused pass does not
constitute a complete package or release check.
