\name{summarize_mfrm_sim_design}
\alias{summarize_mfrm_sim_design}
\alias{print.mfrm_sim_design_summary}
\title{Summarize an arbitrary-facet simulation design}
\usage{
summarize_mfrm_sim_design(x, design_id = 1, design = NULL)
}
\arguments{
\item{x}{Simulated data from \code{\link[=simulate_mfrm_arbitrary_data]{simulate_mfrm_arbitrary_data()}} or a specification from \code{\link[=build_mfrm_arbitrary_sim_spec]{build_mfrm_arbitrary_sim_spec()}}.}

\item{design_id}{Design row used when \code{x} is a specification.}

\item{design}{Optional one-row design override used when \code{x} is a specification.}
}
\value{
A list of class \code{mfrm_sim_design_summary} with overview, facet-load, person-load, pair-coverage, and assignment tables.
}
\description{
Summarize an arbitrary-facet simulation design.
}
\details{
The summary reports how many observations each facet level receives, how many levels of each facet are assigned to each person, and how completely each facet pair is covered. This is intended to make incomplete crossing visible before fitting or running repeated simulations.
}
\examples{
spec <- build_mfrm_arbitrary_sim_spec(
  n_person = 10,
  facets = c(Rater = 3, Criteria = 2, Task = 2),
  facets_per_person = c(Rater = 2)
)
summarize_mfrm_sim_design(spec)
}
\seealso{
\code{\link[=plot_mfrm_sim_design]{plot_mfrm_sim_design()}},
\code{\link[=summarize_mfrm_sim_grid]{summarize_mfrm_sim_grid()}},
\code{\link[=simulate_mfrm_arbitrary_data]{simulate_mfrm_arbitrary_data()}}
}
