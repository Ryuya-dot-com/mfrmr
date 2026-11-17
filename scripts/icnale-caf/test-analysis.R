# Run from the package checkout with the matching mfrmr installed.
source("scripts/icnale-caf/preprocess.R")
source("scripts/icnale-caf/analyse.R")
library(testthat)
test_that("the workflow saves failures and only reuses matching successful fits", {
  out <- tempfile("synthetic-icnale-")
  on.exit(unlink(out, recursive = TRUE))
  input <- list(source_md5 = "synthetic", ratings = data.frame(Person = "fictional",
    Rater = "one", Criterion = "Complexity", Score = 0L))
  fail <- TRUE
  calls <- 0L
  local_mocked_bindings(fit_mfrm = function(...) {
    calls <<- calls + 1L
    if (fail) stop("synthetic fitting failure")
    list(synthetic = TRUE)
  }, .package = "mfrmr")
  expect_error(icnale_fit(input, "RSM", out), "synthetic fitting failure")
  saved <- readRDS(file.path(out, "rsm-failure.rds"))
  expect_s3_class(saved$error, "error")
  expect_identical(conditionMessage(saved$error), "synthetic fitting failure")
  expect_false(file.exists(file.path(out, "rsm-fit.rds")))
  fail <- FALSE
  fit <- icnale_fit(input, "RSM", out)
  expect_identical(icnale_fit(input, "RSM", out), fit)
  expect_identical(calls, 2L)
  input$ratings$Score <- 1L
  expect_error(icnale_fit(input, "RSM", out), "different input")
  expect_identical(calls, 2L)
})

test_that('the workflow distinguishes one- and two-family identification', {
  out <- tempfile('synthetic-models-');on.exit(unlink(out,recursive=TRUE))
  input <- list(source_md5='synthetic',ratings=data.frame(Person='p',Rater='r',Criterion='c',Score=0L))
  local_mocked_bindings(fit_mfrm=function(data,spec,control) list(spec=spec,control=control),.package='mfrmr')
  one <- icnale_fit(input,'GPCM1',out)$spec
  two <- icnale_fit(input,'GPCM2',out)$spec
  expect_identical(one$slope_facet,'Criterion')
  expect_identical(one$gpcm_mml_identification,'free_population')
  expect_identical(two$slope_facet,c('Criterion','Rater'))
  expect_identical(two$slope_reference,'Criterion')
  expect_identical(two$noncenter_facet,'Criterion')
  expect_null(two$population_formula)
  expect_null(two$person_data)
})

source('scripts/icnale-caf/compare.R')
source('scripts/icnale-caf/conquest.R')
test_that('comparison probabilities preserve adjacent odds and affine scaling', {
  f <- structure(list(config=list(model='GPCM',method='MML',n_cat=11L,
    facet_names=c('Rater','Criterion'),slope_facet=c('Criterion','Rater')),
    facets=list(others=data.frame(Facet=c('Rater','Criterion'),Level=c('r','c'),Estimate=c(.3,-.4))),
    slopes=data.frame(SlopeOwner=c('Criterion','Rater'),SlopeFacet=c('c','r'),Estimate=c(1.2,.7)),
    steps=data.frame(StepFacet='c',Step=paste0('Step_',1:10),Estimate=seq(-.9,.9,length.out=10))),class='mfrm_fit')
  query<-data.frame(Rater='r',Criterion='c');theta<-.6
  p<-icnale_probabilities(f,query,theta)
  expect_equal(diff(log(p[1,])),1.2*.7*(theta-.3+.4-f$steps$Estimate),tolerance=1e-13)
  expect_equal(sum(p),1)
  scaled<-f;mu<-.2;sd<-1.4
  scaled$facets$others$Estimate<-c(.3/sd,(-.4-mu)/sd)
  scaled$steps$Estimate<-scaled$steps$Estimate/sd
  scaled$slopes$Estimate[2]<-scaled$slopes$Estimate[2]*sd
  expect_equal(icnale_probabilities(scaled,query,(theta-mu)/sd),p,tolerance=1e-13)
})

test_that('ConQuest export preserves source cells and separates zero-weight support', {
  out<-tempfile('synthetic-conquest-');on.exit(unlink(out,recursive=TRUE))
  d<-expand.grid(Person=c('p1','p2'),Rater=c('r1','r2'),Criterion=c('a','c','f'),stringsAsFactors=FALSE)
  d$Score<-rep(c(0L,10L,3L,8L),3);d<-d[-2,]
  x<-icnale_conquest(list(ratings=d,source_md5='synthetic'),c('r2','r1'),out)
  rows<-readLines(file.path(out,'ratings.dat'))
  expect_identical(x$source_ratings,11L)
  expect_equal(nchar(rows),rep(7L,13))
  expect_equal(substr(rows,7,7),c('1','1',rep('0',11)))
  expect_equal(sum(strsplit(paste(substr(rows[1:2],1,6),collapse=''),'')[[1]]!=' '),11L)
  expect_error(icnale_conquest(list(ratings=d),c('r2','r1'),out),'unused')
})
