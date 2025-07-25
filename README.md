# On The Air

A script for macOS that detects when you're in a video call, and can trigger automated actions through Apple Shortcuts.

## Overview

This script monitors your active video calling applications (Zoom, FaceTime, Microsoft Teams, and Slack Huddles) and automatically triggers Apple Shortcuts when you enter or leave a meeting. The output format also just happens to work seamlessly with [SwiftBar](https://swiftbar.app/) for menu bar integration, but it's flexible enough to be used however you like.

## Why I created this

My home office is in my basement. After too many instances of family members calling for me loudly as they bounded down the stairs, only to be met with disappointment upon learning that I was in a meeting, I decided I needed a new plan.

I remembered seeing those "On The Air" signs in old television studios that would light up during filming so no one would barge in during a show, and my own personal light bulb went off that I could use my existing smart home devices to have something similar. In my case, both the light at the top of the stairs and the LED strip behind my desk turn blue when I'm in a meeting, and return to their original state when the meeting ends.

## How does it work?

The call detection is made possible through [yabai](https://github.com/koekeishiya/yabai), a command-line app that collects information about active macOS windows. I started with simple AppleScript, but learned that wouldn't work with full-screen Spaces. So far this method has proven to be surprisingly reliable.

Special thanks to [koekeishiya](https://github.com/koekeishiya) for creating yabai and making this project possible! If you find this useful, consider [supporting their work on Patreon](https://www.patreon.com/koekeishiya)!

## Prerequisites

### Required Dependencies

Install these using Homebrew:

```bash
# Install yabai (window manager that provides window information)
brew install koekeishiya/formulae/yabai

# Install jq (JSON processor for parsing yabai output)
brew install jq
```

### Apple Shortcuts Setup

You'll also want to create two Apple Shortcuts in the Shortcuts app on your Mac:

1. **"InMeeting"** - Triggered when entering a meeting
2. **"OutOfMeeting"** - Triggered when leaving a meeting

Configure these shortcuts to perform whatever actions you want. For me, they trigger a Scene in Apple Home that changes the color of the hallway light at the top of the stairs and the LED strip behind my desk. But you could do anything, really: send notifications, set Do Not Disturb mode on your phone, change your Slack status, pause your music, etc. If you have any cool ideas, I'd love to hear what you come up with!

## Installation

1. Clone this repository:
```bash
git clone https://github.com/justinclayton/on-the-air.git
cd on-the-air
```

2. Make sure the script is executable:
```bash
chmod +x ontheair.sh
```

3. Test the script:
```bash
./ontheair.sh
```

You should see output like:
```
📴
---
zoom: false
facetime: false
teams: false
slack: false
```

When you're in a meeting, you should instead see:
```
🎥
zoom: false
facetime: false
teams: true
slack: false
```

### Optional: SwiftBar Integration

If you'd like On The Air running all the time out of your menu bar, I highly recommend installing [SwiftBar](https://github.com/swiftbar/SwiftBar):

```bash
brew install swiftbar
```

## Usage

### Standalone Usage

Run the script once to check current meeting status:
```bash
./ontheair.sh
```

### Long-running Monitoring

If you're not using SwiftBar, you can run the script in a loop in a simple wrapper script to continuously monitor for meeting changes:

```bash
#!/bin/bash
while true; do
  /path/to/ontheair.sh
  sleep 5
done
```

### SwiftBar Integration

1. Copy or symlink the script to your SwiftBar plugin folder (configurable in SwiftBar preferences)
2. Rename it with a refresh interval, e.g., `ontheair.5s.sh` (refreshes every 5 seconds)
3. The script will appear in your menu bar showing 🎥 when in a meeting or 📴 when not

## Supported Applications

Currently detects meetings in:

- **Zoom** - Detects Zoom windows with "Meeting" in the title
- **FaceTime** - Detects active FaceTime calls
- **Microsoft Teams** - Detects meeting windows (excludes sidebar tabs like Calendar, Chat, etc.)
- **Slack** - Detects active Huddles (identified by 🎤 emoji in window title)

## Customization

### Changing Shortcut Names

Edit the script to use different Apple Shortcut names:

```bash
inMeetingShortcut="YourInMeetingShortcut"
outOfMeetingShortcut="YourOutOfMeetingShortcut"
```

### Adding More Applications

Want to add support for more video calling apps?

1. Use `yabai -m query --windows` to explore window information for your app
2. Add detection logic similar to the existing apps
3. Feel free to open a GitHub issue or submit a PR!

## Troubleshooting

### False positives/negatives
The detection relies on window titles, which can vary. You can debug by looking at the output after the `---` line to see which apps are being detected. To go deeper, run this command to see all active windows and their titles:

```bash
yabai -m query --windows | jq '.[] | {app: .app, title: .title}'
```

### Shortcuts not triggering

Test each link in the chain:
- Is whatever you're using to loop the script still running?
- Are your Apple Shortcuts named exactly "InMeeting" and "OutOfMeeting" (case-sensitive)?
- Can you trigger the shortcut in your terminal?

  ```bash
  shortcuts run InMeeting
  ```
- Can you trigger the shortcut manually through the Shortcuts app?


## Contributing

Have an idea for improvement or want to add support for more apps? Contributions are welcome!

1. Fork the repository
2. Create a feature branch
3. Test your changes thoroughly
4. Submit a pull request

For new app support, please include:
- The detection logic
- Test cases showing it works reliably
- Any edge cases you discovered

## License

This is released under the MIT License - feel free to use and modify as needed.
