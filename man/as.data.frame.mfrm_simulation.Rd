\name{as.data.frame.mfrm_design_evaluation}
\alias{as.data.frame.mfrm_design_evaluation}
\alias{as.data.frame.summary.mfrm_design_evaluation}
\alias{as.data.frame.mfrm_signal_detection}
\alias{as.data.frame.summary.mfrm_signal_detection}
\alias{as.data.frame.mfrm_bias_detection}
\alias{as.data.frame.summary.mfrm_bias_detection}
\title{Convert simulation evaluation objects to data frames}
\usage{
\method{as.data.frame}{mfrm_design_evaluation}(
  x,
  row.names = NULL,
  optional = FALSE,
  component = c("results", "rep_overview", "design_summary", "overview"),
  ...
)

\method{as.data.frame}{summary.mfrm_design_evaluation}(
  x,
  row.names = NULL,
  optional = FALSE,
  component = c("design_summary", "overview"),
  ...
)

\method{as.data.frame}{mfrm_signal_detection}(
  x,
  row.names = NULL,
  optional = FALSE,
  component = c("results", "rep_overview", "detection_summary", "overview"),
  ...
)

\method{as.data.frame}{summary.mfrm_signal_detection}(
  x,
  row.names = NULL,
  optional = FALSE,
  component = c("detection_summary", "overview"),
  ...
)

\method{as.data.frame}{mfrm_bias_detection}(
  x,
  row.names = NULL,
  optional = FALSE,
  component = c("results", "estimates", "reliability", "fit_statistics",
    "fit_summary", "pair_results", "rep_overview", "target_summary",
    "pair_summary", "design_grid"),
  ...
)

\method{as.data.frame}{summary.mfrm_bias_detection}(
  x,
  row.names = NULL,
  optional = FALSE,
  component = c("target_summary", "pair_summary", "fit_summary"),
  ...
)
}
\arguments{
\item{x}{A simulation evaluation object returned by \code{\link[=evaluate_mfrm_design]{evaluate_mfrm_design()}}, \code{\link[=evaluate_mfrm_signal_detection]{evaluate_mfrm_signal_detection()}}, or \code{\link[=evaluate_mfrm_bias_detection]{evaluate_mfrm_bias_detection()}}.}

\item{row.names}{Ignored; included for compatibility with \code{\link[=as.data.frame]{as.data.frame()}}.}

\item{optional}{Ignored; included for compatibility with \code{\link[=as.data.frame]{as.data.frame()}}.}

\item{component}{Table component to extract. The default is \code{"results"} for raw replication-level results. Other useful components include \code{"rep_overview"}, \code{"design_summary"}, \code{"detection_summary"}, \code{"estimates"}, \code{"reliability"}, and \code{"fit_summary"} when those tables are available for the object class.}

\item{...}{Reserved for future extensions.}
}
\value{
A base \code{data.frame}.
}
\description{
Convert simulation evaluation objects to data frames.
}
\details{
The simulation evaluators already store their core outputs as ordinary data frames. These methods make that contract explicit and provide a stable route for \code{write.csv(as.data.frame(x, component = "results"), ...)} and custom graphics workflows.

For \code{\link[=evaluate_mfrm_design]{evaluate_mfrm_design()}}, the \code{"results"} component includes facet-level separation, strata, reliability, fit summaries, and recovery metrics for each design and replication. For \code{\link[=evaluate_mfrm_bias_detection]{evaluate_mfrm_bias_detection()}}, use \code{"estimates"} for fitted measure estimates and \code{"reliability"} or \code{"fit_summary"} for simulation-derived reliability coefficients.
}
\examples{
spec <- build_mfrm_arbitrary_sim_spec(
  n_person = 10,
  facets = c(Rater = 3, Criteria = 2, Task = 2),
  facets_per_person = c(Rater = 2),
  score_levels = 4
)
targets <- data.frame(Rater = "Rater03", Task = "Task02", Effect = -0.5)
eval <- suppressWarnings(evaluate_mfrm_bias_detection(
  spec,
  bias_targets = targets,
  reps = 1,
  fit_method = "JML",
  maxit = 20,
  bias_max_iter = 1,
  seed = 1
))
head(as.data.frame(eval, component = "estimates"))
head(as.data.frame(eval, component = "reliability"))
}
\seealso{
\code{\link[=evaluate_mfrm_design]{evaluate_mfrm_design()}},
\code{\link[=evaluate_mfrm_signal_detection]{evaluate_mfrm_signal_detection()}},
\code{\link[=evaluate_mfrm_bias_detection]{evaluate_mfrm_bias_detection()}}
}
