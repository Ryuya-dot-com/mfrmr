# Repository-only sampling study; see the companion protocol.
# Rscript <file> run OUTPUT FIRST LAST CORES | summary OUTPUT
gmfrm_sparse_plan <- function() list(
  repetitions=100L, persons=240L, tasks=3L, raters=6L, seed=92810000L,
  designs=c("common_persons","rotating_pairs"), ability_sd=c(1,.5),
  task_location=c(-.4,.1,.3), rater_location=seq(-.3,.3,length.out=6),
  task_slope=exp(c(-.2,0,.2)), rater_slope=seq(.75,1.25,length.out=6),
  step_size=seq(.45,.7,length.out=6), quad_points=31L, maxit=500L,
  em_score_tol=1e-6, level=.95)

gmfrm_sparse_data <- function(id, plan=gmfrm_sparse_plan()) {
  stopifnot(id %in% seq_len(plan$repetitions))
  set.seed(plan$seed+id)
  grid <- expand.grid(Person=sprintf("p%03d",seq_len(plan$persons)),
    Task=paste0("t",seq_len(plan$tasks)),Rater=paste0("r",seq_len(plan$raters)))
  person <- as.integer(grid$Person); task <- as.integer(grid$Task); rater <- as.integer(grid$Rater)
  z <- rnorm(plan$persons); u <- runif(nrow(grid))
  # Fixed, cost-matched roster sizes; assign Persons independently of ability.
  common_order <- sample.int(plan$persons)
  common <- matrix(FALSE,plan$persons,plan$raters)
  common[common_order[1:48],] <- TRUE
  common[cbind(common_order[49:240],rep(1:6,each=32))] <- TRUE
  rotating <- matrix(FALSE,plan$persons,plan$raters)
  panel <- rep(1:6,each=40); rotation_order <- sample.int(plan$persons)
  rotating[cbind(rotation_order,panel)] <- TRUE
  rotating[cbind(rotation_order,panel %% 6+1L)] <- TRUE
  rosters <- list(common_persons=common,rotating_pairs=rotating)
  stopifnot(all(colSums(common)==80),all(colSums(rotating)==80),
    all(rowSums(rotating)==2),sum(rowSums(common)==6)==48)
  cases <- list()
  for(sd in plan$ability_sd) {
    # Literal adjacent-category equation, independent of the fitted kernel.
    eta <- sd*z[person]-plan$task_location[task]-plan$rater_location[rater]
    a <- plan$task_slope[task]*plan$rater_slope[rater]
    logits <- cbind(0,a*(eta+plan$step_size[rater]),2*a*eta)
    probability <- exp(logits-apply(logits,1,max))
    probability <- probability/rowSums(probability)
    score <- as.integer(u>probability[,1])+as.integer(u>rowSums(probability[,1:2]))
    for(design in plan$designs) {
      d <- grid[rosters[[design]][cbind(person,rater)],]
      d$Score <- score[rosters[[design]][cbind(person,rater)]]
      cases[[paste(design,sd,sep="-")]] <- list(data=d,design=design,sd=sd,
        truth=data.frame(SlopeOwner=c(rep("Task",3),rep("Rater",6)),
          SlopeLevel=c(paste0("t",1:3),paste0("r",1:6)),
          Truth=c(plan$task_slope,sd*plan$rater_slope)))
    }
  }
  list(cases=cases,z=z,rosters=rosters)
}

gmfrm_sparse_sources <- function() tools::md5sum(c(
  "inst/validation/gmfrm-sparse-intervals-20260928.R",
  sort(list.files("R",pattern="[.]R$",full.names=TRUE)),
  sort(list.files("src",pattern="[.](cpp|h)$",full.names=TRUE))))

