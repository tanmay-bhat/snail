# Snail

A simple, native macOS status bar app that shows your real-time network speeds and daily data usage.

## Features

- **Real-time Monitoring**: Instant download and upload speeds visible in your menu bar.
- **Customizable Units**: Choose between **MB/s (Megabytes)** and **Mbps (Megabits)**.
- **Appearance Toggles**: Adjustable text sizes (Small, Medium, Large) to fit your menu bar perfectly.
- **Daily Stats**: View your total data uploaded and downloaded for the day at a glance.

## Installation

### From Source

You'll need Xcode Command Line Tools.

1. Clone the repo:
   ```bash
   git clone https://github.com/tanmay-bhat/snail.git
   cd snail
   ```

2. Build:
   ```bash
   make bundle
   ```

The app will be in `build/Snail.app`.

### Pre-built Release

Download the latest `.dmg` file from the [Releases page](https://github.com/tanmay-bhat/snail/releases).

1. Open `Snail.dmg`.
2. Drag Snail to your Applications folder.

## License

GNU General Public License v3.0 (GPLv3). See [LICENSE](LICENSE) for details.
