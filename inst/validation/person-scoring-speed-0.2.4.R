# Load the installed package before sourcing from the development root.
# Timing: reuse pec_timing(preflight, output), running versions sequentially.
source("inst/validation/person-estimated-calibration-0.2.4-summary.R")

person_scoring_speed_replay <- function(preflight, output) {
  dir.create(output, recursive=TRUE, showWarnings=FALSE)
  results <- list()
  for (cell in c(1L,5L)) {
    fit <- readRDS(file.path(preflight,sprintf("cell-%02d-rep-0001.rds",cell)))$fit
    data <- pec_new_cohort(fit$config$model,95000192L,192L)$data
    data$Weight <- 1; data$Weight[1L] <- 0
    rejected <- tryCatch({predict_mfrm_units(fit,data,weight="Weight"); FALSE},
      error=function(e) grepl("strictly positive",conditionMessage(e),fixed=TRUE))
    stopifnot(rejected)
    for (weighted in c(FALSE,TRUE)) {
      data$Weight <- if (weighted) rep(c(0.1,0.25,1,2),length.out=nrow(data)) else 1
      result <- predict_mfrm_units(fit,data,weight="Weight",scoring_quad_points=61L,
        n_draws=10L,seed=714L)
      attr(result,"ZeroWeightRejected") <- rejected
      results[[paste(fit$config$model,weighted,sep="-")]] <- result
    }
  }
  saveRDS(results,file.path(output,"predictions.rds"))
  capture.output(sessionInfo(),file=file.path(output,"session.txt"))
  invisible(results)
}

compare_person_scoring_speed <- function(before, after) {
  old <- readRDS(file.path(before,"predictions.rds"))
  new <- readRDS(file.path(after,"predictions.rds"))
  stopifnot(identical(names(old),names(new)))
  result <- do.call(rbind,lapply(names(old),function(name) {
    x <- old[[name]]; y <- new[[name]]
    error <- max(abs(as.matrix(x$estimates[c("Lower","Upper")])-
      as.matrix(y$estimates[c("Lower","Upper")])))
    unchanged <- setdiff(names(x$estimates),c("Lower","Upper"))
    stopifnot(error<1e-8,identical(x$estimates[unchanged],y$estimates[unchanged]),
      identical(x$draws,y$draws),identical(x$settings,y$settings))
    stopifnot(isTRUE(attr(x,"ZeroWeightRejected")),isTRUE(attr(y,"ZeroWeightRejected")))
    data.frame(Case=name,Persons=nrow(x$estimates),MaxEndpointDifference=error,
      OtherEstimateFieldsIdentical=TRUE,DrawsIdentical=TRUE,SettingsIdentical=TRUE,
      ZeroWeightRejected=TRUE)
  }))
  write.csv(result,file.path(after,"prediction-comparison.csv"),row.names=FALSE)
  invisible(result)
}
