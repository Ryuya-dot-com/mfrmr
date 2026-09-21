# Measurement-model extension roadmap after 0.2.4

Status: internal architecture and research roadmap; not public support, release
authorization, or an API promise

Review date: 2026-09-01

Evidence base: page-by-page review of 57 related Zotero PDFs (1,366 PDF pages),
plus a source audit of the current development tree

Scope: GPCM identity, GRM, LLTM/LPCM parameter design, crossed and bundled
rater structures, multidimensional latent traits, multivariate outcomes and
method factors, response-time and response-event models, response-style/process
mixtures, predictive evaluation, dependence-aware inference, treatment-effect
heterogeneity, and simulation-evidence governance

Related internal records:

- `generalized-mfrm-model-ladder-0.2.3.md`
- `gpcm-literature-to-contract-0.2.3.md`
- `gpcm-model-identity-contract-0.2.3.csv`
- `mfrmr-internal-strategic-roadmap.html`

## 2026-09-01 controlling execution overlay

This overlay controls current sequencing. It supersedes stale task ordering
later in this historical record without rewriting the literature findings or
completed evidence trail.

### Current state and claim ceiling

- D-SIM-5 has 15,000/15,000 immutable outer checkpoints (100.00%).
- `D5-SHARD-001` through `D5-SHARD-050` are complete. Identity-only closure
  passes with 15,000 unique terminal identities and zero missing, duplicate,
  or foreign identities.
- The blind complete-denominator assembler/adjudicator passes its synthetic
  sentinel qualification. One frozen read-only adjudication then returns
  `fail` separately for ABS-PHI and REL-G. D4-S001 passes all coverage cells
  but fails REL-G standardized bias; D4-S006 fails both estimands' bias and
  coverage. D-SIM-5 is a valid negative confirmation, not public support.
- D-SIM-6 retains package-level maturity at `specified`. The narrow internal
  route is executable, but the declared multivariate capability is neither
  simulation- nor independent-reference-validated and has no public surface.
- A capacity-only dual-preflight qualification supports at most two concurrent
  processes on the current host, restricted to distinct shard IDs launched in
  order; same-shard duplication and four-way execution remain prohibited.
- The D34-boundary operational audit validates all 10,200 stored outer
  checkpoints and all generation/backend-call records. Primary fits returned
  in 22,100/22,100 cases; 14 retained `D4-S005` outer attempts lack 15 derived
  coefficient rows because of `primary_target_nonfinite`. Inner fits, bootstrap
  metrics, and intervals are complete. This is a data-integrity finding, not a
  scientific decision, and the frozen no-replacement denominator remains
  unchanged.
- The first and last scenario blocks exercise the interval path; the four
  middle blocks exercise the point-only path.
- Atomic checkpointing, receipt generation, source-bound jobs, and exact
  resume have worked in planned execution.
- No partial result guided execution. Scientific values were opened only after
  full-denominator closure and blind qualification, and were adjudicated once
  without changing the frozen rules. The result does not establish simulation
  validation, reference validation, model adequacy, or public support.

### Three independent work lanes

| Lane | Current priority | Exit condition | Must not inherit |
| --- | --- | --- | --- |
| 0.2.4 public release | Preserve the bounded RSM/PCM portable-calibration release path and ordinary fitted-model contracts | Public documentation, examples, package checks, and release handoff are complete | D-SIM-5 completion, multivariate-G support, GRM, LLTM/LPCM, or response-time modeling |
| D-SIM-5 repository research | Complete the exact admitted 50-shard denominator with the frozen executor | 15,000 one-to-one terminal checkpoints, 50 validated receipts, and a complete-denominator integrity pass | Release timing, interim outcome review, result-based cancellation, or automatic public promotion |
| Post-0.2.4 extension discovery | Keep GPCM portability, GRM, LLTM/LPCM, joint response time, MIRT, and generic registries parked | One realistic problem packet passes the existing portfolio gate | Proximity to existing code, an available solver, or D-SIM-5 success |

D-SIM-5 is therefore neither a 0.2.4 release gate nor an extension-admission
shortcut. Release work may finish while the research denominator runs, and a
completed research denominator may still end in `fail`, `indeterminate`, or a
narrow internal-only finding.

### D-SIM-5 critical path

1. **Acquisition complete.** All 50 shards and 15,000 outer checkpoints were
   completed without changing the frozen executor, launch input, seed bands,
   attempt identities, or denominator.
2. **Blind completion path qualified.** Before result access, implement only
   the smallest missing complete-denominator assembler and adjudicator needed
   by the frozen D-SIM-4 rules. Test them with synthetic sentinels and schema
   failures; they must refuse partial, duplicate, altered, or foreign receipts.
3. **Execution identity closed.** All job, checkpoint, and receipt assertions
   pass; all 15,000 terminal identities and 995,000 registered inner attempts
   are accounted for. The metadata-only closure hash is
   `ac47234f184edbcb3860f0e7e00de8888efe802b98d739af8a0b4f5f3ef9d4a6`.
4. **Adjudicated once.** Run the already frozen ABS-PHI and REL-G summaries,
   Monte Carlo uncertainty calculations, interval/failure accounting, and
   acceptance rules over the complete denominator. The result is `fail` for
   both estimands; no attempt was added, replaced, or replenished and no
   threshold or scenario changed.
5. **Disposed without automatic promotion.** Record `pass`, `fail`, or
   `indeterminate` separately for each estimand and support profile. Even a
   pass authorizes only a later API/documentation/support review; it does not
   make multivariate G theory, GPCM, or another response family public. The
   observed fail leaves all such promotion closed.
6. **Maturity assigned.** D-SIM-6 retains `specified`, preserves the negative
   result, and routes any follow-up to a new axis-separating exploratory design
   rather than a D4-S006 patch or same-seed confirmation replay.

The blind assembler/adjudicator may be developed while computation continues
only if it cannot enumerate or open the active result directory during tests.
The running executor and runner are source-bound and remain frozen until all
50 receipts exist.

### Operational lessons retained

- Use one D-SIM-5 process by default while other long-running R workloads share
  the host. Parallelism is a resource choice, never a denominator change.
- An external interrupt is cooperative rather than an exact boundary command.
  A checkpoint already in flight may commit; retain it and resume at the next
  identity. Do not delete a valid planned checkpoint to restore a cosmetic
  boundary.
- Do not add a stop controller during this run because it would change the
  bound source. Reconsider a cooperative `stop_after` option only after
  D-SIM-5, and only if another retained study needs it.
- Keep one cumulative execution record. Do not create a per-shard roadmap,
  decision record, or wrapper.
- Quiet test wrappers may suppress successful logs, but callers must use a
  failure-propagating test command such as `test_dir(..., stop_on_failure =
  TRUE)`.

### Documentation boundary

`NEWS.md` contains completed user-visible package changes only. Seed bands,
shards, hashes, admission gates, adjudication state, owner decisions, internal
queues, and validation percentages belong in repository-only validation
records and this roadmap. The public `ROADMAP.md` states user-facing direction
and exclusions without internal execution history. Neither document is a
mirror of the validation ledger.

## Decision

The 57 papers do **not** justify broadening the `0.2.4` public promise. The
release boundary remains RSM/PCM MML fixed-standard-normal portable
calibration. The callable GPCM route remains the one-dimensional, aligned
single-owner, relative-slope implementation already described in the existing
GPCM records; it is not silently promoted to portable calibration, a general
many-facet GPCM, or MIRT.

Before adding GRM, LLTM/LPCM, a joint response-time likelihood, or true MIRT,
probability/parameter identity, requested analysis, and validation-study
evidence must be **semantically separated**. Separation is not a claim that
their cross-product is composable: every unqualified combination remains
unsupported by default. The current family label is carrying too many
downstream decisions, while the present resampling and simulation APIs cannot
yet express all crossed prediction targets, failed-run denominators, or frozen
performance rules.

The next implementation is **not** a registry. The A1 admission audit below
found no current invariant that is unprotected by the existing preparation and
runtime-config path, no two admitted downstream consumers, and no identified
set of semantic branches that a three-spec seam would delete. Building it now
would create a second authority in anticipation of optional models. A1 is
therefore parked; only its invariant vocabulary is retained.

The 2026-08-27 Gate 0 portfolio review also admits **none** of portable GPCM
calibration, LLTM/LPCM, GRM, or a joint response-time likelihood. The repository
contains interest and technical preparation, but no named user decision plus
typical data for any candidate. Each has a lower-cost current or external route.
All four therefore remain parked; this is a positive no-build decision, not an
invitation to choose the easiest implementation.

On 2026-08-28, a bounded Gate 0.5 simulation used external `mirt` fits to ask
whether GRM/GPCM geometry is detectably different for new-Person prediction
without implementing GRM in mfrmr. The matched family won in all four frozen
simulation strata, but only by 0.00108--0.00258 nats per response. This reopens
**problem discovery only** for B2. It supplies neither a practical threshold,
named decision, typical operational data, nor a reason to build rather than
integrate, so B2 remains parked and the public boundary is unchanged.

The same-day pre-fit audit then accounted for all ten packaged data objects:
all are synthetic, one has no Score, and all repeat Raters within at least some
Person-by-Criterion cells. Zero were eligible for a real-workflow sensitivity
analysis and zero model fits were run. B2 problem discovery is therefore now
an external intake task, not another simulation or implementation task.

The controlling order is:

1. preserve the current 0.2.4 release boundary and source truth;
2. validate a named user decision, typical data shape, current workaround, and
   simpler alternative before admitting extension work;
3. run a portfolio selection gate and admit at most one domain problem, which
   may end as documentation, integration, refusal, or no-build;
4. reopen A1 only if a current-core invariant or at least two admitted
   consumers need the same seam and a branch-deletion inventory is concrete;
5. if A1 is accepted, close A2 parity; independently, open the minimum A3
   ledger only when a named confirmatory study needs it; and
6. promote a domain implementation only after a real-world decision pilot, lifecycle/support review,
   and an independently challenged evidence decision.

B1--F2 below are conditional options in a dependency graph. They are not a
feature queue, version promise, or instruction to fill every empty WIP slot.

## Portfolio thesis and exclusion rule

The programme optimizes neither implemented model count nor test, record, fit,
page, or checklist volume. It protects the package's core mission: portable
many-facet calibration and scoring with stable scale meaning, visible failure,
and a support boundary users cannot easily misread. A technically correct
feature that does not improve that mission is not automatically package work.

Every candidate must answer all of the following before code is admitted:

1. **Named decision:** which user, workflow, and decision changes?
2. **Core adjacency:** does it improve scale continuity, many-facet
   measurement, scoring portability, or protection from a plausible wrong
   result?
3. **No-build counterfactual:** what happens if mfrmr does nothing?
4. **Simpler alternative:** can documentation, an explicit refusal, current
   RSM/PCM/bounded GPCM, export/interoperability, or a mature external package
   answer the same decision with lower lifecycle cost?
5. **Typical-data identification:** do realistic item, category, owner,
   incidence, missingness, and event counts identify the proposed structure,
   not only a favorable synthetic fixture?
6. **Single major identity axis:** can the first probe change only one of
   family, item-parameter design, latent dimension, random block, local
   dependence, process graph, or estimating objective?
7. **Lifecycle budget:** who will maintain validation, documentation,
   migration, artifacts, performance, support, deprecation, and independent
   review?
8. **Falsifiable exit:** which result causes `advance`, `narrow`, `integrate
   externally`, `docs/refusal only`, `park`, or `kill`?

`integrate externally`, `docs/refusal only`, `scope reduced`, and `no build`
are successful portfolio decisions when they answer the user need more safely.
Past investment, a complete prototype, or an available solver is never an
entry argument.

The long-horizon rules are:

- **No implicit closure.** A new response family inherits no estimator,
  prediction, facet, calibration-artifact, or scoring support automatically.
- **Generalize after reuse.** A platform abstraction enters the core only for a
  current fail-closed invariant or after two materially different admitted
  consumers need the same seam.
- **Reversible research.** A probe creates no public constructor or artifact
  migration obligation; negative and indeterminate outcomes are terminal
  evidence, not failed productivity.
- **Build versus integrate.** General-purpose MIRT, multivariate mixed models,
  multiway inference, process graphs, mixtures, and causal models default to
  interoperability or external analysis unless package-native value is shown.
- **Support profiles, not feature labels.** Any later promotion names the exact
  family, estimator, design, prediction target, artifact behavior, and data
  envelope qualified together.

## Canonical execution control surfaces

This narrative records durable reasoning. Model-extension progress is tracked
only in two compact machine-readable ledgers:

- `measurement-model-extension-execution-gates-0.2.4.csv` records stage state,
  dependencies, user decision, simpler alternative, entry/exit/stop conditions,
  claim ceiling, resource envelope, reversibility, and pass/fail disposition;
- `measurement-model-extension-traceability-0.2.4.csv` maps literature or
  source evidence to a requirement, spec owner, stage, independent oracle,
  negative control, test target, user decision, support disposition, and
  cheaper alternative.

The PDF audit CSV remains provenance, not a progress score. At this review's
start the repository already contained 778 tracked files under
`inst/validation/`, including 332 names containing `record`, 148 containing
`contract`, and 82 containing `pilot` or `prototype`. These counts are not
quality measures; they are a fragmentation warning. The two ledgers above are
intended to consolidate current state, not begin another authorization
hierarchy.

For this programme, a new micro-roadmap, authorization record, or runner layer
is refused unless a concrete failure cannot be represented by the existing
ledger and bounded evidence bundle. Historical outputs may remain append-only,
but one current row owns the decision state and names what it supersedes.

## Page-by-page PDF audit

### Method

The Zotero local library was queried by recent addition date and then checked
at the parent-item and attachment levels. To make the moving library auditable,
the related snapshot is frozen at bibliographic-parent addition time
`2026-08-27T01:48:42Z`: it contains the 57 enumerated PDF attachments added from
`2026-08-26T23:45:55Z` through `2026-08-27T01:48:32Z` and 56 bibliographic
parent records. Adams, Wilson, and Wang (1997) is a standalone PDF attachment.
One note attached to Owen (2007) is not a PDF and was not counted. The two
vocabulary-modality studies added at `00:40Z` are included because they provide
negative controls for separating observed modality, item format, criterion
prediction, and substantive latent dimensionality.

For each PDF:

1. the page count was obtained independently from the PDF container;
2. every page was rendered to an ordered page-image sequence and visually
   inspected;
3. equations, figures, tables, footnotes, page rotation, and extraction gaps
   were checked against `pdftotext -layout` and `pdfplumber` output;
4. image-only or weak-text pages were OCRed or independently extracted and
   checked against the page images; and
5. the original PDF hash, parent key, and attachment key were retained as the
   audit identity.

Coverage was **1,366/1,366 pages**. Unreadable or missing substantive pages:
**0**.
Samejima contains intentional blank/end matter and a malformed annotation
destination warning, but no missing, cropped, or unreadable argument. No Zotero
record, attachment, tag, collection, or PDF was modified.

### Audit ledger and core model-method subset

The machine-checkable full ledger is
`measurement-model-extension-pdf-audit-0.2.4.csv`. It contains one row per PDF
with its parent/attachment keys, title, evidence role, PDF page count, reviewed
page count, unreadable-page count, and SHA-256. Its invariants are 57 unique
attachments, 1,366 PDF pages, `reviewed_pages == pdf_pages` for every row, zero
unreadable pages, and a unique 64-character hash for every attachment.

The compact table below retains the ten papers that directly established the
initial response-family and model-identity architecture. The remaining 47
papers are not lower-priority evidence; they are recorded in the CSV and in the
thematic source capsules below because they primarily govern prediction,
dependence, processes, heterogeneity, and evidence design.

