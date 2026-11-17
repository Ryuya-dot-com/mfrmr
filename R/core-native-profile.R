# Normal-population RSM/PCM profiles in the closed residual-variance coordinate.
# Heat-equation derivatives include the finite one-sided variance score at zero.
mfrm_native_profile_design <- function(fit) {
  cfg<-fit$config
  if (!inherits(fit,'mfrm_fit') || inherits(fit,'mfrm_imported_fit') ||
      !cfg$model %in% c('RSM','PCM') || !identical(cfg$method,'MML') ||
      !isTRUE(cfg$population_spec$active) || !is.null(cfg$population_spec$fixed_sd) ||
      length(cfg$interaction_specs) || length(cfg$dummy_facets) ||
      !identical(cfg$noncenter_facet, 'Person') ||
      !identical(cfg$facet_shrinkage,'none'))
    stop('Profile contrasts require native direct RSM/PCM MML with an estimated normal population, unit weights, unanchored centered facets and steps, without interactions or shrinkage.',call.=FALSE)
  mfrm_native_location_source(fit)
  sizes<-build_param_sizes(cfg);slices<-build_param_slices(sizes)
  idx<-build_indices(fit$prep,cfg$step_facet,cfg$slope_facet,cfg$interaction_specs,gpcm_spec=cfg$gpcm_spec)
  p<-length(fit$opt$par);stopifnot(identical(slices$log_sigma2,as.integer(p)))
  built<-mfrmr_estimability_adjacent_design(fit$prep,idx,cfg,sizes,include_person=FALSE,include_population_beta=TRUE)
  M<-matrix(0,ncol(built$design),p-1L)
  M[cbind(seq_len(nrow(M)),built$map$OptimizerIndex)]<-1
  adjacent<-as.matrix(built$design%*%M);n<-length(idx$score_k);K<-cfg$n_cat-1L
  if (qr(adjacent)$rank < ncol(adjacent))
    stop('Profile contrasts require a full-rank conditional location/step/population design.',call.=FALSE)
  increments<-lapply(seq_len(K),function(k)adjacent[seq_len(n)+(k-1L)*n,,drop=FALSE])
  D<-c(list(matrix(0,n,p-1L)),Reduce(`+`,increments,accumulate=TRUE))
  observed<-matrix(0,n,p-1L)
  for(k in 0:K)observed[idx$score_k==k,]<-D[[k+1L]][idx$score_k==k,,drop=FALSE]
  list(D=D,y=idx$score_k,person=idx$person,
    observed=rowsum(observed,idx$person,reorder=TRUE),K=K,p=p,
    integration=list(config=cfg,indices=idx,sizes=sizes),
    source=replace(fit$opt$par,p,exp(fit$opt$par[p])))
}

