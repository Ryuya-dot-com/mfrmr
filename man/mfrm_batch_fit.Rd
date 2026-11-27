\name{mfrm_batch_fit}
\alias{mfrm_batch_fit}
\title{Multi-Threaded C++ Batch MFRM Estimator for Monte Carlo and Bootstrap Studies}
\description{
Executes tens to thousands of Many-Facet model calibrations, person scorings, and fit diagnostics in parallel across native C++ \code{std::thread} workers without R interpreter or garbage-collection contention. Accepts either a shared template \code{data.frame} paired with a replicated \code{score_matrix} (\code{nrow(data) x R}) or a list of heterogeneous rating \code{data.frame}s.
}
\usage{
mfrm_batch_fit(
  data, person, facets, score = "score", score_matrix = NULL,
  model = c("RSM", "PCM", "GPCM"),
  method = c("MML", "JML", "JML_jeffreys", "CML"),
  step_facet = NULL, slope_facet = NULL, slope_reference = NULL,
  slope_type = c("full_predictor", "ability_only"),
  gpcm_mml_identification = c("free_population",
    "fixed_standard_normal", "unconstrained_slopes"),
  person_score = c("auto", "EAP", "WLE"),
  rating_min = NULL, rating_max = NULL, anchors = NULL,
  group_anchors = NULL, dummy_facets = NULL,
  population_formula = NULL, person_data = NULL, step_constraints = NULL,
  category_support = NULL, facet_formulas = NULL, facet_data = NULL,
  slope_prior_sd = NULL, quad_points = 31L,
  mml_integration = c("auto", "fixed", "adaptive"), xtreme = 0,
  whexact = FALSE, bias_facets = NULL, maxit = 400L, reltol = 1e-10,
  threads = 1L, return_fits = TRUE, weight = NULL,
  noncenter_facet = "Person", positive_facets = NULL,
  centering_scope = c("remainder", "facet"), person_id = NULL,
  population_sd = 1, facet_interactions = NULL,
  facet_shrinkage = c("none", "empirical_bayes", "laplace"),
  facet_prior_sd = NULL)
}
\arguments{
  \item{data}{A template \code{data.frame} (when \code{score_matrix} is supplied) or a list of \code{data.frame}s of observed ratings.}
  \item{person}{Character string naming the person identifier column.}
  \item{facets}{Character vector of non-person facet column names.}
  \item{score}{Character string naming the numeric rating column.}
  \item{score_matrix}{Optional integer/numeric matrix (\code{nrow(data) x R}) of
  replicated rating vectors sharing \code{data}'s complete Person and facet
  identifiers. Scores must be finite integers within the declared support.
  Each returned fit retains the ratings from its own column.}
  \item{model}{\code{"GMFRM"} is accepted as an alias for \code{"GPCM"}; fitted objects retain the code \code{"GPCM"}. Measurement model family (\code{"RSM"}, \code{"PCM"}, or \code{"GPCM"}).}
  \item{method}{Estimation method (\code{"MML"}, \code{"JML"}, \code{"JML_jeffreys"}, or \code{"CML"}).}
  \item{step_facet}{Facet owning thresholds when \code{model} is \code{"PCM"} or \code{"GPCM"}.}
  \item{slope_facet}{Facet(s) owning discrimination slopes when \code{model = "GPCM"}.}
  \item{slope_reference}{Reference slope facet constrained to geometric mean 1 in 2-family \code{GPCM}.}
  \item{slope_type}{GPCM parameterization: \code{"full_predictor"} or \code{"ability_only"}.}
  \item{gpcm_mml_identification}{Scale identification rule for GPCM MML estimation.}
  \item{person_score}{Primary person ability estimator (\code{"auto"}, \code{"EAP"}, or \code{"WLE"}).}
  \item{rating_min}{Minimum integer rubric score.}
  \item{rating_max}{Maximum integer rubric score.}
  \item{anchors}{Optional element anchor table.}
  \item{group_anchors}{Optional group-mean anchor table.}
  \item{dummy_facets}{Optional dummy facets fixed at 0.}
  \item{population_formula}{Optional latent-regression formula for \code{MML}.}
  \item{person_data}{Optional person covariate \code{data.frame} (or list of \code{data.frame}s).}
  \item{step_constraints}{Optional step-constraint declarations.}
  \item{category_support}{Optional per-level category support bounds.}
  \item{facet_formulas}{Optional explanatory facet covariate formulas.}
  \item{facet_data}{Optional covariate tables for explanatory facets.}
  \item{slope_prior_sd}{Optional log-normal prior SD regularizing GPCM log-slopes.}
  \item{quad_points}{Integer number of quadrature points, at least five, for \code{MML} (default \code{31L}).}
  \item{mml_integration}{Integration mode: \code{"auto"} (MML default), \code{"fixed"}, or \code{"adaptive"}. See \code{\link{fit_mfrm}} for the automatic refinement limits and tolerances.}
  \item{xtreme}{Extreme-score adjustment for \code{JML} (default \code{0}).}
  \item{whexact}{Logical flag for exact Wilson-Hilferty \code{ZSTD} (default \code{FALSE}).}
  \item{bias_facets}{Optional length-2 character vector for 2-way local bias.}
  \item{maxit}{Maximum optimization iterations (default \code{400L}).}
  \item{reltol}{Relative convergence tolerance (default \code{1e-10}).}
  \item{threads}{Number of C++ worker threads (default \code{1L}). When the CRAN check environment variable \code{_R_CHECK_LIMIT_CORES_} is enabled, requests are capped at two workers.}
  \item{return_fits}{Logical; if \code{TRUE}, returns the list of \code{mfrm_fit} objects; if \code{FALSE}, returns a compact per-replication summary \code{data.frame}.}
  \item{weight}{Optional column name of nonnegative observation weights.}
  \item{noncenter_facet}{Facet left uncentered to set the scale origin (default \code{"Person"}).}
  \item{positive_facets}{Optional character vector of facets oriented positively (\code{Sign = +1}).}
  \item{centering_scope}{Centering rule under partial anchors: \code{"remainder"} (default; unanchored elements sum to zero) or \code{"facet"} (all elements sum to zero).}
  \item{person_id}{Optional person identifier column name in \code{person_data}.}
  \item{population_sd}{Fixed normal population SD when \code{population_formula} is \code{NULL} (default \code{1}).}
  \item{facet_interactions}{Optional list of length-2 character vectors declaring joint zero-margin 2-way facet interactions.}
  \item{facet_shrinkage}{Facet regularization mode: \code{"none"} (default), \code{"empirical_bayes"}, or \code{"laplace"}.}
  \item{facet_prior_sd}{Optional prior SD for \code{facet_shrinkage}.}
}
\value{
A list of \code{mfrm_fit} objects (when \code{return_fits = TRUE}) or a \code{data.frame} of replication convergence, iteration counts, and log-likelihoods (when \code{return_fits = FALSE}), with attribute \code{"elapsed_sec"}.
}
\details{
The same rubric and anchor checks apply as in \code{\link{fit_mfrm}}.
CML requires unit observation weights on retained ratings and rejects Laplace
facet regularization. Nonfinite conditional likelihood solutions are marked
unavailable for inference. The compact output retains the readiness status.
Empirical Bayes shrinkage uses the final calibration after quadrature refinement.
}
\seealso{
\code{\link{fit_mfrm}}
}
\examples{
ratings <- load_mfrmr_data("example_core")
fit <- fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score", method = "CML")

# Simulate 4 parametric bootstrap replications from fitted category probabilities
probs <- fitted(fit, type = "probs")
cats <- as.integer(colnames(probs))
set.seed(123)
sim_mat <- replicate(4L, vapply(seq_len(nrow(probs)), function(i) {
  sample(cats, 1L, prob = probs[i, ])
}, integer(1)))

mfrm_batch_fit(
  ratings,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  score_matrix = sim_mat,
  method = "CML",
  rating_min = 1,
  rating_max = 4,
  threads = 1L,
  return_fits = FALSE
)
}
