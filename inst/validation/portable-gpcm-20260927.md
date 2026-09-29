# Portable GPCM implementation — 2026-09-27

## Question and disposition

Can an eligible estimated-normal MML GPCM calibration be saved and reused for
new people without losing its model, population assumptions or source-check
limitations? The local development implementation now extends the existing
extract/validate/freeze/save/load/score API. No new exported function is added.
This closes the scoped implementation/replay milestone, not release checks or
the separate profile-likelihood interval milestone.

The scope is one ability dimension, one positive geometric-mean-one relative
slope family, shared or separate slope/step owners, full adjacent-predictor
slope action, known categories/facet levels, unit weights, no anchors or
interactions, and an estimated intercept-only normal population. JML,
covariate-dependent populations and broader structures remain unsupported.

## Source and scoring are different checks

At extraction, the native conditional-scoring check freshly evaluates local
likelihood, gradient, positive unregularized information and higher-order
integration. A failed source cannot be admitted by a review override. The
artifact stores the passing decision and integration comparison together with
the original global audit states. On replay these are validated stored records;
no source refit or fresh evaluation of omitted training responses is claimed.
Semantic consistency is not authentication against a maliciously rewritten file.

| Synthetic source | Source orders | NLL change | Gradient change | Higher-order maximum gradient |
| --- | --- | ---: | ---: | ---: |
| Shared Rater owners | 61 / 121 | 7.946039e-8 | 1.360741e-6 | 3.215813e-5 |
| Criterion slope / Rater step | 31 / 61 | 9.993073e-11 | 1.958876e-9 | 6.538224e-6 |

Both sources retain unevaluated global identification/boundary audits and FALSE
global inference readiness. Passing local checks does not prove a finite global
maximum, justify calibration intervals or establish population transport.

Every GPCM batch compares reported EAP/SD with two adaptive reference orders
under its actual prior (absolute changes at most 1e-5). Failed integration
returns no scores. Endpoint and sparse-pattern labels remain independent of
numerical acceptance. The initial shared-owner scoring order 31 failed on the
new patterns; increasing scoring order to 121 passed without refitting the
calibration or changing tolerances. The separate-owner fixture passed at 31.
Thus even a passing source calibration does not make every later scoring grid
adequate. Continuous posterior intervals use the existing CDF inversion.

## Prior identity and output integration

File format 2 retains slopes, both owners, score/facet maps, constraints,
source evidence, estimated population mean/SD and numerical settings. File
format 1 RSM/PCM retains its original default semantics. Scoring algorithm
versions remain separate from artifact versions.

`scoring_prior = NULL` retains the saved prior. An explicit common
`list(mean, sd)` is an analyst assumption on the unchanged calibration scale;
it neither estimates the new cohort nor modifies the frozen object. Invalid
priors and old grid-endpoint interval artifacts reject this option. Current
RSM/PCM artifacts also support it, with numerical scoring checks. A coarse
RSM scoring grid failed after the prior changed; a re-extracted order-121
artifact passed and agreed with the native scorer without recalibrating.

Scores, summaries and figure data preserve original and actual priors without
rounding, numerical checks and GPCM extraction evidence. Missing/inconsistent
records are refused by summary/plot methods. CSV score columns retain the
prior values. Existing interval, precision and edge-mass plots and ggplot
conversion work with the qualified GPCM score result.

## Verification and limits

- The five dedicated GPCM test groups passed 127 expectations. They cover both
  owners, native EAP/SD/interval agreement (1e-8), independent scalar integrated
  EAP/SD (1e-6), central interval probability 0.95 (1e-7), alternate priors,
  save/load identity, a fresh R process, output metadata and adverse inputs.
- Existing RSM/PCM lifecycle tests passed. Existing public calibration API
  assertions passed; the added RSM prior test passed seven expectations after
  correcting its test grid and native-result comparison. The installed-package
  fresh-process test skips under source loading; the dedicated GPCM fresh-
  process source-loader test passed. Installed-package and platform checks are
  not claimed here.
- Help, capabilities, output guide, README, vignette, NEWS and roadmap now describe the same
  development scope. The output-guide checks passed three expectations. Only relevant help topics are regenerated; their Rd syntax and the extracted vignette code parse successfully. The vignette's
  existing-fit GPCM template is not executed as a fit example; the public
  extraction/replay paths it illustrates are exercised by the retained fixtures.
- No full suite, optimizer study, profile grid, P3 prior simulation or external
  software computation was repeated for this artifact change. Existing
  [TAM](gpcm-fixed-scoring-tam-20260926.md) and
  [ConQuest](gpcm-fixed-scoring-conquest-20260926.md) evidence supports the
  fixed-parameter scale mapping; it is not a fresh external test of these
  newly extracted artifacts or free-estimation equivalence.

