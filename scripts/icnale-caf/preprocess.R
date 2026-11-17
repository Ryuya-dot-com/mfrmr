# ICNALE GRA v2.1, human Written CAF subset following Yamashita (2024).
# Code only: obtain the workbook from https://language.sakura.ne.jp/icnale/.
# Never redistribute the workbook, row-level outputs, or fitted-data objects.

icnale_require <- function(ok, message) {
  if (!isTRUE(ok)) stop(message, call. = FALSE)
}

icnale_score_issues <- function(raw) {
  text <- trimws(as.character(raw))
  missing <- is.na(text) | text %in% c("", "NA", "N/A")
  value <- suppressWarnings(as.numeric(text))
  issue <- rep("valid", length(text))
  issue[!missing & !is.finite(value)] <- "non_numeric"
  numeric <- !missing & is.finite(value)
  issue[numeric & (value < 0 | value > 10)] <- "out_of_range"
  issue[numeric & value >= 0 & value <= 10 & value != trunc(value)] <- "non_integer"
  issue[missing] <- "missing"
  data.frame(Raw = as.character(raw), Score = value, Issue = issue)
}

icnale_clean_caf <- function(wide) {
  criteria <- c("Complexity", "Accuracy", "Fluency")
  icnale_require(all(c("Person", "Rater", criteria) %in% names(wide)), "Missing CAF input columns.")
  icnale_require(!anyNA(wide[c("Person", "Rater")]) &&
    all(nzchar(trimws(wide$Person))) && all(nzchar(trimws(wide$Rater))), "Missing rating identifiers.")
  icnale_require(!anyDuplicated(wide[c("Person", "Rater")]), "Duplicate Person-Rater pairs; do not average them silently.")
  cells <- lapply(criteria, function(name) cbind(wide[setdiff(names(wide), criteria)],
    Criterion = name, icnale_score_issues(wide[[name]])))
  invalid <- do.call(cbind, lapply(cells, function(x) x$Issue != "valid"))
  keep <- rowSums(invalid) == 0L
  audit <- do.call(rbind, cells)
  audit$Included <- rep(keep, times = length(criteria))
  audit$Reason <- ifelse(audit$Included, "", ifelse(audit$Issue == "valid",
    "invalid_other_caf_item", audit$Issue))
  audit <- audit[order(audit$Person, audit$Rater, match(audit$Criterion, criteria)), ]
  rownames(audit) <- NULL
  ratings <- audit[audit$Included, c("Person", "Rater", "Criterion", "Score")]
  ratings$Score <- as.integer(ratings$Score); rownames(ratings) <- NULL
  cleaned <- wide[keep, , drop = FALSE]
  for (j in seq_along(criteria)) cleaned[[criteria[j]]] <- as.integer(cells[[j]]$Score[keep])
  rownames(cleaned) <- NULL
  list(ratings = ratings, wide = cleaned, audit = audit,
    counts = data.frame(Quantity = c("CandidatePairs", "ExcludedPairs", "RetainedPairs", "Ratings"),
      Count = c(nrow(wide), sum(!keep), sum(keep), nrow(ratings))))
}