mfrm_native_profile_likelihood <- function(input,q,adaptive=TRUE) {
  gh<-gauss_hermite_normal(q);D<-input$D;y<-input$y;person<-input$person
  n<-length(y);N<-nrow(input$observed);a<-input$p-1L;K<-input$K
  aggregate<-function(x)rowsum(x,person,reorder=TRUE)
  function(z,hessian=FALSE) {
    v<-z[a+1L];stopifnot(length(z)==a+1L,all(is.finite(z)),v>=0)
    if(v==0) {
      noise<-matrix(0,N,1);log_weights<-matrix(0,N,1)
    } else if(adaptive) {
      # Reuse the normalized Gaussian change of variable, including its weights.
      native<-z;native[a+1L]<-log(v);setup<-input$integration
      params<-expand_params(native,setup$sizes,setup$config)
      basis<-mfrmr_adaptive_quadrature_basis(setup$indices,setup$config,params,gh,
        compute_base_eta(setup$indices,params,setup$config))
      # D already includes the population mean; add only the residual ability.
      noise<-basis$nodes-basis$mu;log_weights<-basis$log_weights
    } else {
      noise<-matrix(sqrt(v)*gh$nodes,N,q,byrow=TRUE)
      log_weights<-matrix(log(gh$weights),N,q,byrow=TRUE)
    }
    Q<-ncol(noise)
    logits<-lapply(0:K,function(k)matrix(drop(D[[k+1L]]%*%z[seq_len(a)]),n,Q)+
      k*noise[person,,drop=FALSE])
    peak<-Reduce(pmax,logits);expz<-lapply(logits,function(x)exp(x-peak));den<-Reduce(`+`,expz)
    prob<-lapply(expz,function(x)x/den);lp<-lapply(logits,function(x)x-peak-log(den))
    ll<-matrix(0,n,Q)
    for(k in 0:K)ll[y==k,]<-lp[[k+1L]][y==k,,drop=FALSE]
    lw<-aggregate(ll)+log_weights;peak<-apply(lw,1,max)
    post<-exp(lw-peak);norm<-rowSums(post);value<--sum(peak+log(norm));post<-post/norm
    mu<-Reduce(`+`,Map(function(p,k)p*k,prob,0:K))
    central<-lapply(0:K,function(k)k-mu)
    variance<-Reduce(`+`,Map(function(p,r)p*r^2,prob,central))
    # Gaussian heat-equation identities integrate exact likelihood derivatives.
    # They do not differentiate the approximate, moving quadrature nodes.
    V<-aggregate(variance);R<-aggregate(y-mu);sv<-.5*(R^2-V)
    ED<-lapply(seq_len(a),function(j)Reduce(`+`,lapply(seq_len(K+1L),function(k)prob[[k]]*D[[k]][,j])))
    sa<-lapply(seq_len(a),function(j)matrix(input$observed[,j],N,Q)-aggregate(ED[[j]]))
    score<-c(sa,list(sv));mean<-vapply(score,function(x)rowSums(post*x),numeric(N))
    gradient<--colSums(mean)
    if(!hessian)return(list(value=value,gradient=gradient))
    H<-crossprod(mean);w<-post[person,,drop=FALSE]
    # Sum over quadrature once, then use weighted cross-products for every pair.
    structural<-Reduce(`+`,lapply(seq_len(K+1L),function(k)
      crossprod(D[[k]],D[[k]]*rowSums(w*prob[[k]]))))
    ED_matrix<-vapply(ED,as.vector,numeric(n*Q))
    sa_matrix<-vapply(sa,as.vector,numeric(N*Q))
    H[seq_len(a),seq_len(a)]<-H[seq_len(a),seq_len(a)]+structural-
      crossprod(ED_matrix,ED_matrix*as.vector(w))-
      crossprod(sa_matrix,sa_matrix*as.vector(post))
    for(j in seq_len(a)) {
      C1<-aggregate(Reduce(`+`,lapply(seq_len(K+1L),function(k)prob[[k]]*central[[k]]*D[[k]][,j])))
      C2<-aggregate(Reduce(`+`,lapply(seq_len(K+1L),function(k)prob[[k]]*central[[k]]^2*D[[k]][,j]))-variance*ED[[j]])
      H[j,a+1L]<-H[a+1L,j]<-H[j,a+1L]-sum(post*(sa[[j]]*sv-R*C1-.5*C2))
    }
    k3<-aggregate(Reduce(`+`,Map(function(p,r)p*r^3,prob,central)))
    k4<-aggregate(Reduce(`+`,Map(function(p,r)p*r^4,prob,central))-3*variance^2)
    H[a+1L,a+1L]<-H[a+1L,a+1L]-sum(post*.25*(R^4-6*R^2*V+3*V^2-4*R*k3-k4))
    list(value=value,gradient=gradient,hessian=(H+t(H))/2)
  }
}

mfrm_native_profile_mapping <- function(p,L=NULL,psi=NULL,zero=FALSE) {
  offset<-numeric(p);free<-seq_len(p)
  if(!is.null(L)){pivot<-which.max(abs(L));free<-setdiff(free,pivot);offset[pivot]<-psi/L[pivot]}
  if(zero)free<-setdiff(free,p)
  B<-diag(p)[,free,drop=FALSE]
  if(!is.null(L))B[pivot,]<--L[free]/L[pivot]
  list(offset=offset,B=B,free=free,vi=match(p,free))
}

