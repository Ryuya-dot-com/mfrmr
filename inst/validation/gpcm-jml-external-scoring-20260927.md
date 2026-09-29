# GPCM JML: fixed-score external comparison and literature scope

Date: 2026-09-27. Local development evidence, not release qualification.

## Question and comparison target

Do the actual shared-owner JML calibrations qualified by the portable workflow
produce the same fixed-calibration scores in an independent engine? The earlier
TAM/ConQuest comparison used MML source calibrations; it could not directly
answer this question about the new JML artifacts.

The [runner](gpcm-jml-external-scoring-20260927.R) reuses the two unchanged fits
in `validation-results/portable-gpcm-jml-20260927/`: `source.rds` (Criterion
owner) and `rater-source.rds` (Rater owner). Neither training calibration is
refitted. Each is scored under N(0,1) and N(.25,1.2^2), giving four model/prior
conditions. Four synthetic new-Person response patterns cover all-low,
all-high, mixed complete and incomplete known assignments. These are finite
examples, not a recovery, stress or interval-coverage study.

All structural parameters and the prior are held fixed. With theta = mu + sd*z,
the existing TAM map is AXsi[j,k] = a_j * {k*(mu-d_j)-sum(t_jh)} and
B[j,k] = k*sd*a_j. The same generalized-item response functions are supplied
to ConQuest. `tam.mml()` and ConQuest's quadrature command are used only to
evaluate the fixed model, not to reestimate it or turn the JML calibration
into MML. The runner checks returned parameters, category-score loadings and
population settings. Native mfrmr and saved/loaded portable EAP, posterior SD
and continuous endpoints agree within 1e-10; each Person is matched by ID.
The default JML prior remains a post-hoc assumption, not an estimated population.

## TAM: deterministic comparison

TAM 4.3-25 used 121/181 equally spaced nodes on [-9,9]. The declared acceptance
criteria are maximum probability difference < 1e-11, Person log-likelihood
difference < 1e-10, EAP/SD difference < 1e-6, and within-engine scoring-grid
movement < 1e-7. These are numerical tolerances, not statistical guarantees.
Independent adjacent-logit probabilities are compared with TAM's returned
`rprobs`; Person log likelihoods include the same observed response cells.

| Owner | Prior mean / SD | Maximum EAP difference | Maximum SD difference | mfrmr grid movement |
| --- | --- | ---: | ---: | ---: |
| Criterion | 0 / 1 | 1.28e-12 | 1.23e-11 | 9.76e-10 |
| Rater | 0 / 1 | 4.92e-13 | 1.63e-12 | 3.75e-10 |
| Criterion | .25 / 1.2 | 7.17e-12 | 4.81e-11 | 9.98e-9 |
| Rater | .25 / 1.2 | 1.84e-12 | 7.35e-12 | 4.29e-9 |

Maximum probability and log-likelihood discrepancies are 5.56e-16 and
1.71e-13. All four conditions pass. Final mfrmr grids are 141/181 for the
reference prior and 181/241 for sensitivity. They are comparison settings,
not new defaults or universal sufficient quadrature orders.

Adverse results are retained. The first 101/141 reference-prior comparison
failed the 1e-7 stability criterion for Criterion ownership (6.98e-7), even
though the high-grid external score discrepancy was small. The 141/181
sensitivity comparison failed for both owners (3.96e-7 and 2.80e-7). Only
scoring grids were refined; no fitting, prior, response pattern or tolerance
was changed. Completed reference results were reused during sensitivity
refinement. Initial evidence is retained in sibling `*-grid-initial/` and
`sensitivity-initial/` directories.

The first runner also compared whole data-frame attributes, encountering
native/portable table class and vector-name differences despite equal Person
ordering. The comparison now matches IDs and checks the four numeric score
columns explicitly. Its original failure is retained in `*-initial/`; an
attempted rerun correctly refused to overwrite an existing artifact. These
were harness issues, not changed score estimates.

## Local ConQuest: model identity and stochastic scores

The installed `/Applications/ConQuest/ConQuest` was executed outside the
sandbox through `/usr/bin/arch -x86_64`. No remote computation or upload was
used. The executable hash is recorded in the manifest. Each condition was
saved with `put` and reloaded in a separate `get` process. A, structural
parameter indices/values, category scores, population mean and variance are
verified before scoring and after reloading; all four models pass. ConQuest
changes some labels on reloading but preserves those numeric identities.

Four-category sources require two explicit category-support rows, one for
each middle category, so ConQuest does not drop parameters before anchoring.
They are labelled separately, excluded from target comparisons and cannot
alter the fully fixed calibration or prior. The original three-category MML
case retains its one support row. Every target and support ID is checked.

All 4 conditions x 4 target Persons x 2 budgets x 3 seeds = 96 target score
rows were retained. Seeds were 2, 73 and 20260926 at 20,000/200,000 posterior
nodes, reusing the earlier comparison settings. Across all conditions/seeds,
maximum absolute EAP/SD discrepancies were .00686/.00274 at 20,000 nodes and
.00211/.00161 at 200,000 nodes. These are descriptive approximation results;
no deterministic EAP pass threshold or favorable-seed selection is applied.
Three seeds do not establish the full Monte Carlo error distribution.

