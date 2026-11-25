\name{compute_information}
\alias{compute_information}
\title{Compute Category Probability and Fisher Test Information Curves}
\description{
Evaluates Fisher test information \eqn{I(\theta)}, conditional standard error \eqn{\mathrm{SE}(\theta) = 1 / \sqrt{I(\theta)}}, expected total score, and reference category probability curves across a grid of latent ability values for \code{"RSM"}, \code{"PCM"}, and \code{"GPCM"} calibrations.
}
\usage{
compute_information(
  fit, theta_range = c(-6, 6), theta_points = 201L, rating_plan = NULL,
  exposure_basis = c("observed_total", "per_person_average"))
}
\arguments{
  \item{fit}{A fitted model object returned by \code{\link{fit_mfrm}}.}
  \item{theta_range}{Numeric vector of length 2 giving the lower and upper logit bounds of the \code{theta} grid (default \code{c(-6, 6)}).}
  \item{theta_points}{Integer number of evaluation points along \code{theta_range} (default \code{201L}).}
  \item{rating_plan}{Optional \code{data.frame} specifying planned facet combinations and \code{Count} on legacy fits.}
  \item{exposure_basis}{Exposure scaling convention on legacy fits (\code{"observed_total"} or \code{"per_person_average"}).}
}
\value{
An S3 object of class \code{"mfrm_information"} containing \code{test_information} (\code{Theta}, \code{Information}, \code{SE}, \code{ExpectedScore}) and \code{category_curves} (\code{ScaleLevel}, \code{Theta}, \code{Category}, \code{Probability}). Supports \code{\link{plot.mfrm_fit}}.
}
\seealso{
\code{\link{fit_mfrm}}, \code{\link{classification_table}}, \code{\link{plot.mfrm_fit}}
}
\examples{
ratings <- load_mfrmr_data("example_core")
fit <- fit_mfrm(ratings, person = "Person", facets = c("Rater", "Criterion"), score = "Score")

info <- compute_information(fit, theta_range = c(-4, 4), theta_points = 81L)
head(info$test_information)
plot(info, type = "information")
}
