#!/usr/bin/env bash

# This script checks if a Zoom meeting is active and sends a notification if it is.
# It uses AppleScript to check the status of the Zoom app and sends a notification using the `osascript` command.
# Make sure to give this script execute permissions:
# chmod +x ontheair.sh
# You can run this script in the background or as a cron job.
# Usage: ./ontheair.sh [num seconds]

# Check to make sure we're on a Mac
if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "This script is intended to be run on macOS only."
  exit 1
fi

rm /tmp/zoomMeetingState.txt # Remove the old state file if it exists

while true; do
  osascript isZoomMeetingActive.applescript
  sleep "${1:-5}" # Default to 5 seconds if no argument is provided
done
