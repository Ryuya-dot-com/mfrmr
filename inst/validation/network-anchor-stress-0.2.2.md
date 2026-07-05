# Network/anchor stress checks for 0.2.2

This artifact stress-tests projected MFRM design networks, zero-overlap
rater networks, self-rater identity designs, disconnected rater panels,
coverage-dose behavior, role/mode specifications, peer-rater designs,
and group-anchor-only low-common-anchor guidance.

- Scenarios: 16
- Checks: 116
- Failed checks: 0

## Scenario summary

Scenario | Full components | Projected components | Projected bridges | Self degree | Self severity index | Downstream rows | Network plot payload
--- | ---: | ---: | ---: | --- | ---: | --- | ---
self_only_zero_overlap | 1 | 24 | 24 | 1-1 | NA | checks=10; visuals=5; templates=5 | layout=48; nodes=48; edges=24
mixed_literal_self_plus_teachers_seed1 | 1 | 1 | 24 | 1-1 | NA | checks=10; visuals=5; templates=5 | layout=52; nodes=52; edges=72
mixed_literal_self_plus_teachers_seed2 | 1 | 1 | 24 | 1-1 | NA | checks=10; visuals=5; templates=5 | layout=52; nodes=52; edges=72
self_teacher_role_rater_only_projection | 1 | 1 | 24 | 1-1 | NA | checks=10; visuals=5; templates=5 | layout=52; nodes=52; edges=72
self_teacher_role_rater_projection | 1 | 1 | 0 | 2-2 | NA | checks=10; visuals=5; templates=5 | layout=54; nodes=54; edges=148
speaking_peer_literal_student_ids | 1 | 1 | 0 | 3-3 | NA | checks=10; visuals=5; templates=5 | layout=50; nodes=50; edges=120
speaking_peer_collapsed_self_assessor | 1 | 1 | 0 | 24-24 | -2.1564026 | checks=10; visuals=5; templates=5 | layout=51; nodes=51; edges=120
speaking_role_only_modes | 1 | 1 | 0 | 24-24 | -0.8255718 | checks=10; visuals=5; templates=5 | layout=27; nodes=27; edges=72
assessor_collapsed_self_plus_teachers_seed1 | 1 | 1 | 0 | 24-24 | -1.2896675 | checks=10; visuals=5; templates=5 | layout=29; nodes=29; edges=72
assessor_collapsed_self_plus_teachers_seed2 | 1 | 1 | 0 | 24-24 | -1.2266642 | checks=10; visuals=5; templates=5 | layout=29; nodes=29; edges=72
two_panel_gap_full_graph_masked | 1 | 2 | 0 | NA-NA | NA | checks=10; visuals=5; templates=5 | layout=28; nodes=28; edges=48
coverage_T0 | 1 | 24 | 24 | 1-1 | NA | checks=10; visuals=5; templates=5 | layout=48; nodes=48; edges=24
coverage_T1_rotating_panel | 1 | 4 | 48 | 1-1 | NA | checks=10; visuals=5; templates=5 | layout=52; nodes=52; edges=48
coverage_T1_common_teacher | 1 | 1 | 48 | 1-1 | NA | checks=10; visuals=5; templates=5 | layout=49; nodes=49; edges=48
coverage_T4 | 1 | 1 | 24 | 1-1 | NA | checks=10; visuals=5; templates=5 | layout=52; nodes=52; edges=120
group_anchor_only_low_common | NA | NA | NA | NA-NA | NA | checks=NA; visuals=NA; templates=NA | layout=NA; nodes=NA; edges=NA

## Interpretation checkpoints

- The full Person-plus-all-facet graph remains connected in designs where
  broad task/criterion facets act as hubs; rater-specific design questions
  should use a projected graph such as `facets = "Rater"`.
- Adding `Role` to the projection can answer a method-mode question, but it
  can also hide the individual self-rater leaf/bridge pattern. Compare
  `self_teacher_role_rater_only_projection` with
  `self_teacher_role_rater_projection`.
- When student IDs appear as both self-raters and peer-raters, the literal
  `Rater` facet estimates student-rater behavior, not a self-assessment
  mode. Use an `Assessor` or `Role` facet when the estimand is self-vs-other
  mode severity.
- Teacher coverage is not a simple dose count: one common teacher links the
  projected graph, while one rotating teacher per person can leave separate
  teacher-panel components.
- Draw-free network figures are checked as reusable plot payloads: layout,
  node_plot, and edge_plot rows must be available for downstream graphics.
- Each rater-network mode is checked for assumption checks, visualization
  routes, APA-style report templates, and non-empty wording-to-avoid
  guardrails, including zero-overlap designs with no retained edges.

## Failed checks

None.

## Rater-mode rows

