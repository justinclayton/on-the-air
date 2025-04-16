#!/usr/bin/osascript

-- This script checks if the Zoom application is running and if a Zoom meeting window is open.

set currentTimestamp to do shell script "date '+%Y-%m-%d %H:%M:%S'"
set zoomRunning to false -- Initialize variable
set inMeeting to false -- Initialize variable

set stateFile to "/tmp/zoomMeetingState.txt"
-- log currentTimestamp & " [DEBUG] State file path: " & stateFile

-- Function to read last known state
try
    set previousState to do shell script "cat " & stateFile -- Read the last state
on error
    -- No file yet, that's fine
    log currentTimestamp & " [ERROR] Error reading state file: " & result
    log currentTimestamp & " [INFO] No state file found. Assuming unknown state."
    set previousState to "unknown" -- Set to unknown if the file doesn't exist
end try

-- Check if Zoom application is running
tell application "System Events"
    set zoomRunning to (name of processes) contains "zoom.us"
end tell
if not zoomRunning then

    -- If Zoom is not running, we can assume we're not in a meeting
    log currentTimestamp & " [INFO] Zoom is not running"
    set newState to "notInMeeting" -- Set to notInMeeting if Zoom is not running
else
    -- Check for an active Zoom meeting by looking for Zoom
    -- windows with "Zoom Meeting" or "Meeting" in their title
    tell application "System Events"
        set zoomWindows to name of windows of application process "zoom.us"
        repeat with win in zoomWindows
            if win contains "Zoom Meeting" or win contains "Meeting" then
                set inMeeting to true -- Set to true if a meeting window is found
                exit repeat
            end if
        end repeat
    end tell

    -- log currentTimestamp & " [DEBUG] inMeeting: " & inMeeting
    -- log currentTimestamp & " [DEBUG] previousState: " & previousState
    -- Compare current state to previous

    -- If we're still in a meeting, do nothing
    if inMeeting and previousState is "inMeeting" then
        -- set currentTimestamp to do shell script "date '+%Y-%m-%d %H:%M:%S'"
        return currentTimestamp & " [NOOP] Still in a meeting"
    -- If we're still not in a meeting, do nothing
    else if (not inMeeting) and previousState is "notInMeeting" then
        -- set currentTimestamp to do shell script "date '+%Y-%m-%d %H:%M:%S'"
        return currentTimestamp & " [NOOP] Not in a meeting"
    -- If we just entered a meeting, turn the light on using the shortcut
    else if inMeeting and previousState is not "inMeeting" then
        log currentTimestamp & " [CHANGE] Entering a meeting! Triggering shortcut..."
        try
            do shell script "shortcuts run InMeeting"
        on error errorMessage
            -- Handle error if the shortcut cannot be run
            return currentTimestamp & " [ERROR] Error running shortcut: " & errorMessage
        end try

        set newState to "inMeeting"

    -- If we just left a meeting, turn the light off on using the shortcut
    else if (not inMeeting) and previousState is not "notInMeeting" then
        log currentTimestamp & " [CHANGE] Leaving a meeting! Triggering shortcut..."
        try
            do shell script "shortcuts run OutOfMeeting"
        on error errorMessage
            -- Handle error if the shortcut cannot be run
            return currentTimestamp & "[ERROR] Error running shortcut: " & errorMessage
        end try

        set newState to "notInMeeting"
    else
        log currentTimestamp & " [ERROR] Unknown state detected. Previous state: " & previousState

        set newState to previousState
    end if
end if

-- Write new state to file if it has changed
if newState is not previousState then
    try
        do shell script "echo " & newState & " > " & stateFile -- Save the new state
    on error errorMessage
        -- Handle error if the file cannot be written
        return currentTimestamp & " [ERROR] Error writing to state file: " & errorMessage
    end try
    log currentTimestamp & " [CHANGE] State updated successfully to: " & newState
else
    log currentTimestamp & " [NOOP] State unchanged: " & newState
end if
