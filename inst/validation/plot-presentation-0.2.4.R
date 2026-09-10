# Presentation review: reuse archived, review-only rendering fixtures.
# Run from the package root: Rscript inst/validation/plot-presentation-0.2.4.R /tmp/mfrmr-plot-presentation-final
pkgload::load_all('.',quiet=TRUE)
fits <- readRDS('inst/validation/plot-models-0.2.4/fits.rds')[c('PCM-interaction-MML','GPCM-Rater-MML')]
args <- commandArgs(trailingOnly=TRUE)
out <- if(length(args)) args[1] else file.path(tempdir(),'mfrmr-plot-presentation')
dir.create(out,recursive=TRUE,showWarnings=FALSE)
results <- list(); payloads <- list()
for(key in names(fits)) for(type in c('wright','facets','pathway','ccc')) {
 for(flags in list(c(TRUE,TRUE),c(FALSE,TRUE),c(TRUE,FALSE),c(FALSE,FALSE))) {
  args <- list(x=fits[[key]],type=if(type=='facets') 'wright' else type,
   show_title=flags[1],show_notes=flags[2],preset='publication')
  if(type=='facets') args$renderer <- 'facets'
  p <- suppressWarnings(do.call(plot,c(args,list(draw=FALSE))))
  baseline_key <- paste(key,type,TRUE,TRUE,sep='-')
  if(!is.null(payloads[[baseline_key]])) {
   baseline <- payloads[[baseline_key]]$data
   stopifnot(identical(p$data[setdiff(names(p$data),'display')],
                       baseline[setdiff(names(baseline),'display')]))
  }
  payloads[[paste(key,type,flags[1],flags[2],sep='-')]] <- p
  for(renderer in c('base','ggplot')) for(size in list(c(5,4),c(7,5))) {
   name <- paste(key,type,flags[1],flags[2],renderer,paste(size,collapse='x'),sep='-')
   png(file.path(out,paste0(name,'.png')),width=size[1],height=size[2],units='in',res=110)
   warnings <- character()
   err <- tryCatch(withCallingHandlers({
    if(renderer=='base') do.call(plot,args) else print(as_ggplot(p))
    ''
   }, warning=function(w){warnings <<- c(warnings,conditionMessage(w));invokeRestart('muffleWarning')}),error=function(e)conditionMessage(e))
   dev.off()
   results[[length(results)+1L]] <- data.frame(Case=key,Type=type,ShowTitle=flags[1],ShowNotes=flags[2],Renderer=renderer,Width=size[1],Height=size[2],Error=err,Warnings=paste(warnings,collapse=' | '))
  }
 }
 cat(key,type,'complete\n')
}
r<-do.call(rbind,results); write.csv(r,file.path(out,'drawings.csv'),row.names=FALSE)
saveRDS(payloads,file.path(out,'payloads.rds'))
print(r[nzchar(r$Error),]);stopifnot(nrow(r)==128,all(r$Error==''))

# Selected PDF exports, including a compact frequency-column adjustment.
exports <- data.frame(Case=c('PCM-interaction-MML','GPCM-Rater-MML','PCM-interaction-MML','PCM-interaction-MML'),
 Type=c('pathway','ccc','wright','facets'), Renderer=c('base','ggplot','base','base'))
for(i in seq_len(nrow(exports))) {
 e <- exports[i,]; name <- paste(e$Case,e$Type,e$Renderer,'clean',sep='-')
 p <- payloads[[paste(e$Case,e$Type,FALSE,FALSE,sep='-')]]
 pdf(file.path(out,paste0(name,'.pdf')),width=5,height=4)
 withCallingHandlers({
  if(e$Renderer=='ggplot') print(as_ggplot(p)) else {
   a <- list(x=fits[[e$Case]],type=if(e$Type=='facets') 'wright' else e$Type,
             show_title=FALSE,show_notes=FALSE,preset='publication')
   if(e$Type=='facets') { a$renderer <- 'facets'; a$persons_per_star <- 4 }
   do.call(plot,a)
  }
 },warning=function(w)invokeRestart('muffleWarning'))
 dev.off()
}
files <- c(list.files('R',pattern='[.]R$',full.names=TRUE),
           'inst/validation/plot-presentation-0.2.4.R',
           'inst/validation/plot-models-0.2.4/fits.rds')
write.csv(data.frame(File=files,MD5=unname(tools::md5sum(files))),file.path(out,'source-md5.csv'),row.names=FALSE)
writeLines(capture.output(sessionInfo()),file.path(out,'session-info.txt'))
write.csv(payloads[['PCM-interaction-MML-pathway-FALSE-FALSE']]$data$notes,
          file.path(out,'notes-example.csv'),row.names=FALSE)
