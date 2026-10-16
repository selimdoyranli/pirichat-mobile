#!/bin/sh
# pirichat: store screenshots on an iOS simulator. usage:
#   tool/store_screenshots.sh <simulator-udid> <out-dir>
# Needs TEST_LAB_EMAIL/TEST_LAB_PASSWORD/TEST_LAB_GUILD_ID in the environment (review account).
set -e
UDID=$1 OUT=$2
mkdir -p "$OUT"
xcrun simctl boot "$UDID" 2>/dev/null || true
xcrun simctl spawn "$UDID" defaults write -g AppleLanguages -array tr
xcrun simctl spawn "$UDID" defaults write -g AppleLocale tr_TR
xcrun simctl status_bar "$UDID" override --time 9:41 --batteryState charged --batteryLevel 100 --cellularBars 4 --wifiBars 3
flutter test integration_test/flows/store_screenshots_test.dart -d "$UDID" --flavor stable \
  --dart-define-from-file=tool/dart_defines/stable.json --dart-define=PUSH_PROVIDER=apns \
  --dart-define=TEST_LAB_EMAIL="$TEST_LAB_EMAIL" --dart-define=TEST_LAB_PASSWORD="$TEST_LAB_PASSWORD" \
  --dart-define=TEST_LAB_GUILD_ID="$TEST_LAB_GUILD_ID" --dart-define=TEST_LAB_CHANNEL_ID=x 2>&1 |
while IFS= read -r line; do
  echo "$line"
  case "$line" in *STORE_SHOT:*)
    name=${line##*STORE_SHOT:}; sleep 2; xcrun simctl io "$UDID" screenshot "$OUT/$name.png" >/dev/null 2>&1 && echo "captured $name";;
  esac
done
