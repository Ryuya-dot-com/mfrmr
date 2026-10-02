# Repository-only A/B held-out scoring. Source mml-stages, jml-stages and
# recovery first. Calibration, batch nodes, priors and evaluation truth remain
# separate. Completed phases are immutable; one worker owns each directory.
wide_f_ab_panels <- function(input) {
  path <- names(input$provenance$bundle)
  stopifnot(length(path) == 1L, identical(tools::md5sum(path), input$provenance$bundle))
  b <- readRDS(path); view <- input$provenance$view
  stopifnot(view %in% c("full-L1", "paired-L1", "paired-L2"),
    identical(input$data, b$views[[view]]), b$unit$Replicate == input$Replicate,
    identical(input$levels, list(Rater = as.character(1:3), Criterion = as.character(1:3))),
    identical(input$categories, 0:3))
  truth <- b$truth
  names(truth$Rater) <- names(truth$Criterion) <- as.character(1:3)
  rownames(truth$steps) <- names(truth$log_slopes) <- as.character(1:3)
  stopifnot(identical(truth, input$truth))
  old_kind <- RNGkind(); had_seed <- exists(".Random.seed", .GlobalEnv, inherits = FALSE)
  if (had_seed) old_seed <- get(".Random.seed", .GlobalEnv)
  on.exit({do.call(RNGkind, as.list(old_kind)); if (had_seed) assign(".Random.seed", old_seed, .GlobalEnv)
    else if (exists(".Random.seed", .GlobalEnv, inherits = FALSE)) rm(".Random.seed", envir = .GlobalEnv)}, add = TRUE)
  RNGkind("L'Ecuyer-CMRG", normal.kind = "Inversion", sample.kind = "Rejection")
  # Fixed substream allocation, including unused panels. The reserved AB F
  # substream is local to this parent; the A-E global stream head is untouched.
  stream <- b$rng$F_first_unused; registry <- list()
  for (id in c("population", paste0("grid", 1:5), "shift_mean", "shift_sd")) {
    registry[[id]] <- list()
    for (component in c("ability", "assignment", "response", "missingness")) {
      registry[[id]][[component]] <- stream; stream <- parallel::nextRNGSubStream(stream)
    }
  }
  selected <- list(population = list(M = 60L, mean = 0, sd = b$unit$SD, theta = NULL))
  anchor <- b$unit$N %in% c(20L,60L,240L,480L)
  if (anchor && view != "paired-L2") for (k in 1:5)
    selected[[paste0("grid",k)]] <- list(M = 30L, mean = NA_real_, sd = NA_real_, theta = k-3)
  if (anchor && view == "paired-L1" && b$unit$SD == 1) {
    selected$shift_mean <- list(M = 60L, mean = .75, sd = 1, theta = NULL)
    selected$shift_sd <- list(M = 60L, mean = 0, sd = .5, theta = NULL)
  }
  panels <- list()
  for (id in names(selected)) {
    p <- selected[[id]]; seeds <- registry[[id]]; M <- p$M
    assign(".Random.seed", seeds$ability, .GlobalEnv)
    theta <- if (is.null(p$theta)) rnorm(M, p$mean, p$sd) else rep(p$theta, M)
    persons <- paste0("F-", id, "-", sprintf("%03d", seq_len(M)))
    assign(".Random.seed", seeds$assignment, .GlobalEnv)
    pair <- integer(M); pair[sample.int(M)] <- rep(1:3, each = M/3)
    pairs <- rbind(c(1,2),c(2,3),c(3,1))
    L <- if (id == "population" && anchor) 2L else 1L
    g <- expand.grid(PersonIndex = seq_len(M), RaterIndex = 1:3, CriterionIndex = 1:3, Event = seq_len(L))
    probability_input <- input
    probability_input$grid <- data.frame(Theta = theta[g$PersonIndex],
      Rater = as.character(g$RaterIndex), Criterion = as.character(g$CriterionIndex))
    mass <- wide_recovery_probabilities(probability_input, input$truth)
    assign(".Random.seed", seeds$response, .GlobalEnv)
    u <- runif(nrow(g)); cdf <- t(apply(mass, 1L, cumsum))[,1:3,drop = FALSE]
    data <- data.frame(RowId = seq_len(nrow(g)), Person = persons[g$PersonIndex],
      Rater = as.character(g$RaterIndex), Criterion = as.character(g$CriterionIndex),
      Event = g$Event, Score = as.integer(rowSums(u > cdf)))
    keep <- if (view == "full-L1") rep(TRUE,nrow(g)) else
      g$RaterIndex == pairs[pair[g$PersonIndex],1] | g$RaterIndex == pairs[pair[g$PersonIndex],2]
    exposures <- if (id == "population" && anchor && view != "full-L1") c(1L,2L) else 1L
    for (exposure in exposures) {
      key <- paste0(id,"_L",exposure); d <- data[keep & g$Event <= exposure, ]; rownames(d) <- NULL
      planned <- data.frame(Person = persons, Theta = theta, Pair = pair)
      z <- list(Panel = key, Family = if (id == "population") {
        if (exposure == if (view == "paired-L2") 2L else 1L) "F-pop" else "F-exposure"
      } else if (startsWith(id,"grid")) "F-grid" else "F-shift",
        CohortId = paste(b$unit$ParentId,id,sep=":"), data = d, planned = planned,
        distribution = p, exposure = exposure, seeds = seeds,
        provenance = input$provenance$bundle, scale = "canonical_theta",
        contract = "AB_held_out_v1")
      stopifnot(!any(persons %in% input$data$Person), all(table(d$Person) ==
        if (view == "full-L1") 9L else 6L*exposure))
      z$DataId <- wide_mml_hash(list(data=d,planned=planned,CohortId=z$CohortId,scale=z$scale))
      z$PanelId <- wide_mml_hash(z); panels[[key]] <- z
    }
  }
  list(panels = panels, registry = registry, next_unused_substream = stream,
    parent = b$unit, calibration_input = input$InputId)
}

