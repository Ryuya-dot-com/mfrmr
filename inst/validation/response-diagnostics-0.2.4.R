# Bounded numerical audit for the posterior predictive residual API.
# Run from the development package root after the cited saved-fit workflows.
# Uses optional RTMB and statmod; no calibration fitting or bootstrap is run.
# A fresh output directory is required for the archive stage.
.libPaths(c(normalizePath('.r-library'), .libPaths()))
pkgload::load_all('.', quiet=TRUE)
out <- 'validation-results/response-diagnostics-20260923'
# Load only the fixed-reference fixture definitions, not the tests.
expr <- parse('tests/testthat/test-response-diagnostics.R')
for (e in expr[1:2]) eval(e)
# Independent tensor integration: direct adjacent-category probabilities,
# joint rater prior, and every Person's ability integral before normalization.
exact <- function(f, order) {
  rule <- statmod::gauss.quad.prob(order, dist='normal')
  grid <- expand.grid(a=seq_len(order), b=seq_len(order))
  u <- cbind(rule$nodes[grid$a],rule$nodes[grid$b])*f$calibration$rater_sd
  wt <- rule$weights[grid$a]*rule$weights[grid$b]
  ability <- rule$nodes*f$calibration$person_sd
  joint <- rep(1,nrow(grid)); focal <- NULL
  for (person in sort(unique(f$input$person))) {
    ll <- matrix(1,nrow(grid),order); focal_prob <- NULL
    for (i in which(f$input$person==person)) {
      eta <- outer(-u[,f$input$rater[i]],ability,'+')
      lw <- list(0*eta,eta+.6,2*eta); shift <- pmax(lw[[1]],lw[[2]],lw[[3]])
      w <- lapply(lw,function(z) exp(z-shift)); den <- Reduce('+',w)
      p <- lapply(w,function(z) z/den)
      ll <- ll*p[[f$input$y[i]+1L]]
      if(i==1) focal_prob <- p
    }
    marginal <- as.vector(ll%*%rule$weights)
    if(!is.null(focal_prob)) focal <- vapply(focal_prob,function(p)
      as.vector((ll*p)%*%rule$weights)/marginal,numeric(nrow(grid)))
    joint <- joint*marginal
  }
  posterior <- joint*wt; posterior <- posterior/sum(posterior)
  colSums(focal*posterior)
}
protocol <- expand.grid(RaterSD=c(0,.7,2),PersonSD=c(.7,1.2),Pattern=c('mixed','extreme','sparse'),stringsAsFactors=FALSE)
saveRDS(list(conditions=protocol,reference_orders=c(41L,81L),extra_reference_order=121L,
  criterion=1e-7,diagnostic_order=121L,target_row=1L,scope='Fixed-calibration numerical integration audit; not repeated-sampling fit calibration'),file.path(out,'protocol.rds'))
results <- vector('list',nrow(protocol))
for(j in seq_len(nrow(protocol))) {
  c <- protocol[j,]; f <- response_random_fixture(c$RaterSD,c$PersonSD)
  if(c$Pattern=='extreme') f$input$y <- c(0,2,2,0,2,2)
  if(c$Pattern=='sparse') {
    d <- f$input$data[-c(3,5),];
    f$input <- mfrm_random_rater_data(d,'Person','Rater',character(),'Score',0:2,reference=f$input)
  }
  f$input$data$Score <- f$input$y; f$input$assigned_data <- f$input$data
  low <- exact(f,41); high <- exact(f,81); delta <- max(abs(high-low)); used <- 81L
  if(delta>1e-7) { previous<-high; high<-exact(f,121);delta<-max(abs(high-previous)); used<-121L }
  d <- mfrm_response_diagnostics(f,rows=1,group_by='Rater',quad_points=121)
  results[[j]] <- list(fit=f,diagnostics=d,reference=high,reference_difference=delta,reference_order=used)
  saveRDS(results[[j]],file.path(out,sprintf('reference-%02d.rds',j)))
  cat(j,c$RaterSD,c$PersonSD,c$Pattern,'error',max(abs(as.numeric(d$probabilities)-high)), 'reference',delta,'\n')
}
tab <- do.call(rbind,lapply(seq_along(results),function(j) {
  z <- results[[j]];p<-as.numeric(z$diagnostics$probabilities);ref<-z$reference
  mean<-sum((0:2)*ref);variance<-sum(((0:2)-mean)^2*ref)
  cbind(protocol[j,],data.frame(ProbabilityError=max(abs(p-ref)),MeanError=abs(z$diagnostics$rows$ExpectedScore-mean),
    VarianceError=abs(z$diagnostics$rows$PredictiveVariance-variance),ReferenceDifference=z$reference_difference,
    ReferenceOrder=z$reference_order,NormalizationError=z$diagnostics$rows$NormalizationError,
    IntegrationDifference=z$diagnostics$rows$IntegrationDifference,Status=z$diagnostics$rows$Status))
}))
write.csv(tab,file.path(out,'reference-summary.csv'),row.names=FALSE)
stopifnot(all(tab$ReferenceDifference<1e-7),all(tab$Status=='available_conditional'))
# Existing real fits, never re-estimated. All testlet rows and a complete
# single-Person set of shared-rater rows; conditioning always retains 768 rows.
for (kind in c('testlet','random')) {
  f <- readRDS(file.path('validation-results/extended-comparison-20260923',paste0(kind,'-workflow.rds')))$fit
  roster <- f$input$assigned_data %||% f$input$data
  rows <- if(kind=='testlet') NULL else which(roster$Person==roster$Person[1])
  start<-proc.time();d <- mfrm_response_diagnostics(f,rows=rows,group_by='Rater',quad_points=121)
  elapsed<-unname((proc.time()-start)['elapsed'])
  saveRDS(list(fit=f,diagnostics=d,elapsed=elapsed),file.path(out,paste0(kind,'-workflow.rds')))
  print(d$measures);print(table(d$rows$Status));cat(kind,'seconds',elapsed,'\n')
  res<-mfrm_results(f,diagnostics=d)
  for(style in c('paired','scatter')) {
    png(file.path(out,paste0(kind,'-',style,'-base.png')),width=1200,height=750,res=130)
    plot(d,style=style);dev.off()
    p<-as_ggplot(d,style=style)
    ggplot2::ggsave(file.path(out,paste0(kind,'-',style,'-ggplot.png')),p,width=9,height=5.5,dpi=140)
  }
  archive<-export_mfrm_results(res,file.path(out,paste0(kind,'-archive')),preset='starter',acknowledge_sensitive=TRUE)
  stopifnot(archive$summary$PlotErrors==0)
  saveRDS(res,file.path(out,paste0(kind,'-results.rds')))
}
