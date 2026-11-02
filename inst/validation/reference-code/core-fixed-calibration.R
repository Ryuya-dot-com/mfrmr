# Repository-only typed-anchor construction used by independent constraint checks.
mfrmr_apply_typed_anchors <- function(config, anchors) {
  incoming <- mfrmr_normalize_typed_anchors(config, anchors)
  if (nrow(incoming$anchors) == 0L) {
    out <- config
    out$step_specs <- mfrmr_step_specs(config)
    existing <- mfrmr_normalize_typed_anchors(
      out, mfrmr_typed_anchors_from_config(out)
    )
    out$typed_anchors <- existing$anchors
    out$typed_anchor_notes <- existing$notes
    return(list(config = out, anchors = existing$anchors,
                notes = existing$notes))
  }
  existing <- mfrmr_typed_anchors_from_config(config)
  combined <- rbind(existing, incoming$anchors)
  combined$AnchorId <- sprintf("combined::%d", seq_len(nrow(combined)))
  combined$DeclarationOrder <- as.integer(seq_len(nrow(combined)))
  normalized <- mfrmr_normalize_typed_anchors(config, combined)
  declarations <- normalized$anchors
  notes <- rbind(incoming$notes, normalized$notes)
  if (nrow(notes) > 0L) {
    notes <- notes[!duplicated(paste(notes$Code, notes$Selector, notes$Count,
                                     notes$Detail, sep = "\r")), , drop = FALSE]
    rownames(notes) <- NULL
  }

  out <- config
  for (facet in as.character(config$facet_names)) {
    direct <- declarations[
      declarations$AnchorType == "direct" &
        declarations$OwnerFacet == facet, , drop = FALSE
    ]
    group <- declarations[
      declarations$AnchorType == "group" &
        declarations$OwnerFacet == facet, , drop = FALSE
    ]
    anchors_map <- if (nrow(direct)) setNames(direct$Value, direct$Level) else NULL
    groups_map <- if (nrow(group)) setNames(group$GroupId, group$Level) else NULL
    group_values <- if (nrow(group)) {
      values <- group$Value[!duplicated(group$GroupId)]
      setNames(values, group$GroupId[!duplicated(group$GroupId)])
    } else {
      NULL
    }
    spec <- tryCatch(
      build_facet_constraint(
        levels = config$facet_specs[[facet]]$levels,
        anchors = anchors_map,
        groups = groups_map,
        group_values = group_values,
        centered = isTRUE(config$facet_specs[[facet]]$centered),
        centering_scope = config$facet_specs[[facet]]$centering_scope %||% "remainder"
      ),
      error = function(error) {
        mfrmr_calibration_abort(
          "ANCHOR_CONSTRAINT_INCOMPATIBLE", "constraints.anchors",
          paste0("facet `", facet, "`: ", conditionMessage(error))
        )
      }
    )
    for (group_id in unique(stats::na.omit(spec$groups))) {
      members <- which(spec$groups == group_id)
      if (all(is.finite(spec$anchors[members]))) {
        target <- spec$group_values[[group_id]] * length(members)
        if (!isTRUE(all.equal(sum(spec$anchors[members]), target,
                              tolerance = 1e-12))) {
          mfrmr_calibration_abort(
            "ANCHOR_CONSTRAINT_INCOMPATIBLE", "constraints.anchors",
            paste0("fully fixed group `", facet, "::", group_id,
                   "` violates its declared mean")
          )
        }
      }
    }
    out$facet_specs[[facet]] <- spec
  }

  n_steps <- max(as.integer(config$n_cat) - 1L, 0L)
  scopes <- if (identical(config$model, "RSM")) {
    "shared"
  } else {
    as.character(config$facet_levels[[config$step_facet]])
  }
  out$step_specs <- lapply(scopes, function(scope) {
    selected <- if (identical(config$model, "RSM")) {
      declarations[declarations$AnchorType == "shared_step", , drop = FALSE]
    } else {
      declarations[
        declarations$AnchorType == "owned_step" &
          declarations$Level == scope, , drop = FALSE
      ]
    }
    values <- if (nrow(selected)) setNames(selected$Value, selected$Step) else NULL
    tryCatch(
      build_step_constraint(
        n_steps, anchors = values, target = 0, scope = scope
      ),
      error = function(error) {
        mfrmr_calibration_abort(
          "ANCHOR_CONSTRAINT_INCOMPATIBLE", "constraints.anchors",
          conditionMessage(error)
        )
      }
    )
  })
  names(out$step_specs) <- scopes
  out$typed_anchors <- declarations
  out$typed_anchor_notes <- notes
  sizes <- build_param_sizes(out)
  for (facet in as.character(out$facet_names)) {
    facet_jacobian <- mfrmr_constraint_jacobian_sparse(
      out$facet_specs[[facet]], facet
    )$jacobian
    if (ncol(facet_jacobian) > 0L &&
        Matrix::rankMatrix(facet_jacobian)[1] != ncol(facet_jacobian)) {
      mfrmr_calibration_abort(
        "ANCHOR_RANK_DEFICIENT", "constraints.anchors",
        paste0("typed facet constraint for `", facet,
               "` is not full column rank")
      )
    }
  }
  step_jacobian <- mfrmr_step_jacobian_sparse(out, sizes)$jacobian
  if (ncol(step_jacobian) > 0L && Matrix::rankMatrix(step_jacobian)[1] !=
      ncol(step_jacobian)) {
    mfrmr_calibration_abort(
      "ANCHOR_RANK_DEFICIENT", "constraints.anchors",
      "typed step constraint Jacobian is not full column rank"
    )
  }
  list(config = out, anchors = declarations, notes = notes)
}
