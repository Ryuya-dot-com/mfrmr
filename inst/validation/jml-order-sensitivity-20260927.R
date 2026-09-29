# Research-only paired sensitivity across adjustment orders. No order selection,
# p-value, truth-coverage statement or public JML interval is produced.
jml_order_sensitivity <- function(candidates) {
  if(length(candidates)<2L) stop('At least two reviewed candidates are required.')
  reference <- candidates[[1]]
  p <- length(reference$beta); N <- nrow(reference$influence)
  orders <- vapply(candidates,function(x) x$order,numeric(1))
  if(any(!is.finite(orders) | orders<1 | orders!=floor(orders)) || anyDuplicated(orders))
    stop('Adjustment orders must be unique positive integers.')
  for(x in candidates) {
    if(!isTRUE(x$reviewed) || !identical(x$sampling,reference$sampling) ||
       !x$sampling %in% c('fixed_rosters','random_rosters') ||
       length(x$beta)!=p || !identical(names(x$beta),names(reference$beta)) ||
       is.null(names(x$beta)) || anyDuplicated(names(x$beta)) ||
       !is.matrix(x$influence) || !identical(dim(x$influence),c(N,p)) ||
       !identical(colnames(x$influence),names(x$beta)) ||
       is.null(rownames(x$influence)) || anyDuplicated(rownames(x$influence)) ||
       !identical(rownames(x$influence),rownames(reference$influence)) ||
       length(x$stratum)!=N || anyNA(x$stratum) ||
       !identical(x$stratum,reference$stratum) ||
       any(!is.finite(x$beta)) || any(!is.finite(x$influence)) || N<=p)
      stop('Candidates need reviewed roots, matching parameters, Persons and sampling targets.')
    # These are the already-centered influence contributions for that target.
    groups <- if(x$sampling=='fixed_rosters') split(seq_len(N),x$stratum) else list(seq_len(N))
    if(any(vapply(groups,function(ids) max(abs(colMeans(x$influence[ids,,drop=FALSE])))>
        1e-8*max(1,max(abs(x$influence))),logical(1))))
      stop('Influence contributions must be centered for the stated sampling target.')
  }
  candidates <- candidates[order(orders)]
  pairs <- combn(seq_along(candidates),2,simplify=FALSE)
  detail <- lapply(pairs,function(pair) {
    a <- candidates[[pair[1]]]; b <- candidates[[pair[2]]]
    Va <- crossprod(a$influence)/N^2; Vb <- crossprod(b$influence)/N^2
    cross <- crossprod(a$influence,b$influence)/N^2
    Vdelta <- crossprod(b$influence-a$influence)/N^2
    delta <- b$beta-a$beta
    se <- sqrt(diag(Vdelta)); to_se <- sqrt(diag(Vb))
    paired_ratio <- ifelse(se>0,abs(delta)/se,NA_real_)
    list(from=a$order,to=b$order,covariance=Vdelta,cross_covariance=cross,
      rows=data.frame(FromOrder=a$order,ToOrder=b$order,Parameter=names(delta),
        FromEstimate=unname(a$beta),ToEstimate=unname(b$beta),Difference=unname(delta),
        FromSE=sqrt(diag(Va)),ToSE=to_se,PairedDifferenceSE=se,
        IndependentDifferenceSE=sqrt(diag(Va+Vb)),
        DifferenceOverToSE=ifelse(to_se>0,abs(delta)/to_se,NA_real_),
        DifferenceOverPairedSE=paired_ratio,
        ZeroDifferenceVariance=se==0,row.names=NULL))
  })
  list(summary=do.call(rbind,lapply(detail,`[[`,'rows')),details=detail,
    selected_order=NA_integer_,interpretation='Sensitivity only; residual bias is not identified.')
}

jml_saved_order_candidate <- function(order,beta,A,covariance,ids,reviewed) {
  IF <- do.call(rbind,lapply(seq_along(ids),function(i)
    -t(solve(A,t(covariance$centered[[i]][ids[[i]],,drop=FALSE])))))
  stratum <- rep(seq_along(ids),lengths(ids))
  rownames(IF) <- unlist(lapply(seq_along(ids),function(i) paste(i,seq_along(ids[[i]]),sep=':')))
  parameter <- c('Rater','Criterion','Step1','Step2','LogSlope')
  names(beta) <- parameter; colnames(IF) <- parameter
  if(max(abs(crossprod(IF)/nrow(IF)^2-covariance$vcov))>1e-10)
    stop('Saved covariance and expanded influence disagree.')
  list(order=order,beta=beta,influence=IF,stratum=stratum,
       sampling=covariance$sampling,reviewed=reviewed)
}

