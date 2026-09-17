# Secondary analysis; no refits or new random draws. See the companion plan.
source('inst/validation/person-learned-population-0.2.4-summary.R')

ptp_prepare <- function(input,output) {
  original <- readRDS(file.path(input,'metadata.rds'))
  stopifnot(original$Stage=='main',original$Planned==128L)
  files <- c(names(original$Payload),
    paste0('inst/validation/',c('person-learned-population-0.2.4-summary.R',
      'person-estimated-calibration-0.2.4-summary.R',
      'person-population-transport-0.2.4.R','person-population-transport-0.2.4-plan.md')))
  payload <- tools::md5sum(unique(files));stopifnot(!anyNA(payload))
  dir.create(output,recursive=TRUE,showWarnings=FALSE)
  for(target in original$Cells$Distribution[seq(1,16,by=4)]) {
    directory <- file.path(output,target);dir.create(directory,showWarnings=FALSE)
    meta <- original;meta$Stage <- 'transport';meta$Payload <- payload
    meta$SourcePayload <- original$Payload;meta$Target <- target
    path <- file.path(directory,'metadata.rds')
    if(file.exists(path)) stopifnot(identical(readRDS(path),meta)) else saveRDS(meta,path)
  }
  invisible(payload)
}

ptp_run <- function(input,output,replicates=1:128) {
  original <- readRDS(file.path(input,'metadata.rds'))
  cells <- original$Cells;targets <- unique(cells$Distribution)
  profile <- original$Profiles;fields <- c('Estimate','SD','Lower','Upper')
  # pec_lookup supplies the checked mapping once per cohort/exposure.
  dummy <- data.frame(Person=unique(profile$Person),Estimate=seq_along(unique(profile$Person)),
    SD=0,Lower=0,Upper=0)
  for(rep in replicates) for(base in 1:4) {
    ids <- seq(base,16,by=4)
    sources <- lapply(ids,function(id) {
      x <- readRDS(file.path(input,sprintf('cell-%02d-rep-%04d.rds',id,rep)))
      stopifnot(x$Cell==id,x$Replicate==rep,identical(x$Payload,original$Payload))
      x
    })
    for(ti in seq_along(targets)) {
      directory <- file.path(output,targets[ti]);meta <- readRDS(file.path(directory,'metadata.rds'))
      stopifnot(identical(meta$Payload,tools::md5sum(names(meta$Payload))))
      target <- sources[[ti]]
      maps <- lapply(setNames(c(3L,6L),c('3','6')),function(exposure)
        pec_lookup(dummy,profile,if(exposure==3L) target$cohort$three else target$cohort$data))
      for(si in seq_along(sources)) {
        x <- sources[[si]];path <- file.path(directory,sprintf('cell-%02d-rep-%04d.rds',x$Cell,rep))
        if(file.exists(path)) {
          saved <- readRDS(path)
          stopifnot(identical(saved$Payload,meta$Payload),saved$TargetCell==target$Cell,
            saved$Cell==x$Cell,saved$Replicate==rep)
          next
        }
        stopifnot(!any(x$calibration$truth$Person %in% target$cohort$truth$Person))
        metrics <- target$metrics[target$metrics$Method=='oracle',];checks <- list()
        for(exposure in c(3L,6L)) {
          data <- if(exposure==3L) target$cohort$three else target$cohort$data
          mapping <- maps[[as.character(exposure)]]
          for(method in c('fixed','learned')) {
            f <- x$fits[[method]]
            if(!isTRUE(f$status$Available)) next
            score <- f$scores$estimates
            index <- match(dummy$Person[mapping$Estimate],score$Person);stopifnot(!anyNA(index))
            predictions <- data.frame(Person=mapping$Person,score[index,fields],
              Ratings=mapping$Ratings,Total=mapping$Total,row.names=NULL)
            actual <- pec_measures(predictions,target$cohort$truth,method,exposure)
            metrics <- rbind(metrics,actual)
            if(si==ti) {
              expected <- x$metrics[x$metrics$Method==method & x$metrics$NewRatings==exposure,]
              rownames(actual) <- rownames(expected) <- NULL
              stopifnot(identical(actual,expected))
            }
            if(rep==1L) {
              new <- data[data$Person %in% target$cohort$truth$Person[1:8],]
              direct <- predict_mfrm_units(f$fit,new,scoring_quad_points=241L,readiness_policy='review')
              matched <- predictions[match(direct$estimates$Person,predictions$Person),]
              error <- max(abs(as.matrix(direct$estimates[fields])-as.matrix(matched[fields])))
              profile_error <- 0
              if(si==ti && exposure==3L) {
                fresh <- predict_mfrm_units(f$fit,profile,scoring_quad_points=241L,readiness_policy='review')$estimates
                fresh <- fresh[match(score$Person,fresh$Person),]
                profile_error <- max(abs(as.matrix(fresh[fields])-as.matrix(score[fields])))
              }
              stopifnot(error<=1e-8,profile_error<=1e-8,
                identical(direct$settings$source_scoring_ready,f$status$ScoringReady))
              checks[[length(checks)+1L]] <- data.frame(Cell=x$Cell,TargetCell=target$Cell,
                Method=method,NewRatings=exposure,Persons=8L,DirectError=error,
                ProfileRechecked=si==ti && exposure==3L,ProfileError=profile_error,
                SourceScoringReady=direct$settings$source_scoring_ready)
            }
          }
        }
        if(si==ti) {
          order_metrics <- function(z) {
            z <- z[order(z$Method,z$NewRatings,z$Stratum),];rownames(z) <- NULL;z
          }
          stopifnot(identical(order_metrics(metrics),order_metrics(x$metrics)))
        }
        value <- list(Cell=x$Cell,Replicate=rep,TargetCell=target$Cell,Stage=meta$Stage,
          Payload=meta$Payload,SourcePayload=original$Payload,
          fits=lapply(x$fits,function(f) list(status=f$status)),metrics=metrics,
          checks=if(length(checks)) do.call(rbind,checks) else NULL)
        saveRDS(value,paste0(path,'.tmp'));stopifnot(file.rename(paste0(path,'.tmp'),path))
      }
    }
    cat(sprintf('replicate %d/128 model/N block %d: all 16 source/target pairs saved\n',rep,base))
    flush.console()
  }
  invisible(TRUE)
}

