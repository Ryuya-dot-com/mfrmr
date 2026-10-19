mvgt_interval_tasks <- function() {
  path <- test_path("..", "..", "inst", "extdata", "mgenova-table12.csv")
  if (!file.exists(path)) path <- system.file("extdata", "mgenova-table12.csv", package = "mfrmr")
  read.csv(path)
}

test_that("one-facet G intervals equal direct ANOVA F inversion and count transformation", {
  data <- mvgt_interval_tasks()
  data$Weighted <- (data$V + data$W)/2
  g <- mfrm_multivariate_gstudy(data, c("V", "W"), rater = NULL)
  d <- mfrm_multivariate_d_study(g, data.frame(Tasks = c(1, 6, 12, 60)),
    weights = c(V=.5,W=.5))
  ci <- confint(d, assumption = "normal")
  # Independent ANOVA implementation on the directly weighted observed scores.
  fit <- aov(Weighted ~ factor(Person) + factor(Task), data = data)
  tab <- summary(fit)[[1L]]
  f <- tab[1L, "Mean Sq"] / tab[3L, "Mean Sq"]
  df <- tab[c(1L,3L), "Df"]
  lower <- max(0, 1 - qf(.975, df[1], df[2])/f)
  upper <- 1 - qf(.025, df[1], df[2])/f
  # Spearman-Brown here follows from the common variance ratio, not an
  # assumption that adding future tasks increases the source information.
  transform <- function(g, multiple) multiple*g / (1+(multiple-1)*g)
  expect_equal(ci$Lower, transform(lower, c(1,6,12,60)/6))
  expect_equal(ci$Upper, transform(upper, c(1,6,12,60)/6))
  expect_equal(ci$Estimate, subset(d$coefficients, Kind == "Composite")$G)
  expect_equal(ci$RawRatioLower, rep(f/qf(.975,df[1],df[2]),4))
  expect_equal(ci$RawRatioUpper, rep(f/qf(.025,df[1],df[2]),4))
  expect_equal(attr(ci,"pivot")$df, df)
  expect_identical(ci$Score, rep("Composite",4))
  more <- confint(d, assumption = "normal", level = .99)
  expect_true(all(more$Lower <= ci$Lower & more$Upper >= ci$Upper))
  expect_identical(attr(more,"pivot")$df, attr(ci,"pivot")$df)
  direct <- mfrm_multivariate_d_study(mfrm_multivariate_gstudy(data,"Weighted",rater=NULL),d$design_grid)
  expect_equal(confint(direct,assumption="normal")$Lower, ci$Lower)
  expect_equal(confint(direct,assumption="normal")$Upper, ci$Upper)
})

test_that("score and named-composite selection preserve weights and saved replay", {
  data <- mvgt_interval_tasks()
  g <- mfrm_multivariate_gstudy(data, c("V","W"), rater=NULL)
  weights <- cbind(Average=c(V=.5,W=.5), Difference=c(V=1,W=-1))
  d <- mfrm_multivariate_d_study(g, data.frame(Tasks=c(3,6,12)),weights)
  expect_error(confint(d,assumption="normal"), "Select one")
  ci <- confint(d,composite="Difference",assumption="normal")
  data$Difference <- data$V-data$W
  direct <- mfrm_multivariate_d_study(mfrm_multivariate_gstudy(data,"Difference",rater=NULL),d$design_grid)
  other <- confint(direct,assumption="normal")
  expect_equal(ci$Lower,other$Lower); expect_equal(ci$Upper,other$Upper)
  expect_equal(attr(ci,"weights"), c(V=1,W=-1))
  score <- confint(d,score="V",assumption="normal")
  expect_equal(score$Estimate, subset(d$coefficients, Kind=="Score" & Score=="V")$G)
  original <- d
  path <- tempfile(fileext=".rds"); on.exit(unlink(path),add=TRUE)
  saveRDS(d,path); saved<-readRDS(path); saved$gstudy$data<-NULL
  expect_identical(confint(saved,composite="Difference",assumption="normal"),ci)
  expect_identical(d,original)
  saveRDS(ci,path); expect_identical(readRDS(path),ci)
  scaled <- mfrm_multivariate_d_study(g,d$design_grid,-10*weights)
  expect_equal(confint(scaled,composite="Difference",assumption="normal")$Lower,ci$Lower)
  expect_equal(confint(scaled,composite="Difference",assumption="normal")$Upper,ci$Upper)
})