wide_f_read <- function(path) {
  z <- readRDS(path)
  stopifnot(identical(z$checksum, wide_mml_hash(z$payload)))
  z
}

wide_f_source <- function(out, input) {
  m <- wide_f_read(file.path(out,"manifest.rds"))$payload
  z <- wide_f_read(file.path(out,"selected.rds"))
  stopifnot(identical(z$binding, wide_mml_hash(m)),
    identical(z$payload$spec_hash, wide_mml_hash(m$spec)))
  s <- z$payload$point; order <- as.integer(sub("^q([0-9]+):.*", "\\1", s$stage))
  f <- wide_f_read(file.path(out,paste0("q",order,"-fit.rds")))
  stopifnot(identical(f$binding, list(job = wide_mml_hash(m), order = order, phase = "fit", dependency = NULL)),
    identical(s$fit_hash, f$checksum), identical(s$stage,paste0("q",order,":",f$checksum)))
  if (!nzchar(f$payload$error)) wide_recovery_fit_identity(f$payload$value,input,m$spec)
  x <- list(fit = f$payload$value, review = s$value, error = s$error,
    stage = s$stage, spec = m$spec, model_source = m$runtime$source,
    files = tools::md5sum(file.path(out,c("manifest.rds","selected.rds",paste0("q",order,"-fit.rds")))))
  x$SourceId <- wide_mml_hash(x); x
}

wide_f_predict <- function(fit, data, prior, q) mfrmr::predict_mfrm_units(fit,
  new_data = data, person = "Person", facets = c("Rater","Criterion"), score = "Score",
  scoring_prior = prior, interval_level = .95, n_draws = 0L,
  readiness_policy = "error", scoring_quad_points = q)

wide_f_retry <- function(error) identical(error, paste0(
  "Posterior scoring integration did not pass the numerical accuracy check. Increase `scoring_quad_points` ",
  "or use `readiness_policy = \"review\"` to inspect the flagged scores."))

