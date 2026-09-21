# MML use-condition evidence and numerical audit

Execution date: 2026-09-09. Status: complete; sixteen model/design cases,
52 fits, and deterministic weight-pattern checks. The design below was fixed
before execution. Non-unit-weight ordinary-inference eligibility remains a
release blocker requiring a shared output restriction or a validated basis.
Record finalized: 2026-09-10.

Follow-up: the [observation-weight readiness repair](observation-weight-readiness-repair-record-0.2.4.md)
subsequently closes the implementation gap through an enforced restriction.
The results, source identities and next-task statements below describe this
pre-repair audit; its 52 saved fits and original inference flags are unchanged.
The repair record owns the current-source replay and migration evidence.

Question: which gaps remain between the completed q61 structural-uncertainty
studies and the default grid, estimated-population and observation-weight
routes that users can call? This is a targeted numerical/output audit, not a
new recovery or coverage confirmation. Existing unfavorable results remain
unchanged. No TAM fit is repeated and no universal quadrature rule is inferred.

Retain sixteen deterministic model/design cases: the first seed in each of the original
eight coverage cells; the two previous population-regression fixture seeds;
two within-Person heterogeneous-weight extensions of the previous weighted
fixtures; and the first fixed-population BASELINE and SPARSE_RATER stress seeds
for each of RSM and PCM. The stress inputs must reproduce their retained
SHA-256 identities. Population fixtures remain inference-ineligible pending
the nonlinear estimability review.

Short fixtures use q31/q61/q121, maxit 200 and reltol 1e-10. Historical stress
fixtures use q31/q61/q121/q181, maxit 1000 and reltol 1e-12 as before. All fits
use direct MML. At every fitted vector, recompute the objective, covariance
and score using q241. Reuse the previous numerical-review bounds: absolute
objective change <=1e-6, relative expanded facet/step SE change <=0.001,
scaled Newton displacement <=0.001, and unregularized positive-definite
information. These are local audit criteria, not new package cutoffs.
Also record free-coordinate SE movement and same-data parameter movement
across refitted grids. A finite fit or readiness flag does not certify the
quadrature comparison. Retain every error, warning and unavailable result.

Weights are (0.5, 1, 1.5) by Rater, so all three occur within each Person and
their mean is one. They multiply conditional log probabilities inside the
Person integral. Check the q241 objective against the independent whole-line
integral at the retained q121 estimate. Separately enumerate all 27 three-rating
patterns for the two complementary assignments at the original known truth,
using the previous independent pattern oracle. Compare unit weights with
these heterogeneous weights: report the sum of powered pattern integrals
and the expected score under the original unit-weight data-generating model.
Unit weights must normalize to one and have expected score near zero; check
finite-difference steps 1e-4 and 5e-5. This determines whether one may assume
the same generative likelihood/estimand after changing observation weights.
It does not derive a corrected weighted estimator or a sandwich covariance.

Inspect current formal-inference flags, the weighting policy already used for
information criteria, and Rater equivalence admission. Preserve source and
input identities, all fits/covariances, planned criteria and summaries.

## Evidence disposition

| Question | Existing evidence and new result | Current disposition |
| --- | --- | --- |
| Does the q61 fixed-normal, unit-weight structural result need another broad run? | The [original confirmation](mml-structural-coverage-record-0.2.4.md) and [fresh bias confirmation](mml-structural-bias-confirmation-record-0.2.4.md) remain applicable to their exact conditions. Current-source fingerprints still match. | Retain their separate decisions and scope; this audit adds numerical examples, not another performance confirmation. |
| Can the result be transferred to the default q31? | The eight retained short-pattern examples have tiny SE/parameter movement, but three exceed the strict absolute objective bound. Historical long-pattern failures reproduce with structural SE and terminal-displacement checks added. | A default grid and an inference-ready flag do not establish integration accuracy for arbitrary data. Retain same-data sensitivity review; no universal replacement grid is established. |
| Do estimated-population fits become inference-ready merely because their covariance agrees? | Previous independent whole-line information checks and the present grid checks agree in two latent-regression examples. The API retains `design_rank_not_evaluated`. | Ordinary inference and equivalence remain unavailable. Review nonlinear estimability/readiness before planning recovery/coverage for these claims. |
| Does a powered weighted objective supply ordinary sampling uncertainty? | Its computation agrees with a whole-line reference, but pattern enumeration demonstrates a different objective under the original data-generating model. All six weighted fits nevertheless admit formal inference and equivalence. | Unresolved inference basis plus a reproduced output restriction gap; prioritize the common eligibility rule. Do not transfer the unit-weight coverage result. |
| Are Person precision and joint decisions covered by the completed studies? | Those studies address the listed structural coordinates and contrasts, not individual Person posterior intervals or joint Wald/TOST operating characteristics. | Keep these targets separate; first specify which retained decisions require additional calibration. |

