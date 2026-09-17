# Aggregation is separate from the frozen simulation payload.
source('inst/validation/person-estimated-calibration-0.2.4-summary.R')
source('inst/validation/person-learned-population-0.2.4.R')

plp_summarize <- function(directory,output=directory) {
  meta <- readRDS(file.path(directory,'metadata.rds'))
  files <- list.files(directory,pattern='^cell-[0-9]+-rep-[0-9]+[.]rds$',full.names=TRUE)
  stopifnot(length(files)>0)
  values <- lapply(files,function(path) {
    x <- readRDS(path)
    stopifnot(identical(x$Payload,meta$Payload),identical(x$Stage,meta$Stage))
    list(status=do.call(rbind,lapply(x$fits,function(f) cbind(Cell=x$Cell,Replicate=x$Replicate,f$status))),
      metrics=cbind(Cell=x$Cell,Replicate=x$Replicate,x$metrics))
  })
  status <- do.call(rbind,lapply(values,`[[`,'status'))
  metrics <- do.call(rbind,lapply(values,`[[`,'metrics'))
  stopifnot(!anyDuplicated(status[c('Cell','Replicate','Method')]),
    !anyDuplicated(metrics[c('Cell','Replicate','Method','NewRatings','Stratum')]))
  counts <- summaries <- population <- list()
  for(cell in 1:16) {
    s <- status[status$Cell==cell,]; if(!nrow(s)) next
    a <- s[s$Method=='fixed',]; b <- s[s$Method=='learned',]
    b <- b[match(a$Replicate,b$Replicate),]
    stopifnot(!anyNA(b$Replicate),identical(a$Replicate,b$Replicate))
    paired <- a$Available & b$Available
    for(method in c('fixed','learned','paired')) {
      available <- if(method=='paired') paired else s$Available[s$Method==method]
      z <- if(method=='paired') s else s[s$Method==method,]
      interval <- mml_coverage_binomial(sum(available),length(available))
      counts[[length(counts)+1L]] <- cbind(meta$Cells[cell,],Stage=meta$Stage,Method=method,
        Assigned=meta$Planned,Attempted=length(available),Available=sum(available),
        AvailabilityLower=unname(interval['Lower']),AvailabilityUpper=unname(interval['Upper']),
        FitReady=if(method=='paired') sum(a$FitReady & b$FitReady) else sum(z$FitReady),
        ScoringReady=if(method=='paired') sum(a$ScoringReady & b$ScoringReady) else sum(z$ScoringReady),
        NumericalConflicts=if(method=='paired') sum((a$Returned & !a$NumericalOK) | (b$Returned & !b$NumericalOK)) else
          sum(z$Returned & !z$NumericalOK),
        Errors=if(method=='paired') sum(nzchar(a$Error) | nzchar(b$Error)) else sum(nzchar(z$Error)),
        WarningTrials=if(method=='paired') sum(nzchar(a$Warnings) | nzchar(b$Warnings)) else sum(nzchar(z$Warnings)),
        MeanSeconds=if(method=='paired') mean(a$Seconds+b$Seconds) else mean(z$Seconds),row.names=NULL)
    }
    for(field in c('Mean','SD')) for(scope in c('returned','available')) {
      z <- b[b$Returned & is.finite(b[[field]]) & (scope=='returned' | b$Available),]
      r <- pec_cluster(z[[field]],rep(1,nrow(z))); n <- nrow(z)
      half <- if(n>1) qt(.975,n-1)*r$mcse else NA_real_
      population[[length(population)+1L]] <- data.frame(Cell=cell,Scope=scope,Parameter=field,
        Replicates=n,Estimate=r$estimate,MCSE=r$mcse,Lower=r$estimate-half,Upper=r$estimate+half,
        AcrossSampleSD=if(n>1) sd(z[[field]]) else NA_real_,
        GeneratingMoment=if(field=='Mean') meta$Populations[[meta$Cells$Distribution[cell]]]$mean else
          sqrt(meta$Populations[[meta$Cells$Distribution[cell]]]$variance))
    }
    m <- metrics[metrics$Cell==cell,]
    strata <- c('All',levels(cut(0,c(-Inf,-2,-1,0,1,2,Inf))))
    for(exposure in c(3L,6L)) for(stratum in strata) {
      selected <- m[m$NewRatings==exposure & m$Stratum==stratum,]
      for(metric in c('Coverage','MeanWidth','Bias','MSE','MeanSD','ExtremeRate')) {
        for(method in c('fixed_own','learned_own','fixed_paired','learned_paired','oracle_all','oracle_paired',
          'learned_minus_fixed','learned_minus_oracle','fixed_minus_oracle','joint_fixed','joint_learned')) {
          joint <- startsWith(method,'joint_'); difference <- grepl('_minus_',method,fixed=TRUE)
          if(joint && (metric!='Coverage' || stratum!='All')) next
          ids <- if(joint || method=='oracle_all') a$Replicate else if(method=='fixed_own') a$Replicate[a$Available] else
            if(method=='learned_own') b$Replicate[b$Available] else a$Replicate[paired]
          vector <- function(name) {
            z <- selected[selected$Method==name,]; index <- match(ids,z$Replicate)
            n <- z$Persons[index]; y <- z[[metric]][index]
            n[is.na(n)] <- 0; y[n==0] <- 0
            list(y=y,n=n)
          }
          name <- if(grepl('learned',method,fixed=TRUE)) 'learned' else if(startsWith(method,'oracle')) 'oracle' else 'fixed'
          x <- vector(name)
          if(joint) x$n <- rep(512L,length(ids))
          result <- pec_cluster(x$y,x$n)
          if(difference) {
            reference <- vector(if(method=='learned_minus_fixed') 'fixed' else 'oracle')
            stopifnot(identical(x$n,reference$n))
            original <- result; other <- pec_cluster(reference$y,reference$n)
            result <- pec_cluster(x$y-reference$y,x$n)
          }
          n <- length(ids); half <- if(n>1) qt(.975,n-1)*result$mcse else NA_real_
          row <- data.frame(Cell=cell,Stage=meta$Stage,NewRatings=exposure,Stratum=stratum,Method=method,
            Metric=metric,CalibrationReplicates=n,Persons=sum(x$n),Estimate=result$estimate,MCSE=result$mcse,
            Lower=result$estimate-half,Upper=result$estimate+half,
            Disposition=if(sum(x$n)==0) 'no_persons' else 'descriptive')
          if(metric=='Coverage' && stratum=='All' && method %in% c('fixed_paired','learned_paired')) {
            bound <- mml_coverage_binomial(sum(paired),nrow(a))['Lower']
            row$Disposition <- if(meta$Stage=='preflight') 'preflight_only' else
              if(nrow(a)!=meta$Planned || bound<.95 || any(s$Returned & !s$NumericalOK) || any(nzchar(s$Error))) 'review' else
                mml_coverage_range(row$Lower,row$Upper,c(.93,.97))
          }
          summaries[[length(summaries)+1L]] <- row
          if(metric=='MSE') {
            row$Metric <- 'RMSE'
            if(difference) {
              row$Estimate <- sqrt(original$estimate)-sqrt(other$estimate)
              influence <- original$influence/(2*sqrt(original$estimate))-other$influence/(2*sqrt(other$estimate))
              row$MCSE <- if(n>1) sd(influence)/sqrt(n) else NA_real_
            } else {
              row$Estimate <- sqrt(result$estimate);row$MCSE <- result$mcse/(2*row$Estimate)
            }
            half <- if(n>1) qt(.975,n-1)*row$MCSE else NA_real_
            row$Lower <- row$Estimate-half;row$Upper <- row$Estimate+half
            summaries[[length(summaries)+1L]] <- row
          }
        }
      }
    }
  }
  checks <- list()
  limits <- c(IndependentObjective=1e-6,IndependentGradient=1e-7,GradientStep=1e-7,ReferenceGradient=1e-4,
    ScoringOrder=1e-6,ReferenceMoment=1e-6,ReferenceTail=1e-6,DirectLookup=1e-8)
  for(field in names(limits)) {
    z <- status[status$Replicate==1L,]
    checks[[field]] <- data.frame(Check=field,Required=if(meta$Stage=='preflight') 32L else 0L,
      Measured=sum(is.finite(z[[field]])),Maximum=if(any(is.finite(z[[field]]))) max(z[[field]],na.rm=TRUE) else NA_real_,
      Limit=limits[[field]],Pass=if(meta$Stage=='preflight') nrow(z)==32L &&
        all(is.finite(z[[field]]) & z[[field]]<=limits[[field]]) && !any(nzchar(z$Error)) else NA)
  }
  dir.create(output,recursive=TRUE,showWarnings=FALSE)
  outputs <- list(runs=status,'replicate-metrics'=metrics,counts=do.call(rbind,counts),
    summary=do.call(rbind,summaries),population=do.call(rbind,population),'preflight-checks'=do.call(rbind,checks))
  for(name in names(outputs)) write.csv(outputs[[name]],file.path(output,paste0(name,'.csv')),row.names=FALSE)
  invisible(outputs)
}

