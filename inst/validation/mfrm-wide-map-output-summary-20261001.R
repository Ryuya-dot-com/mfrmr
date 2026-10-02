# Development accounting for selected structural outputs, not a public API.
# Source this file. No fitting, scoring, stage selection or interval construction.
# One plan row per condition/arm/replicate/target/output. Point and interval rows
# retain their own source stage; retries must not become extra replications.
wide_output_key <- function(x) do.call(paste,c(x[c('ConditionId','Arm','Replicate','Target','Output')],sep='\r'))

wide_output_records <- function(plan,results) {
  keys <- c('ConditionId','Arm','Replicate','Target','Output')
  stopifnot(is.data.frame(plan),is.data.frame(results),nrow(plan)>0L,
    all(c(keys,'InputId','Eligibility','Reference','ReferenceValue') %in% names(plan)),
    all(c(keys,'Status','Available','Estimate','SE','Lower','Upper','SourceStage','Reason') %in% names(results)),
    !anyNA(plan[c(keys,'InputId','Eligibility','Reference')]),!anyNA(results[c(keys,'Status','Available','SourceStage','Reason')]),
    is.logical(results$Available),all(plan$Replicate>=1 & plan$Replicate==floor(plan$Replicate)),
    all(plan$Output %in% c('point','interval')),
    all(plan$Eligibility %in% c('eligible','fixed','unsupported','design_excluded')),
    all(plan$Reference %in% c('generating_parameter','population_equation_root','none')),
    all(results$Status %in% c('returned','error','interrupted','running')))
  pk <- wide_output_key(plan);rk <- wide_output_key(results)
  if(anyDuplicated(pk)||anyDuplicated(rk))stop('Duplicate selected output; stages/targets are not independent replications.')
  if(!all(rk %in% pk))stop('An outcome has no planned target.')
  declared <- plan$Eligibility=='eligible' & plan$Reference!='none'
  if(any(!is.finite(plan$ReferenceValue[declared])))stop('A declared evaluation reference needs a finite value; otherwise use Reference=none.')
  ix <- match(pk,rk);out <- cbind(plan,results[ix,setdiff(names(results),keys),drop=FALSE])
  rownames(out) <- NULL;missing <- is.na(ix)
  out$Status[missing] <- 'not_started';out$Available[missing] <- FALSE
  out$SourceStage[missing] <- '';out$Reason[missing] <- ''
  eligible <- out$Eligibility=='eligible'
  if(any(!eligible & !missing))stop('Fixed/unsupported/design-excluded outputs have no sampling attempt.')
  if(any(out$Status=='returned' & !nzchar(out$SourceStage)))stop('Returned outputs, including refusals, need a source stage.')
  if(any(out$Available & out$Status!='returned'))stop('Only returned outputs can be available.')
  if(any(out$Available & (!is.finite(out$Estimate)|!nzchar(out$SourceStage))))
    stop('Available structural outputs need a finite estimate and source stage.')
  ci <- eligible & out$Output=='interval' & out$Available
  if(any(ci & (!is.finite(out$SE)|out$SE<=0|!is.finite(out$Lower)|!is.finite(out$Upper)|out$Lower>out$Upper)))
    stop('Available intervals need positive finite SE and ordered finite bounds.')
  no_ci <- out$Output=='interval' & !out$Available
  if(any(no_ci & (!is.na(out$SE)|!is.na(out$Lower)|!is.na(out$Upper))))
    stop('Unavailable intervals must not leak SEs or bounds.')
  refused <- eligible & (out$Status %in% c('error','interrupted') | (out$Status=='returned' & !out$Available))
  if(any(refused & !nzchar(out$Reason)))stop('Errors, interruptions and unavailable outputs need a reason.')
  out
}

