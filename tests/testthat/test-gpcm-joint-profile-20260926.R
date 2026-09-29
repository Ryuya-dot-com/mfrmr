test_that('joint profile reoptimizes coupled nuisance coordinates and retains failure', {
  path <- test_path('..','..','inst','validation','gpcm-joint-profile-20260926.R')
  skip_if_not(file.exists(path), 'Repository-only profile work is excluded.')
  env <- new.env(parent = globalenv()); sys.source(path,env)
  evaluator <- list(value=function(x)(x[1]-2*x[2])^2+(x[2]-1)^2+(x[3]-x[1])^2,
    gradient=function(x)c(2*(x[1]-2*x[2])-2*(x[3]-x[1]),
      -4*(x[1]-2*x[2])+2*(x[2]-1),2*(x[3]-x[1])))
  for(start in list(c(5,5,5),c(-4,0,-1))) {
    a <- env$gjp_fit(evaluator,start,2L,-1)
    expect_equal(a$selected$full,c(-2,-1,-2),tolerance=1e-6)
    expect_equal(a$selected$value,4,tolerance=1e-10)
    expect_lt(max(abs(a$selected$gradient)),1e-4)
    expect_equal(evaluator$gradient(a$selected$full)[2],-4,tolerance=1e-5)
  }
  failed <- env$gjp_fit(list(value=function(x)stop('unavailable'),gradient=function(x)x),c(1,2),1L,0)
  expect_null(failed$selected)
  expect_true(all(vapply(failed$stages,function(x)grepl('unavailable',x$error),logical(1))))
})