mfrm_native_profile_fit <- function(fun,start,L=NULL,psi=NULL,zero=FALSE) {
  mp<-mfrm_native_profile_mapping(length(start),L,psi,zero);B<-mp$B;vi<-mp$vi
  embed<-function(u)mp$offset+drop(B%*%u)
  cache<-NULL;at<-NULL
  evaluate<-function(u) {
    if(!identical(u,at)){cache<<-fun(embed(u));at<<-u}
    list(value=cache$value,gradient=drop(crossprod(B,cache$gradient)))
  }
  err<-function(u,g){if(!is.na(vi)&&u[vi]==0)g[vi]<-min(0,g[vi]);max(abs(g))}
  lower<-rep(-Inf,length(mp$free));if(!is.na(vi))lower[vi]<-0
  opt<-nlminb(start[mp$free],function(u)evaluate(u)$value,function(u)evaluate(u)$gradient,
    lower=lower,control=list(iter.max=600,eval.max=1200,rel.tol=1e-13,x.tol=1e-12))
  u<-opt$par
  for(iter in 1:8) {
    f<-fun(embed(u),TRUE);g<-drop(crossprod(B,f$gradient));H<-crossprod(B,f$hessian%*%B)
    if(err(u,g)<1e-8)break
    active<-seq_along(u);if(!is.na(vi)&&u[vi]==0&&g[vi]>0)active<-setdiff(active,vi)
    h<-H[active,active,drop=FALSE]
    if(min(eigen(h,symmetric=TRUE,only.values=TRUE)$values)<=0)break
    delta<-numeric(length(u));delta[active]<-solve(h,g[active]);accepted<-FALSE
    for(scale in 2^-(0:19)) {
      trial<-u-scale*delta;if(!is.na(vi))trial[vi]<-max(0,trial[vi])
      ff<-evaluate(trial)
      if(ff$value<=f$value+1e-10&&err(trial,ff$gradient)<err(u,g)) {
        u<-trial;accepted<-TRUE;break
      }
    }
    if(!accepted)break
  }
  z<-embed(u);f<-fun(z,TRUE);g<-drop(crossprod(B,f$gradient));H<-crossprod(B,f$hessian%*%B)
  tangent<-seq_along(u);if(!is.na(vi)&&u[vi]==0&&g[vi]>1e-5)tangent<-setdiff(tangent,vi)
  list(par=z,nll=f$value,kkt=err(u,g),min_eigen=min(eigen(H[tangent,tangent,drop=FALSE],symmetric=TRUE,only.values=TRUE)$values),
    variance_score=tail(f$gradient,1),optimizer_status=opt$convergence,optimizer_message=opt$message)
}

mfrm_native_profile_qualify <- function(a,low,high,L=NULL,psi=NULL,zero=FALSE) {
  x<-low(a$par,TRUE);y<-high(a$par,TRUE)
  mp<-mfrm_native_profile_mapping(length(a$par),L,psi,zero);B<-mp$B
  gx<-drop(crossprod(B,x$gradient));gy<-drop(crossprod(B,y$gradient))
  active<-seq_len(ncol(B));vi<-mp$vi
  if(!is.na(vi)&&tail(a$par,1)==0) {
    if(gx[vi]>1e-5&&gy[vi]>1e-5)active<-setdiff(active,vi)
    gx[vi]<-min(gx[vi],0);gy[vi]<-min(gy[vi],0)
  }
  T<-B[,active,drop=FALSE]
  Hx<-crossprod(T,x$hessian%*%T);Hy<-crossprod(T,y$hessian%*%T)
  a$kkt<-max(abs(gx));a$high_kkt<-max(abs(gy))
  a$min_eigen<-min(eigen(Hx,symmetric=TRUE,only.values=TRUE)$values)
  a$high_min_eigen<-min(eigen(Hy,symmetric=TRUE,only.values=TRUE)$values)
  # The contrast map is not orthonormal: qualify curvature after projection.
  a$projected_hessian_error_bound<-ncol(T)*max(abs(Hx-Hy))
  a$quadrature_nll<-abs(x$value-y$value);a$quadrature_score<-max(abs(x$gradient-y$gradient))
  a$quadrature_hessian<-max(abs(x$hessian-y$hessian))
  a$quadrature_pass<-a$quadrature_nll<=1e-6&&a$quadrature_score<=1e-5&&
    a$high_kkt<=1e-5&&a$high_min_eigen>0&&a$min_eigen>a$projected_hessian_error_bound
  a$pass<-a$kkt<=1e-5&&a$min_eigen>0&&a$quadrature_pass
  a
}

mfrm_native_profile_select <- function(low,high,starts,L=NULL,psi=NULL) {
  fits<-lapply(starts,function(s)mfrm_native_profile_qualify(mfrm_native_profile_fit(low,s,L,psi),low,high,L,psi))
  boundary<-lapply(starts[c(1,length(starts))],function(s)
    mfrm_native_profile_qualify(mfrm_native_profile_fit(low,s,L,psi,TRUE),low,high,L,psi,TRUE))
  all<-c(fits,boundary)
  reject<-function(message)stop(structure(list(message=message,call=NULL,
    attempts=fits,boundary=boundary,psi=psi),class=c('mfrm_profile_error','error','condition')))
  if(!all(vapply(all,`[[`,TRUE,'pass'))) {
    qfail<-any(vapply(all,function(z)z$kkt<=1e-5&&z$min_eigen>0&&!z$quadrature_pass,TRUE))
    reject(if(qfail)'quadrature_unresolved' else 'optimization_or_curvature_unresolved')
  }
  if(diff(range(vapply(boundary,`[[`,0.,'nll')))>1e-6)reject('zero_starts_disagree')
  if(diff(range(vapply(fits,`[[`,0.,'nll')))>1e-6)reject('closed_variance_starts_disagree')
  best<-fits[[which.min(vapply(fits,`[[`,0.,'nll'))]]
  if(min(vapply(boundary,`[[`,0.,'nll'))<best$nll-1e-6)reject('boundary_improves_baseline')
  list(selected=best,attempts=fits,boundary=boundary)
}

