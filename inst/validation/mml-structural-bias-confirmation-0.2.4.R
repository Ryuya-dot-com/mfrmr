# Fresh fixed-seed confirmation; companion protocol owns the unchanged primary rules.
# Rscript ...R preflight /tmp/mml-bias-confirmation-preflight
# Rscript ...R confirmation /tmp/mml-bias-confirmation 1  (workers 1, 2, 3)
# Rscript ...R summarize /tmp/mml-bias-confirmation
source('inst/validation/mml-structural-bias-diagnostic-0.2.4.R')

mml_bias_confirmation_plan <- function() {
  plan <- expand.grid(Cell=c(1L,5L,7L),Block=1:10)
  plan$Worker <- as.integer((seq_len(nrow(plan))-1L+plan$Block-1L) %% 3L+1L)
  plan$First <- (plan$Block-1L)*1000L+1L
  plan$Last <- plan$Block*1000L
  plan
}

mml_bias_confirmation_payload <- function() {
  names <- c('mml-independent-rsm-information-0.2.4.R',
    'mml-independent-information-conditions-0.2.4.R','mml-structural-coverage-0.2.4.R',
    'mml-structural-coverage-protocol-0.2.4.md','mml-structural-bias-diagnostic-0.2.4.R',
    'mml-structural-bias-diagnostic-evidence-0.2.4.rds','mml-structural-coverage-evidence-0.2.4.rds',
    'mml-structural-bias-confirmation-0.2.4.R','mml-structural-bias-confirmation-protocol-0.2.4.md')
  tools::md5sum(c(list.files('R',pattern='[.]R$',full.names=TRUE),paste0('inst/validation/',names)))
}

mml_bias_confirmation_one <- function(cell,replicate,stage,oracle,template) {
  started <- proc.time()[['elapsed']]
  out <- mml_coverage_one(cell,1000000L+replicate,stage)
  stopifnot(out$Seed==(if(stage=='preflight') 52000000L else 62000000L)+10000L*cell$Cell+replicate)
  out$SeedIndex <- out$Replicate;out$Replicate <- replicate
  out$Linear <- setNames(rep(NA_real_,length(out$Truth)),names(out$Truth))
  out$SecondaryError <- ''
  secondary <- tryCatch({
    draw <- mml_bias_replay(template,out$Seed)
    if(stage=='preflight') {
      original <- mml_information_fixture(cell$Model,'baseline',3L,out$Seed,cell$Persons,cell$Exposure)
      stopifnot(identical(draw$score,original$data$Score))
    }
    counts <- lapply(seq_along(oracle$assignments),function(g)
      tabulate(draw$pattern[template$assignment==g],nrow(oracle$patterns)))
    stopifnot(all(vapply(counts,sum,numeric(1))==cell$Persons/length(counts)))
    score <- Reduce('+',Map(function(n,z) as.vector(crossprod(n,z$score)),counts,oracle$assignments))
    map <- mml_bias_expanded_map(oracle$x)
    out$Linear <- setNames(as.vector(map %*% solve(cell$Persons*oracle$information,score)),rownames(map))
    out$PatternCounts <- counts
    NULL
  },error=identity)
  if(inherits(secondary,'error')) out$SecondaryError <- conditionMessage(secondary)
  out$TotalSeconds <- proc.time()[['elapsed']]-started
  out
}

mml_bias_confirmation_mechanism <- function(error,linear,predicted,linear_variance,planned) {
  predicted<-unname(predicted);linear_variance<-unname(linear_variance)
  n <- length(error);finite <- is.finite(error)&is.finite(linear)
  complete <- n==planned && all(finite) && n>1L
  e <- error[finite];l <- linear[finite];r <- e-l;m <- length(e)
  if(m>1L && all(finite) && sd(e)>0) {
    v <- var(e);s <- sqrt(v);difference <- (mean(r)-predicted)/s
    influence <- (r-mean(r))/s-difference*((e-mean(e))^2-v)/(2*v)
    mcse <- sd(influence)/sqrt(m);z <- qnorm(.975)
    rmc <- sd(r)/sqrt(m)
    data <- c(Attempted=n,Finite=m,RawBias=mean(e),FirstOrderMean=mean(l),
      FirstOrderMCSE=sqrt(linear_variance/m),FirstOrderZ=mean(l)/sqrt(linear_variance/m),
      RemainderMean=mean(r),RemainderMCSE=rmc,RemainderLower=mean(r)-z*rmc,RemainderUpper=mean(r)+z*rmc,
      CurvatureBias=predicted,ApproximationDifference=difference,ApproximationMCSE=mcse,
      ApproximationLower=difference-z*mcse,ApproximationUpper=difference+z*mcse,ErrorSD=s)
    approx <- mml_coverage_range(data['ApproximationLower'],data['ApproximationUpper'],c(-.01,.01))
    signed <- sort(sign(predicted)*data[c('RemainderLower','RemainderUpper')])
    direction <- if(signed[1]>0) 'supported' else if(signed[2]<0) 'concern' else 'review'
    first_order <- if(abs(data['FirstOrderZ'])<=qnorm(.9995)) 'supported' else 'review'
    disposition <- if(!complete) 'review' else if(any(c(approx,direction)=='concern')) 'concern' else
      if(all(c(approx,direction,first_order)=='supported')) 'supported' else 'review'
  } else {
    fields <- c('Attempted','Finite','RawBias','FirstOrderMean','FirstOrderMCSE','FirstOrderZ',
      'RemainderMean','RemainderMCSE','RemainderLower','RemainderUpper','CurvatureBias',
      'ApproximationDifference','ApproximationMCSE','ApproximationLower','ApproximationUpper','ErrorSD')
    data <- setNames(rep(NA_real_,length(fields)),fields);data[c('Attempted','Finite','CurvatureBias')]<-c(n,m,predicted)
    approx <- direction <- first_order <- disposition <- 'review'
  }
  data.frame(as.list(data),CompleteFinite=complete,ApproximationStatus=approx,
    DirectionStatus=direction,FirstOrderStatus=first_order,MechanismDisposition=disposition)
}