| Source | Zotero parent -> attachment | Better BibTeX key | PDF pages reviewed | SHA-256 |
| --- | --- | --- | ---: | --- |
| Samejima (1969), *Estimation of Latent Ability Using a Response Pattern of Graded Scores* | `USWQ48Z6` -> `BSBSSQD6` | `samejimaESTIMATIONLATENTABILITY` | 97/97 | `69683ec9f5c71ff43cbb29aa8b326605bb88c68e662a2ffa6307563804fd4ada` |
| Fischer and Ponocny (1994), *An Extension of the Partial Credit Model with an Application to the Measurement of Change* | `AKDKRMTQ` -> `CQZAJXAX` | `fischerExtensionPartialCredit1994` | 16/16 | `514344c4c5b359a6c62828bf092cfbf50869e5b6d34b610e1d3650b65a10a64a` |
| Adams, Wilson, and Wang (1997), *The Multidimensional Random Coefficients Multinomial Logit Model* | standalone `SM9A4P4X` | none | 23/23 | `a602a8905af90c28eea4d16d9118f1f36f97e3a6a1dd69d7da78dfc83a298c22` |
| van der Linden (2007), *A Hierarchical Framework for Modeling Speed and Accuracy on Test Items* | `5U2MKKGM` -> `3XKZTBDZ` | `vanderlindenHierarchicalFrameworkModeling2007` | 22/22 | `2fb120b1f9d5d7811a1d9a5c6cee253b6f09b92800ef0ab8da922284c6585b22` |
| Bee and Koch (2026), *Predictive Model Evaluation in Bayesian Mixture and Hierarchical Models for Ordinal Data* | `RWSNELPR` -> `EN5XVDJ9` | `beePredictiveModelEvaluation2026` | 26/26 | `5e19394d6b6efb0ed6da6b91756ad22c7bcc7b4eb2e386ced31e3a1e6087df27` |
| Wilson and Hoskens (2001), *The Rater Bundle Model* | `7SEGKT32` -> `H3EPV72U` | `wilsonRaterBundleModel2001` | 24/24 | `1cb9a612b886a9b88aba85ef0bd5992b26a3086aabc57de358c613d7cc970b10` |
| Huang and Cai (2024), *Cross-Classified Item Response Theory Modeling With an Application to Student Evaluation of Teaching* | `ZEL5USGR` -> `H5UEWMPU` | `huangCrossClassifiedItemResponse2024` | 31/31 | `89b1dca06e192e9a9c5bf102353aff7af8546873b9f055cc6f70daf01b022304` |
| Fischer (1973), *The Linear Logistic Test Model as an Instrument in Educational Research* | `KBX3VEFA` -> `G3N2QDYI` | `fischerLinearLogisticTest1973` | 16/16 | `cd3662bad6ef31743b4eb260bb8f8695aabdc20a0dfa43325c6d99360ddd0be7` |
| Andersson and Xin (2021), *Estimation of Latent Regression Item Response Theory Models Using a Second-Order Laplace Approximation* | `ZX8F258W` -> `PNMTULHX` | `anderssonEstimationLatentRegression2021` | 22/22 | `b06a2c7ade5e44666d4723b31e1bc70a6dd519abb5a071ce3173c98525cfb7d4` |
| Ulitzsch et al. (2024), *Using Response Times for Joint Modeling of Careless Responding and Attentive Response Styles* | `NIKD26IY` -> `M7DN9SBX` | `ulitzschUsingResponseTimes2024` | 34/34 | `2b3cfa85812bf251af489239da9f47eff040eab21c960a349851838e0b807e49` |

The page numbers below are PDF page numbers. Where a journal page differs,
both are supplied when that distinction is important.

## Literature-to-contract findings

### 1. GRM is a different response kernel, not a GPCM option

Samejima defines category probability as a difference between successive
cumulative boundary probabilities,

\[
  P_{gk}(\theta)
    = P^*_{gk}(\theta)-P^*_{g,k+1}(\theta),
  \qquad P^*_{g0}=1,\quad P^*_{g,m_g+1}=0,
\]

with ordered boundary locations and a common item discrimination across the
item's boundaries (PDF p.23, Eq. 4-4; logistic form at PDF pp.34--36). The
monograph is explicitly one-dimensional and locally independent (PDF p.4),
and its main estimation problem treats item parameters as known (PDF p.5).
Posterior-mean ability estimation appears at PDF pp.48--49.

Andersson and Xin restate GRM as a cumulative kernel and GPCM as an adjacent
kernel in the same framework (PDF pp.4--5, Eq. 4--6). Bee and Koch likewise
compare them as different ordinal families (PDF pp.8--10). Therefore:

- `GRM` needs a family-specific cumulative probability and derivative contract;
- PCM/GPCM `step` coordinates must not be relabeled as GRM `thresholds`;
- a binary GRM must reduce to the corresponding 2PL link;
- a three-or-more-category regression test must demonstrate that GRM and GPCM
  are not accidentally made equivalent; and
- adding GRM does not add multidimensionality, random facets, local dependence,
  or a response-time process.

### 2. LLTM/LPCM is a parameter-design layer

Fischer's binary LLTM writes item location as a known operation design times
basic parameters (PDF pp.3--5, Eq. 2 and 6). The known design matrix has full
column rank and fewer columns than items. Fischer explicitly shows that a high
correlation between reconstructed and unrestricted item difficulties is not a
sufficient fit criterion (PDF p.12); a conditional likelihood-ratio test and
independent prediction are separate evidence (PDF pp.8 and 15).

Fischer and Ponocny extend the same idea to PCM cells,

\[
  \beta_{ih}=\sum_j w_{ihj}\alpha_j+h c,
\]

where each row of the known matrix indexes an item-category or virtual-item
cell (PDF pp.2--5, Eq. 1--7). The response kernel stays PCM, discrimination
stays one, and the person trait stays one-dimensional. Their estimator is CML
with recurrence relations and BFGS (PDF pp.5--9).

Consequently, the future contract should name this component
`item_parameter_design`, not reuse the current assignment/connectedness
`design_matrix`, a facet map, or a latent loading map. It must retain row keys,
column names, constraint basis, rank, null space, target coordinate, and a
matrix hash. A saturated design must reduce exactly to the existing PCM. An
MML implementation can be called an LPCM response/parameter restriction, but
it cannot claim to reproduce the Fischer--Ponocny CML estimator without a
separately qualified CML engine.

### 3. Parameter design and latent scoring/loadings require different matrices

Adams, Wilson, and Wang define the multidimensional random-coefficients
multinomial-logit model with a reference-category softmax,

\[
  P(X_{ik}=1\mid\theta,\xi)=
  \frac{\exp(b_{ik}^{\mathsf T}\theta+a_{ik}^{\mathsf T}\xi)}
       {1+\sum_{h=1}^{K_i}
          \exp(b_{ih}^{\mathsf T}\theta+a_{ih}^{\mathsf T}\xi)}.
\]

Here `A` is the fixed/basic-parameter design and `B` is the known latent
scoring design (PDF pp.2--4). The printed Eq. 5 omits the displayed baseline
`1`, but Eq. 11 on the same PDF page makes the baseline-inclusive denominator
explicit. The implementation oracle must use the latter.

Their identification result separates the two spaces: `rank(A)=P`,
`rank(B)=D`, and `rank(cbind(B,A))=P+D`, with `P+D <= K` (PDF p.9). Examples
distinguish between-item and within-item multidimensional scoring (PDF
pp.9--13). MML/EM and product quadrature are described at PDF pp.5--8; the
`Q^D` growth is itself a reason not to make product quadrature the general
high-dimensional engine.

This paper supplies the strongest schema argument in the set:

- observed facet and LLTM effects belong to a parameter-design space;
- substantive latent dimensions belong to a scoring/loading space;
- the number of columns in either space is not the number of observed facets;
- changing the reference category requires a probability-preserving contrast
  transformation; and
- a rank check must happen before optimization.

The Adams model is Rasch-type with known scoring vectors; it is not, by itself,
a free-loading GPCM or GRM.

### 4. Multiple facets, cross-classification, and multidimensionality differ

Huang and Cai model responses cross-classified by two level-2 factors. Each
side has its own latent vector and regression, and the GRM predictor contains
two sets of item loading vectors (PDF pp.2--8, Eq. 1--10). The number of
crossed factors is not the number of substantive dimensions within a factor.
Their sparse empirical design requires strong identification choices,
including fixed latent variances and equal item slopes (PDF p.23/journal
p.333). Simulation design appears at PDF pp.12--14.

Bee and Koch model target, rater, and target-by-rater interaction latent
effects with loadings (PDF p.10, Eq. 7). Their mixture is outside the rater-unit
product (PDF p.11, Eq. 11), and rater-wise LOO integrates newly unobserved rater
and rater-by-target effects (PDF pp.11--12, Eq. 12). The dimension of that
integration is computational; it is not automatically a two-dimensional
substantive ability.

Accordingly, future objects must keep `facets`, `latent_traits`, and
`crossed_random` separate. A random block can itself be vector-valued, but that
dimension must be explicitly named and identified. Current `slope_facet`
cannot double as a MIRT loading map.

### 5. Rater-bundle dependence is not a facet interaction

Wilson and Hoskens first write a conventional rater-facet adjacent-category
model (PDF p.3/journal p.285, Eq. 1). They then show that the ordinary facet
likelihood treats ratings as conditionally independent (PDF p.4) and replace
that product with a bundle-level joint response model whose `kappa` parameters
represent residual rater agreement/dependence (PDF pp.5--9, Eq. 4--6).
Ignoring the dependence overstated reliability in both their application and
simulation (PDF pp.13, 18, and 21--22).

The current additive `facet_interactions = "Rater:Criterion"` changes a linear
predictor; it does not change the joint probability of repeated ratings. A
future `local_dependence` or `rater_bundle` component therefore needs an
explicit `bundle_id`, a rater-pair incidence/connectedness review, and
bundle-level likelihood contributions. `kappa = 0` must reduce to the product
of the conditionally independent event probabilities.

### 6. Response time is a separate process model with a typed actor

van der Linden combines an accuracy model with

\[
  \log T_{ij}\sim N(\beta_i-\tau_j,\alpha_i^{-2}),
\]

where `tau` is person speed, `beta` is item time intensity, and `alpha` is time
precision/discrimination (PDF p.7/journal p.293, Eq. 10--12). Accuracy and time
are conditionally independent given ability and speed at the first level;
their dependence is represented through a second-level person covariance and
an item-parameter covariance (PDF pp.7--9, Eq. 12--22). Raw score-time
correlations mix person, item, and sampling effects and may even exhibit
Simpson's paradox (PDF pp.10--11).

This hierarchy makes the response-time likelihood composable with an accuracy
kernel, but the paper's fitted accuracy model is not evidence that mfrmr's
bounded GPCM or a future GRM joint model has passed recovery. The base RT slice
should first use an already qualified RSM/PCM accuracy path.

For rating data, a `ResponseTime` column might record respondent working time,
rater scoring time, or another event process. A future joint API must require
an explicit `time_actor` and time unit. It must not silently call every actor a
person-speed variable. Seconds-to-milliseconds conversion must shift time
intensity by `log(1000)` and leave response probabilities, latent correlations,
and scores otherwise invariant.

### 7. Speed, response style, and process class are not ordinary dimensions

Ulitzsch et al. combine four distinct components:

1. simple-structure content traits in an attentive GPCM;
2. a person-specific threshold-shift response-style variable;
3. a lognormal time model with person speed; and
4. a person-level attentive/careless latent mixture (PDF pp.9--14, Eq. 1--8).

The careless response component uses a shared category simplex and a separate
time distribution. Missing response and missing time have separate indicators.
The model returns uncertain class membership; it is not a hard filtering rule.
Their empirical two-step threshold filters were highly threshold-sensitive
(PDF p.21), five simulation replications failed the stated convergence check
and were excluded from reported recovery summaries (PDF pp.22--23), strong RT
overlap is an acknowledged weak-identification condition (PDF p.26), and the
person-level constant class may be inadequate for long instruments (PDF p.27).

Thus the current descriptive `response_time_review()` must not be upgraded to
automatic deletion or class labels. A later mixture should return soft
probabilities and an explicit separation diagnostic, preserve every failed
replication in its evidence denominator, and distinguish `content_trait`,
`speed`, `response_style`, and `process_class` roles.

### 8. Estimation algorithms are capability-specific

Andersson and Xin define true MIRT latent regression,

\[
  \theta_i\mid x_i\sim N(Bx_i,\Sigma),\qquad \theta_i\in\mathbb R^D,
\]

and approximate each person's multidimensional integral with a second-order
Laplace correction (PDF pp.4--8, Eq. 1--2 and 14--24). Their simple-structure
framework can mix nominal, GRM, GPCM, and 3PL items. `D`, the loading map,
latent regression, and residual covariance are all true latent-structure
components; none is an observed facet.

The simulations also set a boundary on the claim. With six dimensions and
only three items per dimension, second-order Laplace still had material
nonconvergence; six indicators per dimension was substantially safer (PDF
pp.9--17). Dense loading patterns destroy much of the simple-structure
computational advantage (PDF pp.19--20). Therefore, "supports Laplace" must not
be translated into "supports arbitrary high-dimensional MIRT."

Algorithm selection must follow the frozen model specification:

- one-dimensional fixed/adaptive quadrature remains the first GRM option;
- product or adaptive quadrature is a low-dimensional candidate only after
  convergence and quadrature-sensitivity gates;
- second-order Laplace is a candidate for simple-structure latent regression,
  with indicator-count and loading-density support boundaries;
- MH-RM is a separate candidate for cross-classified random structures;
- HMC is a candidate for mixture and complex joint-process models, not proof of
  their identification; and
- CML is required before claiming reproduction of the Fischer LLTM/LPCM
  conditional estimators.

The objective itself also needs an identity. Tibaldi et al. conditionally
transform a Gaussian crossed model to eliminate one crossed effect before a
standard hierarchical fit, and combine conditional logistic regression with
pairwise pseudolikelihood for binary outcomes (PDF pp.3--8). Their simulation
and application target variance components under those particular
factorizations (PDF pp.9--14); they do not make conditional, pseudo-, or
composite likelihood interchangeable with the full marginal likelihood. Future
fit metadata must therefore distinguish the probability model from the
estimating objective and report objective-appropriate uncertainty.

Bellio et al. provide a model-specific scalable example: for a crossed probit
model they combine a naive marginal probit fit with row-wise and column-wise
hierarchical probit likelihoods, invert the resulting attenuation identities,
and replace one high-dimensional integral by one-dimensional integrals (PDF
pp.4--7). Consistency requires both crossed axes to grow without a dominant
row or column and explicit covariate conditions (PDF pp.7--8); uncertainty uses
a robust sandwich or a crossed/pigeonhole bootstrap rather than the naive
Hessian (PDF pp.8--10). The proof also conditions on the observed incidence
set and assumes noninformative missingness (PDF p.4). Its approximately linear
cost and large-data results (PDF pp.10--17) are evidence for that binary-probit
composite objective, not for arbitrary links, ordinal kernels, or exact MML.

### 9. Prediction requires a target, an integration measure, and a score

Skrondal and Rabe-Hesketh distinguish a conditional prediction for a specified
random effect, a posterior-averaged prediction for another unit in an observed
cluster, and a prior-averaged prediction for a new cluster (PDF pp.3--16).
Plugging an EBP/MAP random effect into a nonlinear inverse link is not generally
the corresponding posterior mean. Merkle, Furr, and Rabe-Hesketh make the same
distinction operational for DIC, WAIC, and PSIS-LOO: response-wise conditional
terms and cluster-vector marginal terms answer different questions (PDF
pp.4--10, 16--20). With crossed effects, “conditional” versus “marginal” is not
a sufficient binary label; the exact set of effects integrated out is needed.

Stenhaug and Domingue show that missing-response prediction for an already
observed person and missing-person prediction after integrating the ability
distribution can prefer different IRT models (PDF pp.3--7 and 13--17).
Rabinowicz and Rosset generalize the point: a CV split is unbiased for its
target only when the holdout--training relation matches the future
prediction--training relation (PDF pp.8--17). Correlation correction does not
repair covariate shift or extrapolation (PDF pp.35--36).

Braun, Sabanés Bové, and Held offer a fast, fit-once approximation to
leave-one-observation-out prediction in GLMMs using Bayesian IWLS moments, and
use proper Brier, logarithmic, and Dawid--Sebastiani scores to select fixed and
random effects (PDF pp.2--6). Their held-out observation remains linked to the
other observations from the same individual, and their full-refit comparison
exposes singular-covariance failures (PDF pp.6--12). The method is therefore an
algorithm for one declared same-cluster prediction regime, not a shortcut to
new-person, new-item, or crossed new-entity CV. Any fit-once approximation must
be named as such and calibrated against explicit refits within its support
envelope.

