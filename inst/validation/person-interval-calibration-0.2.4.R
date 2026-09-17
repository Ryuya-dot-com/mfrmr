# See the fixed plan. Source after loading the current mfrmr package.
source("inst/validation/adaptive-quadrature-review-0.2.4.R")

person_interval_design <- function(model, n) {
  base <- -rep(c(-0.8, 0, 0.8), length.out = n)
  owned <- matrix(c(-1.2,0.3,0.9, -0.4,-0.1,0.5, -0.8,0.7,0.1), 3L, byrow = TRUE)
  owner <- rep(1:3, length.out = n)
  steps <- if (model == "RSM") matrix(c(-0.8,0,0.8), n, 3L, byrow = TRUE) else owned[owner, ]
  cumulative <- t(apply(steps, 1L, function(x) c(0, cumsum(x))))
  probability <- function(theta, item) {
    logits <- outer(theta + base[item], 0:3) - matrix(cumulative[item, ], length(theta), 4L, byrow = TRUE)
    p <- exp(logits - apply(logits, 1L, max))
    p / rowSums(p)
  }
  # At theta=0, convolve categorical probabilities without a package kernel.
  total <- 1
  for (item in seq_len(n)) {
    next_total <- numeric(length(total) + 3L)
    for (k in 0:3) next_total[seq_along(total) + k] <-
      next_total[seq_along(total) + k] + total * probability(0, item)[k + 1L]
    total <- next_total
  }
  stopifnot(all(total > 0), abs(sum(total) - 1) < 1e-12)
  config <- list(model = model, n_cat = 4L, n_person = 1L, facet_names = "Item")
  params <- list(facets = list(Item = -base), steps = c(-0.8,0,0.8), steps_mat = owned)
  list(model = model, n = n, base = base, owner = owner, steps = steps,
    cumulative = cumulative, probability = probability, total0 = total,
    config = config, params = params)
}

person_interval_reference <- function(design, total) {
  n <- design$n
  scores <- as.integer(pmin(3, pmax(0, total - 3 * (seq_len(n) - 1L))))
  denominator <- function(theta) vapply(theta, function(value) {
    logits <- outer(value + design$base, 0:3) - design$cumulative
    high <- apply(logits, 1L, max)
    sum(high + log(rowSums(exp(logits - high))))
  }, 0)
  at_zero <- denominator(0)
  log_density <- function(theta) log(design$total0[total + 1L]) + total * theta +
    at_zero - denominator(theta) + dnorm(theta, log = TRUE)
  mode <- optimize(log_density, c(-16,16), maximum = TRUE, tol = 1e-10)$maximum
  peak <- log_density(mode)
  density <- function(theta) exp(log_density(theta) - peak)
  integral <- function(lo, hi, multiplier = function(x) rep(1, length(x))) {
    if (lo == hi) return(c(value = 0, error = 0))
    x <- integrate(function(theta) density(theta) * multiplier(theta), lo, hi,
      rel.tol = 1e-11, abs.tol = 1e-12, subdivisions = 1000L)
    stopifnot(x$message == "OK")
    c(value = x$value, error = x$abs.error)
  }
  mass <- integral(-16, mode) + integral(mode, 16)
  prob_total <- exp(peak) * mass[1L]
  mean <- (integral(-16, mode, identity)[1L] + integral(mode, 16, identity)[1L]) / mass[1L]
  second <- function(theta) (theta - mean)^2
  sd <- sqrt((integral(-16, mode, second)[1L] + integral(mode, 16, second)[1L]) / mass[1L])
  separate <- aq_continuous_reference(scores, design$base, design$steps, rep(1,n), rep(1,n))
  stopifnot(max(abs(c(mean - separate["eap"], sd - separate["sd"]))) < 1e-7,
    mass[2L] / mass[1L] < 1e-9, 2 * pnorm(-16) / prob_total < 1e-12)
  cdf <- function(theta) vapply(theta, function(x) {
    if (x <= -16) return(0)
    if (x >= 16) return(1)
    if (x <= mode) integral(-16, x)[1L] / mass[1L] else
      1 - integral(x, 16)[1L] / mass[1L]
  }, 0)
  list(scores = scores, cdf = cdf, probability = unname(prob_total), mean = unname(mean), sd = unname(sd),
    quantile = function(p) uniroot(function(x) cdf(x) - p, c(-16,16), tol = 1e-10)$root,
    relative_error = unname(mass[2L] / mass[1L]), tail_bound = unname(2 * pnorm(-16) / prob_total))
}

