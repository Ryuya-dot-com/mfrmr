\name{list_mfrm_sim_metrics}
\alias{list_mfrm_sim_metrics}
\title{List available simulation metrics}
\usage{
list_mfrm_sim_metrics(x, component = NULL, design_id = NULL)
}
\arguments{
\item{x}{A simulation specification, simulation summary table, simulation evaluation object, or data frame.}

\item{component}{Optional component to inspect. Defaults to the most useful table for each object class: design-grid summaries for arbitrary specifications, \code{design_summary} for \code{\link[=evaluate_mfrm_design]{evaluate_mfrm_design()}}, \code{detection_summary} for \code{\link[=evaluate_mfrm_signal_detection]{evaluate_mfrm_signal_detection()}}, and \code{fit_summary} for \code{\link[=evaluate_mfrm_bias_detection]{evaluate_mfrm_bias_detection()}}.}

\item{design_id}{Optional design rows used when \code{x} is an arbitrary simulation specification.}
}
\value{
A data frame with metric names, source component, role, direction, and suggested-default flags.
}
\description{
List available simulation metrics.
}
\examples{
spec <- build_mfrm_arbitrary_sim_spec(
  n_person = 20,
  facets = list(Rater = c(2, 4), Criteria = c(2, 3), Task = c(2, 4)),
  facets_per_person = list(Rater = c(1, 2), Task = 2),
  score_levels = 4
)
list_mfrm_sim_metrics(spec)
}
\seealso{
\code{\link[=plot_mfrm_sim_dashboard]{plot_mfrm_sim_dashboard()}},
\code{\link[=summarize_mfrm_sim_grid]{summarize_mfrm_sim_grid()}},
\code{\link[=evaluate_mfrm_design]{evaluate_mfrm_design()}}
}
