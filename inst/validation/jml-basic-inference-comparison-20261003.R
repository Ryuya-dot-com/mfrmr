# Research-only ordinary / order-2 / order-4 inference on retained A/B fits.
# Existing numerical workers and public CI availability are never modified.
jml_basic_setup <- function() {
  source('inst/validation/mfrm-wide-map-pcm-r50-20261002.R');wide_pcm_setup()
  for(f in c('jml-public-profile-bridge-20261002.R','jml-gpcm-local-root-bound-20261003.R',
              'mfrm-wide-map-pcm-summary-20261003.R')) source(file.path('inst/validation',f))
}

jml_basic_policy <- function() list(level=.95,maximum_root_distance_in_sd=.01,
  minimum_jacobian_singular_value=1e-6,normalizations=c('asymptotic','finite_roster'),
  ordinary='Retained public beta; extended-profile Person scores, Schur derivative, local-root distance bound evaluated in floating point',
  corrected='Retained consistent root; stored full equation derivative and actual Person scores',
  interpretation='Research Wald candidates, not qualified structural-truth intervals')

jml_basic_map <- function(input,model) {
  stopifnot(model %in% c('PCM','GPCM'))
  levels <- input$levels;owners <- levels$Criterion;ns <- length(input$categories)-1L
  sizes <- c(lengths(levels),rep(ns,length(owners)),if(model=='GPCM')length(owners))
  H <- as.matrix(Matrix::bdiag(lapply(sizes,mfrmr:::sum_zero_jacobian)))
  targets <- c(unlist(lapply(names(levels),function(f)paste('location',f,levels[[f]],sep=':'))),
    unlist(lapply(owners,function(g)paste('step','Criterion',g,seq_len(ns),sep=':'))),
    if(model=='GPCM')paste('log_slope','Criterion',owners,sep=':'))
  reference <- c(unlist(input$truth[names(levels)]),as.vector(t(input$truth$steps)),
    if(model=='GPCM')input$truth$log_slopes)
  for(f in names(levels)) {
    ix <- match(paste('location',f,levels[[f]][1:2],sep=':'),targets)
    H <- rbind(H,H[ix[1],]-H[ix[2],]);targets <- c(targets,paste('contrast',f,paste(levels[[f]][1:2],collapse='-'),sep=':'))
    reference <- c(reference,input$truth[[f]][1]-input$truth[[f]][2])
  }
  list(H=H,targets=unname(targets),reference=unname(reference))
}

jml_basic_sandwich <- function(U,A,roster,policy=jml_basic_policy()) {
  N <- nrow(U);p <- ncol(U)
  stopifnot(length(roster)==N,!anyNA(roster),identical(dim(A),c(p,p)),
    all(is.finite(U)),all(is.finite(A)))
  if(any(table(roster)<2L))stop('Fixed-roster covariance needs at least two Persons per roster')
  if(N-length(unique(roster))<p)stop('Fixed-roster centered rank ceiling is below structural dimension')
  if(min(svd(A,nu=0,nv=0)$d)<=policy$minimum_jacobian_singular_value)
    stop('Complete equation derivative is singular or below conditioning threshold')
  centered <- U;weight <- numeric(N)
  for(g in unique(roster)) {
    ix <- which(roster==g);centered[ix,] <- sweep(U[ix,,drop=FALSE],2,colMeans(U[ix,,drop=FALSE]))
    weight[ix] <- length(ix)/(length(ix)-1)
  }
  if(qr(centered)$rank<p)stop('Actual centered Person scores do not span all structural coordinates')
  influence <- -centered%*%t(solve(A))
  list(asymptotic=crossprod(influence)/N^2,
       finite_roster=crossprod(influence*sqrt(weight))/N^2)
}

