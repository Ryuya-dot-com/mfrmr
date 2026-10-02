# F orchestration/accounting contracts, without calibration fitting.
fscore <- new.env(parent=globalenv())
for (name in c("mml-stages-20261001","jml-stages-20261001","recovery-20261002","f-scoring-20261002")) {
  p <- test_path("..","..","inst","validation",paste0("mfrm-wide-map-",name,".R"))
  skip_if_not(file.exists(p),"Repository-only F scoring")
  sys.source(p,fscore)
}
f_input <- function() {
  root <- normalizePath(test_path("..",".."))
  path <- file.path(root,"validation-results/mfrm-wide-map-recovery-20261002/witness-manifest.rds")
  skip_if_not(file.exists(path),"Frozen A/B input")
  x <- readRDS(path)$payload$input
  names(x$provenance$bundle) <- file.path(root,names(x$provenance$bundle)); x
}
f_fake_source <- function() {
  x <- list(fit=list(calibration="frozen"),review=list(ready=TRUE),error="",stage="q61:fit",
    spec=list(ConditionId="condition",Replicate=1L,Arm="a"))
  x$SourceId <- fscore$wide_mml_hash(x); x
}
f_failure <- paste0("Posterior scoring integration did not pass the numerical accuracy check. ",
  "Increase `scoring_quad_points` or use `readiness_policy = \"review\"` to inspect the flagged scores.")

test_that("held-out panels preserve reserved streams, balanced rosters and linked events", {
  input <- f_input(); set.seed(72); before <- .Random.seed
  x <- fscore$wide_f_ab_panels(input)
  expect_identical(.Random.seed,before)
  expect_identical(x,fscore$wide_f_ab_panels(input))
  expect_length(x$panels,9)
  a <- x$panels$population_L1; b <- x$panels$population_L2
  expect_equal(nrow(a$data),360); expect_equal(nrow(b$data),720)
  expect_identical(a$planned,b$planned); expect_identical(a$seeds,b$seeds)
  d <- b$data[b$data$Event==1, ]; rownames(d)<-NULL
  expect_identical(a$data,d)
  expect_equal(as.integer(table(a$planned$Pair)),rep(20L,3))
  expect_false(any(a$planned$Person %in% input$data$Person))
  expect_equal(vapply(x$panels[paste0("grid",1:5,"_L1")],function(p) unique(p$planned$Theta),0),
    setNames(-2:2,paste0("grid",1:5,"_L1")))
  expect_equal(x$panels$shift_mean_L1$distribution$mean,.75)
  expect_equal(x$panels$shift_sd_L1$distribution$sd,.5)
  hashes <- unlist(lapply(x$registry,function(s) vapply(s,fscore$wide_mml_hash,"")))
  expect_equal(length(unique(hashes)),32)
  # Alternate calibration exposure receives the identical held-out responses.
  b0 <- readRDS(names(input$provenance$bundle)); input$data <- b0$views[["paired-L2"]]
  input$provenance$view <- "paired-L2"
  y <- fscore$wide_f_ab_panels(input)
  expect_identical(y$panels$population_L1$DataId,a$DataId)
  expect_identical(y$panels$population_L2$DataId,b$DataId)
  expect_equal(y$panels$population_L2$Family,"F-pop")
})