Gneiting and Raftery define strict propriety as truthful predictive reporting
being uniquely optimal in expectation (PDF pp.2--6). Log score, Brier score,
CRPS, energy score, and interval score have different domains; zero--one
accuracy and PMCC are not acceptable primary distributional criteria (PDF
pp.6--13). Therefore `AnalysisSpecV1` must retain:

- the holdout unit and rows removed together;
- `new_entities`, `condition_on`, and `integrate` as explicit entity sets;
- the target population/occasion and whether the observed incidence pattern is
  conditioned on;
- the grouped pointwise log-likelihood identity;
- a frozen proper primary score, orientation, clipping rule, and any joint-score
  weights; and
- criterion Monte Carlo error, pairwise score-difference uncertainty, and an
  `indeterminate` result when ranking is not separated from numerical error.

### 10. Crossed-model structure and dependence-aware inference are separate

Cameron, Gelbach, and Miller form a two-way cluster covariance by
inclusion--exclusion, `V_G + V_H - V_GH`, and extend it to all nonempty
intersections of `D` clustering axes (PDF pp.4--7). MacKinnon, Nielsen, and Webb
show that the resulting estimator can be non-PSD, that the asymptotic rate can
change with the data-generating dependence, and that few clusters materially
alter wild-bootstrap behavior (PDF pp.4--8 and 10--32). These are inferential
conditions, not latent-scale identification conditions.

Owen's pigeonhole bootstrap independently resamples rows and columns of a
sparse array and is generally conservative under its stated no-dominant-level
conditions (PDF pp.3--14); conditioning on the observed incidence mask is a
different target from generating a new mask (PDF p.23). Owen and Eckles extend
product reweighting to arbitrary-order arrays and show that it can become very
conservative when only highest-order interactions remain (PDF pp.4--17).
Bakshy and Eckles likewise find that resampling only the randomized user unit
can lose coverage when item-by-treatment heterogeneity is present, while a
multiway bootstrap is often conservative (PDF pp.2--8). Vaughan and Begg's
paired-school study further illustrates that the number of independent schools,
not only total pupils, governs performance and convergence (PDF pp.4--16).

Menzel makes the scope boundary sharper. The “two or more dimensions” in that
paper are row/column sampling-dependence axes, not latent traits or model
facets. Under separately exchangeable arrays, nonseparable row-by-column
components can be pairwise uncorrelated yet have a non-Gaussian product-normal
limit (PDF pp.2--10). No selector estimates the limiting distribution uniformly
over the full two-way parameter space; the proposed pointwise and adaptive
bootstraps instead trade local adaptivity against uniform size control and can
be deliberately conservative near degeneracy (PDF pp.11--17). Its OLS
extension (PDF pp.25--28) does not automatically establish validity for an
ordinal marginal-likelihood estimator. A future GPCM/GRM bootstrap therefore
needs either a justified asymptotically linear score representation or its own
full-refit qualification.

Consequently, a crossed measurement model must not silently select a sandwich
estimator, bootstrap, or CV split. `AnalysisSpecV1` needs separate
`sampling_units`, `assignment_unit`, `dependence_axes`, `resampling_scheme`,
`cluster_counts`, `intersection_policy`, and finite-cluster correction fields.
The current person-cluster observed-data resampling remains a useful stability
tool; it is not renamed pigeonhole, multiway wild, or crossed-facet inference.

### 11. Crossed random effects describe ownership and generalization, not MIRT

Quené and van den Bergh demonstrate that person and item random effects and
condition slopes must be crossed at the trial level; aggregating proportions or
omitting one owner can inflate Type-I error (PDF pp.4--12). Hoffman and Rovine
separate nested/crossed designs, random slopes, centering, and multivariate
outcomes (PDF pp.3--16). Rasbash and Goldstein and Raudenbush show how nested and
crossed Gaussian blocks can coexist, how unbalanced incidence enters the design,
and how omitting a crossed owner reallocates variance and changes uncertainty
(PDF pp.4--12 and pp.7--27, respectively). Van den Noortgate, De Boeck, and
Meulders express the Rasch model as crossed person/item logistic random effects
while retaining a single ability axis (PDF pp.2--10).

Gilbert et al. show that cluster-by-item heterogeneity affects value-added
reliability and generalization; ignoring the interaction variance can
systematically overstate reliability (PDF pp.4--18). Wagler expresses GLMM
heterogeneity on an odds-ratio scale and shows poor small-sample coverage near
the variance boundary (PDF pp.2--11). Together these sources require a typed
`RandomBlockSpec(group, coefficients, covariance, population_target)` and a
`GeneralizabilityTarget` that declares which facets are fixed versus sampled
and the intended numbers of items, raters, or clusters. The following remain
different:

- a fixed observed facet effect;
- a scalar random intercept or slope owned by a sampling unit;
- a random interaction such as cluster-by-item;
- a vector-valued random block or outcome covariance; and
- a substantive latent content dimension with a loading map.

### 12. Outcome, method, and computational factors need semantic roles

Gueorguieva jointly models outcome-specific GLMMs with correlated random
effects and conditional independence, and explicitly treats a common latent
effect and correlated outcome-specific effects as different cases (PDF
pp.3--16). Agogo et al. use a shared random effect for two binary outcomes but
generate data from two highly correlated effects; the fitted one-factor model
is therefore a restriction, not evidence that two outcomes are one trait (PDF
pp.2--5). Broatch and Lohr's “multidimensional” value-added model concerns a
teacher random-effect vector over distinct real-world outcomes, with scale and
G-versus-R identification requirements (PDF pp.3--11); it is not person-level
MIRT.

Koch et al. distinguish construct factors from method residual factors at
within- and between-cluster levels using an explicit reference method (PDF
pp.7--16). Their simulation shows especially weak between-level performance for
low ICC, five observations per cluster, and few clusters (PDF pp.22--29).
Jeon and Rabe-Hesketh use factor loadings as a general coefficient structure
for random effects and profile the structured parameters (PDF pp.2--7 and
13--21). Such a factor may encode persistence or covariance compression; it is
not automatically a substantive IRT dimension. Leckie shows that correlations
among separate EB/BLUP point estimates do not equal the structural
random-effect correlation and may be biased in either direction (PDF pp.5--13
and 16--25).

Hui's processing-time example makes another terminological collision explicit:
first-fixation duration and total reading time are two observed outcomes in a
Bayesian multivariate mixed model, with crossed participant and word random
intercepts, outcome-specific fixed effects, and covariance at the participant,
word, and residual levels (PDF pp.5--12). That is multivariate outcome modeling,
not a two-dimensional ability model. Aliyar, Siyanova-Chanturia, and Skalicky
similarly analyze form recognition, meaning recall, and meaning recognition as
separate binary outcomes with crossed participant/item intercepts (PDF
pp.10--12), while input modality and lexical item type are observed predictors.
Robles-García et al. call vocabulary knowledge a multidimensional construct,
but their recognition and recall modalities are observed test scores used in
correlation and criterion-prediction analyses rather than an identified MIRT
loading model (PDF pp.2--8 and 11--14). These are useful negative controls: an
outcome, test modality, item format, or criterion relationship does not acquire
the `substantive_trait` role merely because authors use the word
“multidimensional.”

The specification must therefore give every axis a role such as
`substantive_trait`, `method`, `outcome_domain`, `latent_speed`,
`response_style`, or `computational_factor`. Fitted objects must label
`structural_correlation` separately from `score_correlation`; the latter cannot
be returned as a latent covariance estimate. A factor-analytic random
covariance requires its own rotation, scale, sign, rank, and boundary gates.

### 13. Answer change and response style require process/category geometry

van der Linden and Jeon model initial response and conditional change as a
two-stage event with a shared fixed ability scale; reviewed-but-unchanged and
not-reviewed are not observationally interchangeable (PDF pp.4--8). Their
robustness analysis shows that unknown review opportunities change item
probabilities and tail diagnostics (PDF pp.13--17). Jeon, De Boeck, and van der
Linden instead encode `WW`, `WR`, `RW`, and `RR` as leaves of a three-node IRT
tree with node-specific traits and item parameters (PDF pp.4--12). Leaf
probabilities are path products, not ordered-category probabilities, and
structural nonreachability is not ordinary missingness.

Tutz and Berger add a signed adjacent-step design for middle/extreme response
style: style contributions switch sign around the middle and are zero at the
central split for even category counts (PDF pp.4--7). Simulations show material
content-effect bias when style is ignored (PDF pp.13--18). Jin, Wu, and Chen
combine an ideal-point attitude process with a monotone extreme-style process
through an explicit item-response tree; neutral categories may aggregate
multiple paths (PDF pp.4--8 and 14--21). Chan and McDermott provide a useful
construct warning: unchanged marginal recognition accuracy can coexist with a
shift between recollection and familiarity processes (PDF pp.1--6).

A later `ProcessGraphSpec` therefore needs event identity, nodes, routes,
families, latent roles, leaf/category mapping, structural missingness, and
multi-path aggregation. The minimum event schema is
`person, item, attempt, state, response, opportunity, timestamp`. Final-only
rows cannot identify a change process, tree leaves cannot be passed to GPCM or
GRM as if ordinal, and an intent such as cheating cannot be inferred from a
model-dependent tail flag.

The new process papers sharpen the required graph semantics. Wei, Cai, and Tu
factor a mixed-format item into a multiple-choice step followed conditionally
by an open-ended step; their NRM-, nested-logit-, or 3PL-based first node and
2PL second node share one ability, even though the reported score has three
levels (PDF pp.3--7). Their comparisons with SRM, GRM, and GPCM show that a
sequential path and an ordinal category kernel are empirically different model
claims (PDF pp.7--13). Bolsinova et al. contrast a scoring-rule representation
of the four accuracy-by-hint states with an IRTree that models hint request and
conditional accuracy as sequential events (PDF pp.3--10); the extra hint-use
axis is a process propensity, not another content ability. Alarcon, Lee, and
Johnson's midpoint-primary-process IRTree has midpoint, agreement, and extreme
nodes with node-specific item parameters and traits (PDF pp.2--4). Across
2,000 replications per condition, recovery deteriorates deeper in the tree and
does not become reliable merely by increasing the nominal number of items or
persons (PDF pp.4--9). Process-node reachability and node-specific information
therefore belong in both identification diagnostics and the evidence grid.

### 14. A time family is not evidence for another construct dimension

Hui, Godfroid, and Elgort contrast “automatic” word knowledge with a harder
indicator of one lexical-quality factor (PDF pp.3--14). Their two-factor
person-score CFA had a factor correlation of `.92`, was not favored by a
chi-square difference test, and used trimmed correct-response times rather than
an item-level joint likelihood (PDF pp.9--21). This is valuable construct
evidence but not a direct implementation oracle for a GPCM--RT model.

Accordingly, adding `time_family` and adding an ability dimension are separate
feature decisions. The base joint-RT study must compare at least a shared
one-content-axis model, a correlated ability--speed model, and residual/local
dependence alternatives. It records censoring, trimming, timeouts, incorrect
response times, trial order, platform, and occasion. Promotion requires stable
identification and held-out proper-score improvement across prespecified data
generators, not an in-sample fit gain or the existence of an RT column.

Guo, Xu, and Zhang show why missing responses cannot be represented by one
generic `NA` code in that process. Their joint likelihood combines a 2PL
accuracy model with lognormal response and omission times and correlated person
ability, response-speed, and omission-speed variables; the first not-reached
item is a right-censored potential response time, whereas an omission is a
competing event between response and omission clocks (PDF pp.5--10). They fit
the marginal likelihood by EM and compare response-only, RT-only, NRI-only,
OI-only, and joint mechanisms over multiple missingness regimes (PDF pp.10--24).
These speed/omission variables are process roles, not automatically additional
substantive content dimensions. A later survival-process slice must therefore
declare the test clock, risk set, censoring boundary, competing-event rule, and
whether item order is fixed; it cannot be enabled by the presence of an RT
column alone.

### 15. Treatment heterogeneity is an estimand layer, not a dimension

Gilbert, Kim, and Miratrix add an item-by-treatment random slope to an
explanatory IRT model and distinguish inference to a latent item population
from inference for the finite administered test (PDF pp.4--7). Their simulations
show that a constant-effect model can understate item-population uncertainty
when item-level treatment heterogeneity is present even if the mean estimate is
nearly unchanged (PDF pp.7--13).

Gilbert et al. then show that person-by-treatment moderation and correlated
item difficulty/item-treatment effects can mimic one another in aggregate
scores and bias each other when only one is modeled (PDF pp.4--16). Item-level
responses and a joint model are required for the proposed separation; the
empirical and causal interpretation additionally depends on randomized
treatment and pre-treatment information (PDF pp.16--23). An item treatment
slope is therefore neither a new latent ability dimension nor an ordinary
facet severity. Any future `CausalSpec` remains on hold and must declare
assignment, moderator timing, `finite_test` versus `item_population`, and the
probability/linear-predictor/score estimand. Measurement recovery alone cannot
authorize a causal claim.

### 16. Simulation evidence is a versioned object, not a successful-fit table

Pawel et al. distinguish missingness caused by the data generator, the method,
and the performance measure, and show that deletion changes the implicit
estimand (PDF pp.5--14). Their checklist requires the attempted denominator and
handling rationale (PDF p.15). Siepe et al. organize simulations by ADEMP and
require an explicit target, performance measure, Monte Carlo precision, seed
policy, and preregistration (PDF pp.4--9 and 13--17). Pawel, Kook, and Reeve
demonstrate how method, metric, seed, and stopping choices made after inspection
can manufacture apparent superiority (PDF pp.3--8 and 14--19). Agogo et al.'s
use of 1,000 *converged* datasets without the attempted count (PDF p.3) is an
example that mfrmr must not copy.

White et al. add an operational checking layer: include settings with known
answers, build and check the data generator before fitting methods, inspect
individual generated datasets, and diagnose unexpected results with plots that
retain both point estimates and estimated standard errors (PDF pp.2--6). They
also require failed and outlying estimates to be identified rather than
quietly removed (PDF pp.5--6). Thus a frozen ADEMP plan is necessary but not
sufficient; it must carry executable sentinel cases and an audit trail showing
that the generator, estimator wrapper, and performance calculation were
checked in stages before confirmation.

Braun et al. supply a concrete audit fixture: their stated logistic scenario
sizes differ between prose and table, singular random-effect covariances receive
`-Inf` scores, and datasets are generated until 100 valid runs are obtained
(PDF pp.6--7); the full-refit comparison also has many unavailable scores (PDF
pp.11--12). mfrmr must retain the original planned attempts and the exact
scenario source instead of copying a successful-run replenishment convention.

Menzel supplies a second sentinel: the drifting-cluster variances printed in
the prose and Table I footnote differ by a factor of ten (PDF p.20), despite an
otherwise extensive 10,000-dataset by 2,000-bootstrap-draw study. A frozen
machine-readable DGM, its rendered formula/table values, and a consistency
check across prose, table, and executable generator are therefore release
evidence, not editorial extras.

Every research slice therefore gets an `EvidenceSpecV1` before its confirmatory
run. Each attempt has exactly one terminal status such as `valid`,
`dgm_invalid`, `fit_error`, `nonconverged`, `invalid_draw`, or
`metric_undefined`. Primary and sensitivity handling rules are frozen in
advance; successful runs are not silently replenished. All reported metrics
carry the planned and attempted denominators and Monte Carlo uncertainty.

## Separated internal identities; composition unsupported by default

`MeasurementSpecV2`, `AnalysisSpecV1`, and `EvidenceSpecV1` are working internal
names, not public API commitments or proof that their fields can be combined
arbitrarily. They divide what is being modeled, what estimation/prediction/
inference is requested, and what validation evidence can change a support
decision.

