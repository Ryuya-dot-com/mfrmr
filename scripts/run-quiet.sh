#!/bin/sh

# Run a validation command quietly. Successful commands emit one summary line;
# failed commands emit the complete captured log and retain it for inspection.

if [ "$#" -lt 3 ] || [ "$2" != "--" ]; then
  echo "usage: scripts/run-quiet.sh LABEL -- COMMAND [ARG ...]" >&2
  exit 64
fi

label=$1
shift 2

log_file=$(mktemp "${TMPDIR:-/tmp}/mfrmr-validation.XXXXXX") || exit 70
started=$(date +%s)

if "$@" >"$log_file" 2>&1; then
  finished=$(date +%s)
  elapsed=$((finished - started))
  if [ "${MFRMR_KEEP_TEST_LOGS:-0}" = "1" ]; then
    echo "PASS ${label} (${elapsed}s; log: ${log_file})"
  else
    rm -f "$log_file"
    echo "PASS ${label} (${elapsed}s)"
  fi
  exit 0
else
  status=$?
fi

finished=$(date +%s)
elapsed=$((finished - started))
echo "FAIL ${label} (exit ${status}; ${elapsed}s; log: ${log_file})" >&2
echo "----- captured output -----" >&2
cat "$log_file" >&2
echo "----- end captured output -----" >&2
exit "$status"
