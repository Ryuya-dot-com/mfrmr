# Separate aggregation/verification; does not change the frozen simulation payload.
source('inst/validation/person-estimated-calibration-0.2.4.R')

pec_cluster <- function(y,n) {
  stopifnot(length(y)==length(n),all(is.finite(n)),all(n>=0),all(is.finite(y[n>0])))
  y[n==0] <- 0
  if(!length(n) || sum(n)==0) return(list(estimate=NA_real_,mcse=NA_real_,influence=numeric()))
  value <- sum(n*y)/sum(n)
  influence <- n*(y-value)/mean(n)
  list(estimate=value,mcse=if(length(n)>1) sd(influence)/sqrt(length(n)) else NA_real_,
    influence=influence)
}

pec_summarize <- function(directory,output=directory) {
  meta <- readRDS(file.path(directory,'metadata.rds'))
  files <- list.files(directory,pattern='^cell-[0-9]+-rep-[0-9]+[.]rds$',full.names=TRUE)
  values <- lapply(files,function(path) {
    x <- readRDS(path)
    stopifnot(identical(x$payload,meta$Payload))
    x[c('status','metrics')]
  })
  stopifnot(length(values)>0)
  statuses <- do.call(rbind,lapply(values,`[[`,'status'))
  metrics <- do.call(rbind,lapply(values,function(x) cbind(Cell=x$status$Cell,
    Replicate=x$status$Replicate,x$metrics)))
  stopifnot(!anyDuplicated(paste(statuses$Cell,statuses$Replicate)),
    !anyDuplicated(paste(metrics$Cell,metrics$Replicate,metrics$Method,metrics$NewRatings,metrics$Stratum)))
  plan <- mml_coverage_cells(); counts <- summaries <- list()
  for(cell in 1:8) {
    s <- statuses[statuses$Cell==cell,]
    availability <- mml_coverage_binomial(sum(s$Available),nrow(s))
    count <- cbind(plan[cell,],Stage=meta$Stage,Assigned=meta$Planned,Attempted=nrow(s),
      Available=sum(s$Available),AvailabilityLower=availability['Lower'],
      AvailabilityUpper=availability['Upper'],FitReady=sum(s$FitReady),
      ScoringReady=sum(s$ScoringReady),NumericalConflicts=sum(s$Available & !s$NumericalOK),
      Errors=sum(nzchar(s$Error)),WarningTrials=sum(nzchar(s$Warnings)),
      MeanSeconds=if(nrow(s)) mean(s$Seconds) else NA_real_,row.names=NULL)
    counts[[cell]] <- count
    if(!nrow(s)) next
    m <- metrics[metrics$Cell==cell,]
    for(exposure in c(3L,6L)) for(stratum in unique(m$Stratum)) {
      selected <- m[m$NewRatings==exposure & m$Stratum==stratum,]
      for(metric in c('Coverage','MeanWidth','Bias','MSE','MeanSD','ExtremeRate')) {
        for(method in c('known_all','known_paired','estimated','paired_difference','available_and_covered')) {
          if(method=='available_and_covered' && (metric!='Coverage' || stratum!='All')) next
          ids <- if(method %in% c('known_all','available_and_covered')) s$Replicate else
            s$Replicate[s$Available]
          vector <- function(name) {
            r <- selected[selected$Method==name,]; index <- match(ids,r$Replicate)
            n <- r$Persons[index]; y <- r[[metric]][index]
            n[is.na(n)] <- 0; y[n==0] <- 0
            list(y=y,n=n)
          }
          known <- vector('known'); estimated <- vector('estimated')
          if(method=='available_and_covered') {
            estimated$n <- rep(512,length(ids))
          }
          a <- if(method %in% c('known_all','known_paired')) known else estimated
          result <- pec_cluster(a$y,a$n)
          if(method=='paired_difference') {
            stopifnot(identical(known$n,estimated$n))
            result <- pec_cluster(estimated$y-known$y,known$n)
          }
          b <- length(ids); half <- if(b>1) qt(.975,b-1)*result$mcse else NA_real_
          row <- data.frame(Cell=cell,Stage=meta$Stage,NewRatings=exposure,Stratum=stratum,
            Method=method,Metric=metric,CalibrationReplicates=b,Persons=sum(a$n),
            Estimate=result$estimate,MCSE=result$mcse,Lower=result$estimate-half,Upper=result$estimate+half,
            Disposition=if(meta$Stage=='preflight') 'preflight_only' else 'descriptive')
          if(method=='estimated' && metric=='Coverage' && stratum=='All' && meta$Stage=='main') {
            row$Disposition <- if(nrow(s)!=meta$Planned ||
              !isTRUE(availability['Lower']>=.98) || count$NumericalConflicts>0) 'review' else
              mml_coverage_range(row$Lower,row$Upper,c(.93,.97))
          }
          summaries[[length(summaries)+1L]] <- row
          if(metric=='MSE' && method!='paired_difference') {
            row$Metric <- 'RMSE'; row$Estimate <- sqrt(result$estimate)
            row$MCSE <- result$mcse/(2*row$Estimate)
            half <- if(b>1) qt(.975,b-1)*row$MCSE else NA_real_
            row$Lower <- row$Estimate-half; row$Upper <- row$Estimate+half
            summaries[[length(summaries)+1L]] <- row
          }
        }
      }
    }
  }
  dir.create(output,recursive=TRUE,showWarnings=FALSE)
  write.csv(statuses,file.path(output,'runs.csv'),row.names=FALSE)
  write.csv(metrics,file.path(output,'replicate-metrics.csv'),row.names=FALSE)
  write.csv(do.call(rbind,counts),file.path(output,'counts.csv'),row.names=FALSE)
  write.csv(do.call(rbind,summaries),file.path(output,'summary.csv'),row.names=FALSE)
  invisible(do.call(rbind,counts))
}

