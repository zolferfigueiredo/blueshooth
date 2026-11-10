# BlueShooth

A macOS menu bar app that gives you control over which Bluetooth devices can auto-connect. Prevent unwanted automatic Bluetooth connections while keeping your devices paired.

## Problem

macOS automatically connects to paired Bluetooth devices when they're in range, which can be annoying when:
- You have multiple Bluetooth speakers/headphones and only want to connect to specific ones
- You want devices paired but not automatically connecting
- You need more granular control over Bluetooth behavior

## Solution

BlueShooth runs in your menu bar and lets you choose which paired devices should NOT auto-connect. Selected devices stay paired but won't connect automatically - you can still connect them from the BlueShooth menu when you want to use them.

## Features

- 🎯 **Selective Auto-Connect Control**: Choose which devices can auto-connect
- 🔌 **Quick Connect/Disconnect**: Connect or disconnect devices directly from the menu bar
- 🟢 **Real-Time Status**: See which devices are currently connected
- 🚫 **Automatic Blocking**: Instantly disconnects blocked devices if they try to auto-connect
- 🔔 **Notifications**: Get notified about connection events
- 📱 **Menu Bar Interface**: Quick access to all paired devices
- 💾 **Persistent Settings**: Your preferences are saved between sessions
- 🔒 **Privacy-Focused**: All settings stored locally, no data collection

## Requirements

- macOS 13.0 (Ventura) or later
- Xcode 14.0 or later (for building from source)

## Installation

### Option 1: Build from Source

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/blueshooth.git
   cd blueshooth
   ```

2. Open the project in Xcode:
   ```bash
   open BlueShooth.xcodeproj
   ```

3. Build and run (⌘R) or archive for distribution (Product > Archive)

### Option 2: Download Release

Download the latest release from the [Releases](https://github.com/yourusername/blueshooth/releases) page.

## Usage

1. **Launch BlueShooth**: The app appears in your menu bar with a Bluetooth antenna icon

2. **View Devices**: Click the menu bar icon to see all paired Bluetooth devices
   - 🟢 = Currently connected
   - ⚪️ = Disconnected

3. **Connect/Disconnect Devices**:
   - Click on any device to open its submenu
   - Choose "Connect" to connect a disconnected device
   - Choose "Disconnect" to disconnect a connected device
   - No need to open System Settings!

4. **Toggle "Able to connect"**:
   - In the device submenu, click the "Able to connect" option
   - ✓ Able to connect: Enabled = Normal macOS behavior
   - 🚫 Able to connect: Disabled = Device is blocked from connecting, unless you choose "Connect" in BlueShooth (its row shows ⚫️ while disconnected)

5. **Refresh**: Click "Refresh Devices" to update the device list

## How It Works

BlueShooth provides direct control over Bluetooth connections without opening System Settings. The app:

1. Lists all paired Bluetooth devices with real-time connection status
2. Allows you to connect/disconnect devices programmatically via IOBluetooth
3. Stores your auto-connect preferences locally using UserDefaults
4. Monitors system Bluetooth notifications
5. Disconnects blocked devices immediately when they try to auto-connect
6. Shows notifications for connection events

## Permissions

BlueShooth requires Bluetooth access to:
- List paired devices
- Monitor connection events
- Connect and disconnect devices programmatically

The app will request Bluetooth permissions on first launch.

## Limitations

- Device must remain paired (unpaired devices can't be managed)
- Some Bluetooth devices may not support programmatic connection/disconnection
- Some devices may attempt to reconnect multiple times (the app will continue blocking them)
- Connection success depends on device proximity and Bluetooth stack availability

## Development

### Project Structure

```
BlueShooth/
├── BlueShooth/
│   ├── AppDelegate.swift           # Main app and menu bar interface
│   ├── BluetoothManager.swift      # Bluetooth device management logic
│   ├── Info.plist                  # App configuration
│   └── BlueShooth.entitlements     # Required permissions
├── BlueShooth.xcodeproj/           # Xcode project
└── README.md
```

### Building

```bash
# Build from command line
xcodebuild -project BlueShooth.xcodeproj -scheme BlueShooth -configuration Release build

# The built app will be in:
# build/Release/BlueShooth.app
```

### Technologies Used

- **Swift 5.0**: Modern, safe programming language
- **IOBluetooth Framework**: macOS Bluetooth APIs
- **Cocoa/AppKit**: macOS UI framework
- **NSStatusBar**: Menu bar integration
- **NotificationCenter**: System event monitoring

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Known Issues

- Device names may not always display correctly if the Bluetooth device doesn't provide one
- Some Bluetooth devices may not respect disconnection commands
- The app runs as a menu bar utility (no dock icon)

## Roadmap

- [x] Quick connect/disconnect from menu bar
- [ ] Add device grouping/favorites
- [ ] Customize notification sounds
- [ ] Schedule-based auto-connect rules
- [ ] Battery level indicators for devices
- [ ] Launch at login option
- [ ] Keyboard shortcuts
- [ ] Connection history tracking

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with Apple's IOBluetooth framework
- Inspired by the need for better Bluetooth control on macOS

## Support

If you encounter any issues or have suggestions:
- Open an issue on [GitHub Issues](https://github.com/yourusername/blueshooth/issues)
- Check existing issues for solutions

---

Made with ❤️ for macOS users who want more control over their Bluetooth devices
