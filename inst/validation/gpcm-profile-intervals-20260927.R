# Independent fixed-vector checks for the two scoped profile intervals.
# Run after pkgload::load_all(compile = FALSE). Reuses stored endpoint searches.
review_gpcm_profile_endpoints <- function(directory, owners = c("shared", "separate")) {
  source('inst/validation/adaptive-quadrature-review-0.2.4.R',local=TRUE)
  fits <- list(shared=readRDS('validation-results/gpcm-probability-refit-20260925/refit-788.rds')$fit,
    separate=readRDS('tests/testthat/fixtures/mfrm-conditional-scoring-gpcm.rds')$fit)
  stopifnot(all(owners %in% names(fits)))
  fits <- fits[owners]
  rows <- list()
  for(owner in names(fits)) {
    fit<-fits[[owner]]; ci<-readRDS(file.path(directory,paste0(owner,'.rds')))
    saved<-attr(ci,'profile'); limits<-saved$endpoints
    cfg<-fit$config; sizes<-mfrmr:::build_param_sizes(cfg)
    idx<-mfrmr:::build_indices(fit$prep,cfg$step_facet,cfg$slope_facet,cfg$interaction_specs)
    points<-list(source=fit$opt$par)
    for(i in seq_len(nrow(limits))) if(limits$Status[i]=='computed') {
      key<-sprintf('%.17g',log(limits$Bound[i]))
      # exp/log round trips can change the last bit of a stored search key.
      keys<-names(saved$attempts); key<-keys[which.min(abs(as.numeric(keys)-log(limits$Bound[i])))]
      attempts<-saved$attempts[[key]]
      best<-which.min(vapply(attempts,function(a)a$check$NLL,0))
      points[[limits$Side[i]]]<-attempts[[best]]$parameters
    }
    for(name in names(points)) {
      path<-file.path(directory,paste0('reference-',owner,'-',name,'.rds'))
      if(file.exists(path)) { rows[[paste(owner,name)]]<-readRDS(path)$row; next }
      cat('Independent reference:',owner,name,'\n');flush.console()
      p<-points[[name]]; pars<-mfrmr:::expand_params(p,sizes,cfg)
      base<-mfrmr:::compute_base_eta(idx,pars,cfg)
      ref<-lapply(c(32,64),function(limit)do.call(rbind,lapply(split(seq_along(idx$person),idx$person),function(obs)
        aq_continuous_reference(idx$score_k[obs],base[obs],pars$steps_mat[idx$step_idx[obs],,drop=FALSE],
          pars$slopes[idx$slope_idx[obs]],idx$weight[obs],unname(pars$population$coefficients[1]),
          sqrt(pars$population$sigma2),limit))))
      ev<-mfrmr:::make_mfrm_direct_evaluator('MML',mfrmr:::make_param_cache(sizes,cfg,idx,is_mml=TRUE),
        idx,cfg,sizes,mfrmr:::gauss_hermite_normal(cfg$estimation_control$quad_points))
      row<-data.frame(Owner=owner,Point=name,NLL=ev$value(p),IndependentNLL=-sum(ref[[2]][,'log_marginal']),
        ReferenceChange=max(abs(ref[[1]][,1:3]-ref[[2]][,1:3])),RelativeError=max(ref[[2]][,'relative_error']),
        LogTailBound=max(ref[[2]][,'log_relative_tail_bound']))
      row$Passed<-all(is.finite(ref[[2]])) && row$ReferenceChange<1e-8 &&
        row$RelativeError<1e-9 && row$LogTailBound<log(1e-12) && abs(row$NLL-row$IndependentNLL)<1e-5
      saveRDS(list(parameters=p,reference=ref,row=row),path)
      rows[[paste(owner,name)]]<-row
    }
  }
  out<-do.call(rbind,rows)
  out$IndependentLR<-NA_real_
  for(owner in names(fits)) {
    i<-out$Owner==owner
    out$IndependentLR[i]<-2*(out$IndependentNLL[i]-out$IndependentNLL[i & out$Point=='source'])
  }
  write.csv(out,file.path(directory,'independent-reference.csv'),row.names=FALSE)
  print(out)
  stopifnot(all(out$Passed),all(abs(out$IndependentLR[out$Point!='source']-qchisq(.95,1))<1e-4))
  invisible(out)
}
