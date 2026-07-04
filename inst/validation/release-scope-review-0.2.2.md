# Release-scope review (0.2.2)

This lightweight review checks that the 0.2.2 release-scope claims
remain synchronized across the README, NEWS, CRAN comments, helper output,
generated help, and fixed validation evidence. It covers the comprehensive
scope map, the unidimensional `fit_mfrm()` engine boundary, G-theory as an
observed-score complement, bounded GPCM, DIF/DFF reporting, the FACETS
visual migration contract, ETS visualization boundaries, and
release-evidence status markers. It reads
fixed evidence artifacts and public documentation; it does not rerun Monte
Carlo simulations.

- `ReleaseScopeReviewStatus = "ok"`;
- `Checks = 67`;
- `FailedChecks = 0`.

## Area Summary

```
              Area PassedChecks
      bounded_gpcm          5/5
 dif_dff_reporting          3/3
     gtheory_scope          6/6
 overclaim_control          2/2
  release_evidence          2/2
    required_files        31/31
    scope_contract          4/4
        score_side          7/7
   visual_contract          5/5
     visualization          2/2
```

## Failed Checks

No failed checks.

## Files

- `release-scope-review-0.2.2-checks.csv`
