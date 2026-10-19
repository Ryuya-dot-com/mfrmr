# Design-only review of retained data. No source estimator or RNG is loaded.
path <- "validation-results/gmfrm-complete-procedure-20261011/manifest.rds"
manifest <- readRDS(path)
directory <- "validation-results/gmfrm-split-likelihood-contract-20261013"
dir.create(directory, recursive = TRUE, showWarnings = FALSE)
records <- lapply(names(manifest$cases), function(name) {
  s <- manifest$cases[[name]]$specification
  d <- s$data
  person <- as.character(d[[s$person]])
  cell <- do.call(paste, c(lapply(d[s$slope_facets], as.character), sep = "\034"))
  persons <- sort(unique(person))
  signature <- vapply(persons, function(id) paste(sort(cell[person == id]), collapse = "\035"), "")
  fold <- setNames(rep(NA_character_, length(persons)), persons)
  sizes <- c(A = 0L, B = 0L)
  for (key in sort(unique(signature))) {
    ids <- persons[signature == key]
    first <- names(which.min(sizes))
    labels <- rep(c(first, setdiff(c("A", "B"), first)), length.out = length(ids))
    fold[ids] <- labels
    sizes <- sizes + table(factor(labels, levels = names(sizes)))
  }
  rows <- unname(fold[person])
  stopifnot(!anyNA(rows), abs(sum(fold == "A") - sum(fold == "B")) <= 1,
    !length(intersect(person[rows == "A"], person[rows == "B"])))
  table <- do.call(rbind, lapply(c("A", "B"), function(f) data.frame(
    Case = name, Fold = f, Persons = sum(fold == f), Ratings = sum(rows == f),
    AllFirstLevels = setequal(d[[s$slope_facets[1]]][rows == f], d[[s$slope_facets[1]]]),
    AllSecondLevels = setequal(d[[s$slope_facets[2]]][rows == f], d[[s$slope_facets[2]]]))))
  # Missing levels would be retained as a feasibility finding, not repaired
  # by choosing a split using scores. Presence is not an identification proof.
  list(table = table, persons = data.frame(Person = persons, Fold = unname(fold)),
    row_fold = rows)
})
names(records) <- names(manifest$cases)
answer <- list(inputs = tools::md5sum(path),
  source = tools::md5sum("inst/validation/gmfrm-person-split-audit-20261013.R"),
  records = records)
out <- file.path(directory, "person-splits.rds")
if (file.exists(out)) stopifnot(identical(answer, readRDS(out))) else saveRDS(answer, out)
print(do.call(rbind, lapply(records, `[[`, "table")), row.names = FALSE)
cat("Partition verified; source data and response values unchanged. No fit or generation.\n")
