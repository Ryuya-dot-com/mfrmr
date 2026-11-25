\name{fair_average_table}
\alias{fair_average_table}
\title{Compute Reference-Standardized Fair(M) and Zero-Reference Fair(Z) Expected Scores}
\description{
Translates latent logit parameter estimates for persons and non-person facets back onto the original rubric score scale by computing model-expected average ratings against a cohort-mean reference context (\code{FairM}) and a zero-logit reference context (\code{FairZ}), alongside raw observed averages (\code{ObsAvg}).
}
\usage{
fair_average_table(
  fit, diagnostics = NULL, facets = NULL, totalscore = TRUE, umean = 0,
  uscale = 1, udecimals = 2, reference = c("both", "mean", "zero"),
  label_style = c("both", "native", "legacy"), omit_unobserved = FALSE,
  xtreme = 0, fair_se = FALSE, ci_level = 0.95,
  xtreme_method = c("display", "facets"), reference_plan = NULL)
}
\arguments{
  \item{fit}{A fitted model object returned by \code{\link{fit_mfrm}}.}
  \item{diagnostics}{Optional precomputed \code{\link{diagnose_mfrm}} object for legacy fits.}
  \item{facets}{Optional character vector filtering which facets (including \code{"Person"}) to return.}
  \item{totalscore}{Logical; whether to include total observed/expected score columns on legacy tables.}
  \item{umean}{Additive origin shift applied to reported logit measures \code{umean + uscale * Estimate} (default \code{0}).}
  \item{uscale}{Multiplicative scale factor applied to reported logit measures and \code{SE} (default \code{1}).}
  \item{udecimals}{Rounding precision for formatted legacy display columns (default \code{2}).}
  \item{reference}{Which reference expectation to report on legacy fits: \code{"both"}, \code{"mean"}, or \code{"zero"}.}
  \item{label_style}{Column naming convention on legacy fits (\code{"both"}, \code{"native"}, or \code{"legacy"}).}
  \item{omit_unobserved}{Logical; whether to omit elements with zero observed ratings.}
  \item{xtreme}{Extreme-score adjustment for legacy \code{JML} display.}
  \item{fair_se}{Logical; whether to compute delta-method standard errors for fair averages on legacy fits.}
  \item{ci_level}{Confidence level in \code{(0, 1)} when intervals are requested (default \code{0.95}).}
  \item{xtreme_method}{Extreme-score handling convention on legacy fits (\code{"display"} or \code{"facets"}).}
  \item{reference_plan}{Optional common rating plan \code{data.frame} containing exactly all fitted base facet columns plus optional \code{Weight}. Levels must be known, cells unique and weights finite and strictly positive. Weights are normalized to sum to one.}
}
\value{
An S3 object of class \code{"mfrm_fair_average"} containing \code{stacked} (combined \code{data.frame} with \code{Facet}, \code{Level}, \code{ObsCount}, \code{ObsAvg}, \code{ExpAvg}, \code{FairM}, \code{FairZ}, \code{Measure}, and \code{SE}) and \code{raw_by_facet} (named list of per-facet \code{data.frame}s).
When a plan is supplied, also returns \code{reference_plan} with
\code{NormalizedWeight}, and \code{reference_scores} with one person per row.
}
\details{
For the unified engine, \code{reference_scores$Estimate} is the weighted mean
model-expected rating under the same supplied plan for every person, conditional
on that person's primary ability estimate. It is on the original rubric scale
(\code{Units = "original_score"}). The plan preserves the fitted locations,
steps, interactions and slopes; its scores can therefore differ from FairM/FairZ.
An EAP plug-in score is not the posterior mean of the transformed score.
The unified engine does not compute posterior score moments or common-plan
intervals: \code{Uncertainty = "not_computed"}. An unusable calibration returns
\code{NA} with \code{Status = "unavailable_calibration"}.
The table's \code{SE} is the latent measure SE, not a fair-score SE;
\code{fair_se = TRUE} is rejected for the unified engine.
}
\seealso{
\code{\link{fit_mfrm}}, \code{\link{diagnose_mfrm}}
}
\examples{
# Compare raw observed averages (ObsAvg) against rater-adjusted Fair(M) on incomplete panels
ratings <- load_mfrmr_data("example_operational")
fit <- fit_mfrm(ratings, person = "Person", facets = c("Rater", "Criterion"), score = "Score")

fair <- fair_average_table(fit, facets = c("Person", "Rater"))
head(fair$raw_by_facet$Person, 5)
fair$raw_by_facet$Rater

# Put every person on the same weighted panel (original score scale).
plan <- data.frame(Rater = c("R01", "R04"),
                   Criterion = c("Content", "Language"), Weight = c(1, 3))
head(fair_average_table(fit, reference_plan = plan)$reference_scores)
}