Scenario | Mode | Pair rows | Zero-overlap pairs | Edges | Downstream rows
--- | --- | ---: | ---: | ---: | ---
self_only_zero_overlap | severity_direction | 276 | 276 | 0 | checks=6; visuals=5; templates=5; avoid=5
self_only_zero_overlap | agreement | 276 | 276 | 0 | checks=6; visuals=5; templates=5; avoid=5
self_only_zero_overlap | disagreement | 276 | 276 | 0 | checks=6; visuals=5; templates=5; avoid=5
mixed_literal_self_plus_teachers_seed1 | severity_direction | 378 | 326 | 75 | checks=6; visuals=5; templates=5; avoid=5
mixed_literal_self_plus_teachers_seed1 | agreement | 378 | 326 | 52 | checks=6; visuals=5; templates=5; avoid=5
mixed_literal_self_plus_teachers_seed1 | disagreement | 378 | 326 | 52 | checks=6; visuals=5; templates=5; avoid=5
mixed_literal_self_plus_teachers_seed2 | severity_direction | 378 | 326 | 64 | checks=6; visuals=5; templates=5; avoid=5
mixed_literal_self_plus_teachers_seed2 | agreement | 378 | 326 | 52 | checks=6; visuals=5; templates=5; avoid=5
mixed_literal_self_plus_teachers_seed2 | disagreement | 378 | 326 | 52 | checks=6; visuals=5; templates=5; avoid=5
self_teacher_role_rater_only_projection | severity_direction | 378 | 326 | 66 | checks=6; visuals=5; templates=5; avoid=5
self_teacher_role_rater_only_projection | agreement | 378 | 326 | 52 | checks=6; visuals=5; templates=5; avoid=5
self_teacher_role_rater_only_projection | disagreement | 378 | 326 | 52 | checks=6; visuals=5; templates=5; avoid=5
self_teacher_role_rater_projection | severity_direction | 378 | 326 | 67 | checks=6; visuals=5; templates=5; avoid=5
self_teacher_role_rater_projection | agreement | 378 | 326 | 52 | checks=6; visuals=5; templates=5; avoid=5
self_teacher_role_rater_projection | disagreement | 378 | 326 | 52 | checks=6; visuals=5; templates=5; avoid=5
speaking_peer_literal_student_ids | severity_direction | 325 | 228 | 173 | checks=6; visuals=5; templates=5; avoid=5
speaking_peer_literal_student_ids | agreement | 325 | 228 | 97 | checks=6; visuals=5; templates=5; avoid=5
speaking_peer_literal_student_ids | disagreement | 325 | 228 | 97 | checks=6; visuals=5; templates=5; avoid=5
speaking_peer_collapsed_self_assessor | severity_direction | 351 | 252 | 167 | checks=6; visuals=5; templates=5; avoid=5
speaking_peer_collapsed_self_assessor | agreement | 351 | 252 | 99 | checks=6; visuals=5; templates=5; avoid=5
speaking_peer_collapsed_self_assessor | disagreement | 351 | 252 | 99 | checks=6; visuals=5; templates=5; avoid=5
speaking_role_only_modes | severity_direction | 3 | 0 | 6 | checks=6; visuals=5; templates=5; avoid=5
speaking_role_only_modes | agreement | 3 | 0 | 3 | checks=6; visuals=5; templates=5; avoid=5
speaking_role_only_modes | disagreement | 3 | 0 | 3 | checks=6; visuals=5; templates=5; avoid=5
assessor_collapsed_self_plus_teachers_seed1 | severity_direction | 10 | 2 | 16 | checks=6; visuals=5; templates=5; avoid=5
assessor_collapsed_self_plus_teachers_seed1 | agreement | 10 | 2 | 8 | checks=6; visuals=5; templates=5; avoid=5
assessor_collapsed_self_plus_teachers_seed1 | disagreement | 10 | 2 | 8 | checks=6; visuals=5; templates=5; avoid=5
assessor_collapsed_self_plus_teachers_seed2 | severity_direction | 10 | 2 | 16 | checks=6; visuals=5; templates=5; avoid=5
assessor_collapsed_self_plus_teachers_seed2 | agreement | 10 | 2 | 8 | checks=6; visuals=5; templates=5; avoid=5
assessor_collapsed_self_plus_teachers_seed2 | disagreement | 10 | 2 | 8 | checks=6; visuals=5; templates=5; avoid=5
two_panel_gap_full_graph_masked | severity_direction | 6 | 4 | 4 | checks=6; visuals=5; templates=5; avoid=5
two_panel_gap_full_graph_masked | agreement | 6 | 4 | 2 | checks=6; visuals=5; templates=5; avoid=5
two_panel_gap_full_graph_masked | disagreement | 6 | 4 | 2 | checks=6; visuals=5; templates=5; avoid=5
coverage_T0 | severity_direction | 276 | 276 | 0 | checks=6; visuals=5; templates=5; avoid=5
coverage_T0 | agreement | 276 | 276 | 0 | checks=6; visuals=5; templates=5; avoid=5
coverage_T0 | disagreement | 276 | 276 | 0 | checks=6; visuals=5; templates=5; avoid=5
coverage_T1_rotating_panel | severity_direction | 378 | 354 | 31 | checks=6; visuals=5; templates=5; avoid=5
coverage_T1_rotating_panel | agreement | 378 | 354 | 24 | checks=6; visuals=5; templates=5; avoid=5
coverage_T1_rotating_panel | disagreement | 378 | 354 | 24 | checks=6; visuals=5; templates=5; avoid=5
coverage_T1_common_teacher | severity_direction | 300 | 276 | 32 | checks=6; visuals=5; templates=5; avoid=5
coverage_T1_common_teacher | agreement | 300 | 276 | 24 | checks=6; visuals=5; templates=5; avoid=5
coverage_T1_common_teacher | disagreement | 300 | 276 | 24 | checks=6; visuals=5; templates=5; avoid=5
coverage_T4 | severity_direction | 378 | 276 | 137 | checks=6; visuals=5; templates=5; avoid=5
coverage_T4 | agreement | 378 | 276 | 102 | checks=6; visuals=5; templates=5; avoid=5
coverage_T4 | disagreement | 378 | 276 | 102 | checks=6; visuals=5; templates=5; avoid=5

See `network-anchor-stress-0.2.2-summary.csv`,
`network-anchor-stress-0.2.2-checks.csv`, and
`network-anchor-stress-0.2.2-rater-modes.csv` for machine-readable output.
