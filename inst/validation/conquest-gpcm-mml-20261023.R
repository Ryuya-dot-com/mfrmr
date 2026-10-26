# Current-source item-only GPCM comparison, with raw ConQuest outputs retained.
# This script defines functions only; it never launches an external program.
# From the development root, load the validated mfrmr installation and source
# this file. Prepare an unused output directory, run its ConQuest commands in
# their own directories, run native() and compare(), then replay() in a fresh
# session. Retain settings and raw files; do not rerun successful fits merely
# to regenerate summaries. These functions implement this fixture, not a public
# general-purpose ConQuest importer.

cq_gpcm_prepare_20261023 <- function(out) {
  stopifnot(!file.exists(file.path(out, "fixture.rds")))
  dir.create(out, recursive = TRUE, showWarnings = FALSE)
  set.seed(20261023)
  persons <- sprintf("P%04d", 1:240)
  items <- sprintf("I%03d", 1:6)
  x <- rnorm(length(persons))
  theta <- 0.25 + 0.6*x + rnorm(length(persons), sd = 1.2)
  slopes <- c(0.65, 0.85, 1, 1.2, 1.5, 2)
  slopes <- slopes/exp(mean(log(slopes)))
  locations <- c(-1, -0.6, -0.2, 0.2, 0.6, 1)
  steps <- rbind(c(-1.4,-0.1,1.5),c(-1.1,-0.2,1.3),c(-0.9,0,0.9),
                 c(-1.3,0.2,1.1),c(-0.7,-0.1,0.8),c(-1.6,0.3,1.3))
  response <- vapply(seq_along(items), function(j) vapply(theta, function(t) {
    eta <- slopes[j]*((0:3)*(t-locations[j])-c(0,cumsum(steps[j,])))
    sample.int(4,1,prob=exp(eta-max(eta)))-1L
  }, 0L), integer(length(persons)))
  dimnames(response) <- list(persons, items)
  masked <- response
  masked[matrix(runif(length(response))<0.15,nrow(response))] <- NA_integer_
  stopifnot(all(rowSums(!is.na(masked)) > 0L))
  for (mat in list(response,masked)) {
    stopifnot(all(vapply(seq_along(items),function(j)
      all(table(factor(mat[,j],levels=0:3))>0),TRUE)))
  }
  fixture <- list(persons=persons,items=items,x=x,theta=theta,response=response,
    masked=masked,slopes=slopes,locations=locations,steps=steps,seed=20261023L)
  saveRDS(fixture,file.path(out,"fixture.rds"))
  # Review thresholds fixed before fitting; these are scoped numerical checks,
  # not coverage or global-optimum certification. CSV rounding is assessed too.
  settings <- list(cases=c("unconditional","regression","regression_missing"),
    nodes=c(31L,61L,121L),ranges=c(6,6,8),
    thresholds=c(coordinate=1e-4,probability=1e-5,deviance=1e-5,
      gradient=1e-3,relative_covariance=1e-3),
    native=list(integration="auto",quad_points=31L,maxit=1000L,reltol=1e-12),
    external=list(method="quadrature",convergence=1e-8,deviancechange=1e-10,
      iterations=4000L,stderr="empirical",positivescores=TRUE,scoresmax=20L,
      posterior_nodes=2000L,posterior_seeds=c(2L,3L)))
  saveRDS(settings,file.path(out,"settings.rds"))
  for (case in settings$cases) {
    mat <- if (case=="regression_missing") masked else response
    long <- expand.grid(Person=persons,Item=items,stringsAsFactors=FALSE)
    long$Score <- as.vector(mat)
    long <- long[!is.na(long$Score),]
    data <- list(long=long,person_data=data.frame(Person=persons,X=x),
      wide=data.frame(Person=persons,X=x,mat,check.names=FALSE),response=mat)
    dir.create(file.path(out,case),showWarnings=FALSE)
    saveRDS(data,file.path(out,case,"input.rds"))
    for (h in seq_along(settings$nodes)) {
      q <- settings$nodes[h]
      path <- file.path(out,case,paste0("cq",q))
      dir.create(path,showWarnings=FALSE)
      write.csv(data$wide,file.path(path,"input.csv"),row.names=FALSE,na=".",quote=FALSE)
      command <- c("reset;",
        "set lconstraints=cases, sconstraint=cases, scoresmax=20, exit_on_error=yes, p_nodes=2000, seed=2;",
        "datafile input.csv ! filetype=csv, columnlabels=yes, pid=Person, pidwidth=32, responses=I001 to I006, keeps=X, keepswidth=32;",
        "codes 0,1,2,3;",
        if (case!="unconditional") "regression X;",
        "model item + item*step ! type=scoresfree, positivescores=yes;",
        sprintf("estimate ! method=quadrature, nodes=%d, minnode=-%d, maxnode=%d, fit=no, stderr=empirical, matrixout=cq, convergence=0.00000001, deviancechange=0.0000000001, iterations=4000;",
          q,settings$ranges[h],settings$ranges[h]),
        vapply(c("parameters","tau","reg_coefficients","covariance","itemscores","amatrix","cmatrix"),
          function(s) sprintf("export %s ! filetype=csv >> %s.csv;",s,s),""),
        "write cq_history ! filetype=csv >> history.csv;",
        "write cq_estimatecovariances ! filetype=csv >> estimatecovariances.csv;",
        "show parameters ! tables=1:2:3:4:5:6:7, estimates=eap >> report.txt;",
        "put >> fitted.sys;",
        if (q==121L) c(
          "show cases ! estimates=eap, filetype=csv, regressors=yes >> eap_seed2.csv;",
          "set seed=3;",
          "show cases ! estimates=eap, filetype=csv, regressors=yes >> eap_seed3.csv;"),
        "quit;")
      writeLines(command,file.path(path,"commands.cqc"))
    }
  }
  invisible(settings)
}