A fit artifact carries the measurement identity, the fit-relevant subset of
the analysis identity, and execution provenance. `EvidenceSpecV1` is a
study-level object that references one or more fit/analysis identities; it is
not embedded as part of a fitted probability model and cannot change the fit's
meaning after the fact. Predictive evaluations and comparison records likewise
reference, rather than mutate, the fits they assess.

The tables below are a semantic vocabulary and refusal map. A1 does **not**
instantiate every future row as a nullable universal schema. It starts with the
identity-critical fields needed by the current RSM/PCM/bounded-GPCM core and
one admitted next slice. A future field enters the concrete schema only when a
current fail-closed invariant requires it or two admitted consumers establish
reuse.

### MeasurementSpecV2 -- probability and parameter identity

| Axis | Required content | Must not be inferred from |
| --- | --- | --- |
| `observed_scale` | `ScaleId`, category map, missingness and eligibility | family name or observed values alone |
| `response_family` | adjacent, cumulative, or reference-category kernel; link | number of categories, facets, or thresholds |
| `threshold_step_structure` | ordered thresholds vs adjacent steps; ownership and constraints | a shared `step_facet` label |
| `discrimination_structure` | unit, current full-predictor owner, latent-loading-only, or composed rule | a loading map or facet count |
| `item_parameter_design` | known `A`/`W`, target coordinate, rank, constraints, row map, hash | assignment/incidence design or `facets` |
| `outcomes` | named outcome, family, link, category/time/event geometry, scale anchor | number of traits or random blocks |
| `incidence` | canonical shared-owner/row map and hash, observed owner/event mask, overlapping/cumulative membership, multiplicity, order/eligibility, balance/sparsity, assignment origin | outcome-specific row numbers, observed rows alone, or the number of facets |
| `latent_axes` | named axis, semantic role, dimension count `D`, scoring/loading map, covariance | observed facet count, process variables, integration dimension |
| `facets` | observed design columns and fixed/additive effects | random effects or latent traits |
| `random_blocks` | owner unit, coefficients, incidence, covariance, population target | number of facets, outcomes, or hierarchy levels |
| `method_structure` | method role, reference method, nesting level, trait-method constraints | a fixed rater/source facet |
| `local_dependence` | bundle/testlet/event grouping and joint probability structure | additive facet interactions |
| `process_graph` | event actor, nodes, routes, risk set, censoring/competing-event rule, named and hashed leaf/score map, structural missingness, time/style/class roles | final response, `ResponseTime`, a post-hoc score recode, or a QC flag alone |
| `causal_structure` | treatment assignment, timing, moderator, random sensitivity, estimand scale | an item slope or model coefficient alone |
| `identification` | location/scale, reference/contrast, order, sign/rotation, rank, SPD/PSD constraints | optimizer defaults |

### AnalysisSpecV1 -- prediction, estimation, and inference identity

| Axis | Required content | Refusal condition |
| --- | --- | --- |
| `estimation` | JML/MML/CML/Bayesian route, integration rule, optimizer, support envelope | family name is used as the estimator |
| `objective` | full marginal, conditional, pseudo-, composite, separate-outcome, joint-outcome, or score-level contribution map; weights and objective-appropriate uncertainty | a surrogate objective is labeled full likelihood; a separate fit or score regression is labeled a joint item-response likelihood |
| `prediction_target` | holdout unit, new entities, conditioned entities, integrated effects, population/occasion | `conditional=true` leaves crossed effects ambiguous |
| `likelihood_grouping` | event or entity-vector contribution and comparability signature | row likelihood is reused for a new-entity claim |
| `scoring` | proper primary score, orientation, clipping, weights, secondary diagnostics | accuracy/AUC/PMCC is the sole distributional criterion |
| `sampling_design` | sampling and assignment units, dependence axes, cluster counts, incidence-mask target | model facets are silently treated as sampling axes |
| `resampling` | split/bootstrap scheme, intersection rule, exchangeability/growing axes, pointwise/uniform scope, finite-cluster correction, refit/marginalization | split does not match the prediction regime |
| `selection` | candidate model/score-map set, selection route, multiplicity rule, internal/external selection data | data-driven selection is reported as a prespecified model |
| `uncertainty` | structural vs score uncertainty, covariance-aware contrasts, boundary method, criterion MCSE, indeterminate rule | EB/EAP point-score correlation or a separate-fit contrast is labeled structural |

### EvidenceSpecV1 -- decision and simulation identity

| Axis | Required content |
| --- | --- |
| `aim` | concrete user decision, estimand, claim, and non-claim |
| `claim_scope` | model/estimator support envelope, target population, pointwise/uniform and boundary scope |
| `data_generating_mechanism` | frozen parameters, incidence/missingness/process generator, scenario grid, hash |
| `methods` | frozen candidate/comparator and score/leaf-map set, versions, starts, algorithms, fallback/hybrid identity, selection dataset, resource envelope |
| `performance` | primary proper score or recovery criterion, direction, threshold, secondary metrics |
| `replications` | planned attempts, Monte Carlo precision target, pilot/confirmation separation |
| `failures` | exhaustive terminal status taxonomy, denominator, primary and sensitivity handling |
| `randomness` | seed/substream and draw-scope policy, replicate replay identity, prohibition on seed or replicate selection |
| `freeze` | preregistration/freeze time, code/environment hash, timestamped amendments |
| `checks` | known-answer sentinel cells, staged DGM/fit/metric checks, formula/table/code agreement, replay and independent-implementation checks, invariant/diagnostic-plot record |
| `decision_rule` | pass/fail/indeterminate mapping and the scope reduced when a gate fails |

Mandatory invariants:

1. facet count is not latent dimension count;
2. multiple observed scales are not automatically multiple latent traits;
3. a crossed random block is not a content dimension unless a construct and
   loading map say so;
4. local dependence is not another facet effect;
5. speed, response style, and process class are not ordinary accuracy facets or
   interchangeable substantive abilities;
6. LLTM/LPCM parameter design does not define the response family;
7. the numerical dimension of an integration is not a substantive dimension;
8. outcome count, method-factor count, and random-covariance rank are not `D`;
9. item- or cluster-level heterogeneity is not automatically a latent trait;
10. conditional/marginal refers to named integrated effects, not a universal
    model property;
11. a causal estimand is not identified by measurement-model fit alone;
12. event, process-clock, and censoring variables are not content dimensions;
13. an estimation approximation or composite objective does not change the
    declared probability model or become its exact likelihood;
14. the number of incidence owners or dependence axes is not `D`;
15. an API/library field named `trait` is not a latent trait without an explicit
    latent role and loading map; and
16. shared person/item/word identities and deterministic overlapping score
    bands are not split into independent entities by outcome or analysis table.

Legacy aliases should compile as follows:

| Legacy label | Compiled identity |
| --- | --- |
| `RSM` | adjacent kernel; unit slope; shared step structure; `D=1`; fixed additive observed facets |
| `PCM` | adjacent kernel; unit slope; item/facet-specific adjacent steps; `D=1`; fixed additive observed facets |
| current bounded `GPCM` | adjacent kernel; `slope_facet == step_facet`; one owner applies a geometric-mean-one relative slope to the full predictor; `D=1` |
| future `GRM` | cumulative kernel; ordered thresholds; positive discrimination; initially `D=1`; no automatic conversion from PCM/GPCM steps |
| future `LLTM/LPCM` | existing binary/adjacent family plus a known item-parameter design; does not change `D` |

Each fitted object should ultimately be able to emit a parameter-role table
with at least `Parameter`, `Owner`, `Role`, `KernelAction`, and
`IdentificationConstraint`.

## Current source audit

The present architecture is coherent for its current scope but not yet a safe
plugin boundary for the proposed extensions.

- `R/core-likelihood.R:168` centralizes the RSM/PCM/GPCM response-probability
  bundle, but branches directly on `config$model` and uses adjacent-family
  expected-score identities in its information calculation.
- `R/mfrm_core.R:1483`, `:1558`, `:2706`, and `:2913` build parameter sizes,
  expand parameters, resolve step/slope facets, and construct estimation
  configuration around the current three-family contract.
- `R/mfrm_core.R:1693` computes a scalar ability predictor. The MML probability
  path at `R/mfrm_core.R:1755` indexes one person node per quadrature point; it
  is not a vector-latent integration interface.
- the literal `config$model` appears 180 times across 39 R files. This count
  includes reporting and guards as well as mathematical branching, so it is a
  coupling indicator rather than a count of unique kernels.
- twelve function declarations across five R files hard-code
  `model = c("RSM", "PCM", "GPCM")`.
- `R/api-response-time.R:1` and `:176` implement descriptive timing review;
  user-facing messages at `:347` and `:574` correctly say that it is not a
  joint speed-accuracy model.
- `R/api-resampling.R:1` implements observed-data stability resampling with the
  person as the clustering unit. It preserves a person's rows, but it does not
  claim crossed/pigeonhole/product-weight resampling or multiway-cluster
  inference.
- the current R surface has no unit-grouped pointwise likelihood, WAIC, LOO,
  PSIS-LOO, or stacking API. This is preferable to attaching those names to
  row-wise conditional likelihoods before the prediction target exists.
- current simulation helpers already use parts of ADEMP and retain some failed
  fits, but there is no single serializable object that freezes comparator,
  target, proper primary score, complete failure taxonomy, Monte Carlo precision,
  seed policy, and amendments together.
- The 2026-08-27 source audit found that `evaluate_mfrm_design()` documented
  and announced `future.apply::future_lapply` while still executing the same
  nested serial loop. That maintenance defect is now corrected in the
  development tree: `R/api-simulation.R` dispatches replications through
  `future.apply::future_lapply`, records
  `parallel_seed_policy = "preallocated_design_rep_cell_v1"`, and
  `tests/testthat/test-simulation-design.R` requires fixed-ordered-grid
  serial/future equality plus ambient-RNG preservation. This closes the
  public execution-path truth defect, not A3's stronger identity-derived
  substream requirement.
- simulation and resampling seeds are currently allocated in loop order with
  `sample.int()`, while `with_preserved_rng_seed()` restores `.Random.seed` but
  does not define an identity-derived parallel stream. This is adequate for the
  current serial helper but not for A3's method/order/plan-independent evidence
  contract.
- fitted-object identity, fixed-calibration artifact identity, optimizer
  checkpoint identity, and study/attempt evidence already have different
  lifecycles. They must not be merged into one schema. In particular, current
  GPCM fixed-calibration parity means preserving the typed unsupported-family
  refusal, not silently adding GPCM to the RSM/PCM portable artifact.
- the TAM importer explicitly refuses `ndim != 1`; the mirt importer does not
  expose the same early dimension guard. E2 therefore remains blocked until
  imported dimension and parameterization are verified rather than inferred
  from an external object skeleton.

The architecture task is therefore not a broad replacement of working code.
It is an internal compiler/registry seam whose first acceptance criterion is
that nothing observable changes for current aliases.

### Maintenance truth gates before A1--A3

The next work is not a new response kernel. First freeze a canonical semantic
projection for current RSM/PCM/GPCM by JML/MML route, including probability,
objective, gradient, identified coordinates, engine/fallback, typed refusal,
scoring, simulation, import, replay, checkpoint, and fixed-calibration behavior.
Raw RDS bytes and nonsemantic formatting are not the oracle.

Before A1 changes production, preserve the current lifecycle boundaries and
legacy replay authority. The first compiler path is therefore:

`legacy request -> unresolved request identity -> data preparation/binding ->`
`bound measurement/analysis identity -> existing config adapter -> current fit`

It runs in shadow mode first and is not stored in fitted objects. A controlled
switch is allowed only after semantic parity, followed by removal of the
superseded semantic branches. If old and new authorities must coexist
indefinitely, rollback is the correct outcome.

Before A3 confirmation, either implement `parallel = "future"` with an
identity-derived deterministic stream/substream and serial/parallel equality
tests, or withdraw/disable the option and its support wording. A message without
a distinct execution path is a stop condition. The same gate freezes request
versus data-bound hashes, attempt IDs, terminal statuses, and replay identity.

The immediate execution-path part of that gate is now closed for the existing
helper. For the same ordered design grid and explicit seed, serial and future
routes receive the same preallocated cell seeds and return the same semantic
results apart from elapsed time; the active `future::plan()` controls actual
concurrency. Grid-order and method-order invariance are deliberately **not**
claimed. A3 therefore remains queued until its replicate identity derives from
the frozen study identity rather than loop position.

The current semantic baseline is an indexed projection, not a new monolithic
fixture or raw-object hash:

| Semantic surface | Current executable evidence | Frozen comparison |
|---|---|---|
| probability, objective, gradient, identified coordinates | `test-estimation-core.R`; `test-gpcm-model-identity-contract.R`; focused GPCM numerical-oracle tests | exact values where routes are unchanged; independently justified tolerance only for explicit numerical approximations |
| output, warning, refusal, and public support boundary | `test-core-behavior-contracts.R`; `test-gpcm-capability-matrix.R`; fixed-calibration G0/G4 contract tests | typed state, parameter role, support disposition, and user-visible claim |
| simulation and execution path | `test-simulation-design.R` | generated semantic inputs and result tables; elapsed time excluded |
| import, replay, checkpoint, and portable artifact lifecycle | importer tests; optimizer-checkpoint tests; fixed-calibration contract/replay tests | lifecycle-specific identity and refusal; no merged universal artifact identity |

Before an A1 shadow compiler can be admitted, its comparison manifest must
resolve these indexed surfaces to named tests and record any intentional
omission. Creating a second all-purpose baseline object would duplicate
authority and fails the gate.

## Phased internal roadmap

### A0. Literature and identity freeze -- complete

Deliverables:

- this 57-PDF, 1,366-page audit ledger and checksum manifest;
- the separated identity vocabulary and unsupported-by-default composition
  rule above;
- explicit non-equivalences among facet, dimension, parameter design, random
  block, local dependence, response time, style, and mixture; and
- source-level coupling inventory.

No support status changes at A0.

### A1. Minimum identity/registry spike -- parked, current No-Go

The 2026-08-27 admission audit stopped before prototype code. A reproducible
text scan found 179 `config$model` references across 41 R files and 293 lines
containing a family-bearing model conditional. These are coupling indicators,
not 293 duplicated semantic decisions: `mfrm_core.R` and
`api-simulation.R` alone account for 127 conditional lines, mostly probability,
parameter expansion, estimation, and data-generating branches that a registry
cannot remove.

Current semantic choke points already exist:

| Responsibility | Existing authority | Audit result |
|---|---|---|
| public family choice and data binding | `fit_mfrm()` -> `prepare_mfrm_data()` -> `resolve_step_and_slope_facets()` -> `build_estimation_config()` | one production config builder; explicit GPCM step/slope-owner refusals already occur before fitting |
| response probability | `core-category-probabilities.R` | one browseable RSM/PCM/GPCM kernel module; family dispatch is mathematically necessary |
| bounded-GPCM identity and route scope | `mfrmr_gpcm_model_identity()` plus `.gpcm_capability_registry()` and typed scope errors | already shared by fit, methods, boundary tables, and guarded helpers |
| portable calibration identity | versioned fixed-calibration schema and validator | intentionally RSM/PCM MML and lifecycle-specific; generalizing it would merge identities that must remain separate |
| proposed three-spec vocabulary | roadmap and contract tests only | zero production consumers; no GRM, LLTM/LPCM, MIRT, or joint response-time family has been admitted |

No audited branch set could be named for deletion after adding
`MeasurementSpecV2`, `AnalysisSpecV1`, and an evidence reference. The likely
first implementation would instead copy fields from the existing bound config,
adapt them back to that config, and retain both paths. That meets the explicit
rollback condition. A shadow spike would therefore be implementation activity
without demonstrated user or maintenance value.

Decision: do not create A1 code, serialization, fitted-object fields, or an
invalid-spec framework now. Retain the facet/dimension/parameter-design/
objective/evidence vocabulary in this roadmap and keep the current explicit
branches authoritative.

A1 may reopen only when all of the following are recorded in the canonical
ledgers:

1. one concrete current-core invariant that the existing config cannot enforce,
   or two independently admitted consumers that need the same fields;
2. named before/after branch sites showing what will be deleted rather than
   wrapped;
