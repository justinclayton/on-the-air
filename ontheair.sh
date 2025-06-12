#!/usr/bin/env bash

# This script checks if a video call (e.g., Zoom) is active and can trigger an Apple Shortcut.
# It uses the `yabai` window manager to query the state of the video call app.
# You can use this script to trigger macOS Shortcuts when you enter or leave a meeting.
# Make sure to give this script execute permissions:
# chmod +x ontheair.sh
# You can loop over this script.
# Usage: ./ontheair.sh [num seconds]

inMeetingShortcut="InMeeting"
outOfMeetingShortcut="OutOfMeeting"
STATE_FILE="${TMPDIR}/ontheair_statefile.txt"
CURRENT_STATE="out"
yabai="/opt/homebrew/bin/yabai"

# Check to make sure we're on a Mac
if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "This script is intended to be run on macOS only."
  exit 1
fi

# Check for required dependencies
if ! command -v $yabai >/dev/null 2>&1; then
  echo "Error: yabai is not installed. Please install yabai to use this script using: brew install koekeishiya/formulae/yabai"
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is not installed. Please install jq to use this script using: brew install jq"
  exit 1
fi

windows=$($yabai -m query --windows) # produces a JSON of open macOS windows (including full screen Spaces)

# Detect Zoom meeting
zoom_active=$(echo "$windows" | jq -e '.[] | select(.app == "zoom.us") | select(.title | test("Meeting"))' > /dev/null && echo "true" || echo "false")

# Detect FaceTime call
facetime_active=$(echo "$windows" | jq -e '.[] | select(.app == "FaceTime") | select(.title | test("FaceTime|with"))' > /dev/null && echo "true" || echo "false")

# Detect Microsoft Teams call
teams_active=$(echo "$windows" | jq -e '.[] | select(.app | test("Teams")) | select(.title | test("Call|Meeting|with"))' > /dev/null && echo "true" || echo "false")

# Slack Huddles (🎤 emoji in title == active huddle)
slack_active=$(echo "$windows" | jq -e '.[] | select(.app == "Slack") | select(.title | test("🎤"))' > /dev/null && echo "true" || echo "false")


# Final call state is "in" if any are active
if [[ "$zoom_active" == "true" || "$facetime_active" == "true" || "$teams_active" == "true" || "$slack_active" == "true" ]]; then
  CURRENT_STATE="in"
else
  CURRENT_STATE="out"
fi

# Read previous state
if [ -f "$STATE_FILE" ]; then
    PREVIOUS_STATE=$(cat "$STATE_FILE")
else
    PREVIOUS_STATE="unknown"
fi

# print output

if [ "$CURRENT_STATE" == "in" ]; then
  echo "🎥"
  if [ "$PREVIOUS_STATE" != "in" ]; then
    shortcuts run $inMeetingShortcut
  fi
elif [ "$CURRENT_STATE" == "out" ]; then
  echo "📴"
  if [ "$PREVIOUS_STATE" != "out" ]; then
    shortcuts run $outOfMeetingShortcut
  fi
fi

# Extra debugging output below the line
echo "---"
echo "zoom: $zoom_active"
echo "facetime: $facetime_active"
echo "teams: $teams_active"
echo "slack: $slack_active"

# Update state
echo "$CURRENT_STATE" > "$STATE_FILE"
