# mfrmr internal development and validation roadmap

Status: authoritative maintainer execution plan for integrated 0.2.4,
updated 2026-09-30. Repository-only; excluded by `.Rbuildignore`.

This file owns current sequencing, completion criteria and evidence decisions.
[ROADMAP](../../ROADMAP.md) owns reader-facing direction and support boundaries;
help and NEWS describe actual behavior. Update current status here in place.
Dated validation records preserve evidence, not competing queues of next tasks.
The [older internal plan](internal-roadmap-0.2.3.md) is historical.
The previous expanded roadmap is preserved at development commit `7f4f530c`
(`git show 7f4f530c:ROADMAP.md`); its dated protocols and restrictions are not
silently discarded or treated as new work.

## Purpose, scope and work discipline

The target remains **integrated 0.2.4**, currently labelled `0.2.4.9000`.
Three pillars must advance together:

1. Generalized many-facet measurement: appropriate estimation and interpretation
   of ability, facet locations, category use and discrimination.
2. Multivariate observed-score G/D studies: dependable planning for criterion
   and composite scores under supported assessment designs.
3. Rater feedback and assessment decisions: understandable diagnostics,
   recipient-appropriate reports and reproducible calibration reuse.

Educational performance assessment is the reference use; a substantively
different application/design checks generality. Renaming columns alone does
not establish applicability to music, clinical assessment or judged sport.
Features, clustering and assigned-score MI support these pillars. They do not
supply a fourth independent model-development queue or a common reliability
coefficient linking incompatible estimands.

Preserve the user's order: **finish implemented workflows → establish
statistical support → complete agreed model extensions → integrate as 0.2.4**.
Inference and output contracts constrain one another; necessary API/help work
continues while statistical work proceeds. Do not wait for every research
question before fixing an incorrect label, probability or saved result.

Joint-slope GMFRM and corrected JML remain agreed unfinished work. Formal JML
inference cannot be marked complete by exposing RootSE, nor can a promised
consumer be replaced with a generic warning. Required outcomes must be
completed or their change explicitly decided with the user. This does not
require every existing method to support every model: each supported or
unavailable operation needs a defensible target and a clear reason.

Do not start a new simulation because the last one finished. A new task needs
a named user outcome, the decision it can change, existing evidence to reuse,
a bounded check and an exit condition. Counts of functions, tests, figures or
commits are not progress measures. No overall percentage is calculated from
heterogeneous milestones; report completed outcomes and remaining blockers.

## Source and evidence identity

| Layer | Current meaning |
| --- | --- |
| Development checkpoint `7f4f530c` | Accumulated package code, help, tests and validation records through September 30. Two-family and corrected-JML statistical support remains unfinished. This is not a release freeze. |
| This roadmap revision | Documentation/priority reconciliation after that checkpoint; no estimator, numerical default, simulation or acceptance threshold changes. |
| Prior development `08a5ee9b` | Recorded five-environment CI for that source. It does not qualify the accumulated checkpoint. Remote status was not refreshed for this reconciliation. |
| Historical rc.6 | Preserve source/tags/assets and their evidence. Never retag it or reuse its platform/Win-builder checks as evidence for newer source. |
| September 27 local archive | Its packaging, installed replay and manual/tutorial evidence is retained in the claim ledger. Later changes require their own affected checks and final assembled-source qualification. |

Evidence is attached to source, data, model, estimator, target and control
settings. A repaired calculation retains the earlier failed result and a
reason for invalidating only affected evidence. A matched replay is not an
independent confirmation. RDS replay is not portable calibration. Local `main`
and a clean worktree are not evidence of a push, hosted CI or publication.

Workspace reconciliation on 2026-09-30 corrected `../README.md`,
`../releases/README.md` and `../release-candidates/README.md`: the active tree
is `development/` on `main`; published CRAN is 0.2.3.1 (August 25); its earlier
rejection remains a historical event, not its final status. These indexes are
outside the package Git repository and are maintained in place. Remote
`ls-remote` verified main at `08a5ee9b` and development/0.2.4 at `9020ca2a`;
the latter is a historical branch, not the current source authority. Ahead/
behind numbers are snapshots, not permanent branch labels.