cq_gpcm_native_20261023 <- function(out) {
  settings <- readRDS(file.path(out,"settings.rds"))
  for (case in settings$cases) {
    path <- file.path(out,case)
    if (file.exists(file.path(path,"native.rds"))) next
    data <- readRDS(file.path(path,"input.rds"))
    args <- list(data=data$long,person="Person",facets="Item",score="Score",
      model="GPCM",step_facet="Item",slope_facet="Item",mml_integration="auto",
      quad_points=31L,maxit=1000L,reltol=1e-12,anchor_policy="silent")
    if (case!="unconditional") {
      args$population_formula <- stats::as.formula("~ X",env=baseenv())
      args$person_data <- data$person_data
    }
    cat("Native",case,"\n"); flush.console()
    conditions <- character()
    elapsed <- system.time(fit <- withCallingHandlers(do.call(mfrmr::fit_mfrm,args),
      warning=function(w) { conditions <<- c(conditions,conditionMessage(w)); invokeRestart("muffleWarning") }))[["elapsed"]]
    sizes <- mfrmr:::build_param_sizes(fit$config)
    idx <- mfrmr:::build_indices(fit$prep,fit$config$step_facet,fit$config$slope_facet,fit$config$interaction_specs)
    reference <- mfrmr:::run_mfrm_direct_optimization(fit$opt$par,"MML",idx,
      fit$config,sizes,63L,1000L,1e-12)
    stopifnot(reference$convergence==0L)
    information <- mfrmr:::compute_mml_parameter_covariance(fit)
    saveRDS(list(fit=fit,args=args,elapsed=elapsed,warnings=conditions,
      reference63=reference,information=information),file.path(path,"native.rds"))
  }
}

cq_gpcm_read_20261023 <- function(path, regression) {
  read <- function(name) read.csv(file.path(path,paste0(name,".csv")),check.names=FALSE)
  xsi <- read("parameters"); tau <- read("tau"); beta <- read("reg_coefficients")
  latent <- read("covariance"); a <- read("amatrix"); c <- read("cmatrix")
  v <- read("estimatecovariances"); history <- read("history")
  labels <- trimws(c(xsi$Label,tau$Label,if(regression) "x"))
  stopifnot(nrow(xsi)==18L,nrow(tau)==6L,all(tau$Estimate>0 & tau$Estimate<20),
    beta$Estimate[1]==0,nrow(beta)==1L+regression,length(latent$Covariance)==1L,latent$Covariance==1,
    !anyDuplicated(labels),identical(trimws(names(v)[-1L]),labels),nrow(v)==length(labels),
    identical(a$GIN,rep(1:6,each=4)),identical(a$Category,rep(1:4,6)),
    identical(a$GIN,c$GIN),identical(a$Category,c$Category),all(c$Dimension==1))
  A <- as.matrix(a[,-(1:2)]); C <- as.matrix(c[,-(1:3)])
  expected_C <- matrix(0,24,6)
  for (i in 1:6) expected_C[(4*i-3):(4*i),i] <- 0:3
  V <- as.matrix(v[,-1L])
  stopifnot(qr(A)$rank==18L,identical(trimws(names(a)[-c(1,2)]),trimws(xsi$Label)),
    max(abs(C-expected_C))==0,max(abs(V-t(V)))<1e-12,
    min(eigen(V,symmetric=TRUE,only.values=TRUE)$values)>0)
  item_scores <- read("itemscores")
  stopifnot(all(item_scores$Category %in% 1:3),
    max(abs(item_scores$Score-item_scores$Category*tau$Estimate[item_scores$GIN]))<2.1e-6)
  report <- readLines(file.path(path,"report.txt"),warn=FALSE)
  stopifnot(any(grepl("deviance convergence criteria was reached",report,fixed=TRUE)))
  list(par=setNames(c(xsi$Estimate,tau$Estimate,if(regression) beta$Estimate[-1]),labels),
    A=A,C=C,cov=V,history=history,deviance=tail(history$LogLikelihood,1),
    regression=regression,path=path)
}

