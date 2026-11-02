# Run from the repository root before publishing source or building the site.
# Include new, non-ignored files so local checks work before git add.
tracked <- system2("git", c("-c", "core.quotepath=false", "ls-files",
                           "--cached", "--others", "--exclude-standard"), stdout = TRUE)
if (!is.null(attr(tracked, "status"))) stop("Cannot inspect tracked source files.")
tracked <- unique(tracked)
private <- grepl("(^|/)AGENTS[.]md$|^inst/validation/.*roadmap.*[.]md$", tracked) |
  tracked %in% c(
    "inst/validation/release-gate-spec-0.2.3.md",
    "inst/validation/release-spine-priority-queue-0.2.3.md",
    "inst/validation/measurement-extension-next-decisions-0.2.4.md")
if (any(private)) stop("Private maintainer files are tracked or not ignored: ",
  paste(tracked[private], collapse = ", "))

# Research scripts can bind original protocol paths as archived input identities.
# Public prose must not link to private plans; text must not contain personal
# machine paths. This is not a general secrets scanner.
public <- tracked[grepl("^(README[.]md|NEWS[.]md|ROADMAP[.]md|CONTRIBUTING[.]md|_pkgdown[.]yml)$|^(R/.*[.]R|man/.*[.]Rd|vignettes/.*[.]Rmd|inst/(doc|examples|extdata|model-export)/.*[.](R|Rmd|md|txt|html|csv|json|yaml|yml))$", tracked)]
public <- public[file.exists(public)]
research <- tracked[grepl("^inst/validation/.*[.](R|Rmd|md|txt|csv|json|py|yaml|yml)$", tracked)]
research <- research[file.exists(research)]
violations <- character()
for (path in unique(c(public, research))) {
  lines <- readLines(path, warn = FALSE, encoding = "UTF-8")
  hit <- grepl("/Users/(tohokusla|ryuya)/|/home/runner/", lines)
  if (path %in% public || endsWith(path, ".md")) hit <- hit | grepl(
    "internal-roadmap|release-gate-spec|release-spine-priority-queue|measurement-extension-next-decisions", lines)
  if (any(hit)) violations <- c(violations, paste0(path, ":", which(hit)))
}
if (length(violations)) stop("Private references in public documentation/code: ",
  paste(violations, collapse = ", "))

# Citation version and release date must describe this source. Roadmap prose
# and historical research approvals are not machine-readable release metadata.
description <- read.dcf("DESCRIPTION")
field <- function(name) {
  if (name %in% colnames(description)) unname(description[1, name]) else NA_character_
}
cff <- readLines("CITATION.cff", warn = FALSE)
cff_field <- function(name) {
  value <- grep(paste0("^", name, ":"), cff, value = TRUE)
  if (!length(value)) return(NA_character_)
  if (length(value) != 1L) stop("Duplicate CITATION.cff field: ", name)
  sub("['\"]$", "", sub("^['\"]", "", trimws(sub("^[^:]+:", "", value))))
}
version <- field("Version")
status <- field("Config/mfrmr/release-status")
if (is.na(version) || !identical(version, cff_field("version")))
  stop("DESCRIPTION and CITATION.cff versions differ.")
if (!status %in% c("development", "candidate", "released"))
  stop("Unknown release status in DESCRIPTION.")
if (status == "development") {
  if (!is.na(field("Date")) || !is.na(cff_field("date-released")))
    stop("Development sources must not declare a release date.")
} else if (is.na(field("Date")) || !identical(field("Date"), cff_field("date-released"))) {
  stop("Dated sources require matching DESCRIPTION and CITATION.cff dates.")
}
public_version <- field("Config/mfrmr/public-version")
if (is.na(public_version) ||
    (status == "released" && !identical(public_version, version)) ||
    (status != "released" && utils::compareVersion(public_version, version) >= 0L))
  stop("The declared public version conflicts with this source's release status.")
baseline <- read.csv("inst/validation/public-release-baseline-0.2.4.csv",
                     stringsAsFactors = FALSE)
if (!all(c("Field", "Value") %in% names(baseline)) ||
    anyDuplicated(baseline$Field) ||
    !identical(baseline$Value[baseline$Field == "PublicVersion"], public_version) ||
    !identical(length(baseline$Value[baseline$Field == "CranSourceSHA256"]), 1L) ||
    !grepl("^[a-f0-9]{64}$", baseline$Value[baseline$Field == "CranSourceSHA256"]))
  stop("Public release baseline is missing or inconsistent with DESCRIPTION.")
cat("Public source and version checks passed (", length(public),
    " user-facing files; ", length(research),
    " research files checked for personal paths and private-plan references in prose).\n", sep = "")