mml_bias_confirmation_self_check <- function() {
  mml_coverage_self_check()
  n <- 2000L;e <- exp(.45*qnorm((1:n-.5)/n))-exp(.45^2/2)+.03
  r <- .005+.02*e+.03*(e^2-mean(e^2));predicted <- .003
  z <- mml_bias_confirmation_mechanism(e,e-r,c(target=predicted),c(target=1),n)
  value <- (mean(r)-predicted)/sd(e)
  loo <- vapply(1:n,function(i) (mean(r[-i])-predicted)/sd(e[-i]),numeric(1))
  jackknife_mcse <- sqrt((n-1)/n*sum((loo-mean(loo))^2))
  stopifnot(abs(z$ApproximationDifference-value)<1e-14,
    abs(jackknife_mcse/z$ApproximationMCSE-1)<.02,
    !mml_bias_confirmation_mechanism(c(NA,e[-1]),e-r,predicted,1,n)$CompleteFinite,
    mml_bias_confirmation_mechanism(e,e+.1,.1,1,n)$MechanismDisposition=='concern')
  plan <- mml_bias_confirmation_plan()
  stopifnot(nrow(plan)==30L,all(table(plan$Cell)==10L),all(table(plan$Worker)==10L),
    !anyDuplicated(paste(plan$Cell,plan$Block)))
  invisible(list(InfluenceMCSE=z$ApproximationMCSE,JackknifeMCSE=jackknife_mcse))
}

mml_bias_confirmation_run <- function(stage,directory,worker=1L) {
  stopifnot(stage %in% c('preflight','confirmation'),worker %in% 1:3)
  pkgload::load_all('.',quiet=TRUE)
  self_check <- mml_bias_confirmation_self_check()
  payload <- mml_bias_confirmation_payload()
  prior <- readRDS('inst/validation/mml-structural-bias-diagnostic-evidence-0.2.4.rds')
  basis <- readRDS('inst/validation/mml-structural-coverage-evidence-0.2.4.rds')$confirmation[[1]]$Payload
  stopifnot(identical(tools::md5sum(names(basis)),basis))
  plan <- mml_bias_confirmation_plan()
  if(stage=='preflight') {
    plan <- data.frame(Cell=c(1L,5L,7L),Block=0L,Worker=worker,First=1L,Last=5L)
  } else plan <- plan[plan$Worker==worker,]
  dir.create(directory,recursive=TRUE,showWarnings=FALSE)
  started <- proc.time()[['elapsed']]
  for(j in seq_len(nrow(plan))) {
    task <- plan[j,];cell <- mml_coverage_cells()[task$Cell,]
    oracle <- prior$oracles[[paste(cell$Model,cell$Exposure)]]
    template <- mml_bias_replay_template(cell,oracle)
    path <- file.path(directory,sprintf('cell-%02d-block-%02d.rds',task$Cell,task$Block))
    state <- list(Cell=cell,Stage=stage,Task=task,Planned=task$Last-task$First+1L,
      TotalPlanned=if(stage=='preflight')5L else 10000L,Payload=payload,Results=list(),
      Session=sessionInfo(),RNGkind=RNGkind(),SelfCheck=self_check)
    if(file.exists(path)) {
      state <- readRDS(path)
      stopifnot(identical(state$Payload,payload),identical(state$Task,task),identical(state$Stage,stage))
    }
    checkpoint <- function() {
      saveRDS(state,paste0(path,'.tmp'),compress=FALSE)
      stopifnot(file.rename(paste0(path,'.tmp'),path))
    }
    first <- task$First+length(state$Results)
    if(first>task$Last) next
    for(rep in seq.int(first,task$Last)) {
      state$Results[[rep-task$First+1L]] <- mml_bias_confirmation_one(cell,rep,stage,oracle,template)
      if(rep %% 50L==0L || stage=='preflight' || rep==task$Last) {
        checkpoint();recent<-tail(state$Results,min(50L,length(state$Results)))
        cat(sprintf('%s worker %d cell %d block %d: %d/%d; mean %.3fs; errors %d; secondary errors %d; conflicts %d\n',
          stage,worker,cell$Cell,task$Block,rep-task$First+1L,state$Planned,
          mean(vapply(recent,`[[`,numeric(1),'TotalSeconds')),
          sum(vapply(recent,function(z)nzchar(z$Error),logical(1))),
          sum(vapply(recent,function(z)nzchar(z$SecondaryError),logical(1))),
          sum(vapply(recent,`[[`,logical(1),'ReadyNumericalConflict'))));flush.console()
      }
      if(proc.time()[['elapsed']]-started>4*3600) {checkpoint();stop('Resource ceiling; incomplete study')}
    }
  }
  invisible(TRUE)
}

