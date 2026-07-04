# DIF/DFF APA reporting validation (0.2.2)

Status: release-evidence artifact for the 0.2.2 DIF/DFF reporting route.
Generated from `inst/validation/dif-apa-reporting-0.2.2.R` on the current
source tree after loading the package with `pkgload::load_all()`.

The purpose of this artifact is not to validate DIF detection power. That is
handled separately by the MH simulation and package-comparison helpers. This
artifact validates the reporting adapter: whether `dif_report(...,
style = "apa")`, `apa_table()`, and `build_apa_outputs(..., dif_results = ...)`
keep method labels, tables, captions, notes, and caveats synchronized without
promoting screening evidence into bias, fairness, invariance, or operational
subgroup-decision claims.

## Source boundary

The validation follows the source boundary recorded in
`inst/references/dif-apa-reporting-0.2.2.md`:

- fitted-model `analyze_dff()` / `analyze_dif()` rows are MFRM DFF/DIF
  screening evidence;
- `analyze_dff_moderation()` rows are continuous-covariate residual-moderation
  screens, not categorical MH DIF;
- `analyze_dif_mh()` rows are observed-score Mantel-Haenszel DIF screens and do
  not use a fitted-MFRM `RSM`, `PCM`, or bounded-`GPCM` likelihood;
- bounded-`GPCM` rows must carry the slope-aware sensitivity-reporting caveat in
  the report object and in the APA table note;
- none of the reporting routes may state that measurement bias, fairness,
  invariance, or an operational subgroup decision has been established.

## Case coverage

`mfrmr_review_dif_apa_reporting(include_refit = TRUE, include_gpcm = TRUE)`
returned status `ok` with 7 cases and 76 checks.

| Case | Rows | Columns | Section | Checks |
|---|---:|---:|---|---:|
| `categorical_two_level` | 3 | 26 | Differential functioning | 12/12 |
| `categorical_three_level` | 9 | 26 | Differential functioning | 11/11 |
| `continuous_covariate` | 3 | 24 | Differential functioning | 10/10 |
| `observed_score_mh` | 4 | 31 | Observed-score DIF screening | 11/11 |
| `interaction_screen` | 6 | 8 | Differential functioning | 10/10 |
| `refit_branch` | 3 | 26 | Differential functioning | 11/11 |
| `bounded_gpcm` | 3 | 26 | Differential functioning | 11/11 |

## Checks performed

Every case must satisfy:

- `dif_report(..., style = "apa")` returns an `mfrm_dif_report`;
- narrative text is non-empty;
- the APA table is non-empty;
- `apa_table(result)` has the same row count as `dif_report(result,
  style = "apa")$apa_table`;
- note and caption text are non-empty;
- the note contains screening and measurement-bias boundary language;
- positive overclaim phrases such as "bias was detected", "fairness was
  established", or "invariance was established" are absent.

Case-specific checks additionally require:

- two-level fitted DFF/DIF text names the DIF screening route and
  differential-functioning screening boundary;
- three-level fitted DFF/DIF produces at least three group-pair contrasts;
- continuous-covariate output names the continuous-covariate route and states
  that it is not categorical MH DIF;
- observed-score MH output names Mantel-Haenszel DIF, states that it is not
  fitted-MFRM, and carries `MFRMFitUsed = FALSE`;
- interaction output names cell-level residual screening;
- refit output exposes `ETS`, `ScaleLinkStatus`, and
  `PrimaryReportingEligible` columns so ETS availability and demotion remain
  visible;
- bounded-`GPCM` output has a non-empty `gpcm_boundary` and the APA note
  includes the bounded-GPCM caveat.

## Release-readiness integration

`inst/validation/release-readiness.R` calls
`mfrmr_release_readiness_dif_apa_reporting_status()`, which sources
`inst/validation/dif-apa-reporting-0.2.2.R` and requires:

- `DIFAPAReportingStatus = "ok"`;
- `ReportingGateOK = TRUE`;
- `FailedChecks = 0`.

The evidence-artifacts gate now reports `dif_apa_status=ok` and
`dif_apa_helper=TRUE` when the helper and this evidence route are present and
passing.

## Residual risks

This validation does not claim that a particular DIF procedure is the most
powerful or unbiased detector for every design. It checks the reporting layer.
Detection operating characteristics remain the responsibility of dedicated
simulation, external-comparison, and study-design review artifacts.
