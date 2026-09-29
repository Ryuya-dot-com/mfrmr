# Local convention check, not an equality/coverage benchmark for free estimates.
run_tam_anchor_convention <- function(out) {
  if(dir.exists(out)) stop('Refusing to overwrite anchor evidence.')
  dir.create(out,recursive=TRUE)
  e <- new.env(); utils::data('data.sim.rasch',package='TAM',envir=e)
  resp <- as.matrix(e$data.sim.rasch[1:200,1:8])
  anchor <- matrix(c(1,.2),1,2)
  log <- capture.output({
    jml <- TAM::tam.jml(resp,adj=.3,bias=FALSE,xsi.fixed=anchor,verbose=FALSE)
    mml <- TAM::tam.mml(resp,xsi.fixed=anchor,verbose=FALSE)
  })
  result <- data.frame(Engine='TAM',Version=as.character(utils::packageVersion('TAM')),
    Method=c('JML','MML'),FixedValue=c(jml$xsi[1],mml$xsi$xsi[1]),
    ReportedSE=c(jml$errorP[1],mml$xsi$se.xsi[1]))
  stopifnot(all(result$FixedValue==.2),all(result$ReportedSE==0))
  write.csv(result,file.path(out,'summary.csv'),row.names=FALSE)
  writeLines(log,file.path(out,'engine.log'))
  saveRDS(list(response=resp,anchors=anchor,JML=jml,MML=mml,result=result,
    source_md5=tools::md5sum('inst/validation/tam-anchor-convention-20260927.R')),
    file.path(out,'results.rds'))
  writeLines(capture.output(sessionInfo()),file.path(out,'sessionInfo.txt'))
  print(result,row.names=FALSE)
}
if(sys.nframe()==0L) run_tam_anchor_convention('validation-results/tam-anchor-convention-20260927')
