# Repository-only model mapping, not a fitting API or a coverage experiment.
# Reuse two saved inputs; generate brms data/code, check category probabilities
# and owner identities (1e-12 tolerance), and parse Stan. No MCMC or new data.
source('inst/validation/local-testlet-tam-reference-0.2.4.R')

random_effects_brms_spec <- function(data, effect = c('local', 'shared_rater')) {
  effect <- match.arg(effect)
  stopifnot(requireNamespace('brms', quietly = TRUE),
    all(c('Person', 'Rater', 'Criterion', 'Score') %in% names(data)),
    nrow(data) > 0L, is.numeric(data$Score), all(data$Score %in% 0:2))
  for (name in c('Person', 'Rater', 'Criterion')) {
    labels <- as.character(data[[name]])
    stopifnot(!anyNA(labels), all(nzchar(trimws(labels))))
    data[[name]] <- factor(labels, levels = unique(labels))
  }
  stopifnot(nlevels(data$Person) >= 2L, nlevels(data$Rater) >= 2L,
    nlevels(data$Criterion) >= 2L)
  data$Score <- ordered(data$Score, levels = 0:2)
  basis <- list()
  fixed <- character()
  owners <- if (effect == 'local') c('Criterion', 'Rater') else 'Criterion'
  for (owner in owners) {
    q <- stats::contr.helmert(nlevels(data[[owner]]))
    q <- sweep(q, 2, sqrt(colSums(q^2)), '/')
    rownames(q) <- levels(data[[owner]])
    colnames(q) <- paste0(substr(owner, 1, 1), seq_len(ncol(q)))
    basis[[owner]] <- q
    data[colnames(q)] <- as.data.frame(q[as.integer(data[[owner]]), , drop = FALSE])
    fixed <- c(fixed, colnames(q))
  }
  group <- if (effect == 'local') 'PersonRater' else 'Rater'
  if (effect == 'local') {
    data$PersonRater <- interaction(data$Person, data$Rater, drop = TRUE, lex.order = TRUE)
  }
  formula <- brms::bf(stats::as.formula(paste('Score ~',
    paste(c(fixed, '(1 | Person)', paste0('(1 | ', group, ')')), collapse = ' + '))),
    center = FALSE)
  # Proper priors are an explicit reference candidate, not validated defaults.
  # Orthonormal contrasts make fixed-facet priors invariant to level relabeling.
  prior <- c(brms::set_prior('normal(0, 2)', class = 'b'),
    brms::set_prior('normal(0, 2)', class = 'Intercept'),
    brms::set_prior('constant(1)', class = 'sd', group = 'Person'),
    brms::set_prior('normal(0, 1)', class = 'sd', group = group))
  list(formula = formula, data = data, family = brms::acat('logit', threshold = 'flexible'),
    prior = prior, basis = basis, effect = effect, random_group = group)
}