## Grid results and interpretation

All 52 fits and their information calculations completed. The following table
counts the cases meeting all three frozen numerical bounds at each fitted
grid against q241 at that same parameter vector. Counts are not statistical
pass probabilities. The [numeric summary](mml-use-condition-audit-summary-0.2.4.csv)
preserves every continuous discrepancy, flag and error/warning count.

| Case family | Cases | q31 | q61 | q121 | q181 |
| --- | ---: | ---: | ---: | ---: | ---: |
| Original coverage first seeds, 3 or 6 ratings per Person | 8 | 5/8 | 8/8 | 8/8 | not run |
| Population regression | 2 | 2/2 | 2/2 | 2/2 | not run |
| Within-Person heterogeneous weights | 2 | 0/2 | 2/2 | 2/2 | not run |
| Historical 12- or 30-rating stress cases | 4 | 0/4 | 0/4 | 2/4 | 4/4 |

For the eight short-pattern cases at q31, the largest relative structural-SE
movement is 1.276e-6, or about 0.000128%, and the largest refitted parameter
movement is 9.625e-6 of its high-grid SE. Cells 4, 6 and 8 miss only the
absolute objective bound, with changes 2.725e-5, 3.123e-6 and 5.333e-5.
The other numerical bounds are met. These are small arithmetic discrepancies;
they do not demonstrate materially bad SEs in these examples. Conversely,
eight examples cannot transfer the q61 repeated-sampling conclusion to every
q31 dataset or parameter configuration. Both weighted q31 misses are likewise
objective-only, with structural-SE movement at most 3.025e-6 relative.

Longer patterns show a distinct numerical effect. At q31 the historical
30-rating RSM and PCM examples have objective changes of 0.2311 and 0.2714,
and the following structural differences:

| Historical case | Ratings per Person | Maximum relative SE change at q31 | Maximum refitted parameter movement in high-grid SE units |
| --- | ---: | ---: | ---: |
| RSM BASELINE | 30 | 0.7756% | 0.05396 |
| PCM BASELINE | 30 | 0.3124% | 0.02638 |
| RSM SPARSE_RATER | 12 | 0.08926% | 0.004099 |
| PCM SPARSE_RATER | 12 | 0.10243% | 0.003324 |

The 30-rating cases still miss the objective bound at q121; their q181
evaluations meet all bounds against q241. The 12-rating cases meet all bounds
at q121 and q181. All sixteen cases pass at their highest fitted grid.
These results reproduce and refine the previously documented integration
problem; they do not justify a universal q181 default or reclassify the old
TAM comparison. No new TAM estimation was performed.

All sixteen historical-stress fits are marked inference-ready by the API,
including the ten that miss this numerical audit's criteria. Fit readiness
therefore must not be described as a certificate of quadrature stability.
The existing public sensitivity helper includes likelihood, parameter and
Person-score movement, plus its existing slope/population information
diagnostics. This audit additionally measures expanded RSM/PCM facet/step-SE
movement. Whether the public review procedure sufficiently supports a
retained structural-uncertainty claim needs an explicit disposition.

## Population and weight findings

Both population-regression examples pass the grid checks at all three orders.
All six fits remain formally ineligible and refuse Rater equivalence because
the nonlinear population-variance block retains `design_rank_not_evaluated`.
That is a restriction awaiting estimability/readiness evidence, not a newly
observed likelihood or covariance error. The [independent information
extension](mml-independent-information-conditions-record-0.2.4.md) remains its
separate whole-line numerical foundation.

For the two heterogeneous-weight examples, the independent whole-line
objective and q241 calculation at the q121 fitted vector differ by only
1.535e-12 (RSM) and 1.194e-12 (PCM). Thus the package correctly evaluates the
stated powered conditional objective in these examples.

That calculation does not establish a probability model for the original
single-rating observations or its sampling covariance. The weights have
mean one, but they are applied inside each Person integral. Let Q_w(y) be
that powered integral for pattern y. The [weight summary](mml-use-condition-audit-weights-0.2.4.csv)
averages the two balanced assignments under the original fixed-normal truth:

