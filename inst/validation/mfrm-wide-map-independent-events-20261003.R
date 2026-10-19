# Verify the event/count likelihood identity at saved public fits. Category
# frequencies here are exact counts, not survey weights or averaged scores.
wide_independent_events_check <- function(out) {
  source('inst/validation/mfrm-wide-map-pcm-r50-20261002.R');wide_pcm_setup()
  root <- 'validation-results/mfrm-wide-map-pcm-r50-20261002'
  m <- wide_f_read(file.path(root,'manifest.rds'))$payload
  input <- wide_recovery_ab_input(m$root,'AB:paired-L2:N480:SD1:S-PCM',1L)
  d <- input$data
  stopifnot(!anyDuplicated(d[c('Person','Rater','Criterion','Event')]),
    all(table(d$Person)==12L),setequal(d$Event,1:2))
  rows <- list()
  for(i in 14001:14006) {
    job <- m$jobs[m$jobs$JobId==sprintf('job-%05d',i),]
    q <- if(grepl('MML',job$Arm))31L else 0L
    path <- file.path(root,job$JobId,'calibration',paste0('q',q,'-fit.rds'))
    fit <- wide_f_read(path)$payload$value;cfg <- fit$config
    prep <- fit$prep;dat <- prep$data;sizes <- mfrmr:::build_param_sizes(cfg)
    stopifnot(nrow(dat)==nrow(d),all(dat$Weight==1),!length(cfg$interaction_specs))
    key <- interaction(dat[c('Person',cfg$facet_names,'score_k')],drop=TRUE)
    group <- match(key,unique(key));take <- !duplicated(group)
    compressed <- prep;compressed$data <- dat[take,]
    compressed$data$Weight <- as.numeric(tabulate(group))
    stopifnot(sum(compressed$data$Weight)==nrow(dat))
    evaluator <- function(p) {
      idx <- mfrmr:::build_indices(p,cfg$step_facet,cfg$slope_facet)
      mfrmr:::make_mfrm_direct_evaluator(cfg$method,
        mfrmr:::make_param_cache(sizes,cfg,idx,is_mml=cfg$method=='MML'),
        idx,cfg,sizes,if(q)mfrmr:::gauss_hermite_normal(q) else NULL)
    }
    a <- evaluator(prep);b <- evaluator(compressed);beta <- fit$opt$par
    coordinates <- seq_along(beta)
    if(cfg$method=='JML')coordinates <- coordinates[-seq_len(sizes$theta)]
    differences <- c(value=abs(a$value(beta)-b$value(beta)),
      gradient=max(abs(a$gradient(beta)-b$gradient(beta))))
    derivative <- vapply(coordinates,function(k) {
      plus <- minus <- beta;plus[k] <- plus[k]+1e-4;minus[k] <- minus[k]-1e-4
      max(abs((a$gradient(plus)-a$gradient(minus))-
        (b$gradient(plus)-b$gradient(minus))))/(2e-4)
    },0)
    stopifnot(differences['value']<1e-8,differences['gradient']<1e-8,max(derivative)<1e-6)
    rows[[job$Arm]] <- data.frame(Arm=job$Arm,EventRows=nrow(dat),CountRows=nrow(compressed$data),
      ValueDifference=differences['value'],GradientDifference=differences['gradient'],
      FullGradientStructuralDerivativeDifference=max(derivative))
  }
  result <- do.call(rbind,rows);rownames(result) <- NULL
  dir.create(out,recursive=TRUE,showWarnings=FALSE)
  write.csv(result,file.path(out,'summary.csv'),row.names=FALSE)
  saveRDS(list(summary=result,input=input$InputId,runtime=wide_multi_runtime(),
    script=tools::md5sum('inst/validation/mfrm-wide-map-independent-events-20261003.R'),
    note='No fits or new data. This verifies likelihood/derivative equivalence under conditional independence, not independence of real re-ratings or public scoring admission.'),
    file.path(out,'verified.rds'))
  result
}
if(sys.nframe()==0L) {
  args <- commandArgs(trailingOnly=TRUE);stopifnot(length(args)==1L)
  wide_independent_events_check(args[1])
}