jml_basic_roster <- function(fit,persons) {
  data <- fit$prep$data;facets <- fit$config$facet_names
  cell <- interaction(data[facets],drop=TRUE)
  groups <- split(seq_len(nrow(data)),as.character(data$Person))
  key <- vapply(groups,function(ix)paste(tabulate(as.integer(cell[ix]),nlevels(cell)),collapse=':'),'')
  out <- unname(key[persons]);stopifnot(!anyNA(out));out
}

jml_basic_evaluate <- function(input,spec,fitting,stage,policy=jml_basic_policy()) {
  wide_recovery_plan(input,spec)
  stopifnot(spec$args$method=='JML',spec$args$model %in% c('PCM','GPCM'))
  map <- jml_basic_map(input,spec$args$model)
  beta <- NULL;covariances <- NULL;diagnostics <- list();reason <- fitting$error
  status <- if(nzchar(fitting$error))'error' else 'returned'
  if(!nzchar(fitting$error)) {
    fit <- fitting$value;wide_recovery_fit_identity(fit,input,spec)
    if(is.null(spec$args$jml_correction_order)) {
      ctx <- jml_bridge_context(fit);beta <- ctx$beta
      result <- tryCatch({
        # Only the scalar nuisance profiles are solved, with public beta fixed.
        profile <- jml_bridge_profile(ctx,beta)
        if(min(eigen(profile$hessian,symmetric=TRUE,only.values=TRUE)$values)<=0)
          stop('Nonpositive extended-profile curvature')
        U <- profile$scores;A <- profile$hessian/ctx$np
        V <- jml_basic_sandwich(U,A,ctx$roster,policy)
        bound <- jml_gpcm_local_root_bound(ctx,profile,V$asymptotic)
        distance <- if(isTRUE(bound$available))bound$summary$AllContrastDistanceInStoredRootSD else NA_real_
        admitted <- is.finite(distance)&&distance<=policy$maximum_root_distance_in_sd
        list(covariances=V,diagnostics=list(scores=U,jacobian=A,roster=ctx$roster,
          profile_theta=profile$theta,mean_score=max(abs(colMeans(U))),
          root_bound=bound,root_distance_in_sd=distance,admitted=admitted),
          reason=if(admitted)'' else 'Ordinary local-root distance bound unavailable or exceeds 0.01 stored SD')
      },error=function(e)list(reason=paste('Ordinary covariance unavailable:',conditionMessage(e))))
      covariances <- result$covariances;diagnostics <- result$diagnostics;reason <- result$reason
    } else {
      a <- fit$jml_adjustment
      stopifnot(spec$args$jml_correction_order %in% c(2L,4L),a$estimator$sampling=='fixed_rosters')
      if(isTRUE(a$point$available))beta <- a$point$beta
      reason <- paste('Corrected research interval unavailable:',a$point$status,a$covariance$status,a$covariance$reason)
      diagnostics <- list(root_status=a$point$status)
      if(identical(a$point$status,'consistent_roots')&&isTRUE(a$covariance$available)) {
        z <- a$covariance$result;roster <- jml_basic_roster(fit,a$persons)
        covariances <- jml_basic_sandwich(z$scores,z$jacobian,roster,policy)
        stopifnot(max(abs(covariances$asymptotic-z$vcov))<1e-10,
          z$sampling=='fixed_rosters',z$order==spec$args$jml_correction_order)
        diagnostics <- c(diagnostics,list(scores=z$scores,jacobian=z$jacobian,roster=roster))
        reason <- ''
      }
    }
    if(!is.null(beta)) {
      stopifnot(length(beta)==ncol(map$H),all(is.finite(beta)))
      parameters <- wide_recovery_parameters(fit,input)
      expected <- c(unlist(parameters[names(input$levels)],use.names=FALSE),as.vector(t(parameters$steps)),
        if(spec$args$model=='GPCM')unname(parameters$log_slopes))
      stopifnot(max(abs(head(drop(map$H%*%beta),length(expected))-expected))<1e-10)
    }
  }
  candidates <- lapply(policy$normalizations,function(normalization) {
    base <- data.frame(ConditionId=spec$ConditionId,Arm=spec$Arm,Replicate=spec$Replicate,
      Target=map$targets,InputId=input$InputId,Eligibility='eligible',Reference='generating_parameter',
      ReferenceValue=map$reference,CovarianceNormalization=normalization,
      FormalStructuralInference=FALSE,Level=policy$level)
    plan <- rbind(transform(base,Output='point'),transform(base,Output='interval'))
    r <- plan[c('ConditionId','Arm','Replicate','Target','Output')]
    r$Status <- status;r$Available <- FALSE;r$Estimate <- r$SE <- r$Lower <- r$Upper <- NA_real_
    r$SourceStage <- stage;r$Reason <- if(nzchar(reason))reason else 'Point unavailable'
    point <- r$Output=='point';ci <- !point
    if(!is.null(beta)) {
      estimate <- drop(map$H%*%beta);r$Estimate <- rep(estimate,2)
      r$Available[point] <- TRUE;r$Reason[point] <- ''
      if(!nzchar(reason)&&!is.null(covariances)) {
        variance <- rowSums((map$H%*%covariances[[normalization]])*map$H)
        se <- sqrt(pmax(0,variance));half <- qnorm((1+policy$level)/2)*se
        ok <- is.finite(variance)&variance>0&is.finite(estimate-half)&is.finite(estimate+half)
        slope <- startsWith(map$targets,'log_slope:')
        ok[slope] <- ok[slope]&is.finite(exp(estimate[slope]-half[slope]))&is.finite(exp(estimate[slope]+half[slope]))
        rows <- which(ci)[ok];r$Available[rows] <- TRUE;r$Reason[rows] <- ''
        r$SE[rows] <- se[ok];r$Lower[rows] <- estimate[ok]-half[ok];r$Upper[rows] <- estimate[ok]+half[ok]
        r$Reason[which(ci)[!ok]] <- 'Research interval requires positive variance and finite bounds'
      }
    }
    list(plan=plan,records=r,rows=wide_output_records(plan,r))
  });names(candidates) <- policy$normalizations
  list(candidates=candidates,diagnostics=diagnostics,covariances=covariances,map=map,
    policy=policy,stage=stage,interpretation='Original point retained, including interval refusals; research uncertainty around a local equation root does not remove structural bias')
}

