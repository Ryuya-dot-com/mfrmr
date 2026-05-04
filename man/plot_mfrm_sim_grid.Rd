\name{plot_mfrm_sim_grid}
\alias{plot_mfrm_sim_grid}
\title{Plot arbitrary-facet simulation design grid tradeoffs}
\usage{
plot_mfrm_sim_grid(
  x,
  x_var = NULL,
  metric = c("Observations", "MeanObsPerPerson", "MinPairCoverage",
    "MeanPairCoverage", "CompletePairCoverageRate", "MinFacetPersonShare"),
  group_var = NULL,
  panel_var = NULL,
  design_id = NULL,
  draw = TRUE,
  ...
)
}
\arguments{
\item{x}{Output from \code{\link[=summarize_mfrm_sim_grid]{summarize_mfrm_sim_grid()}} or an arbitrary simulation specification with a design grid.}

\item{x_var}{Design-grid column for the horizontal axis. Defaults to \code{n_Rater} when available, otherwise the first \code{n_*} facet-count column.}

\item{metric}{Grid metric to plot.}

\item{group_var}{Optional design-grid column used to draw separate lines or point groups, such as \code{n_Task}.}

\item{panel_var}{Optional design-grid column used to split the returned payload, and the base plot when \code{draw = TRUE}, into panels.}

\item{design_id}{Optional design rows to summarize when \code{x} is a specification.}

\item{draw}{Whether to draw a base R plot.}

\item{...}{Reserved for future extensions.}
}
\value{
Invisibly, an \code{mfrm_plot_data} object. The payload contains the full grid summary and a plotting table with \code{.x}, \code{.y}, \code{.group}, and \code{.panel} columns for custom graphics.
}
\description{
Plot arbitrary-facet simulation design grid tradeoffs.
}
\details{
Use this function for planning questions where one facet count changes together with other facet counts. For example, set \code{x_var = "n_Rater"}, \code{group_var = "n_Task"}, and \code{panel_var = "n_Criteria"} to inspect whether adding raters increases person workload, improves pair coverage, or simply creates a larger response burden under different task/criteria choices.
}
\examples{
spec <- build_mfrm_arbitrary_sim_spec(
  n_person = 20,
  facets = list(Rater = c(2, 4), Criteria = c(2, 3), Task = c(2, 4)),
  facets_per_person = list(Rater = c(1, 2), Task = 2),
  score_levels = 4
)
plot_mfrm_sim_grid(
  spec,
  x_var = "n_Rater",
  metric = "Observations",
  group_var = "n_Task",
  panel_var = "n_Criteria",
  draw = FALSE
)
}
\seealso{
\code{\link[=summarize_mfrm_sim_grid]{summarize_mfrm_sim_grid()}},
\code{\link[=plot_mfrm_sim_dashboard]{plot_mfrm_sim_dashboard()}},
\code{\link[=list_mfrm_sim_metrics]{list_mfrm_sim_metrics()}},
\code{\link[=plot_mfrm_sim_design]{plot_mfrm_sim_design()}}
}