The missing `/private/tmp/...icc-candidate-20260921` registration was pruned.
The clean `~/mfrmr-pr6` and saved site-edit worktrees were removed normally after
checking tracked, untracked and ignored files. Commits `532d59e7`, `2b12b82f`
and `4df7e072` remain referenced by their existing branch/remote refs. Only the
active development worktree remains. No branch was reset, deleted or merged.

## Current delivery and remaining decisions

| Outcome | Implemented scope | Required closure or explicit decision |
| --- | --- | --- |
| RSM/PCM and one-family GPCM | Existing RSM/PCM routes; MML separate slope/step owners; scoped inference/comparison and profiles; portable MML and scoped JML EAP. One-family GPCM EM falls back to direct. | Preserve actual engine, scale, prior, anchor and conditional-uncertainty identity in all supported consumers. Keep adverse coverage findings. Do not infer single-family EM from two-family EM. |
| Two-family GMFRM fitting | Explicit ordered owners, fixed N(0,1), MML--EM, common fit class, arbitrary column names, no anchors, unit weights, exactly two non-Person facets. | Finish target-specific statistical admission and consumer decisions; local rank and numerical agreement do not establish global identification or sampling performance. |
| Two-family outputs | Summary/print; conditional category/information curves without intervals; experimental component Wald/profile intervals; descriptive same-data posterior response diagnostics; plot/report/export/reopen. | Location/curve intervals, ordinary fit/bias/Q3/PCA, Wright/Pathway, model ranking/LRT, new-Person/portable scoring and individual sheets remain open or unsupported. For each, specify the target and required implementation/evidence or an explicit release-scope decision; do not inherit support from the shared fit class. |
| Corrected JML | Shared-owner explicit-order adjusted-equation estimator, matching local full-Jacobian covariance, point/distribution output, conditional residuals, new-Person EAP and portable format 5. | Resolve residual-bias treatment and formal inferential scope. No validated automatic order selector, structural CIs, corrected Person ML/WLE, corrected RSM/PCM, anchors or separate-owner corrected JML. Keep a valid point if covariance fails. |
| Multivariate G/D studies | One/two random facets, crossed or Child-within-Parent with Persons crossed; ANOVA/MINQUE(0); composites/differences; complete future plans; 2D plots; prespecified crossed normal-theory paired-delta intervals. | Complete the existing data-to-plan-to-report route with metric-specific availability, raw covariance estimates, score units, explicit future counts and cost assumptions. General fixed/nested structures, unequal future rosters and a joint latent GMFRM/G model are not implemented. |
| Individual feedback | Native additive RSM/PCM sheets, recipient privacy, exposure/reference, category use and unexpected-rating review. | Retain this usable route; decide model-aware GMFRM reporting/sheet scope explicitly. Severity, slope, misfit and feature groups must not become competence or training-effect claims. |
| Dependence models | Separate shared-rater and Person-local testlet RSM fitting/scoring and descriptive comparisons, with limited uncertainty. | Preserve sharing units and conditional/new-unit populations. Use matched ordinary-RSM comparisons. Ordinary fit cutoffs, zero-variance LRTs and Person-only robust SEs do not automatically transfer. |
| Features and missing scores | PAM/hierarchical/PCA/k-means, setting and imputation comparisons, assigned-response review/fitting/eligible pooling. | Preserve IDs, coding/scaling, roster, observed scores and pooling target in saved outputs. No filling unassigned ratings, inferential group effects, extended-model MI or pooled Person scores by implication. |
| Beginner/API consistency | Existing guides, recommended aliases, saved objects and accessible plotting foundation. | One recommended route per task; explicit omitted/NULL/default meanings and actual plotted values; compatible old calls; no internal execution language in help/NEWS. Author review is not novice participant evidence. |

## Integration milestones and exit conditions

These D identifiers are the only release-level checkpoints. Older repeated
G2/D2 labels in historical records do not close these milestones.

