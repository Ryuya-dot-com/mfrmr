\name{evaluate_mfrm_bias_detection}
\alias{evaluate_mfrm_bias_detection}
\alias{summary.mfrm_bias_detection}
\alias{plot.mfrm_bias_detection}
\alias{print.mfrm_bias_detection}
\alias{print.summary.mfrm_bias_detection}
\title{Evaluate arbitrary-facet interaction-bias screening}
\usage{
evaluate_mfrm_bias_detection(
  sim_spec,
  bias_targets,
  facet_pairs = NULL,
  design_id = 1,
  reps = 20,
  seed = NULL,
  alpha = 0.05,
  p_adjust = "holm",
  bias_abs_t = 2,
  bias_p_cut = alpha,
  fit_method = c("MML", "JML", "JMLE"),
  maxit = 100,
  quad_points = 21,
  bias_max_iter = 2,
  residual_pca = c("none", "overall", "facet", "both"),
  fit_args = list()
)
}
\arguments{
\item{sim_spec}{Output from \code{\link[=build_mfrm_arbitrary_sim_spec]{build_mfrm_arbitrary_sim_spec()}}.}

\item{bias_targets}{Data frame of known interaction targets. Use either direct facet columns plus \code{Effect}, or columns \code{Target}, \code{FacetA}, \code{LevelA}, \code{FacetB}, \code{LevelB}, and \code{Effect}.}

\item{facet_pairs}{Optional list of pairwise facet vectors to evaluate. Target pairs are always included.}

\item{design_id}{Design rows to evaluate. Use \code{NULL} for all rows in the specification grid.}

\item{reps}{Replications per design.}

\item{seed}{Optional random seed.}

\item{alpha}{Screening alpha used for adjusted p values.}

\item{p_adjust}{Multiplicity adjustment passed to \code{\link[stats:p.adjust]{stats::p.adjust()}}.}

\item{bias_abs_t}{Minimum absolute screening t value.}

\item{bias_p_cut}{Optional p-value cutoff. Defaults to \code{alpha}.}

\item{fit_method}{Estimation method passed to \code{\link[=fit_mfrm]{fit_mfrm()}}.}

\item{maxit}{Maximum iterations passed to \code{\link[=fit_mfrm]{fit_mfrm()}}.}

\item{quad_points}{Quadrature points passed to \code{\link[=fit_mfrm]{fit_mfrm()}} when applicable.}

\item{bias_max_iter}{Maximum iterations passed to \code{\link[=estimate_bias]{estimate_bias()}}.}

\item{residual_pca}{Residual PCA mode passed to \code{\link[=diagnose_mfrm]{diagnose_mfrm()}}.}

\item{fit_args}{Optional additional arguments passed to \code{\link[=fit_mfrm]{fit_mfrm()}}. Core arguments \code{data}, \code{person}, \code{facets}, and \code{score} are controlled by this evaluator.}
}
\value{
An object of class \code{mfrm_bias_detection} with design grid, per-target results, pair-level summaries, run-level fit summaries, fitted estimates, reliability tables, fit-statistic tables, and settings. These table components are ordinary data frames and can be saved with \code{\link[utils:write.table]{utils::write.csv()}} or retrieved with \code{as.data.frame(x, component = "estimates")}.
}
\description{
Evaluate arbitrary-facet interaction-bias screening.
}
\details{
This helper is a simulation-based screening sensitivity check. It does not convert \code{\link[=estimate_bias]{estimate_bias()}} into a formal inferential test.

\code{BiasScreenRate} is the fraction of replications in which the injected target cell passed the selected adjusted-p and absolute-t screening rules. \code{BiasScreenFalsePositiveRate} is computed from non-target cells in the same pairwise bias table.

The \code{Effect} value is added to the RSM linear predictor for rows matching the target cell. Positive effects increase expected scores; negative effects decrease expected scores after accounting for person and facet main effects.

When \code{sim_spec} was created by \code{\link[=extract_mfrm_arbitrary_sim_spec]{extract_mfrm_arbitrary_sim_spec()}}, the evaluator carries forward the fitted rating range and retained \code{Weight} column by default. Pass an explicit \code{fit_args$weight} value if a sensitivity run should change that refitting convention.

The evaluator also stores fitted measure estimates, reliability coefficients, and fit statistics for successful replications. Use \code{as.data.frame(eval, component = "estimates")}, \code{as.data.frame(eval, component = "reliability")}, or \code{as.data.frame(eval, component = "fit_summary")} for CSV export or custom visualization.
}
\examples{
\dontrun{
spec <- build_mfrm_arbitrary_sim_spec(
  n_person = 16,
  facets = c(Rater = 3, Criteria = 2, Task = 3),
  facets_per_person = c(Rater = 2, Task = 2),
  score_levels = 4
)
targets <- data.frame(Rater = "Rater03", Task = "Task03", Effect = -0.7)
# Repeated simulations estimate how often this injected interaction is
# recovered by the bias-screening workflow.
eval <- evaluate_mfrm_bias_detection(
  spec,
  bias_targets = targets,
  reps = 10,
  seed = 1
)
summary(eval)
plot(eval, metric = "screen_rate")
plot(eval, metric = "reliability", facet = "Rater")
head(as.data.frame(eval, component = "estimates"))
head(as.data.frame(eval, component = "reliability"))
}
}
\seealso{
\code{\link[=estimate_bias]{estimate_bias()}},
\code{\link[=extract_mfrm_arbitrary_sim_spec]{extract_mfrm_arbitrary_sim_spec()}},
\code{\link[=simulate_mfrm_arbitrary_data]{simulate_mfrm_arbitrary_data()}}
}