run_random_effects_brms_bridge <- function() {
  prefix <- 'inst/validation/random-effects-brms-bridge-0.2.4'
  output <- 'validation-results/random-effects-brms-bridge-20260918'
  dir.create(output, recursive = TRUE, showWarnings = FALSE)
  inputs <- c('validation-results/local-testlet-main-coverage-20260917/cell-03-rep-0001-data.rds',
    'validation-results/shared-rater-fixed-point-20260917/evidence.rds')
  hashes <- tools::md5sum(c(paste0(prefix, '.R'),
    'inst/validation/local-testlet-tam-reference-0.2.4.R', inputs))
  g <- readRDS(inputs[1]); shared <- readRDS(inputs[2])
  y <- g$fixture$response
  local <- expand.grid(Person = rownames(y), Observation = seq_len(ncol(y)))
  local$Rater <- paste0('R', g$fixture$map$Rater[local$Observation])
  local$Criterion <- paste0('C', g$fixture$map$Criterion[local$Observation])
  local$Score <- as.vector(y)
  ix <- arrayInd(seq_along(shared$response), dim(shared$response))
  crossed <- data.frame(Person = paste0('P', ix[, 1]), Rater = paste0('R', ix[, 2]),
    Criterion = paste0('C', ix[, 3]), Score = as.vector(shared$response))
  specs <- list(local = random_effects_brms_spec(local, 'local'),
    shared_rater = random_effects_brms_spec(crossed, 'shared_rater'))
  checks <- records <- list()
  check <- function(case, name, error, tolerance = 1e-12) {
    checks[[length(checks) + 1L]] <<- data.frame(Case = case, Check = name,
      Error = error, Tolerance = tolerance, Pass = is.finite(error) && error <= tolerance)
  }
  for (id in names(specs)) {
    spec <- specs[[id]]
    args <- spec[c('formula', 'data', 'family', 'prior')]
    stan_data <- do.call(brms::make_standata, args)
    code <- do.call(brms::make_stancode, args)
    d <- spec$data; p <- as.integer(d$Person); r <- as.integer(d$Rater)
    j <- as.integer(d$Criterion)
    check(id, 'zero_based_categories_mapped_once', max(abs(stan_data$Y - as.integer(d$Score))))
    check(id, 'person_owner', max(abs(stan_data$J_1 - p)))
    owner <- as.integer(d[[spec$random_group]])
    check(id, 'second_random_owner', max(abs(stan_data$J_2 - owner)))
    check(id, 'owner_count', abs(stan_data$N_2 - length(unique(owner))))
    for (name in names(spec$basis)) {
      q <- spec$basis[[name]]; n <- nrow(q)
      check(id, paste0(name, '_exchangeable_contrast_covariance'),
        max(abs(tcrossprod(q) - (diag(n) - matrix(1 / n, n, n)))))
    }
    beta <- if (id == 'local') as.vector(g$fixture$criterion_contrasts %*% g$par[2:3]) else
      unlist(shared$input$shared_and_local_models$criterion_difficulties)
    b <- as.vector(-crossprod(spec$basis$Criterion, beta))
    if (id == 'local') {
      severity <- g$fixture$rater_contrasts * g$par[4]
      b <- c(b, as.vector(-crossprod(spec$basis$Rater, severity)))
      mu <- as.vector(stan_data$X %*% b) + g$theta[p] + g$gamma[cbind(p, r)]
      alpha <- g$par[1]; tau <- c(g$par[5], -g$par[5])
      expected <- do.call(rbind, lapply(seq_len(nrow(d)), function(i)
        g$probabilities[p[i], , local$Observation[i]]))
    } else {
      # Conditional probes on the saved response fixture, not new sampled data.
      theta <- c(-.4, .7); severity <- c(-.25, .25)
      mu <- as.vector(stan_data$X %*% b) + theta[p] - severity[r]
      alpha <- 0; tau <- c(-.6, .6)
      expected <- local_testlet_probabilities(theta[p] - beta[j] - severity[r], tau[1])
    }
    thresholds <- tau - alpha
    # brms' installed R kernel is checked alongside its generated Stan algebra.
    actual <- getFromNamespace('dacat', 'brms')(1:3, eta = matrix(mu, nrow(d), 2),
      thres = matrix(thresholds, nrow(d), 2, byrow = TRUE))
    check(id, 'conditional_category_probabilities', max(abs(actual - expected)))
    positions <- cbind(seq_len(nrow(d)), stan_data$Y)
    check(id, 'conditional_response_loglik', abs(sum(log(actual[positions])) - sum(log(expected[positions]))))
    check(id, 'threshold_location_inverse', max(abs(c(-mean(thresholds) - alpha,
      thresholds - mean(thresholds) - tau))))
    required <- c('cumulative_sum(disc * (mu - thres))', 'real disc = 1;',
      'vector[nthres] Intercept;', 'sd_1 = rep_vector(1, rows(sd_1));',
      'r_2_1 = (sd_2[1] * (z_2[1]));')
    check(id, 'generated_model_contract', as.integer(!all(vapply(required,
      grepl, logical(1), x = code, fixed = TRUE))), 0)
    path <- file.path(output, paste0(id, '.stan'))
    writeLines(code, path)
    syntax <- cmdstanr::cmdstan_model(path, compile = FALSE)$check_syntax(quiet = TRUE)
    check(id, 'stan_syntax', as.integer(!isTRUE(syntax)), 0)
    records[[id]] <- list(spec = spec, stan_data = stan_data, code = code,
      conditional_point = list(b = b, mu = mu, thresholds = thresholds),
      expected = expected, actual = actual, syntax = syntax)
  }
  check('provenance', 'sources_and_inputs_unchanged',
    as.integer(!identical(hashes, tools::md5sum(names(hashes)))), 0)
  checks <- do.call(rbind, checks)
  evidence <- list(records = records, checks = checks, hashes = hashes,
    brms = as.character(utils::packageVersion('brms')),
    cmdstanr = as.character(utils::packageVersion('cmdstanr')),
    cmdstan = as.character(cmdstanr::cmdstan_version()), session = sessionInfo(),
    scope = 'Conditional-model and ownership bridge only; no posterior sampling or interval qualification',
    completed = Sys.time())
  saveRDS(evidence, paste0(prefix, '-evidence.rds'))
  write.csv(checks, paste0(prefix, '-checks.csv'), row.names = FALSE)
  print(checks, row.names = FALSE)
  stopifnot(all(checks$Pass))
  invisible(evidence)
}

if (sys.nframe() == 0L) run_random_effects_brms_bridge()
