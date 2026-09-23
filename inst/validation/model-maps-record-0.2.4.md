# Conditional Person comparisons and model-aware maps

Local checkpoint: 2026-09-23. Working tree based on `2230003`, branch
`development/0.2.4-expanded-workflows-20260922`. No commit, push, CI, main
merge or release was performed.

## Question, decision and release position

M3 requires a user to see how Person estimates change under a testlet or
shared-rater model and to relate latent locations to descriptive residuals.
This checkpoint completes those display/comparison connections using existing
calibrations and explicit source-roster scoring. It does not determine which
model is superior or qualify the extensions' statistical accuracy.

`score_mfrm_persons()` supplies a common source-roster entry point. It delegates
extension calculations to their existing scoring methods. For the bounded
ordinary RSM MML route it integrates the continuous conditional ability
posterior, retaining the fitted intercept-only normal mean and variance.
The ordinary route has the same population/model restrictions as
`mfrm_response_diagnostics()`; ordinary plug-in scoring is unchanged.
Person selection restricts returned rows, never the complete conditioning
roster. Missing-only Persons remain prior-only; zero ability variance and
failed integration remain unavailable, without zero-width intervals.

Saved scores attach to `compare_mfrm(..., person_scores = ...)` and, for the
extensions, `mfrm_results(..., scores = ...)`. Testlet `predictions =` remains
an alias. Person comparison requires matching complete assigned-event
multisets, calibration metadata, selected IDs, observed counts and interval
levels. It subtracts each fitted population mean from EAPs and interval
endpoints while preserving the unit Rasch logit scale. Raw coordinates,
origins, conditional SDs and endpoints remain in tables. Prior-only and
unavailable differences are withheld. No difference interval, Person test,
ranking or model selection is supplied.

`plot(res, type = "wright")` and `type = "fit_pathway"` now accept the two
extension result classes. The latter name follows the existing ordinary
residual-versus-location route; ordinary `type = "pathway"` remains a
different expected-score display. Native and ggplot renderers share saved
coordinates, English labels, symbol/color alternatives, monochrome output,
selection and title/annotation controls. Unavailable rows stay in tables;
empty pathway panels stay visible, and selected versus displayed Person
counts are separate. Tables and alt text accompany the images.

## Mathematical meaning of the coordinates

The adjacent-category equation is

`log(P(k)/P(k-1)) = theta + local - sum(facet severities) - step(k)`.

A fixed facet's reference location is its severity coefficient plus the
unweighted mean fitted step. It is the mean adjacent-category crossing
when all other severities and local effects are zero, not the middle
expected-score ability. Shared-rater positions use the fitted conditional
rater modes. They are not replacement-rater marginal predictions or
posterior-averaged crossings. Person-local testlet effects have no global
testlet column. A separate category column shows raw steps at the zero
reference; the Person column shows conditional EAPs on the fitted mean-zero
scale. Adding displayed facet locations would count the mean step repeatedly.

Only Person conditional intervals appear on these maps. Simply translating
a fixed/rater interval by the step mean would omit its uncertainty and
covariance; no such composite interval is fabricated. Original calibration
and rater interval plots remain separate. The pathway horizontal coordinate
is the saved descriptive posterior Infit or Outfit defined in the
[response-diagnostics record](response-diagnostics-record-0.2.4.md).
Selected-row denominators remain available. There are no expectation-one
lines, ordinary cutoffs, ZSTD, acceptance bands or rater-quality decisions.

## Evidence and corrections

Workflow: `model-maps-0.2.4.R`. Artifacts are in
`validation-results/model-maps-20260923/`, excluded from the package.
The protocol records tolerances before the fitted zero-effect comparison.

- Independent direct logistic probabilities and continuous integration
  verify ordinary EAP, posterior SD and both interval-tail probabilities to
  `1e-7`, including a nonzero mean and nonunit variance. A fixed-calibration
  zero-testlet reference checks origin alignment and preserved uncertainty.
- Reused separately fitted ordinary and known-zero-testlet example models
  agree within the prespecified `1e-5` tolerance. Maximum differences across
  the four selected Persons are EAP `3.456222e-7`, posterior SD `1.072841e-7`,
  lower endpoint `4.598272e-7`, upper endpoint `2.874558e-7`. The noncentered
  three-step coordinate fixture also checks the adjacent-crossing convention;
  it is a numerical reference, not a fitted inferential example.
- Targeted tests: model-maps 67, testlet-integration 41,
  testlet-population 49, extended-results 95, extended-comparison 61,
  response-comparison 76, namespace-contract 4: **393 passing expectations**,
  zero failures, warnings or skips. After the final empty-panel/count
  correction only the affected map tests were repeated. No full suite or
  broad simulation was repeated.
- Fresh-session replay (`verify-saved.R`) runs with RTMB unavailable and
  fitting/scoring/integration entry points replaced by errors. Both models'
  maps, paired/difference Person plots, reports, CSVs and starter archives
  still complete with zero plot errors. Generated replay scripts reproduce
  the saved tables exactly; CSV location coordinates agree to `1e-14`.
- The fitted example has 48 Persons and 768 ratings. Four testlet and two
  shared-rater Person outputs reuse the complete roster. The shared-rater
  residual example describes only 16 selected rows, still conditioning on
  all 768 ratings. Selecting outputs is not thinning the shared posterior.
  Existing shared-rater scores and diagnostic integrals were reused.
- Both changed tutorial sections execute from saved calibrations, including
  their actual ordinary scoring, Person comparison and map calls. Their
  scores/location tables match the workflow. Six changed/new help topics
  parse and render without issues. Native and ggplot figures were visually
  inspected for coordinate meanings, legibility and annotation controls.

The first archive run exposed ordinary-only plotting arguments being passed
to the new extension routes. The exporter now supplies those arguments only
to ordinary models; successful exports/replays verify the correction. Final
review also found that unavailable Person rows were counted as displayed
and entirely empty ggplot pathway panels could disappear. Selected/displayed
counts and explicit empty panels now preserve those distinctions. The
archive introduction and image alternatives describe the model-specific
figures instead of exposing plot component identifiers.

The final targeted-test run itself passed; its CSV writer initially failed
on testthat's list-valued result column. The saved test-result RDS was
summarized without that column, without rerunning tests. Initial workflow
and test logs remain available rather than being erased.

## What this does not close

M3's map/Person-comparison implementation and the corresponding M4 help and
replay are now local. **M3 remains incomplete.** Independent numerical
agreement verifies calculations, not approximation accuracy across sparse
designs, scoring performance under estimated populations, interval coverage,
or diagnostic accuracy. The earlier fixed-population shared-rater
undercoverage and nonzero small-reference Laplace error remain unresolved;
the zero-testlet comparison does not address either problem.

M2 must finish the statistical protocol and decisions for retained interval
and approximation claims, including conditions, practical tolerances,
Monte Carlo precision and unavailable-outcome accounting before new
confirmation runs. MI-model adequacy is also still open. Those dependencies,
not additional display variants or repeatedly running the whole package,
are the next release work. M5 local completion and M6 publication remain
unreached. No required outcome is silently deferred or declared validated.