Evidence and earlier failed attempts are retained under
`validation-results/portable-gpcm-20260927/`. The small synthetic regression
fixtures and their provenance are under `tests/testthat/fixtures/`.
No general frequentist coverage guarantee or new-cohort prior validity follows
from these conditional posterior checks. Release-candidate/platform validation
remains pending; the released 0.2.4 candidate is not changed by this local work.

## Combined workflow and external comparison

The next local review executes the public tutorial's extraction, scoring and
prior-sensitivity chunks with both retained qualified fits. The
[workflow runner](portable-gpcm-workflow-20260927.R) reads the actual chunks,
not a separately maintained approximation of their code. It reuses the fitted
sources; the newly added fitting template is explained and parsed, but was
not rerun as a calibration experiment. The vignette now identifies the input
columns, ownership choices, calibration/scoring sessions, missing-response
policy, prior assumptions, plot selection and separate reporting routes.

For each owner arrangement, the runner extracts/validates/freezes/saves the
artifact at scoring order 141 and starts a fresh `Rscript --vanilla` process.
That process receives only the artifact, response CSV and package code. A
mocked fitter fails if inadvertently invoked. Six synthetic response patterns
include the distinct text IDs `001` and `1`, both score endpoints, a one-rating
pattern and an all-missing assigned rating for literal ID `NA`. These are
software-workflow examples, not independent empirical cohorts or a new study
of sparse-design accuracy. The public omission policy does not add unassigned
cells or impute assigned missing ratings.

Both workflows return five scores, three requiring review, and one `not_scored`
Person. The latter is preserved in the complete disposition CSV and plot's
unplotted data, with no fabricated score point. Score CSV numbers agree with
the saved full-precision result within 1e-12 and IDs remain distinct. Both
original and changed-prior scoring pass their integration checks. The example
changes the prior mean by .5 logits and SD by a factor of 1.25; maximum EAP
movements are .6427 and .5803 logits for shared and separate owners. These are
scenario consequences, not recommended priors or population-transport evidence.
The frozen artifact remains byte-identical in memory after sensitivity scoring.

Saved score objects replay exactly. Summary, native plots and ggplot conversion
were executed with scoring and fitting mocked to fail, establishing that
reporting did not recompute the scores. Training-model `mfrm_results()` tables
and HTML reports were exported separately. A new-cohort score batch is not an
input to `mfrm_report()`; its supported outputs are its dedicated summary,
plots, full score/disposition tables and saved object. The guide states this
boundary rather than adding another report API.

### Reader-facing corrections found by the walkthrough

The adaptive scorer already passed its actual reported-EAP/SD checks, but the
printed summary showed the separate adaptive-minus-fixed comparison without
explaining that its fixed grid had not produced the scores. For the separate
fixture, that unused fixed grid differs in SD by more than 1e-5 while the
actual reported-score check passes. Summary printing now identifies these as
two different comparisons and displays the actual check. An all-missing batch
explicitly has no score comparison; it is not reported as a successful check
on zero scores. Numerical scoring and acceptance tolerances did not change.

Figures now state the number of unscored people. Their zero reference is
labelled `Scale origin`, correcting the old `Prior mean / scale origin` metadata
which was wrong when the scoring prior's mean differed from zero. Shape and
colour retain review distinctions. Native and ggplot exports were inspected;
this is author review, not accessibility conformance or novice-reader evidence.

The dedicated portable suite passed 135 checks after the summary correction.
The subsequent plot-label delta and its new assertions passed 52 focused
checks across the GPCM and ordinary RSM plot/summary groups; these overlap the
earlier suite and are not 187 independent checks. The two added assertions bring
the covered dedicated suite to 137 checks. Selected help topics were regenerated,
and their Rd and the vignette R code parse. The entire vignette also rendered
to HTML with its ordinary RSM example chunks enabled; GPCM template chunks
retain `eval=FALSE` and were exercised separately as described above. No full
package suite was repeated.

The first runner attempt changed factor IDs directly and produced missing IDs;
the scorer correctly refused those rows. That failed preparation/log remains
separate. The runner now explicitly converts the synthetic Person column to
character before assigning IDs. Accepted evidence is in
`validation-results/portable-gpcm-workflow-20260927-v2/`; the first attempt is
retained in the sibling directory without `-v2`. Final plots were regenerated
from saved results after the label corrections, without another scoring run.

### Connect the frozen artifacts to the external evidence