wide_output_summary <- function(plan,results) {
  x <- wide_output_records(plan,results)
  group <- c('ConditionId','Arm','Target','Output','Eligibility','Reference')
  ids <- do.call(paste,c(x[group],sep='\r'))
  rows <- lapply(split(seq_len(nrow(x)),ids),function(i) {
    z <- x[i,];eligible <- z$Eligibility=='eligible'
    n <- sum(eligible);settled <- eligible & z$Status %in% c('returned','error')
    complete <- sum(settled)==n
    delivered <- eligible & z$Available;nd <- sum(delivered)
    valid <- delivered & z$Reference!='none'
    error <- z$Estimate[valid]-z$ReferenceValue[valid]
    returned_intervals <- delivered & z$Output=='interval'
    interval_reference <- z$Output[1]=='interval' && z$Reference[1]!='none' && n>0
    coverage <- valid & z$Output=='interval'
    covered <- sum(z$Lower[coverage]<=z$ReferenceValue[coverage] & z$Upper[coverage]>=z$ReferenceValue[coverage])
    nc <- sum(coverage)
    conditional <- if(complete && nc>0)covered/nc else NA_real_
    cbind(z[1,group,drop=FALSE],data.frame(Planned=nrow(z),Eligible=n,Excluded=nrow(z)-n,
      Started=sum(eligible & z$Status!='not_started'),Settled=sum(settled),
      NotStarted=sum(eligible & z$Status=='not_started'),Running=sum(eligible & z$Status=='running'),
      Interrupted=sum(eligible & z$Status=='interrupted'),Errors=sum(eligible & z$Status=='error'),
      ReturnedUnavailable=sum(eligible & z$Status=='returned' & !z$Available),Available=nd,
      Complete=complete,Availability=if(complete && n>0)nd/n else NA_real_,
      ReferenceAvailable=sum(valid),MeanError=if(complete && any(valid))mean(error) else NA_real_,
      RMSE=if(complete && any(valid))sqrt(mean(error^2)) else NA_real_,
      ErrorMCSE=if(complete && length(error)>1L)sd(error)/sqrt(length(error)) else NA_real_,
      MeanWidth=if(complete && any(returned_intervals))mean(z$Upper[returned_intervals]-z$Lower[returned_intervals]) else NA_real_,
      Covered=if(interval_reference)covered else NA_integer_,ConditionalCoverage=conditional,
      CoverageMCSE=if(is.finite(conditional))sqrt(conditional*(1-conditional)/nc) else NA_real_,
      ReturnedAndCovered=if(complete && interval_reference)covered/n else NA_real_))
  })
  out <- do.call(rbind,rows);rownames(out) <- NULL;out
}

wide_paired_point_summary <- function(plan,results,arm_a,arm_b) {
  stopifnot(length(arm_a)==1L,length(arm_b)==1L,arm_a!=arm_b)
  x <- wide_output_records(plan,results)
  x <- x[x$Output=='point' & x$Eligibility=='eligible' & x$Arm %in% c(arm_a,arm_b),]
  keys <- c('ConditionId','Replicate','Target')
  z <- merge(x[x$Arm==arm_a,],x[x$Arm==arm_b,],by=keys,suffixes=c('_A','_B'),all=TRUE)
  if(!nrow(z)||anyNA(z$Arm_A)||anyNA(z$Arm_B))stop('Both arms need the same prespecified eligible point targets.')
  if(any(z$InputId_A!=z$InputId_B)||any(z$Reference_A!=z$Reference_B)||
    any(z$Reference_A=='none')||any(z$ReferenceValue_A!=z$ReferenceValue_B))
    stop('Paired errors require identical inputs and declared evaluation references.')
  for(field in intersect(c('Coordinate','ScaleReference','TargetDefinition'),names(plan))) {
    a <- z[[paste0(field,'_A')]];b <- z[[paste0(field,'_B')]]
    if(anyNA(a)||anyNA(b)||any(a!=b))
      stop('Paired errors require matching target coordinates, scale references and contrast definitions; map targets explicitly first.')
  }
  ids <- paste(z$ConditionId,z$Target,z$Reference_A,sep='\r')
  rows <- lapply(split(seq_len(nrow(z)),ids),function(i) {
    a <- z[i,];both <- a$Available_A & a$Available_B
    complete <- all(a$Status_A %in% c('returned','error') & a$Status_B %in% c('returned','error'))
    difference <- (a$Estimate_A[both]-a$ReferenceValue_A[both])^2-
      (a$Estimate_B[both]-a$ReferenceValue_B[both])^2
    data.frame(ConditionId=a$ConditionId[1],Target=a$Target[1],Reference=a$Reference_A[1],
      ArmA=arm_a,ArmB=arm_b,EligiblePairs=nrow(a),AAvailable=sum(a$Available_A),
      BAvailable=sum(a$Available_B),BothAvailable=sum(both),Complete=complete,
      MeanSquaredErrorDifference=if(complete && any(both))mean(difference) else NA_real_,
      PairedMCSE=if(complete && length(difference)>1L)sd(difference)/sqrt(length(difference)) else NA_real_,
      Conditioning='Both selected point outputs returned; marginal availability remains reported.')
  })
  out <- do.call(rbind,rows);rownames(out) <- NULL;out
}
