# C design/category outputs. Source the original helpers and the qualified
# facet overlay first. Calibration inputs, aliases and fixed rosters stay frozen.
wide_c_input <- function(condition, replicate,
    root='validation-results/mfrm-wide-map-r50-20261001/c-inputs') {
  index_path <- file.path(root,'inputs.csv')
  verified <- readRDS(file.path(root,'verified-inputs.rds'))
  registry_path <- file.path(root,'rng-registry.rds')
  stopifnot(identical(tools::md5sum(index_path),verified$inputs_md5),
    identical(tools::md5sum(registry_path),verified$registry_md5))
  index <- read.csv(index_path,stringsAsFactors=FALSE)
  row <- index[index$ConditionId==condition & index$Replicate==replicate,]
  stopifnot(nrow(row)==1L,unname(tools::md5sum(row$Bundle))==row$BundleMD5)
  registry <- readRDS(registry_path)
  unit <- registry$units[registry$units$ParentId==row$ExtensionId,]
  stopifnot(nrow(unit)==1L,unit$Replicate==replicate,unit$Truth==row$Truth,
    unit$N==row$N,unit$SD==1,unit$CohortId==row$CohortId)
  extension <- file.path(root,unit$Bundle)
  expected <- unique(index[index$ExtensionId==row$ExtensionId & !index$InputAlias,
    c('Bundle','BundleMD5')])
  stopifnot(nrow(expected)==1L,expected$Bundle==extension,
    unname(tools::md5sum(extension))==expected$BundleMD5,
    unname(tools::md5sum(unit$ABBundle))==unit$ABBundleMD5)
  b <- readRDS(extension); stopifnot(identical(b$unit,unit))
  spec <- b$specs[[row$Design]]
  data <- if(row$InputAlias) {
    stopifnot(row$Design=='null-task',row$View=='paired-L2',
      row$Transform=='Task=as.character(Event)',row$Bundle==unit$ABBundle)
    z <- readRDS(row$Bundle)$views[[row$View]];z$Task <- as.character(z$Event);z
  } else b$views[[row$View]]
  truth <- spec$truth[c(spec$facets,'steps','log_slopes')]
  for(f in spec$facets)names(truth[[f]]) <- as.character(seq_along(truth[[f]]))
  rownames(truth$steps) <- names(truth$log_slopes) <- names(truth$Criterion)
  stopifnot(nrow(data)==row$ObservedRows,spec$K-1L==ncol(truth$steps))
  wide_recovery_input(condition,replicate,data,truth,
    list(index=tools::md5sum(index_path),bundle=tools::md5sum(row$Bundle),
      extension=tools::md5sum(extension),ab_bundle=tools::md5sum(unit$ABBundle),
      registry=tools::md5sum(registry_path),view=row$View,design=row$Design,row=row,
      covariance_sampling='fixed_rosters'),facets=spec$facets)
}

wide_c_bundle <- function(input) {
  stopifnot(identical(input$InputId,wide_mml_hash(input[setdiff(names(input),'InputId')])))
  p <- input$provenance
  for(h in list(p$bundle,p$extension,p$ab_bundle,p$registry))
    stopifnot(identical(tools::md5sum(names(h)),h))
  b <- readRDS(names(p$extension))
  data <- if(p$row$InputAlias) {
    z <- readRDS(names(p$ab_bundle))$views[['paired-L2']]
    z$Task <- as.character(z$Event);z
  } else b$views[[p$view]]
  stopifnot(identical(data,input$data),b$unit$Replicate==input$Replicate,
    b$unit$CohortId==p$row$CohortId,identical(p$covariance_sampling,'fixed_rosters'),
    !anyDuplicated(names(b$theta)),all(is.finite(b$theta)))
  b
}

