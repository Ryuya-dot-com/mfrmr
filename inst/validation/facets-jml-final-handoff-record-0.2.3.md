# Final FACETS handoff for RSM/PCM JML in mfrmr 0.2.3

Status: the external FACETS numerical audit of the current RSM/PCM JML
estimation kernel is complete. FACETS is no longer a routine development or
test dependency. This decision does not claim full FACETS feature replacement.

## What is complete

The evidence now covers matched RSM and Criterion-step PCM models under:

- strict-convergence, fixed-information three-, four-, and five-facet designs;
- five additional opened seeds across those dimension-growth designs;
- 40,000-row designs;
- 10- and 30-facet designs;
- connected distributed sparsity and six-Person weak-bridge sparsity; and
- a disconnected structural negative control.

The fixed-information five-seed pilot had 29 comparison-eligible cases out of
30. The ineligible case was retained as a FACETS convergence failure rather
than converted into agreement. Across eligible cases, the largest common
element and step differences were `0.000633` and `0.000363` logits.

The stress envelope completed all 12 external launches. It separated FACETS
update-sensitive sparse convergence, mfrmr's replication-sensitive raw-gradient
review, JML Person boundaries, and weak-link relative-location sensitivity.
Consequently, external-program agreement was not allowed to override
structural rejection, optimizer state, or boundary policy.

## Final local sentinel

On 2026-08-15, the final handoff sentinel reran the frozen 640-row,
five-facet RSM and PCM controls with the current worktree at commit `f75fc0e`,
R 4.5.1, and local FACETS 4.5.0. Both processes returned zero, both programs
met their declared numerical gates, and the complete coordinate contracts
passed:

| Model | FACETS iteration | mfrmr gradient | Elements matched | Steps matched | Maximum element difference | Maximum step difference |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| RSM | 35 | 0.0000552321 | 53/53 | 3/3 | 0.0003622826 | 0.0002106360 |
| PCM | 51 | 0.0000313340 | 53/53 | 12/12 | 0.0001517469 | 0.0000082503 |

The complete scientific manifest fields and the global element and step
maxima were identical to the earlier frozen control result. Runtime timestamps,
file bytes, serialized objects, and SHA values were not compared and do not
enter scientific acceptance.

The ignored local evidence directory is
`validation-results/facets-final-handoff-sentinel-20260815-v1`. It retains the
RSM/PCM reports, score and anchor files, canonical comparison tables, the RDS
result, and a small scientific-field comparison table. These files are local
handoff evidence, not CRAN runtime inputs.

## Meaning of sufficient

The completed evidence is sufficient to stop routine FACETS reruns for the
current RSM/PCM JML estimator. It supports close numerical agreement of matched
element and step coordinates over the tested envelope and correct fail-closed
handling of the tested structural and boundary cases.

It does not establish:

- byte-level or hidden floating-point identity;
- equality of every FACETS fit statistic, bias table, or reporting feature;
- absence of finite-sample JML bias;
- GPCM or MML equivalence; or
- interchangeability of the two applications for every workflow.

Bias, coverage, recovery, readiness calibration, and user-facing diagnostic
quality are mfrmr responsibilities and should be evaluated with mathematical
invariants, truth-known simulation, and end-to-end workflow tests rather than
additional FACETS matching.

## When FACETS comparison should reopen

Reopen the small frozen sentinel, and only expand it if the sentinel changes,
when a change affects any of the following:

- the RSM/PCM JML likelihood, score, gradient, or retained-solution selection;
- parameter signs, constraints, centering, anchors, or coordinate transforms;
- category retention, step ownership, or step parameterization;
- extreme-score or boundary-coordinate estimation semantics;
- FACETS control generation or coordinate import/normalization; or
- a compatibility claim for a materially different FACETS version.

Changes confined to explanations, summary layout, plots, APA tables, reports,
or exports do not require FACETS when the fitted parameter object and its scale
contract are unchanged.

## Next priority

Development now moves to a coherent user-facing path from `fit_mfrm()` through
`summary()`, diagnostics, plots, APA/report output, and export. Boundary
Persons, weak links, exact nonidentification, and optimizer review must be
presented as distinct, actionable states. That work should use the retained
FACETS evidence as background calibration, not as a runtime dependency.