test_that("ratio-space intersection precedes transformation and retains boundary evidence", {
  n<-10; k<-6
  p<-qr.Q(qr(contr.helmert(n))); t<-qr.Q(qr(contr.helmert(k)))
  # Independent orthogonal vectors give Person MS = .5 and residual MS = 1.
  y<-outer(p[,1]*sqrt(.5*(n-1)/k),rep(1,k)) +
    sqrt((n-1)*(k-1))*outer(p[,2],t[,1])
  data<-expand.grid(Person=1:n,Task=1:k); data$Score<-as.vector(y)
  g<-mfrm_multivariate_gstudy(data,"Score",rater=NULL)
  d<-mfrm_multivariate_d_study(g,data.frame(Tasks=c(6,60)))
  ci<-confint(d,assumption="normal")
  expect_true(all(is.na(ci$Estimate)))
  expect_true(all(ci$PointStatus=="Negative universe variance"))
  expect_equal(ci$Lower,c(0,0));expect_true(all(ci$Upper>0 & ci$Upper<=1))
  expect_true(all(ci$RawRatioLower<.9 & ci$RawRatioUpper>.9))
  expect_identical(ci$Status,rep("Includes zero",2))
  # The second plan's transformation has a pole at R = .9, inside the raw
  # ratio interval. Clipping already-transformed endpoints would fail here.
  data<-expand.grid(Person=1:3,Task=1:3)
  data$Score<-as.vector(outer(c(-1,0,1),c(-1,0,1)))
  empty<-confint(mfrm_multivariate_d_study(mfrm_multivariate_gstudy(data,"Score",rater=NULL)),assumption="normal")
  expect_true(is.na(empty$Lower) && is.na(empty$Upper))
  expect_identical(empty$Status,"Empty parameter-space interval")
  expect_lt(empty$RawRatioUpper,1)
  data$Score<-data$Person
  zero<-confint(mfrm_multivariate_d_study(mfrm_multivariate_gstudy(data,"Score",rater=NULL)),assumption="normal")
  expect_equal(zero$Estimate,1)
  expect_true(is.na(zero$Lower) && is.na(zero$Upper))
  expect_identical(zero$Status,"Zero residual mean square")
})

test_that("one-facet G inference refuses unsupported targets, designs and altered summaries", {
  g<-mfrm_multivariate_gstudy(mvgt_interval_tasks(),c("V","W"),rater=NULL)
  d<-mfrm_multivariate_d_study(g)
  expect_error(confint(d),"assumption")
  expect_error(confint(d,assumption="normal",parm="SEM"),"one of")
  expect_error(confint(d,assumption="normal",level=1),"level")
  expect_error(confint(d,assumption="normal",score="Other"),"Select one")
  expect_error(confint(d,assumption="normal",score="V",composite="Other"),"either")
  expect_error(confint(d,assumption="normal",extra=TRUE),"must be empty")
  g0<-mfrm_multivariate_gstudy(mvgt_interval_tasks(),c("V","W"),rater=NULL,method="minque0")
  expect_error(confint(mfrm_multivariate_d_study(g0),assumption="normal"),"ANOVA")
  bad<-d;bad$gstudy$degrees_of_freedom$DF[1]<-8
  expect_error(confint(bad,assumption="normal"),"degrees of freedom")
  bad<-d;bad$gstudy$mean_products<-NULL
  expect_error(confint(bad,assumption="normal"),"matrices")
  data("mfrmr_example_gtheory_crossed",package="mfrmr")
  two<-mfrm_multivariate_gstudy(mfrmr_example_gtheory_crossed,c("Content","Organization"))
  expect_error(confint(mfrm_multivariate_d_study(two),assumption="normal",method="exact_f"),"Unsupported")
  nested<-mfrm_multivariate_gstudy(mfrmr_example_gtheory_crossed,c("Content","Organization"),nesting=c(Rater="Task"))
  expect_s3_class(confint(mfrm_multivariate_d_study(nested),assumption="normal"),"mfrm_dstudy_intervals")
  expect_error(confint(mfrm_multivariate_d_study(nested,data.frame(Raters=1,Tasks=6)),assumption="normal"),"child count per parent")
})

