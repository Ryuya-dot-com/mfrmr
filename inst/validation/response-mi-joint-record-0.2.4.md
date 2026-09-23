# Joint RSM assigned-score example: result and remaining inference

2026-09-23; local M1/M2 example completion, not release completion.
The [plan](response-mi-joint-0.2.4.md) was written before sampling. Source and
outputs are in `validation-results/response-mi-joint-20260923/`. The earlier
ordinal-imputer example and its adverse six-score prediction check remain in
`validation-results/m1-workflows-20260923/`; its former tutorial is also saved
as `previous-ordinal-tutorial.Rmd`. The two masks differ, so their prediction
errors are not a paired comparison and cannot demonstrate improvement.

## What changed and why

The tutorial now supplies completions from a joint adjacent-category RSM,
matching the complete-data analysis's score support, additive fixed facets,
sum constraints and known N(0,1) Person population. Proper normal calibration
priors and one posterior ability draw per Person propagate the two uncertainty
sources. One calibration draw is shared by the whole roster. Multiple missing
scores of the same Person share that Person's draw; no plug-in EAP or independent
per-rating ability draw substitutes for it. This corrects the previous
example's coarse ordinal-regression/dependence specification, without adding
an exported imputation engine or changing importer/pooling calculations.

The masking rule depends only on observed R01 scores and was fixed before
sampling. The resulting roster has 732 observed assigned scores, 30 missing
assigned scores (five Persons with two missing scores) and six unassigned
events. Held-out values are excluded from the imputation likelihood. This is
a constructed MAR example; it does not diagnose real nonresponse as MAR.

The executable generation files and compact supplied example are
`inst/examples/response-imputation.R`, `.stan` and `.rds`. The compact file
includes the original incomplete roster, selected category draws, probabilities,
model/data/settings, software versions, chain/iteration identities and sampling
diagnostics. It includes no development-machine path or serialized compiler
object. The optional script requires an existing CmdStanR/Stan installation;
using the supplied example adds no package dependency. All raw chains remain
in the local sampling directory. Regeneration does not automatically install
software or replace an earlier run.

## Sampling and numerical correspondence

Four chains, 1,000 warmup and 2,000 retained iterations each, seeds/settings
as prespecified. All chains completed without divergences or tree-depth hits.
Maximum Rhat is 1.002811; minimum bulk/tail ESS is 9,025.7/4,972.0; E-BFMI
ranges from 0.9672 to 1.0686. All prespecified sampling checks pass. These are
computation diagnostics, not model-fit or frequentist-coverage evidence.

At each of forty retained completion draws, the Stan observed-score conditional
log likelihood agrees with the package kernel within 2.274e-13. Every missing
event's conditional category probabilities agree within 5.552e-16. Sum
constraints and the orthonormal prior covariance are checked, along with event
preservation, assignment and integer support. All 131 numerical/preservation
checks pass. Forty baseline and forty sensitivity analyses are eligible, with
no fit warnings. All original and paired fits are saved; none were dropped.

The original observed-roster fits with NA scores were numerically ready but
retained `input_review_required`, so the facet-interval API correctly refused
them. For this explicitly generated missingness example, the comparison was
then fitted to the reviewed observed assigned events; the full roster remains
saved. Both Q61/Q121 parameter vectors are exactly unchanged by this explicit
selection. No readiness flag was edited and no check was relaxed. The original
input-review fits and log are retained. Q61/Q121 differences in the observed
contrast and SE are 1.600e-6 and 1.390e-7, below the prespecified 1e-4 bound.

An intermediate summary failed because a scalar extracted from a posterior
draws matrix retained a column name. The record writer now converts that
scalar to numeric before binding rows. The fix reused all saved fits and draws;
there was no statistical rerun or changed result-selection rule.

## Answer for this example

Target: fixed R04-minus-R01 severity, logits; larger means R04 is more severe.

| Procedure | Estimate | SE / posterior SD | Lower | Upper |
| --- | ---: | ---: | ---: | ---: |
| Observed-score MML, Q121 | 0.463006 | 0.143025 | 0.182682 | 0.743330 |
| Observed-score Bayesian posterior | 0.464363 | 0.141106 | 0.184298 | 0.743394 |
| Joint-model MI, forty completions | 0.468187 | 0.145713 | 0.182444 | 0.753930 |
| Missing scores one category lower | 0.667466 | 0.140993 | 0.391095 | 0.943836 |

The Bayesian row uses posterior SD and equal-tailed credible bounds, not a
frequentist SE/CI. The MML row uses inverse observed information/normal bounds;
MI rows use Rubin covariance and t bounds. The MI point-estimate MCSE is
0.008225; within/between/total variance is 0.018458/0.002706/0.021232. The
point estimate agrees closely with direct inference in this example. MI does
not create extra observed information. For this same-likelihood target under
ignorable missingness, direct observed-score MML is already a valid analysis
route subject to the model's regularity, identifiability and approximation
conditions; users do not need to fill scores just to fit that likelihood.

The paired lower-score assumption changes the contrast by 0.199279 logits
(simulation MCSE 0.003517). This illustrates dependence on a substantive
assumption about missing scores. It is not an estimated MNAR mechanism or an
inferential interval for the between-scenario change. The thirty held-out
scores average 2.10 versus a posterior predictive mean of 2.241738; average
multicategory Brier score is 0.612534. This small check cannot qualify probability
calibration or establish population bias. A more favorable new mask was not
searched for and no outcome was used to change the fixed model or priors.

## Public integration and verification

The tutorial now explains the target, joint model, sampling checks, why direct
inference is possible, and the distinction between posterior and Rubin
intervals. It adds an English category-probability display with numerical
labels and alternative text, retains the pooled-contrast plot, and saves the
full provenance through the existing result object. Roxygen help, NEWS,
public ROADMAP, active work plan and claim ledger agree with this scope.

The updated tutorial's data/import/plot/table code executes with explicit
identity-checked replay of the just-computed baseline, sensitivity and direct
fits; no duplicate eighty-fit run or MCMC was needed. The rendered values
match the saved numerical record. All three affected Rd pages parse and render.
The probability figure and contrast figure were inspected as rendered images;
a light sequential palette retains readable black text throughout the
probability range. The compact example and results round-trip through RDS unchanged.
No full test suite, earlier numerical study, commit, push or publication ran.

During targeted Rd generation, the roclet's cleanup also removed other
generated topics. These were regenerated from their current R sources; the
unrelated local `as_kable` link was preserved. This was a documentation-build
repair, with no estimator change. The final diff has no deleted Rd topics or
unrelated new tracked-man changes, and `git diff --check` passes.

## Completion boundary

The M1 requirement for a defensible joint-model example, shared dependence,
parameter uncertainty, assigned-cell accounting, sensitivity and a declared
downstream target is now implemented and examined locally. One-example
agreement does **not** qualify repeated-sampling coverage. The imputer's proper
prior makes posterior moments different from unpenalized complete-data MML
moments; their substitution is an approximation, not exact congeniality.
This distinction follows Bartlett and Hughes (2020), Section 2.2,
doi:10.1177/0962280220932189, and is explicit in the help.

M2 still needs a prespecified repeated-sampling assessment of this retained
MI contrast/interval target, including availability, bias, width, coverage and
Monte Carlo precision under a relevant adverse assumption. The known ability
distribution, fixed RSM facets and this masking rule do not qualify PCM,
random-rater/testlet imputations or general auxiliary-variable models.
The separate shared-rater Laplace/scoring and regular-interval decisions also
remain open. M5 local completion and M6 publication have not been reached.
