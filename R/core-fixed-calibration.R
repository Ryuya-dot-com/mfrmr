


mfrmr_calibration_refusal <- function(code, field_path, detail) {
    n <- length(code)
    data.frame(Code = as.character(code), FieldPath = as.character(field_path), Detail = as.character(detail), 
        Severity = rep("error", n), stringsAsFactors = FALSE)
}

mfrmr_calibration_abort <- function(code, field_path, detail, refusals = NULL) {
    code <- as.character(code[1])
    field_path <- as.character(field_path[1])
    detail <- as.character(detail[1])
    message <- paste0(code, " at `", field_path, "`: ", detail)
    condition <- structure(list(message = message, call = NULL, code = code, field_path = field_path, 
        detail = detail, refusals = refusals %||% mfrmr_calibration_refusal(code, field_path, detail)), 
        class = c("mfrm_calibration_error", "error", "condition"))
    stop(condition)
}


mfrmr_calibration_bind_rows <- function(rows, template) {
    if (length(rows) == 0L) 
        return(template)
    out <- do.call(rbind, rows)
    rownames(out) <- NULL
    out
}


mfrmr_calibration_anchor_template <- .mfrmr_empty_table(c(AnchorId = "character", AnchorType = "character", 
    ParameterClass = "character", OwnerFacet = "character", Level = "character", Step = "character", 
    GroupId = "character", Value = "double", CoordinateSystem = "character", DeclarationOrder = "integer"))

mfrmr_typed_anchor_note_template <- .mfrmr_empty_table(c(Code = "character", Selector = "character", 
    Count = "integer", Detail = "character"))