3. a bounded ownership table that does not copy fixed-calibration, replay,
   checkpoint, or evidence lifecycles; and
4. a no-build comparison showing lower total maintenance cost than explicit
   branches or external integration.

The specification below is retained only as the reopen envelope, not as an
active task.

The first slice is a time-bounded, deletable spike behind current public
arguments. It freezes invariants and refusals, not every future feature field.
It does not add a public constructor, generic plug-in API, new family behavior,
fit-object field, or fit-time `EvidenceSpecV1`.

Required output:

- a minimal measurement identity for current RSM/PCM/bounded GPCM;
- the fit-relevant analysis identity, including probability model versus
  estimating objective;
- a study-level evidence-reference identity with no probability fields;
- a parameter-role table and legacy-call trace;
- deterministic serialization, schema versioning, and unknown-field refusal;
- an invalid-spec corpus covering facet/latent/random/outcome/objective
  collisions; and
- a source-coupling inventory showing which duplicated branches the accepted
  seam would remove, not merely relocate.

The spike compiles an unresolved request, binds data-dependent category/facet
identity during the existing preparation path, and adapts the bound identity
back to the current runtime config. The current probability and optimizer code
remain authoritative until A2; the spike must not duplicate data preparation,
estimability, replay, or checkpoint logic.

Admission requires a current fail-closed invariant or two admitted consumers.
One deliberately unsupported extension must be representable as an identity
and refused before fit; implementing it is outside A1.

Accept the spike only when field ownership is unambiguous, serialization is
order/process independent, public behavior is unchanged, and semantic change
points are fewer or materially easier to audit. Revert it if it creates a
universal nullable schema, requires family-specific bypasses, leaves permanent
old/new sources of truth, or cannot show value if no new family ships during
the next planning horizon.

### A2. Exact current-family parity -- conditional hold

Compile RSM, PCM, and current bounded GPCM through the accepted spike without
changing the public call or result meaning. Compare old and compiled paths for:

- per-row category probabilities and log probabilities;
- JML and MML objectives and analytic gradients;
- fitted parameters after documented coordinate normalization;
- scoring and fixed-calibration artifact identity;
- simulation, import, replay, diagnostics, and public output semantics; and
- warning/error classes and text only where they are part of the tested user
  contract.

For fixed calibration, parity is support-profile specific: RSM/PCM portable
artifacts must remain identical, while GPCM must preserve the current typed
unsupported-family refusal. Adding a spec field to old fits, changing checkpoint
fingerprints, or creating a second replay format is outside this gate.

Exact equality is required where code paths are unchanged; any tolerance must
be justified by a deliberately changed numerical route. Nonsemantic formatting
uses risk-tiered regression rather than making every string a permanent API.
The exit record must also show deleted or consolidated semantic branches. If
the only way to pass is to keep both paths indefinitely or widen a tolerance
after observing drift, rollback wins.

This gate applies only if A1 reopens and is accepted. The indexed current-family
semantic regression baseline remains required for every new family regardless
of A1, but no compiler-parity programme is run while there is no compiler.

### A3. Evidence-plan and attempt-ledger foundation

Make a minimal study-level `EvidenceSpecV1` serializable before confirmatory
studies for B--F. It may reference the existing fit/calibration identities and
does not require A1; if a later measurement/analysis identity is accepted, it
may reference that identity without embedding it. It never becomes a fitted-model field. The first slice closes one real bounded
decision; it does not attempt to become a general simulation platform or rerun
every historical study. It supplies:

- ADEMP fields and a frozen scenario/comparator/primary-metric grid;
- pilot, freeze, confirmation, and amendment timestamps and hashes;
- deterministic seed/substream allocation independent of method order;
- one terminal status per attempt and an exhaustive accounting identity;
- replicate id, data/DGM hash, replay command, diagnostic record, and explicit
  fallback/hybrid-method identity;
- method-by-scenario planned, attempted, valid, and failure denominators;
- Monte Carlo SE for bias, coverage, failure rate, and pairwise proper-score
  differences; and
- executable known-answer sentinel cells plus staged DGM, estimator-wrapper,
  and metric checks retained with the confirmation record;
- a short RNG smoke test that proves replicate-scoped facet/random/process
  draws are regenerated, while common-random-number objects follow their
  declared scope; and
- a `pass | fail | indeterminate` decision that cannot be changed by silently
  replacing failed runs or choosing another seed/metric.

Execution integrity is an entry requirement, not a later optimization. The
previously nominal future-parallel route now has a distinct execution path and
fixed-ordered-grid serial equivalence tests. Replicate streams for A3 must still
be identity-derived and independent of grid order, method order, and parallel
plan; the current loop-position allocation and `.Random.seed` preservation are
insufficient for confirmatory evidence.

Admission test: a deliberately failing comparator and an undefined metric must
remain in the ledger and alter the declared denominator exactly as specified.
The abstraction is generalized only after a second materially different study
reuses it with lower total burden than separate scripts. Otherwise the compact
ledger remains deliberately specific.

### Portfolio selection gate -- mandatory before every B--F admission

Passing any applicable foundation gate makes research safer; it does not make
any model essential. A1 and A2 are not prerequisites when the registry remains
parked. A3 is required before confirmation, not before problem discovery or a
small deterministic oracle.
Before a B--F option becomes active, its row in
`measurement-model-extension-execution-gates-0.2.4.csv` must record:

- the named user decision and harm or limitation in the current workflow;
- evidence from a realistic data shape rather than a literature example alone;
- the no-build counterfactual and the best current simpler alternative;
- a `build | integrate externally | docs/refusal | park | kill` disposition;
- the one major identity axis changed in the first probe;
- typical-data identifiability, compute, maintenance, migration, documentation,
  support, and independent-review budgets;
- one support profile that success could plausibly authorize; and
- a fixed budget and result that stops, narrows, or kills the lane.

Only one domain feature may be active alongside one horizontal foundation or
evaluation lane. B1 and B2 are not automatically both selected, and B1 has no
priority merely because it is a convenient architecture exercise. An unused
feature slot stays empty. `evidence_ready` work awaiting a decision blocks
admission of another feature; review, not more computation, is then the
bottleneck.

The maturity path begins at `0 · problem-validated`, before `implemented`.
Method qualification is followed by a decision-validated external/field pilot
before public support. Any point may end in `docs_only`, `scope_reduced`,
`parked`, `killed`, or `external_integration`; these are explicit dispositions,
not incomplete checkboxes.

The detailed B--F sections are option cards and test designs. None is active
until the selection gate records `admit`.

### Gate 0 disposition -- 2026-08-27

The first portfolio review compared the three named model extensions with the
closest core-adjacent unfinished capability, portable GPCM calibration. It
used four kinds of evidence:

- the public GitHub repository had zero issues, so it supplied no named user,
  workflow, harm, or decision for any candidate;
- all ten bundled `.rda` data sets contain rating identities and scores, but no
  response-time field, prespecified LLTM/LPCM `A/W` matrix, cumulative-boundary
  study, or real fresh-session GPCM artifact handoff;
- internal tests and synthetic fixtures establish technical possibilities and
  safety boundaries, not product demand or typical-data identification; and
- a current build-versus-integrate check found available external routes:
  `mirt` documents `graded`, `gpcm`, and fixed-calibration workflows; `eRm`
  documents CML LLTM/LPCM; `TAM` documents GPCM, multifaceted parameter-design,
  and fixed-parameter routes; and `LNIRT` jointly analyzes responses and
  response times by MCMC. The checked CRAN package pages were
  <https://CRAN.R-project.org/package=mirt>,
  <https://CRAN.R-project.org/package=eRm>,
  <https://CRAN.R-project.org/package=TAM>, and
  <https://CRAN.R-project.org/package=LNIRT>.

Absence of a public issue is not proof of absence of need. In this review it is
combined with absence of a named internal workflow, a qualifying data packet,
and evidence that package-native work beats the simpler alternative. Anticipated
interest alone does not satisfy those conditions.

| Candidate | Current evidence and no-build route | Lifecycle burden that must be justified | Disposition and exact reopen signal |
| --- | --- | --- | --- |
| Portable GPCM calibration | Bounded GPCM fitting and fitted-object scoring exist; the portable API already gives a typed unsupported result. No real artifact handoff or scale-continuity decision was supplied. | Portable slope-owner identity, anchors, schema migration, fresh-session scoring, version compatibility, diagnostics, and support must close together. | **Parked under the existing G5 optional-lane disposition**, outside the B--F model-extension ledger. Reopen only for a recurring named fresh-session scoring workflow with real source and target data, exact slope-owner/anchor requirements, and a demonstrated gap in fitted-object or external workflows. |
| B1 LLTM/LPCM | No bundled prespecified `A/W` design or new-item decision. Current PCM plus external/post-fit component analysis remains adequate; `eRm` and `TAM` cover mature parameter-design routes. | Row-key and rank contracts, contrast/null-space identity, virtual-item behavior, estimator-specific claims, prediction validation, and user support. | **Parked.** Reopen only with an operation design fixed before outcomes, a typical-data rank audit, a named interpretation or new-item decision, and evidence that integration cannot answer it. |
| B2 one-dimensional GRM | No bundled cumulative-boundary workflow, public issue, or decision comparison against adjacent-category families. `mirt` already provides a maintained GRM route. | A new kernel and derivatives, threshold transformations, estimator/diagnostic/scoring parity, artifact semantics, migration, and support without implying MIRT. | **Parked.** Reopen only when category meaning warrants cumulative boundaries and held-out evidence can show that GRM changes a named decision beyond PCM/bounded GPCM and external `mirt`. |
| D1 joint response time | Existing timing support is deliberately descriptive; timing columns occur only in synthetic QC fixtures. No actor/provenance/missingness-qualified operational data or speed-adjusted decision was supplied. `LNIRT` is a dedicated joint-model route. | Actor and event identity, time units, separate missingness, covariance identification, numerical inference, process outputs, privacy, computation, and support are all new obligations. | **Parked.** Reopen only with event-level operational data, trustworthy actor/time provenance, typed missingness, a decision beyond QC, and an external-integration gap. |

No candidate reached `problem-validated`; zero domain features are admitted.
The relative **discovery** order, if a concrete request arrives, is portable
GPCM first because it is closest to the package north star, then GRM,
LLTM/LPCM, and joint response time. This ordering allocates questions, not code
or release slots. A lower-ranked candidate may reopen first if its evidence is
stronger. Multiple observed scales remains a separate product-discovery
hypothesis and receives no implied admission from this comparison.

### Gate 0.5 GRM--GPCM simulation disposition -- 2026-08-28

The simulation was designed as a falsification-first external comparison, not
as a prototype GRM implementation. It changed one major identity axis only:
the response family. There were no observed facets, additional latent
dimensions, random blocks, response-time processes, mixtures, or portable
artifacts. The prediction target was a new Person's complete item-response
vector, integrating the scalar trait over a fixed standard-normal population.

The independent DGP implements Samejima cumulative differences for GRM and
adjacent-category softmax probabilities for GPCM. It proves exact binary
closure and polytomous non-equivalence before fitting. Both candidate models
were then fitted by `mirt 1.47`; the primary metric was marginal held-out log
score per response. Two fixed numerical integrations, 81 and 161 equally
spaced nodes over `[-6, 6]`, bounded quadrature sensitivity. The seed is derived
from contract, scenario, DGP family, replication, and method identity rather
than loop order. Every dataset-fit attempt has one of six terminal states, and
no failed attempt can leave the denominator.

| Threshold regime | True family | Valid pairs | Matched minus mismatched log score per response | Replication MCSE | Frozen directional result |
| --- | --- | ---: | ---: | ---: | --- |
| compressed | GPCM | 30/30 | 0.0025787153 | 0.0003467614 | matched better |
| compressed | GRM | 30/30 | 0.0011390452 | 0.0002298825 | matched better |
| regular | GPCM | 30/30 | 0.0016411913 | 0.0002480214 | matched better |
| regular | GRM | 30/30 | 0.0010808865 | 0.0002148583 | matched better |

All 240/240 fit attempts were valid; the other terminal-state counts were zero,
all 120 paired comparisons were available, and the largest absolute 81-versus-
161-node mean-score shift was `1.1040169e-10`. The executable design is
`measurement-model-extension-gate05-grm-gpcm-probe-0.2.4.R`; the compact
historical receipt is
`measurement-model-extension-gate05-grm-gpcm-pilot-0.2.4.csv`. The receipt binds
`mirt 1.47` and script SHA-256
`7e52cf064145a95f48cbbf38efeeb22fa60dd4df0106d29ce89f007f069fad8f`.
It is evidence, not a third control surface.

The frozen directional rule classified all four strata as `matched_better`, so
the study disposition is
`geometry_detectable_reopen_problem_discovery_only`. The numerical differences
are small on the metric scale, and no practical threshold was specified before
the run. They therefore cannot be called decision-relevant. The next admissible
B2 action is to find one real ordinal workflow whose category semantics are
cumulative, then compare external GRM and the current adjacent-family route on
representative de-identified data with an action-linked metric. Writing a GRM
kernel, registry, artifact, or public constructor remains prohibited.

### B2 bundled-data eligibility disposition -- 2026-08-28

The first problem-discovery action was an eligibility audit, not another fit.
It accounted for all ten packaged `.rda` objects. Nine contain scores and one is
a score-free assignment roster; all ten are explicitly synthetic. The three
current teaching datasets were generated from adjacent-category RSM
probabilities. The six legacy `ej2021` score objects reproduce published design
shapes but have no retained DGP and cannot establish cumulative geometry. The
two combined objects also lack a reviewed cross-study linking identity.

Every object contains repeated Person-by-Criterion cells: the score-bearing
tables have one to four Raters per such cell, while the roster declares two.
A plain external GRM item matrix would therefore require an unapproved change
of estimand. Averaging and rounding, majority voting, retaining a first or
latest rating, or treating each Rater-by-Criterion combination as an item were
all refused. Those operations would erase or redefine rater severity; they do
not turn an observed facet into a latent dimension or supply a multifacet GRM.
Numeric ordered categories likewise do not establish an owner-confirmed
cumulative-boundary interpretation.

The executable audit
`measurement-model-extension-b2-data-eligibility-0.2.4.R` and its ten-row
receipt `measurement-model-extension-b2-data-eligibility-0.2.4.csv` therefore
record zero eligible objects and zero model fits. The disposition is
`no_eligible_bundled_problem_packet_external_intake_required`; B2 stays parked.
This is a successful fail-closed result, not missing simulation coverage.

One external packet may enter sensitivity analysis only after all of the
following are supplied before looking at model rankings:

- a workflow owner, named decision, and action if the result changes;
- a representative de-identified response table with stable Person, Rater,
  Criterion/item, occasion if relevant, and response identities;
- category labels, order, direction, and an explicit cumulative-boundary
  interpretation rather than integer ordering alone;
- a prespecified repeated-rating/facet policy that preserves the intended
  estimand, plus missingness and split-unit policies;
- a proper metric, practical decision threshold, and current adjacent-family
  workaround; and
- the concrete question that external `mirt` integration cannot answer.

Until that packet exists, the next B2 action is external intake only. A new
simulation grid, a GRM kernel, a generic multifacet composition, or convenient
aggregation of the bundled ratings would be local optimization without problem
evidence.

### B1. LLTM/LPCM parameter-design research slice

Start with PCM and a known full-rank design over nonreference item-category
cells. Keep the response kernel and latent dimension fixed. Required reductions:

- saturated design equals current PCM;
- an RSM design equals current RSM;
- column permutations and valid contrast changes preserve likelihood;
- rank deficiency, duplicate intercepts, missing row keys, and unknown target
  coordinates fail before fitting; and
- unpresented virtual items contribute no likelihood.

Use an independent direct matrix oracle and finite-difference/AD derivatives.
Evaluate correct and misspecified designs, sparse and dense designs, virtual
items, incomplete presentation, global fit, and new-item prediction. Include a
known frequency-band item feature and cumulative-band overlap fixture: the
feature may enter `A/W`, but neither the number of bands nor overlapping
1K--5K score summaries changes the response family or `D`. Add CML
as a separate estimator slice if and only if the package will claim the
Fischer estimators rather than only the linear restriction.

