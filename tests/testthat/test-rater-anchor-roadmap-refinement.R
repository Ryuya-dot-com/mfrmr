rater_anchor_roadmap_text <- function() {
  path <- testthat::test_path("..", "..", "ROADMAP.md")
  testthat::skip_if_not(file.exists(path))
  paste(readLines(path, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
}

test_that("public roadmap keeps Rater-anchor guidance reader-facing", {
  roadmap <- rater_anchor_roadmap_text()

  expect_match(roadmap, "## Rater assignment and anchors", fixed = TRUE)
  expect_match(roadmap, "single recommended percentage", fixed = TRUE)
  expect_match(roadmap, "complete and incomplete rating designs", fixed = TRUE)
  expect_match(roadmap, "direct anchors, group anchors, and unanchored linking",
               fixed = TRUE)
  expect_match(roadmap, "one allocation pattern will not be generalized",
               fixed = TRUE)
  expect_false(grepl(
    "G[0-9] exit|ExecutionAuthorized|candidate fits",
    roadmap,
    perl = TRUE
  ))
})
