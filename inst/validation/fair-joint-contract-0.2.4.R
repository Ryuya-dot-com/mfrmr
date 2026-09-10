# Repository-only numerical/output checks; see interval-drf-preflight-protocol.
# Run from package root, with a new output directory as the first argument.
source('inst/validation/mml-independent-information-conditions-0.2.4.R')
pkgload::load_all('.', quiet=TRUE)
# Reuse only the archived oracle definition, not its top-level 40-fit pilot.
oracle <- parse('inst/validation/fair-score-refit-0.2.4.R')
for (expr in oracle) if (is.call(expr) && identical(expr[[1]], as.name('<-')) &&
  identical(expr[[2]], as.name('fair_reference'))) eval(expr)
out <- commandArgs(TRUE)[1]; stopifnot(!is.na(out), !dir.exists(out))
dir.create(out, recursive=TRUE)
files <- c(list.files('R', '[.]R$', full.names=TRUE),
  'inst/validation/fair-joint-contract-0.2.4.R',
  'inst/validation/interval-drf-preflight-protocol-0.2.4.md',
  'inst/validation/fair-score-refit-0.2.4.R',
  'inst/validation/mml-independent-information-conditions-0.2.4.R',
  'inst/validation/mml-independent-rsm-information-0.2.4.R')
hash <- tools::md5sum(files)
runs <- targets <- replay_checks <- list()
for (mi in 1:2) for (n in c(80L,320L)) for (exposure in c(3L,6L)) {
  model <- c('RSM','PCM')[mi]; id <- paste(model,n,exposure,sep='-')
  seed <- 73000000L + 10000L*mi + 100L*n + exposure
  x <- mml_information_fixture(model,'baseline',3L,seed,n,exposure)
  warnings <- character(); started <- proc.time()[['elapsed']]
  fitted <- list(); qtime <- numeric(2); rows <- list()
  error <- tryCatch(withCallingHandlers({
    for (qi in 1:2) {
      qt <- proc.time()[['elapsed']]
      fitted[[qi]] <- fit_mfrm(x$data,'Person',c('Rater','Criterion'),'Score',
        model=model, method='MML', step_facet=if(model=='PCM') 'Criterion' else NULL,
        rating_min=0,rating_max=2,quad_points=c(61L,121L)[qi],maxit=200L,reltol=1e-10)
      qtime[qi] <- proc.time()[['elapsed']]-qt
    }
    covs <- lapply(fitted,mfrmr:::compute_mml_parameter_covariance)
    stopifnot(all(vapply(fitted,mfrmr:::mfrm_inference_ready,logical(1))),
      all(vapply(covs,function(v) identical(v$status,'ok'),logical(1))))
    fa <- fair_average_table(fitted[[1]],reference='zero',udecimals=12)
    conditional <- plot_fair_average(fitted[[1]],metric='FairZ',show_ci=TRUE,draw=FALSE)$data$data
    for (j in 1:5) {
      a <- fair_reference(fitted[[1]]$opt$par,x,model,j)
      b <- fair_reference(fitted[[2]]$opt$par,x,model,j)
      v <- covs[[1]]$cov; g <- a$gradient
      se <- sqrt(as.numeric(t(g)%*%v%*%g))
      se_high <- sqrt(as.numeric(t(b$gradient)%*%covs[[2]]$cov%*%b$gradient))
      numerical <- mfrmr:::finite_difference_gradient(function(p) fair_reference(p,x,model,j)$value,fitted[[1]]$opt$par)
      transform <- diag(seq(.5,2,length.out=length(g)))[rev(seq_along(g)),,drop=FALSE]
      transformed_g <- as.vector(t(solve(transform))%*%g)
      transformed_v <- transform%*%v%*%t(transform)
      se_transformed <- sqrt(as.numeric(t(transformed_g)%*%transformed_v%*%transformed_g))
      facet <- if(j<=3) 'Rater' else 'Criterion'; level <- if(j<=3) paste0('R',j) else paste0('C',j-3)
      table <- fa$raw_by_facet[[facet]]; at <- match(level,table$Level)
      endpoint <- a$value+c(-1,1)*qnorm(.975)*se
      endpoint_high <- pmin(2,pmax(0,b$value+c(-1,1)*qnorm(.975)*se_high))
      r <- data.frame(Cell=id,Seed=seed,Target=paste(facet,level,sep=':'),
        Estimate=a$value,Truth=fair_reference(x$truth,x,model,j)$value,SE=se,
        UnclippedLower=endpoint[1],UnclippedUpper=endpoint[2],
        Lower=max(0,endpoint[1]),Upper=min(2,endpoint[2]),FairCIEligible=FALSE,
        GradientError=max(abs(numerical-g)),TableError=abs(table$FairZ[at]-a$value),
        CoordinateSEError=abs(se_transformed-se),
        JointToDiagonalSE=se/sqrt(sum(g*g*diag(v))),
        JointToConditionalSE=se/conditional$CI_SE[conditional$Facet==facet & conditional$Level==level],
        ScoreChange=b$value-a$value,RelativeSEChange=se_high/se-1,
        MaxEndpointChange=max(abs(endpoint_high-pmin(2,pmax(0,endpoint)))),
        MaxParameterChange=max(abs(fitted[[2]]$opt$par-fitted[[1]]$opt$par)),
        MaxPersonEAPChange=max(abs(fitted[[2]]$facets$person$Estimate-fitted[[1]]$facets$person$Estimate)),
        ObjectiveChange=fitted[[2]]$opt$value-fitted[[1]]$opt$value)
      rows[[j]] <- r
    }
    if(n==80L && exposure==3L) {
      data_file <- normalizePath(file.path(out,paste0(id,'-data.csv')),mustWork=FALSE)
      write.csv(x$data,data_file,row.names=FALSE)
      replay <- build_mfrm_replay_script(fitted[[1]],data_file=data_file,include_bundle=FALSE)
      writeLines(replay$script,file.path(out,paste0(id,'-replay.R')))
      env <- new.env(parent=globalenv()); eval(parse(text=replay$script),env)
      replay_checks[[mi]] <- data.frame(Model=model,
        ParameterError=max(abs(env$fit$opt$par-fitted[[1]]$opt$par)),
        ObjectiveError=abs(env$fit$opt$value-fitted[[1]]$opt$value),
        EAPError=max(abs(env$fit$facets$person$Estimate-fitted[[1]]$facets$person$Estimate)),
        Ready=identical(mfrmr:::mfrm_inference_ready(env$fit),mfrmr:::mfrm_inference_ready(fitted[[1]])))
    }
    ''
  },warning=function(w){warnings <<- c(warnings,conditionMessage(w));invokeRestart('muffleWarning')}),error=function(e)conditionMessage(e))
  targets <- c(targets,rows)
  runs[[length(runs)+1L]] <- data.frame(Cell=id,Seed=seed,Error=error,
    Warnings=paste(warnings,collapse=' | '),Q61FitSeconds=qtime[1],Q121FitSeconds=qtime[2],
    TotalSeconds=proc.time()[['elapsed']]-started)
  saveRDS(list(fixture=x,fits=fitted,error=error),file.path(out,paste0(id,'.rds')))
  cat(id,'error:',error,'\n'); flush.console()
}
runs <- do.call(rbind,runs); targets <- do.call(rbind,targets)
replay_checks <- do.call(rbind,replay_checks)
for (name in c('runs','targets','replay_checks')) write.csv(get(name),file.path(out,paste0(name,'.csv')),row.names=FALSE)
write.csv(data.frame(File=files,MD5=unname(hash)),file.path(out,'source-md5.csv'),row.names=FALSE)
writeLines(capture.output(sessionInfo()),file.path(out,'session-info.txt'))
stopifnot(identical(hash,tools::md5sum(files)),nrow(runs)==8L,all(runs$Error==''),
  nrow(targets)==40L,all(is.finite(targets$SE)),all(targets$GradientError<1e-7),
  all(targets$TableError<1e-9),all(targets$CoordinateSEError<1e-10),
  all(abs(targets$ScoreChange)<=1e-5),all(abs(targets$RelativeSEChange)<=.001),
  all(targets$MaxEndpointChange<=1e-5),nrow(replay_checks)==2L,
  all(replay_checks$ParameterError<1e-8),all(replay_checks$ObjectiveError<1e-8),
  all(replay_checks$EAPError<1e-8),all(replay_checks$Ready))
print(runs)