plp_self_check <- function(directory) {
  checks <- list()
  check <- function(name,value) {stopifnot(isTRUE(value));checks[[name]] <<- data.frame(Check=name,Pass=value)}
  meta <- readRDS(file.path(directory,'metadata.rds'))
  x <- pec_cluster(c(.8,1),c(512,512))
  check('calibration cluster MCSE',abs(x$estimate-.9)<1e-15 && abs(x$mcse-.1)<1e-15)
  x <- pec_cluster(c(1,0,NA),c(2,1,0))
  check('zero-count strata retain clusters',abs(x$estimate-2/3)<1e-15 && length(x$influence)==3L)
  for(cell in 1:16) {
    x <- readRDS(file.path(directory,sprintf('cell-%02d-rep-0001.rds',cell)))
    g <- meta$Populations[[meta$Cells$Distribution[cell]]];fixture <- meta$Fixtures[[meta$Cells$Model[cell]]]
    check(paste(cell,'seeded calibration replay'),identical(x$calibration,
      plp_generate(fixture,g,meta$Cells$Persons[cell],x$Seed,'CAL')))
    check(paste(cell,'independent cohort replay'),identical(x$cohort,plp_generate(fixture,g,512L,x$Seed+2000L,'NEW')))
    for(method in c('oracle','fixed','learned')) for(exposure in c(3L,6L)) {
      if(method!='oracle' && !x$fits[[method]]$status$Available) next
      scores <- if(method=='oracle') meta$Oracle[[meta$Cells$Model[cell]]][[meta$Cells$Distribution[cell]]] else
        x$fits[[method]]$scores$estimates
      data <- if(exposure==3L) x$cohort$three else x$cohort$data
      actual <- pec_measures(pec_lookup(scores,meta$Profiles,data),x$cohort$truth,method,exposure)
      expected <- x$metrics[x$metrics$Method==method & x$metrics$NewRatings==exposure,]
      rownames(actual) <- rownames(expected) <- NULL
      check(paste(cell,method,exposure,'raw cohort metrics'),identical(actual,expected))
    }
  }
  write.csv(do.call(rbind,checks),file.path(directory,'self-checks.csv'),row.names=FALSE)
  invisible(do.call(rbind,checks))
}