mml_bias_confirmation_summarize <- function(directory) {
  pkgload::load_all('.',quiet=TRUE)
  payload <- mml_bias_confirmation_payload();states<-list();all_seeds<-integer()
  plan <- mml_bias_confirmation_plan()
  for(id in c(1L,5L,7L)) {
    tasks <- plan[plan$Cell==id,]
    blocks <- lapply(tasks$Block,function(b) readRDS(file.path(directory,sprintf('cell-%02d-block-%02d.rds',id,b))))
    for(j in seq_along(blocks)) {
      b<-blocks[[j]]
      stopifnot(identical(b$Payload,payload),identical(b$Task,tasks[j,,drop=FALSE]),
        b$Stage=='confirmation',length(b$Results)==1000L)
    }
    results<-unlist(lapply(blocks,`[[`,'Results'),recursive=FALSE)
    stopifnot(identical(vapply(results,`[[`,integer(1),'Replicate'),1:10000),
      identical(vapply(results,`[[`,integer(1),'Seed'),62000000L+10000L*id+1:10000))
    all_seeds<-c(all_seeds,vapply(results,`[[`,integer(1),'Seed'))
    state<-list(Cell=blocks[[1]]$Cell,Stage='confirmation',Planned=10000L,Payload=payload,Results=results)
    saveRDS(state,file.path(directory,sprintf('cell-%02d.rds',id)))
    states[[as.character(id)]]<-state
  }
  stopifnot(length(all_seeds)==30000L,!anyDuplicated(all_seeds))
  primary <- mml_coverage_summarize(directory)
  prior <- readRDS('inst/validation/mml-structural-bias-diagnostic-evidence-0.2.4.rds')
  rows<-list();targets<-c('1'='shared:Step_2','5'='C1:Step_2','7'='Criterion:C1')
  for(state in states) {
    cell<-state$Cell;key<-paste(cell$Model,cell$Exposure);oracle<-prior$oracles[[key]]
    map<-mml_bias_expanded_map(oracle$x)
    predicted<-as.vector(map %*% prior$curvature[[key]]$fine$coefficient)/cell$Persons
    variance<-diag(map %*% solve(cell$Persons*oracle$information) %*% t(map))
    for(j in seq_len(nrow(map))) {
      error<-vapply(state$Results,function(z)z$Estimate[j]-z$Truth[j],numeric(1))
      linear<-vapply(state$Results,function(z)z$Linear[j],numeric(1))
      row<-mml_bias_confirmation_mechanism(error,linear,predicted[j],variance[j],10000L)
      rows[[length(rows)+1L]]<-cbind(cell,Coordinate=rownames(map)[j],
        MechanismTarget=rownames(map)[j]==targets[as.character(cell$Cell)],row)
    }
  }
  mechanism<-do.call(rbind,rows)
  write.csv(mechanism,file.path(directory,'mechanism.csv'),row.names=FALSE)
  invisible(list(primary=primary,mechanism=mechanism,states=states,payload=payload))
}

if(sys.nframe()==0L) {
  args<-commandArgs(trailingOnly=TRUE);stopifnot(length(args) %in% 2:3)
  if(args[1]=='summarize') mml_bias_confirmation_summarize(args[2]) else
    mml_bias_confirmation_run(args[1],args[2],if(length(args)==3L)as.integer(args[3]) else 1L)
}
