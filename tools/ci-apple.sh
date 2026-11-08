#!/usr/bin/env bash
# Build and test every Xcode project of the companion on an iOS simulator (macOS only).
#   tools/ci-apple.sh [project-dir ...]     default: every directory with a project.yml
set -euo pipefail
cd "$(dirname "$0")/.."
DIRS=("$@")
if [ ${#DIRS[@]} -eq 0 ]; then
  while IFS= read -r f; do
    d=$(dirname "$f"); [ -f "$d/.ci-skip" ] || DIRS+=("$d")      # .ci-skip: work in progress
  done < <(find . -name project.yml -not -path "*/.build/*" | sort)
fi
SIM_NAME=${SIM_NAME:-iPhone 17}
DEST_ID=$(xcrun simctl list devices available -j | python3 -c '
import json, sys
d = json.load(sys.stdin)["devices"]
runtimes = sorted((k for k in d if "iOS" in k), key=lambda k: [int(x) for x in k.split("iOS-")[1].split("-")])
for k in reversed(runtimes):
    for dev in d[k]:
        if dev["name"] == "'"$SIM_NAME"'":
            print(dev["udid"]); sys.exit()
for k in reversed(runtimes):
    for dev in d[k]:
        if dev["name"].startswith("iPhone"):
            print(dev["udid"]); sys.exit()')
echo "Simulator: $DEST_ID"
xcrun simctl list devices available | grep "$DEST_ID" || true
# Light appearance, 9:41 in the status bar: clean screenshots for the book
xcrun simctl boot "$DEST_ID" 2>/dev/null || true
xcrun simctl status_bar "$DEST_ID" override --time "9:41" --batteryState charged --batteryLevel 100 --cellularBars 4 --wifiBars 3 || true
xcrun simctl ui "$DEST_ID" appearance light || true
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
  result="$RUNNER_TEMP/$name.xcresult"; rm -rf "$result"
  # Ad hoc signing ("Sign to Run Locally"): no team needed in the simulator, and the
  # app gets the entitlements that the Keychain requires.
  xcodebuild "$action" -project "$dir/$name.xcodeproj" -scheme "$name" \
    -destination "id=$DEST_ID" -skipPackagePluginValidation -resultBundlePath "$result" \
    CODE_SIGN_IDENTITY=- CODE_SIGN_STYLE=Manual DEVELOPMENT_TEAM= \
    > "$log" 2>&1
  rc=$?
  if [ "$action" = test ] && [ -d "$result" ]; then
    mkdir -p "$RUNNER_TEMP/screenshots/$name"
    xcrun xcresulttool export attachments --path "$result" \
      --output-path "$RUNNER_TEMP/screenshots/$name" >/dev/null 2>&1 || true
  fi
  set -e
  grep -E "(error|warning): " "$log" | grep -v "appintentsmetadataprocessor" | sort -u | head -40 || true
  grep -E "^Test Suite '.*xctest' (passed|failed)|Test run with|\*\* (BUILD|TEST) " "$log" | tail -6 || true
  grep -A60 "Audit issue" "$log" | grep -v "^ *t = " | head -80 || true    # audit details
  grep -A80 "^Attributes: Application" "$log" | head -80 || true    # hierarchy dumps
  # Apps with an archive configuration are also built in Release for a real device
  # (without signing): the configuration used for TestFlight and the App Store.
  if [ $rc -eq 0 ] && grep -q "archive:" "$dir/project.yml"; then
    if xcodebuild build -project "$dir/$name.xcodeproj" -scheme "$name" -configuration Release \
         -destination "generic/platform=iOS" CODE_SIGNING_ALLOWED=NO > "$log.release" 2>&1; then
      echo "Release build for devices: OK"
    else
      grep -E "error: " "$log.release" | head -20; rc=1
    fi
  fi
  echo "::endgroup::"
  if [ $rc -ne 0 ]; then grep -E "^ +t = " "$log" | tail -150; tail -60 "$log"; summary+=("FAIL $name"); else summary+=("OK   $name ($action)"); fi
done
printf '%s\n' "${summary[@]}"
printf '%s\n' "${summary[@]}" | grep -q '^FAIL' && exit 1 || exit 0