run_person_interval_calibration <- function(output_dir) {
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  designs <- expand.grid(n = c(3L,6L,30L), model = c("RSM","PCM"), stringsAsFactors = FALSE)
  results <- reference <- list()
  for (id in seq_len(nrow(designs))) {
    d <- person_interval_design(designs$model[id], designs$n[id])
    message(id, "/6 ", d$model, " n=", d$n)
    for (total in 0:(3L*d$n)) {
      ref <- person_interval_reference(d, total)
      reference[[length(reference) + 1L]] <- data.frame(Design=id, Model=d$model, Ratings=d$n, Total=total,
        Probability=ref$probability, EAP=ref$mean, SD=ref$sd,
        RelativeError=ref$relative_error, TailBound=ref$tail_bound)
      idx <- list(person = rep(1L,d$n), facets = list(Item=seq_len(d$n)),
        step_idx = d$owner, score_k = ref$scores, weight = rep(1,d$n))
      for (level in c(0.8,0.95)) {
        alpha <- (1-level)/2
        oracle <- vapply(c(alpha,1-alpha), ref$quantile, 0)
        for (mode in c("fixed","adaptive")) for (q in c(31L,61L,121L)) {
          config <- d$config; config$estimation_control <- list(mml_integration=mode)
          posterior <- mfrmr:::compute_person_posterior_summary(idx,config,d$params,
            mfrmr:::gauss_hermite_normal(q),"P",interval_level=level)$estimates
          tails <- ref$cdf(c(posterior$Lower,posterior$Upper))
          results[[length(results)+1L]] <- data.frame(Design=id, Model=d$model, Ratings=d$n,
            Total=total, Level=level, Integration=mode, Order=q, Probability=ref$probability,
            EAP=posterior$Estimate, SD=posterior$SD, Lower=posterior$Lower, Upper=posterior$Upper,
            OracleLower=oracle[1L], OracleUpper=oracle[2L], EAPError=posterior$Estimate-ref$mean,
            SDError=posterior$SD-ref$sd, LowerCDF=tails[1L], UpperCDF=tails[2L],
            PosteriorMass=diff(tails), MaxTailError=max(abs(tails-c(alpha,1-alpha))),
            EndpointPass=all(abs(tails-c(alpha,1-alpha))<=1e-4), row.names=NULL)
        }
      }
    }
    write.csv(do.call(rbind,results),file.path(output_dir,"intervals.csv"),row.names=FALSE)
    write.csv(do.call(rbind,reference),file.path(output_dir,"reference.csv"),row.names=FALSE)
  }
  result <- do.call(rbind,results); ref <- do.call(rbind,reference)
  stopifnot(nrow(result)==2880L,nrow(ref)==240L,
    all(abs(tapply(ref$Probability,ref$Design,sum)-1)<1e-9))
  capture.output(sessionInfo(),file=file.path(output_dir,"session.txt"))
  invisible(result)
}

simulate_person_interval_coverage <- function(interval_dir, output_dir=interval_dir) {
  intervals <- read.csv(file.path(interval_dir,"intervals.csv"))
  stopifnot(nrow(intervals)==2880L)
  results <- strata <- list()
  for (id in 1:6) {
    rows <- intervals[intervals$Design==id,]
    design <- person_interval_design(rows$Model[1L],rows$Ratings[1L])
    set.seed(93000000L+1000L*id)
    theta <- rnorm(100000L); total <- integer(length(theta))
    for (item in seq_len(design$n)) {
      p <- design$probability(theta,item)
      total <- total+rowSums(runif(length(theta))>t(apply(p,1L,cumsum))[,1:3,drop=FALSE])
    }
    groups <- split(seq_along(theta),cut(theta,c(-Inf,-2,-1,0,1,2,Inf)))
    method <- interaction(rows$Level,rows$Integration,rows$Order,drop=TRUE)
    for (r in split(rows,method)) {
      index <- match(total,r$Total); stopifnot(!anyNA(index))
      covered <- theta>=r$Lower[index] & theta<=r$Upper[index]
      ci <- binom.test(sum(covered),length(theta))$conf.int
      common <- data.frame(Design=id,Model=design$model,Ratings=design$n,Level=r$Level[1L],
        Integration=r$Integration[1L],Order=r$Order[1L])
      results[[length(results)+1L]] <- cbind(common,Persons=length(theta),Coverage=mean(covered),
        MCLower=ci[1L],MCUpper=ci[2L],MCSE=sqrt(mean(covered)*(1-mean(covered))/length(theta)),
        IntegratedCoverage=sum(r$Probability*r$PosteriorMass),
        MeanWidth=mean(r$Upper[index]-r$Lower[index]),EAPRMSE=sqrt(mean((r$EAP[index]-theta)^2)),
        MeanPosteriorSD=mean(r$SD[index]))
      for (name in names(groups)) {
        ix <- groups[[name]]
        strata[[length(strata)+1L]] <- cbind(common,Stratum=name,Persons=length(ix),Coverage=mean(covered[ix]))
      }
    }
  }
  result <- do.call(rbind,results)
  stopifnot(nrow(result)==72L,all(abs(result$Coverage-result$IntegratedCoverage)<4*result$MCSE))
  dir.create(output_dir,recursive=TRUE,showWarnings=FALSE)
  write.csv(result,file.path(output_dir,"coverage.csv"),row.names=FALSE)
  write.csv(do.call(rbind,strata),file.path(output_dir,"strata.csv"),row.names=FALSE)
  invisible(result)
}