cq_gpcm_coordinates_20261023 <- function(fit, cq) {
  sizes <- mfrmr:::build_param_sizes(fit$config)
  expand <- function(par) mfrmr:::expand_params(par,sizes,fit$config)
  forward <- function(par) {
    p <- expand(par); sigma <- sqrt(p$population$sigma2)
    beta <- p$population$coefficients; a <- p$slopes
    logits <- a*(outer(p$facets$Item-beta[1],0:3)*(-1)-
      t(apply(p$steps_mat,1,function(x) c(0,cumsum(x)))))
    xi <- qr.solve(cq$A,as.vector(t(logits)))
    stopifnot(max(abs(cq$A%*%xi-as.vector(t(logits))))<1e-10)
    setNames(c(xi,sigma*a,if(cq$regression) beta[-1]/sigma),names(cq$par))
  }
  inverse <- function(par) {
    p <- expand(fit$opt$par)
    tau <- par[19:24]; sigma <- exp(mean(log(tau))); a <- tau/sigma
    intercepts <- matrix(cq$A%*%par[1:18],6,4,byrow=TRUE)
    adjacent <- -t(apply(intercepts,1,diff))/a
    delta <- rowMeans(adjacent); beta0 <- -mean(delta)
    p$facets$Item[] <- delta+beta0
    p$steps_mat[,] <- adjacent-delta
    p$slopes[] <- a; p$log_slopes[] <- log(a)
    p$population$coefficients[] <- c(beta0,if(cq$regression) sigma*par[25])
    p$population$sigma2 <- sigma^2; p$population$log_sigma2 <- log(sigma^2)
    mfrmr:::collapse_expanded_params(p,fit$config)
  }
  probability <- function(par,z=seq(-4,4,length.out=161)) {
    logits <- outer(as.vector(cq$C%*%par[19:24]),z)+as.vector(cq$A%*%par[1:18])
    vapply(seq_len(ncol(logits)),function(k) {
      m <- matrix(logits[,k],6,4,byrow=TRUE)
      m <- exp(m-apply(m,1,max)); as.vector(t(m/rowSums(m)))
    },numeric(24))
  }
  list(forward=forward,inverse=inverse,expand=expand,probability=probability)
}

