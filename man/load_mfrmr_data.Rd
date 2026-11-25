\name{load_mfrmr_data}
\alias{load_mfrmr_data}
\title{Load Bundled Synthetic Many-Facet Example Datasets}
\description{
Returns one of the synthetic many-facet rating datasets bundled with \pkg{mfrmr} as a ready-to-use \code{data.frame} for learning, testing, and reproducible examples.
}
\usage{
load_mfrmr_data(
  name = c(
    "example_core", "example_bias", "example_operational",
    "study1", "study2", "combined",
    "study1_itercal", "study2_itercal", "combined_itercal"
  )
)
}
\arguments{
  \item{name}{Character string selecting the bundled dataset: \code{"example_operational"} (connected incomplete two-rater assignment), \code{"example_core"} (complete 48 x 4 x 4 crossing), \code{"example_bias"} (planted interaction and group DFF), one of the \code{ej2021} synthetic datasets (\code{"study1"}, \code{"study2"}, \code{"combined"}, and \code{"*_itercal"} variants), or \code{"list"} to return the vector of available dataset keys.}
}
\value{
A \code{data.frame} in long format (one row per observed rating) containing \code{Person}, facet columns (\code{Rater}, \code{Criterion}), \code{Score}, and dataset metadata columns.
}
\seealso{
\code{\link{mfrmr_example_data}}, \code{\link{ej2021_data}}, \code{\link{describe_mfrm_data}}
}
\examples{
ratings <- load_mfrmr_data("example_operational")
head(ratings)
table(ratings$Rater, ratings$Score)
}
