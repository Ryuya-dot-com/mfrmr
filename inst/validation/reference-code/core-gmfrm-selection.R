# Review a completed, prespecified start set. The caller binds all likelihood
# evidence to the same data/model; constraint applicability is checked here.
mfrm_gmfrm_select_candidates <- function(candidates, starts, reference_nll,
                                         comparisons = list()) {
  real <- function(x) is.numeric(x) && !is.complex(x)
  if (!is.character(starts) || length(starts) < 2L || anyNA(starts) ||
      any(!nzchar(starts)) || anyDuplicated(starts) || !is.list(candidates) ||
      length(candidates) != length(starts) || anyDuplicated(names(candidates)) ||
      !setequal(names(candidates), starts) || !real(reference_nll) ||
      length(reference_nll) != length(starts) || anyDuplicated(names(reference_nll)) ||
      !setequal(names(reference_nll), starts) || any(is.infinite(reference_nll)) ||
      !is.list(comparisons) || (length(comparisons) &&
        (is.null(names(comparisons)) || anyNA(names(comparisons)) ||
         any(!nzchar(names(comparisons))) || anyDuplicated(names(comparisons)))))
    stop("Supply every prescribed start and its verified NLL or explicit NA.")
  candidates <- candidates[starts]; reference_nll <- reference_nll[starts]
  first <- candidates[[1]]; fixed <- first$fixed
  values <- first$selected$parameters[fixed]; p <- length(first$selected$parameters)
  constraint_ok <- function(f, v) real(f) && real(v) && length(f) == length(v) &&
    all(is.finite(c(f,v))) && !anyDuplicated(f) && all(f == trunc(f) & f >= 1 & f <= p)
  if (!p || !constraint_ok(fixed, values)) stop("Invalid original constraint.")
  table <- do.call(rbind, lapply(starts, function(name) {
    a <- candidates[[name]]; z <- a$selected$parameters; raw <- a$selected$evaluation$value
    if (!real(z) || length(z) != p || any(!is.finite(z)) || !real(raw) ||
        length(raw) != 1L || !is.finite(raw) || !identical(a$fixed, fixed) ||
        !identical(z[fixed], values) || !is.character(a$status) || length(a$status) != 1L || is.na(a$status))
      stop("Candidates must share the original constraint and finite point representation.")
    ref <- unname(reference_nll[name])
    if (is.finite(ref) && abs(ref-raw) > 1e-7)
      stop("Verified NLL does not match the saved candidate point.")
    qualified <- identical(a$status, "reference_qualified_local_candidate")
    if (qualified && (!is.finite(ref) || !isTRUE(a$stages$reference$passed) ||
        !isTRUE(a$stages$reference$reference$qualified) ||
        !isTRUE(all.equal(ref, a$stages$reference$reference$nll, tolerance=0)) ||
        is.null(a$information) || !identical(a$information$parameters, a$native_parameters) ||
        !identical(a$information$free, setdiff(seq_len(p),fixed)) ||
        !identical(a$information_scope, if(length(fixed)) "conditional_nuisance" else "joint_unrestricted")))
      stop("Qualified candidate is missing its matching reference or information.")
    data.frame(Start=name, Status=a$status, Qualified=qualified, ReportedNLL=raw,
      ReferenceNLL=ref, ReferenceAvailable=is.finite(ref), stringsAsFactors=FALSE)
  }))
  comparison_table <- data.frame(Name=character(), Kind=character(), NLL=numeric(),
    Verified=logical(), Applicable=logical(), FamilyExcluded=logical(), stringsAsFactors=FALSE)
  for (name in names(comparisons)) {
    b <- comparisons[[name]]
    if (!is.character(b$kind) || length(b$kind) != 1L || is.na(b$kind) ||
        !b$kind %in% c("feasible_point","feasible_limit","family_lower_bound") ||
        !real(b$nll) || length(b$nll) != 1L || is.infinite(b$nll) ||
        !is.logical(b$verified) || length(b$verified) != 1L || is.na(b$verified) ||
        (b$verified && !is.finite(b$nll)) || !constraint_ok(b$fixed,b$values))
      stop("Invalid comparison kind, likelihood, verification or constraint certificate.")
    bound <- b$kind == "family_lower_bound"
    # Feasible witnesses must satisfy the target null. A family lower bound
    # can also cover it by bounding a larger, less constrained family.
    from <- if(bound) b$fixed else fixed
    to <- if(bound) fixed else b$fixed
    left <- if(bound) b$values else values
    right <- if(bound) values else b$values
    at <- match(from,to)
    applicable <- !anyNA(at) && identical(unname(left),unname(right[at]))
    comparison_table <- rbind(comparison_table,data.frame(Name=name,Kind=b$kind,NLL=b$nll,
      Verified=b$verified,Applicable=applicable,FamilyExcluded=FALSE))
  }
  usable <- comparison_table$Verified & comparison_table$Applicable
  witnesses <- usable & comparison_table$Kind != "family_lower_bound"
  known <- c(table$ReferenceNLL[table$ReferenceAvailable],comparison_table$NLL[witnesses])
  best_known <- if(length(known)) min(known) else NA_real_
  bounds <- usable & comparison_table$Kind == "family_lower_bound"
  if (is.finite(best_known)) comparison_table$FamilyExcluded[bounds] <-
    comparison_table$NLL[bounds]-best_known > 1e-6
  qualified <- which(table$Qualified)
  best <- if(length(qualified)) qualified[which.min(table$ReferenceNLL[qualified])] else NA_integer_
  spread <- if(all(table$ReferenceAvailable)) diff(range(table$ReferenceNLL)) else NA_real_
  dominated <- if(length(qualified)) table$ReferenceNLL[best] > best_known+1e-5 else NA
  status <- if(!length(qualified)) "no_qualified_candidate" else
    if(!all(table$Qualified)) "incomplete_start_qualification" else
    if(!is.finite(spread) || spread > 1e-5) "start_disagreement" else
    if(dominated) "dominated_candidate" else "local_candidate_selected"
  selected <- if(status == "local_candidate_selected") starts[best] else NA_character_
  list(status=status, selected=selected,
    candidate=if(is.na(selected)) NULL else candidates[[selected]],
    best_qualified=if(length(qualified)) starts[best] else NA_character_,
    best_known_nll=best_known, start_spread=spread, dominated=dominated,
    attempts=table, comparisons=comparison_table, evidence=comparisons,
    fixed=fixed, fixed_values=values,
    global_optimality="not assessed; only supplied starts and comparisons reviewed",
    interval_qualification="not assessed")
}
