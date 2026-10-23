# Paired development comparison on the original 500 condition-datasets.
# Each continuation is separate; never select the better interval case by case.
script <- 'inst/validation/gmfrm-interval-comparison-20261010.R'
helper <- 'inst/validation/mfrm-wide-map-output-summary-20261001.R'
source(helper)
root <- 'validation-results/mfrm-wide-map-d-historical-two-family-r50-20261006'
out <- 'validation-results/gmfrm-interval-disposition-20261010'
audit_path <- file.path(out,'review.rds'); audit <- readRDS(audit_path)
paths <- character()
check <- function(h) {
  stopifnot(length(h)>0L,!anyNA(h),identical(unname(tools::md5sum(names(h))),unname(h)))
  paths <<- union(paths,names(h))
}
check(audit$inputs_and_source)
baseline <- list()
for(n in c(20,30,40,60,120,240,480)) {
  p <- if(n==240) 'validation-results/mfrm-wide-map-d-retained-output-20261005/complete-n240-summary.rds' else
    file.path(root,paste0('complete-n',n,'-summary'),if(n==30)'source-bound-replay' else '', 'summary.rds')
  s <- readRDS(p); paths<-union(paths,p); check(s$binding$outputs)
  files<-names(s$binding$outputs);files<-files[grepl('/d-outputs[.]rds$',files)]
  z<-do.call(rbind,lapply(files,function(p){x<-readRDS(p)$payload;wide_output_records(x$plan,x$records)}))
  baseline[[as.character(n)]]<-z[grepl(paste0(':N',n,':'),z$ConditionId),]
}
baseline<-do.call(rbind,baseline);rownames(baseline)<-NULL
stopifnot(nrow(baseline)==20000L,!anyDuplicated(wide_output_key(baseline)))
continuations<-c(curvature='validation-results/gmfrm-stationarity-continuation-20261010/summary.rds',
  saved_source='validation-results/gmfrm-retained-source-reuse-20261010/summary.rds')
versions<-list(original=baseline);changed<-list()
for(name in names(continuations)) {
  p<-continuations[[name]];s<-readRDS(p);paths<-union(paths,p);check(s$files)
  if(name=='saved_source') {
    p<-'validation-results/gmfrm-retained-source-reuse-20261010/independent-reference.rds'
    reference<-readRDS(p);paths<-union(paths,p);check(reference$inputs_and_source)
  }
  x<-baseline
  for(v in s$results) {
    if(name=='curvature')check(v$phases)
    if(!v$admitted)next
    if(name=='saved_source') {
      k<-match(v$job$Job,reference$rows$Job);stopifnot(!is.na(k))
      if(!reference$rows$Passed[k])next
    }
    j<-v$job; rows<-which(x$ConditionId==j$ConditionId & x$Replicate==j$Replicate & x$Output=='interval')
    stopifnot(length(rows)==20L,all(!x$Available[rows]))
    table<-v$intervals; ix<-match(x$Target[rows],table$Target);stopifnot(!anyNA(ix))
    for(k in c('Owner','Level','Coordinate','ScaleReference'))stopifnot(identical(x[[k]][rows],table[[k]][ix]))
    for(k in c('Available','Estimate','SE','Lower','Upper','Reason'))x[[k]][rows]<-table[[k]][ix]
    x$SourceStage[rows]<-if(name=='saved_source')j$LaterStage else paste0('curvature:',j$Job)
    changed[[length(changed)+1L]]<-data.frame(Version=name,ConditionId=j$ConditionId,Replicate=j$Replicate)
  }
  # Only interval records from preselected stationary refusals may change.
  candidate<-paste(x$ConditionId,x$Replicate) %in%
    paste(audit$refusals$ConditionId[audit$refusals$FirstFailedCheck=='Stationary local maximum'],
      audit$refusals$Replicate[audit$refusals$FirstFailedCheck=='Stationary local maximum']) & x$Output=='interval'
  stopifnot(identical(x[!candidate,],baseline[!candidate,]))
  versions[[name]]<-x
}
summary<-do.call(rbind,lapply(names(versions),function(name) {
  z<-versions[[name]];z<-z[z$Output=='interval',]
  do.call(rbind,lapply(split(z,paste(z$ConditionId,z$Target)),function(x) {
    ok<-x$Available;n<-sum(ok);k<-sum(x$Lower[ok]<=x$ReferenceValue[ok] & x$ReferenceValue[ok]<=x$Upper[ok])
    ci<-if(n)unname(binom.test(k,n)$conf.int) else c(NA_real_,NA_real_)
    err<-x$Estimate[ok]-x$ReferenceValue[ok]
    cbind(x[1,c('ConditionId','Target','Owner','Level','Coordinate')],data.frame(Version=name,
      Planned=nrow(x),Excluded=sum(x$Eligibility!='eligible'),Available=n,Covered=if(n)k else NA_integer_,
      ConditionalCoverage=if(n)k/n else NA_real_,CoverageLower=ci[1],CoverageUpper=ci[2],
      ReturnedAndCovered=k/nrow(x),
      RefusalOnlyCeiling=if(n && all(x$Eligibility=='eligible'))(k+nrow(x)-n)/nrow(x) else NA_real_,
      Bias=if(n)mean(err)else NA_real_,
      SEtoSD=if(n>1)sqrt(mean(x$SE[ok]^2))/sd(err)else NA_real_))
  }))
}));rownames(summary)<-NULL
stopifnot(nrow(summary)==600L)
old<-summary[summary$Version=='original',]
at<-match(paste(old$ConditionId,old$Target),paste(audit$metrics$ConditionId,audit$metrics$Target))
for(k in c('Planned','Excluded','Available','Covered','ConditionalCoverage','CoverageLower','CoverageUpper','Bias','SEtoSD'))
  stopifnot(isTRUE(all.equal(old[[k]],audit$metrics[[k]][at],tolerance=1e-12)))
hashes<-tools::md5sum(c(paths,audit_path,script,helper));check(hashes)
result<-list(summary=summary,changed=do.call(rbind,changed),inputs_and_source=hashes,
  scope='Paired inspected-development comparison; separate procedures, no interval switching by truth/coverage, no new data. Original point outputs and all unaffected interval records remain identical.')
target<-file.path(out,'comparison.rds')
if(file.exists(target))stopifnot(identical(readRDS(target),result)) else saveRDS(result,target)
write.csv(summary,file.path(out,'comparison.csv'),row.names=FALSE)
print(summary[summary$Target=='slopes:"Task":"t1"' & grepl(':N(30|40|60):',summary$ConditionId),
  c('ConditionId','Version','Available','Covered','ConditionalCoverage','CoverageUpper')],row.names=FALSE)
cat('Three complete paired procedures reconciled; original and unaffected records unchanged.\n')
