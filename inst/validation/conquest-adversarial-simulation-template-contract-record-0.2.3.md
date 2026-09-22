# ConQuest adversarial simulation template contract for mfrmr 0.2.3

Status:
`ASP_G1_cross_family_deterministic_templates_complete_execution_closed`,
2026-08-15.

- Specification: `0.2.3-conquest-adversarial-simulation-template-contract-v1`
- Contract: `mfrmr_conquest_adversarial_simulation_template_contract_v1`
- Completed gate: `ASP-G1-TEMPLATE-COMPLETION`
- Next gate: `ASP-G2-DGP-ORACLE-SEPARATION`

## Completed template envelope

The nine registered failure-mode classes now each have an RSM and PCM arm,
for 18 deterministic arms. Six scenario-level gaps required seven new arms:

- two disjoint complete-crossing prototype arms;
- PCM paired planned/explicit missingness;
- RSM rare boundary categories;
- PCM extreme Person scores;
- RSM unused-intermediate-category rejection; and
- PCM disconnected-design rejection.

All Persons use the reserved `ASPT` prototype namespace. The fixed responses
are structural probes only. They are neither random draws nor admissible smoke,
calibration, or confirmation data.

## Structural evidence

Every eligible arm retains the expected constrained location-predictor rank at
relative singular-value tolerances `1e-12`, `1e-10`, and `1e-8`: 9 for RSM and
13 for PCM. The complete arms contain 576 rows and all six positive Rater-pair
edges. The sparse multiple-bridge, weak single-bridge, unequal-workload,
missingness, rare-category, and extreme-Person classes satisfy their distinct
structural contracts in both families.

The paired missingness arms each retain 288 observed rows. Their explicit
representations contain 576 rows with 288 typed missing responses, and the
retained observed data equal the planned-absence representation exactly.

## Corrected interpretation of the negative controls

The disconnected control is not rejected merely because an informal graph
label says “disconnected.” In both families, X is perfectly confounded with the
two Person--Rater components. The complete location predictor—population
intercept, population slope, and constrained conditional coordinates—is checked
directly. It has rank 8 of 9 for RSM and 12 of 13 for PCM at all three registered
tolerances. Criterion sharing and the common MML population therefore are not
silently treated as proof either for or against identification.

The unused-category control has full algebraic location-predictor rank, but no
observed category 1 and positive counts in categories 0, 2, and 3. Its rejection
is a support/boundary claim, not a design-rank claim. Later code must not merge
these two failure mechanisms.

## Current authorization state

- `ScenarioClasses=9`
- `FamilyArms=18`
- `ScenarioGapsClosed=6`
- `NewArmsRelativeToP2Registry=7`
- `LegacyDisconnectedLabelUsedAsProof=FALSE`
- `DisconnectedFullLocationPredictorRankChecked=TRUE`
- `UnusedCategoryRejectionIsRankClaim=FALSE`
- `UnusedCategoryRejectionIsSupportBoundaryClaim=TRUE`
- `ASPG1Complete=TRUE`
- `PrototypeResponsesReusableAsSampledData=FALSE`
- `AnyRandomResponseGenerated=FALSE`
- `AnyFitAttempted=FALSE`
- `ConQuestExecutionAttempted=FALSE`
- `PublicTextChangeAuthorized=FALSE`
- `ScientificEquivalenceInferred=FALSE`