gmfrm_sparse_run <- function(out, first, last, cores=2L) {
  plan <- gmfrm_sparse_plan(); hashes <- gmfrm_sparse_sources()
  stopifnot(first>=1L,last<=plan$repetitions,first<=last,cores>=1L,cores<=2L)
  dir.create(out,recursive=TRUE,showWarnings=FALSE)
  manifest <- list(plan=plan,source_hash=hashes,session=capture.output(sessionInfo()))
  manifest_path <- file.path(out,"manifest.rds")
  if(file.exists(manifest_path)) {
    old <- readRDS(manifest_path)
    stopifnot(identical(old$plan,plan),identical(old$source_hash,hashes))
  } else saveRDS(manifest,manifest_path)
  worker <- function(id) {
    input <- gmfrm_sparse_data(id,plan)
    for(key in names(input$cases)) {
      path <- file.path(out,sprintf("%03d-%s.rds",id,key))
      if(file.exists(path)) {
        old <- readRDS(path)
        stopifnot(identical(old$id,id),identical(old$key,key),identical(old$source_hash,hashes))
        next
      }
      case <- input$cases[[key]]; warnings <- character(); fit <- ci <- NULL; error <- NULL
      elapsed <- system.time(withCallingHandlers(tryCatch({
        fit <- fit_mfrm(case$data,person="Person",facets=c("Task","Rater"),score="Score",
          model="GPCM",method="MML",slope_facet=c("Task","Rater"),
          step_facet="Rater",noncenter_facet="Rater",gpcm_mml_identification="fixed_standard_normal",
          mml_engine="em",rating_min=0,rating_max=2,category_policy="preserve",
          quad_points=plan$quad_points,maxit=plan$maxit,em_score_tol=plan$em_score_tol)
        ci <- confint(fit,level=plan$level)
      },error=function(e) error <<- conditionMessage(e)),warning=function(w) {
        warnings <<- c(warnings,conditionMessage(w)); invokeRestart("muffleWarning")
      }))["elapsed"]
      stopifnot(identical(hashes,gmfrm_sparse_sources()))
      result <- list(id=id,key=key,seed=plan$seed+id,case=case,fit=fit,ci=ci,
        error=error,warnings=unique(warnings),seconds=unname(elapsed),source_hash=hashes)
      saveRDS(result,paste0(path,".tmp"))
      stopifnot(file.rename(paste0(path,".tmp"),path))
      nci <- if(is.null(ci)) 0L else sum(attr(ci,"diagnostics")$CIEligible)
      cat(id,key,"converged",isTRUE(fit$summary$Converged),"intervals",nci,
        "seconds",unname(elapsed),"\n"); flush.console()
    }
    TRUE
  }
  done <- parallel::mclapply(seq.int(first,last),worker,mc.cores=cores,mc.set.seed=FALSE)
  stopifnot(all(vapply(done,isTRUE,logical(1))))
  invisible(out)
}

