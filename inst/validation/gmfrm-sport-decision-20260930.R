# Empirical decision-target audit, not a GMFRM fit or winner-inference API.
# Run from the package root after saving the five public source files below.
# Requires pdftotext and xml2 locally; neither is a new package dependency.
out <- "validation-results/gmfrm-sport-20260930"
base <- "https://results.isu.org/results/season2526/owg2026/"
sources <- c(short.pdf = "FSKWSINGLES-----------QUAL000100--_JudgesDetailsperSkater.pdf",
  free.pdf = "FSKWSINGLES-----------FNL-000100--_JudgesDetailsperSkater.pdf",
  results.html = "CAT002RS.htm", `short-judges.html` = "SEG003OF.htm",
  `free-judges.html` = "SEG004OF.htm")
inputs <- file.path(out, names(sources))
stopifnot(all(file.exists(inputs)), nzchar(Sys.which("pdftotext")),
  requireNamespace("xml2", quietly = TRUE))
if (file.exists(file.path(out, "audit.rds"))) stop("Retain the existing audit; do not overwrite it.")
html_rows <- function(file) lapply(
  xml2::xml_find_all(xml2::read_html(file.path(out, file)), "//tr"),
  function(x) trimws(xml2::xml_text(xml2::xml_find_all(x, "./td"))))

read_segment <- function(segment) {
  path <- file.path(out, paste0(segment, ".txt"))
  stopifnot(system2(Sys.which("pdftotext"), c("-layout",
    shQuote(file.path(out, paste0(segment, ".pdf"))), shQuote(path))) == 0L)
  lines <- readLines(path, warn = FALSE)
  pages <- 1L + cumsum(grepl("\f", lines, fixed = TRUE))
  header <- paste0("^\\s*([0-9]+)\\s+(.+?)\\s+([A-Z]{3})\\s+([0-9]+)",
    paste(rep("\\s+(-?[0-9]+\\.[0-9]{2})", 4L), collapse = ""), "\\s*$")
  starts <- which(grepl(header, lines, perl = TRUE))
  judges <- Filter(function(x) length(x) >= 2L && grepl("^Judge No\\.[1-9]$", x[1]),
    html_rows(paste0(segment, "-judges.html")))
  judge_ids <- vapply(judges, `[`, character(1), 2L)
  stopifnot(length(judges) == 9L, !anyDuplicated(judge_ids),
    identical(vapply(judges, `[`, character(1), 1L), paste0("Judge No.", 1:9)))
  records <- lapply(seq_along(starts), function(i) {
    end <- if (i < length(starts)) starts[i + 1L] - 1L else length(lines)
    fields <- regmatches(lines[starts[i]], regexec(header, lines[starts[i]], perl = TRUE))[[1]][-1]
    block <- lines[starts[i]:end]
    component <- grep("^\\s*(Composition|Presentation|Skating Skills)\\s+", block, value = TRUE)
    component_names <- sub("^\\s*(Composition|Presentation|Skating Skills)\\s+.*$", "\\1", component)
    values <- lapply(component, function(x) as.numeric(strsplit(trimws(sub(
      "^\\s*(Composition|Presentation|Skating Skills)\\s+", "", x)), "\\s+")[[1]]))
    stopifnot(identical(component_names, c("Composition", "Presentation", "Skating Skills")),
      all(lengths(values) == 11L))
    values <- do.call(rbind, values)
    raw <- values[, 2:10, drop = FALSE]
    # Work from integer quarter-points / hundredths. Round the trimmed mean,
    # then each factored component, before adding. R's ties-to-even round()
    # is not the half-up convention reproducing these published PCS totals.
    mean_cents <- apply(raw, 1, function(x) floor(sum(sort(x * 4)[2:8]) * 25 / 7 + .5))
    reconstructed <- mean_cents / 100
    stopifnot(all(raw * 4 == round(raw * 4)), all(raw >= .25 & raw <= 10),
      max(abs(reconstructed - values[, 11])) < 1e-10)
    pcs <- sum(floor((mean_cents * round(values[, 1] * 100) + 50) / 100)) / 100
    totals <- as.numeric(fields[5:8])
    stopifnot(abs(pcs - totals[3]) < 1e-10,
      abs(totals[2] + pcs + totals[4] - totals[1]) < 1e-10)
    list(performance = data.frame(Person = fields[2], Segment = segment,
      Page = pages[starts[i]], SegmentRank = as.integer(fields[1]),
      Total = totals[1], TES = totals[2], PCS = totals[3], SignedDeductions = totals[4]),
      ratings = data.frame(Person = fields[2], Segment = segment,
        Component = rep(c("Composition", "Presentation", "Skating Skills"), each = 9),
        JudgeSlot = rep(1:9, 3), Rater = rep(judge_ids, 3),
        Score = as.vector(t(raw))))
  })
  list(performances = do.call(rbind, lapply(records, `[[`, "performance")),
    ratings = do.call(rbind, lapply(records, `[[`, "ratings")), judges = judge_ids)
}
short <- read_segment("short")
free <- read_segment("free")
stopifnot(nrow(short$performances) == 29L, nrow(free$performances) == 24L,
  !anyDuplicated(short$performances$Person), !anyDuplicated(free$performances$Person))
performances <- rbind(short$performances, free$performances)
ratings <- rbind(short$ratings, free$ratings)
finalists <- intersect(short$performances$Person, free$performances$Person)
final <- aggregate(cbind(Total, TES, PCS, SignedDeductions) ~ Person,
  performances[performances$Person %in% finalists, ], sum)
official <- Filter(function(x) length(x) == 6L && grepl("^[0-9]+$", x[1]) &&
  nzchar(x[6]), html_rows("results.html"))
official <- do.call(rbind, official)
stopifnot(nrow(official) == 24L, setequal(final$Person, official[, 2]))
final <- final[match(official[, 2], final$Person), ]
final$OfficialRank <- as.integer(official[, 1])
final$PublishedTotal <- as.numeric(official[, 4])
stopifnot(max(abs(final$Total - final$PublishedTotal)) < 1e-10,
  nrow(ratings) == 1431L, !anyNA(ratings),
  !anyDuplicated(ratings[c("Person", "Segment", "Component", "Rater")]))
# Only descriptive official totals, not independently rederived GOE conversions.
# No judge deletion, latent ranking, competence label or winner probability.
audit <- list(source_urls = setNames(paste0(base, sources), names(sources)),
  source_hashes = tools::md5sum(inputs), reviewed = "2026-09-30",
  performances = performances, component_ratings = ratings, finalists = final,
  unique_judges = length(union(short$judges, free$judges)),
  shared_judges = intersect(short$judges, free$judges),
  non_finalists = setdiff(short$performances$Person, free$performances$Person),
  checks = c(ComponentMeans = 159L, ProgramComponentTotals = 53L,
    SegmentTotals = 53L, FinalTotals = 24L),
  scope = "PCS reconstructed from raw marks; published TES retained; no inferential claim")
saveRDS(audit, file.path(out, "audit.rds"))
write.csv(final, file.path(out, "final-totals.csv"), row.names = FALSE)
write.csv(ratings, file.path(out, "component-ratings.csv"), row.names = FALSE)
writeLines(capture.output(sessionInfo()), file.path(out, "session-info.txt"))
print(audit$checks)
print(c(UniqueJudges = audit$unique_judges, SharedJudges = length(audit$shared_judges),
  NonFinalists = length(audit$non_finalists)))
print(head(final, 2), row.names = FALSE)
