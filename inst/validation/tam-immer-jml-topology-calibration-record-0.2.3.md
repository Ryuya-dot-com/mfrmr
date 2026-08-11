# Matched-topology TAM/immer/mfrmr JML smoke record for mfrmr 0.2.3

Status: Draft.79 repository-only topology-feasibility record, 2026-08-09.
The declared 180-dataset replicated pilot remains unexecuted and is not yet
authorized as a performance study.

## Execution and exact accounting

The 18-profile x RSM/PCM smoke was executed from the current development tree.
The run intentionally stopped after publishing its first atomic dataset
checkpoint, then resumed the remaining 35 cells. All expected states matched:

| State | Datasets | Retained method rows |
| --- | ---: | ---: |
| Observed graph connected; nine modes attempted | 30 | 270 |
| Observed graph disconnected; stopped before optimization | 6 | 0 |

The six structural negatives are RSM/PCM versions of globally disconnected
`DISCONNECTED_B24`, assigned-connected/observed-disconnected
`PATH_B12_DROP1`, and assigned-connected/observed-disconnected
`HUB_B12_DROP1`. The result retains 4,710 metric rows, all with
`EvidenceReady = FALSE`; `ContractPassed` is `TRUE`.

A second R process validated and resumed all 36 checkpoints, refit zero cells,
and reproduced the exact aggregate and completion-marker identities:

| Identity | SHA-256 |
| --- | --- |
| Execution | `844268cae8961607c7d55c821d1fd84446c1db3d4af308f53c320b8789d6cb08` |
| Aggregate result | `d95a85f450a4278fc1b953d1458cf7ccf7dd9f3076012ffe895245dd2a0195c4` |
| Checkpoint ledger | `a51a7ac86bb7d350d59c956abef820c3d826146c5dd3c3193bb103bd2eec8a58` |
| Completion-marker file | `d7bbec847bb3d6fc4104bde276e06b2c1e1a6a91665dd0981937bcb539309453` |
| Aggregate RDS file | `1055b5504c4e60ce60ee1bf6b17bc916b3fcab5de543fa5f6c5227ce9cf8b3d2` |

The ignored 26 MB local bundle is
`validation-results/draft79-tam-immer-jml-topology-smoke-20260809/`.
Manifest, dataset, graph, dropped-link, mode, and metric CSV hashes are retained
beside the aggregate. The runtime was R 4.6.1 on
`aarch64-apple-darwin23`, with mfrmr 0.2.3, TAM 4.3.25, and immer 1.5.13.
Their primary-function hashes equal the Draft.78 recorded identities.

## Matched topology result

The table below uses the RSM assignment audit; PCM is identical because
topology is generated independently of scores.

| Bridges | Topology | Edges | Edge-weight min--max | Weighted algebraic connectivity | Articulation Raters | Cut edges | One-link-Person failure edges |
| ---: | --- | ---: | --- | ---: | ---: | ---: | ---: |
| 8 | path | 7 | 1--2 | 0.1549 | 6 | 7 | 6 |
| 8 | cycle/distributed | 8 | 1--1 | 0.5858 | 0 | 0 | 0 |
| 8 | hub | 7 | 1--2 | 1.0000 | 1 | 7 | 6 |
| 12 | path | 7 | 1--2 | 0.2561 | 6 | 7 | 2 |
| 12 | cycle | 8 | 1--2 | 0.7511 | 0 | 0 | 0 |
| 12 | distributed | 12 | 1--1 | 0.9016 | 0 | 0 | 0 |
| 12 | hub | 7 | 1--2 | 1.0000 | 1 | 7 | 2 |
| 24 | path | 7 | 3--4 | 0.5016 | 6 | 7 | 0 |
| 24 | cycle | 8 | 3--3 | 1.7574 | 0 | 0 | 0 |
| 24 | distributed | 24 | 1--1 | 3.8299 | 0 | 0 | 0 |
| 24 | hub | 7 | 3--4 | 3.0000 | 1 | 7 | 0 |

Within each bridge-count stratum, mean Person-Rater degree and assignment
density are identical. At 12 bridges, for example, every matched cell has mean
degree 1.10 and density 0.1375.

