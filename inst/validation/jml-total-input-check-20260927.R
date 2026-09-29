# Focused repair checks: one Person must retain two-dimensional owner totals.
source('inst/validation/jml-design-adjustment-20260927.R')
source('inst/validation/jml-total-expectation-20260927.R')
out <- 'validation-results/jml-total-expectation-20260927'
if(file.exists(file.path(out,'input-check.rds'))) stop('Refusing to overwrite evidence.')
old <- new.env(parent=globalenv())
sys.source(file.path(out,'initial-factory.R'),envir=old)
beta <- c(.3,-.4,-.6,-.9,.25)
reference <- make_jml_roster_problem('Criterion',rep(1,4))
checks <- c(); errors <- c()
for(i in c(1L,2L,reference$n)) {
  counts <- lapply(reference$counts,function(x)x[i,,drop=FALSE])
  before <- try(old$make_jml_total_problem('Criterion',rep(1,4),counts),silent=TRUE)
  checks <- c(checks,inherits(before,'try-error'))
  fixed <- make_jml_total_problem('Criterion',rep(1,4),counts)
  for(k in c(0L,1L,4L)) {
    error <- max(abs(fixed$scores(beta,k)$value-reference$scores(beta,k)$value[i,,drop=FALSE]))
    errors <- c(errors,error); checks <- c(checks,error<1e-8)
  }
}
counts <- reference$counts
invalid <- counts; invalid[[1]][1,1] <- -1
checks <- c(checks,inherits(try(make_jml_total_problem('Criterion',rep(1,4),invalid),silent=TRUE),'try-error'))
invalid <- counts; invalid[[1]][1,] <- c(.5,.5,0)
checks <- c(checks,inherits(try(make_jml_total_problem('Criterion',rep(1,4),invalid),silent=TRUE),'try-error'))
checks <- c(checks,inherits(try(make_jml_total_problem('Criterion',rep(1,4),counts,max_states=2),silent=TRUE),'try-error'))
x <- make_jml_total_problem('Criterion',rep(1,4),counts)
checks <- c(checks,inherits(try(x$scores(beta,omit_mass=.01),silent=TRUE),'try-error'))
# The small-array repair and removal of an unused variance calculation must not
# change the source-bound complete/sparse/unequal or 32-rating results.
exposures <- list(rep(2,4),c(2,1,0,2),c(2,1,0,1))
for(e in exposures) {
  q <- make_jml_roster_problem('Criterion',e)
  a <- old$make_jml_total_problem('Criterion',e,q$counts)
  b <- make_jml_total_problem('Criterion',e,q$counts)
  for(k in c(0L,1L,4L)) checks <- c(checks,identical(a$scores(beta,k),b$scores(beta,k)))
}
sample <- readRDS(file.path(out,'observed-counts.rds'))
a <- old$make_jml_total_problem('Criterion',sample$exposure,sample$counts)
b <- make_jml_total_problem('Criterion',sample$exposure,sample$counts)
for(k in c(1L,4L)) checks <- c(checks,identical(a$scores(beta,k),b$scores(beta,k)))
saveRDS(list(checks=checks,single_person_errors=errors),file.path(out,'input-check.rds'))
print(c(AllChecks=all(checks),MaxSinglePersonError=max(errors)))
stopifnot(all(checks))