wide_c_specs <- function(input) {
  b <- wide_c_bundle(input)
  allocation <- read.csv('validation-results/mfrm-wide-map-r50-20261001/conditions.csv',
    stringsAsFactors=FALSE)
  row <- allocation[allocation$ConditionId==input$ConditionId,]
  stopifnot(nrow(row)==1L,row$Block=='C')
  arms <- strsplit(row$Arms,';',fixed=TRUE)[[1L]]
  template <- wide_f_read('validation-results/mfrm-wide-map-recovery-20261002/witness-manifest.rds')$payload$specs
  specs <- lapply(arms,function(arm) {
    key <- sub('^RSM','PCM',arm)
    key <- sub('-MML-free-population$','-MML-free',key)
    key <- sub('-JML-order([24])$','-JML\\1',key)
    stopifnot(key %in% names(template))
    spec <- template[[key]];spec$Arm <- arm
    spec$ConditionId <- input$ConditionId;spec$Replicate <- input$Replicate
    spec$InputId <- input$InputId;spec$purpose <- 'C_R50_descriptive_comparison'
    spec$args$data <- input$data;spec$args$facets <- names(input$levels)
    spec$args$rating_min <- 0L;spec$args$rating_max <- max(input$categories)
    if(b$unit$Truth=='S-RSM') {
      spec$args$model <- 'RSM';spec$args$step_facet <- NULL
    }
    if(!is.null(spec$args$population_formula))
      spec$args$person_data <- data.frame(Person=names(b$theta))
    if(!is.null(spec$args$jml_correction_order)) {
      stopifnot(!nzchar(row$CorrectedExclusion))
      spec$args$jml_correction_sampling <- 'fixed_rosters'
    }
    wide_interval_spec(input,spec)
  })
  names(specs) <- arms;specs
}

wide_c_training_panel <- function(input) {
  b <- wide_c_bundle(input)
  planned <- data.frame(Person=names(b$theta),Theta=unname(b$theta))
  x <- list(Panel='training',Family='training_rescore',CohortId=b$unit$CohortId,
    data=input$data,planned=planned,provenance=input$provenance,
    scale='canonical_theta',contract='C_same_training_responses_and_AB_alias_v1')
  x$DataId <- wide_mml_hash(x[c('data','planned','CohortId','scale')])
  x$PanelId <- wide_mml_hash(x);x
}

wide_c_training_native <- function(input,spec,fitting,stage) {
  collect <- wide_training_native
  environment(collect) <- list2env(list(wide_training_panel=wide_c_training_panel),
    parent=environment(collect))
  collect(input,spec,fitting,stage)
}