cq_gpcm_compare_20261023 <- function(out) {
  source("inst/validation/adaptive-quadrature-review-0.2.4.R",local=environment())
  source("inst/validation/adaptive-optimization-probe-0.2.4.R",local=environment())
  settings <- readRDS(file.path(out,"settings.rds"))
  rows <- posteriors <- checks <- list()
  jacobian <- function(fn,par,h) vapply(seq_along(par),function(i) {
    plus <- minus <- par; plus[i] <- plus[i]+h; minus[i] <- minus[i]-h
    (fn(plus)-fn(minus))/(2*h)
  },numeric(length(par)))
  for (case in settings$cases) {
    cat("Compare",case,"\n"); flush.console()
    path <- file.path(out,case); saved <- readRDS(file.path(path,"native.rds"))
    fit <- saved$fit; context <- aqopt_context(fit,aq_continuous_reference)
    evaluate <- mfrmr:::mfrmr_make_adaptive_mml_evaluator(context$idx,fit$config,context$sizes,63L)
    grids <- lapply(settings$nodes,function(q) cq_gpcm_read_20261023(file.path(path,paste0("cq",q)),case!="unconditional"))
    native <- fit$opt$par; reference <- context$reference(native)
    map <- cq_gpcm_coordinates_20261023(fit,grids[[3]])
    cq_native <- map$forward(native)
    stopifnot(max(abs(map$inverse(cq_native)-native))<1e-11)
    J <- jacobian(map$forward,native,1e-5)
    Jhalf <- jacobian(map$forward,native,5e-6)
    stopifnot(max(abs(J-Jhalf))<1e-7,qr(J)$rank==length(native),
      saved$information$status=="ok",!saved$information$regularized)
    V <- J%*%saved$information$cov%*%t(J)
    H63 <- stats::optimHess(native,fn=function(p)evaluate(p)$value,gr=function(p)evaluate(p)$gradient)
    stopifnot(min(eigen(H63,symmetric=TRUE,only.values=TRUE)$values)>0)
    V63 <- J%*%solve(H63)%*%t(J)
    scale <- sqrt(outer(diag(V63),diag(V63)))
    pnative <- map$expand(native)
    sigma <- sqrt(pnative$population$sigma2); beta0 <- pnative$population$coefficients[1]
    table <- fit$facets$person[match(context$labels,fit$facets$person$Person),]
    stopifnot(identical(table$Person,context$labels))
    checks[[case]] <- data.frame(case=case,
      native_nll=evaluate(native)$value,continuous_nll=-sum(reference[,"log_marginal"]),
      native_gradient=max(abs(evaluate(native)$gradient)),
      native_q63_refit_movement=max(abs(saved$reference63$par-native)),
      native_eap_error=max(abs(table$Estimate-reference[,"eap"])),
      native_sd_error=max(abs(table$PosteriorSD-reference[,"sd"])),
      jacobian_halving=max(abs(J-Jhalf)),covariance_q63_difference=max(abs(V-V63)/scale),
      native_inference_ready=fit$summary$InferenceReady,
      continuous_relative_error=max(reference[,"relative_error"]),
      continuous_log_relative_tail_bound=max(reference[,"log_relative_tail_bound"]))
    comparison <- list()
    for (i in seq_along(grids)) {
      cq <- grids[[i]]; par <- map$inverse(cq$par); ev <- evaluate(par)
      stopifnot(max(abs(map$forward(par)-cq$par))<1e-11)
      prob_diff <- max(abs(map$probability(cq$par)-map$probability(cq_native)))
      rows[[length(rows)+1L]] <- data.frame(case=case,nodes=settings$nodes[i],
        cq_reported_deviance=cq$deviance,cq_continuous_deviance=2*ev$value,
        native_deviance=2*evaluate(native)$value,
        deviance_gap=2*(ev$value-evaluate(native)$value),
        reported_deviance_error=cq$deviance-2*ev$value,
        cq_gradient=max(abs(ev$gradient)),coordinate_difference=max(abs(cq$par-cq_native)),
        probability_difference=prob_diff,
        covariance_scaled_difference=max(abs(cq$cov-V63)/scale),
        covariance_relative_spectral=norm(cq$cov-V63,"2")/norm(V63,"2"),
        se_relative_difference=max(abs(sqrt(diag(cq$cov)/diag(V63))-1)),
        min_tau=min(cq$par[19:24]),max_tau=max(cq$par[19:24]))
      comparison[[i]] <- list(cq=cq,native_coordinates=par,evaluation=ev)
    }
    final_par <- comparison[[3]]$native_coordinates
    cq_reference <- context$reference(final_par)
    pcq <- map$expand(final_par); cq_sigma <- sqrt(pcq$population$sigma2)
    cq_beta0 <- pcq$population$coefficients[1]
    native_eap <- (reference[,"eap"]-beta0)/sigma
    native_sd <- reference[,"sd"]/sigma
    cq_eap <- (cq_reference[,"eap"]-cq_beta0)/cq_sigma
    cq_sd <- cq_reference[,"sd"]/cq_sigma
    posterior <- lapply(c(2,3),function(seed) {
      d <- read.csv(file.path(grids[[3]]$path,paste0("eap_seed",seed,".csv")),check.names=FALSE)
      d$PID <- trimws(d$PID)
      stopifnot(!anyDuplicated(d$PID),setequal(d$PID,context$labels))
      d <- d[match(context$labels,d$PID),]
      stopifnot(all(is.finite(d$EAP_1)),all(is.finite(d$PosteriorSD_1)))
      posteriors[[length(posteriors)+1L]] <<- data.frame(case=case,seed=seed,
        calibration_eap_difference=max(abs(cq_eap-native_eap)),
        calibration_sd_difference=max(abs(cq_sd-native_sd)),
        reported_eap_max_error=max(abs(d$EAP_1-cq_eap)),
        reported_eap_rmse=sqrt(mean((d$EAP_1-cq_eap)^2)),
        reported_sd_max_error=max(abs(d$PosteriorSD_1-cq_sd)),
        reported_sd_rmse=sqrt(mean((d$PosteriorSD_1-cq_sd)^2)))
      d
    })
    checks[[case]]$cq_continuous_nll_error <- abs(-sum(cq_reference[,"log_marginal"])-evaluate(final_par)$value)
    checks[[case]]$cq_seed_eap_difference <- max(abs(posterior[[1]]$EAP_1-posterior[[2]]$EAP_1))
    checks[[case]]$cq_seed_sd_difference <- max(abs(posterior[[1]]$PosteriorSD_1-posterior[[2]]$PosteriorSD_1))
    saveRDS(list(native_reference=reference,cq_reference=cq_reference,
      comparisons=comparison,J=J,Jhalf=Jhalf,V=V,V63=V63,H63=H63,posterior=posterior),
      file.path(path,"comparison.rds"))
  }
  write.csv(do.call(rbind,rows),file.path(out,"comparison.csv"),row.names=FALSE)
  write.csv(do.call(rbind,checks),file.path(out,"checks.csv"),row.names=FALSE)
  write.csv(do.call(rbind,posteriors),file.path(out,"posterior.csv"),row.names=FALSE)
  invisible(rows)
}

