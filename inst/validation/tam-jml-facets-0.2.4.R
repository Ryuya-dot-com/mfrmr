# Bounded current-source JML comparison. No MML fitting or external-code patching.
# Run from the package root with TAM and mfrmr loaded in the intended library.
tam_jml_crosscheck_design <- function(model, sparse=FALSE, extreme=FALSE) {
  set.seed(241024)
  cells <- expand.grid(Rater=1:3,Task=1:3)
  theta <- seq(-1.4,1.4,length.out=48)
  steps <- if(model=='PCM') rbind(c(-.7,.2,.5),c(-.4,-.2,.6),c(-1,.3,.7)) else matrix(rep(c(-.7,.1,.6),3),3,byrow=TRUE)
  resp <- matrix(NA_real_,48,9,dimnames=list(sprintf('P%02d',1:48),paste0('C',1:9)))
  for(p in 1:48) for(i in 1:9) {
    eta <- theta[p]-c(-.5,0,.5)[cells$Rater[i]]-c(-.6,.1,.5)[cells$Task[i]]
    logits <- (0:3)*eta-c(0,cumsum(steps[cells$Task[i],]))
    resp[p,i] <- sample(0:3,1,prob=exp(logits-max(logits)))
  }
  if(sparse) for(p in 1:48) resp[p,which((1:9+p)%%4==0)] <- NA
  # Interior-score probes are intentionally conditioned examples, not recovery data.
  for(p in 1:48) {
    ii <- which(!is.na(resp[p,])); s <- sum(resp[p,ii])
    if(s==0) resp[p,ii[1]] <- 1
    if(s==3*length(ii)) resp[p,ii[1]] <- 2
  }
  if(extreme) {resp[1,!is.na(resp[1,])] <- 0; resp[2,!is.na(resp[2,])] <- 3}
  # Negative cumulative difficulty: intercept + centered facets + centered steps.
  ng <- if(model=='PCM') 3L else 1L
  A <- array(0,c(9,4,5+2*ng),dimnames=list(colnames(resp),0:3,
    c('Intercept','R1','R2','T1','T2',paste0('S',1:(2*ng)))))
  cc <- contr.sum(3)
  for(i in 1:9) for(k in 1:3) {
    A[i,k+1,1:5] <- -k*c(1,cc[cells$Rater[i],],cc[cells$Task[i],])
    g <- if(model=='PCM') cells$Task[i] else 1
    A[i,k+1,5+(g-1)*2+1:2] <- -colSums(cc[seq_len(k),,drop=FALSE])
  }
  ij <- which(!is.na(resp),arr.ind=TRUE)
  long <- data.frame(Person=rownames(resp)[ij[,1]],Rater=as.character(cells$Rater[ij[,2]]),
    Task=as.character(cells$Task[ij[,2]]),Score=resp[ij],Weight=1)
  B <- array(rep(rep(0:3,each=9),1),c(9,4,1),
    dimnames=list(colnames(resp),0:3,'Ability'))
  list(resp=resp,A=A,B=B,cells=cells,long=long,index=ij)
}

tam_jml_crosscheck_moments <- function(fit,theta=fit$theta) {
  n <- nrow(fit$resp); I <- ncol(fit$resp); K <- dim(fit$A)[2]
  E <- V <- F <- matrix(NA_real_,n,I); P <- array(NA_real_,c(n,I,K))
  AX <- sapply(seq_len(K),function(k) fit$A[,k,] %*% fit$xsi)
  for(p in seq_len(n)) for(i in seq_len(I)) {
    l <- AX[i,]+fit$B[i,,1]*theta[p]; pr <- exp(l-max(l)); pr <- pr/sum(pr)
    y <- fit$B[i,,1]; e <- sum(pr*y)
    P[p,i,] <- pr; E[p,i] <- e; V[p,i] <- sum(pr*(y-e)^2); F[p,i] <- sum(pr*(y-e)^4)
  }
  list(E=E,V=V,F=F,P=P,AX=AX)
}

