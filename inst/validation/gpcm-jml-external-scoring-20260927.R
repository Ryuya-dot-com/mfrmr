# Run from package root. Reuse qualified JML fits; no refitting or coverage study.
pkgload::load_all(".", quiet = TRUE, compile = FALSE)
source("inst/validation/gpcm-fixed-scoring-tam-20260926.R")
source("inst/validation/gpcm-fixed-scoring-conquest-20260926.R")
out <- "validation-results/gpcm-jml-external-scoring-20260927"
paths <- c(Criterion = "validation-results/portable-gpcm-jml-20260927/source.rds",
  Rater = "validation-results/portable-gpcm-jml-20260927/rater-source.rds")
# The retained 101/141 comparison failed the predeclared 1e-7 stability
# criterion for Criterion ownership; refine scoring only, not the calibration.
reference <- run_gpcm_fixed_scoring_tam(file.path(out, "reference"), paths,
  native_nodes = c(141L, 181L))
sensitivity <- run_gpcm_fixed_scoring_tam(file.path(out, "sensitivity"), paths,
  scoring_prior = list(mean = .25, sd = 1.2), native_nodes = c(181L, 241L))
fixed <- c(setNames(reference, paste0(names(reference), "_reference")),
  setNames(sensitivity, paste0(names(sensitivity), "_sensitivity")))
saveRDS(fixed, file.path(out, "results.rds"))
prepare_gpcm_fixed_scoring_conquest(file.path(out, "conquest"), file.path(out, "results.rds"))
check_gpcm_conquest_input_map(file.path(out, "conquest"))
# Execute separately outside the sandbox, as requested:
# run_gpcm_fixed_scoring_conquest(file.path(out, "conquest"))
# summarize_gpcm_fixed_scoring_conquest(file.path(out, "conquest"))
