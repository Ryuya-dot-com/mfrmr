rating_support_fixture <- function() {
  d <- data.frame(Person=c('p1','p1','p1','p2','p2','p3','p3','p4','p4'),
    Rater=factor(c('A','A','A','A','B','B','B','B','B'),levels=c('A','B','unused')),
    Task=c('A','A','B','A','A','B','B','A','C'),
    Score=c(1,1,3,2,1,3,3,1,2),Weight=c(0,2,1,3,1,1,1,1,1))
  d$score_k <- d$Score-1L
  structure(list(prep=list(data=d,facet_names=c('Rater','Task'),rating_min=1L,
    score_map=data.frame(OriginalScore=1:4,InternalScore=1:4)),config=list(n_cat=4L),
    facets=list(person=data.frame(Person=paste0('p',1:4),Estimate=0,SE=.5))),class='mfrm_fit')
}

test_that('rating support separates persons, repeated rows, crossings and unused categories', {
  f <- rating_support_fixture()
  x <- mfrm_facet_rating_support(f)
  r <- x$table[x$table$Facet=='Rater',]
  expect_equal(r[c('Level','Ratings','Persons','MinRatingsPerPerson','MedianRatingsPerPerson','MaxRatingsPerPerson')],
    data.frame(Level=c('A','B'),Ratings=c(4L,5L),Persons=c(2L,3L),MinRatingsPerPerson=c(1L,1L),
      MedianRatingsPerPerson=c(2,2),MaxRatingsPerPerson=c(3L,2L)))
  expect_equal(r$ObservedCategories,c(3L,3L))
  expect_equal(r$DeclaredCategories,c(4L,4L))
  cr <- x$crossings[x$crossings$Facet=='Rater',]
  expect_equal(cr$ObservedLevels,c(2L,3L))
  expect_equal(cr$RetainedLevels,c(3L,3L))
  cats <- x$categories[x$categories$Facet=='Rater',]
  expect_equal(cats$Score,rep(1:4,2))
  expect_equal(cats$Ratings,c(2L,1L,1L,0L,2L,1L,2L,0L))
  expect_false(any(x$table$Level=='unused'))
  f$prep$data$Weight <- f$prep$data$Weight*17
  expect_identical(mfrm_facet_rating_support(f),x)
  f$prep$score_map <- NULL
  missing <- mfrm_facet_rating_support(f)
  expect_true(all(is.na(missing$table$ObservedCategories)))
  expect_equal(nrow(missing$categories),0L)
  f$prep$data$Person[1] <- NA
  expect_error(mfrm_facet_rating_support(f),'IDs must be observed')
  f$prep$data <- NULL
  expect_equal(nrow(mfrm_facet_rating_support(f)$table),0L)
  expect_match(mfrm_facet_rating_support(f)$notes[1],'unavailable')
})

test_that('sample reviews retain legacy fields with explicit rating-count bands', {
  f <- rating_support_fixture()
  x <- facet_small_sample_review(f,thresholds=c(standard=8,sparse=2,marginal=4))
  expect_equal(x$table$N,x$table$Ratings)
  r <- x$table[x$table$Facet=='Rater',]
  expect_equal(r$SampleCategory,c('standard','standard'))
  expect_equal(r$RatingCountBand,rep('4 <= Ratings < 8',2))
  expect_equal(r$Persons,c(2L,3L))
  expect_equal(x$facet_summary$MinPersons[x$facet_summary$Facet=='Rater'],2L)
  expect_equal(x$facet_summary$MaxPersons[x$facet_summary$Facet=='Rater'],3L)
  txt <- capture.output(summary(x))
  expect_false(any(grepl('strong|standard',txt)))
  expect_true(any(grepl('not precision grades',txt,fixed=TRUE)))
  p <- plot(x,draw=FALSE)
  expect_identical(plot_data(p,'table')$Persons,x$table$Persons[order(x$table$Facet,x$table$N)])
  scale <- p$scales$get_scales('fill')
  expect_identical(unname(scale$labels('standard')),'4 <= Ratings < 8')
  expect_identical(scale$breaks(c('strong','marginal','sparse')),c('sparse','marginal','strong'))
  expect_identical(unserialize(serialize(x,NULL))$categories,x$categories)
  expect_identical(mfrm_facet_rating_support(f)$table,
    mfrm_facet_rating_support(unserialize(serialize(f,NULL)))$table)
})

test_that('two-family support tables preserve data basis through summaries and reports', {
  f <- readRDS(test_path('fixtures','gmfrm-explicit-start.rds'))$fit
  before <- f
  # A nested saved fit with explicit reduction provenance suffices for counting.
  reduced <- f
  reduced$prep$data <- reduced$prep$data[-1L,,drop=FALSE]
  reduced$config$gpcm_limit_source <- list(removed_rows=1L)
  f$point_limit <- list(fit=reduced)
  s <- summary(f)
  result <- mfrm_results(f,compute='never')
  report <- mfrm_report(result)
  for (name in c('rating_support','rating_crossings','rating_categories','rating_support_notes')) {
    expect_identical(s[[name]],result$tables[[paste0('gpcm_',name)]])
    expect_identical(s[[name]],report$tables[[name]])
  }
  tab <- s$rating_support
  facet <- f$config$facet_names[1L]
  expect_equal(sum(tab$Ratings[tab$Facet==facet & tab$DataBasis=='full_model']),nrow(f$prep$data))
  expect_equal(sum(tab$Ratings[tab$Facet==facet & tab$DataBasis=='limiting_likelihood']),nrow(f$prep$data)-1L)
  expect_identical(f$opt,before$opt)
  expect_identical(f$slopes,before$slopes)
  expect_identical(s$point_estimation$Status,'legacy_not_reviewed')
})
