# Small model/rendering fixtures; not a recovery or inference-validation study.
# Run from the package root: Rscript inst/validation/plot-models-0.2.4.R /tmp/mfrmr-plot-models
pkgload::load_all('.', quiet=TRUE)
args <- commandArgs(trailingOnly=TRUE)
out <- if(length(args)) args[1] else file.path(tempdir(),'mfrmr-plot-models')
dir.create(out,recursive=TRUE,showWarnings=FALSE)
fits <- list(); conditions <- list(); warns <- list()
for (owner in c('Criterion','Rater')) {
 d <- simulate_mfrm_data(n_person=60,n_rater=4,n_criterion=4,raters_per_person=2,
  assignment='rotating',model='GPCM',step_facet=owner,slope_facet=owner,
  slopes=c(0.6,0.85,1.2,1.6),score_levels=4,seed=9510+match(owner,c('Criterion','Rater')))
 d$Score[seq(7,nrow(d),7)] <- NA
 for (method in c('JML','MML')) {
  key <- paste('GPCM',owner,method,sep='-'); messages <- character(); start <- proc.time()[['elapsed']]
  fits[[key]] <- withCallingHandlers(fit_mfrm(d,person='Person',facets=c('Rater','Criterion'),score='Score',
   model='GPCM',method=method,step_facet=owner,slope_facet=owner,quad_points=11,maxit=30),
   warning=function(w) {messages <<- c(messages,conditionMessage(w)); invokeRestart('muffleWarning')})
  conditions[[key]] <- data.frame(Case=key,Model='GPCM',Method=method,Owner=owner,Rows=nrow(d),Missing=sum(is.na(d$Score)),Interactions=FALSE,Seconds=proc.time()[['elapsed']]-start)
  warns[[key]] <- messages; cat(key, 'completed\n'); saveRDS(fits,file.path(out,'fits.rds'))
 }
}
effects <- expand.grid(Rater=c('R01','R02'),Criterion=c('C01','C02'),stringsAsFactors=FALSE)
effects$Effect <- c(0.8,-0.8,-0.8,0.8)
for (model in c('RSM','PCM')) {
 d <- simulate_mfrm_data(n_person=60,n_rater=4,n_criterion=4,raters_per_person=2,
  assignment='rotating',model=model,score_levels=4,interaction_effects=effects,seed=9520+match(model,c('RSM','PCM')))
 d$Score[seq(7,nrow(d),7)] <- NA
 key <- paste(model,'interaction-MML',sep='-'); messages <- character(); start <- proc.time()[['elapsed']]
 fits[[key]] <- withCallingHandlers(fit_mfrm(d,person='Person',facets=c('Rater','Criterion'),score='Score',
  model=model,method='MML',facet_interactions='Rater:Criterion',quad_points=11,maxit=30),
  warning=function(w) {messages <<- c(messages,conditionMessage(w)); invokeRestart('muffleWarning')})
 conditions[[key]] <- data.frame(Case=key,Model=model,Method='MML',Owner=if(model=='PCM') 'Criterion' else '',Rows=nrow(d),Missing=sum(is.na(d$Score)),Interactions=TRUE,Seconds=proc.time()[['elapsed']]-start)
 warns[[key]] <- messages; cat(key,'completed\n'); saveRDS(fits,file.path(out,'fits.rds'))
}
write.csv(do.call(rbind,conditions),file.path(out,'conditions.csv'),row.names=FALSE)
saveRDS(warns,file.path(out,'fit-warnings.rds'))