read_icnale_caf <- function(workbook) {
  icnale_require(requireNamespace("readxl", quietly = TRUE), "Install readxl before reading the workbook.")
  workbook <- normalizePath(workbook, mustWork = TRUE)
  checksum <- unname(tools::md5sum(workbook))
  read_sheet <- function(sheet, skip) {
    x <- as.data.frame(readxl::read_excel(workbook, sheet = sheet, skip = skip,
      col_types = "text", trim_ws = FALSE, .name_repair = "minimal"))
    names(x) <- trimws(names(x)); x
  }
  columns <- c("Complexity (Language)", "Accuracy (Language)", "Fluency (Language)")
  raw <- read_sheet("3_Rating", 2L)
  required <- c("Seq", "S/E", "Sample Code", "Rater Code", "Original Code", "Region", "L2 Proficiency", columns)
  icnale_require(all(required %in% names(raw)), "Unexpected 3_Rating columns; this reader targets GRA v2.1.")
  icnale_require(!anyNA(raw$`S/E`) && all(raw$`S/E` %in% c("S", "E")), "Unknown speech/essay codes.")
  raw$ExcelRow <- seq_len(nrow(raw)) + 3L
  essays <- raw[raw$`S/E` == "E", ]
  icnale_require(!anyNA(essays[setdiff(required, columns)]) && !anyDuplicated(essays$Seq) &&
    !anyDuplicated(essays[c("Sample Code", "Rater Code")]) && nrow(essays) == 140L * 80L &&
    setequal(essays$`Sample Code`, sprintf("Essay_%03d", 1:140)) &&
    setequal(essays$`Rater Code`, sprintf("W_%03d", 1:80)), "Unexpected v2.1 essay-rating layout or identifiers.")
  raters <- read_sheet("2_Rater", 1L)
  icnale_require(all(c("S/E", "Rater Code") %in% names(raters)), "Missing rater identifiers.")
  ids <- raters$`Rater Code`[!is.na(raters$`S/E`) & raters$`S/E` == "E"]
  icnale_require(length(ids) == 80L && !anyDuplicated(ids) &&
    setequal(ids, sprintf("E_%03d", 1:80)), "Unexpected v2.1 essay-rater metadata.")
  # The W_ -> E_ crosswalk is restricted to essays. S_ numbers do not identify
  # the same people; no cross-modality identity is inferred here.
  check <- as.data.frame(readxl::read_excel(workbook, sheet = "6_Check", range = "A2:Q22402",
    col_types = "text", .name_repair = "minimal"))
  icnale_require(all(c("Seq", "Rater", columns) %in% names(check)) && !anyDuplicated(check$Seq),
    "Unexpected verification-sheet keys.")
  ix <- match(essays$Seq, check$Seq)
  icnale_require(!anyNA(ix) && identical(check$Rater[ix], sub("^W_", "E_", essays$`Rater Code`)) &&
    all(vapply(columns, function(name) identical(check[[name]][ix], essays[[name]]), logical(1))),
    "The essay rater crosswalk or CAF ratings disagree with 6_Check.")
  samples <- unique(essays[c("Sample Code", "Original Code", "Region", "L2 Proficiency")])
  icnale_require(nrow(samples) == 140L && !anyDuplicated(samples$`Sample Code`) &&
    !anyDuplicated(samples$`Original Code`) && sum(samples$Region == "ENS") == 4L &&
    all((samples$Region == "ENS") == (samples$`L2 Proficiency` == "ENS")), "Inconsistent essay metadata.")
  selected <- essays[essays$Region != "ENS", ]
  wide <- data.frame(Person = selected$`Sample Code`, Rater = sub("^W_", "E_", selected$`Rater Code`),
    Seq = selected$Seq, ExcelRow = selected$ExcelRow, OriginalRater = selected$`Rater Code`,
    Complexity = selected[[columns[1]]], Accuracy = selected[[columns[2]]], Fluency = selected[[columns[3]]])
  wide <- wide[order(wide$Person, wide$Rater), ]
  out <- icnale_clean_caf(wide)
  icnale_require(length(unique(out$ratings$Person)) == 136L &&
    setequal(out$ratings$Rater, ids), "Cleaning removed an entire writer or rater; review before fitting.")
  out$counts <- rbind(data.frame(Quantity = c("Persons", "Raters", "Criteria"), Count = c(136L, 80L, 3L)), out$counts)
  out$source_md5 <- checksum
  out$selection <- "Human essay ratings; exclude ENS; CAF only; remove the entire Person-Rater triple if any score is not an integer in 0:10."
  out$category_counts <- as.data.frame(table(Criterion = factor(out$ratings$Criterion,
    levels = c("Complexity", "Accuracy", "Fluency")), Score = factor(out$ratings$Score, levels = 0:10)))
  icnale_require(identical(checksum, unname(tools::md5sum(workbook))), "The input workbook changed while reading.")
  out
}
