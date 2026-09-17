# Run from the development directory after loading mfrmr (or pkgload::load_all).
# Reuses the existing scenario generator; records expected rejection separately
# from successful computation and does not equate either with manuscript readiness.
source('inst/validation/first-use-workflow-stress.R')
run_user_data_stress <- function(output_dir, seeds = 20260913:20260915, only = NULL) {
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  records <- list()
  record <- function(name, kind, code) {
    if (!is.null(only) && !name %in% only) return(invisible(NULL))
    started <- proc.time()[['elapsed']]
    result <- mfrmr_first_use_capture(withCallingHandlers(code(), error = function(e) {
      writeLines(vapply(sys.calls(),function(x) paste(deparse(x),collapse=' '),character(1)),
                 file.path(output_dir,paste0(name,'-trace.txt')))
    }))
    records[[length(records)+1L]] <<- data.frame(
      Scenario=name, Kind=kind, Passed=!nzchar(result$error),
      Seconds=proc.time()[['elapsed']]-started,
      Detail=if(nzchar(result$error)) result$error else paste(result$value,collapse='; '),
      Warnings=paste(result$unique_warnings,collapse=' | '), stringsAsFactors=FALSE)
    write.csv(do.call(rbind,records),file.path(output_dir,'scenarios.csv'),row.names=FALSE)
    cat(name,if(nzchar(result$error)) 'FAIL' else 'PASS','\n')
    flush.console()
  }
  fit_data <- function(data, ...) fit_mfrm(data,'Person',c('Rater','Criterion'),'Score',method='MML',model='RSM',...)
  pipeline <- function(setup, disconnected=FALSE) {
    args <- c(list(data=setup$data),setup$fit_args)
    desc <- do.call(describe_mfrm_data,c(args[intersect(names(args),c('data','person','facets','score','weight','rating_min','rating_max','keep_original','missing_codes'))],list(include_agreement=FALSE)))
    f <- tryCatch(do.call(fit_mfrm,args),error=identity)
    if(disconnected) {
      stopifnot(inherits(f,'mfrmr_estimability_error'),grepl('Optimization was not run',conditionMessage(f),fixed=TRUE))
      return('Expected rejection before optimization: unidentified design')
    }
    if(inherits(f,'error')) stop(f)
    dx <- diagnose_mfrm(f,residual_pca='none',diagnostic_mode='both')
    s <- summary(f,diagnostics=dx)
    stopifnot(nrow(dx$obs)==f$prep$n_obs, sum(dx$obs$Weight)==f$summary$N,
              nrow(f$facets$person)==f$summary$Persons)
    p <- plot(f,diagnostics=dx,show_ci=TRUE,draw=FALSE)
    stopifnot(inherits(p,'mfrm_plot_data'),nrow(p$data$locations)>0)
    apa <- build_apa_outputs(f,dx)
    stopifnot(!apa$contract$availability$has_pca_overall,!apa$contract$availability$has_pca_by_facet)
    if(!isTRUE(f$summary$InferenceReady)) stopifnot(identical(apa$decision$FormalInference,'No'))
    stopifnot(identical(as.numeric(apa$contract$metadata$n_obs),as.numeric(nrow(dx$obs))))
    counts <- apa$contract$metadata$facet_counts
    stopifnot(identical(as.integer(counts),as.integer(lengths(f$config$facet_levels))))
    paste('N',f$summary$N,'Persons',f$summary$Persons,'Readiness',f$summary$FitReadiness)
  }
  for(name in mfrmr_first_use_stress_plan()$Scenario) for(seed in seeds) {
    record(paste(name,seed,sep='_'),'design/model',function() pipeline(
      mfrmr_first_use_make_scenario(name,seed),name=='disconnected_rsm'))
  }
  d <- load_mfrmr_data('example_operational')
  ref <- fit_data(d)
  ordered <- function(f,which='others') {
    t <- as.data.frame(f$facets[[which]])
    key <- if(which=='person') as.character(t$Person) else paste(t$Facet,t$Level)
    t$Estimate[order(key)]
  }
  same <- function(a,b,sign=1) {
    stopifnot(isTRUE(all.equal(a$summary$LogLik,b$summary$LogLik,tolerance=1e-5)),
      isTRUE(all.equal(ordered(a),sign*ordered(b),tolerance=1e-4)),
      isTRUE(all.equal(ordered(a,'person'),sign*ordered(b,'person'),tolerance=1e-4)))
    'Likelihood and keyed estimates preserved'
  }
  for(seed in seeds) record(paste0('row_order_',seed),'invariance',function() {
    set.seed(seed); same(fit_data(d[sample(nrow(d)),]),ref)
  })
  record('unit_weights','invariance',function() { x<-d; x$Weight<-1; same(fit_data(x,weight='Weight'),ref) })
  record('weights_vs_duplicate_rows','invariance',function() {
    x<-d; x$Weight<-2; same(fit_data(x,weight='Weight'),fit_data(d[rep(seq_len(nrow(d)),each=2),]))
  })
  record('score_translation','invariance',function() { x<-d;x$Score<-x$Score+10; same(fit_data(x,rating_min=11,rating_max=14,keep_original=TRUE),ref) })
  record('score_reflection','invariance',function() { x<-d;x$Score<-5-x$Score; same(fit_data(x),ref,sign=-1) })
  record('sentinel_vs_na','invariance',function() {
    x<-d; x$Score[1:5]<-NA; y<-x;y$Score[1:5]<-99; same(fit_data(y,missing_codes=TRUE),fit_data(x))
  })
  record('unused_factor_levels','invariance',function() {
    x<-d; x$Rater<-factor(x$Rater,levels=c(rev(unique(x$Rater)),'unused')); same(fit_data(x),ref)
  })
  record('positive_rater_orientation','invariance',function() {
    f<-fit_data(d,positive_facets='Rater'); f$facets$others$Estimate[f$facets$others$Facet=='Rater'] <- -f$facets$others$Estimate[f$facets$others$Facet=='Rater']; same(f,ref)
  })
  record('nonstandard_columns','input/output',function() {
    x<-d; names(x)[match(c('Person','Rater','Criterion','Score'),names(x))]<-c('受験者 ID','評価者名','採点基準','得点')
    pipeline(list(data=x,fit_args=list(person='受験者 ID',facets=c('評価者名','採点基準'),score='得点',method='MML',model='RSM')))
  })
  record('unicode_long_labels','input/output',function() {
    x<-d;x$Person<-paste0('受験者_',x$Person);x$Rater<-paste0('評価者 "',x$Rater,'" & 長い名称');x$Criterion<-paste0('採点基準_',x$Criterion)
    pipeline(list(data=x,fit_args=list(person='Person',facets=c('Rater','Criterion'),score='Score',method='MML',model='RSM')))
  })
  record('larger_connected_7500_ratings','size',function() {
    x<-simulate_mfrm_data(n_person=500,n_rater=12,n_criterion=5,raters_per_person=3,assignment='rotating',seed=20260913)
    pipeline(list(data=x,fit_args=list(person='Person',facets=c('Rater','Criterion'),score='Score',method='MML',model='RSM')))
  })
  invalid <- list(
    empty=function(x) x[0,],
    missing_column=function(x) {x$Rater<-NULL;x},
    duplicate_column=function(x) {x$extra<-x$Score;names(x)[ncol(x)]<-'Score';x},
    all_missing_scores=function(x) {x$Score<-NA_real_;x},
    nonnumeric_score=function(x) {x$Score<-'oops';x},
    fractional_score=function(x) {x$Score[1]<-1.5;x},
    infinite_score=function(x) {x$Score[1]<-Inf;x},
    all_missing_person=function(x) {x$Person<-NA_character_;x}
  )
  for(name in names(invalid)) record(name,'input rejection',function() {
    e<-tryCatch(fit_data(invalid[[name]](d)),error=identity)
    stopifnot(inherits(e,'error'),nzchar(conditionMessage(e)))
    conditionMessage(e)
  })
  record('mixed_nonnumeric_score','input review',function() {
    x<-d;x$Score<-as.character(x$Score);x$Score[1]<-'oops'
    got<-mfrmr_first_use_capture(fit_data(x))
    stopifnot(inherits(got$value,'mfrm_fit'),got$value$prep$n_obs==nrow(d)-1L,
              any(grepl('non-numeric',got$warnings,fixed=TRUE)))
    'One invalid score explicitly warned and excluded'
  })
  record('declared_out_of_range','input rejection',function() {
    x<-d;x$Score[1]<-5
    e<-tryCatch(fit_data(x,rating_min=1,rating_max=4),error=identity)
    stopifnot(inherits(e,'error'));conditionMessage(e)
  })
  record('constant_response','weak information',function() {
    x<-d;x$Score<-1L
    f<-tryCatch(fit_data(x,rating_min=1,rating_max=4,keep_original=TRUE),error=identity)
    stopifnot(inherits(f,'error') || !isTRUE(f$summary$InferenceReady))
    if(inherits(f,'error')) conditionMessage(f) else f$summary$FitReadiness
  })
  do.call(rbind,records)
}

