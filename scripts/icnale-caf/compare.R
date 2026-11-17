# Local exploratory comparisons for the four declared ICNALE models.
# Source preprocess.R first. No corpus-derived output belongs in the repository.

icnale_probabilities <- function(fit, contexts, theta) {
  icnale_require(inherits(fit,'mfrm_fit') && fit$config$method=='MML' &&
    fit$config$model %in% c('RSM','PCM','GPCM') && fit$config$n_cat==11L &&
    setequal(fit$config$facet_names,c('Rater','Criterion')) &&
    !length(fit$config$interaction_specs), 'Use a declared CAF MML model.')
  icnale_require(length(theta)==nrow(contexts) && all(is.finite(theta)),
    'Supply one finite ability per context.')
  offset <- rep(0,nrow(contexts)); slope <- rep(1,nrow(contexts))
  for(owner in c('Rater','Criterion')) {
    tab <- fit$facets$others[fit$facets$others$Facet==owner,]
    offset <- offset+tab$Estimate[match(contexts[[owner]],tab$Level)]
    if(fit$config$model=='GPCM' && owner %in% fit$config$slope_facet) {
      tab <- fit$slopes
      if('SlopeOwner' %in% names(tab)) tab <- tab[tab$SlopeOwner==owner,]
      slope <- slope*tab$Estimate[match(contexts[[owner]],tab$SlopeFacet)]
    }
  }
  step <- fit$steps
  if(fit$config$model=='RSM') step$StepFacet <- 'shared'
  scopes <- unique(step$StepFacet)
  cumulative <- t(vapply(scopes,function(scope) {
    block <- step[step$StepFacet==scope,]
    block <- block[order(as.integer(sub('Step_','',block$Step))),]
    icnale_require(nrow(block)==10L,'Expected all ten modeled steps.')
    c(0,cumsum(block$Estimate))
  },numeric(11)))
  scope <- if(fit$config$model=='RSM') rep(1L,nrow(contexts)) else match(contexts$Criterion,scopes)
  logits <- (outer(theta-offset,0:10)-cumulative[scope,,drop=FALSE])*slope
  icnale_require(all(is.finite(logits)) && all(slope>0),'Missing or invalid fitted coordinates.')
  probability <- exp(logits-apply(logits,1,max))
  probability/rowSums(probability)
}

icnale_comparison_data <- function(fits) {
  icnale_require(identical(names(fits),c('RSM','PCM','GPCM1','GPCM2')),
    'Supply the four named, successful fits in the declared order.')
  keys <- function(d) paste(d$Person,d$Rater,d$Criterion,d$Score,sep='|')
  original <- sort(keys(fits[[1]]$prep$data))
  tables <- lapply(names(fits),function(name) {
    f <- fits[[name]]; d <- f$prep$data
    icnale_require(identical(sort(keys(d)),original) && all(d$Weight==1),
      'Compare exactly the same retained ratings with unit weights.')
    icnale_require(identical(f$opt$optimizer_diagnostics$ConvergenceSeverity,'pass'),
      'Resolve numerical convergence before comparing points.')
    if(name=='GPCM2') icnale_require(isTRUE(f$config$gpcm_point_estimation$overview$PrimaryAvailable),
      'Two-family primary estimates must be available.')
    mu <- if(isTRUE(f$population$active)) unname(f$population$coefficients[1]) else 0
    sd <- if(isTRUE(f$population$active)) sqrt(f$population$sigma2) else 1
    person <- f$facets$person
    locations <- as.data.frame(f$facets$others[c('Facet','Level','Estimate')])
    # Origin shift belongs to Criterion; Rater and step offsets only rescale.
    locations$Measure <- (locations$Estimate-ifelse(locations$Facet=='Criterion',mu,0))/sd
    writer <- data.frame(Facet='Person',Level=person$Person,Estimate=person$Estimate,
      Measure=(person$Estimate-mu)/sd)
    probabilities <- icnale_probabilities(f,d,person$Estimate[match(d$Person,person$Person)])
    expected <- drop(probabilities%*%0:10)
    variance <- rowSums(probabilities*(rep(0:10,each=nrow(d))-expected)^2)
    icnale_require(all(variance>0),'Positive conditional rating variance is required.')
    residual2 <- (d$Score-expected)^2
    pathway <- do.call(rbind,lapply(split(seq_len(nrow(d)),d$Rater),function(i)
      data.frame(Level=as.character(d$Rater[i[1]]),Ratings=length(i),
        Infit=sum(residual2[i])/sum(variance[i]),Outfit=mean(residual2[i]/variance[i]))))
    pathway$Measure <- locations$Measure[match(pathway$Level,locations$Level)]
    grid <- expand.grid(Z=seq(-2,2,length.out=81),Rater=sort(unique(d$Rater)),
      Criterion=sort(unique(d$Criterion)),stringsAsFactors=FALSE)
    grid$ExpectedScore <- drop(icnale_probabilities(f,grid,mu+sd*grid$Z)%*%0:10)
    list(model=name,mu=mu,sd=sd,locations=rbind(writer,locations),pathway=pathway,
      curves=aggregate(ExpectedScore~Z+Criterion,grid,mean),probabilities=probabilities)
  })
  names(tables) <- names(fits)
  tables
}

