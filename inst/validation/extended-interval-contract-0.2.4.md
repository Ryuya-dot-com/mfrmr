# Retained extended-model interval contract

Decision frozen 2026-09-23; implemented and verified 2026-09-24. This settles output policy
using existing evidence; no new coverage experiment or numerical-method change.

The [known-population shared-rater pilot](random-rater-record-0.2.4.md) has
85% coverage for each step with six raters (34/40 each) and an adverse
individual-rater result. The [800 estimated-population study](estimated-model-qualification-record-0.2.4.md)
and [480 testlet study](testlet-estimated-qualification-record-0.2.4.md) do not
qualify regular calibration intervals generally.
Local likelihood and conditional-scoring references validate their specified
numerical approximations, not repeated-sampling coverage. Relabeling automatic
95% bounds is insufficient to resolve that difference.

| Target | Retained output policy | Meaning and boundary |
| --- | --- | --- |
| Fixed facets and steps, both extensions | Point estimates and approximate SEs by default; no automatic Lower/Upper. Explicit normal intervals through confint, summary, testlet plots and common results. | Observed-information, pointwise normal approximation at a numerically ready interior fit. No established general finite-sample coverage or rater-quality classification. |
| Realized shared-rater effects | Existing point/mode and SE outputs; normal intervals only through the existing explicit request, bootstrap only after explicit computation. | Existing adverse coverage results, unavailable refits and conditional/first-order distinctions remain. No new default interval. |
| Shared-rater population SD | Existing explicit confint(..., parm='rater_sd') profile route. | Approximate marginal profile with asymptotic chi-square cutoff, including zero when supported; no full-profile numerical or finite-sample coverage qualification is inferred from local checks. Known-SD and nuisance-boundary refusals remain. |
| Testlet variance and ability SD | No new regular interval. | Boundaries and sparse information do not justify Wald or log-Wald replacements. |
| Person ability | Existing explicitly conditional scoring intervals. | Calibration held fixed, not general calibration-adjusted frequentist intervals. |

Keep every calibration row, including missing bounds, and never mutate an older
saved fit to apply a display policy. Rebuilding summaries/results from that fit
must use the new default and explicit-request rules without fitting/scoring.
An explicitly selected confidence level must agree in the table, plot and saved
report. A numerical/information failure, estimated variance boundary or invalid
SE cannot be overridden by asking for the normal approximation. Population-SD
rows never acquire calibration Wald bounds.

Use existing S3 confint and plotting/reporting routes; add no new model, CI
class or exported general-purpose engine. Centralize calibration-table policy
so fits, older saved objects and reporting cannot diverge. Preserve ordinary
MFRM behavior and reject extension-only options on an ordinary result. Existing
archived result bundles retain their original tables; rebuilding from the saved
fit applies the new policy. New result bundles preserve the explicit request
and level across save/replay/export and plotting.

This is an output restriction and access decision, not improved coverage or
positive qualification of the old interval method. It retains the requested
workflows and explicit approximation access; it does not silently remove a
model or invent a safe sample-size/rater-count cutoff. Verify formulas,
unavailability, old-fit nonmutation, common output and focused regressions.
After this decision is implemented, move to cross-workflow integration rather
than expanding simulation grids. M5 still requires one integrated checked source.


## Implemented result and verification, 2026-09-24

One internal table policy now serves both fit constructors, summaries, printed
fits, testlet calibration plots and the extended results adapter. The new S3
`confint.mfrm_testlet` and shared-rater `parm = "calibration"` use saved SEs;
likelihood, optimization, covariance estimation and Person scoring algorithms
are unchanged. The method excludes population SD rows from calibration bounds.
Normal quantiles use the smaller tail probability, avoiding premature infinity
for an otherwise valid level very close to one. Noninteger percentage labels
retain the selected level, e.g. 92.5%.

New result bundles record method and nominal level. Testlet calibration plots
inherit them unless explicitly overridden. Reports, CSVs and archived replay
retain the recorded values. Older fit objects are not mutated; rebuilding
summaries/results applies the new defaults. Older result bundles retain their
original stored tables and legacy plot convention. A new plot request is a
new display choice, not a modification of the archived tables.

The verification directory is
`validation-results/extended-interval-contract-20260924/`:

- Seven focused test files pass **520 expectations**, with zero failures,
  warnings or skips: extended results 212; extended plot views 82; testlet
  display integration 41; existing shared-rater normal output 26; namespace 4;
  testlet estimation/scoring reference tests 74; shared-rater fit/profile
  reference tests 81. These are code/output regressions, not coverage trials.
- Guards cover numerical and information failures, both estimated variance
  boundaries, invalid SEs, population-SD exclusion and interval-width plots
  without an explicit request. Independent normal-quantile calculations check
  80%, 92.5%, 95% and a valid near-one level across both classes, without
  source-fit mutation. Ordinary fits reject extension-only options.
- Two real saved interior fits (the first frozen shared-rater calibration
  reference case and testlet qualification case 121) reproduce finite explicit
  80% and 95% calibration bounds from saved estimates/SEs. Default summaries
  omit their old automatic bounds. No calibration fit or Person scoring was
  rerun for this check.
- An exported testlet result replays in a fresh R session with the current
  development namespace and fitting/scoring functions blocked. Its 80%
  calibration table, report and plot agree. This verifies local replay, not
  installation of a frozen source package.
- Eight changed Rd topics are regenerated, parsed and rendered to HTML.
  Both model tutorials, the interval/workflow guides, NEWS, README migration,
  reference index and maintained roadmaps reflect the same contract. Rendered
  default/explicit-80% testlet plots were visually inspected: English text,
  readable monochrome marks and complete captions, with no internal paths.
- The full test suite, earlier simulation studies, full vignettes, installed
  archive and platform CI were not rerun. They are not completion evidence
  for this source. The applicable integration checks belong to M5 after the
  remaining cross-workflow reconciliation.

This closes the **M2 retained interval-output decision** and its focused M3/M4
implementation checks. It does not close every M2/M3/M4 outcome or make the
intervals statistically qualified. M5 local completion and M6 publication
remain open. Proceed with cross-workflow source/help/output reconciliation
against the admitted claims and existing evidence; do not add another coverage
grid merely to extend this checkpoint. No commit, push or publication was made.