jml_basic_job <- function(root,job,out) {
  m <- wide_f_read(file.path(root,'manifest.rds'))$payload
  stopifnot(identical(m$source,tools::md5sum(names(m$source))))
  j <- m$jobs[m$jobs$JobId==job,,drop=FALSE]
  stopifnot(nrow(j)==1L,j$Arm %in% c('PCM-JML','GPCM-JML','GPCM-JML2','GPCM-JML4'))
  dir <- file.path(root,job);paths <- file.path(dir,c('outputs.rds','calibration/manifest.rds','calibration/q0-fit.rds'))
  old <- wide_f_read(paths[1]);cm <- wide_f_read(paths[2])$payload;f <- wide_f_read(paths[3])
  stopifnot(identical(old$binding$job,j),identical(old$binding$source,m$source),
    isTRUE(old$payload$completed),cm$spec$Arm==j$Arm,cm$spec$Replicate==j$Replicate,
    cm$spec$ConditionId==j$ConditionId,
    identical(f$binding,list(job=wide_mml_hash(cm),order=0L,phase='fit',dependency=NULL)))
  input <- wide_recovery_ab_input(m$root,j$ConditionId,j$Replicate)
  stopifnot(identical(input$InputId,old$binding$input))
  sources <- file.path('inst/validation',c('jml-basic-inference-comparison-20261003.R',
    'jml-public-profile-bridge-20261002.R','jml-gpcm-local-root-bound-20261003.R'))
  binding <- list(numerical_manifest=tools::md5sum(file.path(root,'manifest.rds')),
    inputs=tools::md5sum(paths),source=tools::md5sum(sources),policy=jml_basic_policy())
  dir.create(out,recursive=TRUE,showWarnings=FALSE)
  wide_mml_phase(file.path(out,paste0(job,'.rds')),binding,function() {
    value <- jml_basic_evaluate(input,cm$spec,f$payload,paste0('initial:q0:',f$checksum))
    # Existing corrected intervals are an independent saved output contract.
    if(!is.null(old$payload$candidate)) {
      r <- value$candidates$asymptotic$records;r <- r[r$Output=='interval',]
      saved <- old$payload$candidate$records
      stopifnot(identical(r$Target,saved$Target),identical(r$Available,saved$Available),
        isTRUE(all.equal(r[c('Estimate','SE','Lower','Upper')],saved[c('Estimate','SE','Lower','Upper')],
          tolerance=1e-10,check.attributes=FALSE)))
    }
    value
  })
}

