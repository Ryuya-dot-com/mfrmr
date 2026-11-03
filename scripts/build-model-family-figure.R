# From the package root: Rscript scripts/build-model-family-figure.R
# Equation illustration only: no fitted data or package comparison benchmark.
library(ggplot2)

eta <- seq(-3, 3, length.out = 301L)
adjacent <- exp(outer(eta, 0:2) - pmax(0, 2 * eta))
adjacent <- adjacent / rowSums(adjacent)
cumulative <- function(cdf, cuts) {
  lower <- cdf(cuts[1L] - eta)
  upper <- cdf(cuts[2L] - eta)
  cbind(lower, upper - lower, 1 - upper)
}
logit <- cumulative(plogis, qlogis(c(1 / 3, 2 / 3)))
probit <- cumulative(pnorm, qnorm(c(1 / 3, 2 / 3)))
probabilities <- list(
  "RSM / PCM: adjacent logit" = adjacent,
  "Ordinal mixed model: cumulative logit" = logit,
  "Ordinal CFA: cumulative probit" = probit
)

# Verify the displayed probabilities and the defining link equations.
center <- which.min(abs(eta))
for (p in probabilities) {
  stopifnot(all(is.finite(p)), all(p >= 0), all(p <= 1),
    max(abs(rowSums(p) - 1)) < 1e-14,
    max(abs(p[center, ] - 1 / 3)) < 1e-14,
    all(diff(drop(p %*% (0:2))) > 0))
}
stopifnot(
  max(abs(log(adjacent[, 2] / adjacent[, 1]) - eta)) < 1e-13,
  max(abs(log(adjacent[, 3] / adjacent[, 2]) - eta)) < 1e-13,
  max(abs(qlogis(logit[, 1]) - (qlogis(1 / 3) - eta))) < 1e-12,
  max(abs(qlogis(rowSums(logit[, 1:2])) - (qlogis(2 / 3) - eta))) < 1e-12,
  max(abs(qnorm(probit[, 1]) - (qnorm(1 / 3) - eta))) < 1e-12,
  max(abs(qnorm(rowSums(probit[, 1:2])) - (qnorm(2 / 3) - eta))) < 1e-12
)
curves <- do.call(rbind, lapply(names(probabilities), function(model) {
  data.frame(Predictor = rep(eta, 3L),
    Probability = as.vector(probabilities[[model]]),
    Category = factor(rep(0:2, each = length(eta))), Model = model)
}))
curves$Model <- factor(curves$Model, levels = names(probabilities))

figure <- ggplot(curves, aes(Predictor, Probability,
    colour = Category, linetype = Category)) +
  geom_vline(xintercept = 0, colour = "grey70", linetype = "dotted") +
  geom_line(linewidth = 0.95) +
  geom_point(data = curves[curves$Predictor == 0 & curves$Category == 0, ],
    colour = "#222222", size = 2.4, show.legend = FALSE) +
  facet_wrap(~Model, ncol = 1) +
  scale_colour_manual(values = c("#0072B2", "#B35A00", "#007E68")) +
  scale_linetype_manual(values = c("solid", "dashed", "longdash")) +
  scale_x_continuous(breaks = -3:3, expand = expansion(mult = 0.015)) +
  scale_y_continuous(limits = c(0, 1), breaks = c(0, 1 / 3, 2 / 3, 1),
    labels = c("0", "1/3", "2/3", "1")) +
  labs(x = "Predictor (within-model units)", y = "Category probability") +
  theme_minimal(base_size = 16, base_family = "sans") +
  theme(legend.position = "top", legend.justification = "left",
    strip.text = element_text(face = "bold", hjust = 0),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.spacing = grid::unit(1.2, "lines"),
    plot.margin = margin(8, 12, 8, 8))

destination <- "vignettes/articles/model-comparison"
dir.create(destination, recursive = TRUE, showWarnings = FALSE)
ggsave(file.path(destination, "model-families.svg"), figure,
  device = svglite::svglite, width = 7.2, height = 8.3, bg = "white")
cat("PASS: three normalized probability families, link identities, central match,",
  "and increasing expected scores; saved model-families.svg\n")
