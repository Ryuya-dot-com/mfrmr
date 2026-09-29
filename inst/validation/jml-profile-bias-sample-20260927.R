# Sample-level engineering check of one-step profile-score recentering.
# Not a public estimator or a repeated-sampling coverage study.
# Rscript inst/validation/jml-profile-bias-sample-20260927.R [output-directory]
source('inst/validation/jml-profile-bias-exact-20260927.R')
if (!requireNamespace('nleqslv', quietly = TRUE)) stop('Local validation requires nleqslv.')

jml_sample_jacobian <- function(fn, beta, h) vapply(seq_along(beta), function(j) {
  lo <- hi <- beta; lo[j] <- lo[j] - h; hi[j] <- hi[j] + h
  (fn(hi) - fn(lo))/(2*h)
}, numeric(length(fn(beta))))

jml_sample_root <- function(p, weights, adjusted, start,
  method = if(adjusted) "Broyden" else "Newton",
  global = if(adjusted) "cline" else "dbldog") {
  fn <- function(beta) p$mean_score(beta, weights, adjusted)
  # Raw JML has an objective; the adjusted equation is not a likelihood score.
  prefit <- NULL
  if (!adjusted) {
    prefit <- optim(start, function(beta) sum(weights*p$evaluate(beta)$q), fn,
      method = 'BFGS', control = list(maxit = 500, reltol = 1e-12))
    start <- prefit$par
  }
  z <- nleqslv::nleqslv(start, fn,
    method = method, global = global,
    control = list(ftol = 1e-10, xtol = 1e-11, maxit = 150, stepmax = 1))
  A1 <- jml_sample_jacobian(fn, z$x, 1e-4)
  A2 <- jml_sample_jacobian(fn, z$x, 5e-5)
  singular <- svd(A2, nu = 0, nv = 0)$d
  error <- max(abs(A1-A2))/max(1,max(abs(A2)))
  residual <- max(abs(fn(z$x)))
  reviewed <- residual < 1e-7 && min(singular) > 1e-6 && error < 1e-5 &&
    (adjusted || min(eigen((A2+t(A2))/2, symmetric = TRUE)$values) > 0)
  list(beta = z$x, reviewed = reviewed, A = A2, A_other = A1,
    residual = residual, jacobian_error = error, min_singular = min(singular),
    solver = z, likelihood_prefit = prefit)
}

jml_sample_covariance <- function(p, weights, n_persons, beta, adjusted, A) {
  if (length(weights) != p$n || any(!is.finite(weights)) || any(weights < 0) ||
      abs(sum(weights)-1) > 1e-10 || length(n_persons) != 1 ||
      !is.finite(n_persons) || n_persons <= length(beta)) stop('Invalid sample weights or size.')
  U <- p$scores(beta, adjusted)
  mean <- drop(crossprod(weights,U))
  centered <- sweep(U,2,mean)
  B <- crossprod(centered,weights*centered)
  # No ridge or pseudoinverse: unidentified covariance stays unavailable.
  if (min(svd(A, nu = 0, nv = 0)$d) <= 1e-6 ||
      qr(sqrt(weights)*centered)$rank < length(beta))
    stop('Insufficient rank for this sample covariance.')
  inverse <- solve(A)
  V <- inverse %*% B %*% t(inverse) / n_persons
  list(vcov = V, meat = B, scores = U, mean = mean,
    influence = -centered %*% t(inverse))
}