pec_self_check <- function(directory) {
  results <- list()
  check <- function(name,condition,error=NA_real_) {
    stopifnot(isTRUE(condition))
    results[[length(results)+1L]] <<- data.frame(Check=name,Pass=condition,MaxError=error)
  }
  c <- pec_cluster(c(.8,1),c(512,512))
  check('equal clusters use calibration-level MCSE',abs(c$estimate-.9)<1e-15 && abs(c$mcse-.1)<1e-15)
  d <- pec_cluster(c(.8,.9)-c(.9,1),c(512,512))
  check('paired cluster differences preserve covariance',abs(d$estimate+.1)<1e-15 && d$mcse<1e-15)
  d <- pec_cluster(c(1,0,NA),c(2,1,0))
  check('stratum ratio retains zero-count clusters',abs(d$estimate-2/3)<1e-15 && length(d$influence)==3)
  meta <- readRDS(file.path(directory,'metadata.rds'))
  for(cell in c(1L,5L)) {
    x <- readRDS(file.path(directory,sprintf('cell-%02d-rep-0001.rds',cell)))
    prepared <- mfrmr:::prepare_mfrm_prediction_data(x$fit,meta$Profiles)
    idx <- mfrmr:::build_indices(prepared$prep,step_facet=x$fit$config$step_facet)
    sizes <- mfrmr:::build_param_sizes(x$fit$config)
    params <- mfrmr:::expand_params(x$calibration_truth,sizes,x$fit$config)
    actual <- mfrmr:::compute_person_posterior_summary(idx,x$fit$config,params,
      mfrmr:::gauss_hermite_normal(121L),prepared$prep$levels$Person)$estimates
    expected <- meta$Oracle[[x$fit$config$model]]
    expected <- expected[match(actual$Person,expected$Person),]
    fields <- c('Estimate','SD','Lower','Upper')
    error <- max(abs(as.matrix(actual[fields])-as.matrix(expected[fields])))
    check(paste(x$fit$config$model,'independent known-calibration posterior'),error<=1e-8,error)
    replay <- pec_new_cohort(x$fit$config$model,x$status$Seed+2000L)
    check(paste(x$fit$config$model,'same seeded abilities and responses'),identical(replay,x$cohort))
    check(paste(x$fit$config$model,'source truth independent of fitted coordinates'),
      !identical(x$calibration_truth,x$fit$opt$par))
  }
  result <- do.call(rbind,results)
  write.csv(result,file.path(directory,'self-checks.csv'),row.names=FALSE)
  invisible(result)
}

pec_timing <- function(directory,output=directory) {
  fit <- readRDS(file.path(directory,'cell-01-rep-0001.rds'))$fit
  profiles <- pec_profiles()
  score <- predict_mfrm_units(fit,profiles,scoring_quad_points=61L)$estimates
  rows <- list()
  for(n in c(48L,192L,768L)) {
    data <- pec_new_cohort('RSM',95000000L+n,n)$data
    expected <- pec_lookup(score,profiles,data)
    for(run in 1:3) {
      elapsed <- system.time(actual <- predict_mfrm_units(fit,data,scoring_quad_points=61L)$estimates)['elapsed']
      matched <- expected[match(actual$Person,expected$Person),]
      fields <- c('Estimate','SD','Lower','Upper')
      error <- max(abs(as.matrix(actual[fields])-as.matrix(matched[fields])))
      stopifnot(error<=1e-8)
      rows[[length(rows)+1L]] <- data.frame(Persons=n,Ratings=nrow(data),Run=run,Seconds=unname(elapsed),MaxError=error)
      write.csv(do.call(rbind,rows),file.path(output,'timing.csv'),row.names=FALSE)
      message('timing ',n,' Persons run ',run,': ',elapsed,' s')
    }
  }
  invisible(do.call(rbind,rows))
}
