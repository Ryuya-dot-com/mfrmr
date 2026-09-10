Sys.setenv(NOT_CRAN="true")
pkgload::load_all('.',quiet=TRUE)
files <- c('plot-customization','plot-device-state','as-ggplot','draw-and-plot-contracts',
           'wright-facets-style','fit-pathway','api-public-method-contracts','mathematical-consistency')
rows <- lapply(files,function(nm) {
 r<-as.data.frame(testthat::test_file(paste0('tests/testthat/test-',nm,'.R'),reporter='summary'))
 data.frame(File=nm,Tests=nrow(r),Passed=sum(r$passed),Failed=sum(r$failed),Errors=sum(r$error),Warnings=sum(r$warning),Skipped=sum(r$skipped))
})
r<-do.call(rbind,rows);print(r);write.csv(r,file.path(tempdir(),'mfrmr-plot-color-tests.csv'),row.names=FALSE)
stopifnot(!any(r$Failed),!any(r$Errors))
