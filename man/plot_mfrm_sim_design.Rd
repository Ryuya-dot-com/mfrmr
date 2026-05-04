\name{plot_mfrm_sim_design}
\alias{plot_mfrm_sim_design}
\title{Plot arbitrary-facet simulation design diagnostics}
\usage{
plot_mfrm_sim_design(
  x,
  type = c("load", "person_load", "pair_coverage"),
  facet = NULL,
  pair = NULL,
  draw = TRUE,
  ...
)
}
\arguments{
\item{x}{Output from \code{\link[=summarize_mfrm_sim_design]{summarize_mfrm_sim_design()}}, simulated data, or an arbitrary simulation specification.}

\item{type}{Plot payload type: facet-level load, person-level load, or pairwise coverage.}

\item{facet}{Optional facet filter for \code{type = "load"}.}

\item{pair}{Optional two-facet character vector for \code{type = "pair_coverage"}.}

\item{draw}{Whether to draw a base R plot.}

\item{...}{Reserved for future extensions.}
}
\value{
Invisibly, an \code{mfrm_plot_data} object.
}
\description{
Plot arbitrary-facet simulation design diagnostics.
}
\examples{
spec <- build_mfrm_arbitrary_sim_spec(
  n_person = 10,
  facets = c(Rater = 3, Criteria = 2, Task = 2),
  facets_per_person = c(Rater = 2)
)
plot_mfrm_sim_design(spec, draw = FALSE)
}
\seealso{
\code{\link[=summarize_mfrm_sim_design]{summarize_mfrm_sim_design()}},
\code{\link[=plot_mfrm_sim_grid]{plot_mfrm_sim_grid()}}
}
