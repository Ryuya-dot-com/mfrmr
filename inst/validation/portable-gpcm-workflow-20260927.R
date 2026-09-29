# Execute the public vignette's extraction/scoring/prior chunks with existing
# synthetic fits. Calibration fitting is reused, not claimed as rerun here.
run_portable_gpcm_workflow <- function(directory) {
  root <- normalizePath('.')
  directory <- normalizePath(directory,mustWork=FALSE)
  dir.create(directory,recursive=TRUE,showWarnings=FALSE)
  vignette <- readLines('vignettes/mfrmr-portable-calibration.Rmd')
  chunk <- function(name) {
    start <- grep(paste0('^```\\{r ',name,'[,}]'),vignette)
    stopifnot(length(start)==1L)
    end <- which(seq_along(vignette)>start & vignette=='```')[1]
    vignette[seq.int(start+1L,end-1L)]
  }
  paths <- c(shared='validation-results/gpcm-probability-refit-20260925/refit-788.rds',
    separate='tests/testthat/fixtures/mfrm-conditional-scoring-gpcm.rds')
  files <- c(list.files('R','[.]R$',full.names=TRUE),paths,
    'vignettes/mfrmr-portable-calibration.Rmd',
    'inst/validation/portable-gpcm-workflow-20260927.R')
  saveRDS(list(source=tools::md5sum(files),session=sessionInfo()),file.path(directory,'manifest.rds'))
  summaries <- list()
  for(owner in names(paths)) {
    out <- file.path(directory,owner);dir.create(out,showWarnings=FALSE)
    gpcm_fit <- readRDS(paths[owner])$fit
    fixture <- readRDS(file.path('tests/testthat/fixtures',paste0('calibration-gpcm-',owner,'.rds')))
    rows <- fixture$rows[c('Person','Rater','Criterion','Score')]
    rows$Person <- as.character(rows$Person)
    ids <- unique(rows$Person);rows$Person[rows$Person==ids[1]] <- '001'
    rows$Person[rows$Person==ids[2]] <- '1'
    sparse <- rows[1,,drop=FALSE];sparse$Person <- 'sparse'
    missing <- sparse;missing$Person <- 'NA';missing$Score <- NA
    rows <- rbind(rows,sparse,missing)
    write.csv(rows,file.path(out,'new-responses.csv'),row.names=FALSE,na='')
    # Execute the extraction chunk verbatim using the documented eligible fit.
    previous <- getwd();setwd(out)
    tryCatch(eval(parse(text=chunk('portable-gpcm'))),finally=setwd(previous))
    training <- mfrm_results(gpcm_fit,compute='never')
    export_mfrm_results(training,output_dir=file.path(out,'training-report'),
      include=c('tables','report'),overwrite=TRUE)
    worker <- c('args <- commandArgs(TRUE)',
      'pkgload::load_all(args[1],quiet=TRUE,compile=FALSE)',
      'setwd(args[2])',
      'stopifnot(!exists("gpcm_fit"),!exists("calibration_responses"))',
      'png("cohort-interval.png",width=1200,height=800,res=144)',
      'testthat::with_mocked_bindings({',chunk('portable-gpcm-score'),
      '},fit_mfrm=function(...)stop("unexpected refit"),.package="mfrmr")',
      'dev.off()',
      'stopifnot(identical(unique(new_responses$Person),c("001","1","lower","upper","sparse","NA")))',
      'before <- serialize(calibration,NULL)',chunk('portable-gpcm-prior'),
      'stopifnot(identical(before,serialize(calibration,NULL)))',
      'saveRDS(alternative,"alternative-prior.rds")',
      'testthat::with_mocked_bindings({',
      'replayed <- readRDS("scored-cohort.rds")',
      'stopifnot(identical(replayed,scores))',
      'print(summary(replayed))',
      'payload <- plot(replayed,draw=FALSE,top_n=Inf)',
      'stopifnot("NA" %in% payload$data$unplotted_dispositions$Person)',
      'gg <- as_ggplot(payload);ggplot2::ggsave("cohort-interval-ggplot.png",gg,width=8,height=5,dpi=144)',
      '},score_mfrm_calibration=function(...)stop("unexpected rescoring"),fit_mfrm=function(...)stop("unexpected refit"),.package="mfrmr")',
      'csv <- read.csv("person-scores.csv",colClasses="character",na.strings="",check.names=FALSE)',
      'review <- read.csv("person-review.csv",colClasses="character",na.strings="",check.names=FALSE)',
      'stopifnot(identical(csv$Person,scores$estimates$Person),"NA" %in% review$Person,',
      'review$Disposition[review$Person=="NA"]=="not_scored")',
      'for(n in c("Estimate","SD","Lower","Upper","PriorMean","PriorSD")) stopifnot(max(abs(as.numeric(csv[[n]])-scores$estimates[[n]]))<1e-12)',
      'stopifnot(all(scores$estimates$ScoreIntegrationReady),all(alternative$estimates$ScoreIntegrationReady))',
      'cat("PASS: fresh-session tutorial chunks, identifiers, missingness, saved replay and full-precision CSV.\\n")')
    writeLines(worker,file.path(out,'scoring-session.R'))
    status <- system2(file.path(R.home('bin'),'Rscript'),
      c('--vanilla',shQuote(file.path(out,'scoring-session.R')),shQuote(root),shQuote(out)),
      stdout=file.path(out,'scoring-session.log'),stderr=file.path(out,'scoring-session-errors.log'))
    stopifnot(status==0L)
    score <- readRDS(file.path(out,'scored-cohort.rds'))
    alternative <- readRDS(file.path(out,'alternative-prior.rds'))
    s <- summary(score)
    summaries[[owner]] <- data.frame(Owner=owner,Persons=nrow(score$person_dispositions),
      Scored=nrow(score$estimates),Review=s$overview$Review,NotScored=s$overview$NotScored,
      MaxPriorEAPChange=max(abs(alternative$estimates$Estimate-score$estimates$Estimate)))
  }
  result <- do.call(rbind,summaries)
  write.csv(result,file.path(directory,'workflow-summary.csv'),row.names=FALSE)
  print(result);invisible(result)
}