| Model | Weights | Sum of Q_w over patterns, averaged across assignments | Maximum absolute expected score at the original truth |
| --- | --- | ---: | ---: |
| RSM | unit | 1.0000000 | 3.462e-10 |
| RSM | (0.5, 1, 1.5) by Rater | 1.0656463 | 0.0080910 |
| PCM | unit | 1.0000000 | 4.029e-10 |
| PCM | (0.5, 1, 1.5) by Rater | 1.0729877 | 0.0040542 |

The weighted expected score does not vanish even after averaging assignments.
Consequently the original truth is not a stationary point of this weighted
expected objective for these data-generating conditions. Normalizing the mean
weight to one does not restore the original likelihood or estimand. This is
a deterministic calculation over all patterns, with finite-difference step
changes below 5.1e-10, not a chance imbalance in a small simulation.

This counterexample concerns fractional observation weights on the stated
single-rating data. It does not rule out every legitimate weighting design
or frequency representation. It does show why the ordinary unit-weight
sampling result cannot be carried over without specifying what the weights
represent and what uncertainty is being estimated. No bias correction,
Person-frequency reinterpretation or sandwich-SE implementation is supplied.

Despite this unresolved basis, all six weighted fits expose
`SupportsFormalInference = TRUE` and admit `analyze_facet_equivalence()`.
Their existing IC weighting policy correctly identifies
`nonunit_row_varying`; the formal-uncertainty path does not use that restriction.
The earlier [information extension](mml-independent-information-conditions-record-0.2.4.md)
also retained formal eligibility for non-unit weights constant within each
Person. Both categories require a support decision.

## Required next implementation and remaining boundaries

The first corrective task is a shared restriction on ordinary inference when
non-unit observation weights lack a validated inferential basis. Reuse the
existing weight classification, keep omitted weights and explicit all-unit
weights as positive controls, and check fresh fits, stored fits, supplied
diagnostics, equivalence bundles, summaries and plots together. A change only
to the displayed warning or one equivalence caller would leave other routes
able to restore the unsupported claim. Weighted point objectives and their
diagnostic curvature must retain accurate labels and provenance.

For grids, retain the supported same-data sensitivity workflow and make the
remaining structural-SE review requirement explicit; do not introduce a
universal cutoff or a default change from these examples. For estimated
populations, next review the nonlinear estimability evidence and its current
restriction before a performance protocol. Person uncertainty, joint
inferential decisions, full GPCM and estimator-specific JML remain separate.
No release or broad scope expansion follows from this audit.

## Reproduction, warnings and source preservation

The fit-and-reference pipeline took 238.336 seconds; log timestamps span
23:47:23--23:51:24 JST on 2026-09-09, about four minutes including startup.
There were no fit/reference execution errors. The 16 model/design cases use
14 distinct response datasets: the two historical stress datasets are each
reused for RSM and PCM, exactly matching their retained input fingerprints.
They must not be counted as four independent data replications.

The initial helper emitted 52 metadata warnings: its two SE extractions in
each of 26 RSM fits accessed the absent `StepFacet` column. RSM has shared
steps; PCM has an owner column. The numeric SEs and their ordering were
unaffected. The helper now uses the explicit `shared` label for RSM and checks
coordinate-name uniqueness. Both SE extractions were replayed from the saved
fit/covariance objects in all 52 fits, without warnings and with unchanged
numeric discrepancies to 1e-14. Initial warnings and source remain archived.
No seed, fit, grid, tolerance or production formula was replaced.

The [evidence archive](mml-use-condition-audit-evidence-0.2.4.rds) contains
all inputs, fits, covariance matrices, reference scores, initial source and
plan, the label-corrected helper/replay, pattern calculations, fingerprints,
logs, finalizer, base commit and source diff. Numeric matrices and summaries
were checked after serialization. Formula environments require structural
comparison rather than pointer identity; the all-empty CSV error column is
read explicitly as character when checking the round trip. These reader
adjustments do not alter the recorded outcomes.

Production `R/` files and all previous statistical-study payloads remain
unchanged. The initial audit's source fingerprint is preserved separately
from the corrected helper fingerprint. Run the [helper](mml-use-condition-audit-0.2.4.R)
from the package root with an output directory; the archived finalizer also
reconstructs the compact summaries and the preserved label-only replay.
This audit has not yet corrected production eligibility for weighted fits.