# Install the working package into `library` first. Every replay below runs in
# a separate --vanilla R process, after moving the complete analysis folder.
run_user_data_archive_stress <- function(output_dir, library) {
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  records <- list()
  cases <- c('literal_ids_jml', 'unicode_mml', 'pcm_varying_steps',
             'gpcm_varying_slopes', 'weighted_missing', 'latent_factor',
             'diagnostic_options', 'facets_workflow')
  for (name in cases) {
    result <- mfrmr_first_use_capture({
      d <- load_mfrmr_data('example_operational')
      args <- list(person='Person',facets=c('Rater','Criterion'),score='Score',method='MML')
      if (name %in% c('pcm_varying_steps','gpcm_varying_slopes')) {
        setup <- mfrmr_first_use_make_scenario(name,20260913)
        d <- setup$data; args <- setup$fit_args
      }
      if (name %in% c('literal_ids_jml','latent_factor')) {
        ids <- unique(d$Person)
        labels <- c('01','1','NA',sprintf('%03d',seq.int(4L,length(ids))))
        d$Person <- labels[match(d$Person,ids)]
      }
      if (name=='literal_ids_jml') args$method <- 'JML'
      if (name=='unicode_mml') {
        d$Rater <- paste0('評価者 <',d$Rater,'> & "長い名称"')
        names(d)[match(c('Person','Rater','Criterion','Score'),names(d))] <-
          c('受験者 ID','評価者名','採点基準','得点')
        args$person <- '受験者 ID'; args$facets <- c('評価者名','採点基準');args$score <- '得点'
      }
      if (name=='pcm_varying_steps') {
        d$Score <- d$Score+10L; args$rating_min <- min(d$Score);args$rating_max <- max(d$Score)
        args$keep_original <- TRUE
      }
      if (name=='weighted_missing') {
        d$Weight <- rep(c(0,1,.5,2),length.out=nrow(d)); d$Score[2:4] <- NA_real_
        args$weight <- 'Weight'
      }
      if (name=='latent_factor') {
        background <- data.frame(Person=unique(d$Person))
        background[['Group code']] <- factor(rep(c('01','1'),length.out=nrow(background)),levels=c('1','01'))
        contrasts(background[['Group code']]) <- contr.sum(2)
        args$person_data <- background; args$person_id <- 'Person'
        args$population_formula <- ~ `Group code`
      }
      run <- if(name=='facets_workflow') do.call(run_mfrm_facets,c(list(data=d),args)) else NULL
      f <- if(is.null(run)) do.call(fit_mfrm,c(list(data=d),args)) else run$fit
      dx <- if(name=='diagnostic_options') diagnose_mfrm(f,diagnostic_mode='legacy',
        fit_df_method='facets',whexact=TRUE,residual_pca='both',pca_max_factors=2L,
        interaction_pairs=list(c('Rater','Criterion')),top_n_interactions=3L) else diagnose_mfrm(f)
      folder <- file.path(output_dir,paste0(name,'_original'))
      b <- export_mfrm_bundle(if(is.null(run)) f else run,diagnostics=dx,data=d,
        output_dir=folder,prefix='archive',
        include=c('core_tables','apa','manifest','script','html'),acknowledge_sensitive=TRUE)
      csvs <- b$written_files$Path[b$written_files$Format=='csv']
      stopifnot(all(file.exists(b$written_files$Path)),length(csvs)>0L)
      invisible(lapply(csvs,read.csv,check.names=FALSE,colClasses='character',na.strings=''))
      if(name=='unicode_mml') {
        html <- paste(readLines(file.path(folder,'archive_bundle.html'),encoding='UTF-8'),collapse='\n')
        stopifnot(grepl('評価者 &lt;',html,fixed=TRUE),grepl('&amp;',html,fixed=TRUE),
                  !grepl('評価者 <',html,fixed=TRUE))
      }
      before <- tools::md5sum(b$written_files$Path)
      existing <- tryCatch(export_mfrm_bundle(f,diagnostics=dx,data=d,output_dir=folder,
        prefix='archive',include='core_tables',acknowledge_sensitive=TRUE),error=identity)
      stopifnot(inherits(existing,'error'),identical(before,tools::md5sum(b$written_files$Path)))
      saveRDS(list(data=d,ids=c(args$person,args$facets),fit=f,diagnostics=dx),file.path(folder,'expected.rds'))
      writeLines(c(
        paste0('.libPaths(c(',deparse(normalizePath(library)),', .libPaths()))'),
        'library(mfrmr)',
        'folder <- normalizePath(commandArgs(trailingOnly=TRUE)[1])',
        'expected <- readRDS(file.path(folder,"expected.rds"))',
        'e <- new.env(); source(file.path(folder,"archive_replay.R"),local=e,chdir=TRUE)',
        'stopifnot(identical(names(e$data),names(expected$data)))',
        'for (nm in expected$ids) stopifnot(identical(e$data[[nm]],as.character(expected$data[[nm]])))',
        'stopifnot(identical(e$fit$prep$n_obs,expected$fit$prep$n_obs))',
        'stopifnot(isTRUE(all.equal(e$fit$summary,expected$fit$summary,tolerance=1e-6)))',
        'stopifnot(isTRUE(all.equal(e$fit$facets,expected$fit$facets,tolerance=1e-6)))',
        'stopifnot(identical(e$diagnostics$replay_inputs,expected$diagnostics$replay_inputs))',
        'stopifnot(isTRUE(all.equal(e$diagnostics$measures,expected$diagnostics$measures,tolerance=1e-6)))',
        'stopifnot(isTRUE(all.equal(e$diagnostics$interactions,expected$diagnostics$interactions,tolerance=1e-6)))',
        'stopifnot(isTRUE(all.equal(e$fit$population$coefficients,expected$fit$population$coefficients,tolerance=1e-6)))',
        'if(isTRUE(expected$fit$population$active)) stopifnot(identical(e$fit_person_data,expected$fit$population$person_table_replay))',
        'cat("Fresh-session moved-folder replay matched\n")'
      ),file.path(folder,'verify.R'))
      moved <- file.path(output_dir,paste0(name,'_移動 folder'))
      stopifnot(file.rename(folder,moved))
      status <- system2(file.path(R.home('bin'),'Rscript'),c('--vanilla',shQuote(file.path(moved,'verify.R')),shQuote(moved)),
                        stdout=file.path(moved,'fresh-session.log'),stderr=file.path(moved,'fresh-session.log'))
      stopifnot(status==0L)
      paste(length(csvs),'readable CSVs; IDs, fit, diagnostics and overwrite protection checked')
    })
    records[[name]] <- data.frame(Scenario=name,Passed=!nzchar(result$error),
      Detail=if(nzchar(result$error)) result$error else result$value,
      Warnings=paste(result$unique_warnings,collapse=' | '),stringsAsFactors=FALSE)
    write.csv(do.call(rbind,records),file.path(output_dir,'archives.csv'),row.names=FALSE)
    cat(name,if(nzchar(result$error)) 'FAIL' else 'PASS','\n');flush.console()
  }
  do.call(rbind,records)
}
