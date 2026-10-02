# Complete declared held-out panels for the retained one-PCM-input eight-arm
# comparison. No calibration fitting. Rscript THIS_FILE OUTPUT_DIRECTORY
pkgload::load_all(".",quiet=TRUE,compile=FALSE)
for (name in c("mml-stages-20261001","jml-stages-20261001","recovery-20261002","f-scoring-20261002"))
  source(paste0("inst/validation/mfrm-wide-map-",name,".R"))
out <- commandArgs(trailingOnly=TRUE)[1L]; stopifnot(length(out)==1L,!is.na(out))
old <- "validation-results/mfrm-wide-map-intervals-20261002"
previous <- wide_f_read(file.path(old,"witness-manifest.rds"))$payload
input <- previous$input; runtime <- wide_jml_runtime()
keys <- names(runtime$source)[grepl("^(R/|src/|loaded:)|^(DESCRIPTION|NAMESPACE)$",names(runtime$source))]
stopifnot(identical(runtime$source[keys],previous$runtime$source[keys]),
  identical(previous$model_archive,tools::md5sum(names(previous$model_archive))))
sources <- setNames(lapply(names(previous$jobs),function(arm) wide_f_source(file.path(old,arm),input)),names(previous$jobs))
for (x in sources) stopifnot(identical(x$model_source[keys],runtime$source[keys]))
paths <- c("inst/validation/mfrm-wide-map-f-witness-20261002.R",
  "inst/validation/mfrm-wide-map-f-scoring-20261002.R",
  "inst/validation/mfrm-wide-map-recovery-20261002.R",
  names(runtime$source)[grepl("^inst/validation/",names(runtime$source))])
runtime$source <- c(runtime$source,tools::md5sum(setdiff(paths,names(runtime$source))))
manifest <- list(input=input,sources=sources,runtime=runtime,source=tools::md5sum(paths),
  model_archive=previous$model_archive,prior_labels=c("reference","retained"),
  previous=tools::md5sum(file.path(old,"witness-manifest.rds")),
  protocol=list(calibration_refits=0L,independent_calibration_replicates=1L,
    panels="All nine declared A/B held-out batches for this preselected N20 SD1 paired-L1 PCM case",
    interpretation="Workflow and cost evidence, not comparative performance or R=50 qualification."))
dir.create(out,recursive=TRUE,showWarnings=FALSE)
stopifnot(identical(wide_mml_phase(file.path(out,"witness-manifest.rds"),"F-eight-arm-v1",function() manifest),manifest))
dir.create(file.path(out,"source"),showWarnings=FALSE)
for (p in paths) {
  dest <- file.path(out,"source",basename(p))
  if (!file.exists(dest)) stopifnot(file.copy(p,dest))
  stopifnot(unname(tools::md5sum(p))==unname(tools::md5sum(dest)))
}
if (!file.exists(file.path(out,"protocol-before-execution.md"))) {
  stopifnot(file.copy("inst/validation/internal-roadmap-0.2.4.md",file.path(out,"protocol-before-execution.md")))
  writeLines(capture.output(sessionInfo()),file.path(out,"session-info.txt"))
}
panels <- wide_mml_phase(file.path(out,"panels.rds"),wide_mml_hash(manifest),function() wide_f_ab_panels(input))
stopifnot(length(panels$panels)==9L)
jobs <- expand.grid(Arm=names(sources),Prior=manifest$prior_labels,Panel=names(panels$panels),stringsAsFactors=FALSE)
jobs$JobId <- paste(jobs$Arm,jobs$Prior,jobs$Panel,sep="--")
stopifnot(identical(wide_mml_phase(file.path(out,"jobs.rds"),wide_mml_hash(manifest),function() jobs),jobs))
results <- list(); records <- list(); attempts <- list()
for (i in seq_len(nrow(jobs))) {
  j <- jobs[i, ]; s <- sources[[j$Arm]]; p <- panels$panels[[j$Panel]]
  z <- wide_f_run(s,p,j$Prior,file.path(out,j$JobId),runtime)
  results[[j$JobId]] <- z; records[[j$JobId]] <- wide_f_records(s,p,z)
  attempts[[j$JobId]] <- do.call(rbind,lapply(names(z$attempts),function(q) {
    a <- z$attempts[[q]]
    data.frame(JobId=j$JobId,Arm=j$Arm,Prior=j$Prior,Panel=j$Panel,ScoringOrder=as.integer(q),
      Elapsed=a$elapsed,Error=a$error,Warnings=paste(a$warnings,collapse="; "))
  }))
  cat(i,"/",nrow(jobs),j$JobId,"scoring q",z$selected_order,
    "scores",sum(tail(records[[j$JobId]]$ScoreAvailable,nrow(p$planned))),"\n"); flush.console()
}
stopifnot(identical(names(results),jobs$JobId),identical(tools::md5sum(paths),manifest$source))
records <- do.call(rbind,records); rownames(records)<-NULL
contributions <- wide_f_contributions(records)
summary <- wide_f_summary(contributions,expected_replicates=input$Replicate)
stopifnot(all(summary$Complete),all(summary$Replicates==1L),all(is.na(summary$RMSEMCSE)))
# Comparisons use identical panels and common returned Persons. No method
# selection or pooled grid/population RMSE follows from these single-case sums.
paired <- list(); arms <- combn(names(sources),2,simplify=FALSE)
for (a in arms) for (prior in manifest$prior_labels)
  paired[[paste(a[1],a[2],prior)]] <- wide_f_paired(records,a[1],prior,a[2],prior)
for (a in names(sources)) paired[[paste(a,"prior")]] <- wide_f_paired(records,a,"reference",a,"retained")
wide_mml_save(list(records=records,contributions=contributions,summary=summary,
  paired=do.call(rbind,paired),attempts=do.call(rbind,attempts),jobs=jobs,
  source=manifest$source,calibration_refits=0L,independent_calibration_replicates=1L),file.path(out,"verified.rds"))
