# Progress Day

A minimal macOS menu bar app that visualizes how much of your day is left.

## Features

- **Menu bar progress ring** — a small circular indicator that fills as your day progresses
- **Time-adaptive colors** — the ring shifts from blue in the morning, to gold at midday, to purple in the evening
- **Hover tooltip** — see time remaining without clicking
- **Display modes** — icon only, icon + percentage, or icon + time remaining
- **Configurable schedule** — set your own start and end times (supports past-midnight)
- **Launch at login** — start automatically with your Mac
- **Clean settings** — borderless, compact panel with no visual clutter

## Install

Download the latest `.zip` from [Releases](https://github.com/samflynn/progress-day/releases), unzip, and drag **ProgressDay.app** to your Applications folder.

## Build from source

Requires macOS 14+ and Xcode 15+.

```bash
git clone https://github.com/samflynn/progress-day.git
cd progress-day
swift build -c release
```

The binary will be at `.build/arm64-apple-macosx/release/ProgressDay`.

## Requirements

- macOS 14 (Sonoma) or later
- Apple Silicon (arm64)

## License

MIT
