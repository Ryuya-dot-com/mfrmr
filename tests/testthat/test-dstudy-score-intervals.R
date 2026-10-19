score_crossed_d <- function() {
  g <- mfrm_multivariate_gstudy(mfrmr_example_gtheory_crossed, c("Content", "Organization"))
  mfrm_multivariate_d_study(g, data.frame(Raters=c(1,2,4,2), Tasks=c(1,4,8,4)),
    weights=c(Content=.5, Organization=.5))
}

test_that("score intervals preserve points, method scope and saved diagnostics", {
  d <- score_crossed_d(); before <- serialize(d,NULL)
  ci <- confint(d,method="score",assumption="normal")
  point <- subset(summary(d),Kind=="Composite")
  expect_identical(ci$Estimate,point$G);expect_identical(ci$PointStatus,point$GStatus)
  expect_true(all(ci$Available & ci$NumericalComplete & !ci$Empty))
  expect_identical(attr(ci,"diagnostics")[[2]],attr(ci,"diagnostics")[[4]])
  expect_identical(serialize(d,NULL),before)
  expect_true(all(grepl("Experimental",ci$Validation)))
  expect_error(confint(d,method="score"),"normal")
  expect_error(confint(d,method="score",assumption="normal",parm="Phi"),"Unsupported")
  expect_error(confint(d,method="score",assumption="normal",parm="RelativeSEM"),"Unsupported")
  expect_error(confint(d,method="score",assumption="normal",reference=1),"reference")
  # Balanced crossed defaults use MLS; the experimental score method is opt-in.
  expect_identical(confint(d,assumption="normal")$MethodCode,
    rep("mls",nrow(d$design_grid)))
  wide <- confint(d,method="score",assumption="normal",level=.99)
  expect_true(all(wide$Lower <= ci$Lower & wide$Upper >= ci$Upper))
  d$gstudy$data <- NULL
  expect_identical(confint(d,method="score",assumption="normal"),ci)
  for (z in attr(ci,"diagnostics")) {
    expect_true(z$grid_agreement)
    expect_true(z$fine$cutoff_error < 1e-5)
    expect_true(all(vapply(z$profiles,`[[`,logical(1),"valid")))
  }
  g <- mfrm_multivariate_gstudy(mfrmr_example_gtheory_nested,"Content",nesting=c(Rater="Task"))
  expect_error(confint(mfrm_multivariate_d_study(g),method="score",assumption="normal"),"Unsupported")
})

test_that("expected-information score agrees with independent linear coordinates", {
  d <- score_crossed_d(); p <- .mfrm_mvgt_anova_projection(d$gstudy,weights=d$weights)
  error <- c(0,0,0,.5,.25,0,.125);rho <- .45
  f <- .mfrm_mvgt_score_target(p$ms,p$design,error,rho)
  expect_true(f$valid)
  h <- (1-rho)*p$design$A[1,]-rho*drop(error%*%p$design$A)
  aa <- which(h!=0); h <- h[aa]/max(abs(h[aa]));lambda <- f$lambda[aa]
  C <- rbind(h,diag(length(aa))[-which.max(abs(h)),,drop=FALSE]);B<-solve(C)
  S <- p$design$df[aa]*(p$ms[aa]-lambda)/(2*lambda^2)
  score <- drop(crossprod(B,S))
  I <- crossprod(B,diag(p$design$df[aa]/(2*lambda^2))%*%B)
  efficient <- score[1]-drop(I[1,-1,drop=FALSE]%*%solve(I[-1,-1,drop=FALSE],score[-1]))
  expect_equal(unname(efficient^2*solve(I)[1,1]),f$statistic,tolerance=1e-9)
  for(s in c(1e-100,1e100))expect_equal(
    .mfrm_mvgt_score_target(p$ms*s,p$design,error,rho)$statistic,f$statistic,tolerance=1e-6)
  # Two-stratum special case has an analytic null fit and statistic.
  f <- .mfrm_mvgt_score_fit(c(5.4,1),c(9,27),c(1,-2.7))
  lambda2 <- (9*2+27)/36
  expect_equal(f$lambda,c(2.7,1)*lambda2)
  expect_equal(f$statistic,9*27*36/(2*(9*2+27)^2))
})

