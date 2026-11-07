#!/usr/bin/env bash
# Build and test every Xcode project of the companion on an iOS simulator (macOS only).
#   tools/ci-apple.sh [project-dir ...]     default: every directory with a project.yml
set -euo pipefail
cd "$(dirname "$0")/.."
DIRS=("$@")
if [ ${#DIRS[@]} -eq 0 ]; then
  while IFS= read -r f; do DIRS+=("$(dirname "$f")"); done < <(find . -name project.yml -not -path "*/.build/*" | sort)
fi
DEST_ID=$(xcrun simctl list devices available -j | python3 -c '
import json, sys
d = json.load(sys.stdin)["devices"]
runtimes = sorted((k for k in d if "iOS" in k), key=lambda k: [int(x) for x in k.split("iOS-")[1].split("-")])
for k in reversed(runtimes):
    for dev in d[k]:
        if dev["name"].startswith("iPhone 1") or dev["name"].startswith("iPhone"):
            print(dev["udid"]); sys.exit()')
echo "Simulator: $DEST_ID"
summary=()
for dir in "${DIRS[@]}"; do
  name=$(awk '/^name:/{print $2; exit}' "$dir/project.yml")
  echo "::group::$name ($dir)"
  (cd "$dir" && xcodegen generate --quiet)
  if [ -f "$dir/.swiftlint.yml" ]; then (cd "$dir" && swiftlint lint --strict --quiet); fi
  action=build
  if grep -q "^    test:" "$dir/project.yml" || grep -q "test:" "$dir/project.yml"; then action=test; fi
  log="$RUNNER_TEMP/$name.log"
  set +e
  xcodebuild "$action" -project "$dir/$name.xcodeproj" -scheme "$name" \
    -destination "id=$DEST_ID" -skipPackagePluginValidation \
    CODE_SIGNING_ALLOWED=NO > "$log" 2>&1
  rc=$?
  set -e
  grep -E "(error|warning): " "$log" | grep -v "appintentsmetadataprocessor" | sort -u | head -40 || true
  grep -E "^Test Suite '.*xctest' (passed|failed)|Test run with|\*\* (BUILD|TEST) " "$log" | tail -6 || true
  echo "::endgroup::"
  if [ $rc -ne 0 ]; then tail -60 "$log"; summary+=("FAIL $name"); else summary+=("OK   $name ($action)"); fi
done
printf '%s\n' "${summary[@]}"
printf '%s\n' "${summary[@]}" | grep -q '^FAIL' && exit 1 || exit 0
