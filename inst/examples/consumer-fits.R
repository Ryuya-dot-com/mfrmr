# Recreate the example_core fits used by centrality and Person-scoring help.
# Sourcing this file only defines a function. Use the returned fits with
# rater_centrality_table() or score_mfrm_persons() to compute fresh results.
#
# source(system.file("examples", "consumer-fits.R", package = "mfrmr"))
# saveRDS(consumer_fit_examples(), "consumer-fits.rds", compress = "xz")
consumer_fit_examples <- function() {
  ratings <- mfrmr::load_mfrmr_data("example_core")
  rsm <- mfrmr::fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score",
    method = "JML", model = "RSM", maxit = 100)
  pcm <- mfrmr::fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score",
    method = "JML", model = "PCM", step_facet = "Rater", maxit = 100)
  mml <- mfrmr::fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score")
  # Constant population formulas must not serialize the generation session.
  for (field in c("formula", "terms")) {
    if (!is.null(mml$population[[field]]))
      environment(mml$population[[field]]) <- baseenv()
    if (!is.null(mml$config$population_spec[[field]]))
      environment(mml$config$population_spec[[field]]) <- baseenv()
  }
  list(dataset = "example_core", rsm = rsm, pcm = pcm, mml = mml)
}
