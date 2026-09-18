# mfrmr roadmap

Status: public roadmap, updated 2026-09-18. Release dates are not promised.
Completed user-visible changes belong in `NEWS.md`; source-bound evidence and
execution details belong in the [maintainer roadmap](inst/validation/internal-roadmap-0.2.3.md#2026-09-18-current-priorities-and-completion-decisions).

## Purpose and priorities

mfrmr helps users calibrate ratings, compare Persons and facets on an explicit
measurement scale, reuse a calibration, and report what the evidence supports.
Its responsibilities are the response model, category/facet meanings,
identification, anchors and linking, scoring, and preservation of uncertainty
and restrictions throughout that workflow.

The estimation core remains frequentist MML/JML. EAP scoring conditional on
an MML calibration does not turn that calibration into full Bayesian
estimation. Random effects do not require a Bayesian backend. Future engine
choices follow a specified measurement model and inferential target; adopting
a generic regression interface is not itself a development objective.

Priorities are: close the existing public claims for 0.2.4; qualify useful
measurement decisions within that scope; then extend rating-design support
and sampled-facet models in bounded stages. New model families, plots and
validation counts are not progress measures on their own.

## Current releases

- The [CRAN package](https://cran.r-project.org/package=mfrmr) lists 0.2.3.1
  as the published source release, checked 2026-09-18.
- Local development is 0.2.4.9000. Neither the completed checks nor this roadmap
  approves a 0.2.4 release.

## What 0.2.4 is intended to support

The principal addition is a portable calibration and new-Person scoring
workflow with an explicit, deliberately narrow contract:

- one observed rating scale, RSM or PCM, and MML calibration with a fixed
  standard-normal Person distribution;
- supported direct and group facet anchors;
- same-data fitting-integration sensitivity review before extraction, using
  the highest reviewed fitting order with estimation completed at each order;
- separate scoring-integration settings and checks;
- preservation of categories, facet levels, scale, anchors and scoring basis
  when saving and transferring the calibration;
- EAP scoring of compatible new Persons, with explicit refusal of incompatible
  data, levels, models or settings.

Portable score intervals condition on the frozen point calibration and stored
prior; calibration-estimation uncertainty is excluded. Repeated calibration,
learned populations, transport and linking uncertainty are separate targets.
No single quadrature order is guaranteed for all designs.

The ordinary fitted-object routes remain subject to their documented scope.
Existing GPCM, JML, diagnostic, design and reporting functions are part of the
release review even when they are outside portable calibration.

## Evidence required before 0.2.4

The [claim ledger](inst/validation/claim-reconciliation-0.2.4.md) covers all 18
claim groups. Their reconciliation is complete; claim closure remains open.
For each retained result, the release decision must bind the target, model,
use conditions, estimator, evidence and executable output restrictions.

| Work | Current position | Next decision and completion condition |
| --- | --- | --- |
| Core calibration and portable scoring | Structural studies, integration reviews, identity repairs and installed-process replay provide bounded evidence. | Reconcile applicable evidence to the final source; verify supported fit → freeze → save/load → new-Person score → export workflows and incompatible-input refusals. Conditional uncertainty must remain explicit in extracted results. |
| FairZ intervals | The [20,000-dataset confirmation](inst/validation/fairz-confirmation-results-0.2.4.md) is complete: five primary cells supported, three under review. Public intervals remain diagnostic-only. | Decide the public disposition of the joint-covariance candidate and the existing conditional output. Any promotion requires an implemented target/scope rule and matching output checks. Five supported simulation cells are not a general eligibility formula; do not extend the completed study to obtain a pass. |
| Differential rater functioning (DRF) | EAP residual equality differs from a no-DRF hypothesis. A joint RSM/PCM comparison can include group ability means; four saved pairs pass the bounded q121 numerical preflight. | Freeze and evaluate the omnibus test's own null-size and availability study. Then decide a scoped inferential route or continued unavailability. Existing residual/refit screens do not acquire calibrated p-values from this work. |
| GPCM and JML | Independent kernels, numerical/boundary audits and bounded external comparisons exist; broader uncertainty and output claims remain open. | Close exact model/estimator subclaims or enforce restrictions. Include the selected slope owner and other facets, JML correction/extreme-score conventions, and uncertainty for the actual target. Item-only overlap with another package is insufficient. |
| Other decision-bearing routes | Equivalence, fit/PCA/Q3 flags, linking, observed-score G/D studies, shrinkage, imports and descriptive helpers have distinct evidence and limits. | Resolve each retained formula/decision/output claim in the ledger. A descriptive label or warning cannot repair an incorrect calculation or prevent an unsupported automatic decision. |
| Final release source | Prior local and cross-platform checks are reusable evidence for their recorded sources. | After the retained claims close, check one frozen candidate: full packaged tests, platform matrix, examples/vignettes, saved-object compatibility and CRAN requirements. Record skips/warnings and source identity; then make the release decision. |

The release blocker is an unresolved **retained public claim or material
implementation defect**. A new research candidate may be deferred if the
existing public route has a correct, enforced disposition. In particular,
adding a formal DRF LRT is conditional, not a new unconditional 0.2.4 promise.
The separate, unrun 80,000-dataset population-coordinate interval study is not
a prerequisite for that LRT. It becomes necessary only for the population
claims that depend on its specific evidence.

### Delivery order and release consequences

1. Freeze the already numerically reviewed joint-DRF sampling protocol and its
   execution/failure policy. Do not repeat the four-pair numerical panel without
   a new discrepancy or a relevant source change.
2. Resolve the FairZ candidate's public disposition from the finished study.
   Continue the independent GPCM/JML and secondary-route claim decisions while
   an admitted experiment runs; new computations must answer a named gap.
3. Implement the resulting corrections or restrictions and verify the affected
   complete user workflows. Statistical qualification of an omnibus comparison
   must not silently unlock population intervals, Person intervals or per-rater
   tests through a shared readiness flag.
4. Once every retained claim has a supported or enforced-restriction
   disposition, freeze and check the release candidate. A failed retained claim
   requires a correction or explicit supported-scope revision before release.

New studies fix their questions, targets, conditions, precision, seeds,
replication counts and failure accounting before execution. Preserve attempted
and available denominators, including numerical conflicts and boundary cases.
An inconclusive result stays inconclusive; increasing repetitions or changing
thresholds after seeing it is not the default next action.

Reuse completed studies and source-applicability checks. Run focused software
checks after affected changes, and the broad suite after shared-runtime changes
or at final-source review. No internal development visualization is planned.
User-facing plots require an identifiable user decision and a qualified result
object; their labels and documentation remain in English.

## Model scope

| Area | Current direction |
| --- | --- |
| RSM / PCM | Existing fitted-model routes and the bounded 0.2.4 portable MML workflow. |
| GPCM | Documented bounded fitted-model routes; slope identification and uncertainty require their own decisions. No portable GPCM in 0.2.4. |
| JML | Documented fitted-model analyses with estimator/correction/extreme-score distinctions preserved. No portable JML in 0.2.4. |
| Interactions / estimated populations | Retain documented fitting capabilities and actual inference restrictions. Neither a returned fit nor local information rank establishes formal inference. No portable interaction calibration in 0.2.4. |
| Multiple scales | Later explicit scale identifiers and separate-scale routing; no silent pooling or automatic cross-scale linking. |

## Random-effects MFRM and testlet covariance

The first sampled-facet use case is generalization beyond the observed rater
pool: what varies across raters, and how uncertain is a Person comparison when
raters are replaced? Keep this separate from dependence among repeated ratings
of the same response. Current fixed-facet MML and post-fit empirical-Bayes
shrinkage do not constitute a jointly estimated random-facet MFRM.

The first candidate is a single-scale, unit-weight adjacent-category RSM with
one shared random-rater intercept, fixed task/criterion effects and a declared
Person distribution. One effect belongs to each rater across all their Persons;
integrating a fresh rater effect for every Person changes the model. Keep
Person-local testlet effects and shared-rater effects separately identified.
Reuse completed local-dependence and fixed-point reference work; completing
every correlated-testlet variant is not a prerequisite for this bounded rater
question.

| Stage | Required result before proceeding |
| --- | --- |
| Specify the measurement and inference | Define observed-rater versus new-rater targets, scale constraints, effect ownership, missingness assumptions and a frequentist marginal-likelihood/prediction route. Resolve the role of calibration uncertainty in Person and Person-difference results. |
| Choose a computational route | Compare existing engines against the exact adjacent-category probabilities, likelihood, effect sharing and constraints. Reuse an engine only where these match; explain a demonstrated gap before creating a native solver or adapter. |
| Qualify the bounded model | Verify joint likelihood/derivatives, identification, zero-variance and weak-information behavior, integration and optimizer stability. Then assess recovery, interval/prediction performance, availability and cost at the intended rater counts and workloads. A two-rater reference is not evidence for operational scale. |
| Admit a public workflow | Preserve model/covariance declarations in fitting, scoring, saved objects and reporting. Distinguish conditional observed-rater results from new-rater predictions, and retain shared uncertainty in Person differences. |
| Extend only after a new use case is admitted | PCM, sampled tasks, local/correlated testlets, crossed/nested interactions and random slopes receive separate specifications and evidence. They are not one mandatory Cartesian-product study. |

The inference framework is chosen before the backend. The previous brms/Stan
reference results remain research evidence; further Bayesian fitting is paused.
A cumulative-link ordinal regression engine is not a drop-in estimator for
polytomous RSM/PCM. Neither this distinction nor the pause mandates writing a
new estimator. See the [measurement-purpose decision](inst/validation/measurement-extension-next-decisions-0.2.4.md)
and the [literature-grounded model specification](inst/validation/measurement-model-extension-literature-roadmap-0.2.4.md).

Random effects and covariance must be declared as model elements, with owners,
response mappings, constraints and prediction populations. Positive-definite
covariance alone does not establish identification. Random slopes on observed
covariates differ from discrimination on latent ability. A new rater is not
silently represented by severity zero, and independent marginal Person SDs do
not represent a jointly estimated Person difference.

## Rater assignment and anchors

The design question is: within a stated total and per-rater workload, which
assignments provide defensible comparisons for the intended Persons and
raters? Define the cost unit explicitly, particularly when one scored response
contains several criterion ratings. Connectedness, balanced workload and an
anchor percentage alone do not answer the precision question.

| Stage | User benefit and evidence required |
| --- | --- |
| Existing fixed-facet design support | Audit current assignment, workload, connectivity, failure-denominator and requested-facet handling. Retain their present supported meaning; this work does not wait for random-rater estimation. |
| Target-specific equal-cost comparisons | Specify whether the objective is facet estimation, Person scoring or a Person difference. Compare the same declared targets across allocations, showing error, interval availability/coverage/width, and computation. Use uncertainty qualified for that target; facet recovery cannot stand in for Person-difference precision. |
| Generalization to replacement raters | After the matching random-rater model and prediction route qualify, compare allocation under sampled rater pools and explicit replacement assumptions. This stage depends on the sampled-facet track; the preceding stages do not. |
| Recommendation API | Require usable result objects, explicit constraints and transparent trade-offs. Preserve unavailable/disconnected cases and subgroup disadvantages. Do not declare one best design without a user-relevant objective and acceptable uncertainty. |

Reuse the [saved equal-cost layouts and common targets](inst/validation/measurement-extension-next-decisions-0.2.4.md#3-評定設計支援で比較する対象).
Keep disconnected layouts as negative controls. The known confounding between
rating density and comparison groups in layout B must be handled explicitly;
it cannot identify an isolated bridging effect. Model-based finite outputs do
not establish direct comparison information in a disconnected assignment.

Anchors and linking require a separate statement of what changes: fixing an
anchor, deleting a rating, or excluding a common element are different
procedures. Existing [topology checks](inst/validation/equating-topology-record-0.2.4.md)
and [fixed-estimate offset checks](inst/validation/offset-sensitivity-record-0.2.4.md)
retain their limits. Inference for full-refit differences must repeat any
selection/linking, preserve a common scale and account for paired covariance.

## Generalizability theory

Existing `mfrm_generalizability()` and `mfrm_d_study()` cover a limited
observed-score, main-effects mixed-model decomposition and planning projection.
Their assumptions and output claims belong in the 0.2.4 review. They do not
establish a full interaction decomposition or reliability on the MFRM latent
scale. Future multivariate G-theory needs declared universe-score/error
covariances, relative/absolute decisions and design-dependent coefficients;
univariate calculations do not establish that extension.

## Response time and decision processes

These remain unversioned research directions below the sampled-facet and
rating-design priorities. A hierarchical response-time model needs a concrete
timed workflow, a declared actor/event and unit, treatment of missing/censored
times, and an identified ability-speed relationship. A respondent's one
production time must not be duplicated because several raters score the
response. Rater scoring time is a different observation.

A drift diffusion model requires a suitable choice-and-time decision task and
its own validated likelihood; ordinary polytomous ratings or essay completion
times do not by themselves justify it. Response time, diffusion models and
multivariate G-theory are not prerequisites for 0.2.4 or random-rater support.
Existing descriptive time summaries retain their scope. See the
[process-model research specification](inst/validation/measurement-model-extension-literature-roadmap-0.2.4.md#2026-09-15-crossed-effects-and-process-model-refinement)
for the deferred questions and literature.

## External comparison

Use FACETS, ConQuest, TAM, mirt, sirt, immer or other software only after
matching response probabilities, parameterization, identification, effect
owners, estimator and target. Record differences when exact matching is
impossible. External agreement is evidence, not a definition of correctness
or a claim of feature parity. Independent likelihood calculations remain
useful when no external program expresses the full model.

## Relationship to adjacent R packages

mfrmr owns the many-facet measurement workflow and scale/uncertainty contract.
It should reuse mature computation where it preserves that contract. Begin
with documentation/export and an exact matched case; add a narrow adapter only
for a recurring user need. Dependencies, backend identities and unsupported
translations stay explicit. Importing results is not refitting or reconstructing
an unavailable covariance. A backend is not silently converted into a native
mfrmr fit or portable calibration.

The [dated package-scope audit](inst/validation/measurement-model-extension-literature-roadmap-0.2.4.md#2026-09-15-sirt-and-immer-scope-audit)
retains checked versions, shared computational dependencies and model
comparisons. Those records do not approve every current or future package
feature as an interchangeable engine.

## Version direction

| Version / horizon | Goal | Entry or completion condition |
| --- | --- | --- |
| 0.2.4 | Release the bounded portable calibration/scoring workflow and close retained existing-route claims. | Claim dispositions and implemented restrictions precede final-source/platform checks and the release decision. |
| 0.2.5 candidate | Explicit scale identifiers and separate-scale RSM/binary and PCM routing, if user demand justifies it. | After 0.2.4 closure, fix scale-specific identification, categories, missingness and scoring. This is not automatic linking or a prerequisite for random-rater research. |
| Subsequent feature releases, version unassigned | Target-specific rating-design support and bounded frequentist random-rater MFRM. | Use the separate staged gates above; admit public features only after numerical, statistical and workflow evidence. |
| 0.3.0 | Consolidate validated APIs, object schemas, migration and reproducible performance. | Include only admitted routes; no requirement to complete all research tracks. |
| 1.0.0 | Maintain a deliberately bounded stable core. | Document supported use conditions, statistical limits, compatibility policy and maintenance commitments. |

There are no promised versions for portable GPCM/JML/interactions, automatic
cross-scale linking, multidimensional estimation, mixed response families,
multivariate G-theory, response-time or diffusion models. Their absence does
not prevent a stable core release.

## Compatibility principles

- Reject incompatible objects clearly; preserve model, scale, category, anchor
  and uncertainty meanings across summaries, plots, exports and replay.
- Give schema changes an explicit migration or refusal policy. Semantic
  identity matters more than incidental file hashes.
- Use realistic operational defaults in examples and clear reader-facing
  documentation. A compact illustration must not imply general qualification.
- Describe functionality as supported only when its documented conditions,
  implementation and evidence agree. A planning milestone is not API support.

## Not part of the 0.2.4 promise

Portable GPCM/JML/interaction calibration, jointly estimated random facets,
multiple observed scales within one portable object, automatic cross-scale
linking, joint response-time/diffusion estimation, exported multivariate
G-theory, and external-software feature parity remain outside the release
promise. A new formal DRF LRT or FairZ uncertainty method is admitted only by
its own evidence and output decision. Existing exported functionality still
requires a correct, enforceable disposition.