### B2. One-dimensional GRM research slice

If later admitted after real-data problem discovery, implement a cumulative
kernel with ordered-threshold transforms, positive
discrimination, and logit first; probit is a separately identified link.
Initially allow one content trait and only the simplest fixed additive facet
location structure. Do not add cross-classified random effects, mixtures, or
MIRT in the same slice.

Required algebraic gates:

- all probabilities are finite, nonnegative, and sum to one;
- cumulative boundaries and category differences agree with an independent
  Samejima-form oracle;
- ordered thresholds remain ordered after every parameter transformation;
- the binary case reduces to 2PL;
- extreme-theta limits select the correct end categories;
- analytic gradients agree with an independent numerical derivative; and
- a polytomous fixture proves non-equivalence to GPCM.

Recovery covers category count, discrimination, boundary separation, rare end
categories, skewed latent distributions, and local-dependence misspecification.

### C1. Predictive-unit contract

Before cluster-aware LOO or stacking, define the prediction task explicitly:

- `unit = event | person | item | rater | class | occasion | target | bundle`
  (including a declared compound unit when more than one new entity is held
  out);
- the rows removed together;
- `new_entities`, `condition_on`, and the exact latent/random effects integrated;
- category/scale map and missingness identity; and
- candidate-model comparability signature, proper primary score, and criterion
  Monte Carlo uncertainty.

Event-wise log likelihood must be rejected, not silently accepted, when the
claim is new-rater or new-bundle prediction. Current frequentist fits should
use refit or independently defined marginal predictive scores. PSIS-LOO names
and diagnostics are reserved for routes with appropriate posterior draws and
unit-wise marginalized likelihoods.

A one-fit IWLS or influence approximation may be studied only after the exact
holdout grouping is fixed. Its admission test compares score values, model
ranking, singular-covariance behavior, and elapsed cost with explicit refits;
success for same-person observation holdout does not authorize new-person or
crossed new-entity prediction. Any reuse of full-data fixed effects or random-
effect covariance remains visible in the analysis identity rather than being
labeled exact LOO.

Required oracles include same-person response holdout, new-person, new-rater,
new-item, and at least one crossed new-entity combination. Each CV split is
compared with an independently generated future sample from the same prediction
regime. Log score is primary for full category distributions; multicategory
Brier/RPS and accuracy are secondary diagnostics. A ranking inside its MCSE is
`indeterminate`, not a win.

### C2. Dependence-aware resampling and inference

Separate model random effects from sampling, assignment, and resampling units.
Implement no “automatic multiway” default. Start with an internal resampling
plan compiler and small direct covariance/weight oracles:

- one-way person clustering exactly reproduces the current observed-data
  resampling behavior;
- two-way inclusion--exclusion enumerates `G`, `H`, and `G:H` contributions and
  reports non-PSD estimates rather than concealing them;
- pigeonhole/product reweighting is labeled conditional on the observed
  incidence mask and reports its conservatism conditions;
- separate versus joint exchangeability, the axes tending to infinity, any
  fixed axis, and excluded serial/spatial dependence are explicit assumptions;
- adaptive/bootstrap selector, studentization, multiplier moments, and the
  conservative-near-degeneracy policy are part of the result identity;
- assignment-unit and nonassignment crossed effects are separate inputs; and
- few-cluster, dominant-level, sparse-cell, highest-order-interaction, and
  missing-incidence cases are prespecified negative controls.

Acceptance is decision-specific: coverage, Type-I error, interval width,
failure rate, and model-selection regret are compared with an oracle across the
declared dependence regime. A multiway method is not promoted merely because a
crossed facet appears in `MeasurementSpecV2`.

The test grid includes no-cluster, additive, nonseparable pairwise-uncorrelated,
local-to-zero, fixed-axis, sparse-incidence, and two-versus-three-way negative
controls. Uniform validity is never inferred from good pointwise performance;
conservative size accompanied by unusable interval width is not recorded as a
win.

### D1. Base joint response-time process

Keep `response_time_review()` descriptive. Add any likelihood under a new
process specification. The first research model uses an already qualified
RSM/PCM accuracy kernel, one content ability, one speed variable, and a
lognormal time model. It requires:

- `time_column`, `time_actor`, event/item key, and time unit;
- separate response and time missingness indicators;
- location/scale identification for time intensity and speed;
- positive time precision and an SPD ability-speed covariance; and
- process outputs that cannot be mistaken for descriptive QC flags.

Required reductions include zero ability-speed covariance to the factorized
second-level model and unit conversion that shifts only time intensity. Person
and rater time actors need different simulation designs; a rater-time claim
requires crossed/linking stress cases. GPCM and GRM plug-ins receive their own
recovery gates after the base process passes.

The base slice treats response/time missingness explicitly but does not yet
claim nonignorable omission modeling. Only after D1 and the E1 event graph pass
may a bounded survival-process probe distinguish response, omission, and
not-reached events. Its first oracle represents NRI as right censoring and OI
as a competing response/omission clock, with fixed item order and a declared
test limit. Reductions to response-only, response-plus-time, NRI-only, and
OI-only mechanisms, plus misspecified-missingness negative controls, are
required before any joint model can affect ability reporting.

### D2. Rater-bundle local-dependence slice

Require a true bundle identifier and construct a joint pattern likelihood.
Check joint-probability normalization, rater-order permutation invariance,
`kappa=0` reduction, rater-pair graph connectedness, and unbalanced/partial
bundles. The primary decision metric is whether uncertainty and reliability
calibration improve when dependence is present without unacceptable loss when
it is absent.

This work does not reuse additive `facet_interactions` as the dependence
parameter.

### D3. Cross-classified random-effects slice

Create typed random blocks for the two or more owner units, separate from fixed
facets and content traits. Start with one scalar latent effect per side and
strongly constrained loadings. Required reductions and negative controls:

- random variance zero reduces to the corresponding fixed/base model;
- row and column label permutations preserve likelihood;
- sparse/disconnected incidence fails or returns an explicit weak-information
  status; and
- increasing one side's sample size improves the parameters owned by that side
  in the expected direction.

Do not describe two crossed owners as a two-dimensional ability.

The slice also distinguishes finite observed facets from sampled populations.
Reliability/generalizability calculations declare the target item/rater/cluster
counts and include relevant interaction variances. Structural random-effect
covariances are estimated jointly; correlations among separate EB/EAP/BLUP
point scores are labeled descriptive and never substituted for them.

Estimator qualification is objective-specific. For a binary-probit oracle,
compare the full marginal likelihood, a conditional/pseudolikelihood route, and
the all-row-column composite route on matched parameters. The composite path
must expose its naive/row/column contribution maps, attenuation inversion,
balance/no-dominant-level assumptions, quadrature nodes, and sandwich or
pigeonhole uncertainty. Zero variance, one-sided imbalance, sparse incidence,
dominant owner, nonprobit-link, and ordinal-response cases are reductions or
refusals, not silent reuse of the probit proof.

The attenuation inversion must hard-fail when its variance-ratio denominator
is nonpositive and mark a prespecified near-zero margin as unstable. Quadrature-
node sensitivity and singleton-owner rates are diagnostics. Because the stacked
composite contributions are not a normalized joint likelihood, they cannot be
fed directly to WAIC, PSIS-LOO, or a joint proper predictive score.

### E1. Response-event and process-graph foundation

Represent initial response, review opportunity, change, and final response as
events before fitting answer-change or response-tree models. Build a typed
`ProcessGraphSpec` whose first oracles are deliberately small:

- the two-stage shared-ability transition likelihood equals its direct
  conditional-logistic factorization;
- a three-node `WW/WR/RW/RR` tree produces four normalized leaf probabilities
  equal to manual path products;
- a mixed-format two-step item uses one named ability while preserving separate
  nominal/accuracy node kernels and the exact path-to-score map;
- a hint-use fixture distinguishes an ordinal scoring-rule likelihood from a
  hint-request/conditional-accuracy IRTree and labels hint tendency as a
  process role; its four leaf probabilities must normalize, its response/score
  map must be named and hashed before fitting, and changing that map is a new
  model identity rather than a recode;
- nonreached nodes contribute probability one and carry `structural_missing`,
  not ordinary `NA`;
- unknown opportunity is distinct from confirmed unchanged response;
- node/category reversal and process-axis sign changes preserve probability
  after their documented transformations; and
- aggregate final-only data refuses process-identification claims.

The hint fixture additionally requires label/route permutation oracles and a
zero hint-loading reduction to the declared one-axis submodel. Candidate score
maps and tree constraints are frozen in `EvidenceSpecV1`; the best-fitting map
cannot be selected and then reported as if it were prespecified.

This foundation can later host binary, nominal, PCM, GRM, or time outcomes at
individual nodes. It is not itself a new ordinal response family.

### E2. True MIRT and latent regression

Only after `compute_eta` and integration accept a vector latent state should a
MIRT slice begin. Freeze `D`, named traits, Q/loading map, covariance,
regression, and sign/permutation/rotation constraints. Start with simple
structure and low `D`; dense loadings and high `D` remain experimental.

Required reductions:

- `D=1` equals the qualified one-dimensional family;
- Adams-style `A/B` rank conditions fail before optimization;
- covariance remains SPD;
- equivalent dimension relabeling maps parameters and leaves likelihood
  unchanged;
- true one-dimensional, multidimensional, facet-heterogeneity, interaction,
  and local-dependence generators are separate negative controls; and
- a fitted multidimensional model does not by itself authorize useful
  subscores.

The E1 hint fixture may move to a two-axis state (`substantive_ability` plus
`hint_tendency`) only here, after the nominal-score and IRTree identities pass
separately. Its `D=1`/zero-hint-loading reduction, sign/scale constraints, rare
hint boundary, and score-map freeze remain explicit.

Second-order Laplace, low-dimensional quadrature, and MH-RM must be compared on
matched estimands and retained failure denominators. Support envelopes include
indicators per dimension and loading density, not only `D` and sample size.

### E3. Multivariate outcome, method-factor, and structured-random lanes

These are three bounded probes, not one “multidimensional” feature:

1. mixed outcome families with outcome-specific correlated random effects and
   an explicit conditional-dependence diagnostic;
2. within/between construct and method factors with a reference method and
   CTC(M-1)-style constraints; and
3. factor-analytic random covariance used for compression/persistence, labeled
   `computational_factor` unless a construct argument says otherwise.

Each probe requires scale anchors, covariance PSD, role labels, nested-model
reductions, and low-ICC/small-cluster/boundary simulations. Fixed loading values
must reduce to the corresponding ordinary GLMM. Profile-likelihood uncertainty
must include structured-parameter uncertainty; the naive inner-fit SE is only a
diagnostic. Multiple outcomes or a covariance rank never increments the
substantive `D` field automatically.

The first multivariate-outcome oracle should be deliberately non-IRT: two
log-time outcomes in long form, crossed participant and item random intercepts,
outcome-specific slopes, and covariance at both owner levels plus the residual.
It must recover the equivalent pair of univariate models when every
cross-outcome covariance is fixed to zero. This keeps “two outcomes” separate
from “two content traits” before mixed binary/ordinal/time families are added.
The canonical long representation must agree with an independently assembled
wide-outcome likelihood, owner/outcome relabeling must preserve probability,
and a cross-outcome coefficient contrast must use its fitted covariance
(`var1 + var2 - 2 * cov12`). A separate-fit contrast that drops `cov12` is a
required negative control, not an alternative structural-correlation estimate.
An observed three-test longitudinal fixture likewise keeps `D=0`, shares the
person and lexeme identities across outcomes, and refuses a causal
new-class/generalization claim when the assignment and sampling class are not
declared.

### F1. Response-style and process-mixture slice -- hold

Begin only after the relevant attentive accuracy, RT, missingness, and MIRT
submodels have separate recovery evidence. Stage the model:

1. a fixed-covariate signed middle/extreme step design with explicit odd/even
   category geometry;
2. a person random response-style effect after the fixed design recovers;
3. an ideal-point plus dominance process graph with orientation anchors;
4. the base response-time process;
5. a person-level attentive/careless mixture; and only then
6. multidimensional content traits or event-varying process classes.

Required gates include label-switching constraints, class-prevalence
boundaries, component collapse, RT-separation diagnostics, soft probability
calibration, missing response/time patterns, and complete HMC failure
denominators. The API must never return automatic deletion as the default
decision.

### F2. Treatment-effect and causal-heterogeneity slice -- hold

Do not begin until random-slope/covariance structure, boundary inference,
item-population versus finite-test prediction, and `EvidenceSpecV1` are
qualified independently. The first noncausal algebra probe may add an
item-by-condition random slope, but public names and outputs must not call it a
treatment effect without an assignment/identification contract.

Any causal study must jointly represent person moderation and item sensitivity,
estimate item intercept--slope covariance, declare the response/probability/
score estimand, and refuse person-versus-item separation from aggregate scores.
Recovery includes the exact equivalence example, the person-only and item-only
generators, their cross-bias under misspecification, variance/correlation
boundaries, and treatment/item-label invariance. This work is outside the
measurement-family release path.

## Evidence and acceptance policy

### Deterministic gates

The following are mathematical/software contracts and may use tight,
versioned numerical tolerances after an independent oracle and conditioning
study:

- probability normalization and stable log-sum-exp calculations;
- exact nested-model reductions;
- rank, ordering, simplex, positivity, SPD, and graph checks;
- reference/contrast and label-permutation invariance;
- analytic derivative agreement with independent AD or finite differences;
- unit-conversion invariance; and
- correct grouping and marginalization of predictive likelihoods.

Suggested starting tolerances such as `1e-12` for normalized probability sums,
`1e-10` for small direct likelihood or probability oracles, and `1e-6` for
well-scaled gradient checks are **engineering candidates**, not findings from
the reviewed papers. They must be loosened or tightened only through a recorded
conditioning study, never after viewing a release-gate outcome.

### Finite-sample gates

Every recovery study records:

- the frozen `EvidenceSpecV1` and all planned cells and attempts;
- `attempted = valid + dgm_invalid + fit_error + nonconverged + invalid_draw +
  metric_undefined` (with versioned extensions but no uncategorized deletion);
- conditional-on-valid and failure-inclusive performance when both are useful;
- bias, RMSE, interval coverage, boundary rate, and calibration in coordinates
  meaningful for the model;
- the prediction target and proper primary score for comparative studies;
- Monte Carlo SE or an interval for every release-changing metric, including
  failure rate and pairwise score differences;
- missingness, imbalance, connectivity, category sparsity, and
  misspecification conditions;
- algorithm, starts, integration resolution, hardware, and runtime/memory;
- estimate-versus-SE/outlier and coverage-decomposition diagnostics, plus every
  fallback or hybrid analysis path as a distinct method identity; and
- the user decision that pass, fail, or indeterminate changes.

No reviewed paper supplies a universal mfrmr sample-size rule or release
threshold. The papers' designs are replication anchors and stress cases. An
exploratory pilot must calibrate metrics and Monte Carlo precision; thresholds
are then frozen before confirmation. Pilot draws do not enter confirmation.
A failed cell is never removed from the denominator because a paper did so or
because a different optimizer succeeds, and a confirmatory run is not silently
extended until significance, coverage, or a preferred ranking appears.

### Promotion gate

A slice moves from research to public-supported only when all of the following
agree:

1. model identity, estimand, and non-claims;
2. independent algebraic/oracle evidence;
3. finite-sample recovery including negative controls and failure denominators;
4. estimator and integration support envelope;
5. data-schema, artifact, scoring, prediction, and migration behavior;
6. help, examples, capability matrix, and runtime messages; and
7. an independent method/code review.

Completion of this literature audit satisfies none of these promotion gates by
itself.

## Targeted Zotero re-audit for multivariate G theory and D-SIM-0

