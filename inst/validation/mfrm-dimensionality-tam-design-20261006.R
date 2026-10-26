# Research-only model map for the declared Rater3 x Criterion6 dimensionality
# comparison. Both location facets and each three-step ladder are centered,
# matching native noncenter_facet="Person" with fixed N(0,1).
# This constructs a response model; fitting/integration policies are separate.
wide_dim_tam_design <- function(model, dimensions, interaction = FALSE) {
  stopifnot(length(model)==1L,model %in% c('RSM','PCM'),
    length(dimensions)==1L,dimensions %in% 1:2,
    is.logical(interaction),length(interaction)==1L,!is.na(interaction))
  cells <- expand.grid(Rater=1:3,Criterion=1:6)
  rater <- contr.sum(3);criterion <- contr.sum(6);steps <- contr.sum(3)
  location <- cbind(rater[cells$Rater,],criterion[cells$Criterion,])
  colnames(location) <- c(paste0('Rater:',1:2),paste0('Criterion:',1:5))
  if(interaction){
    h <- expand.grid(Rater=1:2,Criterion=1:5)
    product <- vapply(seq_len(nrow(h)),function(j)
      rater[cells$Rater,h$Rater[j]]*criterion[cells$Criterion,h$Criterion[j]],numeric(18))
    colnames(product) <- paste0('Rater:Criterion:',h$Rater,':',h$Criterion)
    # Native interaction coordinates add to eta. The roadmap's positive
    # severity H is their negative: eta = theta - b - c - H.
    location <- cbind(location,-product)
  }
  ladder <- rbind(0,apply(steps,2,cumsum))
  n_location <- ncol(location);n_step <- if(model=='RSM')2L else 12L
  step_names <- if(model=='RSM')paste0('Step:',1:2) else
    paste0('Step:',rep(1:6,each=2),':',rep(1:2,6))
  item_names <- paste0('R',cells$Rater,':C',cells$Criterion)
  A <- array(0,c(18L,4L,n_location+n_step),
    dimnames=list(item_names,as.character(0:3),c(colnames(location),step_names)))
  for(j in seq_len(n_location))A[,,j] <- -outer(location[,j],0:3)
  for(j in 1:18){
    index <- n_location + if(model=='RSM')1:2 else 2L*(cells$Criterion[j]-1L)+1:2
    A[j,,index] <- -ladder
  }
  dimension <- if(dimensions==1L)rep(1L,18) else 1L+(cells$Criterion>3L)
  Q <- matrix(0,18L,dimensions,dimnames=list(item_names,paste0('D',seq_len(dimensions))))
  Q[cbind(1:18,dimension)] <- 1
  B <- array(0,c(18L,4L,dimensions),dimnames=list(item_names,as.character(0:3),colnames(Q)))
  for(d in seq_len(dimensions))B[,,d] <- outer(Q[,d],0:3)
  list(model=model,dimensions=dimensions,interaction=interaction,cells=cells,
    A=A,B=B,Q=Q,coordinates=dimnames(A)[[3]],
    location_parameters=n_location,step_parameters=n_step,
    beta.fixed=cbind(1L,seq_len(dimensions),0),
    variance.fixed=cbind(seq_len(dimensions),seq_len(dimensions),1),
    covariance_parameters=if(dimensions==2L)1L else 0L,
    identification='Centered Rater and Criterion; centered step ladders; zero latent means and unit marginal variances. In 2D the correlation remains a separate free parameter.')
}