wide_f_run <- function(source, panel, prior, out, runtime) {
  stopifnot(prior %in% c("reference","retained"),
    identical(panel$PanelId, wide_mml_hash(panel[setdiff(names(panel),"PanelId")])),
    identical(source$SourceId, wide_mml_hash(source[setdiff(names(source),"SourceId")])))
  actual <- if (prior == "reference") list(mean = 0, sd = 1) else NULL
  # Evaluation truth is not supplied to the scorer or the retry predicate.
  rows <- panel$data[c("Person","Rater","Criterion","Score")]
  manifest <- list(SourceId = source$SourceId, PanelId = panel$PanelId, prior = prior,
    actual_prior = actual, data = rows, orders = c(31L,61L,121L), runtime = runtime)
  dir.create(out,recursive = TRUE,showWarnings = FALSE)
  old <- wide_mml_phase(file.path(out,"manifest.rds"),"held-out-scoring-v1",function() manifest)
  if (!identical(old,manifest)) stop("Scoring data, source, prior or procedure changed.")
  identity <- wide_mml_hash(manifest); attempts <- list(); finished <- FALSE; q <- 31L
  status <- function(value) wide_mml_save(list(status = value, identity = identity,
    scoring_order = q, time = Sys.time()),file.path(out,"status.rds"))
  on.exit(if (!finished) status("interrupted"),add = TRUE)
  source_ready <- !nzchar(source$error) && isTRUE(source$review$ready)
  for (q in manifest$orders) {
    status("running")
    a <- wide_mml_phase(file.path(out,paste0("score-q",q,".rds")),
      list(job = identity, scoring_order = q),function() {
        if (!source_ready) return(list(value = NULL, error = paste("Scoring source refused:",
          source$error,paste(source$review$reason_codes,collapse = "; "),
          source$review$local_calibration_review$review), warnings = character(), elapsed = 0))
        wide_mml_capture(function() wide_f_predict(source$fit,rows,actual,q))
      })
    attempts[[as.character(q)]] <- a
    if (!wide_f_retry(a$error)) break
  }
  selected <- list(identity = identity, source_ready = source_ready, source_stage = source$stage,
    attempts = attempts, selected_order = q, prior = prior, SourceId = source$SourceId, PanelId = panel$PanelId)
  saved <- wide_mml_phase(file.path(out,"selected.rds"),identity,function() selected)
  stopifnot(identical(saved,selected)); status("complete"); finished <- TRUE
  saved
}