test_that("only the exact batch integration refusal retries, with unchanged rows and calibration", {
  panel <- fscore$wide_f_ab_panels(f_input())$panels$population_L1
  source <- f_fake_source(); calls <- list()
  old <- fscore$wide_f_predict; on.exit(fscore$wide_f_predict <- old)
  fscore$wide_f_predict <- function(fit,data,prior,q) {
    calls[[length(calls)+1L]] <<- list(fit=fit,data=data,prior=prior,q=q)
    if (q==31L) stop(f_failure,call.=FALSE)
    list(unchanged="public output fixture")
  }
  out <- tempfile(); z <- fscore$wide_f_run(source,panel,"reference",out,list(version=1))
  expect_equal(z$selected_order,61L); expect_length(calls,2)
  expect_identical(calls[[1]]$data,calls[[2]]$data)
  expect_identical(calls[[1]]$fit,calls[[2]]$fit)
  expect_identical(calls[[1]]$prior,list(mean=0,sd=1))
  expect_false("Theta" %in% names(calls[[1]]$data))
  paths <- list.files(out,"[.]rds$",full.names=TRUE); paths <- paths[basename(paths)!="status.rds"]
  before <- tools::md5sum(paths)
  fscore$wide_f_predict <- function(...) stop("Unexpected recomputation")
  expect_identical(fscore$wide_f_run(source,panel,"reference",out,list(version=1)),z)
  expect_identical(tools::md5sum(paths),before)
  expect_error(fscore$wide_f_run(source,panel,"retained",out,list(version=1)),"changed")
  expect_false(fscore$wide_f_retry("The retained calibration or scoring prior is invalid"))
  expect_false(fscore$wide_f_retry("Scoring could not produce finite posterior summaries"))
  fscore$wide_f_predict <- function(...) stop(f_failure,call.=FALSE)
  z <- fscore$wide_f_run(source,panel,"reference",tempfile(),list(version=1))
  expect_equal(z$selected_order,121L); expect_length(z$attempts,3)
  rows <- fscore$wide_f_records(source,panel,z)
  expect_true(all(!rows$ScoreAvailable)); expect_true(all(!rows$IntervalAvailable))
  expect_true(all(rows$BatchStatus=="integration_refused")); expect_equal(nrow(rows),120)
  source$review$ready <- FALSE; source$SourceId <- NULL; source$SourceId <- fscore$wide_mml_hash(source)
  fscore$wide_f_predict <- function(...) stop("Must not call scorer")
  z <- fscore$wide_f_run(source,panel,"reference",tempfile(),list(version=1))
  expect_length(z$attempts,1)
  rows <- fscore$wide_f_records(source,panel,z)
  expect_true(all(rows$BatchStatus=="source_refused"))
})

f_accounting_rows <- function() data.frame(ConditionId="c",Replicate=c(1,1,2,2),Arm="a",
  Prior="reference",Rule="refinement",Panel="population_L1",Family="F-pop",Scale="canonical_theta",
  Person=rep(c("a","b"),2),ScoreAvailable=c(TRUE,TRUE,FALSE,FALSE),
  IntervalAvailable=c(TRUE,FALSE,FALSE,FALSE),Error=c(1,3,NA,NA),
  Lower=c(-1,NA,NA,NA),Upper=c(1,NA,NA,NA),Covered=c(TRUE,FALSE,FALSE,FALSE),
  Extreme=c(TRUE,FALSE,TRUE,FALSE),Observed=c(6,6,6,0),
  BatchStatus=c("returned","returned","source_refused","source_refused"),
  DataId=rep(c("p1","p2"),each=2),CohortId=rep(c("cohort1","cohort2"),each=2),Theta=0)

test_that("F error and inclusion retain zero-delivery calibrations and cluster-level MCSE", {
  rows <- f_accounting_rows(); c <- fscore$wide_f_contributions(rows)
  expect_equal(c$Planned,c(2,2)); expect_equal(c$Scores,c(2,0))
  expect_equal(c$ErrorSum,c(4,0)); expect_equal(c$SquaredErrorSum,c(10,0))
  z <- fscore$wide_f_summary(c,1:2)
  expect_equal(z$Availability,.5); expect_equal(z$AvailabilityMCSE,.5)
  expect_equal(z$Bias,2); expect_equal(z$RMSE,sqrt(5))
  expect_equal(z$IntervalAvailability,.25); expect_equal(z$ConditionalInclusion,1)
  expect_equal(z$ReturnedAndCovered,.25)
  expect_true(is.na(fscore$wide_f_summary(c[c$Replicate==1, ],1)$BiasMCSE))
  partial <- fscore$wide_f_summary(c)
  expect_false(partial$Complete); expect_true(is.na(partial$Availability)); expect_true(is.na(partial$RMSE))
  none <- fscore$wide_f_summary(c[c$Replicate==2, ],2)
  expect_equal(none$Availability,0); expect_true(is.na(none$Bias)); expect_true(is.na(none$ConditionalInclusion))
  expect_error(fscore$wide_f_contributions(rbind(rows,rows)),"Duplicate")
  expect_error(fscore$wide_f_summary(rbind(c,c)),"Duplicate")
  b <- rows; b$Arm <- "b"; b$Error[b$ScoreAvailable] <- c(2,2)
  p <- fscore$wide_f_paired(rbind(rows,b),"a","reference","b","reference")
  expect_equal(p$Joint,c(2,0)); expect_equal(p$SquaredErrorDifferenceSum,c(2,0))
  b$DataId[1] <- "different"
  expect_error(fscore$wide_f_paired(rbind(rows,b),"a","reference","b","reference"),"same planned")
})

