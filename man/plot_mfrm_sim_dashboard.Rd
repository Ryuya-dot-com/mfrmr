\name{plot_mfrm_sim_dashboard}
\alias{plot_mfrm_sim_dashboard}
\title{Plot a multi-metric simulation dashboard}
\usage{
plot_mfrm_sim_dashboard(
  x,
  metrics = NULL,
  x_var = NULL,
  group_var = NULL,
  panel_var = NULL,
  facet = NULL,
  component = NULL,
  design_id = NULL,
  draw = TRUE,
  scales = c("free_y", "fixed"),
  ...
)
}
\arguments{
\item{x}{A simulation specification, grid summary, simulation evaluation object, or data frame.}

\item{metrics}{Character vector of numeric metric columns to plot. If omitted, a conservative default set is chosen from \code{\link[=list_mfrm_sim_metrics]{list_mfrm_sim_metrics()}}.}

\item{x_var}{Design or data column used for the horizontal axis. Defaults to \code{n_Rater}, \code{n_rater}, the first \code{n_*} column, or \code{design_id}.}

\item{group_var}{Optional design or data column used for grouped lines.}

\item{panel_var}{Optional design or data column used for panels in addition to metric panels.}

\item{facet}{Optional facet filter when the source table has a \code{Facet} column. The default uses \code{Rater} when present, otherwise the first non-person facet. Use \code{facet = "all"} to keep all facets.}

\item{component}{Optional component to plot. See \code{\link[=list_mfrm_sim_metrics]{list_mfrm_sim_metrics()}}.}

\item{design_id}{Optional design rows used when \code{x} is an arbitrary simulation specification.}

\item{draw}{Whether to draw a base R multi-panel plot.}

\item{scales}{Y-axis scaling. \code{"free_y"} gives each metric its own y-axis; \code{"fixed"} uses a common y-axis across metrics.}

\item{...}{Additional arguments passed to the base plotting call.}
}
\value{
Invisibly, an \code{mfrm_plot_data} object.
}
\description{
Plot a multi-metric simulation dashboard.
}
\details{
This dashboard separates two planning stages. Before fitting, arbitrary design-grid summaries can plot workload and connectivity metrics such as \code{MeanObsPerPerson}, \code{Observations}, and \code{MinPairCoverage}. After repeated fitting, evaluation objects can plot empirical performance metrics such as \code{MeanReliability}, \code{MeanSeparation}, \code{MeanSeverityRMSE}, \code{MeanUnderfitRate}, or \code{ConvergenceRate}.

The returned \code{mfrm_plot_data} payload contains a long-form data frame with \code{.metric}, \code{.value}, \code{.x}, \code{.group}, and \code{.panel} columns so users can build their own ggplot2, lattice, or spreadsheet visualizations.

In practice, useful dashboards usually combine one metric from each decision category:
\itemize{
\item response burden/connectivity: \code{Observations}, \code{MeanObsPerPerson}, \code{MinPairCoverage}, \code{CompletePairCoverageRate}
\item measurement precision: \code{MeanReliability}, \code{MeanSeparation}, \code{MeanStrata}
\item recovery error: \code{MeanSeverityRMSE}, \code{MeanSeverityBias}
\item fit and flag direction: \code{MeanUnderfitRate}, \code{MeanOverfitRate}, \code{MeanMnSqMisfitRate}
\item computational stability: \code{ConvergenceRate}, \code{MeanElapsedSec}
}
}
\examples{
spec <- build_mfrm_arbitrary_sim_spec(
  n_person = 20,
  facets = list(Rater = c(2, 4), Criteria = c(2, 3), Task = c(2, 4)),
  facets_per_person = list(Rater = c(1, 2), Task = 2),
  score_levels = 4
)
dash <- plot_mfrm_sim_dashboard(
  spec,
  metrics = c("MeanObsPerPerson", "MinPairCoverage"),
  x_var = "n_Rater",
  group_var = "n_Task",
  panel_var = "n_Criteria",
  draw = FALSE
)
head(dash$data$data)
}
\seealso{
\code{\link[=list_mfrm_sim_metrics]{list_mfrm_sim_metrics()}},
\code{\link[=plot_mfrm_sim_grid]{plot_mfrm_sim_grid()}},
\code{\link[=evaluate_mfrm_design]{evaluate_mfrm_design()}}
}
