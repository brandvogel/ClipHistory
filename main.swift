import AppKit

// Pure AppKit menu bar app — no SwiftUI, no macros. Builds with plain swiftc.

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private let store = ClipboardStore()

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "doc.on.clipboard",
                                   accessibilityDescription: "Clipboard History")
        }

        rebuildMenu()
        store.onChange = { [weak self] in self?.rebuildMenu() }
    }

    private func rebuildMenu() {
        let menu = NSMenu()

        let header = NSMenuItem(title: "Clipboard History", action: nil, keyEquivalent: "")
        header.isEnabled = false
        menu.addItem(header)
        menu.addItem(.separator())

        if store.items.isEmpty {
            let empty = NSMenuItem(title: "No history yet — copy something",
                                   action: nil, keyEquivalent: "")
            empty.isEnabled = false
            menu.addItem(empty)
        } else {
            for (index, item) in store.items.enumerated() {
                let title = preview(item)
                // 1–9 get a Cmd-number shortcut for quick access.
                let key = index < 9 ? String(index + 1) : ""
                let entry = NSMenuItem(title: title,
                                       action: #selector(copyEntry(_:)),
                                       keyEquivalent: key)
                entry.target = self
                entry.tag = index
                entry.toolTip = item
                menu.addItem(entry)
            }
        }

        menu.addItem(.separator())

        let openText = NSMenuItem(title: "Open History as Text…",
                                  action: #selector(openHistoryAsText),
                                  keyEquivalent: "o")
        openText.target = self
        menu.addItem(openText)

        let clear = NSMenuItem(title: "Clear History",
                               action: #selector(clearHistory),
                               keyEquivalent: "")
        clear.target = self
        menu.addItem(clear)

        let quit = NSMenuItem(title: "Quit ClipHistory",
                              action: #selector(quit),
                              keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)

        statusItem.menu = menu
    }

    @objc private func copyEntry(_ sender: NSMenuItem) {
        let index = sender.tag
        guard index >= 0, index < store.items.count else { return }
        store.copy(store.items[index])
    }

    @objc private func clearHistory() {
        store.clear()
    }

    @objc private func openHistoryAsText() {
        let url = store.exportToTextFile()
        NSWorkspace.shared.open(url)
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }

    private func preview(_ text: String) -> String {
        let oneLine = text
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let max = 60
        return oneLine.count > max ? String(oneLine.prefix(max - 1)) + "…" : oneLine
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory) // menu bar only; no Dock icon
app.run()
