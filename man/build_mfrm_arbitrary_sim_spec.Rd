\name{build_mfrm_arbitrary_sim_spec}
\alias{build_mfrm_arbitrary_sim_spec}
\alias{print.mfrm_arbitrary_sim_spec}
\title{Build an arbitrary-facet MFRM simulation specification}
\usage{
build_mfrm_arbitrary_sim_spec(
  n_person = 50,
  facets,
  facet_sd = NULL,
  facets_per_person = NULL,
  score_levels = 5,
  theta_sd = 1,
  noise_sd = 0,
  step_span = 1.4,
  thresholds = NULL,
  group_levels = NULL,
  dif_effects = NULL,
  interaction_effects = NULL,
  model = c("RSM", "PCM", "GPCM")
)
}
\arguments{
\item{n_person}{Number of persons. A vector creates design-grid choices.}

\item{facets}{Named counts for all non-person facets, or a named list whose elements are count choices.}

\item{facet_sd}{Optional named standard deviations for simulated facet effects. A single unnamed value is reused for every facet.}

\item{facets_per_person}{Optional named assignment counts. Facets not listed are fully crossed within each person; listed facets use deterministic rotating subsets.}

\item{score_levels}{Number of ordered score categories.}

\item{theta_sd}{Standard deviation of simulated person measures.}

\item{noise_sd}{Optional observation-level noise added to the linear predictor.}

\item{step_span}{Spread of generated common RSM thresholds.}

\item{thresholds}{Optional common RSM thresholds. Must have \code{score_levels - 1} values.}

\item{group_levels}{Optional group labels assigned at the person level.}

\item{dif_effects}{Optional DIF effect table.}

\item{interaction_effects}{Optional facet-interaction effect table.}

\item{model}{Measurement model for the arbitrary-facet generator. Version 0.2.0 supports \code{model = "RSM"} for this branch.}
}
\value{
An object of class \code{mfrm_arbitrary_sim_spec}.
}
\description{
Build an arbitrary-facet MFRM simulation specification.
}
\details{
This specification is the arbitrary-facet counterpart to \code{\link[=build_mfrm_sim_spec]{build_mfrm_sim_spec()}}.
The older role-based \code{Person x Rater x Criterion} generator remains available for PCM/GPCM simulation contracts.
This branch focuses on flexible RSM-based design and bias-screening sensitivity checks with any number of non-person facets.

If \code{facets_per_person} contains \code{Rater = 2} and \code{Task = 3}, each person receives a deterministic rotating subset of two raters and three tasks. Omitted facets, such as \code{Criteria}, are fully crossed with those selected levels.

A typical design-first workflow is to build a specification, inspect it with \code{\link[=summarize_mfrm_sim_design]{summarize_mfrm_sim_design()}} or \code{\link[=plot_mfrm_sim_design]{plot_mfrm_sim_design()}}, simulate data, and then fit or evaluate the design. If a researcher already has a fitted RSM model, use \code{\link[=extract_mfrm_arbitrary_sim_spec]{extract_mfrm_arbitrary_sim_spec()}} instead so the simulation starts from the observed response skeleton and fitted estimates.
}
\examples{
spec <- build_mfrm_arbitrary_sim_spec(
  n_person = 20,
  facets = c(Rater = 4, Criteria = 3, Task = 5, Occasion = 2),
  facet_sd = c(Rater = .35, Criteria = .25, Task = .30, Occasion = .10),
  facets_per_person = c(Rater = 2, Task = 3),
  score_levels = 5
)
spec$design_grid
design <- summarize_mfrm_sim_design(spec)
design$overview
design$assignment
}
\seealso{
\code{\link[=simulate_mfrm_arbitrary_data]{simulate_mfrm_arbitrary_data()}},
\code{\link[=extract_mfrm_arbitrary_sim_spec]{extract_mfrm_arbitrary_sim_spec()}},
\code{\link[=summarize_mfrm_sim_design]{summarize_mfrm_sim_design()}},
\code{\link[=summarize_mfrm_sim_grid]{summarize_mfrm_sim_grid()}},
\code{\link[=plot_mfrm_sim_grid]{plot_mfrm_sim_grid()}},
\code{\link[=evaluate_mfrm_bias_detection]{evaluate_mfrm_bias_detection()}}
}
