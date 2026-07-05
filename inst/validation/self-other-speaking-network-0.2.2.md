# Self/other speaking assessment network example for 0.2.2

This artifact fixes the recommended interpretation route for a speaking
assessment design in which each learner's self-rater ID is literally the
same as the `Person` ID, while teacher ratings are supplied by external
raters. The example separates three questions:

- the full fitted observation graph, where Task/Criterion can act as hubs;
- the Person-plus-Rater projection, where literal self-rater leaves and
  bridge dependencies are visible;
- the Assessor/AssessorType route, where the estimand is self-versus-
  teacher mode rather than literal rater identity.

- Status: ok
- Checks: 9
- Failed checks: 0

## Summary

- Rows/persons/teacher raters: 324 / 18 / 3
- Full graph: components=1, articulation_points=0, bridges=0
- Person-plus-Rater projection: components=1, articulation_points=18, bridges=18
- Literal self-rater nodes: 18, degree range=1-1
- AssessorType mode graph: components=1, self degree=18, teacher degree=18
- Collapsed Assessor severity network: edges=12, self severity index=-1.159
- Projected network plot payload: layout=39, nodes=39, edges=54
- Collapsed Assessor plot payload: layout=4, nodes=4, edges=12

## Interpretation

- Use the full graph for broad observation-design connectedness.
- Use `facets = "Rater"` when the claim is about literal self-rater
  isolation or teacher bridging.
- Use an `AssessorType` or collapsed `Assessor` facet when the claim is
  about self-versus-teacher mode severity rather than individual rater IDs.
- Use `rater_network_analysis()` on the collapsed Assessor route for
  pairwise score-relationship summaries; keep it separate from the
  co-observation design graph.
- Use draw-free `type = "network"` plot payloads for custom figures;
  layout coordinates are graphical positions, not model estimates.

## Failed checks

None.