mfrmr_normalize_typed_anchors <- function(config, anchors) {
    expected <- names(mfrmr_calibration_anchor_template)
    if (!is.data.frame(anchors) || !identical(names(anchors), expected)) {
        mfrmr_calibration_abort("ANCHOR_DECLARATION_INVALID", "constraints.anchors", "typed anchors must use the exact registered columns")
    }
    if (nrow(anchors) == 0L) {
        return(list(anchors = mfrmr_calibration_anchor_template, notes = mfrmr_typed_anchor_note_template))
    }
    character_columns <- setdiff(expected, c("Value", "DeclarationOrder"))
    if (any(!vapply(anchors[character_columns], is.character, logical(1))) || !is.numeric(anchors$Value) || 
        !is.integer(anchors$DeclarationOrder)) {
        mfrmr_calibration_abort("ANCHOR_DECLARATION_INVALID", "constraints.anchors", "typed anchor columns must retain their registered storage types")
    }
    if (anyNA(anchors$AnchorId) || any(!nzchar(anchors$AnchorId)) || anyDuplicated(anchors$AnchorId)) {
        mfrmr_calibration_abort("ANCHOR_DECLARATION_INVALID", "constraints.anchors.AnchorId", "declaration identifiers must be nonempty and unique")
    }
    if (anyNA(anchors$DeclarationOrder) || any(anchors$DeclarationOrder < 1L) || anyDuplicated(anchors$DeclarationOrder)) {
        mfrmr_calibration_abort("ANCHOR_DECLARATION_INVALID", "constraints.anchors.DeclarationOrder", 
            "declaration order must be unique and positive but never sets precedence")
    }
    if (any(!is.finite(anchors$Value))) {
        mfrmr_calibration_abort("ANCHOR_DECLARATION_INVALID", "constraints.anchors.Value", "every anchor value must be finite")
    }
    if (anyNA(anchors$CoordinateSystem) || any(anchors$CoordinateSystem != "expanded_logit")) {
        mfrmr_calibration_abort("ANCHOR_COORDINATE_SYSTEM_INVALID", "constraints.anchors.CoordinateSystem", 
            "core anchors must use the exact expanded_logit coordinate system")
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
        mfrmr_calibration_abort("ANCHOR_DECLARATION_INVALID", "constraints.anchors.AnchorType", "anchor type is not supported by this calibration workflow")
    }
    for (i in seq_len(nrow(anchors))) {
        row <- anchors[i, , drop = FALSE]
        path <- paste0("constraints.anchors[", i, "]")
        type <- row$AnchorType
        if (type %in% c("direct", "group")) {
            if (!identical(row$ParameterClass, "facet") || missing_text(row$OwnerFacet) || missing_text(row$Level) || 
                present_text(row$Step) || (identical(type, "direct") && present_text(row$GroupId)) || 
                (identical(type, "group") && missing_text(row$GroupId))) {
                mfrmr_calibration_abort("ANCHOR_SELECTOR_INVALID", path, "facet anchors have an invalid direct/group selector shape")
            }
            if (!row$OwnerFacet %in% facet_names) {
                mfrmr_calibration_abort("ANCHOR_OWNER_UNKNOWN", paste0(path, ".OwnerFacet"), "facet owner is not declared by the model")
            }
            if (!row$Level %in% as.character(facet_levels[[row$OwnerFacet]])) {
                mfrmr_calibration_abort("ANCHOR_LEVEL_UNKNOWN", paste0(path, ".Level"), "facet level is not declared under the selected owner")
            }
        }
        else if (identical(type, "shared_step")) {
            if (!identical(row$ParameterClass, "shared_step") || present_text(row$OwnerFacet) || present_text(row$Level) || 
                missing_text(row$Step) || present_text(row$GroupId)) {
                mfrmr_calibration_abort("ANCHOR_SELECTOR_INVALID", path, "shared-step anchors require only a transition selector")
            }
            if (!identical(family, "RSM")) {
                mfrmr_calibration_abort("ANCHOR_OWNER_INCOMPATIBLE", path, "shared-step anchors belong only to RSM")
            }
        }
        else {
            if (!identical(row$ParameterClass, "owned_step") || missing_text(row$OwnerFacet) || missing_text(row$Level) || 
                missing_text(row$Step) || present_text(row$GroupId)) {
                mfrmr_calibration_abort("ANCHOR_SELECTOR_INVALID", path, "owned-step anchors require owner, owner level, and transition")
            }
            if (!identical(family, "PCM") || !identical(row$OwnerFacet, step_owner)) {
                mfrmr_calibration_abort("ANCHOR_OWNER_INCOMPATIBLE", paste0(path, ".OwnerFacet"), "owned-step anchor does not belong to the declared PCM step owner")
            }
            if (!row$Level %in% as.character(facet_levels[[step_owner]])) {
                mfrmr_calibration_abort("ANCHOR_LEVEL_UNKNOWN", paste0(path, ".Level"), "owned-step level is not declared under the step owner")
            }
        }
        if (type %in% c("shared_step", "owned_step")) {
            step <- suppressWarnings(as.integer(row$Step))
            if (is.na(step) || step < 1L || step > n_steps || !identical(as.character(step), row$Step)) {
                mfrmr_calibration_abort("ANCHOR_STEP_UNKNOWN", paste0(path, ".Step"), "transition must be a canonical integer in the declared category range")
            }
        }
    }
    semantic_key <- ifelse(anchors$AnchorType == "direct", paste("direct", anchors$OwnerFacet, anchors$Level, 
        sep = "::"), ifelse(anchors$AnchorType == "group", paste("group_member", anchors$OwnerFacet, 
        anchors$Level, sep = "::"), ifelse(anchors$AnchorType == "shared_step", paste("shared_step", 
        anchors$Step, sep = "::"), paste("owned_step", anchors$OwnerFacet, anchors$Level, anchors$Step, 
        sep = "::"))))
    group_target_key <- ifelse(anchors$AnchorType == "group", paste("group_target", anchors$OwnerFacet, 
        anchors$GroupId, sep = "::"), NA_character_)
    conflict <- function(key, include_group) {
        for (value in unique(key[!is.na(key)])) {
            index <- which(key == value)
            signatures <- if (include_group) {
                paste(anchors$GroupId[index], sprintf("%.17g", anchors$Value[index]), sep = "\r")
            }
            else {
                sprintf("%.17g", anchors$Value[index])
            }
            if (length(unique(signatures)) > 1L) 
                return(value)
        }
        NA_character_
    }
    conflict_selector <- conflict(semantic_key, include_group = TRUE)
    if (!is.na(conflict_selector)) {
        mfrmr_calibration_abort("ANCHOR_CONFLICT", "constraints.anchors", paste0("conflicting declarations target selector `", 
            conflict_selector, "`"))
    }
    group_conflict <- conflict(group_target_key, include_group = FALSE)
    if (!is.na(group_conflict)) {
        mfrmr_calibration_abort("ANCHOR_CONFLICT", "constraints.anchors", paste0("group mean differs within selector `", 
            group_conflict, "`"))
    }
    duplicate_groups <- split(seq_len(nrow(anchors)), semantic_key)
    duplicate_groups <- duplicate_groups[lengths(duplicate_groups) > 1L]
    notes <- if (length(duplicate_groups) == 0L) {
        mfrmr_typed_anchor_note_template
    }
    else {
        do.call(rbind, lapply(names(duplicate_groups), function(selector) {
            data.frame(Code = "ANCHOR_DUPLICATE_DEDUPLICATED", Selector = selector, Count = as.integer(length(duplicate_groups[[selector]])), 
                Detail = "identical declarations were collapsed without precedence", stringsAsFactors = FALSE)
        }))
    }
    keep <- vapply(duplicate_groups <- split(seq_len(nrow(anchors)), semantic_key), function(index) index[1], 
        integer(1))
    out <- anchors[sort(keep), , drop = FALSE]
    facet_index <- match(out$OwnerFacet, facet_names)
    facet_index[is.na(facet_index)] <- 0L
    level_index <- vapply(seq_len(nrow(out)), function(i) {
        if (is.na(out$OwnerFacet[i]) || !nzchar(out$OwnerFacet[i])) 
            return(0L)
        match(out$Level[i], as.character(facet_levels[[out$OwnerFacet[i]]])) %||% 0L
    }, integer(1))
    step_index <- suppressWarnings(as.integer(out$Step))
    step_index[is.na(step_index)] <- 0L
    type_index <- match(out$AnchorType, valid_types)
    ord <- order(type_index, facet_index, level_index, step_index, ifelse(is.na(out$GroupId), "", out$GroupId), 
        method = "radix")
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
        rows[[length(rows) + 1L]] <<- data.frame(AnchorId = paste0("existing::", length(rows) + 1L), 
            AnchorType = type, ParameterClass = parameter_class, OwnerFacet = owner, Level = level, Step = step, 
            GroupId = group, Value = as.numeric(value), CoordinateSystem = "expanded_logit", DeclarationOrder = as.integer(length(rows) + 
                1L), stringsAsFactors = FALSE)
    }
    for (facet in as.character(config$facet_names %||% character(0))) {
        spec <- config$facet_specs[[facet]]
        levels <- as.character(spec$levels)
        for (i in which(is.finite(spec$anchors))) {
            add("direct", "facet", facet, levels[i], NA_character_, NA_character_, spec$anchors[i])
        }
        groups <- as.character(spec$groups %||% rep(NA_character_, length(levels)))
        for (i in which(!is.na(groups) & nzchar(groups))) {
            add("group", "facet", facet, levels[i], NA_character_, groups[i], spec$group_values[[groups[i]]])
        }
    }
    step_specs <- mfrmr_step_specs(config)
    for (scope_index in seq_along(step_specs)) {
        spec <- step_specs[[scope_index]]
        for (step in which(is.finite(spec$anchors))) {
            if (identical(config$model, "RSM")) {
                add("shared_step", "shared_step", NA_character_, NA_character_, as.character(step), NA_character_, 
                  spec$anchors[step])
            }
            else {
                add("owned_step", "owned_step", as.character(config$step_facet), names(step_specs)[scope_index], 
                  as.character(step), NA_character_, spec$anchors[step])
            }
        }
    }
    mfrmr_calibration_bind_rows(rows, mfrmr_calibration_anchor_template)
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

































