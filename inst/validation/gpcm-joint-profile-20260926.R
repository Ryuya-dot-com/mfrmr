# Repository-only local nuisance profiles. No public readiness/default change.
# Run after pkgload::load_all(compile = FALSE); see the paired protocol record.
gjp_fit <- function(evaluator, start, fixed_index = integer(), fixed_value = numeric(), maxit = 400L) {
  free <- setdiff(seq_along(start), fixed_index)
  embed <- function(z) { p <- start; p[free] <- z; p[fixed_index] <- fixed_value; p }
  safe <- mfrmr:::make_mfrm_boundary_safe_objective(evaluator)
  fn <- function(z) safe$value(embed(z))
  gr <- function(z) safe$gradient(embed(z))[free]
  stages <- list(); selected <- NULL
  for (tol in c(1e-10, 1e-13)) {
    initial <- if (is.null(selected)) start[free] else selected$par
    result <- tryCatch({
      opt <- optim(initial, fn, gr, method = 'BFGS',
        control = mfrmr:::build_mfrm_optim_control('BFGS', maxit, tol))
      p <- embed(opt$par)
      list(opt = opt, par = opt$par, full = p, value = evaluator$value(p),
        gradient = evaluator$gradient(p)[free], error = '')
    }, error = function(e) list(error = conditionMessage(e)))
    stages[[length(stages) + 1L]] <- result
    if (!is.null(result$value) && is.finite(result$value) && all(is.finite(result$gradient)) &&
        (is.null(selected) || result$value < selected$value ||
         result$value <= selected$value + 1e-9 && max(abs(result$gradient)) < max(abs(selected$gradient)))) selected <- result
    if (!is.null(selected) && selected$opt$convergence == 0L && max(abs(selected$gradient)) <= 1e-4) break
  }
  list(selected = selected, stages = stages, fixed_index = fixed_index, fixed_value = fixed_value)
}

gjp_context <- function(fit, order) {
  cfg <- fit$config
  cfg$estimation_control$mml_integration <- 'adaptive'
  cfg$estimation_control$quad_points <- order
  sizes <- mfrmr:::build_param_sizes(cfg)
  idx <- mfrmr:::build_indices(fit$prep, cfg$step_facet, cfg$slope_facet, cfg$interaction_specs)
  ev <- mfrmr:::make_mfrm_direct_evaluator('MML',
    mfrmr:::make_param_cache(sizes, cfg, idx, is_mml = TRUE), idx, cfg, sizes,
    mfrmr:::gauss_hermite_normal(order))
  list(config = cfg, sizes = sizes, idx = idx, evaluator = ev,
    slices = mfrmr:::build_param_slices(sizes))
}

