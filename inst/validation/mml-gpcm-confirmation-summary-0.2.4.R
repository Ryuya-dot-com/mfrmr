# Post-run audit of registered preflight artifacts. No estimation or simulation.
source('inst/validation/mml-gpcm-confirmation-preflight-0.2.4.R')
confirmation_same_grid <- function(x,y) {
  identical(names(x),names(y)) && identical(nrow(x),nrow(y)) &&
    all(vapply(names(y),function(n) identical(x[[n]],y[[n]]),logical(1)))
}
confirmation_family <- function(x) {
  stopifnot(length(unique(x$Kind))==1L,length(unique(x$Method))==1L,
    length(unique(x$Adjustment))==1L,!anyDuplicated(x$Target))
  available <- all(x$Returned)
  data.frame(Targets=nrow(x),FamilyReturned=available,
    FamilyFinite=available && all(is.finite(x$Lower) & is.finite(x$Upper)),
    FamilyCovered=available && all(x$Lower<=x$Truth & x$Upper>=x$Truth))
}
confirmation_family_selfcheck <- function() {
  spec <- read.csv(file.path(confirmation_root,'preflight-plan.csv'))[1,]
  grid <- confirmation_targets(spec)$grid
  plain <- grid; attr(plain,'out.attrs') <- NULL
  stopifnot(confirmation_same_grid(plain,grid),
    !confirmation_same_grid(plain[nrow(plain):1,],grid))
  x <- confirmation_targets(spec)$rows[1:3,]
  x$Returned <- TRUE; x$Lower <- -Inf; x$Upper <- Inf
  stopifnot(confirmation_family(x)$FamilyCovered,!confirmation_family(x)$FamilyFinite)
  x$Returned[2] <- FALSE; x$Lower[2] <- x$Upper[2] <- NA_real_
  stopifnot(!confirmation_family(x)$FamilyReturned,!confirmation_family(x)$FamilyCovered)
}
confirmation_estimates <- function(fit,spec,grid) {
  p <- confirmation_decode(fit$opt$par)
  r <- match(grid$Rater,sprintf('R%02d',1:3)); c <- match(grid$Criterion,sprintf('C%02d',1:3))
  pr <- exp(confirmation_logprob(grid$Theta,r,c,p,spec$Owner))
  list(relative=p$slope,standardized=p$slope*p$sigma,ratio=p$slope[1:2]/p$slope[2:3],
    difference=(p$slope[1:2]-p$slope[2:3])*p$sigma,probability=as.vector(t(pr)),
    information=(drop(pr %*% (0:2)^2)-drop(pr %*% (0:2))^2)*p$slope[if(spec$Owner=='Rater')r else c]^2)
}
confirmation_summarize <- function() {
  confirmation_selfcheck(); confirmation_family_selfcheck()
  plan <- read.csv(file.path(confirmation_root,'preflight-plan.csv'))
  cases <- rows <- stages <- families <- list()
  for(i in seq_len(nrow(plan))) for(arm in c('current','ablation')) {
    spec <- plan[i,]; file <- file.path(confirmation_root,'preflight',sprintf('%s-%02d.rds',arm,spec$Cell))
    x <- if(file.exists(file))readRDS(file) else NULL
    t <- confirmation_targets(spec); d <- if(is.null(x))t$rows else x$rows
    if(!is.null(x)) {
      stopifnot(identical(x$spec,spec),identical(x$identity[['Runner']],unname(tools::md5sum(confirmation_runner))),
        identical(x$identity[['Manifest']],unname(tools::md5sum(file.path(confirmation_root,'source-manifest.csv')))),
        identical(x$identity[['Data']],unname(tools::md5sum(file.path(confirmation_root,'preflight-data',sprintf('cell-%02d.rds',spec$Cell))))))
    } else if(file.exists(sub('[.]rds$','.log',file))) {
      d$Attempted <- TRUE; d$Reason <- 'Worker started but no usable result artifact was saved; inspect log.'
    }
    prefix <- data.frame(Arm=arm,Cell=spec$Cell,Owner=spec$Owner,N=spec$N,RatersPerPerson=spec$RatersPerPerson,Slopes=spec$Slopes)
    rows[[length(rows)+1L]] <- cbind(prefix[rep(1,nrow(d)),],d)
    for(indices in split(seq_len(nrow(d)),interaction(d[c('Kind','Method','Adjustment')],drop=TRUE))) {
      group <- d[indices,]; confirmation_counts(group) # validates status, not independent-row inference
      families[[length(families)+1L]] <- cbind(prefix,group[1,c('Kind','Method','Adjustment')],confirmation_family(group))
    }
    reference <- x$reference
    if(is.null(reference)) reference <- data.frame(ProbabilityError=NA_real_,ObjectiveError=NA_real_,ObjectiveTolerance=NA_real_,
      ScaledGradientError=NA_real_,ContinuousNLL=NA_real_,ContinuousDifference=NA_real_,ContinuousReportedError=NA_real_)
    point_error <- NA_real_; q_objective <- q_slopes <- q_sd <- NA_real_
    aligned <- source_verified <- TRUE
    if(!is.null(x$fit)) {
      expected <- confirmation_estimates(x$fit,spec,t$grid)
      errors <- numeric()
      for(kind in names(expected)) {
        values <- split(d[d$Kind==kind,],interaction(d[d$Kind==kind,c('Method','Adjustment')],drop=TRUE))
        for(tab in values) {
          good <- is.finite(tab$Estimate)
          errors <- c(errors,abs(tab$Estimate[good]-expected[[kind]][good]))
        }
      }
      for(name in names(x$outputs)) {
        obj <- x$outputs[[name]]
        if(inherits(obj,'mfrm_curve_intervals')) {
          k <- if(obj$settings$type=='probability')3L else 1L
          indices <- rep(seq_len(nrow(t$grid)),each=k)
          aligned <- aligned && confirmation_same_grid(obj$newdata,t$grid) &&
            identical(as.integer(obj$table$InputRow),indices) &&
            confirmation_same_grid(obj$table[names(t$grid)],t$grid[indices,]) &&
            if(k==3L)identical(as.numeric(obj$table$Category),rep(as.numeric(1:3),nrow(t$grid))) else all(is.na(obj$table$Category))
          provenance <- obj$source
        } else {
          tab <- attr(obj,'diagnostics')
          expected_labels <- if(grepl('^(relative|standardized)_',name))sprintf('%s%02d',substr(spec$Owner,1,1),1:3) else rownames(t$contrasts)
          aligned <- aligned && identical(as.character(tab$SlopeFacet),expected_labels)
          provenance <- attr(obj,'source')
        }
        source_verified <- source_verified && identical(provenance$parameters,x$fit$opt$par) &&
          identical(provenance$objective,x$fit$opt$value) && identical(provenance$data,x$fit$prep$data) &&
          identical(provenance$integration,x$fit$config$estimation_control[c('quad_points','mml_integration')])
      }
      if(length(errors)) point_error <- max(errors)
      if(!is.null(x$q101)) {
        a <- confirmation_decode(x$fit$opt$par); b <- confirmation_decode(x$q101$opt$par)
        q_slopes <- max(abs(a$slope-b$slope)); q_sd <- abs(a$sigma-b$sigma)
        q_objective <- x$q101$opt$value-x$fit$opt$value
      }
    }
    rss <- NA_real_; log_status <- 'unavailable (time -l sysctl denied)'
    resource_file <- sub('[.]rds$','-resource.json',file)
    if(file.exists(resource_file)) {
      resource <- jsonlite::fromJSON(resource_file)
      rss <- resource$peak_rss_raw/1024^2; log_status <- paste('wait4',resource$exit_code)
    }
    cases[[length(cases)+1L]] <- cbind(prefix,ArtifactSaved=!is.null(x),FitReturned=!is.null(x$fit),
      SolutionEligible=isTRUE(x$check$eligible),Errors=length(x$errors),Elapsed=x$elapsed %||% NA_real_,
      PeakRSSMiB=rss,ResourceStatus=log_status,TargetOrderVerified=aligned,OutputSourceVerified=source_verified,
      PointEstimateError=point_error,
      Q101NLLChange=q_objective,Q101MaxRelativeSlopeChange=q_slopes,Q101PopulationSDChange=q_sd,
      LRTAvailable=identical(x$comparison$comparison_basis$lrt_status,'computed'),
      LRTPValue=if(!is.null(x$comparison$lrt$p_value))x$comparison$lrt$p_value else NA_real_,reference)
    if(!is.null(x$stages)) stages[[length(stages)+1L]] <- cbind(prefix,x$stages)
  }
  cases <- do.call(rbind,cases); rows <- do.call(rbind,rows); stages <- do.call(rbind,stages); families <- do.call(rbind,families)
  cases$NumericalReferencePass <- with(cases,is.finite(ProbabilityError) & ProbabilityError<=1e-10 &
    is.finite(ObjectiveError) & ObjectiveError<=ObjectiveTolerance & is.finite(ScaledGradientError) &
    ScaledGradientError<=1e-5 & TargetOrderVerified & OutputSourceVerified &
    is.finite(PointEstimateError) & PointEstimateError<=1e-10)
  # Preserve planned IDs and family group sizes; no list of just successful fits.
  stopifnot(nrow(cases)==32L,nrow(rows)==32L*472L,nrow(families)==32L*24L)
  for(name in c('cases','rows','stages','families')) write.csv(get(name),
    file.path(confirmation_root,paste0('preflight-',name,'.csv')),row.names=FALSE)
  a <- rows[rows$Arm=='current',]; b <- rows[rows$Arm=='ablation',]
  key <- function(x) do.call(paste,c(x[c('Cell','Kind','Method','Adjustment','Target')],sep='|'))
  ix <- match(key(a),key(b)); stopifnot(!anyNA(ix)); b <- b[ix,]
  pairs <- data.frame(a[c('Cell','Kind','Method','Adjustment','Target')],
    BothReturned=a$Returned & b$Returned,CurrentReturned=a$Returned,AblationReturned=b$Returned,
    EstimateDifference=a$Estimate-b$Estimate,LowerDifference=a$Lower-b$Lower,UpperDifference=a$Upper-b$Upper)
  write.csv(pairs,file.path(confirmation_root,'preflight-paired-rows.csv'),row.names=FALSE)
  cat('Case count:',nrow(cases),'reference passes:',sum(cases$NumericalReferencePass),
      'operation errors:',sum(cases$Errors),'\n')
  print(cases[,c('Arm','Cell','Elapsed','PeakRSSMiB','NumericalReferencePass','ContinuousDifference','Q101MaxRelativeSlopeChange')],row.names=FALSE)
  # Timing assumes the same process and target calls, not cached shared covariance.
  main <- sum(stages$Elapsed[!stages$Stage %in% c('q101_refit','reference')])*500
  q <- sum(stages$Elapsed[stages$Stage=='q101_refit'])*10
  ref <- sum(stages$Elapsed[stages$Stage=='reference'])
  complete <- all(cases$ArtifactSaved) && all(cases$Errors==0L)
  if(!complete) main <- q <- ref <- NA_real_
  endpoint_files <- file.path(confirmation_root,paste0('preflight-q101-',c('current','ablation'),'.csv'))
  endpoint <- if(all(file.exists(endpoint_files)))do.call(rbind,lapply(endpoint_files,read.csv)) else NULL
  endpoint_complete <- !is.null(endpoint) && nrow(endpoint)==32L && all(endpoint$Errors==0L)
  endpoint_seconds <- if(endpoint_complete)sum(endpoint$Elapsed)*10 else NA_real_
  forecast <- data.frame(CompleteEngineeringRun=complete,CoreSerialHours=main/3600,SelectedQ101SerialHours=q/3600,
    SelectedReferenceSerialHours=ref/3600,Q101EndpointAuditComplete=endpoint_complete,
    SelectedQ101EndpointSerialHours=endpoint_seconds/3600,
    IdealTwoWorkerHours=(main+q+ref+endpoint_seconds)/7200,
    StartupIOExcluded=TRUE,PreflightOnly=TRUE)
  write.csv(forecast,file.path(confirmation_root,'main-resource-preflight.csv'),row.names=FALSE)
  print(forecast)
  invisible(cases)
}
`%||%` <- function(x,y) if(is.null(x))y else x
confirmation_summarize()
