#' @section Reporting, tables, and saving routes:
#' | Need | Primary route |
#' | --- | --- |
#' | Triage an ordinary RSM/PCM analysis | [mfrm_results()], then `summary(res)$triage` and `$next_actions` |
#' | Build an analyst report or single-rater feedback sheet | [mfrm_report()] (`style = "rater"` requires `facet` and `rater`) |
#' | Draft manuscript prose and formatted tables | [build_apa_outputs()], [build_summary_table_bundle()], [apa_table()] |
#' | Check reporting gaps or uncertainty readiness | `mfrm_report(fit, type = "checklist")` and `type = "precision"` |
#' | Preserve complete R objects, CSVs, or replay archives | [base::saveRDS()], [export_mfrm_tables()], [export_mfrm_results()], [export_mfrm_bundle()] |
#'
#' Reporting helpers organize stored evidence (informed by JARS-Quant;
#' Appelbaum et al., 2018, \doi{10.1037/amp0000191}); `DraftReady`,
#' `ReadyForAPA`, and `ClaimStrength` do not certify substantive validity or
#' replace study-design, recruitment, missingness, and multiplicity disclosures.
#' Retain `NA`/status/reason columns rather than replacing unavailable outputs
#' with zero. See `vignette("mfrmr-reporting-and-apa", package = "mfrmr")` for
#' a complete fit-to-manuscript walkthrough.
#'
#' @aliases mfrmr_reporting_and_apa
#' @rdname mfrmr_output_guide
#' @name mfrmr_reporting_and_apa
NULL