run_gpcm_joint_profile <- function(output_dir, resume = FALSE, max_elapsed_seconds = 600) {
  paths <- c(shared = 'validation-results/gpcm-probability-refit-20260925/refit-788.rds',
    separate = 'validation-results/portable-gpcm-development-probe.rds')
  fits <- list(shared = readRDS(paths[1])$fit, separate = readRDS(paths[2])$review$fits$q41)
  stopifnot(length(max_elapsed_seconds) == 1L, !is.na(max_elapsed_seconds), max_elapsed_seconds > 0)
  if (!resume) {
    stopifnot(!dir.exists(output_dir))
    dir.create(output_dir, recursive = TRUE)
  }
  plan <- do.call(rbind, lapply(names(fits), function(owner) {
    f <- fits[[owner]]; slices <- mfrmr:::build_param_slices(mfrmr:::build_param_sizes(f$config))
    stopifnot(length(slices$log_sigma2) == 1L, length(slices$log_slopes) >= 1L)
    variance <- f$opt$par[slices$log_sigma2] + c(-4, -2, -1, 0, 1, 2, 4)
    slope <- f$opt$par[slices$log_slopes[1]] + c(-3, -1.5, -.5, 0, .5, 1.5, 3)
    rbind(data.frame(Owner = owner, Target = 'log_variance', Index = slices$log_sigma2,
      Value = variance, Offset = c(-4,-2,-1,0,1,2,4)),
      data.frame(Owner = owner, Target = 'first_log_relative_slope', Index = slices$log_slopes[1],
      Value = slope, Offset = c(-3,-1.5,-.5,0,.5,1.5,3)))
  }))
  plan <- merge(plan, data.frame(Start = c('retained', 'neutral')), by = NULL, sort = FALSE)
  plan$Id <- sprintf('profile-%02d', seq_len(nrow(plan)))
  if (resume) {
    manifest <- readRDS(file.path(output_dir, 'manifest.rds'))
    source_paths <- names(manifest$source)[startsWith(names(manifest$source), 'R/')]
    stopifnot(identical(tools::md5sum(paths), manifest$inputs),
      identical(tools::md5sum(source_paths), manifest$source[source_paths]))
    old_plan <- read.csv(file.path(output_dir, 'plan.csv'))
    stopifnot(isTRUE(all.equal(plan, old_plan, check.attributes = FALSE)))
    rows <- read.csv(file.path(output_dir, 'rows.csv'))
    stopifnot(!anyDuplicated(rows$Id))
    rows <- split(rows, rows$Id)
    saveRDS(list(source = tools::md5sum(c(
      'inst/validation/gpcm-joint-profile-20260926.R',
      'inst/validation/gpcm-joint-profile-20260926.md')),
      prior_results = tools::md5sum(file.path(output_dir, paste0(names(rows), '.rds'))),
      max_elapsed_seconds = max_elapsed_seconds, session = sessionInfo()),
      file.path(output_dir, 'resume-manifest.rds'))
  } else {
  write.csv(plan, file.path(output_dir, 'plan.csv'), row.names = FALSE)
  saveRDS(list(inputs = tools::md5sum(paths),
    source = tools::md5sum(c(list.files('R','[.]R$',full.names = TRUE),
      'inst/validation/gpcm-joint-profile-20260926.R',
      'inst/validation/gpcm-joint-profile-20260926.md')),
    source_commit = system2('git', c('rev-parse','HEAD'), stdout=TRUE),
    fitting_order = 31L, comparison_order = 61L, gradient_tolerance = 1e-4,
    integration_nll_tolerance = 1e-5, start_nll_tolerance = 1e-5,
    max_elapsed_seconds = max_elapsed_seconds, session = sessionInfo()), file.path(output_dir,'manifest.rds'))
  rows <- list()
  }
  started <- proc.time()[['elapsed']]
  for (owner in names(fits)) {
    f <- fits[[owner]]; a <- gjp_context(f,31L); b <- gjp_context(f,61L)
    starts <- list(retained=f$opt$par, neutral=rep(0,length(f$opt$par)))
    work <- rbind(data.frame(Owner=owner,Target='unconstrained',Index=NA_integer_,Value=NA_real_,
      Offset=NA_real_,Start=names(starts),Id=paste0(owner,'-baseline-',names(starts))),
      plan[plan$Owner == owner,])
    for (i in seq_len(nrow(work))) {
      if (work$Id[i] %in% names(rows)) next
      if (proc.time()[['elapsed']] - started > max_elapsed_seconds) {
        writeLines('Stopped at declared elapsed-time budget; missing rows remain unexecuted.',file.path(output_dir,'incomplete.txt'))
        return(invisible(rows))
      }
      spec <- work[i,]; cat(spec$Id,owner,spec$Target,spec$Offset,spec$Start,'\n'); flush.console()
      index <- if (is.na(spec$Index)) integer() else spec$Index
      value <- if (is.na(spec$Value)) numeric() else spec$Value
      t0 <- proc.time()[['elapsed']]
      ans <- gjp_fit(a$evaluator,starts[[spec$Start]],index,value)
      r <- cbind(spec,Returned=FALSE,NuisancePass=FALSE,OwnNLL=NA_real_,CommonNLL=NA_real_,
        IntegrationDifference=NA_real_,Gradient=NA_real_,FixedDerivative=NA_real_,
        DerivativeError=NA_real_,Variance=NA_real_,MinSlope=NA_real_,MaxSlope=NA_real_,
        Error=paste(vapply(ans$stages,`[[`,'','error'),collapse=' | '))
      if (!is.null(ans$selected)) {
        selected <- ans$selected; p <- selected$full
        dense <- b$evaluator$value(p); params <- mfrmr:::expand_params(p,a$sizes,a$config)
        r$Returned <- TRUE; r$OwnNLL <- selected$value; r$CommonNLL <- dense
        r$Gradient <- max(abs(selected$gradient))
        r$NuisancePass <- selected$opt$convergence == 0L && r$Gradient <= 1e-4
        r$IntegrationDifference <- abs(selected$value-dense)
        r$Variance <- params$population$sigma2
        r$MinSlope <- min(params$slopes); r$MaxSlope <- max(params$slopes)
        if (length(index)) {
          delta <- 1e-5; hi <- lo <- p; hi[index] <- hi[index]+delta; lo[index] <- lo[index]-delta
          r$FixedDerivative <- a$evaluator$gradient(p)[index]
          r$DerivativeError <- abs(r$FixedDerivative-(a$evaluator$value(hi)-a$evaluator$value(lo))/(2*delta))
        }
      }
      r$Elapsed <- proc.time()[['elapsed']]-t0
      saveRDS(list(spec=spec,result=ans,row=r),file.path(output_dir,paste0(spec$Id,'.rds')))
      rows[[spec$Id]] <- r
      write.csv(do.call(rbind,rows),file.path(output_dir,'rows.csv'),row.names=FALSE)
    }
  }
  if (file.exists(file.path(output_dir, 'incomplete.txt')))
    file.rename(file.path(output_dir, 'incomplete.txt'), file.path(output_dir, 'initial-budget-stop.txt'))
  writeLines('All 56 constrained and 4 unconstrained runs attempted.',file.path(output_dir,'complete.txt'))
  invisible(do.call(rbind,rows))
}
