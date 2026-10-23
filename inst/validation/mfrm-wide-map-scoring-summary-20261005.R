# Sampling precision needs at least two contributing calibration replicates.
# In particular, one returned batch cannot establish zero conditional MCSE.
wide_f_summary_precision <- function(contributions,expected_replicates=1:50) {
  result <- wide_f_summary(contributions,expected_replicates)
  keys <- c('ConditionId','Arm','Prior','Rule','Panel','Family','Scale')
  key <- function(x)do.call(paste,c(x[keys],sep='\r'))
  groups <- split(contributions,key(contributions))
  result$ScoreReplicates <- vapply(key(result),function(k)sum(groups[[k]]$Scores>0L),1L)
  result$IntervalReplicates <- vapply(key(result),function(k)sum(groups[[k]]$Intervals>0L),1L)
  for(name in c('BiasMCSE','MSEMCSE','RMSEMCSE'))
    result[[name]][result$ScoreReplicates<2L] <- NA_real_
  for(name in c('WidthMCSE','ConditionalInclusionMCSE'))
    result[[name]][result$IntervalReplicates<2L] <- NA_real_
  result
}
