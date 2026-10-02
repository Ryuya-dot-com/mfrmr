# Bind prespecified A/B contrasts and slope outputs to truth only for analysis.
# Source stage helpers, multi-output and recovery first. Selection never sees
# reference values, coverage or a preferred model/correction order.
wide_interval_spec <- function(input, spec, level = .95) {
  wide_recovery_plan(input, spec) # Check the frozen data/truth/coordinate contract.
  contrasts <- wide_recovery_contrasts(input)
  spec$level <- level
  spec$outputs <- setNames(lapply(names(contrasts), function(facet)
    list(kind = "contrast", facet = facet, contrasts = contrasts[[facet]])),
    tolower(names(contrasts)))
  if (spec$args$model == "GPCM") spec$outputs$slopes <- list(kind = "slopes")
  wide_multi_validate(spec)
  spec
}

wide_interval_plan <- function(input, spec) {
  wide_recovery_plan(input, spec)
  plan <- wide_multi_plan(spec)
  for (id in names(spec$outputs)) {
    consumer <- spec$outputs[[id]]; t <- wide_multi_targets(spec, consumer)
    reference <- if (consumer$kind == "contrast") {
      C <- wide_multi_contrast(spec, consumer)
      drop(C %*% input$truth[[consumer$facet]][colnames(C)])
    } else if (consumer$kind == "slopes") {
      stopifnot(identical(spec$args$slope_facet, "Criterion"))
      unname(input$truth$log_slopes[t$Level])
    } else stop("The A/B interval ledger expects declared contrasts or slopes.")
    ix <- plan$Consumer == id
    plan$ReferenceValue[ix] <- reference[match(plan$Target[ix], t$Target)]
    plan$Reference[ix] <- "generating_parameter"
    plan$Procedure[ix & plan$Output == "point"] <- "first_admitted_scoring_source"
    plan$Procedure[ix & plan$Output == "interval"] <- if (spec$args$method == "JML") "unsupported" else
      if (consumer$kind == "slopes") "one_family_relative_slope_model" else
      if (spec$args$model %in% c("RSM", "PCM") && is.null(spec$args$population_formula))
        "fixed_population_model_existing" else "mml_native_location_model_v1"
  }
  plan$InputId <- input$InputId
  stopifnot(all(is.finite(plan$ReferenceValue)))
  plan
}

wide_interval_recovery <- function(input, spec, selected) {
  plan <- wide_interval_plan(input, spec)
  records <- wide_multi_records(spec, selected)
  rows <- wide_output_records(plan, records)
  list(plan = plan, records = records, summary = wide_output_summary(plan, records), rows = rows,
    interpretation = "Source-reviewed points and separately selected model intervals on generating targets; initial-call recovery remains separate. JML structural intervals are unsupported.")
}
