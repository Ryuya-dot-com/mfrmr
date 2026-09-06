# D-SIM-3 v4 five-scope resource-controller qualification record

Status: fifth shared-substrate layer qualified; final unopened-855 launch-readiness reconciliation required
Date: 2026-08-31
Contract: `MFRMR-GTHEORY-MV-DSIM3-RESOURCE-CONTROLLER-V1`
Parent route/receipt-contract hash: `0b74d833dc9bff44e3eded32261258b8dbd5ca6a2a30805c871d2cc22c9d0129`
Parent route/receipt-manifest hash: `6a59dc1a7874f731554baff7a134b8b52ad18614e26ee80470d08ffbd8372e9f`
Parent execution-plan hash: `b91ab4229203efc15a3ca9421256d81ae7331143e42f845b5c6a879575552de7`
Parent resource-registry hash: `0d9cdfa0cd36b6750ac34aa09e9cd196127cda0718a6d525788fadc673c19195`
Worker SHA-256: `44c2a2eb527b53d220cdb8f2e52c34e89651a005ed475331ddac15a868b0a4d0`
Resource-controller contract hash: `535ab118a335a66bf0fd264ecc609249dc4e5042ffa1ac64aee1fdc846c94919`
Resource-controller manifest hash: `2a752382b94d0eb0b488c1e7b96029f0f6cc786738997e2dc7c27f28c4051f9d`

## Result

One controller path now enforces the five resource scopes frozen in the
unopened D-SIM-3 execution contract. Fifteen isolated R subprocess probes
exercise success, wall-time exceedance, and peak-RSS exceedance for every
scope. Exceedance probes are actually terminated by the controller; this is
not a schema-only or mocked receipt test.

| Quantity | Result |
|---|---:|
| frozen resource scopes qualified | 5/5 |
| isolated process probes qualified | 15/15 |
| successful-exit probes | 5/5 |
| wall-time enforcement probes | 5/5 |
| peak-RSS enforcement probes | 5/5 |
| live-worker concurrency probes | 1/1 |
| composite stop-new-launches probes | 2/2 |
| registered composite probe units retained | 6/6 |
| terminal receipts fabricated for unlaunched units | 0 |
| replacement launches | 0 |
| exploratory 855 datasets / responses | 0 / 0 |
| backend calls / fits / metrics | 0 / 0 / 0 |

The production limits remain those frozen upstream: 300 seconds and 2,048 MiB
for one dataset generation; 1,200 seconds and 8,192 MiB for one route fit; 120
seconds and 2,048 MiB for one route metric; 7,200 seconds and 8,192 MiB for one
dataset pipeline; and 172,800 seconds and 8,192 MiB for the complete
exploratory run. Every scope permits at most one active worker.

## Mechanics probes are not capacity claims

The probes use deliberately smaller trigger values so success, wall-time, and
RSS behavior can be checked quickly and safely. They exercise the same
controller path to which the production limits are bound, but they do not show
that a real fit will complete inside the production envelope. Consequently,
`ProbeBudgetsAreProductionCapacityClaims` is false.

Exact elapsed time and observed peak RSS depend on the host and are not kept in
the canonical manifest. The normalized receipts retain only whether each
measurement was observed, which limit relation triggered, whether a signal was
sent, whether the process terminated, and whether the expected outcome was
obtained. This keeps the evidence replayable without turning incidental host
performance into a frozen statistical result.

## Atomic termination and composite stopping are different

Resource exceedance at the three atomic scopes projects to an existing unit
terminal state:

- `dataset_generation` -> `generation_resource_limit`;
- `one_route_fit` -> `fit_resource_limit`; and
- `one_route_metric` -> `metric_resource_limit`.

The dataset-pipeline and complete-run scopes instead issue controller-level
stop receipts. Once triggered, new launches are denied, but every registered
unit remains in the denominator. A unit that was never launched receives no
invented failure or terminal receipt, and no replacement launch is created.
This preserves the route/receipt layer's present-tense exactly-one accounting.

The concurrency probe also observes that the first worker is live when the
second admission is attempted. With the frozen maximum of one worker, the
second launch is denied as `maximum_concurrent_workers_reached`, after which
the first probe process is terminated and reaped.

## Claim boundary and next dependency

This record qualifies resource mechanics and completes the five shared
pre-execution substrate layers. It is not workload capacity evidence, model
recovery evidence, backend parity, inference, a validation result, or public
support. The 855 RNG band remains unopened, feature maturity remains
`specified`, and no execution authority follows automatically from a
mechanics pass.

The next bounded task is one final, nonexecuting launch-readiness
reconciliation. It must compare the frozen 855 plan, current environment,
backend requests, route eligibility, terminal accounting, and resource
controller as one identity-bound package. Only that reconciliation may decide
whether the exploratory launch contract is internally ready to be opened; it
must not itself generate a response, call a backend, or claim support.