test_that("empty score sets and zero mean squares remain different states", {
  # Orthogonal raw-score fixture with prescribed ANOVA mean squares;
  # independent of the package's mean-product/component calculation.
  counts <- c(10,2,4);df<-c(9,1,3,9,27,3,27)
  ms <- c(.1,1,1,2,2,.5,1)
  basis <- lapply(counts,function(n){z<-seq_len(n)-mean(seq_len(n));cbind(rep(1/sqrt(n),n),z/sqrt(sum(z^2)))})
  groups <- list(1,2,3,c(1,2),c(1,3),c(2,3),1:3)
  columns <- sapply(groups,function(g)kronecker(basis[[3]][,1+(3%in%g)],
    kronecker(basis[[2]][,1+(2%in%g)],basis[[1]][,1+(1%in%g)])))
  x <- expand.grid(Person=1:10,Rater=1:2,Task=1:4)
  x$Score <- drop(columns%*%sqrt(df*ms))
  g <- mfrm_multivariate_gstudy(x,"Score")
  expect_equal(vapply(g$mean_products,as.numeric,numeric(1)),ms,ignore_attr=TRUE)
  d <- mfrm_multivariate_d_study(g)
  ci <- confint(d,method="score",assumption="normal")
  expect_true(ci$NumericalComplete);expect_true(ci$Empty)
  expect_false(ci$Available);expect_true(is.na(ci$Estimate))
  expect_true(all(is.na(ci[c("Lower","Upper")])));expect_match(ci$Status,"Empty")
  tab <- plot_data(plot(ci,draw=FALSE),"table")
  expect_identical(tab$StatusLabel,"Empty set");expect_true(is.na(tab$Estimate))
  x$Score <- 0
  constant <- mfrm_multivariate_d_study(mfrm_multivariate_gstudy(x,"Score"))
  zero <- confint(constant,method="score",assumption="normal")
  expect_false(zero$NumericalComplete);expect_false(zero$Empty)
  expect_false(zero$Available);expect_match(zero$Status,"Positive mean squares")
})

test_that("score method comparisons and ribbons retain saved values", {
  d <- score_crossed_d()
  ci <- confint(d,method="score",assumption="normal")
  both <- confint(d,method=c("approximate_f","score"),assumption="normal")
  expect_identical(both$MethodCode,rep(c("approximate_f","score"),each=4))
  expect_identical(both$Estimate[5:8],ci$Estimate)
  expect_identical(both$Lower[5:8],ci$Lower)
  forest <- plot(both,draw=FALSE)
  curves <- mfrm_multivariate_d_study(d$gstudy,
    expand.grid(Raters=c(2,4),Tasks=c(3,6,12)),d$weights)
  curve_ci <- confint(curves,method="score",assumption="normal")
  ribbon <- plot(curves,metric="G",intervals=curve_ci,draw=FALSE)
  expect_identical(plot_data(forest,"intervals"),both)
  expect_true(all(is.finite(plot_data(ribbon,"series")$Lower)))
  expect_true(all(table(plot_data(ribbon,"series")$Group)==3))
  other <- mfrm_multivariate_d_study(d$gstudy,d$design_grid,-10*d$weights)
  transformed <- confint(other,method="score",assumption="normal")
  expect_equal(transformed$Lower,ci$Lower,tolerance=1e-6)
  expect_equal(transformed$Upper,ci$Upper,tolerance=1e-6)
  path<-tempfile(fileext=".rds");on.exit(unlink(path),add=TRUE)
  saveRDS(list(ci=ci,forest=forest,ribbon=ribbon),path)
  saved<-readRDS(path);expect_identical(saved$ci,ci)
  skip_if_not_installed("ggplot2")
  local_mocked_bindings(.mfrm_mvgt_score_fit=function(...)stop("Must not recalculate"))
  expect_s3_class(as_ggplot(saved$forest),"ggplot")
  expect_s3_class(as_ggplot(saved$ribbon),"ggplot")
})
