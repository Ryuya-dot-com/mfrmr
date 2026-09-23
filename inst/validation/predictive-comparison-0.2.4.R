# Run from the development package root. Reuse earlier calibration and diagnostics.
# No new simulation or model fitting. See predictive-comparison-record-0.2.4.md.
pkgload::load_all('.', quiet = TRUE)
out <- 'validation-results/predictive-comparison-20260923'
dir.create(out, recursive = TRUE, showWarnings = FALSE)
writeLines(c('Same-data predictive target, calibration fixed; no cutoff/coverage claim.',
  'Independent continuous ordinary probability tolerance: 1e-8.',
  'Separately fitted zero-testlet reduction: maximum probability/mean/variance/index difference 1e-5.',
  'Missing roster: 320 assigned, 306 observed, 14 missing; no available-row deletion.',
  'Saved examples and plots must replay with optional RTMB unavailable; no refits.'), file.path(out,'protocol.txt'))
o <- readRDS('validation-results/extended-comparison-20260923/ordinary.rds')
a <- mfrm_response_diagnostics(o, group_by = 'Rater')
saveRDS(a, file.path(out,'ordinary-diagnostics.rds'))
# Direct RSM probabilities and continuous ability integration for one Person.
d <- o$prep$data; ids <- which(d$Person == d$Person[1]); steps <- o$steps$Estimate
mu <- as.numeric(o$population$coefficients); sd <- sqrt(o$population$sigma2)
off <- vapply(ids,function(i) sum(vapply(c('Rater','Criterion'),function(f) {
  z <- o$facets$others; z$Estimate[z$Facet == f & z$Level == as.character(d[[f]][i])]
},numeric(1))),numeric(1))
k <- 0:length(steps)
probs <- function(theta, offset) { z <- k * (theta - offset) - c(0,cumsum(steps)); z <- exp(z-max(z)); z/sum(z) }
integral <- function(category=NULL) integrate(function(theta) vapply(theta,function(t) {
  p <- vapply(off, function(v) probs(t,v), numeric(length(k)))
  mass <- prod(p[cbind(d$score_k[ids]+1L,seq_along(ids))]) * dnorm(t,mu,sd)
  mass * if (is.null(category)) 1 else p[category,1]
},numeric(1)), -Inf, Inf, rel.tol=1e-10, abs.tol=0)$value
reference <- vapply(seq_along(k),integral,numeric(1))/integral()
continuous_difference <- max(abs(reference-a$probabilities[1,]))
stopifnot(continuous_difference < 1e-8)
saveRDS(list(reference=reference,api=a$probabilities[1,],difference=continuous_difference),file.path(out,'continuous-reference.rds'))
z <- readRDS('validation-results/extended-comparison-20260923/zero-reference.rds')
za <- mfrm_response_diagnostics(z$ordinary, group_by='Rater')
zb <- mfrm_response_diagnostics(z$zero_testlet, group_by='Rater')
zero <- compare_mfrm(z$ordinary,z$zero_testlet,response_diagnostics=list(za,zb))
zero_differences <- c(probability=max(abs(zero$responses$probabilities$Difference)),
  mean=max(abs(zero$responses$rows$ExpectedScoreDifference)),variance=max(abs(zero$responses$rows$PredictiveVarianceDifference)),
  infit=max(abs(zero$responses$measures$InfitDifference)),outfit=max(abs(zero$responses$measures$OutfitDifference)))
stopifnot(all(zero_differences < 1e-5))
saveRDS(list(comparison=zero,differences=zero_differences),file.path(out,'zero-testlet.rds'))
for (name in c('testlet','random')) {
  old <- readRDS(paste0('validation-results/response-diagnostics-20260923/',name,'-workflow.rds'))
  ref <- if (name=='testlet') a else mfrm_response_diagnostics(o,rows=old$diagnostics$rows$InputRow,group_by='Rater')
  cmp <- compare_mfrm(o,old$fit,labels=c('Ordinary RSM',if(name=='testlet') 'Testlet RSM' else 'Shared-rater RSM'),response_diagnostics=list(ref,old$diagnostics))
  res <- mfrm_results(old$fit,comparison=cmp,response_diagnostics=old$diagnostics,compute='never')
  stopifnot(identical(mfrm_report(res)$tables$comparison_response_rows,cmp$responses$rows))
  saveRDS(cmp,file.path(out,paste0(name,'-comparison.rds')))
  saveRDS(res,file.path(out,paste0(name,'-results.rds')))
  exported <- export_mfrm_results(res,output_dir=file.path(out,paste0(name,'-archive')),preset='starter',acknowledge_sensitive=TRUE,overwrite=TRUE)
  stopifnot(nrow(exported$plot_errors)==0)
  saveRDS(exported,file.path(out,paste0(name,'-export.rds')))
  png(file.path(out,paste0(name,'-infit-difference.png')),width=1200,height=900,res=144)
  plot(cmp,metric='infit',style='difference',title='How do rater residual summaries change?')
  dev.off()
  gp <- as_ggplot(cmp,metric='probability',show_labels=FALSE,show_title=FALSE,show_notes=FALSE,palette='mono')
  ggplot2::ggsave(file.path(out,paste0(name,'-probability.png')),gp,width=9,height=5.5,dpi=144)
}
m <- readRDS('validation-results/extended-comparison-20260923/omissions-workflow.rds')
ma <- mfrm_response_diagnostics(m$ordinary,group_by='Person')
mb <- readRDS('validation-results/response-diagnostics-20260923/omissions.rds')$diagnostics
# The earlier saved diagnostics also group by Block/Criterion: selecting summaries
# does not alter their probabilities or source. No extra testlet integration.
mb$measures <- mb$measures[mb$measures$Facet=='Person',]; rownames(mb$measures)<-NULL
mb$settings$group_by <- 'Person'
omissions <- compare_mfrm(m$ordinary,m$extension,response_diagnostics=list(ma,mb))
stopifnot(nrow(omissions$responses$rows)==320,sum(omissions$responses$rows$Status=='missing_score')==14,
  sum(omissions$responses$rows$Status=='available_descriptive')==306)
saveRDS(omissions,file.path(out,'omissions-comparison.rds'))
r <- mfrm_results(o,response_diagnostics=a,compute='never')
stopifnot(identical(mfrm_report(r)$tables$response_measures,a$measures))
saveRDS(r,file.path(out,'ordinary-results.rds'))
export_mfrm_results(r,output_dir=file.path(out,'ordinary-archive'),include=c('tables','rds','replay','manifest'),acknowledge_sensitive=TRUE,overwrite=TRUE)
summary <- data.frame(Check=c('continuous_probability',paste0('zero_testlet_',names(zero_differences))),
  MaximumDifference=c(continuous_difference,zero_differences),Tolerance=c(1e-8,rep(1e-5,5)))
write.csv(summary,file.path(out,'numerical-summary.csv'),row.names=FALSE)
print(summary)
capture.output(sessionInfo(),file=file.path(out,'session-info.txt'))
