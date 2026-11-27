\name{plot.mfrm_fit}
\alias{plot.mfrm_bias}
\alias{plot.mfrm_diagnostics}
\alias{plot.mfrm_dff}
\alias{plot.mfrm_drift}
\alias{plot.mfrm_fit}
\alias{plot.mfrm_gtheory}
\alias{plot.mfrm_information}
\alias{plot.mfrm_multivariate_d_study}
\title{Color-Vision-Safe ggplot2 Visualizations for Many-Facet Models and Diagnostics}
\description{
Default \pkg{ggplot2} \code{plot()} methods for fitted MFRM models, diagnostics, G/D-Studies, pairwise \code{RajuSA-Welch} bias tables, DFF screens, test information curves, and rater drift trajectories. Every multi-group aesthetic pairs color (\code{"okabe_ito"}, \code{"viridis"}, or strict \code{R == G == B} \code{"monochrome"}) with distinct point \code{shape} and \code{linetype} encodings. Canvas titles and footnotes are omitted by default and stored in \code{attr(p, "mfrm_notes")}.
}
\usage{
\method{plot}{mfrm_bias}(
  x, type = c("forest", "pairwise"), top_n = 20L,
  palette = c("okabe_ito", "viridis", "monochrome"), base_size = 11, ...)

\method{plot}{mfrm_diagnostics}(
  x, facet = NULL, palette = c("okabe_ito", "viridis", "monochrome"),
  base_size = 11, ..., type = c("pathway", "residual_pca", "fit_sensitivity"))

\method{plot}{mfrm_dff}(
  x, top_n = 25L, palette = c("okabe_ito", "viridis", "monochrome"),
  base_size = 11, ...)

\method{plot}{mfrm_drift}(
  x, type = c("trajectory", "contrasts"),
  palette = c("okabe_ito", "viridis", "monochrome"), base_size = 11, ...)

\method{plot}{mfrm_fit}(
  x,
  type = c("wright", "pathway", "steps", "category_curves", "persons",
    "raters", "person_fit", "residual_qq", "slopes", "qc",
    "fit_sensitivity", "cut_sensitivity"),
  palette = c("okabe_ito", "viridis", "monochrome"), facet = NULL,
  base_size = 11, ..., fit_statistic = c("infit", "outfit", "both"), interactive = FALSE)

\method{plot}{mfrm_gtheory}(
  x, type = NULL,
  palette = c("okabe_ito", "viridis", "monochrome"), base_size = 11, ...)

\method{plot}{mfrm_information}(
  x, type = c("information", "ccc"),
  palette = c("okabe_ito", "viridis", "monochrome"), base_size = 11, ...)

\method{plot}{mfrm_multivariate_d_study}(
  x, palette = c("okabe_ito", "viridis", "monochrome"), base_size = 11, ...)



}
\arguments{
  \item{interactive}{For fits, return a Plotly widget for Wright maps, category curves, raters, pathways or fit sensitivity. Requires the optional plotly package. The widget includes the plot notes.}
  \item{fit_statistic}{Horizontal mean-square statistic for a pathway plot. Use \code{"both"} for separate Infit and Outfit panels on the same scale.}
  \item{x}{An \pkg{mfrmr} model, diagnostic, bias, DFF, information, drift, G/D-Study object.}
  \item{type}{Character string selecting the visualization panel: for diagnostic objects, \code{"pathway"}, \code{"residual_pca"} (first residual contrast), or \code{"fit_sensitivity"}; for fitted models, \code{"wright"}, \code{"pathway"}, \code{"steps"}, \code{"category_curves"}, \code{"persons"}, \code{"raters"}, \code{"person_fit"}, \code{"residual_qq"}, \code{"slopes"} (GPCM), \code{"qc"}, \code{"fit_sensitivity"} (flagged counts across symmetric \code{[1 - d, 1 + d]} \code{MnSq} bounds), or \code{"cut_sensitivity"} (pass rate and 90\% borderline counts across candidate \code{Fair(M)} cutoffs); for G-Studies, \code{"dstudy"} or \code{"variance"} (\code{NULL} chooses D-Study for Henderson and component variance for ANOVA/MINQUE); for bias, \code{"forest"} or \code{"pairwise"}; for information, \code{"information"} or \code{"ccc"}; for drift, \code{"trajectory"} or \code{"contrasts"}.}
  \item{top_n}{Maximum number of ranked bias cells or DFF elements to display.}
  \item{palette}{Color-vision-safe palette: \code{"okabe_ito"} (default), \code{"viridis"}, or strict \code{"monochrome"} grayscale.}
  \item{base_size}{Base font size in points (default \code{11}).}
  \item{...}{Additional plotting options.}
  \item{facet}{Optional facet name filter for element pathway and rater diagnostic plots.}
}
\value{
A \code{ggplot} object or, for fits with \code{interactive = TRUE}, a Plotly widget with diagnostic and scale notes attached in \code{attr(p, "mfrm_notes")}.
}
\details{
The Wright map shows finite person ability estimates, including shrinkage when
EAP scoring is used. The histogram and optional \code{person_display = "density"}
extend left from zero. In \code{person_display = "stars"}, each asterisk represents
\code{persons_per_star} people (default 3). For example, \verb{** +2} represents
eight people. Empty bins are blank. Large tallies use a multiplier. Facet column
signs in star and yardstick displays give the sign of the fitted facet in the predictor.

Set an equal bin width in logits with \code{binwidth}, or pass
\code{yardstick = 4} for four ruler rows per logit. With a yardstick, count rows
are centred on multiples of the row spacing around zero, and halfway values
join the higher row. Density uses the ruler without binning.
\code{yardstick = list(lines = 4, range = c(-3, 3))} also sets the visible logit
window. The reported N includes all finite estimates, including those outside
this window. Finite extreme estimates keep their locations.
The frequency symbols and vertical spacing follow conventions described in the
FACETS manual (\href{https://www.winsteps.com/facetman64/vertical.htm}{Vertical}
and \href{https://www.winsteps.com/facetman64/yardstick.htm}{Yardstick}).
The default step column shows
relative offsets. For adjacent-category crossings on the ability scale, pass
one calibrated rating context as \code{newdata}, with every fitted base facet.
When inference is unavailable these conditional crossings are withheld. For
\code{type = "category_curves"} or \code{"steps"}, supply one row per context in
\code{newdata} to plot conditional category probabilities on the ability scale.

Read horizontally from person ability to the right-hand Fair average ruler for
the model-expected rating on the original rubric. Short lines connect displaced
element labels to their actual measures. Score ticks are placed by inverting
the fitted mean rating in the displayed logit window. They are point predictions.

By default, other facets are at their calibration means, including fitted
interaction locations. GMFRM uses the observation-weighted geometric mean
discrimination. With shared steps this is person Fair(M). With multiple step
groups the ruler pools their frequencies across all retained rating weights;
persons assigned a different mix can have a different individual Fair(M).
With \code{reference_plan}, the ruler instead uses the weighted expected rating
for those exact facet combinations, as in \code{\link{fair_average_table}}.
\code{newdata} selects the adjacent-category crossings independently.
Set \code{fair_average = FALSE} to hide the ruler. When calibration requires
review or the displayed range has no resolvable score ticks, the reason appears
in \code{attr(p, "mfrm_notes")}. For ggplot and Plotly, the displayed
\code{FairAverage} and \code{Logit} pairs are in \code{attr(p, "mfrm_fair_average")},
with the step weights or the normalized reference plan attached.

Wright maps and quality-control plots omit unidentified step estimates.
The \code{"steps"} and \code{"category_curves"} panels omit any ladder with
an unidentified supported transition. The names of affected ladders appear
in \code{attr(p, "mfrm_notes")}, including for saved fits. In fit sensitivity
tables, \code{TotalElements} counts finite MnSq values and \code{UnavailableMnSqCount}
counts the omitted elements.

The \code{"person_fit"} panel plots Outfit against the reported person-fit
index from \code{compute_person_fit_indices()}: conditional \eqn{l_z^*}
when available, otherwise \eqn{l_z}. Its two-sided flags agree with
\code{summary()} of that result. These are screening references, not
calibrated significance tests.

For unified-engine fits, slope bars use the same log-scale 95 percent model
intervals as \code{confint(x, component = "slopes")}. Person and facet diagnostic
bars use descriptive Real-SE intervals. For \code{mfrm_drift} objects,
\code{type = "contrasts"} displays wave-vs-baseline severity changes with 95
percent total-SE intervals when \code{checks$NumericalReady} is \code{TRUE}. When
a calibration or drift fit fails numerical readiness, interval bars are withheld
while finite descriptive points are retained; \code{attr(p, "mfrm_notes")}
records the reasons. Neither visible bars nor a ready status establish nominal
finite-sample coverage.
}
\examples{
# Saved JML calibration of example_core; see fit_mfrm() for estimation.
saved <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
fit <- saved$fit
p1 <- plot(fit, type = "wright", palette = "okabe_ito")
p2 <- plot(fit, type = "category_curves", palette = "viridis")
p3 <- plot(fit, type = "residual_qq", palette = "monochrome")
attr(p1, "mfrm_notes")
ruler <- plot(fit, type = "wright", person_display = "stars", yardstick = 2)
attr(ruler, "mfrm_fair_average")
plot(fit, type = "wright", newdata = data.frame(Rater = "R04", Criterion = "Content"))
if (interactive() && requireNamespace("plotly", quietly = TRUE))
  plot(fit, type = "category_curves", interactive = TRUE)
}
