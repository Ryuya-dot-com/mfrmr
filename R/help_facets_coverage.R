#' @section Guide topics (`positioning`, `terms`, `visuals`, `coverage`):
#' - `facets_guide("positioning")`: scope and reporting notes comparing native
#'   `mfrmr` estimation, external FACETS table imports, and supported models
#'   (`Topic`, `Position`, `RecommendedWording`, `PrimaryRoute`).
#' - `facets_guide("terms")`: crosswalk from FACETS terminology to `mfrmr`
#'   functions and columns (`FACETSTerm`, `mfrmrTerm`, `mfrmrRoute`,
#'   `Relationship`, `Boundary`).
#' - `facets_guide("visuals")`: closest `mfrmr` plots and tables for FACETS
#'   displays, distinguishing the FACETS Table 6 asterisk ruler from
#'   uncertainty-aware native Wright maps.
#' - `facets_guide("coverage", status = ...)`: feature matrix across FACETS 4.5.0
#'   Tables 1--14, output files, and graph-menu curves (`implemented`,
#'   `supported_with_caveat`, `partial`, `not_implemented`, `not_targeted`),
#'   reporting `SurfaceCoverage`, `StatisticalContract`, `ValidationEvidence`,
#'   and `OperationalStatus` columns.
#'
#' @aliases facets_positioning_guide facets_term_crosswalk
#' @aliases facets_visual_contract facets_feature_coverage
#' @rdname facets_guide
#' @name facets_positioning_guide
NULL

.facets_feature_coverage <- function(status = c("all", "implemented",
                                               "supported_with_caveat",
                                               "partial", "not_implemented",
                                               "not_targeted")) {
  status <- match.arg(status)
  out <- .mfrmr_table_facets_feature_coverage_all
  if (identical(status, "all")) return(out)
  out[out$Status == status, , drop = FALSE]
}
