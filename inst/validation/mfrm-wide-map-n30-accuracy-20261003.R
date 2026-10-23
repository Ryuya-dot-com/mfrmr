# Read-only numerical/statistical review of the completed N30 condition.
# No fitting, nuisance root solving, simulation, scoring or numerical derivatives.
wide_n30_generator_bound <- function(ctx, diagnostics) {
  bound <- diagnostics$root_bound
  if(!isTRUE(bound$available)) return(NULL)
  B <- bound$transform; radius <- bound$summary$RootMetricRadius
  beta <- ctx$beta; nl <- ncol(ctx$lin[[1L]]); p <- length(beta)
  theta <- diagnostics$profile_theta; D <- numeric(length(ctx$y))
  scores <- matrix(0,ctx$np,p); H <- matrix(0,p,p)
  for(i in seq_along(ctx$groups)) {
    rows <- ctx$groups[[i]]
    if(is.infinite(theta[i])) {
      stopifnot(all(ctx$y[rows]==if(theta[i]<0)0L else ctx$K-1L)); next
    }
    z <- jml_bridge_person(ctx,beta,theta[i],rows)
    h <- z$hessian[1L,1L]; c <- z$hessian[-1L,1L]
    stopifnot(h>0)
    scores[i,] <- z$gradient[-1L]
    H <- H+z$hessian[-1L,-1L]-tcrossprod(c)/h
    for(row in rows) {
      s <- ctx$slope[row,]
      gamma <- drop(crossprod(B,c(rep(0,nl),s)))
      g <- radius*sqrt(sum(gamma^2))
      a <- exp(sum(s*if(p>nl)beta[(nl+1L):p] else numeric()))
      pair <- combn(seq_len(ctx$K),2L)
      changes <- apply(pair,2L,function(k) {
        gap <- k[2L]-k[1L]
        d <- ctx$lin[[k[2L]]][row,]-ctx$lin[[k[1L]]][row,]
        ft <- drop(crossprod(B,c(d,rep(0,p-nl))-gap*c/h))
        f_norm <- sqrt(gap^2/h+sum(ft^2))
        f0 <- gap*theta[i]+sum(d*beta[seq_len(nl)])
        a*(abs(f0)*expm1(g)+exp(g)*radius*f_norm)
      })
      D[row] <- max(changes)
    }
  }
  stopifnot(max(abs(scores-diagnostics$scores))<1e-10,
    max(abs(H/ctx$np-diagnostics$jacobian))<1e-10)
  list(row_logit_span=D,maximum_row_tv=min(1,max(D)/4),
    joint_tv=min(1,sqrt(sum(D^2))/4),
    scope='Floating evaluation of a local-root perturbation bound, not an outward-rounded/global/truth bound')
}

