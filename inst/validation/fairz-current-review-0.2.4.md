# FairZ source, reporting and preflight review

Date: 2026-09-15. C12/C17 follow-up to the
[integrated ledger](claim-reconciliation-0.2.4.md).
This review repairs a reporting defect and checks the frozen study against
current source. It does not establish interval coverage or release readiness.
The 20,000-dataset confirmation remains unrun.

## Reporting question and repair

Can a user accidentally combine an earlier analysis's diagnostics with a new
fit when reporting FairZ? Before this repair, both `fair_average_table()` and
`plot_fair_average()` accepted that combination. They used the supplied
diagnostic measures/SEs together with the fit's threshold/reference structure.
On the first saved RSM preflight dataset, swapping MML/JML diagnostics changed
the five non-Person FairZ values by up to **0.124720 on the 0–2 score scale**;
the maximum measure-SE change was 0.076714. The opposite swap also changed
FairZ (maximum 0.100585). Plot eligibility stayed false, but the reported
numbers belonged to a mixed analysis.

The public table entry point now reuses the existing fit/diagnostics identity
validator. Plots and downstream callers inherit that check. The original
mixed pairs now fail through the table and both interval-enabled/disabled
plot routes, with instructions to recompute diagnostics. Matching saved
diagnostics remain usable. The fitting, transformation and SE formulas were
not changed. The derivative test now perturbs the internal transformation
directly instead of asking the public report to accept deliberately mismatched
diagnostics.

The help also corrects the formatted identifier to `Element` (`Level` belongs
to the raw tables), removes a nonexistent standalone `SE` alias, and describes
the transformed Measure units. The initial output-audit script incorrectly
joined formatted tables on `Level`; its failed check/log is preserved. The
join was corrected to `Element`, without relaxing numeric tolerances.

## Which uncertainty is being checked?

| Route | Quantity and available uncertainty |
| --- | --- |
| FairZ point estimate | Expected score at zero references, not a z-score. For PCM Rater rows, the reference uses averaged threshold parameters, not averaged response probabilities. |
| Public RSM/PCM table | Measure-level SEs accompany transformed measures. `fair_se = TRUE` leaves fair-score SEs unavailable; these measure SEs must not be used directly as FairZ SEs. |
| Public fitted-object RSM/PCM plot | Conditional focal-measure delta approximation, with fitted thresholds held fixed. Returned interval eligibility stays false, including when notes are hidden. |
| Repository confirmation candidate | Joint structural covariance propagated through the fixed-reference, non-Person FairZ gradient. This remains separate from the public table/plot uncertainty. |
| Bounded GPCM table | Its existing opt-in structural delta approximation remains diagnostic only; Person EAPs are conditioned on. This RSM/PCM preflight does not qualify GPCM intervals. |

The [frozen protocol](fairz-coverage-protocol-0.2.4.md) still defines eight
RSM/PCM × 80/320-Person × 3/6-rating cells, five Rater/Criterion targets,
fixed standard-normal Persons, unit weights, 0–2 scores and no anchors.
Neither targets, seeds, interval construction nor acceptance criteria changed.
FairM, Person, gap, linking and population-parameter intervals require their
own evidence.

## Current-source numerical and output checks

The existing runner was rerun after source changes on the same **40 unique
preflight datasets**, five per cell. Each final q61 fit also received q121
objective/gradient/information evaluation. The first dataset in each cell
received a fresh q121 optimization: 48 complete fits in that pass, not 48
independent datasets. Earlier passes are retained and do not enlarge the
replication count. All final fits passed the frozen preflight requirements;
errors, warnings, numerical conflicts and verification failures were zero.

