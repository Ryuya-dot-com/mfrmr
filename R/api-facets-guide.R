#' Choose a FACETS comparison guide
#'
#' One entry point for terminology, feature coverage, visual correspondence,
#' and fit-statistic interpretation. These guides describe how to use and
#' compare outputs; they do not establish numerical equivalence with FACETS.
#'
#' @param topic Guide to return: `"positioning"` explains the relationship
#'   between the packages; `"terms"` maps terminology; `"visuals"` maps plots;
#'   `"coverage"` lists supported and unavailable outputs; `"fit_df"` explains
#'   degrees of freedom and ZSTD comparisons.
#' @param ... Topic-specific controls. For `"coverage"`, `status = "all"`
#'   can filter to `"implemented"`, `"supported_with_caveat"`, `"partial"`,
#'   `"not_implemented"`, or `"not_targeted"`. For `"fit_df"`,
#'   `include_references = FALSE` omits the reference table. Other topics
#'   accept no extra arguments. Unsupported arguments raise an error.
#' @return A data frame for positioning, terms, visuals, or coverage. The
#'   fit-df guide is an `mfrm_facets_fit_df_guide` bundle with `summary`,
#'   `formula_guide`, `column_guide`, `decision_guide`, `interpretation_guide`,
#'   `references`, and `settings`; its existing summary/print methods apply.
#' @details The full topic descriptions are available in
#'   [facets_positioning_guide], [facets_term_crosswalk],
#'   [facets_visual_contract], [facets_feature_coverage], and
#'   [facets_fit_df_guide]. All topics are descriptive and require no fitting.
#' @seealso [read_facets_results()], [facets_fit_review()],
#'   [mfrmr_api_migration_030]
#' @examples
#' facets_guide("terms")
#' facets_guide("coverage", status = "partial")
#' facets_guide("fit_df")$decision_guide
#' @export
facets_guide <- function(topic = c("positioning", "terms", "visuals", "coverage", "fit_df"), ...) {
  topic <- match.arg(topic)
  if (topic == "coverage") return(.facets_feature_coverage(...))
  if (topic == "fit_df") return(.facets_fit_df_guide(...))
  if (length(list(...))) stop("This guide topic accepts no additional arguments.", call. = FALSE)
  switch(topic,
    positioning = .mfrmr_table_facets_positioning_guide_data,
    terms = .mfrmr_table_facets_term_crosswalk_data,
    visuals = .mfrmr_table_facets_visual_contract_data)
}
