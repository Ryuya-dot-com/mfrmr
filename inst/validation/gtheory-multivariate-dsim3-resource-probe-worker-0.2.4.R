# Standalone nonreserved worker for D-SIM-3 resource-controller qualification.
#
# This worker performs mechanics probes only. It does not source mfrmr, open an
# RNG stream, generate a response, call a backend, fit a model, or compute a
# metric.

mfrmr_gtds3uw_stop <- function(message) {
  cat(paste0("DSIM3_RESOURCE_PROBE_ERROR:", message, "\n"), file = stderr())
  quit(save = "no", status = 64L, runLast = FALSE)
}

mfrmr_gtds3uw_args <- function(arguments = commandArgs(trailingOnly = TRUE)) {
  if (length(arguments) != 3L) {
    mfrmr_gtds3uw_stop("expected action, duration, and allocation")
  }
  action <- arguments[[1L]]
  duration <- suppressWarnings(as.numeric(arguments[[2L]]))
  allocation_mib <- suppressWarnings(as.integer(arguments[[3L]]))
  if (!action %in% c("success", "sleep", "memory", "hold") ||
      length(duration) != 1L || is.na(duration) || !is.finite(duration) ||
      duration < 0 || length(allocation_mib) != 1L ||
      is.na(allocation_mib) || allocation_mib < 0L ||
      allocation_mib > 512L) {
    mfrmr_gtds3uw_stop("invalid mechanics-probe arguments")
  }
  list(
    Action = action, DurationSeconds = duration,
    AllocationMiB = allocation_mib
  )
}

mfrmr_gtds3uw_touch_memory <- function(allocation_mib) {
  bytes <- as.double(allocation_mib) * 1024^2
  if (bytes > .Machine$integer.max) {
    mfrmr_gtds3uw_stop("allocation exceeds one raw-vector limit")
  }
  value <- raw(as.integer(bytes))
  if (length(value) > 0L) value[] <- as.raw(1L)
  value
}

mfrmr_gtds3uw_main <- function() {
  arguments <- mfrmr_gtds3uw_args()
  if (arguments$Action == "memory") {
    retained <- mfrmr_gtds3uw_touch_memory(arguments$AllocationMiB)
    cat("DSIM3_RESOURCE_MEMORY_READY\n")
    flush.console()
    Sys.sleep(arguments$DurationSeconds)
    invisible(length(retained))
  } else if (arguments$Action %in% c("sleep", "hold")) {
    cat(paste0("DSIM3_RESOURCE_", toupper(arguments$Action), "_READY\n"))
    flush.console()
    Sys.sleep(arguments$DurationSeconds)
  } else {
    Sys.sleep(arguments$DurationSeconds)
  }
  cat("DSIM3_RESOURCE_PROBE_COMPLETE\n")
  invisible(TRUE)
}

if (identical(environment(), globalenv()) && !interactive()) {
  mfrmr_gtds3uw_main()
}
