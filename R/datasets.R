#' Simulated MFRM datasets based on Eckes and Jin (2021)
#'
#' Synthetic many-facet rating datasets in long format.
#' All datasets include one row per observed rating.
#'
#' Available data objects:
#' - `mfrmr_example_core`
#' - `mfrmr_example_bias`
#' - `ej2021_study1`
#' - `ej2021_study2`
#' - `ej2021_combined`
#' - `ej2021_study1_itercal`
#' - `ej2021_study2_itercal`
#' - `ej2021_combined_itercal`
#'
#' @format A data.frame with 5 columns:
#' \describe{
#'   \item{Study}{Study label (`"Study1"` or `"Study2"`).}
#'   \item{Person}{Person/respondent identifier.}
#'   \item{Rater}{Rater identifier.}
#'   \item{Criterion}{Criterion facet label.}
#'   \item{Score}{Observed category score.}
#' }
#' @source Simulated for this package with design settings informed by Eckes
#' and Jin (2021). The Eckes and Jin (2021) Method section reports the
#' following design parameters that motivated the synthetic versions
#' shipped here: Study 1 had 307 examinees (149 males, 158 females), 18
#' raters (4 males, 14 females), and 3 criteria (global impression, task
#' fulfillment, linguistic realization) on a 4-category rating scale (TDN
#' levels rescored 1-4); Study 2 had 206 examinees (66 males, 140 females),
#' 12 raters (1 male, 11 females), and 9 criteria on the same 4-category
#' scale. The packaged datasets reproduce these
#' (examinees, raters, criteria, categories) shapes but use simulated
#' responses, so they are not the real TestDaF data.
#'
#' @references
#' Eckes, T., & Jin, K.-Y. (2021). Measuring rater centrality effects in
#' writing assessment: A Bayesian facets modeling approach.
#' \emph{Psychological Test and Assessment Modeling, 63}(1), 65--94.
#' \url{https://www.gast.de/fileadmin/gast.de/GAST/4_PDF/2-Forschung-Entwicklung/Publikationen/Eckes-u-Jin-PTAM-2021-1.pdf}
#' @details
#' Naming convention:
#' - `study1` / `study2`: separate simulation studies
#' - `combined`: row-bind of study1 and study2
#' - `_itercal`: iterative-calibration variant
#'
#' Use [load_mfrmr_data()] for programmatic selection by key.
#'
#' @section Source boundary:
#' These are Eckes-and-Jin-inspired synthetic datasets, not redistributed
#' TestDaF operational records. The paper informs the design shape and
#' rating-scale context. The response rows, generated scores, baseline /
#' iterative-calibration variants, and any fitted `mfrmr` estimates are
#' package-generated artifacts. Do not cite these objects as reproductions of
#' the Eckes and Jin empirical analyses or of their Bayesian FM-SC estimates.
#'
#' @section Data dimensions:
#' \tabular{lrrrr}{
#'   \strong{Dataset} \tab \strong{Rows} \tab \strong{Persons} \tab \strong{Raters} \tab \strong{Criteria} \cr
#'   study1 \tab 1842 \tab 307 \tab 18 \tab 3 \cr
#'   study2 \tab 3287 \tab 206 \tab 12 \tab 9 \cr
#'   combined \tab 5129 \tab 307 \tab 18 \tab 12 \cr
#'   study1_itercal \tab 1842 \tab 307 \tab 18 \tab 3 \cr
#'   study2_itercal \tab 3341 \tab 206 \tab 12 \tab 9 \cr
#'   combined_itercal \tab 5183 \tab 307 \tab 18 \tab 12
#' }
#' Score range: 1--4 (four-category rating scale).
#'
#' @section Simulation design:
#' Person ability is drawn from N(0, 1).  Rater severity effects span
#' approximately -0.5 to +0.5 logits.  Criterion difficulty effects span
#' approximately -0.3 to +0.3 logits.  Scores are generated from the
#' resulting linear predictor plus Gaussian noise, then discretized into
#' four categories.  The `_itercal` variants use a second iteration of
#' calibrated rater severity parameters.
#'
#' @section Interpreting output:
#' Each dataset is already in long format and can be passed directly to
#' [fit_mfrm()] after confirming column-role mapping.
#'
#' @section Typical workflow:
#' 1. Inspect available datasets with [list_mfrmr_data()].
#' 2. Load one dataset using [load_mfrmr_data()].
#' 3. Fit and diagnose with [fit_mfrm()] and [diagnose_mfrm()].
#'
#' @examples
#' data("ej2021_study1", package = "mfrmr")
#' head(ej2021_study1)
#' table(ej2021_study1$Study)
#' @name ej2021_data
#' @aliases ej2021_study1 ej2021_study2 ej2021_combined
#' @aliases ej2021_study1_itercal ej2021_study2_itercal ej2021_combined_itercal
NULL

