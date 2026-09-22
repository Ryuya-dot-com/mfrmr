# Screened linking graph repair — 2026-09-10

The existing `plot(chain, type = "graph")` now answers which common elements
were retained in each recorded comparison while keeping every declared wave
visible. This is the first bounded implementation from the
[visualization plan](plot-expansion-plan-0.2.4.md).

## Behavior and interpretation

- Squares represent waves/forms; circles represent an element in one reviewed
  link. A label such as `Item: I1 [L2]` refers to link 2 in the returned links
  table. The same element is repeated across links to retain pair-specific
  screening. A common `AnchorId` records its facet/level identity.
- Solid lines mean retained with no residual flag; dot-dash means retained
  with a flag or unavailable flag; dashed means excluded; dotted means unknown
  retention. Four distinct line types remain in monochrome.
- All waves remain in zero-common-element and zero-link cases. RetainedDegree
  counts retained incidences; it is not precision, centrality or readiness.
- New chains store positional wave IDs and element LinkID. Labels can repeat
  or contain arrows, pipes and colons without being used as graph identities.
  Older native chains are matched against complete labels; ambiguous link
  references fail explicitly rather than guessing endpoints.
- The returned `data$data` includes nodes, edges, links, elements and counts.
  `n_anchors` counts unique facet/level identities; `n_element_nodes` counts the
  actual link-specific element nodes. Edges retain Retained, Flag, Status and
  Reason. Full labels remain available if a narrow figure uses IDs.
- `show_title = FALSE` and `show_notes = FALSE` omit the graph title/footer.
  Legends and data labels remain; interpretation and support notes stay in
  `data$notes` and `print()`. Layout warnings remain ordinary R warnings.
  The other two chain plot types also honor show_title; show_notes controls
  the graph footer, since those views have no interpretation footer.

This graph shows screened common-element comparisons, not supplied fixed
anchor constraints or all possible form comparisons. Even a retained element
can have no usable SE and receive no weight in a weighted offset. Screening
can also retain an element with a residual flag. The graph does not certify
invariance, identification, adequate support, common-scale comparability or
inference. Offset/SE calculations are unchanged by this repair.

## Checks and figures

The [replay script](equating-graph-0.2.4.R) creates 32 drawings: four cases
(mixed statuses with an isolated wave, no common elements, repeated/long names,
and a public-builder example), two presets, annotated/clean displays, and
PNG/PDF output. All use a 5 by 4 inch canvas. See the
[drawing results](equating-graph-0.2.4/drawings.csv) and
[execution log](equating-graph-0.2.4/drawings.log).

All 32 drawings completed without error. Eight long-label drawings issued the
expected warning that IDs replace labels too wide for the panel. The other
24 produced no warnings. Drawn and draw-free payloads were identical in every
case. Both a repeated-name public chain and the synthetic identity cases were
checked. The builder example reuses an archived review-only PCM fit solely to
exercise graph construction; it provides no new statistical evidence.

The mixed colour, clean monochrome, empty and duplicate-name PNGs were inspected
visually. PDF raster previews also check the clean monochrome figure and the
public-builder example. The figures retain all wave nodes, legible status
keys and the expected omission of titles/footers in clean mode.

- [Mixed statuses, colour](equating-graph-0.2.4/mixed-publication-annotated.pdf)
- [Mixed statuses, clean monochrome](equating-graph-0.2.4/mixed-monochrome-clean.pdf)
- [No shared elements](equating-graph-0.2.4/empty-publication-annotated.pdf)
- [Public-builder example](equating-graph-0.2.4/public_builder-publication-annotated.pdf)

The dedicated regression tests cover isolated and empty graphs, shared
identities with different screening across links, unknown and flagged states,
duplicate/punctuated names, legacy matching, invalid references, monochrome,
title/note controls and graphics-state restoration. A retained-edge graph check
verifies that excluding the B-C occurrence of a shared element disconnects A-C
while keeping the A-B occurrence. This is a topology check, not an estimate
influence calculation.

The final relevant checks passed **419 expectations in 70 blocks across four
files**, with zero failures, errors, warnings or skips; see the combined
[test results](equating-graph-0.2.4/tests.csv). The
[initial run](equating-graph-0.2.4/initial-tests.log) exposed two assertions in
one pre-existing APA composite test that assumed no width warning on the
default small device. Its device was changed to 12 by 9 inches, matching the
existing four-panel device-state test, while preserving the warning assertions.
The graph and plotting-extras files were then
[rerun successfully](equating-graph-0.2.4/final-tests.log); the unaffected
anchor-equating and device-state files retain their initial passing results.
`tools::checkRd()` and `git diff --check` also passed. A full package check was
not part of this bounded plot repair.

Source hashes and the runtime environment are recorded in
[source-md5.csv](equating-graph-0.2.4/source-md5.csv) and
[session-info.txt](equating-graph-0.2.4/session-info.txt). Replay from the package
root with `Rscript inst/validation/equating-graph-0.2.4.R <output-directory>`.
The tested files also have [separate hashes](equating-graph-0.2.4/test-source-md5.csv).
The pre-repair probe archive remains unchanged.

## Remaining scope

The renderer uses a fixed two-column layout and warns when labels need a
larger device. A compact administration-link view, dense-chain panels and
anchor-deletion summaries remain future work. Explicitly recomputed offset,
estimate and SE sensitivity remains a separate step; graph disconnection must
not be presented as its substitute. No dependency, estimator, simulation or
package release was added by this repair.
