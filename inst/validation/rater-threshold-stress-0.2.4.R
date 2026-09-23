# Run from the package root: setup <directory>, then run <directory> <first> <last>.
# New, bounded stress conditions; the earlier matched-budget study is reused separately.
stress_conditions <- function() data.frame(
  Condition = c('Small crossed null', 'Short sparse null', 'Large sparse null',
    'Twelve-rater null', 'Heavy MCAR null', 'Random R6', 'Predictable R6',
    'Local dependence', 'Disconnected null'),
  Persons = c(60,60,600,120,120,120,120,120,120),
  Raters = c(6,6,6,12,6,6,6,6,6),
  Design = c('crossed',rep('rotating',7),'disconnected'),
  Departure = c(rep('none',5),'random','predictable','local','none'),
  Missing = c(0,0,0,0,.6,0,0,0,0), stringsAsFactors = FALSE)

stress_setup <- function(directory) {
  conditions <- stress_conditions()
  roster <- do.call(rbind,lapply(seq_len(nrow(conditions)),function(i) {
    z <- conditions[i,]; d <- expand.grid(Replicate=1:100,Target=paste0('R',seq_len(z$Raters)))
    d$Condition <- z$Condition
    d$Affected <- if(z$Departure=='local') TRUE else z$Departure %in% c('random','predictable') & d$Target=='R6'
    d[c('Condition','Replicate','Target','Affected')]
  }))
  source <- c('R/api-estimation.R','R/mfrm_core.R','R/core-data-prep.R',
    'R/api-methods.R','inst/validation/rater-threshold-stress-0.2.4.R')
  protocol <- list(conditions=conditions,roster=roster,seeds=823000L+1:100,
    thresholds=data.frame(Profile=c('0.4-1.2','0.5-1.5','0.6-1.4','0.7-1.3','0.8-1.2'),
      Lower=c(.4,.5,.6,.7,.8),Upper=c(1.2,1.5,1.4,1.3,1.2)),
    direction=c('underfit','overfit','either'), statistics=c('Infit','Outfit','either'),
    zstd=list(cut=2,conventions=c('engine','facets'),rule='MnSq OR abs(ZSTD) >= 2; compared separately with MnSq only'),
    model='RSM',method='MML',ability='Known N(0,1); generated standard normal',
    quad_points=61L,maxit=400L,random_probability=.5,predictable_probability=.75,
    local_sd=1,category_scores=0:3,steps=c(-1,0,1),criterion=c(-.3,0,.3),
    observations='Two raters and three criteria per Person except the crossed condition; nonassignments absent',
    uncertainty='100 independent replications within condition; max conditional MCSE 0.05 when all available; pointwise binomial intervals, no simultaneous guarantee',
    eligibility='Retain computable descriptive screens separately from numerical and inference readiness; no exclusions or replacement runs',
    interpretation='No best threshold or universal acceptable false-flag rate selected; compare directional null family events, affected-target detection, availability and Z-only additions',
    formula_check_tolerance=1e-10,source=tools::md5sum(source),session=sessionInfo())
  path <- file.path(directory,'protocol.rds');if(file.exists(path))stop('Protocol already exists.')
  saveRDS(protocol,path);writeLines(capture.output(str(protocol)),file.path(directory,'protocol.txt'))
  write.csv(roster,file.path(directory,'roster.csv'),row.names=FALSE)
}

stress_generate <- function(z,seed) {
  set.seed(seed)
  persons <- sprintf('P%04d',seq_len(z$Persons)); theta <- rnorm(z$Persons)
  raters <- paste0('R',seq_len(z$Raters)); severity <- seq(-.8,.8,length.out=z$Raters)
  d <- expand.grid(Person=persons,Rater=raters,Criterion=paste0('C',1:3),stringsAsFactors=FALSE)
  p <- match(d$Person,persons);r <- match(d$Rater,raters)
  if(z$Design!='crossed') {
    if(z$Design=='disconnected') {
      panel <- ifelse(p<=z$Persons/2,0,3); first<-panel+(p-1)%%3+1
      second<-panel+p%%3+1
    } else {first<-(p-1)%%z$Raters+1;second<-first%%z$Raters+1}
    keep<-r==first|r==second;d<-d[keep,];p<-p[keep];r<-r[keep]
  }
  eta <- theta[p]-severity[r]-c(-.3,0,.3)[match(d$Criterion,paste0('C',1:3))]
  probability <- function(eta) {
    logw<-cbind(0,eta+1,2*eta+1,3*eta)
    w<-exp(logw-apply(logw,1,max));w/rowSums(w)
  }
  reference <- probability(eta)
  if(z$Departure=='local') {
    local <- matrix(rnorm(z$Persons*z$Raters),nrow=z$Persons)
    prob <- probability(eta+local[cbind(p,r)])
  } else prob<-reference
  target <- r==6
  if(z$Departure=='random') prob[target,]<-.5*prob[target,]+.5/4
  if(z$Departure=='predictable') {
    modal<-max.col(prob,ties.method='first');point<-matrix(0,nrow(d),4);point[cbind(seq_len(nrow(d)),modal)]<-1
    prob[target,]<-.25*prob[target,]+.75*point[target,]
  }
  cumulative<-t(apply(prob,1,cumsum));cumulative[,4]<-1
  d$Score<-rowSums(runif(nrow(d))>cumulative)
  mu<-drop(reference%*%(0:3));variance<-rowSums(sweep(reference,2,(0:3)^2,'*'))-mu^2
  d$ReferenceMean<-mu;d$ReferenceVar<-variance
  if(z$Missing>0) {
    set.seed(seed+923000L);d$Score[sample.int(nrow(d),round(z$Missing*nrow(d)))]<-NA_integer_
  }
  d
}

