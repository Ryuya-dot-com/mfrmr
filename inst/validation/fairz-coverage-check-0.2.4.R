# Executable checks for the new study plumbing; no confirmation data generated.
# Optional argument: the completed study directory, for actual resume/gate checks.
source('inst/validation/fairz-coverage-0.2.4.R')
pkgload::load_all('.',quiet=TRUE)
fails <- function(expr) inherits(tryCatch(force(expr),error=identity),'error')
mml_coverage_self_check()
targets <- c(paste0('Rater:R',1:3),'Criterion:C1','Criterion:C2')
methods <- c('joint_structural_candidate','conditional_measure')
est <- setNames(c(0,.01,1,1.99,2),targets)
se <- matrix(c(rep(.1,5),rep(.2,5)),5,2,dimnames=list(targets,methods))
ci <- fairz_coverage_intervals(est,se,TRUE)
stopifnot(identical(dim(ci$Lower),c(5L,2L)),identical(dimnames(ci$Lower),dimnames(se)),
  all(ci$Available),all(ci$Lower>=0),all(ci$Upper<=2),
  any(ci$Upper-ci$Lower < ci$UnclippedUpper-ci$UnclippedLower))
for(truth in seq(0,2,length.out=101)) stopifnot(identical(
  ci$Lower<=truth & truth<=ci$Upper,ci$UnclippedLower<=truth & truth<=ci$UnclippedUpper))
bad <- se; bad[1,1] <- NA_real_;bad[2,2] <- 0;bad[3,1] <- Inf
bad_ci <- fairz_coverage_intervals(est,bad,TRUE)
stopifnot(sum(!bad_ci$Available)==3L,all(is.na(bad_ci$Lower[!bad_ci$Available])),
  !any(fairz_coverage_intervals(est,se,FALSE)$Available))
seed <- unlist(lapply(1:8,function(id) fairz_coverage_seed(id,1:2500,'confirmation')))
pre <- unlist(lapply(1:8,function(id) fairz_coverage_seed(id,1:5,'preflight')))
stopifnot(length(seed)==20000L,!anyDuplicated(seed),!any(seed %in% pre),
  min(seed)==77010001L,max(seed)==77082500L)
cat('PASS: inherited MC metrics, bounded intervals/width, missing SEs, seed allocation.\n')

args <- commandArgs(TRUE)
if(length(args)) local({
  directory <- args[1]; payload <- fairz_coverage_payload()
  stopifnot(fairz_coverage_preflight_ready(directory,payload))
  before <- tools::md5sum(list.files(file.path(directory,'preflight'),pattern='[.]rds$',full.names=TRUE))
  # Resume a completed REAL preflight: no dataset is computed or file rewritten.
  fairz_coverage_run('preflight',directory)
  stopifnot(identical(before,tools::md5sum(names(before))))
  state <- readRDS(file.path(directory,'preflight','cell-01.rds'))
  cell <- mml_coverage_cells()[1,]
  wrong <- state; wrong$Stage <- 'confirmation'
  stopifnot(fails(fairz_coverage_validate(wrong,cell,'preflight',payload)))
  wrong <- state;wrong$Payload[1] <- 'changed'
  stopifnot(fails(fairz_coverage_validate(wrong,cell,'preflight',payload)))
  wrong <- state;wrong$Backend$DLLMD5 <- 'changed'
  stopifnot(fails(fairz_coverage_validate(wrong,cell,'preflight',payload)))
  wrong <- state;wrong$Results[[2]]$Seed <- wrong$Results[[1]]$Seed
  stopifnot(fails(fairz_coverage_validate(wrong,cell,'preflight',payload)))
  wrong <- state;wrong$Results[[1]]$SE <- numeric(10)
  stopifnot(fails(fairz_coverage_validate(wrong,cell,'preflight',payload)))
  wrong <- state;wrong$Results[[1]]$FairCIEligible <- TRUE
  stopifnot(fails(fairz_coverage_validate(wrong,cell,'preflight',payload)))

  # Mock only the expensive one-dataset calculation; exercise real checkpoints.
  tmp <- tempfile('fairz-resume-');on.exit(unlink(tmp,recursive=TRUE),add=TRUE)
  original <- fairz_coverage_one;calls <- integer()
  assign('fairz_coverage_one',function(cell,replicate,stage) {
    calls <<- c(calls,replicate)
    r <- state$Results[[1]];r$Replicate <- replicate
    r$Seed <- fairz_coverage_seed(cell$Cell,replicate,stage);r
  },envir=.GlobalEnv)
  on.exit(assign('fairz_coverage_one',original,envir=.GlobalEnv),add=TRUE)
  stopifnot(!fairz_coverage_run('preflight',tmp,cells=1L,max_seconds=0),identical(calls,1L))
  partial <- fairz_coverage_summarize(file.path(tmp,'preflight'))
  stopifnot(sum(partial$runs$Attempted)==1L,sum(partial$runs$Assigned)==40L,
    all(partial$summary$Disposition=='preflight_only'),
    !fairz_coverage_preflight_ready(tmp,payload),
    fails(fairz_coverage_run('confirmation',tmp,cells=1L,max_seconds=0)))
  stopifnot(fairz_coverage_run('preflight',tmp,cells=1L),identical(calls,1:5))
  done <- length(calls);fairz_coverage_run('preflight',tmp,cells=1L)
  stopifnot(length(calls)==done)
  lock <- file.path(tmp,'preflight','cell-01.rds.lock');dir.create(lock)
  stopifnot(fails(fairz_coverage_run('preflight',tmp,cells=1L)),dir.exists(lock))
  unlink(lock,recursive=TRUE)
  cat('PASS: real completed resume; source/stage/seed/shape guards; synthetic interruption/resume; incomplete preflight refusal; cell lock.\n')
})