test_that("Phi matches the corrected published generalized pivot and future-count identity", {
  data <- mvgt_interval_tasks()
  data$Weighted <- (data$V+data$W)/2
  g <- mfrm_multivariate_gstudy(data,c("V","W"),rater=NULL)
  counts <- c(1,6,12)
  d <- mfrm_multivariate_d_study(g,data.frame(Tasks=counts),weights=c(V=.5,W=.5))
  # Independent raw-score ANOVA and unsimplified Eq. 11 (Mondal et al., 2025).
  a <- summary(aov(Weighted~factor(Person)+factor(Task),data))[[1L]]
  n <- 10; k <- 6; B <- 100000
  set.seed(27)
  f <- rchisq(B,k-1); p <- rchisq(B,n-1); e <- rchisq(B,(n-1)*(k-1))
  z <- pmax(0,(n-1)*a[1,"Mean Sq"]/(k*p)-(n-1)*(k-1)*a[3,"Mean Sq"]/(k*e)) /
    ((k-1)*a[2,"Mean Sq"]/(n*f)+(n-1)*a[1,"Mean Sq"]/(k*p)+
       (n*k-n-k+1)*(n*k-n-k)*a[3,"Mean Sq"]/(n*k*e))
  bounds <- quantile(z,c(.025,.975),names=FALSE)
  # Published author's ci.GCI() with the same seed and data: retained oracle.
  expect_equal(bounds,c(.02752522,.54810188),tolerance=1e-8)
  transform <- function(r) counts*r/(1+(counts-1)*r)
  seed_before <- .Random.seed
  ci <- confint(d,parm="Phi",assumption="normal",seed=27)
  expect_identical(.Random.seed,seed_before)
  expect_equal(ci$Lower,transform(bounds[1]),tolerance=1e-12)
  expect_equal(ci$Upper,transform(bounds[2]),tolerance=1e-12)
  expect_equal(ci$Estimate,subset(d$coefficients,Kind=="Composite")$Phi)
  expect_identical(ci$PointStatus,subset(d$coefficients,Kind=="Composite")$PhiStatus)
  expect_equal(attr(ci,"pivot")$df,c(9,5,45))
  expect_true(all(is.na(ci$RawRatioLower)))
  expect_identical(ci$Method,rep("Generalized CI under normal effects",3))
  mc <- attr(ci,"monte_carlo")
  expect_equal(mc$zero_proportion,mean(z==0))
  # For continuous quantiles, binomial rank bands have >=95% probability;
  # ties at zero can make them conservative.
  for (prob in c(.025,.975)) {
    lo<-qbinom(.025,B,prob);hi<-qbinom(.975,B,prob)+1
    expect_gte(pbinom(hi-1,B,prob)-pbinom(lo-1,B,prob),.95)
  }
  expect_true(all(mc$endpoint_bands$LowerMCLower<=ci$Lower & mc$endpoint_bands$LowerMCUpper>=ci$Lower))
  expect_true(all(mc$endpoint_bands$UpperMCLower<=ci$Upper & mc$endpoint_bands$UpperMCUpper>=ci$Upper))
  direct<-mfrm_multivariate_d_study(mfrm_multivariate_gstudy(data,"Weighted",rater=NULL),d$design_grid)
  expect_equal(confint(direct,parm="Phi",assumption="normal",seed=27)$Lower,ci$Lower)
  expect_equal(confint(direct,parm="Phi",assumption="normal",seed=27)$Upper,ci$Upper)
  path<-tempfile(fileext=".rds");on.exit(unlink(path),add=TRUE)
  d$gstudy$data<-NULL;saveRDS(d,path)
  expect_identical(confint(readRDS(path),parm="Phi",assumption="normal",seed=27),ci)
  saveRDS(ci,path);expect_identical(readRDS(path),ci)
})

test_that("Phi preserves signed-composite meaning, scaling and the absence of an RNG seed", {
  data<-mvgt_interval_tasks();data$Difference<-data$V-data$W
  g<-mfrm_multivariate_gstudy(data,c("V","W"),rater=NULL)
  w<-cbind(Average=c(V=.5,W=.5),Difference=c(V=1,W=-1))
  d<-mfrm_multivariate_d_study(g,data.frame(Tasks=c(3,6,12)),weights=w)
  ci<-confint(d,parm="Phi",composite="Difference",assumption="normal",draws=4000)
  direct<-mfrm_multivariate_d_study(mfrm_multivariate_gstudy(data,"Difference",rater=NULL),d$design_grid)
  other<-confint(direct,parm="Phi",assumption="normal",draws=4000)
  expect_equal(ci$Lower,other$Lower);expect_equal(ci$Upper,other$Upper)
  scaled<-mfrm_multivariate_d_study(g,d$design_grid,-1e6*w)
  expect_equal(confint(scaled,parm="Phi",composite="Difference",assumption="normal",draws=4000)$Lower,ci$Lower)
  expect_equal(confint(scaled,parm="Phi",composite="Difference",assumption="normal",draws=4000)$Upper,ci$Upper)
  expect_error(confint(d,parm="Phi",assumption="normal"),"Select one")
  old<-.Random.seed;on.exit(assign(".Random.seed",old,.GlobalEnv),add=TRUE)
  rm(".Random.seed",envir=.GlobalEnv)
  invisible(confint(direct,parm="Phi",assumption="normal",draws=4000))
  expect_false(exists(".Random.seed",envir=.GlobalEnv,inherits=FALSE))
})