| Check | Maximum discrepancy | Frozen bound |
| --- | ---: | ---: |
| Independent FairZ versus public table | 2.22e-16 | <1e-9 |
| Analytic versus numerical FairZ gradient | 1.80e-11 | <1e-7 |
| Conditional SE versus plot data | 2.56e-13 | <1e-8 |
| q121 fixed-parameter objective change | 1.17e-8 | ≤1e-6 |
| q121 relative SE change | 6.26e-10 | ≤0.001 |
| q121 Newton displacement / q61 parameter SE | 1.11e-5 | ≤0.001 |
| Fresh q121 refit FairZ change | 1.48e-10 | ≤1e-5 |
| Fresh q121 refit relative SE change | 7.34e-10 | ≤0.001 |
| Fresh q121 refit clipped endpoint change | 2.14e-10 | ≤1e-5 |

The guard leaves the 40 datasets' parameters, FairZ, both SE calculations,
availability and interval endpoints exactly unchanged. Relative to the
September 10 recorded preflight, maximum FairZ/SE/endpoint changes are below
1.4e-14. This checks applicability of that numerical preparation, not its
statistical adequacy.

The [output audit](fairz-current-output-0.2.4.R) uses the first saved fit in
each cell with native/legacy/both labels: **24 reporting configurations**.
It checks zero-reference summary values, full-precision plot data, rounded
table values, 90% conditional endpoints, RDS round trips, replay using matching
saved fit/diagnostics, CSV values and retained eligibility/notes. Saved
RSM/PCM tables alone correctly leave plot intervals unavailable. Suppressing
visible annotations does not remove the diagnostic restriction in returned
data. These are repeated output routes for eight datasets, not new data.
Maximum discrepancies were 4.93e-13 for formatted table/summary values,
4.21e-13 for conditional interval endpoints, and 5.11e-15 after CSV reload.

The focused tests and connected report/export tests passed **2,535
expectations in 12 files**, with no failures, errors, warnings or skips.
The shared identity test covers eight MML/JML × model/owner configurations
and 19 reporting routes, including APA measure tables and the three added
Fair Score routes. APA measure SEs are not reinterpreted as FairZ SEs.
Later help-only edits leave all 87 executable R files identical to the tested
version after parsing without comments. No complete package or platform
release check was repeated in this increment.

## Evidence and next work

The [retained bundle](../../validation-results/fairz-current-20260915) contains
the before/after mismatch probe, prior source snapshots, final preflight,
per-test results, numerical comparisons, output CSV/RDS files and source
hashes. `final-current` is the reviewed preflight/output run; earlier source
directories are historical. Cell RDS files retain source text, native-library
identity and session information. The existing resume/seed/source/backend/
shape/lock checks passed without changing the frozen protocol.

The final pass spent 35.188 seconds on the main procedure and 72.714 seconds
including its extra verification/full-refit work, excluding runner overhead.
Its cell means project about **4.9 serial hours** for confirmation before
checkpoint/report overhead. This is a five-dataset-per-cell timing estimate,
not a guaranteed deadline; parallel speedup has not been measured.

This completes the current-source FairZ preparation and reporting repair.
The next FairZ task is the frozen **2,500 fresh datasets per cell (20,000
total)** confirmation, retaining failed attempts and Monte Carlo uncertainty.
No new user approval is required by the historical documentation pause.
Recheck source identity before starting; further source changes require a
matching preflight. Public `FairCIEligible` remains false, and statistical
qualification is still open. The separate population 80,000-dataset study,
DRF alignment and GPCM/JML questions are not closed by this review.

From the package root, the existing commands for this reviewed source are:

```sh
Rscript inst/validation/fairz-current-output-0.2.4.R validation-results/fairz-current-20260915/final-current
Rscript inst/validation/fairz-coverage-0.2.4.R confirmation validation-results/fairz-current-20260915/final-current
Rscript inst/validation/fairz-coverage-0.2.4.R summarize validation-results/fairz-current-20260915/final-current/confirmation
```

Only the first of these commands has run in this review. The existing
four-hour invocation ceiling checkpoints unfinished work; the same
confirmation command resumes it under identical source/backend identity.