The shared-owner artifact has exactly the same response-function coefficients
and prior as the existing TAM/ConQuest comparison. Its external calculations
are reused after that identity check. The old separate-owner comparison used
the fixed-Q31 pilot fit, whose source integration fails today's extraction
check. It cannot qualify the newer artifact merely because it is labelled
separate-owner. No review override or tolerance change admits that source.

The missing comparison was therefore run on the already retained eligible
adaptive separate-owner fit. The existing TAM and ConQuest runners now accept
explicit source paths/owner lists, preserving their old defaults and recording
the chosen input. This changes the validation harness, not a package API or
the historical evidence. TAM fixes every calibration and population parameter;
there is no free recalibration. Its 121/181-grid and mfrmr 101/141-grid checks
pass the previously declared 1e-7 integration and 1e-6 scoring criteria.

`compare_portable_gpcm_external()` reconstructs the external category predictors
from each frozen artifact and verifies exact design/prior identity. It scores
the four prespecified external patterns (all-low, all-high, mixed complete and
incomplete known contexts) directly from the saved artifacts. Across both
owners and eight patterns, maximum differences from TAM are:

| Artifact | Maximum EAP difference | Maximum posterior SD difference |
| --- | ---: | ---: |
| Shared owners; existing external results reused | 7.99e-14 | 1.98e-13 |
| Separate owners; eligible source newly compared | 1.33e-15 | 2.78e-15 |

ConQuest was run locally outside the sandbox using the previously authorized
`/usr/bin/arch -x86_64 /Applications/ConQuest/ConQuest`. The new separate-owner
comparison keeps all two budgets × three seeds × four patterns, with exported
model checks before scoring and after native save/reload. Model identity passes;
labels change on reload, as in the earlier run, so numeric design/parameter
identity is checked. The maximum printed-parameter probability discrepancy is
1.13e-7 and its deterministic score effect is 1.13e-7. At 200,000 posterior
nodes, maximum artifact-versus-ConQuest EAP/SD differences are .0020319/.0013762
for shared owners (reused) and .0024212/.0016520 for separate owners (new).
At 20,000 nodes they are .0060942/.0025296 and .0071216/.0032503. All seeds remain
visible. These differences are consistent with the observed stochastic scoring
variation; they do not establish deterministic equality or a universal error
bound. Cross-engine interval endpoints and free-estimation equivalence are
not assessed.

### Local completion and release boundary

The scoped order-4 user workflow and fixed-artifact scoring comparison are now
complete. The admitted next integration scope is conditional scoring with
explicit prior sensitivity, scoped portable GPCM, experimental explicitly
requested slope profiles and their connected outputs. Existing RSM/PCM behavior
remains covered; broader GPCM structures and stronger inference claims are not
silently included. Remaining release work is a single combined-source check,
matching platform evidence and a version decision. This record does not create
a new tag, authorize a CRAN submission or transfer rc.6's results to changed
code. Numerical fitting and prior/coverage studies were not restarted.

### JML scope follow-up

The subsequent JML audit distinguishes implemented joint estimation and
fitted-object post-hoc EAP from unavailable portable extraction. Shared-owner
GPCM JML exists; separate owners and the MML formal slope-inference routes are
not JML features. The JML EAP reference prior defaults to N(0,1) or accepts an
explicit normal prior; it is not a population distribution estimated by JML
and is not new-Person ML/WLE scoring. No estimator, source gate or inference
acceptance rule changed in this follow-up.

Corrected capability text had attributed the portable JML gap to omitted
training Person coordinates or slopes. The gap is the unimplemented
JML-specific portable extraction/source qualification/prior contract. Public
help, the two vignettes, NEWS and the roadmap now state that distinction. A
focused check also exposed a stale RSM/PCM-only output-guide decision boundary;
it now includes conditional GPCM MML and explicitly excludes JML extraction.

Evidence: `validation-results/jml-scope-review-20260927/accepted-tests.rds`
and `.log` combine five relevant tests, 83 passing expectations, no warnings,
skips or errors. The existing 14-Person PCM JML test checks default and explicit
prior scoring, unchanged source fit, and typed portable refusal. Other checks
cover the GPCM JML interval guard and public guidance. The interval-guard test
uses a controlled object, not a new GPCM JML calibration or coverage study.
Three regenerated Rd topics parse/check successfully; `git diff --check`
passes. The initial custom test runner had reporting setup errors; these and
the stale guide assertion remain in the earlier logs. After correcting the
guide, only its affected tests were rerun; accepted JML numerical results were
reused. This is a scope/regression review, not completion of JML portability,
formal inference, a full package check or new external-software validation.