run_tam_jml_crosscheck <- function(out) {
  stopifnot(requireNamespace('TAM',quietly=TRUE),requireNamespace('digest',quietly=TRUE))
  if(dir.exists(out)) stop('Refusing to overwrite evidence: ',out)
  dir.create(out,recursive=TRUE)
  writeLines(capture.output(sessionInfo()),file.path(out,'session.txt'))
  source <- c(list.files('R',pattern='[.]R$',full.names=TRUE),
    'inst/validation/tam-jml-facets-0.2.4.R')
  write.csv(data.frame(File=source,SHA256=vapply(source,digest::digest,character(1),file=TRUE,algo='sha256')),
    file.path(out,'source-sha256.csv'),row.names=FALSE)
  functions <- c('tam.jml','tam_jml_version1','tam_jml_version2','tam.jml.fit','tam_jml_wle')
  write.csv(data.frame(Function=functions,SHA256=vapply(functions,function(n) {
    f <- get(n,asNamespace('TAM'));digest::digest(list(formals(f),body(f)),algo='sha256')
  },character(1)),Version=as.character(packageVersion('TAM'))),file.path(out,'tam-functions.csv'),row.names=FALSE)
  results <- fits <- list(); events <- list()
  attempt <- function(label,expr) {
    warns <- character(); start <- proc.time()[['elapsed']]
    value <- tryCatch(withCallingHandlers(force(expr),warning=function(w) {
      warns <<- c(warns,conditionMessage(w));invokeRestart('muffleWarning')
    }),error=identity)
    events[[length(events)+1]] <<- data.frame(Case=label,Seconds=proc.time()[['elapsed']]-start,
      Status=if(inherits(value,'error')) 'error' else 'returned',
      Error=if(inherits(value,'error')) conditionMessage(value) else '',Warnings=paste(warns,collapse='; '))
    value
  }
  control <- list(conv=1e-9,convM=1e-10,Msteps=50,maxiter=800)
  for(model in c('RSM','PCM')) for(scenario in c('complete','sparse','partial_anchor','extreme')) {
    tag <- paste(model,scenario,sep='_'); cat('\nCASE ',tag,'\n')
    d <- tam_jml_crosscheck_design(model,sparse=scenario!='complete',extreme=scenario=='extreme')
    tf <- if(scenario=='partial_anchor') matrix(c(3,-.4),1,2) else NULL
    anchors <- if(is.null(tf)) NULL else data.frame(Facet='Person',Level='P03',Anchor=-.4)
    mf <- attempt(paste0(tag,'_mfrmr'),fit_mfrm(d$long,'Person',c('Rater','Task'),'Score',
      model=model,step_facet=if(model=='PCM') 'Task' else NULL,method='JML',rating_min=0,rating_max=3,
      anchors=anchors,maxit=500,reltol=1e-11,optimizer='BFGS'))
    if(inherits(mf,'error')) next
    dx <- diagnose_mfrm(mf,residual_pca='none',diagnostic_mode='legacy',fit_df_method='both',whexact=FALSE)
    for(mode in c('raw','adjusted','default')) {
      z <- attempt(paste(tag,mode,sep='_'),TAM::tam.jml(d$resp,A=d$A,B=d$B,
        xsi.fixed=matrix(c(1,0),1,2),theta.fixed=tf,bias=mode=='default',
        adj=if(mode=='raw') 0 else .3,verbose=FALSE,control=control))
      fits[[paste(tag,mode,sep='_')]] <- z
      if(inherits(z,'error')) next
      stopifnot(isTRUE(all.equal(unname(z$B),unname(d$B))),
        isTRUE(all.equal(unname(z$A),unname(d$A))))
      mm <- tam_jml_crosscheck_moments(z); actual <- !is.na(d$resp)
      key <- paste(d$long$Person,d$long$Rater,d$long$Task)
      oi <- match(key,paste(dx$obs$Person,dx$obs$Rater,dx$obs$Task))
      expected <- mm$E[d$index]; variance <- mm$V[d$index]
      mp <- mf$facets$person; pi <- match(rownames(d$resp),mp$Person)
      stopifnot(!anyNA(pi))
      score_error <- rowSums((d$resp-mm$E),na.rm=TRUE)
      score_adjusted <- rowSums(mm$E*actual)-as.numeric(z$PersonScores)
      free <- setdiff(1:48,if(is.null(tf)) integer() else tf[,1])
      nativefit <- attempt(paste(tag,mode,'fit',sep='_'),TAM::tam.jml.fit(z,trim_val=Inf))
      di <- match(rownames(d$resp),dx$measures$Level[dx$measures$Facet=='Person'])
      mx <- dx$measures[dx$measures$Facet=='Person',][di,]
      zz <- (d$resp-mm$E)^2/mm$V
      ii <- rowSums((d$resp-mm$E)^2,na.rm=TRUE)/rowSums(mm$V*actual)
      oo <- rowMeans(zz,na.rm=TRUE)
      vin <- rowSums((mm$F-mm$V^2)*actual)/rowSums(mm$V*actual)^2
      vout <- rowSums((mm$F/mm$V^2-1)*actual)/rowSums(actual)^2
      mse <- 1/sqrt(rowSums(mm$V*actual))
      row <- data.frame(Case=tag,Mode=mode,Version=if(is.null(z$version)) 1 else z$version,
        Iterations=z$iter,Obs=nrow(d$long),MeanExposure=mean(rowSums(actual)),
        MaxExpectedDifference=max(abs(expected-dx$obs$Expected[oi])),
        MaxVarianceDifference=max(abs(variance-dx$obs$Var[oi])),
        MaxPersonDifference=max(abs(z$theta-mp$Estimate[pi])),
        MaxPersonWLEDifference=max(abs(z$WLE-z$theta)),
        MaxFreeScoreResidual=max(abs(score_error[free])),
        MaxAdjustedScoreResidual=max(abs(score_adjusted[free])),
        AnchorError=if(is.null(tf)) NA_real_ else z$theta[3]+.4,
        PrimarySEAvailable=sum(is.finite(mp$SE[pi])),
        PersonSEvsConditional=max(abs(mx$ModelSE[free]-mse[free])),
        WLESEvsMLEInformation=max(abs(z$errorWLE[free]-mse[free])),
        InfitVsMfrmr=max(abs(nativefit$fit.person$infitPerson-mx$Infit)),
        OutfitVsMfrmr=max(abs(nativefit$fit.person$outfitPerson-mx$Outfit)),
        TAMInfitFormulaError=max(abs(nativefit$fit.person$infitPerson-ii)),
        TAMOutfitFormulaError=max(abs(nativefit$fit.person$outfitPerson-oo)),
        TAMInfitZFormulaError=max(abs(nativefit$fit.person$infitPerson_t-((ii^(1/3)-1)*3/sqrt(vin)+sqrt(vin)/3))),
        TAMOutfitZFormulaError=max(abs(nativefit$fit.person$outfitPerson_t-((oo^(1/3)-1)*3/sqrt(vout)+sqrt(vout)/3))))
      results[[length(results)+1]] <- row
    }
    fits[[paste0(tag,'_source')]] <- list(data=d,fit=mf,diagnostics=dx)
    saveRDS(fits,file.path(out,'fits.rds')); write.csv(do.call(rbind,results),file.path(out,'comparison.csv'),row.names=FALSE)
    write.csv(do.call(rbind,events),file.path(out,'execution.csv'),row.names=FALSE)
  }
  invisible(list(fits=fits,comparison=do.call(rbind,results),execution=do.call(rbind,events)))
}