icnale_comparison_plots <- function(fits) {
  tables <- icnale_comparison_data(fits)
  bind <- function(part) do.call(rbind,lapply(names(tables),function(name) {
    x<-tables[[name]][[part]];x$Model<-factor(name,levels=names(tables));x
  }))
  locations<-bind('locations');pathway<-bind('pathway');curves<-bind('curves')
  colors<-c(RSM='#0072B2',PCM='#009E73',GPCM1='#D55E00',GPCM2='#CC79A7')
  base<-ggplot2::theme_minimal(base_size=13)
  wright<-ggplot2::ggplot(locations,ggplot2::aes(Facet,Measure,color=Model))+
    ggplot2::geom_point(position=ggplot2::position_jitter(width=.16,height=0,seed=11),alpha=.6,size=1.6)+
    ggplot2::facet_wrap(~Model,nrow=1)+ggplot2::geom_hline(yintercept=0,color='grey75')+
    ggplot2::labs(x=NULL,y='Location in population SD units')+base+
    ggplot2::theme(legend.position='none')+ggplot2::scale_color_manual(values=colors)
  fit_map<-ggplot2::ggplot(pathway,ggplot2::aes(Infit,Measure,color=Model))+
    ggplot2::geom_point(alpha=.75,size=1.8)+ggplot2::facet_wrap(~Model,nrow=1)+
    ggplot2::labs(x='Conditional EAP plug-in Infit MnSq (descriptive)',y='Rater location in population SD units')+
    base+ggplot2::theme(legend.position='none')+ggplot2::scale_color_manual(values=colors)
  expected<-ggplot2::ggplot(curves,ggplot2::aes(Z,ExpectedScore,color=Model))+
    ggplot2::geom_line(linewidth=.9)+ggplot2::facet_wrap(~Criterion,nrow=1)+
    ggplot2::labs(x='Ability in population SD units',y='Mean expected score')+
    base+ggplot2::theme(legend.position='bottom')+ggplot2::scale_color_manual(values=colors)
  thresholds<-do.call(rbind,lapply(names(fits),function(name) {
    f<-fits[[name]];scale<-tables[[name]];c<-f$facets$others[f$facets$others$Facet=='Criterion',]
    do.call(rbind,lapply(seq_len(nrow(c)),function(j) {
      s<-if(name=='RSM') f$steps else f$steps[f$steps$StepFacet==c$Level[j],]
      data.frame(Model=name,Criterion=c$Level[j],Step=as.integer(sub('Step_','',s$Step)),
        Threshold=(c$Estimate[j]+s$Estimate-scale$mu)/scale$sd)
    }))
  }))
  thresholds$Model<-factor(thresholds$Model,levels=names(fits))
  steps<-ggplot2::ggplot(thresholds,ggplot2::aes(Step,Threshold,color=Model,group=Model))+
    ggplot2::geom_line(linewidth=.7)+ggplot2::geom_point(size=2)+ggplot2::facet_wrap(~Criterion,nrow=1)+
    ggplot2::scale_x_continuous(breaks=1:10)+ggplot2::labs(x='Upper score in adjacent-category transition',
      y='Category boundary in population SD units')+base+ggplot2::theme(legend.position='bottom')+
    ggplot2::scale_color_manual(values=colors)
  list(data=list(models=tables,locations=locations,pathway=pathway,curves=curves,thresholds=thresholds),
    plots=list(wright=wright,pathway=fit_map,expected=expected,thresholds=steps),
    notes=c('Point-only location comparison; no standardized confidence intervals are implied.',
      'Category boundaries condition on Rater location zero; expected scores average the same raters equally.',
      'Pathway statistics condition on saved EAPs. They are descriptive, with no calibrated acceptance band or rater-quality verdict.',
      'These workflow figures do not extend plot.mfrm_fit() support to two-family GPCM.'))
}