wide_f_records <- function(source, panel, selected) {
  stopifnot(identical(source$SourceId,selected$SourceId), identical(panel$PanelId,selected$PanelId))
  result <- lapply(c("default31","refinement"), function(rule) {
    q <- if (rule == "default31") 31L else selected$selected_order
    a <- selected$attempts[[as.character(q)]]; stopifnot(!is.null(a))
    z <- panel$planned; z$Observed <- vapply(z$Person, function(id)
      sum(panel$data$Person == id & !is.na(panel$data$Score)), 1L)
    z$Extreme <- vapply(z$Person,function(id) {
      y <- panel$data$Score[panel$data$Person == id & !is.na(panel$data$Score)]
      length(y) > 0L && (all(y == 0) || all(y == 3))
    },TRUE)
    z$Estimate <- z$SD <- z$Lower <- z$Upper <- z$PriorMean <- z$PriorSD <- NA_real_
    z$ScoreAvailable <- z$IntervalAvailable <- FALSE
    z$Reason <- a$error; z$BatchStatus <- if (!selected$source_ready) "source_refused" else
      if (wide_f_retry(a$error)) "integration_refused" else if (nzchar(a$error)) "error" else "returned"
    z$BatchCheck <- "no_return"
    if (!nzchar(a$error)) {
      v <- a$value; t <- v$estimates
      mfrmr:::prediction_validate_population_output(v)
      stopifnot(inherits(v,"mfrm_unit_prediction"), !anyDuplicated(t$Person),
        all(t$Person %in% z$Person), v$settings$scoring_quad_points == q,
        v$settings$interval_level == .95, v$settings$n_draws == 0,
        identical(v$settings$readiness_policy,"error"), isTRUE(v$settings$source_scoring_ready),
        identical(v$settings$scoring_prior, if (selected$prior == "reference") list(mean=0,sd=1) else NULL))
      ix <- match(z$Person,t$Person)
      for (field in c("Estimate","SD","Lower","Upper","PriorMean","PriorSD")) z[[field]] <- t[[field]][ix]
      checked <- !is.null(v$settings$score_integration_review)
      if (checked) stopifnot(all(v$settings$score_integration_review$Passed))
      z$BatchCheck <- if (checked) "public_EAP_SD_pass" else "not_performed_by_public_procedure"
      z$ScoreAvailable <- !is.na(ix) & z$Observed > 0 & is.finite(z$Estimate) &
        t$EstimateUse[ix] == "fitted_object_scoring"
      z$IntervalAvailable <- z$ScoreAvailable & is.finite(z$SD) & z$SD > 0 &
        is.finite(z$Lower) & is.finite(z$Upper) & z$Lower < z$Upper
      z$Reason <- ifelse(z$ScoreAvailable,"",ifelse(z$Observed == 0,"No usable responses","Score not returned"))
    }
    z$IntervalReason <- ifelse(z$IntervalAvailable,"",ifelse(nzchar(z$Reason),z$Reason,"Conditional interval not returned"))
    z$Error <- ifelse(z$ScoreAvailable,z$Estimate-z$Theta,NA_real_)
    z$Covered <- z$IntervalAvailable & z$Lower <= z$Theta & z$Upper >= z$Theta
    z$Covered[!z$IntervalAvailable] <- FALSE
    z$ConditionId <- source$spec$ConditionId; z$Replicate <- source$spec$Replicate; z$Arm <- source$spec$Arm
    z$Prior <- selected$prior; z$Rule <- rule; z$Panel <- panel$Panel; z$Family <- panel$Family
    z$PanelId <- panel$PanelId; z$DataId <- panel$DataId
    z$CohortId <- panel$CohortId; z$SourceId <- source$SourceId
    z$SourceStage <- source$stage; z$ScoringOrder <- q; z$Scale <- panel$scale
    z$ConditionalUncertainty <- TRUE; z
  })
  do.call(rbind,result)
}

# Numerator/denominator contributions belong to calibration replicates, not
# individual Persons. Returned-only error and all-planned delivery stay paired.
wide_f_contributions <- function(records) {
  group <- c("ConditionId","Replicate","Arm","Prior","Rule","Panel","Family","Scale")
  key <- do.call(paste,c(records[c(group,"Person")],sep="\r"))
  if (anyDuplicated(key)) stop("Duplicate scoring target; Persons and retries are not independent replications.")
  ids <- do.call(paste,c(records[group],sep="\r"))
  do.call(rbind,lapply(split(seq_len(nrow(records)),ids),function(i) {
    z <- records[i, ]; available <- z$ScoreAvailable; ci <- z$IntervalAvailable
    cbind(z[1,group,drop=FALSE],data.frame(Planned=nrow(z), Scores=sum(available), Intervals=sum(ci),
      ErrorSum=sum(z$Error[available]), SquaredErrorSum=sum(z$Error[available]^2),
      WidthSum=sum(z$Upper[ci]-z$Lower[ci]), Covered=sum(z$Covered),
      ExtremePersons=sum(z$Extreme), MissingOnly=sum(z$Observed==0),
      SourceRefused=all(z$BatchStatus=="source_refused")))
  }))
}

wide_f_ratio <- function(numerator, denominator) {
  stopifnot(length(numerator)==length(denominator), length(numerator)>0L,
    all(is.finite(numerator)),all(is.finite(denominator)),all(denominator>=0))
  value <- if (sum(denominator)>0) sum(numerator)/sum(denominator) else NA_real_
  mcse <- if (length(numerator)>1L && is.finite(value))
    sd(numerator-value*denominator)/(sqrt(length(numerator))*mean(denominator)) else NA_real_
  c(value=value,MCSE=mcse)
}