Probabilities reconstructed from rounded ConQuest exports differ from the
full-precision input by at most 5.40e-7; reconstructed Person log likelihoods
differ by at most 1.58e-5 over the checked grid. These are export-based
reconstructions, not independent exports of ConQuest's internal likelihood
evaluations. The corresponding deterministic EAP/SD rounding effect is at
most 3.45e-7, much smaller than observed stochastic scoring differences.
Posterior interval endpoints were not compared externally.

## Literature: what is and is not supported

The local Zotero API was unavailable (connection refused); semantic search
did not identify the exact paper reliably. No library setting was changed.
The library's attached Bock & Mislevy PDF at storage key `AKBMRMYP` was found
locally. All 14 article pages (431-444; PDF pages 2-15, excluding publisher
cover) were read in sequence using extracted text and rendered page images,
including formulas, tables and figures. The PDF hash is retained locally.

Page-by-page reading roles:

| Article page | Content checked and relevance |
| --- | --- |
| 431 | Motivation; ability scoring assumes supplied response functions. |
| 432 | Posterior means versus modes; multiple-category scoring extension. |
| 433 | Likelihood and quadrature EAP/SD formulas (3)-(6). |
| 434 | One simulated session and its assumed standard-normal prior. |
| 435 | Early-item likelihood/prior/posterior curves. |
| 436 | Later-item curves and growing response information. |
| 437 | Reliability interpretation and simulation assumptions. |
| 438 | Test-length distributions under specified stopping criteria. |
| 439 | Conditional bias; additional fixed-ability simulations. |
| 440 | Table 4: bias and variability vary by ability and precision. |
| 441 | Shrinkage and limits of comparisons across priors/precision. |
| 442 | Extreme-response EAP contrasted with unavailable finite ML. |
| 443 | Conclusions and the connection to an MML E-step. |
| 444 | References; no GPCM JML qualification or numerical-cutoff rule. |

This supports fixed-response-function posterior scoring. It does not establish
the present many-facet JML calibration, its bias, a new cohort's prior, general
coverage, or the package's objective/gradient/condition-number cutoffs. The
paper's adaptive binary-model simulations are not imported as sparse-rating
performance evidence. Its discussion of extremes concerns scoring; it does
not prove that every structural parameter becomes inestimable when a training
Person has an infinite JML estimate. Portable boundary-source refusal remains
a workflow limitation, not that general theorem.

Muraki (1992) remains the GPCM model/EM reference. This increment does not
claim a fresh page-by-page review of Muraki or of formal JML asymptotic and
boundary theory. Those require a separate inference-focused review before
new structural intervals or broad bias guarantees are admitted.

Sources:

- Bock, R. D., & Mislevy, R. J. (1982). Adaptive EAP estimation of ability in a
  microcomputer environment. *Applied Psychological Measurement, 6*, 431-444.
  <https://doi.org/10.1177/014662168200600405>.
- Muraki, E. (1992). A generalized partial credit model: Application of an EM
  algorithm. *Applied Psychological Measurement, 16*, 159-176.
  <https://doi.org/10.1177/014662169201600206>.
- [TAM's JML documentation](https://alexanderrobitzsch.github.io/TAM/reference/tam.jml.html):
  supplied loading matrix, `adj=.3` and `bias=TRUE` defaults. Matching those
  settings is essential when comparing free RSM/PCM JML estimates.
- [ConQuest command reference](https://conquestmanual.acer.org/s4-00.html),
  estimate note 11: JML cannot estimate item scores. Fixed-score comparisons
  do not bypass that limitation or validate free GPCM JML slopes.

## Disposition and retained evidence

Evidence lives under `validation-results/gpcm-jml-external-scoring-20260927/`:
source/script manifests, source-to-portable score pairs, final artifacts, TAM
fits/results, ConQuest command files, console logs, numeric exports, saved
systems and all score rows. The final summary adds the exported-parameter
log-likelihood diagnostic without rerunning ConQuest. Executed-stage and final
script hashes are retained separately rather than silently relabelling them.

The two original MML TAM comparisons were rerun once because their shared
runner changed; their retained metrics reproduce within 1e-14.
The three-category ConQuest input preparation was also replayed without
launching ConQuest: responses, A matrices, anchors and prior files reproduce
the retained MML inputs exactly, and both probability maps pass.
Changed help pages parse/check, and the diff passes whitespace checking. No package
estimator or scoring algorithm was changed in this increment; no whole-suite
rerun or large simulation was necessary.

The scoped direct JML-calibration fixed-score comparison is complete locally.
Help, NEWS and roadmap distinguish scoring literature, package numerical
criteria and free-estimation evidence. JML structural bias/boundary/inference,
general sparse-design coverage, external interval equivalence and assembled
archive/platform qualification remain open. No tag, push or CRAN submission.