On 2026-08-29, seven additional local-library sources were checked against the
then-active D-SIM-0 v3 contract. The machine-readable compact record is
`gtheory-multivariate-zotero-literature-audit-0.2.4.csv`. A subsequent close
review completed text extraction and visual inspection for all 542/542 PDF
pages, including the full 430-page Cronbach monograph and full 14-page Wind
article. It also added seven official R-package PDF manuals/vignettes. The
combined 1,538-page page ledger, document manifest, and synthesis are
`gtheory-measurement-core-page-review-0.2.4.csv`,
`gtheory-measurement-core-page-review-manifest-0.2.4.csv`, and
`gtheory-measurement-core-page-review-0.2.4.md`. They extend rather than
silently rewrite the earlier 57-PDF, 1,366-page snapshot.

The Zotero search also returned three parent records for the same Jiang et al.
(2020) article (`2BQX642B`, `VJJDXAFU`, and `528TN57V`). Traceability uses
`2BQX642B` because it owns the reviewed indexed attachment `SM7KLBUJ`. No
deduplication or other Zotero-library write was performed.

The audit changes the technical roadmap in four places:

1. **Backend eligibility follows covariance design.** Jiang et al. (2020)
   distinguish disjoint condition sets from identical conditions scored across
   fixed dimensions. The implied random and residual covariance blocks differ.
   The current `lme4 2.0.6` manual corrects the older blanket claim about random
   structures: it now documents `us`, `diag`, `cs`, and `ar1` random-effect
   covariance. Its level-1 residual, however, remains one scale times a known
   diagonal inverse-weight matrix. D-SIM-0 therefore keeps `glmmTMB` as the
   conditional general primary route and permits `lme4` only as sensitivity
   evidence when every random block maps to a supported structure and no
   estimated linked cross-stratum residual covariance is required. Neither
   backend is universally eligible: D-SIM-1 now binds covariance design,
   nonredundant residual identity, and route eligibility for each canonical
   fixture. The current C1 candidate is narrower still: it estimates
   unstructured cross-stratum covariance for Object, Rater, and Object:Rater,
   but only one homoskedastic scalar residual independent across rows. That
   matched `lme4`--`glmmTMB` overlap is not a complete canonical multivariate-G
   design. It remains only a design-specific sensitivity route where the
   observation-event map implies a diagonal residual block; otherwise the DGM
   and fitter need a custom covariance contract rather than a tolerance
   adjustment.
2. **Policy weights and effective weights are different objects.** Jiang et
   al. (2020) and Vispoel et al. (2023) distinguish nominal weights expressing
   substantive importance from effective weights describing the realized
   variance-covariance contribution. Only externally fixed nominal weights can
   be decision-bearing in v3. Effective and data-optimized weights are
   diagnostics or separately contracted exploratory sensitivities, never
   post-outcome replacements for the policy vector.
3. **G theory and MFRM are complementary rather than competing votes.** Wind,
   Jones, and Grajeda (2023) show that G theory is suited to variance and design
   dependability, while MFR more directly exposes individual severity,
   centrality, and bias. Sparse designs require sufficient connectivity and
   can reduce diagnostic sensitivity. A future MFRM audit is consequently a
   nondecision diagnostic with its own connectivity gate; it does not vote
   with the G/Phi routes or substitute for them.
4. **Facet, fixed stratum, response family, and latent dimension remain
   orthogonal identities.** Muraki's GPCM application uses one latent ability.
   Uto's multidimensional generalized MFRM adds an explicit person ability
   vector and item-by-dimension discriminations alongside rater and rubric
   parameters, plus location, scale, and exchangeable-dimension constraints.
   Jiang et al. (2024) further shows that mixed response formats require their
   own families, links, and covariance decomposition. Multiple facets or
   multiple G-theory strata therefore do not authorize MIRT, and adding GPCM
   or GRM does not itself add a latent dimension.

These corrections deliberately do not open another model implementation lane.
Under the v4 package-capability contract, D-SIM-1 has now completed the
deterministic binding of covariance/event design, algebraic closure, and route
eligibility. It did not wait for an operational owner packet and does not make
an operational recommendation. D-SIM-2 subsequently completed one nonreserved
shared-rater/distinct-event fixture from generator through lme4 REML, nonvoting
G/Phi metric plumbing, terminal-state accounting, and exact replay. It did not
compare truth, targets, or backends. D-SIM-3 then froze 21 outcome-blind design
cells covering 44/44 levels and 603/603 feasible dataset-axis pairs with zero
generated datasets. Its separate execution contract subsequently froze 42
dataset attempts, 210 route units, 420 nonvoting coordinates, and an isolated
855 seed band without opening it. The following pre-execution audit retained
18/37 reusable generator primitives but found 0/21 complete profiles, 0/50
candidate routes, 0/13 terminal states, and 0/5 resource scopes with exact
D-SIM-3 bindings. A shared 22-rule design compiler subsequently qualified
21/21 profiles over nine axes and 147,948 structural row identities without
RNG or responses. The following shared layers qualified covariance/distribution
binding, 21/21 nonreserved shadow generations, 50/50 shared-dataset route
admissions, and all 13 terminal semantics. Current accounting retains 181
exactly-once terminal receipts and correctly leaves 92 open units at zero;
admission is not terminal. The bounded dependency is now the five-scope
resource controller, not another model family or scenario patch.
A Bayesian mixed-format model, multidimensional generalized MFRM, or joint
ordinal G-theory implementation remains a separately admitted future
programme.

### R-package-manual implications

The official manuals sharpen the build-versus-integrate boundary:

- `glmmTMB 1.1.14` documents the random-block structures, dispersion control,
  diagnostics, and simulation mechanics needed for a candidate mG encoding,
  but it does not supply the statistical observation-event identity;
- archived `gtheory 0.1.2` fits strata separately and obtains between-stratum
  observed-score covariance, so it is not a joint component-covariance oracle;
- `mirt 1.47` is the primary maintained external oracle for GPCM/GRM response
  kernels, latent dimensions, explanatory/random-effect IRT, and mixed-family
  simulation, while keeping those specifications distinct;
- `TAM 4.3-25` explicitly says item slopes cannot be estimated directly in
  faceted `tam.mml.mfr` designs; its documented workaround requires a
  pre-specified design or staged `tam.mml.2pl` route; and
- `brms 2.23.0` is a candidate external Bayesian prototype for ordinal,
  mixed-format, and response-time work, but true residual correlation is
  limited to multivariate Gaussian/Student models and shared group effects are
  not a general residual-correlation substitute.

Consequently, the long-term order is covariance/event identity and D-SIM
qualification first; then, only after a named real workflow reopens a lane,
unidimensional GPCM external-oracle identity, a separate GRM kernel, LLTM/LPCM
parameter design, response-time event/process modeling, and finally an
explicitly identified multidimensional generalized MFRM. This is a dependency
order, not a feature or release queue.

On 2026-08-30, the first dependency was converted from prose to a fail-closed
v3 contract input. The owner packet now has 13 rather than 12 inputs: input 9
binds S2/S3 condition incidence, observation-event linkage, and
methodologist-confirmed Object, Rater, and Object:Rater structure mappings.
The route qualifier admits `lme4` only for a diagonal level-1 residual with
supported random structures, admits `glmmTMB` conditionally for diagonal or
unstructured event blocks using nonredundant dispersion, and sends any
explicit condition/event mask or unsupported random structure to
`custom_contract_required`. The historical v3 candidate remains 0/13 and every
qualification row keeps execution false. V4 permits D-SIM-1 deterministic work,
and that work now passes all seven criteria with 39 unique evidence rows and
43 criterion-to-evidence assignments over five canonical designs. It still
does not authorize planned response generation, planned-seed access,
confirmation, or a public support claim.

The contract also derives a 21-row adjudication plan without multiplying the
scientific decisions. Rows 1--13 are the existing owner inputs; rows 14--21
only expose the two observation-event and six random-block subtasks already
contained in input 9. The plan fixes phase order, decision authority, evidence
provider, confirmation role, exact blocking dependencies, recommended
predecessors, unsupported-design disposition, and downstream estimand/backend
effect. All 21 rows are currently unready, cannot be resolved using simulation
outcomes, and keep execution false. They remain an applied decision-project
surface, not an active prerequisite for package D-SIM-1, D-SIM-2, or D-SIM-3
coverage-design work.

Phase 1 repository evidence has now been separated from owner evidence. The
public `mfrm_generalizability()` and `mfrm_d_study()` surfaces establish that
univariate `G` and `Phi` computations and sensitivity projections exist; their
vignette examples and tests establish software behavior only. V2 supplies a
stronger historical technical candidate for ABS-PHI and retains G as a
secondary sensitivity, but it explicitly withholds owner confirmation and
execution. No repository item names a real multivariate workflow, owner, or
consequence for either family. The Phase 1 dossier therefore leaves both
enablement values missing and provides a separate blank two-row owner response
surface. It also corrects the public example ordering to `Phi <= G` under the
implemented nonnegative main-effect decomposition. This correction changes no
estimand, threshold, readiness state, or simulation authority.

Phase 1 now has an upstream admission gate so that “no operational use” is not
misclassified as missing data. The continuing v3 typed packet still correctly
requires at least one enabled family. Before that packet is constructed, the
gate distinguishes unresolved evidence, at least one fully evidenced enabled
use that may advance only to Phase 2 evidence collection, and two fully
evidenced disable decisions that terminate the study without a v3 packet. A
terminal stop is not D-SIM-0 satisfaction; it makes D-SIM unnecessary. Neither
the advance nor stop branch authorizes response generation, fitting, planned
seed access, or public support.

On 2026-08-30, the responsibility scale was corrected again. The v4
package-capability contract supersedes this Phase 1 path for package
development. A general R package does not choose a user's target, workflow, or
action consequence. It must instead validate the definitions and numerical
behavior of both `ABS-PHI` and `REL-G` over a broad, nonadaptive design
multiverse. The v3 owner-response, packet, adjudication, and sign-off artifacts
remain historical provenance and optional project templates. They no longer
block either estimand, the completed D-SIM-1 qualification, or later
exploratory package validation. D-SIM-1 passed seven of seven criteria with 39
unique evidence rows and 43 criterion-to-evidence assignments over
`U1-CLOSURE`, `S2-DISJOINT-DISTINCT`,
`S2-SHARED-LINKED`, `S3-PARTIAL-MIXED`, and the disconnected negative
control. It generated no stochastic response, performed no fit, and accessed
no planned seed. V4 therefore remains at the specification maturity level;
simulation validation, reference validation, and stable public support remain
closed.

D-SIM-2 later closed the next plumbing dependency with one 720-row
nonreserved fixture and one lme4 REML route. The terminal state was
`plumbing_complete_nonpromoting`, and an exact replay preserved generation,
fit, metric, and run identities. The exercised C1 intersection has shared
raters but distinct response events and a diagonal level-1 residual; it is not
evidence for linked residuals. The observed G/Phi values are interface outputs,
not recovery or target evidence. D-SIM-3 subsequently froze 21 outcome-blind
design cells covering 44/44 declared levels and 603/603 feasible dataset-axis
pairs, while generating zero datasets. G/Phi and route rows are shared-dataset
projections, not scenario multiplication. Its separate exploratory contract
then bound seeds, replication, terminal accounting, and resources without
opening them. A nonexecuting qualification audit subsequently showed that
legacy assets do not supply an exact common profile/route/receipt/resource
binding. The first common compiler layer now qualifies typed design semantics
for 21/21 profiles. The second shared layer now qualifies the three variance/
covariance/distribution axes through 84/84 PSD component factors and 21/21
response-kernel contracts, without treating the ordinal aggregate as an IRT
model. Response generation subsequently qualified for 21/21 profiles on
nonreserved shadow streams, including 84/84 unit-to-effective covariance
identities and nine
outcome-independent fixed-count MCAR masks. Planned 855 RNG streams remain
closed. A successor layer subsequently qualified 50/50 shared-dataset route
admissions and all 13 terminal semantics, with 181 currently terminal units at
exactly one receipt and 92 open units at zero. The five-scope resource
controller remains the last shared-substrate dependency before any 855
execution is reconsidered.

## Version and portfolio boundaries

- **0.2.4:** no new model, field, score, likelihood, exclusion rule, or public
  claim from this roadmap.
- **0.2.5 multiple observed scales:** remains a product-discovery hypothesis.
  `ScaleId` is orthogonal to latent dimension and must not be used as a covert
  MIRT implementation.
- **post-0.2.4 research:** A1 is parked after its admission audit and A2 is a
  conditional hold. A3 opens only for a named confirmatory study and may use
  existing identities. None is an admission prerequisite for B--F problem
  discovery or a small deterministic oracle. C1/C2 may be selected as
  horizontal evaluation infrastructure, but cannot change a support claim
  before applicable parity and evidence gates close. Extension WIP is at most one horizontal foundation/evaluation
  lane plus one explicitly admitted domain feature; an empty slot is not a
  problem to solve.
- **main package versus integration:** general-purpose MIRT, multivariate mixed
  modeling, multiway inference, process graphs, mixtures, and causal analysis
  remain external-integration or companion-research candidates by default.
  Package-native implementation requires the portfolio gate to show core
  adjacency and lower lifecycle cost than integration.
- **release numbering:** assigned only after a slice reaches a decision-ready
  promotion review; this record does not pre-allocate GRM, LLTM, RT, or MIRT to
  a version.

## Immediate internal queue

1. run the smallest read-only D4-S006 root-cause audit, separating point-center
   error, interval calibration, truth/operator identity, and response-family
   mismatch without fitting a new model; **completed:** the ordinal 0--4
   observed-score fit was compared with pre-threshold latent truth;
2. keep the 0.2.4 release path independent and remove internal execution prose
   from public NEWS, help, vignettes, and examples; **verified:** the existing
   public-boundary test passes, the public-surface scan returns no internal
   execution terms, and a temporary source-tarball `R CMD check --no-manual`
   completes with zero errors or warnings. A dirty-tree local
   `--as-cran --run-donttest` preflight also completes with zero errors and
   warnings; its two noncandidate notes are the `0.2.4.9000` development
   version and host-created `xcrun_db` detritus;
3. retain the A1 No-Go, A2 conditional hold, and parked GPCM/GRM/LLTM/RT/MIRT
   lanes; do not use available implementation work to manufacture demand;
4. retain continuous observed-score G theory as the narrow candidate envelope
   and keep ordinal dependability parked until a real problem packet chooses
   observed-score versus latent truth; only then consider an axis-separating
   exploratory bridge; **clarified:** the existing G-study and D-study objects,
   print methods, and help now identify their estimand scale as
   `observed_numeric_score`, without changing the estimator or admitting an
   ordinal latent route;
5. accept at most one realistic external problem packet for post-0.2.4
   discovery, with no production implementation or generic simulation grid;
   and
6. require a new versioned contract and disjoint seed namespace before any
   revised estimator or interval can receive new confirmation evidence.

## References reviewed

### Initial model-identity set (311 pages)

- Adams, R. J., Wilson, M., & Wang, W.-C. (1997). The multidimensional random
  coefficients multinomial logit model. *Applied Psychological Measurement,
  21*, 1--23. <https://doi.org/10.1177/0146621697211001>
- Andersson, B., & Xin, T. (2021). Estimation of latent regression item response
  theory models using a second-order Laplace approximation. *Journal of
  Educational and Behavioral Statistics, 46*, 244--265.
  <https://doi.org/10.3102/1076998620945199>
- Bee, R. M., & Koch, T. (2026). Predictive model evaluation in Bayesian mixture
  and hierarchical models for ordinal data: A teaching evaluation case study.
  *Journal of Educational and Behavioral Statistics*, advance online
  publication. <https://doi.org/10.3102/10769986261422706>
- Fischer, G. H. (1973). The linear logistic test model as an instrument in
  educational research. *Acta Psychologica, 37*, 359--374.
  <https://doi.org/10.1016/0001-6918(73)90003-6>
- Fischer, G. H., & Ponocny, I. (1994). An extension of the partial credit model
  with an application to the measurement of change. *Psychometrika, 59*,
  177--192. <https://doi.org/10.1007/BF02295182>
- Huang, S., & Cai, L. (2024). Cross-classified item response theory modeling
  with an application to student evaluation of teaching. *Journal of
  Educational and Behavioral Statistics, 49*, 311--341.
  <https://doi.org/10.3102/10769986231193351>
- Samejima, F. (1969). *Estimation of latent ability using a response pattern of
  graded scores*. Psychometric Monograph No. 17.
