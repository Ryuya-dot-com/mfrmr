# Apply the existing exact conditional reference to the 50 retained N30 inputs.
# No optimization, simulation, numerical differentiation or parameter substitution.
source('inst/validation/mfrm-wide-map-pcm-r50-20261002.R');wide_pcm_setup()
args <- commandArgs(trailingOnly=TRUE);stopifnot(length(args)==2L)
root <- args[1];out <- args[2];dir.create(out,recursive=TRUE,showWarnings=FALSE)
summary <- wide_f_read(file.path(root,'summary-n30/summary.rds'))$payload
jobs <- summary$jobs[summary$jobs$Arm=='PCM-JML',]
stopifnot(nrow(jobs)==50L,all(jobs$ConditionId=='AB:paired-L1:N30:SD1:S-PCM'))
paths <- file.path(root,jobs$JobId,'calibration/q0-fit.rds')
binding <- list(input=tools::md5sum(paths),source=tools::md5sum(c(
  'inst/validation/jml-n30-conditional-reference-20261003.R',
  'inst/validation/jml-pcm-conditional-intervals-20261003.py')))
write_bound <- function(value,path) {
  text <- jsonlite::toJSON(value,auto_unbox=TRUE,digits=NA,pretty=TRUE)
  if(file.exists(path))stopifnot(identical(readChar(path,file.info(path)$size),paste0(text,'\n')))
  else writeLines(text,path)
}
wide_mml_phase(file.path(out,'manifest.rds'),'saved-n30-conditional-reference-v1',function()binding)
rows <- list()
for(i in seq_len(nrow(jobs))) {
  fit <- wide_f_read(paths[i])$payload$value;d <- fit$prep$data
  stopifnot(fit$config$model=='PCM',fit$config$method=='JML',
    fit$config$step_facet=='Criterion',fit$config$n_cat==4L,
    all(d$Weight==1),identical(fit$config$facet_names,c('Rater','Criterion')))
  data <- data.frame(Person=as.character(d$Person),Rater=as.integer(as.character(d$Rater)),
    Criterion=as.integer(as.character(d$Criterion)),Score=as.integer(d$score_k))
  input <- file.path(out,sprintf('input-%02d.json',i))
  output <- file.path(out,sprintf('result-%02d.json',i))
  write_bound(list(data=data,K=3L,N=30L,step_facet='Criterion'),input)
  if(!file.exists(output)) {
    code <- system2('python3',c('inst/validation/jml-pcm-conditional-intervals-20261003.py',input,output),
      stdout=file.path(out,sprintf('result-%02d.log',i)))
    stopifnot(code==0L)
  }
  result <- jsonlite::fromJSON(output,simplifyVector=FALSE)
  stopifnot(result$N==30L,result$K==3L)
  original <- wide_f_read(file.path(root,jobs$JobId[i],'outputs.rds'))$payload
  for(z in result$Results) {
    facet <- sub(' 1 - 2','',z$Contrast,fixed=TRUE)
    tab <- fit$facets$others;tab <- tab[tab$Facet==facet,]
    estimate <- tab$Estimate[match('1',tab$Level)]-tab$Estimate[match('2',tab$Level)]
    plan <- original$initial$plan
    truth <- unique(plan$ReferenceValue[plan$Target==paste0('contrast:',facet,':1-2')])
    lo <- as.numeric(z$Lower);hi <- as.numeric(z$Upper)
    rows[[paste(i,facet)]] <- data.frame(Replicate=i,JobId=jobs$JobId[i],Facet=facet,
      Estimate=estimate,Truth=truth,Lower=lo,Upper=hi,Width=hi-lo,
      ContainsTruth=lo<=truth&&truth<=hi,ContainsJMLPoint=lo<=estimate&&estimate<=hi,
      Finite=is.finite(lo)&&is.finite(hi),Pairs=z$Pairs,DiscordantPairs=z$DiscordantPairs)
  }
  cat('Completed conditional reference',i,'of 50\n');flush.console()
}
table <- do.call(rbind,rows);write.csv(table,file.path(out,'intervals.csv'),row.names=FALSE)
wide_mml_phase(file.path(out,'summary.rds'),c(binding,list(results=tools::md5sum(
  file.path(out,sprintf('result-%02d.json',1:50))))),function()list(table=table,
    new_fits=0L,new_datasets=0L,
    scope='Exact conditional structural-truth reference, retaining the public JML point; not validation of its Wald or bootstrap interval.'))
print(aggregate(cbind(Finite,ContainsTruth,ContainsJMLPoint,Width)~Facet,table,sum),row.names=FALSE)
