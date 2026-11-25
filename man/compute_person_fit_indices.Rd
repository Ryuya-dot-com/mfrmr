\name{compute_person_fit_indices}
\alias{compute_person_fit_indices}
\title{Compute Parametric Person-Fit Statistics (lz and Outfit/Infit Screening)}
\description{
Computes the standardized log-likelihood person-fit index \eqn{l_z} (Drasgow, Levine, & Williams, 1985) alongside person-level \code{InfitMnSq} and \code{OutfitMnSq} from a fitted Many-Facet model or diagnostic bundle to screen aberrant examinee rating patterns.
}
\usage{
compute_person_fit_indices(
  diagnostics, fit = NULL)
}
\arguments{
  \item{diagnostics}{Either a fitted model object from \code{\link{fit_mfrm}} or a diagnostic bundle from \code{\link{diagnose_mfrm}}.}
  \item{fit}{Optional matching \code{\link{fit_mfrm}} object when \code{diagnostics} is a legacy diagnostic bundle.}
}
\value{
An S3 object of class \code{"mfrm_person_fit_indices"} containing \code{table} (\code{Person}, \code{ObsCount}, \code{L0}, \code{lz}, \code{InfitMnSq}, \code{OutfitMnSq}, and \code{Flagged} indicating \code{lz < -2.0} or \code{OutfitMnSq > 1.5}).
}
\seealso{
\code{\link{diagnose_mfrm}}, \code{\link{plot.mfrm_fit}}
}
\examples{
ratings <- load_mfrmr_data("example_core")
fit <- fit_mfrm(ratings, person = "Person", facets = c("Rater", "Criterion"), score = "Score")

pfit <- compute_person_fit_indices(fit)
head(pfit$table)
plot(fit, type = "person_fit")
}