- Ulitzsch, E., Pohl, S., Khorramdel, L., Kroehne, U., & von Davier, M. (2024).
  Using response times for joint modeling of careless responding and attentive
  response styles. *Journal of Educational and Behavioral Statistics, 49*,
  173--206. <https://doi.org/10.3102/10769986231173607>
- van der Linden, W. J. (2007). A hierarchical framework for modeling speed and
  accuracy on test items. *Psychometrika, 72*, 287--308.
  <https://doi.org/10.1007/s11336-006-1478-z>
- Wilson, M., & Hoskens, M. (2001). The rater bundle model. *Journal of
  Educational and Behavioral Statistics, 26*, 283--306.
  <https://doi.org/10.3102/10769986026003283>

### Targeted multivariate-G-theory re-audit set (542/542 attached pages)

- Cronbach, L. J., Gleser, G. C., Nanda, H., & Rajaratnam, N. (1972). *The
  dependability of behavioral measurements: Theory of generalizability for
  scores and profiles*. Wiley. All 430 PDF pages received text and visual
  review; the multivariate, profile, and composite chapters received targeted
  close reading as recorded in the page ledger.
- Jiang, Z., Ouyang, J., Shi, D., Shi, D., Zhang, J., Xu, L., & Cai, F. (2024).
  Customizing Bayesian multivariate generalizability theory to mixed-format
  tests. *Behavior Research Methods, 56*, 8080--8090.
  <https://doi.org/10.3758/s13428-024-02472-7>
- Jiang, Z., Raymond, M., Shi, D., & DiStefano, C. (2020). Using a linear
  mixed-effect model framework to estimate multivariate generalizability theory
  parameters in R. *Behavior Research Methods, 52*, 2383--2393.
  <https://doi.org/10.3758/s13428-020-01399-z>
- Muraki, E. (1992). A generalized partial credit model: Application of an EM
  algorithm. *Applied Psychological Measurement, 16*, 159--176.
  <https://doi.org/10.1177/014662169201600206>
- Uto, M. (2021). A multidimensional generalized many-facet Rasch model for
  rubric-based performance assessment. *Behaviormetrika, 48*, 425--457.
  <https://doi.org/10.1007/s41237-021-00144-w>
- Vispoel, W. P., Lee, H., Hong, H., & Chen, T. (2023). Applying multivariate
  generalizability theory to psychological assessments. *Psychological
  Methods*. Advance online publication.
  <https://doi.org/10.1037/met0000606>
- Wind, S. A., Jones, E., & Grajeda, S. (2023). Does sparseness matter?
  Examining the use of generalizability theory and many-facet Rasch measurement
  in sparse rating designs. *Applied Psychological Measurement, 47*, 351--364.
  <https://doi.org/10.1177/01466216231182148>

### Additional architecture and evidence set (813 pages)

- Agogo, G. O., Murphy, T. E., McAvay, G. J., & Allore, H. G. (2019). Joint
  modeling of concurrent binary outcomes in a longitudinal observational study
  using inverse probability of treatment weighting for treatment effect
  estimation. *Annals of Epidemiology, 35*, 53--58.
  <https://doi.org/10.1016/j.annepidem.2019.04.008>
- Bakshy, E., & Eckles, D. (2013). Uncertainty in online experiments with
  dependent data: An evaluation of bootstrap methods. *Proceedings of KDD '13*,
  1303--1311. <https://doi.org/10.1145/2487575.2488218>
- Broatch, J., & Lohr, S. (2012). Multidimensional assessment of value added by
  teachers to real-world outcomes. *Journal of Educational and Behavioral
  Statistics, 37*, 256--277. <https://doi.org/10.3102/1076998610396900>
- Cameron, A. C., Gelbach, J. B., & Miller, D. L. (2011). Robust inference with
  multiway clustering. *Journal of Business & Economic Statistics, 29*,
  238--249. <https://doi.org/10.1198/jbes.2010.07136>
- Chan, J. C. K., & McDermott, K. B. (2007). The testing effect in recognition
  memory: A dual process account. *Journal of Experimental Psychology: Learning,
  Memory, and Cognition, 33*, 431--437.
  <https://doi.org/10.1037/0278-7393.33.2.431>
- Gilbert, J. B., Himmelsbach, Z., Miratrix, L. W., Ho, A. D., & Domingue,
  B. W. (2025). Item-level heterogeneity in value added models: Implications for
  reliability, cross-study comparability, and effect sizes. *Journal of
  Educational and Behavioral Statistics*, advance online publication.
  <https://doi.org/10.3102/10769986251393339>
- Gilbert, J. B., Miratrix, L. W., Joshi, M., & Domingue, B. W. (2025).
  Disentangling person-dependent and item-dependent causal effects: Applications
  of item response theory to the estimation of treatment effect heterogeneity.
  *Journal of Educational and Behavioral Statistics, 50*, 72--101.
  <https://doi.org/10.3102/10769986241240085>
- Gilbert, J. B., Kim, J. S., & Miratrix, L. W. (2023). Modeling item-level
  heterogeneous treatment effects with the explanatory item response model.
  *Journal of Educational and Behavioral Statistics, 48*, 889--913.
  <https://doi.org/10.3102/10769986231171710>
- Gneiting, T., & Raftery, A. E. (2007). Strictly proper scoring rules,
  prediction, and estimation. *Journal of the American Statistical Association,
  102*, 359--378. <https://doi.org/10.1198/016214506000001437>
- Gueorguieva, R. (2001). A multivariate generalized linear mixed model for
  joint modelling of clustered outcomes in the exponential family. *Statistical
  Modelling, 1*, 177--193. <https://doi.org/10.1177/1471082X0100100302>
- Hoffman, L., & Rovine, M. J. (2007). Multilevel models for the experimental
  psychologist: Foundations and illustrative examples. *Behavior Research
  Methods, 39*, 101--117. <https://doi.org/10.3758/BF03192848>
- Hui, B., Godfroid, A., & Elgort, I. (2025). A construct validation study of
  time-sensitive word-knowledge measures. *Applied Linguistics*, amaf037,
  1--25. <https://doi.org/10.1093/applin/amaf037>
- Jeon, M., & Rabe-Hesketh, S. (2012). Profile-likelihood approach for
  estimating generalized linear mixed models with factor structures. *Journal
  of Educational and Behavioral Statistics, 37*, 518--542.
  <https://doi.org/10.3102/1076998611417628>
- Jeon, M., De Boeck, P., & van der Linden, W. J. (2017). Modeling answer change
  behavior: An application of a generalized item response tree model. *Journal
  of Educational and Behavioral Statistics, 42*, 467--490.
  <https://doi.org/10.3102/1076998616688015>
- Jin, K.-Y., Wu, Y.-J., & Chen, H.-F. (2022). A new multiprocess IRT model with
  ideal points for Likert-type items. *Journal of Educational and Behavioral
  Statistics, 47*, 297--321. <https://doi.org/10.3102/10769986211057160>
- Koch, T., Schultze, M., Burrus, J., Roberts, R. D., & Eid, M. (2015). A
  multilevel CFA-MTMM model for nested structurally different methods. *Journal
  of Educational and Behavioral Statistics, 40*, 477--510.
  <https://doi.org/10.3102/1076998615606109>
- Leckie, G. (2018). Avoiding bias when estimating the consistency and stability
  of value-added school effects. *Journal of Educational and Behavioral
  Statistics, 43*, 440--468. <https://doi.org/10.3102/1076998618755351>
- MacKinnon, J. G., Nielsen, M. Ø., & Webb, M. D. (2021). Wild bootstrap and
  asymptotic inference with multiway clustering. *Journal of Business &
  Economic Statistics, 39*, 505--519.
  <https://doi.org/10.1080/07350015.2019.1677473>
- Merkle, E. C., Furr, D., & Rabe-Hesketh, S. (2019). Bayesian comparison of
  latent variable models: Conditional versus marginal likelihoods.
  *Psychometrika, 84*, 802--829. <https://doi.org/10.1007/s11336-019-09679-0>
- Owen, A. B. (2007). The pigeonhole bootstrap. *The Annals of Applied
  Statistics, 1*, 386--411. <https://doi.org/10.1214/07-AOAS122>
- Owen, A. B., & Eckles, D. (2012). Bootstrapping data arrays of arbitrary
  order. *The Annals of Applied Statistics, 6*, 895--927.
  <https://doi.org/10.1214/12-AOAS547>
- Pawel, S., Bartoš, F., Siepe, B. S., & Lohmann, A. (2026). Handling
  missingness, failures, and non-convergence in simulation studies: A review of
  current practices and recommendations. *The American Statistician, 80*,
  31--48. <https://doi.org/10.1080/00031305.2025.2540002>
- Pawel, S., Kook, L., & Reeve, K. (2024). Pitfalls and potentials in simulation
  studies: Questionable research practices in comparative simulation studies
  allow for spurious claims of superiority of any method. *Biometrical Journal,
  66*, Article 2200091. <https://doi.org/10.1002/bimj.202200091>
- Quené, H., & van den Bergh, H. (2008). Examples of mixed-effects modeling with
  crossed random effects and with binomial data. *Journal of Memory and
  Language, 59*, 413--425. <https://doi.org/10.1016/j.jml.2008.02.002>
- Rabinowicz, A., & Rosset, S. (2022). Cross-validation for correlated data.
  *Journal of the American Statistical Association, 117*, 718--731.
  <https://doi.org/10.1080/01621459.2020.1801451>
- Rasbash, J., & Goldstein, H. (1994). Efficient analysis of mixed hierarchical
  and cross-classified random structures using a multilevel model. *Journal of
  Educational and Behavioral Statistics, 19*, 337--350.
  <https://doi.org/10.3102/10769986019004337>
- Raudenbush, S. W. (1993). A crossed random effects model for unbalanced data
  with applications in cross-sectional and longitudinal research. *Journal of
  Educational Statistics, 18*, 321--349.
  <https://doi.org/10.3102/10769986018004321>
- Siepe, B. S., Bartoš, F., Morris, T. P., Boulesteix, A.-L., Heck, D. W., &
  Pawel, S. (2024). Simulation studies for methodological research in
  psychology: A standardized template for planning, preregistration, and
  reporting. *Psychological Methods*, advance online publication.
  <https://doi.org/10.1037/met0000695>
- Skrondal, A., & Rabe-Hesketh, S. (2009). Prediction in multilevel generalized
  linear models. *Journal of the Royal Statistical Society: Series A, 172*,
  659--687. <https://doi.org/10.1111/j.1467-985X.2009.00587.x>
- Stenhaug, B. A., & Domingue, B. W. (2022). Predictive fit metrics for item
  response models. *Applied Psychological Measurement, 46*, 136--155.
  <https://doi.org/10.1177/01466216211066603>
- Tutz, G., & Berger, M. (2016). Response styles in rating scales: Simultaneous
  modeling of content-related effects and the tendency to middle or extreme
  categories. *Journal of Educational and Behavioral Statistics, 41*,
  239--268. <https://doi.org/10.3102/1076998616636850>
- van der Linden, W. J., & Jeon, M. (2012). Modeling answer changes on test
  items. *Journal of Educational and Behavioral Statistics, 37*, 180--199.
  <https://doi.org/10.3102/1076998610396899>
- Van den Noortgate, W., De Boeck, P., & Meulders, M. (2003).
  Cross-classification multilevel logistic models in psychometrics. *Journal of
  Educational and Behavioral Statistics, 28*, 369--386.
  <https://doi.org/10.3102/10769986028004369>
- Vaughan, R. D., & Begg, M. D. (1999). Methods for the analysis of pair-matched
  binary data from school-based intervention studies. *Journal of Educational
  and Behavioral Statistics, 24*, 367--383.
  <https://doi.org/10.3102/10769986024004367>
- Wagler, A. E. (2014). Confidence intervals for assessing heterogeneity in
  generalized linear mixed models. *Journal of Educational and Behavioral
  Statistics, 39*, 167--179. <https://doi.org/10.3102/1076998614529159>

### Snapshot extension (242 pages)

- Alarcon, G. M., Lee, M. A., & Johnson, D. (2023). A Monte Carlo study of
  IRTree models' ability to recover item parameters. *Frontiers in Psychology,
  14*, Article 1003756. <https://doi.org/10.3389/fpsyg.2023.1003756>
- Aliyar, M., Siyanova-Chanturia, A., & Skalicky, S. (2026). Reading versus
  listening: Which one is more effective for incidental vocabulary learning?
  *The Modern Language Journal, 110*, 6--30.
  <https://doi.org/10.1111/modl.70029>
- Bellio, R., Ghosh, S., Owen, A. B., & Varin, C. (2025). Consistent and
  scalable composite likelihood estimation of probit models with crossed
  random effects. *Biometrika, 112*(3), Article asaf037.
  <https://doi.org/10.1093/biomet/asaf037>
- Bolsinova, M., Deonovic, B., Arieli-Attali, M., Settles, B., Hagiwara, M., &
  Maris, G. (2022). Measurement of ability in adaptive learning and assessment
  systems when learners use on-demand hints. *Applied Psychological
  Measurement, 46*, 219--235. <https://doi.org/10.1177/01466216221084208>
- Braun, J., Sabanés Bové, D., & Held, L. (2014). Choice of generalized linear
  mixed models using predictive crossvalidation. *Computational Statistics &
  Data Analysis, 75*, 190--202. <https://doi.org/10.1016/j.csda.2014.02.008>
- Guo, J., Xu, X., & Zhang, S. (2025). Jointly modeling omitted and not-reached
  items in time-limit tests: A survival analysis approach. *Journal of
  Educational and Behavioral Statistics*, advance online publication.
  <https://doi.org/10.3102/10769986251380892>
- Hui, B. (2019). Analyzing processing time data in applied linguistics and
  second language research: A multivariate mixed-effects approach. *Journal of
  Research Design and Statistics in Linguistics and Communication Science,
  5*(1--2), 189--207. <https://doi.org/10.1558/jrds.39117>
- Menzel, K. (2021). Bootstrap with cluster-dependence in two or more
  dimensions. *Econometrica, 89*, 2143--2188.
  <https://doi.org/10.3982/ECTA15383>
- Robles-García, P., Shin, J.-Y., Stewart, J., & McLean, S. (2026). Do modality
  and frequency matter in predicting reading proficiency from vocabulary
  knowledge? A comparison of meaning recognition and meaning recall. *Journal
  of English for Academic Purposes, 81*, Article 101667.
  <https://doi.org/10.1016/j.jeap.2026.101667>
- Tibaldi, F. S., Verbeke, G., Molenberghs, G., Renard, D., Van Den Noortgate,
  W., & De Boeck, P. (2007). Conditional mixed models with crossed random
  effects. *British Journal of Mathematical and Statistical Psychology, 60*,
  351--365. <https://doi.org/10.1348/000711006X110562>
- Wei, J., Cai, Y., & Tu, D. (2023). A mixed sequential IRT model for
  mixed-format items. *Applied Psychological Measurement, 47*, 259--274.
  <https://doi.org/10.1177/01466216231165302>
- White, I. R., Pham, T. M., Quartagno, M., & Morris, T. P. (2024). How to check
  a simulation study. *International Journal of Epidemiology, 53*(1), Article
  dyad134. <https://doi.org/10.1093/ije/dyad134>

## Non-claims

This record does not claim that:

- the current bounded GPCM is a full generalized MFRM or MIRT;
- a future family is identified merely because it can be optimized;
- GRM thresholds can be converted from PCM/GPCM steps without a model change;
- observed facets, crossed owners, process variables, or integration nodes are
  substantive dimensions;
- multiple outcomes, method factors, random-covariance rank, or item-level
  heterogeneity are substantive dimensions without an explicit construct and
  loading map;
- fitting crossed random effects automatically validates a multiway SE,
  bootstrap, CV split, or new-entity prediction target;
- EAP/BLUP score correlations estimate structural latent/random-effect
  correlations;
- an item-by-condition random slope is a causal effect without an assignment
  and estimand contract;
- timing flags diagnose careless responding or justify deletion;
- a paper's reported simulation success is a package release gate; or
- any proposed constructor name is a stable public API.
