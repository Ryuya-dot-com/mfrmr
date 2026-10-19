test_that("continuous posterior bounds recover a normal prior, including small tails", {
  idx <- list(person=c(2L,1L),score_k=c(0L,3L),weight=c(0,0),step_idx=c(1L,1L))
  config <- list(model="RSM",n_cat=4L,n_person=2L)
  params <- list(steps=c(-1,0,1))
  population <- list(active=TRUE,design_matrix=matrix(c(1,2),2L,1L),coefficients=-0.8,
    sigma2=0.16,person_lookup=1:2)
  for (level in c(0.8,0.95,1-1e-10)) {
    actual <- mfrmr:::mfrmr_person_posterior_intervals(idx,config,params,c(0,0),c("A","B"),
      population,level)
    alpha <- (1-level)/2
    expected <- outer(c(-1.6,-0.8),0.4*c(qnorm(alpha),qnorm(alpha,lower.tail=FALSE)),"+")
    expect_equal(unname(actual),unname(expected),tolerance=1e-8)
  }
})

test_that("posterior endpoints carry their stated mass for weighted ordinal likelihoods", {
  for (model in c("RSM","PCM","GPCM")) for (n in c(4L,40L)) {
    owner <- rep(1:2,length.out=n)
    idx <- list(person=rep(1L,n),score_k=if(n==4L) 0:3 else rep(3L,n),
      weight=rep(c(0.25,1,2,0),length.out=n),step_idx=owner,slope_idx=owner)
    config <- list(model=model,n_cat=4L,n_person=1L)
    params <- list(steps=c(-0.8,0,0.8),steps_mat=rbind(c(-1.2,0.3,0.9),c(-0.4,-0.1,0.5)),
      slopes=c(0.6,1.5))
    base <- rep(c(-0.8,0.8),length.out=n)
    actual <- mfrmr:::mfrmr_person_posterior_intervals(idx,config,params,base,"P")
    steps <- if(model=="RSM") matrix(params$steps,n,3L,byrow=TRUE) else params$steps_mat[owner,]
    cumulative <- t(apply(steps,1L,function(x) c(0,cumsum(x))))
    slope <- if(model=="GPCM") params$slopes[owner] else rep(1,n)
    log_density <- function(theta) vapply(theta,function(value) {
      logits <- slope*(outer(value+base,0:3)-cumulative)
      high <- apply(logits,1L,max)
      sum(idx$weight*(logits[cbind(seq_len(n),idx$score_k+1L)]-high-
        log(rowSums(exp(logits-high)))))+dnorm(value,log=TRUE)
    },0)
    peak <- optimize(log_density,c(-12,12),maximum=TRUE)$objective
    density <- function(theta) exp(log_density(theta)-peak)
    mass <- integrate(density,-12,12,rel.tol=1e-11)$value
    cdf <- vapply(actual,function(value) integrate(density,-12,value,rel.tol=1e-11)$value/mass,0)
    expect_equal(unname(cdf),c(0.025,0.975),tolerance=1e-8)
  }
})

test_that("likelihood-only evaluation preserves weighted and shifted-prior kernels", {
  old <- options(mfrmr.use_cpp11_backend=TRUE)
  on.exit(options(old),add=TRUE)
  idx <- list(person=rep(1L,4L),score_k=0:3,weight=c(0,0.25,1,2),
    step_idx=c(2L,1L,2L,1L),slope_idx=c(2L,1L,2L,1L))
  params <- list(steps=c(-0.8,0,0.8),steps_mat=rbind(c(-1.2,0.3,0.9),c(-0.4,-0.1,0.5)),
    slopes=c(0.6,1.5))
  z <- c(-25,-3,0,0.4,4,25)
  for (model in c("RSM","PCM","GPCM")) {
    config <- list(model=model,n_cat=4L,n_person=1L,
      estimation_control=list(mml_integration="adaptive"))
    evaluate <- mfrmr:::mfrmr_adaptive_person_kernel(idx,config,params,c(-1,0,1,0.3),-0.8,0.4)
    expected <- evaluate(z)
    for (compiled in c(TRUE,FALSE)) {
      options(mfrmr.use_cpp11_backend=compiled)
      actual <- evaluate(z,include_moments=FALSE)
      expect_equal(actual$log_likelihood,expected$log_likelihood,tolerance=1e-12)
      expect_identical(evaluate(z),expected)
    }
  }
})

test_that("batched adaptive nodes preserve scalar probabilities and posterior derivatives", {
  withr::local_options(mfrmr.use_cpp11_backend = FALSE)
  for (model in c("RSM", "PCM", "GPCM")) for (n in c(1L, 4L)) {
    idx <- list(person = rep(1L, n), score_k = (seq_len(n) - 1L) %% 4L,
      weight = c(2, 0, .25, 1)[seq_len(n)], step_idx = c(2L, 1L, 2L, 1L)[seq_len(n)],
      slope_idx = c(1L, 2L, 2L, 1L)[seq_len(n)])
    config <- list(model = model, n_cat = 4L, n_person = 1L)
    params <- list(steps = c(-.8, 0, .8),
      steps_mat = rbind(c(-1.2, .3, .9), c(-.4, -.1, .5)), slopes = c(.6, 1.5))
    evaluate <- mfrmr:::mfrmr_adaptive_person_kernel(
      idx, config, params, c(-1, 0, 1, .3)[seq_len(n)], -.8, .4)
    z <- c(25, -.3, -25, 0, 1.2)
    batched <- evaluate(z, include_linear_part = TRUE)
    scalar <- lapply(z, evaluate, include_linear_part = TRUE)
    for (field in c("log_likelihood", "score", "information")) {
      expect_identical(batched[[field]], vapply(scalar, `[[`, 0, field))
    }
    expect_identical(batched$prob_list, lapply(scalar, function(x) x$prob_list[[1L]]))
    expect_identical(batched$linear_part_list, lapply(scalar, function(x) x$linear_part_list[[1L]]))
    # Differentiate the log posterior, independently of the category-moment formulas.
    log_posterior <- function(x) evaluate(x, include_moments = FALSE)$log_likelihood +
      dnorm(x, log = TRUE)
    h <- 1e-3
    z <- c(-1.2, .3, 2)
    score <- (log_posterior(z - 2*h) - 8*log_posterior(z - h) +
      8*log_posterior(z + h) - log_posterior(z + 2*h)) / (12*h)
    information <- (log_posterior(z + 2*h) - 16*log_posterior(z + h) +
      30*log_posterior(z) - 16*log_posterior(z - h) + log_posterior(z - 2*h)) / (12*h^2)
    expect_lt(max(abs(evaluate(z)$score - score)), 1e-8)
    expect_lt(max(abs(evaluate(z)$information - information)), 1e-7)
  }
})