jml_sample_checks <- function(p, weights, N, fit, adjusted, ids,
  perturbations = c(1e-4,5e-5)) {
  covariance <- jml_sample_covariance(p,weights,N,fit$beta,adjusted,fit$A)
  # Expanded Person contributions independently check frequency aggregation.
  individual <- covariance$scores[ids,,drop = FALSE]
  empirical <- crossprod(sweep(individual,2,colMeans(individual)))/N
  # Influence covariance is computed in observation space, with A^{-T} on the right.
  IF <- -t(solve(fit$A,t(sweep(individual,2,colMeans(individual)))))
  V_ref <- crossprod(IF)/N^2
  check <- c(score_aggregation = max(abs(colMeans(individual)-p$mean_score(fit$beta,weights,adjusted)))<1e-10,
    meat_aggregation = max(abs(empirical-covariance$meat))<1e-10,
    covariance_influence = max(abs(V_ref-covariance$vcov))<1e-10,
    covariance_symmetric = max(abs(covariance$vcov-t(covariance$vcov)))<1e-10,
    covariance_positive = min(eigen(covariance$vcov,symmetric = TRUE)$values)>0,
    extreme_limits = all(covariance$scores[p$extreme,] == 0))
  doubled <- jml_sample_covariance(p,weights,2*N,fit$beta,adjusted,fit$A)
  check['sample_size_scaling'] <- max(abs(doubled$vcov-covariance$vcov/2))<1e-12
  rank_one <- rep(0,p$n); rank_one[ids[1]] <- 1
  refused <- try(jml_sample_covariance(p,rank_one,N,fit$beta,adjusted,fit$A),silent = TRUE)
  check['rank_failure_refused'] <- inherits(refused,'try-error')
  # Actual re-solving under small empirical-frequency perturbations checks
  # the FULL derivative (including theta_hat and the generating expectation).
  direction_id <- which.max(rowSums(covariance$influence^2)*as.numeric(weights>0))
  direction <- -weights; direction[direction_id] <- direction[direction_id]+1
  finite_difference <- list()
  for(h in perturbations) {
    plus <- jml_sample_root(p,weights+h*direction,adjusted,fit$beta)
    minus <- jml_sample_root(p,weights-h*direction,adjusted,fit$beta)
    derivative <- (plus$beta-minus$beta)/(2*h)
    error <- max(abs(derivative-covariance$influence[direction_id,])) /
      max(1,max(abs(covariance$influence[direction_id,])))
    finite_difference[[as.character(h)]] <- list(plus = plus,minus = minus,
      relative_error = error,pattern = direction_id)
  }
  check['refitted_influence'] <- all(vapply(finite_difference,function(x)
    x$plus$reviewed && x$minus$reviewed && x$relative_error<1e-3,logical(1)))
  list(covariance = covariance, checks = check, influence_refits = finite_difference)
}

