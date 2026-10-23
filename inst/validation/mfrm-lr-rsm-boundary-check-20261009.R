# Bounded numerical qualification, not a repeated-sampling coverage study.
# Twenty saved three-category fits; four new fits to two saved four-category
# response cohorts (rho=0/.5); one deterministic zero-variance control.
# Run from package root: scripts/validation-R --slave -f THIS_FILE [--args OUT]
pkgload::load_all('.',quiet=TRUE,compile=FALSE)
helpers <- paste0('inst/validation/',c('mfrm-wide-map-mml-stages-20261001.R',
  'mfrm-wide-map-lr-inputs-20261002.R','mfrm-lr-rsm-boundary-20261009.R'))
for(path in helpers) source(path)
script <- 'inst/validation/mfrm-lr-rsm-boundary-check-20261009.R'
args <- commandArgs(trailingOnly=TRUE)
out <- if(length(args)) args[1L] else 'validation-results/mfrm-lr-rsm-boundary-20261009'
dir.create(out,recursive=TRUE,showWarnings=FALSE)
archive_path <- 'inst/validation/population-coverage-preflight-evidence-0.2.4.rds'
archive <- readRDS(archive_path)
input_root <- 'validation-results/mfrm-wide-map-r50-20261001/lr-inputs'
index_path <- file.path(input_root,'inputs.csv')
index <- read.csv(index_path,stringsAsFactors=FALSE)
rows <- subset(index,Truth=='S-RSM' & SD==1 & View=='paired-L1' & Replicate==1 & N %in% c(20L,240L))
stopifnot(nrow(rows)==4L)
jobs <- list()
for(s in archive$states) if(s$Cell$Model=='RSM') for(r in s$Results) {
  id <- paste0('preflight-',s$Cell$Cell,'-',r$Replicate)
  jobs[[id]] <- list(fit=r$Detail$fit,args=NULL,check=r$Replicate==1L,control=FALSE)
}
for(i in seq_len(nrow(rows))) {
  a <- dlr_fit_input(rows[i,],input_root,'RSM')
  a$population_formula <- as.formula('~X',env=baseenv())
  a$quad_points <- 61L; a$reltol <- 1e-12
  id <- paste0('N',rows$N[i],'-rho',rows$Rho[i],'-four-category')
  jobs[[id]] <- list(fit=NULL,args=a,check=TRUE,control=FALSE)
}
# Each X stratum observes every possible three-rating pattern exactly once.
# Uniform independent responses attain the saturated multinomial maximum at
# eta=0,v=0. Complementary Criterion rosters keep the joint nuisance design full rank.
patterns <- as.matrix(expand.grid(rep(list(0:2),3L)))
persons <- data.frame(Person=paste0('P',1:54),X=rep(c(-1,1),each=27L))
data <- do.call(rbind,lapply(seq_len(nrow(persons)),function(i)
  data.frame(Person=persons$Person[i],Rater=paste0('R',1:3),
    Criterion=paste0('C',if(i<=27L)c(1,2,1) else c(2,1,2)),
    Score=patterns[(i-1L)%%27L+1L,])))
jobs[['balanced-zero-control']] <- list(fit=NULL,check=TRUE,control=TRUE,args=list(
  data=data,person='Person',facets=c('Rater','Criterion'),score='Score',model='RSM',method='MML',
  population_formula=as.formula('~X',env=baseenv()),person_data=persons,person_id='Person',
  population_policy='error',rating_min=0,rating_max=2,category_policy='preserve',
  mml_engine='direct',mml_integration='fixed',optimizer='BFGS',quad_points=61L,maxit=400L,reltol=1e-12))
inputs <- unique(c(archive_path,index_path,file.path(input_root,rows$Bundle),rows$ABBundle))
runtime <- wide_mml_runtime(); runtime$boundary_sources <- tools::md5sum(c(helpers,script))
manifest <- list(jobs=jobs,inputs=tools::md5sum(inputs),runtime=runtime,rule=rsm_lr_boundary_rule(),
  scope='Numerical boundary qualification only; no random draws, sampling calibration or global positive-variance proof.')
saved <- wide_mml_phase(file.path(out,'manifest.rds'),'RSM-LR-boundary-review-v1',function() manifest)
stopifnot(identical(saved,manifest))
for(path in unique(c(helpers,script,names(runtime$source)[!startsWith(names(runtime$source),'loaded:')]))) {
  dest <- file.path(out,'source',path);dir.create(dirname(dest),recursive=TRUE,showWarnings=FALSE)
  if(!file.exists(dest)) stopifnot(file.copy(path,dest))
  stopifnot(unname(tools::md5sum(path))==unname(tools::md5sum(dest)))
}

