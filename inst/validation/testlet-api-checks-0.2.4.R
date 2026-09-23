# Local API qualification; reuse retained reference functions, not their studies.
# Run from development/: Rscript inst/validation/testlet-api-checks-0.2.4.R
pkgload::load_all(".", quiet = TRUE)
out <- "validation-results/testlet-api-20260923"
dir.create(out, recursive = TRUE, showWarnings = FALSE)
reference <- new.env(parent = globalenv())
for (file in c("local-testlet-tam-reference-0.2.4.R", "local-testlet-stress-0.2.4.R")) {
  for (expr in as.list(parse(file.path("inst/validation", file)))) {
    if (is.call(expr) && identical(expr[[1]], as.name("<-")) &&
        is.call(expr[[3]]) && identical(expr[[3]][[1]], as.name("function"))) eval(expr, reference)
  }
}
long <- function(f) data.frame(Person = rep(rownames(f$response), each = 6),
  Rater = rep(as.character(f$map$Rater), nrow(f$response)),
  Criterion = rep(as.character(f$map$Criterion), nrow(f$response)), Score = as.vector(t(f$response)))
base <- mfrm_testlet_data(long(reference$local_testlet_fixture()), "Person", "Score", "Rater",
  c("Rater", "Criterion"), 0:2, "omit")
map <- function(p, v) c(as.vector(crossprod(base$basis$Rater, c(p[4], -p[4]))),
  as.vector(crossprod(base$basis$Criterion, c(p[2:3], -sum(p[2:3])))),
  p[5] - p[1], -p[5] - p[1], v)
jac <- vapply(1:5, function(i) map(diag(5)[, i], 0), numeric(6))
cases <- reference$stress_cases()
zero <- cases[[1]]; zero$id <- "exact_zero"; zero$variance <- 0
cases$exact_zero <- zero
results <- lapply(cases, function(case) {
  # Fixed-point evaluations may include designs that the fitting API refuses.
  x <- mfrm_testlet_data(long(case$fixture), "Person", "Score", "Rater",
    c("Rater", "Criterion"), 0:2, "omit", reference = base)
  a <- mfrm_testlet_evaluate(x, map(case$parameters, case$variance), gauss_hermite_normal(121))
  b <- reference$stress_reference(case$fixture, case$parameters, case$variance, 121)
  g <- c(as.vector(crossprod(jac, a$gradient)), case$variance * tail(a$gradient, 1))
  data.frame(Case = case$id, Variance = case$variance,
    LogLikError = abs(a$loglik - b$loglik), GradientError = max(abs(g - b$gradient)),
    MomentError = max(abs(a$moments - b$moments[, 1:2])))
})
results <- do.call(rbind, results)
write.csv(results, file.path(out, "reference-comparison.csv"), row.names = FALSE)
stopifnot(all(is.finite(as.matrix(results[, 3:5]))), max(as.matrix(results[, 3:5])) < 1e-9)
print(results)

# A new shape: three testlets, four categories, uneven observed assignments.
# One bounded example checks execution and recovery against an independent
# optimizer; it is not a Monte Carlo coverage study.
set.seed(20260923)
d <- expand.grid(Criterion = c("c1", "c2"), Block = c("b1", "b2", "b3"),
  Person = sprintf("P%02d", 1:60), stringsAsFactors = FALSE)
theta <- rnorm(60); gamma <- matrix(rnorm(180, sd = .7), 60, 3)
p <- match(d$Person, unique(d$Person)); b <- match(d$Block, c("b1", "b2", "b3"))
eta <- theta[p] + gamma[cbind(p, b)] - c(-.3, .3)[match(d$Criterion, c("c1", "c2"))]
w <- exp(outer(eta, 0:3) - matrix(c(0, -.8, -.8, 0), nrow(d), 4, byrow = TRUE))
d$Score <- apply(w / rowSums(w), 1, function(prob) sample(0:3, 1, prob = prob))
d <- d[!(p %% 3 == 0 & b == 3), ] # Unassigned blocks are absent.
d$Score[seq(11, nrow(d), 23)] <- NA # Assigned missing scores stay explicit.
fit <- fit_mfrm_testlet(d, "Person", "Score", "Block", "Criterion", 0:3,
  quad_points = 121, missing = "omit", person_sd = 1)
saveRDS(list(data = d, fit = fit), file.path(out, "three-block-source.rds"))
stopifnot(fit$checks$NumericalReady, fit$checks$InformationPositive)
input <- fit$input; rule <- gauss_hermite_normal(243)
restricted <- head(fit$parameters, -1L) # Historical fixed N(0,1) reference layout.
alt <- nlminb(restricted * c(rep(.9, length(restricted) - 1), 1.1),
  function(par) -mfrm_testlet_evaluate(input, par, rule)$loglik,
  function(par) -mfrm_testlet_evaluate(input, par, rule)$gradient,
  lower = c(rep(-20, length(restricted) - 1), 0),
  upper = c(rep(20, length(restricted) - 1), 16),
  control = list(rel.tol = 1e-10, x.tol = 1e-8, iter.max = 300))
saveRDS(alt, file.path(out, "three-block-alternative.rds"))
print(alt); print(max(abs(alt$par - restricted)))
stopifnot(alt$convergence == 0, abs(alt$objective + fit$loglik) < 1e-7,
  max(abs(alt$par - restricted)) < 1e-4)
scores <- predict(fit, d[d$Person %in% unique(d$Person)[1:4], ], missing = "omit")
stopifnot(all(scores$table$Status == "available_conditional"))
saveRDS(list(data = d, fit = fit, independent_optimizer = alt, scores = scores,
  generating = list(criterion = c(-.3, .3), steps = c(-.8, 0, .8), variance = .49),
  session = sessionInfo()), file.path(out, "three-block-fit.rds"))
print(fit); print(fit$checks); print(scores)
