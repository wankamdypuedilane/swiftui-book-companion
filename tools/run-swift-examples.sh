#!/usr/bin/env bash
# Compile and run every example in examples/swift and record its output next to it.
#   tools/run-swift-examples.sh            record   (writes <name>.out)
#   tools/run-swift-examples.sh --check    compare  (fails if an output changed)
# An example whose first line is "// expect: compile-error" must NOT compile; the
# compiler's diagnostics (error lines only) are recorded instead of program output.
set -u
cd "$(dirname "$0")/.."
MODE="${1:-record}"
EXTRA=${SWIFT_LINK_FLAGS:-}
TMP=$(mktemp -d)
status=0; n=0
for src in $(find examples/swift -name '*.swift' | sort); do
  n=$((n+1)); out="${src%.swift}.out"; bin="$TMP/prog"
  if head -1 "$src" | grep -q 'expect: compile-error'; then
    if swiftc -swift-version 6 "$src" -o "$bin" $EXTRA >"$TMP/log" 2>&1; then
      echo "FAIL (compiled but should not): $src"; status=1; continue
    fi
    grep -E '^[^ ].*(error|warning): ' "$TMP/log" | sed -E 's#^.*/([^/]+\.swift)#\1#' > "$TMP/result"
  else
    if ! swiftc -swift-version 6 "$src" -o "$bin" $EXTRA >"$TMP/log" 2>&1; then
      echo "FAIL (compile): $src"; sed -n 1,20p "$TMP/log"; status=1; continue
    fi
    if grep -q 'warning:' "$TMP/log"; then echo "WARN: $src"; grep 'warning:' "$TMP/log" | head -5; fi
    (cd "$(dirname "$src")" && timeout 30 "$bin") > "$TMP/result" 2>&1 || true
  fi
  if [ "$MODE" = "--check" ]; then
    if ! diff -u "$out" "$TMP/result" > "$TMP/diff"; then echo "DIFF: $src"; cat "$TMP/diff"; status=1; fi
  else
    cp "$TMP/result" "$out"
  fi
done
rm -rf "$TMP"
echo "swift examples: $n checked, status=$status"
exit $status
