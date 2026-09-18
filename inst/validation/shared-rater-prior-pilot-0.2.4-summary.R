# Read saved summaries only. No sampling, response generation or retuning.
summarize_shared_rater_prior_pilot <- function() {
  prefix <- 'inst/validation/shared-rater-prior-pilot-0.2.4'
  x <- read.csv(paste0(prefix, '-summary.csv'))
  stopifnot(!anyDuplicated(x[c('Design', 'Prior', 'Target')]))
  base <- x[x$Prior == 'baseline', ]
  other <- x[x$Prior != 'baseline', ]
  key <- function(d) paste(d$Design, d$Target, sep = ':')
  index <- match(key(other), key(base))
  stopifnot(!anyNA(index))
  b <- base[index, ]
  sensitivity <- data.frame(Design = other$Design, Prior = other$Prior,
    Target = other$Target, Kind = other$Kind,
    Available = other$Available & b$Available,
    BaselineSD = b$SD, DeltaMean = other$Mean - b$Mean,
    DeltaMeanInBaselineSD = (other$Mean - b$Mean) / b$SD,
    MCSEDeltaMean = sqrt(other$MCSEMean^2 + b$MCSEMean^2),
    WidthRatio = (other$Upper - other$Lower) / (b$Upper - b$Lower),
    DeltaLower = other$Lower - b$Lower, DeltaUpper = other$Upper - b$Upper,
    MCSEDeltaLower = sqrt(other$MCSELower^2 + b$MCSELower^2),
    MCSEDeltaUpper = sqrt(other$MCSEUpper^2 + b$MCSEUpper^2))
  write.csv(sensitivity, paste0(prefix, '-sensitivity.csv'), row.names = FALSE)
  print(x[x$Target %in% c('alpha', 'RaterSD', 'RaterVariance'),
    c('Design', 'Prior', 'Target', 'Mean', 'Lower', 'Upper', 'Available')], row.names = FALSE)
  invisible(sensitivity)
}

if (sys.nframe() == 0L) summarize_shared_rater_prior_pilot()