wide_c_future_bundle <- function(input,ab_panels_path,out) {
  b <- wide_c_bundle(input);ab <- readRDS(names(input$provenance$ab_bundle))
  saved <- wide_f_read(ab_panels_path);future <- saved$payload
  panel <- future$panels[['population_L2']]
  stopifnot(!is.null(panel),identical(future$parent,ab$unit),
    identical(saved$binding$input,future$calibration_input),nrow(panel$planned)==60L,
    panel$exposure==2L,setequal(panel$planned$Person,unique(panel$data$Person)),
    identical(panel$seeds,future$registry$population),
    identical(panel$seeds$ability,ab$rng$F_first_unused))
  s <- ab$rng$F_first_unused
  for(component in c('ability','assignment','response','missingness')) {
    stopifnot(identical(panel$seeds[[component]],s));s <- parallel::nextRNGSubStream(s)
  }
  original <- 'inst/validation/mfrm-wide-map-c-inputs-20261001.R'
  frozen <- file.path('validation-results/mfrm-wide-map-r50-20261001/c-inputs/source',original)
  registry <- readRDS(names(input$provenance$registry))
  ab_generator <- 'validation-results/mfrm-wide-map-r50-20261001/ab-inputs/source/mfrm-wide-map-ab-inputs-20261001.R'
  stopifnot(unname(tools::md5sum(frozen))==unname(registry$source_md5[original]),
    unname(tools::md5sum(ab_generator))==unname(registry$source_md5[ab_generator]))
  binding <- list(parent=input$provenance$extension,ab_parent=input$provenance$ab_bundle,
    ab_future=tools::md5sum(ab_panels_path),generator=tools::md5sum(c(frozen,ab_generator)),
    bridge=tools::md5sum('inst/validation/mfrm-wide-map-c-output-20261006.R'),
    first_substream=b$rng$F_first_unused,M=60L,contract='C_F_population_AB_pairing_v1')
  dir.create(out,recursive=TRUE,showWarnings=FALSE)
  result <- wide_mml_phase(file.path(out,'future.rds'),binding,function() {
    kind <- RNGkind();had <- exists('.Random.seed',.GlobalEnv,inherits=FALSE)
    if(had)seed <- get('.Random.seed',.GlobalEnv)
    on.exit({do.call(RNGkind,as.list(kind));if(had)assign('.Random.seed',seed,.GlobalEnv)
      else if(exists('.Random.seed',.GlobalEnv,inherits=FALSE))rm('.Random.seed',envir=.GlobalEnv)},add=TRUE)
    RNGkind("L'Ecuyer-CMRG",normal.kind='Inversion',sample.kind='Rejection')
    assign('.Random.seed',panel$seeds$assignment,.GlobalEnv)
    order <- sample.int(60L);pair <- integer(60L);pair[order] <- rep(1:3,each=20L)
    stopifnot(identical(pair,panel$planned$Pair))
    # Reconstruct only the within-pair order; abilities and saved AB scores
    # come directly from the existing future panel, not new draws.
    unit <- ab$unit;unit$N <- 60L;unit$ParentId <- panel$CohortId
    native <- list(unit=unit,truth=ab$truth,
      theta=setNames(panel$planned$Theta,panel$planned$Person),
      assignment=data.frame(Person=panel$planned$Person,PairId=pair),person_order=order,
      rng=panel$seeds,views=list('paired-L1'=future$panels[['population_L1']]$data,
        'paired-L2'=panel$data))
    ab_path <- file.path(out,'ab-future-input.rds')
    if(file.exists(ab_path))stopifnot(identical(readRDS(ab_path),native)) else wide_mml_save(native,ab_path)
    context <- new.env(parent=globalenv())
    context$source <- function(file,...) {
      stopifnot(identical(file,ab_generator));sys.source(file,envir=context)
    }
    sys.source(frozen,envir=context)
    unit <- b$unit;unit$N <- 60L;unit$CohortId <- panel$CohortId
    unit$ParentId <- paste0(b$unit$ParentId,':F-pop')
    unit$ABBundle <- ab_path;unit$ABBundleMD5 <- unname(tools::md5sum(ab_path))
    stream <- b$rng$F_first_unused;seeds <- list()
    for(component in c('ability_reserved','assignment_reserved','response','missingness')) {
      seeds[[component]] <- stream;stream <- parallel::nextRNGSubStream(stream)
    }
    bundle <- context$c_generate(unit,seeds)
    list(bundle=bundle,binding=binding,ab_input=tools::md5sum(ab_path),
      next_unused_substream=stream)
  })
  stopifnot(identical(result$binding,binding),
    identical(tools::md5sum(names(result$ab_input)),result$ab_input))
  result
}

wide_c_future_panel <- function(input,future) {
  b <- wide_c_bundle(input);f <- future$bundle;design <- input$provenance$design
  stopifnot(identical(future$binding$parent,input$provenance$extension),
    identical(future$binding$ab_parent,input$provenance$ab_bundle),
    identical(f$specs[[design]],b$specs[[design]]),f$unit$N==60L,
    identical(tools::md5sum(names(future$ab_input)),future$ab_input))
  data <- if(design=='null-task') {
    z <- readRDS(names(future$ab_input))$views[['paired-L2']]
    z$Task <- as.character(z$Event);z
  } else f$views[[design]]
  planned <- data.frame(Person=names(f$theta),Theta=unname(f$theta))
  stopifnot(!any(planned$Person %in% input$data$Person),
    all(table(data$Person)==f$specs[[design]]$ratings))
  x <- list(Panel='population',Family='F-pop',CohortId=f$unit$CohortId,data=data,
    planned=planned,provenance=future$binding,scale='canonical_theta',
    contract='C_F_population_original_design_v1')
  x$DataId <- wide_mml_hash(x[c('data','planned','CohortId','scale')])
  x$PanelId <- wide_mml_hash(x);x
}
