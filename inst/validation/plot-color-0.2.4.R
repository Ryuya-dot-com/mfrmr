# Run from the package root. colorspace is a review-only dependency.
pkgload::load_all('.', quiet = TRUE)
stopifnot(requireNamespace('colorspace', quietly = TRUE))
args <- commandArgs(trailingOnly = TRUE)
out <- if(length(args)) args[1] else file.path(tempdir(), 'mfrmr-plot-color')
dir.create(out, recursive = TRUE, showWarnings = FALSE)
fits <- readRDS('inst/validation/plot-models-0.2.4/fits.rds')[c('PCM-interaction-MML','GPCM-Rater-MML')]
views <- c('wright','facets','pathway','fit_pathway','ccc','ccc_overlay')
transforms <- list(normal = identity, protan = colorspace::protan,
 deutan = colorspace::deutan, tritan = colorspace::tritan, grayscale = colorspace::desaturate)
rows <- list()
for(key in names(fits)) for(type in views) {
 a <- list(x = fits[[key]], type = if(type == 'facets') 'wright' else type,
           show_title = FALSE, show_notes = FALSE, preset = 'publication')
 if(type == 'facets') { a$renderer <- 'facets'; a$persons_per_star <- 4 }
 p <- suppressWarnings(do.call(plot, c(a, list(draw = FALSE))))
 series <- if(type %in% c('ccc','ccc_overlay')) unique(as.character(p$data$probabilities$Category)) else
   if(type == 'pathway') unique(as.character(p$data$expected$CurveGroup)) else
   if(type == 'fit_pathway') unique(as.character(p$data$table$Facet)) else c('facet_level','step_threshold')
 base_colors <- mfrmr:::.plot_series_colors(series)
 for(mode in names(transforms)) {
  a$palette <- setNames(transforms[[mode]](base_colors), series)
  q <- suppressWarnings(do.call(plot, c(a, list(draw = FALSE))))
  for(component in intersect(c('locations','expected','probabilities','overlay','table','fit_readiness'), names(p$data)))
   stopifnot(identical(p$data[[component]], q$data[[component]]))
  for(renderer in c('base','ggplot')) {
   name <- paste(key,type,mode,renderer,sep = '-')
   png(file.path(out,paste0(name,'.png')),width = 7,height = 5,units = 'in',res = 110)
   warnings <- character()
   error <- tryCatch(withCallingHandlers({
    if(renderer == 'base') do.call(plot,a) else print(as_ggplot(q))
    ''
   }, warning = function(w) {warnings <<- c(warnings,conditionMessage(w)); invokeRestart('muffleWarning')}),
    error = function(e) conditionMessage(e))
   dev.off()
   rows[[length(rows)+1L]] <- data.frame(Case=key,Type=type,Mode=mode,Renderer=renderer,
     Error=error,Warnings=paste(unique(warnings),collapse=' | '))
  }
 }
 cat(key,type,'complete\n')
}
r <- do.call(rbind,rows)
write.csv(r,file.path(out,'drawings.csv'),row.names=FALSE)
stopifnot(nrow(r)==120L,all(r$Error==''))
# Quantify opaque line-ink/background contrast, separately from colour separation.
rows <- list()
for(n in c(8,10)) for(mode in names(transforms)) for(bg in c('white','#fcfdff')) {
 colors <- transforms[[mode]](mfrmr:::.plot_series_colors(seq_len(n)))
 rows[[length(rows)+1L]] <- data.frame(Count=n,Mode=mode,Background=bg,Series=seq_len(n),
  Color=colors,Contrast=colorspace::contrast_ratio(colors,bg))
}
contrast <- do.call(rbind,rows)
write.csv(contrast,file.path(out,'contrast.csv'),row.names=FALSE)
stopifnot(all(contrast$Contrast >= 3))
# Publication figures: ordinary colour and a genuine monochrome preset.
for(type in c('pathway','ccc')) for(renderer in c('base','ggplot')) for(preset in c('publication','monochrome')) {
 a <- list(x=fits[['GPCM-Rater-MML']],type=type,preset=preset,show_title=FALSE,show_notes=FALSE)
 p <- suppressWarnings(do.call(plot,c(a,list(draw=FALSE))))
 name <- paste(type,renderer,preset,sep='-')
 pdf(file.path(out,paste0(name,'.pdf')),width=5,height=4)
 suppressWarnings(if(renderer=='base') do.call(plot,a) else print(as_ggplot(p)))
 dev.off()
}
files <- c(list.files('R',pattern='[.]R$',full.names=TRUE),
 'inst/validation/plot-color-0.2.4.R','inst/validation/plot-models-0.2.4/fits.rds')
write.csv(data.frame(File=files,MD5=unname(tools::md5sum(files))),file.path(out,'source-md5.csv'),row.names=FALSE)
writeLines(capture.output(sessionInfo()),file.path(out,'session-info.txt'))
