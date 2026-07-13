import AppKit
import Foundation

/// Watches the system pasteboard and keeps the most recent text entries.
/// Pure Foundation/AppKit — no SwiftUI, no macros.
final class ClipboardStore {
    private(set) var items: [String] = []

    /// Called on the main thread whenever `items` changes.
    var onChange: (() -> Void)?

    private let maxItems = 15
    private let pasteboard = NSPasteboard.general
    private var lastChangeCount: Int
    private var timer: Timer?

    // Set true briefly when WE write to the pasteboard, so re-copying
    // an existing entry doesn't re-trigger a capture.
    private var suppressNextChange = false

    private let historyURL: URL = {
        let dir = FileManager.default.homeDirectoryForCurrentUser
        return dir.appendingPathComponent(".clip_history.json")
    }()

    init() {
        lastChangeCount = pasteboard.changeCount
        load()
        start()
    }

    deinit { timer?.invalidate() }

    private func start() {
        // NSPasteboard has no change notification, so poll the cheap
        // `changeCount` twice a second — the standard approach.
        let t = Timer(timeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.poll()
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    private func poll() {
        guard pasteboard.changeCount != lastChangeCount else { return }
        lastChangeCount = pasteboard.changeCount

        if suppressNextChange {
            suppressNextChange = false
            return
        }

        guard let text = pasteboard.string(forType: .string),
              !text.isEmpty else { return }
        record(text)
    }

    private func record(_ text: String) {
        var next = items.filter { $0 != text }   // dedupe
        next.insert(text, at: 0)                 // most recent first
        if next.count > maxItems { next = Array(next.prefix(maxItems)) }
        items = next
        save()
        onChange?()
    }

    /// Copy an entry back to the clipboard.
    func copy(_ text: String) {
        suppressNextChange = true
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        lastChangeCount = pasteboard.changeCount
        record(text) // move to front → "most recently used"
    }

    func clear() {
        items = []
        save()
        onChange?()
    }

    /// Write all entries to a readable .txt file and return its URL.
    /// Each entry gets a numbered header so multiline copies stay legible.
    func exportToTextFile() -> URL {
        let tmp = FileManager.default.temporaryDirectory
        let url = tmp.appendingPathComponent("clipboard-history.txt")

        if items.isEmpty {
            try? "Clipboard history is empty.\n".write(to: url, atomically: true, encoding: .utf8)
            return url
        }

        let divider = String(repeating: "─", count: 40)
        var text = "Clipboard History (\(items.count) item\(items.count == 1 ? "" : "s"))\n"
        text += "\(divider)\n\n"
        for (index, item) in items.enumerated() {
            text += "[\(index + 1)]\n\(item)\n\n\(divider)\n\n"
        }

        try? text.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    // MARK: - Persistence

    private func load() {
        guard let data = try? Data(contentsOf: historyURL),
              let decoded = try? JSONDecoder().decode([String].self, from: data)
        else { return }
        items = Array(decoded.prefix(maxItems))
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: historyURL, options: .atomic)
    }
}
