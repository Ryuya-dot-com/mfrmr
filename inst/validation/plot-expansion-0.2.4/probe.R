# Read-only diagnostic probe; records existing gaps, not repaired behavior.
# Run from the package root.
pkgload::load_all('.', quiet = TRUE)
out <- file.path(tempdir(), 'mfrmr-plot-expansion')
dir.create(out, recursive=TRUE, showWarnings=FALSE)
stopifnot(requireNamespace('igraph', quietly=TRUE))
make_chain <- function(detail) {
 structure(list(
  links=data.frame(From=c('A','B'),To=c('B','C'),N_Common=c(1L,0L),N_Retained=c(0L,0L)),
  cumulative=data.frame(Wave=c('A','B','C'),Cumulative_Offset=c(0,NA,NA)),
  element_detail=detail,config=list(waves=c('A','B','C'))),
  class=c('mfrm_equating_chain','list'))
}
d <- data.frame(Facet='Criterion',Level='I1',Link='A -> B',Retained=FALSE,Flag=TRUE)
p <- plot(make_chain(d),type='graph',draw=FALSE)
r <- data.frame(Check=c('Declared waves','Returned graph waves','Returned edges from excluded element','Edge status retained'),
 Value=c(3,p$data$data$n_waves,nrow(p$data$data$edges),any(c('Retained','Flag') %in% names(p$data$data$edges))))
empty <- d[FALSE,,drop=FALSE]
e <- tryCatch({q<-plot(make_chain(empty),type='graph',draw=FALSE);'no error'},error=function(e)conditionMessage(e))
r <- rbind(r,data.frame(Check='Zero common elements',Value=e))
print(r)
write.csv(r,file.path(out,'probe.csv'),row.names=FALSE)
# Real rendering fixture: verify the current public design-network path.
f <- readRDS('inst/validation/plot-models-0.2.4/fits.rds')[['PCM-interaction-MML']]
net <- suppressWarnings(mfrm_network_analysis(f))
q <- plot(net,type='network',draw=FALSE)
print(net$summary)
print(names(q$data))
write.csv(net$summary,file.path(out,'design-network-summary.csv'),row.names=FALSE)