mfrm_native_profile_search <- function(input,L,level=.95,q=81L) {
  low<-mfrm_native_profile_likelihood(input,q);high<-mfrm_native_profile_likelihood(input,2*q-1)
  source<-input$source;neutral<-numeric(length(source));neutral[length(source)]<-1
  zero<-source;zero[length(zero)]<-0
  full<-mfrm_native_profile_select(low,high,list(source,zero,neutral));b<-full$selected$par
  center<-sum(L*b);baseline<-full$selected$nll;cutoff<-stats::qchisq(level,1)
  H<-low(b,TRUE)$hessian;active<-seq_along(b)
  if(tail(b,1)==0)active<-head(active,-1)
  se<-sqrt(drop(crossprod(L[active],solve(H[active,active,drop=FALSE],L[active]))))
  cache<-list()
  at<-function(psi) {
    key<-sprintf('%.17g',psi)
    if(is.null(cache[[key]])) {
      pt<-mfrm_native_profile_select(low,high,list(b,neutral),L,psi)
      if(pt$selected$nll<baseline-1e-6)stop('profile_improves_baseline',call.=FALSE)
      pt$psi<-psi;pt$lr<-2*(pt$selected$nll-baseline);cache[[key]]<<-pt
    }
    cache[[key]]$lr-cutoff
  }
  reason<-failure<-NULL;ends<-rep(NA_real_,2)
  tryCatch({
    stopifnot(abs(at(center)+cutoff)<=1e-5,is.finite(se),se>0)
    for(side in 1:2) {
      sign<-c(-1,1)[side];step<-se;previous<--cutoff;crossed<-FALSE
      for(j in 1:14) {
        edge<-center+sign*step;value<-at(edge)
        if(value<previous-1e-5)stop('nonmonotone_sampled_profile')
        if(value>=0){crossed<-TRUE;break}
        previous<-value;step<-step*1.6
      }
      if(!crossed)stop('endpoint_bracket_unresolved')
      ends[side]<-uniroot(at,sort(c(center,edge)),tol=1e-9)$root
    }
    for(psi in seq(ends[1],ends[2],length.out=13))at(psi)
    for(sign in c(-1,1)) {
      side<-Filter(function(pt)sign*(pt$psi-center)>=-1e-12,cache)
      order<-order(vapply(side,function(pt)abs(pt$psi-center),0.))
      if(any(diff(vapply(side[order],`[[`,0.,'lr'))< -1e-5))stop('nonmonotone_connected_profile')
    }
    if(max(abs(vapply(ends,at,0.)))>1e-5)stop('endpoint_residual')
  },error=function(e){reason<<-conditionMessage(e);failure<<-if(inherits(e,'mfrm_profile_error'))unclass(e) else list(message=reason)})
  if(!is.null(reason))ends[]<-NA_real_
  list(full=full,estimate=center,lower=ends[1],upper=ends[2],available=is.null(reason),reason=reason,
    cutoff=cutoff,points=cache,quad_points=q,source_nll=low(source)$value,failure=failure)
}