#' Purpose-built example datasets for package help pages
#'
#' Compact synthetic many-facet datasets designed for documentation examples.
#' Both datasets are large enough to avoid tiny-sample toy behavior while
#' remaining fast in `R CMD check` examples.
#' Use them for smoke checks and route demonstrations. For interpretation,
#' report writing, or user-facing examples, prefer the larger Study 1 / Study 2
#' datasets or the user's own data.
#'
#' Available data objects:
#' - `mfrmr_example_core`
#' - `mfrmr_example_bias`
#'
#' @format A data.frame with 6 columns:
#' \describe{
#'   \item{Study}{Example dataset label (`"ExampleCore"` or `"ExampleBias"`).}
#'   \item{Person}{Person/respondent identifier.}
#'   \item{Rater}{Rater identifier.}
#'   \item{Criterion}{Criterion facet label.}
#'   \item{Score}{Observed category score on a four-category scale (`1`--`4`).}
#'   \item{Group}{Balanced grouping variable used in DFF/DIF examples (`"A"` / `"B"`).}
#' }
#' @source Synthetic documentation data generated from rating-scale Rasch facet
#'   designs with fixed seeds in `data-raw/make-example-data.R`. These compact
#'   examples are not derived from a paper dataset.
#' @details
#' `mfrmr_example_core` is generated from a single latent trait plus rater and
#' criterion main effects, making it suitable for general fitting, plotting, and
#' reporting examples.
#'
#' `mfrmr_example_bias` starts from the same basic design but adds:
#' - a known `Group x Criterion` effect (`Group B` is advantaged on `Language`)
#' - a known `Rater x Criterion` interaction (`R04 x Accuracy`)
#'
#' This lets differential-functioning and bias-analysis help pages demonstrate non-null findings.
#'
#' @section Source boundary:
#' `mfrmr_example_core` and `mfrmr_example_bias` are package-authored fixtures.
#' They are useful for smoke checks, examples, and route demonstrations, but
#' they are not empirical study data and should not be used as evidence for a
#' substantive rater, criterion, or group claim.
#'
#' @section Data dimensions:
#' \tabular{lrrrrr}{
#'   \strong{Dataset} \tab \strong{Rows} \tab \strong{Persons} \tab \strong{Raters} \tab \strong{Criteria} \tab \strong{Groups} \cr
#'   example_core \tab 768 \tab 48 \tab 4 \tab 4 \tab 2 \cr
#'   example_bias \tab 384 \tab 48 \tab 4 \tab 4 \tab 2
#' }
#'
#' @section Suggested usage:
#' - Use `mfrmr_example_core` for fitting, diagnostics, design-weighted precision curves,
#'   and generic plots/reports.
#' - Use `mfrmr_example_bias` for [analyze_dff()], [analyze_dif()], [dif_interaction_table()],
#'   [plot_dif_heatmap()], and [estimate_bias()].
#'
#' Both objects can be loaded either with [load_mfrmr_data()] or directly via
#' `data("mfrmr_example_core", package = "mfrmr")` /
#' `data("mfrmr_example_bias", package = "mfrmr")`.
#'
#' @examples
#' data("mfrmr_example_core", package = "mfrmr")
#' table(mfrmr_example_core$Score)
#' table(mfrmr_example_core$Group)
#' @name mfrmr_example_data
#' @aliases mfrmr_example_core mfrmr_example_bias
NULL