rows <- list(); payloads <- list()
for (key in names(fits)) for(type in c('wright','pathway','ccc')) {
 warn <- character()
 p <- withCallingHandlers(plot(fits[[key]],type=type,draw=FALSE,preset='publication'),
  warning=function(w){warn <<- c(warn,conditionMessage(w));invokeRestart('muffleWarning')})
 payloads[[paste(key,type,sep='-')]] <- p
 for (renderer in c('base','ggplot')) for(size in list(c(7,5),c(12,8))) {
  messages <- character(); file <- sprintf('%s-%s-%s-%sx%s.png',key,type,renderer,size[1],size[2])
  png(file.path(out,file),width=size[1],height=size[2],units='in',res=110)
  error <- tryCatch(withCallingHandlers({
   if(renderer=='base') plot(fits[[key]],type=type,preset='publication') else print(as_ggplot(p))
   ''
  },warning=function(w) {messages <<- c(messages,conditionMessage(w));invokeRestart('muffleWarning')}),error=function(e)conditionMessage(e))
  dev.off()
  rows[[length(rows)+1L]] <- data.frame(Case=key,Type=type,Renderer=renderer,Width=size[1],Height=size[2],Error=error,Warnings=paste(unique(messages),collapse=' | '))
 }
 cat(key,type,'drawn\n')
}
write.csv(do.call(rbind,rows),file.path(out,'drawings.csv'),row.names=FALSE)
saveRDS(payloads,file.path(out,'payloads.rds'))

r <- do.call(rbind,rows)
stopifnot(nrow(r)==72L,all(r$Error==''))

rows <- list()
for(key in names(fits)) {
 fit <- fits[[key]]; pc <- payloads[[paste(key,'ccc',sep='-')]]$data
 pw <- payloads[[paste(key,'pathway',sep='-')]]$data
 error <- expected_error <- information_error <- 0
 for (group in unique(pc$probabilities$CurveGroup)) {
  sub <- pc$probabilities[pc$probabilities$CurveGroup==group,]
  tau <- if(fit$config$model=='RSM') fit$steps$Estimate else fit$steps$Estimate[fit$steps$StepFacet==group]
  slope <- if(fit$config$model=='GPCM') fit$slopes$Estimate[fit$slopes$SlopeFacet==group] else 1
  theta <- sort(unique(sub$Theta)); cats <- sort(unique(as.numeric(sub$Category)))
  logs <- slope * (outer(theta,seq_along(cats)-1L) - matrix(c(0,cumsum(tau)),nrow=length(theta),ncol=length(cats),byrow=TRUE))
  probs <- exp(logs-apply(logs,1,max)); probs <- probs/rowSums(probs)
  observed <- matrix(NA_real_,nrow=length(theta),ncol=length(cats))
  observed[cbind(match(sub$Theta,theta),match(as.numeric(sub$Category),cats))] <- sub$Probability
  error <- max(error,abs(observed-probs))
  ex <- drop(probs %*% cats); variance <- drop(probs %*% cats^2)-ex^2
  curve <- pw$expected[pw$expected$CurveGroup==group,]; curve <- curve[match(theta,curve$Theta),]
  expected_error <- max(expected_error,abs(curve$ExpectedScore-ex))
  information_error <- max(information_error,abs(curve$Information-slope^2*pmax(variance,0)))
  stopifnot(all(curve$Slope==slope),all(curve$PredictorOffset==0),all(curve$CurveBasis=='zero_additive_facet_profile'))
 }
 rows[[key]] <- data.frame(Case=key,ProbabilityMaxError=error,ExpectedScoreMaxError=expected_error,InformationMaxError=information_error,BasisMatches=identical(pw$curve_basis,pc$curve_basis))
}
r<-do.call(rbind,rows);print(r)
write.csv(r,file.path(out,'curve-checks.csv'),row.names=FALSE)
stopifnot(all(r$ProbabilityMaxError<1e-12),all(r$ExpectedScoreMaxError<1e-12),all(r$InformationMaxError<1e-10),all(r$BasisMatches))


for (key in c('GPCM-Rater-MML','PCM-interaction-MML')) for(renderer in c('base','ggplot')) {
 type <- if(key=='GPCM-Rater-MML') 'ccc' else 'pathway'
 pdf(file.path(out,paste0(key,'-',type,'-',renderer,'.pdf')),width=7,height=5)
 withCallingHandlers({
  if(renderer=='base') plot(fits[[key]],type=type,preset='publication') else print(as_ggplot(payloads[[paste(key,type,sep='-')]]))
 },warning=function(w)invokeRestart('muffleWarning'))
 dev.off()
}
files <- list.files('R',pattern='[.]R$',full.names=TRUE)
write.csv(data.frame(File=files,MD5=unname(tools::md5sum(files))),file.path(out,'source-md5.csv'),row.names=FALSE)
writeLines(capture.output(sessionInfo()),file.path(out,'session-info.txt'))