jml_basic_summary_tables <- function(saved,expected=1:50) {
  tables <- list(summary=list(),variation=list(),paired_points=list(),refusals=list())
  for(normalization in jml_basic_policy()$normalizations) {
    p <- do.call(rbind,lapply(saved,function(z)z$candidates[[normalization]]$plan))
    r <- do.call(rbind,lapply(saved,function(z)z$candidates[[normalization]]$records))
    x <- wide_output_records(p,r)
    stopifnot(setequal(unique(x$Arm),c('PCM-JML','GPCM-JML','GPCM-JML2','GPCM-JML4')))
    groups <- split(seq_len(nrow(x)),paste(x$ConditionId,x$Arm,x$Target,x$Output,sep='\r'))
    stopifnot(all(vapply(groups,function(i)setequal(x$Replicate[i],expected),TRUE)),
      all(x$Status %in% c('returned','error')))
    tables$summary[[normalization]] <- wide_output_summary(p,r)
    ci <- x[x$Output=='interval',]
    groups <- split(seq_len(nrow(ci)),paste(ci$ConditionId,ci$Arm,ci$Target,sep='\r'))
    tables$variation[[normalization]] <- do.call(rbind,lapply(groups,function(i) {
      z <- ci[i,];ok <- z$Available;v <- z$Estimate[ok];se <- z$SE[ok]
      empirical <- if(length(v)>1L)sd(v) else NA_real_
      data.frame(ConditionId=z$ConditionId[1],Arm=z$Arm[1],Target=z$Target[1],
        Planned=length(expected),Intervals=sum(ok),EmpiricalSD=empirical,
        MeanSE=if(any(ok))mean(se) else NA_real_,
        RootMeanEstimatedVariance=if(any(ok))sqrt(mean(se^2)) else NA_real_,
        ReportedToEmpiricalSDRatio=if(is.finite(empirical)&&empirical>0)sqrt(mean(se^2))/empirical else NA_real_,
        Conditioning='Same interval-delivered datasets for empirical SD and reported SE; all-point bias and availability are separate summary rows')
    }))
    arms <- unique(p$Arm)
    tables$paired_points[[normalization]] <- do.call(rbind,lapply(combn(arms,2,simplify=FALSE),function(a) {
      targets <- intersect(p$Target[p$Arm==a[1]],p$Target[p$Arm==a[2]])
      wide_paired_point_summary(p[p$Target %in% targets,],r[r$Target %in% targets,],a[1],a[2])
    }))
    refused <- x[x$Output=='interval'&!x$Available,]
    if(nrow(refused)) {
      keys <- c('ConditionId','Arm','Target','Status','Reason')
      tables$refusals[[normalization]] <- aggregate(rep(1L,nrow(refused)),refused[keys],sum)
      names(tables$refusals[[normalization]])[length(keys)+1L] <- 'Datasets'
    }
  }
  lapply(tables,function(group) {
    if(!length(group))return(data.frame())
    do.call(rbind,lapply(names(group),function(n)cbind(CovarianceNormalization=n,group[[n]])))
  })
}