ptp_summarize <- function(output,original_summary) {
  previous <- read.csv(original_summary,stringsAsFactors=FALSE)
  all <- checks <- list()
  for(target in c('normal','shifted','wide','skewed')) {
    directory <- file.path(output,target);meta <- readRDS(file.path(directory,'metadata.rds'))
    value <- plp_summarize(directory)
    stopifnot(nrow(value$runs)==4096L,all(value$counts$Attempted==128L),
      !anyDuplicated(value$summary[c('Cell','NewRatings','Stratum','Method','Metric')]))
    s <- value$summary;cells <- meta$Cells
    s$Model <- cells$Model[match(s$Cell,cells$Cell)]
    s$CalibrationN <- cells$Persons[match(s$Cell,cells$Cell)]
    s$Training <- cells$Distribution[match(s$Cell,cells$Cell)];s$Target <- target
    all[[target]] <- s
    diagonal <- s[s$Training==target,]
    old <- previous[previous$Cell %in% diagonal$Cell,]
    key <- function(z) do.call(paste,c(z[c('Cell','NewRatings','Stratum','Method','Metric')],sep='|'))
    old <- old[match(key(diagonal),key(old)),];stopifnot(!anyNA(old$Cell))
    fields <- c('Estimate','MCSE','Lower','Upper')
    a <- as.matrix(diagonal[fields]);b <- as.matrix(old[fields])
    stopifnot(identical(is.na(a),is.na(b)),max(abs(a-b),na.rm=TRUE)<=1e-12)
    checks[[target]] <- data.frame(Check=paste(target,'diagonal aggregate'),Rows=nrow(old),
      Error=max(abs(a-b),na.rm=TRUE),Pass=TRUE)
  }
  summary <- do.call(rbind,all);rownames(summary) <- NULL
  write.csv(summary,file.path(output,'summary.csv'),row.names=FALSE)
  write.csv(do.call(rbind,checks),file.path(output,'diagonal-checks.csv'),row.names=FALSE)
  invisible(summary)
}
