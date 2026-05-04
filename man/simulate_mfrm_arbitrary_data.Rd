\name{simulate_mfrm_arbitrary_data}
\alias{simulate_mfrm_arbitrary_data}
\title{Simulate arbitrary-facet RSM data}
\usage{
simulate_mfrm_arbitrary_data(
  sim_spec,
  design_id = 1,
  design = NULL,
  seed = NULL,
  dif_effects = NULL,
  interaction_effects = NULL
)
}
\arguments{
\item{sim_spec}{Output from \code{\link[=build_mfrm_arbitrary_sim_spec]{build_mfrm_arbitrary_sim_spec()}}.}

\item{design_id}{Design row to use from \code{sim_spec$design_grid}. Use one value for data generation.}

\item{design}{Optional one-row design override with the same columns as \code{sim_spec$design_grid}.}

\item{seed}{Optional random seed.}

\item{dif_effects}{Optional DIF effect table. The table must include \code{Effect}, \code{Group}, and at least one of \code{Person} or a simulated facet column.}

\item{interaction_effects}{Optional interaction effect table. The table must include \code{Effect} and at least one of \code{Person} or a simulated facet column.}
}
\value{
A long-format \code{data.frame} with \code{Study}, \code{Person}, arbitrary facet columns, and \code{Score}. Attributes \code{mfrm_truth} and \code{mfrm_simulation_spec} store the generating values and reusable design metadata.
}
\description{
Simulate arbitrary-facet RSM data.
}
\details{
The arbitrary-facet generator samples
\deqn{\eta_{n...} = \theta_n - \sum_f \delta_{f,\ell} + e_{n...},}
then applies row-matched \code{dif_effects} and \code{interaction_effects} as logit shifts before sampling ordered categories under a common-threshold RSM:
\deqn{P(X = k) \propto \exp(k\eta - \sum_{h=1}^{k}\tau_h).}

Higher simulated facet effects behave as more severe or more difficult levels, matching the sign convention used by \code{\link[=fit_mfrm]{fit_mfrm()}}.

Specifications created by \code{\link[=extract_mfrm_arbitrary_sim_spec]{extract_mfrm_arbitrary_sim_spec()}} may reuse a fitted response skeleton, fitted person/facet estimates, retained weights, and the fitted rating range rather than generated labels and parameters.

Category labels are generated as \code{1:score_levels} for design-first specifications. For fit-derived specifications, the fitted \code{rating_min} and \code{rating_max} are reused, so scales such as \code{0:3} remain on their original score metric.
}
\examples{
spec <- build_mfrm_arbitrary_sim_spec(
  n_person = 12,
  facets = c(Rater = 3, Criteria = 2, Task = 3),
  facets_per_person = c(Rater = 2, Task = 2),
  score_levels = 4
)
sim <- simulate_mfrm_arbitrary_data(spec, seed = 1)
head(sim)
attr(sim, "mfrm_truth")$design
}
\seealso{
\code{\link[=build_mfrm_arbitrary_sim_spec]{build_mfrm_arbitrary_sim_spec()}},
\code{\link[=extract_mfrm_arbitrary_sim_spec]{extract_mfrm_arbitrary_sim_spec()}},
\code{\link[=fit_mfrm]{fit_mfrm()}},
\code{\link[=summarize_mfrm_sim_design]{summarize_mfrm_sim_design()}}
}