| Milestone | Status | Reviewable exit condition |
| --- | --- | --- |
| D0 — Evidence identity | Reconciled on 2026-09-30 after correcting workspace records; repeat before freeze | Source and scope of each result, workspace indexes, active branch, retained worktrees and actual published baseline agree. Local, committed, archived and published states are distinct. |
| D1 — Statistical support | Open | Fix each retained estimator/interval/diagnostic procedure and failure policy; evaluate the specific claim; resolve joint-slope and corrected-JML decisions. Report adverse and unavailable outcomes. Apply the dated escalation rule below before an over-budget study starts and while a conclusion is still unresolved. No universal coverage or capacity guarantee is required or claimed. |
| D2 — Complete delivered workflows | Open | Supported fit → summary/uncertainty → meaningful plot/diagnostic → report/export → reopen/scoring paths agree on model, owner, scale, population and uncertainty. Existing G/D, features/MI and RSM/PCM feedback stay on the regression path. Unsupported routes have explicit tested reasons. Close the task-to-function acceptance table below against the installed guide, help, examples and saved replay; export counts are not acceptance evidence. |
| D3 — Freeze scope and source | Not reached | Required D1/D2 outcomes are closed or changed by explicit agreement. DESCRIPTION, capability tables, help, examples, NEWS, README and version metadata agree. Produce one identified submission-quality archive without changing old tags. Retain a complete phase-timed local check and a demonstrated optimization plan against the 600-second check budget; an unmeasured or over-budget source does not close D3. |
| D4 — Validate and integrate that source | Not reached for current scope | Run affected integration and package checks; fix failures; verify matching main integration, five-environment CI, installed/site examples, URLs, reverse dependencies and Windows results. Require matching Windows check time below 600 seconds, separated from installation, and a supported/missing optional-dependency matrix with no unexplained feature skips. Reuse source-identical evidence; no routine repeated whole-suite or numerical studies after small edits. |
| D5 — Publish and maintain | Not reached for current scope | Matching source/documentation/assets are published under applicable authorization. Record GitHub release, CRAN submission and acceptance separately; retain regression witnesses and migration information. |

Local completion requires implementation/decisions through D3 and applicable
local checks of the identified archive. Publication completion additionally
requires matching hosted and release evidence. A clean development checkpoint
closes neither endpoint. Stop the release cycle at its agreed endpoint, not
when all long-term research has been attempted.

## CRAN check-time budget: release prerequisite (D3/D4)