# Match the FACETS Person-anchor origin: noncenter Rater, centered Task.
# In TAM's contrast design the free intercept carries the Rater mean; fixing
# that intercept as in the earlier runner would impose an extra restriction.
run_tam_jml_anchor_origin_check <- function(out, xsi_fixed=NULL) {
  if(dir.exists(out)) stop('Refusing to overwrite evidence: ',out)
  dir.create(out,recursive=TRUE)
  writeLines(capture.output(sessionInfo()),file.path(out,'session.txt'))
  native <- read.csv('tests/testthat/fixtures/facets-anchor-origin.csv')
  fits <- results <- list()
  for(model in c('RSM','PCM')) {
    d <- tam_jml_crosscheck_design(model,sparse=TRUE)
    mf <- fit_mfrm(d$long,'Person',c('Rater','Task'),'Score',model=model,
      step_facet=if(model=='PCM') 'Task' else NULL,method='JML',rating_min=0,rating_max=3,
      anchors=data.frame(Facet='Person',Level='P03',Anchor=-.4),
      noncenter_facet='Rater',centering_scope='anchor_origin',
      optimizer='BFGS',maxit=500,reltol=1e-11)
    z <- TAM::tam.jml(d$resp,A=d$A,B=d$B,theta.fixed=matrix(c(3,-.4),1,2),
      xsi.fixed=xsi_fixed,
      bias=FALSE,adj=0,verbose=FALSE,
      control=list(conv=1e-9,convM=1e-10,Msteps=50,maxiter=800))
    stopifnot(isTRUE(all.equal(unname(z$B),unname(d$B))),
      isTRUE(all.equal(unname(z$A),unname(d$A))))
    mm <- tam_jml_crosscheck_moments(z)
    dx <- diagnose_mfrm(mf,residual_pca='none',diagnostic_mode='legacy')
    ti <- c(z$theta,drop(contr.sum(3) %*% z$xsi[2:3])+z$xsi[1],
      drop(contr.sum(3) %*% z$xsi[4:5]))
    pa <- mfrmr:::expand_params(mf$opt$par,mfrmr:::build_param_sizes(mf$config),mf$config)
    mi <- c(pa$theta,pa$facets$Rater,pa$facets$Task)
    ref <- native[native$Model==model,]
    oi <- match(paste(d$long$Person,d$long$Rater,d$long$Task),
      paste(dx$obs$Person,dx$obs$Rater,dx$obs$Task))
    keys <- paste(rep(c('Person','Rater','Task'),c(48,3,3)),
      c(rownames(d$resp),as.character(1:3),as.character(1:3)))
    ni <- match(keys,paste(ref$Facet,ref$Level))
    stopifnot(!anyNA(oi),!anyNA(ni))
    # Independently differentiate the returned category probabilities.
    gradient <- rep(0,length(z$xsi)); loglik <- 0
    for(j in seq_len(nrow(d$index))) {
      p <- d$index[j,1]; i <- d$index[j,2]; y <- d$resp[p,i]
      gradient <- gradient+d$A[i,y+1,]-drop(mm$P[p,i,] %*% d$A[i,,])
      loglik <- loglik+log(mm$P[p,i,y+1])
    }
    row <- data.frame(Model=model,TAMVersion=as.character(packageVersion('TAM')),
      MaxTAMMfrmr=max(abs(ti-mi)),MaxNativeMfrmr=max(abs(ref$Native[ni]-mi)),
      MaxNativeTAM=max(abs(ref$Native[ni]-ti)),
      MaxExpectedDifference=max(abs(mm$E[d$index]-dx$obs$Expected[oi])),
      MaxTAMGradient=max(abs(c(gradient,rowSums(d$resp-mm$E,na.rm=TRUE)[-3]))),
      NLLDifference=abs(-loglik-mf$opt$value),TAMIterations=z$iter,
      TAMPersonAnchor=z$theta[3],TAMPersonMean=mean(z$theta),
      EmptyFixedXsi=!is.null(xsi_fixed) && nrow(xsi_fixed)==0L)
    fits[[model]] <- list(data=d,mfrmr=mf,tam=z,diagnostics=dx)
    results[[model]] <- row
    saveRDS(fits,file.path(out,'fits.rds'))
    write.csv(do.call(rbind,results),file.path(out,'comparison.csv'),row.names=FALSE)
    print(row)
    stopifnot(row$MaxTAMMfrmr<1e-4,row$MaxNativeMfrmr<1e-4,
      row$MaxNativeTAM<1e-4,row$MaxExpectedDifference<1e-4,
      row$MaxTAMGradient<1e-4,row$NLLDifference<1e-7)
  }
  invisible(list(fits=fits,comparison=do.call(rbind,results)))
}
