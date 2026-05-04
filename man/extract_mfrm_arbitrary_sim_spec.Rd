\name{extract_mfrm_arbitrary_sim_spec}
\alias{extract_mfrm_arbitrary_sim_spec}
\title{Extract an arbitrary-facet simulation specification from a fitted model}
\usage{
extract_mfrm_arbitrary_sim_spec(
  fit,
  data = NULL,
  assignment = c("skeleton", "balanced"),
  parameter_source = c("estimates", "resampled"),
  facets_per_person = NULL,
  group = NULL,
  include_weights = TRUE,
  noise_sd = 0,
  dif_effects = NULL,
  interaction_effects = NULL
)
}
\arguments{
\item{fit}{An \code{mfrm_fit} object returned by \code{\link[=fit_mfrm]{fit_mfrm()}}.}

\item{data}{Optional original long-format data. When supplied with \code{group}, person-level group labels are carried into the simulation skeleton. The fitted model's retained analysis skeleton is otherwise used.}

\item{assignment}{Simulation assignment mode. \code{"skeleton"} reuses the fitted response skeleton exactly. \code{"balanced"} keeps the fitted facet levels and estimated parameters but rebuilds a deterministic rotating design using \code{facets_per_person}.}

\item{parameter_source}{Parameter source for simulated truth. \code{"estimates"} uses the fitted person, facet, and RSM threshold estimates directly. \code{"resampled"} samples fitted person/facet estimates with replacement from their empirical support.}

\item{facets_per_person}{Optional named assignment counts used when \code{assignment = "balanced"}. If omitted, the median number of observed levels per person is derived from the fitted skeleton for each facet.}

\item{group}{Optional group column in \code{data} to carry into the skeleton.}

\item{include_weights}{Whether the fitted analysis weights should be carried into skeleton simulations.}

\item{noise_sd}{Optional observation-level noise added during simulation.}

\item{dif_effects}{Optional DIF effect table passed through to the resulting specification.}

\item{interaction_effects}{Optional interaction effect table passed through to the resulting specification.}
}
\value{
An object of class \code{mfrm_arbitrary_sim_spec}.
}
\description{
Extract an arbitrary-facet simulation specification from a fitted model.
}
\details{
This helper connects the model a researcher has already estimated to the arbitrary-facet simulation branch. It is deliberately limited to fitted \code{RSM} models in version 0.2.0 because \code{\link[=simulate_mfrm_arbitrary_data]{simulate_mfrm_arbitrary_data()}} uses a common-threshold RSM response generator. Role-based PCM/GPCM simulation remains available through \code{\link[=extract_mfrm_sim_spec]{extract_mfrm_sim_spec()}} and \code{\link[=simulate_mfrm_data]{simulate_mfrm_data()}}.

With \code{assignment = "skeleton"}, the generated data reuse the same retained person-by-facet observation rows used by the fitted model. With \code{parameter_source = "estimates"}, the fitted person measures, facet measures, and step estimates are used as the data-generating truth. This answers a direct sensitivity question: how would repeated responses behave under this fitted model and this observed design? If the fitted analysis used observation weights, the extracted specification records the retained \code{Weight} column so \code{\link[=evaluate_mfrm_bias_detection]{evaluate_mfrm_bias_detection()}} can refit simulated data with the same weighting unless \code{fit_args$weight} overrides it.

Use \code{assignment = "balanced"} when the question is not a direct parametric replay of the observed design, but a planning question such as "what if the same fitted severity distribution were used under a more balanced rater-task assignment?" In that case, \code{facets_per_person} controls the rebuilt design.
}
\examples{
spec0 <- build_mfrm_arbitrary_sim_spec(
  n_person = 12,
  facets = c(Rater = 3, Criteria = 2, Task = 2),
  facets_per_person = c(Rater = 2),
  score_levels = 4
)
dat <- simulate_mfrm_arbitrary_data(spec0, seed = 1)
fit <- fit_mfrm(
  dat,
  person = "Person",
  facets = spec0$facet_names,
  score = "Score",
  rating_min = 1,
  rating_max = 4,
  model = "RSM",
  method = "JML",
  maxit = 20
)
fitted_spec <- extract_mfrm_arbitrary_sim_spec(fit)
summarize_mfrm_sim_design(fitted_spec)$overview
fitted_sim <- simulate_mfrm_arbitrary_data(fitted_spec, seed = 2)
head(fitted_sim)

balanced_spec <- extract_mfrm_arbitrary_sim_spec(
  fit,
  assignment = "balanced",
  parameter_source = "resampled",
  facets_per_person = c(Rater = 2)
)
summarize_mfrm_sim_design(balanced_spec)$assignment
}
\seealso{
\code{\link[=simulate_mfrm_arbitrary_data]{simulate_mfrm_arbitrary_data()}},
\code{\link[=build_mfrm_arbitrary_sim_spec]{build_mfrm_arbitrary_sim_spec()}},
\code{\link[=extract_mfrm_sim_spec]{extract_mfrm_sim_spec()}}
}