#' List packaged simulation datasets
#'
#' @return Character vector of dataset keys accepted by [load_mfrmr_data()].
#' @details
#' Use this helper when you want to select packaged data programmatically
#' (e.g., inside scripts, loops, or shiny/streamlit wrappers).
#'
#' Typical pattern:
#' 1. call `list_mfrmr_data()` to see available keys.
#' 2. pass one key to [load_mfrmr_data()].
#'
#' @section Interpreting output:
#' Returned values are canonical dataset keys accepted by [load_mfrmr_data()].
#'
#' @section Typical workflow:
#' 1. Capture keys in a script (`keys <- list_mfrmr_data()`).
#' 2. Select one key by index or name.
#' 3. Load data via [load_mfrmr_data()] and continue analysis.
#'
#' @seealso [load_mfrmr_data()], [ej2021_data]
#' @examples
#' keys <- list_mfrmr_data()
#' keys
#' d <- load_mfrmr_data(keys[1])
#' head(d)
#' @export
list_mfrmr_data <- function() {
  c(
    "example_core",
    "example_bias",
    "study1",
    "study2",
    "combined",
    "study1_itercal",
    "study2_itercal",
    "combined_itercal"
  )
}

#' Load a packaged simulation dataset
#'
#' @param name Dataset key. One of values from [list_mfrmr_data()].
#'
#' @return A data.frame in long format.
#' @details
#' `load_mfrmr_data("<key>")` is the canonical loader for the packaged
#' datasets and the entry point used across the package help and
#' vignettes. The equivalent base-R alternative
#' `data("mfrmr_<key>", package = "mfrmr")` remains available for users
#' who prefer the full `data()` spelling; both paths return identical
#' long-format data frames and are supported long-term.
#'
#' All returned datasets include the core long-format columns
#' `Study`, `Person`, `Rater`, `Criterion`, and `Score`.
#' Some datasets, such as the packaged documentation examples, also include
#' auxiliary variables like `Group` for DIF/bias demonstrations.
#'
#' The `example_*` datasets are compact smoke-test fixtures for help pages and
#' automated checks. They are not intended to carry substantive conclusions.
#' They are not tied to a source paper. The `study*` datasets are larger
#' Eckes-and-Jin-inspired synthetic datasets; they borrow design dimensions
#' from the paper but do not contain original TestDaF rows. Use `study1`,
#' `study2`, or user data for realistic end-to-end interpretation.
#'
#' @section Interpreting output:
#' The return value is a plain long-format `data.frame`, ready for direct use
#' in [fit_mfrm()] without additional reshaping.
#'
#' @section Typical workflow:
#' 1. list valid names with [list_mfrmr_data()].
#' 2. load one dataset key with `load_mfrmr_data(name)`.
#' 3. fit a model with [fit_mfrm()] and inspect with `summary()` / `plot()`.
#'
#' @seealso [list_mfrmr_data()], [ej2021_data]
#' @examples
#' data("mfrmr_example_core", package = "mfrmr")
#' head(mfrmr_example_core)
#'
#' d <- load_mfrmr_data("example_core")
#' fit <- fit_mfrm(
#'   data = d,
#'   person = "Person",
#'   facets = c("Rater", "Criterion"),
#'   score = "Score",
#'   method = "JML",
#'   maxit = 30
#' )
#' summary(fit)
#' @export
load_mfrmr_data <- function(name = c(
                            "example_core",
                            "example_bias",
                            "study1",
                            "study2",
                            "combined",
                            "study1_itercal",
                            "study2_itercal",
                            "combined_itercal"
                          )) {
  key <- match.arg(tolower(name), choices = list_mfrmr_data())

  obj_name <- switch(
    key,
    example_core = "mfrmr_example_core",
    example_bias = "mfrmr_example_bias",
    study1 = "ej2021_study1",
    study2 = "ej2021_study2",
    combined = "ej2021_combined",
    study1_itercal = "ej2021_study1_itercal",
    study2_itercal = "ej2021_study2_itercal",
    combined_itercal = "ej2021_combined_itercal"
  )

  utils::data(list = obj_name, package = "mfrmr", envir = environment())
  get(obj_name, envir = environment(), inherits = FALSE)
}