jml_basic_condition <- function(root,condition,out) {
  registry <- wide_pcm_condition_files(root,condition)
  if(!registry$complete)stop(sprintf('Condition incomplete: %d/%d outputs. No inferential performance summary produced.',registry$finished,registry$expected))
  jobs <- registry$jobs[registry$jobs$Arm %in% c('PCM-JML','GPCM-JML','GPCM-JML2','GPCM-JML4'),]
  stopifnot(nrow(jobs)==200L)
  saved <- lapply(jobs$JobId,function(id)jml_basic_job(root,id,file.path(out,'jobs')))
  tables <- jml_basic_summary_tables(saved)
  binding <- list(condition=condition,jobs=tools::md5sum(file.path(out,'jobs',paste0(jobs$JobId,'.rds'))),
    source=tools::md5sum(c('inst/validation/jml-basic-inference-comparison-20261003.R',
      'inst/validation/mfrm-wide-map-output-summary-20261001.R')))
  value <- wide_mml_phase(file.path(out,'summary.rds'),binding,function()list(tables=tables,
    independent_datasets=50L,policy=jml_basic_policy(),note='Descriptive research comparison, no public interval qualification'))
  stopifnot(identical(tables,value$tables))
  for(n in names(tables))write.csv(tables[[n]],file.path(out,paste0(n,'.csv')),row.names=FALSE)
  invisible(value)
}