The retained August 25 incoming-pretest notification for 0.2.3.1 explicitly
reports `Overall checktime 12 min > 10 min`. Treat **600 seconds for the check
itself** as this package's submission ceiling, with a **480-second local target**
to leave headroom. Installation and build times are reported separately.
The [CRAN policy](https://cran.r-project.org/web/packages/policies.html) requests
minimal CPU use and feature coverage in retained checks; its public text does
not state a universal 600-second rule. The concrete threshold is supported by
this package's actual rejection. A previously accepted package or an `OK`
status above 600 seconds is not permission for another over-budget submission.

Retained observations, not measurements of the current development source:

| Source / environment | Install | Check | Static R-code analysis | Examples | Tests | Vignette rebuild | PDF / HTML manual |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 0.2.3.1 incoming Windows, August 25 | separate | 701 s | 270 s | 82 s | 41 s | not separately timed | 45 / 38 s |
| rc.6 Win-builder R-release, September 26 | 128 s | 1,538 s | 309 s | 82 s | about 780 s (`13m`) | 27 s | 68 / 127 s |
| rc.6 Win-builder R-devel, September 26 | 133 s | 1,587 s | 356 s | 81 s | about 780 s (`13m`) | 26 s | 68 / 51 s |

Phase labels are rounded service timings; their sum need not equal the
notification total. Logs are in `validation-results/cran-preflight-20260926/`
under `winbuilder-R-release/` and `winbuilder-R-devel/`; notifications and
archive attribution remain in the [claim ledger](claim-reconciliation-0.2.4.md).
The older rejection evidence is in the workspace's
`release-candidates/cran-submission/2026-08-25/pretest-rejection-0.2.3.1/`.

The freshly retrieved [CRAN check page](https://cran.r-project.org/web/checks/check_results_mfrmr.html),
updated 2026-09-30 00:56 CEST, shows 0.2.3.1 r-devel Windows installation
107 s, check **638 s**, total **745 s**. Do not label 745 s as check-only time.
The [package page](https://cran.r-project.org/package=mfrmr) confirms version
0.2.3.1 published on 2026-08-25. Browser-search caches can show older checks;
verify the page's timestamp and version when refreshing this record. The
retrieved HTML and HTTP headers are retained under
`validation-results/roadmap-prerequisites-20260930/`.

The retained 0.2.3 archive has 147,801 lines in 81 R files; the development
checkpoint has 177,616 lines in 139 R files (about 20% more, including comments
and roxygen). This flags a measurement need, not a linear timing law: loaded
function/AST complexity, repeated analysis, R/codetools versions and hardware
matter. The rc.6 test phase alone exceeded 600 seconds, so static-analysis
optimization by itself cannot solve the observed problem.

Provisional phase allocations for the 480-second local target are: static
analysis 180 s, examples 45 s, tests 120 s, vignette rebuild 30 s, PDF/HTML
manuals together 60 s, remaining check phases 45 s. These are planning budgets,
not achieved results or independent acceptance thresholds; reallocate from
measured evidence while retaining the overall ceiling and headroom.

Required deliverable: one source/command/environment-bound timing table for
static analysis, examples, tests, vignette rebuilding, PDF/HTML manual and
other check overhead, plus install/build/check totals, CPU/elapsed distinction,
R/codetools/optional-package versions, thread settings and actual skips. Use the
built tarball with normal CRAN examples/tests/vignettes/manuals enabled and
`NOT_CRAN=false`; a `--no-tests`, `--no-examples`, `--no-manual` or partial check
cannot close this requirement. Record `--run-donttest` as a distinct additional
profile if used; do not silently change the comparison workload.

Optimization sequence: reuse old logs → time the selected installed-package
tests by file with supported optional dependencies → remove repeated expensive
fitting from presentation/compatibility checks using valid synthetic fixtures,
while retaining small real estimation/uncertainty checks for every supported
feature → move genuinely long sampling/refit studies to the explicit complete
CI tier → profile measured static-analysis/manual bottlenecks and simplify
only proven duplication → rerun changed phases → run one assembled full check.
The September 30 runtime pass added the existing GMFRM EM/public-workflow and
corrected-JML public-workflow files to the CRAN selector after measuring them
with dependencies present. D2/D4 must still map all admitted features to an
exercised small check. Do not disable code analysis, hide failures,
remove all coverage of an optional model or use extra cores to evade the budget.

D3 needs measured source-matched local results and an evidence-backed path to
600 seconds on Windows. D4 needs actual matching Windows results below that
ceiling; a local 480-second result is not a cross-platform guarantee. If the
ceiling cannot be met, report the measured bottleneck and ask for a concrete
scope/engineering decision before submission. Any CRAN exception requires
explicit correspondence; it must not be inferred from 0.2.3.1 acceptance.

## Next work: one ordered queue

### 0. Close the check-time measurement gap before another broad study (D0/D3)

Workspace identity is reconciled. The [September 30 runtime record](cran-check-time-20260930.md)
now identifies an installed baseline, measured repeated-calibration and
planning-table costs, targeted repairs, added model checks and the subsequent
archive-bound phase profile. The complete command took 468.66 s including a
rounded 27-second installation; check-only time is approximately 442 s, below
the provisional local 480-second target. The test phase took 230 s with 4,930
passes. Its undeclared-test-dependency warning was repaired through DESCRIPTION
and the matching dependency check; a second complete check is not claimed.
The metadata-only successor archive preserves all other 795 files. Use this
evidence to select targeted static/manual profiling or a current-source Windows
timing run; a Mac result cannot predict that ceiling. Do not repeat the same
full run after metadata-only repairs or start
another broad statistical study instead. This prerequisite proceeds separately
from unresolved D1 methods. Local timing does not close the Windows ceiling
or qualify the unfinished statistical scope.

The next Windows measurement uses the existing check runner's `cran-timing`
profile and a Windows-only manual workflow dispatch, with manuals enabled and
RTMB >= 2.0/nleqslv present. The shared timing decision now requires the whole
check minus installation, including rounding uncertainty; the earlier
examples/tests/vignettes-only rule was insufficient. Its partial-log success
must not be reused. See the runtime record for the corrected regression and
the eight unchanged repository scope/prose failures that still require D2
reconciliation. A successful package timing run will not close those concerns.

### 1. Fix the inferential procedure and unresolved consumer decisions (D1/D2)

The first deliverable is a prespecified decision protocol for the revised
two-family inference procedure, accompanied by an operation-by-model review
of the remaining consumers in the scope table. Reuse current classes and the
existing numerical witnesses. Do not create another wrapper or start a broad
coverage grid before this protocol and its computation plan are reviewable.

The protocol must identify component/scale targets, model/Wald versus explicit
profile roles, optimizer starts and restarts, integration-refinement policy,
source and endpoint failures, boundary handling, estimands and practical
acceptance criteria. Source-fit and profile iteration budgets are distinct.
A grid increase is an explicit refit; all triggered retries and their cost
belong to the evaluated procedure. Do not select favorable targets or discard
unavailable intervals after looking at results.

Determine which missing consumers need only a correct existing target and
which require new inference. Descriptive report/plot repairs proceed without
waiting for interval qualification. New-Person scoring, portable calibration,
individual sheets, maps and inferential diagnostics each need an explicit
contract; neither ordinary-model reuse nor relabelling is sufficient.

Exit: the procedure, sample-size/precision rationale, failure accounting and
consumer decisions are fixed before new independent evaluation. Unresolved
release commitments remain visible; a narrow experiment cannot close them.

**Decision deadline:** report the evaluation plan's compute and elapsed-time
estimate when the plan is ready. If its expected interpretable result would
fall after **2026-10-02 18:00 JST**, consult the user before launching it; if D1
is still unresolved at that checkpoint, present the evidence, remaining cost
and concrete options for continued work or an explicit scope decision without
waiting for a conclusive result. This is a review date, not a truncation rule
for datasets, an automatic deferral of agreed features, or a promise that a
background reminder has been scheduled. Continue independent G/D, MI, feedback
and release-engineering work. Review earlier if a changed method or a new study
materially exceeds the plan's estimate.

### 2. Resolve statistical claims using existing evidence first (D1)

For joint slopes, numerical identities and retained failure repairs are
already available. Evaluate the revised prespecified procedure on independent
data for the claims retained at release. Include bias, empirical versus
estimated SE, interval width, availability, coverage among returned intervals
and returned-and-covered frequency. Distinguish nonexistence/weak identification,
optimization failure and integration error. Profile-versus-Wald disagreement
is a diagnostic, not proof that profiles are better.

Choose repetitions from Monte Carlo precision and decision consequences, not
a ten-minute cutoff or a desire to obtain significance. Roughly 119 independent
datasets give a 2-percentage-point MCSE for 95% coverage, and 475 give one point
before allowing for unavailable intervals; correlated parameters within one
sample do not increase the independent replication count. These are planning
calculations, not predetermined acceptance thresholds. Estimate cost from the
existing feasibility timings, save resumable jobs and report every planned case.
If the prespecified conclusion is inconclusive, decide whether the claim can
be supported, needs a changed method or needs an explicit scope decision;
do not automatically multiply repetitions or add another factor grid.

For corrected JML, reuse the 200-dataset one-step and 400-dataset order
comparisons. Examine residual bias and order sensitivity against the matching
full-Jacobian covariance. Orders 2/4 reverse MSE preference across examined
settings; neither is an established universal default. Automatic selection
needs an observable rule, retained override/reason and independent evaluation
of the entire selected procedure. External fixed-scoring agreement does not
qualify this new corrected estimator or its structural intervals.

Exit: record a supported claim and its domain, a specific remaining repair,
or an explicit unresolved decision. Do not relabel numerical success as
statistical qualification, or erase valid point estimates when inference fails.

### 3. Finish all three assessment workflows together (D2)

Use the existing educational assessment walkthrough and one substantively
different design to review assignment → model → diagnostic/uncertainty →
recipient feedback and G/D plan comparison → saved report/reopen. Preserve
separate estimands, populations, row selections and score scales. Use existing
features/MI as optional branches, with observed values and pooling assumptions
visible. Do not add an unrelated toy study to every completed function.

Check consequential defaults, unavailable results, generic methods, exact
plot values, non-color cues, title/caption removal, alternative text, individual
privacy and compatibility. Existing aliases and standard R argument names
remain unless a demonstrated usability problem justifies a migration. Do not
mark specialist functions superseded merely because a broader wrapper exists.
Run a realistic reader review when available; absence of participant evidence
must remain explicit rather than described as tested beginner comprehension.

Exit: each admitted user outcome in the scope table is executable and
interpretable end to end, with matching help and NEWS. Unresolved GMFRM/JML
scope cannot disappear when the walkthrough uses only RSM/PCM.

### 4. Freeze, check and publish the integrated source (D3–D5)

Reconcile the supported capability list and version metadata, including the
DESCRIPTION description of multiple slope families, only against the admitted
scope. Build an identified archive. Run integration/package/platform checks
for that source, not inherited historical candidates. Keep check failures and
repairs attributable to their source. Commit, remote integration, CI, site,
release assets, Windows checks and CRAN states are separate verification tasks.
A local cleanup does not trigger external submission or retagging.

## D2 task-to-function acceptance table

This is the reviewable completion artifact, backed by the existing
`mfrmr_output_guide()` and `mfrmr_output_guide("plots")`, not a new guide API.
The current namespace still has 208 exports and 35 `plot_*` names (including
plot-data helpers). Counts do not determine recommendations. For each row,
D2 records: input/result class, model/estimator restrictions, consequential
defaults, recommended entry and alias/specialist role, help/example link,
plot-data/ggplot support, saved replay evidence and unresolved reason. Publish
the applicable mapping through the existing help/guide and pkgdown categories.

| Task | Recommended existing entry / sequence | Acceptance evidence to reconcile |
| --- | --- | --- |
| Review ratings and fit | `describe_mfrm_data()` → `fit_mfrm()` → `summary()` | Workflow help, public-model tests, explicit score scale/roles/defaults |
| Review estimates and uncertainty | `mfrm_results()` with explicitly computed supported intervals; `confint()` where admitted | Output-guide, interval and results tests; model-specific exclusions |
| Choose and customize a figure | `mfrmr_output_guide("plots")` → result `plot()`; `plot_data()` / `as_ggplot()` where supported | Plot-guide and result-class checks; unavailable conversions stated |
| Deliver a report or file bundle | `mfrm_results()` → `mfrm_report()` / `export_mfrm_results()` | Report/export/reopen checks; do not pass the return value of `plot()` as results |
| Give one rater a sheet | `mfrm_report(..., style = "rater")` | `test-rater-feedback.R`; additive RSM/PCM support and privacy |
| Reuse calibration | `extract_mfrm_calibration()` → review/freeze → save/load → `score_mfrm_calibration()` | Portable workflow help and installed replay; estimator/prior/format limits |
| Plan multivariate scores | `mfrm_multivariate_gstudy()` → `mfrm_multivariate_d_study()` → prespecified `mfrm_multivariate_d_compare()` | G/D examples, tables/plots and saved-result tests; source/future design distinction |
| Group mixed features | `mfrm_cluster_pam()` or explicitly hierarchical `mfrm_cluster_hierarchical()` | Feature guide; `mfrm_cluster()` remains a compatible alias, not a new algorithm |
| Explore numeric features | `mfrm_pca()` → `mfrm_cluster_kmeans()` when dimension reduction is intended | Numeric-feature tests; scaling, component retention and original-unit profiles |
| Review and pool missing assigned scores | `review_mfrm_imputations()` → `fit_mfrm_imputed()` → `pool_mfrm_imputed()` | Imputation tests; compatible old review name, eligible cells and pooling targets |
| Use dependence extensions | `fit_mfrm_random_rater()` / `fit_mfrm_testlet()` with model-specific scoring/response routes | Extension tests with dependencies present; conditional versus new-unit targets |

The listed entries have been checked against current exports/source. This is
an initial acceptance map, not a claim that every row has completed a new
end-to-end run. D2 closes only when each admitted model/task combination has
its actual help, example and replay evidence, and unsupported combinations
are explicit. Preserve specialist functions unless their role is truly replaced.

## D4 optional-dependency evidence

A passing check with skips is not evidence that the skipped model ran. Retain
a per-environment matrix of dependency/version, covered route, executed checks,
skips and reasons, linked to the source. At least one supported environment
must execute each admitted optional feature with its dependency present;
platform-dependent compiled routes also need appropriate Windows evidence.
Separately check the missing/too-old dependency message and unaffected core
workflows. Installed-version inspection alone is not feature-test evidence.

| Dependency / feature | Required supported case | Unavailable case / boundary |
| --- | --- | --- |
| RTMB >= 2.0 / shared-rater fitting and inference | Small actual estimation and applicable uncertainty/response checks; retain compiled version/platform | Missing or < 2.0 must give the documented actionable message; do not count skips as success |
| nleqslv / corrected JML | Explicit-order fit and supported scoring/output check | Missing solver must not silently switch estimator |
| cluster / feature clustering; mice / supplied imputation workflows | Exercise the admitted clustering and completion-review routes | No fabricated imputation or clustering when unavailable |
| ggplot2 / conversion; lme4 / optional mixed-model comparisons | Execute supported conversions/comparisons and retain version | Keep native/core behavior and clear unavailable routes |
| Other Suggests in DESCRIPTION | Map each admitted optional route to executed or explicitly inapplicable evidence | Explain skips; do not make all optional software mandatory for core use |

The September 24 Windows check skipped six tests because RTMB was 1.9; the
September 26 rc.6 logs contain five other skips and no old/missing-RTMB skip.
Do not merge those evidence states. The September 30 installed runtime checks
execute shared-rater tests with RTMB 2.0 and corrected-JML fitting/covariance/
replay with nleqslv 3.3.7; see the runtime record for source, results and remaining
checks. Dependency absence/version-error branches and the final Windows
environment remain separate evidence requirements.
These checks belong to the existing five-environment/targeted CI process;
no new service or broad duplicate simulation is required.

## Evidence to reuse and unresolved findings

| Record | Evidence that may be reused | What it does not establish |
| --- | --- | --- |
| [GMFRM algorithm and consumers](gmfrm-mml-em-20260927.md) | Literal equations, scores, EM ascent/direct-MML checks, owner identity, summaries, output and local-information tests. | Global identification, universal sparse support or coverage. sirt comparisons are restricted to an explicit common submodel. |
| [Sparse intervals and numerical repair](gmfrm-sparse-intervals-20260928.md) | 400 original datasets; all 100 common-Person SD=1 fits replayed at 61 nodes; subsequent retained numerical failures and independent likelihood checks. | Same-data refits are not independent confirmation. Task t3 coverage 90/100 after the SD=1 integration repair remains an adverse finding. |
| [Profile feasibility](gmfrm-profile-feasibility-20260929.md) | 80 new datasets / 160 requested component profiles under the original fixed procedure; availability, failure stages and cost. | Not a powered coverage comparison and not confirmation of later repaired procedures. |
| [September 30 repairs](gmfrm-sparse-intervals-20260928.md#2026-09-30-control-sensitivity-weak-slope-search-and-user-documentation) | Matched replay: 43 sources and 45 profiles, originally 43/45 complete; later targeted repairs recovered the remaining optimization/integration cases. | No new all-45 success rate: only affected cases were replayed after the last changes. No established coverage advantage or general boundary solution. |
| [Corrected-JML method](jml-inference-review-20260927.md), [sample comparison](jml-sample-comparison-20260927.md), [order comparison](jml-order-sampling-20260927.md) | Reference equations, fixed/random roster covariance, bias/SE/order results and adverse conditions. | No validated automatic selector or general structural interval. |
| [General-input JML](jml-general-inputs-20260928.md) | Non-prototype numerical checks, explicit-order fit/output/residual/EAP and fresh-process portable replay. | Engineering samples do not establish coverage, unique global roots or absence of residual bias. |
| [Portable MML GPCM](portable-gpcm-20260927.md), [JML GPCM](portable-gpcm-jml-20260927.md), [RSM/PCM JML](portable-jml-20260927.md) | Defined calibration formats, conditional scoring/prior and replay checks. | Conditional intervals omit calibration uncertainty; transport to another population needs its own interpretation. |
| [Claim/evidence ledger](claim-reconciliation-0.2.4.md) and existing G/D, feature/MI, feedback and dependence records | Earlier mathematical/workflow and source-specific package evidence. | Historical present-tense claims do not override this current plan or qualify later source. |

The existing targeted tests are reusable regression witnesses. For this
roadmap/commit task, package loading, 139 R-file and 273 Rd-page parses and
whitespace checks passed at `7f4f530c`; statistical studies and the full suite
were not rerun. Final current-source release checks remain open.
The subsequent roadmap reconciliation passed the existing public-language and
anchor-guidance checks (54 assertions), all local links in both current plans,
and incoming Markdown anchors to the public roadmap. The existing documentation
check now reads this current internal plan; historical checks keep their sources.

## Design and interpretation requirements

Use a question-driven selection, not a Cartesian expansion of all factors:

- **Assignment and links:** complete, all-rater common Persons, rotating or
  connected random panels, weak bridges and disconnected designs answer
  different questions. Match the primary rating budget and retain exposure.
  Connectivity does not establish slope identification. Reuse the existing
  PCM/JML anchor pilot and single-family sparse pilot within their own scope.
- **Anchors:** common Persons are observations, not fixed parameters. Exact
  anchors, perturbed anchors and estimated calibrations with uncertainty have
  different targets. Two-family anchor support is absent; supported-model
  anchor findings cannot be transferred to it.
- **Population:** under two-family fixed N(0,1), transforming
  `theta = mu + sigma*z` leaves first-family slopes unchanged, multiplies
  second-family slopes by sigma, divides locations/steps by sigma and absorbs
  the mean into the free second-family location. Compare to transformed truth.
  Normal SD changes affect targeting/information but are not by themselves
  distributional misspecification. Group-dependent ability, mixtures and skew
  are separate contrasts, selected only for a retained claim.
- **G/D planning:** preserve covariance admissibility and metric-specific
  results. Incomplete source data do not imply unequal future-plan support.
  Prespecified paired normal-theory differences do not support adaptive plan
  selection, nested/robust intervals or informative-missingness correction.
- **Dependence:** distinguish shared rater, Person-local performance/testlet
  and independent units. A nonzero local variance is not proof of halo;
  a zero variance is a boundary. Separate slope heterogeneity from omitted
  dependence before interpreting discrimination or rater feedback.
- **Dimensionality:** substantive structure, residual patterns and matched
  simulation may assess a one-ability assumption. Residual PCA/networks need
  exposure and null-calibration interpretation. A native multidimensional
  fitter is not a prerequisite for all diagnostic work.
- **External comparison:** compare equations, constraints, scale, data,
  population, likelihood and target before comparing numbers. TAM/ConQuest
  fixed-scoring checks and sirt submodel checks do not qualify corrected JML
  or all GMFRM estimators. GENOVA formula comparisons are not software parity.
- **Capacity:** measure an actual bottleneck with relevant Person/facet counts,
  pattern length, time, OS memory and accuracy. A workload result or a data-size
  cap is not a general capacity guarantee.

## Deferred structures and conditions to reopen

These are not a hidden checklist for 0.2.4, and do not defer the agreed
joint-slope/corrected-JML completion work above.

| Candidate | Reopen only when |
| --- | --- |
| Shared-rater interval expansion | A concrete method/numerical change, justified narrower target or feasible computation plan addresses the retained 800-dataset findings. More bootstrap draws alone do not repair unavailable tails. |
| General G-theory, nested intervals or unequal future rosters | A named assessment decision cannot be represented by current plans; define the structure, score/composite, uncertainty target and identification first. |
| Combined shared-rater/testlet effects, random slopes or heterogeneous task variances | A real decision requires them and matched simpler-model comparisons justify the extra structure. Define sharing, integration, identifiability and new-unit prediction together. |
| Broader slope action/families, multidimensional ability, process/mixture models | Constructs, response equations, loading/covariance identification, useful scores, uncertainty and maintenance cost are agreed. Multidimensional work remains explicitly deferred. |
| Portable ML/WLE, latent-regression portability, calibration-aware intervals | A defined scoring target and scale/prior/calibration-uncertainty contract can be validated; portable EAP does not implement these. |
| General diagnostic guarantees or adaptive design/weight selection | The actual decision and error criterion are specified. Finite simulation cannot supply universal guarantees; selected procedures need their own evidence. |

## Maintenance and review rules

After a work package, revise the relevant status row and identify its effect
on D1/D2. If a new study mainly explains the previous study, return to the
user decision before expanding it. Reopen completed work only for changed
behavior, a reproduced failure or a new admitted claim.

Keep internal identifiers, optimizer history, release gates and source hashes
in maintainer material. Public help/NEWS must retain model assumptions,
limitations and actionable numerical guidance without internal chronology.
Preserve independent mathematical checks, failure regression fixtures and
saved-object migration. No extra dashboard or progress artifact is required.