test_that("Phi distinguishes numerical controls, negative point estimates and degenerate input", {
  n<-10;k<-6;p<-qr.Q(qr(contr.helmert(n)));t<-qr.Q(qr(contr.helmert(k)))
  # Orthogonal effects with MS_P=.5, MS_F=1 and MS_E=1.
  y<-outer(p[,1]*sqrt(.5*(n-1)/k),rep(1,k)) +
    outer(rep(1,n),t[,2]*sqrt((k-1)/n)) + sqrt((n-1)*(k-1))*outer(p[,2],t[,1])
  data<-expand.grid(Person=1:n,Task=1:k);data$Score<-as.vector(y)
  d<-mfrm_multivariate_d_study(mfrm_multivariate_gstudy(data,"Score",rater=NULL))
  ci<-confint(d,parm="Phi",assumption="normal")
  expect_true(is.na(ci$Estimate));expect_equal(ci$PointStatus,"Negative universe variance")
  expect_equal(ci$Lower,0);expect_gt(ci$Upper,0);expect_equal(ci$Status,"Includes zero")
  expect_gt(attr(ci,"monte_carlo")$zero_proportion,0)
  expect_error(confint(d,parm="Phi",assumption="normal",draws=1000),"each tail")
  expect_error(confint(d,parm="Phi",assumption="normal",draws=1e5,level=.999),"each tail")
  expect_error(confint(d,parm="Phi",assumption="normal",draws=4000.5),"integer")
  expect_error(confint(d,parm="Phi",assumption="normal",seed=NA),"seed")
  expect_error(confint(d,parm="Phi",assumption="normal",seed=-1),"seed")
  data$Score <- as.vector(outer(p[,1]*sqrt(1e-10*(n-1)/k),rep(1,k)) +
    outer(rep(1,n),t[,2]*sqrt((k-1)/n)) + sqrt((n-1)*(k-1))*outer(p[,2],t[,1]))
  boundary <- confint(mfrm_multivariate_d_study(mfrm_multivariate_gstudy(data,"Score",rater=NULL)),parm="Phi",assumption="normal",draws=4000)
  expect_equal(boundary$Status,"Upper endpoint at zero")
  expect_equal(c(boundary$Lower,boundary$Upper),c(0,0))
  expect_equal(attr(boundary,"monte_carlo")$zero_proportion,1)
  data$Score<-data$Person
  zero<-confint(mfrm_multivariate_d_study(mfrm_multivariate_gstudy(data,"Score",rater=NULL)),parm="Phi",assumption="normal")
  expect_equal(zero$Estimate,1);expect_equal(zero$Status,"Degenerate mean squares")
  expect_true(is.na(zero$Lower)&&is.na(zero$Upper))
  expect_equal(attr(zero,"monte_carlo")$draws_used,0)
})

test_that("G comparison intervals include an interior extremum instead of mapping endpoints only", {
  range_fun<-mfrmr:::.mfrm_mvgt_g_difference_range
  counts<-c(3,6,12);reference<-6;k<-6
  interval<-list(log_bounds=log1p(k*c(.01,5)),status="Available")
  ci<-range_fun(interval,k,counts,reference)
  for(i in c(1,3)) {
    # Independent direct difference of G values and scalar optimization.
    h<-function(t) counts[i]*t/(1+counts[i]*t)-reference*t/(1+reference*t)
    endpoints<-h(c(.01,5))
    extrema<-c(endpoints,optimize(h,c(.01,5),maximum=FALSE,tol=1e-12)$objective,
      optimize(h,c(.01,5),maximum=TRUE,tol=1e-12)$objective)
    expect_equal(c(ci$lower[i],ci$upper[i]),range(extrema),tolerance=1e-10)
  }
  expect_gt(ci$upper[3],max(12*c(.01,5)/(1+12*c(.01,5))-6*c(.01,5)/(1+6*c(.01,5))))
  expect_equal(ci$lower[2],0);expect_equal(ci$upper[2],0)
  expect_equal(ci$status[2],"Identical counts")
  interval$log_bounds<-c(0,Inf)
  all<-range_fun(interval,k,counts,reference)
  peak<-(sqrt(2)-1)/(sqrt(2)+1)
  expect_equal(all$lower,c(-peak,0,0));expect_equal(all$upper,c(0,0,peak))
  interval$log_bounds<-log1p(k*c(.5,1))
  away<-range_fun(interval,k,12,reference)
  h<-function(t)12*t/(1+12*t)-6*t/(1+6*t)
  expect_equal(c(away$lower,away$upper),sort(h(c(.5,1))))
})