# Reuse external results only when the frozen model and prior match exactly.
# The separate-owner comparator must use the qualified fixture, not the older
# fixed-Q31 pilot that fails current extraction checks.
compare_portable_gpcm_external <- function(directory) {
  shared <- readRDS('validation-results/gpcm-fixed-scoring-tam-20260926/results.rds')$shared
  separate <- readRDS(file.path(directory,'tam/results.rds'))$separate
  fixed <- list(shared=shared,separate=separate)
  rows <- conquest_rows <- list()
  for(owner in names(fixed)) {
    x <- fixed[[owner]]
    artifact <- load_mfrm_calibration(file.path(directory,owner,'gpcm-calibration.rds'))
    coords <- artifact$parameters$coordinates; mu <- artifact$scoring_basis$prior_mean
    sd <- artifact$scoring_basis$prior_sd; contexts <- x$context_map
    k <- seq_len(ncol(x$AXsi))-1L
    ax <- b <- matrix(NA_real_,nrow(contexts),length(k))
    for(i in seq_len(nrow(contexts))) {
      location <- sum(vapply(artifact$model$facet_names,function(f)
        artifact$model$facet_signs[[f]]*coords$Value[coords$ParameterClass=='facet' & coords$OwnerFacet==f &
          coords$Level==contexts[[f]][i]],numeric(1)))
      a <- coords$Value[coords$ParameterClass=='slope' & coords$Level==contexts[[artifact$model$slope_owner]][i]]
      s <- coords[coords$ParameterClass=='owned_step' & coords$Level==contexts[[artifact$model$step_owner]][i],]
      steps <- s$Value[order(as.integer(s$Step))]
      ax[i,] <- a*(k*(mu+location)-c(0,cumsum(steps)))
      b[i,] <- k*sd*a
    }
    model_difference <- max(abs(ax-x$AXsi),abs(b-x$B[,,1]),abs(mu-x$mean),abs(sd-x$sd))
    stopifnot(model_difference<1e-12)
    responses <- do.call(rbind,lapply(seq_len(nrow(x$response)),function(i) {
      r <- contexts;r$Person <- rownames(x$response)[i]
      map <- artifact$response$score_map
      r$Score <- map$OriginalScore[match(x$response[i,]+artifact$response$rating_min,map$InternalScore)]
      r[!is.na(x$response[i,]),]
    }))
    scores <- score_mfrm_calibration(artifact,responses)
    est <- scores$estimates[match(rownames(x$response),scores$estimates$Person),]
    delta <- as.matrix(est[c('Estimate','SD')])-x$external_scores[[2]]
    stopifnot(all(is.finite(delta)),max(abs(delta))<1e-6)
    rows[[owner]] <- data.frame(Owner=owner,ModelDifference=model_difference,
      EAPDifference=max(abs(delta[,1])),SDDifference=max(abs(delta[,2])))
    cq_path <- if(owner=='shared') 'validation-results/gpcm-fixed-scoring-conquest-20260926-v6/score-comparison.csv' else
      file.path(directory,'conquest/score-comparison.csv')
    cq <- read.csv(cq_path);cq <- cq[cq$Owner==owner,]
    at <- match(cq$Person,est$Person);stopifnot(!anyNA(at),nrow(cq)==24L)
    cq$EAPDifference <- cq$EAP-est$Estimate[at]
    cq$SDDifference <- cq$SD-est$SD[at]
    conquest_rows[[owner]] <- cq
    saveRDS(list(artifact=artifact,rows=responses,scores=scores,TAM=x$external_scores[[2]]),
      file.path(directory,owner,'external-score-bridge.rds'))
  }
  rows <- do.call(rbind,rows); cq <- do.call(rbind,conquest_rows)
  write.csv(rows,file.path(directory,'portable-tam-comparison.csv'),row.names=FALSE)
  write.csv(cq,file.path(directory,'portable-conquest-comparison.csv'),row.names=FALSE)
  print(rows);print(aggregate(abs(cq[c('EAPDifference','SDDifference')]),cq[c('Owner','Nodes')],max))
  invisible(rows)
}