wide_f_summary <- function(contributions, expected_replicates = 1:50) {
  stopifnot(length(expected_replicates)>0L,!anyDuplicated(expected_replicates),
    all(contributions$Replicate %in% expected_replicates))
  group <- c("ConditionId","Arm","Prior","Rule","Panel","Family","Scale")
  key <- do.call(paste,c(contributions[c(group,"Replicate")],sep="\r"))
  if (anyDuplicated(key)) stop("Duplicate calibration replicate.")
  ids <- do.call(paste,c(contributions[group],sep="\r"))
  do.call(rbind,lapply(split(seq_len(nrow(contributions)),ids),function(i) {
    z <- contributions[i, ]; metrics <- list(Availability=c("Scores","Planned"),
      IntervalAvailability=c("Intervals","Planned"), Bias=c("ErrorSum","Scores"),
      MSE=c("SquaredErrorSum","Scores"), Width=c("WidthSum","Intervals"),
      ConditionalInclusion=c("Covered","Intervals"), ReturnedAndCovered=c("Covered","Planned"))
    r <- z[1,group,drop=FALSE]; r$Replicates <- nrow(z); r$Planned <- sum(z$Planned)
    r$ExpectedReplicates <- length(expected_replicates)
    r$Complete <- setequal(z$Replicate,expected_replicates)
    r$Scores <- sum(z$Scores); r$Intervals <- sum(z$Intervals)
    for (name in names(metrics)) {
      m <- metrics[[name]]; t <- wide_f_ratio(z[[m[1]]],z[[m[2]]])
      if (!r$Complete) t[] <- NA_real_
      r[[name]] <- t["value"]; r[[paste0(name,"MCSE")]] <- t["MCSE"]
    }
    r$RMSE <- sqrt(r$MSE); r$RMSEMCSE <- if (is.finite(r$RMSE) && r$RMSE>0) r$MSEMCSE/(2*r$RMSE) else NA_real_
    r
  }))
}

wide_f_paired <- function(records, arm_a, prior_a, arm_b, prior_b) {
  a <- records[records$Arm==arm_a & records$Prior==prior_a, ]
  b <- records[records$Arm==arm_b & records$Prior==prior_b, ]
  keys <- c("ConditionId","Replicate","Rule","Panel","Person")
  stopifnot(nrow(a)>0L,nrow(b)>0L,!anyDuplicated(a[keys]),!anyDuplicated(b[keys]))
  z <- merge(a,b,by=keys,suffixes=c("_A","_B"),all=TRUE)
  for (field in c("DataId","CohortId","Theta","Scale")) {
    aa <- z[[paste0(field,"_A")]]; bb <- z[[paste0(field,"_B")]]
    if (anyNA(aa)||anyNA(bb)||any(aa!=bb)) stop("Paired scores need the same planned Persons, panel and target scale.")
  }
  group <- c("ConditionId","Replicate","Rule","Panel")
  ids <- do.call(paste,c(z[group],sep="\r"))
  do.call(rbind,lapply(split(seq_len(nrow(z)),ids),function(i) {
    x <- z[i, ]; both <- x$ScoreAvailable_A & x$ScoreAvailable_B
    cbind(x[1,group,drop=FALSE],data.frame(ArmA=arm_a,PriorA=prior_a,ArmB=arm_b,PriorB=prior_b,
      Planned=nrow(x),AAvailable=sum(x$ScoreAvailable_A),BAvailable=sum(x$ScoreAvailable_B),Joint=sum(both),
      ErrorDifferenceSum=sum(x$Error_A[both]-x$Error_B[both]),
      SquaredErrorDifferenceSum=sum(x$Error_A[both]^2-x$Error_B[both]^2)))
  }))
}