test_that("returned scores join by Person and retain missing-only and interval limitations", {
  # A public-shape fixture isolates the ledger mapping; the real API and its
  # output validator are exercised by the retained eight-arm execution.
  local_mocked_bindings(prediction_validate_population_output=function(x) invisible(x),.package="mfrmr")
  p <- fscore$wide_f_ab_panels(f_input())$panels$population_L1
  p$planned <- p$planned[1:3, ]; p$data <- p$data[p$data$Person %in% p$planned$Person, ]
  p$data$Score[p$data$Person==p$planned$Person[3]] <- NA_integer_
  p$PanelId <- NULL; p$PanelId <- fscore$wide_mml_hash(p)
  s <- f_fake_source()
  t <- data.frame(Person=p$planned$Person[2:1],Estimate=c(.2,.1),SD=c(.5,.4),
    Lower=c(NA,-.7),Upper=c(NA,.9),PriorMean=0,PriorSD=1,EstimateUse="fitted_object_scoring")
  v <- structure(list(estimates=t,settings=list(scoring_quad_points=61L,interval_level=.95,
    n_draws=0L,readiness_policy="error",source_scoring_ready=TRUE,scoring_prior=list(mean=0,sd=1),
    score_integration_review=data.frame(Passed=c(TRUE,TRUE)))),class="mfrm_unit_prediction")
  z <- list(SourceId=s$SourceId,PanelId=p$PanelId,prior="reference",source_ready=TRUE,
    selected_order=61L,attempts=list(`31`=list(value=NULL,error=f_failure),`61`=list(value=v,error="")))
  rows <- fscore$wide_f_records(s,p,z); a <- rows[rows$Rule=="refinement", ]
  expect_equal(a$Estimate,c(.1,.2,NA)); expect_equal(a$ScoreAvailable,c(TRUE,TRUE,FALSE))
  expect_equal(a$IntervalAvailable,c(TRUE,FALSE,FALSE)); expect_equal(a$Observed,c(6L,6L,0L))
  expect_equal(a$Reason[3],"No usable responses")
  expect_equal(a$IntervalReason[2],"Conditional interval not returned")
  expect_true(all(a$BatchCheck=="public_EAP_SD_pass")); expect_true(all(a$SourceStage=="q61:fit"))
  expect_true(all(!rows$ScoreAvailable[rows$Rule=="default31"]))
  z$attempts[["61"]]$value$settings$score_integration_review <- NULL
  expect_true(all(fscore$wide_f_records(s,p,z)$BatchCheck[4:6]=="not_performed_by_public_procedure"))
  z$attempts[["61"]]$value$settings$scoring_prior <- list(mean=.75,sd=1)
  expect_error(fscore$wide_f_records(s,p,z))
})

test_that("A/B panel selection respects N, SD, truth and roster instead of expanding every condition", {
  root <- normalizePath(test_path("..","..","validation-results","mfrm-wide-map-r50-20261001","ab-inputs"))
  skip_if_not(file.exists(file.path(root,"inputs.csv")),"Frozen A/B registry")
  a <- fscore$wide_recovery_ab_input(root,"AB:paired-L1:N30:SD0.5:S-RSM",1L)
  x <- fscore$wide_f_ab_panels(a)
  expect_identical(names(x$panels),"population_L1")
  expect_equal(x$panels[[1]]$distribution$sd,.5)
  expect_equal(nrow(x$panels[[1]]$planned),60)
  b <- fscore$wide_recovery_ab_input(root,"AB:full-L1:N60:SD0.5:S-GPCM",1L)
  y <- fscore$wide_f_ab_panels(b)
  expect_length(y$panels,6); expect_equal(nrow(y$panels$population_L1$data),540)
  expect_equal(as.integer(table(y$panels$population_L1$data$Person)),rep(9L,60))
  expect_true(all(vapply(y$panels,function(p) all(p$data$Score %in% 0:3),TRUE)))
  expect_false(any(vapply(y$panels,function(p) p$Family=="F-shift",TRUE)))
  expect_false(identical(x$registry$population$response,y$registry$population$response))
})
