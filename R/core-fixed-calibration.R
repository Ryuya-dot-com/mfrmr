# Internal fixed-calibration lifecycle for the bounded 0.2.4 core.
#
# These functions are deliberately unexported while the G1 evidence gates are
# open. They support only one-scale, one-dimensional RSM/PCM MML fits with an
# unconditional fixed-standard-normal scoring basis.

mfrmr_calibration_schema_id <- function() "mfrmr.fixed_calibration"

mfrmr_calibration_schema_version <- function() 1L

mfrmr_calibration_semantic_identity_version <- function() {
  "mfrmr-calibration-semantic-identity-v1"
}

mfrmr_calibration_now_utc <- function() {
  format(Sys.time(), "%Y-%m-%dT%H:%M:%OS6Z", tz = "UTC")
}

mfrmr_calibration_is_utc_timestamp <- function(value) {
  is.character(value) && length(value) == 1L && !is.na(value) &&
    grepl(
      "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}([.][0-9]+)?Z$",
      value
    ) && !is.na(suppressWarnings(as.POSIXct(
      sub("Z$", "", value), format = "%Y-%m-%dT%H:%M:%OS", tz = "UTC"
    )))
}

mfrmr_calibration_refusal <- function(code, field_path, detail) {
  n <- length(code)
  data.frame(
    Code = as.character(code),
    FieldPath = as.character(field_path),
    Detail = as.character(detail),
    Severity = rep("error", n),
    stringsAsFactors = FALSE
  )
}

mfrmr_calibration_empty_refusals <- function() {
  mfrmr_calibration_refusal(character(0), character(0), character(0))
}

mfrmr_calibration_abort <- function(code, field_path, detail,
                                    refusals = NULL) {
  code <- as.character(code[1])
  field_path <- as.character(field_path[1])
  detail <- as.character(detail[1])
  message <- paste0(code, " at `", field_path, "`: ", detail)
  condition <- structure(
    list(
      message = message,
      call = NULL,
      code = code,
      field_path = field_path,
      detail = detail,
      refusals = refusals %||% mfrmr_calibration_refusal(
        code, field_path, detail
      )
    ),
    class = c("mfrm_calibration_error", "error", "condition")
  )
  stop(condition)
}

mfrmr_calibration_abort_review <- function(refusals) {
  if (!is.data.frame(refusals) || nrow(refusals) == 0L) {
    return(invisible(NULL))
  }
  mfrmr_calibration_abort(
    refusals$Code[1], refusals$FieldPath[1], refusals$Detail[1], refusals
  )
}

mfrmr_calibration_bind_rows <- function(rows, template) {
  if (length(rows) == 0L) return(template)
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}

mfrmr_calibration_coordinate_template <- function() {
  data.frame(
    CoordinateKey = character(0),
    ParameterClass = character(0),
    OwnerFacet = character(0),
    Level = character(0),
    Step = character(0),
    InteractionId = character(0),
    Value = numeric(0),
    OrderIndex = integer(0),
    stringsAsFactors = FALSE
  )
}

mfrmr_calibration_anchor_template <- function() {
  data.frame(
    AnchorId = character(0),
    AnchorType = character(0),
    ParameterClass = character(0),
    OwnerFacet = character(0),
    Level = character(0),
    Step = character(0),
    GroupId = character(0),
    Value = numeric(0),
    CoordinateSystem = character(0),
    DeclarationOrder = integer(0),
    stringsAsFactors = FALSE
  )
}

mfrmr_typed_anchor_note_template <- function() {
  data.frame(
    Code = character(0),
    Selector = character(0),
    Count = integer(0),
    Detail = character(0),
    stringsAsFactors = FALSE
  )
}

mfrmr_typed_anchor_abort <- function(code, field_path, detail) {
  mfrmr_calibration_abort(code, field_path, detail)
}

mfrmr_normalize_typed_anchors <- function(config, anchors) {
  expected <- names(mfrmr_calibration_anchor_template())
  if (!is.data.frame(anchors) || !identical(names(anchors), expected)) {
    mfrmr_typed_anchor_abort(
      "ANCHOR_DECLARATION_INVALID", "constraints.anchors",
      "typed anchors must use the exact registered columns"
    )
  }
  if (nrow(anchors) == 0L) {
    return(list(
      anchors = mfrmr_calibration_anchor_template(),
      notes = mfrmr_typed_anchor_note_template()
    ))
  }
  character_columns <- setdiff(expected, c("Value", "DeclarationOrder"))
  if (any(!vapply(anchors[character_columns], is.character, logical(1))) ||
      !is.numeric(anchors$Value) || !is.integer(anchors$DeclarationOrder)) {
    mfrmr_typed_anchor_abort(
      "ANCHOR_DECLARATION_INVALID", "constraints.anchors",
      "typed anchor columns must retain their registered storage types"
    )
  }
  if (anyNA(anchors$AnchorId) || any(!nzchar(anchors$AnchorId)) ||
      anyDuplicated(anchors$AnchorId)) {
    mfrmr_typed_anchor_abort(
      "ANCHOR_DECLARATION_INVALID", "constraints.anchors.AnchorId",
      "declaration identifiers must be nonempty and unique"
    )
  }
  if (anyNA(anchors$DeclarationOrder) || any(anchors$DeclarationOrder < 1L) ||
      anyDuplicated(anchors$DeclarationOrder)) {
    mfrmr_typed_anchor_abort(
      "ANCHOR_DECLARATION_INVALID", "constraints.anchors.DeclarationOrder",
      "declaration order must be unique and positive but never sets precedence"
    )
  }
  if (any(!is.finite(anchors$Value))) {
    mfrmr_typed_anchor_abort(
      "ANCHOR_DECLARATION_INVALID", "constraints.anchors.Value",
      "every anchor value must be finite"
    )
  }
  if (anyNA(anchors$CoordinateSystem) ||
      any(anchors$CoordinateSystem != "expanded_logit")) {
    mfrmr_typed_anchor_abort(
      "ANCHOR_COORDINATE_SYSTEM_INVALID", "constraints.anchors.CoordinateSystem",
      "core anchors must use the exact expanded_logit coordinate system"
    )
  }

  missing_text <- function(value) is.na(value) | !nzchar(value)
  present_text <- function(value) !missing_text(value)
  facet_names <- as.character(config$facet_names %||% character(0))
  facet_levels <- config$facet_levels %||% list()
  n_steps <- max(as.integer(config$n_cat %||% 0L) - 1L, 0L)
  family <- as.character(config$model %||% NA_character_)
  step_owner <- as.character(config$step_facet %||% NA_character_)
  valid_types <- c("direct", "group", "shared_step", "owned_step")
  if (anyNA(anchors$AnchorType) || any(!anchors$AnchorType %in% valid_types)) {
    mfrmr_typed_anchor_abort(
      "ANCHOR_DECLARATION_INVALID", "constraints.anchors.AnchorType",
      "anchor type is not registered for the core lane"
    )
  }

  for (i in seq_len(nrow(anchors))) {
    row <- anchors[i, , drop = FALSE]
    path <- paste0("constraints.anchors[", i, "]")
    type <- row$AnchorType
    if (type %in% c("direct", "group")) {
      if (!identical(row$ParameterClass, "facet") ||
          missing_text(row$OwnerFacet) || missing_text(row$Level) ||
          present_text(row$Step) ||
          (identical(type, "direct") && present_text(row$GroupId)) ||
          (identical(type, "group") && missing_text(row$GroupId))) {
        mfrmr_typed_anchor_abort(
          "ANCHOR_SELECTOR_INVALID", path,
          "facet anchors have an invalid direct/group selector shape"
        )
      }
      if (!row$OwnerFacet %in% facet_names) {
        mfrmr_typed_anchor_abort(
          "ANCHOR_OWNER_UNKNOWN", paste0(path, ".OwnerFacet"),
          "facet owner is not declared by the model"
        )
      }
      if (!row$Level %in% as.character(facet_levels[[row$OwnerFacet]])) {
        mfrmr_typed_anchor_abort(
          "ANCHOR_LEVEL_UNKNOWN", paste0(path, ".Level"),
          "facet level is not declared under the selected owner"
        )
      }
    } else if (identical(type, "shared_step")) {
      if (!identical(row$ParameterClass, "shared_step") ||
          present_text(row$OwnerFacet) || present_text(row$Level) ||
          missing_text(row$Step) || present_text(row$GroupId)) {
        mfrmr_typed_anchor_abort(
          "ANCHOR_SELECTOR_INVALID", path,
          "shared-step anchors require only a transition selector"
        )
      }
      if (!identical(family, "RSM")) {
        mfrmr_typed_anchor_abort(
          "ANCHOR_OWNER_INCOMPATIBLE", path,
          "shared-step anchors belong only to RSM"
        )
      }
    } else {
      if (!identical(row$ParameterClass, "owned_step") ||
          missing_text(row$OwnerFacet) || missing_text(row$Level) ||
          missing_text(row$Step) || present_text(row$GroupId)) {
        mfrmr_typed_anchor_abort(
          "ANCHOR_SELECTOR_INVALID", path,
          "owned-step anchors require owner, owner level, and transition"
        )
      }
      if (!identical(family, "PCM") || !identical(row$OwnerFacet, step_owner)) {
        mfrmr_typed_anchor_abort(
          "ANCHOR_OWNER_INCOMPATIBLE", paste0(path, ".OwnerFacet"),
          "owned-step anchor does not belong to the declared PCM step owner"
        )
      }
      if (!row$Level %in% as.character(facet_levels[[step_owner]])) {
        mfrmr_typed_anchor_abort(
          "ANCHOR_LEVEL_UNKNOWN", paste0(path, ".Level"),
          "owned-step level is not declared under the step owner"
        )
      }
    }
    if (type %in% c("shared_step", "owned_step")) {
      step <- suppressWarnings(as.integer(row$Step))
      if (is.na(step) || step < 1L || step > n_steps ||
          !identical(as.character(step), row$Step)) {
        mfrmr_typed_anchor_abort(
          "ANCHOR_STEP_UNKNOWN", paste0(path, ".Step"),
          "transition must be a canonical integer in the declared category range"
        )
      }
    }
  }

  semantic_key <- ifelse(
    anchors$AnchorType == "direct",
    paste("direct", anchors$OwnerFacet, anchors$Level, sep = "::"),
    ifelse(
      anchors$AnchorType == "group",
      paste("group_member", anchors$OwnerFacet, anchors$Level, sep = "::"),
      ifelse(
        anchors$AnchorType == "shared_step",
        paste("shared_step", anchors$Step, sep = "::"),
        paste("owned_step", anchors$OwnerFacet, anchors$Level,
              anchors$Step, sep = "::")
      )
    )
  )
  group_target_key <- ifelse(
    anchors$AnchorType == "group",
    paste("group_target", anchors$OwnerFacet, anchors$GroupId, sep = "::"),
    NA_character_
  )
  conflict <- function(key, include_group) {
    for (value in unique(key[!is.na(key)])) {
      index <- which(key == value)
      signatures <- if (include_group) {
        paste(anchors$GroupId[index], sprintf("%.17g", anchors$Value[index]),
              sep = "\r")
      } else {
        sprintf("%.17g", anchors$Value[index])
      }
      if (length(unique(signatures)) > 1L) return(value)
    }
    NA_character_
  }
  conflict_selector <- conflict(semantic_key, include_group = TRUE)
  if (!is.na(conflict_selector)) {
    mfrmr_typed_anchor_abort(
      "ANCHOR_CONFLICT", "constraints.anchors",
      paste0("conflicting declarations target selector `", conflict_selector, "`")
    )
  }
  group_conflict <- conflict(group_target_key, include_group = FALSE)
  if (!is.na(group_conflict)) {
    mfrmr_typed_anchor_abort(
      "ANCHOR_CONFLICT", "constraints.anchors",
      paste0("group mean differs within selector `", group_conflict, "`")
    )
  }

  duplicate_groups <- split(seq_len(nrow(anchors)), semantic_key)
  duplicate_groups <- duplicate_groups[lengths(duplicate_groups) > 1L]
  notes <- if (length(duplicate_groups) == 0L) {
    mfrmr_typed_anchor_note_template()
  } else {
    do.call(rbind, lapply(names(duplicate_groups), function(selector) {
      data.frame(
        Code = "ANCHOR_DUPLICATE_DEDUPLICATED",
        Selector = selector,
        Count = as.integer(length(duplicate_groups[[selector]])),
        Detail = "identical declarations were collapsed without precedence",
        stringsAsFactors = FALSE
      )
    }))
  }
  keep <- vapply(duplicate_groups <- split(seq_len(nrow(anchors)), semantic_key),
                 function(index) index[1], integer(1))
  out <- anchors[sort(keep), , drop = FALSE]

  facet_index <- match(out$OwnerFacet, facet_names)
  facet_index[is.na(facet_index)] <- 0L
  level_index <- vapply(seq_len(nrow(out)), function(i) {
    if (is.na(out$OwnerFacet[i]) || !nzchar(out$OwnerFacet[i])) return(0L)
    match(out$Level[i], as.character(facet_levels[[out$OwnerFacet[i]]])) %||% 0L
  }, integer(1))
  step_index <- suppressWarnings(as.integer(out$Step))
  step_index[is.na(step_index)] <- 0L
  type_index <- match(out$AnchorType, valid_types)
  ord <- order(type_index, facet_index, level_index, step_index,
               ifelse(is.na(out$GroupId), "", out$GroupId), method = "radix")
  out <- out[ord, , drop = FALSE]
  rownames(out) <- NULL
  out$AnchorId <- sprintf("typed_anchor::%d", seq_len(nrow(out)))
  out$DeclarationOrder <- as.integer(seq_len(nrow(out)))
  rownames(notes) <- NULL
  list(anchors = out, notes = notes)
}