run_jml_order_sensitivity <- function(out) {
  if(file.exists(file.path(out,'results.rds'))) stop('Refusing to overwrite evidence.')
  dir.create(out,recursive=TRUE,showWarnings=FALSE)
  input <- 'validation-results/jml-design-adjustment-20260927'
  existing <- readRDS(file.path(input,'results.rds'))
  candidates <- list()
  for(d in c('complete','sparse')) {
    observed <- readRDS(file.path(input,paste0(d,'-observed-patterns.rds')))
    candidates[[d]] <- lapply(c(1L,2L,4L),function(k) {
      record <- existing[[paste(d,'sample',k,sep='-')]]
      fit <- record$attempts[[1]]$fit
      jml_saved_order_candidate(k,fit$beta,fit$A,record$fixed,observed$ids,record$summary$Reviewed)
    })
  }
  unequal <- readRDS(file.path(input,'unequal.rds'))
  repaired <- readRDS(file.path(input,'unequal-followup.rds'))
  candidates$unequal <- lapply(c(1L,4L),function(k) {
    record <- repaired$results[[as.character(k)]]
    jml_saved_order_candidate(k,record$solver$x,record$A,record$covariance,
      unequal$ids,record$summary$Reviewed)
  })
  results <- lapply(candidates,jml_order_sensitivity)
  rows <- do.call(rbind,lapply(names(results),function(d)
    cbind(Design=d,results[[d]]$summary)))
  checks <- c()
  for(d in names(results)) {
    cands <- candidates[[d]]
    for(detail in results[[d]]$details) {
      a <- cands[[which(vapply(cands,`[[`,numeric(1),'order')==detail$from)]]
      b <- cands[[which(vapply(cands,`[[`,numeric(1),'order')==detail$to)]]
      N <- nrow(a$influence)
      reference <- (crossprod(a$influence)+crossprod(b$influence)-
        crossprod(a$influence,b$influence)-crossprod(b$influence,a$influence))/N^2
      checks <- c(checks,max(abs(reference-detail$covariance))<1e-12,
        min(eigen(detail$covariance,symmetric=TRUE)$values)>-1e-12)
    }
    # A common unknown displacement cannot be detected by differences/SEs.
    shifted <- lapply(cands,function(x) {x$beta <- x$beta+c(.2,-.3,.4,-.5,.6); x})
    comparison <- jml_order_sensitivity(shifted)
    columns <- c('Difference','PairedDifferenceSE','DifferenceOverToSE','DifferenceOverPairedSE')
    checks <- c(checks,max(abs(as.matrix(comparison$summary[columns])-
      as.matrix(results[[d]]$summary[columns])))<1e-10,is.na(comparison$selected_order))
    bad <- cands; bad[[2]]$influence <- bad[[2]]$influence[nrow(bad[[2]]$influence):1,,drop=FALSE]
    checks <- c(checks,inherits(try(jml_order_sensitivity(bad),silent=TRUE),'try-error'))
    bad <- cands; bad[[2]]$sampling <- 'random_rosters'
    checks <- c(checks,inherits(try(jml_order_sensitivity(bad),silent=TRUE),'try-error'))
    bad <- cands; bad[[2]]$reviewed <- FALSE
    checks <- c(checks,inherits(try(jml_order_sensitivity(bad),silent=TRUE),'try-error'))
    same <- list(cands[[1]],cands[[1]]); same[[2]]$order <- 2L
    duplicate <- jml_order_sensitivity(same)$summary
    checks <- c(checks,all(duplicate$Difference==0),all(duplicate$PairedDifferenceSE==0),
      all(is.na(duplicate$DifferenceOverPairedSE)))
  }
  # Validate the paired influence directly by perturbing the same data for both orders.
  source('inst/validation/jml-design-adjustment-20260927.R')
  ps <- list(make_jml_roster_problem('Criterion',c(2,1,0,2)),
             make_jml_roster_problem('Criterion',c(0,2,2,1)))
  record <- existing[['sparse-sample-1']]
  weights <- record$weights; prop <- record$proportions
  patterns <- lapply(c(1L,4L),function(k) {
    x <- existing[[paste('sparse','sample',k,sep='-')]]
    -t(solve(x$attempts[[1]]$fit$A,t(x$fixed$centered[[1]])))
  })
  change <- patterns[[2]]-patterns[[1]]
  ix <- which.max(rowSums(change^2)*(weights[[1]]>0))
  direction <- -weights[[1]]; direction[ix] <- direction[ix]+1
  refits <- list()
  for(h in c(1e-5,5e-6)) {
    fitted <- lapply(c(1L,4L),function(k) {
      start <- existing[[paste('sparse','sample',k,sep='-')]]$attempts[[1]]$fit$beta
      lapply(c(-1,1),function(sign) {
        perturbed <- weights; perturbed[[1]] <- perturbed[[1]]+sign*h*direction
        eq <- make_jml_design_equation(ps,perturbed,prop,k)
        jml_design_root(eq,k,start)
      })
    })
    observed <- ((fitted[[2]][[2]]$fit$beta-fitted[[1]][[2]]$fit$beta)-
      (fitted[[2]][[1]]$fit$beta-fitted[[1]][[1]]$fit$beta))/(2*h)
    predicted <- prop[1]*change[ix,]
    error <- max(abs(observed-predicted))/max(1,max(abs(predicted)))
    checks <- c(checks,all(vapply(unlist(fitted,recursive=FALSE),function(x)x$fit$reviewed,logical(1))),error<1e-3)
    refits[[as.character(h)]] <- list(fitted=fitted,error=error,predicted=predicted,observed=observed)
  }
  saveRDS(list(results=results,candidates=candidates,refits=refits,checks=checks),file.path(out,'results.rds'))
  write.csv(rows,file.path(out,'summary.csv'),row.names=FALSE)
  print(rows[rows$Parameter=='LogSlope',],row.names=FALSE)
  writeLines(capture.output(sessionInfo()),file.path(out,'sessionInfo.txt'))
  stopifnot(all(checks))
}
if(sys.nframe()==0L) run_jml_order_sensitivity('validation-results/jml-order-sensitivity-20260927')
