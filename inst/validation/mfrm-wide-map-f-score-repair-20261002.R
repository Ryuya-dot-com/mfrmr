# Verify the repaired retained-prior route on all 18 affected saved batches.
# No calibration fits or data generation. Keep the original F epoch intact.
pkgload::load_all(".",quiet=TRUE,compile=FALSE)
for (name in c("mml-stages-20261001","jml-stages-20261001","recovery-20261002","f-scoring-20261002"))
  source(paste0("inst/validation/mfrm-wide-map-",name,".R"))
out <- commandArgs(trailingOnly=TRUE)[1L]; stopifnot(length(out)==1L,!is.na(out))
old <- "validation-results/mfrm-wide-map-f-scoring-20261002"
m <- wide_f_read(file.path(old,"witness-manifest.rds"))$payload
stopifnot(file.exists(file.path(old,"fresh-process-replay.rds")))
baseline <- readRDS(file.path(old,"verified.rds"))
panels <- wide_f_read(file.path(old,"panels.rds"))$payload$panels
runtime <- wide_jml_runtime()
keys <- names(runtime$source)[grepl("^(R/|src/|loaded:)|^(DESCRIPTION|NAMESPACE)$",names(runtime$source))]
changed <- keys[runtime$source[keys]!=m$runtime$source[keys]]
stopifnot(identical(changed,"R/api-prediction.R"))
# Confirm the reused fits' scoring-source checks and estimation helpers have
# identical parsed code. Only scoring and saved-output validation changed.
old_file <- names(m$model_archive)[endsWith(names(m$model_archive),"/R/api-prediction.R")]
stopifnot(length(old_file)==1L,identical(tools::md5sum(old_file),m$model_archive[old_file]))
definitions <- function(path) {
  expr <- as.list(parse(path,keep.source=FALSE))
  stopifnot(all(vapply(expr,function(x) is.call(x) && identical(x[[1]],as.name("<-")),TRUE)))
  setNames(lapply(expr,function(x)x[[3]]),vapply(expr,function(x) as.character(x[[2]]),""))
}
a <- definitions(old_file); b <- definitions("R/api-prediction.R")
stopifnot(identical(names(a),names(b)),setequal(names(a)[!vapply(names(a),function(n)identical(a[[n]],b[[n]]),TRUE)],
  c("prediction_validate_population_output","predict_mfrm_units")))
sources <- m$sources[c("PCM-MML-fixed","PCM-JML")]
for (s in sources) stopifnot(identical(tools::md5sum(names(s$files)),s$files))
paths <- c("inst/validation/mfrm-wide-map-f-score-repair-20261002.R",
  "inst/validation/mfrm-wide-map-f-scoring-20261002.R","R/api-prediction.R",
  "tests/testthat/test-ordinary-score-integration.R","tests/testthat/fixtures/ordinary-score-integration.rds")
runtime$source <- c(runtime$source,tools::md5sum(setdiff(paths,names(runtime$source))))
manifest <- list(sources=sources,panels=panels,runtime=runtime,source=tools::md5sum(paths),
  baseline=tools::md5sum(file.path(old,c("verified.rds","fresh-process-replay.rds","panels.rds"))),
  interpretation="Scoring-only repair epoch; same calibration, rows and prior, no independent new replicate.")
dir.create(out,recursive=TRUE,showWarnings=FALSE)
stopifnot(identical(wide_mml_phase(file.path(out,"repair-manifest.rds"),"F-score-repair-v1",function()manifest),manifest))
dir.create(file.path(out,"source"),showWarnings=FALSE)
for (p in paths) {
  dest <- file.path(out,"source",basename(p))
  if (!file.exists(dest)) stopifnot(file.copy(p,dest))
  stopifnot(unname(tools::md5sum(p))==unname(tools::md5sum(dest)))
}
jobs <- expand.grid(Arm=names(sources),Panel=names(panels),stringsAsFactors=FALSE)
records <- list(); comparison <- list()
for (i in seq_len(nrow(jobs))) {
  j <- jobs[i, ]; id <- paste(j$Arm,j$Panel,sep="--"); s <- sources[[j$Arm]]; p <- panels[[j$Panel]]
  z <- wide_f_run(s,p,"retained",file.path(out,id),runtime)
  rows <- wide_f_records(s,p,z); records[[id]] <- rows
  current <- rows[rows$Rule=="refinement", ]
  reference <- baseline$records[baseline$records$Arm==j$Arm & baseline$records$Panel==j$Panel &
    baseline$records$Prior=="reference" & baseline$records$Rule=="refinement", ]
  reference <- reference[match(current$Person,reference$Person), ]
  stopifnot(identical(current$DataId,reference$DataId),identical(current$ScoreAvailable,reference$ScoreAvailable),
    identical(current$IntervalAvailable,reference$IntervalAvailable),all(current$BatchCheck=="public_EAP_SD_pass"),
    all(current$ScoringOrder==reference$ScoringOrder))
  delta <- max(abs(as.matrix(current[c("Estimate","SD","Lower","Upper")])-
    as.matrix(reference[c("Estimate","SD","Lower","Upper")])))
  stopifnot(is.finite(delta),delta<1e-12)
  comparison[[id]] <- data.frame(Arm=j$Arm,Panel=j$Panel,ScoringOrder=z$selected_order,
    Scores=sum(current$ScoreAvailable),MaxDifference=delta,
    Default31Scores=sum(rows$ScoreAvailable[rows$Rule=="default31"]))
  cat(i,"/",nrow(jobs),id,"q",z$selected_order,"difference",delta,"\n");flush.console()
}
stopifnot(identical(tools::md5sum(paths),manifest$source))
wide_mml_save(list(records=do.call(rbind,records),comparison=do.call(rbind,comparison),
  source=manifest$source,calibration_refits=0L,new_responses=0L),file.path(out,"verified.rds"))