test_that("G comparison tables preserve paired context, reversal and saved replay", {
  data<-mvgt_interval_tasks()
  g<-mfrm_multivariate_gstudy(data,c("V","W"),rater=NULL)
  d<-mfrm_multivariate_d_study(g,data.frame(Tasks=c(6,12,6)),weights=c(V=.5,W=.5))
  before<-serialize(d,NULL)
  a<-confint(d,reference=1,assumption="normal")
  points<-subset(d$coefficients,Kind=="Composite")$G
  expect_equal(a$Estimate,points[-1]-points[1])
  expect_equal(a$ReferenceValue,rep(points[1],2));expect_equal(a$Value,points[-1])
  expect_equal(a$ReferenceCount,c(6,6));expect_identical(a$Metric,rep("G difference",2))
  expect_equal(a$Lower[2],0);expect_equal(a$Upper[2],0)
  expect_equal(a$Status[2],"Identical counts")
  expect_equal(attr(a,"weights"),c(V=.5,W=.5))
  expect_equal(attr(a,"pivot"),attr(confint(d,assumption="normal"),"pivot"))
  expect_equal(attr(a,"reference")$scenario,1L)
  expect_true(!is.null(attr(a,"source_design")))
  b<-confint(d,reference=2,assumption="normal")
  expect_equal(b$Estimate[1],-a$Estimate[1])
  expect_equal(b$Lower[1],-a$Upper[1]);expect_equal(b$Upper[1],-a$Lower[1])
  wider<-confint(d,reference=1,assumption="normal",level=.99)
  expect_true(all(wider$Lower<=a$Lower & wider$Upper>=a$Upper))
  path<-tempfile(fileext=".rds");on.exit(unlink(path),add=TRUE)
  saveRDS(list(d=d,ci=a),path);saved<-readRDS(path)
  expect_identical(confint(saved$d,reference=1,assumption="normal"),saved$ci)
  expect_identical(serialize(d,NULL),before)
  for(ref in list(0,4,NA_real_,1.5,TRUE,matrix(1)))
    expect_error(confint(d,reference=ref,assumption="normal"),"reference")
  expect_error(confint(mfrm_multivariate_d_study(g),reference=1,assumption="normal"),"at least two")
})

test_that("G comparison intervals retain empty and boundary states", {
  n<-10;k<-6;p<-qr.Q(qr(contr.helmert(n)));t<-qr.Q(qr(contr.helmert(k)))
  data<-expand.grid(Person=1:n,Task=1:k)
  data$Score<-as.vector(outer(p[,1]*sqrt(.5*(n-1)/k),rep(1,k)) +
    sqrt((n-1)*(k-1))*outer(p[,2],t[,1]))
  make<-function(data) mfrm_multivariate_d_study(
    mfrm_multivariate_gstudy(data,"Score",rater=NULL),data.frame(Tasks=c(6,12)))
  ci<-confint(make(data),reference=1,assumption="normal")
  expect_true(is.na(ci$Estimate));expect_equal(ci$PointStatus,"Point difference unavailable")
  expect_equal(ci$Lower,0);expect_gt(ci$Upper,0);expect_equal(ci$Status,"Includes zero")
  data$Score<-as.vector(sqrt((n-1)*(k-1))*outer(p[,2],t[,1]))
  empty<-confint(make(data),reference=1,assumption="normal")
  expect_equal(empty$Status,"Empty parameter-space interval")
  expect_true(is.na(empty$Lower)&&is.na(empty$Upper))
  data$Score<-data$Person
  zero<-confint(make(data),reference=1,assumption="normal")
  expect_equal(zero$Estimate,0);expect_equal(zero$Status,"Zero residual mean square")
  expect_true(is.na(zero$Lower)&&is.na(zero$Upper))
})