The hub result is the clearest reason not to use one scalar graph cutoff. Its
weighted algebraic connectivity is 1.0, exceeding the cycle's 0.7511 and
path's 0.2561, but it still has one articulation Rater and seven cut edges.
Removing that hub Rater destroys every link. At 24 bridges, neither path nor
hub is disconnected by losing one shared Person because every edge has at
least three shared Persons, yet both remain vulnerable to whole-edge loss and
the hub remains vulnerable to one Rater loss.

The 24-bridge negative control has four edges of weight six inside one
four-Rater cluster but five total components because the other four Raters are
isolated. Bridge count and within-cluster redundancy do not establish global
scale linkage.

## Adversarial one-link loss

The assigned 12-bridge path, cycle, distributed, and hub graphs were all
connected. One outcome-independent adversarial bridge-Person link was then
removed:

| Topology | Observed components | Observed algebraic connectivity | Articulation Raters | Cut edges |
| --- | ---: | ---: | ---: | ---: |
| path | 2 | 0 | not applicable while disconnected | not applicable |
| cycle | 1 | 0.2142 | 6 | 7 |
| distributed | 1 | 0.3611 | 2 | 2 |
| hub | 2 | 0 | not applicable while disconnected | not applicable |

The cycle survives but becomes a path. The distributed graph also survives,
but acquires two articulation Raters and two cut edges. Thus
`still connected after loss` does not mean `still robust after loss`.
Assigned and observed topology states must both remain in the later pilot.

## Estimator availability exposed a new pilot blocker

Natural all-minimum/all-maximum Persons occurred in all 30 connected datasets,
including both degree-two reference cells. This makes the original raw JML
estimand ineligible in every smoke cell:

| Mode | Returned / 30 | Engine-labelled numerical convergence | Evidence-eligible |
| --- | ---: | ---: | ---: |
| mfrmr raw finite trace | 30 | 30 | 0 |
| mfrmr extended profile | 30 | 30 | 30 |
| TAM raw | 0 | 0 | 0 |
| TAM adjusted | 30 | 10 | 30 |
| TAM classical correction | 0 | 0 | 0 |
| TAM adjusted + classical | 30 | 10 | 30 |
| immer `jml` | 30 | 30 | 0 |
| immer `eps_adj` | 30 | 30 | 30 |
| immer `jml_bc` | 30 | 30 | 30 |

The mfrmr raw rows are finite optimizer traces, not attained original-JML
maxima when extreme Persons are present. The TAM counts use an 800-iteration
smoke ceiling and remain an iteration-before-ceiling proxy; 20/30 adjusted
fits reached the ceiling. Increasing the declared pilot ceiling to 1,200 does
not by itself close convergence identity.

TAM's potential-pseudoitem postscale is 0.96875 throughout. immer's
observed-exposure postscale ranges 0.765625--0.875. These are different method
identities under sparse exposure; no correction is selected. Common-surface
coverage and definition-matched reported facet separation again have zero
eligible rows.

## Metacognitive consequence for the unexecuted pilot

Draft.79 successfully validates topology construction, structural failure,
adversarial link loss, graph vulnerability, atomic checkpoints, and exact
resume. It does not make the currently declared 180-dataset manifest suitable
for a full estimator-performance comparison.

Running that manifest unchanged would knowingly produce an almost entirely
extreme-Person, raw-JML-ineligible low-exposure panel and a weak TAM convergence
proxy. The next revision must therefore split:

1. an operational sparse-topology lane, where natural extremes are part of the
   data problem and profile/adjusted identities are primary;
2. a raw-JML-eligible high-information lane with enough observations per Person
   to make no-extreme datasets realistically observable, without conditioning
   away extreme responses post hoc; and
3. an engine-convergence lane that extracts stronger native stopping/score
   evidence or prespecifies a justified ceiling calibration.

Only after those lanes and their Monte Carlo precision are frozen should the
five-replicate topology pilot run. Draft.79 freezes no bridge minimum, graph
cutoff, topology preference, correction, sample size, convergence rule,
coverage rule, method ranking, checklist pass, candidate, or confirmation
decision. GPCM transfer remains later and remains separate for Criterion-owned
and Rater-owned model identities.
