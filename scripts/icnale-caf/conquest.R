# Export a declared subset for local ConQuest RSM/PCM comparisons.
# Standard ConQuest supports at most 100 generalized items here.
# Source preprocess.R first. All generated files are private research outputs.
icnale_conquest <- function(input, raters, output_dir) {
  d <- input$ratings
  icnale_require(is.character(raters) && length(raters)>1L && !anyDuplicated(raters) &&
    all(raters %in% d$Rater), 'Declare distinct retained rater identifiers.')
  criteria <- sort(unique(d$Criterion)); persons <- sort(unique(d$Person))
  icnale_require(length(criteria)==3L && 3L*length(raters)<=100L,
    'This Standard-version export supports at most 33 raters and three criteria.')
  d <- d[d$Rater %in% raters,]
  key <- function(x) paste(x$Person,x$Rater,x$Criterion,sep='|')
  icnale_require(!anyDuplicated(key(d)), 'One retained score per writer, rater and criterion is required.')
  roster <- expand.grid(Criterion=criteria,Rater=raters,Person=persons,stringsAsFactors=FALSE)
  scores <- d$Score[match(key(roster),key(d))]
  icnale_require(all(is.na(scores) | (scores %in% 0:10)), 'Use integer scores from zero to ten.')
  items <- length(raters)*3L
  coded <- matrix(ifelse(is.na(scores),' ',letters[scores+1L]),nrow=length(persons),byrow=TRUE)
  # Round-trip the exported ordering, including missing triples.
  decoded <- match(as.vector(t(coded)),letters[1:11])-1L
  icnale_require(identical(as.numeric(decoded),as.numeric(scores)), 'Export round-trip failed.')
  # Weight-zero support records declare the full 0:10 ladder for every
  # generalized item. They contribute exactly zero to the fitted likelihood.
  # ConQuest may count them in displays: do not use its printed N/BIC/fit
  # summaries as if these were additional writers or observed ratings.
  rows <- paste0(apply(coded,1,paste,collapse=''),'1')
  support <- paste0(vapply(letters[1:11],function(s)paste(rep(s,items),collapse=''),character(1)),'0')
  icnale_require(length(rows)+length(support)<=3000L,'The declared export exceeds the Standard case limit.')
  dir.create(output_dir,recursive=TRUE,showWarnings=FALSE)
  icnale_require(!file.exists(file.path(output_dir,'ratings.dat')),'Choose an unused output directory.')
  writeLines(c(rows,support),file.path(output_dir,'ratings.dat'))
  for(model in c('rsm','pcm')) {
    formula <- if(model=='rsm')'criteria+rater+step' else 'criteria+rater+criteria*step'
    writeLines(c('datafile ratings.dat;',sprintf('format responses 1-%d wt %d ! criteria(3),rater(%d);',items,items+1L,length(raters)),
      'caseweight wt;','codes a,b,c,d,e,f,g,h,i,j,k;',
      'score (a,b,c,d,e,f,g,h,i,j,k) (0,1,2,3,4,5,6,7,8,9,10);',
      'set lconstraints=cases, warning=yes, skipwtzero=no;',paste0('model ',formula,';'),
      'estimate ! method=quadrature,nodes=481,minnode=-6,maxnode=6,iterations=2000,convergence=0.0000001,deviancechange=0.00000001,stderr=empirical,matrixout=r;',
      paste0('show parameters ! estimates=latent >> ',model,'-show.txt;'),
      paste0('export parameters >> ',model,'-parameters.txt;'),
      paste0('export covariance >> ',model,'-population.txt;'),
      paste0('export parameters ! filetype=csv >> ',model,'-parameters-full.csv;'),
      paste0('print r_estimatecovariances ! filetype=csv >> ',model,'-parameter-covariance.csv;'),
      'quit;'),file.path(output_dir,paste0(model,'.cqc')))
  }
  manifest <- list(Person=persons,Rater=raters,Criterion=criteria,
    source_ratings=nrow(d),source_persons=length(persons),zero_weight_support_records=11L,
    source_md5=input$source_md5)
  saveRDS(manifest,file.path(output_dir,'manifest.rds'))
  invisible(manifest)
}
