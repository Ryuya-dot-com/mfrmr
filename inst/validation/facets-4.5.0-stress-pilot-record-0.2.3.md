# FACETS 4.5.0 stress-pilot record for mfrmr 0.2.3

Status: `0.2.3-draft.18` one-seed calibration record. This is not confirmation,
does not freeze a tolerance, and does not authorize a release claim.

## Purpose and identity

The pilot tested whether a paired truth-first mfrmr JML/FACETS workflow can
account for ordinary, sparse, missing, malformed, and weakly identified RSM
and PCM cases without treating external-program agreement as ground truth.

| Field | Recorded value |
| --- | --- |
| Run date | 2026-08-03 |
| Scenario seed base | 450023 |
| Models | RSM and PCM |
| Scenarios per model | 22 |
| FACETS executable | Local `C:/Facets/Facets.exe` |
| File metadata/report version | 4.5.0 / 4.5.0 |
| Executable SHA-256 | `dfb0afb0faa18f026d1b3b4175f22e42cc3764430eb83cbd368c7a572b3593a1` |
| Executable size | 16,391,680 bytes |
| Evidence role | Pilot-only; no confirmation |

The official update history lists FACETS 4.5.1 as a July 2026 release. No
RSM/PCM measure-estimation change is listed from 4.5.0. Fully unobserved
`Labels=` reporting and Table 7 subgroup/Welch output are version-sensitive,
so the 4.5.0 results below are not represented as 4.5.1-equivalent evidence.
The upstream-version difference was recorded and did not stop unrelated rows.

## Scenario coverage and accounting

The expanded registry included a balanced reference, rotating and planned
sparse assignment, MCAR missingness near 20%, 80%, and 90%, rater- and
score-dependent missingness, block dropout, workload imbalance, single-bridge
and disconnected topologies, structural rater-by-item holes, nesting, rare and
unused categories, extreme persons, an entirely unobserved rater, exact and
conflicting duplicate cells, rater drift contamination, and a small-sample
sparse case.

- FACETS reports: 44 expected, 44 present, 44 process statuses `ok`.
- FACETS report headers: 44 of 44 identify version 4.5.0.
- mfrmr fits: 44 completed; 39 numerical `pass`, 5 numerical `review`.
- mfrmr data state: 38 `pass`, 6 `review` for duplicates or nonconsecutive
  observed category support.
- mfrmr design state: 42 `pass_linked`, 2 `hold_disconnected`.
- Reporting state: 32 exploratory-ready, 5 numerical review, 5 data review,
  and 2 design hold.

One FACETS temporary-file cleanup warning occurred after a successful PCM
extreme-person report. It did not remove the report from accounting, but the
runner still needs a retry-safe cleanup policy before confirmation.

## Reference-cell result

For the balanced complete cell, transformed mfrmr-minus-FACETS differences
were small. MAE ranged from 0.00236 to 0.00603 across model and facet; maximum
absolute difference ranged from 0.00503 to 0.01629. Both programs separately
showed finite-sample truth-recovery error: FACETS RMSE ranged from 0.0409 to
0.2090 and mfrmr RMSE from 0.0416 to 0.2116 across rater, criterion, and person
parameters. Close program agreement was therefore not substituted for truth
recovery.

## Adversarial findings

1. Both deliberately disconnected cells completed numerically in both
   programs, but mfrmr correctly reported `hold_disconnected` and
   `hold_for_design_review`. Optimizer completion alone did not become
   inference readiness.
2. A single bridge remained `pass_linked`. Yet its between-program rater MAE
   was 0.206 for PCM and 0.314 for RSM, and RSM criterion MAE was 0.490. Binary
   connectivity is therefore insufficient as a stability or support gate.
3. At roughly 90% MCAR missingness, maximum person differences reached 22.04
   for PCM and 17.68 for RSM. In the small-sample sparse cell, PCM person MAE
   was 5.61 and its maximum difference was 30.34. These rows cannot be rescued
   by high pooled correlations or by good balanced-cell behavior.
4. FACETS truth-recovery RMSE for rater severity reached 0.635 in the RSM
   small-sample sparse cell and 0.595 in PCM. Planned sparse assignment,
   rater-drift contamination, unused categories, and 90% missingness also
   materially degraded some rater/criterion recovery rows.
5. The entirely unobserved-rater cases ran with seven observed raters in both
   programs. Because 4.5.1 changed Table 2 reporting for labels with no data,
   this row is retained as a 4.5.0 reporting-sensitivity case rather than a
   cross-version equivalence claim.
6. Five mfrmr fits retained optimizer code 0 but were correctly downgraded by
   the terminal-gradient review. Duplicate and unused-category cases also
   produced explicit data-review states.

## Consequences for the next pilot

- Add quantitative bridge-strength, articulation, component-balance, and
  local-information diagnostics; technical connectivity is not enough.
- Replicate the 80%--90% missing, small-sample sparse, planned sparse,
  weak-bridge, extreme-person, structural-hole, and drift cells across frozen
  pilot seeds before choosing any tolerance.
- Separate person, rater, criterion, and step rules. Do not pool parameter
  classes or rely on correlation alone.
- Add matched anchor cells, coverage/SE checks where definitions align,
  expected-failure accounting, parser negative tests, and retry-safe cleanup.
- Repeat the fully unobserved-label and Welch subgroup sensitivity rows under
  4.5.1 if that executable becomes available; retain version strata.
- Keep raw FACETS outputs outside the package and candidate source tree. Bind
  normalized evidence to parser, generator, control, locale, runtime, and
  candidate identities before confirmation.

## Reproduction boundary

The repository driver is `facets-4.5.0-stress-pilot-0.2.3.R`. The raw pilot
directory is intentionally outside this package repository. The normalized
figures above were reviewed from its scenario manifest, paired run summary,
truth-recovery tables, program-agreement table, and tool-identity record. A
candidate-linked rerun on disjoint seeds remains required.

## Sources

- FACETS official product page: <https://www.winsteps.com/facets.htm>
- FACETS official update history: <https://www.winsteps.com/facgood.htm>
