# 0.2.4 integrated claim and evidence ledger

Date: 2026-09-24. **GitHub rc.5 remains published; the successor API/GPCM source
has completed local integration checks, and CRAN submission remains open.**
A subsequent [GPCM inference audit](#september-24-gpcm-inference-follow-up-audit)
reopens the explicit-population quadrature workflow/help correction before
public handoff. See the
[final API/GPCM integration](#september-24-final-api-and-gpcm-integration) for
the current frozen archive, repaired full-run failures and evidence reuse.
The earlier revised source/article
snapshot passed local checks and was sent to Win-builder. The user's subsequent
direction puts local development before further external checks. The
[latest local-development record](#september-24-local-development-after-candidate-checks)
distinguishes that uploaded snapshot from newer source changes. The
[verified rc.5 publication](#september-24-verified-rc5-publication) and
[earlier Windows result](#september-24-windows-result-and-pre-submission-scope-review)
remain evidence only for their original sources.
The original eighteen-group
reconciliation remains historical evidence. This is the successor assessment to the
[September 9 inventory](public-claim-evidence-review-0.2.4.md), under the
[public roadmap](../../ROADMAP.md). It does not broaden API support or replace
the source identities, protocols, failures or results in earlier records.
The subsequent [beginner/help review](#september-24-pre-integration-beginner-and-api-review)
and CRAN preflight are reconciled on the
[successor archive](#follow-through-successor-archive-cran-check-and-targeted-repairs).
The candidate's checked implementation and separately verified documentation
changes are distinguished below. The failed initial checks and targeted repairs
remain explicit. Post-release priorities are now in the
[public roadmap](../../ROADMAP.md#post-release-priorities); a planned statistical
extension does not change the admitted 0.2.4 claims.

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
| Local integration and later publication | The final local checks, five-environment implementation checks and verified rc.5 publication below have distinct source identities and scopes. | M5 closed within the retained scope; M6 closed for the GitHub candidate with verified main integration, assets and published documentation. The URL-corrected local submission archive has a later focused online check; Win-builder results and CRAN submission remain separate. | M5 local endpoint; M6 GitHub candidate publication complete |

The September 24 entry review resolved the retained implementation and
statistical decisions. The final integration disposition below now closes M1–M5
for those outcomes. Subsequent publication verification closes M6 for the
GitHub candidate; CRAN has not received a submission. Each closure uses source-specific checks
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


#### September 24 live-site accessibility and article-completeness correction

The rc.4 site build succeeded in 36m11s and Pages deployed source `1e6151d` as
`32a803abec965b1a63fc66341e03cd938452df6e`. Fourteen live pages matched their
published bytes and source links before the comprehensive image check exposed
**23 empty alternatives** in four older articles. The new-workflow figures had
alternatives; the defect was in linking/DFF, reporting/APA, visual diagnostics
and the workflow introduction. An additional residual-PCA figure is conditional
on available diagnostics and now has an alternative too. This failed audit was
not relabeled a pass. The build's single `@examplesIf interactive() is FALSE`
warning records the intended refusal to launch an interactive viewer.

This review also corrects the earlier M4/M5 claim of “fifteen executed tutorials.”
The rc.4 archive contained fifteen prebuilt articles, but only the seven newly
added workflows were fully evaluated; the eight older articles retained their
CRAN-safe computation guards. Its 43-figure count and archive hashes were correct,
but completeness of evaluation was overstated. Eight older articles are now
rendered with NOT_CRAN=true against the matching installed M5 implementation;
they take 29.574 seconds in total. Their sources add no new analysis. The seven
costly executed articles are retained, avoiding another shared-rater computation
(the hosted article alone took about 17m25s).

Four Rmd files add figure alternatives, with all R chunk bodies unchanged.
The eight regenerated R scripts match their original Rmd sources extracted
with evaluation enabled. The other seven scripts remain byte-identical to rc.4.
The earlier stored scripts comment out guarded chunks; therefore an attempted
comparison of all fifteen parsed scripts across execution modes failed. The
corrected comparison uses matching extraction modes for the eight changed scripts
and byte identity for the seven unchanged scripts, without claiming they all
execute automatically. The rc.5
source archive contains fifteen executed articles and 68 described images;
source/Rmd pairs, internal-path exclusions and archive membership are checked.
R/native code, Rd, tests, data, packaged example results and interfaces are
byte-identical to rc.4 and the five-environment implementation. Only documentary
inputs, eight executed HTML outputs, corresponding extraction scripts and build time change.
The rc.5 archive SHA256 is
`d988e5023f404895bca6ff184b037a7511680289634aeb4fcb31d2a20a7cb5c6`.

The initial live HTTP check hit Python's local missing-issuer configuration;
standard macOS curl, with certificate verification intact, retrieved the public
pages. No TLS verification was disabled. The subsequent alternative-text failure
and all corrective checks are retained under
`validation-results/github-integration-20260924/`. The existing rc.4 tag is
preserved. The corrected candidate will use rc.5; focused archive checks and
source-matched site/article rebuilding precede its final publication verification.


The rc.5 focused archive check (`--no-manual --no-examples --no-tests --timings`)
returns **Status: OK**, zero errors/warnings/notes, including package installation,
help, vignette dependencies and article rebuilding under the CRAN guards. The
first attempt omitted the existing user R-library path and stopped on unavailable
mice/covr/flextable; the corrected path reused the already installed dependencies.
No force-Suggests override or dependency installation was used. This is not a new
full numerical suite or complete `--as-cran` run. The scope of the five-environment
check at `4f5ed87` remains explicitly tied to the unchanged implementation.


#### September 24 verified rc.5 publication

**M6 is complete for the agreed GitHub candidate scope.** Main includes the
expanded implementation checked at `4f5ed87`, the rc.4 publication preparation,
and the documentation correction at `3cd50b89edaee6b949aa6cc02ab82b27c4be6e71`.
GitHub pre-release [v0.2.4-rc.5](https://github.com/Ryuya-dot-com/mfrmr/releases/tag/v0.2.4-rc.5)
fixes that source. Both attachments were re-downloaded and matched byte for byte.
The archive SHA256 is
`d988e5023f404895bca6ff184b037a7511680289634aeb4fcb31d2a20a7cb5c6`.
The immutable rc.4 tag/assets remain; its notes correct the overstated tutorial
execution claim and direct readers to rc.5.

The hosted site build at `1e6151d` supplied the unchanged reference and expensive
article outputs. pkgdown 2.2.1, matching the hosted version, rebuilt only the four
changed ordinary-model articles and home/NEWS; Markdown copies and search were
regenerated without rerunning articles. Home generation initially needed an
online CRAN sidebar lookup and writable cache; a task-local R cache and normal
network access resolved it. Source references now identify `3cd50b89`.
388 reference/unchanged-article HTML pages retain identical output apart from
those source-link updates. Generated session-information Markdown retains normal
R column-padding whitespace; it is not a changed computation or failed R check.

Pages deployed site `1f34357e9dea11de618d2701d2439d7dd9318065`. All 403 HTML pages
were checked for exposed local/validation paths and fatal rendering messages;
none was found. Fifteen live pages, including ROADMAP, and representative images
match the deployed bytes. All 68 tutorial figures have nonempty descriptive
alternatives. Matching reference/article source links are checked. This does not
constitute an exhaustive user study or external-URL/CRAN incoming check.

The final completion record changes repository-only documentation. The public
ROADMAP page is refreshed separately to show the verified state; API/reference,
tutorial and archive content remain fixed at rc.5. The five-environment run is
not attributed to a new commit: implementation and Rd identity, unchanged Rmd
analysis bodies and focused documentation checks are the stated reuse basis.
No new full regression, coverage simulation, CRAN submission or CRAN acceptance
is claimed. Receipts are under `validation-results/github-integration-20260924/rc5/`.

#### September 24 CRAN URL, reverse-dependency and Win-builder preflight

The user requested these checks after rc.5 publication. A current CRAN source
index (25,165 packages; retrieved September 24) lists mfrmr 0.2.3.1 and no reverse
Depends, Imports, LinkingTo, Suggests or Enhances. The CRAN reverse-dependency
denominator is zero; private or non-CRAN consumers are not assessed by that index.

The rc.5 URL check found a PubMed HTTP 203 browser challenge. The cited Wind and
Guo paper is confirmed by its publisher and PMID as DOI
`10.1177/0013164419834613`; its article link now uses the DOI. README roadmap and
NEWS links use the public site URLs so that they also resolve outside GitHub
(the roadmap is excluded from the source archive). These are three link edits,
not a change in the cited paper, analysis or numerical implementation.

A local successor archive has SHA256
`3cef1b900e311476d40a7ee646dc461b3632faa57ceff4b16c13c9f0326902a1`.
Member-by-member comparison with rc.5 permits only those exact substitutions
in README, article source/output copies and the automatic Packaged timestamp.
All other members are identical, including R/native code, Rd, tests, data,
executed tutorial R and numerical output. Existing published assets are preserved.

urlchecker 2.0.0 finds no problems among 130 URL occurrences / 68 distinct
references with HTTP status exclusions disabled. The three DESCRIPTION DOI-form
references pass a separate normalized-URL check. Six relative article-link
occurrences resolve against their three rendered `inst/doc` targets. Directly
resolving those Rmd source links in `vignettes` initially returned false because
the HTML is installed in `inst/doc`; the corrected receipt checks the rendered
destination rather than mislabeling source-relative HTML as broken.

The exact successor passes online
`R CMD check --as-cran --no-examples --no-tests --no-manual --timings` on arm64
macOS / R 4.6.1 with zero errors, zero warnings and one NOTE: maintainer identity
and seven updates in the past six months. Remote incoming checks were enabled.
The earlier clock/temp-file notes did not recur. Fifteen articles rebuild under
their CRAN guards. This check does not repeat examples, tests or manuals; prior
applicable evidence is retained and is not attributed to the new archive hash.

Official HTTPS Win-builder forms received the same 6,617,358-byte archive for
R-release and R-devel. Both HTTP 200 responses identify its correct filename and
size. An initial receipt assertion expected the word "success", which the
service does not return; its actual filename/size receipt was verified, and
R-release was not uploaded twice. Only the then-unsent R-devel upload followed.
Results have not yet been retrieved. Receipt is not a successful check, and the
maintainer result links are required to retrieve and archive the temporary logs.

`cran-comments.md` now summarizes the selected archive, current checks, reused
evidence, NOTE and outstanding results instead of mixing superseded candidates
with submission status. Earlier records remain in Git and this ledger. Local
receipts are under `validation-results/cran-preflight-20260924/`. No CRAN
submission or replacement GitHub release has been made.

#### September 24 GPCM and API roadmap reconciliation

The user's question about indefinite bounded-GPCM status exposed two distinct
issues. The old technical supplement required an all-or-nothing completion of
model structure, inference and downstream lifecycle functions. The public
roadmap now separates current-model inference, slope/step separation, portable
calibration and additional slope families. It assigns API naming, consequential
arguments/defaults and coherent help to the next feature release, with a
compatibility/migration requirement. These are plans, not new public functions
or relaxed statistical restrictions. The active internal plan and old GPCM
supplement now agree on that sequence.

Source inspection also found a current tutorial contradiction: wording implied
that same-grid readiness could enable free-slope GPCM ranking, and two stated
weighting-review evidence labels did not match the implementation. The existing
`compare_mfrm` help correctly withholds that ranking. The tutorial now explains
that matching grids alone cannot remove the current free-slope inference
restriction, uses the actual evidence tiers, and distinguishes the
`PCM_in_GPCM_ic_only` structural label from permission to rank models. NEWS
records this user-visible correction. The code, signatures and analysis chunks
are unchanged; no inferential capability is promoted.

This local correction postdates the immutable Win-builder archive
`3cef1b900e311476d40a7ee646dc461b3632faa57ceff4b16c13c9f0326902a1`.
It must enter a checked successor with matching executed article prose before
submission; pending results are evidence for the archive actually sent.
No rebuild, upload, commit or publication is implied by the roadmap revision.

Focused verification uses the installed package from that exact archive:
`test-gpcm-slope-owner-comparison.R` passes, and a direct MML boundary-component
check confirms that free slopes remain `not_evaluated` even with a complete
Person boundary audit. Neither check fits a model. The revised tutorial renders
under its existing CRAN guard and contains the corrected evidence labels; all
five executable R chunks are byte-identical to HEAD. Six changed Markdown files
parse, their checked local links/anchors resolve, and `git diff --check` passes.
The uploaded archive retains its original SHA256. No full regression, numerical
study or tutorial fitting was repeated; the guarded render does not replace the
executed article needed for the successor archive.

#### September 24 Windows result and pre-submission scope review

The user supplied `https://win-builder.r-project.org/3Gn4UzF3o10P/` for the
September 24 R-release check. Its logs report R 4.6.1 on Windows Server 2022
x64, successful installation, examples, the selected CRAN test tier, vignette
rebuilds and PDF/HTML manuals: 0 errors, 0 warnings and 1 NOTE. The NOTE gives
maintainer information and seven updates in six months; it is neither a
statistical concern nor CRAN acceptance. Check time is 1,459 seconds and
installation time 139 seconds in the supplied notification.

The test log has 2,926 passes and 11 skips. Six are shared-rater tests requiring
RTMB >= 2.0 where the service installed 1.9; three are deliberately skipped on
CRAN, one requires a fresh check-installed process, and one requires compiled
sources. The retrieved CRAN source index lists RTMB 2.0, matching the declared
optional requirement. Do not infer successful estimation of the skipped routes
from the overall check. Reconcile applicable existing Windows evidence or check
those affected paths with the required dependency before the revised candidate
is declared covered.

Check/install logs, example source/output/timings, test output and the Windows
binary are archived under
`validation-results/cran-preflight-20260924/winbuilder-R-release/` with hashes.
The binary ZIP passes its integrity check; its namespace matches the uploaded
archive's installed namespace, and its Packaged timestamp matches that source.
This supports the upload receipt attribution; the server does not provide a
source-archive hash in its log. The immutable source remains
`3cef1b900e311476d40a7ee646dc461b3632faa57ceff4b16c13c9f0326902a1`.
R-devel remains pending. No CRAN submission occurred.

The user's request to weigh pre-submission API/GPCM changes revises the earlier
blanket allocation to 0.2.5. A downloaded CRAN 0.2.3.1 source has 170 exports
versus the candidate's 204, with none removed. Clustering, supplied-imputation
review, shared-rater/testlet fitting and `score_mfrm_persons()` are additions
since that CRAN version; `fit_mfrm()`, GPCM and `predict_mfrm_units()` already
exist there. First-CRAN-entry names have lower migration cost now, but existing
GitHub consumers still require compatibility. Update-frequency feedback also
favors consolidation without constituting a requirement to expand the model.

The recommended 0.2.4 boundary is now explicit in the public roadmap: complete
principal API naming/semantics/help/migration and disposition of current GPCM
eligibility before submission. Repair an established defect affecting a retained
claim; admit narrower inference only with its required evidence. Independent
slope/step owners or additional slope families remain separately scoped model
extensions. The trade-off is additional compatibility/integration work and a
revised candidate check, against exposing avoidable confusion and a second
migration soon after release. This review changes the plan and recorded result,
not code, public names, defaults or statistical eligibility. No regression or
simulation was rerun for this decision.

#### September 24 compatible API integration

The subsequent implementation adds `mfrm_cluster_pam()` as the recommended
Gower/PAM entry and `review_mfrm_imputations(..., impute_ids = ...)` for supplied
score completions. The original functions retain their argument order and
result classes. The PAM alias shares one implementation; the old imputation
wrapper delegates to the same validator. Event selection still distinguishes
IDs such as `001` and `1`, preserves observed scores and assignments, and
rejects invalid or ambiguous inputs. The fit/pool workflow still consumes the
same `mfrm_response_imputations` class.

`fit_mfrm()`, `describe_mfrm_data()` and `review_mfrm_anchors()` accept the
explicit `category_policy = "preserve"`/`"collapse"` spelling at the end of
their signatures, preserving previous positional arguments. One resolver maps
it to the existing boolean. Omission or `NULL` retains the previous default;
contradictory explicit old/new choices fail. Tests compare gapped-category
reviews, identical fitted coordinates and replay inputs, and the unchanged
unsupported-internal-category refusal. Imputed fitting blocks category-policy
overrides because it fixes a common declared ladder. No likelihood, category
estimator, result schema or statistical default is changed.

The compatibility table, workflow guide, fitting help, relevant tutorials,
README and NEWS use the recommended names and explain consequential settings.
Fitting help groups data/rubric/model/computation/output choices; GPCM guidance
states the one-facet slope/step structure and distinguishes numerical estimates,
formal slope intervals, descriptive comparisons and conditional scoring.
Machine statuses and GPCM inferential restrictions are unchanged. Existing
help topics/website page names are retained while new names resolve to them.
The unsupported-category error no longer refers to the outdated 0.2.3 version.

Seven affected test files were run: API migration, feature clustering, response
imputation, GPCM capabilities, GPCM slope-owner comparison, namespace and output
guide. The final outcomes have no failures or warnings; three costly GPCM
checks retain their explicit CRAN skips. Initial migration-test failures came
from an incorrect expected condition class and comparing the condition returned
by `expect_warning()` instead of the review result. Those test errors were
fixed, the affected file alone was rerun, and initial receipts were retained.
They did not require a change to the numerical implementation.

A separate installation passes; installed new-name help, the three selected
entry examples and `tools::codoc()` pass. Five changed reference pages render
locally with examples disabled after the selected examples were checked
separately. The first site attempt exposed topic-name selection and an
unwritable default Sass cache; retaining original topic names and using a
workspace cache resolves those issues. These checks do not regenerate the
executed tutorial archive or constitute the final submission package check.
Evidence is under `validation-results/api-integration-20260924/`.

The earlier Windows CI test log has 3,027 passes and only the three deliberate
CRAN GPCM skips, so it executed the RTMB-dependent tests skipped on Win-builder.
The required RTMB version is enforced by those tests. This reuses existing
evidence for unchanged shared-rater estimation; it does not attribute those
checks to the latest wrappers, help or archive. Both records remain intact.

API naming/category-policy implementation is complete locally for the described
routes, not a claim that every signature was renamed or usability was tested
with student participants. Standard generic arguments and differing interval
or new-data spellings are retained with their actual meanings. The GPCM
inference eligibility decision, final source/article reconciliation, required
candidate checks and R-devel result are still open. The uploaded archive remains
unchanged; no commit, push or CRAN submission occurred in this step.

#### September 24 GPCM output eligibility decision

The retained-scope proposal in this entry was subsequently reopened at the
user's explicit request; see the terminology and inference-rationale review
below and the current public roadmap. The original numerical evidence and
uncertainty-reporting repair retain their scopes.

The pre-submission review concludes **retain with explicit restrictions** for
the current free-slope GPCM. This closes the release-scope decision, not the
statistical qualification of new inference. It does not treat an incomplete
software check as proof that every numerical fit is wrong.

The review traced `mfrmr_readiness_boundary_component()`, the nonlinear local
estimability classification, structural covariance/uncertainty, the IC
contract, `compare_mfrm()` and the weighting-review comparison contract.
Every current free-slope GPCM remains unqualified by the shared readiness
policy. This is unconditional on the optimizer's success; repeated fitting
cannot establish a route the software does not implement. AIC/BIC raw-value
eligibility and integration selectability are distinct from the comparison's
final `ICComparable` decision.

| Output | Disposition and reason |
| --- | --- |
| Relative slopes, response probabilities and curves | Retain numerical/descriptive uses with the explicit optimizer/primary distinction. Kernel, derivative and coordinate witnesses support these calculations within their documented scopes. |
| Primary slope SEs and intervals | Retain the restriction. Constrained-log covariance and natural-slope transformations exist, but local curvature alone does not qualify the interval procedure. A future rule needs a named target, admissible solution/information conditions and assessment of sampling behavior. |
| Facet/step uncertainty and Person posteriors | Preserve existing precision, interval and source-readiness qualifications. Conditional posterior variation is not calibration-estimation uncertainty. A finite local SE does not override the fit's restriction. |
| Automatic IC comparison | Retain the restriction independently of the interval decision. A future rule needs comparable maximized marginal likelihoods, parameter counting/identification, numerical integration and competing-solution handling. It does not need slope-interval coverage merely to compute ICs. |
| PCM/GPCM LRT | Retain the unsupported automatic-test status; the unit-slope response reduction alone does not qualify the test. |
| Additional slope structures and portable calibration | Separate extensions; not prerequisites for the retained descriptive model or for one future inference target. |

Reused evidence includes the
[item-only TAM witness](tam-gpcm-item-only-overlap-record-0.2.3.md),
[seven-start interior example](gpcm-solution-stability-p0-record-0.2.3.md),
[endpoint examples](gpcm-endpoint-solution-stability-p0b-record-0.2.3.md),
[quadrature comparison of the two numerical regions](gpcm-low-basin-quadrature-p1b-record-0.2.3.md),
[20-replicate estimator pilot](gpcm-estimator-asymptotics-pilot-record-0.2.3.md)
and [current-default owner smoke](gpcm-owner-current-default-smoke-p1s-record-0.2.3.md).
The positive witnesses support local numerical implementation. Endpoint
results demonstrate poor default solutions and material integration sensitivity
in particular cases; they do not prove universal failure. The owner smoke
validates model identity, not uncertainty. These are historical, source-specific
results, not newly rerun simulations. Their old all-or-nothing global-proof
and authorization language does not override the current roadmap.
The primary R-core [AIC documentation](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/AIC.html)
was checked for the distinction between calculable values and comparisons of
maximized, comparable likelihoods. No new literature-derived estimator or
interval formula was adopted.

An actual reporting defect was reproduced before editing:
`compute_mml_structural_parameter_se()` defaulted missing `SEEligible` to
`TRUE`. An old-style slope table with two slopes (2 and 0.5) and a known
log-slope covariance produced ordinary SEs (0.4 and 0.1), confidence limits and
`UncertaintyEligibility = "eligible"` without any readiness metadata.
The saved before-state is a controlled reporting fixture, not a model fit or
coverage experiment. The repair requires current parameter metadata, checks
SE/CI permissions separately, keeps regularized covariance diagnostic, and
sets unavailable-covariance eligibility explicitly false. Diagnostic
`Optimizer*` values remain available. Current fits with already-false slope
eligibility are not promoted or numerically refitted by this change.

Summary guidance now identifies the free-slope restriction as current package
availability; help and the tutorial distinguish output-specific meanings and
explain how to refresh old diagnostics. This repairs the misleading impression
that a user can unlock inference solely with more iterations, and removes the
suggestion that exhaustive global boundary proofs are universally necessary
for an interval. NEWS and both active roadmaps record the actual decision.

Focused checks: 57 expectations for the new lightweight reporting regression,
32 for existing identified-step/covariance/gradient behavior and 316 for output
guidance; 405 passed with zero failures, errors, warnings or skips. The new
metadata regression is included in the CRAN tier and does not run model fits.
Evidence is under `validation-results/gpcm-inference-review-20260924/`.
No full suite or broad simulation was repeated. The earlier Win-builder
archive remains unchanged; this repair requires the successor candidate check.

The revised source installs successfully. Installed `tools::codoc()` reports
no mismatches, and the saved legacy reproduction now has unavailable ordinary
uncertainty with identical diagnostic SEs. The two affected reference pages
and GPCM article render successfully, including all four executable capability
chunks. The first rendering attempt could not fetch a public CDN dependency
inside the network sandbox; the partial output then triggered pkgdown's
nonempty-destination guard. Retaining those attempts, allowing the public
dependency read and using a fresh local destination resolved both issues.
The successful output is in `site-complete/`; it is not a published website or
a rebuilt submission archive. Source hashes and checks are in `receipt.json`.


#### September 24 local development after candidate checks

The source/article reconciliation produced a revised snapshot with the API
aliases, explicit category policy and GPCM legacy-uncertainty repair. It also
corrected README installation guidance: published rc.5 predates these new
interfaces. Four changed tutorials were rebuilt; eleven were retained
byte-for-byte. The MI tutorial reuses existing fits/pools only after exact
input and setting checks; no eighty-fit regeneration was needed. Shipped
articles, figures and exclusion of internal records were checked.

The full local CRAN-tier check on `024357db...97ddc2` passed examples (including
`donttest`), 3,121 test expectations, article rebuilds and PDF/HTML manuals.
There were four skips: three deliberate CRAN GPCM checks and one fresh-process
calibration-evidence check. It reported one warning for four source-vignette
timestamps newer than identical inst/doc copies, and one incoming NOTE
(maintainer and seven updates in six months). Repairing the timestamps produced
`404d54d1676cb8ce6694a4839fa359c2a25496b17e257127c2e9c795108d286a`.
Every file content is identical except DESCRIPTION's Packaged timestamp.
The focused exact-archive check passed with 0 errors, 0 warnings and 1 NOTE;
examples/tests/manuals were reused on the proven content-identity basis.
Evidence is in `validation-results/submission-candidate-20260924/`.

Both Win-builder forms accepted that 6,630,129-byte snapshot before the user's
steering message returned work to local development. This was an external
check upload, not CRAN submission. Receipt is not a check pass. Preserve it and
attribute any arriving results to that exact source; do not send additional
snapshots while the local work is being reconciled. No Git commit, push or
website publication occurred. The author README walkthrough passed; there
was no independent novice participant study.

A further local API review reproduced an input/output gap: the selected
`category_policy` was stored via `keep_original`, but missing from both the
fit's settings overview and the data-review overview. The repair adds
`CategoryPolicy` and `ScoreRecoded` after existing table columns, with matching
summary/help/NEWS. Policy is distinct from actual mapping: collapse on a fully
observed contiguous scale does not imply recoding. Older saved fits reuse
recorded preparation/config/replay settings; older reviews without a recorded
choice say `not_recorded`. Missing maps yield NA; policy is not inferred from
an identity score map. Saved analyses are neither refitted nor recoded by
summary. Existing statistical calculations and defaults are unchanged.

The focused API tests have 68 passes, 0 failures, 0 errors, 0 warnings and
0 skips. They check old/new calls, category-policy conflicts, real gapped-data
handling, legacy metadata, saved results and exported summary tables. All
four changed Rd pages parse and render with the new fields. The first evidence
CSV writer could not serialize testthat's list column; selecting its scalar
summary columns fixed the recorder without changing tests. Tests were repeated
only after moving new columns to the end to preserve existing column order.
Evidence is in `validation-results/api-result-consistency-20260924/`.
These post-upload changes have focused local validation, not a new package-wide
or Windows check. Remaining local workflow reconciliation and eventual source
selection stay open. GPCM's retained inference restrictions remain explicit;
package-check success does not supply statistical qualification.

#### September 24 portfolio and rater-feedback route review

The user requested continued local work from a project-wide perspective.
The review traces ordinary fitting/calibration and source scoring, feedback,
features, response MI, G/D planning, the two model extensions and saved outputs.
The earlier numerical and cross-workflow results are reused for unchanged
sources rather than rerunning their simulations. Against the checked September
24 archive, 117 R files and all 21 present native/example/external-data files
are identical. The five changed R files contain the later category-summary
and guidance changes; no likelihood, scoring or interval estimator was added.

An actual route-selection gap was found: `mfrm_facet_intervals()` and the
screening-evaluation functions lacked a direct rater-feedback entry in the
output guide. The existing `mfrmr_output_guide()` now accepts `"feedback"`,
with separate rows for fixed-facet intervals, ordinary rating-fit review,
extended posterior residuals, shared-rater uncertainty and known-truth warning
performance. Each row names the input/model, next table/plot/saving operation
and interpretation limits. An observed severity difference is not misfit;
observed-data cutoff sensitivity is not false-flag accuracy. The main guide,
workflow help, README and NEWS agree. No universal wrapper or new estimator
was introduced. The existing testlet `scores` alias was confirmed in the
public dispatcher and was not duplicated after inspecting its lower-level
adapter.

Focused output-guide tests: 336 passed, zero failures/errors/warnings/skips.
Both changed help pages parse and render. Packaged synthetic shared-rater and
testlet fits/scores were replayed through results, plot-data and reports without
refitting or rescoring: conditional Person endpoints remain identical, and
automatic calibration/rater bounds stay absent. These are interface/output
checks, not new coverage or approximation-accuracy evidence. Results and source
identity are in `validation-results/portfolio-review-20260924/`.

The roadmap's M4/M5/M6 positions now distinguish rc.5's historical integration
and publication from current local changes and the open final-source/publication
stages. The stale statement that numeric k-means/PCA had not been published is
corrected. GPCM free-slope inference, general coverage/diagnostic accuracy,
broader G-theory and deferred multidimensional structures remain unresolved
within their explicit separate scopes. No full suite, new statistical study,
archive upload, Git push or CRAN submission occurred in this review.


#### September 24 GPCM terminology and inference-rationale review

The user challenged the blanket model label and the rationale for withholding
three inferential outputs. Current public model names, messages, route-table
labels, help, README and tutorials now use GPCM. The selected slope/step facet
and unavailable operations remain explicit. Legacy machine-readable field and
status identifiers are preserved for compatibility. This is terminology and
explanation work, not new inference.

The code review separates three mechanisms: slope covariance/transformation
calculations exist but primary eligibility is withheld; compare_mfrm() couples
IC comparison to shared InferenceReady, whose free-slope boundary state is
unconditionally incomplete; the aligned PCM/GPCM nesting branch explicitly
returns eligible = FALSE. That branch's old message incorrectly suggested
permission for IC comparison and now points to ICComparable separately.

The log-slope null is zero with G-1 independent restrictions when all other
free dimensions, including the population model, match. Positive unit slopes
are interior, not a variance-zero boundary. The current default model labels
do not themselves establish a shared population. These facts identify a
possible ordinary MML LRT target, not a currently validated test.

Primary references reviewed: the official R AIC documentation and mirt model
and anova documentation linked in the GPCM help/tutorial. IC comparison does
not require slope-CI coverage or nested models. A conventional approximate
interval does not require universal coverage. Prior stable and problematic
GPCM fixtures retain their original source/design limits; no new statistical
study was run and no old failure was asserted for the current engine.

The public roadmap reopens the earlier retain-with-restrictions proposal at
the user's request. It prioritizes an output-specific MML IC rule before
source freeze, then separates LRT and interval acceptance conditions. Merely
removing the shared guard is not an implemented or verified solution.

Evidence: validation-results/gpcm-terminology-review-20260924/receipt.json.
Four focused test files report 316 passes, zero failures/errors/warnings and
three existing CRAN skips. All Rd files parse and pass checkRd; five selected
help pages and the four-chunk GPCM tutorial render. All 31 changed R files
retain identical non-string code tokens against the pre-turn local source.
No full suite, new simulation, archive rebuild, commit, push or upload was run.


#### September 24 required GPCM inference and first IC implementation

The user requires the remaining IC comparison, PCM/GPCM LRT and relative-slope
interval work to be resolved in 0.2.4. The public roadmap now makes G1--G3
release requirements; the earlier blanket retain-with-restrictions proposal
is superseded. G2 and G3 remain unfinished and final source freeze is open.

G1 now separates comparison eligibility from the shared InferenceReady flag.
For GPCM and estimated-population RSM/PCM MML, compare_mfrm() reuses the current
fitted-information evaluator at the retained parameters and data. It checks
objective agreement, the existing terminal-gradient rule (at most 1e-4), and
positive unregularized information at the existing relative inversion
tolerance. It preserves input/category, current IC identity, free dimensions,
unit weights, common data/constraints, and quadrature requirements. Ordinary
fixed-population RSM/PCM keep their existing decision. The dense information
execution limit remains 80 free coordinates, not 80 Persons. This is a local
solution check, not a global optimum or integration-error certificate.

ICFitEligible/Basis/Review describe that decision. ICComparable controls the
returned deltas, weights and preferences. The weighting review inherits the
verified comparison. InferenceReady, slope interval eligibility and LRT
permissions are not promoted. An initial matched-population PCM example
exposed the same blanket flag on the comparator, leading to the shared MML
solution rule rather than a GPCM-only exception.

Reused complete Criterion- and Rater-slope GPCM fits from the September 15
continuous-integration study were reevaluated against current code. Two PCM
models were fitted on their respective exact data with the same estimated
normal population and adaptive Q61 settings. Both comparisons and saved
weighting reviews pass, while modified parameter vectors and non-unit-weight
comparisons are rejected. The unchanged GPCM estimates and their historical
start/integration evidence do not imply interval coverage or an LRT null law.

Evidence: validation-results/gpcm-ic-eligibility-20260924/receipt.json. Six
focused files have 421 passes, no failures/errors/warnings/skips. Two initial
failures were old warning-text expectations; their numerical assertions were
unchanged. Five reference pages and the four-chunk GPCM article render. No
full suite, new simulation grid, commit, push or external upload was run.


## September 24 matched PCM/GPCM likelihood-ratio test

**Question and release role.** Complete G2 for the existing MML GPCM: test
whether the selected facet's relative slopes are equal, while holding the
population specification, step/facet constraints and interactions constant.
This is distinct from G1 IC comparison and the still-open G3 slope intervals.
No new response model, JML reference distribution, variance-boundary mixture,
operational weighting recommendation or general size guarantee is introduced.

**Implementation.** `compare_mfrm(..., nested = TRUE)` verifies the shared
population design at the same Persons, the same facet/step specifications and
interactions, and exactly G-1 additional sum-zero log-slope coordinates. The
PCM null is identified by model rather than display label or a parameter-count
guess. Existing G1 likelihood, data, unit-weight, integration, gradient and
unregularized-information checks remain required. Other nesting routes retain
their prior inference-readiness requirement. The reported statistic is twice
the log-likelihood gain and its reference is asymptotic chi-square with the
verified restriction count. Negative gains and mismatched dimensions retain a
reason and no p-value. An explicit logical request is required.

`build_weighting_review(..., nested = TRUE)` carries the test, status and
unavailable reason; its default remains FALSE and its compact summary displays
a computed test. Very small p-values are not printed as zero. Fit summaries,
help, NEWS and the GPCM article distinguish comparison checks from unavailable
slope intervals. Machine-readable reference/status fields remain in results;
printed explanations use plain language. Older saved comparisons/reviews must
be rebuilt. No optimizer or estimation default was changed.

**Algebra and numerical checks.** Objective and common-coordinate gradient
identity at unit slopes passed for both slope owners, including a common
population covariate and nonzero nuisance coordinates. Tests also cover
reordered population designs, incompatible populations/interactions/steps,
wrong free dimensions, negative gains, JML, default no-test behavior and
repeated display labels. Two retained non-unit GPCM examples and their saved
matched PCM fits produce LR = 21.431284 (Criterion) and 20.665544 (Rater),
both df = 3, and pass weighting-review and saved-result propagation. These
examples establish workflow correctness, not power. Source re-evaluation uses
the existing 80-free-coordinate information limit; local checks do not prove a
global maximum or sufficient integration accuracy for every dataset.

**Targeted null experiment.** `inst/validation/gpcm-lrt-null-0.2.4.R` declares
four cells before fitting: Criterion/Rater slope owner by crossed N=100 or
rotating N=40 with two of three raters per Person. There are three criteria,
three score categories, normal abilities (SD 1), rater/criterion locations
redrawn at SD .35/.25, step pairs (-.7,.7), (-1.1,1.1), (-1.5,1.5), and unit
true slopes. Both MML fits estimate an intercept-only normal population and
use fixed quadrature q=61, maxit=400 and reltol=1e-10. All planned pairs,
failures, seeds, fits and comparison objects are retained. The generator's
initial unnamed-threshold-matrix error occurred before generating datasets;
that harness error is retained separately and corrected using explicit facet
labels with the same planned seeds. The experiment resumed saved identical
pairs when worker count changed from two to four; there was no outcome-based
resampling or replicate replacement.

| Slope owner | Design | Planned/available | Rejections at .05 | Exact 95% MC interval |
|---|---|---:|---:|---:|
| Criterion | Crossed N=100 | 100/100 | 5/100 | .0164--.1128 |
| Rater | Crossed N=100 | 100/100 | 7/100 | .0286--.1389 |
| Criterion | Rotating N=40 | 100/100 | 6/100 | .0223--.1260 |
| Rater | Rotating N=40 | 100/100 | 7/100 | .0286--.1389 |

These are descriptive Monte Carlo results, not a test that the implementation
has exactly 5% size. Their precision is limited (MC SE about .022--.026).
Sample size and assignment density change together, so separate sparsity
attribution is unsupported. No misspecified population, arbitrary dependence,
rare-category or broad-capacity guarantee follows. Four prespecified first
replications refitted at q=121 changed LR by at most 8.09e-8; a separate shared
dataset gave fixed-q61 versus adaptive-q31 LR difference 7.01e-11.

**Verification and disposition.** Focused tests, rendered help/article and
replay evidence are in `validation-results/gpcm-lrt-20260924/`; its receipt
records final counts and source hashes. Initial expectation failures were old
G1 warning wording and nested warning-capture behavior; numerical assertions
were retained. The shared printer and invalid-request checks were verified
without repeating unaffected suites. No full package check, source archive,
commit, push or external upload was performed. G2's implementation and declared
null evaluation are complete locally. G3 intervals and final integrated
release checks remain required before source freeze/submission. Saved null
fits can be reused for the interval milestone rather than regenerated.

#### September 24 G3 relative-slope intervals and sampling limits

The blanket GPCM MML interval restriction is replaced by an output-specific
rule. `confint(fit, parm = "slopes", level = .95)` returns a matrix with a
concise print method and explicit diagnostic attributes. `diagnose_mfrm()`
uses the same 95% computation; diagnostic attachment synchronizes the fitted
slope table and its parameter-readiness rows, including weighting-review
columns. Global fit readiness and other parameter families are not promoted.
The new finite_local_solution status identifies local MML qualification,
not a certified finite global maximum. JML boundary decisions are preserved.

The covariance is the slope block of the inverse **full joint** observed
information, including population parameters. The sum-zero Jacobian maps it
to all log slopes; positive-scale bounds exponentiate normal log-slope limits.
It is not the inverse slope-information block, a population-SD-standardized
interval, simultaneous inference, or misspecification-robust inference.
The common solution check reevaluates likelihood/gradient and the unregularized
information; G3 reuses the covariance routine's freshly computed Hessian instead
of differentiating twice. Unit-weight, category, current-likelihood-identity,
quadrature and numerical-convergence restrictions still apply. Old SE/CI flags
cannot supply permission. Changed slope tables/parameters, non-unit weights,
coarse integration, failed convergence, weak categories, regularized covariance
and nonrepresentable bounds retain missing ordinary intervals and explanations.

Question and design: assess availability and pointwise coverage, including an
incomplete design, for Criterion-owned or Rater-owned slopes. All 400 G2 unit-
slope fits were reused without refitting. An additional 400 datasets use true
relative slopes exp(-.4, 0, .4). Each of eight cells has 100 independent
replicates: three criteria, three raters, three categories, N100 with all raters
versus N40 with two of three raters per Person. The normal population model is
correctly specified; q61 fixed integration, estimated intercept/variance,
maxit400 and reltol1e-10 are shared. Person sample size and incomplete assignment
change together, so this does not estimate their separate effects. Seeds,
planned cases and all outcomes are retained. No outcome was replaced.

Results:

| Design | True relative slopes | Available datasets per 100, by owner | Pointwise coverage among available intervals across levels |
| --- | --- | --- | --- |
| N100, all three raters | All 1 | 100 / 100 | 92--97% |
| N100, all three raters | 0.6703, 1, 1.4918 | 100 / 100 | 94--98% |
| N40, two of three raters | All 1 | 100 / 100 | 95--97% |
| N40, two of three raters | 0.6703, 1, 1.4918 | 96 / 97 | 90.625--97.917% |

All 800 fits returned; intervals qualified in 793 datasets. Four additional-
slope cases had regularized information and three required category-support
review. The smallest coverage-and-return rate among all planned replicates
is 87/100 (Criterion C02, sparse N40 with unequal slopes), distinct from 87/96
conditional coverage. Per-level exact binomial Monte Carlo intervals use the
96--100 independent datasets, not 3 times that denominator. They all include
.95, but that is not proof of nominal coverage or absence of undercoverage.
The low end and broad Monte Carlo uncertainty must remain visible.

Width is a substantive limitation, not just an availability count. For sparse
unequal Rater slopes, R02 has median width 1.280, 95th percentile 2.631, and
maximum width 1274.40. The mean 14.52 alone hides that tail. The widest Rater
(rep49) and Criterion (rep98) datasets were diagnostically refitted at q121;
they remain wide, with maximum slope changes 3.35e-4 and 1.20e-7. Maximum bound
changes are 1.151 and 1.69e-5 respectively. These post-hoc checks do not enter
the planned coverage denominator and do not establish a global maximum.
Four previously saved, preselected G2 q121 fits give maximum endpoint change
8.01e-7 from q61, and the saved adaptive31/fixed61 example differs by 1.21e-10.
Thus the local numerical checks allow useful regular cases while the small,
unequal-slope incomplete-design evidence limits the statistical claim.

Focused verification: six test files have 514 passes, zero failures/errors/
warnings, and four existing CRAN skips. The initial run exposed three tests
of the superseded interval/readiness policy and an older "Bounded GPCM note"
string expectation; the expectations were updated to the new specific output,
while the global-readiness assertions were retained. Integration additionally
checks public confint/diagnose agreement, attachment, weighting profiles,
confidence levels, stale-primary reset, and seven refusal cases. The first
planned replicate of each of eight simulation cells reproduces the saved
bounds under the final API. Printing excludes internal readiness fields.

Evidence: `validation-results/gpcm-slope-intervals-20260924/` contains plan,
800 saved interval outcomes (400 reused source fits and 400 new fitted data),
per-level coverage/width tables, initial/final test receipts, public API and
quadrature checks, rendered help/article and source hashes. During simulation,
subsequent edits concerned status/display text, primary-value synchronization
and documentation, not the numerical interval formula or its admission rule;
final-source API replays verify identical bounds for all eight selected cases.
No full test-suite repetition, package archive, commit, push, Win-builder upload
or CRAN submission was performed in this tranche.

G1--G3 implementation and targeted local checks are complete for their stated
MML outputs. This does **not** close M5: the combined source still needs its
final integrated package checks and a newly frozen archive. Earlier external
checks apply to the earlier tarball. The public roadmap, NEWS, help, interval
route guide and GPCM vignette now state the current behavior and small-sample
limits. Ordinary Wright/Pathway maps and plug-in information curves do not gain
slope uncertainty bands as a side effect of this work.

#### September 24 ConQuest/TAM model and inference reconciliation

Question: which existing GPCM structures and inference targets actually match
ConQuest and TAM, and what does that imply for the next model extension?
This review updates documentation and sequencing, not the fitted likelihood
or the G1--G3 eligibility rules.

Sources: the current official TAM fitting reference (Example 14c), `tam.se()`
and `anova()` help; the current ConQuest command reference; and Macaskill and
Adams (2016), *Score Estimation and Generalised Partial Credit Models*,
[ConQuest Note 8](https://www.acer.org/files/Note_8--The_ConQuest_4_Model.pdf).
All five Note 8 pages were rendered and read, including the scoring-design
formula on page 2, population/MML formulation on page 3, generalized-item and
score-group definitions on page 4, and identification on pages 4--5. The
older ConQuest 3 Note 6 was not used to attribute obsolete limitations to the
current program. The local ConQuest manual corroborates the distinction
between latent covariance and parameter-estimate error covariance.

Findings and changes:

- Corrected the incomplete TAM explanation: `tam.mml.mfr()` alone cannot
  estimate slopes, but Example 14c uses its facet intercept design with
  `tam.mml.2pl(irtmodel="GPCM.design")` and a slope design. ConQuest's default
  estimated scores belong to generalized items; a C design can change sharing.
- Explained the mathematical difference between slopes on the complete
  predictor and slopes on ability with additive rater effects. A simple
  criterion/rater example translates that difference into the severity effect.
  Independent linear intercept and score designs do not impose products of
  free slopes and free severities. This is a structural comparison, not a
  statement that either program cannot fit multifacet slope models.
- Reused the recorded TAM 4.3-25 and local ConQuest 5.47.5 item-only results.
  Current text preserves their versions, designs and historical status; no
  native engine or Monte Carlo study was rerun. Exact probability-coordinate
  checks do not establish current-source inference or general software parity.
- Added the relative-to-standardized slope transformation, specifying residual
  population SD when covariates are present. Its interval transformation needs
  joint covariance, including scale uncertainty. ConQuest's documented
  `estimatecovariances` is a possible source requiring an actual parameter-
  ordering/constraint check; `export covariance` is not that matrix. TAM's
  `tam.se()` covariance omission describes that method, not every possible
  way of obtaining a covariance. Current public `confint()` remains relative.
- Reconciled help, README, NEWS and the GPCM article. Removed the stale NEWS
  statement that IC ranking and PCM/GPCM LRT are unavailable. The roadmap now
  separates slope action, slope/step ownership and standardized-slope inference;
  it does not silently change the existing model or make full external parity
  a 0.2.4 release gate.

Targeted checks and source identities are retained in
`validation-results/gpcm-model-scope-20260924/`: regenerated Rd, executed GPCM
article, existing deterministic ConQuest coordinate/constraint checks and the
standardized-log-slope covariance identity. Estimator sources and tests are
unchanged by this review. M5 final integrated checks and the new frozen archive
remain open; there was no commit, upload or release in this tranche.

#### September 24 final API and GPCM integration

**M4/M5 are complete locally for the retained 0.2.4 scope; M6 is open.** The
frozen successor is `validation-results/local-release-integration-20260924/final/mfrmr_0.2.4.tar.gz`,
SHA256 `873a48056529a2d4cf35d9405a8246004877946fa9184d5ce8991701f7782deb`.
This decision includes the compatible API/category-summary changes, feedback
guide, G1--G3 inference and ConQuest/TAM scope explanation. It does not qualify
standardized-slope or JML intervals, new slope structures, universal coverage,
or any other research extension excluded by the current roadmap. The source
remains uncommitted and has not been sent to CI, Win-builder or CRAN.

A fresh snapshot contains 672 selected source files. Five changed articles
were executed against the installed source; the other ten HTML outputs are
byte-identical to the previous checked archive. All fifteen source/output/R
index entries agree. All 68 figures have nonempty alternative text; visible
article text contains no local/internal paths. The new confint help is included
in the website reference list. Roxygen regeneration produced no untracked
source/help discrepancy. Numerical G3 source and namespace hashes match the
800-fit interval evidence, which was reused without repeating the study.

The initial archive, SHA256
`efd5034ee1966ddac4f36cd3e63cca4ef72a4698622760795ad4f471d6de36a1`,
ran `R CMD check --as-cran --no-vignettes --timings` with `NOT_CRAN=true`,
arm64 macOS/R 4.6.1 and RTMB 2.0. It finished with **1 ERROR, 0 warnings,
1 NOTE**, not a clean pass. The full packaged suite reported 22,717 passed
expectations, five failures, zero warnings and 45 skips. Ordinary examples
(28 seconds), donttest-inclusive examples (158 seconds), PDF/HTML manuals,
namespace/code/Rd and compiled-code checks passed. The NOTE records the
maintainer and seven updates in six months. Total check time was 1,589 seconds;
maximum child-process RSS was 2,012,446,720 bytes. This is the local exhaustive
workload and a maximum per-process measurement, not a CRAN-tier time or general
model-capacity guarantee.

| Finding in the full run | Repair and retained check |
| --- | --- |
| A commented GPCM fitting description was counted as an active example lacking quadrature settings. | The example scanner ignores whole comment lines before checking execution guards. A regression includes commented fitting/parallel settings and braces while preserving detection of a real fitting call. The example-policy file passes 330 expectations. |
| APA output still expected the old “Bounded GPCM note” label. | Expect the current GPCM label while preserving the caveated report/QC/export/linking assertions; the capability file passes 215 expectations. |
| A deliberately coarse/nonconverged fit expected the superseded global parameter-readiness refusal. | Check the solution/covariance refusal and retain assertions that ordinary SEs/intervals are missing, eligibility is false and diagnostic traces remain; the identified-step file passes 33 expectations. |
| The exact namespace inventory lacked the new confint and interval-print methods. | Add both required S3 registrations; all four namespace-contract expectations pass. |
| The route guide expected the generic word “bounded”. | Check the actual shared slope/step-facet restriction; the output-guide file passes 336 expectations. |

The five repaired files pass **918 expectations, with zero failures/errors,
warnings or skips**, against the installed implementation. These overlap the
initial full run and are not independent extra tests. The first focused runner
also exposed a helper-definition ordering error in the new scanner test and
missing namespace context in the standalone test runner. Both were corrected;
initial logs/results remain in `repair-tests-initial.*`. No estimator source
was changed to make these assertions pass.

Twelve installed-suite skips concern source documentation; both source files
pass all 564 expectations separately. The fresh-process calibration case, which
was also skipped in the check harness, passes all 12 expectations against the
installed package, preserving literal IDs, saved calibration identity, scores,
interval level and refusal behavior. The remaining 32 skips require deliberately
excluded repository research artifacts; their historical evidence is retained,
not re-executed or represented as current full research qualification.

The final archive differs from the initial one in exactly the five repaired
test files and the DESCRIPTION Packaged timestamp. All runtime/native code,
namespace, help, data, examples and article content are byte-identical. Its
`R CMD check --as-cran --no-examples --no-tests --no-manual --timings` completes
with **0 errors, 0 warnings and 1 NOTE**, including all fifteen CRAN-mode article
rebuilds. The full regressions/examples/manuals were not repeated: the initial
results plus focused repairs are reused on this explicit content-identity basis.
The final check took 209 seconds, maximum child RSS 753,532,928 bytes.

`validation-results/local-release-integration-20260924/` retains the initial
and final archives, source manifests, complete logs, failed and repaired test
results, fresh-process/source-documentation checks, article/figure audits,
archive delta and resource records. Earlier GitHub/Windows results do not
certify this successor. Next release work is M6 checking/publication on the
frozen source; the package check is not evidence of general statistical validity.


#### September 24 GPCM inference follow-up audit

Question: beyond passing package checks, what is still missing from GPCM
inference, and does an independent calculation support the interval machinery?
This is a review of the frozen 873a4805 archive, not an implementation of new
inferential targets. Estimator, help, tests and the checked archive are unchanged.
The roadmap reopens a targeted M4 correction; M5's archived check results remain
valid, but public handoff must follow the correction and its applicable checks.

Verified findings:

- The full joint information is inverted before taking its slope block; the
  sum-zero log-slope Jacobian preserves nuisance-parameter uncertainty and
  cross-slope covariance. Public intervals are pointwise log-Wald intervals for
  geometric-mean-one relative slopes, with freshly checked numerical eligibility.
  IC ranking and the matched equal-slope LRT have separate requirements. No
  numerical defect was reproduced in these operations during this review.
- **Workflow/help gap:** the saved first G2 fit has eligible public slope
  intervals, yet the recommended `mml_quadrature_sensitivity()` call with grids
  61 and 121 rejects its explicit `population_formula = ~1` model as a
  user-supplied population. The refusal occurs before refitting. The public
  matched-model example uses that same explicit population route; help linking
  to the helper does not disclose the incompatibility. The existing G3 wide-
  interval follow-up worked around it with explicit same-population refits.
  The fix must preserve population design and should compare inferential
  endpoints/eligibility and paired model decisions, not just raw diagnostic SEs.
- **Computational scope:** actual supported model configurations with 3 raters,
  3 score categories and 26 versus 27 criterion slope levels contain 80 versus
  83 free parameters when population intercept/variance are estimated. The
  fitted-information routine returns `not_evaluated_dimension_limit` before
  evaluation for 83. These were configuration/count probes, not estimated
  models or capacity tests. The slope covariance routine has no parallel
  dimension limit and passes its own fresh Hessian to the shared solution check;
  IC/LRT invoke the capped routine. This documented implementation restriction
  is not a statistical rule or a Person-count limit. Reconcile the computational
  paths and resource policy before claiming large facet-count support.
- **Presentation residue:** the quadrature error text and model-role description
  still contain “bounded GPCM” / “current bounded route”. This does not alter
  inference, but belongs with the reopened workflow/help correction.

Independent numerical check: `numDeriv::hessian()` differentiated the retained
objective using Richardson extrapolation for the first planned regular G2 fit
and both previously identified widest sparse-design cases. It did not use the
analytic gradient used by `compute_mml_parameter_covariance()`. All three
independent information matrices were positive definite. Relative maximum
Hessian differences were 6.53e-7, 4.46e-7 and 1.11e-6. Maximum relative differences
in expanded log-slope SEs were 1.09e-7, 1.95e-5 and 4.74e-4 (0.0474%). This supports
the local calculation in these cases; it does not prove global optimality,
integration accuracy, or repeated-sampling coverage. The wide intervals persist
with a different differentiation method and cannot be explained by a simple
analytic-gradient differentiation discrepancy in these examples.

Remaining targets must not be confused with a defect in relative-slope Wald
intervals: pairwise slope ratios/contrasts with their joint covariance,
population-SD-standardized intervals, simultaneous intervals, bootstrap or
profile alternatives, Person-cluster robust uncertainty, and propagated curve/
information uncertainty are absent from this public API. JML does not inherit
MML covariance or reference distributions. A parametric bootstrap calibrates a
fitted-model procedure; it does not by itself repair misspecification.

Existing sampling evidence is retained, not rerun. G2 has 100 independent
replicates in each of four cells, with 5--7 null rejections and broad Monte Carlo
intervals. G3 has 800 fits across eight cells, 793 qualified datasets, and a
minimum 87/96 coverage among available intervals versus 87/100 covered-and-
returned. It changes N and assignment density together, uses only three slope
levels/categories and a correctly specified intercept-only normal population.
It does not establish latent-covariate, many-facet-level, rare-category,
selective-assignment, dependent-Person or misspecified-population performance.
Any further study should isolate the condition needed for a declared user
claim, retain all unavailable cases, and set Monte Carlo precision in advance.

Primary documentation rechecked: R-core's AIC help (maximized comparable
likelihoods); TAM's `tam.se()` help (that method ignores estimate covariances and
calls GPCM.design loading SEs highly experimental); mirt's model help (joint
information/sandwich options) and `boot.LR()` (parametric-bootstrap LRT).
These are method precedents, not evidence of mfrmr equivalence or validation:
https://stat.ethz.ch/R-manual/R-devel/library/stats/html/AIC.html
https://alexanderrobitzsch.github.io/TAM/reference/tam.se.html
https://philchalmers.github.io/mirt/reference/mirt.html
https://philchalmers.github.io/mirt/reference/boot.LR.html

Evidence: `validation-results/gpcm-inference-review-20260924/review.R`,
`review.log`, `review.rds` and `curvature.csv`. The review used the installed
frozen candidate, completed without optimizer runs, preserved the saved input,
and did not repeat the whole test suite or any sampling experiment. No commit,
external upload, or archive rebuild was performed.

## September 24 GPCM inference extensions

The user approved implementing the follow-up gaps locally. This source postdates
the `873a480...` integrated archive and every external platform check cited for
that archive or an earlier upload. No commit, push, Win-builder upload or CRAN
submission is part of this work. M4 now includes the following implemented
outputs; a new source freeze and integrated package checks remain M5 work.

| Need | Implemented contract and numerical basis |
| --- | --- |
| Explicit-population quadrature review | Replay the stored formula, person data, factor levels and contrasts; check the canonical design by Person. Preserve scoring covariates. Report fresh relative-slope interval endpoints, eligibility and changes across grids. |
| Shared information computation | IC/LRT qualification uses the same gradient-differentiated full observed information as slope intervals. The 80-coordinate IC/LRT cutoff is replaced by `mfrmr.max_information_bytes`, default 256 MiB for an estimated eight dense square matrices. This excludes data, quadrature arrays and other memory; it is not a process capacity guarantee. The separate fitting boundary-audit budget is unchanged. |
| Standardized and comparative slopes | `confint.mfrm_fit()` adds standardized slopes using log(alpha) + log(sigma2)/2, full cross-covariances, named zero-sum contrasts for ratios or differences, Wald p-values and optional Bonferroni adjustment. Ratios cancel the common scale. With covariates, sigma is the residual population SD. Defaults retain the previous relative/model calculation. |
| Sandwich intervals | Differentiate each Person's marginal log likelihood, including population coordinates and integration. Aggregate complete Person score vectors within independent clusters, and form inverse-information × score-cross-product × inverse-information. Full score rank is required. The optional G/(G-1) factor is explicit and is not a small-sample guarantee. The same aggregation helper is reused by facet intervals. |
| Bootstrap alternative | `bootstrap_mfrm_gpcm()` generates conditional-normal independent Persons and ordered responses on the analyzed assignment; reestimate free parameters. Saved draws give basic bootstrap error-quantile intervals. With an eligible PCM null, simulate under PCM and refit both models for the LRT. Trials, seeds, warnings and failures are retained; unknown outcomes widen interval or p-value bounds. No profile likelihood, BCa method, informative-missingness correction or exact finite-sample test is claimed. |
| Curve uncertainty and plots | `mfrm_curve_intervals()` uses the full calibration covariance and a numerical Jacobian for category probabilities and alpha-squared times conditional category variance per rating. Logit/log limits respect support. Theta is fixed on the native scale. Color and line type, optional titles, palette changes, plotted tables and alt text are available. Bonferroni covers the finite output grid, not a continuous band. |

Evidence is under `validation-results/gpcm-inference-extension-20260924/`:

- `integration.rds` and `integration.log`: transformed targets, both covariance
  methods and both contrast types; probability sums and information values;
  explicit intercept-only quadrature replay; 19/19 available interval bootstrap
  datasets and 19/19 available null-bootstrap pairs. The latter gives 16
  exceedances, plus-one p = 0.85, resolution 0.05 and Monte Carlo bounds about
  0.604--0.966. These small runs test mechanics, not coverage or test size.
  RNG restoration is checked. Injected refit failure tests verify retention
  without replacements; independently specified basic-error quantiles verify
  the reversed-tail calculation and unresolved outcomes reaching 0/infinity.
- `population-numerical.rds`: a categorical latent regression preserves its
  nondefault factor coding after session contrast defaults change, at 31 and
  61 nodes. Interval endpoint maximum change is 7.67e-8 and eligibility does not
  change in this example. Independently evaluated Richardson derivatives of
  three Person marginal log likelihoods agree within 8.41e-9 absolute with the
  central-difference score calculation. This is numerical evidence, not
  latent-regression interval coverage evidence.
- `above-80.rds`: one 120-Person, 3-rater, 27-criterion, 3-category GPCM, with
  83 free parameters and 61 fixed nodes, returns all 27 slope intervals and
  passes the IC solution check. Fit plus both inference calls took 52.9 seconds
  in this run. This is not a general capacity benchmark or a memory measurement.
- `paired-adaptive.rds`: explicit-population PCM/GPCM comparisons at common
  61- and 81-node grids both return the LRT (LR about 0.691, df 2, p about 0.708).
  A separate 31-node adaptive fit returns standardized sandwich intervals,
  including the Person-score derivative-sum check against the full gradient.
- `reused-coverage-rows.csv`, `reused-coverage-summary.csv` and
  `reused-family-coverage.csv`: reuse all 800 saved G3 fits with zero new
  simulations/optimizer runs. All cases remain in denominators; availability
  is 96--100 per 100-dataset cell, 793 eligible datasets in total. Standardized
  model pointwise coverage ranges 90.7--99%, sandwich 90.7--100%; corresponding
  ratio coverage is 90.7--98% and 91.8--98%, difference coverage 94--99% and
  93--99%. The minimum standardized result is 88/97 available intervals
  (Monte Carlo 95% bounds 83.1--95.7%) versus 88/100 covered-and-returned.
  Bonferroni family coverage for three standardized slopes ranges 91.7--98%
  with model covariance and 90--97% with sandwich. Two-ratio family coverage is
  94--99% and 94--98%, respectively; two-difference family coverage is 94--100%
  and 95--99%. These are 100 independent datasets per cell, not independent
  individual intervals. The original correctly specified, three-category,
  three-slope, intercept-only normal-population scope and the confounding of
  N with assignment density remain. These results do not establish robustness
  under misspecification, cluster dependence or selective assignment.
- `tests-final.csv`: 1,095 passing expectations across 11 affected test files,
  zero failures/errors/warnings, three existing CRAN-condition skips in the
  capability file (report/QC/export/linking, design/forecast and diagnostic
  screening workflows). Initial new-test findings were a name attribute in
  an expected vector and a test's assignment of an unknown factor level;
  both fixtures were corrected. A CSV writer initially attempted to export a
  list column; scalar summaries are now retained. These were not silently
  counted as an initially clean run. Unchanged passing files were reused;
  only changed/newly affected files were rerun. The whole suite was not repeated.
- `finalization.log` and the rendered `mfrmr-gpcm-scope.html`: help regenerated
  and parsed; the article executes with `NOT_CRAN=true`, including the new
  reproducible slope-comparison and sandwich examples and two described curve
  figures. Their rendered images were inspected, including removed titles.
  The earlier documentation render used CRAN defaults; only the final run is
  evidence for execution of the new chunks. API usage checks report no findings.

The methods remain explicit approximations. The reused-fit evidence does not
show uniform improvement from sandwich covariance or nominal family coverage
in every small-sample cell. Bootstrap coverage, misspecification/dependent-
Person performance, and curve-band sampling performance have not been qualified.
Numerical checks and implemented methods are not general inferential guarantees.

Method documentation was checked against the primary sandwich package overview
(Hessian/score construction and clustered covariance), R's `boot.ci()` help
(basic error intervals, transformation and unstable extreme empirical tails),
and mirt's `boot.LR()` help (fitted-model bootstrap LRT). mfrmr uses empirical
quantile type 1 and explicit missing-trial bounds; numerical equivalence to
`boot.ci()`, mirt, TAM or ConQuest is not claimed. References are in the public
interval and bootstrap help:
https://sandwich.r-forge.r-project.org/articles/sandwich.html
https://stat.ethz.ch/R-manual/R-devel/library/boot/html/boot.ci.html
https://philchalmers.github.io/mirt/reference/boot.LR.html


## September 24 GPCM inference reporting and design follow-up

This work postdates the earlier frozen archive. It completes local saved-result
connections while leaving the additional statistical-performance questions open
under M2/M3. No point-estimator switch, publication or new source freeze occurs.

- `validation-results/gpcm-inference-followup-20260924/diagnose.R` reuses every
  one of the 800 saved fits and previously calculated intervals. It obtains
  standardized estimates from saved parameters, and recovers log-scale SEs
  exactly from saved log-Wald widths. It repeats neither fitting nor Hessians.
  `diagnosis-summary.csv` retains bias among all fits and eligible fits,
  empirical dispersion, RMS SE, directional misses and Monte Carlo uncertainty.
  In the unequal-rater N=40/two-rater cell, R01 has 97 eligible datasets and
  all nine misses are above truth: 88/97 conditional versus 88/100
  covered-and-returned. Eligible log bias is .01790, empirical log SD .49024,
  RMS log SE .46682, and estimate/SE correlation -.85998. Ineligible extreme
  estimates are retained, including one log error -13.33. Eligibility selection
  must not be confused with unconditional point-estimation performance.
- `cross-design-plan.csv`, `cross-design.R` and 200 individual saved results
  complete two previously missing cells for unequal Rater slopes: N=40/full
  and N=100/two-rater assignments. Repetitions and seeds (92420001--92420200),
  q=61, ordinary MML and the original generating parameters were fixed before
  results. The two-worker run retains all generated data, fits and warnings.
  The purpose is explanatory separation of N and assignment density; 100
  independent datasets per cell give nominal MCSE .0218 at .95 coverage,
  not precision sufficient to qualify general coverage. Every new dataset
  returns both model and Person-sandwich intervals. Across the three slopes,
  model coverage is 94--98% and sandwich coverage 92--98%. R01 model coverage
  is 98/100 at N=40/full (MC 95% limits .9296--.9976), and 94/100 at N=100/two
  raters (.8740--.9777); the corresponding sandwich counts are 96 and 93.
  `cross-design-summary.csv` also records all-planned denominators, widths and
  eligible-point bias. No misspecification or dependent-Person condition is
  included, and no default estimator or interval method is changed. There are
  no fit exceptions or warnings. Individual fit-plus-two-interval elapsed times
  range 1.504--13.394 seconds, median 7.3395, with 1469.87 summed worker seconds
  in the two-worker run; these are measured conditions, not capacity guarantees.
- Saved slope/curve/bootstrap inference connects to `apa_table()`, explicit
  `mfrm_results(intervals = ...)` attachment, `mfrm_report()`, export and named
  result plots. Target, method, confidence level, multiplicity, specified
  contrasts and cluster maps remain available. Source matching checks data,
  parameters, population design and integration settings. Finite, unavailable
  and unbounded intervals remain distinguishable without color alone; curves
  retain line types and alternative text. Wright/Pathway and ordinary fit
  diagnostics keep their own targets. No rater-quality/scoring-weight decision
  is generated from slope intervals.
- The retained focused tests comprise 44 new reporting checks, 63 inference
  checks, 361 existing result checks, four namespace checks and 79 existing
  ggplot checks (551 total). All pass, with no warnings/skips in these runs.
  The original namespace test lacked the six new S3 registrations; its expected
  contract was updated and that file alone rerun. The first export test surfaced
  three expected existing fit-readiness warnings; the final test explicitly
  checks their count and wording instead of counting them as unexpected warnings.
  The whole regression suite was not repeated. A further 336 passing output-guide checks
  cover the discoverability updates (887 passing expectations across six files). `usage.log` is empty and `git diff --check`
  passes.
- `render.R` executes the changed article with `NOT_CRAN=true`, parses/renders
  changed help and saves inspectable slope/curve plots; both were visually
  inspected. `api-handoff.R` saves a 90% standardized sandwich result and
  `fresh-session.R` executes the exported replay in a new R process with fitting,
  covariance calculation and resampling traced to stop if invoked. Replay,
  reporting, plotting and exact target/cluster checks pass. The initial harness
  used the package directory instead of the explicitly documented export folder;
  it was corrected to `source(..., chdir=TRUE)`, with the initial log retained.
- `estimator-kernel-identity.csv` records exact equality to the previous frozen
  archive for likelihood, category probabilities/support, simulation and both
  native C++ files. New source fingerprints belong to this follow-up directory;
  historical evidence manifests are not overwritten. Metadata/reporting changes
  do not turn previous archive checks into checks of this new source.

Bootstrap performance across independent datasets, continuous curve-band
performance, misspecification and dependence remain unqualified. New numerical
results and completed display routes are not a universal inferential guarantee.


The full 499-refit bootstrap pilot uses the first prespecified small/incomplete
unequal-rater dataset (index 404), seed 92410404, without selecting the dataset
by its interval outcome. It runs on the pre-cache numerical implementation;
its complete bootstrap object is written to `bootstrap-404.rds` only at completion.
A single dataset, irrespective of bootstrap repetitions, cannot establish
repeated-dataset coverage. No aborted trials will be silently replaced.

A targeted runtime investigation, justified by this long run, found that the
original source dataset took 11.936 seconds although its optimizer stage took
.377 seconds. One profiled refit attributed 9.07/10.53 sampled seconds to the
all-response-pattern information audit. An inner C++ pointer-access experiment
did not materially improve total time and was reverted; no native-source change
is retained. The retained change instead reuses cumulative probabilities across
response patterns only for a fixed GPCM parameter vector, design and fixed nodes.
Pattern-specific likelihoods/posterior weights are recomputed, adaptive integration
is excluded, and the cache lives only inside the single pattern-evaluation call.
A complete source-data refit retains exactly the same free parameters, objective
and default slope endpoints. Unprofiled timings were 10.844 seconds for the
unsuccessful native probe and 9.753 seconds after the retained cache; separately
profiled totals were 10.53 and 8.47 seconds. These single-case observations do
not support a general speedup claim, and the ongoing bootstrap is not restarted.

`pattern-tests.log` verifies cached versus uncached score matrices bit-for-bit,
response-pattern reordering, changed parameters and probability-only evaluation,
and runs the existing estimability and inference-extension tests. Reusing these
quantities does not change the estimator or omit the expensive statistical audit.

The final retained test record totals 1,222 unique passing expectations in eight
files: the preceding 887, nine cache checks and 326 existing estimability checks.
The 63 inference-extension checks were rerun after the cache change and remain
passing; they are counted once. Saved 19-draw interval/LRT objects additionally
pass table, report, plot-data and customization integration while refitting,
information calculation and resampling are disabled. Their histogram was
visually inspected; these objects still verify mechanics only.

`collect-bootstrap.R` is queued locally to read the already-running pilot,
retain all 499 trials, report failure reasons and compare saved model/sandwich/
bootstrap intervals. It also checks the saved-result report/plot connection,
without refitting. It writes `bootstrap-completion.txt` only after those checks
pass. Until that file exists, the pilot has no reported completion or findings.
The waiting collector stops with an explicit error after two hours if the raw
output does not arrive. No commit, upload or publication is performed.


## RSM/PCM saved fixed-facet reporting integration (2026-09-25)

This M4 change connects existing fixed-facet inference to reporting; it does
not alter the estimator, Hessian, sandwich formula, inferential eligibility,
or pointwise critical values. `mfrm_results(intervals = ...)` accepts a single
saved result or uniquely named results from the matching RSM/PCM fit. Saved
data, parameters, constraints, population and quadrature are checked through
the existing native-fit signature. Named `facet_` plots, APA tables, reports,
CSV output and RDS replay retain methods, levels, contrasts, cluster maps and
fixed/unavailable rows. Ordinary Wright/Pathway and Person-score uncertainty
are not replaced with the attached covariance.

Base plots preserve their draw-free payload. The ggplot converter consumes
that same payload, preserving intervals rather than allowing a generic bar
chart to discard uncertainty. Component-only ggplot requests remain rejected;
`plot_data()` extracts the requested table. Title, subtitle, caption, reference
and legend omission are explicit display choices. Noninteger confidence levels
remain exact in labels; color, line types, vertical offsets and status shapes
support monochrome reading. An initial visual inspection found a duplicated
method legend when all selected intervals were unavailable; aligned scale
limits fixed it and the final image was reinspected.

Evidence is under `validation-results/facet-reporting-integration-20260925/`:

- 76 new reporting checks pass for RSM and PCM, including nondefault levels,
  specified contrasts, mismatched sources, unavailable intervals, saved export
  and replay without refitting/covariance calculation.
- Affected regressions pass: 50 facet-interval, 44 GPCM-reporting, 361 common
  result, 79 ggplot, 336 output-guide and 103 output-routing expectations.
  Total: 1,049 unique passing expectations in seven files. No unexpected test
  warnings or skips; expected export review warnings are checked by message.
  The full suite and statistical simulation studies were not repeated.
- The first test-count CSV export failed after the 74 tests passed because
  testthat includes a list column. The audit script now writes scalar summary
  columns; only the not-yet-run output-routing tests were run in the continuation.
  Both logs are retained; this was an audit-output error, not a package failure.
  A final targeted rerun adds exact confidence-level checks for APA settings
  tables, so their numeric rounding cannot display 99.5 percent as 100 percent.
- Roxygen regenerated changed help; the changed Rd files were parsed/rendered.
  The RSM/PCM article was executed with `NOT_CRAN=true`. Available, unavailable,
  monochrome and anchored-target displays were inspected. An independent R
  session replayed the exported result with fitting, covariance calculation
  and interval construction traced to stop if invoked; table, figure, exact
  confidence-level and unavailable-result checks passed.
- NEWS, interval/plot/results/APA/ggplot/export help, discovery guidance and the
  roadmap reflect the same scope. Source integration/platform checks and
  publication remain separate; this work was not committed or uploaded.

### Completion of the previously running GPCM bootstrap pilot

The queued collector has completed. `bootstrap-completion.txt` in the earlier
GPCM follow-up directory records 4,876.679 elapsed seconds for 499 planned
refits: 408 eligible and 91 unresolved, with all trials retained. The reasons
are 62 data/category-support restrictions and 29 joint-information restrictions
(near-singular information regularized on inversion). All three standardized
basic intervals are 0 to infinity when unresolved draws are retained. The
saved table/report/plot-data integration passed without refitting. This is a
single prespecified dataset, not a coverage study; no estimator/default change
or release qualification follows. Earlier statements that this pilot was
running describe the previous checkpoint and are superseded by this completion.


## Saved inference discovery and displayed replay (2026-09-25)

A user-facing integration review found that exported replay correctly reloaded
saved inference, but the reproduction code displayed in a result summary/HTML
still reconstructed from the fit without attaching those results. The common
native-result route now shows saving and loading the complete result. Summaries
also update this code for older result objects with attached inference. The
viewer receives the same summary code. Export replay uses the same code builder
with saving disabled because the RDS has already been written. Ordinary results
without attached inference retain their existing reconstruction route.

Starter export indexes now show the actual saved RSM/PCM and GPCM inference PNGs
with descriptions. RSM/PCM captions retain their facet, method and exact level;
GPCM descriptions direct readers to the corresponding target/method tables and
retain the rater-quality/scoring-weight distinction. Ordinary Wright/Pathway
uncertainty is explicitly separate. The feedback discovery guide points to the
matching results/plot/export calls; NEWS, results/export help and both inference
articles explain saving the complete object rather than rebuilding from fit.

Evidence: `validation-results/saved-inference-discovery-20260925/check.log` and
per-file scalar test summaries record 855 passing expectations in four files:
108 RSM/PCM reporting, 50 GPCM reporting, 361 common results and 336 output guide.
There are no failed expectations, unexpected warnings or skipped tests. New
checks execute the displayed save/reload code with fitting and covariance
calculation disabled, compare the complete RSM and PCM objects, verify historical
summary/HTML/viewer routes, and inspect actual starter exports for both model
families. Generated help parses successfully and the diff whitespace check
passes. No estimator, interval formula, simulation result or default method was
changed. No repeated full suite, commit, upload or publication was performed.
This is M4 integration evidence; the remaining M2/M3 performance questions and
M5/M6 source/platform/publication gates remain open.


## GPCM bootstrap rejection audit and retained diagnostics (2026-09-25)

Question: were the 91 unresolved trials numerical fitting failures, lack of
category support, or conservative eligibility decisions? The 499-replicate
object retained every seed/reason but not rejected parameter vectors. The audit
recreates each dataset with its saved seed and audits category counts without
new sampling or model fitting. It then replays only the first trial in each
recorded reason class (including the accepted control): trials 2, 9 and 1.
The resulting data, fits and information diagnostics are saved under
`validation-results/gpcm-bootstrap-audit-20260925/`; the original bootstrap
object and its 408 accepted vectors remain unchanged.

Results:

- All 62 category-check rejections have no empty category and exactly one
  singleton. The 29 information-check rejections include 15 cases with an
  empty boundary category, one with a singleton and 13 with neither. There
  are no empty internal categories in this example. These are recorded gate
  paths with potentially overlapping underlying concerns, not independent
  causal classifications or general failure rates.
- Trial 1 (singleton) returns numerical state `ready`, unregularized information
  status `ok`, gradient maximum 5.215518e-5, smallest information eigenvalue
  1.40538 and absolute scale 85.43238. Holding its data/parameters/information
  fixed and changing only the category-state flag makes the existing local
  check pass. This diagnostic counterfactual does not change the saved fit's
  real category state or authorize its use for intervals.
- Trial 9 (information rejection) also returns numerical state `ready`, but
  has smallest eigenvalue 8.544122e-7 and absolute scale 97604.53 (ratio about
  8.75e-12); its inverse information was regularized. Convergence alone cannot
  qualify this case. No weak-information threshold or optimizer was changed.
- Trial 2 reproduces the accepted parameter vector from the original run.
  No repeated-dataset performance inference follows from these three replays.

The mathematical and software restrictions are now distinguished. Basic
bootstrap error quantiles do not require a variance estimate per replicate;
R's boot documentation assigns that requirement to studentized intervals:
https://stat.ethz.ch/R-manual/R-devel/library/boot/html/boot.ci.html
This does not establish regularity, identification or stable estimation for
rejected MML solutions. The present API still uses its conservative Wald-based
gate. Relaxing it requires a separately justified point-estimate admission rule,
not deletion of failed trials or a change motivated solely by narrower bounds.

Implementation: `trials` now retains the last stage and whether alternative/null
fits returned. `checks` records category states/counts, numerical status and
already-computed information diagnostics. `refit_draws` retains returned
alternative parameter vectors before eligibility, while the existing `draws`
continues to contain only accepted interval draws. `confint()` never reads
`refit_draws`. Checks are available through APA tables, common results, reports
and exports; older saved objects lacking checks still work. No extra Hessian
calculation is introduced by diagnostic recording. New help/NEWS and the GPCM
article distinguish returned fits, rejected estimates and fitting errors.

Validation: 90 inference-extension and 50 inference-reporting expectations pass
with no unexpected warnings/skips. These cover actual-error stages, returned
but rejected vectors, null-fit errors, unchanged missing-draw bounds, saved check
reporting and legacy objects. The initial run had two assertion-only mismatches
between integer counts and equal-valued numeric counts from existing rounding/
column sums; equality assertions corrected those without changing computation.
The original log is retained. A second check reuses actual saved trials 1/2 in
the new runner, verifies the generated data against their seeds, forbids new
fitting and reproduces their rejected/accepted decisions. Both returned vectors
remain finite in diagnostic storage, only the accepted one enters `draws`, and
the accepted vector matches the original 499-trial object. The two-trial replay
verifies storage and decision paths only, not tail accuracy. Updated Rd parses
and renders; statistical study reruns and publication were not performed.

### GPCM basic-bootstrap singleton admission (2026-09-25)

**Question.** Does one observation in a score category justify excluding an
otherwise qualified point estimate from a basic bootstrap? It does not, by
itself. Replicate variances are used by studentized intervals, not the basic
error-quantile formula (R `boot::boot.ci` documentation). This does not establish
that every finite returned estimate is adequate. A singular random-effect
covariance in `lme4::isSingular` is also distinct from a singular/ill-conditioned
likelihood information matrix.

**Change.** Native GPCM slope bootstrapping has a narrow singleton exception.
A fresh data audit must confirm all step-scope categories are observed, at least
one is a singleton, and no step coordinate/category contrast is unsupported.
Identity, source/refit compatibility, convergence, likelihood reevaluation,
gradient, and unregularized-information checks remain. The source fit uses the
same admission rule. Saved readiness, Wald intervals, IC and LRT rules are not
changed. There is no automatic admission of singular-information estimates.

`checks` now distinguishes `BootstrapEligible` from `WaldEligible`, with a
`BootstrapCaution`; `source_checks` records the source decision. Accepted
singleton replicates produce one aggregate warning. Cautions persist in basic
interval diagnostics/printing, default plot subtitles, APA tables and report
outputs. Users can override plot subtitles, including with NULL, without
removing the saved diagnostics. Raw rejected vectors remain diagnostic only.

**Verification.** Three focused files passed 212 expectations (44 eligibility,
118 inference extensions, 50 reporting), with no test warnings/skips. Guards
include empty/unknown category counts, unsupported coordinates/contrasts,
incomplete audits, bad input/convergence, stale likelihood, excessive gradient
and ill-conditioned information. The ordinary default eligibility is unchanged.
Saved-data replay uses original trials 1 and 2 without new fitting: the singleton
case is admitted with a warning but still Wald-ineligible, and the adequate case
retains its original accepted vector. Fresh information evaluation of saved
trial 9 still rejects its ill-conditioned solution. Saved warnings also appear
in report tables and the default plot, with custom/NULL subtitle checks.

The previous audit retained only three representative refits. To quantify the
policy change, the remaining 61 originally category-rejected cases are replayed
from their original seeds, saving every returned fit/check. Accepted original
replicates and the original 29 information rejections are not refitted. The
assembled comparison is explicitly marked as an original run plus selected
replays, not a new 499-refit run.

Evidence: `validation-results/gpcm-bootstrap-singleton-20260925/`. The original
499-refit run and original three-case audit are preserved. No complete package
test rerun, estimator change, external upload, source freeze or coverage claim
is part of this correction. M2/M3 numerical calibration remain open.

**Completed targeted recheck.** All 62 category-rejected cases satisfy the new
bootstrap checks and remain Wald-ineligible. Only 61 new fits were needed;
trial 1 reused its saved fit. The original accepted estimates and all 499 seeds
were verified unchanged. Availability increases from 408/499 (81.8%) to
470/499 (94.2%). All 29 original information-rejected trials remain unresolved;
all three standardized 95% basic intervals still span (0, infinity). Their
5.8% unresolved fraction exceeds each 2.5% tail. The comparison removes a
category-policy artifact without demonstrating finite interval precision or
coverage. The selected replay took 545.6 seconds; no full 499-fit rerun occurred.

`category-recheck-completion.txt`, `policy-comparison.csv`,
`category-recheck-checks.csv`, `reconciled-intervals.csv` and
`reconciled-499-bootstrap.rds` retain the result. The assembled object explicitly
states that its detailed checks cover the 62 selected cases and other trials
retain their original records. `finalize-recheck.R` verifies the untouched
original draws/seeds/source and the connection to saved report tables.

### GPCM unresolved-information mechanisms and readable diagnostics (2026-09-25)

**Question and scope.** After the singleton-only correction, can the remaining
29 withheld point estimates simply be used with a warning? The audit separates
boundary behavior, premature numerical stopping and quadrature sensitivity.
It uses the original 499-trial pilot/replicate seeds. All 15 empty-category
assignments are reconstructed without estimation; the 14 nonempty cases are
reviewed numerically. A saved adequate control and saved trial 9 are reused.
Fourteen native fits are newly replayed in total (one empty-category example
and 13 nonempty cases without a retained native fit), not all 499 trials.

**Reference calculation.** For this unanchored three-rater, three-criterion,
three-category, intercept-only population model, define A_r = a_r sigma,
D_c = Criterion_c / sigma and B_rk = a_r(Rater_r + step_rk - mu). Conditional
log(P_k/P_0) is k A_r(z - D_c) minus the cumulative B_rk, with z standard
normal. Positive finite A maps back to the original geometric-mean-one
parameterization. Direct softmax/person marginal calculations reproduce the
native objective (maximum error about 2.7e-12 in the initial four cases) and
analytic gradients agree with independent numerical derivatives. Restarts
use the saved point and unit standardized slopes; conditional profiles at
A_r = 0 evaluate a limit outside the finite native coordinates. They are not
new public estimators or complete native fit objects.

The finite-difference derivative check initially failed for trials 381 and
431 because the relative difference step was respectively too large for steep
curves and too small near a zero intercept. A step-size check with a small
absolute floor reduced their maximum derivative discrepancies to approximately
1.8e-7 and 2.6e-8; the 2e-5 validation tolerance was not relaxed. Cached fits and
completed comparisons were reused. This validation adjustment does not alter
native derivatives, fitting or bootstrap admission.

**Findings for all 29.** These are primary findings, not mutually independent
statistical causes or global-maximum certificates.

| Primary finding | Cases | Evidence and limit |
| --- | ---: | --- |
| Unused highest category in the unanchored R03 step scope | 15 | At fixed finite slopes, increasing its natural intercept cost improves every affected observed-category probability. Hence the unpenalized sample likelihood has no finite threshold maximizer. A representative numerical path confirms the direction; its slopes are stable under restarts. The missing category is a sampling outcome, not a recommendation to delete the scoring category. |
| Approach to zero standardized R01 discrimination | 11 | Positive-slope restarts approach zero; conditional zero-slope profiles have no larger objective, small nuisance gradients and positive one-sided A scores at 61 and 101 nodes. These checks do not prove a global optimum or validate boundary intervals. |
| Better positive-slope interior solutions | 2 | Trials 225/271 have small native terminal gradients but negative local curvature. Reference-coordinate restarts agree on better positive-slope points. Backmapping lowers negative log-likelihood from 200.382393 to 200.379965 and from 182.201576 to 182.201149. Trial 225 then has unregularized native information; 271 has positive curvature but still fails the raw-coordinate conditioning threshold. A native BFGS restart with parameter-magnitude scaling does not recover these solutions. |
| Extreme slope and severe quadrature dependence | 1 | Trial 381 has a standardized slope about 1675. The same saved parameter vector gives negative log-likelihood 184.865096 at 61 nodes and 857.883370 at 101. Reference restarts do not establish a stable optimum. Neither grid is validated by this comparison. |

The interior and steep-slope cases make numerical stopping/scaling and
integration the next M2 priority, before broader acceptance of returned values.
Boundary reporting then needs target-specific limits: finite standardized
slopes/contrasts can coexist with divergent native relative/location/threshold
coordinates. A blanket warning cannot substitute for recovering a better
solution or resolving integration sensitivity. The source estimator and all
original bootstrap decisions remain unchanged: 470/499 admitted, 29 unresolved.
No reference candidate silently replaces an original draw. M3 repeated-dataset
coverage remains open.

**Public change and verification.** `checks`/`source_checks` now include
`PopulationSD`, `MinimumStandardizedSlope` and `MaximumStandardizedSlope` from
retained optimizer estimates; recording adds no fitting or Hessian evaluation.
They match the existing standardized-slope target on the 16 retained fits.
Unavailable source estimates remain missing. APA check tables use significant
digits for those columns and gradient/eigenvalue diagnostics, including kable
conversion, to avoid presenting small positive values as exact zero. Raw
checks remain numeric. Help, vignette, NEWS and ROADMAP explain the scope;
no automatic boundary/rater-quality classification was added.

Two focused files pass 185 expectations (127 inference-extension, 58 reporting),
including missing scale metadata, fixed population scale, no extra information
calculation and small-value preservation through APA/HTML conversion. The
existing native admission statuses are unchanged on the retained examples.
Roxygen help was regenerated and checked; no full package test rerun or external
upload was performed.

Evidence: `validation-results/gpcm-information-review-20260925/`, especially
`disposition.csv`, `all-empty-category-cases.csv`,
`all-nonempty-case-review.csv`, `interior-native-review.csv`, `public-checks.csv`
and the reproducible reference/review scripts. Interpret the CSV flags and
profile diagnostics within the stated pilot structure, not as a general API.
The distinction between convergence warnings, derivative scaling and singular
random-effect covariance is also described in the official
[lme4 convergence documentation](https://lme4.github.io/lme4/reference/convergence.html)
and [isSingular documentation](https://lme4.github.io/lme4/reference/isSingular.html);
it does not supply validity for this GPCM.

## 2026-09-25 — Recover finite GPCM solutions before relaxing inference rules

**Question and scope.** The previous audit identified two saved datasets
(225, 271) where the original native optimizer stopped with a small raw
gradient but negative numerical curvature. An independent reexpression of
the same likelihood found better finite solutions. The task here was to
recover them through the native API, without substituting reference vectors
into bootstrap draws or choosing an optimizer by its interval availability.

**Correction.** Small fixed-grid GPCM MML problems (1–64 free parameters,
requested `reltol <= 1e-9`, retained optimizer code zero) now review curvature.
For detected negative curvature, up to three BFGS restarts use an invertible
linear search-coordinate transformation, centered at the current point.
With `H = Q diag(lambda) Q'`, the transformation columns are
`Q[,j] / sqrt(max(abs(lambda[j]), max(abs(lambda))*1e-10))`.
The objective is evaluated in the original coordinates; the gradient follows
the chain rule. This floor only limits search scaling. It is not a ridge
penalty, an inverse information matrix or an inference criterion.
Each stage retains the requested `maxit`; lack of parameter movement stops
further identical attempts. Negative curvature means a minimum eigenvalue
below `-64*.Machine$double.eps*max(1,max(abs(lambda)))`; this is a numerical
review trigger, not a proof of saddle geometry.

A replacement must pass the unchanged optimizer/gradient checks, have no
detected negative curvature, and not worsen the retained objective beyond
roundoff. Actual objective improvement takes precedence over simply obtaining
a smaller raw gradient. Failed recovery retains the original point and marks
it for numerical review with a warning. All tried stages, curvature errors,
evaluation counts and elapsed costs are recorded. RSM/PCM, JML, adaptive
integration, larger problems and looser requested tolerances retain their
previous paths. The original joint information is freshly evaluated for
inference; its regularization and eligibility rules are unchanged.

**Results.** Five native refits reused the original datasets and seeds with
the original 400-step per-stage ceiling; only the two finite counterexamples
were additionally refitted at 101 nodes. No full 499-trial rerun was performed.

| Case | Native NLL before → after (61 nodes) | Result |
| --- | --- | --- |
| 225 | 200.382393 → 200.379965 | Two rescaled stages recover the reference solution; maximum raw gradient about 4.1e-6 and minimum native eigenvalue about 1.65e-4. The unchanged information and bootstrap checks pass. |
| 271 | 182.201576 → 182.201149 | One rescaled stage recovers the reference solution; maximum raw gradient about 1.3e-6 and minimum native eigenvalue about 2.65e-6. Conditioning still requires regularization, so ordinary inference/basic-bootstrap admission remains unavailable. |
| 2, adequate control | unchanged, including exact retained parameter vector | Existing eligibility preserved. |
| 9, zero-boundary control | unchanged, including exact retained parameter vector | Existing information rejection preserved; no boundary estimate was introduced. |
| 381, extreme/integration-sensitive slope | unchanged, including exact retained parameter vector | Its nonzero optimizer code/large gradient remains a failure. The new code-zero curvature path does not cure its quadrature problem. |

For 225 and 271, 101-node re-estimation changes each standardized slope by
less than 7e-6; the NLL changes are below 3e-6. This is a limited integration
sensitivity check on the two recovered cases, not a general integration or
coverage guarantee. Both improved 61-node objectives agree with the independent
reference-coordinate minima within 1e-8. Exploratory native `nlminb` attempts
(with and without a supplied numerical Hessian) did not provide a converged
replacement for both cases and are not exposed as another estimator/API.

**Verification and remaining work.** The focused suites pass 239 expectations:
64 optimizer-curvature, 48 GPCM boundary handling and 127 inference-extension;
no failures, errors, warnings or skips. They include a recoverable nonconvex
counterexample with a deceptively small raw gradient, chain-rule validation,
failed recovery with retained estimates/warnings, bounded work and unchanged
RSM/PCM/JML paths. A separate saved-result verification confirms dataset
identity, reference likelihood agreement, unchanged controls, explicit
eligibility outcomes and 61/101-node sensitivity. The initial CSV test-log
serialization failed on testthat's list column after the tests passed;
the final runner omits that column and successfully writes the results.
Roxygen regenerated `fit_mfrm.Rd`, which passes `tools::checkRd`.
Help, NEWS, vignette and ROADMAP describe the mechanism and its limits.

Evidence lives in `validation-results/gpcm-optimizer-review-20260925/`:
`replay.R`, `replay.csv`, `integration.R`, `integration.csv`, `verify.R`,
`verify.log`, `targeted-tests.csv`, and complete saved fit objects/stage histories.
The saved 499-trial bootstrap remains unchanged at 470 admitted/29 unresolved;
the new case-225 result has not silently replaced an old draw. Boundary-target
outputs, the remaining conditioning/integration issues, a specified revised
bootstrap estimator and repeated-dataset coverage remain M2/M3 work.
The search uses base R's documented
[`optim`/`optimHess`](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/optim.html)
with no new numerical dependency.

## 2026-09-25 — Verify weak MML information instead of blanket exclusion

**Question.** After the optimizer correction, case 271 had a finite positive-
slope solution but failed the raw-coordinate conditioning cutoff. Was its
unavailable interval due only to parameter units, to inaccurate numerical
curvature, or to weak statistical information? Saved fits and the independent
standardized-slope/category-intercept likelihood were reused; no optimization
or bootstrap simulation was run for this audit.

**Finding.** At the same improved estimate, native Hessian differences with
steps 1e-3, 1e-4 and 1e-5 give standardized log-slope SEs about 30.028,
26.984 and 26.959. The reference parameterization gives 26.956. Thus a coarse
finite difference contributes to the problem, while the large limiting SE
also demonstrates weak precision. The raw minimum/maximum eigenvalue ratio
is around 3e-9; the reference-coordinate ratio is around 1e-5. In contrast,
zero-boundary example 9 changes from positive to negative native curvature
as the difference step is reduced. A generic reduction of the eigenvalue
cutoff or use of the ridge covariance would not distinguish these cases.

**Shared correction.** The MML information calculation used by RSM, PCM and
GPCM now reviews an initially positive Hessian that would otherwise need an
eigenvalue floor. It obtains two additional Hessians at 1e-4 and 1e-5 and forms
two Richardson estimates, `(100*H_fine - H_coarse)/99`, using the initial
1e-3 Hessian as the first coarse matrix. Both refined matrices must admit
unpivoted Cholesky factorization. The accepted covariance is the inverse of
the final refined matrix, without flooring, a penalty or a pseudoinverse.

With `H = R'R`, `B = R^-1`, and consecutive refined matrices `H` and `H_old`,
the numerical review requires:

- `norm(B' (H-H_old) B, "2") <= 1e-3`, measuring change relative to curvature;
- both one/infinity norms of `H V - I` at most 1e-6 for the unregularized inverse;
- `sqrt(g' H^-1 g) <= 1e-4`, so a small gradient in poorly scaled raw coordinates
  alone cannot qualify a nonstationary point.

These are numerical acceptance tolerances, not statistical error bounds or
coverage guarantees. Refinement failure, nonpositive curvature or an unstable
inverse leaves covariance-based inference unavailable with a reason. The
previous well-conditioned path is unchanged. Its eight-dense-matrix workspace
estimate still uses `mfrmr.max_information_bytes`; the additional refinement
path checks a twenty-matrix estimate before allocating it. This is a workspace
estimate, not a process-memory guarantee. The extra derivatives are only used
for the initially positive, poorly conditioned cases.

**Numerical result and interpretation.** Case 271 now passes at 61 and 101
nodes. At 61 nodes, relative refined-Hessian change is 5.44e-5, inversion
residual is 5.11e-8 and curvature-scaled gradient is 5.34e-6. Standardized
log-slope SEs differ from the independent reference by at most 0.0078%; their
61/101-node relative difference is at most 0.026%. The weakest standardized
slope estimate remains about 0.01006; its nominal 95% log-Wald interval is
about `[1.14e-25, 8.91e20]`. A returned interval therefore exposes extreme
uncertainty rather than establishing useful precision or trustworthy boundary
coverage. Case 271 is now locally eligible with a caution; case 225 and the
adequate control retain exactly their previous covariance matrices.

All 11 saved zero-boundary candidates (9, 30, 54, 167, 201, 203, 317, 352,
407, 428, 431) and the unused-top-category representative (14) remain
ineligible. The integration-sensitive case 381 also remains ineligible.
These are qualification checks on saved estimates, not refitted boundary
solutions or a general proof against false admission.

**API connections.** Local IC qualification recognizes the explicitly verified
inverse with a saved caution. GPCM relative/standardized slope and contrast
intervals, curve bands and bootstrap qualification reuse the same calculation.
Warnings persist through `cautions`, `InferenceReview`, printing, default
plot subtitles, APA tables and result/report objects. Custom subtitles,
including NULL, still work. Model comparisons emit an aggregate warning and
retain `ICFitCaution`, `ICFitReview` and the requested LRT interpretation;
printing a saved comparison also shows the caution. Bootstrap checks add
`InformationRefinementVerified`, `InformationRelativeChange`,
`InformationInverseResidual` and `InformationScaledGradient`, without rerunning
information calculation for logging; APA formatting preserves their small
numeric values. Facet/step MML SE details also retain the refinement caution.
No category, source-identity, numerical-convergence, nesting or quadrature
requirement is waived by numerical verification.

**Verification.** Six focused files pass 465 expectations in their final
versions: 33 information-refinement, 52 IC eligibility, 151 GPCM inference
extensions, 58 reporting, 68 LRT and 103 information-criteria contracts.
Coverage includes known weak quadratic inverses, change of units, singular/
indefinite and oscillatory derivative counterexamples, large curvature-scaled
gradients, refusal before extra workspace allocation for all three model
families, saved caution propagation and existing interval/curve/IC/LRT paths.
No failures, warnings or skips were observed. Only files affected by later
budget/printing guards were rerun; the whole package suite was not repeated.
Help was regenerated and the changed Rd files pass `tools::checkRd`.

Evidence: `validation-results/gpcm-information-conditioning-20260925/`, especially
`conditioning.csv`, `richardson.log`, `verify.R`, `verify.log`,
`verified-271.rds`, `verified-checks.csv`, `boundary-checks.csv`,
`final-tests.csv` and the documentation log. The base numerical operations
follow R's documented [Cholesky factorization](https://stat.ethz.ch/R-manual/R-devel/library/base/html/chol.html)
and [numerical Hessian calculation](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/optim.html).

The original 499-trial object and its recorded 470 admitted/29 unresolved
decisions remain unchanged. The two repaired finite cases are separate,
explicitly qualified evidence; they have not silently replaced saved draws.
M2 still requires steep-slope integration review, target-specific boundary
outputs and a reconciled estimator/admission contract. M3 repeated-dataset
coverage is still open. This change is not a release-readiness declaration.


## 2026-09-25 — Restore release-wide completion priorities

**Question.** Do the recent optimizer/information repairs advance the agreed
0.2.4 outcomes, or has the next-work selection become dominated by a single
bootstrap dataset? The repairs address reproduced numerical defects, but
the saved-case sequence alone cannot qualify the changed inference or close
the current-source release gates.

**Decision.** ROADMAP now separates current-source M0–M6 status from earlier
archive/integration evidence. Its active completion register distinguishes
required repairs, validation of included features, demonstrably safe limited
output and excluded research. Agreed GPCM inference APIs remain in 0.2.4.
The register supersedes the previous automatic sequence of further extreme-
slope investigations; the prior numerical evidence is retained here. A new
solver is required only if a supported-result defect establishes the need,
not simply because a failed case has no finite qualified interval.

**Cross-workflow finding.** Source tracing shows that
`mfrm_facet_intervals()` (`R/api-facet-intervals.R`),
`analyze_facet_equivalence()` (`R/api-facet-equivalence.R`) and
`pool_mfrm_imputed()` (`R/api-imputed-estimation.R`) call the changed
`compute_mml_parameter_covariance()` routine. Their covariance-admission code
checks successful/unregularized information, but does not explicitly retain
the new `solution_information$inverse_review` caution in the returned result.
GPCM warning/reporting checks therefore do not establish complete integration
of the common information change. This is a source-level impact finding;
reachability under each API's model/eligibility restrictions and a real-data
warning omission have not been demonstrated in this review.

**Next bounded work.** Trace these consumers and the remaining common-MML
callers, verify reachability and failure behavior under their own supported
models, and preserve applicable cautions through saved/displayed results.
Then freeze the estimator/output contract and independent evaluation protocol
before new confirmation outcomes. The protocol must separate availability,
conditional coverage, covered-and-returned frequency, width and resources,
with prespecified criteria and Monte Carlo precision. Reuse unaffected prior
evidence; do not rerun unrelated studies merely to accumulate checks.

**Completion and verification boundary.** Local completion requires supported
user workflows, consistent help/NEWS/reporting and a checked current archive;
platform checks/publication and CRAN acceptance are separate. No new numerical
fits, simulations or package tests were run for this documentation/source
review. Markdown references and whitespace are checked locally. The original
499-trial object and all earlier numerical evidence remain unchanged.

## 2026-09-25 — Preserve common MML cautions across consumers

**Question and scope.** Does the newly verified unregularized inverse lose its
weak-information caution outside the GPCM slope/curve routes? This review
traces every direct consumer of `compute_mml_parameter_covariance()`. It
changes propagation and presentation, not the estimator, covariance formulas,
numerical-refinement thresholds or inference-admission rules.

**Findings and repairs.** Fixed-facet intervals, practical equivalence and
Rubin pooling admitted `status = "ok"` covariance without preserving the new
inverse-review notice. These routes now emit a warning and retain applicable
`cautions`, `information_review` and `InferenceCaution` table columns.
Ordinary result tables without a caution retain their existing columns.
Pooled reviews retain every imputation's list position; identical warnings are
combined with the affected indices. A failed/ineligible completion still stops
pooling rather than disappearing from its denominator.

| Consumer | Disposition |
| --- | --- |
| `mfrm_facet_intervals()` | Caution reaches model/sandwich result tables, printing, plot data, base/ggplot default subtitles, APA tables and attached `mfrm_results()` output. The numerical review has its own report table. A focused test exposed a further omission from report Markdown; the report overview now includes the caution. |
| `analyze_facet_equivalence()` | Summary, joint-test, pairwise and mean-deviation tables retain the caution. Curated printing adds the notice; saved plot data and drawn plots expose it. Equivalence decisions and approximations are unchanged. |
| `pool_mfrm_imputed()` | Full covariance and Rubin calculations are unchanged. Tables, printing, RDS and plot data retain the indexed notice. `title`/`subtitle`, including NULL, allow display customization without deleting saved cautions. |
| Facet and step diagnostic SEs / main diagnostics | Existing detail propagation was confirmed in the shared SE helpers and traced into diagnostic precision notes. The step table already retains covariance detail. Focused tests exercise the helper outputs; this is not a completed whole assessment-to-feedback walkthrough. |
| GPCM expected-score and fair-average delta calculations | Both used generic successful-covariance descriptions that dropped the caution. Existing detail fields now append it; numerical SEs and descriptive/conditional interpretation remain unchanged. |
| Quadrature review | Its successful covariance status formerly omitted the calculation explanation. `CovarianceDetail` now accompanies the status, including failed-information explanations. |
| GPCM inference / local IC comparison | Existing qualification and caution routes were inspected and retained. Their earlier focused evidence is reused; no new likelihood, IC, LRT or slope-interval claim is made by this presentation repair. |

**Reachability and evidential limits.** The public fixed-facet and pooling
routes keep their ordinary RSM/PCM, fixed-standard-normal, weight and readiness
restrictions. Equivalence keeps its current MML/readiness and estimable-contrast
requirements. None independently excludes a successful verified-information
result before reading its covariance. Consumer-contract tests use eligible
example-data RSM/PCM fits and inject a verified review at that boundary while
leaving the fitted covariance unchanged. The review itself comes from the
analytic weak-quadratic refinement test. Tests confirm downstream reachability,
unchanged numeric results, caution persistence and refusal when covariance is
unavailable. They do **not** establish that the example ratings themselves
have weak information, the real-data frequency of this branch, or interval/test
coverage. The earlier actual GPCM case 271 remains separate numerical evidence.
No random simulation or search for an endogenous weak RSM/PCM dataset was added.

**Verification.** Nine affected test files pass 658 expectations, with zero
failures, errors, unexpected warnings or skips. The new consumer tests account
for 95 of those expectations. Existing fixed-facet, equivalence, imputation,
report/export, quadrature and GPCM diagnostic tests cover unchanged behavior.
Only affected files were repeated after later presentation repairs, not the
whole package suite. Plot rendering exposed a title/subtitle overlap after
adding a second subtitle line; additional top spacing and a shorter pooled
notice resolved it. The rendered fixed-facet, equivalence and pooled plots
were visually inspected. This was a temporary display check, not a new public
visualization or novice-usability study.

Roxygen initially used the installed namespace, which generated documentation
against the wrong source. Regeneration against the local development namespace
restored the topics; a subsequent pass completed without messages. The five
changed help topics pass `tools::checkRd`, and `git diff --check` is clean.
NEWS/help describe the warning's meaning and retained output fields.

Evidence: `tests/testthat/test-mml-information-consumers.R` and
`validation-results/mml-consumer-review-20260925/` contain the source hashes,
focused test logs and final per-file results. No original 499-bootstrap results
were changed. The source-tracing/propagation repair is complete at this scope;
M2/M3 statistical qualification, M4 whole-workflow integration and M5/M6 remain
open. The next work is to fix the estimator/output contract and independent
evaluation protocol, not automatically optimize another extreme-slope case.

## 2026-09-25 — Register the current-source inference confirmation protocol

**Decision and purpose.** The next gate is source-matched statistical evidence,
not another unconstrained optimizer probe. The prospective specification is
[`gpcm-inference-confirmation-protocol-0.2.4.md`](gpcm-inference-confirmation-protocol-0.2.4.md),
ID `mml-gpcm-confirmation-20260925-v1`. It separates the estimator contract,
numerical integrity, output-specific sampling questions, warnings/failed outcomes
and resource feasibility. Review margins are declared project choices, not a
claim of universally acceptable coverage or criteria taken from a reference.

**Comparison identity.** A complete historical source matching the most recent
pre-repair development state was not established from the records inspected.
The paired comparator is therefore explicitly an ablation of the current source:
disable post-code-zero curvature restarts, weak-positive-information refinement
and the basic-bootstrap singleton exception. It is not a past release. Exactly
three one-line guards differ, recorded in `ablation.diff`. A combined comparison
measures the joint policy effect; it cannot separately causally attribute each
performance difference to a single guard. Mechanism logs and prior regression
cases support interpretation without adding more fit arms automatically.

**Prospective design.** N40/100 × rotating-two/all-three raters × Rater/Criterion
owner × unit/spread slopes gives 16 cells with 500 datasets each. Fixed facet
parameters, normal abilities, preserved 1:3 categories and independent assignment
are explicit. Relative/standardized slopes, contrasts, model/sandwich methods,
finite curve families and matched PCM comparisons reuse each paired dataset and
fit. No unassigned rating is imputed. The protocol does not add misspecification,
latent-regression or arbitrary-design coverage claims. Earlier numerical/API
checks and unaffected RSM/PCM/MI studies are reused with their original limits.

Independent generation/reference and failure-aware summarization still need a
runnable preflight. Registered plans do not establish their correctness. All
returned, eligible, finite and covered counts stay distinct. Unknown bootstrap
outcomes cannot disappear, and an all-support interval cannot count as finite
availability. Paired summaries respect dataset-level dependence; performance
and Monte Carlo uncertainty are reported separately from numerical checks.

**Nested cost gate.** The registered bootstrap phase selects 400 outer datasets
before outcomes, with B=499, including separate slope and PCM-null targets.
It entails up to 598,800 inner model fits across both arms. The historical
single-dataset 499-bootstrap object records 4,876.679 seconds (about 81 minutes).
Simple equal-cost extrapolation gives about 1,626 serial hours or 813 hours with
two ideally parallel workers, far beyond the phase's 48-hour envelope. This is
one earlier difficult dataset and assumes comparable PCM/GPCM refit cost; it is
not a forecast with calibrated uncertainty. It is enough to reject an automatic
bulk launch. No nested confirmation was launched; feasibility remains unresolved.
Do not disguise fewer replications, easier cases or the previous one-dataset
pilot as completion of the registered question. Any efficiency/budget/design
revision must be explicit before its confirmation outcomes.

**Artifacts and verification.**
`validation-results/mml-gpcm-confirmation-20260925/` contains 131 source files per
arm, source manifests, the three-line diff, the copied protocol, 8,000 primary
IDs, 400 nested IDs, 16 engineering preflight IDs and SHA-256 registration.
All R files in both arms parse. All recorded hashes match; only the three
specified source files differ. The planned seed IDs have no overlap with the
2,956 seed values found in earlier `*plan*.csv` files. This is an audit of those
archived plans, not of every unindexed RNG state in every saved object.
`resource-gate.json` retains assumptions and arithmetic. The production R/src
files were not edited; no new data, fits, bootstrap trials or package-wide tests
were run. This snapshot freezes study inputs, not the final release archive.

M2 now has a registered source/decision protocol; its engineering and remaining
boundary-output checks are open. M3 evaluation, M4 full workflow and M5/M6 remain
open. The next bounded work is independent generator/target/summary preparation
and main-phase preflight, preserving the nested cost limitation explicitly.

## 2026-09-25 — Complete engineering checks and retain the confirmation cost gate

**Question and role.** Before spending the registered confirmation budget, can
the runner reproduce the stated model, associate each output with its correct
target/source, retain failed attempts and fit inside the execution envelope?
This is engineering qualification of the experiment. One reserved dataset per
cell cannot establish interval coverage, Type I error or repair benefit.

**Implementation and source identity.**
`mml-gpcm-confirmation-preflight-0.2.4.R` independently generates scores from the
adjacent-category formula, decodes parameters and calculates target truths.
Independent `statmod` quadrature and finite differences check the native NLL
and gradient; segmented adaptive integration checks the fitted NLL without
using the native quadrature rule. Parameter-layout assertions limit this
reference to the registered three-rater/three-criterion model.
`mml-gpcm-confirmation-summary-0.2.4.R` preserves every assigned cell and target;
injected failures verify attempted, returned, finite and covered denominators.
Unbounded intervals remain distinct from finite intervals. Family coverage
keeps correlated targets within a dataset rather than treating them as
independent replications. No coverage percentages from these engineering
datasets are presented as qualification.

Both frozen sources installed in separate libraries. Each worker verifies its
package namespace and native DLL path. All 262 registered source-file hashes,
the protocol/plans and the frozen runner hash still match. The 16 engineering
seeds are 1599990001 through 1599990016; no primary confirmation or nested
bootstrap datasets were generated. The comparator remains the explicit
three-rule ablation, not an historical release.

**Observed numerical results.** All 32 arm/cell jobs saved usable artifacts,
with no captured operation errors or warnings. Every expected target was
available in this sample. Maximum discrepancies across the jobs were:

| Check | Maximum absolute discrepancy (gradient is scaled) |
| --- | --- |
| Independent/native response probabilities | 4.44e-16 |
| Independent/native same-grid NLL | 2.27e-13 |
| Independent finite-difference/native gradient | 4.25e-08 |
| Independently decoded/output point estimates | 3.33e-15 |
| Continuous-integral/Q61 NLL | 1.83e-07 |

All registered engineering probability, same-grid NLL and gradient thresholds
pass. Row, category, facet, scale and source identities also pass. Adaptive
integration reported maximum relative integration error 9.19e-10; this is an
integrator diagnostic, not a bound on every statistical inference.

An initial summary audit compared the entire curve-grid data frame with
`identical()`. `expand.grid`'s unused `out.attrs` made that test falsely fail.
The audit now compares exact column names, values and order, with explicit
input-row/category checks. A fixture verifies that removing the unused
attribute passes and reversing rows fails. No package calculation was changed
to make this audit pass. The summary also withholds time projections from an
incomplete or error-containing engineering run.

**Integration sensitivity.** Saved Q101 refits were reused by
`mml-gpcm-confirmation-quadrature-0.2.4.R` to evaluate every declared interval
and curve target; this follow-up did not refit models again. All 32 cases
retained eligibility, with no gained or lost interval rows. Maximum absolute
endpoint changes were 3.49e-06 for relative/standardized slopes, 5.74e-06 for
ratios, 5.74e-07 for standardized differences, 1.80e-07 for probabilities and
1.91e-05 for information. These are changes on the respective target scales,
not an across-scale accuracy score or a new acceptance threshold. Q101 and
Q61 agreement is a sensitivity check, not proof of exact integration.

Across the two source arms, all 7,552 matched target rows have identical point
estimates and endpoints. No weak-information caution occurred. Thus this
preflight supports implementation consistency in these cases, but supplies no
observed benefit from the three repaired policies. Earlier difficult cases
retain their separate regression role.

**Resources and decision.** Two workers, each with one native thread, completed
the engineering jobs. `/usr/bin/time -l` failed to retrieve OS clock information
after the first two R jobs had saved results. Those successful fits were not
repeated to obtain memory measurements. Python `os.wait4` obtained each later
child's resource usage: peak RSS 376.6–452.2 MiB for the remaining 30 workers.
This resolves the measurement problem in this sandbox; it is not a general
memory-capacity guarantee or a measurement of combined process peaks.

Primary stages total 428.306 seconds across the 32 engineering jobs. Applying
the registered replication counts, selected Q101 refits/endpoint reviews and
continuous-reference checks gives 30.54 ideal two-worker hours. Startup/I/O,
load variation and additional work on adverse weak-information cases are not
included. With one timing dataset per cell this is a rough forecast, but it
already exceeds the registered 24-hour main envelope. The main cost gate is
therefore **not satisfied**; no bulk run was launched. The separate nested
bootstrap gate remains unresolved, with its previous cost evidence unchanged.

About half the primary-stage time is spent in the 24 interval/curve calls per
fit. Source tracing confirms that these calls recompute common covariance and,
for sandwich inference, person scores. The next bounded task is to assess
reuse of identical inference inputs while preserving estimates, admission,
interval transformations and source identity. A speedup has not yet been
implemented or demonstrated. Record and verify any source/execution revision
before confirmation; do not quietly reduce B, replications or targets.

**Evidence and completion status.** The artifact directory
`validation-results/mml-gpcm-confirmation-20260925/` contains installed arms,
saved inputs/results, per-stage timings, per-child resource records,
`preflight-cases.csv`, target/family/paired tables, Q101 output artifacts,
`main-resource-preflight.csv` and `engineering-audit.json`. The latter records
script hashes and the preserved registration identities. Only validation
scripts and development records changed; no production R/src, public API,
help or NEWS claim was changed, and no package-wide test suite was repeated.

M2's engineering numerical check is complete for this registered design;
execution feasibility and the remaining boundary-output checks are open.
M3 statistical qualification, M4 workflow integration and M5/M6 remain open.
This does not mark 0.2.4 ready for publication.

## 2026-09-25 — Reassess necessity before optimizing the confirmation grid

**User question.** Is the projected 30-hour analysis actually necessary?
**Decision.** The complete registered grid has not been justified as the
minimum evidence needed for the release. Do not launch it or begin an efficiency
repair merely to make that grid affordable. The previous next-action ordering
put implementation cost ahead of the necessity of the scientific questions.

The 30.54 hours is an engineering projection for 8,000 new datasets and two
source arms, not a statistical lower bound. The separate nested bootstrap is
not included. Five hundred replications per cell provide an interpretable
Monte Carlo precision, but that alone does not justify all 16 cells, both arms
for every question, and every repeated API call as mandatory release work.
The 16 engineering datasets had identical arm outputs and no weak-information
caution. That is not evidence that the changes never matter; it shows why
the general grid alone is not a sufficient rationale for checking rare repairs.

Existing evidence includes the 800 G3 datasets and 200 additional crossed
sample-size/assignment cases documented above, independent derivatives and
transformations, and the focused common-MML consumer checks. The earlier
sampling results have limitations and adverse/inconclusive findings; they are
not invalidated wholesale by a change to conditional numerical branches, nor
automatically transferable to those changed branches. Source-path applicability
must be established before reuse. Bootstrap and curve sampling qualification
remain gaps; mechanics checks alone do not close them.

The necessary sequence is (1) map retained release claims to changed code and
existing evidence, (2) complete numerical/safe-failure checks for affected
paths, (3) specify independent sampling only for unresolved statistical
questions at a decision-relevant Monte Carlo precision, and (4) measure and
optimize that justified plan if necessary. Saved difficult cases remain
regression evidence, not an unbiased sample for coverage or failure frequency.
Correlated targets and deterministic multiplicity transformations must not
multiply the apparent independent sample size or trigger needless refits.

Protocol v1, its source snapshots, plans and outcomes are retained unchanged.
A successor design must explicitly describe evidence reuse, changes and any
unresolved question before new confirmation outcomes. Revising a validation
plan does not remove an agreed API, assert general coverage, erase a failure
or by itself complete M2/M3. ROADMAP now prioritizes this necessity review
over caching or bulk execution. No simulations, tests, production edits or
publications were performed for this decision review.

## 2026-09-25 — Map retained claims to evidence and audit changed admissions

**Decision and scope.** The registered 8,000-dataset/two-arm grid is not a
mandatory release deliverable. Retain its frozen records without launching it.
The release needs correct supported outputs and honest qualification, not
completion of one chosen experimental design. The following mapping replaces
automatic execution or optimization of that grid. It retains the agreed APIs
and explicitly leaves unanswered statistical questions open.

| Retained output or claim | Evidence that can be used, with its limits | Required remaining work; reason for additional sampling |
| --- | --- | --- |
| Ordinary relative/standardized model and sandwich slope intervals | Historical 800-fit evidence, the additional 200 standardized-slope fits, independent scores/Jacobians, and current engineering checks. Ten selected historical controls reproduce endpoints exactly under current inference. | Do not relabel the historical coverage as current-source coverage. Trace changes in estimates/admission before pooling evidence. New sampling is needed for a new performance claim about changed branches, not to recheck every confidence-level option. |
| Ratios and differences | Ratios cancel common SD; independent transformation checks apply to the specified coefficients. The historical extension script used **relative** differences (first-second, first-third); protocol v1 uses **standardized** differences (first-second, second-third). A new independent analytic check verifies standardized differences, full scale covariance and both multiplicity options for both covariance methods. | Historical difference coverage does not qualify a different scale or contrast. Preserve that gap if discussing standardized-difference sampling performance; do not add independent fit runs merely because an algebraic transformation has another API option. |
| Probability and information intervals | Independent probability/information values, derivative/output checks and Q61/Q101 engineering sensitivity. These are fixed native-ability calibration targets. | Sampling coverage of the retained curve targets is not supplied by slope coverage. First assess whether saved data contain reconstructible generating truths and matching fitted references for a transparent reanalysis. Any fresh sampling must target an identified remaining question. |
| PCM–GPCM LRT and local IC | The 400 historical null pairs are already included in the 800-fit corpus, not 400 additional independent datasets. Their rejection rates are 5–7 per 100 with wide MC intervals. Existing nesting, likelihood, counting and failure tests are reusable as implementation evidence. | Check changed solution admissions and matched-likelihood outputs. Do not re-run broad model-selection/power studies to validate arithmetic or claim that asymptotic calibration follows from a numerical pass. New Type I error evidence, if needed, uses null datasets; slope/curve alternatives are not substitutes. |
| Basic bootstrap intervals/test | Independent quantile and unresolved-trial checks, saved source/replicate diagnostics, and the original 499-trial case with 470 admitted/29 unresolved. | Verify each changed admission and retain failures, source identity and unbounded results. Outer-dataset sampling is necessary for a bootstrap-coverage claim; increasing inner B or replaying selected failures cannot establish it. The unlaunched costly nested plan is not itself a release requirement, and its unanswered question is not marked complete. |
| Restart/refinement and warnings through user output | Repaired numerical counterexamples, unchanged controls, strict refusal examples, consumer tests, and the two further historical admissions examined below. | Finish representative boundary/unavailable/wide-result display and replay checks. A new solver, universal finite intervals or a general coverage guarantee is not required. A reproduced inaccurate supported result requires repair before dependent simulation. |

**What “reuse” means here.** All eleven files in the September 24 extension
manifest differ at the whole-file level from the current source. This does not
prove eleven numerical regressions (comments and reporting changes also affect
hashes), but rules out claiming exact whole-source identity. The current
working R/src snapshot still matches all 131 current-arm registered files.
Reused historical results retain their own conditions, limitations and source
identity. The 800+200 total is not 1,000 replications of one design. No current
coverage percentage is inferred from the selective replay below.

**Retrospective replay, without fitting.** Before evaluation,
`reuse-audit-selection.csv` selected the first replication of each of eight
historical G3 cells, all seven originally unavailable G3 datasets and the first
replication of each of the two additional cells. On these 17 saved fits, the
current public interval API gives:

- All ten previously eligible controls retain exactly the same endpoints.
- Five of seven originally unavailable datasets remain unavailable.
- G3 indices 460 (Rater owner) and 667 (Criterion owner) now return their three
  relative-slope intervals with the verified weak-information caution.

An interim commentary incorrectly said all seven remained unavailable after
only part of the printed output was inspected. The full CSV audit exposed the
two changes; that statement was corrected before drawing the reuse decision.
The original summaries and availability counts are not overwritten. In
particular, this is not a complete re-evaluation of 800 current estimates or a
claim that only these two datasets could change after fresh optimization.

**Independent standardized-difference check.** On saved engineering case 16,
the analytic derivative of `C (a sigma)` includes the log-SD coordinate and all
cross-covariances. It reproduces model/sandwich and pointwise/Bonferroni public
endpoints exactly in the recorded computation. Omitting SD uncertainty changes
the target variance by about .00150/.00158, so the check detects that omission.
It validates the calculation, not the coverage of the transformed target.

**The two changed admissions.** The earlier standardized-coordinate reference
was generalized only to swap the owner/non-owner roles in this same 3×3,
three-category model. Parameter round-trip and perturbed-point likelihood
checks verify the mapping separately for each owner. No model was optimized.
Same-grid native/reference NLL differences are zero. Q101 and continuous
integration at the same saved parameters change NLL by at most 1.03e-11.
These are fixed-point integration checks, not Q101 refits or global-optimum
proofs.

The initial direct comparison of native delta-method and reference-coordinate
log-slope SEs failed the previously used 1e-4 relative tolerance: differences
were .0006485 and .0048448. These failures remain recorded. A Hessian does not
transform simply by congruence at a nonstationary point. For native coordinates
`v = t(z)`, the exact chain rule is
`H_z = J' H_v J + sum_i g_v[i] H(t_i)`.
The saved curvature-scaled gradients are 3.65e-5 and 5.34e-5, not zero. Including
this nonzero-gradient term reduces the SE discrepancy to at most 2.95e-7 for
reference derivative steps 1e-4, 1e-5 and 1e-6. A coarser 1e-3 step was also
retained in the sensitivity table. Thus the failed congruence-only check is
explained by the coordinate/finite-stationarity assumption; it is not evidence
of a wrong native information inverse. No tolerance, optimizer or covariance
formula was changed to make it pass, and the native intervals were not replaced
by reference-coordinate intervals.

The standardized intervals are extremely wide: minimum lower/maximum upper
endpoints across slopes are approximately 3.93e-26/8.66e20 and
1.97e-24/3.36e19. Numerical consistency does not establish useful precision or
nominal weak-information coverage. Saved slope and curve results retain the
caution; the actual report table has three cautioned slope rows in each case.
An initial audit used a nonexistent report-table name; the follow-up checks
the explicit `gpcm_slopes_intervals` table and its row count, avoiding a vacuous
empty-table pass. Original audit outputs are retained separately from this
correction.

**Evidence and stopping point.** The existing confirmation artifact directory
now contains `audit-reuse.R`, selection/results CSVs, the independent
standardized-difference check, `audit-admitted.R`, `reference-owner.R`,
`review-admitted.R`, saved admitted-case results/reports, the initial failed
audit and coordinate follow-up, and `reuse-audit-identity.json`. Original
registration hashes are unchanged. This work generated no datasets, optimized
no models, ran no whole-package suite and made no production R/src changes.

Claim/evidence mapping is complete at this scope. It identifies concrete changed
admissions and target mismatches rather than requiring a blanket 30-hour rerun.
The next release work is the representative boundary/wide-result user workflow
and its warning/default/help consistency. Statistical performance of changed
admissions, standardized differences, curves and bootstrap remains explicitly
unqualified where evidence is insufficient. These gaps must receive a justified
target-specific evaluation or an explicit disposition of the proposed claim;
they cannot disappear merely because the broad grid is no longer mandatory.

## 2026-09-25 — Preserve unavailable and weak inference through figures and reports

**User outcome and findings.** The representative display review uses actual
saved GPCM results: weak-information G3 case 667, unavailable G3 case 468, and
the existing 499-trial bootstrap source 404 with unbounded standardized
intervals. It does not generate a new statistical study or refit these models.
The unavailable curve example had 21 of 21 missing intervals, yet its figure
showed ordinary curves without a visible unavailability cue. The weak example's
default curve subtitle ran beyond the right figure edge. CSV/HTML tables kept
the inference explanations, but the report's Markdown overview omitted those
explanations and the distinction between finite, unbounded and unavailable
intervals.

**Repairs.** Curve plots now mark retained estimates without intervals using
crosses, include an availability-count caption, and break ribbons at unavailable
grid points within each context/category. Grouping follows the ability axis
even for unsorted supplied rows. Categories retain both color and line type;
the interval marker has its own legend and the alternative text explains it.
Default subtitles/captions wrap at the tested output size. Explicit
`caption = NULL`, like title/subtitle removal, removes text without removing
markers or saved reasons. The raw probability/interval table is unchanged.

GPCM Markdown report summaries now include finite/unbounded/unavailable counts
and the saved `InferenceReview` text. Test-result tables are labelled as such,
not counted as intervals. No interval is recomputed by this report change.
For extremely wide positive slope/ratio intervals, the guide uses the existing
`as_ggplot(ci) + ggplot2::scale_x_log10()` route, with strictly positive finite
bounds/estimates and linear axes for signed differences. No new scale API or
automatic default-axis change was introduced. Axis transformation does not
improve precision or coverage.

**Observed workflow checks.** The three representative result objects retain,
respectively, three finite (but very wide), three unavailable, and three
unbounded slope intervals. Numeric endpoints, target/method, eligibility and
reasons survive named result attachment, plots, report tables, both result and
report CSVs, local exports and RDS replay. The bootstrap's saved draws and all
trial records remain exact after replay. Its source formulas recreate R
environment identities on serialization; semantic object equality and exact
numeric draw/trial equality are checked instead of pointer identity. Final
Markdown checks verify the actual weak-information caution, unavailable reason
and three-unbounded count.

The generated weak, unavailable and unbounded figures were visually inspected,
including the optional logarithmic slope view. The corrected unavailable curve
shows all 21 crosses with its count; the weak curve's full caution fits in the
default figure. This is author display QA, not an independent novice-reader
study or a guarantee for every custom output size.

**Verification and source boundary.** The affected reporting test file passes
77 expectations with no failures, errors, unexpected warnings or skips. New
checks cover missing middle points, unsorted grids, all-unavailable curves,
caption removal without losing markers, warning wrapping, and Markdown counts
and reasons. The file was rerun after the subsequent Markdown repair; unrelated
package tests and numerical studies were not repeated. The initial test-result
CSV writer attempted a list column; the saved test results were recovered and
exported as scalar fields without rerunning the passing tests for that issue.
Export auditing was corrected to check both result/report CSV copies, and the
RDS audit distinguishes formula-environment identity from saved data equality.

Help/NEWS and the existing GPCM tutorial were updated. Only two Rd topics were
regenerated, and both pass `tools::checkRd`. An initial source-audit assertion
named the public report wrapper instead of `mfrm_report_build`; the final AST
comparison identifies exactly two changed production definitions:
`plot.mfrm_curve_intervals` and `mfrm_report_build`. All other parsed definitions
in the three edited production files match the registered current snapshot;
remaining registered production files are unchanged. The frozen numerical
protocol/inputs remain intact. No estimation, covariance, admission rule or
interval formula was changed, so this display repair does not require a new
coverage experiment.

Evidence is in `validation-results/gpcm-display-review-20260925/`: before/after
public figures, saved result objects and local exports, `workflow-checks.csv`,
`final-tests.csv`, corrected Markdown reports, `final-source-audit.log` and
`source-review.json`. No GitHub/CRAN publication occurred. This completes the
representative interval-display/replay review. The complete assessment-to-
feedback workflow and unresolved target-specific statistical qualifications
remain open; neither all M4 work nor release readiness is claimed.


## 2026-09-25 — Complete the educational assessment-to-feedback walkthrough

**Question and scope.** Can a user follow the existing educational assessment
example from declared categories and assignment review to rater feedback and
saved output without contradictory instructions or loss of interpretation?
The current-source `mfrmr-workflow` vignette was executed locally. Its two
entry routes (bundled data and CSV import) use the same 282 synthetic ratings:
48 persons, six raters and three criteria. The declared roster has 288 cells,
with six planned ratings absent and no unexpected observed cells. Both reviewed
facet networks are connected. This is user-workflow QA, not a new simulation,
independent novice-reader study or validation in other application domains.

**Observed defect and repair.** The stored diagnostic precision profile supports
the ordinary MML precision contract, but `summary(mfrm_results(...))` failed to
pass it to the common decision helper. Its decision and the report consequently
said precision had not been evaluated. Result summaries now pass the saved
precision support and tier, retaining the source-fit gate. Report precision
evidence can also use the diagnostic profile when the separate precision-review
component was not requested. This changes summary composition, not estimation,
intervals, numerical thresholds or statistical eligibility. Missing profiles
remain unreviewed; unsupported profiles and restricted fits cannot become
formally supported from this change.

**User guidance.** The quick start and CSV/review examples now declare rubric
bounds and use `category_policy = "preserve"`; the workflow help uses the same
canonical argument while preserving its old/new migration table. The vignette
explains that session options affect screening and that numeric `misfit_warn`
uses a reciprocal lower cutoff. Its six raters remain unflagged under the
unmodified 0.5–1.5 and absolute-severity-1 defaults, while the separate response
screen still selects 141 of 282 ratings. Neither fact establishes rater quality.
The new reload example locates the RDS through the written-files manifest.
It distinguishes reopening collected results from a precomputed-fit replay
recipe and from saving the separate feedback dashboard.

Follow-up questions now point to covariance-aware rater differences, assigned
missing-score imputation, external-attribute groups and observed-score G/D
planning. The guidance separates missing attributes from missing scores,
excludes unassigned cells from imputation, keeps G/D on its observed-score
scale, and names dedicated output/saving routes rather than treating those
objects as ordinary MFRM results. No new analysis family or estimator is added.

**Verification.** All executable vignette chunks completed with current source;
the optional explicitly unevaluated external observed-writing example was not
rerun. After the decision repair, the HTML and exports were rebuilt using the
two saved fits and diagnostics, avoiding another fit. Summary/report decisions
agree; the restored full result equals the exported object and retains actual
`mfrm_diagnostics`, not an empty placeholder. The ordinary replay recipe also
runs with its documented precomputed fit/diagnostics inputs. Existing saved
PCA, partitions, group comparison, pooled score-MI, and complete/incomplete
D-study objects retain nonempty summaries and matching plot payloads without
new fitting, imputation or simulation. These checks reuse the earlier branch
evidence and do not renew its sampling qualification.

A focused regression passes 16 expectations, including supported, absent,
unsupported and source-restricted precision states, report consistency and a
blocked unexpected diagnostic call. The two regenerated Rd topics parse and
`git diff --check` passes. The first validation-only CSV writer attempted to
flatten the structural-missingness list instead of its summary table; the
saved analysis was recovered without refitting. A documentation checksum list
also included the `man/figures` directory; the file-only inventory and Rd checks
resolved that audit error without repeating tests. Original logs are retained.
Evidence is in `validation-results/assessment-feedback-walkthrough-20260925/`,
including `executed-workflow.rds`, before/after HTML and exports, `finish.R`,
`finish.log`, final test results and `documentation-check.log`.

**Release implication.** The representative educational walkthrough is complete
as author integration review. Whole-package checks, external CI and publication
were not run. Target-specific inference qualification remains open under the
existing evidence map; neither this repair nor the workflow's formal-precision
label supplies missing coverage evidence. M5 archive freezing and M6 publication
remain later milestones.


## 2026-09-25 — Evaluate missing GPCM targets using all saved fits

**Question and design.** Earlier slope intervals cannot supply sampling evidence
for standardized differences, category probabilities or information curves.
The retrospective plan `gpcm-saved-target-reanalysis-0.2.4.md` was written before
coverage calculation. It uses every one of the 800 historical G3 fits: eight
original conditions with 100 independent datasets each. No new data generation,
optimization, outcome-dependent selection or tuning was performed. The 400
PCM-null pairs are included in these 800 datasets, not additional evidence.

All 800 input truths were verified before coverage evaluation. The generating
facets are random across datasets; their saved vectors were centered to the
fitted sum-zero location reference. Shifting raw Theta by the two original
facet means reproduces the same probabilities and information to numerical
precision. Population SD is one, steps have zero within-scope means, and there
are no injected interaction/DIF effects or extra noise. First/second/third
slope levels remain matched by name. This addresses a real scale-matching
requirement, not merely relabelling a plotted axis.

**Execution identity and efficiency.** The frozen September 25 current-arm
library and its matching native DLL supply interval calculations. The numerical
bodies of the two public interval APIs match working source. All 131 frozen
source hashes remain intact; only plotting/report-composition function bodies
differ in the working tree. A validation-local exact-fit lookup reuses one
information matrix and Person-score sandwich calculation per fit; no production
cache or formula is changed. All 96 direct-public-API/table comparisons on the
first replication of each of eight cells match exactly, including availability
and reasons. The computation finished in 185.7 seconds with two processes,
within the declared 15-minute budget. The initial source-audit script looked
for a nonexistent constraint label; inspection showed the actual `centered`
and `anchors` fields, which were checked before any coverage calculation.
The failed initial audit log is preserved. No statistical rule changed.

The analysis combines historical fitted points with current interval checks.
It is not a fresh evaluation of optimizing all 800 datasets with the current
estimator, not a holdout and not evidence of the benefit of repaired branches.
Two datasets receive numerical cautions. There are 121,600 dependent target
rows; they are not 121,600 independent replications. Every original index is
retained, and every case has all 152 planned output rows.

**Targets.** At native Theta -2, 0 and 2, evaluate all three owner levels with
the other facet at its second level. There are 27 category-probability targets
and nine per-rating information targets. The two slope targets are
standardized first-minus-second and second-minus-third differences, retaining
population-SD covariance. Model and independent-Person sandwich intervals use
level .95 and `adjust = FALSE`. Bonferroni applies separately to the 27-, 9-
and 2-member calls. Family coverage is one all-target event per dataset.

| Target | Pointwise model coverage | Pointwise sandwich coverage | Bonferroni model family coverage | Bonferroni sandwich family coverage |
| --- | --- | --- | --- | --- |
| Standardized differences | 91–98% | 91–99% | 92.9–98% | 93.9–98% |
| Probabilities | 88–100% | 85.6–99% | 84.7–96% | 83.7–97% |
| Per-rating information | 90.7–100% | 89.8–99% | 95–100% | 92–98% |

Ranges are across original conditions and prespecified targets, conditional
on available intervals or complete available families. Pointwise availability
is 96–100/100 depending on the target and condition. All planned denominators,
conditional and covered-and-returned rates, exact binomial MC intervals,
median/95th-percentile widths, warnings and reasons are retained in CSV.
In the small incomplete unequal-rater-slope condition, the sandwich probability
family covers 82/98 available datasets (83.7%; cell-specific MC 95% interval
74.8–90.4%), or 82/100 planned datasets. The model family in that condition
covers 83/98. The worst pointwise sandwich probability is 83/97 (85.6%) in
the small incomplete unequal-Criterion-slope condition. These are adverse
findings, not a nominal-coverage pass. Selecting a minimum across cells does
not give that minimum a simultaneous binomial confidence interval.

**Implication and public guidance.** Bonferroni cannot fix an inaccurate
marginal approximation, and sandwich is not an automatic cure. The GPCM
vignette now reports the actual target-specific results, scale alignment,
denominators and source limitations; it no longer describes the finite-grid
adjustment as necessarily covering that grid. Curve/slope/scope help and NEWS
point to the limitation. Earlier bootstrap counts and conditioning statements
are explicitly tied to their saved audit stage, not presented as the current
status of later separately repaired candidates. No API was removed and no
arbitrary sample-size refusal or estimator/interval change was introduced.

**Verification and stopping point.** The three regenerated Rd topics parse;
the updated vignette renders with numerical examples skipped because their
code did not change. The all-case truth audit, API equivalence and aggregation
checks pass; these are computation checks, not statistical-performance passes.
`git diff --check` passes. Evidence is under
`validation-results/gpcm-target-reanalysis-20260925/`: source plan/truth hashes,
per-case outputs, full row/point/family tables, warning counts, scripts/logs,
source audit and rendered vignette. No whole-package tests or publications ran.

The missing-target retrospective evaluation is complete; M3 is not. The next
question is whether the probability shortfall is an approximation limitation,
a scale/calculation defect or materially changed by current optimization.
Numerical identities already narrow that question, but do not substitute for
its attribution. Any targeted refit/independent confirmation must address this
specific adverse finding with a stated target and precision. The broad
30-hour grid and nested bootstrap remain unlaunched; bootstrap outer-dataset
coverage remains a separate unanswered claim.


## 2026-09-25 — Attribute probability undercoverage with matched current refits

**Question.** Does the low probability-family coverage arise because the
retrospective analysis used estimates from an earlier optimizer? The protocol
`gpcm-probability-refit-attribution-0.2.4.md` selected the entire adverse
unequal-rater-slope, rotating-40 cell before this comparison: 100 original
datasets, including all uncovered and unavailable cases. These are a subset
of the earlier 800, not additional independent replications or a holdout.

**Execution.** Ordinary initialization, GPCM with Rater step/slope ownership,
free intercept/variance normal population, preserved 1–3 categories, Q61,
maxit 400 and reltol 1e-10 were retained. Input hashes, prepared rows, category
maps, parameter dimensions and population designs were checked. The frozen
current numerical implementation and its native DLL were used; the source
comparison identified only already recorded plotting/reporting differences.
Later display-text edits in this turn leave the numerical implementation
unchanged. Two processes completed the 100 refits in 479.5 seconds, within the
15-minute budget. All fits returned; no captured operation errors occurred.
Warnings and all planned indices are retained.

**Paired results.** Maximum changes in objective, parameter vector, category
probability and available interval endpoint are all exactly zero. There are
no materially improved objectives and no changes in available or covered
families under either covariance method or adjustment. The nominal-95%
Bonferroni probability family remains 83/98 for model covariance and 82/98
for Person-sandwich covariance; the latter is 83.7% with cell-specific MC 95%
interval 74.8–90.4%, or 82/100 covered and returned. The prespecified attribution
criterion is met: updating optimization does not explain the observed
shortfall in this selected cell. Pointwise-interval all-target event counts
are also stored, but they are not judged against 95% simultaneous coverage.

**Independent transformation check.** The first and last planned refits
(indices 404 and 800) were specified for a computation-only supplement before
its evaluation. An independent 11-coordinate softmax calculation supplies
analytic probability derivatives for all nine contexts and 27 probabilities.
The derivative agrees with Richardson differentiation within 5.53e-10;
probabilities agree with the API within 3.34e-16. Using the same full covariance
inputs, model/sandwich probability SEs agree within 9.14e-12 and pointwise/
Bonferroni endpoints within 1.84e-9. This checks the transformation, not the
accuracy of the estimated covariance, global optimization, integration or
finite-sample approximation. The results do not establish approximation error
as the only possible cause or generalize the exact old/new equality to every
model condition.

**User output.** Curve printing now says that the intervals are approximate
and numerical availability does not establish nominal coverage. Default plot
subtitles identify approximate calibration intervals at fixed ability. Existing
custom subtitle omission remains available. This addresses a real ambiguity:
the former print method omitted the generic `InferenceReview` on available
rows, leaving the qualification visible only in the full table/help. No
interval formula, numeric table, eligibility threshold or API scope is changed.
The GPCM guide records the full-cell comparison, its lack of independent
replication and appropriate interpretation. README, NEWS and the curve help
retain the corresponding limitation. No sample-size rejection rule or ad hoc
widening of intervals was added.

**Checks and completion.** A saved actual unavailable-curve result verifies
printing, default and omitted subtitles, unchanged original table columns and
unchanged serialized input. The first display check compared the full plot
table against the source table and failed because plotting adds context/group
columns; comparing the original columns resolves that test error. Both logs
are retained. The updated Rd topic parses and the guide renders with unchanged
numerical examples skipped. `git diff --check` passes. Evidence is under
`validation-results/gpcm-probability-refit-20260925/`, including all fits,
paired rows/families, state/warning records, source checks, independent
transformation results and the rendered guide.

The matched optimizer-attribution task is complete and should not be repeated
without a relevant change. It does not close M3. The remaining release decision
is the qualification of the retained approximate inference outputs, with
adverse finite-sample evidence preserved. Bootstrap coverage/provenance remains
a separate question, not a presumed fix. A new interval procedure would need
its own justified specification/evaluation rather than being introduced solely
to make this selected condition's percentage larger. No new simulated data,
whole-package tests, bootstrap study or external publication were performed.


## 2026-09-25 — Set GPCM release dispositions and preserve bootstrap reanalysis history

**Decision.** M3 now has an explicit release disposition for each retained
inference family, rather than an open-ended demand for more simulations.
Relative/standardized slopes, ratios/differences, fixed-native-ability curves,
matched IC/LRT and fitted-model bootstrap remain available as the specified
approximations. No agreed API is removed or moved to a later release. This
settles the release interpretation, not all statistical performance questions:
probability-family nominal coverage is contradicted in the evaluated adverse
cell, and bootstrap repeated-dataset coverage/Type I error is unqualified.
The guide and roadmap distinguish these facts from numerical correctness.
No new probability-interval method or improved-coverage claim is introduced.

**Bootstrap provenance.** Read-only reconciliation identifies two distinct
objects, correcting the earlier shorthand “original 499-trial case with 470”:
`gpcm-inference-followup-20260924/bootstrap-404.rds` contains the original
408 admitted / 91 unresolved run. The separate
`gpcm-bootstrap-singleton-20260925/reconciled-499-bootstrap.rds` combines its
original draws with 62 selected category-case updates, giving 470 / 29.
All seeds and the original source identity agree. All 62 substituted parameter
vectors match their retained seed-specific records, and all other draw rows
remain exact. The later repaired cases 225/271 are still unresolved in that
assembled object; there is no 472-admitted result or complete current-procedure
run. Both input-file MD5 hashes are unchanged after review. The same three
standardized basic intervals remain zero to infinity.

**Reproduced output defect and repair.** The assembled result already stores
`settings$recheck` and `settings$diagnostic_checks_scope`, but these did not
reach the derived interval cautions or sampling tables. Thus printing/reporting
could show 470 admitted without its changed-procedure context. The existing
saved-history fields now follow interval settings, a short generic caution,
printing, default slope plots, interval/sampling tables and result/report
output. Custom subtitles still work and do not erase table metadata. A saved
null-test result retains the history through its separate print/table path.
Ordinary results without those optional fields retain their existing tables;
absence is not proof that an older object used current procedures. No draw,
quantile, interval formula, estimator or acceptance rule changes.

**User guidance.** The GPCM vignette now has a question-to-evidence table
covering each inference family. The bootstrap history is shortened to the
scientifically necessary distinction between an original run and selected
updates; development-stage narration remains in this internal record.
Boundary/numerical findings and their statistical limits remain in the guide.
Help explains that a complete separate run is needed to evaluate a changed
bootstrap procedure; it does not instruct users to silently replace failed
trials. NEWS records the actual output repair and retained limitations.

**Verification.** The modified GPCM reporting test file passes 91 expectations,
with no failures, errors, warnings or skips. Its new regression covers unchanged
numeric intervals/availability, printing, plot customization, APA tables,
interval/result/report metadata, nonmutation and the separate null-test print
path. The actual 499-trial objects independently verify retained seeds, all
62 replacements, 29 unresolved outcomes and unchanged input-file hashes.
Fitting, resampling and covariance recomputation are disabled in the actual
saved-output check. Only `bootstrap_mfrm_gpcm.Rd` changes on regeneration;
the topic parses and the GPCM guide renders with unchanged numerical chunks
skipped. An initial one-line documentation command failed during parsing due
to string escaping, before execution; a script using `[.]Rd$` completes.
Artifacts and logs are in `validation-results/gpcm-release-disposition-20260925/`.

**Next gate.** M5 must freeze and check one successor source/archive, preserving
these dispositions and the previously completed numerical/workflow evidence.
No whole-package check, new simulation, selected-refit rerun, commit, upload or
publication is performed in this tranche. M5/M6 remain open. The completed
100-case attribution and 800-fit reanalysis should not be repeated without a
relevant source change or failure; the unlaunched broad and nested studies
remain unexecuted, not silently marked successful.


## 2026-09-26 — Complete local integration of the retained inference scope

**Outcome.** M5 is complete locally for the retained 0.2.4 approximate-output
scope. The frozen successor is
`validation-results/local-release-integration-20260925/final/mfrmr_0.2.4.tar.gz`,
SHA256 `0f1f21c042512318a3b3c8ffbce246bcdab21db1d3dc2dce2cf5e091c58155e1`.
M6 platform/Windows checking and publication remain open. This local completion
does not repair the observed probability undercoverage, establish bootstrap
repeated-dataset accuracy, or change the release dispositions above.

**Source and articles.** The initial staging copied 686 selected source inputs,
with 66 changed files and three changed articles relative to the previously
checked September 24 archive. Facet-interval and GPCM articles execute against
the installed current source. The educational workflow renders current
summaries/reports/plots with exact-input saved fits and diagnostics from the
completed walkthrough, without repeating its fits. Twelve other article HTML
files remain byte-identical. All fifteen article sources/outputs agree, all
72 figures have nonempty alternative text, and user-visible article text has
no local/internal paths. A staging cleanup inadvertently removed the prebuilt
vignette index, generating an additional detail in the initial NOTE. The index
was restored only after every current title, dependency, keyword and output
path matched its fifteen entries. The final installed index is verified too.

**Initial exhaustive check.** The initial archive SHA256 is
`7a0800a9e97ca51257c7c9a20afdc996302641f1f1a216e64221791fb158c69f`.
Its `NOT_CRAN=true`, `R CMD check --as-cran --no-vignettes --timings` run
completed with **1 ERROR, 0 warnings, 1 NOTE**. The packaged suite reports
**23,290 passed expectations, three failures, zero warnings and 45 skips**.
Ordinary examples (24 seconds), donttest-inclusive examples (141 seconds),
PDF manual (11 seconds) and HTML manual (12 seconds) pass. The three failures
are not hidden by the final metadata check:

| Finding | Repair and evidence |
| --- | --- |
| A malformed `mfrm_fit` with unsupported predictions reached interval routing before its explanatory refusal; a missing model produced an NA logical branch. | Move the existing unsupported-attachment refusal before interval routing and require a scalar true model-family match. The new missing-model interval regression also refuses clearly. Four affected reporting files pass 428 expectations, without failures/warnings/skips. |
| Two GPCM coordinate-check expectations fail because their mocked IC checker lacks the added `allow_singleton` argument. | Update the test double to accept and assert FALSE for that argument. All 88 expectations pass. Production eligibility is unchanged. |
| The initial staging omitted the unchanged fifteen-entry vignette index. | Restore the independently matched index and verify all installed targets. The corresponding NOTE detail disappears. |

**Coverage of skipped checks.** Two source-tree documentation/S3 test files
pass 574 expectations and cover the twelve installed-source-documentation
skips (the counts overlap other checks and are not independent evidence).
Only the skipped fresh-session calibration case and its fixture are selected
from the public-API file; it passes all twelve expectations against the final
installed package. The remaining 32 skips require deliberately excluded
repository research artifacts. They retain their prior scope and are not
claimed as executed by this integration check.

**Final archive and reuse.** The archive delta is exactly six paths:
DESCRIPTION (date/Packaged metadata), NEWS, `R/api-results.R`, two repaired test
files and `build/vignette.rds`. Every other archive byte, including numerical
core, help, data and article output, is unchanged. Parsed definitions identify
`mfrm_results` as the sole changed runtime function after the full run; its
change concerns input routing, not numerical computation. Focused checks cover
its report/interval consumers, and direct final-installed checks verify the
repaired refusals. This justifies retaining the successful full-run evidence
without repeating the entire suite, examples, manuals or completed simulations.
All final source-input hashes match the working source at completion.

The exact final archive passes
`R CMD check --as-cran --no-examples --no-tests --no-manual --timings` with
**0 errors, 0 warnings, 1 NOTE**. All fifteen vignette outputs rebuild in CRAN
mode. The remaining NOTE is maintainer information and seven updates within
six months. The final check intentionally does not rerun the full suite;
its result must be reported together with the initial failures and the focused
repairs, not as a fresh all-green exhaustive run.

**Environment, resources and limits.** Checks used arm64 macOS/R 4.6.1.
A preliminary sandboxed attempt stopped during dependency/incoming repository
queries due to DNS restrictions, before tests. Its logs are in `network-attempt/`.
The completed checks use permitted read-only network access; no package upload
is performed. The resource wrapper records 1,682.9 elapsed monotonic seconds,
1,560.0 user-CPU seconds and maximum child-process RSS 3,220,717,568 bytes
(about 3.0 GiB) for the exhaustive run. The final complementary check takes
269.4 seconds. These are this local workload's measurements, not a total
concurrent process-tree memory estimate or a general capacity guarantee.
UTC timestamps are also retained separately; no hardware-performance claim
is inferred from their elapsed differences.

**Records.** `validation-results/local-release-integration-20260925/` retains
initial/final archives, source manifests, exact archive delta, article audit,
all failed and repaired checks, source-doc/fresh-session results, resource
records and `receipt.json`. ROADMAP now records M5 completion and M6 as the
next gate. `cran-comments.md` is rewritten as a current preparation draft;
its former detailed chronology remains in this journal. No commit, push,
Win-builder upload, GitHub release or CRAN submission was performed.


## 2026-09-26 — Prepare the checked successor for GitHub CI

The user explicitly requested committing/pushing the accumulated local work,
cleaning the Git working tree and running the five-platform checks. The branch
is `main`, tracking `Ryuya-dot-com/mfrmr`; fetched remote and local HEAD agree
before the new commit. All 686 packaged source inputs still match the M5 final
manifest (with the recorded resaved-data exception). Ignored validation results,
libraries and compiled intermediates remain local; cleaning the Git tree does
not delete the evidence archives.

The actual CI source-truth step exposed a stale September 22 citation date
against DESCRIPTION's September 26 date, and a public-roadmap phrase blocked
by its existing reader-facing check. CITATION.cff now matches the candidate
date, and the roadmap spells out counts of planned and available datasets.
These files are excluded from the package; numerical sources and the frozen
archive are unchanged. The source-truth and maintenance-admission CI prerequisites
both pass after this correction. No eligibility rule or CI guard was relaxed.
The five-platform run will use the pushed commit; its results must be recorded
separately from the completed local package checks.

## 2026-09-26 — Complete successor five-platform CI and website deployment

**Source and authorization.** The requested commit/push is complete on `main`:
`6f541bfa3ff5eb6f59e513ee4a375956e9119eb7`, "Integrate GPCM inference and
finalize 0.2.4 workflows". All accumulated source changes were included. Ignored
local evidence and libraries were preserved. No numerical source change or
additional simulation was needed during CI.

**Platform results.** [Run 36155335441](https://github.com/Ryuya-dot-com/mfrmr/actions/runs/36155335441)
completes successfully at that exact commit. Each job logs `Status: OK`, zero
errors/warnings/notes, and the checked commit identity:

| Environment | R | Job | Result |
| --- | --- | --- | --- |
| macOS arm64 | 4.6.1 | 108138363648 | Success |
| Windows | 4.6.1 UCRT | 108143941851 | Success |
| Ubuntu release | 4.6.1 | 108143941716 | Success |
| Ubuntu oldrel-1 | 4.5.3 | 108143941847 | Success |
| Ubuntu devel | 2026-09-23 r90586 | 108143941698 | Success |

Each job builds its own source archive, checks it with `--no-manual` and
`NOT_CRAN=false`, then passes two international-input cases, eight moved-folder
replay cases and the repository review. The CI archives are not asserted to be
byte-identical to the prebuilt M5 local archive. This is platform/package-check
evidence, not a fresh exhaustive suite, `--as-cran` run, G4 confirmation or
statistical-performance qualification. The M5 local archive and full-run repair
history remain as recorded above.

**Website.** [pkgdown run 36155335057](https://github.com/Ryuya-dot-com/mfrmr/actions/runs/36155335057)
succeeds at the same source. Its `gh-pages` commit is
`14d111c5b5831b64469589d3e061d937183798a4`; the matching
[Pages deployment](https://github.com/Ryuya-dot-com/mfrmr/actions/runs/36159750653)
also succeeds. The public `mfrm_curve_intervals` help and `mfrmr-gpcm-scope`
tutorial return successfully and link their sources to the full checked commit.
No successor release tag/archive, Win-builder upload or CRAN submission was made.

**Record-only follow-up.** ROADMAP and cran-comments now distinguish completed
main/platform/site integration from outstanding tagged release assets and any
further submission checks. This follow-up changes those two documents and this
journal only, all excluded by `.Rbuildignore`. The result-recording commit uses
`[skip ci]` to avoid repeating checks or rebuilding the site for unchanged package
inputs. The source-truth precheck is rerun on the changed public wording.
Machine-readable run results, five job logs and the two published HTML pages
are retained under `validation-results/github-integration-20260926/`.

## 2026-09-26 — Publish the verified rc.6 tag and archive

The user requested release-tag creation after the successful five-platform CI.
The existing candidate lifecycle is preserved: the next tag is `v0.2.4-rc.6`,
not a final `v0.2.4` declaration. Its annotated tag object is
`9031d0ee88fb3decaa8e7ef6b2ace87da20929d5`, pointing to
`a7529b73a76f131cdd7368ce69d1af6267b42b0b`. Remote tag resolution was verified.
That commit adds only package-excluded records to the five-platform implementation
`6f541bfa3ff5eb6f59e513ee4a375956e9119eb7`.

The [GitHub pre-release](https://github.com/Ryuya-dot-com/mfrmr/releases/tag/v0.2.4-rc.6)
is public, not a draft, and was explicitly not marked as the latest stable release.
Its two attachments are the unchanged M5 `mfrmr_0.2.4.tar.gz` and a SHA256 file.
All 686 selected source inputs match the final source manifest; the packaged
source identity and unchanged archive hash were rechecked before upload.
Both public assets were downloaded afterwards. The downloaded archive and
checksum agree with SHA256
`0f1f21c042512318a3b3c8ffbce246bcdab21db1d3dc2dce2cf5e091c58155e1`.

Release notes describe GPCM/API changes, compatible entry points, approximate
inference limits, the exact CI source and the distinction between the initial
full local check, its repairs and final complementary checks. No full suite,
simulation, archive rebuild, Win-builder upload or CRAN submission was repeated.
The existing website deployment already matches the implementation.

ROADMAP and cran-comments now record verified candidate publication, while
keeping the final-release/submission decision and statistical qualification
separate. The follow-up publication record changes only these two excluded
documents and this journal; `[skip ci]` avoids another unchanged-source run.
Preparation notes, tag/source identities, release metadata, downloaded assets
and checksum verification are retained in
`validation-results/release-rc6-20260926/`.

## 2026-09-26 — Check rc.6 submission prerequisites and upload to Win-builder

The user asked to continue with the stated URL, reverse-dependency, Windows
and submission-note preparation. The archive is unchanged from rc.6:
SHA256 `0f1f21c042512318a3b3c8ffbce246bcdab21db1d3dc2dce2cf5e091c58155e1`,
6,925,015 bytes. No rebuild, model fit, simulation or full local test run was
needed for this step.

**URLs and reverse dependencies.** The current official CRAN source index
contains 25,196 packages and lists mfrmr 0.2.3.1. Reverse Depends, Imports,
LinkingTo, Suggests and Enhances each have zero entries. This covers that index,
not private or non-CRAN users. urlchecker reviews 152 URL occurrences and 76
distinct references in the exact archive, with HTTP-status exclusions disabled;
there are no reported problems. Seven distinct references are new relative to
the September 24 submission snapshot, including a README section link whose
target heading is present. Unchanged DESCRIPTION DOI references retain their
previous normalized-link evidence. No package link edit was necessary.

**Uploads.** The official HTTPS Win-builder form accepted the same archive for
R-release at 2026-09-25 17:04:45 UTC and R-devel at 17:05:29 UTC (September 26
in Japan). Both HTTP 200 responses identify the expected filename and exact
size. The local receipts bind the submitted file to the archive hash. Each
version was sent once. These are receipt confirmations, not completed checks;
current result links/logs remain pending and earlier results are not substituted.
A narrowly scoped search of connected Gmail found no mfrmr Win-builder result
messages; the user has been asked to share the current result links when received.

**Submission notes and scope.** cran-comments is shortened to the changes,
candidate identity, check environments/results, remaining NOTE and pending
Windows results. The detailed preceding failed-check/repair/reuse history is
preserved here and in the prior Git version. ROADMAP records received uploads
and remaining result review. No final-release tag, lifecycle change or CRAN
submission is performed while current Windows results remain unavailable.
Only package-excluded records change, so the existing candidate and check
evidence remain unchanged. Evidence, URL databases, the CRAN index, scripts,
HTML upload responses and receipt timestamps are retained in
`validation-results/cran-preflight-20260926/`.

## 2026-09-26 — Review both current Win-builder results

The user supplied the result links for the rc.6 uploads:
[R-release](https://win-builder.r-project.org/58oV2XD8gB7Q/00check.log) and
[R-devel](https://win-builder.r-project.org/jNhW5RFMe5gs/00check.log).
Both run on Windows Server 2022 x64/UCRT and report **0 errors, 0 warnings,
1 NOTE**. R-release is R 4.6.1; R-devel is 2026-09-21 r90579 (the binary identifies
R 4.7.0). Their sole NOTE reports maintainer information and seven updates in
six months. No calculation, API or documentation repair is requested by it;
CRAN acceptance is not inferred from this result.

**Executed scope.** Both logs pass installation, examples, the selected CRAN
test tier, vignette rebuilds and PDF/HTML manuals. Each test log records 3,683
passes, zero failures, zero test warnings and five skips: one fresh-process
calibration case, three CRAN-specific GPCM omissions and one compiled-source
contract. The fresh-process route already has the separately recorded local
evidence; no fresh Windows execution of that skipped case is claimed. Unlike
the September 24 result, neither log lists missing/old RTMB skips. This does
not extend the statistical qualification of shared-rater or other model outputs.
The test logs retain ICC/lme4 convergence and singular-fit messages despite
their zero test-warning counts; successful package checks do not mean every
fit encountered in tests converged. These messages are retained, not suppressed
or presented as a new coverage guarantee.

**Attribution and preservation.** Each result manifest covers ten saved result
files: check/install logs, example source/output/PDF/timings, test driver/output
and startup file, and the Windows ZIP. SHA256 manifests are retained. Both ZIPs
pass integrity checks. Namespace, NEWS, all 15 installed article sources and
the test driver match the uploaded candidate after normalizing line endings;
the DESCRIPTION Packaged timestamp matches 2026-09-25 15:22:20 UTC. Together
with the recorded upload identity and user-supplied notifications, these support
attribution to archive SHA256
`0f1f21c042512318a3b3c8ffbce246bcdab21db1d3dc2dce2cf5e091c58155e1`.
The server does not publish a source-archive hash, so binary checks are not
represented as an independent server-side source-hash verification.

The supplied notifications give installation/check times of 128/1,538 seconds
for R-release and 133/1,587 seconds for R-devel. Logs and binary receipts are in
`validation-results/cran-preflight-20260926/winbuilder-R-release/` and
`winbuilder-R-devel/`. The main preflight receipt now records reviewed results.
ROADMAP and cran-comments replace pending status with the observed outcomes.
Only excluded records change; no archive rebuild, repeated numerical tests,
new release tag or CRAN submission is performed in this step.

## 2026-09-26 — Review next-feature GPCM and interface proposals

The user's proposals were checked against source `7d12af23`. Namespace/formal
inspection confirms 208 exports, 35 `plot_*` names and 44 registered `plot()`
methods. First arguments among the 35 are x=20, fit=13, fits=1 and reference=1;
main=8, title=0, ci_level=10, level=0 and preset=28. This prefix count includes
the two `plot_data*` extraction helpers and is not a count of figure types.
The per-function inventory is retained as
`validation-results/post-release-scope-review-20260926/plot-arguments.csv`.

The primary route and primary/specialist pkgdown organization already exist.
The report and export consume `mfrm_results`, not the return value of `plot()`.
Focused APA tables, fixed bias reports and replay exports have distinct input
and output roles; no wholesale superseded/deprecation designation is justified
by counts alone. The guide already has RecommendedEntry/UserLevel/APILayer
metadata, but its Lifecycle column mixes stage and role concepts. A future
cleanup must preserve existing guide consumers and distinguish these concepts.

`as_ggplot()` has dedicated name/class routes as well as a tabular fallback.
Clustering/PCA, main-effects D-study, multivariate difference intervals, pooled
intervals and screening-performance payloads have explicit refusals. Other
families have dedicated conversions. This static review is not a complete
class/type/component conversion test matrix. The next delivery specifies that
matrix and an aligned purpose gallery before introducing additional mapping
machinery. Shared appearance can reuse the current resolver/internal theme;
global option precedence and replay semantics remain to be implemented.

The GPCM kernel already accepts distinct step and slope indices, but supported
fitting, inference, simulation and reporting retain the shared-owner contract.
Owner separation is therefore not implemented by deleting one guard. It still
admits only one slope family and preserves full-predictor slope action initially.
Profile intervals require target-specific constrained nuisance optimization;
they are not supplied by the joint Hessian alone and do not automatically fix
probability-interval undercoverage or outrun bootstrap. The method references
are Fischer and Lewis (2021), DOI 10.1007/s11222-021-10012-y, and the official
lifecycle stage documentation. These informed planning, not a new estimator
implementation or a comprehensive statistical literature review.

ROADMAP now sets explicit next-delivery conditions for navigation/lifecycle,
argument compatibility, ggplot support, an accessible purpose gallery,
individual rater sheets, consistent appearance, separate GPCM ownership,
profile inference and portable scoring. These are proposed extensions and
acceptance conditions, not claimed implementations or a reopening of the
checked 0.2.4 source. Individual sheets must preserve model-specific meanings,
available uncertainty, identifiers/privacy and readable interpretation.
Only excluded planning records change; no package code, help, NEWS, archive,
full suite, simulation, release tag or submission changes in this review.


## 2026-09-26 — Start local development with purpose-based plot guidance

Work continues on `development/output-guide-plots`, identified as 0.2.4.9000
with development lifecycle and unset release dates in DESCRIPTION/CITATION.
The rc.6 tag, archive, main branch and hosted site are unchanged. Their check
results remain evidence only for the frozen candidate, not this development
branch. README now distinguishes rc.6 from the new development-only scope and
corrects its stale rc.5 installation guidance.

`mfrmr_output_guide("plots")` provides 28 selected routes: 14 dedicated
converters, two native ggplot methods, one explicit generic table view and
11 unavailable conversions with alternatives. Each row names its input class,
result-creation help, plot call, reusable data component and conversion call.
The table is intentionally curated; neither all plot variants nor all
components are certified. Public help and the existing visual-diagnostics
tutorial explain this boundary. No estimator or renderer changed; no exported
function was added and no existing entry was deprecated.

Validation:

- `test-output-guide.R` and new `test-plot-guide.R` pass without failures,
  warnings or skips. The printed core, native GPCM, generic precision,
  shared-rater scoring and multivariate D-study calls were executed; named
  data components and ggplot building were checked. All 11 unavailable rows
  refuse conversion even when given a generically convertible component.
- The first run exposed an incorrect guide component for `fit_pathway`;
  it now names the actual `table` component. The targeted rerun passed.
- All 27 pre-existing scopes return data identical to the base commit's
  implementation, not merely the same column names.
- Updated Rd files pass `tools::checkRd()`; the output-guide help examples
  execute. The source-truth/lifecycle check passes for 0.2.4.9000.
- The initial source-only roxygen loader could not resolve package-local
  links; regenerating with the loaded package namespace restored the links
  and left changes in only the two intended Rd files.

Full package checks, new simulations, hosted publication and Win-builder
resubmission were not needed for this local guide change. The remaining
interface milestones (complete conversion equivalence review, purpose gallery,
argument migration, feedback sheets and style options) remain open. GPCM
structural, profile-interval and portable-calibration work is not implemented
by this change.


## 2026-09-26 — Add a selected purpose-based figure gallery

The local 0.2.4.9000 visual-diagnostics tutorial now provides six previews
linked to executed examples: Wright map, fit pathway, category probabilities,
subset coverage, external-feature dendrogram and composite D-study planning.
Existing Wright/fit/coverage figures are reused. The added examples reuse the
current fit, use eight explicitly fictional feature rows, and use the packaged
MGENOVA Person-by-Task scores, respectively. They add no estimator or renderer.
Each example shows numerical data extraction and states its interpretation
limits. D-study G/Phi meanings and fixed-component projection uncertainty are
kept distinct from MFRM ability inference.

Gallery purpose labels and conversion status are read from the existing output
guide, not copied into a second capability table. One subset-coverage route
extends the selected map to 29 rows (14 dedicated, two native, two generic and
11 unavailable). Its explicit matrix conversion omits the observation-share
panel. Both the guide and tutorial distinguish relative observed facet-level
counts from planned-assignment completion and from missingness mechanisms.

Validation under `validation-results/plot-gallery-20260926/`:

- `test-plot-guide.R` passes, including execution of the added subset-coverage
  route and agreement between its matrix values and the generic ggplot data.
- The modified article alone was built with examples enabled. The final build
  completes without warnings or missing-alt messages. Initial empty thumbnail
  alternatives were replaced with named previews. The raw-coercion warning was
  traced to resource discovery URL-decoding a literal `%s` Markdown placeholder
  in the source chunk; constructing the image markup without a fake URL fixes
  it. An initial sass-cache write warning was avoided with a temporary R cache.
- Rendered HTML checks confirm all six purpose labels/support descriptions
  match the guide and all six extraction examples contain executed output.
- Local headless Chrome checks pass for all six loaded images and fragment
  destinations, nonempty thumbnail/full-figure alternatives, sequential Tab
  navigation, visible focus, Enter activation and opening/closing the route
  table. The unrelated pkgdown header logo is outside these figure checks;
  this is not a whole-site accessibility certification.
- Gallery cards have no horizontal overflow at 1280, 390 and 320 CSS pixels.
  Desktop/mobile captures and the new full figures were visually inspected.
  The local preview contains this article, not a rebuilt full reference site.

The first six-purpose gallery is complete locally. Whole-package checks,
repeated coverage simulations and public deployment were not performed.
Broader converter equivalence, argument migration, individual rater sheets,
style options and GPCM inference/structure extensions remain separate open work.


## 2026-09-26 — Add standalone individual rater feedback

This local 0.2.4.9000 interface milestone uses `mfrm_report(style = "rater")`
on the current development branch. It does not change rc.6, estimation,
interval formulas or their statistical qualification.

The implementation selects a native additive RSM/PCM facet level explicitly
and returns a whitelist projection: severity oriented toward lower scores,
reference zero, exposure, saved individual fixed-facet intervals, ordinary
Infit/Outfit, category use and selected standardized-residual cases. It accepts
matching saved diagnostics; it never fits, diagnoses or calculates covariance.
The individual interval is selected by its contrast vector rather than its
label, and multiple matching attachments require an explicit choice. Arbitrary
contrast intervals cannot be relabeled as an individual-rater interval.
Model-coded expected scores stay on their fitted scale. Missing or unavailable
sections remain explicit. GPCM, interactions, imported, testlet and random-rater
models are refused by this sheet route, retaining their specific reports.

HTML, Markdown, tables and the returned object omit the source fit, Person and
rater identifiers, task labels, source row numbers and arbitrary source notes
or attributes. The default recipient label is generic; a user-supplied label
is intentional displayed content. Cases use sheet-local numbering. Numeric
patterns can still permit recognition, especially in small groups: this is an
identifier-field exclusion contract, not universal anonymization. Complete
source notes and numerical cautions must be reviewed by the analyst before
sharing; they are not copied into the recipient's document.

Validation under `validation-results/rater-feedback-20260926/`:

- `test-rater-feedback.R`: saved numerical equality, no fitting/diagnostic/CI
  calls during projection, all output formats, source-field/attribute omission,
  escaped HTML labels, ambiguous/wrong-target/mismatched intervals, missing and
  unavailable inputs, recoding, effect direction, provisional source state,
  RSM/PCM and MML/JML scope, and existing QC positional calls.
- `test-output-guide.R`: the added individual-sheet route and existing guide
  contracts pass; the table schema and pre-existing routes are retained.
- The new `individual-sheet` tutorial chunk executes using the saved fitted
  input; report Rd syntax and generated namespace are checked.
- Headless local Chrome checks both audiences at 1280, 390 and 320 pixels,
  table header semantics, keyboard focus, resource independence and print CSS.
  Desktop, narrow-screen and print-CSS screenshots are inspected. The print
  check verifies CSS layout, not browser-independent PDF pagination.

A test exposed partial matching of a removed `diagnostics` field to
`diagnostics_provenance`; exact list extraction now prevents that error.
The initial browser harness missed a load event already delivered; its wait
was corrected before the successful checks. Those failures were not ignored.
No whole-package test, simulation campaign, CI, push or publication was run for
this reporting change. PDF automation, broader model coverage and review by
intended recipients are still open. The source and help make no claim of
validated rater-quality classification or general interval coverage.

## 2026-09-26 — Compatible plot titles and bubble conversion repair

This local 0.2.4.9000 interface tranche addresses the roadmap's argument
consistency and renderer-equivalence work. All eight exported `plot_*` helpers
with `main` now accept `title`: marginal fit/pairwise, unexpected responses,
interrater agreement, facet chi-square, bubble, bias interaction and facet
quality dashboard. Existing formal argument positions and `main` behavior
remain; `main = NULL` still selects a default heading. Explicit `title = NULL`
or `""` suppresses it. Supplying both names fails before data processing, even
when equal. The new argument is appended, and is exact-name-only after `...`
in the dashboard helper. One shared resolver and inherited parameter help
maintain the same contract. No deprecation warning or export is added.

The title-free dashboard retains its stored interpretation status, source
readiness and notes. Only the heading (including its REVIEW ONLY prefix) is
hidden; users must keep those limitations in the figure caption or report.
The S3 dashboard route forwards `title`. Payloads retain an empty title across
save/load and the supported bubble ggplot conversion renders no title.

Visual inspection exposed a pre-existing bubble-converter defect: it used
constant-size points and ggplot's default colours regardless of saved radii
and facet colours. The native monochrome preset also still selected a coloured
facet palette. The converter now uses saved radius ratios, facet colours,
facet order and reference lines, while the native monochrome branch uses the
existing gray-series helper. Explicit palette overrides remain. Base and ggplot
physical sizes differ; this is not a claim of pixel-equivalent rendering.
The bubble help now correctly describes N-based radii as proportional to
sqrt(N), with circle area proportional to N. No estimate, SE, interval,
screening threshold or radius formula changed.

Evidence in `validation-results/plot-title-alias-20260926/`:

- `baseline.rds` captures 21 view-specific payloads before editing the eight
  helpers. `compare-baseline.R` verifies exact equality for omitted titles,
  custom legacy main, explicit main=NULL, new custom title, and complete
  legacy positional calls. Formal defaults and positions are compared too.
- `test-plot-title-alias.R` passes: all 21 views, conflicts/invalid arguments,
  base graphics title capture, dashboard S3 forwarding and retained review
  evidence, supported ggplot titles/save-load, and unequal N/SE radius/colour/
  order/reference-line checks for both bubble views and all three size modes.
- `test-as-ggplot.R` passes after the converter change. No full package test
  or repeated estimator simulation was run.
- The `title-controls` vignette chunk executes from saved diagnostics. The
  eight Rd files parse and share generated title-argument descriptions.
  Custom-title and title-free ggplot images are rendered and inspected.

The first baseline harness used a diagnostics object where the unexpected
plot requires a fit or its dedicated result; it was corrected before the
baseline was frozen. Test-only failures also identified a legacy-only
fixture, ggplot's deliberate empty-title-to-NULL normalization, and empty
reference lists represented by NULL rather than numeric(0); the checks now
use the correct inputs and representations. The final comparisons pass.

Broader argument naming, global appearance settings, other converter gaps,
extended-model individual sheets and GPCM structure/inference remain separate
open roadmap work. The checked rc.6 source, CI, GitHub publication and CRAN
submission are unchanged by this local tranche.

### 2026-09-26 — Session defaults for common plot presets

The appearance item in the interface roadmap now has a local implementation:
`options(mfrmr.plot_preset = "publication")`. One internal resolver reads and
validates the option at 42 direct public plotting entries and eight report
bundle branches. Explicit arguments take precedence, including the legacy
`preset = NULL` package-default behavior. Formal defaults and argument positions
are unchanged. Paired comparisons now forward the parent preset to both source
plots. The fixed defaults in saved-data renderers are deliberately unchanged.

This is a plotting convenience, not new statistical inference or a universal
theme. Existing payloads retain their resolved appearance for supported ggplot
conversion after a session change; newly created plots use the current option.
Plots with separate palette controls retain their own settings. The option
does not mutate the global ggplot theme. A public theme and complete renderer
coverage remain open work, as do GPCM structural and inference extensions.

Evidence in `validation-results/plot-preset-option-20260926/`:

- `baseline.rds` was saved before this implementation. Final `verify.R` and
  `verify.log` confirm 27 default payloads remain exactly identical, and the
  same 27 session-default outputs match explicit monochrome calls.
- `test-plot-preset-option.R` passes. It checks missing/explicit option handling
  at all 42 direct entries; four presets on eight representative routes;
  explicit overrides and NULL; paired-source forwarding; saved bubble
  save/load/ggplot data; legacy payload fallback; results/plot-data forwarding;
  unchanged numerical tables, radii, reference lines and global theme. Its
  mocked estimators reject unintended new fitting/diagnostic calls.
- `session-preset` in the existing tutorial executes with a saved fit and
  restores the prior option. Roxygen completes without warnings; all 43
  affected help topics parse with one inherited session-default section each.
- README, NEWS and ROADMAP describe precedence, replay behavior and limits.

Initial test-harness errors used an unqualified `local_options()` and an
unsupported `info` argument to `expect_s3_class()`. The harness now uses
`withr::local_options()` and an inheritance assertion; the final tests pass.
No full suite, repeated estimator simulation, CI or external submission was
performed for this appearance-only tranche. The frozen rc.6 candidate is
unchanged.

### 2026-09-26 — Dedicated external-feature PCA ggplot conversion

The next converter tranche addresses the three PCA routes in the purpose
guide: scree, scores and loadings. A single private renderer reads saved PCA
payloads. Default and explicit `component = "table"` conversion preserve the
complete view; other components cannot re-enter a generic numeric-column
fallback. The normal `as_ggplot(pca, type = ...)` route uses the existing
plot-data adapter without adding exports or refitting PCA/clustering.

Scree plots retain explained-variance percentages for all fitted components
and distinguish retained/open symbols. Scores retain the selected axes,
ID-aligned saved group colours/shapes and label choice. Loadings retain feature
order, the selected component, the coefficient scale and the zero reference.
Converted objects carry the full source payload, including transformations,
weights, excluded IDs and units, for extraction with `plot_data()`. The preset
comes from that saved payload, not a changed session option. Titles/subtitles
can be removed using ggplot labs without removing the attached source evidence.

Evidence in `validation-results/pca-ggplot-20260926/`:

- `baseline.rds` precedes the converter change. Final `verify.R` confirms the
  four pre-change payloads (scree, grouped reversed-axis scores, ungrouped
  scores and second-component loadings) remain identical.
- `test-pca-ggplot.R`, `test-plot-guide.R` and
  `test-workflow-output-routing.R` pass. The new checks compare built graphic
  coordinates, percentages, shapes/colours, label settings, feature order,
  fixed axis units, explicit/default component routing, saved-data replay and
  metadata extraction. Reordered memberships expose positional-ID errors;
  missing axes/encoding cause errors instead of generic graphics. Mocked PCA
  and k-means calls reject unintended refitting. A single-feature scree plot
  builds without a line-group warning.
- Image inspection exposed a very narrow score panel when selected components
  have strongly unequal variance, clipping labels. The final renderer uses
  equal displayed spans as well as equal axis units; points are unchanged.
  Updated PCA tests pass (`tests-final-pca.log`). The final grouped score,
  scree, loadings and title-free tutorial images were inspected.
- The exact `numeric-pca-ggplot` tutorial chunk executes using a saved result
  of the same shape as a single feature completion. This is an example/display
  check, not a rerun or validation of multiple imputation. Roxygen completes
  without warnings and changed help topics parse.
- The guide now has 17 dedicated, two native, two generic and eight unavailable
  selected routes. README, feature tutorial, installed help, NEWS and ROADMAP
  distinguish the new PCA support from still unsupported partition/tree/MI
  graphics.

The first test run tried to retrieve labels from an untrained positional scale;
its assertion now uses the built panel scale. No estimator, PCA geometry,
clustering algorithm, uncertainty formula or public function signature changed.
Physical sizes are not asserted equal across base and ggplot. Dense labels may
still require `labels = FALSE`; text alternatives and colour/shape redundancy
are not a complete accessibility certification. The checked rc.6 candidate,
main, published site and CRAN submission are unchanged. No full suite or new
large simulation was run for this local display change.

### 2026-09-26 — Saved hierarchical dendrogram conversion

The hierarchy route now has a dedicated `as_ggplot()` conversion. A private
linear traversal of the saved hclust merges generates branches at recorded
heights and midpoint positions. It does not compute distances, fit a new tree
or call cutree. Leaf order, stored memberships, requested k, excluded IDs and
label/preset choices remain attached through `plot_data()`.

The default and `component = "tree"` convert the same complete view. Other
components cannot fall back to a misleading generic table plot. Group boxes
follow the saved contiguous membership runs, including cuts at tied heights.
They use dashed lines to distinguish boxes from branches in monochrome. The
cut caution appears only when the two heights bounding the selected k cut
are equal, not simply because another pair of heights somewhere in the tree
ties. Label omission never samples or removes leaves. Display widths and text
sizes need not match the base renderer pixel for pixel.

Evidence in `validation-results/dendrogram-ggplot-20260926/`:

- `test-dendrogram-ggplot.R`, `test-plot-guide.R`, `test-cluster-plots.R` and
  `test-workflow-output-routing.R` pass. Independent stats::as.dendrogram
  node midpoints/member counts and heights agree with the converted branches
  for average/complete linkages, with and without tied cuts. Tests also cover
  zero-height trees, saved-data replay, exclusions, omitted labels, explicit
  tree selection, malformed indices/order/groups, and rejection of generic
  component fallbacks. Mocked clustering, hclust and cutree reject recomputation.
- The final dendrogram-specific tests pass after the dashed-box and
  cut-specific caution changes (`tests-final.log`). A separate tied-height
  condition away from the selected cut verifies that no cut caution is added.
- `verify.R` executes the exact `hierarchy-ggplot` tutorial chunk and inspects
  the attached source payload. Eight-rater, tied four-rater, and 120-rater
  figures render. The 120-rater check counts all 357 branch segments with
  ID labels hidden; this is a display check, not a maximum-capacity guarantee.
  Final figures were visually inspected for branch/box distinction, labels
  and captions. The caption-only change does not alter heights or memberships.
- Roxygen finishes without warnings; updated help topics parse. The guide,
  README, both relevant tutorials, NEWS and ROADMAP describe dedicated tree
  conversion. The 29 selected guide entries now have 18 dedicated, two native,
  two generic and seven unavailable conversions.

This completes the saved-tree conversion gap, not silhouette/profile or
imputation co-membership conversion, pooled trees or branch-support inference.
No public function, clustering estimator or partition-selection rule was added.
No full suite or large estimator simulation was repeated. The frozen rc.6
candidate, main, website and CRAN submission remain unchanged.

### 2026-09-26 — Imputation co-membership ggplot conversion

The dedicated co-membership renderer uses the saved matrix, ID order, legend,
label choice and imputation count. The default and explicit `component =
"matrix"` preserve the full fixed zero-to-one view; other components cannot
fall back to generic graphics. Source metadata remain attached and extractable,
including selected IDs and all excluded IDs. No imputation, clustering,
renormalization, reordering or consensus partition is computed.

Grey cells receive crosses, distinguishing unavailable pairs from zero without
relying on colour. The caption explains the all-imputation denominator and
separates these fractions from membership probabilities and sampling stability.
Saved plots ignore later session preset changes. Labels, titles and captions
can be hidden through the documented creation/ggplot routes without removing
source records. The native plot and numerical result construction are unchanged.

Evidence in `validation-results/co-membership-ggplot-20260926/`:

- `test-co-membership-ggplot.R`, `test-plot-guide.R`, `test-cluster-plots.R`
  and `test-workflow-output-routing.R` pass. The dedicated final tests also
  pass after tightening invalid-input checks (`tests-final.log`).
- Explicit partitions provide known fractions. Checks resolve plotted x/y
  coordinates back to requested IDs, compare values without renormalization,
  retain the fixed scale and imputation count, distinguish zero/NA fills and
  NA crosses, and exercise singleton/all-unavailable views. A 51-ID view keeps
  all 2,601 cells when default labels are hidden; this is not a capacity bound.
- Save/load checks preserve graphics and metadata under an invalid later
  session option, without changing the global theme or opening a device.
  Mocked imputation/clustering functions reject unintended analysis calls.
  Invalid matrices, missing IDs/count/legend and unsupported component
  selection cause errors rather than misleading fallback graphics.
- `verify.R` executes the exact new tutorial chunk using a five-ID saved-result
  fixture. Colour, monochrome, all-unavailable and one-person images render and
  were inspected. This verifies display and example execution, not a rerun or
  validation of the feature-imputation model. Updated help parses and roxygen
  completes without warnings.
- Help, README, NEWS, feature tutorial, output guide and ROADMAP are reconciled.
  The 29 selected guide routes now have 19 dedicated, two native, two generic
  and six unavailable conversions. Silhouette/profile conversions and broader
  inference/structural roadmap work remain separate.

No public function or statistical procedure was added. The renderer materializes
one row per displayed pair, so memory still grows quadratically; the raster
layer is not a general large-data guarantee. No full suite or large simulation
was repeated. The checked rc.6 candidate, main, website and CRAN submission
remain unchanged.

### 2026-09-26 — Silhouette and feature-profile conversion

Dedicated conversion now covers the remaining selected partition views:
silhouettes and numeric/categorical profiles. One private renderer reads saved
summaries; default and explicit table conversion retain the complete selected
view, with matrix selection additionally supported for categorical profiles.
No clustering, silhouette calculation or interval estimation is performed.

Silhouettes retain negative widths, row order and the saved overall-mean
reference on a fixed [-1, 1] scale. Group labels provide non-colour identification;
omitting entity labels does not remove widths. Numeric profiles retain means,
medians and counts in original units. Circle/triangle symbols use small vertical
offsets so coincident values remain visible; x values do not change. Categorical
profiles retain unused levels, original order, group counts and a fixed [0, 1]
scale. Cell boundaries make zero proportions visible. All source summaries,
exclusions and interpretation metadata remain extractable after labels change.

Evidence in `validation-results/cluster-summary-ggplot-20260926/`:

- The new `test-cluster-summary-ggplot.R` and related plot-guide, cluster-plot
  and workflow-routing test files pass. Final focused tests also pass after
  layout refinement and the missing-reference guard (`tests-final.log`).
- Built graphics are checked against saved negative widths, row order,
  reference values, original-unit summaries/counts, category order and unused
  zero cells. Tests cover explicit/default components, save/load, ignored
  later session options, source extraction, missing inputs and labels hidden
  without sampling. Mocked clustering calls reject unintended analysis.
- PAM, k-means and hierarchy profile routes build. A k-means result fitted
  with silhouette=FALSE still refuses a silhouette view without computing it;
  its existing profile remains available.
- The exact `profile-ggplot` tutorial chunk executes using a saved-result-shaped
  fixture. Colour and monochrome profile/silhouette figures render; final
  numeric, categorical and negative-width layouts were inspected. The QA-only
  negative-width fixture uses a matching updated saved mean; it is not an
  empirical algorithm result. Display assertions intentionally use a distinct
  saved mean to prove conversion does not replace it by recomputation.
- Updated help parses; roxygen completes without warnings. Help, README,
  NEWS, feature tutorial and ROADMAP match the implementation.

The selected guide's clustering/PCA routes now have dedicated converters.
Across all 29 selected entries it reports 21 dedicated, two native, two generic
and four unavailable conversions. This is not a full package plot inventory.
Pooled-facet, screening-performance and the remaining G/D-study conversion
families stay explicit gaps; model/inference work remains separate. No new
public function, numerical estimator or statistical guarantee was added.
No full suite or large simulation was repeated. This remains local development;
the checked rc.6 candidate, main, website and CRAN submission are unchanged.

### 2026-09-26 — Pooled fixed-facet MI interval conversion

The selected pooled-interval route now has dedicated ggplot conversion. It
reads the saved MI t-interval endpoints rather than recreating normal intervals
from SEs. Target order, contrasts, DF, confidence-level settings, complete-data
information reviews and cautions remain attached through `plot_data()`. The
default and explicit table component retain the same full view; other
components cannot fall back to generic graphics.

Fixed targets use open diamonds without intervals. Missing interval endpoints
use crosses at the saved estimate; missing point estimates cause an error
rather than being placed at zero. Infinite interval endpoints use arrows whose
tips are rendering limits, not substituted finite bounds. Original endpoint
values and per-row cautions remain in the source table. These are converter
behaviors; the native plot and pooling formulas have not changed. No extra
multiplicity adjustment or classification of rater quality is implied.

Evidence in `validation-results/pooled-ggplot-20260926/`:

- `test-pooled-ggplot.R`, `test-plot-guide.R` and
  `test-workflow-output-routing.R` pass. Tests distinguish a saved small-df t
  interval from its normal approximation, preserve fixed targets and target
  order, verify arrows for infinite endpoints and crosses for missing
  intervals, and cover all-fixed/all-unavailable views. Save/load and display
  controls preserve metadata under a changed session option. Mocked fitting,
  pooling, covariance and qt calls reject unintended recalculation.
- An initial label assertion assumed ascending breaks; it now matches labels
  to their actual y coordinates. The display itself retained the correct order.
- `verify.R` runs the exact new tutorial chunk using the existing
  `response-mi-joint-20260923/pooled.rds` result from 40 imputations. Its table,
  contrasts, settings and DF remain identical. No model or imputation rerun
  is needed. This is replay verification, not additional coverage evidence.
- Colour and monochrome state fixtures render, including fixed, unbounded,
  unavailable and weak-information cases. The tutorial and state figures were
  visually inspected. These constructed states exercise display semantics;
  they are not new empirical results or a claim that such endpoints occurred
  in the saved 40-imputation example.
- Roxygen completes without warnings and changed help topics parse. README,
  NEWS, response-imputation tutorial, installed help, output guide and ROADMAP
  are reconciled. The README migration table's stale blanket refusal of
  external-feature ggplot conversion is also corrected.

The old refusal assertion in test-response-imputation.R now expects the
supported ggplot class; its fitting-heavy full file was not rerun. The direct
saved-result replay and focused tests cover the changed rendering behavior.
No full package suite or estimator simulation was repeated. The selected guide
now reports 22 dedicated, two native, two generic and three unavailable routes;
screening-performance and remaining G/D-study conversions are still gaps.
The frozen rc.6 candidate, main, website and CRAN submission are unchanged.

## 2026-09-26: representative saved-workflow integration

This review connects the accumulated display and reporting work before moving
to the next statistical target. It does not add estimators or claim complete
plot coverage. Evidence: `validation-results/workflow-integration-20260926/`.

- `verify.R` reuses the existing RSM fit/diagnostics/individual-rater intervals,
  PCA/k-means fixture and real 40-imputation response-score result. The analyst
  RDS round trip preserves the complete results. Individual-sheet tables and
  cautions, plain/researcher numerical agreement and fixed-facet plot data
  remain unchanged. The exported replay script executes from its export folder
  and reloads the same results. Copied recipient HTML remains readable after
  removing the temporary source; source Person/rater IDs are absent.
- Saved PCA, original-unit profiles and pooled t-interval views convert after
  changing the session preset without changing their saved payloads. Fitting,
  diagnosis, interval calculation, PCA, k-means and pooling entry points are
  mocked to reject unintended recalculation during replay.
- `tutorials.R` executes both new save/reopen tutorial chunks. A small
  25-row, three-imputation fixture additionally checks all-completion PCA/group
  preservation, co-membership conversion and zero changed-pair fraction after
  reloading. Its renamed example attributes are an API fixture, not an
  educational dataset or evidence for imputation adequacy. During replay,
  mice/PCA/clustering entry points are blocked. No statistical simulation or
  large fitting suite is repeated.
- The imputation-model object's `identical()` check initially fails only for
  formula environments: separate deserializations create separate R environment
  references. `all.equal()` passes; all analyses, co-membership, summaries,
  original features, imputed-cell records and settings are identical.
  `serialization.log` isolates the formula component. There is no evidence of
  changed estimates or classifications from this check.
- `export-check.R` compares interval, contrast and setting CSVs with source
  tables and report CSVs, including missing-value positions. CSV type inference
  reads an all-missing numeric setting as logical NA; numeric comparison
  therefore restores the source numeric type. RDS preserves the original type.
  The initial harness also used an incorrect pooling mock name and plural
  `profiles` plot type; these were corrected to the existing API names.

The feedback help/tutorial now demonstrate copying the temporary HTML and
reopening the analyst RDS. The feature tutorial saves the full imputed analysis
alongside a selected first-completion view, explicitly distinguishing their
scope and the separate pooled-response workflow. NEWS and ROADMAP reflect
these changes. Roxygen regenerates the report help; generated trailing whitespace
in the existing facet-interval topic is normalized. No rendering or estimation
implementation change was required by this review. Intended-reader evaluation,
unavailable specialized converters and statistical qualification remain open.

## 2026-09-26: rater-uncertainty evidence reconciliation and refit checks

The next work package remains prediction intervals for observed random-rater
effects relative to the population mean, not fixed-panel coefficients, future
scores, training effects or rater-quality classifications. This turn reconciles
existing evidence and repairs missing refit records; it does not improve or
qualify coverage. Evidence is under
`validation-results/rater-uncertainty-review-20260926/`.

`reuse.R` verifies the existing 800-dataset numerical ledger: 53 Person-
quadrature failures (2/24/1/26 by original condition) and one further estimated
rater-variance boundary, with all optimizer and information checks passing.
The original finite-interval denominators are 198/176/198/174 out of 200.
`source-check.R` compares parsed function definitions: the likelihood and
both variance-boundary calculations match the frozen study source. Inspection
of the fitter difference identifies an existing named `PersonQuadratureStable`
flag and `isTRUE()` guards around the same numerical tolerances. The old and
new quadrature decisions agree for all 800 saved finite discrepancies; this
does not claim identical handling of hypothetical nonfinite discrepancies.
Its qualification decisions remain unchanged. The completed eight-
calibration, 144-comparison local-likelihood reference is reusable evidence;
its scoped conclusion does not justify restarting it or claiming global
Laplace accuracy.

All 24 bootstrap pilot results and 2,376 saved trials replay with identical
stored 95% studentized endpoints and no refitting. Their source ability SD is
known and fixed at one. They do not qualify the estimated-population default.
The methodological reference was checked at the authors' arXiv abstract
(https://arxiv.org/abs/0806.2931): its stated scope is linear mixed models.
This is not a new full-paper review or a theorem for the ordinal RSM.

New trial records retain optimizer code, numerical/information readiness,
quadrature/check orders, likelihood/gradient discrepancies, the separate
rater-variance boundary and Person search-bound status. Existing root
calculations, gates, seeds, warnings and error records are unchanged. If no
fit returns, these additional checks are NA, not passes. Old trial records
are not retroactively relabeled or populated from source-fit checks.

The affected interval tests pass, covering numerical versus information
failure, thrown refit errors, variance boundaries, unresolved roots,
studentization direction, actual small refits and saved replay. An initial
test cleanup used `on.exit()` without `add = TRUE`, overwriting mock cleanup;
using `withr::defer()` fixes the test isolation. No production inference failure
was inferred from that harness defect. A stored example verifies that additional
NA historical-check fields survive results, reports, RDS and CSV; these are
explicitly a transport fixture, not invented bootstrap measurements. Its
interval plot remains unchanged.

Help, the random-rater tutorial and NEWS explain these checks. ROADMAP now
separates completed numerical evidence, limited known-population bootstrap
evidence and unqualified current-population inference. It requires numerical
policy, outer and inner precision, and a computing budget before another
qualification study. If adequate precision is impractical, candidate status
remains explicit and does not indefinitely postpone the scoped GPCM ownership
work. No new coverage study, full test suite, publication or release change
was undertaken.

## 2026-09-26: interval computation decision and separated-owner GPCM preflight

The nested random-rater qualification run is not started in this tranche.
`validation-results/rater-uncertainty-budget-20260926/assess.R` calculates
planning sensitivities from saved results, without new fits. Independent
datasets, not individual raters within a dataset, are the Monte Carlo units.
Using the existing normal-interval dataset SDs as planning proxies, MCSE .01
and observed availability imply 908 planned outer datasets across four cells.
At B = 499 this is 454,000 fits including source fits, about 874 summed hours
using historical median elapsed-fit proxies (842--901 using lower/upper
quartiles). These are neither confidence bounds on runtime nor a prediction
of parallel wall time. Bootstrap-method variability and a revised quadrature
procedure can differ, so this is not a proven minimum sample size.

The existing availability gate supplies a separate best-case calculation.
For a two-sided exact 95% binomial interval with every case available, its
lower bound is .025^(1/N). At least N = 72 per condition is needed to reach
.95; `binom.test()` confirms failure at 71 and success at 72. Across four
conditions, 288 source datasets with 499 draws imply 144,000 fits, about 299
summed median-proxy hours. This is only the availability gate, not enough
evidence for interval coverage. No new ad hoc coverage criterion is adopted.

The inner planning calculation sqrt(p(1-p)/B), p = .025, concerns the empirical
CDF at a fixed population-tail threshold with independent, fully known draws.
B = 499 gives probability-scale MCSE .00699; illustrative .005 and .0025
targets imply B = 975 and 3,900. This is not endpoint MCSE in logits, which
also depends on the error density, and unresolved roots are a separate issue.
These sensitivity values do not prescribe a universal production B.

`test-random-rater-tail-resolution.R` verifies the existing type-1 completion
rule at B = 19, 99 and 499, including the transition from finite to infinite
limits. At 95% and B = 499, 13 unresolved roots for one rater make both limits
infinite; increasing B at a persistent 3% unresolved fraction remains
unbounded. This is a constructed arithmetic check, not coverage evidence.
The R type-1 definition was checked against the official stats manual:
https://stat.ethz.ch/R-manual/R-devel/library/stats/html/quantile.html .
Help, tutorial and NEWS explain the concrete consequence without treating
the count as an acceptable-failure threshold. Outer-study failure rates are
not assumed to equal conditional inner-bootstrap failure probabilities.

Work now advances to the already scoped GPCM ownership extension. The preflight
under `validation-results/gpcm-separated-owners-20260926/` uses six Persons,
three raters and two criteria, both ownership directions, complete/incomplete
crossed rosters, known standard-normal ability and fixed/adaptive 61-node MML
integration. The parameter maps and observation indices are existing internal
code; no public guard was removed. A separate scalar adjacent-category
recursion integrated by R's `integrate()` checks the marginal likelihood.
Maximum likelihood discrepancy is 2.99e-11; analytical versus finite-difference
gradient discrepancy is 6.74e-10. Unit slopes reproduce PCM values exactly in
these cases and nuisance gradients within 1.56e-15. The numerical regression
is retained in `test-gpcm-separated-owner-kernels.R`; it passes. The internal
kernel comment now distinguishes the slope and step indices explicitly.

This admits further implementation work, not a public separate-owner model.
Identification, actual fitted solutions, population-estimation routes,
inference eligibility, prediction, saved reporting and affected specialized
helpers remain to be connected or explicitly restricted. First admission is
additive MML with one slope family; JML's existence/boundary machinery requires
separate work. The frozen candidate and public model restriction are unchanged.
Both focused test files pass, roxygen succeeds and diff whitespace checks pass.
No full package suite, coverage simulation, hosted CI or publication was run.


## 2026-09-26: Separate GPCM owners connected through the local MML workflow

This supersedes the preceding preflight's public-guard status for the local
0.2.4.9000 development tree only. MML now permits distinct slope/step facets;
JML keeps the equality restriction. There is one positive, geometric-mean-one
slope family multiplying the entire adjacent-category predictor. No estimator,
likelihood, slope-action or population-default change was made.

Output qualification now checks each role against the retained specification
and the actual slope-level order instead of requiring role equality. PCM/GPCM
nesting retains matching step owner, population, facet/step constraints and
numerical checks; its degrees of freedom are slope levels minus one. Bootstrap
replay checks both owners. General simulation/design and fit-derived simulation
specifications explicitly refuse distinct owners, as does the existing weighting
review; same-design `bootstrap_mfrm_gpcm()` is separately supported.

The independent scalar-generated 120-person, 3-rater, 2-criterion fit yielded
relative slopes 0.8624 and 1.1595 with eligible approximate log-Wald intervals.
Interchanging facet names left the parameter vector unchanged within 1e-9.
A rotating assignment retaining two raters per person yielded slopes 0.8425 and
1.1869 with eligible approximate intervals. A confounded design with only R1/C1
and R2/C2 was refused before optimization (rank 4/5). An additional fit using
three rater slopes and two criterion step sets also completed with eligible
approximate intervals (`opposite.rds`, `final-smoke.log`). This changes the fitted
model rather than recovering the generating truth. This single-case evidence
checks numerical behavior, not bias, coverage or general sparse-design adequacy.
The matched free-population PCM/GPCM comparison gave LR 2.353 (rounded), df 1,
p 0.1251; three same-design bootstrap refits completed, and new-person fitted-object
scoring completed. No sampling-performance conclusion is drawn from three draws.

A real export uncovered a shared-owner assumption in CCC/pathway construction:
the step label was used to look up the slope. Joint step/slope profiles now
produce explicit paired labels and correct reference probabilities. Such profiles
do not borrow a single-facet fit flag; individual fit measures remain available
separately. Independent scalar expected-score checks cover all six pairs.
The corrected export has zero plot errors and preserves exact saved uncertainty
and both owners after RDS reopening. The initial failing export is retained as
provenance, alongside the corrected export. Native CCC panels were visually
inspected; their footer states that additive effects and interactions are zero.

Validation: focused separated-owner workflow and kernel checks, equal-owner
inference extensions and reporting, slope-owner comparison, model choice,
output guide, fit pathway and Wright regressions passed. LRT and uncertainty
readiness regressions also passed. Three expensive capability-matrix tests kept
their existing `skip_on_cran()` skips under the default local test environment;
they were not silently counted as executed. No whole-package suite, coverage
simulation, hosted CI, commit/push, release-tag change or CRAN submission occurred.
Help source, generated Rd, NEWS, README, scope vignette and roadmap are updated.
Sources: `validation-results/gpcm-separated-owners-20260926/fit/{probe.rds,
workflow.R,workflow.log,tests.log,regression.log,reexport.R,reexport.log}`.

## 2026-09-26: Repair development-branch CI metadata review

GitHub run 36230655189 for 7699a05e stopped at source-metadata review before
package building or tests; the other four environments were skipped. Local
reproduction identified internal path/terminology in the public roadmap.
Reader-facing prose and a linked evidence reference now pass the unchanged
source-truth check. NEWS explicitly identifies the development version.

The affected repository review initially exposed nine failures: outdated
roadmap/README wording assertions, a historical raw pass-count claim, and a
stress-runner PCA availability error. Scope checks now follow the current
one-slope-family wording without restoring the obsolete blanket "bounded"
label. The stress runner accepts only a named finite eigenvalue, not merely
a returned object or another numeric column; unavailable PCA remains explicit.
The iteration-limited JML corner has no finite PCA result and is no longer
recorded as available. Neither fitting nor statistical eligibility was changed.
The complete release-readiness protocol file now passes locally (no failures,
warnings or skips); the direct CI metadata check and diff whitespace check pass.
Logs are retained in `validation-results/development-ci-repair-20260926/`.
These results repair the stopped check; they do not constitute a five-platform
package-check result or completion of D1 statistical evaluation.


## 2026-09-26: Complete the separate-owner GPCM diagnostic pilot

The fixed protocol ran 20 datasets in each of four cells: N=120/400 and
complete/connected rotating assignment. All 80 fits and targeted slope/curve
intervals returned under existing checks; all optimizer codes were zero and
joint-information statuses were ok. Total fit/inference time was 147.304 seconds.
All failed/unavailable and planned-but-unrun accounting is retained in the
runner/summary even though no such cases occurred in this pilot. A separate
summary check exercises unavailable and unexecuted cases.

Slope coverage was 18/20 for both 120-person cells and 20/20 for both 400-person
cells. Probability-target coverage ranges were 16–20/20, 16–20/20, 18–20/20 and
17–20/20 respectively (120 complete, 120 incomplete, 400 complete, 400 incomplete).
Dependent targets are not counted as independent replications; the minimum
across 54 probability targets is not a multiplicity-adjusted finding. No nominal
coverage guarantee or estimator improvement is claimed. The pilot does not
justify repeating itself or automatic bootstrap/confirmation expansion.

The protocol, runner, summary and result/cost record are retained as
`inst/validation/gpcm-separated-owner-pilot*-20260926.*`; generated data and
fits are local under `validation-results/gpcm-separated-owner-pilot-20260926/`.
D1's diagnostic pilot is complete, while statistical qualification remains open.
No public API, statistical cutoff or default was changed by this study.

## 2026-09-26: Repair the S3 registry expectation after the CI package check

Run 36231290875 reached the macOS source-tarball package check and failed one
test: the exact expected S3 registry omitted `print.mfrm_rater_feedback`.
The source registration was correct. The same failure reproduced locally;
adding the method to the expected registry repairs the contract without
weakening the equality assertion or changing package behavior. The namespace
contract and API S3 consistency files now pass, and `getS3method()` resolves
the feedback method. The other four CI environments were skipped in that run;
a replacement CI run is still required before claiming five-platform success.

## 2026-09-26: Align the fixed-rater reporting walkthrough with the primary API

The main reporting help previously led with the specialist manuscript stack.
It now begins with stored results, selected plots, reports and analyst archives,
while retaining the purpose of the specialist helpers. The existing fixed-facet
tutorial distinguishes `style`, `output`, `include`, and the two meanings of
`preset`; it explicitly selects the saved individual interval and executes an
archive/reopen example that checks identical saved interval objects. Recipient
HTML and analyst archives remain separate. No estimator, API name or default
was changed.

The complete tutorial rendered with `NOT_CRAN=true`, including RSM/PCM fits,
individual sheets, interval figures and the new archive/reopen example. The
existing rater-feedback tests passed, including real print dispatch, no-refit
checks, identifier omission, missing intervals and rejected model scopes.
Roxygen regenerated the reporting help without warnings. Outputs and logs are
under `validation-results/d2-feedback-workflow-20260926/`. Browser visual review
was unavailable because the UI tool reported no available browser; successful
HTML generation is not a layout inspection or a novice-comprehension study.
The CI for repair commit `0b11aed9` does not include these later documentation
changes. D2's broader argument inventory and reader feedback remain open.

## 2026-09-26: Repair silent plot-argument loss in the primary workflow

Two failures were reproduced: `plot(fit, level = .8)` ignored `level`, and
`as_ggplot(saved_plot, title = ..., level = ...)` ignored both settings.
The fitted-model method now accepts a named-only `level` alternative after
`...`, preserving every previous positional argument. Simultaneous `level`
and `ci_level` are rejected, even if equal; the default remains .95. The alias
is forwarded through ordinary result plots, plot-data extraction and ggplot.
Saved interval-result plotting still rejects a new level rather than changing
the inferential result. The saved core-payload converter rejects unsupported
arguments and a new plot type. Complete CCC views retain their three documented
conversion controls; existing dedicated converters keep their own validation.

New checks compare actual 80%/95% interval widths with their normal-quantile
ratio, compare the old/new spellings, reject invalid/conflicting requests, and
check saved conversion without changed data. The new argument tests and the
existing ggplot, preset, title, fixed-facet reporting and testlet integration
files pass. No full suite or sampling experiment was repeated. Help and NEWS
describe the distinction between a fit, a saved inferential result and a saved
plot; estimator calculations, statistical qualification and specialist helper
names are unchanged. Evidence is in
`validation-results/d2-plot-arguments-20260926/`.

The earlier repair commit `0b11aed9` passed the macOS CI prerequisite and
started the four remaining environments. That run does not cover these later
source/help changes, which require their own integrated check.
