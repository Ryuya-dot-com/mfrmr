\name{summarize_mfrm_sim_grid}
\alias{summarize_mfrm_sim_grid}
\alias{print.mfrm_sim_grid_summary}
\title{Summarize all rows in an arbitrary-facet simulation design grid}
\usage{
summarize_mfrm_sim_grid(sim_spec, design_id = NULL)
}
\arguments{
\item{sim_spec}{Output from \code{\link[=build_mfrm_arbitrary_sim_spec]{build_mfrm_arbitrary_sim_spec()}} or \code{\link[=extract_mfrm_arbitrary_sim_spec]{extract_mfrm_arbitrary_sim_spec()}}.}

\item{design_id}{Optional design rows to summarize. Use \code{NULL} to summarize every row in \code{sim_spec$design_grid}.}
}
\value{
A data frame of class \code{mfrm_sim_grid_summary}.
}
\description{
Summarize all rows in an arbitrary-facet simulation design grid.
}
\details{
This grid summary is the multi-design companion to \code{\link[=summarize_mfrm_sim_design]{summarize_mfrm_sim_design()}}. It is useful when a planning grid varies \code{n_Rater} together with other facet counts such as \code{n_Task}, \code{n_Criteria}, or assignment counts such as \code{Rater_per_person}.

The returned table keeps the original design-grid columns and adds workload and coverage metrics. \code{MeanObsPerPerson} describes person-level rating load; \code{MinPairCoverage} and \code{MeanPairCoverage} summarize how completely each pair of non-person facets is crossed within the generated skeleton.
}
\examples{
spec <- build_mfrm_arbitrary_sim_spec(
  n_person = 20,
  facets = list(Rater = c(2, 4), Criteria = c(2, 3), Task = c(2, 4)),
  facets_per_person = list(Rater = c(1, 2), Task = 2),
  score_levels = 4
)
grid <- summarize_mfrm_sim_grid(spec)
grid[, c("design_id", "n_Rater", "n_Criteria", "n_Task", "Observations")]
}
\seealso{
\code{\link[=plot_mfrm_sim_grid]{plot_mfrm_sim_grid()}},
\code{\link[=plot_mfrm_sim_dashboard]{plot_mfrm_sim_dashboard()}},
\code{\link[=list_mfrm_sim_metrics]{list_mfrm_sim_metrics()}},
\code{\link[=summarize_mfrm_sim_design]{summarize_mfrm_sim_design()}}
}