mfrm_native_profile_intervals <- function(fit,facet,contrasts,level,control) {
  input<-mfrm_native_profile_design(fit)
  target<-mfrm_facet_contrasts(fit,facet,contrasts)
  C<-target$contrasts
  if(is.null(contrasts)||nrow(C)!=1L||sum(C==1)!=1L||sum(C== -1)!=1L||any(!C %in% c(-1,0,1)))
    stop('Profile intervals require one explicit pairwise contrast: one +1, one -1 and zeros, with named facet-level columns.',call.=FALSE)
  defaults<-list(quad_points=81L,max_quad_points=321L)
  if(!is.list(control)||(!is.null(names(control))&&anyDuplicated(names(control)))||
      (length(control)&& (is.null(names(control))||any(!names(control)%in%names(defaults)))))
    stop('profile_control accepts quad_points and max_quad_points only.',call.=FALSE)
  defaults[names(control)]<-control
  if(!all(vapply(defaults,function(x)is.numeric(x)&&!is.complex(x)&&!is.object(x)&&
      length(x)==1L&&is.finite(x)&&x>=3&&x==floor(x)&&x%%2==1,TRUE))||
      defaults$max_quad_points<defaults$quad_points)
    stop('Profile quadrature orders must be odd integers >= 3, with max_quad_points >= quad_points.',call.=FALSE)
  sizes<-build_param_sizes(fit$config);slices<-build_param_slices(sizes)
  L<-numeric(input$p);L[slices[[facet]]]<-target$jacobian[1,]
  source_estimate<-sum(L*input$source);attempts<-list();q<-defaults$quad_points
  repeat {
    r<-tryCatch(mfrm_native_profile_search(input,L,level,q),error=function(e)
      list(available=FALSE,reason=conditionMessage(e),quad_points=q,
        failure=if(inherits(e,'mfrm_profile_error'))unclass(e) else list(message=conditionMessage(e))))
    attempts[[length(attempts)+1L]]<-r
    if(isTRUE(r$available)||!identical(r$reason,'quadrature_unresolved')||2*q-1>defaults$max_quad_points)break
    q<-2*q-1
  }
  qualified<-!is.null(r$full);center<-if(qualified)r$estimate else NA_real_
  baseline<-if(qualified)r$full$selected$nll else NA_real_
  estimate<-if(qualified)center else source_estimate
  reason<-if(isTRUE(r$available))'Numerically verified connected profile; sampling coverage unqualified.' else r$reason
  tab<-data.frame(Target=rownames(C),Estimate=estimate,SourceEstimate=source_estimate,
    ProfileEstimate=center,SE=NA_real_,Lower=if(isTRUE(r$available))r$lower else NA_real_,
    Upper=if(isTRUE(r$available))r$upper else NA_real_,
    Status=if(isTRUE(r$available))'available' else 'unavailable',SEEligible=FALSE,
    CIEligible=isTRUE(r$available),CoverageQualified=FALSE,
    PointEstimateBasis=if(qualified)'reoptimized_profile_likelihood' else 'source_fit',
    InferenceReview=reason,SourceNLL=if(qualified)r$source_nll else NA_real_,
    ProfileNLL=baseline,NLLGain=if(qualified)r$source_nll-baseline else NA_real_,
    ProfileResidualVariance=if(qualified)tail(r$full$selected$par,1) else NA_real_)
  checks<-do.call(rbind,lapply(seq_along(attempts),function(i) {
    a<-attempts[[i]];data.frame(Attempt=i,QuadPoints=a$quad_points,CheckQuadPoints=2*a$quad_points-1,
      Available=isTRUE(a$available),Reason=if(isTRUE(a$available))'available' else a$reason)
  }))
  profile<-if(length(r$points))do.call(rbind,lapply(r$points,function(p)
    data.frame(TargetValue=p$psi,LR=p$lr,ResidualVariance=tail(p$selected$par,1),NLL=p$selected$nll))) else
    data.frame(TargetValue=numeric(),LR=numeric(),ResidualVariance=numeric(),NLL=numeric())
  if(nrow(profile))profile<-profile[order(profile$TargetValue),,drop=FALSE]
  caution<-c('Experimental connected profile interval using a chi-square(1) reference; general boundary calibration and finite-sample coverage are unestablished.',
    'All nuisance parameters, including nonnegative residual variance, are reoptimized. SourceEstimate and ProfileEstimate are distinct; the supplied fit is unchanged.',
    'A failed search is unavailable, not an infinite bound. This is not a simultaneous interval or a guarantee of the full confidence set. No Wald SE is supplied.')
  if(!isTRUE(r$available))warning(paste('Profile interval unavailable:',r$reason),call.=FALSE)
  V<-matrix(NA_real_,1,1,dimnames=list(rownames(C),rownames(C)))
  structure(list(table=tab,covariance=V,model_covariance=V,contrasts=C,
    target_jacobian=matrix(L,1,dimnames=list(rownames(C),names(fit$opt$par))),
    settings=list(facet=facet,method='profile',procedure='mml_native_profile_v2',
      integration='adaptive',boundary_integration='exact_zero_variance',
      target='pairwise_location_contrast',level=level,scale='native',
      quad_points=q,check_quad_points=2*q-1,max_quad_points=defaults$max_quad_points,
      cutoff=stats::qchisq(level,1),reference_distribution='chi_square_1_unqualified_at_general_boundaries'),
    checks=checks,profile=profile,profile_attempts=attempts,cautions=caution,
    source=mfrm_native_location_identity(fit),fit=fit),class='mfrm_facet_intervals')
}
