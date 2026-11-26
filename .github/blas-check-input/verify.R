# Bind this verification branch to the submitted source and actual BLAS/LAPACK.
archive <- ".github/blas-check-input/mfrmr_0.3.2.tar.gz"
unpacked <- tempfile("mfrmr-source-")
dir.create(unpacked)
utils::untar(archive, exdir = unpacked, tar = "internal")
source <- file.path(unpacked, "mfrmr")
for (path in list.files(file.path(source, "R"), pattern = "[.]R$")) {
  stopifnot(identical(parse(file.path(source, "R", path), keep.source = FALSE),
                      parse(file.path("R", path), keep.source = FALSE)))
}
files <- list.files(source, recursive = TRUE)
files <- files[grepl("^(src|man|tests|data|vignettes|inst/examples)/", files) |
  files %in% c("NAMESPACE", "README.md", "NEWS.md", "inst/NEWS-0.2.4-details.md")]
stopifnot(identical(unname(tools::md5sum(file.path(source, files))),
                    unname(tools::md5sum(files))))
a <- read.dcf(file.path(source, "DESCRIPTION"))
b <- read.dcf("DESCRIPTION")
normalize <- function(x) trimws(gsub("[[:space:]]+", " ", x))
stopifnot(identical(normalize(a[1, colnames(b)]), normalize(b[1, ])))

# Resolve both libraries after using BLAS and LAPACK; a job label is insufficient.
x <- matrix(seq_len(100), 10L)
invisible(crossprod(x))
invisible(svd(x))
blas <- extSoftVersion()[["BLAS"]]
lapack <- La_library()
expected <- Sys.getenv("MFRMR_EXPECTED_BLAS")
stopifnot(expected %in% c("mkl", "openblas"),
          grepl(expected, blas, ignore.case = TRUE),
          grepl(expected, lapack, ignore.case = TRUE))
cat("Commit:", Sys.getenv("GITHUB_SHA"), "\n",
    "Container:", Sys.getenv("MFRMR_CONTAINER"), "\n",
    "BLAS:", blas, "\nLAPACK:", lapack, "\n")
print(sessionInfo())
cat("Source archive, checkout and active backend agree.\n")