wide_n30_accuracy <- function(root,out) {
  source('inst/validation/mfrm-wide-map-pcm-r50-20261002.R');wide_pcm_setup()
  source('inst/validation/jml-public-profile-bridge-20261002.R')
  for(name in c('optim','nlminb','uniroot','optimHess'))
    trace(name,tracer=quote(stop('New estimation forbidden in saved-result audit')),
      print=FALSE,where=asNamespace('stats'))
  on.exit(for(name in c('optim','nlminb','uniroot','optimHess'))
    untrace(name,where=asNamespace('stats')),add=TRUE)
  dependencies <- character()
  read <- function(path) {
    z <- wide_f_read(path);dependencies <<- union(dependencies,path);z
  }
  summary_dir <- file.path(root,'summary-n30')
  original <- read(file.path(summary_dir,'summary.rds'))
  research <- read(file.path(summary_dir,'jml-inference/summary.rds'))
  stopifnot(identical(original$binding$outputs,tools::md5sum(names(original$binding$outputs))),
    identical(research$binding$jobs,tools::md5sum(names(research$binding$jobs))))
  m <- read(file.path(root,'manifest.rds'))$payload
  stopifnot(identical(m$source,tools::md5sum(names(m$source))))
  jobs <- original$payload$jobs
  stopifnot(nrow(jobs)==400L,all(table(jobs$Arm)==50L),
    all(jobs$ConditionId=='AB:paired-L1:N30:SD1:S-PCM'))
  inputs <- lapply(1:50,function(i)wide_recovery_ab_input(m$root,jobs$ConditionId[1L],i))
  for(input in inputs) {
    dependencies <- union(dependencies,names(input$provenance$bundle))
    roster <- split(input$data,as.character(input$data$Person))
    key <- vapply(roster,function(d)paste(sort(unique(d$Rater)),collapse=':'),'')
    stopifnot(nrow(input$data)==180L,length(roster)==30L,
      all(lengths(lapply(roster,rownames))==6L),all(table(key)==10L))
  }
  jobs_out <- phases <- probabilities <- ordinary <- contrasts <- paired_rms <- intervals <- list()
  export <- function(job,phase,kind,grid,pars) {
    values <- cbind(Theta=grid$Theta,Rater=unname(pars$Rater[grid$Rater]),
      Criterion=unname(pars$Criterion[grid$Criterion]),
      LogSlope=unname(pars$log_slopes[grid$Criterion]),
      pars$steps[grid$Criterion,,drop=FALSE])
    colnames(values)[5:7] <- paste0('Step',1:3)
    logits <- exp(values[,4L])*(outer(values[,1L]-values[,2L]-values[,3L],0:3)-
      t(apply(values[,5:7,drop=FALSE],1L,function(x)c(0,cumsum(x)))))
    P <- matrix(0,nrow(grid),4L)
    finite <- is.finite(grid$Theta)
    if(any(finite)) {
      e <- exp(logits[finite,,drop=FALSE]-apply(logits[finite,,drop=FALSE],1L,max))
      P[finite,] <- e/rowSums(e)
    }
    P[grid$Theta==-Inf,1L] <- 1;P[grid$Theta==Inf,4L] <- 1
    stopifnot(all(is.finite(P)),max(abs(rowSums(P)-1))<1e-12)
    all <- cbind(values,P);colnames(all)[8:11] <- paste0('P',0:3)
    hex <- as.data.frame(lapply(as.data.frame(all),function(x)sprintf('%a',x)))
    cbind(data.frame(JobId=job$JobId,Arm=job$Arm,Replicate=job$Replicate,
      Phase=phase,Kind=kind,Row=seq_len(nrow(grid))),hex)
  }
  scalar <- function(x)if(length(x)==1L&&is.numeric(x))as.numeric(x) else NA_real_
  for(i in seq_len(nrow(jobs))) {
    job <- jobs[i,,drop=FALSE]; input <- inputs[[job$Replicate]]
    directory <- file.path(root,job$JobId)
    record <- read(file.path(directory,'outputs.rds'))$payload
    stopifnot(identical(record$job,job),isTRUE(record$completed))
    selected <- read(file.path(directory,'calibration/selected.rds'))$payload
    q0 <- if(grepl('MML',job$Arm))31L else 0L
    point_ready <- !nzchar(selected$point$error)&&isTRUE(selected$point$value$ready)
    source_reason <- paste(selected$point$value$reason_codes,collapse=';')
    integration <- selected$point$value$local_calibration_review$integration
    check <- selected$point$value$local_calibration_review$checks
    jr <- NULL
    if(grepl('JML',job$Arm))jr <- read(file.path(summary_dir,'jml-inference/jobs',paste0(job$JobId,'.rds')))$payload
    jobs_out[[i]] <- data.frame(JobId=job$JobId,Arm=job$Arm,Replicate=job$Replicate,
      InitialNumericalPass=record$initial$numerical_pass,SourceReady=point_ready,
      SourceStage=selected$point$stage,SourceReason=source_reason,
      SelectedNLLChange=scalar(integration$NLLChange),
      SelectedGradientChange=scalar(integration$GradientChange),
      SelectedComparisonGradient=scalar(integration$ComparisonGradient),
      SelectedComparisonOrder=scalar(integration$ComparisonOrder),
      SelectedEquationResidual=scalar(check['equation_residual']),
      SelectedRemainingStep=scalar(check['remaining_step']))
    if(grepl('MML',job$Arm))for(consumer in c('rater','criterion')) {
      result <- selected$intervals[[consumer]]; v <- result$value
      nc <- v$numerical_checks
      intervals[[paste(job$JobId,consumer)]] <- data.frame(JobId=job$JobId,Arm=job$Arm,
        Replicate=job$Replicate,Consumer=consumer,Stage=result$stage,
        Available=all(result$table$Available),
        ComparisonRecorded=!is.null(nc),
        CurvatureScaledGradient=scalar(nc$CurvatureScaledGradient),
        InverseResidual=scalar(nc$InverseResidual),
        ComparisonInverseResidual=scalar(nc$ComparisonInverseResidual),
        QuadratureScoreShift=scalar(nc$QuadratureScoreShift),
        QuadratureCovarianceChange=scalar(nc$QuadratureCovarianceChange))
    }
    initial <- record$initial$results
    initial <- initial[initial$Analysis=='initial_finite_return' & grepl('^contrast:',initial$Target),]
    initial$Truth <- record$initial$plan$ReferenceValue[match(initial$Target,record$initial$plan$Target)]
    initial$Error <- initial$Estimate-initial$Truth
    initial$NumericalPass <- record$initial$numerical_pass
    initial$ResearchIntervalAvailable <- FALSE
    if(!is.null(jr)) {
      ci <- jr$candidates$asymptotic$records
      ci <- ci[ci$Output=='interval',]
      initial$ResearchIntervalAvailable <- ci$Available[match(initial$Target,ci$Target)]
    }
    initial$JobId <- job$JobId;contrasts[[i]] <- initial
    grid_p <- list()
    for(q in as.integer(names(selected$stages))) {
      phase <- paste0('q',q)
      f <- read(file.path(directory,'calibration',paste0(phase,'-fit.rds')))$payload
      pr <- NULL
      if(!nzchar(f$error)) {
        fit <- f$value; pars <- wide_recovery_parameters(fit,input)
        if(all(is.finite(unlist(pars)))) {
          pr <- wide_recovery_probabilities(input,pars)
          probabilities[[paste(job$JobId,phase,'grid')]] <- export(job,phase,'fixed_theta_grid',input$grid,pars)
          grid_p[[phase]] <- pr
          stopifnot(max(abs(pr-matrix(as.numeric(unlist(lapply(
            probabilities[[paste(job$JobId,phase,'grid')]][paste0('P',0:3)],
            function(x)as.numeric(x)))),ncol=4L)))<1e-14)
        }
        phases[[paste(job$JobId,phase)]] <- data.frame(JobId=job$JobId,Arm=job$Arm,
          Replicate=job$Replicate,Phase=phase,SelectedPoint=identical(selected$point$stage,paste0(phase,':',wide_mml_hash(f))),
          MinSlope=if(is.null(pr))NA_real_ else min(exp(pars$log_slopes)),
          MaxSlope=if(is.null(pr))NA_real_ else max(exp(pars$log_slopes)))
        if(q==0L && job$Arm %in% c('PCM-JML','GPCM-JML')) {
          dg <- jr$diagnostics;ctx <- jml_bridge_context(fit)
          gb <- if(length(dg$profile_theta))wide_n30_generator_bound(ctx,dg) else NULL
          ordinary[[job$JobId]] <- data.frame(JobId=job$JobId,Arm=job$Arm,Replicate=job$Replicate,
            RootAdmitted=isTRUE(dg$admitted),RootBoundAvailable=isTRUE(dg$root_bound$available),
            RootDistanceSD=scalar(dg$root_distance_in_sd),
            RootMetricRadius=scalar(dg$root_bound$summary$RootMetricRadius),
            MaxRowTV=if(is.null(gb))NA_real_ else gb$maximum_row_tv,
            JointGeneratorTV=if(is.null(gb))NA_real_ else gb$joint_tv,
            ExtremePersons=if(length(dg$profile_theta))sum(is.infinite(dg$profile_theta)) else NA_integer_,
            Reason=jr$candidates$asymptotic$records$Reason[jr$candidates$asymptotic$records$Output=='interval'][1L])
          if(length(dg$profile_theta)) {
            g <- data.frame(Theta=dg$profile_theta[as.integer(fit$prep$data$Person)],
              Rater=as.character(fit$prep$data$Rater),Criterion=as.character(fit$prep$data$Criterion))
            probabilities[[paste(job$JobId,phase,'generator')]] <- export(job,phase,'profile_generator',g,pars)
          }
        }
      }
    }
    if(length(grid_p)>1L) {
      p0 <- grid_p[[paste0('q',q0)]]
      for(phase in setdiff(names(grid_p),paste0('q',q0))) {
        diff <- grid_p[[phase]]-p0
        paired_rms[[paste(job$JobId,phase)]] <- data.frame(JobId=job$JobId,Arm=job$Arm,
          Replicate=job$Replicate,Phase=phase,MaxProbabilityChange=max(abs(diff)),
          GridRMSChange=sqrt(mean(diff^2)))
      }
    }
    if(i%%50L==0L)cat('Read',i,'of 400 saved jobs\n')
  }
  tables <- lapply(list(jobs=jobs_out,phases=phases,ordinary=ordinary,contrasts=contrasts,
    refinement_probability=paired_rms,intervals=intervals),function(x)do.call(rbind,x))
  dir.create(out,recursive=TRUE,showWarnings=FALSE)
  for(n in names(tables))write.csv(tables[[n]],file.path(out,paste0(n,'.csv')),row.names=FALSE)
  probability_input <- do.call(rbind,probabilities)
  write.csv(probability_input,file.path(out,'probability-input.csv'),row.names=FALSE)
  binding <- list(input=tools::md5sum(dependencies),source=tools::md5sum(c(
    'inst/validation/mfrm-wide-map-n30-accuracy-20261003.R',
    'inst/validation/jml-public-profile-bridge-20261002.R')),runtime=wide_mml_runtime())
  wide_mml_phase(file.path(out,'audit.rds'),binding,function()list(tables=tables,
    probability_input=tools::md5sum(file.path(out,'probability-input.csv')),
    jobs=400L,independent_inputs=50L,new_fits=0L,new_generated_datasets=0L,
    root_scope='Local-root floating diagnostics; probability recovery is distinct from arithmetic error'))
  stopifnot(identical(m$source,tools::md5sum(names(m$source))))
  invisible(tables)
}

if(sys.nframe()==0L) {
  args <- commandArgs(trailingOnly=TRUE);stopifnot(length(args)==2L)
  wide_n30_accuracy(args[1L],args[2L])
}