check_boundary <- function(ctx,zero) {
  idx <- mfrmr:::build_indices(ctx$fit$prep)
  native <- mfrmr:::make_mfrm_direct_evaluator('MML',
    mfrmr:::make_param_cache(ctx$sizes,ctx$fit$config,idx,is_mml=TRUE),idx,
    ctx$fit$config,ctx$sizes,mfrmr:::gauss_hermite_normal(1L))
  points <- list(zero$eta,zero$eta+.03*cos(seq_len(ctx$p)))
  checks <- lapply(points,function(eta) {
    z <- rsm_lr_boundary_eval(ctx,eta)
    values <- vapply(c(-32,0,32),function(v) native$value(c(eta,v)),0.)
    gradient <- native$gradient(c(eta,0))[seq_len(ctx$p)]
    differences <- lapply(c(1e-4,5e-5),function(h) {
      g <- numeric(ctx$p); H <- matrix(0,ctx$p,ctx$p)
      for(j in seq_len(ctx$p)) {
        plus <- minus <- c(eta,0); plus[j] <- plus[j]+h;minus[j] <- minus[j]-h
        g[j] <- (native$value(plus)-native$value(minus))/(2*h)
        H[,j] <- (native$gradient(plus)-native$gradient(minus))[seq_len(ctx$p)]/(2*h)
      }
      list(gradient=g,hessian=H)
    })
    c(Value=max(abs(values-z$value)),Gradient=max(abs(gradient-z$gradient)),
      GradientDifference=max(abs(differences[[2]]$gradient-z$gradient))/ctx$persons,
      GradientStepDifference=max(abs(differences[[1]]$gradient-differences[[2]]$gradient))/ctx$persons,
      HessianDifference=max(abs(differences[[2]]$hessian-z$hessian))/max(1,max(abs(z$hessian))))
  })
  z <- rsm_lr_boundary_eval(ctx,zero$eta)
  ix <- ctx$groups[[1L]]; K <- ctx$K
  pattern <- as.matrix(expand.grid(rep(list(0:(K-1L)),length(ix))))
  probability <- rep(1,nrow(pattern)); scores <- matrix(0,nrow(pattern),ctx$p+1L)
  residual <- numeric(nrow(pattern)); variance <- 0
  A <- matrix(0,ctx$p,ctx$p); cross <- numeric(ctx$p); fourth <- 0; variances <- numeric(length(ix))
  for(j in seq_along(ix)) {
    row <- ix[j]; p <- z$probability[row,]; y <- pattern[,j]
    C <- do.call(rbind,lapply(z$centered,function(D) D[row,]))
    mu <- sum((0:(K-1L))*p); e <- (0:(K-1L))-mu; v <- sum(e^2*p)
    probability <- probability*p[y+1L]
    scores[,seq_len(ctx$p)] <- scores[,seq_len(ctx$p)]+C[y+1L,,drop=FALSE]
    residual <- residual+y-mu;variance <- variance+v
    A <- A+crossprod(C*sqrt(p));cross <- cross+as.vector(crossprod(C,p*e^2))/2
    fourth <- fourth+(sum(p*e^4)-v^2)/4;variances[j] <- v
  }
  scores[,ctx$p+1L] <- (residual^2-variance)/2
  d <- fourth+(sum(variances)^2-sum(variances^2))/2
  expected <- rbind(cbind(A,cross),c(cross,d))
  enumeration <- c(Mass=abs(sum(probability)-1),Mean=max(abs(colSums(scores*probability))),
    Information=max(abs(crossprod(scores*sqrt(probability))-expected)))
  steps <- c(1e-4,5e-5,2.5e-5)
  paths <- lapply(steps,function(v) rsm_lr_continuous_value(ctx,zero$eta,v))
  f <- vapply(paths,`[[`,0.,'value')
  forward <- c((-3*z$value+4*f[2]-f[1])/(2*steps[2]),(-3*z$value+4*f[3]-f[2])/(2*steps[3]))
  derivative_error <- max(abs(forward+z$natural_variance_score))/ctx$persons
  numerical <- do.call(rbind,checks)
  passed <- c(value=all(numerical[,'Value']<=1e-8),gradient=all(numerical[,'Gradient']<=1e-8),
    differences=all(numerical[,'GradientDifference']<=1e-7 & numerical[,'GradientStepDifference']<=1e-7 &
      numerical[,'HessianDifference']<=1e-6),enumeration=all(enumeration<=c(1e-12,1e-10,1e-9)),
    natural_variance_derivative=derivative_error<=1e-6)
  list(checks=passed,numerical=numerical,enumeration=enumeration,
    natural_variance_derivative_error=derivative_error,steps=steps,paths=paths,forward=forward)
}

