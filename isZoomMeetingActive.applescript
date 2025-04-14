#!/usr/bin/osascript

-- This script checks if the Zoom application is running and if a Zoom meeting window is open.

set stateFile to "zoomMeetingState.txt"
set zoomRunning to false -- Initialize variable
set inMeeting to false -- Initialize variable

-- Function to read last known state
try
    set previousState to do shell script "cat " & stateFile -- Read the last state
on error
    -- No file yet, that's fine
    log "Error writing to state file: " & result
    log "No state file found. Assuming unknown state."
    set previousState to "unknown"
end try

-- Check if Zoom application is running
tell application "System Events"
    set zoomRunning to (name of processes) contains "zoom.us"
end tell
if not zoomRunning then

    -- If Zoom is not running, we can exit early
    return "Zoom is not running -- exiting"
end if

-- Check for an active Zoom meeting by looking for Zoom
-- windows with "Zoom Meeting" or "Meeting" in their title
tell application "System Events"
    set inMeeting to false -- Initialize variable
    set zoomWindows to name of windows of application process "zoom.us"
    repeat with win in zoomWindows
        if win contains "Zoom Meeting" or win contains "Meeting" then
            set inMeeting to true -- Set to true if a meeting window is found
            exit repeat
        end if
    end repeat
end tell

log "inMeeting: " & inMeeting
log "previousState: " & previousState
-- Compare current state to previous

-- If we're still in a meeting, do nothing
if inMeeting and previousState is "inMeeting" then
    return "Still in a meeting -- nothing changed. exiting..."
-- If we're still not in a meeting, do nothing
else if (not inMeeting) and previousState is "notInMeeting" then
    return "Still not in a meeting -- nothing changed. exiting..."
-- If we just entered a meeting, turn the light on using the shortcut
else if inMeeting and previousState is not "inMeeting" then
    log "Entering a meeting, triggering shortcut"
    try
        do shell script "shortcuts run InMeeting"
    on error errorMessage
        -- Handle error if the shortcut cannot be run
        log "Error running shortcut: " & errorMessage
        return false
    end try

    set newState to "inMeeting"
-- If we just left a meeting, turn the light off on using the shortcut
else if (not inMeeting) and previousState is "inMeeting" then
    log "Leaving a meeting, triggering shortcut"
    try
        do shell script "shortcuts run OutOfMeeting"
    on error errorMessage
        -- Handle error if the shortcut cannot be run
        log "Error running shortcut: " & errorMessage
        return false
    end try

    set newState to "notInMeeting"
end if

-- Write new state to file
log "Writing new state to file: " & newState
try
    do shell script "echo " & newState & " > " & stateFile -- Save the new state
on error errorMessage
    -- Handle error if the file cannot be written
    log "Error writing to state file: " & errorMessage
end try
