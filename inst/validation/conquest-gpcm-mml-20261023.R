# Current-source item-only GPCM comparison, with raw ConQuest outputs retained.
# This script defines functions only; it never launches an external program.

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