stress_one <- function(z,seed,replicate,protocol) {
  d<-stress_generate(z,seed);labels<-paste0('R',seq_len(z$Raters))
  rows<-data.frame(Condition=z$Condition,Replicate=replicate,Target=labels,
    Infit=NA_real_,Outfit=NA_real_,InfitZSTD=NA_real_,OutfitZSTD=NA_real_,
    InfitZSTD_FACETS=NA_real_,OutfitZSTD_FACETS=NA_real_,N=NA_real_,
    ReferenceInfit=NA_real_,ReferenceOutfit=NA_real_)
  for(j in seq_along(labels)) {
    a<-d[d$Rater==labels[j]&!is.na(d$Score),];e2<-(a$Score-a$ReferenceMean)^2
    rows$ReferenceInfit[j]<-sum(e2)/sum(a$ReferenceVar)
    rows$ReferenceOutfit[j]<-mean(e2/a$ReferenceVar)
  }
  status<-data.frame(Condition=z$Condition,Replicate=replicate,
    Assigned=nrow(d),Observed=sum(!is.na(d$Score)),NumericalReady=FALSE,InferenceReady=FALSE,
    Components=NA_integer_,FormulaDifference=NA_real_,Seconds=NA_real_,Error='',Warnings='')
  warnings<-character();fit<-NULL;dx<-NULL;start<-proc.time()[['elapsed']]
  tryCatch(withCallingHandlers({
    observed<-d[!is.na(d$Score),]
    fit<-fit_mfrm(observed,'Person',c('Rater','Criterion'),'Score',model='RSM',method='MML',
      rating_min=0,rating_max=3,quad_points=61,maxit=400)
    status$NumericalReady<-identical(fit$summary$NumericalState,'ready')
    status$InferenceReady<-isTRUE(fit$summary$InferenceReady)
    dx<-diagnose_mfrm(fit,residual_pca='none',fit_df_method='both')
    status$Components<-nrow(dx$subsets$summary)
    m<-dx$measures[dx$measures$Facet=='Rater',];at<-match(labels,m$Level)
    columns<-c('Infit','Outfit','InfitZSTD','OutfitZSTD','InfitZSTD_FACETS','OutfitZSTD_FACETS','N')
    rows[columns]<-m[at,columns]
    manual<-vapply(labels,function(id){
      a<-dx$obs[dx$obs$Rater==id,];e2<-(a$Observed-a$Expected)^2
      c(Infit=sum(e2)/sum(a$Var),Outfit=mean(e2/a$Var))
    },numeric(2))
    status$FormulaDifference<-max(abs(t(manual)-as.matrix(rows[c('Infit','Outfit')])))
    if(!is.finite(status$FormulaDifference)||status$FormulaDifference>protocol$formula_check_tolerance)stop('Residual formula agreement failed.')
  },warning=function(w){warnings<<-c(warnings,conditionMessage(w));invokeRestart('muffleWarning')}),
  error=function(e){status$Error<<-conditionMessage(e)})
  status$Seconds<-proc.time()[['elapsed']]-start;status$Warnings<-paste(unique(warnings),collapse=' | ')
  list(rows=rows,status=status,example=if(replicate==1L||nzchar(status$Error))list(data=d,fit=fit,diagnostics=dx)else NULL)
}

if(sys.nframe()==0L) {
  args<-commandArgs(trailingOnly=TRUE);stopifnot(length(args)>=2)
  dir.create(args[2],recursive=TRUE,showWarnings=FALSE)
  if(args[1]=='setup')stress_setup(args[2]) else if(args[1]=='run') {
    pkgload::load_all('.',quiet=TRUE);protocol<-readRDS(file.path(args[2],'protocol.rds'))
    # Verify the fitting/diagnostic source loaded for this worker before execution.
    stopifnot(identical(unname(tools::md5sum(names(protocol$source))),unname(protocol$source)))
    for(i in seq.int(as.integer(args[3]),as.integer(args[4]))) {
      file<-file.path(args[2],paste0('replicate-',i,'.rds'))
      if(file.exists(file))stop('Refusing to replace an executed replication.')
      runs<-lapply(seq_len(nrow(protocol$conditions)),function(j)
        stress_one(protocol$conditions[j,],protocol$seeds[i],i,protocol))
      saveRDS(list(runs=runs,source=protocol$source),file)
      cat('Replication',i,'complete;',sum(vapply(runs,function(x)nzchar(x$status$Error),logical(1))),'errors\n');flush.console()
    }
  } else stop('Unknown action.')
}
