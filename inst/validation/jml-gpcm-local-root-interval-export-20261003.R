# Export exact binary inputs for an independent interval local-root check.
# Retained fits/derivatives only; no optimization or response generation.
args <- commandArgs(trailingOnly=TRUE); stopifnot(length(args)==1L)
out <- args[1]; dir.create(out,recursive=TRUE,showWarnings=FALSE)
pkgload::load_all('.',quiet=TRUE,compile=FALSE)
source('inst/validation/mfrm-wide-map-mml-stages-20261001.R')
source('inst/validation/jml-public-profile-bridge-20261002.R')
for(name in c('optim','optimHess','uniroot')) trace(name,
  tracer=quote(stop('Estimation is forbidden in this export')),
  print=FALSE,where=asNamespace('stats'))
for(name in c('jml_bridge_check','jml_bridge_profile','jml_bridge_person')) trace(name,
  tracer=quote(stop('Derivative reevaluation is forbidden in this export')),
  print=FALSE,where=.GlobalEnv)
base <- 'validation-results/mfrm-wide-map-recovery-20261002'
pilot <- 'validation-results/mfrm-facet-structure-pilot-20261001/fits'
paths <- c(setNames(file.path(base,c('PCM-JML','GPCM-JML'),'q0-fit.rds'),c('AB20-PCM','AB20-GPCM')),
  setNames(file.path(pilot,paste0(c('240-base_two_facet','20-four_tasks','240-six_raters'),'-JML.rds')),
    c('pilot240-base','pilot20-task4','pilot240-rater6')))
hex <- function(x) {stopifnot(all(is.finite(x)));sprintf('%a',x)}
rows <- function(x)lapply(seq_len(nrow(x)),function(i)hex(x[i,]))
script <- 'inst/validation/jml-gpcm-local-root-interval-export-20261003.R'
bridge_script <- 'inst/validation/jml-public-profile-bridge-20261002.R'
for(id in names(paths)) {
  f <- readRDS(paths[[id]])
  if(startsWith(id,'AB'))stopifnot(identical(f$checksum,wide_mml_hash(f$payload)))
  fit <- if(startsWith(id,'AB'))f$payload$value else f$fit
  bridge_path <- file.path('validation-results/jml-public-profile-bridge-20261002',paste0(id,'.rds'))
  z <- readRDS(bridge_path)
  stopifnot(identical(z$checksum,wide_mml_hash(z$payload)),
    identical(z$binding$input,tools::md5sum(paths[[id]])),
    identical(z$binding$source,tools::md5sum(bridge_script)))
  ctx <- jml_bridge_context(fit); profile <- z$payload$profile; p <- length(ctx$beta)
  B <- backsolve(chol(profile$hessian),diag(p))
  active <- which(!vapply(profile$persons,is.null,FALSE))
  persons <- lapply(active,function(i) {
    h <- profile$persons[[i]]$hessian[1,1]; c <- profile$persons[[i]]$hessian[-1,1]
    list(index=i,theta=hex(profile$theta[i]),nu=hex(1/sqrt(h)),
      tau=hex(-drop(crossprod(B,c/h))),rows=unname(ctx$groups[[i]]),
      saved_gradient=hex(profile$persons[[i]]$gradient),
      saved_hessian=rows(profile$persons[[i]]$hessian))
  })
  excluded <- which(vapply(profile$persons,is.null,FALSE))
  stopifnot(all(vapply(excluded,function(i) {
    y <- ctx$y[ctx$groups[[i]]];all(y==0)||all(y==ctx$K-1L)
  },FALSE)))
  payload <- list(id=id,N=ctx$np,K=ctx$K,p=p,nl=ncol(ctx$lin[[1]]),
    model=fit$config$model,levels=lengths(fit$prep$levels[fit$config$facet_names]),
    beta=hex(ctx$beta),B=rows(B),lin=lapply(ctx$lin,rows),slope=rows(ctx$slope),
    y=unname(ctx$y),persons=persons,excluded=excluded,
    inputs=as.list(tools::md5sum(c(paths[[id]],bridge_path))),
    source=as.list(tools::md5sum(c(script,bridge_script))),runtime=wide_mml_runtime())
  target <- file.path(out,paste0(id,'.json'))
  encoded <- jsonlite::toJSON(payload,auto_unbox=TRUE,pretty=TRUE)
  if(file.exists(target))stopifnot(identical(paste(readLines(target),collapse='\n'),as.character(encoded))) else
    writeLines(encoded,target)
  cat('Exported',id,'\n')
}