jml_basic_check <- function(root,condition,out) {
  rejects <- function(expr,pattern) {
    e <- tryCatch({force(expr);''},error=function(e)conditionMessage(e))
    stopifnot(grepl(pattern,e,fixed=TRUE));invisible(e)
  }
  U <- cbind(c(1,-1,1,-1),c(2,-2,-2,2));roster <- c(1,1,2,2)
  V <- jml_basic_sandwich(U,diag(2),roster)
  stopifnot(identical(unname(V$asymptotic),diag(c(.25,1))),
    isTRUE(all.equal(V$finite_roster,diag(c(.5,2)),tolerance=1e-14)))
  rejects(jml_basic_sandwich(U,diag(2),1:4),'at least two Persons')
  rejects(jml_basic_sandwich(cbind(U,1),diag(3),roster),'rank ceiling')
  rejects(jml_basic_sandwich(U,matrix(0,2,2),roster),'conditioning threshold')
  rejects(jml_basic_sandwich(cbind(U[,1],U[,1]),diag(2),roster),'do not span')
  registry <- wide_pcm_condition_files(root,condition)
  jobs <- registry$jobs[registry$jobs$Replicate==1 & registry$jobs$Arm %in%
    c('PCM-JML','GPCM-JML','GPCM-JML2','GPCM-JML4'),]
  stopifnot(nrow(jobs)==4L)
  saved <- lapply(jobs$JobId,function(id)jml_basic_job(root,id,file.path(out,'jobs')))
  paths <- file.path(out,'jobs',paste0(jobs$JobId,'.rds'));before <- tools::md5sum(paths)
  for(name in c('jml_bridge_profile','jml_gpcm_local_root_bound'))
    trace(name,tracer=quote(stop('Numerical reevaluation forbidden during replay')),print=FALSE,where=.GlobalEnv)
  on.exit(for(name in c('jml_bridge_profile','jml_gpcm_local_root_bound'))untrace(name,where=.GlobalEnv),add=TRUE)
  replay <- lapply(jobs$JobId,function(id)jml_basic_job(root,id,file.path(out,'jobs')))
  stopifnot(identical(saved,replay),identical(before,tools::md5sum(paths)))
  # A separate empty registry must be refused before any job computation.
  empty <- tempfile('jml-incomplete-');dir.create(empty)
  stopifnot(file.copy(file.path(root,'manifest.rds'),file.path(empty,'manifest.rds')))
  on.exit(unlink(empty,recursive=TRUE),add=TRUE)
  rejects(jml_basic_condition(empty,condition,file.path(empty,'summary')),'Condition incomplete: 0/400')
  cm <- wide_f_read(file.path(root,jobs$JobId[1],'calibration/manifest.rds'))$payload
  input <- wide_recovery_ab_input(registry$manifest$root,condition,1L)
  failed <- jml_basic_evaluate(input,cm$spec,list(error='declared fitting failure'),'failed-stage')
  stopifnot(all(vapply(failed$candidates,function(z)!any(z$records$Available)&&all(is.na(z$records$SE)),TRUE)))
  # Synthetic accounting only: 50 distinct IDs, 40 zero errors, 10 errors of 3;
  # five interval refusals among the zero errors. Never simulation evidence.
  fixture <- unlist(lapply(1:50,function(k)lapply(saved,function(z) {
    answer <- list(candidates=z$candidates)
    for(n in names(answer$candidates)) {
      a <- answer$candidates[[n]];a$plan$Replicate <- a$records$Replicate <- k
      a$plan$InputId <- paste0('synthetic-parent-',k);a$plan$ReferenceValue <- 0
      r <- a$records;r$Status <- 'returned';r$Available <- TRUE
      r$Estimate <- if(k<=40)0 else 3;r$SE <- r$Lower <- r$Upper <- NA_real_;r$Reason <- ''
      ci <- r$Output=='interval';r$SE[ci] <- 1;r$Lower[ci] <- r$Estimate[ci]-1;r$Upper[ci] <- r$Estimate[ci]+1
      if(k<=5) {r$Available[ci] <- FALSE;r$SE[ci] <- r$Lower[ci] <- r$Upper[ci] <- NA_real_;r$Reason[ci] <- 'synthetic refusal'}
      a$records <- r;answer$candidates[[n]] <- a
    };answer
  })),recursive=FALSE)
  tables <- jml_basic_summary_tables(fixture)
  s <- tables$summary;points <- s[s$Output=='point',];ci <- s[s$Output=='interval',]
  stopifnot(all(abs(points$MeanError-.6)<1e-12),all(abs(points$RMSE-sqrt(1.8))<1e-12),
    all(ci$Available==45),all(ci$Covered==35),all(abs(ci$ConditionalCoverage-35/45)<1e-12),
    all(abs(ci$ReturnedAndCovered-.7)<1e-12),all(abs(ci$MeanError-2/3)<1e-12),
    all(abs(tables$variation$EmpiricalSD-sqrt(70/44))<1e-12),
    all(tables$variation$MeanSE==1),all(tables$paired_points$MeanSquaredErrorDifference==0))
  rejects(jml_basic_summary_tables(fixture[-1]),'setequal')
  rejects(jml_basic_summary_tables(c(fixture,fixture[1])),'Duplicate selected output')
  evidence <- list(jobs=jobs,job_md5=before,policy=jml_basic_policy(),
    checks=c('Exact analytic sandwich and finite-roster factor','Singleton/rank/Jacobian refusals',
      'Four saved jobs and corrected interval replay','No-computation cache replay',
      'Incomplete condition refused before work','Fitting error retains all refusals',
      '50-ID synthetic bias/coverage/SD and paired accounting','Missing/duplicate dataset refusal'),
    synthetic_accounting=TRUE,source=tools::md5sum('inst/validation/jml-basic-inference-comparison-20261003.R'))
  path <- file.path(out,'verified.rds')
  if(file.exists(path))stopifnot(identical(readRDS(path),evidence)) else saveRDS(evidence,path)
  cat('All focused checks passed; no 50-dataset performance result has been produced.\n')
  invisible(evidence)
}

if(sys.nframe()==0L) {
  args <- commandArgs(trailingOnly=TRUE);stopifnot(length(args)==4L)
  jml_basic_setup()
  if(args[1]=='job')invisible(jml_basic_job(args[2],args[3],args[4])) else
    if(args[1]=='condition')jml_basic_condition(args[2],args[3],args[4]) else
      if(args[1]=='check')jml_basic_check(args[2],args[3],args[4]) else stop('Expected job, condition or check')
}