summary <- results <- list()
for(id in names(jobs)) {
  job <- jobs[[id]]; dir <- file.path(out,id);dir.create(dir,showWarnings=FALSE)
  binding <- list(manifest=wide_mml_hash(manifest),job=id)
  phase <- function(name,dependency,compute) wide_mml_phase(file.path(dir,paste0(name,'.rds')),
    c(binding,list(phase=name,dependency=dependency)),compute)
  cat('Starting',id,'\n');flush.console()
  fitting <- phase('fit',NULL,function()wide_mml_capture(function()
    if(!is.null(job$fit)) job$fit else wide_mml_fit(job$args)))
  stopifnot(!nzchar(fitting$error))
  fit <- fitting$value; ctx <- rsm_lr_boundary_context(fit)
  zero <- phase('zero',wide_mml_hash(fitting),function()wide_mml_capture(function()rsm_lr_boundary_zero(ctx)))
  interior <- phase('interior',wide_mml_hash(fitting),function()wide_mml_capture(function()
    rsm_lr_continuous_value(ctx,head(fit$opt$par,-1L),fit$population$sigma2)))
  decision <- if(nzchar(zero$error) || nzchar(interior$error)) list(eligible=FALSE,status='boundary_error',gain=NA_real_) else
    rsm_lr_boundary_decision(zero$value,interior$value)
  numerical <- if(job$check && !nzchar(zero$error)) phase('independent-check',wide_mml_hash(zero),function()
    wide_mml_capture(function()check_boundary(ctx,zero$value))) else NULL
  intervals <- phase('public-intervals',wide_mml_hash(fitting),function()wide_mml_capture(function() {
    L <- rbind(mean_at_minus1=c(1,-1),mean_at_plus1=c(1,1),difference=c(0,2))
    colnames(L) <- fit$population$design_columns
    mfrm_population_intervals(fit,contrasts=L)
  }))
  public_ready <- !nzchar(intervals$error) && all(intervals$value$table$CIEligible)
  row <- data.frame(Job=id,N=ctx$persons,Categories=ctx$K,Nuisance=ctx$p,
    SavedFit=!is.null(job$fit),Control=job$control,ZeroQualified=isTRUE(zero$value$qualified),
    BoundaryExcluded=isTRUE(decision$eligible),Gain=decision$gain,
    PublicIntervals=public_ready,StudyIntervals=isTRUE(decision$eligible) && public_ready,
    IndependentChecks=if(!job$check) NA else !nzchar(numerical$error) && all(numerical$value$checks),
    Error=paste(Filter(nzchar,c(zero$error,interior$error,numerical$error,intervals$error)),collapse='; '))
  result <- list(row=row,zero=zero,interior=interior,decision=decision,numerical=numerical,intervals=intervals)
  phase('result',c(wide_mml_hash(zero),wide_mml_hash(interior),wide_mml_hash(intervals)),function()result)
  summary[[id]] <- row;results[[id]] <- result
  print(row,row.names=FALSE);flush.console()
}
summary <- do.call(rbind,summary);rownames(summary) <- NULL
stopifnot(nrow(summary)==25L,all(summary$ZeroQualified),all(summary$IndependentChecks %in% c(TRUE,NA)),
  !summary$BoundaryExcluded[summary$Control],!summary$StudyIntervals[summary$Control],
  identical(manifest$runtime,within(wide_mml_runtime(),boundary_sources<-tools::md5sum(c(helpers,script)))),
  identical(manifest$inputs,tools::md5sum(inputs)))
control <- results[['balanced-zero-control']]
stopifnot(abs(control$zero$value$nll-162*log(3))<1e-10,
  max(abs(control$zero$value$eta))<1e-10,
  !rsm_lr_boundary_decision(list(qualified=FALSE,reason='injected failure'),NULL)$eligible,
  !rsm_lr_boundary_decision(list(qualified=TRUE,nll=1,entropy_nll=1),list(value=1,summed_relative_error=0))$eligible,
  !rsm_lr_boundary_decision(list(qualified=TRUE,nll=1,entropy_nll=1),list(value=0,summed_relative_error=2))$eligible)
evidence <- list(summary=summary,results=results,manifest_hash=tools::md5sum(file.path(out,'manifest.rds')),
  source=runtime,session=sessionInfo(),new_positive_variance_fits=5L,new_random_samples=0L,
  scope=manifest$scope)
wide_mml_save(evidence,file.path(out,'evidence.rds'))
write.csv(summary,file.path(out,'summary.csv'),row.names=FALSE)
cat('Completed RSM boundary qualification. No sampling-coverage conclusion.\n')