gmfrm_sparse_summary <- function(out) {
  manifest <- readRDS(file.path(out,"manifest.rds")); plan <- manifest$plan
  keys <- manifest$case_keys
  if (is.null(keys)) keys <- names(gmfrm_sparse_data(1L,plan)$cases)
  paths <- unlist(lapply(seq_len(plan$repetitions),function(id)
    file.path(out,sprintf("%03d-%s.rds",id,keys))))
  stopifnot(all(file.exists(paths)))
  records <- lapply(paths,readRDS)
  stopifnot(all(vapply(records,function(z)identical(z$source_hash,manifest$source_hash),logical(1))))
  rows <- do.call(rbind,lapply(records,function(z) {
    t <- z$case$truth; n <- nrow(t); f <- z$fit; ci <- z$ci
    estimate <- lower <- upper <- se <- rep(NA_real_,n); available <- rep(FALSE,n)
    reason <- if(is.null(z$error)) "" else z$error
    if(!is.null(f)) {
      index <- mfrmr:::mfrm_match_slope_table(t$SlopeOwner,t$SlopeLevel,f$slopes)
      estimate <- f$slopes$Estimate[index]
    }
    if(!is.null(ci)) {
      tab <- attr(ci,"diagnostics")
      stopifnot(identical(tab$SlopeOwner,t$SlopeOwner),identical(tab$SlopeLevel,t$SlopeLevel))
      available <- tab$CIEligible; lower <- log(tab$CI_Lower); upper <- log(tab$CI_Upper)
      se <- tab$LogSE
      check <- attr(ci,"checks"); reason <- paste(check$Check[!check$Passed],collapse="; ")
    }
    data.frame(Design=z$case$design,AbilitySD=z$case$sd,Replicate=z$id,t,
      LogTruth=log(t$Truth),LogEstimate=log(estimate),LogSE=se,Lower=lower,Upper=upper,
      Converged=isTRUE(f$summary$Converged),Available=available,
      Covered=available & is.finite(lower) & is.finite(upper) & lower<=log(t$Truth) & upper>=log(t$Truth),
      Failure=reason,Seconds=z$seconds)
  }))
  average <- function(x) if(length(x)) mean(x) else NA_real_
  interval <- function(k,n) if(n) unname(binom.test(k,n)$conf.int) else c(NA_real_,NA_real_)
  grouped <- split(rows,interaction(rows$Design,rows$AbilitySD,rows$SlopeOwner,rows$SlopeLevel,drop=TRUE))
  summary <- do.call(rbind,lapply(grouped,function(x) {
    point <- x$Converged & is.finite(x$LogEstimate)
    err <- x$LogEstimate[point]-x$LogTruth[point]
    ok <- x$Available; n <- sum(ok); covered <- sum(x$Covered)
    bounds <- interval(covered,n); delivered <- interval(covered,nrow(x))
    availability <- interval(n,nrow(x))
    data.frame(x[1,c("Design","AbilitySD","SlopeOwner","SlopeLevel","Truth")],
      Attempted=nrow(x),Converged=sum(point),Available=n,Covered=covered,
      Availability=n/nrow(x),AvailabilityLow=availability[1],AvailabilityHigh=availability[2],
      LogBias=average(err),BiasMCSE=sd(err)/sqrt(length(err)),LogRMSE=sqrt(average(err^2)),
      EmpiricalLogSD=sd(x$LogEstimate[ok]),RootMeanLogVariance=sqrt(average(x$LogSE[ok]^2)),
      MeanLogWidth=average(x$Upper[ok]-x$Lower[ok]),ConditionalCoverage=if(n) covered/n else NA_real_,
      CoverageMCSE=if(n) sqrt(covered/n*(1-covered/n)/n) else NA_real_,
      CoverageLow=bounds[1],CoverageHigh=bounds[2],ReturnedAndCovered=covered/nrow(x),
      ReturnedLow=delivered[1],ReturnedHigh=delivered[2])
  }))
  disposition <- do.call(rbind,lapply(split(rows,interaction(rows$Design,rows$AbilitySD,
    rows$Replicate,drop=TRUE)),function(x) data.frame(
      x[1,c("Design","AbilitySD","Replicate","Converged","Failure","Seconds")],
      IntervalsAvailable=sum(x$Available))))
  write.csv(rows,file.path(out,"rows.csv"),row.names=FALSE)
  write.csv(summary,file.path(out,"summary.csv"),row.names=FALSE)
  write.csv(disposition,file.path(out,"dispositions.csv"),row.names=FALSE)
  print(summary[summary$SlopeLevel %in% c("t1","r1"),],row.names=FALSE)
  print(with(disposition,table(Design,AbilitySD,Failure)))
  cat("Completed",length(records),"of",length(paths),"planned fits; worker seconds:",
    sum(vapply(records,`[[`,numeric(1),"seconds")),"\n")
  invisible(summary)
}

if(sys.nframe()==0L) {
  pkgload::load_all(quiet=TRUE,compile=FALSE)
  args <- commandArgs(trailingOnly=TRUE)
  if(identical(args[1],"run")) gmfrm_sparse_run(args[2],as.integer(args[3]),as.integer(args[4]),as.integer(args[5]))
  else if(identical(args[1],"summary")) gmfrm_sparse_summary(args[2])
  else stop("Use run OUTPUT FIRST LAST CORES or summary OUTPUT.")
}
