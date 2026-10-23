adaptive_pattern_problem <- function(model = "GPCM", population = TRUE) {
  d <- expand.grid(Person = paste0("p",1:8), Rater = c("r1","r2"),
    Item = c("i1","i2","i3"), stringsAsFactors = FALSE)
  d$Score <- (match(d$Rater,c("r1","r2")) + match(d$Item,c("i1","i2","i3"))) %% 4
  d$Weight <- c(.5,1,1.5)[match(d$Item,c("i1","i2","i3"))]
  prep <- prepare_mfrm_data(d,"Person",c("Rater","Item"),"Score",weight_col="Weight")
  interactions <- build_facet_interaction_specs(prep,list(c("Rater","Item")),
    min_obs_per_interaction=0)
  pop <- if(population) list(active=TRUE,person_id="Person",
    person_table=data.frame(Person=prep$levels$Person),
    design_matrix=cbind("(Intercept)"=1,X=rep(c(-1,1),each=4))) else NULL
  built <- build_estimation_config(prep,model,"MML",
    if(model!="RSM") "Item",if(model=="GPCM") "Item",
    interaction_specs=interactions,weight_col="Weight",
    facet_signs=c(Rater=1,Item=-1),positive_facets="Rater",
    noncenter_facet="Person",dummy_facets=NULL,
    anchor_df=data.frame(Facet="Rater",Level="r1",Anchor=.3),
    group_anchor_df=NULL,population=pop)
  cfg <- built$config
  cfg$estimation_control <- list(mml_integration="adaptive",quad_points=15L)
  cfg$step_specs <- lapply(cfg$step_specs,function(spec)
    build_step_constraint(3L,anchors=c("2"=.15),scope=spec$scope))
  sizes <- build_param_sizes(cfg)
  idx <- build_indices(prep,cfg$step_facet,cfg$slope_facet,cfg$interaction_specs)
  list(prep=prep,config=cfg,sizes=sizes,idx=idx,
    par=.2*sin(seq_len(sum(unlist(sizes)))))
}

test_that("adaptive reuse preserves weighted constrained objectives, gradients and information", {
  for(model in c("RSM","PCM","GPCM")) for(population in c(FALSE,TRUE)) {
    a <- adaptive_pattern_problem(model,population)
    evaluate <- mfrmr_make_adaptive_mml_evaluator(a$idx,a$config,a$sizes,3L)
    separate <- mfrmr_make_adaptive_mml_evaluator(a$idx,a$config,a$sizes,3L,FALSE)
    groups <- mfrmr_mml_person_design_groups(a$idx,a$config,include_responses=TRUE)
    expected_groups <- if(isTRUE(a$config$population_spec$active) && population) 2L else 1L
    expect_equal(groups$unique_person_designs,expected_groups)
    for(shift in c(0,.17)) {
      par <- a$par+shift
      expect_equal(evaluate(par),separate(par),tolerance=1e-11)
      review <- mfrmr_adaptive_quadrature_review(a$idx,a$config,
        expand_params(par,a$sizes,a$config),list(nodes=0,weights=1),a$prep$levels$Person,3L)
      expect_equal(evaluate(par)$value,-sum(review$AdaptiveLogMarginal),tolerance=1e-11)
    }
    if(model=="GPCM" && population) {
      # Different regression rows still have different derivatives when beta=0
      # makes their current prior means identical.
      par <- a$par; par[build_param_slices(a$sizes)[["beta"]]] <- 0
      expect_equal(evaluate(par),separate(par),tolerance=1e-11)
      h1 <- optimHess(par,function(p)evaluate(p)$value,function(p)evaluate(p)$gradient)
      h2 <- optimHess(par,function(p)separate(p)$value,function(p)separate(p)$gradient)
      expect_equal(h1,h2,tolerance=1e-8)
      h <- 1e-5
      fd <- vapply(seq_along(par),function(j) {
        plus <- minus <- par; plus[j] <- plus[j]+h; minus[j] <- minus[j]-h
        (separate(plus)$value-separate(minus)$value)/(2*h)
      },0)
      expect_equal(evaluate(par)$gradient,fd,tolerance=1e-6)
    }
  }
})

test_that("pattern keys distinguish response, weights, missingness, owners and covariates", {
  a <- adaptive_pattern_problem()
  count <- function(idx=a$idx,cfg=a$config)
    mfrmr_mml_person_design_groups(idx,cfg,include_responses=TRUE)$unique_person_designs
  expect_equal(count(),2L)
  target <- which(a$idx$person==8L)[1]
  changes <- list()
  b <- a$idx; b$score_k[target] <- (b$score_k[target]+1L) %% 4L; changes$response <- b
  b <- a$idx; b$weight[target] <- b$weight[target]+1e-12; changes$weight <- b
  changes$missing <- mfrmr_subset_observation_indices(a$idx,setdiff(seq_along(a$idx$person),target))
  b <- a$idx; b$facets$Rater[target] <- 3L-b$facets$Rater[target]; changes$facet <- b
  b <- a$idx; b$interactions[[1]][target] <- b$interactions[[1]][target] %% 6L+1L; changes$interaction <- b
  b <- a$idx; b$step_idx[target] <- b$step_idx[target] %% 3L+1L; changes$step <- b
  b <- a$idx; b$slope_idx[target] <- b$slope_idx[target] %% 3L+1L; changes$slope <- b
  for(b in changes) {
    expect_equal(count(b),3L)
    expect_equal(mfrmr_make_adaptive_mml_evaluator(b,a$config,a$sizes,7L)(a$par),
      mfrmr_make_adaptive_mml_evaluator(b,a$config,a$sizes,7L,FALSE)(a$par),tolerance=1e-11)
  }
  cfg <- a$config
  cfg$population_spec$design_matrix[cfg$population_spec$person_lookup[8],2] <- 1+1e-12
  expect_equal(count(cfg=cfg),3L)
  expect_equal(mfrmr_make_adaptive_mml_evaluator(a$idx,cfg,a$sizes,7L)(a$par),
    mfrmr_make_adaptive_mml_evaluator(a$idx,cfg,a$sizes,7L,FALSE)(a$par),tolerance=1e-11)
  b <- mfrmr_subset_observation_indices(a$idx,rev(seq_along(a$idx$person)))
  expect_equal(count(b),2L)
  expect_equal(mfrmr_make_adaptive_mml_evaluator(b,a$config,a$sizes,7L)(a$par),
    mfrmr_make_adaptive_mml_evaluator(a$idx,a$config,a$sizes,7L)(a$par),tolerance=1e-11)
  # Multiplicity must not turn independent Persons into repeated observations
  # of a single latent variable.
  independent <- mfrmr_make_adaptive_mml_evaluator(a$idx,a$config,a$sizes,7L)(a$par)
  grouped <- mfrmr_mml_person_design_groups(a$idx,a$config,include_responses=TRUE)
  rows <- unlist(grouped$canonical_rows[grouped$representative_positions],use.names=FALSE)
  b <- mfrmr_subset_observation_indices(a$idx,rows); b$weight <- b$weight*4
  collapsed <- mfrmr_make_adaptive_mml_evaluator(b,a$config,a$sizes,7L)(a$par)
  expect_gt(abs(independent$value-collapsed$value),.01)
})
