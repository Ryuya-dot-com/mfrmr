# Exact decision and allocation checks; no draws, estimator calls or RNG reservations.
confirm_paths <- test_path('..','..','inst','validation',c('mfrm-lr-rsm-boundary-20261009.R',
  'mfrm-lr-rsm-stages-20261009.R','mfrm-lr-rsm-confirmation-20261009.R'))
skip_if_not(all(file.exists(confirm_paths)),'Repository-only RSM confirmation')
confirm_env <- new.env(parent=globalenv())
for(path in confirm_paths) sys.source(path,confirm_env)

test_that('the frozen decision separates adequate, adverse and inconclusive evidence', {
  decide <- confirm_env$rsm_confirm_decision
  good <- decide(800L,800L,760L)
  expect_identical(good$status,'supported')
  expect_identical(good$coverage,unname(stats::binom.test(760L,800L)$conf.int))
  expect_identical(decide(800L,800L,680L)$status,'repair_required')
  expect_identical(decide(800L,800L,800L)$status,'repair_required')
  expect_identical(decide(800L,800L,750L)$status,'inconclusive')
  expect_identical(decide(800L,720L,684L)$status,'repair_required')
  empty <- decide(800L,0L,0L)
  expect_identical(empty$status,'repair_required');expect_true(all(is.na(empty$coverage)))
  expect_identical(empty$joint,unname(stats::binom.test(0L,800L)$conf.int))
  expect_error(decide(800L,801L,760L));expect_error(decide(800L,750L,751L))
  expect_error(decide(800L,750.5,710L));expect_error(decide(0L,0L,0L))
})

test_that('precision and the two shards match the planned independent units', {
  p <- confirm_env$rsm_confirm_protocol()
  expect_identical(p$N,c(20L,240L));expect_identical(p$Replicates,800L)
  returned <- p$Replicates*p$criteria$availability
  k <- 0:returned
  intervals <- vapply(k,function(x)confirm_env$rsm_confirm_cp(x,returned),numeric(2))
  accepted <- intervals[1,]>=p$criteria$coverage[1] & intervals[2,]<=p$criteria$coverage[2]
  expect_lt(sqrt(.95*.05/returned),.008)
  expect_gt(sum(stats::dbinom(k[accepted],returned,.95)),.90)
  expect_lt(sqrt(.25/p$Replicates),.02)
  units <- expand.grid(Replicate=seq_len(p$Replicates),N=p$N)
  shards <- lapply(seq_len(p$Shards),function(i)seq(i,nrow(units),by=p$Shards))
  expect_length(intersect(shards[[1]],shards[[2]]),0L)
  expect_equal(sort(unlist(shards)),seq_len(nrow(units)))
  expect_true(all(vapply(shards,function(ix)all(table(units$N[ix])==400L),TRUE)))
})
