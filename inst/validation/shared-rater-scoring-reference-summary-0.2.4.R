# Read-only summaries: retain the original quantile decisions separately.
out <- 'validation-results/shared-rater-scoring-reference-20260923'
plan <- readRDS(file.path(out,'plan.rds'))
original <- readRDS(file.path(out,'summary.rds'))
stopifnot(nrow(original$comparisons)==192L,nrow(original$status)==12L)
stopifnot(all(is.finite(original$status$MaxLogJointError)),
  all(original$status$MaxLogJointError<1e-8))
cdfs <- endpoints <- diagnostics <- list()
for(rec in plan$records) {
  x <- readRDS(file.path(out,sprintf('tails-%02d.rds',rec$index)))
  stopifnot(x$index==rec$index,identical(x$source,tools::md5sum(names(x$source))))
  for(person in rec$persons) {
    a <- x$results[[person]]
    stopifnot(!is.null(a))
    if(!isTRUE(a$available)) {
      for(q in c('Lower','Upper')) endpoints[[length(endpoints)+1L]] <-
        data.frame(Case=rec$index,Roster=rec$roster,Person=person,Quantity=q,Decision='score_unavailable')
      next
    }
    s <- a$stats
    stopifnot(nrow(s)==4L,all(is.finite(s$Mean)),all(s$Mean>=0 & s$Mean<=1),
      s$Mean[1]<s$Mean[2],s$Mean[3]<s$Mean[4])
    cdfs[[length(cdfs)+1L]] <- cbind(Case=rec$index,Roster=rec$roster,Person=person,
      Quantity=rep(c('Lower','Upper'),each=2),Side=rep(c('minus .10','plus .10'),2),s)
    for(q in c('Lower','Upper')) endpoints[[length(endpoints)+1L]] <-
      data.frame(Case=rec$index,Roster=rec$roster,Person=person,Quantity=q,Decision=unname(a$decision[q]))
    diagnostics[[length(diagnostics)+1L]] <- data.frame(Case=rec$index,Roster=rec$roster,Person=person,
      NumericalReady=a$numeric_ready,CDFDifference=a$cdf_difference,
      NormalizerDifference=a$normalizer_difference,MinimumNormalizer=a$min_normalizer,
      TailBound=a$tail_bound,ContinuousCDFError=a$continuous_error,
      ContinuousNormalizerError=a$continuous_normalizer_error)
  }
}
cdfs <- do.call(rbind,cdfs);endpoints <- do.call(rbind,endpoints);diagnostics <- do.call(rbind,diagnostics)
stopifnot(nrow(endpoints)==96L,!anyDuplicated(endpoints[c('Case','Person','Quantity')]))
decisions <- rbind(original$comparisons[original$comparisons$Quantity %in% c('Estimate','ConditionalSD'),
  c('Case','Roster','Person','Quantity','Decision')],endpoints)
stopifnot(nrow(decisions)==192L,!anyDuplicated(decisions[c('Case','Person','Quantity')]))
maxima <- aggregate(cbind(AbsoluteError,ErrorUpper,MCSE)~Roster+Quantity,
  original$comparisons,max)
for(n in c('cdfs','endpoints','diagnostics','decisions','maxima'))
  write.csv(get(n),file.path(out,paste0('tail-',n,'.csv')),row.names=FALSE)
saveRDS(list(original=original,cdfs=cdfs,endpoints=endpoints,diagnostics=diagnostics,
  decisions=decisions,maxima=maxima,summary_source=tools::md5sum(
    'inst/validation/shared-rater-scoring-reference-summary-0.2.4.R')),
  file.path(out,'complete-summary.rds'))
cat('Original raw-quantile comparison (retained unchanged):\n')
print(table(original$comparisons$Quantity,original$comparisons$Decision))
cat('Original mean/SD and conditional-CDF endpoint decisions:\n')
print(table(decisions$Quantity,decisions$Decision))
print(maxima,row.names=FALSE)
cat('Conditional-CDF max MCSE:',max(cdfs$MCSE),'; max Rhat:',max(cdfs$Rhat),
  '; min bulk/tail ESS:',min(cdfs$BulkESS),min(cdfs$TailESS),'\n')
print(sapply(diagnostics[c('CDFDifference','NormalizerDifference','TailBound',
  'ContinuousCDFError','ContinuousNormalizerError')],max))
