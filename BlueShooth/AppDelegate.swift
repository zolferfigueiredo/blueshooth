import Cocoa
import IOBluetooth

@main
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    var statusItem: NSStatusItem!
    var menu: NSMenu!
    var bluetoothManager: BluetoothManager!

    // No main nib, so the default NSApplicationMain would never create this delegate.
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        withExtendedLifetime(delegate) { app.run() }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.image = NSImage(systemSymbolName: "antenna.radiowaves.left.and.right", accessibilityDescription: "BlueShooth")

        bluetoothManager = BluetoothManager()

        menu = NSMenu()
        menu.delegate = self
        statusItem.menu = menu
        setupMenu()
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
        bluetoothManager.refreshDevices()
        setupMenu()
    }

    func setupMenu() {
        menu.removeAllItems()

        let settingsItem = NSMenuItem(title: "Bluetooth Settings…", action: #selector(openBluetoothSettings), keyEquivalent: "")
        settingsItem.target = self
        menu.addItem(settingsItem)
        menu.addItem(NSMenuItem.separator())

        let paired = bluetoothManager.getPairedDevices()
        let pairedDevices = paired.filter(bluetoothManager.isConnected) + paired.filter { !bluetoothManager.isConnected($0) }

        if pairedDevices.isEmpty {
            let noDevicesItem = NSMenuItem(title: "No paired devices found", action: nil, keyEquivalent: "")
            noDevicesItem.isEnabled = false
            menu.addItem(noDevicesItem)
        } else {
            for device in pairedDevices {
                // Create submenu for each device
                let deviceItem = NSMenuItem(title: device.name, action: nil, keyEquivalent: "")
                let deviceSubmenu = NSMenu()

                // Connection status
                let isConnected = bluetoothManager.isConnected(device)
                let statusItem = NSMenuItem(
                    title: isConnected ? "🟢 Connected" : "⚪️ Disconnected",
                    action: nil,
                    keyEquivalent: ""
                )
                statusItem.isEnabled = false
                deviceSubmenu.addItem(statusItem)
                deviceSubmenu.addItem(NSMenuItem.separator())

                // Connect/Disconnect option
                if isConnected {
                    let disconnectItem = NSMenuItem(
                        title: "Disconnect",
                        action: #selector(disconnectDevice(_:)),
                        keyEquivalent: ""
                    )
                    disconnectItem.target = self
                    disconnectItem.representedObject = device
                    deviceSubmenu.addItem(disconnectItem)
                } else {
                    let connectItem = NSMenuItem(
                        title: "Connect",
                        action: #selector(connectDevice(_:)),
                        keyEquivalent: ""
                    )
                    connectItem.target = self
                    connectItem.representedObject = device
                    deviceSubmenu.addItem(connectItem)
                }

                deviceSubmenu.addItem(NSMenuItem.separator())

                // Auto-connect toggle
                let autoConnectDisabled = bluetoothManager.isAutoConnectDisabled(for: device)
                let autoConnectItem = NSMenuItem(
                    title: autoConnectDisabled ? "🚫 Able to connect: Disabled" : "✓ Able to connect: Enabled",
                    action: #selector(toggleDeviceAutoConnect(_:)),
                    keyEquivalent: ""
                )
                autoConnectItem.target = self
                autoConnectItem.representedObject = device
                autoConnectItem.state = autoConnectDisabled ? .on : .off
                deviceSubmenu.addItem(autoConnectItem)

                // Set the submenu
                deviceItem.submenu = deviceSubmenu

                let icon = isConnected ? "🟢" : (autoConnectDisabled ? "⚫️" : "⚪️")
                deviceItem.title = "\(icon) \(device.name)"

                menu.addItem(deviceItem)
            }
        }

        menu.addItem(NSMenuItem.separator())

        // Refresh
        let refreshItem = NSMenuItem(title: "Refresh Devices", action: #selector(refreshDevices), keyEquivalent: "r")
        refreshItem.target = self
        menu.addItem(refreshItem)

        menu.addItem(NSMenuItem.separator())

        // Quit
        let quitItem = NSMenuItem(title: "Quit BlueShooth", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        menu.addItem(NSMenuItem.separator())

        let titleItem = NSMenuItem(title: "BlueShooth - Smart Bluetooth Manager", action: nil, keyEquivalent: "")
        titleItem.isEnabled = false
        menu.addItem(titleItem)
    }

    @objc func openBluetoothSettings() {
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.BluetoothSettings")!)
    }

    @objc func connectDevice(_ sender: NSMenuItem) {
        guard let device = sender.representedObject as? BluetoothDevice else { return }

        _ = bluetoothManager.connectDevice(device)

        // Refresh menu after a short delay to show updated connection status
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.setupMenu()
        }
    }

    @objc func disconnectDevice(_ sender: NSMenuItem) {
        guard let device = sender.representedObject as? BluetoothDevice else { return }

        _ = bluetoothManager.disconnectDevice(device)

        // Refresh menu after a short delay to show updated connection status
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.setupMenu()
        }
    }

    @objc func toggleDeviceAutoConnect(_ sender: NSMenuItem) {
        guard let device = sender.representedObject as? BluetoothDevice else { return }

        bluetoothManager.toggleAutoConnect(for: device)
        setupMenu()
    }

    @objc func refreshDevices() {
        bluetoothManager.refreshDevices()
        setupMenu()
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
