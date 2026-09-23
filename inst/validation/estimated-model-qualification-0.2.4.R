# Run from package root. init once; then independent workers 1..4.
.libPaths(c(normalizePath('.r-library'), .libPaths()))
pkgload::load_all('.', quiet = TRUE)
args <- commandArgs(trailingOnly = TRUE)
out <- 'validation-results/estimated-model-qualification-20260923'
dir.create(out, recursive = TRUE, showWarnings = FALSE)
files <- c(sort(list.files('R', pattern='[.]R$', full.names=TRUE)), 'DESCRIPTION', 'NAMESPACE',
  'inst/validation/estimated-model-qualification-0.2.4.R',
  'inst/validation/estimated-model-qualification-0.2.4.md')
protocol_path <- file.path(out, 'protocol.rds')
if (identical(args[1], 'init')) {
  stopifnot(!file.exists(protocol_path))
  conditions <- expand.grid(Raters=c(6L,24L), Design=c('rotating','weak'), stringsAsFactors=FALSE)
  roster <- do.call(rbind,lapply(1:4,function(i) data.frame(Trial=(i-1L)*200L+1:200,
    Condition=i,Raters=conditions$Raters[i],Design=conditions$Design[i],
    Replicate=1:200,Seed=92326000L+1:200)))
  saveRDS(list(roster=roster,source=tools::md5sum(files),session=sessionInfo(),frozen=Sys.time()),protocol_path)
  for(f in files) {
    dest<-file.path(out,'executed-source',f);dir.create(dirname(dest),recursive=TRUE,showWarnings=FALSE)
    stopifnot(file.copy(f,dest))
  }
  cat('Frozen:',nrow(roster),'planned datasets\n')
  quit(status=0)
}
protocol <- readRDS(protocol_path)
stopifnot(identical(protocol$source,tools::md5sum(files)))
worker<-as.integer(args[1]);workers<-as.integer(args[2])
stopifnot(length(worker)==1L,worker>=1L,worker<=workers)
roster<-protocol$roster[(protocol$roster$Trial-1L) %% workers == worker-1L,]
for(j in seq_len(nrow(roster))) {
  row<-roster[j,];path<-file.path(out,sprintf('trial-%04d.rds',row$Trial))
  if(file.exists(path)) {stopifnot(identical(readRDS(path)$roster,row));next}
  set.seed(row$Seed)
  theta<-rnorm(240,sd=1.3);u<-rnorm(24,sd=.7)[seq_len(row$Raters)];uniform<-runif(1440)
  p<-rep(1:240,each=6);slot<-rep(rep(0:1,each=3),240);criterion<-rep(1:3,480)
  if(row$Design=='rotating') r<-(p-1+slot) %% row$Raters+1L else {
    h<-row$Raters/2L;r<-(p-1+slot) %% h+1L+as.integer(p>120)*h
    a<-r[p==1 & slot==1][1];b<-r[p==121 & slot==1][1]
    r[p==1 & slot==1]<-b;r[p==121 & slot==1]<-a
  }
  stopifnot(length(unique(table(r)))==1L)
  eta<-theta[p]-u[r]-c(-.3,0,.3)[criterion]
  weights<-cbind(0,eta+.6,2*eta);weights<-exp(weights-apply(weights,1,max));prob<-weights/rowSums(weights)
  y<-rowSums(uniform>t(apply(prob,1,cumsum)))
  stopifnot(all(y %in% 0:2),max(abs(rowSums(prob)-1))<1e-14)
  data<-data.frame(Person=sprintf('P%03d',p),Rater=sprintf('R%02d',r),Criterion=paste0('C',criterion),Score=y)
  fits<-list();errors<-warnings<-list();elapsed<-numeric()
  for(model in c('ordinary','shared')) {
    warning_text<-error_text<-character()
    timing<-system.time(fit<-tryCatch(withCallingHandlers({
      if(model=='ordinary') fit_mfrm(data,'Person',c('Rater','Criterion'),'Score',
        population_formula=~1,person_data=unique(data['Person']),quad_points=61,
        maxit=400,rating_min=0,rating_max=2,keep_original=TRUE) else
        fit_mfrm_random_rater(data,'Person','Rater','Score','Criterion',0:2,
          person_sd=NULL,quad_points=61,maxit=400)
    },warning=function(w) {warning_text<<-c(warning_text,conditionMessage(w));invokeRestart('muffleWarning')}),
      error=function(e) {error_text<<-conditionMessage(e);NULL}))
    fits[model]<-list(fit);warnings[model]<-list(warning_text);errors[model]<-list(error_text)
    elapsed[model]<-timing[['elapsed']]
  }
  saveRDS(list(roster=row,data=data,truth=list(theta=setNames(theta,sprintf('P%03d',1:240)),
    raters=setNames(u,sprintf('R%02d',seq_along(u))),criterion=setNames(c(-.3,0,.3),paste0('C',1:3)),
    steps=c(-.6,.6),person_sd=1.3,rater_sd=.7),fits=fits,errors=errors,warnings=warnings,elapsed=elapsed),path)
  cat('trial',row$Trial,'condition',row$Condition,'replicate',row$Replicate,
    'shared ready',isTRUE(fits$shared$checks$NumericalReady),'seconds',sum(elapsed),'\n');flush.console()
}
