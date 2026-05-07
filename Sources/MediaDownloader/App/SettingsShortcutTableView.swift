import AppKit

final class SettingsShortcutTableView: NSView {
    private let preferences: PreferencesStore
    private enum Metrics {
        static let width: CGFloat = 520
        static let rowHeight: CGFloat = 50
        static let recorderWidth: CGFloat = 178
        static let recorderHeight: CGFloat = 24
        static let horizontalInset: CGFloat = 28
    }

    init(preferences: PreferencesStore) {
        self.preferences = preferences
        super.init(frame: NSRect(
            x: 0,
            y: 0,
            width: Metrics.width,
            height: Metrics.rowHeight * CGFloat(HotKeyAction.allCases.count)
        ))
        wantsLayer = true
        layer?.cornerRadius = 11
        layer?.masksToBounds = true
        layer?.backgroundColor = NSColor.controlBackgroundColor.withAlphaComponent(0.18).cgColor
        layer?.borderColor = NSColor.separatorColor.withAlphaComponent(0.28).cgColor
        layer?.borderWidth = 1
        buildRows()
    }

    required init?(coder: NSCoder) {
        nil
    }

    private func buildRows() {
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        for (index, action) in HotKeyAction.allCases.enumerated() {
            stack.addArrangedSubview(SettingsShortcutRowView(
                action: action,
                shortcut: preferences.hotKeyShortcut(for: action),
                isAlternate: index.isMultiple(of: 2),
                showsSeparator: index < HotKeyAction.allCases.count - 1,
                onRecord: { [weak self] shortcut in
                    self?.preferences.setHotKeyShortcut(shortcut, for: action)
                }
            ))
        }
    }
}

private final class SettingsShortcutRowView: NSView {
    init(
        action: HotKeyAction,
        shortcut: HotKeyShortcut,
        isAlternate: Bool,
        showsSeparator: Bool,
        onRecord: @escaping (HotKeyShortcut) -> Void
    ) {
        super.init(frame: NSRect(x: 0, y: 0, width: 520, height: 50))
        wantsLayer = true
        layer?.backgroundColor = (isAlternate
            ? NSColor.controlBackgroundColor.withAlphaComponent(0.06)
            : NSColor.controlBackgroundColor.withAlphaComponent(0.18)
        ).cgColor

        let titleLabel = NSTextField(labelWithString: action.title)
        titleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        titleLabel.textColor = .labelColor
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let recorder = HotKeyRecorderButton(shortcut: shortcut, onRecord: onRecord)
        recorder.translatesAutoresizingMaskIntoConstraints = false

        addSubview(titleLabel)
        addSubview(recorder)

        var constraints: [NSLayoutConstraint] = [
            heightAnchor.constraint(equalToConstant: 50),

            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            recorder.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -28),
            recorder.centerYAnchor.constraint(equalTo: centerYAnchor),
            recorder.widthAnchor.constraint(equalToConstant: 178),
            recorder.heightAnchor.constraint(equalToConstant: 24)
        ]

        if showsSeparator {
            let separator = NSView()
            separator.wantsLayer = true
            separator.layer?.backgroundColor = NSColor.separatorColor.withAlphaComponent(0.18).cgColor
            separator.translatesAutoresizingMaskIntoConstraints = false
            addSubview(separator)
            constraints.append(contentsOf: [
                separator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
                separator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -28),
                separator.bottomAnchor.constraint(equalTo: bottomAnchor),
                separator.heightAnchor.constraint(equalToConstant: 1)
            ])
        }

        NSLayoutConstraint.activate(constraints)
    }

    required init?(coder: NSCoder) {
        nil
    }
}

private final class HotKeyRecorderButton: NSButton {
    private var shortcut: HotKeyShortcut
    private let onRecord: (HotKeyShortcut) -> Void
    private var isRecordingShortcut = false
    private var keyMonitor: Any?

    init(shortcut: HotKeyShortcut, onRecord: @escaping (HotKeyShortcut) -> Void) {
        self.shortcut = shortcut
        self.onRecord = onRecord
        super.init(frame: .zero)
        isBordered = false
        wantsLayer = true
        layer?.cornerRadius = 7
        layer?.masksToBounds = true
        focusRingType = .none
        setButtonType(.momentaryPushIn)
        target = self
        action = #selector(startRecording)
        updateAppearance()
    }

    required init?(coder: NSCoder) {
        nil
    }

    deinit {
        removeKeyMonitor()
    }

    override var acceptsFirstResponder: Bool {
        true
    }

    @objc private func startRecording() {
        isRecordingShortcut = true
        updateAppearance()
        window?.makeFirstResponder(self)
        installKeyMonitor()
    }

    override func keyDown(with event: NSEvent) {
        guard isRecordingShortcut else {
            super.keyDown(with: event)
            return
        }

        capture(event)
    }

    private func capture(_ event: NSEvent) {
        if event.keyCode == 53 {
            stopRecording()
            return
        }

        guard !Self.modifierOnlyKeyCodes.contains(event.keyCode) else {
            return
        }

        shortcut = HotKeyShortcut(keyCode: event.keyCode, modifiers: event.modifierFlags)
        stopRecording()
        onRecord(shortcut)
    }

    private func updateAppearance() {
        let text = isRecordingShortcut ? "Record shortcut" : shortcut.displayText
        let font = isRecordingShortcut
            ? NSFont.systemFont(ofSize: 12, weight: .regular)
            : NSFont.monospacedSystemFont(ofSize: 13, weight: .medium)
        let color = isRecordingShortcut
            ? NSColor.controlAccentColor
            : NSColor.labelColor.withAlphaComponent(0.88)

        attributedTitle = NSAttributedString(
            string: text,
            attributes: [
                .font: font,
                .foregroundColor: color
            ]
        )
        alignment = .center
        layer?.backgroundColor = (isRecordingShortcut
            ? NSColor.controlAccentColor.withAlphaComponent(0.14)
            : NSColor.quaternaryLabelColor.withAlphaComponent(0.24)
        ).cgColor
        layer?.borderColor = (isRecordingShortcut
            ? NSColor.controlAccentColor.withAlphaComponent(0.48)
            : NSColor.separatorColor.withAlphaComponent(0.18)
        ).cgColor
        layer?.borderWidth = 1
    }

    private func stopRecording() {
        isRecordingShortcut = false
        removeKeyMonitor()
        updateAppearance()
    }

    private func installKeyMonitor() {
        removeKeyMonitor()
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self, isRecordingShortcut else {
                return event
            }

            capture(event)
            return nil
        }
    }

    private func removeKeyMonitor() {
        if let keyMonitor {
            NSEvent.removeMonitor(keyMonitor)
            self.keyMonitor = nil
        }
    }

    private static let modifierOnlyKeyCodes: Set<UInt16> = [
        54, 55, 56, 57, 58, 59, 60, 61, 62
    ]
}
