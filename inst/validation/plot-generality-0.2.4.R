# Small rendering fixtures, not a parameter-recovery simulation.
# Run from the package root:
# Rscript inst/validation/plot-generality-0.2.4.R /tmp/mfrmr-plot-generality
pkgload::load_all('.', quiet = TRUE)
args <- commandArgs(trailingOnly = TRUE)
out_dir <- if(length(args)) args[1] else file.path(tempdir(), 'mfrmr-plot-generality')
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
specs <- data.frame(Case=c('minimal','many_levels','many_categories','coincident','long_english','japanese'),
 Raters=c(2,12,4,6,4,4),Items=c(2,12,4,6,4,4),Categories=c(2,4,10,5,4,4))
fits <- list()
for(i in seq_len(nrow(specs))) {
 s <- specs[i,]
 d <- simulate_mfrm_data(n_person=60,n_rater=s$Raters,n_criterion=s$Items,score_levels=s$Categories,seed=9300+i)
 if(s$Case=='coincident') d$Score <- 1L+(match(d$Person,unique(d$Person))-1L)%%s$Categories
 if(s$Case %in% c('long_english','japanese')) {
  d$Rater <- paste0(if(s$Case=='japanese') '専門的な記述回答を担当する評価者番号' else 'Expert rater responsible for written responses number ',d$Rater)
  d$Criterion <- paste0(if(s$Case=='japanese') '論理構成と根拠の説明に関する評価観点番号' else 'Analytical judgement of argumentation and evidence number ',d$Criterion)
 }
 for (model in c('RSM','PCM')) {
  key<-paste(s$Case,model,sep='-')
  fits[[key]] <- suppressWarnings(fit_mfrm(d,person='Person',facets=c('Rater','Criterion'),score='Score',model=model,method='JML',maxit=25))
  cat(key,'fitted\n')
 }
}

b <- list(specs=specs,fits=fits)
if (!capabilities('aqua')) stop('This archived device review requires macOS Quartz; other backends need a separate review.')
quartzFonts(Japanese=quartzFont(c('HiraginoSans-W3','HiraginoSans-W6','HiraginoSans-W3','HiraginoSans-W6')))
original <- mfrmr:::.place_plot_labels
layouts<-list(); results<-list(); saved_payloads<-list()
record_layout <- function(...) {
 a<-list(...); p<-original(...)
 overlap<-pmin(outer(p$Right,p$Right,pmin)-outer(p$Left,p$Left,pmax), outer(p$Top,p$Top,pmin)-outer(p$Bottom,p$Bottom,pmax))
 covered<-vapply(seq_along(a$point_x),function(j) any(a$point_x[j]>p$Left & a$point_x[j]<p$Right & a$point_y[j]>p$Bottom & a$point_y[j]<p$Top),logical(1))
 usr<-par('usr')
 layouts[[length(layouts)+1L]] <<- data.frame(Labels=nrow(p),Overlap=sum(overlap[upper.tri(overlap)]>1e-8),Covered=sum(covered),Outside=sum(p$Left<usr[1]-1e-8|p$Right>usr[2]+1e-8|p$Bottom<usr[3]-1e-8|p$Top>usr[4]+1e-8))
 p
}
testthat::with_mocked_bindings({
 for(key in names(b$fits)) for(size in list(c(7,5),c(5,4),c(12,8))) for(type in c('wright','pathway','ccc')) {
  for(device in c('png','pdf')) {
   name<-sprintf('%s-%s-%sx%s-%s',key,type,size[1],size[2],device)
   file<-file.path(out_dir,paste0(name,if(device=='png') '.png' else '.pdf'))
   if(device=='png') {
    png(file,width=size[1],height=size[2],units='in',res=110)
   } else if(grepl('japanese',key)) {
    quartz(type='pdf',file=file,width=size[1],height=size[2])
   } else pdf(file,width=size[1],height=size[2])
   stopifnot(dev.cur()>1L)
   if(grepl('japanese',key)) par(family='Japanese')
   layouts<-list(); messages<-character(); start<-proc.time()[['elapsed']]
   value<-tryCatch(withCallingHandlers(plot(b$fits[[key]],type=type,preset='publication'),warning=function(w){messages<<-c(messages,conditionMessage(w));invokeRestart('muffleWarning')}), error=function(e)e)
   elapsed<-proc.time()[['elapsed']]-start
   dev.off()
   error<-if(inherits(value,'error')) conditionMessage(value) else ''
   if(!inherits(value,'error')) saved_payloads[[name]]<-value
   m<-if(length(layouts)) Reduce('+',layouts) else data.frame(Labels=0,Overlap=0,Covered=0,Outside=0)
   results[[length(results)+1L]]<-cbind(data.frame(Case=key,Type=type,Width=size[1],Height=size[2],Device=device,Error=error,Warnings=paste(unique(messages[!grepl('^Review-only display:',messages)]),collapse=' | '),Seconds=elapsed),m)
  }
 }
},.place_plot_labels=record_layout,.package='mfrmr')
r<-do.call(rbind,results)
write.csv(r,file.path(out_dir,'results.csv'),row.names=FALSE)
saveRDS(saved_payloads,file.path(out_dir,'payloads.rds'))
print(r[r$Error!=''|r$Outside>0,c('Case','Type','Width','Device','Error','Overlap','Outside')],row.names=FALSE)
print(aggregate(cbind(Overlap,Covered,Outside)~Case,r,sum),row.names=FALSE)
cat('Non-readiness warning rows:',sum(nzchar(r$Warnings)),'\n')

files <- list.files('R', pattern='[.]R$', full.names=TRUE)
write.csv(data.frame(File=files,MD5=unname(tools::md5sum(files))),file.path(out_dir,'source-md5.csv'),row.names=FALSE)
write.csv(specs,file.path(out_dir,'conditions.csv'),row.names=FALSE)
writeLines(capture.output(sessionInfo()),file.path(out_dir,'session-info.txt'))
stopifnot(nrow(r)==216L, all(r$Error==''), all(r$Covered==0), all(r$Outside==0),
          all(r$Overlap[r$Width==12]==0),
          all(grepl('^Plot labels need more space',r$Warnings[r$Overlap>0])))