run_jml_sample_review <- function() {
  args <- commandArgs(trailingOnly = TRUE)
  out <- if(length(args)) args[[1]] else 'validation-results/jml-profile-bias-sample-20260927'
  if (file.exists(file.path(out,'results.rds'))) stop('Refusing to overwrite completed evidence.')
  dir.create(out, recursive = TRUE, showWarnings = FALSE)
  conditions <- expand.grid(Owner = c('Criterion','Rater'), Repeats = 1:2,
    stringsAsFactors = FALSE)
  N <- 400L
  # One dataset per existing design, for implementation checks only. No coverage claim.
  ability <- c(-1,0,1); mixing <- c(.25,.5,.25)
  starts <- list(neutral = c(0,0,-.8,-.8,0), opposing = c(-.3,.4,-.3,-1.1,-.25))
  population <- read.csv('validation-results/jml-profile-bias-roots-20260927/resolved-roots.csv')
  old <- readRDS('validation-results/jml-profile-bias-exact-20260927-plugin/results.rds')
  results <- list(); rows <- list(); checks <- list(); attempts <- list()
  for (i in seq_len(nrow(conditions))) {
    owner <- conditions$Owner[i]; repeats <- conditions$Repeats[i]
    p <- make_jml_exact_problem(owner, repeats)
    set.seed(20260927L + i)
    theta <- sample(ability,N,replace = TRUE,prob = mixing)
    ids <- vapply(theta,function(t) sample.int(p$n,1,prob = p$mass(p$truth,t)),integer(1))
    weights <- tabulate(ids,nbins = p$n)/N
    # Preserve observed responses, not merely estimated parameters or population weights.
    cells <- expand.grid(Rater = 1:2,Criterion = 1:2)
    response <- do.call(rbind,lapply(seq_along(ids),function(k) {
      do.call(rbind,lapply(1:4,function(j) data.frame(Person = k,
        Rater = cells$Rater[j],Criterion = cells$Criterion[j],
        Score = rep(0:2,p$counts[[j]][ids[k],]))))
    }))
    label <- paste(owner,4*repeats,sep = '-')
    write.csv(response,file.path(out,paste0(label,'-responses.csv')),row.names = FALSE)
    for (adjusted in c(FALSE,TRUE)) {
      method <- if(adjusted) 'one_step' else 'raw'
      key <- paste(label,method,sep = '-')
      reference <- if(adjusted) old[[i]]$plugin_adjusted_gradient else old[[i]]$profile_gradient
      stopifnot(max(abs(p$scores(p$truth,adjusted)-reference)) < 1e-12)
      fits <- lapply(names(starts),function(start) {
        attempt <- tryCatch(jml_sample_root(p,weights,adjusted,starts[[start]]),
          error = function(e) list(reviewed = FALSE,error = conditionMessage(e)))
        attempts[[paste(key,start,sep = '-')]] <<- attempt
        saveRDS(attempt,file.path(out,paste0(key,'-',start,'.rds')))
        attempt
      })
      accepted <- which(vapply(fits,`[[`,logical(1),'reviewed'))
      spread <- if(length(accepted)>1) max(abs(fits[[accepted[1]]]$beta-fits[[accepted[2]]]$beta)) else NA_real_
      # Require both starts, rather than choosing whichever produces a desired estimate.
      row <- data.frame(Owner = owner,Ratings = 4*repeats,Method = method,Persons = N,
        ExtremePersons = sum(p$extreme[ids]),AcceptedStarts = length(accepted),
        StartSpread = spread,Reviewed = length(accepted)==2 && is.finite(spread) && spread<1e-6,
        FirstSlope = NA_real_,LogSlopeSE = NA_real_,SlopeDeltaSE = NA_real_,
        MaxTruthError = NA_real_,MaxPopulationRootDifference = NA_real_,
        ScoreResidual = NA_real_,JacobianAsymmetry = NA_real_,Error = NA_character_)
      if(row$Reviewed) {
        fit <- fits[[accepted[1]]]
        verified <- jml_sample_checks(p,weights,N,fit,adjusted,ids)
        covariance <- verified$covariance
        check <- verified$checks
        finite_difference <- verified$influence_refits
        target <- population[population$Owner==owner & population$Ratings==4*repeats &
          population$Method==method & population$Start=='neutral',
          c('Rater','Criterion','Step1','Step2','LogSlope')]
        row$FirstSlope <- exp(fit$beta[5]); row$LogSlopeSE <- sqrt(covariance$vcov[5,5])
        row$SlopeDeltaSE <- row$FirstSlope*row$LogSlopeSE
        row$MaxTruthError <- max(abs(fit$beta-p$truth))
        row$MaxPopulationRootDifference <- max(abs(fit$beta-as.numeric(target[1,])))
        row$ScoreResidual <- fit$residual
        row$JacobianAsymmetry <- max(abs(fit$A-t(fit$A)))
        checks[[key]] <- check
        results[[key]] <- list(fit = fit,covariance = covariance,checks = check,
          influence_refits = finite_difference,ids = ids,weights = weights,theta = theta,
          response = response,summary = row)
      } else {
        row$Error <- paste(vapply(fits,function(x) if(is.null(x$error)) '' else x$error,character(1)),collapse = '; ')
        results[[key]] <- list(fits = fits,ids = ids,weights = weights,response = response,summary = row)
      }
      rows[[key]] <- row
      saveRDS(results[[key]],file.path(out,paste0(key,'-review.rds')))
      print(row,row.names = FALSE); flush.console()
    }
  }
  summary <- do.call(rbind,rows); rownames(summary) <- NULL
  saveRDS(results,file.path(out,'results.rds'))
  saveRDS(attempts,file.path(out,'attempts.rds'))
  write.csv(summary,file.path(out,'summary.csv'),row.names = FALSE)
  writeLines(capture.output(sessionInfo()),file.path(out,'sessionInfo.txt'))
  paths <- c('inst/validation/jml-profile-bias-exact-20260927.R',
    'inst/validation/jml-profile-bias-sample-20260927.R',
    'validation-results/jml-profile-bias-roots-20260927/resolved-roots.csv')
  write.csv(data.frame(Path=paths,SHA256=vapply(paths,function(f)
    digest::digest(file=f,algo='sha256'),character(1))),file.path(out,'sources.csv'),row.names = FALSE)
  # An unresolved sample is retained and fails this engineering gate.
  stopifnot(nrow(summary)==8,all(summary$Reviewed),all(unlist(checks)))
  invisible(results)
}
# Follow-ups are deliberately separate: retain initial solver and perturbation failures.
run_jml_sample_followup <- function() {
  args <- commandArgs(trailingOnly = TRUE)
  out <- if(length(args)) args[[1]] else 'validation-results/jml-profile-bias-sample-20260927'
  initial <- readRDS(file.path(out,'results.rds'))
  if(file.exists(file.path(out,'followup-results.rds'))) stop('Refusing to overwrite follow-up evidence.')
  resolved <- initial
  key <- 'Rater-8-one_step'
  p <- make_jml_exact_problem('Rater',2)
  x <- initial[[key]]
  # Retry the original failed start, without warm-starting at the successful root.
  repaired <- jml_sample_root(p,x$weights,TRUE,c(-.3,.4,-.3,-1.1,-.25),
    method = 'Newton',global = 'dbldog')
  saveRDS(repaired,file.path(out,'followup-Rater-8-one_step-opposing.rds'))
  spread <- max(abs(repaired$beta-x$fits[[1]]$beta))
  if(repaired$reviewed && spread<1e-6) {
    verified <- jml_sample_checks(p,x$weights,length(x$ids),repaired,TRUE,x$ids)
    row <- x$summary
    row$Reviewed <- TRUE; row$AcceptedStarts <- 2; row$StartSpread <- spread
    row$FirstSlope <- exp(repaired$beta[5])
    row$LogSlopeSE <- sqrt(verified$covariance$vcov[5,5])
    row$SlopeDeltaSE <- row$FirstSlope*row$LogSlopeSE
    row$MaxTruthError <- max(abs(repaired$beta-p$truth))
    pop <- read.csv('validation-results/jml-profile-bias-roots-20260927/resolved-roots.csv')
    pop <- pop[pop$Owner=='Rater' & pop$Ratings==8 & pop$Method=='one_step' &
      pop$Start=='neutral',c('Rater','Criterion','Step1','Step2','LogSlope')]
    row$MaxPopulationRootDifference <- max(abs(repaired$beta-as.numeric(pop[1,])))
    row$ScoreResidual <- repaired$residual
    row$JacobianAsymmetry <- max(abs(repaired$A-t(repaired$A)))
    row$Error <- NA_character_
    resolved[[key]] <- c(list(fit=repaired,summary=row,ids=x$ids,weights=x$weights),verified)
  }
  # Weak raw JML is highly nonlinear at the first frequency-perturbation sizes.
  # Reduce the step, not the acceptance tolerance, and retain both original errors.
  key <- 'Criterion-4-raw'; x <- initial[[key]]
  p <- make_jml_exact_problem('Criterion',1)
  verified <- jml_sample_checks(p,x$weights,length(x$ids),x$fit,FALSE,x$ids,
    perturbations=c(1e-5,5e-6))
  resolved[[key]]$checks <- verified$checks
  resolved[[key]]$influence_refits <- verified$influence_refits
  saveRDS(resolved,file.path(out,'followup-results.rds'))
  rows <- do.call(rbind,lapply(resolved,function(x) {
    row <- x$summary
    row$AllChecks <- length(x$checks)==9 && all(x$checks)
    row$MaxRefitInfluenceError <- if(length(x$influence_refits))
      max(vapply(x$influence_refits,`[[`,numeric(1),'relative_error')) else NA_real_
    row
  }))
  rownames(rows) <- NULL
  write.csv(rows,file.path(out,'resolved-summary.csv'),row.names=FALSE)
  writeLines(digest::digest(file='inst/validation/jml-profile-bias-sample-20260927.R',
    algo='sha256'),file.path(out,'followup-runner-sha256.txt'))
  print(rows,row.names=FALSE)
  stopifnot(all(rows$Reviewed),all(rows$AllChecks))
}
if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  if('--followup' %in% args) run_jml_sample_followup() else run_jml_sample_review()
}