mfrmr_typed_anchors_from_config <- function(config) {
  rows <- list()
  add <- function(type, parameter_class, owner, level, step, group, value) {
    rows[[length(rows) + 1L]] <<- data.frame(
      AnchorId = paste0("existing::", length(rows) + 1L),
      AnchorType = type,
      ParameterClass = parameter_class,
      OwnerFacet = owner,
      Level = level,
      Step = step,
      GroupId = group,
      Value = as.numeric(value),
      CoordinateSystem = "expanded_logit",
      DeclarationOrder = as.integer(length(rows) + 1L),
      stringsAsFactors = FALSE
    )
  }
  for (facet in as.character(config$facet_names %||% character(0))) {
    spec <- config$facet_specs[[facet]]
    levels <- as.character(spec$levels)
    for (i in which(is.finite(spec$anchors))) {
      add("direct", "facet", facet, levels[i], NA_character_, NA_character_,
          spec$anchors[i])
    }
    groups <- as.character(spec$groups %||% rep(NA_character_, length(levels)))
    for (i in which(!is.na(groups) & nzchar(groups))) {
      add("group", "facet", facet, levels[i], NA_character_, groups[i],
          spec$group_values[[groups[i]]])
    }
  }
  step_specs <- mfrmr_step_specs(config)
  for (scope_index in seq_along(step_specs)) {
    spec <- step_specs[[scope_index]]
    for (step in which(is.finite(spec$anchors))) {
      if (identical(config$model, "RSM")) {
        add("shared_step", "shared_step", NA_character_, NA_character_,
            as.character(step), NA_character_, spec$anchors[step])
      } else {
        add("owned_step", "owned_step", as.character(config$step_facet),
            names(step_specs)[scope_index], as.character(step), NA_character_,
            spec$anchors[step])
      }
    }
  }
  mfrmr_calibration_bind_rows(rows, mfrmr_calibration_anchor_template())
}

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
    spec <- build_facet_constraint(
      levels = config$facet_specs[[facet]]$levels,
      anchors = anchors_map,
      groups = groups_map,
      group_values = group_values,
      centered = isTRUE(config$facet_specs[[facet]]$centered)
    )
    for (group_id in unique(stats::na.omit(spec$groups))) {
      members <- which(spec$groups == group_id)
      if (all(is.finite(spec$anchors[members]))) {
        target <- spec$group_values[[group_id]] * length(members)
        if (!isTRUE(all.equal(sum(spec$anchors[members]), target,
                              tolerance = 1e-12))) {
          mfrmr_typed_anchor_abort(
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
        mfrmr_typed_anchor_abort(
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
      mfrmr_typed_anchor_abort(
        "ANCHOR_RANK_DEFICIENT", "constraints.anchors",
        paste0("typed facet constraint for `", facet,
               "` is not full column rank")
      )
    }
  }
  step_jacobian <- mfrmr_step_jacobian_sparse(out, sizes)$jacobian
  if (ncol(step_jacobian) > 0L && Matrix::rankMatrix(step_jacobian)[1] !=
      ncol(step_jacobian)) {
    mfrmr_typed_anchor_abort(
      "ANCHOR_RANK_DEFICIENT", "constraints.anchors",
      "typed step constraint Jacobian is not full column rank"
    )
  }
  list(config = out, anchors = declarations, notes = notes)
}

mfrmr_calibration_interaction_template <- function() {
  data.frame(
    InteractionId = character(0),
    FacetA = character(0),
    FacetB = character(0),
    LevelCountA = integer(0),
    LevelCountB = integer(0),
    Identification = character(0),
    CoordinateKeys = character(0),
    stringsAsFactors = FALSE
  )
}

mfrmr_calibration_identification_template <- function() {
  data.frame(
    ConstraintId = character(0),
    ParameterClass = character(0),
    OwnerFacet = character(0),
    ConstraintType = character(0),
    Target = character(0),
    Value = numeric(0),
    FreeDimension = integer(0),
    stringsAsFactors = FALSE
  )
}

mfrmr_calibration_event_template <- function() {
  data.frame(
    Revision = integer(0),
    Operation = character(0),
    From = character(0),
    To = character(0),
    AtUTC = character(0),
    ParentId = character(0),
    stringsAsFactors = FALSE
  )
}

mfrmr_calibration_parameter_status_template <- function() {
  data.frame(
    ParameterClass = character(0),
    Status = character(0),
    EvidenceCode = character(0),
    stringsAsFactors = FALSE
  )
}

mfrmr_calibration_default_id <- function(model, method, created_at) {
  stamp <- gsub("[^0-9]", "", as.character(created_at[1]))
  paste("mfrmr-calibration-v1", tolower(model), tolower(method), stamp, sep = ":")
}

mfrmr_calibration_normalize_source_columns <- function(fit) {
  src <- fit$config$source_columns %||% fit$prep$source_columns %||% list()
  facets <- src$facets %||% fit$config$facet_names
  facets <- as.character(facets)
  if (length(facets) == length(fit$config$facet_names)) {
    names(facets) <- fit$config$facet_names
  }
  list(
    person = as.character(src$person %||% "Person"),
    facets = facets,
    score = as.character(src$score %||% "Score"),
    weight = if (is.null(src$weight)) NULL else as.character(src$weight)
  )
}

mfrmr_calibration_extract_coordinates <- function(fit, params) {
  rows <- list()
  order_index <- 0L
  facet_names <- as.character(fit$config$facet_names)

  add_row <- function(key, parameter_class, owner, level, step,
                      interaction_id, value) {
    order_index <<- order_index + 1L
    rows[[length(rows) + 1L]] <<- data.frame(
      CoordinateKey = as.character(key),
      ParameterClass = as.character(parameter_class),
      OwnerFacet = as.character(owner),
      Level = as.character(level),
      Step = as.character(step),
      InteractionId = as.character(interaction_id),
      Value = as.numeric(value),
      OrderIndex = as.integer(order_index),
      stringsAsFactors = FALSE
    )
  }

  for (facet_index in seq_along(facet_names)) {
    facet <- facet_names[facet_index]
    levels <- as.character(fit$config$facet_levels[[facet]])
    values <- as.numeric(params$facets[[facet]])
    for (level_index in seq_along(levels)) {
      add_row(
        sprintf("facet::%d::level::%d", facet_index, level_index),
        "facet", facet, levels[level_index], NA_character_, NA_character_,
        values[level_index]
      )
    }
  }

  if (identical(fit$config$model, "RSM")) {
    for (step_index in seq_along(params$steps)) {
      add_row(
        sprintf("shared_step::%d", step_index),
        "shared_step", NA_character_, NA_character_, as.character(step_index),
        NA_character_, params$steps[step_index]
      )
    }
  } else {
    owner <- as.character(fit$config$step_facet)
    owner_levels <- as.character(fit$config$facet_levels[[owner]])
    for (level_index in seq_along(owner_levels)) {
      for (step_index in seq_len(ncol(params$steps_mat))) {
        add_row(
          sprintf("owned_step::level::%d::step::%d", level_index, step_index),
          "owned_step", owner, owner_levels[level_index], as.character(step_index),
          NA_character_, params$steps_mat[level_index, step_index]
        )
      }
    }
  }

  specs <- fit$config$interaction_specs %||% list()
  for (interaction_index in seq_along(specs)) {
    spec <- specs[[interaction_index]]
    interaction_id <- names(specs)[interaction_index]
    values <- params$interactions[[interaction_id]]
    for (b_index in seq_len(spec$n_b)) {
      for (a_index in seq_len(spec$n_a)) {
        add_row(
          sprintf(
            "interaction::%d::cell::%d::%d",
            interaction_index, a_index, b_index
          ),
          "interaction", interaction_id,
          sprintf("cell::%d::%d", a_index, b_index), NA_character_,
          interaction_id, values[a_index, b_index]
        )
      }
    }
  }

  mfrmr_calibration_bind_rows(rows, mfrmr_calibration_coordinate_template())
}

mfrmr_calibration_extract_interactions <- function(fit, coordinates) {
  specs <- fit$config$interaction_specs %||% list()
  if (length(specs) == 0L) return(mfrmr_calibration_interaction_template())
  rows <- lapply(seq_along(specs), function(i) {
    spec <- specs[[i]]
    interaction_id <- names(specs)[i]
    keys <- coordinates$CoordinateKey[
      coordinates$ParameterClass == "interaction" &
        coordinates$InteractionId == interaction_id
    ]
    data.frame(
      InteractionId = interaction_id,
      FacetA = as.character(spec$facet_a),
      FacetB = as.character(spec$facet_b),
      LevelCountA = as.integer(spec$n_a),
      LevelCountB = as.integer(spec$n_b),
      Identification = as.character(spec$identification),
      CoordinateKeys = paste(keys, collapse = ";"),
      stringsAsFactors = FALSE
    )
  })
  mfrmr_calibration_bind_rows(rows, mfrmr_calibration_interaction_template())
}

mfrmr_calibration_extract_anchors <- function(fit) {
  anchors <- mfrmr_typed_anchors_from_config(fit$config)
  normalized <- mfrmr_normalize_typed_anchors(fit$config, anchors)
  out <- normalized$anchors
  if (nrow(out) > 0L) {
    out$AnchorId <- sprintf("anchor::%d", seq_len(nrow(out)))
  }
  out
}

mfrmr_calibration_extract_identification <- function(fit) {
  rows <- list()
  facet_names <- as.character(fit$config$facet_names)
  for (facet_index in seq_along(facet_names)) {
    facet <- facet_names[facet_index]
    spec <- fit$config$facet_specs[[facet]]
    has_anchor <- any(is.finite(spec$anchors)) ||
      any(!is.na(spec$groups) & nzchar(as.character(spec$groups)))
    rows[[length(rows) + 1L]] <- data.frame(
      ConstraintId = sprintf("facet_constraint::%d", facet_index),
      ParameterClass = "facet",
      OwnerFacet = facet,
      ConstraintType = if (has_anchor) "typed_anchor_expansion" else "sum_to_zero",
      Target = sprintf("facet_levels::%d", length(spec$levels)),
      Value = NA_real_,
      FreeDimension = as.integer(spec$n_params),
      stringsAsFactors = FALSE
    )
  }

  step_specs <- mfrmr_step_specs(fit$config)
  if (identical(fit$config$model, "RSM")) {
    step_spec <- step_specs[[1]]
    rows[[length(rows) + 1L]] <- data.frame(
      ConstraintId = "shared_step_constraint",
      ParameterClass = "shared_step",
      OwnerFacet = NA_character_,
      ConstraintType = if (any(is.finite(step_spec$anchors))) {
        "sum_to_zero_with_fixed_anchors"
      } else {
        "sum_to_zero"
      },
      Target = sprintf("transitions::%d", fit$config$n_cat - 1L),
      Value = 0,
      FreeDimension = as.integer(step_spec$n_params),
      stringsAsFactors = FALSE
    )
  } else {
    owner <- as.character(fit$config$step_facet)
    for (level_index in seq_along(fit$config$facet_levels[[owner]])) {
      step_spec <- step_specs[[level_index]]
      rows[[length(rows) + 1L]] <- data.frame(
        ConstraintId = sprintf("owned_step_constraint::%d", level_index),
        ParameterClass = "owned_step",
        OwnerFacet = owner,
        ConstraintType = if (any(is.finite(step_spec$anchors))) {
          "row_sum_to_zero_with_fixed_anchors"
        } else {
          "row_sum_to_zero"
        },
        Target = sprintf("owner_level::%d", level_index),
        Value = 0,
        FreeDimension = as.integer(step_spec$n_params),
        stringsAsFactors = FALSE
      )
    }
  }

  specs <- fit$config$interaction_specs %||% list()
  for (i in seq_along(specs)) {
    spec <- specs[[i]]
    rows[[length(rows) + 1L]] <- data.frame(
      ConstraintId = sprintf("interaction_constraint::%d", i),
      ParameterClass = "interaction",
      OwnerFacet = names(specs)[i],
      ConstraintType = "two_way_sum_to_zero_margins",
      Target = sprintf("shape::%d::%d", spec$n_a, spec$n_b),
      Value = 0,
      FreeDimension = as.integer(spec$n_params),
      stringsAsFactors = FALSE
    )
  }

  mfrmr_calibration_bind_rows(rows, mfrmr_calibration_identification_template())
}

mfrmr_calibration_semantic_components <- function(x) {
  list(
    schema = list(
      schema_id = x$header$schema_id,
      schema_version = x$header$schema_version,
      semantic_identity_version = x$header$semantic_identity_version
    ),
    model_family_estimator = x$model[c("family", "estimator")],
    scale_dimension_counts = x$model[c(
      "n_observed_scales", "n_latent_dimensions"
    )],
    facet_order_roles_levels_signs = x$model[c(
      "facet_names", "facet_roles", "facet_levels", "facet_signs", "step_owner"
    )],
    interaction_map = x$model$interactions,
    response_map = x$response,
    parameter_coordinates = x$parameters$coordinates,
    identification_constraints = x$constraints$identification,
    typed_anchors = x$constraints$anchors,
    scoring_prior = x$scoring_basis[c("type", "prior_mean", "prior_sd")],
    scoring_algorithm = x$scoring_basis$scoring_algorithm,
    quadrature = x$scoring_basis[c(
      "quadrature_rule", "quadrature_order", "nodes", "weights"
    )],
    eligibility_lane = x$eligibility$lane_id
  )
}

mfrmr_extract_calibration_draft <- function(fit, calibration_id = NULL,
                                            source_fit_id = NULL,
                                            created_at_utc = NULL,
                                            scoring_quad_points = 31L) {
  if (!inherits(fit, "mfrm_fit")) {
    mfrmr_calibration_abort(
      "PROVENANCE_SOURCE_ID_INVALID", "fit",
      "source must inherit from `mfrm_fit`"
    )
  }
  model <- toupper(as.character(fit$config$model %||% ""))
  method <- toupper(as.character(fit$config$method %||% ""))
  if (!model %in% c("RSM", "PCM")) {
    mfrmr_calibration_abort(
      "MODEL_FAMILY_UNSUPPORTED", "model.family",
      "the 0.2.4 core draft extractor accepts only RSM or PCM fits"
    )
  }
  if (!identical(method, "MML")) {
    mfrmr_calibration_abort(
      "MODEL_ESTIMATOR_UNSUPPORTED", "model.estimator",
      "the 0.2.4 core draft extractor accepts only MML fits"
    )
  }
  population <- fit$config$population_spec %||% list()
  posterior_basis <- as.character(fit$config$posterior_basis %||% "")
  if (isTRUE(population$active) || identical(posterior_basis, "population_model")) {
    mfrmr_calibration_abort(
      "SCORING_BASIS_UNSUPPORTED", "scoring_basis.type",
      "estimated-population and latent-regression fits belong to OPT-01"
    )
  }
  if (identical(model, "PCM") &&
      (is.null(fit$config$step_facet) ||
       !fit$config$step_facet %in% fit$config$facet_names)) {
    mfrmr_calibration_abort(
      "IDENTIFICATION_CONTRACT_INVALID", "model.step_owner",
      "PCM requires one explicit stored step owner"
    )
  }

  fit_quad_points <- fit$config$estimation_control$quad_points
  if (is.null(fit_quad_points) || length(fit_quad_points) != 1L ||
      !is.finite(fit_quad_points) || fit_quad_points < 1 ||
      fit_quad_points != as.integer(fit_quad_points)) {
    mfrmr_calibration_abort(
      "QUADRATURE_ORDER_INVALID", "scoring_basis.quadrature_order",
      "the source fit must store one positive integer quadrature order"
    )
  }
  if (!is.numeric(scoring_quad_points) || length(scoring_quad_points) != 1L ||
      !is.finite(scoring_quad_points) || scoring_quad_points < 2 ||
      scoring_quad_points != as.integer(scoring_quad_points)) {
    mfrmr_calibration_abort(
      "QUADRATURE_ORDER_INVALID", "scoring_basis.quadrature_order",
      "operational scoring requires one integer quadrature order of at least 2"
    )
  }
  quad_points <- as.integer(scoring_quad_points)

  sizes <- build_param_sizes(fit$config)
  params <- expand_params(fit$opt$par, sizes, fit$config)
  coordinates <- mfrmr_calibration_extract_coordinates(fit, params)
  interactions <- mfrmr_calibration_extract_interactions(fit, coordinates)
  anchors <- mfrmr_calibration_extract_anchors(fit)
  identification <- mfrmr_calibration_extract_identification(fit)
  quad <- gauss_hermite_normal(as.integer(quad_points))
  quad_order <- order(quad$nodes)
  quad$nodes <- as.numeric(quad$nodes[quad_order])
  quad$weights <- as.numeric(quad$weights[quad_order])
  facet_names <- as.character(fit$config$facet_names)
  is_step_owner <- rep(FALSE, length(facet_names))
  if (identical(model, "PCM")) {
    is_step_owner <- facet_names == fit$config$step_facet
  }
  facet_roles <- data.frame(
    Facet = facet_names,
    Role = ifelse(is_step_owner, "facet_and_step_owner", "facet"),
    OrderIndex = seq_along(facet_names),
    stringsAsFactors = FALSE
  )
  facet_levels <- do.call(rbind, lapply(seq_along(facet_names), function(i) {
    facet <- facet_names[i]
    levels <- as.character(fit$config$facet_levels[[facet]])
    data.frame(
      Facet = facet,
      Level = levels,
      LevelIndex = seq_along(levels),
      stringsAsFactors = FALSE
    )
  }))
  rownames(facet_levels) <- NULL
  score_map <- as.data.frame(fit$prep$score_map, stringsAsFactors = FALSE)
  score_map$OrderIndex <- seq_len(nrow(score_map))
  score_map <- score_map[c("OriginalScore", "InternalScore", "OrderIndex")]
  created_at_utc <- as.character(created_at_utc %||% mfrmr_calibration_now_utc())
  calibration_id <- as.character(calibration_id %||%
    mfrmr_calibration_default_id(model, method, created_at_utc))
  source_fit_id <- as.character(source_fit_id %||% paste(
    "mfrm-fit", as.character(utils::packageVersion("mfrmr")), model, method,
    length(fit$opt$par), gsub("[^0-9]", "", created_at_utc), sep = ":"
  ))
  readiness_contract <- as.character(
    fit$readiness$contract_version %||% ""
  )
  source_ready <- identical(readiness_contract, mfrmr_readiness_contract_version()) &&
    isTRUE(mfrm_inference_ready(fit))
  parameter_classes <- unique(coordinates$ParameterClass)
  parameter_status <- data.frame(
    ParameterClass = parameter_classes,
    Status = if (source_ready) "eligible" else "ineligible",
    EvidenceCode = if (source_ready) {
      "SOURCE_FIT_CURRENT_AND_READY"
    } else {
      "SOURCE_READINESS_INELIGIBLE"
    },
    stringsAsFactors = FALSE
  )

  event <- data.frame(
    Revision = 1L,
    Operation = "extract_draft",
    From = "none",
    To = "draft",
    AtUTC = created_at_utc,
    ParentId = source_fit_id,
    stringsAsFactors = FALSE
  )
  x <- list(
    header = list(
      schema_id = mfrmr_calibration_schema_id(),
      schema_version = mfrmr_calibration_schema_version(),
      object_class = "mfrm_calibration",
      calibration_id = calibration_id,
      semantic_identity_version = mfrmr_calibration_semantic_identity_version()
    ),
    model = list(
      family = model,
      estimator = method,
      n_observed_scales = 1L,
      n_latent_dimensions = 1L,
      facet_names = facet_names,
      facet_roles = facet_roles,
      facet_levels = facet_levels,
      facet_signs = fit$config$facet_signs[facet_names],
      step_owner = if (identical(model, "RSM")) "shared" else fit$config$step_facet,
      interactions = interactions
    ),
    response = list(
      score_map = score_map,
      rating_min = as.integer(fit$prep$rating_min),
      rating_max = as.integer(fit$prep$rating_max),
      n_categories = as.integer(fit$config$n_cat)
    ),
    input_schema = list(
      source_columns = mfrmr_calibration_normalize_source_columns(fit)
    ),
    parameters = list(coordinates = coordinates),
    constraints = list(
      identification = identification,
      anchors = anchors
    ),
    scoring_basis = list(
      type = "fixed_standard_normal",
      prior_mean = 0,
      prior_sd = 1,
      scoring_algorithm = "quadrature_eap_v1",
      quadrature_rule = "gauss_hermite_standard_normal_golub_welsch_v1",
      quadrature_order = as.integer(quad_points),
      nodes = as.numeric(quad$nodes),
      weights = as.numeric(quad$weights)
    ),
    eligibility = list(
      lane_id = if (identical(model, "RSM")) {
        "core_rsm_mml_fixed_normal"
      } else {
        "core_pcm_mml_fixed_normal"
      },
      source_readiness_contract = readiness_contract,
      source_readiness_status = if (source_ready) "eligible" else "ineligible",
      parameter_class_status = parameter_status
    ),
    validation = list(
      schema_valid = FALSE,
      semantic_valid = FALSE,
      refusals = mfrmr_calibration_empty_refusals(),
      validated_at_utc = NULL
    ),
    lifecycle = list(
      state = "draft",
      revision = 1L,
      events = event
    ),
    provenance = list(
      source_fit_id = source_fit_id,
      source_package_version = as.character(utils::packageVersion("mfrmr")),
      created_at_utc = created_at_utc,
      created_by = "mfrmr:::mfrmr_extract_calibration_draft_v1",
      parent_calibration_id = NULL
    ),
    integrity = list(
      semantic_components = NULL,
      optional_hash = NULL
    )
  )
  x$integrity$semantic_components <- mfrmr_calibration_semantic_components(x)
  class(x) <- c("mfrm_calibration", "list")
  x$validation$refusals <- mfrmr_review_calibration(x)
  x
}

mfrmr_calibration_expected_sections <- function() {
  list(
    top = c(
      "header", "model", "response", "input_schema", "parameters",
      "constraints", "scoring_basis", "eligibility", "validation",
      "lifecycle", "provenance", "integrity"
    ),
    header = c(
      "schema_id", "schema_version", "object_class", "calibration_id",
      "semantic_identity_version"
    ),
    model = c(
      "family", "estimator", "n_observed_scales", "n_latent_dimensions",
      "facet_names", "facet_roles", "facet_levels", "facet_signs",
      "step_owner", "interactions"
    ),
    response = c("score_map", "rating_min", "rating_max", "n_categories"),
    input_schema = "source_columns",
    parameters = "coordinates",
    constraints = c("identification", "anchors"),
    scoring_basis = c(
      "type", "prior_mean", "prior_sd", "scoring_algorithm", "quadrature_rule",
      "quadrature_order", "nodes", "weights"
    ),
    eligibility = c(
      "lane_id", "source_readiness_contract", "source_readiness_status",
      "parameter_class_status"
    ),
    validation = c(
      "schema_valid", "semantic_valid", "refusals", "validated_at_utc"
    ),
    lifecycle = c("state", "revision", "events"),
    provenance = c(
      "source_fit_id", "source_package_version", "created_at_utc",
      "created_by", "parent_calibration_id"
    ),
    integrity = c("semantic_components", "optional_hash")
  )
}

mfrmr_calibration_find_prohibited <- function(x, path = "") {
  prohibited_names <- c(
    "fit", "opt", "data", "prep", "raw_optimizer_vector",
    "training_response_rows", "training_design_matrix", "person_identifiers",
    "person_coordinates", "person_estimates", "optimizer_trace", "hessian",
    "rng_state", "ambient_options", "absolute_source_path"
  )
  hits <- character(0)
  if (is.environment(x) || is.function(x) ||
      typeof(x) %in% c("externalptr", "weakref")) {
    return(if (nzchar(path)) path else "<root>")
  }
  if (!is.list(x)) return(hits)
  nms <- names(x)
  if (is.null(nms)) nms <- rep("", length(x))
  for (i in seq_along(x)) {
    child <- if (nzchar(nms[i])) nms[i] else paste0("[[", i, "]]" )
    child_path <- if (nzchar(path)) paste(path, child, sep = ".") else child
    if (tolower(nms[i]) %in% prohibited_names) {
      hits <- c(hits, child_path)
    }
    hits <- c(hits, mfrmr_calibration_find_prohibited(x[[i]], child_path))
  }
  unique(hits)
}

mfrmr_calibration_anchor_review_config <- function(x) {
  facet_names <- as.character(x$model$facet_names)
  level_table <- x$model$facet_levels
  facet_levels <- lapply(facet_names, function(facet) {
    rows <- level_table[level_table$Facet == facet, , drop = FALSE]
    rows <- rows[order(rows$LevelIndex), , drop = FALSE]
    as.character(rows$Level)
  })
  names(facet_levels) <- facet_names
  list(
    model = as.character(x$model$family),
    n_cat = as.integer(x$response$n_categories),
    facet_names = facet_names,
    facet_levels = facet_levels,
    step_facet = if (identical(x$model$family, "RSM")) {
      NULL
    } else {
      as.character(x$model$step_owner)
    }
  )
}

mfrmr_review_calibration <- function(x) {
  refusals <- mfrmr_calibration_empty_refusals()
  add <- function(code, field, detail) {
    refusals <<- rbind(
      refusals, mfrmr_calibration_refusal(code, field, detail)
    )
  }
  scalar_character <- function(value) {
    is.character(value) && length(value) == 1L && !is.na(value) && nzchar(value)
  }
  scalar_integer <- function(value) {
    is.integer(value) && length(value) == 1L && !is.na(value)
  }
  scalar_numeric <- function(value) {
    is.numeric(value) && length(value) == 1L && is.finite(value)
  }
  check_names <- function(value, expected, path) {
    if (!is.list(value)) {
      add("SCHEMA_TYPE_INVALID", path, "must be a named list")
      return(FALSE)
    }
    missing <- setdiff(expected, names(value))
    unexpected <- setdiff(names(value), expected)
    for (field in missing) {
      add("SCHEMA_FIELD_MISSING", paste(path, field, sep = "."), "required field is absent")
    }
    for (field in unexpected) {
      add("SCHEMA_FIELD_UNEXPECTED", paste(path, field, sep = "."), "field is not registered in schema version 1")
    }
    length(missing) == 0L && length(unexpected) == 0L
  }

  if (!is.list(x)) {
    add("SCHEMA_TYPE_INVALID", "<root>", "artifact must be a named list")
    return(refusals)
  }
  prohibited <- mfrmr_calibration_find_prohibited(x)
  if (length(prohibited) > 0L) {
    for (path in prohibited) {
      add(
        if (grepl("person", path, ignore.case = TRUE)) {
          "PROHIBITED_PERSON_STATE"
        } else {
          "PROHIBITED_TRAINING_STATE"
        },
        path, "artifact contains prohibited training, Person, or executable state"
      )
    }
  }
  expected <- mfrmr_calibration_expected_sections()
  if (!check_names(x, expected$top, "<root>")) return(refusals)
  section_ok <- vapply(names(expected)[-1], function(section) {
    check_names(x[[section]], expected[[section]], section)
  }, logical(1))
  if (!all(section_ok)) return(refusals)

  if (!inherits(x, "mfrm_calibration")) {
    add("SCHEMA_CLASS_INVALID", "header.object_class", "object must inherit from mfrm_calibration")
  }
  if (!identical(x$header$schema_id, mfrmr_calibration_schema_id())) {
    add("SCHEMA_ID_UNKNOWN", "header.schema_id", "schema identifier is not registered")
  }
  version <- x$header$schema_version
  if (!scalar_integer(version)) {
    add("SCHEMA_TYPE_INVALID", "header.schema_version", "must be one integer")
  } else if (version > mfrmr_calibration_schema_version()) {
    add("SCHEMA_VERSION_UNSUPPORTED", "header.schema_version", "newer schema version must fail closed")
  } else if (version < mfrmr_calibration_schema_version()) {
    add("SCHEMA_MIGRATION_REQUIRED", "header.schema_version", "older schema requires an explicit migration")
  }
  if (!identical(x$header$object_class, "mfrm_calibration")) {
    add("SCHEMA_CLASS_INVALID", "header.object_class", "class marker must be exact")
  }
  if (!scalar_character(x$header$calibration_id)) {
    add("IDENTITY_ID_INVALID", "header.calibration_id", "must be one nonempty identifier")
  }
  if (!identical(
    x$header$semantic_identity_version,
    mfrmr_calibration_semantic_identity_version()
  )) {
    add("IDENTITY_VERSION_UNKNOWN", "header.semantic_identity_version", "identity algorithm is not registered")
  }

  if (!identical(x$model$family, "RSM") && !identical(x$model$family, "PCM")) {
    add("MODEL_FAMILY_UNSUPPORTED", "model.family", "core family must be RSM or PCM")
  }
  if (!identical(x$model$estimator, "MML")) {
    add("MODEL_ESTIMATOR_UNSUPPORTED", "model.estimator", "core estimator must be MML")
  }
  if (!identical(x$model$n_observed_scales, 1L)) {
    add("MODEL_SCALE_COUNT_UNSUPPORTED", "model.n_observed_scales", "schema version 1 supports exactly one scale")
  }
  if (!identical(x$model$n_latent_dimensions, 1L)) {
    add("MODEL_DIMENSION_COUNT_UNSUPPORTED", "model.n_latent_dimensions", "schema version 1 supports exactly one dimension")
  }
  facet_names <- x$model$facet_names
  if (!is.character(facet_names) || length(facet_names) == 0L ||
      anyNA(facet_names) || any(!nzchar(facet_names)) || anyDuplicated(facet_names)) {
    add("MODEL_FACET_ORDER_INVALID", "model.facet_names", "must be a nonempty unique ordered character vector")
  }
  roles <- x$model$facet_roles
  if (!is.data.frame(roles) ||
      !identical(names(roles), c("Facet", "Role", "OrderIndex")) ||
      !identical(as.character(roles$Facet), facet_names) ||
      !identical(as.integer(roles$OrderIndex), seq_along(facet_names))) {
    add("MODEL_FACET_ROLE_INVALID", "model.facet_roles", "role rows must align exactly with facet order")
  }
  levels <- x$model$facet_levels
  if (!is.data.frame(levels) ||
      !identical(names(levels), c("Facet", "Level", "LevelIndex")) ||
      anyDuplicated(paste(levels$Facet, levels$Level, sep = "\r"))) {
    add("MODEL_FACET_LEVEL_INVALID", "model.facet_levels", "level dictionary is malformed or duplicated")
  } else if (!setequal(unique(as.character(levels$Facet)), facet_names)) {
    add("MODEL_FACET_LEVEL_INVALID", "model.facet_levels", "every and only declared facet must have levels")
  }
  signs <- x$model$facet_signs
  if (!is.numeric(signs) || !identical(names(signs), facet_names) ||
      any(!is.finite(signs)) || any(!signs %in% c(-1, 1))) {
    add("MODEL_FACET_SIGN_INVALID", "model.facet_signs", "every facet requires one explicit -1 or 1 sign in order")
  }
  if (identical(x$model$family, "RSM") && !identical(x$model$step_owner, "shared")) {
    add("IDENTIFICATION_CONTRACT_INVALID", "model.step_owner", "RSM step owner must be shared")
  }
  if (identical(x$model$family, "PCM") &&
      (!scalar_character(x$model$step_owner) || !x$model$step_owner %in% facet_names)) {
    add("IDENTIFICATION_CONTRACT_INVALID", "model.step_owner", "PCM step owner must be one declared facet")
  }
  interactions <- x$model$interactions
  interaction_columns <- names(mfrmr_calibration_interaction_template())
  if (!is.data.frame(interactions) || !identical(names(interactions), interaction_columns) ||
      anyDuplicated(interactions$InteractionId)) {
    add("MODEL_INTERACTION_INVALID", "model.interactions", "interaction map must use the registered typed columns and unique IDs")
  }

  score_map <- x$response$score_map
  if (!is.data.frame(score_map) ||
      !identical(names(score_map), c("OriginalScore", "InternalScore", "OrderIndex")) ||
      nrow(score_map) == 0L || anyNA(score_map) ||
      anyDuplicated(score_map$OriginalScore) || anyDuplicated(score_map$InternalScore) ||
      !identical(as.integer(score_map$OrderIndex), seq_len(nrow(score_map)))) {
    add("RESPONSE_SCORE_MAP_INVALID", "response.score_map", "score map must be complete, one-to-one, and ordered")
  }
  if (!scalar_integer(x$response$rating_min) || !scalar_integer(x$response$rating_max) ||
      x$response$rating_max < x$response$rating_min) {
    add("RESPONSE_RATING_BOUND_INVALID", "response.rating_min", "rating bounds must be ordered integers")
  }
  if (!scalar_integer(x$response$n_categories) || x$response$n_categories < 2L ||
      !identical(
        x$response$n_categories,
        as.integer(x$response$rating_max - x$response$rating_min + 1L)
      )) {
    add("RESPONSE_CATEGORY_COUNT_INVALID", "response.n_categories", "category count must agree with rating bounds")
  }
  if (is.data.frame(score_map) && nrow(score_map) > 0L &&
      scalar_integer(x$response$rating_min) &&
      scalar_integer(x$response$rating_max) &&
      !identical(
        sort(as.integer(score_map$InternalScore)),
        seq.int(x$response$rating_min, x$response$rating_max)
      )) {
    add("RESPONSE_SCORE_MAP_INVALID", "response.score_map", "internal scores must exactly cover the declared rating bounds")
  }

  src <- x$input_schema$source_columns
  if (!is.list(src) || !identical(names(src), c("person", "facets", "score", "weight")) ||
      !scalar_character(src$person) || !scalar_character(src$score) ||
      !is.character(src$facets) || !identical(names(src$facets), facet_names)) {
    add("SCHEMA_TYPE_INVALID", "input_schema.source_columns", "source column defaults must be typed and aligned to facet order")
  }

  coordinates <- x$parameters$coordinates
  coordinate_columns <- names(mfrmr_calibration_coordinate_template())
  if (!is.data.frame(coordinates) || !identical(names(coordinates), coordinate_columns) ||
      nrow(coordinates) == 0L) {
    add("PARAMETER_COORDINATE_INVALID", "parameters.coordinates", "expanded coordinate table is absent or malformed")
  } else {
    if (anyNA(coordinates$CoordinateKey) || any(!nzchar(coordinates$CoordinateKey)) ||
        anyDuplicated(coordinates$CoordinateKey) ||
        !identical(as.integer(coordinates$OrderIndex), seq_len(nrow(coordinates)))) {
      add("PARAMETER_COORDINATE_DUPLICATE", "parameters.coordinates.CoordinateKey", "coordinate keys must be unique and canonically ordered")
    }
    if (any(!is.finite(coordinates$Value))) {
      add("PARAMETER_NONFINITE", "parameters.coordinates.Value", "every expanded coordinate must be finite")
    }
    allowed_classes <- c("facet", "shared_step", "owned_step", "interaction")
    if (any(!coordinates$ParameterClass %in% allowed_classes)) {
      add("PARAMETER_COORDINATE_INVALID", "parameters.coordinates.ParameterClass", "unknown parameter class")
    }
    if (identical(x$model$family, "RSM") && any(coordinates$ParameterClass == "owned_step")) {
      add("PARAMETER_COORDINATE_INVALID", "parameters.coordinates.ParameterClass", "RSM cannot contain owned steps")
    }
    if (identical(x$model$family, "PCM") && any(coordinates$ParameterClass == "shared_step")) {
      add("PARAMETER_COORDINATE_INVALID", "parameters.coordinates.ParameterClass", "PCM cannot contain shared steps")
    }
  }

  identification <- x$constraints$identification
  identification_columns <- names(mfrmr_calibration_identification_template())
  if (!is.data.frame(identification) ||
      !identical(names(identification), identification_columns) ||
      nrow(identification) == 0L || anyDuplicated(identification$ConstraintId)) {
    add("IDENTIFICATION_CONTRACT_INVALID", "constraints.identification", "identification table is absent, malformed, or duplicated")
  }
  anchors <- x$constraints$anchors
  anchor_columns <- names(mfrmr_calibration_anchor_template())
  if (!is.data.frame(anchors) || !identical(names(anchors), anchor_columns) ||
      anyDuplicated(anchors$AnchorId)) {
    add("ANCHOR_DECLARATION_INVALID", "constraints.anchors", "anchor table is malformed or duplicated")
  } else if (nrow(anchors) > 0L) {
    normalized <- tryCatch(
      mfrmr_normalize_typed_anchors(
        mfrmr_calibration_anchor_review_config(x), anchors
      ),
      mfrm_calibration_error = function(error) error
    )
    if (inherits(normalized, "mfrm_calibration_error")) {
      add(normalized$code, normalized$field_path, normalized$detail)
    } else {
      comparable <- setdiff(anchor_columns, "AnchorId")
      normalized_values <- normalized$anchors[, comparable, drop = FALSE]
      stored_values <- anchors[, comparable, drop = FALSE]
      rownames(normalized_values) <- NULL
      rownames(stored_values) <- NULL
      if (!identical(stored_values, normalized_values)) {
        add(
          "ANCHOR_CANONICAL_ORDER_INVALID", "constraints.anchors",
          "stored anchors must equal the order-invariant canonical declaration table"
        )
      }
      if (is.data.frame(coordinates) &&
          identical(names(coordinates), coordinate_columns)) {
        for (i in seq_len(nrow(anchors))) {
          row <- anchors[i, , drop = FALSE]
          match_index <- if (row$AnchorType == "direct") {
            which(coordinates$ParameterClass == "facet" &
                    coordinates$OwnerFacet == row$OwnerFacet &
                    coordinates$Level == row$Level)
          } else if (row$AnchorType == "shared_step") {
            which(coordinates$ParameterClass == "shared_step" &
                    coordinates$Step == row$Step)
          } else if (row$AnchorType == "owned_step") {
            which(coordinates$ParameterClass == "owned_step" &
                    coordinates$OwnerFacet == row$OwnerFacet &
                    coordinates$Level == row$Level &
                    coordinates$Step == row$Step)
          } else {
            integer(0)
          }
          if (row$AnchorType != "group" &&
              (length(match_index) != 1L ||
               !isTRUE(all.equal(coordinates$Value[match_index], row$Value,
                                 tolerance = 1e-12)))) {
            add(
              "ANCHOR_COORDINATE_MISMATCH", paste0("constraints.anchors[", i, "]"),
              "fixed declaration does not equal its expanded stored coordinate"
            )
          }
        }
        group_rows <- anchors[anchors$AnchorType == "group", , drop = FALSE]
        if (nrow(group_rows) > 0L) {
          group_keys <- unique(paste(group_rows$OwnerFacet, group_rows$GroupId,
                                     sep = "\r"))
          for (key in group_keys) {
            index <- which(paste(group_rows$OwnerFacet, group_rows$GroupId,
                                 sep = "\r") == key)
            rows <- group_rows[index, , drop = FALSE]
            coordinate_index <- match(
              paste(rows$OwnerFacet, rows$Level, sep = "\r"),
              paste(coordinates$OwnerFacet, coordinates$Level, sep = "\r")
            )
            if (anyNA(coordinate_index) ||
                !isTRUE(all.equal(
                  mean(coordinates$Value[coordinate_index]), rows$Value[1],
                  tolerance = 1e-12
                ))) {
              add(
                "ANCHOR_COORDINATE_MISMATCH", "constraints.anchors",
                "group declaration does not equal the stored member-coordinate mean"
              )
            }
          }
        }
      }
    }
  }

  if (!identical(x$scoring_basis$type, "fixed_standard_normal")) {
    add("SCORING_BASIS_UNSUPPORTED", "scoring_basis.type", "core scoring basis must be fixed_standard_normal")
  }
  if (!identical(x$scoring_basis$prior_mean, 0) ||
      !identical(x$scoring_basis$prior_sd, 1)) {
    add("SCORING_PRIOR_INVALID", "scoring_basis.prior_mean", "core prior must be exactly N(0,1)")
  }
  if (!identical(x$scoring_basis$scoring_algorithm, "quadrature_eap_v1")) {
    add(
      "SCORING_BASIS_UNSUPPORTED", "scoring_basis.scoring_algorithm",
      "core scoring algorithm must be exactly quadrature_eap_v1"
    )
  }
  if (!identical(
    x$scoring_basis$quadrature_rule,
    "gauss_hermite_standard_normal_golub_welsch_v1"
  )) {
    add("QUADRATURE_RULE_INVALID", "scoring_basis.quadrature_rule", "quadrature rule identity is not registered")
  }
  order <- x$scoring_basis$quadrature_order
  nodes <- x$scoring_basis$nodes
  weights <- x$scoring_basis$weights
  if (!scalar_integer(order) || order < 2L || length(nodes) != order || length(weights) != order) {
    add("QUADRATURE_ORDER_INVALID", "scoring_basis.quadrature_order", "order must be at least 2 and equal stored node and weight lengths")
  }
  if (!is.numeric(nodes) || any(!is.finite(nodes)) ||
      length(nodes) > 1L && any(diff(nodes) <= 0)) {
    add("QUADRATURE_NODES_INVALID", "scoring_basis.nodes", "nodes must be finite and strictly increasing")
  }
  if (!is.numeric(weights) || any(!is.finite(weights)) || any(weights <= 0) ||
      abs(sum(weights) - 1) > 1e-12) {
    add("QUADRATURE_WEIGHTS_INVALID", "scoring_basis.weights", "weights must be finite, positive, aligned, and normalized")
  }

  expected_lane <- if (identical(x$model$family, "RSM")) {
    "core_rsm_mml_fixed_normal"
  } else {
    "core_pcm_mml_fixed_normal"
  }
  if (!identical(x$eligibility$lane_id, expected_lane)) {
    add("ELIGIBILITY_LANE_INVALID", "eligibility.lane_id", "lane does not agree with the model family")
  }
  if (!identical(
    x$eligibility$source_readiness_contract,
    mfrmr_readiness_contract_version()
  )) {
    add("SOURCE_READINESS_CONTRACT_INVALID", "eligibility.source_readiness_contract", "source readiness contract is not current")
  }
  if (!identical(x$eligibility$source_readiness_status, "eligible")) {
    add("SOURCE_READINESS_INELIGIBLE", "eligibility.source_readiness_status", "source fit is not eligible for validation")
  }
  parameter_status <- x$eligibility$parameter_class_status
  if (!is.data.frame(parameter_status) ||
      !identical(names(parameter_status), names(mfrmr_calibration_parameter_status_template())) ||
      nrow(parameter_status) == 0L || any(parameter_status$Status != "eligible")) {
    add("PARAMETER_CLASS_INELIGIBLE", "eligibility.parameter_class_status", "every stored parameter class must be eligible")
  }

  state <- x$lifecycle$state
  if (!scalar_character(state) ||
      !state %in% c("draft", "validated", "frozen", "superseded", "retired")) {
    add("LIFECYCLE_STATE_INVALID", "lifecycle.state", "state is not registered")
  }
  events <- x$lifecycle$events
  event_columns <- names(mfrmr_calibration_event_template())
  if (!is.data.frame(events) || !identical(names(events), event_columns) ||
      nrow(events) == 0L ||
      !identical(as.integer(events$Revision), seq_len(nrow(events))) ||
      !identical(x$lifecycle$revision, as.integer(nrow(events))) ||
      !identical(as.character(events$To[nrow(events)]), state)) {
    add("LIFECYCLE_EVENT_CHAIN_INVALID", "lifecycle.events", "event chain must be contiguous and terminate at the current state")
  }
  if (identical(state, "draft")) {
    if (!identical(x$validation$schema_valid, FALSE) ||
        !identical(x$validation$semantic_valid, FALSE) ||
        !is.null(x$validation$validated_at_utc)) {
      add("VALIDATION_SCHEMA_FAILED", "validation", "draft must not claim successful validation")
    }
  } else if (state %in% c("validated", "frozen", "superseded", "retired")) {
    if (!identical(x$validation$schema_valid, TRUE) ||
        !identical(x$validation$semantic_valid, TRUE) ||
        !scalar_character(x$validation$validated_at_utc)) {
      add("VALIDATION_SCHEMA_FAILED", "validation", "post-validation states require explicit successful validation")
    }
  }

  refusal_columns <- names(mfrmr_calibration_empty_refusals())
  if (!is.data.frame(x$validation$refusals) ||
      !identical(names(x$validation$refusals), refusal_columns) ||
      any(!x$validation$refusals$Severity %in% "error")) {
    add("VALIDATION_REFUSAL_INVALID", "validation.refusals", "refusal table must use the registered typed columns and severity")
  } else if (!identical(state, "draft") && nrow(x$validation$refusals) != 0L) {
    add("VALIDATION_SEMANTIC_FAILED", "validation.refusals", "post-validation states require an empty refusal table")
  }
  if (identical(state, "draft")) {
    if (!is.null(x$validation$validated_at_utc)) {
      add("VALIDATION_TIME_INVALID", "validation.validated_at_utc", "draft validation time must be absent")
    }
  } else if (!mfrmr_calibration_is_utc_timestamp(x$validation$validated_at_utc)) {
    add("VALIDATION_TIME_INVALID", "validation.validated_at_utc", "must be a valid RFC3339 UTC timestamp")
  }

  if (!scalar_character(x$provenance$source_fit_id)) {
    add("PROVENANCE_SOURCE_ID_INVALID", "provenance.source_fit_id", "source fit identity is required")
  }
  package_version_valid <- scalar_character(x$provenance$source_package_version) &&
    !inherits(try(base::package_version(x$provenance$source_package_version),
                  silent = TRUE), "try-error")
  if (!package_version_valid) {
    add("PROVENANCE_PACKAGE_VERSION_INVALID", "provenance.source_package_version", "creator package version is required")
  }
  if (!mfrmr_calibration_is_utc_timestamp(x$provenance$created_at_utc)) {
    add("PROVENANCE_TIME_INVALID", "provenance.created_at_utc", "creation time must be a valid RFC3339 UTC timestamp")
  }
  if (!identical(
    x$provenance$created_by,
    "mfrmr:::mfrmr_extract_calibration_draft_v1"
  )) {
    add("PROVENANCE_CREATOR_INVALID", "provenance.created_by", "creator identity is not registered")
  }
  terminal <- state %in% c("superseded", "retired")
  parent_id <- x$provenance$parent_calibration_id
  if (terminal) {
    if (!scalar_character(parent_id) || identical(parent_id, x$header$calibration_id)) {
      add("PROVENANCE_PARENT_INVALID", "provenance.parent_calibration_id", "terminal lifecycle records require a distinct parent calibration identity")
    }
  } else if (!is.null(parent_id)) {
    add("PROVENANCE_PARENT_INVALID", "provenance.parent_calibration_id", "nonterminal calibration records cannot claim a parent calibration")
  }

  if (is.data.frame(events) && identical(names(events), event_columns) &&
      nrow(events) > 0L) {
    expected_operation <- switch(
      state,
      draft = "extract_draft",
      validated = c("extract_draft", "validate"),
      frozen = c("extract_draft", "validate", "freeze"),
      superseded = c("extract_draft", "validate", "freeze", "supersede"),
      retired = c("extract_draft", "validate", "freeze", "retire"),
      character(0)
    )
    expected_from <- switch(
      state,
      draft = "none",
      validated = c("none", "draft"),
      frozen = c("none", "draft", "validated"),
      superseded = c("none", "draft", "validated", "frozen"),
      retired = c("none", "draft", "validated", "frozen"),
      character(0)
    )
    expected_to <- switch(
      state,
      draft = "draft",
      validated = c("draft", "validated"),
      frozen = c("draft", "validated", "frozen"),
      superseded = c("draft", "validated", "frozen", "superseded"),
      retired = c("draft", "validated", "frozen", "retired"),
      character(0)
    )
    lineage_id <- if (terminal) parent_id else x$header$calibration_id
    expected_parent <- c(
      x$provenance$source_fit_id,
      rep(lineage_id, max(length(expected_operation) - 1L, 0L))
    )
    if (!identical(as.character(events$Operation), expected_operation) ||
        !identical(as.character(events$From), expected_from) ||
        !identical(as.character(events$To), expected_to) ||
        !identical(as.character(events$ParentId), expected_parent) ||
        any(!vapply(events$AtUTC, mfrmr_calibration_is_utc_timestamp,
                    logical(1)))) {
      add("LIFECYCLE_EVENT_CHAIN_INVALID", "lifecycle.events", "operation, state, parent, and timestamp sequence must match the registered lifecycle")
    }
  }

  expected_identity <- tryCatch(
    mfrmr_calibration_semantic_components(x),
    error = function(e) NULL
  )
  if (is.null(expected_identity) ||
      !identical(x$integrity$semantic_components, expected_identity)) {
    add("IDENTITY_COMPONENT_MISMATCH", "integrity.semantic_components", "stored identity components do not exactly match semantic fields")
  }
  if (!is.null(x$integrity$optional_hash) &&
      !scalar_character(x$integrity$optional_hash)) {
    add("INTEGRITY_HASH_INVALID", "integrity.optional_hash", "optional hash must be one nonempty string when present")
  }

  rownames(refusals) <- NULL
  refusals
}

mfrmr_calibration_transition <- function(x, operation, from, to, at_utc) {
  if (!identical(x$lifecycle$state, from)) {
    mfrmr_calibration_abort(
      "LIFECYCLE_TRANSITION_INVALID", "lifecycle.state",
      paste0("operation ", operation, " requires state ", from)
    )
  }
  out <- x
  revision <- as.integer(out$lifecycle$revision + 1L)
  event <- data.frame(
    Revision = revision,
    Operation = operation,
    From = from,
    To = to,
    AtUTC = as.character(at_utc),
    ParentId = as.character(out$header$calibration_id),
    stringsAsFactors = FALSE
  )
  out$lifecycle$events <- rbind(out$lifecycle$events, event)
  rownames(out$lifecycle$events) <- NULL
  out$lifecycle$revision <- revision
  out$lifecycle$state <- to
  out
}

mfrmr_validate_calibration_draft <- function(x, validated_at_utc = NULL) {
  if (!inherits(x, "mfrm_calibration")) {
    mfrmr_calibration_abort(
      "SCHEMA_CLASS_INVALID", "header.object_class",
      "validation requires an mfrm_calibration draft"
    )
  }
  if (!identical(x$lifecycle$state, "draft")) {
    mfrmr_calibration_abort(
      "LIFECYCLE_TRANSITION_INVALID", "lifecycle.state",
      "only a draft can enter validation"
    )
  }
  review <- mfrmr_review_calibration(x)
  mfrmr_calibration_abort_review(review)
  at_utc <- as.character(validated_at_utc %||% mfrmr_calibration_now_utc())
  out <- x
  out$validation$schema_valid <- TRUE
  out$validation$semantic_valid <- TRUE
  out$validation$refusals <- mfrmr_calibration_empty_refusals()
  out$validation$validated_at_utc <- at_utc
  out <- mfrmr_calibration_transition(out, "validate", "draft", "validated", at_utc)
  final_review <- mfrmr_review_calibration(out)
  mfrmr_calibration_abort_review(final_review)
  out
}

mfrmr_freeze_calibration <- function(x, frozen_at_utc = NULL) {
  if (!inherits(x, "mfrm_calibration")) {
    mfrmr_calibration_abort(
      "SCHEMA_CLASS_INVALID", "header.object_class",
      "freezing requires an mfrm_calibration"
    )
  }
  review <- mfrmr_review_calibration(x)
  mfrmr_calibration_abort_review(review)
  at_utc <- as.character(frozen_at_utc %||% mfrmr_calibration_now_utc())
  out <- mfrmr_calibration_transition(x, "freeze", "validated", "frozen", at_utc)
  final_review <- mfrmr_review_calibration(out)
  mfrmr_calibration_abort_review(final_review)
  out
}

mfrmr_calibration_terminal_record <- function(x, operation, record_id,
                                              at_utc = NULL) {
  review <- mfrmr_review_calibration(x)
  mfrmr_calibration_abort_review(review)
  if (!identical(x$lifecycle$state, "frozen")) {
    mfrmr_calibration_abort(
      "LIFECYCLE_TRANSITION_INVALID", "lifecycle.state",
      paste0("operation ", operation, " requires state frozen")
    )
  }
  if (!is.character(record_id) || length(record_id) != 1L ||
      is.na(record_id) || !nzchar(record_id) ||
      identical(record_id, x$header$calibration_id)) {
    mfrmr_calibration_abort(
      "PROVENANCE_PARENT_INVALID", "record_id",
      "terminal record identity must be nonempty and distinct from its frozen parent"
    )
  }
  at_utc <- as.character(at_utc %||% mfrmr_calibration_now_utc())
  if (!mfrmr_calibration_is_utc_timestamp(at_utc)) {
    mfrmr_calibration_abort(
      "PROVENANCE_TIME_INVALID", "at_utc",
      "terminal transition requires a valid RFC3339 UTC timestamp"
    )
  }
  parent_id <- x$header$calibration_id
  out <- mfrmr_calibration_transition(
    x, operation, "frozen", if (identical(operation, "supersede")) {
      "superseded"
    } else {
      "retired"
    }, at_utc
  )
  out$header$calibration_id <- record_id
  out$provenance$parent_calibration_id <- parent_id
  final_review <- mfrmr_review_calibration(out)
  mfrmr_calibration_abort_review(final_review)
  out
}

mfrmr_supersede_calibration <- function(x, record_id,
                                        superseded_at_utc = NULL) {
  mfrmr_calibration_terminal_record(
    x, "supersede", record_id, superseded_at_utc
  )
}

mfrmr_retire_calibration <- function(x, record_id,
                                     retired_at_utc = NULL) {
  mfrmr_calibration_terminal_record(
    x, "retire", record_id, retired_at_utc
  )
}

mfrmr_save_calibration <- function(x, file, overwrite = FALSE) {
  review <- mfrmr_review_calibration(x)
  mfrmr_calibration_abort_review(review)
  file <- as.character(file[1])
  if (is.na(file) || !nzchar(file) || !grepl("[.]rds$", file, ignore.case = TRUE)) {
    mfrmr_calibration_abort(
      "PERSISTENCE_PATH_INVALID", "file",
      "canonical calibration persistence requires one `.rds` path"
    )
  }
  target_dir <- dirname(file)
  if (!dir.exists(target_dir)) {
    mfrmr_calibration_abort(
      "PERSISTENCE_PATH_INVALID", "file",
      "target directory does not exist"
    )
  }
  if (file.exists(file) && !isTRUE(overwrite)) {
    mfrmr_calibration_abort(
      "PERSISTENCE_TARGET_EXISTS", "file",
      "target exists; set overwrite explicitly to replace it"
    )
  }
  temporary <- tempfile(pattern = paste0(".", basename(file), "-"), tmpdir = target_dir)
  on.exit(unlink(temporary), add = TRUE)
  tryCatch(
    saveRDS(x, temporary, version = 3),
    error = function(e) mfrmr_calibration_abort(
      "PERSISTENCE_WRITE_FAILED", "file", conditionMessage(e)
    )
  )
  copied <- file.copy(temporary, file, overwrite = isTRUE(overwrite))
  if (!isTRUE(copied)) {
    mfrmr_calibration_abort(
      "PERSISTENCE_WRITE_FAILED", "file",
      "temporary artifact could not be committed to the target"
    )
  }
  invisible(normalizePath(file, mustWork = TRUE))
}

mfrmr_load_calibration <- function(file) {
  file <- as.character(file[1])
  if (is.na(file) || !nzchar(file) || !file.exists(file)) {
    mfrmr_calibration_abort(
      "PERSISTENCE_PATH_INVALID", "file", "artifact file does not exist"
    )
  }
  x <- tryCatch(
    readRDS(file),
    error = function(e) mfrmr_calibration_abort(
      "PERSISTENCE_READ_FAILED", "file", conditionMessage(e)
    )
  )
  review <- mfrmr_review_calibration(x)
  mfrmr_calibration_abort_review(review)
  x
}

mfrmr_calibration_scoring_column <- function(value, fallback, field_path) {
  value <- value %||% fallback
  if (!is.character(value) || length(value) != 1L ||
      is.na(value) || !nzchar(value)) {
    mfrmr_calibration_abort(
      "SCORING_COLUMN_MAPPING_INVALID", field_path,
      "must resolve to one nonempty column name"
    )
  }
  value
}

mfrmr_calibration_scoring_facets <- function(x, facets) {
  facet_names <- x$model$facet_names
  if (is.null(facets)) {
    facets <- x$input_schema$source_columns$facets
  }
  if (!is.character(facets) || length(facets) != length(facet_names) ||
      is.null(names(facets)) || !identical(names(facets), facet_names) ||
      anyNA(facets) || any(!nzchar(facets))) {
    mfrmr_calibration_abort(
      "SCORING_COLUMN_MAPPING_INVALID", "facets",
      "must be a named character vector aligned exactly to model.facet_names"
    )
  }
  facets
}

mfrmr_calibration_scoring_levels <- function(x) {
  out <- vector("list", length(x$model$facet_names))
  names(out) <- x$model$facet_names
  dictionary <- x$model$facet_levels
  for (facet in x$model$facet_names) {
    rows <- dictionary[dictionary$Facet == facet, , drop = FALSE]
    expected_index <- seq_len(nrow(rows))
    if (nrow(rows) == 0L || anyNA(rows$Level) ||
        any(!nzchar(rows$Level)) || anyDuplicated(rows$Level) ||
        !identical(as.integer(rows$LevelIndex), expected_index)) {
      mfrmr_calibration_abort(
        "MODEL_FACET_LEVEL_INVALID", "model.facet_levels",
        paste0("facet ", facet, " does not have one canonical ordered level dictionary")
      )
    }
    out[[facet]] <- as.character(rows$Level)
  }
  out
}

mfrmr_calibration_materialize_scoring <- function(x) {
  coordinates <- x$parameters$coordinates
  facet_levels <- mfrmr_calibration_scoring_levels(x)
  facet_values <- vector("list", length(x$model$facet_names))
  names(facet_values) <- x$model$facet_names

  for (facet in x$model$facet_names) {
    rows <- coordinates[
      coordinates$ParameterClass == "facet" &
        !is.na(coordinates$OwnerFacet) &
        coordinates$OwnerFacet == facet,
      , drop = FALSE
    ]
    position <- match(facet_levels[[facet]], rows$Level)
    if (nrow(rows) != length(facet_levels[[facet]]) ||
        anyNA(position) || anyDuplicated(rows$Level)) {
      mfrmr_calibration_abort(
        "PARAMETER_COORDINATE_INVALID", "parameters.coordinates",
        paste0("facet ", facet, " must have exactly one coordinate per declared level")
      )
    }
    facet_values[[facet]] <- stats::setNames(
      as.numeric(rows$Value[position]), facet_levels[[facet]]
    )
  }

  n_steps <- x$response$n_categories - 1L
  shared_steps <- NULL
  owned_steps <- NULL
  if (identical(x$model$family, "RSM")) {
    rows <- coordinates[coordinates$ParameterClass == "shared_step", , drop = FALSE]
    position <- match(as.character(seq_len(n_steps)), rows$Step)
    if (nrow(rows) != n_steps || anyNA(position) || anyDuplicated(rows$Step)) {
      mfrmr_calibration_abort(
        "PARAMETER_COORDINATE_INVALID", "parameters.coordinates",
        "RSM must have exactly one shared coordinate per transition"
      )
    }
    shared_steps <- as.numeric(rows$Value[position])
  } else {
    owner <- x$model$step_owner
    owner_levels <- facet_levels[[owner]]
    rows <- coordinates[
      coordinates$ParameterClass == "owned_step" &
        !is.na(coordinates$OwnerFacet) &
        coordinates$OwnerFacet == owner,
      , drop = FALSE
    ]
    expected_level <- rep(owner_levels, each = n_steps)
    expected_step <- rep(as.character(seq_len(n_steps)), times = length(owner_levels))
    selector <- paste(rows$Level, rows$Step, sep = "\r")
    position <- match(paste(expected_level, expected_step, sep = "\r"), selector)
    if (nrow(rows) != length(position) || anyNA(position) ||
        anyDuplicated(selector)) {
      mfrmr_calibration_abort(
        "PARAMETER_COORDINATE_INVALID", "parameters.coordinates",
        "PCM must have exactly one owned-step coordinate per owner level and transition"
      )
    }
    owned_steps <- matrix(
      as.numeric(rows$Value[position]),
      nrow = length(owner_levels), ncol = n_steps, byrow = TRUE,
      dimnames = list(owner_levels, as.character(seq_len(n_steps)))
    )
  }

  interaction_values <- vector("list", nrow(x$model$interactions))
  names(interaction_values) <- as.character(x$model$interactions$InteractionId)
  if (nrow(x$model$interactions) > 0L) {
    for (i in seq_len(nrow(x$model$interactions))) {
      spec <- x$model$interactions[i, , drop = FALSE]
      facet_a <- as.character(spec$FacetA)
      facet_b <- as.character(spec$FacetB)
      if (!facet_a %in% x$model$facet_names ||
          !facet_b %in% x$model$facet_names || identical(facet_a, facet_b) ||
          !identical(spec$LevelCountA, as.integer(length(facet_levels[[facet_a]]))) ||
          !identical(spec$LevelCountB, as.integer(length(facet_levels[[facet_b]]))) ||
          !identical(as.character(spec$Identification), "two_way_sum_to_zero_margins")) {
        mfrmr_calibration_abort(
          "MODEL_INTERACTION_INVALID", "model.interactions",
          paste0("interaction ", spec$InteractionId, " is not aligned to its facet dictionaries")
        )
      }
      rows <- coordinates[
        coordinates$ParameterClass == "interaction" &
          !is.na(coordinates$InteractionId) &
          coordinates$InteractionId == spec$InteractionId,
        , drop = FALSE
      ]
      expected_cells <- unlist(lapply(
        seq_len(spec$LevelCountB),
        function(b) sprintf("cell::%d::%d", seq_len(spec$LevelCountA), b)
      ), use.names = FALSE)
      position <- match(expected_cells, rows$Level)
      if (nrow(rows) != length(expected_cells) || anyNA(position) ||
          anyDuplicated(rows$Level) ||
          !identical(
            paste(rows$CoordinateKey[position], collapse = ";"),
            as.character(spec$CoordinateKeys)
          )) {
        mfrmr_calibration_abort(
          "PARAMETER_COORDINATE_INVALID", "parameters.coordinates",
          paste0("interaction ", spec$InteractionId, " does not have one canonical coordinate per cell")
        )
      }
      interaction_values[[i]] <- matrix(
        as.numeric(rows$Value[position]),
        nrow = spec$LevelCountA, ncol = spec$LevelCountB,
        dimnames = list(facet_levels[[facet_a]], facet_levels[[facet_b]])
      )
    }
  }

  expected_coordinate_count <- sum(lengths(facet_levels)) +
    (if (identical(x$model$family, "RSM")) n_steps else {
      length(facet_levels[[x$model$step_owner]]) * n_steps
    }) + sum(x$model$interactions$LevelCountA * x$model$interactions$LevelCountB)
  if (nrow(coordinates) != expected_coordinate_count) {
    mfrmr_calibration_abort(
      "PARAMETER_COORDINATE_INVALID", "parameters.coordinates",
      "coordinate table contains an omitted or extraneous operational coordinate"
    )
  }

  list(
    facet_levels = facet_levels,
    facet_values = facet_values,
    shared_steps = shared_steps,
    owned_steps = owned_steps,
    interactions = interaction_values
  )
}

mfrmr_calibration_grid_quantile <- function(nodes, probabilities, probability) {
  hit <- which(cumsum(probabilities) >= probability)[1]
  hit <- if (is.na(hit)) length(nodes) else hit
  nodes[hit]
}

mfrmr_calibration_operational_scoring_policy <- function() {
  list(
    contract_id = "mfrmr_operational_scoring_v1",
    missing_response_policies = c("error", "omit"),
    very_sparse_max_responses = 1L,
    quadrature_edge_mass_threshold = 0.05,
    estimate_basis = "posterior_eap_fixed_calibration",
    uncertainty_basis = "conditional_on_frozen_point_calibration",
    prior_sensitivity_status = "not_evaluated_fixed_basis"
  )
}

mfrmr_score_calibration <- function(calibration,
                                    new_data,
                                    person = NULL,
                                    facets = NULL,
                                    score = NULL,
                                    weight = NULL,
                                    interval_level = 0.95,
                                    missing_response = "error",
                                    event_id = NULL) {
  review <- mfrmr_review_calibration(calibration)
  mfrmr_calibration_abort_review(review)
  if (!inherits(calibration, "mfrm_calibration")) {
    mfrmr_calibration_abort(
      "SCHEMA_CLASS_INVALID", "header.object_class",
      "scoring requires an mfrm_calibration"
    )
  }
  if (!identical(calibration$lifecycle$state, "frozen")) {
    mfrmr_calibration_abort(
      "LIFECYCLE_NOT_FROZEN", "lifecycle.state",
      "only a frozen calibration may score new Persons"
    )
  }
  if (!is.data.frame(new_data)) {
    mfrmr_calibration_abort(
      "SCORING_INPUT_TYPE_INVALID", "new_data",
      "must be a data.frame"
    )
  }
  if (nrow(new_data) == 0L) {
    mfrmr_calibration_abort(
      "SCORING_INPUT_EMPTY", "new_data",
      "must contain at least one response row"
    )
  }
  if (!is.numeric(interval_level) || length(interval_level) != 1L ||
      !is.finite(interval_level) || interval_level <= 0 || interval_level >= 1) {
    mfrmr_calibration_abort(
      "SCORING_INTERVAL_INVALID", "interval_level",
      "must be one finite number strictly between zero and one"
    )
  }
  scoring_policy <- mfrmr_calibration_operational_scoring_policy()
  if (!is.character(missing_response) || length(missing_response) != 1L ||
      is.na(missing_response) ||
      !missing_response %in% scoring_policy$missing_response_policies) {
    mfrmr_calibration_abort(
      "SCORING_MISSING_POLICY_INVALID", "missing_response",
      "must be exactly `error` or `omit`"
    )
  }

  source <- calibration$input_schema$source_columns
  person_col <- mfrmr_calibration_scoring_column(
    person, source$person, "person"
  )
  score_col <- mfrmr_calibration_scoring_column(score, source$score, "score")
  facet_cols <- mfrmr_calibration_scoring_facets(calibration, facets)
  weight_default <- source$weight
  weight_col <- if (is.null(weight) && is.null(weight_default)) {
    NULL
  } else {
    mfrmr_calibration_scoring_column(weight, weight_default, "weight")
  }
  event_id_col <- if (is.null(event_id)) {
    NULL
  } else {
    mfrmr_calibration_scoring_column(event_id, NULL, "event_id")
  }
  required <- c(
    person_col, unname(facet_cols), score_col, weight_col, event_id_col
  )
  if (anyDuplicated(required)) {
    mfrmr_calibration_abort(
      "SCORING_COLUMN_MAPPING_INVALID", "new_data",
      "person, facet, score, and weight columns must be distinct"
    )
  }
  missing_columns <- setdiff(required, names(new_data))
  if (length(missing_columns) > 0L) {
    mfrmr_calibration_abort(
      "SCORING_COLUMN_MISSING", "new_data",
      paste0("required columns are absent: ", paste(missing_columns, collapse = ", "))
    )
  }

  raw <- new_data[, required, drop = FALSE]
  names(raw) <- c(
    "Person", calibration$model$facet_names, "Score",
    if (!is.null(weight_col)) "Weight",
    if (!is.null(event_id_col)) "EventId"
  )
  to_label <- function(value, field_path) {
    if (is.list(value) || is.data.frame(value)) {
      mfrmr_calibration_abort(
        "SCORING_INPUT_TYPE_INVALID", field_path,
        "must be an atomic vector"
      )
    }
    value <- as.character(value)
    invalid <- is.na(value) | !nzchar(trimws(value))
    if (any(invalid)) {
      mfrmr_calibration_abort(
        "SCORING_VALUE_MISSING", field_path,
        paste0("contains missing or blank values at row(s): ",
               paste(utils::head(which(invalid), 10L), collapse = ", "))
      )
    }
    value
  }
  raw$Person <- to_label(raw$Person, paste0("new_data.", person_col))
  for (facet in calibration$model$facet_names) {
    raw[[facet]] <- to_label(
      raw[[facet]], paste0("new_data.", facet_cols[[facet]])
    )
  }
  if (!is.null(event_id_col)) {
    raw$EventId <- to_label(
      raw$EventId, paste0("new_data.", event_id_col)
    )
  }

  if (is.list(raw$Score) || is.data.frame(raw$Score)) {
    mfrmr_calibration_abort(
      "SCORING_INPUT_TYPE_INVALID", paste0("new_data.", score_col),
      "score must be an atomic vector"
    )
  }
  raw_score <- if (is.factor(raw$Score)) as.character(raw$Score) else raw$Score
  missing_score <- is.na(raw_score)
  if (is.character(raw_score)) {
    missing_score <- missing_score | !nzchar(trimws(raw_score))
  }
  if (any(missing_score) && identical(missing_response, "error")) {
    mfrmr_calibration_abort(
      "SCORING_SCORE_INVALID", paste0("new_data.", score_col),
      "every score must be numeric, finite, and present unless missing_response = `omit`"
    )
  }
  score_values <- rep(NA_real_, nrow(raw))
  score_values[!missing_score] <- suppressWarnings(
    as.numeric(raw_score[!missing_score])
  )
  if (any(!is.finite(score_values[!missing_score]))) {
    mfrmr_calibration_abort(
      "SCORING_SCORE_INVALID", paste0("new_data.", score_col),
      "every nonmissing score must be numeric and finite"
    )
  }
  score_map <- calibration$response$score_map
  internal_score <- rep(NA_integer_, nrow(raw))
  internal_score[!missing_score] <- score_map$InternalScore[
    match(score_values[!missing_score], score_map$OriginalScore)
  ]
  unknown_score <- !missing_score & is.na(internal_score)
  if (any(unknown_score)) {
    unknown <- sort(unique(score_values[unknown_score]))
    mfrmr_calibration_abort(
      "SCORING_SCORE_UNKNOWN", paste0("new_data.", score_col),
      paste0("score(s) are outside the frozen map: ", paste(unknown, collapse = ", "))
    )
  }

  weights <- if (is.null(weight_col)) {
    rep(1, nrow(raw))
  } else {
    if (is.list(raw$Weight) || is.data.frame(raw$Weight)) {
      mfrmr_calibration_abort(
        "SCORING_INPUT_TYPE_INVALID", paste0("new_data.", weight_col),
        "weight must be an atomic vector"
      )
    }
    raw_weight <- if (is.factor(raw$Weight)) as.character(raw$Weight) else raw$Weight
    suppressWarnings(as.numeric(raw_weight))
  }
  scored_row <- !missing_score
  if (length(weights) != nrow(raw) ||
      any(!is.finite(weights[scored_row])) || any(weights[scored_row] <= 0)) {
    mfrmr_calibration_abort(
      "SCORING_WEIGHT_INVALID",
      if (is.null(weight_col)) "weight" else paste0("new_data.", weight_col),
      "every weight must be finite and strictly positive"
    )
  }
  weights[!scored_row] <- NA_real_

  materialized <- mfrmr_calibration_materialize_scoring(calibration)
  facet_index <- vector("list", length(calibration$model$facet_names))
  names(facet_index) <- calibration$model$facet_names
  for (facet in calibration$model$facet_names) {
    facet_index[[facet]] <- match(raw[[facet]], materialized$facet_levels[[facet]])
    if (anyNA(facet_index[[facet]])) {
      unknown <- sort(unique(raw[[facet]][is.na(facet_index[[facet]])]))
      mfrmr_calibration_abort(
        "SCORING_FACET_LEVEL_UNKNOWN", paste0("new_data.", facet_cols[[facet]]),
        paste0("unseen level(s) for facet ", facet, ": ", paste(unknown, collapse = ", "))
      )
    }
  }
  event_fields <- c(
    "Person", calibration$model$facet_names,
    if (!is.null(event_id_col)) "EventId"
  )
  duplicate_event <- duplicated(raw[event_fields]) |
    duplicated(raw[event_fields], fromLast = TRUE)
  if (any(duplicate_event)) {
    mfrmr_calibration_abort(
      "SCORING_EVENT_DUPLICATE", "new_data",
      paste0("one response per Person-by-facet design cell is required; duplicate row(s): ",
             paste(utils::head(which(duplicate_event), 10L), collapse = ", "))
    )
  }

  all_person_labels <- unique(raw$Person)
  all_person_index <- match(raw$Person, all_person_labels)
  valid_responses <- tabulate(
    all_person_index[scored_row], nbins = length(all_person_labels)
  )
  omitted_responses <- tabulate(
    all_person_index[!scored_row], nbins = length(all_person_labels)
  )
  person_dispositions <- data.frame(
    Person = all_person_labels,
    Disposition = ifelse(valid_responses == 0L, "not_scored", "scored"),
    ReasonCodes = ifelse(
      valid_responses == 0L, "ZERO_VALID_RESPONSES", ""
    ),
    ValidResponses = as.integer(valid_responses),
    OmittedResponses = as.integer(omitted_responses),
    EndpointStatus = ifelse(
      valid_responses == 0L, "not_evaluated", "none"
    ),
    VerySparsePattern = rep(FALSE, length(all_person_labels)),
    QuadratureEdgeMass = rep(NA_real_, length(all_person_labels)),
    QuadratureEdgeThreshold = rep(
      scoring_policy$quadrature_edge_mass_threshold,
      length(all_person_labels)
    ),
    PriorSensitivityStatus = rep(
      scoring_policy$prior_sensitivity_status, length(all_person_labels)
    ),
    ReadinessStatus = ifelse(
      valid_responses == 0L, "not_scored", "conditional_score_ready"
    ),
    AdministrationCompleteness = ifelse(
      valid_responses == 0L,
      "no_valid_responses",
      ifelse(
        omitted_responses > 0L,
        "partial_supplied_missing_response",
        "not_evaluated_no_plan"
      )
    ),
    EstimateBasis = ifelse(
      valid_responses == 0L, "not_applicable", scoring_policy$estimate_basis
    ),
    UncertaintyBasis = ifelse(
      valid_responses == 0L, "not_applicable", scoring_policy$uncertainty_basis
    ),
    CalibrationId = rep(
      calibration$header$calibration_id, length(all_person_labels)
    ),
    stringsAsFactors = FALSE
  )
  row_dispositions <- data.frame(
    InputRow = seq_len(nrow(raw)),
    Person = raw$Person,
    stringsAsFactors = FALSE
  )
  for (facet in calibration$model$facet_names) {
    row_dispositions[[facet]] <- raw[[facet]]
  }
  row_dispositions$EventId <- if (is.null(event_id_col)) {
    rep(NA_character_, nrow(raw))
  } else {
    raw$EventId
  }
  row_dispositions$Score <- score_values
  row_dispositions$Weight <- weights
  row_dispositions$Disposition <- ifelse(scored_row, "scored", "omitted")
  row_dispositions$ReasonCode <- ifelse(
    scored_row, "ROW_SCORED", "RESPONSE_MISSING_OMITTED"
  )
  row_dispositions$CalibrationId <- rep(
    calibration$header$calibration_id, nrow(raw)
  )

  nodes <- calibration$scoring_basis$nodes
  estimates <- data.frame(
    Person = character(0), Estimate = numeric(0), SD = numeric(0),
    Lower = numeric(0), Upper = numeric(0), Observations = integer(0),
    WeightedN = numeric(0), Disposition = character(0),
    ReasonCodes = character(0), ReadinessStatus = character(0),
    EstimateBasis = character(0),
    UncertaintyBasis = character(0), CalibrationId = character(0),
    SchemaVersion = integer(0), ScoringBasis = character(0),
    stringsAsFactors = FALSE
  )
  if (any(scored_row)) {
    scoring_rows <- which(scored_row)
    scored_raw <- raw[scoring_rows, , drop = FALSE]
    scored_facet_index <- lapply(facet_index, function(index) index[scoring_rows])
    base_eta <- numeric(length(scoring_rows))
    for (facet in calibration$model$facet_names) {
      base_eta <- base_eta + calibration$model$facet_signs[[facet]] *
        materialized$facet_values[[facet]][scored_facet_index[[facet]]]
    }
    if (nrow(calibration$model$interactions) > 0L) {
      for (i in seq_len(nrow(calibration$model$interactions))) {
        spec <- calibration$model$interactions[i, , drop = FALSE]
        base_eta <- base_eta + materialized$interactions[[i]][cbind(
          scored_facet_index[[spec$FacetA]],
          scored_facet_index[[spec$FacetB]]
        )]
      }
    }

    person_labels <- unique(scored_raw$Person)
    person_index <- match(scored_raw$Person, person_labels)
    prior_weights <- calibration$scoring_basis$weights
    score_k <- as.integer(
      internal_score[scoring_rows] - calibration$response$rating_min
    )
    scored_weights <- weights[scoring_rows]
    k_values <- 0:(calibration$response$n_categories - 1L)
    log_likelihood <- matrix(
      0, nrow = length(person_labels), ncol = length(nodes),
      dimnames = list(person_labels, NULL)
    )
    processing_order <- do.call(
      order,
      c(list(person_index), unname(scored_facet_index), list(method = "radix"))
    )
    for (row in processing_order) {
      step_values <- if (identical(calibration$model$family, "RSM")) {
        materialized$shared_steps
      } else {
        owner <- calibration$model$step_owner
        materialized$owned_steps[scored_facet_index[[owner]][row], ]
      }
      cumulative_step <- c(0, cumsum(step_values))
      for (node in seq_along(nodes)) {
        logits <- k_values * (nodes[node] + base_eta[row]) - cumulative_step
        maximum <- max(logits)
        observed_log_probability <- logits[score_k[row] + 1L] -
          (maximum + log(sum(exp(logits - maximum))))
        log_likelihood[person_index[row], node] <-
          log_likelihood[person_index[row], node] +
          scored_weights[row] * observed_log_probability
      }
    }

    log_posterior <- sweep(log_likelihood, 2L, log(prior_weights), "+")
    posterior <- matrix(NA_real_, nrow(log_posterior), ncol(log_posterior))
    for (i in seq_len(nrow(log_posterior))) {
      maximum <- max(log_posterior[i, ])
      denominator <- maximum + log(sum(exp(log_posterior[i, ] - maximum)))
      posterior[i, ] <- exp(log_posterior[i, ] - denominator)
    }
    if (any(!is.finite(posterior)) ||
        any(abs(rowSums(posterior) - 1) > 1e-12)) {
      mfrmr_calibration_abort(
        "SCORING_NUMERICAL_FAILURE", "posterior",
        "posterior normalization did not produce finite unit sums"
      )
    }

    estimate <- as.vector(posterior %*% nodes)
    posterior_sd <- vapply(seq_along(person_labels), function(i) {
      sqrt(sum(posterior[i, ] * (nodes - estimate[i])^2))
    }, numeric(1))
    alpha <- (1 - interval_level) / 2
    lower <- vapply(seq_along(person_labels), function(i) {
      mfrmr_calibration_grid_quantile(nodes, posterior[i, ], alpha)
    }, numeric(1))
    upper <- vapply(seq_along(person_labels), function(i) {
      mfrmr_calibration_grid_quantile(nodes, posterior[i, ], 1 - alpha)
    }, numeric(1))
    observations <- tabulate(person_index, nbins = length(person_labels))
    weighted_n <- as.numeric(rowsum(
      scored_weights, person_index, reorder = FALSE
    )[, 1])
    edge_nodes <- unique(c(1L, ncol(posterior)))
    edge_mass <- rowSums(posterior[, edge_nodes, drop = FALSE])
    endpoint_status <- vapply(seq_along(person_labels), function(i) {
      values <- score_k[person_index == i]
      if (all(values == 0L)) {
        "all_lower_endpoint"
      } else if (all(values == calibration$response$n_categories - 1L)) {
        "all_upper_endpoint"
      } else {
        "none"
      }
    }, character(1))
    very_sparse <- observations <= scoring_policy$very_sparse_max_responses
    edge_review <- edge_mass >= scoring_policy$quadrature_edge_mass_threshold
    reason_codes <- vapply(seq_along(person_labels), function(i) {
      codes <- character(0)
      all_index <- match(person_labels[i], person_dispositions$Person)
      if (person_dispositions$OmittedResponses[all_index] > 0L) {
        codes <- c(codes, "RESPONSES_MISSING_OMITTED")
      }
      if (endpoint_status[i] == "all_lower_endpoint") {
        codes <- c(codes, "ALL_RESPONSES_LOWER_ENDPOINT")
      } else if (endpoint_status[i] == "all_upper_endpoint") {
        codes <- c(codes, "ALL_RESPONSES_UPPER_ENDPOINT")
      }
      if (very_sparse[i]) {
        codes <- c(codes, "VERY_SPARSE_RESPONSE_PATTERN")
      }
      if (edge_review[i]) {
        codes <- c(codes, "QUADRATURE_EDGE_MASS_REVIEW")
      }
      paste(codes, collapse = ";")
    }, character(1))
    disposition <- ifelse(nzchar(reason_codes), "scored_review", "scored")

    disposition_index <- match(person_labels, person_dispositions$Person)
    person_dispositions$Disposition[disposition_index] <- disposition
    person_dispositions$ReasonCodes[disposition_index] <- reason_codes
    person_dispositions$EndpointStatus[disposition_index] <- endpoint_status
    person_dispositions$VerySparsePattern[disposition_index] <- very_sparse
    person_dispositions$QuadratureEdgeMass[disposition_index] <- edge_mass
    person_dispositions$ReadinessStatus[disposition_index] <- ifelse(
      disposition == "scored", "conditional_score_ready", "review"
    )

    estimates <- data.frame(
      Person = person_labels,
      Estimate = estimate,
      SD = posterior_sd,
      Lower = lower,
      Upper = upper,
      Observations = as.integer(observations),
      WeightedN = weighted_n,
      Disposition = disposition,
      ReasonCodes = reason_codes,
      ReadinessStatus = ifelse(
        disposition == "scored", "conditional_score_ready", "review"
      ),
      EstimateBasis = rep(scoring_policy$estimate_basis, length(person_labels)),
      UncertaintyBasis = rep(
        scoring_policy$uncertainty_basis, length(person_labels)
      ),
      CalibrationId = rep(
        calibration$header$calibration_id, length(person_labels)
      ),
      SchemaVersion = rep(
        calibration$header$schema_version, length(person_labels)
      ),
      ScoringBasis = rep(calibration$scoring_basis$type, length(person_labels)),
      stringsAsFactors = FALSE
    )
  }

  input_data <- raw[c(
    "Person", calibration$model$facet_names,
    if (!is.null(event_id_col)) "EventId"
  )]
  input_data$Score <- score_values
  input_data$Weight <- weights
  structure(
    list(
      estimates = estimates,
      row_review = data.frame(
        InputRows = as.integer(nrow(raw)),
        ScoredRows = as.integer(sum(scored_row)),
        OmittedRows = as.integer(sum(!scored_row)),
        RefusedRows = 0L,
        MissingResponsePolicy = missing_response,
        stringsAsFactors = FALSE
      ),
      row_dispositions = row_dispositions,
      person_dispositions = person_dispositions,
      input_data = input_data,
      settings = list(
        calibration_id = calibration$header$calibration_id,
        semantic_identity_version =
          calibration$header$semantic_identity_version,
        semantic_components = calibration$integrity$semantic_components,
        schema_version = calibration$header$schema_version,
        lifecycle_state = calibration$lifecycle$state,
        family = calibration$model$family,
        estimator = calibration$model$estimator,
        scoring_basis = calibration$scoring_basis$type,
        scoring_algorithm = calibration$scoring_basis$scoring_algorithm,
        quadrature_order = calibration$scoring_basis$quadrature_order,
        interval_level = interval_level,
        missing_response_policy = missing_response,
        event_id_column = event_id_col,
        scoring_contract_id = scoring_policy$contract_id,
        prior_identity = list(
          type = calibration$scoring_basis$type,
          mean = calibration$scoring_basis$prior_mean,
          sd = calibration$scoring_basis$prior_sd
        ),
        quadrature_identity = list(
          rule = calibration$scoring_basis$quadrature_rule,
          order = calibration$scoring_basis$quadrature_order,
          edge_mass_threshold =
            scoring_policy$quadrature_edge_mass_threshold
        ),
        score_map = calibration$response$score_map,
        source_readiness_contract =
          calibration$eligibility$source_readiness_contract,
        source_readiness_status =
          calibration$eligibility$source_readiness_status,
        parameter_class_status =
          calibration$eligibility$parameter_class_status,
        package_version = as.character(utils::packageVersion("mfrmr")),
        source_columns = list(
          person = person_col, facets = facet_cols,
          score = score_col, weight = weight_col, event_id = event_id_col
        ),
        engine_identity = "artifact_coordinates_v1"
      ),
      notes = c(
        "Posterior summaries use only the frozen calibration artifact and supplied response rows.",
        "All estimates are posterior EAP values; endpoint results are not finite JML maxima.",
        "Posterior SD and intervals are conditional on the frozen point calibration and exclude calibration-parameter uncertainty.",
        "Prior sensitivity is not evaluated in the fixed-basis scoring call.",
        "No fit, training data, refit, RNG, or ambient option is consulted."
      )
    ),
    class = c("mfrm_calibration_score", "list")
  )
}

#' @export
summary.mfrm_calibration <- function(object, ...) {
  coordinates <- object$parameters$coordinates
  out <- list(
    calibration_id = object$header$calibration_id,
    schema_id = object$header$schema_id,
    schema_version = object$header$schema_version,
    state = object$lifecycle$state,
    model = object$model$family,
    estimator = object$model$estimator,
    lane = object$eligibility$lane_id,
    facets = length(object$model$facet_names),
    coordinates = nrow(coordinates),
    anchors = nrow(object$constraints$anchors),
    scoring_basis = object$scoring_basis$type,
    source_readiness = object$eligibility$source_readiness_status,
    refusals = mfrmr_review_calibration(object)
  )
  class(out) <- c("summary.mfrm_calibration", "list")
  out
}

#' @export
print.mfrm_calibration <- function(x, ...) {
  s <- summary.mfrm_calibration(x)
  cat("<mfrm_calibration>", "\n", sep = "")
  cat("  State: ", s$state, "\n", sep = "")
  cat("  Model: ", s$model, " / ", s$estimator, "\n", sep = "")
  cat("  Lane: ", s$lane, "\n", sep = "")
  cat("  Facets: ", s$facets, "; coordinates: ", s$coordinates,
      "; anchors: ", s$anchors, "\n", sep = "")
  cat("  Validation refusals: ", nrow(s$refusals), "\n", sep = "")
  invisible(x)
}

#' @export
print.summary.mfrm_calibration <- function(x, ...) {
  cat("mfrmr Calibration Summary\n")
  cat("  Calibration: ", x$calibration_id, "\n", sep = "")
  cat("  Schema: ", x$schema_id, " v", x$schema_version, "\n", sep = "")
  cat("  State: ", x$state, "\n", sep = "")
  cat("  Model/lane: ", x$model, " / ", x$estimator, " / ", x$lane, "\n", sep = "")
  cat("  Scoring basis: ", x$scoring_basis, "\n", sep = "")
  cat("  Validation refusals: ", nrow(x$refusals), "\n", sep = "")
  invisible(x)
}