# Run in a fresh R session. Uses retained results, without repeating fits or
# continuous integration. A numerical pass does not grant inference readiness.
cq_gpcm_replay_20261023 <- function(out) {
  source("inst/validation/conquest-gpcm-overlap-contract-0.2.3.R",local=environment())
  settings <- readRDS(file.path(out,"settings.rds"))
  comparison <- read.csv(file.path(out,"comparison.csv"))
  checks <- read.csv(file.path(out,"checks.csv"))
  result <- list()
  for (case in settings$cases) {
    path <- file.path(out,case)
    saved <- readRDS(file.path(path,"native.rds"))
    detail <- readRDS(file.path(path,"comparison.rds"))
    cq <- cq_gpcm_read_20261023(file.path(path,"cq121"),case!="unconditional")
    for (q in settings$nodes) {
      other <- cq_gpcm_read_20261023(file.path(path,paste0("cq",q)),case!="unconditional")
      stopifnot(identical(other$A,cq$A),identical(other$C,cq$C),
        identical(names(other$par),names(cq$par)))
    }
    map <- cq_gpcm_coordinates_20261023(saved$fit,cq)
    native <- saved$fit$opt$par; p <- map$expand(native)
    contract <- mfrmr_cq_gpcm_transform(p$population$coefficients[1],
      p$population$coefficients[-1],p$population$sigma2,p$slopes,
      p$facets$Item,p$steps_mat)
    z <- seq(-4,4,length.out=161)
    proof <- mfrmr_cq_gpcm_probability_audit(contract,
      p$population$coefficients[1]+sqrt(p$population$sigma2)*z)
    # Audit helper orders item, ability, category; the exported design orders
    # item/category within each ability. Align explicitly, never by blind sort.
    proof_prob <- array(proof$Detail$MfrmrProbability,c(4,length(z),6))
    design_prob <- map$probability(map$forward(native),z)
    aligned <- matrix(aperm(proof_prob,c(1,3,2)),24,length(z))
    design_error <- max(abs(aligned-design_prob))
    stopifnot(design_error<1e-12,proof$MaxAbsProbabilityDifference<1e-12,
      max(abs(map$forward(map$inverse(cq$par))-cq$par))<1e-11,
      identical(cq$par,detail$comparisons[[3]]$cq$par),
      identical(unname(cq$cov),unname(detail$comparisons[[3]]$cq$cov)))
    last <- comparison[comparison$case==case & comparison$nodes==121,]
    check <- checks[checks$case==case,]
    public_error <- abs(saved$fit$opt$value+sum(detail$native_reference[,"log_marginal"]))
    checks$public_nll_continuous_error[match(case,checks$case)] <- public_error
    criteria <- c(coordinate=last$coordinate_difference,probability=last$probability_difference,
      deviance=abs(last$deviance_gap),gradient=last$cq_gradient,
      relative_covariance=last$covariance_scaled_difference)
    stopifnot(all(is.finite(criteria)),public_error<1e-7,
      abs(check$native_nll-check$continuous_nll)<1e-7,
      check$cq_continuous_nll_error<1e-7,check$native_eap_error<1e-6,
      check$native_sd_error<1e-6,!check$native_inference_ready)
    result[[case]] <- data.frame(case=case,criterion=names(criteria),value=unname(criteria),
      threshold=unname(settings$thresholds[names(criteria)]),
      passed=criteria<=settings$thresholds[names(criteria)],
      design_probability_error=design_error)
  }
  result <- do.call(rbind,result)
  write.csv(checks,file.path(out,"checks.csv"),row.names=FALSE)
  write.csv(result,file.path(out,"criteria.csv"),row.names=FALSE)
  print(result,row.names=FALSE)
  invisible(result)
}
