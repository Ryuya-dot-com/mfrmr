# 0.2.4 integrated claim and evidence ledger

Date: 2026-09-24. **The expanded 0.2.4 is complete locally within the retained
release scope; public release remains open.** The original eighteen-group
reconciliation remains historical evidence. This is the successor assessment to the
[September 9 inventory](public-claim-evidence-review-0.2.4.md), under the
[public roadmap](../../ROADMAP.md). It does not broaden API support or replace
the source identities, protocols, failures or results in earlier records.
The subsequent [beginner/help review](#september-24-pre-integration-beginner-and-api-review)
and CRAN preflight are reconciled on the
[successor archive](#follow-through-successor-archive-cran-check-and-targeted-repairs).
It includes the revised help; earlier archives and hosted CI do not qualify its
publication. The failed initial checks and the targeted repairs remain explicit.

Release-plan update, 2026-09-21: 0.2.4 now targets completion of existing
development functions, statistical-support extensions, selected model
extensions, and then integration. The 18-group reconciliation below describes
the earlier baseline; it is not an inventory or approval of the expanded
release. Historical exclusions and candidate checks do not automatically define
its scope. Reconcile new retained claims and their source-specific evidence
before the final integration decision, following the
[current work plan](internal-roadmap-0.2.3.md#current-work-plan).

## September 23: expanded release scope and completion evidence

This is the current inventory for the expanded local 0.2.4, following the
[public release scope](../../ROADMAP.md#focus-for-024) and its
[M0–M6 milestones](../../ROADMAP.md#milestones-and-the-end-of-this-development-cycle).
It extends this ledger in place. The original eighteen-group CSV and the
September 22 A01–A16 disposition remain historical baseline evidence; neither
certifies the later model, uncertainty or diagnostic additions. A local source manifest for integrated verification was frozen on September 24;
the final disposition below now establishes M5 within the retained scope. The inventory distinguishes
the initial scope decision from subsequent implementation and statistical
checkpoints, each with its own source identity and limitations.

| Retained outcome | Evidence available for reuse | Local disposition and remaining limitation | Milestone |
| --- | --- | --- | --- |
| Existing MFRM, portable calibration, anchors/linking and saved-output repairs | The source-specific baseline dispositions below and the published candidate's recorded checks. | Closed locally. The packaged regression, ordinary/portable installed checks and fresh-session replay preserve the supported outputs, restrictions and migration behavior. The final archive has its own identity; earlier CI does not certify publication of this source. | M4/M5, then M6 |
| External-feature and numeric PCA/k-means workflows | Existing clustering/MI comparisons; the numeric workflow checkpoint in the active roadmap and independent transformation/reference checks in `test-numeric-feature-workflows.R`. | Closed locally for descriptive geometry, identity, comparisons and output. Executed tutorial, installed examples, PCA/group replay and colour/shape checks agree; unsupported conversions fail explicitly. The order-dependent PCA test spy is repaired and rechecked. Group validity and best-partition inference are not claimed. | M1/M4/M5 |
| Assigned-score MI and eligible non-Person Rubin pooling | Assignment/category/observed-score protections, independent pooling checks, the [joint RSM example](response-mi-joint-record-0.2.4.md), and the [paired repeated-sampling record](response-mi-coverage-record-0.2.4.md): 200 datasets with MAR/MNAR masks, direct MML/Bayes references and every failure retained. | Closed locally for reviewed supplied completions and eligible fixed-facet inference. The joint-RSM tutorial, source/help, examples and saved output agree. MAR coverage is 96.5% among 198 available intervals, with two unavailable imputers; MNAR coverage is 26.0% with +.574-logit bias. This does not qualify arbitrary imputers/designs, pooled EAPs or exact prior/MML congeniality. | M4/M5 for the bounded workflow; broader qualification outside this evidence |
| One-way fixed-facet sandwich inference | [Derivative checks, bounded comparison and M2 target reconciliation](facet-sandwich-record-0.2.4.md). Current computation/help hashes and public wording were checked without repeating the study. | Closed locally for the one-way working-model target, with executed tutorial and retained output. Generating-truth undercoverage and the distinction from misspecification-bias correction remain explicit. Few-cluster/multiway robustness and general coverage are outside this scope. | M4/M5 |
| Rater-feedback and screening-performance evaluation | [Matched-budget and threshold-stress studies](rater-screening-matched-record-0.2.4.md), including 900 new fixed-protocol fits, 800 reused raw-statistic fits, directional error/detection comparisons and the EAP plug-in reference discrepancy. | Closed locally for mean-square-only descriptive screening, explicit alternative thresholds, sensitivity plots and complete failure denominators. The executed tutorial and replay agree. Heavy-missingness false flags and low contamination sensitivity remain; automatic exclusion and general diagnostic accuracy are not supported. | M1/M2/M4 |
| Multivariate crossed/nested G/D studies and fixed-task planning | Existing ANOVA/MINQUE, composite, nested-design and paired normal-theory interval records below. The fixed-task README/help example now agrees with direct weighted-score analyses for complete/incomplete sources and independent balanced ANOVA. | Closed locally for the supported designs, normal-theory plan comparisons and fixed-task example. Independent weighted-score agreement, installed examples, complete/incomplete saved replay and dedicated plot panels are retained. Arbitrary fixed/random designs and general robust inference remain later work. | M1/M4 |
| Shared-rater RSM | [Initial implementation and pilot](random-rater-record-0.2.4.md), [paired bootstrap comparison](random-rater-interval-record-0.2.4.md), independent joint-likelihood references, the estimated ability-population and joint conditional Person-scoring checkpoints (rater covariance, profile/refits, bootstrap, scoring references and saved reports), the saved-estimate view/accessibility checkpoint (display contracts and offline replay, not diagnostic qualification), and the [crossed-model mapping](extended-model-readiness-review-0.2.4.md#m2-literature-follow-through). | Closed locally for the bounded shared-normal RSM, conditional scoring and descriptive output. The 800-dataset qualification remains inconclusive; automatic individual-rater/calibration bounds are absent and explicit approximations keep their guards. All 53 saved integration failures have separate higher-order repair evidence; 48 scores/96 endpoints and 128 local-likelihood points have bounded independent numerical support. Final installed help, executed tutorial and replay agree. These checks do not qualify general coverage, full profiles or bootstrap intervals. | M2/M3/M4 |
| Person-local testlet RSM | [Fit/scoring/output record](testlet-api-record-0.2.4.md), independent variance-boundary/tensor/continuous-interval checks, [model-aware comparisons and maps](model-maps-record-0.2.4.md), and the task/criterion application tutorial. The [480-dataset estimated-population comparison and numerical repair](testlet-estimated-qualification-record-0.2.4.md) retain all original outcomes plus a separate fourteen-case repair and four unchanged controls. | Closed locally for common-variance non-overlapping testlets, conditional scoring and descriptive output. The 480-dataset comparison retains original failures and a separate fourteen-case start-selection repair; only the two larger balanced conditions have post-repair bounded conditional coverage support. Small/sparse and regular calibration intervals remain inconclusive, and point accuracy does not uniformly improve. Both executed tutorials, installed help, explicit interval controls and replay agree. Task-specific variances and automatic halo diagnosis are not implemented. | M2/M3/M4 |
| Extended-model comparison, Infit/Outfit and Wright/pathway displays | [Literature-to-implementation audit](extended-model-readiness-review-0.2.4.md) and the active M2 checkpoint specify matched events, latent integration, full predictive variance and descriptive residual targets. | Closed locally for aligned events, specified posterior moments/full variances, centered facet/conditional Person comparisons and descriptive maps. Independent numerical checks and final saved reports preserve these targets. Ordinary plug-in cutoffs, formal extended-model DRF/LRT and automatic ranking are not inherited. | M2/M3/M4 |
| Local integration and later publication | Existing static-report/export connections and historical archive/help/source checks supply reusable methods, not current completion evidence. | M5 closed by the final source/archive disposition below. The completed broad suite is reconciled with focused repairs, executed tutorial provenance and a clean final structural/example check. M6 still requires matching five-environment CI, main integration, release assets and published documentation. | M5 local endpoint; M6 public release |

The September 24 entry review resolved the retained implementation and
statistical decisions. The final integration disposition below now closes M1–M5
for those outcomes. M6 remains open. Each closure uses source-specific checks
and the stated statistical boundary; the number of tests is not evidence of
general coverage, diagnostic accuracy or arbitrary-design support.


The subsequent M1 example checkpoint is recorded in the active work plan and
`validation-results/m1-workflows-20260923/`. It closes the fixed-task example
requirement and corrects a missing source of variation in the illustrative
ordinal imputer. It does not close the entire release row or endorse the
imputation model: parameter resampling does not remedy conditional-model
misspecification, and one held-out set cannot establish population bias or
interval coverage. No model-family or release-readiness claim is added.

Explicit later work includes substantive multidimensional MFRM; arbitrary
G-theory structures; general calibration-aware Person/contrast intervals;
few-cluster/multiway and robust/nested G-D inference; formal extended-model
DRF/bias tests; joint shared-rater/testlet, PCM and heterogeneous/correlated
extensions; automatic rater removal or allocation optimization; and extended
Shiny support. Conditional intervals are retained only with their actual
conditioning and qualified scope. Known adverse results cannot be resolved
solely by adding a warning. A required workflow may not be silently moved to
later work to declare M5 complete. Such a change requires an explicit
release-scope decision recorded in the public roadmap and active work plan.

## September 24: saved-output integration

The question was whether each included analysis family can reach its documented
summary, graph and saved result without changing the statistical target or
silently taking an unsupported generic route. Source inspection and a saved-
object replay found and repaired an actual display defect: explicitly selecting
`component = "table"` bypassed conversion restrictions. PCA lost PC2, a pooled
MI result lost both bounds, and a D-study graphed scenario numbers instead of
G/Phi. The original reproductions are retained. Unsupported families now refuse
that route; supported multivariate D-study plots accept `component = "series"`
through their dedicated converter. Unclassified custom tabular payloads keep
the documented generic fallback.

The public routing guide now has `features`, `imputation` and `gtheory` sections,
with dedicated summary/plot/RDS/CSV routes and explicit separation from
`mfrm_results()`. It does not imply plot methods for raw feature reviews,
partition comparisons or G-study component objects. PCA score plots add shared
package colours and point shapes; retained/omitted scree points use filled/open
symbols. Encoding and ID-aligned coordinates are retained, with shape recycling
after six groups stated. No statistical estimate or cluster assignment changed.

Evidence is in `validation-results/workflow-output-integration-20260924/`:

| Workflow | Executed integration check | Limits preserved |
| --- | --- | --- |
| Numeric PCA / external groups | Saved PCA, a direct and reduced-space partition comparison, RDS/CSV summaries and plotted coordinates; public-method routing and monochrome rendering. | Projection and descriptive groups only; no automatic ggplot conversion or pooled labels. Mixed-feature and feature-MI calculations reuse earlier evidence; this is not a new recovery study. |
| Assigned-score MI | Reused the saved joint-RSM pooled example, retaining the full source RDS, summary CSV and interval endpoints. | Eligible fixed-facet Rubin target only; no new imputation, fit or coverage claim. |
| Observed-score G/D study | Reused complete and incomplete fixed-task/sampled-rater results; summaries, exact series, two-panel G/Phi figures and RDS/CSV replay agree. Existing tests retain metric-specific availability, score units and nested counts. | Source incompleteness does not change the future balanced-design interpretation; plan-difference inference has its separate normal/crossed scope. |
| Fixed-facet uncertainty and screening | Saved sandwich, screening-performance and threshold-sensitivity objects preserve summaries, graph data and supported/refused conversions without recomputation. | Working-model target, planned denominators, unresolved outcomes and directional rules remain unchanged. |
| Both extended RSMs | Rebuilt results from previously saved fits with matched scores, comparisons and diagnostics; Person tables and model locations remain identical. Wright/fit-pathway/comparison plots, static reports and archive replay work with fitting/scoring/diagnostic computation blocked. | Current calibration defaults apply without changing Person scores or model assumptions. Descriptive residuals retain no automatic classic fit cutoffs. |

Five focused files pass 749 expectations (routing 106, numeric features 109,
output guide 316, D-study plots 139, existing ggplot routes 79), with zero
failures, warnings or skips in their final runs. The initial new renderer test
mistook points drawn by the score-plot legend for scree points; isolating the
scree capture fixed the test without changing the drawing implementation.
That initial failure is retained separately. Four changed Rd topics are
regenerated, parsed and HTML-rendered. Tutorials, NEWS and README include the
routing and migration changes. PCA colour/monochrome/scree, pooled-MI and
D-study figures were visually inspected for axes, marks, labels and clipping.

This closes the identified output-routing defect and the representative
cross-workflow saved-output pass in M4. It does not declare all M1–M4 closed or
constitute M5: final source/installed-help identity, examples, optional-dependency
behavior and applicable integrated package checks remain. No new simulation,
full-suite run, commit, push or publication was performed. Follow those concrete
integration requirements next; do not reopen bounded coverage studies merely
to add more conditions.

## September 24: installed-workflow integration

The question was whether the expanded workflows remain usable from an installed
source archive, without `pkgload`, development-only helpers or an implicit
refit. The package was built and installed in an isolated temporary library;
each checking process asserted the loaded package path. Source and installed
help agree on all 204 exports and 262 S3 registrations. Code/documentation
argument checks and Rd-content checks pass across 269 help topics. Regenerating
all topics from the source identified exactly two differences:
`fit_mfrm_imputed` and `pool_mfrm_imputed` had been generated without Markdown
processing. Their links and code formatting are now generated correctly from
the package settings, with no change to estimation or pooling.

A separate reproduced failure concerned capability guidance: unsupported PCA,
clustering and interval conversions checked for ggplot2 first. They could tell
a user to install a package that would still not enable that view. The shared
converter now refuses unsupported views first and gives the available base-
plot/plot-data route; supported ggplot conversions retain their dependency check.

Evidence is in `validation-results/installed-workflows-20260924/`:

| Check | Result and scope |
| --- | --- |
| Installed API and generated help | All exports documented, S3 registrations resolve, argument/Rd checks pass, and every generated help topic matches source. The two corrected pages render without literal Markdown markers. |
| Representative help examples | Seventeen installed examples execute without warnings/errors: mixed/numeric/hierarchical groups, feature MI, G/D studies and plan differences, fixed-facet intervals, screening/sensitivity and routing guides. `donttest`/`dontrun` blocks and whole vignettes are not counted as executed here. |
| Preserved ordinary and portable baseline | The existing ordinary RSM/PCM smoke route passes 54 expectations; the portable installed/fresh-process test passes 12, including CSV identities, unavailable facet/category refusals and scoring agreement. These ran on the initial inspection installation; their implementation is unchanged in the final inspection archive. |
| Optional dependencies | Actual installed examples exercise mice/cluster. With namespace availability explicitly mocked to false for ggplot2, cluster, mice and RTMB, numeric PCA/k-means without silhouettes, all 40 shipped assigned-score completions, and saved extended-model tables/normal intervals/base maps/reports still work. PAM/hierarchies/silhouettes, mids import, shared-rater fitting/profiling and supported ggplot conversion give their required-dependency messages. This is simulated absence, not a separate minimal-library installation. No user package was removed. |
| Saved results in a fresh installed process | Nine existing PCA/group/comparison, pooled-MI, complete/incomplete D-study, interval and screening objects preserve summaries/plot data and remain unmodified. Both extended-model public export scripts replay with matching report tables and supported model maps. Fitting/scoring/statistical recomputation is blocked during this check. |
| Focused conversion regressions | 186 expectations pass with no failure, warning or skip: routing 107 and existing ggplot routes 79. The first installed run exposed a new test's implicit `pkgload` dependency; adding its explicit package name fixes the test. That initial failure is retained separately and is not a statistical/package-output failure. |
| Archive boundaries and identity | 626 packaged R/help/native/test/vignette and NEWS/NAMESPACE files match the current source byte for byte. Validation records, internal roadmap, local library and Rplots.pdf are excluded. The archive and file hashes are retained. |

The final inspection archive has SHA256
`bbb2518ef8401a70d9a19903a048dbfb3fcc438d6ff6b4d4e4b46af2d6a00b6f`.
It was built with `--no-build-vignettes --no-manual`. It verifies installation
and the checks above, not the full tutorial build or final integrated package
check. The initial archive and failures remain separate. No numerical study,
full suite, commit, push or publication was repeated/performed.

This closes the installed-workflow checkpoint within M4. The remaining sequence
is to reconcile each retained release outcome with its existing evidence and
explicit restrictions, then freeze one source for M5, build its complete
vignettes/local documentation and run the applicable integrated checks. Do not
reopen bounded coverage studies just because their broader, non-retained claims
remain unqualified. Do not declare M5 or M6 from this inspection archive.

## September 24: entry to final integrated verification

The per-outcome review now resolves the prior generic "complete statistical
qualification" action into the retained claims of the public release scope.
It does not accept a new inferential guarantee or remove an included workflow.

| Retained outcome | Disposition before the integrated check |
| --- | --- |
| Existing MFRM / portable calibration | Preserve the established bounded model/anchor/linking interfaces. The installed ordinary and portable checks pass; the packaged suite must also preserve the earlier ICC, variance-scale, shrinkage and interaction/replay corrections. |
| External features / numeric PCA and k-means | The descriptive feature geometry, per-entity identity, mixed/hierarchical routes, paired imputation comparison and output/refusal contracts have implementation and reference evidence. No group-validity or best-partition inference is claimed. |
| Assigned-score MI | The review/fit/pool workflow and the proper joint-RSM example are implemented. The declared MAR comparison is complete, and adverse MNAR results/failures remain in the tutorial. The retained target is eligible fixed-facet inference under adequate supplied imputations, not arbitrary-imputer or missingness correction. |
| Fixed-facet intervals / rater screening | The one-way sandwich working-model target and observed-versus-generating-parameter distinction are resolved. Mean-square-only screening, explicit alternative thresholds and complete failure denominators have bounded evidence. General diagnostic accuracy, removal rules and multiway robustness are not claimed. |
| G/D studies | Crossed/selected nested components, composites, complete future plans, metric-specific availability and the supported normal-theory plan differences retain their established scope. The fixed-task/sampled-rater example has direct independent agreement. No additional generic design solver is needed for this release scope. |
| Shared-rater / testlet workflows | The estimated-normal-population choice, effect sharing, zero-variance reductions, conditional scoring and declared uncertainty are implemented. The independent posterior/local-likelihood checks and bounded fitted-model comparisons support their specified targets. Failed cases and adverse coverage/point-accuracy results remain recorded. Automatic unqualified calibration/individual-rater bounds have been removed; explicit approximations retain their guards. Full-profile numerical and general coverage qualification are not inferred. |
| Model-aware comparisons / diagnostics / figures | Matched events and population/location conventions, same-data posterior moments/full variances and conditional Person comparisons are implemented and independently checked. Wright/reference-location and descriptive fit-pathway figures retain their units, selected counts and unsupported-inference restrictions. No automatic classical fit bands, formal extended bias test or model-ranking rule is promised. |
| User output / maintenance | Generated help, representative examples, source/installed API identity, dependency boundaries, saved-value replay and user-facing routing have passed their focused integration checks. Full tutorial execution and the final packaged regression/documentation check are the remaining gate. Workload records describe measured configurations and do not claim a universal capacity bound. |

M1/M2 decisions and M3 retained workflows are ready for integrated verification;
this is not M5 completion. M4's remaining whole-tutorial check is included in
that gate. The frozen local snapshot in
`validation-results/final-integration-20260924/source/mfrmr/` has a manifest
of 662 source inputs. It represents the dirty local working tree, not the old
Git commit. Building uses the complete vignettes; the package check uses the
full packaged test tier (`NOT_CRAN=true`). Historical research scripts and
slow external confirmation protocols remain outside the package and are not
rerun. The complete vignette build executes the tutorials; `R CMD check` then
uses `--no-manual --no-vignettes` on that exact archive to avoid executing the
same tutorials another two times. Vignette presence/source identity, ordinary
Rd examples and the full packaged tests remain checked. This is not a PDF
manual build or a substitute for the later five-platform CI. Any failure is
retained and repaired before accepting the corresponding
source/archive; no blanket pass is assumed.

### Integrated build findings and repairs

The complete 15-vignette build succeeded, retaining 43 rendered figures and
matching article sources. The first archive audit found 19 figures with empty
HTML alternatives. Five tutorial sources now supply target-specific `fig.alt`
text, including separate alternatives for multi-plot chunks. The repaired full
build succeeds, all 43 figures have nonempty alternatives, and visible article
text contains no local user paths or internal validation-directory paths.
Figure coordinates, tables and executed R expressions are unchanged.

The initial package check also found unresolved unqualified `confint` and
`predict` calls. This was an actual runtime defect, not only a static NOTE:
with `R_DEFAULT_PACKAGES=base`, normal-rater plotting failed because `confint`
was not found. The package now imports both generics from stats. Under the same
minimal attached-package session, the repaired installed archive supports
normal-rater and bootstrap-interval plotting and source-Person testlet scoring;
the latter agrees with direct `stats::predict()` without a calibration refit.
Roxygen-generated NAMESPACE and the package source annotation agree.

The first repaired archive is
`validation-results/final-integration-20260924/repair/mfrmr_0.2.4.tar.gz`, SHA256
`41067098f73ea0410b4fa24f76689f147bb782430a9adf06ff3e912aaaa6793d`.
Its `R CMD check --no-manual --no-vignettes --no-tests` result is **Status: OK**.
The initial full packaged suite then finished with **22,364 passed expectations,
2 failures, 42 warnings and 44 skipped tests**. That original failed receipt is
retained; it is not relabelled as a clean run.

The two failures were a missing CRAN execution guard in seven new tutorials
and an order-dependent PCA renderer spy. Registered numeric S3 methods reproduce
the latter failure; observing/restoring the registered methods fixes the test
without changing the renderer or weakening its shape/legend assertions. The
39 category-support warnings are now expected and their weak-information state
asserted in the deliberate fixtures. One comparison test explicitly expects
both readiness and JML-ranking warnings. A larger test device removes two label
crowding warnings while preserving the intentional frequency-overflow check.
No product warning is suppressed. Source-only documentation checks also found
and corrected internal validation wording in the README.

Eight affected/source-only test files now pass **1,590 expectations, with no
failure, error, warning or skip**. The earlier intermediate failures and their
repaired reruns are retained separately. Twelve documentation/help checks skipped
in the installed suite now execute from source. The other 32 skips depend on
excluded repository-only GPCM/external research artifacts; their existing
source-specific records are reused rather than re-executing those studies.

The initial build took 546.85 seconds. Its `/usr/bin/time -l` wrapper failed
while reading `kern.clockrate` after the archive had been built; no RSS is
claimed for that attempt. The repaired build used Python `getrusage` and
finished in 562.06 seconds with a maximum child-process RSS of 2,942,255,104
bytes (2.74 GiB). The repaired structural/example package check took 99.60
seconds, maximum child RSS 787,496,960 bytes. These are observed local workloads
on R 4.6.1/macOS arm64, not summed concurrent-process memory, model-level
benchmarks or general capacity guarantees. Dependency-index requests to
CRAN/Bioconductor were unavailable in the sandbox; installed dependencies
satisfied the check, which reported no resulting NOTE/warning/error. No online
repository/URL validation or PDF-manual compilation is claimed.


### Local completion decision and final source

**M1–M5 are complete locally for the retained release scope. M6 is open.** No
required included workflow or known defect invalidating a supported default
remains pending. Broader inferential claims remain excluded as specified in the
public roadmap; inconclusive/adverse study results are not changed by this decision.

The final local archive is
`validation-results/final-integration-20260924/final/mfrmr_0.2.4.tar.gz`, SHA256
`9eceab3943bf5ae6d6e76fda2b95787272e77a6d62f1fac931ea3b630658f3c0`.
Its `source-sha256.csv` identifies 708 source/build-document inputs, including
the prebuilt tutorials; the 662 original package-source inputs are reconciled
with the working tree. This is a frozen dirty-tree snapshot, not a Git commit.

- All executable package R expressions and compiled-code sources are unchanged
  from the completed broad suite. The only runtime namespace change imports
  `stats::confint` and `stats::predict`, separately verified against the final
  installed archive in a session without attached stats. Test-only changes,
  README/NEWS and vignette options are recorded in the source manifests.
- The fifteen fully executed tutorials and all image bytes are inherited from
  the successful first-repair build. Seven **hidden setup chunks only** add the
  existing CRAN guard; all analysis expressions, prose and display options match.
  Twenty-one true/false/unset setup branches pass. Matching Rmd files and freshly
  extracted R scripts accompany the unchanged executed HTML. The final build
  uses `--no-build-vignettes` to preserve these outputs without refitting.
  All 43 images have nonempty alternative text; source/asset identity and absence
  of local/internal paths in visible article text pass.
- The exact final archive passes `R CMD check --no-manual --no-vignettes --no-tests`
  with **0 errors, 0 warnings, 0 NOTEs**. This covers installation, namespace,
  compiled code, Rd/usage/cross-references, ordinary examples and vignette assets.
  It is combined with the completed broad run and the 1,590 repaired/source-only
  expectations above, not described as a second clean full-suite run.
- The final installed package retains **204 exports, 262 S3 registrations and
  269 Rd topics**. Fresh-process replay preserves nine workflow objects and both
  model export/report scripts with statistical recomputation blocked. Earlier
  optional-dependency and ordinary/portable checks remain applicable to unchanged
  executable code. Saved-analysis migration instructions remain in README/help.
- Final packaging took 3.72 seconds and the structural/example check 97.50 seconds,
  maximum child RSS 799,506,432 bytes. The full packaged run took 1,206.86 seconds,
  maximum child RSS 3,038,806,016 bytes. These are local observations with the same
  per-process memory limitation described above.

The local result is an installable candidate with matching help and executed
articles. Five-environment CI, main/tag/asset/site publication, online URL and
repository checks, and PDF-manual compilation are not part of this local receipt.
No commit, push, publication or CRAN submission was made. Future changes must be
mapped to the applicable evidence before reusing this archive's disposition.

### September 24: publication-candidate preparation

The M5 checks above remain the local qualification. The publication candidate
is assembled on `development/0.2.4-expanded-workflows-20260922`, based on main
`2230003f2caa1c0e615c2a1c96f99320db78ac71`. A read-only GitHub check on
September 24 confirms that main still points there and `v0.2.4-rc.3` is the
latest published candidate; neither contains this expansion. The existing
five-environment workflow includes the new feature/MI/interval/screening and
model test files. Release metadata consistency passes locally.

`cran-comments.md` now describes this expansion and its actual local checks,
instead of the earlier archive. Incidental `Rplots.pdf` is ignored by Git as
well as source packaging. Staging the new files exposed one trailing space in
testlet tutorial prose; it is removed without changing rendered HTML or R code.
The publication-preparation archive is
`validation-results/release-preparation-20260924/mfrmr_0.2.4.tar.gz`, SHA256
`776465bc7b637d0b1859988485f9ac711ebc60c521aa476b4ef22c6a6497f134`.
Its exact member comparison with the checked M5 archive finds only that prose
space, the same change in the embedded Rmd, and the generated packaging timestamp.
Every executable source, test, Rd topic, dataset, extracted tutorial script,
rendered HTML and image is byte-identical. Existing checks are reused on that
basis; no new full run is claimed. M6 still requires matching hosted results
and verification of integration/publication.

### September 24: pre-integration beginner and API review

The user asked whether a beginning graduate student could follow the workflow
and understand the API names before integration into main. This was a
source/help walkthrough, not a usability study with student participants.
The ordinary load/fit/summary/diagnostics route already had a runnable example.
The principal gaps were choosing among extensions and recognizing what the
less explicit names actually do.

The README now maps practical questions to inputs, functions and outputs.
The workflow help explains operation verbs, the package/model prefixes,
conditional calibration, EAP and SE/SD, and puts the summary-to-diagnostics
step before specialist routes. Fourteen help topics and two tutorial
introductions were updated. The compact beginner guide uses direct questions
and no longer makes a particular map mandatory. No aliases, public names,
arguments, numerical methods or model scope were changed.

The review addresses these specific misunderstandings:

- `mfrm_response_imputations()` reviews supplied completions; it does not
  generate them. Review, fitting and eligible pooling are separate operations.
- `predict()` returns probabilities at supplied abilities for shared raters,
  but scores Persons for testlets. The existing `score_mfrm_persons()` gives
  the common source-Person route. Selected IDs reduce requested output without
  removing the remaining conditioning data; shared-rater scoring can be slow.
- `mfrm_cluster()` selects PAM, not an algorithm automatically. K-means and
  hierarchical grouping have explicit entries. PCA is optional and retains
  all numerically nonzero components unless fewer are requested.
- Screening performance requires known simulation truth. Threshold
  sensitivity analysis and the reported detection rate are distinct meanings.
- G/D studies use observed scores and do not require fitting an MFRM first.

Local receipts are in `validation-results/beginner-review-20260924/`.
The four affected guidance/API/routing/documentation files pass **985
expectations**, with no failure, error, warning or skip. The final prose
refinement additionally reran the same 54 documentation expectations; these
are not 54 new independent checks. All fourteen changed Rd topics are generated,
parsed, checked and rendered, and the README renders. Numerical R expressions,
NAMESPACE, public formals and the executable chunks of both edited tutorials
are unchanged. The only executable difference is output-guide text.

An optional duplicate numerical scoring comparison on saved fits was manually
interrupted after the focused checks had passed: the shared-rater calculation
was costly and its implementation had not changed. This attempt is not a
successful numerical check. A separate passing dispatch check verifies that
the common entry preserves the complete fit, requested IDs, interval level
and quadrature when forwarding to each extension. Existing independent
numerical evidence is reused; neither the full suite nor the numerical studies
were repeated for these prose changes.

The prior publication candidate `4819f79` and its archive above describe
pre-review documentation. The bounded numerical qualification remains
applicable, but a matching source archive, rendered tutorial prose and hosted
checks must accompany the successor candidate before main/publication. No new
archive, push, merge or publication is claimed here. M6 remains open. The
review improves discoverability; it does not establish novice task-completion
rates or remove the need to learn the relevant statistical assumptions.

#### Follow-through: defaults and user intent

The user then asked whether omitted arguments could select an unintended
analysis. The review traced the main ordinary/extended fitting, source scoring,
feature/PCA/clustering, response-MI, interval, screening, G/D and reporting
entry points. It is not a claim that every display argument of every export
has undergone a usability study. Existing protections include required group
counts, selected imputation events and category rosters, default missing-data
refusals in the new routes, and retained resolved settings.

Important differences remain intentional but need visible choices:
ordinary RSM/PCM MML fixes N(0,1), whereas the extensions estimate ability
variance by default; ordinary preparation can compress gapped categories
(with a warning and mapping) and omit incomplete rows; extensions require
additional fixed facets explicitly; numeric features default to SD scaling;
intervals default to model covariance; D-study weights do not create an
automatic equal-weight total. Screening defaults can depend on session
options, and a supplied dashboard `misfit_warn` sets a reciprocal lower
bound as well as an upper bound. These defaults are not universally suitable
choices or inferred user intentions.

The maintained workflow help now explains those choices, the MI complete-data
degrees-of-freedom approximation, calculation costs and display controls.
The opening README/help example explicitly declares rubric bounds, preserved
categories and the fixed ability population. The fitting and extension help
exposes scale/effect choices; the dashboard argument help now correctly
distinguishes `NULL` from numeric input. The guide treats the native Wright
map as a purpose-specific view; existing export presets still retain their
declared figures. NEWS records the changes. No defaults, signatures or
statistical calculations were changed.

Receipts are in `validation-results/default-review-20260924/`. Five small
behavior checks reproduce category compression/preservation, missing-row
identity, PCA scaling/rank, session-option thresholds, and unchanged input
for the newly explicit opening example. The initial probe failed because
`identical()` compared integer and double storage instead of category values;
that failed receipt is retained. The corrected probe checks values and the
expected recoding warning, and passes. There was no model refit. The two
affected guide/documentation files pass 370 expectations without failure,
error, warning or skip. They overlap the earlier 985 checks and are not added
as independent evidence. Five changed Rd topics are generated and rendered,
and the README renders. Source-expression comparison confirms unchanged
numerical code/defaults, with only guidance strings changed. The new help
remains local and requires the matching successor archive described above.

#### Follow-through: CRAN examples and the local ConQuest connection

The September 24 source-help preflight addresses the user's CRAN preparation
and explicit request to run `/Applications/ConQuest/ConQuest` locally. Its
receipts are under `validation-results/cran-preflight-20260924/`. No push,
merge, release or CRAN submission was performed. The current M5 completion is
reopened for the example workload and successor archive; the earlier clean
ordinary-example check remains evidence for its own source and narrower run.

**ConQuest connection.** The specified x86_64 executable ran locally via
`/usr/bin/arch -x86_64`, outside the filesystem sandbox. Its transcript reports
ConQuest 5.47.5 Standard Version, and its SHA256 is
`61d0b87f379f1578466b789866366c5cc633d31a6c3501e872861d44ff02da48`.
A data-free startup probe and the generated native command both exited zero;
no licence or system policy was altered. The public bundle uses synthetic
60-Person by six-item binary responses, one numeric covariate, Q31,
maxit=2000 and reltol=1e-10. Native estimation terminated on deviance change
at iteration 132. All requested CSVs and the review text were produced.
The public normalizer and reviewer align all three population targets,
six centered items and 60 Person EAPs, with no missing, duplicate or
non-numeric attention items. Native input/output, console, command/executable
hashes and version/edition/date are retained.

The largest population-coordinate difference is 4.448e-6, the largest centered
item difference is 4.638e-6, and the largest EAP difference is 0.008232. These
are descriptive results from one case, not newly defined acceptance margins
or evidence of general software equivalence. The native posterior simulation
settings were not overridden. The [earlier ConQuest study](conquest-adaptive-recheck-0.2.4.md)
and [official command reference](https://conquestmanual.acer.org/s4-00.html)
explain the separate `p_nodes`/`seed` controls for posterior EAP calculation;
that numerical experiment was not repeated here. The source fit reports
numerical convergence but remains `MfrmrInferenceReady = FALSE`. Neither
reading back complete files nor close coefficients upgrades this status.
No SE, interval-coverage, sparse/multifacet or extended-model bridge is admitted.

Help now explains local execution and relative paths, optional ConQuest use,
posterior controls, and the difference between descriptive comparison and
inferential qualification. The old bundle instruction wrongly treated all
readiness restrictions as convergence failures; it is corrected in the help,
generated README and status note. Review notes state the descriptive scope.
The builder example now uses the same Q31/2000/1e-10 controls as the local
run; its printed example executes in 4.949 seconds. The 28 existing ConQuest
tests pass 365 expectations. The initial ad-hoc test reporter failed before
running those tests because it lacked a file context; that harness log is
retained, and the corrected runner uses `test_file()` on the selected existing
test expressions. It is not a package failure or a clean initial test receipt.

**Example execution.** The inventory contains 269 Rd pages, 238 with examples:
163 include `donttest`, 72 are ordinary executable examples, two require
external ConQuest output, and one is the interactive viewer. The preflight
extracts the current Rd code and evaluates each page in a fresh R process,
with `NOT_CRAN=false`, one numerical thread and a 90-second per-page ceiling.
It reuses the checked installed numerical code, with current guide wording;
source-expression comparisons confirm that estimation, defaults and public
formals have not changed. This initial pass evaluates expressions without
implicit printing of their return values. It is not an archive-level
`R CMD check --as-cran` or a complete print/render check.

Of the 235 executable pages, 233 finish and two reach the local limit:
`mfrm_random_rater_intervals` and `score_mfrm_random_rater`. Those two are
**not passes**, nor is a timeout evidence of incorrect estimates. The three
guarded pages were not executed by this pass. Completed evaluations total
443.809 seconds, with separate 90-second incomplete attempts; no actual CRAN
check total is inferred. Four testlet workflows each take about 60–71 seconds,
mostly repeating full calibration. The public ConQuest round trip separately
exercises the two external-file operations. No new guard was added to hide
long examples. `donttest` normally executes in the second `--as-cran` pass,
as specified in [R Internals](https://cran.r-project.org/doc/manuals/r-release/R-ints.html#Tools).

The pass also reveals iteration-limit warnings in 61 JML examples whose
ceilings were set to 30. A common-data probe with a 300-iteration ceiling
converges in 0.582 seconds with inference-ready status. The 61 affected
examples now allow 300 iterations, preserving their data, estimator and
model. All 61 regenerated/rendered help examples finish when rechecked with
printing enabled: 61.719 seconds combined, maximum 2.398 seconds, no error or
iteration-limit warning. The observed-data QC example retains its legitimate
category-support warning; an added comment explains that convergence cannot
remove that support restriction. Other original linking/category warnings
remain in their raw logs and are not relabelled as a warning-free full pass.

A separate attempt to reduce both extensions to Q31 on the unchanged
`example_core` input fails their integration/readiness checks. It is retained
as a rejected shortcut; Q121 examples, numerical thresholds and defaults were
not changed. Contributor guidance no longer recommends switching estimators,
small quadrature or a forced 30-iteration ceiling just to shorten checks; the
corresponding source-policy assertion is removed. The final example-policy
and terminology checks pass 329 and 54 expectations, respectively, with no
failure, error, warning or skip. Earlier overlapping policy runs are not added
as independent checks. No full package suite or new statistical study ran.

**M5 disposition at this preflight.** Repeated costly fitting in post-fit
examples and the two incomplete examples required resolution while retaining
reproducible workflows and numerical checks. The follow-through below addresses
those examples. Actual ordinary/donttest passes on the successor archive remain
to be measured. Revised help, matching tutorial prose and archive identity must
travel together.
The source manifest and `git diff --check` are retained. This preflight does
not establish a new complete `--as-cran`, PDF-manual or five-platform result.

#### Follow-through: commented recomputation and executable saved examples

The user's suggestion to comment out examples is applied to the measured costly
calibration, scoring, diagnostics and bootstrap calls. Seven help pages now
read packaged synthetic results and still execute summaries, interval-level
changes and figures: both extension fitters, testlet prediction, shared-rater
scoring, response diagnostics, model maps and shared-rater bootstrap intervals.
Their outer `donttest` wrappers are removed. The package now has 156 rather
than 163 pages containing `donttest`; commenting out a whole workflow or
disabling its numerical regression checks is not the chosen policy.

`inst/examples/extended-models.rds` contains two fits, matched conditional
scores, testlet diagnostics and all 19 planned shared-rater bootstrap trials.
It uses the unchanged 48-Person, four-rater, four-criterion `example_core`
ratings, Q121 and estimated ability variance. The 19 trials demonstrate reuse
and failure accounting, not stable tail quantiles. Studentized results retain
two unresolved trials and unbounded limits; the unscaled method retains one
unresolved trial. No failed trial is removed. The complete optional regeneration
function is distributed as `inst/examples/extended-models.R`; sourcing it only
defines the function. RTMB >= 2.0 is needed for recomputation, not replay.

The existing workflow-output and population-study results are reused, not
refitted or relabelled as new numerical evidence. Their exact source paths are
in `validation-results/example-reuse-20260924/retained-sources.csv`. The first
assembly check assumed that an older shared-rater fit had `assigned_data`;
the corrected check uses its retained `input$data` when that field is absent
and verifies all values against `example_core`. The first replay check also
caught an unsuitable testlet score result based on a 64-row subset: the Wright
map correctly refused it. The selected result now preserves the full 768-row
source roster and selects four Person outputs. The regeneration recipe uses
`persons =` accordingly. Both failed checks remain in the receipts.

Older saved fits contained automatic bounds in their raw display tables.
Their calibration/rater display tables are refreshed using the existing public
`summary()` methods so the distributed example follows the current explicit
interval policy. Estimates, calibration SEs, parameters, covariance, numerical
checks, scoring results and bootstrap draws are retained. This is presentation
migration, not recalibration or new interval qualification. The saved bootstrap
source is matched to the refreshed fit. The distributed RDS is 66,660 bytes,
SHA256 `3c1fef277148b4971d67b89269805eb9e2b0436753a2d34b2a9557762d4d8840`.
It contains no native pointers, functions or session environments.

The seven regenerated Rd pages pass syntax checks and render. After installing
the current source in an isolated local library, all seven examples execute
with printing and plots, without warnings or errors: 0.369 seconds combined,
maximum 0.297 seconds. RTMB is not loaded during this replay. These timings
exclude installation and do not predict a whole CRAN check. The new compatibility
test passes 29 expectations, including source-roster identity, default missing
bounds, preserved trials, plot-data agreement and refusal of accidental
statistical recomputation. The existing example-policy and terminology tests
pass 329 and 54 expectations; overlapping repeated checks are not counted as
additional evidence. Source-expression comparisons verify unchanged statistical
code, defaults and public signatures; earlier guidance-only edits are retained.

Receipts, generated examples/HTML, installation logs, final example timings and
artifact hashes are in `validation-results/example-reuse-20260924/`. No full
suite, new numerical simulation, push or publication was performed. M5 remains
open: build a successor archive containing these results and all intervening
help revisions, then verify its actual ordinary/donttest workload and applicable
package/manual checks. Direct installation from this source directory does not
verify archive exclusions or establish an archive-level `--as-cran` result.

#### Follow-through: successor archive CRAN check and targeted repairs

**M5 is requalified locally; M6 remains open.** The selected successor is
`validation-results/cran-candidate-20260924/final/mfrmr_0.2.4.tar.gz`, SHA256
`27f9ca8697263e79d1f2c14b7c959aded97ef676fdd96c52c1430e99318ece54`.
It contains the beginner/default/ConQuest/JML help revisions and the saved
extended-model examples. This is a frozen local working-tree snapshot, not a
new commit, hosted CI result, main integration, publication or CRAN submission.

The first archive (`7d0d244f03e438cb27fb007aa1dc9b00847331d09985d8201edc946a65dd3146`)
was checked using `R CMD check --as-cran --timings`, `NOT_CRAN=false` and one
numerical thread. Incoming remote queries were explicitly disabled. Package
index access and remote clock verification were unavailable. The result was
**two errors, one warning and three notes**, not a clean pass. The receipts are
in `validation-results/cran-candidate-20260924/`.

| Finding | Repair and actual verification |
| --- | --- |
| Missing prebuilt vignette index after reusing articles with `--no-build-vignettes` | Retain the index from the previously executed build; verify all fifteen source, output, extracted-R and title entries against the current articles. Final incoming/build-directory checks pass. Contributor guidance now documents this requirement. |
| Test code uses `withr` without declaring it directly | Add `withr` to Suggests; existing calls and statistical code are unchanged. The tools dependency audit and final archive's test-dependency check pass. |
| One guide test requires the superseded phrase “conditional Person scores” | Assert the documented `score_mfrm_persons()` route while retaining the separate calibration-uncertainty boundary assertion. All 41 expectations in the affected integration file pass without warning or skip. |
| External-feature article inline expressions run despite disabled analysis chunks | Apply the existing `!is_cran_check && available` condition to both expressions. The article renders in CRAN mode; both executed-value branches agree with their former expressions, and all unavailable/disabled branches avoid absent objects. The final archive rebuilds all fifteen articles successfully. |

The initial ordinary examples pass in 25 seconds and the pass including
`donttest` completes in 152 seconds. The test tier takes 113 seconds and reports
3,014 passed expectations, one failed wording expectation and four skips.
Three skips are explicit CRAN GPCM exclusions; the fourth is an installed-library
path condition in the portable-API subprocess check. Their unchanged numerical
paths retain the earlier GPCM and installed/fresh-process evidence. The focused
repair resolves the one failed assertion; its 41 passing expectations overlap
the initial run and are not added as independent tests. No full numerical
regression suite or statistical simulation was repeated.

The final archive is checked with
`R CMD check --as-cran --no-examples --no-tests --no-manual --timings`.
It returns zero errors, zero warnings and **two notes**, for unavailable remote
time verification and the `xcrun_db` temporary file. Declared test/vignette
dependencies, installed help, the restored index and all article rebuilding
(11 seconds) pass. This final pass skips examples, tests and manual compilation;
it is not represented as a fresh complete `--as-cran` run. The final source also
compiles separately to a 591-page PDF manual. The initial archive passed PDF
and HTML manual checks. Raw TeX destination warnings for external-package
references are retained; exhaustive PDF layout or online-link validation is
not claimed.

The package-controlled timing components sum to approximately 301 seconds
(25 + 152 + 113 + 11), using the repaired article-rebuild time. This includes
the initial failed test run, not a new clean full-run measurement, and is not a
platform-independent time guarantee. Initial/final check elapsed times are
447.280 and 132.484 seconds, including compilation and check infrastructure.
Maximum per-child-process RSS is recorded as 1,698,365,440 and 755,187,712 bytes
using macOS `RUSAGE_CHILDREN`; it is neither summed concurrent memory nor a
general capacity limit.

Archive member comparison admits exactly five changed paths after the initial
check: DESCRIPTION, `build/vignette.rds`, the affected test, and the external-
feature Rmd in `vignettes` and `inst/doc`. All R/native code, Rd, data, saved
examples, executed article HTML/figures and extracted tutorial R are unchanged.
The current working tree matches all 630 packaged code/help/test/article/example
inputs byte for byte. The archive audit also checks internal-record exclusions,
all fifteen article assets and alternative text on all 43 figures.

Earlier executed article output is preserved. The two scoring-explanation prose
updates are rendered into their HTML after checking identical R chunks and
output/figure blocks. The external-feature inline-guard repair leaves the fully
executed HTML applicable when computation is enabled. The original staging
checks that encountered generated files and an already-documented trailing-space
change are retained; a first standalone dependency-audit assertion misread the
tools result structure and is likewise retained separately from its corrected
pass. These are validation-script failures, not unreported package passes.

Current source/manifest, archive hashes, member comparison, article provenance,
initial failure logs, focused repairs, final check and final manual logs are
retained together. The remaining release work is matching hosted CI and public
source/help/asset identity, plus the separately reported online CRAN/repository
checks. Neither earlier hosted CI nor this local result authorizes a broader
inferential claim or establishes CRAN acceptance.

## Earlier candidate and claim-reconciliation evidence

### September 21: selected additions in the integrated candidate

September 22 follow-through: the original sixteen-action audit is now
reconciled in the [active roadmap](internal-roadmap-0.2.3.md#current-work-plan).
Subsequent C15/C17 repairs prevent rounded design-threshold decisions and
restore default fit archives without optional predictions. A prespecified
selection/refit study and an observed writing-assessment workflow add bounded
evidence, without qualifying automatic rater removal or broad diagnostic
error rates. The corrected source is `31e9197`, separate from the earlier
`4a6f8fb` candidate. Its own five-platform checks, verified release archive and
matching site now support `v0.2.4-rc.3`; the active roadmap records the source
identities and the additional oldrel-1 README-content skip. This completes that
candidate's distribution checks, without closing the broader statistical claims
or making a final/CRAN release decision. This post-publication record update
changes no package or site input.

The source identifies itself as candidate 0.2.4, not a final release.
The original 18-group table remains historical. The additional retained claims
are reconciled here; their implementation records are in the current work plan.

| Retained addition | Applicable evidence | Boundary retained in public help |
| --- | --- | --- |
| External-feature PAM/hierarchical clustering, MI and setting comparisons | Existing ID/type/omission/pairing regressions, applied tutorial and bounded feature stress results; plotted values reuse fitted objects. | Exploratory descriptions, not latent classes, population recovery, membership probabilities or pooled inference. No generic ggplot conversion. |
| Multivariate crossed G/D-study points, composites and metric-specific availability | Independent ANOVA/QR, MINQUE kernels, published numerical examples, weighted-score reduction and saved sparse/plan-choice assessments. | One/two common random facets; numeric observed scores. Raw non-PSD estimates remain flagged; no missingness correction, sparse-roster reliability or MFRM latent reliability. |
| Prespecified paired G/Phi/SEM plan-difference intervals | Joint quadratic-form/delta calculations, independent dense covariance checks, existing Gaussian and targeted nonnormal coverage results; API/plot/replay regressions. | Explicit normal random effects and two crossed facets only. Gamma-condition failures remain evidence against a robust claim; no selection-adjusted, simultaneous or nested intervals. |
| Person-by-(Child-within-Parent) G/D-study points | Five-component independent QR/kernel equations, incomplete/unequal examples, direct composite reduction, published D-study divisors, saved-result and rendered plot checks. | Shared persons and score identities; future balanced nesting retained. No nesting within persons, partial sharing, score-specific children, arbitrary sparse recovery claim or nested intervals. |

Integration also preserves the prior candidate's ICC/shrinkage and portable
calibration implementation: direct comparison to `/private/tmp/mfrmr-0.2.4-icc-candidate-20260921`
found no native-source changes and only the expected shared R changes in
`api-generalizability.R` and `api-as-ggplot.R`, plus the new feature/G-theory
files. Subsequent edits add workflow help only. Source identity and the batched
package-check outcome are recorded under the stage-4 entry of the
[active work plan](internal-roadmap-0.2.3.md#current-work-plan). No earlier
full-suite or hosted result is relabeled as a pass for this integrated source.

Subsequent follow-up: the [fit/diagnostics identity repair](estimator-output-identity-repair-0.2.4.md)
addresses a newly reproduced C03/C04/C05/C17 output defect. MML diagnostics
could incorrectly promote a JML lightweight summary to formal inference.
Shared source checks now reject these mixed pairs. That record contains the
new tests/source checkpoint; the counts and source identity below remain this
ledger's original reconciliation checkpoint, not results of the later repair.

The [paired-owner GPCM kernel audit, 2026-09-15](gpcm-paired-owner-kernel-0.2.4.md)
adds bounded C03/C04 evidence: 48 specified finite points cover both estimators
and slope owners, five categories, sparse observations and unequal weights.
It supports probability/NLL/gradient implementation agreement, retaining the
initial comparison-script and finite-difference failures and their follow-up.
Fixed quadrature remains sensitive to order; recovery, uncertainty and global
optimization claims stay open. The table below retains its original checkpoint.

The subsequent [continuous-integration study](gpcm-continuous-integration-0.2.4.md)
evaluates 120 fixed-point/rule combinations and 24 public GPCM-MML refits.
All four adaptive-Q61 refits meet the stated continuous-reference tolerances,
with small Q31/Q61 parameter changes; fixed Q301 remains materially sensitive
in the weighted sparse datasets. Two earlier wide-slope fixed points still
fail at adaptive Q301. This adds C04 numerical evidence without certifying
an order universally, a global optimum, or free-slope uncertainty.

The [initial-value and finite-path follow-up](gpcm-start-boundary-0.2.4.md)
finds close agreement between five new starts and the retained adaptive-Q61
solution in each of those four datasets. It checks specified finite slope/SD
paths while leaving nuisance coordinates fixed; it does not profile or exclude
all boundaries. A shared reporting repair also separates known numerical
convergence from pending statistical readiness. Its current-source tests and
package check belong to that follow-up; the original checkpoint below is
unchanged, and C04/C17 are not release-closed.

The [current-source FairZ follow-up](fairz-current-review-0.2.4.md) repairs
mixed fit/diagnostic inputs in fair-average tables and plots and reconciles
the fixed-reference candidate with a matching 40-dataset preflight. Saved
outputs, label variants and CSV routes retain the diagnostic restrictions.
This advances C12/C17 preparation. The subsequent
[confirmation](fairz-confirmation-status-0.2.4.md) resumed from 450 saved datasets
after the user's September 17 instruction and source/state verification.
All 20,000 assigned datasets are now complete: the
[frozen adjudication](fairz-confirmation-results-0.2.4.md) supports five primary
cells and leaves three under review. The subsequent
[package-check repair](package-check-repair-0.2.4.md) preserves the original
evidence identity and compares 12 saved cases against the changed source.
Public Fair Score interval eligibility remains false. Earlier checkpoint
tables below retain their original counts; the machine-readable ledger
includes later follow-ups.

The [current maintainer sequence](internal-roadmap-0.2.3.md#current-work-plan) supersedes the historical execution instructions below. Completing a numerical repair or resuming a study does not close the
corresponding statistical claim.

The main workflow, documentation and many numerical/output repairs are well
advanced. The remaining work is to resolve the evidence and restrictions for
the exact retained claims, then verify one final release source. Counting
features, test expectations or mapped declarations does not measure that
completion; no overall completion percentage is assigned.

## What this reconciliation established


### September 20: public scope and saved-analysis instructions

The public documentation now distinguishes what is implemented, what is
exploratory, and what remains outside 0.2.4 without exposing claim IDs,
research sample counts or maintainer execution instructions. The previous
public roadmap is retained in
`validation-results/documentation-scope-20260920/before/ROADMAP.md`;
its internal details remain historical context, not new release conditions.
The existing maintainer roadmap and this ledger continue to own source
applicability, evidence gaps and release decisions.

The reconciliation found actionable documentation mismatches, not new numerical
failures. NEWS already described full pooling at zero prior variance, but the
shrinkage help example still claimed no pooling and zero mean shrinkage. The
example now matches the implemented formula. Its effective-weight sum is not
presented as model test degrees of freedom. G-theory help now distinguishes
absolute-decision dependability from accuracy at a specific cut score. The
workflow guide explicitly requires review-only estimated-population scoring,
retains unavailable residual-DIF rates and does not suggest that a denser grid
makes free-slope GPCM ranking or the PCM/GPCM LRT available.

NEWS and README now direct users to the installed workflow help's saved-analysis
section. It distinguishes display refresh, rebuilding derived results, rescoring,
re-importing, and refitting a native fit lacking current estimation checks.
Diagnostic recomputation cannot supply missing fit checks; exporting an old
object does not recalculate it. Valid portable v1 artifacts preserve their
recorded algorithm; adopting continuous intervals requires a newly created
artifact through the existing reviewed workflow. Original plausible-value draws
can correct empirical summary quantiles without resampling, except where older
population restrictions require scoring regeneration. The G-study is explicitly
a separate observed-score mixed-model refit, not an MFRM refit. Missing design
metadata cannot be invented by re-summarizing.

Evidence is in `validation-results/documentation-scope-20260920/`. Existing
public-documentation tests pass 108 expectations in 13 blocks without failures,
warnings or skips. All four regenerated Rd pages parse, pass `checkRd`, render
as text/HTML, and have resolvable local help links. README/NEWS/ROADMAP relative
file links resolve. Parsed executable expressions in all four edited R files
are identical to the pre-edit snapshot. This is a documentation-only change;
no model was refitted and no numerical study, full package test, platform check
or new release-source approval was performed.

Two initial verification-harness problems are retained separately: a selected
block lacked test-file reporter context, then its temporary location caused the
source-path check to skip. The final runner evaluates the same existing block
from the test directory and explicitly requires zero skips. Those initial runs
are not additional evidence counts. No test assertion was changed.

All 18 claim dispositions, including C12's deferred inferential method, remain
unchanged. Completed output repairs supersede stale next-action phrases in the
CSV; their statistical limitations and original evidence records remain.
The subsequent descriptive-output review below addresses the reproduced
network/agreement/time defects (C18). Resolve
retained scope/evidence gaps before the eventual final-source/platform checks;
this documentation cleanup does not close them.

### September 20: current-source applicability of structural SE evidence (C02/C05)

The [structural-source review](mml-structural-source-applicability-0.2.4.md)
reconstructs all 88 original payload files exactly and identifies the active
fixed-normal RSM/PCM numerical change: the repaired quadrature rule. Parameter
maps, fixed-grid cached likelihood/gradient, information inversion and facet-SE
arithmetic are unchanged. Adaptive and estimated-variance branches do not act
on the original sampling target; weighted/regularized and legacy-source
restrictions remain explicit.

All 13 saved independent-information fixtures retain their original numerical
criteria without refitting or regenerating reference Hessians. On 73 original
dataset identities (55 preflight and all 18 formerly interval-unavailable
confirmation datasets), current refits pass the frozen numerical comparisons.
Maximum estimate movement is 1.801e-6 of the original SE, and maximum relative
SE movement is 3.449e-8. Current q61/q121 fixed-parameter checks also pass.

There is a material evidence-identity distinction: 15 of the 18 previously
unavailable fits now return optimizer success. Restoring only the historical
quadrature function reproduces every original estimate, SE and availability
decision exactly in all 18. This attributes the transitions to numerical
quadrature changes without relaxing any acceptance rule. It does not justify
overwriting historical failures or assigning old conditional-coverage rates
to a newly defined current-source eligible sample.

Retain the existing unregularized structural-SE implementation and historical
sampling evidence within the original fixed-normal, unit-weight, additive
RSM/PCM conditions, accompanied by this bounded numerical continuity record.
Other grids, adaptive integration, anchors/interactions, learned populations,
row weights, posterior Person intervals and decision error rates keep their
separate evidence and restrictions. No new sampling study or whole C05
approval follows. The original 20,000/30,000 results and dispositions remain
unchanged; their stale source-applicability action is replaced by this specific
answer and remaining scope.

Production code is unchanged from archive
`09b0f07db2ade6e79e7c5656aa1429e1c6e8c8a2c51dd10214118b59b0fc8bdb`;
all 538 packaged source files still match. This follow-up adds repository-only
evidence, no public labels or NEWS claims, and does not rerun unchanged package
tests. Final integrated workflows, the full packaged suite and platform checks
remain the next candidate-validation work.

### September 20: descriptive agreement, network and timing availability (C18/C17)

Direct implementation review reproduced unavailable correlations becoming
passing flags, probability subsets being compared with full observed-agreement
denominators, zero-weight rater edges connecting nodes, and raters without
directional comparisons receiving a balanced index. Group identifiers joined
with separators could merge distinct matching contexts. Numeric time factors
were read as integer codes, explicitly supplied NULL cutoffs could be labelled
as user cutoffs, and persons without valid times disappeared from summaries.

The shared agreement calculation now preserves context identity, reports
available/unavailable comparisons and withholds expected agreement unless the
entire observed comparison has valid category probabilities. Repeated ratings
within a cell still yield weighted mean scores, but category-probability
agreement is withheld for those means. The public wrapper uses three-valued
flags and pre-truncation denominators. Figures retain unassessed pairs and omit
unestimated diagonal self-agreement. Agreement and design/halo network entry
points require diagnostics matching the source fit.

Rater graph edges now require positive weights. Isolated raters retain missing
directional indices, and distance summaries explicitly concern reachable pairs.
Design reviews record retained versus source subsets, so connectedness after
subset selection cannot establish full-design connectedness. Missing coverage
or vulnerability checks cannot produce a complete assessment. Halo summaries
retain unassessed comparisons. Welch t/df/p columns are intentionally NA:
correlations that share observations are dependent, while the ordinary Welch
calculation does not represent their covariance. The R documentation describes
[ordinary two-sample t tests](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/t.test.html)
and [pairwise correlation tests](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/cor.test.html);
withdrawing a dependent-edge Welch comparison is a methodological restriction,
not a replacement halo test. Existing per-pair association screens remain
conditional on their sampling assumptions and are not causal halo evidence.

Time summaries now retain input, valid and excluded row counts, including groups
with zero valid times. Numeric factor labels are converted to their values;
NULL-derived quantiles, reversed cutoffs, tied/singleton plotting and distinct
flagged-group counts are handled explicitly. A row must represent one timed
event: copying one response-production time across raters or criteria does not
create independent timing observations. Quantiles and user cutoffs describe
the observed valid-time distribution; they do not establish rapid guessing,
effort, speed-accuracy effects or a censoring model.

Normal printing uses readable meanings while machine status fields stay in
structured data. Old agreement/rater-network/time bundles lacking availability
records request regeneration from the original inputs. NEWS and installed help
give this migration action; native MFRM refitting is not required.

Evidence is retained in `validation-results/descriptive-reviews-20260920/`.
Focused existing/new tests cover these defects and normal report routes.
Initial mismatch tests changed an unused config field; their five harness
failures are retained, and the corrected tests alter an actual fit estimate.
The first saved-fit replay was refused because old diagnostics predated the
shared reliability-coverage requirement. The comparison regenerates derived
diagnostics under each source and reuses the same fitted models, without
parameter re-estimation. Complete-case pair metrics are compared with the
previous checked installed source, not an invented external reference. The seven
saved fits pass 112 numeric/output/CSV checks. The initial CSV harness inferred
all-NA numeric columns as logical; explicit source column types fix the harness.
A late saved-network-summary export regression initially omitted a required
reporting-map component; the final fixture uses the native summary constructor.
Both failures are retained. The final focused contract has 76 passing
expectations; with the other existing report, agreement-metric and timing
blocks, 218 distinct expectations pass without failures, warnings or skips.

The first built archive passes the macOS CRAN-light package tests (673 passes,
three intentional skips, no failures/warnings). Its sole code-check NOTE was an
unquoted Ratings selector, corrected without changing selected data. The final
refinement also refreshes stored network-review verdicts during table export
and clarifies adjacent-agreement and coincident-cutoff display labels. These
changes are covered by the focused contract; unchanged broader tests are not
counted again as new evidence.

Final exact-archive macOS `R CMD check --no-tests --no-manual --no-vignettes`
has zero errors, warnings and notes. Its installed regression contract passes
all 76 expectations; fresh-process installed saved-fit replay passes the same
112 checks on seven models without refitting. The final archive SHA256 is
`09b0f07db2ade6e79e7c5656aa1429e1c6e8c8a2c51dd10214118b59b0fc8bdb`;
it matches 538 working files apart from generated DESCRIPTION metadata,
includes eight built HTML vignettes, and excludes maintainer records.
The initial tested archive and final refinement identities remain distinct;
only three R files and the new regression file differ between them.

No likelihood, estimator, formal-inference eligibility or statistical cutoff
calibration is added. These are bounded descriptive-output repairs, not causal
halo identification, rater-quality validation, uncertainty coverage or closure
of C18/C17. All 18 dispositions, including C12's deferred inferential method,
remain unchanged. Final release-source/platform verification remains separate.


### September 20: consistent model-summary decisions and public labels (C05/C17)

The native fit-summary review found an interpretive contradiction: the opening
decision correctly withheld formal inference until precision support was reviewed,
while a later full-view line printed “Formal inference: Ready” from fit readiness
alone. This was reproduced on a saved RSM-MML fit. Population, visual-workflow,
GPCM and information-criterion sections also printed internal state/family codes.
The before/after source and saved-fit evidence are retained in
[`validation-results/model-summary-output-20260920/`](../../validation-results/model-summary-output-20260920/).

The display now uses the existing interpretation decision once. The direct fit
printer no longer falls back to a positive inference claim if that decision is
unavailable. The optimizer-success line reads the recorded return code, preserving
unknown status when it is absent, rather than equating another convergence flag
with code zero. None of these changes promotes source or parameter readiness.

Printed workflow/visual/Person-distribution states now retain readable restrictions
and exclusions. Unknown statuses request review instead of being treated as passes.
Population displays distinguish fixed-normal MML, estimated conditional-normal MML
and JML, which estimates no normal population. Estimated coefficients and residual
variance remain point estimates with omitted parameter uncertainty in posterior
scoring. Shared GPCM descriptions explain the estimator and the full adjacent-
category slope action without implementation-family codes; optimizer traces and
unsupported uncertainty stay labelled. Information-criterion output explains
weighting, integration and small-sample restrictions without state codes. Detailed
settings and status data remain in structured tables. No raw numerical field is
removed or rewritten by printing, and Person identifiers remain opt-in.

The current tests pass 441 expectations in 31 blocks: four relevant console,
summary-profile, reporting-block and information-criterion files plus two selected
GPCM identity/boundary blocks. Saved-fit replay passes 84 checks over eight RSM,
PCM and GPCM fits, including MML/JML, anchors, non-unit weights, both GPCM slope
owners and a learned-normal population. Brief/full prints and selected expanded
profiles preserve a single inference decision and the structured result. All eight
fit-only summaries are identical to their saved pre-change objects; original fit
parameters/states are unchanged. No calibration refit or new sampling study ran.
Across the three touched R files, 362 parsed function definitions are unchanged;
only seven display/wording functions changed or were added.

Initial GPCM expectations depended on a phrase staying on one physical line;
they now compare normalized whitespace. Previously stale expectations for raw
scale labels were updated to the already implemented public descriptions. An
initial expanded-profile replay completed its old checks but then encountered a
parse error because its runner was edited before the process finished. That log
is retained and excluded from the primary verification counts. The final bounded
runner completed separately without this error; its script and result identity
are the current evidence. No acceptance threshold or numerical tolerance changed.

The initial archive
`771d5f79c330962c8b9dda3ea0687f7300e590f97b2b06e744a8d396ae70d338`
passed macOS CRAN-light `R CMD check --no-manual --no-vignettes` with zero
errors/warnings/notes, 673 passing expectations and three intended skips.

The final refinement moves precision-tier wording entirely to printing, so old
saved summaries also receive readable explanations and their original decision
fields are unchanged. The console regression file passes all 64 expectations
again, including a saved coded reason and serialization identity. Only the
formatter R file and its console regression file differ from the initial archive;
remaining source/help/test files are identical. No numerical tests or studies
were repeated for this display-only refinement.

Final archive
`1f50ae47d6859ce4bf59799953aa5b8d8ae31e8a0f575d28cd481dd72651e390`
matches 536 packaged working files apart from generated DESCRIPTION, contains
eight built HTML vignettes and excludes maintainer records. Its macOS
`R CMD check --no-tests --no-manual --no-vignettes` finishes with zero
errors/warnings/notes. A fresh process using that installed package passes
all 84 saved-fit checks. The 673 package-test passes above belong to the initial
archive, not to the final test-skipping check. These are output-consistency
checks, not uncertainty coverage, a full-suite/five-platform qualification or
release approval; C05/C17 and all 18 existing dispositions remain open.


### September 20: fitted-object Person scoring and draw interpretation (C06/C17)

The ordinary scoring review reproduced a mismatch between the requested interval
level and plausible-value summaries: empirical draw limits always used 95%.
Score-only exports did not retain the level, prior parameters or conditional
uncertainty meaning. Console output printed internal scoring/readiness codes;
HTML also reintroduced them through raw manifest dumps. The retained source,
probes and checks are in
[`validation-results/person-scoring-output-20260920/`](../../validation-results/person-scoring-output-20260920/).

Person estimate tables now retain the exact interval level, scoring algorithm,
calibration method, prior form and per-Person prior mean/SD, weighting indicator,
and interval/uncertainty interpretation. Draws and empirical draw summaries
retain their discrete posterior basis and prior/calibration meaning. Numerical
prior values and interval levels are not rounded away by summary formatting.
JML-based scoring is explicitly posterior EAP under N(0,1), not a direct JML
estimate. Non-unit response weights raise likelihood contributions to powers;
the stated posterior uncertainty does not establish equivalent independent
ratings or frequentist coverage.

Empirical draw quantiles now use the stored requested level. A known sample
0:99 at level 0.81234567 gives bounds 9 and 90, rather than the old 2 and 97.
These finite-sample limits remain distinct from continuous posterior intervals.
No EAP, posterior SD, continuous interval, or draw-generation calculation was
changed. Older raw results can be re-summarized and re-exported without refitting
or resampling; an older derived plausible-value summary must be recreated from
the original draw object. Missing numerical priors in old estimated-population
outputs remain unavailable until re-scored with the existing fit. Missing
algorithm identity is not assumed to mean continuous intervals. Imported source
objects are explicitly refused by the native scoring entry point.

Ordinary scoring print methods and HTML scoring tables use readable explanations.
HTML uses basic model details and the existing public interpretation decision
instead of raw manifest tables/text. Detailed manifest CSV/text records remain
unchanged. This is not a claim that every unrelated report or console surface
has been cleared of internal labels: the native full fit-summary population and
visual-workflow tables remain a concrete next review item.

Existing statistical evidence is reused with its limits. The continuous-interval
study establishes posterior-mass calculation for its known RSM/PCM calibration
and correct prior, not conditional-on-ability frequentist coverage. The estimated-
calibration study reports bounded repeated-calibration behavior without adding
calibration uncertainty to the interval calculation. Learned-normal and transport
studies show that estimating mean/spread does not solve shape mismatch or target-
population change. Estimated-population scoring remains explicitly review-only;
no source readiness is promoted. Plausible draws alone do not qualify downstream
regression/group inference without a compatible conditioning model and sampling
design. No new sampling study was run.

Current verification passes 193 expectations in the complete prediction test
file and 63 in the two relevant export tests. The saved-fit replay passes 60
checks over ordinary MML/JML RSM fits, a portable-workflow RSM source fit, and
learned-normal RSM scoring with fixed/adaptive integration. It reuses four
calibrations in five scoring configurations without refitting. EAP, SD, posterior
limits and seeded draws are exactly unchanged; prior values, requested empirical
quantiles, console explanations and CSV/HTML meaning are checked. The original
probe called its portable fixture “PCM”; its actual model is RSM, and the replay
corrects that case label rather than claiming PCM coverage.

Retained initial failures include CSV serialization of a test-result list column,
a test reporter initialized without a file context, loss of the review-only
wording while removing duplicate notes, raw-manifest/full-summary HTML exposure,
and an incorrect expected heading. The corrected checks preserve the numerical
criteria and source-eligibility restrictions. The checked-code archive
`88b016735abd4b38626dae4bd648384d46f7baa6ed92f020cf3f143aa1a57bc0`
passed 673 CRAN-light expectations with three intended skips and no test
failures/warnings. Its package check had one NOTE: the new HTML call needed
`utils::capture.output`. The isolated installed package also passed the same
60 saved-fit replay checks. The namespace qualification is the only difference
across 497 R/man/tests/src/NEWS/NAMESPACE files in the two archives; numerical
code and tests are unchanged, so those tests were not repeated for this fix.

Final archive
`ab442486b2b77928d637c9ea2e7252a23590196b60f37222ed1bcca22724f9b0`
matches 536 packaged working files apart from generated DESCRIPTION, contains
eight built HTML vignettes and excludes maintainer records. Its macOS
`R CMD check --no-tests --no-manual --no-vignettes` finishes with zero
errors/warnings/notes, including examples and Rd checks. Source identities,
initial NOTE, original test logs and final checks remain in the evidence
directory. These are bounded output/package checks, not a new full suite,
five-platform qualification or release approval. C06, C17 and all 18 existing
dispositions remain open and unchanged.


### September 19: marginal-fit availability and reporting (C11/C17)

The first-order screen dropped missing probabilities from weighted sums. A
retained two-row probe with no probabilities produced zero expected counts,
unavailable standardized residuals encoded as FALSE flags, and a fabricated
RMSD of 0.5. Pairwise calculations skipped unavailable posterior/weight rows;
a two-context probe consequently reported one opportunity. Summary flag counts
could then report zero without a classification denominator. These were output
and calculation defects, not evidence of category or local-dependence validity.

Complete probability vectors, observed categories and nonnegative finite weights
are now checked before aggregation. Missing contributing inputs withhold the
affected complete-scope totals/residuals/RMSDs rather than selecting usable
rows. Known observed or expected counts can remain independently available.
Zero-weight opportunities contribute no information. A zero residual variance
leaves its standardized statistic and flag unavailable. Three-valued rules retain
a known crossing even if its companion rule is unavailable; otherwise a missing
comparison cannot establish an unflagged result. Category groups and level pairs
retain observation/opportunity counts, classified/unclassified counts and known
flags. Available maxima have matching availability counts. Pairwise opportunities
with invalid inputs stay in the attempted denominator.

The common bundle carries coverage through diagnostic summaries, rating-scale
and category-structure tables, APA text, visual explanations and summary-table
exports. Partial classification is described explicitly in the ordinary summary.
Saved marginal diagnostics and their derived outputs require regeneration with
the original fit/settings; no model refit is required. Plot entry points also
reject mismatched fit/diagnostics. Ordinary marginal views use plain explanations
instead of basis/literature/status codes; raw metadata remain structured data.

GPCM step-group diagnostics had been pooled into a Common group despite declared
step ownership. They now use each declared step-facet family, as PCM already did.
Plots had also filtered/ranked a preselected top-20 list. Both marginal plots now
apply the requested facet and metric to all candidate rows, disclose metric
availability counts, retain missing rows in the returned data and label displayed
unavailable values. A selected metric's missingness is distinct from a known
crossing under another pairwise rule.

The source computes expectations with Person posteriors conditioned on the same
responses and fixed fitted calibration. Help and output now say so. The residual
scales sum weighted Bernoulli variances (with products of row weights for pairs);
they omit cross-response/opportunity covariance and calibration uncertainty.
No M2 test, formal generalized-residual test, posterior-predictive replication,
finite-sample cutoff calibration or multiple-testing guarantee is supplied. The
existing formal-inference metadata remain false. This review does not endorse
one diagnostic path as inferentially superior.

Evidence is retained in `validation-results/marginal-fit-20260919/`. Five saved
MML fits (RSM plus complete/weighted sparse GPCM under both slope owners) require
no refitting. Their 24 overall category cells, 188 facet/category cells and 49
level-pair summaries retain existing numeric values within 1e-12, including all
12 flagged pairs across 7,488 context opportunities. GPCM step groups change from
one pooled group to four declared families per saved case; each new group's
numeric cells match its existing corresponding facet-level cells. The first
replay comparison stopped on retained data-frame row names in that keyed check;
normalizing only row names resolves it. The initial log remains available.

Adverse-case tests cover missing/invalid probabilities, weights, scores, zero
weights, deterministic agreement, missing context opportunities, coverage across
outputs, mixed-fit refusal, saved-object guards and full-candidate plot selection.
The 81 focused expectations pass. Existing marginal, reporting, summary-table
and output-stability checks pass. Three old full-display assertions expected the
internal `not_available` code and now require readable output. A later partial-
classification display regression exposed a label mapping in the wrong print
method; it is corrected and both brief/full output are checked. Initial failures
are retained rather than replaced by passing-only logs.

The exact archive contains eight rebuilt HTML vignettes and matches all 535
packaged working files apart from generated DESCRIPTION metadata. Maintainer
records are excluded. SHA256:
`6c336e581daaac103cbb025cba0bb70a0731cc1ae9634454db98eec6181f0b9e`.
The macOS `NOT_CRAN=false R CMD check --no-manual --no-vignettes` completes with
0 errors, warnings or notes; its CRAN-light suite has 673 passes and three
intentional CRAN skips. The focused and selected regression tests run separately.
Repository-index access messages are retained in the console log; installed
dependencies suffice. The archive manifest, full working diff, untracked tests,
and initial/final logs are retained. This is not a full-suite, platform-matrix,
PDF-manual or final-release approval.
C11/C17 remain open. The next release work returns to the supported portable
save/load/new-Person-scoring/export workflow and reconciliation of existing
source-specific evidence, rather than adding a new marginal diagnostic study.
Imported metric/covariance restrictions and the final full-suite/platform/manual
checks remain on the release queue.

### September 19: category usage and threshold availability (C11/C17)

The previous step summary described a missing middle threshold, and a single
threshold, as having no disordered steps. The rating-scale summary discarded
nonfinite estimates before differencing, so it could report monotonic ordering
across a missing step. An isolated old-formatter probe with empty category and
step summaries produced adequate-usage and ordered-threshold prose. That probe
used matching fit/diagnostics and replaced the calculation outputs; it does
not claim native diagnostics produced those empty tables. The first attempted
public probe used mismatched diagnostics and was correctly rejected; its error
is retained rather than counted as evidence of a reachable reporting defect.

A shared calculation now compares adjacent numbered thresholds within each
family and retains expected, available, unavailable and decreasing pair counts.
Missing steps, invalid/duplicate indices and absent declared PCM/GPCM families
cannot establish complete ordering. A known decreasing pair remains recorded
alongside unavailable comparisons. Equal estimates count as nondecreasing
within the existing numerical tolerance; this describes point estimates, not
strict separation or category adequacy. A finite single threshold is explicitly
not applicable to adjacent-pair ordering. Threshold plots no longer connect
unrelated families or bridge absent steps; unavailable estimates remain labelled.

Category usage retains unavailable scores/weights/counts, category fit no longer
omits missing residual terms, and unavailable fit flags remain NA. Missing model
probabilities cannot become zero expected counts. Weight totals are identified
as such in help; they are not independent sample sizes. Rating-scale and
category-structure usage summaries cover the full scale before hiding zero-count
rows. Category-structure flag counts have available/unavailable denominators.
QC, APA prose, notes and visual explanations use the same coverage information;
no empty result earns an adequate/ordered conclusion. Ordinary category displays
hide internal mode/basis codes. Saved rating/category bundles and QC results
without the new coverage need regeneration from the original fit, diagnostics
and settings, without refitting the MFRM model. Supplied diagnostics must match
the fit in both category table entry points.

The rating-scale help had attributed 1.4/5-logit gap rules to Linacre (2002),
*What do Infit and Outfit, mean-square and standardized mean?* The
[primary text](https://www.rasch.org/rmt/rmt162f.htm) concerns fit-statistic
interpretation, including the mean-square review interval, not those gap rules.
That attribution and the claim of implemented summary gap heuristics are
removed. Count, fit and order screens do not justify automatic category merging.

Evidence is retained in `validation-results/category-threshold-20260919/`.
Seven existing RSM/PCM/GPCM JML/MML fits are reused without refitting: all 32
category rows preserve observed/expected counts, percentages, Infit/Outfit and
ZSTD, and all 58 available adjacent comparisons preserve the old gaps and
ordering conclusions. The adverse cases exercise missing intermediate/terminal
steps, absent families, invalid labels, tied estimates, binary scales, incomplete
fit/count inputs, empty formatter outputs, provenance refusal, full-scale totals,
legacy-result guards, ordinary text and plotted connections. The initial focused
failure was a test assertion spanning wrapped text; two existing empty-screen
assertions still expected the previously withdrawn zero count, and two step-text
assertions needed the new unavailable-ordering wording. Their original logs and
corrections are retained. Targeted category, core, reporting, QC and bundle tests
pass; the existing QC fixtures emit their 15 retained category-support warnings.

The exact source archive includes eight rebuilt HTML vignettes and matches all
534 packaged working files (apart from generated DESCRIPTION metadata). It
excludes maintainer records. SHA256:
`48fd053c94e8f84dd3eb5b2069cde1a5c76082d541e4a75d32ca7147217fd0c2`.
The macOS `NOT_CRAN=false R CMD check --no-manual --no-vignettes` finishes with
0 errors, warnings or notes; the CRAN-light suite has 673 passes and three
intentional CRAN skips. The new focused tests run separately and pass; the
output-stability file also passes. Repository-index access warnings remain in
the console log, and installed dependencies suffice. Source comparison,
cumulative diff, untracked tests and the initial/final logs are retained.
This check does not replace the full suite, platform matrix, PDF manual check
or final release approval.
No new error-rate, recovery or category-merging study is claimed. C11/C17 remain
open; the subsequent marginal-fit review above covers the next output slice.
Final-source portable evidence
applicability and imported-metric/covariance restrictions remain on the release
queue.

### September 19: mean-square and ZSTD reporting (C11/C17)

The report layer had three reproduced defects: all unavailable mean squares
produced zero element flags and an 'outside' global-fit classification;
partially available flags could be counted against a denominator containing
only complete pairs ('2 of 1'); and missing ZSTD values were replaced rowwise
by mean-square deviations, mixing units in one ranking and labelling a ZSTD
of 8 as a mean-square deviation of 8.

A shared calculation now retains three-valued screening for MnSq and each
ZSTD cutoff. A known crossing is flagged even when the companion statistic is
missing; otherwise an unknown comparison remains unclassified. Nonfinite
statistics and negative mean squares are unavailable. Counts identify all,
classified, unclassified and incomplete-statistic elements. Wholly unavailable
flag counts remain NA; overall rates require every element to be classified.
Diagnostic summaries, visual explanations, APA prose and summary-table exports
use these same counts. Missing evidence prompts review and cannot produce a
zero-flag clearance. Missing global evidence is distinct from an observed
threshold crossing. Reported per-statistic means identify their own available
denominators.

Rankings use complete paired ZSTD values. Narrative fallback to complete
paired MnSq deviations occurs only when no paired ZSTD is available, so one
ranking never combines units. Partial known flags remain in the flag tables
even if those rows cannot enter the paired ranking. Printed summaries explain
the descriptive cutoffs and omitted error-rate calibration. Interval prose
uses plain language instead of CIEligible/column names and counts only finite
eligible limits. Stored diagnostic summaries lacking coverage require
regeneration; regenerate reports/exports from the existing diagnostics without
an MFRM refit. No estimator or fit-statistic formula changes.

Evidence: `validation-results/fit-summary-20260919/` retains the original
source snapshots and reproduced failures (`baseline.log`), focused regression
checks, and `replay.R`, `replay.csv`, `replay.rds` plus console captures. Seven
saved fits cover 365 elements; all 82 MnSq flags are unchanged, as are their
global fit and reliability tables. The report and table routes retain the
new coverage. No MFRM refit or new simulation was used for the replay.
The initial focused export check found the new coverage table absent from
the summary-table registry; adding it and requiring it for saved summaries
fixes that omission. Focused coverage, summary-reporting blocks, reporting
contracts, summary-table bundles and report-function tests pass. The final
focused rerun also covers empty fit tables and ordinary interval wording.

The output-stability tests also pass. The final macOS CRAN-light
`R CMD check --no-manual --no-vignettes` reports 0 errors, 0 warnings and
0 notes, with 673 passing expectations and three intentional CRAN-mode skips.
Eight vignettes were built before checking. The checked archive matches 533
working source/help/test/data files, apart from generated DESCRIPTION metadata,
and excludes maintainer records. Its SHA256 is
`3367a992888641c4a60b368d2653808d6c10c25b6d4614b47bd4288ae242d7ce`.
Source comparisons, full working diff, initial failure and final logs are
retained in the evidence directory. Console repository-index access warnings
are retained; installed dependencies suffice. This does not replace the full
test suite, final platform matrix, PDF manual check or release approval.

This repairs count arithmetic and reporting scope; it supplies no new
finite-sample or multiple-element error-rate calibration. C11/C17 and the
release decision remain open. The subsequent category/threshold review above
addresses the next output slice without closing these groups.

### September 19: person-fit availability and response screening (C11/C17)

The likelihood-based person screen previously floored positive probabilities
at machine epsilon, could calculate a statistic on only the usable responses,
and encoded unavailable index flags as FALSE. The probability moments and
observed log likelihood now retain small positive probabilities exactly as
represented. A zero, invalid or missing observed probability, or an unavailable
moment, withholds the whole person's statistic. Total, available and unavailable
response counts remain visible; unavailable flags and wholly unavailable
aggregate flag counts remain NA.

The existing ability-correction formula is retained, conditional on fitted
non-person calibration. Its implemented scope now requires established
numerical convergence, a finite JML person estimate, unit observation weights
and complete probability/derivative information. It does not silently omit
unusable responses or apply an unweighted estimating equation to weighted
fits. The uncorrected, unweighted response-pattern index remains available
where computable, with a plain explanation of the missing correction.
MML/EAP is not promoted to the JML correction. Standard-normal cutoffs remain
uncalibrated screening references, with no multiple-person error control or
automatic response/person exclusion claim.

Supplied fit and diagnostics must identify the same analysis. Older native
probability moments refresh from the matching saved fit without refitting;
without that fit the caller must regenerate diagnostics. Old person-fit
tables and summaries require regeneration. Direct printing uses a compact
plain-language summary instead of exposing internal index/status codes.
Person plots retain all Person rows and show computability separately for
mean squares and the likelihood-based index; missing Infit/Outfit no longer
removes an otherwise available likelihood statistic.

Unexpected-response screening now preserves three-valued AND/OR logic:
for example, a known low probability suffices under the either rule even
when the residual is unavailable, whereas two unknown checks do not clear
the response. Summaries retain evaluated/unclassified counts and withhold the
overall rate when any response remains unclassified. Before/after adjustment
reductions and comparison plots require complete classification in both
screens. QC retains missing diagnostics as review; it refreshes only usable
older summaries to recover their coverage. Saved screening/QC summaries
without the new coverage require regeneration, without an MFRM refit.

Evidence is retained in `validation-results/person-fit-qc-20260919/`:

- `source-before/`, `baseline.log` and saved before tables retain the defect:
  one available probability of 1e-50 plus one unavailable response previously
  produced LogLik about -36.04 and FALSE unavailable correction flags. The
  complete one-response calculation now uses log(1e-50), about -115.13;
  the incomplete two-response calculation is unavailable.
- `replay.R`, `replay.csv` and `replay.rds` reuse seven saved fits and their
  diagnostics, with no MFRM refits. All 312 persons retain an available report
  index. Available raw lz changes are at most 7.6e-14 and corrected lz* changes
  at most 2.5e-12; the 47 available corrections and all seven full-sample
  unexpected-response percentages are unchanged. Four GPCM examples retain
  their existing uncorrected screens. Console captures contain no internal
  person-fit decision codes.
- Targeted checks cover tiny positive and zero probabilities, incomplete
  moments/derivatives, unit weights, nonfinite estimates, numerical convergence,
  mixed fit/diagnostics, missing mean squares, saved results, three-valued
  response classification, QC, summary/export tables and bundle/plot dispatch.
  Initial failures are retained: a short-iteration JML test fixture did not
  meet the new convergence requirement; QC summary lacked the new coverage
  marker; and missing diagnostic summaries were incorrectly refreshed.
  The fixture now converges, summaries retain their configuration and absent
  diagnostics remain unavailable. A subsequent mocked-readiness test changed
  the identity signature; it is replaced by a real one-iteration fixture.
  The initial package check then found the new direct-print S3 method missing
  from the test's expected registration list (672 passes, one failure, three
  intentional CRAN-mode skips). The list is updated and its four checks pass;
  the original archive and failed check are retained. Only that test file
  changes in the final archive; already-built vignettes are reused.

The final macOS CRAN-light `R CMD check --no-manual --no-vignettes` reports
0 errors, 0 warnings and 0 notes; 673 expectations pass, with three intentional
CRAN-mode skips. All affected focused tests pass; the QC fixtures retain 15
expected category-support warnings. Eight HTML vignettes were built with the
unchanged production source and are byte-identical in the final archive.
The checked archive matches 532 working source/help/test/data files exactly,
apart from generated DESCRIPTION metadata, and excludes maintainer records.
Its SHA256 is `7e7ce272aac720751fb73ab130dc3798f9d467e370b8c05b4af3af3edf48a582`.
Archive comparisons, full working diff, initial failures and final logs are
retained in the evidence directory. Console repository-index access warnings
are retained; installed dependencies suffice. This is not the full test suite,
final platform matrix, PDF manual check or release approval.

This is a computational and output-scope repair, not new statistical
calibration. The [original estimated-ability result](https://www.stats.ox.ac.uk/~snijders/publ.htm)
and [polytomous extension](https://www.cambridge.org/core/journals/psychometrika/article/abs/asymptotically-correct-standardization-of-personfit-statistics-beyond-dichotomous-items/CE79EC42DABC2767A4E95440EFA7B1DB)
do not supply finite-sample or multiple-person error-rate evidence for the
package's fitted many-facet routes. C11/C17 closure remains open. Remaining
mean-square/ZSTD report aggregates are the next bounded review.

### September 19: residual correlation computability and equivalence displays (C09/C11/C17)

This follow-up fixes two computational defects: directed A--B/B--A rows were
counted twice by Q3, and undefined PCA correlations were replaced with zero
before automatic smoothing. The latter can produce apparently usable
components from constant columns or inconsistent pairwise correlations.
Q3 now reports all unordered candidates, available/unavailable counts and
pair-specific reasons; unavailable flags remain NA, including aggregate flag
counts when nothing can be evaluated. Its heatmap uses the same calculation
and validates supplied fit/diagnostics identity. Neither an unflagged pair
nor an unavailable one establishes local independence.

PCA requires finite pairwise correlations and a positive semidefinite matrix,
allowing numerical roundoff. It does not remove unusable columns, impute
correlations or repair an indefinite matrix. Combined-facet label collisions
are refused rather than merging distinct columns. Failed calculations cannot
produce eigenvalue tables from their stored correlation matrix. The observed
and permuted matrices use the same check; any failed permutation withholds
the reference table, retaining the successful count and reason. Conditioning
on successful permutations would change the intended reference distribution.
This conditional permutation reference does not refit the model or establish
fitted-model false-positive control.

Requested PCA recalculates older stored results from the supplied observations
and respects changed component limits. Reporting only summarizes compatible
stored calculations; it does not silently add a PCA. Older saved PCA/Q3
summaries require regeneration. Reports retain PCA failures, including
facet-specific ones. Scree plots retain the descriptive unit-eigenvalue line;
unsupported 'critical minimum' and 'strong second dimension' labels are gone.
Numerical profile defaults remain uncalibrated descriptive references.

Equivalence's existing covariance-aware contrasts, TOST rules and readiness
restrictions are unchanged. The mean-deviation forest title and normal-mass
axis now match their actual targets. Printed equivalence and PCA summaries
use plain language without internal decision, basis or eligibility codes.
The prior [covariance repair](facet-equivalence-repair-record-0.2.4.md) remains
the numerical evidence; these display changes add no finite-sample coverage.

Evidence is retained in `validation-results/pca-q3-equivalence-20260919/`:

- `source-before/` and `constant-before.rds`: a constant-column input previously
  yielded eigenvalues approximately 2, 1 and 0; it now gives an explicit
  unavailable result. Regression checks also cover disjoint person overlaps,
  a pairwise matrix with minimum eigenvalue -1, valid singular matrices,
  incomplete permutations, cached/legacy results, label collisions and reports.
- `replay.R`, `replay.csv`, `replay.rds`: seven saved fits and unchanged
  diagnostics, with no MFRM refits. Q3 values are unchanged and 12 directed
  rows become six unique pairs in each case. Of 21 overall/facet PCA scopes,
  19 preserve eigenvalues within 1.8e-15. Two sparse weighted GPCM overall
  matrices are indefinite and now yield no PCA, replacing nine components
  from each automatically repaired matrix. Ten permutations per scope check
  the output path only; they are not a calibration study.
- The eligible saved MML equivalence bundle is identical before/after; other
  saved estimator/precision routes remain refused. Final display replay and
  affected tests check the ordinary output independently of numerical fields.
- The initial reporting regression exposed numeric-versus-integer component
  limits preventing cache reuse; canonical stored limits fix it. The initial
  replay script mistakenly nested four saved case wrappers; the corrected
  traversal reuses their existing fits. A generic bundle test had an older
  case-sensitive 'Adjusted Score' expectation; its matching is corrected.
  Original failure logs are retained alongside successful reruns.

Affected Q3/Person-fit, secondary plotting, report functions, reporting
contracts, equivalence, bundle dispatch and focused residual-screening tests
pass. The final seven-case console replay contains no internal eligibility,
method or covariance codes; the sparse saved-fit APA report retains the failed
overall PCA alongside available facet PCA. No new model fit or sampling study
is used for these display checks.

The final macOS CRAN-light `R CMD check --no-manual --no-vignettes` reports
0 errors, 0 warnings and 0 notes; 673 expectations pass, with three intentional
CRAN-mode skips. Eight vignettes were built before checking; check-time
vignette execution/rebuilding and the PDF manual are skipped. Console
repository-index access warnings are retained; installed dependencies suffice.
The checked archive matches 531 working source/help/test/data files exactly,
excluding generated DESCRIPTION metadata, and excludes maintainer records.
Its SHA256 is `1ba651be7ea190a25d16dade52c4d9f7a405f9bf571703a3499492c31e4565a7`;
the baseline, full working diff, archive/source comparison and logs are retained
in the evidence directory. This is not the full test suite, final platform
matrix or release approval.

The matrix-check rationale follows the [R correlation documentation](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/cor.html),
which explains undefined and non-PSD pairwise correlations, and the
[psych smoothing documentation](https://personality-project.org/r/psych/help/cor.smooth.html),
which describes how smoothing changes eigenvalues and the reconstructed matrix.
These repairs do not qualify universal PCA/Q3 cutoffs, equivalence coverage,
or the remaining fit/person-fit decisions. C09/C11/C17 and all 18 claim groups
remain open for release closure.

### September 19: G/D projection arithmetic and shrinkage interpretation (C13/C14/C17)

G-study variance components were rounded to six decimals before calculating
G/Phi or passing them to D-study. A score-unit change could erase all components.
Components now retain full precision and proportions have no absolute
variance-scale cutoff. The reported level counts use the actual mixed-model
rows; factor-valued scores use their numeric labels. The missing-ID and
numerical-warning routes are covered. Singularity and optimizer convergence
are distinct checks, as described in the [lme4 convergence documentation](https://lme4.github.io/lme4/reference/convergence.html)
and [singularity documentation](https://lme4.github.io/lme4/reference/isSingular.html).
Unresolved numerical warnings now require review rather than receiving an
identified coefficient band; a warning is not claimed to prove a failed fit.

D-study no longer substitutes zero for a missing/invalid residual or facet
variance. Missing residual makes G/Phi unavailable; missing facet-main-effect
variance withholds Phi while the relative-error calculation can remain
available. Negative components are invalid and duplicate sources are rejected.
Planned counts must be positive integers, and factor labels are read as numbers.
Missing identification information requests review. Old G/D outputs refuse
reuse/printing/plotting until recreated from the existing MFRM fit; the Gaussian
G-study is rerun, not the MFRM. Previously exported figures/tables must also
be regenerated. Default displays explain the observed-score target, omitted
variance-estimation uncertainty and residual-scaling assumptions in plain
language. These are point projections, not confidence bounds or validation of
cut-score accuracy, fixed-facet universes, interaction decomposition or a
recommended rating design.

Shrinkage still uses the existing zero-centered moment adjustment, with no
change to the original MFRM estimates or predictions. Its mean factor now uses
eligible estimate/positive-SE pairs; excluded pairs have unavailable factors
instead of diluting the mean with zero. Prior SD and Person-option arguments
are validated in the post-hoc route. The incorrect help example now states
that zero prior variance means full pooling, and the unsupported claim that
ShrunkSE is a guaranteed lower bound is removed. Sum-to-zero identification
is not treated as a known population mean or independent sampling errors.
Unequal shrinkage need not retain that constraint. EffectiveDF is described
as a conditional sum of retained weights, not degrees of freedom for IC/tests.

Shrunk SEs and optional normal bands remain descriptive plug-in quantities;
they omit prior-variance uncertainty and cross-level covariance. Zero width
after full pooling does not establish perfect precision. Both plot routes,
returned tables, manifests and Methods prose retain that interpretation. Raw
and shrunk point calculations are retained. Saved reports without the current
interpretation must be refreshed with the same shrinkage settings before
reusing report/plot/manifest routes; no MFRM refit is required. The checklist
records the choice to shrink or retain fixed effects, without recommending
shrinkage solely from small counts or claiming stability from large counts.
Ordinary Methods prose also omits optimizer/IC status codes; structured status
fields and comparison restrictions are unchanged.

Evidence in ignored `validation-results/gd-shrinkage-20260919/` includes
source-before files, direct regressions and a three-fit replay using saved
RSM JML, PCM anchored JML and RSM MML fits. No MFRM fitting or new simulation
occurs in the replay; G-study Gaussian fits are computed for the required
before/after and unit-change checks. Original and shrunk estimates/SEs are
numerically identical. The existing nine-row hand-calculated D-study example
is reproduced. The old missing-residual case gives G=1; the corrected result
is unavailable. The old small-unit example loses every variance component;
the corrected one retains them. The initial replay assertion compared vector
names as well as numeric values; the retained inspection shows identical
numbers and the revised assertion explicitly checks those numbers. Existing
Q3/Person-fit, shrinkage, secondary-plot, reporting and output-stability files
pass; the repository's deterministic public one-stratum formula check also
passes after declaring its current synthetic input version. Final display
checks exercise the D-study curve/surface and shrinkage renderers without
creating new user-facing figures or research artifacts. This is not new
calibration evidence for shrinkage intervals or G/D decisions; all affected
claim groups remain open.

The final source archive matches 530 working source files, excluding generated
DESCRIPTION metadata, contains eight built vignettes and excludes maintainer
records. Its hash, comparison manifest and cumulative diff over `ff0675b` are
retained. The macOS CRAN-light `R CMD check --no-manual --no-vignettes` finishes
with 0 errors, 0 warnings and 0 notes; 673 expectations pass and three are
intentionally skipped in CRAN mode. Check-time vignette execution/rebuilding
and the PDF manual are skipped; vignettes were built before checking.
Dependency-index access warnings in the console are retained; installed
dependencies sufficed. This is not the full statistical test suite, final
platform matrix or release approval. The final Methods replay uses the same
three saved fits after removing raw optimizer/IC status text; no refitting
occurs in that display check.

### September 19: QC decisions, imported uncertainty and linking displays (C05/C08/C11/C16/C17)

The QC pipeline previously imposed minimum reliability and separation across
all non-Person facets, thereby treating low rater differentiation as poor
quality even when distinguishing raters was not the user's purpose. The new
`separation_facets` argument makes that purpose explicit; unrequested checks
are marked Skip and excluded from the overall result. The returned
`AffectsOverall` field records this policy. Reliability and separation remain
related indices from one variance decomposition, not independent evidence of
quality. Numerical convergence and inferential eligibility are distinguished
in ordinary output without changing the convergence gate. A QC Pass states
only that the selected screening rules passed; universal cutoffs or error-rate
control are not established.

Missing global fit, element fit, unexpected-response and connectivity results
now request review rather than becoming passing defaults. Diagnostics must
match their fit. Each PCM threshold ladder is checked separately in numeric
step order; unavailable estimates cannot count as ordered thresholds. The
rater screen no longer guesses that the first facet is a rater. Recommendations
no longer treat disordered thresholds alone as a reason to collapse categories.
Old QC objects and summaries must be recreated from the existing fit/current
diagnostics before printing or plotting; no model refit is required.

Imported diagnostics use the shared finite-estimate/SE denominator and expose
its counts. Missing required SEs withhold reliability/separation. Imported
marginal SEs alone do not supply the joint covariance and estimator assumptions
needed for a joint facet test, so synthesized chi-square statistics, degrees
of freedom and p-values are withdrawn. Point estimates and original SEs are
unchanged and retain their source-package interpretation. Native QC explicitly
refuses imported fits. Existing source-package fits can be re-imported with
`compute_fit = TRUE`; stale imported diagnostics request that step. Previously
exported tables are not rewritten automatically.

Linking calculations and flags are unchanged. Ordinary drift, chain and
linking-review output explains that source-parameter, estimated-offset and
cross-fit covariance are not fully propagated. `Offset_SD` is residual spread,
not offset uncertainty, and cumulative offsets do not propagate uncertainty
across links. Common-element counts do not establish invariance. The retained
[offset sensitivity record](offset-sensitivity-record-0.2.4.md) fixes source
estimates and therefore cannot qualify full refit/linking uncertainty.
Structured risk/status tables remain available; default printing uses plain
review guidance and omits internal status codes.

Evidence is retained in ignored `validation-results/qc-import-20260919/`.
QC and full import regression files pass, including mirt/TAM/eRm import paths,
hand-calculated incomplete-SE cases, stale-result refusals and missing-result
checks. The QC fixture emits 15 known category-support warnings, including
three added cases; no warning is suppressed as a release decision. Nine saved
fits replayed without re-estimation preserve unchanged QC checks exactly;
explicitly selecting all non-Person facets reproduces the old differentiation
values/verdicts. One saved PCM JML fit confirms the cross-ladder ordering bug.
Final QC print replay omits raw readiness/status codes. Output-stability and
summary-table-bundle regressions pass. The initial linking display assertion
failed only because the new sentence wrapped; the log is retained and the
assertion normalizes whitespace. The complete linking regression file passes
on the final display code. A macOS CRAN-light packaged check finishes with
0 errors, 0 warnings and 0 notes; 673 expectations pass with three intentional
CRAN-mode skips. Eight vignettes were built; check-time vignette execution and
rebuilding, and the PDF manual, were skipped by the stated command. Console
dependency-index access warnings are retained; installed dependencies sufficed.
The checked archive matches 530 working source files byte for byte, excluding
generated DESCRIPTION metadata, and excludes maintainer records. Baseline
`ff0675b`, the cumulative diff, archive hash and comparison manifest are retained
alongside the logs. No estimator or new sampling study is introduced. This
work qualifies no new uncertainty estimator, linking invariance test, or
complete claim group; full release-source/platform checks remain pending.

### September 19: reliability denominators and model-choice output (C04/C05/C11/C17)

The shared variance decomposition previously selected finite estimates and
finite SEs independently. It could subtract error variance from a different
set of levels, or continue with available SEs when a finite estimate's SE was
missing. The calculation now uses SEs only on the finite-estimate population
and withholds RMSE, error-adjusted spread, reliability, separation and strata
when any of those SEs is missing. Observed spread and SE-availability summaries
remain available. Tables retain counts and readable calculation notes;
non-finite estimates are explicitly excluded. Facet-level formal-reporting
eligibility requires complete, affirmative row eligibility and complete
estimates/SEs; convergence or missing flags no longer supplies permission.
Native diagnostics lacking the new denominator record must be regenerated
from their existing fits before reuse. Previously exported files are not
rewritten.

QC no longer drops an unavailable non-Person facet from the minimum
reliability/separation statistic. Ordering checks with no finite comparison
pairs request review instead of passing. Help and ordinary diagnostic output
state that fit-adjusted indices are not confidence bounds, rater separation
is not agreement, and the separation-based index using Person EAP estimates
is not posterior-variance EAP reliability. No new reliability estimator,
coverage qualification, or universal QC threshold is established here.

Weighting reviews now read numerical convergence separately from inference
eligibility. A numerically converged GPCM with incomplete identification or
boundary checks remains descriptive without being called an optimizer trace.
The helper retains the current prohibition on free-slope GPCM ranking even
if a supplied comparison flag says otherwise; it no longer suggests that a
user can enable that ranking simply by increasing quadrature or repairing
readiness. Standard weighting/model-choice displays omit machine status
codes, while structured tables retain them. Saved review objects and saved review summaries lacking the numerical
convergence record refuse printing until rebuilt from their existing fits.

Bounded evidence is in ignored `validation-results/reliability-choice-20260919/`.
Hand calculations cover unmatched finite rows, missing SEs, exclusions and
missing eligibility flags. Regression tests cover numerical versus inferential
readiness, model-choice/weighting displays, QC, output stability and reporting.
All seven selected files pass; the QC fixture emits its existing category
support warning in 12 tests. The first run retained three stale warning-text
assertions in model-choice tests; these were updated to the current quadrature
warning and rerun. Additional QC assertions verify unavailable ordering checks.
Nine existing fits are replayed without fitting: three JML boundary/anchor/MML
fixtures, two earlier RSM MML/JML controls and four GPCM integrations spanning
both slope owners and complete/weighted weak-bridge data. Every previously
reported numeric reliability and facet-precision value is identical, while
counts explicitly expose two and one excluded Persons in the two extreme-JML
cases. Two saved GPCM fits additionally exercise the model-choice display;
they use different prepared data, and the output explicitly withholds
comparison for that reason as well as the GPCM inference restriction. This
is an output/refusal replay, not a comparable model-selection experiment.

The source remains a working tree over `ff0675b`. Source-before copies,
replay scripts, outputs and test logs are retained. Saved-review and summary
appendix regressions pass after the compatibility guard; final display replay
also confirms the two saved GPCM fits show numerical convergence as passed
while inference remains unavailable. A macOS CRAN-light `R CMD check` on the
final archive reports 0 errors, 0 warnings and 0 notes (673 passed expectations,
3 intentional skips). Vignettes were built; their check-time rerun/rebuild and
the PDF manual were skipped. Console dependency-index access warnings from the
restricted network are retained; installed dependencies sufficed. The archive
matches 530 working source files exactly, excluding generated DESCRIPTION
metadata; its hash and manifest are retained. The earlier clean check predates
the saved-review compatibility guard and is retained separately. Neither check
is the complete statistical/local test suite or final platform matrix. Claim
groups remain open.

### September 19: JML conventions and extreme-score displays (C03/C05/C12/C17)

The JML follow-up reconciles the public estimator with the retained
[matched-mode comparison](tam-immer-jml-mode-comparison-record-0.2.3.md),
[extreme-profile pilot](jml-extreme-profile-recovery-pilot-record-0.2.3.md),
[factor pilot](tam-immer-jml-factor-pilot-record-0.2.3.md), and
[topology smoke](tam-immer-jml-topology-calibration-record-0.2.3.md).
Their original source identities and limitations are unchanged. Matching raw
RSM/PCM kernels on finite no-extreme cases does not match score-adjusted or
postscaled estimators. Potential-panel and observed-exposure correction factors
diverge under missing or unequal response panels. The profile calculation
addresses non-attainment, not finite-exposure incidental-parameter bias.
The five-replicate recovery traces do not choose a correction, and the
topology smoke has no raw-JML-eligible connected datasets or qualified common
surface coverage. The unexecuted 180-dataset pilot is not resumed unchanged.

The 0.2.4 disposition is explicit: public JML uses observed scores without
extreme-score adjustment or a finite-item bias correction. Independently free
extreme Persons retain infinite primary estimates, fixed anchors remain fixed,
and coupled constraints require separate review. JML SEs/normal bands remain
exploratory. No corrected-JML estimator or public profile-limit estimator is
introduced. Help, NEWS, the public roadmap and native fit printing distinguish
these conventions from optional display adjustments.

Two concrete reporting defects were reproduced and corrected:

- `fair_average_table(..., xtreme > 0)` replaced the displayed measure without
  retaining the original measure in that table. It could attach an original
  MML posterior SD or anchored-JML approximate SE to the replacement.
  Tables now preserve `PrimaryMeasure`, including infinities, a readable
  `MeasureBasis`, and the exact score-unit `ExtremeAdjustment` in raw/formatted
  tables and CSV. Displayed values are unchanged; measure SEs on replaced
  rows are unavailable. This option does not refit, change anchors, or correct
  JML bias. Summary notes state the distinction.
- The non-Person FairM reference previously averaged finite optimizer Person
  coordinates even when the primary JML Person estimates were infinite.
  It now uses primary Person measures and withholds non-Person FairM when
  their mean is unbounded. `FairMReference`, summaries and plot messages state
  why; FairZ's zero reference is unchanged. No arbitrary optimizer stopping
  point is substituted for the missing mean.

Saved fair tables lacking the original-measure/reference basis are rejected
by summary/plot routes; printing an older fair-summary object also requests
recreation. Native saved diagnostics containing those old tables
must be recomputed before downstream reporting. Reuse the fit and original
options; no refit is required. Previously extracted CSVs and standalone
summaries must be recreated. The current calculation does not rewrite them.

Bounded software evidence is retained in ignored
`validation-results/jml-conventions-20260919/`. Three small public-workflow
fixtures use the existing boundary-test data: RSM JML, PCM JML with a fixed
extreme Person, and RSM MML. The initial probe's invalid list-form anchor input
is retained; the corrected run uses a supported anchor table. The fitted
objects are then reused. Previous numeric outputs agree exactly except for
the deliberately withdrawn adjusted-measure SEs and non-Person FairM in the
two unbounded-JML cases; FairZ and all fitted estimates remain unchanged.
The first test run exposed empty vector-name attributes on the new measure
column; removing those attributes resolves the assertions without changing
values. Fair-score/interval, Person-boundary, IC-display and complete shared
readiness-propagation regression checks pass. The GPCM fair-score file passes
except for two obsolete console-text assertions from the earlier display
cleanup; these are updated, and its affected public-workflow block passes.
A saved no-extreme RSM JML fit supplies an additional no-refit control: every
previous fair-table value is identical. The source archive includes built
vignettes and matches 529 working source files; its hash, baseline, source
copies, cumulative diff, manifests, first failures and follow-up logs are
retained. The first package check reports only an R-code NOTE about four new
bare column names; explicit `.data` references resolve those bindings.
The corrected macOS CRAN-light `R CMD check --no-manual --no-vignettes`
finishes with 0 errors, warnings or notes (673 passes, three intentional
CRAN-mode skips). Vignettes were built beforehand; their code/output rebuilding
is skipped by the stated check command. Repository-access warnings remain in
the console log; the check uses installed dependencies. A subsequent NEWS-only
clarification states that display replacement also requires an available mean
reference. The rebuilt archive differs from the checked archive only in NEWS
and the generated DESCRIPTION packaging timestamp; all other packaged file
bytes agree, and both hashes are retained. No full
statistical suite or cross-platform matrix is rerun for this bounded repair.
These are software checks, not new recovery, interval-coverage or
correction-selection evidence.

The old studies remain historical evidence with their own scope. Broader JML
recovery/uncertainty, GPCM boundaries, and remaining reliability and model-choice
reporting claims are still open; this is not whole C03/C05/C12/C17 closure.

### September 19: precision eligibility and comparison reporting (C03/C04/C05/C09/C17)

The next review traced existing JML/GPCM uncertainty and model-comparison
restrictions through diagnostics, precision reports, summaries and exports.
Two defects were reproduced. `build_measure_se_table()` discarded the
regularized-Hessian status when assigning facet SE labels, so such rows could
receive ordinary `CIEligible`/`SupportsFormalInference` approval. It also
labelled an unavailable model-based SE as model-based even when the numeric
value came from the observation-table fallback. Separately, precision checks
used overall inference readiness as if it were numerical convergence: four
saved, numerically converged GPCM fits were described as needing optimizer
review while their precision tier received a pass.

The shared SE builder now carries regularization and fallback provenance into
row eligibility and the precision profile. These SEs and normal bands remain
diagnostic only. Existing step uncertainty already excluded regularized
covariance, and facet equivalence already required unregularized information;
those restrictions are retained. The new row restriction changes eligibility,
not the SE or interval calculation. Precision checks use the actual numerical
component separately from inferential support. JML advice no longer implies
that changing to MML alone validates SEs, intervals or reliability.

Saved diagnostics without the new precision provenance must be regenerated
with `diagnose_mfrm(fit)`; the fit itself need not be refitted. Shared reporting
identity checks, diagnostics summaries and the precision accessor enforce this
restriction. Old precision reports/summaries must likewise be recreated.
Previously extracted raw tables or assembled exports are not recomputed by
updating the package; users must recreate them from current diagnostics.

Comparison calculations and restrictions are unchanged. Warnings and default
printing explain unavailable rankings/tests without raw readiness codes.
`InferenceReview` and `ReadinessReasonCodes` preserve readable reasons and
machine-readable detail in the table. Documentation now explicitly says that
the structural PCM-in-GPCM relation does not authorize GPCM IC ranking or an
LRT. JML/GPCM refusals and the separate conditions for facet equivalence remain.

Evidence in ignored `validation-results/precision-comparison-20260919/`:

- The before-output log and source copies retain the reproduced GPCM review
  defect. The regularization propagation reproducer holds the covariance
  matrix fixed and changes only its status to exercise the relevant branch;
  it is a controlled software test, not a newly observed near-singular fit.
  The unavailable-model-SE test similarly checks fallback provenance.
- Six saved fits are reused: the earlier RSM MML/JML pair and the four
  adaptive-Q61 GPCM fits spanning both slope owners and complete/weighted weak
  designs. New diagnostics reproduce every existing numeric measure column
  exactly. Comparison statistics, LRT availability and preferred lists also
  exactly match the saved pre-edit source functions. No fitting or response
  generation occurs in this replay. All four GPCM numerical checks pass while
  their precision checks remain under review; JML inference remains unavailable.
- Focused SE/legacy-output/report/comparison tests pass. Complete readiness
  propagation and results-readiness files pass, including eligible connected
  controls and ineligible designs. The initial runs retain a vector-name
  assertion failure, obsolete warning-text expectations and a nested-warning
  capture failure; these are corrected without changing the numerical or
  inferential restrictions. Two existing category-support fixture warnings
  remain visible in the comparison tests.
- Edited help is regenerated and checked. The source tarball and local
  CRAN-light check are retained separately from the earlier package/platform
  evidence; this is not the final release source or a new statistical study.
  The final console replay uses the six saved fits without new diagnostics or
  fitting; precision displays omit internal column/tier names and JML
  comparisons omit inapplicable MML-only failure reasons. The weighting-review
  help now also states the enforced GPCM ranking restriction. The checked
  archive matches 529 working source files byte for byte, includes built
  vignettes and excludes maintainer validation records. Its SHA-256, baseline
  commit, cumulative working diff and comparison manifest are retained locally.
  The macOS `NOT_CRAN=false R CMD check --no-manual --no-vignettes` finishes
  with 0 errors, warnings or notes; the light suite has 673 passes and three
  intentional CRAN-mode skips. Vignettes were built before the check; their
  code/output rebuilding is skipped by the stated check command. The first
  preparation omitted built vignettes and produced two packaging warnings;
  that log is retained. Dependency-repository access warnings in the console
  also remain recorded; installed dependencies suffice for the local check.

This closes the reproduced SE-provenance and review-language defects. JML
mode-specific recovery, full-model GPCM boundary/uncertainty questions, broader
precision/reliability calibration and finite-sample equivalence-test behavior
remain open. Neither numerical convergence nor passing these software checks
establishes those statistical claims.

### September 19: portable scope and interval reporting (C07/C17)

The portable review found two concrete publication defects. The public roadmap
incorrectly excluded all portable interactions, although extraction, stored
interaction coordinates and scoring already supported compatible fixed-normal
RSM/PCM MML fits. Separately, the normal score displays omitted the saved-v1
interval caveat, and exported estimate tables could not distinguish v1 grid
endpoints from v2 continuous intervals or identify their requested level.

The roadmap now matches the existing two-way interaction support. A focused
public-API replay covers RSM and PCM: same-data q5/q7 review, exact q7 fit
extraction, validation/freezing, save/load, and new-Person scoring on the stored
31-point scoring rule. Both agree with the corresponding fitted-object scores.
These small grids are software fixtures, not operational recommendations or
evidence of interaction inference, transport, or adequate integration generally.

Returned score tables now include `ScoringAlgorithm` and `IntervalLevel`.
Summaries retain them and recover them from stored settings in earlier score
objects; the requested level is not rounded with the estimates. Normal console
output replaces support-profile/review codes with the prior and plain reasons.
Score printing and interval figures state the level and the actual continuous
or saved-grid interpretation. Machine-readable identities and refusal codes
remain available. No schema, eligibility, likelihood or interval calculation
was changed; v1 artifacts retain their original endpoints.

Evidence is in the ignored `validation-results/portable-workflow-20260919/`:

- Initial existing interaction-coordinate/scoring tests passed before edits.
  The public API tests and the selected lifecycle tests passed after edits,
  followed by the remaining lifecycle tests. The source-tree fresh-process
  test skipped because it requires an installed package.
- `replay.log` / `replay.csv` compare all four fixed/adaptive v1/v2 scoring
  algorithms against `ff0675b` source functions on the same artifacts/rows:
  existing estimates, settings and Person dispositions are exactly unchanged.
  Save/load is identical. Console files retain both old and corrected output.
- The two existing 27-Person RSM/PCM result objects from the September 14
  Linux replay preserve estimates and review tables when re-summarized, and
  CSV retains the recovered algorithm/level. No new responses or coverage
  experiment were generated.
- Actual base and ggplot interval figures were inspected. The initial base
  caption overlapped its axis label; increased bottom spacing resolves it.
  Modified help was regenerated and the three calibration help pages checked.
- The current source tarball was built without rebuilding vignettes for an
  isolated installation. Its public-API fresh-process test passes, including
  exact scoring agreement and the new algorithm/level fields. This is not a
  full package check or final release candidate. Build/install results and
  source identities are retained alongside the focused tests.

This closes the identified portable scope/reporting defects and adds bounded
workflow evidence. It does not close population transport, calibration
uncertainty, interaction inference, all input combinations or the whole C07/C17
groups. Final-source applicability and platform checks remain release work.

### September 19: portable review consistency and source applicability (C07/C17)

The next workflow review reproduced an extraction gap: a review whose lower-grid
fit was replaced by the higher-grid fit, whose replay anchors changed, or whose
retained lower-grid fit no longer converged still passed. The extraction guard
checked the review table and shared response data, but did not bind every
retained fit to its stated order, settings and actual convergence state.

Extraction now also compares the retained fit orders, replay arguments,
resolved model/constraint components and score maps, and checks convergence
on each fit. Differences in anchors, integration mode, optimizer settings or
resolved facet signs are refused. Row reordering remains accepted. This is a
consistency check on the supplied review, not authentication or certification
that quadrature error is small enough. Scoring, persistence and interval
calculations are unchanged; no schema migration is needed.

Evidence is in `validation-results/portable-boundary-20260919/`:

- The public API, full calibration lifecycle and RSM/PCM sensitivity test
  files pass, including direct/group anchors and RSM/PCM interactions. The
  existing adaptive persistence/scoring test passes for RSM and PCM. An initial
  test used an unsupported `info` argument to `expect_s3_class`; that harness
  error and its correction are retained.
- The earlier portable source manifest agrees byte for byte for ten relevant
  calibration, scoring, integration, likelihood, readiness and display files.
  Other accumulated package changes are listed separately; the old package
  checks are not relabelled as checks of the whole current source.
- A newly built archive matches all 535 packaged working files apart from
  generated DESCRIPTION metadata, includes eight built HTML vignettes, and
  excludes maintainer records. SHA-256:
  `8a1fd8aade8be5b16068cdc9e10d65dac0675db8f8c4c5f600bb000230d03438`.
  Isolated installation and installed extraction-guard checks pass.
- Fresh-process scoring of four saved RSM artifact fixtures (fixed/adaptive
  v1/v2) exactly
  preserves estimates, settings and Person/row dispositions against the
  earlier portable installation. CSV retains Person identity, calibration,
  scoring/uncertainty basis, algorithm and unrounded level. Separate disposition
  CSV retains the all-missing Person. Earlier score tables recover interval
  identity when re-summarized. Initial CSV comparisons incorrectly required
  R row-name attributes, which `row.names = FALSE` intentionally omits; the
  corrected checks compare Person keys and column values, with unchanged
  numerical tolerances. Both failure logs remain recorded.
- Help regeneration/checking and normal console review pass. Console output
  states the prior, interval interpretation, omitted calibration uncertainty
  and readable review reasons without internal status codes.

This closes the reproduced extraction-consistency defect and supports the
bounded current-source workflow. The archive has not undergone a new complete
package/platform/manual check. Earlier numerical and interval studies retain
their original sources and targets; this replay is not calibration-uncertainty,
transport, interaction-inference or group-wide release approval.

### September 20: external import coordinates and source uncertainty (C05/C16/C17)

The September 19–20 source review reproduced three substantive mapping defects:
eRm cumulative easiness coefficients appeared as multiple item difficulties with
the wrong sign; TAM coefficient-name parsing confused category parameters with
items; mirt multidimensional scores could put the second factor in the SE column,
and rating-scale offsets were omitted. Native summaries additionally asserted
population/slope assumptions absent from the imported object. The original
implementation and adverse probes are retained in
[`validation-results/import-metric-20260919/`](../../validation-results/import-metric-20260919/).

The repaired mapping uses one mean adjacent-category difficulty per item.
eRm cumulative coefficients are differenced and negated; the item location is
minus the last cumulative coefficient divided by its category-step count, with
the same scalar SE transformation. TAM uses successive source category logits
and their constant positive slope. A TAM location SE is retained only for a
single-coefficient linear transformation with a fixed slope; otherwise missing
joint covariance leaves it unavailable. TAM multi-facet coordinates now describe
combined response-design conditions, not reconstructed separate facet effects;
the original coefficient table is retained. mirt imports use supported 1D
Rasch/partial-credit models with positive slopes and ordinary category scoring,
including `b - c/a` for gpcmIRT/rsm. Source identification is not rescaled.

mirt/TAM Person estimates retain EAP with conditional posterior SD, excluding
calibration uncertainty. TAM Person fit remains source WLE-based and is labelled
separately; item fit uses posterior-averaged per-item statistics. Source posterior
SDs no longer supply sampling SEs for separation reliability. Missing covariance
still prevents joint facet tests. Original mirt Person identifiers discarded by
the source object cannot be reconstructed; generated row labels say so.
eRm extreme-response extrapolations retain their labels.

Public summaries and base/ggplot Wright maps describe the source ability scale;
Wright maps show points only. Native curves, QC, comprehensive `mfrm_results()`
reports and portable calibration are outside this adapter scope. Re-import old
bundles from the existing source fit, then recreate displays and exports; no
source model re-estimation is needed. NEWS, roadmap and help state these limits
without maintainer claim/version codes in ordinary output.

Verification reuses 12 saved native fits: seven TAM fits (three parameterizations
plus four existing RSM/PCM baseline/missingness fits), three mirt fits and two eRm
fits. Item/threshold and probability comparisons have maximum absolute error
7.11e-15; source EAP/SD values are unchanged. Wright coordinates and CSV threshold
meaning survive the same replay. Two adverse saved mirt fits are refused for
multidimensionality/negative slopes. This is coordinate/adapter evidence, not
estimator recovery, interval coverage or a new external agreement study.

Four relevant test files pass 340 expectations without failures, warnings or
skips, including direct source probability/threshold and eRm covariance checks,
equivalent TAM parameter designs, missing covariance, imported-output restrictions
and native summary regression. The eRm check also covers RSM. Base and ggplot
renders retain the source axis and omit uncertainty bands. Initial test-harness
failures (CSV list columns, vector name attributes and a polytomous Rasch fixture
mislabelled RSM), the discarded-mirt-ID expectation, and an empty-tibble print
warning are retained with their corrections; no numerical tolerance was relaxed.

The checked-code source archive
`62dee8ae2aaea90d7fcb789c1e829c566d0ca39e44bb279aaafe77a8c1cca4d8`
passed macOS CRAN-light `R CMD check --no-manual --no-vignettes` with zero
errors/warnings/notes, 673 passing expectations and three intentional skips.
Its isolated installation passes the 72 new adapter expectations and repeats
the 205 saved-fit comparisons. These runs are not a new full-suite or
five-platform qualification.

The final help clarification limits `compute_fit = TRUE` advice to mirt/TAM.
It changes only roxygen comments and three generated importer Rd pages; all
parsed R expressions remain identical to the checked-code archive. The final
rebuilt archive
`6d1f9d379492411bd36e9a8d736b6458b59bdd1e33c53955219eed5d177ec1b4`
matches 536 working files apart from generated DESCRIPTION, contains eight
built HTML vignettes and excludes maintainer records. The first checked archive
identity and its test logs are retained separately. Rd checks pass, and the
numeric tests are not repeated for this documentation-only clarification.
The final archive's `R CMD check --no-tests --no-manual --no-vignettes` also
finishes with zero errors/warnings/notes; its examples, Rd and package checks
pass. The test pass counts above belong to the checked-code run, not this
test-skipping documentation check.

Primary definitions were checked against installed mirt 1.47, TAM 4.3.25 and
eRm 1.0.10, with their corresponding documentation:
[mirt coefficients](https://philchalmers.github.io/mirt/html/coef-method.html),
[mirt model equations](https://philchalmers.github.io/mirt/reference/mirt.html),
[mirt scores](https://philchalmers.github.io/mirt/reference/fscores.html),
[TAM category model](https://alexanderrobitzsch.github.io/TAM/reference/tam.mml.html),
[TAM item fit](https://alexanderrobitzsch.github.io/TAM/reference/msq.itemfit.html),
and [eRm definitions](https://statmath.wu.ac.at/~hatz/IRT/R/eRmvig.pdf).
All 18 claim groups remain unclosed and their dispositions are unchanged;
these bounded adapter repairs do not certify source estimation or release
readiness.

### September 19: existing residual outputs and FairZ disposition

Following the accepted release review, the existing residual-comparison route
now retains group/cell means, counts, scaled residuals and pair contrasts as
descriptive quantities. It no longer reports residual-contrast SE/t/df/p,
confidence intervals or binary DFF classifications. The interaction table
retains only the explicit absolute residual-mean comparison in score units;
its old t-based flags are NA. Reports and plotted data preserve these meanings.
Older residual analyses, summaries and reports must be regenerated from the
existing fit and data before public display; no model refit is needed.
Residual signal-detection outputs preserve unavailable rates as NA. Existing
simulation objects can be re-summarized without repeating their simulations.
This closes the identified residual-output decision defect, not all C10/C15/C17
subclaims, and does not establish a new formal test or change fit readiness.

The joint-covariance FairZ candidate is deferred beyond 0.2.4. The completed
20,000-dataset study retains its original five supported/three review cells,
source identity and failures. Existing conditional diagnostic intervals keep
false inferential eligibility. Six saved RSM/PCM tables (native/legacy/both
labels) are exactly unchanged; two saved-fit residual comparisons also match
the prior implementation exactly for all retained numeric values. Arbitrary
A/B groups were added to those saved input rows only to exercise reporting;
these are software replays, not no-DRF or power experiments.

Focused regression checks cover residual statistics and unavailable states,
legacy analyses/summaries/reports, CSV interpretation, plots and simulation
summaries. The initial DFF selection had one failure expecting old report prose;
the affected test passed after its expectation was updated. Subsequent checks
found an old FairZ wording expectation and a missing printed residual note;
the wording test and note representation were repaired. A caption expectation
also now allows the existing ggplot line wrapping. Final relevant checks
pass; three category-support warnings in the targeted DFF rerun are retained
fixture warnings. Earlier broader DFF checks remain applicable to untouched
refit/validation paths and are not counted twice.

Saved-output replay initially failed because the replay script assumed a
`person_col` field in a saved config. It was corrected to use the existing
Person-column fallback; production code was not changed for that failure.
The completed replay also exercises base and ggplot output. Edited help files
were regenerated and checked with `tools::checkRd()`. Console examples retain
plain-English interpretation rather than release/readiness codes. Figure QA
uses temporary renders of these existing public plots; no new visualization
feature or research figure was added.

The retained logs, replay receipt, runner copies and source identities are in
`validation-results/public-output-20260919/`, based on HEAD `ff0675b` plus the
recorded working diff. No new response simulation study, broad package/platform
check, release freeze or release approval is claimed. Next close the bounded
portable workflow and the exact remaining retained subclaims using existing
evidence before additional computation.

### September 18 follow-up: portable score summary tables (C07/C17)

On source baseline `d1c363d`, `summary(scores)$estimates` dropped the existing
`EstimateBasis`, `UncertaintyBasis`, `CalibrationId`, `SchemaVersion` and
`ScoringBasis` columns. The complete summary already retained interpretation
notes, but extracting its table lost these row-level fields. The summary now
preserves the available columns, including in empty score tables; console
previews and scoring calculations are unchanged.

The saved RSM and PCM objects in
`validation-results/person-estimated-calibration-20260914/linux-artifact-replay/cell-01.rds`
and `cell-05.rds` reproduced the loss. Replaying their summaries locally after
the repair preserved all prior columns and other summary components exactly;
both 27-Person tables retained the five fields through CSV round trips. The
saved objects were unchanged. The affected `test-calibration-public-api.R`
file passed 149 expectations with no failures or warnings and one expected
skip requiring a check-installed package. New regression checks cover the
summary/CSV fields, score rounding and the empty-table schema.

This closes the identified table-output defect. Intervals remain conditional
on the frozen point calibration and exclude calibration-parameter uncertainty.
It adds no statistical coverage evidence and does not close C07/C17 as a whole
or replace the final-source package/platform checks. No new calibration study,
full-suite rerun or development visualization was needed.

An installed-source follow-up at `6459a95` built and installed mfrmr in an
isolated temporary library using the available dependencies. The previously
skipped fresh-process artifact-scoring test passed all eight expectations,
without warnings or skips. A first whole-file installed run had 141 passes
but failed its vignette lookup because the build intentionally used
`--no-build-vignettes`; it is not recorded as a whole-file pass. An initial
attempt to isolate the test also failed in reporter initialization before
the test body ran. The final run used the unchanged fixture and target test
through `testthat::test_file()`. Build/install logs and both unsuccessful
attempts are retained with the successful log under
`validation-results/portable-installed-20260918/`. This completes that specific
installed-process check, not a new full package check.

### September 18 follow-up: DRF interpretation (C10/C15)

The [location and scope decision](interval-drf-preflight-record-0.2.4.md#september-18-drf-scope-and-location-decision)
resolves the algebraic treatment of facet centering using all 22 saved cases.
It separates a future matched fixed-population null from population
misspecification and preserves the original executions. Public DFF help now
keeps group ability differences distinct from differential functioning and
removes unsupported small-subset and multiple-comparison error-control claims.
The current scope remains screening; a matched null/power study and formal
inferential qualification are not completed by this documentation repair.

The subsequent [null-statistic audit](interval-drf-preflight-record-0.2.4.md#september-18-follow-up-which-null-does-the-statistic-test)
finds a distinct obstacle: even with known, correctly specified calibration
and group populations, EAP-based mean residuals can differ when DRF is zero.
The 64-pattern enumeration separates this centering problem from variance
approximation; an SE correction alone cannot repair the target. Eight fits using
the existing joint-MML API on four saved datasets reproduce continuous-integral likelihoods
within 3.56e-8, but all four public LRTs remain unavailable under the current
estimability contract. No finite-sample error-rate or power claim is added.

The [joint-null follow-up](interval-drf-preflight-record-0.2.4.md#september-18-follow-up-regularity-at-the-joint-null-and-comparison-reasons)
also finds full continuous-integral information rank at all four embedded
zero-interaction points and positive nuisance-adjusted interaction information.
Only inference readiness fails among the implemented comparison requirements;
this is not a finding of nonidentification or optimizer failure. Comparison
warnings now identify the fits and their actual readiness reasons. This left
a scoped population-model acceptance decision pending.

The subsequent [qualification decision](interval-drf-preflight-record-0.2.4.md#september-18-scope-decision-qualify-the-omnibus-comparison-separately)
specifies the first omnibus target and separates its size/availability evidence
from population-coordinate and Person-interval coverage. It also repairs an
automatic nesting gap: population designs must match by Person, while nuisance
estimates may differ. Existing legitimate comparisons and their readiness
restrictions are preserved. This closes that structural-classification defect,
not the omnibus test's inferential qualification (C02/C10/C15 remain open).

The [paired-fit numerical preflight](interval-drf-preflight-record-0.2.4.md#september-18-follow-up-paired-joint-fit-numerical-stability)
then qualifies full-coordinate stationarity and start stability at q121 in
the four saved pairs; checked zero-variance solutions have worse likelihoods.
Two original q61 PCM vectors fail the strict gradient-agreement bound, and
those outcomes remain visible alongside the successful q121 comparisons.
There are no new response datasets or production readiness changes. The September 19 release-scope decision defers this new omnibus test;
procedure-level null calibration remains absent.

### Original reconciliation checkpoint

- The current `NAMESPACE` has **182 exports and 191 S3 registrations (373
  declarations)**. The old inventory has 372. The missing declaration was
  `plot_compare_mfrm()`, now mapped to C02/C03/C04/C05/C17. All current function
  source locations were resolved again. These are entry points, not 373
  independently validated analyses.
- C09's omitted contrast covariance and unsupported equivalence decisions are
  **repaired implementation defects**, not current outstanding defects. The
  six-fit current-source probe and analytic regression checks pass. This does
  not close finite-sample equivalence-test calibration.
- The Gauss–Hermite zero-weight defect is repaired, with later adaptive
  integration and external comparisons. A universal accurate quadrature order
  has not been established; small retained weights and adequate integration
  are separate requirements.
- Recent Person studies now distinguish a known calibration, an estimated
  calibration, a learned normal population and population transport. None
  substitutes for population-parameter interval validation or unconditional
  propagation of calibration/linking uncertainty.
- Public G/D-study, shrinkage, external imports and descriptive network/time
  routes have explicit dispositions below. Broader repository research models
  cannot supply evidence for a different public calculation.

## Claim-by-claim disposition

The [machine-readable ledger](claim-reconciliation-0.2.4.csv) records supported
scope, evidence, restrictions, source applicability and the next check for
each group. “Bounded evidence” below means support for the stated conditions,
not group-wide acceptance. Every row retains follow-up; none issues release
approval.

For example, `coverage_complete` in a precision table describes completeness
of the table's combinations; it is not a simulation-based interval coverage
result. Such output labels must be interpreted within their actual contract.

| Group and user question | Evidence and support to retain within its recorded scope | Remaining check / restriction |
| --- | --- | --- |
| **C01 Inputs and design:** can these ratings be analysed, and what is missing? | [User/data stress](user-data-stress-0.2.4.md): category support, missingness, ID preservation, sparse/disconnected designs, weights, replay and output paths. | Complete the per-route acceptance/refusal trace, especially combinations of anchors, interactions, categories and weights. Connectivity does not establish adequate information. |
| **C02 RSM/PCM MML:** does fitting evaluate and optimize the stated model? | [Weight repair](gauss-hermite-weight-repair-0.2.4.md), [adaptive fitting](adaptive-fitting-0.2.4.md), [TAM](tam-adaptive-recheck-0.2.4.md) and [ConQuest](conquest-adaptive-recheck-0.2.4.md) rechecks support their matched numerical targets. | Keep fitting and scoring integration separate. Close exact anchor/interaction/weight/population subclaims; numerical parity does not confer inference readiness. |
| **C03 JML:** which estimate and extreme-score convention is being reported? | [Matched estimator modes](tam-immer-jml-mode-comparison-record-0.2.3.md) and [extreme-profile pilot](jml-extreme-profile-recovery-pilot-record-0.2.3.md); current six-fit audit preserves exploratory precision. | Reconcile current raw/adjusted/corrected targets and non-extreme numerical overlap before mode-specific recovery. Ordinary SE/CI validity is not established by optimizer success. |
| **C04 Full GPCM:** does the complete selected-slope-owner model work? | [Non-unit score oracle](gpcm-nonunit-score-oracle-record-0.2.3.md), [owner identity checks](gpcm-owner-current-default-smoke-p1s-record-0.2.3.md) and bounded item-only external overlap. | Check both slope owners/estimators with nonzero other-facet effects, information and boundaries. Free-slope SE/CI remain ineligible. Item-only TAM agreement cannot close the complete model. |
| **C05 Precision and decisions:** what uncertainty does this SE, interval or reliability represent? | [20,000 structural datasets](mml-structural-coverage-record-0.2.4.md), then [30,000 fresh targeted datasets](mml-structural-bias-confirmation-record-0.2.4.md); [joint-information](mml-independent-information-conditions-record-0.2.4.md) and [weight restrictions](observation-weight-readiness-repair-record-0.2.4.md). | September 20 source replay verifies bounded numerical continuity; historical eligible denominators are not current-source denominators. Person posterior intervals, population parameters, reliability/separation and decision calibration need separate targets. These studies are not 50,000 replicates per condition. |
| **C06 Fitted-object scoring and draws:** what prior and calibration determine this Person result? | [Interval construction](person-interval-calibration-0.2.4.md), [prior robustness](person-prior-robustness-0.2.4.md), [estimated calibration](person-estimated-calibration-0.2.4.md), [learned population](person-learned-population-0.2.4.md) and [transport](person-population-transport-0.2.4.md). | Preserve the stated conditional uncertainty and source readiness. Learned-population scoring remains review-only. Do not extend these studies to every GPCM prediction, future outcome or plausible-value analysis. |
| **C07 Portable calibration:** can another user reproduce compatible new-Person scoring? | [Lifecycle and integration review](mml-quadrature-remedy-record-0.2.4.md), [data/replay stress](user-data-stress-0.2.4.md) and recent fixed-population Person evidence. | Retain fixed-normal RSM/PCM MML, documented direct/group anchors and the highest reviewed fitting grid. Recheck identity/refusal and fitting versus scoring settings on the final source. Calibration estimation uncertainty is excluded. |
| **C08 Anchors/linking:** are changes on a common scale, and what was held fixed? | [Sparse-design refinement](rater-anchor-incomplete-design-refinement-record-0.2.4.md), [topology](equating-topology-record-0.2.4.md), [conditional offset sensitivity](offset-sensitivity-record-0.2.4.md) and recent sparse execution/replay stress. | Fixed-anchor and fixed-source-estimate results do not establish estimated-anchor uncertainty. Paired full refits must repeat selection/linking and retain between-fit covariance; weak bridges need explicit information checks. |
| **C09 Equivalence:** is a small facet difference supported by its joint uncertainty? | [Shared repair](facet-equivalence-repair-record-0.2.4.md), [anchored rank restriction](mml-independent-information-conditions-record-0.2.4.md), current six fits and seven analytic/output test blocks. | Implementation repair verified. Finite-sample TOST, multiple-comparison operating characteristics and broader eligible anchor conditions remain open; preserve all ineligible-source refusals. |
| **C10 Bias/DFF/DIF/interactions:** is this a screen or a calibrated decision? | [22 execution cases and subsequent null-statistic audit](interval-drf-preflight-record-0.2.4.md): EAP residual centering can fail under no DRF; eight joint-MML fits reproduce independently integrated likelihoods. | Residual screens have a different null; refit screens omit shared-anchor estimation terms. Existing joint-model LRTs remain withheld by the estimability contract. Error rates and power remain unqualified. |
| **C11 Fit/PCA/Q3/person fit/QC:** what does a flagged response or residual pattern mean? | Existing formula/convention tests, [reporting audit](reporting-completeness-audit-0.2.4.md), and current Q3/person-fit/report tests. Unrequested PCA is not silently added by a report. | Verify thresholds, missingness, degrees of freedom and restrictions in all outputs. Numerical residual summaries do not validate a dimensionality or automatic fit decision. |
| **C12 Fair Scores and curves (September 14 checkpoint):** which reference produces this expected score and interval? | [Full-refit pilot](fair-score-refit-record-0.2.4.md), [interval repairs](interval-drf-preflight-record-0.2.4.md), [FairZ protocol/preflight](fairz-coverage-record-0.2.4.md). | FairZ is a zero-reference expected score. Public fair-score CI remain diagnostic-only/ineligible for ordinary inference. The later September 17 confirmation is complete (five supported cells, three review); its joint-SE candidate is deferred from 0.2.4; reestimated-reference FairM, Person and gap uncertainty are distinct questions. |
| **C13 G/D-study:** what changes when only rater count changes? | Public observed-score Gaussian main-effect model; existing singularity/projection tests and the current hand-calculated fixed-Criterion example below. | Retain explicit collapsed-residual scaling assumptions. Full person-by-facet interactions, fixed-facet universe designs, multivariate decomposition and latent ordinal coefficients are not established by these helpers. Public formula/scope review remains necessary. |
| **C14 Hierarchy and shrinkage:** is this descriptive adjustment or a new fitted model? | Existing hand-calculation, full-pooling, prior-SD, hierarchy/ICC, manifest and plotting tests, rerun here. | Shrinkage is post-hoc, with a naive SE conditional on prior variance; full pooling can yield zero `ShrunkSE`. Trace downstream interval/ranking uses and heuristic thresholds. No joint hierarchical MFRM fit or calibrated shrinkage interval is established. |
| **C15 Simulation/design/resampling:** does the validation experiment answer its stated question? | Recent Person studies record calibration reuse, Monte Carlo precision and failures; the DRF follow-up separates exact-pattern null centering from four saved-data likelihood checks. | Verify truth/identification, attempted versus eligible replicates, resampling unit and Monte Carlo error. Group ability shifts are legitimate no-DRF controls. Enumeration and eight fits do not establish procedure-level error rates or power. |
| **C16 External imports:** which quantities were actually estimated elsewhere? | Current FACETS import and metric/precision tests, plus [bounded ConQuest overlap](conquest-adaptive-recheck-0.2.4.md). | Import/normalization is not re-estimation or SE equivalence. Trace all importers, absent covariance/raw data, categories/constraints, and downstream refusals; FACETS tests do not validate every importer. |
| **C17 Reports/plots/APA/exports/replay:** does the result keep its meaning when reported? | [Beginner/data/replay stress](user-data-stress-0.2.4.md), [reporting completeness](reporting-completeness-audit-0.2.4.md), current output tests, all 373 declarations mapped. | Finish the decision-bearing route sweep, including legacy/imported/supplied objects and hidden annotations. Re-run complete workflows and platform checks on the eventual final source. A usable report does not establish the validity of its estimates. |
| **C18 Network/agreement/time:** what descriptive relationship is being summarized? | September 20 repairs unavailable comparisons, context identity, zero edges, selected-subset scope, dependent-edge Welch output and timing denominators. Seven saved fits retain existing complete-case pair values without refitting. | Retain descriptive interpretation and regenerate older results. Graph topology, association screens and time cutoffs do not establish rater quality, causal halo, rapid guessing or latent-model inference. Final-source applicability and any stronger statistical claims remain open. |

## Numerical agreement and quadrature: the current answer

The [Gauss–Hermite repair](gauss-hermite-weight-repair-0.2.4.md) addresses
eigenvector components becoming zero before squaring, which had removed
representable small weights. The replacement uses a scaled orthonormal
Hermite recurrence, not an epsilon floor. Its high-precision and platform
checks cover the recorded orders; very high orders still meet floating-point
limits and are refused when positive finite weights cannot be represented.
For example, the later learned-population study refused Q481. This is not a
promise that arbitrarily high orders are usable.

The [TAM adaptive recheck](tam-adaptive-recheck-0.2.4.md) retains 36 cases
(21 RSM, 15 PCM). Adaptive Q31/Q61 versus dense TAM Q301 satisfies numerical
criteria in 72/72 macOS comparisons and 20/20 comparisons from 10 selected
Linux cases. macOS maximum cumulative difficulty-surface discrepancy is
1.075e-5 and EAP discrepancy 1.942e-6. **Only 48/72 macOS and 16/20 Linux fits
are inference-ready.** The record retains the original restart failures and
their separate follow-ups. Fixed Q31/Q61 still shows material movement in
some patterns; repairing weights alone did not solve integration accuracy.

The [ConQuest recheck](conquest-adaptive-recheck-0.2.4.md) is a matched
96-Person, two-rater, two-criterion microcase, with four native and eight
mfrmr fits. Native calibration agreement and stochastic native Person-scoring
agreement are separate results. Changing native Person integration settings
left calibration exports identical; raising the scoring budget reduced the
observed maximum EAP difference to about 0.000485. This neither establishes
cross-software SE equivalence nor validates all multifacet models.

## G/D-study: counts held constant are not fixed-facet inference

The documented public call supports the requested planning pattern:

```r
gt <- mfrm_generalizability(fit)
ds <- mfrm_d_study(
  gt,
  data.frame(Rater = c(2, 3, 4), Criterion = 4),
  residual_scaling = "sensitivity"
)
```

Criterion count remains four while rater count changes. This does **not**
change Criterion from a random measurement facet to a statistically fixed
facet, nor fit person-by-rater and person-by-criterion interactions separately.
Removing a facet from `random_facets` does not demonstrate a valid fixed-facet
universe design. The public helper uses Gaussian observed numeric scores,
random main effects and a collapsed residual, with three explicit residual
scaling assumptions.

The current arithmetic check supplies variances Person=1, Rater=0.4,
Criterion=0.2, residual=0.8. All nine count/scaling rows match hand-calculated
error variances within 1e-12 and G/Phi at the public output's four-decimal
precision. The initial probe incorrectly demanded unrounded precision from
these rounded columns and failed; the corrected check separately verifies raw
error variances and rounded coefficients. No production calculation or
statistical acceptance criterion was changed. This checks the projection, not estimation of
those components or the adequacy of the decomposition for actual data.
The [multivariate research disposition](gtheory-multivariate-dsim6-maturity-disposition-record-0.2.4.md)
concerns a different model and does not promote this public helper.

## Historical September 14 work queue (superseded)

| Priority | Concrete next result | Completion condition / release consequence |
| --- | --- | --- |
| 1. Resolve retained uncertainty/output claims | Trace exact estimates, references, covariance sources and readiness through the remaining C03–C06/C08–C14/C16–C18 routes. Give each subclaim an evidence basis, verified restriction, or explicit unresolved disposition. | A repaired implementation is not left listed as broken; an unvalidated ordinary interval/decision is not declared supported. Already public GPCM/JML and secondary routes remain part of release review. |
| 2. Settle the small numerical/design questions | Reconcile the fixed-reference joint FairZ candidate to current source; align DRF generator location and group means; specify paired refit/linking targets; finish exact full-model GPCM/JML comparisons. | Define the procedure being evaluated, independent target calculation and failure accounting before spending on large confirmations. Preserve adverse results. |
| 3. Run only necessary claim-specific confirmations | FairZ planned main: **0/20,000**; population-parameter interval main: **0/80,000**. Each has 40 preliminary datasets on its recorded source. DRF null/power confirmation still requires the aligned pilot. | These are unrun studies, not failed studies. Recent Person experiments do not fill these denominators. Reconcile source and frozen criteria before execution; a narrower release scope requires an explicit restriction decision, not silently waiving missing evidence. No large study was launched by this reconciliation. |
| 4. Verify one final release candidate | Complete user workflows, packaged full tests, five-platform matrix, examples/vignettes and checks after required statistical/output changes. | Bind all results to the final source. Earlier cross-platform checks and the latest lighter package check are checkpoints, not final release approval. |

The historical FairZ record's documentation pause is not a new request for
permission. Help/reporting work has since advanced. The remaining prerequisite
is a current-source and target review; this ledger leaves the main study
pending and does not alter its frozen protocol.

## Current-source verification and provenance

The [reproduction script](claim-reconciliation-0.2.4.R) reuses the existing
six-fit audit with an explicit current inventory and nine existing test files.
The original inventory and old results are unchanged. No production R/C++ or
help implementation was changed by this reconciliation.

The retained [audit bundle](../../validation-results/claim-reconciliation-20260914)
contains the current inventory, runtime/covariance tables, per-test results,
fixed-count D-study table, source hashes, warnings, session information,
invocations and SHA-256 manifest.

- Six fits: RSM/PCM/GPCM × MML/JML on one example dataset, q31, two equivalence
  bounds. **0 unsupported positive-decision rows**, with ineligible routes
  refused. For 12 RSM/PCM pair contrasts the maximum absolute relative SE
  discrepancy is **0**. This is not six independent recovery experiments.
- Nine existing test files: **140 test blocks, 983 passing expectations,
  0 failures, 0 errors, 0 warnings and 0 skips**. Scope includes equivalence,
  Q3/person fit/G/D-study, shrinkage, hierarchy, response times, reports/network,
  FACETS metrics/imports and multifacet precision contracts.
- An additional nine-row fixed-Criterion D-study arithmetic check passes.
- Current `R/` (87), compiled-source files (2), `man/` (228), `NAMESPACE`,
  and all 170 packaged test files are byte-identical to the latest checked
  package. `DESCRIPTION` differs through build-time normalization/generated
  fields; its authored fields are semantically checked separately. Another
  284 repository test/helper files are not in that tarball and are not counted
  as packaged test coverage.

Latest checked tarball: `mfrmr_0.2.4.9000.tar.gz`, SHA-256
`1ad565ec34687a9ca1e6d57dc585547322fad47a9ed1b4c096249bbed9aeded5`.
Its macOS light `R CMD check --no-manual` checkpoint reports Status OK,
673 passing expectations and three intended skips. The older
[five-platform/full-workflow verification](prerelease-verification-0.2.4.md)
belongs to an earlier candidate. This reconciliation does not claim a new full
suite, five-platform run, coverage experiment or release approval.


#### September 24 expanded-candidate hosted checks and publication preparation

M6 now has matching five-environment evidence for
`4f5ed87c11a1d01ee27547fa3d3e5d0c14aa1b04`, tree
`1db54edaa3c53ef85e6d1075dede261ebe674738`:
[run 35948657009](https://github.com/Ryuya-dot-com/mfrmr/actions/runs/35948657009).
All five macOS/Windows/Linux R-version cells complete `R CMD check --no-manual`
with **zero errors, zero warnings and zero notes**, plus international-input,
moved-folder replay and repository-consistency checks. Downloaded source and
check-log hashes agree with every receipt and with the same candidate commit/tree.
The matrix uses the representative CRAN tier, not a repeat of the full numerical
regression or new coverage simulations. The macOS tier reports 3,027 passed
expectations and three explicit CRAN skips; the formerly skipped fresh-process
portable-API test now runs and passes. Existing statistical limits are unchanged.
Runner action-runtime deprecation annotations are maintenance notices, not R
package-check warnings or failed cells.

The source-truth review initially rejected the word “preflight” in the public
roadmap; reader-facing wording was repaired before the CI commit. No guard was
weakened. All 634 staged packaged implementation/help/test/example inputs matched
the M5 archive before publication preparation. The CI commit includes the prior
expanded implementation commit `4819f79` and the M5 help/example repairs.

The prepared publication archive has SHA256
`d1b7503790b275aefe02ab2d99ad4c9e79d35918ddda582c8f3c36a1e259b40b`.
Its complete member inventory matches the M5 archive. Only README installation
and status prose, and the automatic DESCRIPTION Packaged timestamp differ.
The initial comparison correctly exposed that timestamp in addition to README;
the corrected comparison admits only that field, not arbitrary metadata changes.
All numerical code, Rd, tests, data, saved results, executed article HTML/figures,
article sources and index remain byte-identical. A further 664 existing checkout
files agree with their publication archive members. The archive checksum and
comparison receipt are retained in
`validation-results/github-integration-20260924/publication/`; hosted receipts,
run/job identities and the CI watch log are in its parent directory.

The subsequent publication-preparation commit changes only README, the public
roadmap, this record, the internal plan and `cran-comments.md`. The last four are
excluded from the source archive. Their distinct commit identity is not claimed
to have rerun the matrix. Do not rerun unchanged numerical tests merely to record
CI results. Main integration, tag/asset re-download and site/help identity remain
open until verified. This does not submit the package to CRAN.
