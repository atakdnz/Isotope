import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var timerEngine = TimerEngine()
    private let settings = Settings.shared
    
    // Menu items that need updating
    private var startStopMenuItem: NSMenuItem!
    private var modeMenuItems: [TimerMode: NSMenuItem] = [:]
    private var showSecondsMenuItem: NSMenuItem!
    private var compactModeMenuItem: NSMenuItem!
    private var colorMenuItems: [ColorTheme: NSMenuItem] = [:]
    private var pomodoroStatusMenuItem: NSMenuItem!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupMenu()
        timerEngine.delegate = self
        updateDisplay(timerEngine.formattedTime())
    }
    
    // MARK: - Setup
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        updateStatusItemAppearance()
    }
    
    private func updateStatusItemAppearance() {
        guard let button = statusItem.button else { return }
        
        let fontSize: CGFloat = settings.compactMode ? 12 : 14
        button.font = NSFont.monospacedDigitSystemFont(ofSize: fontSize, weight: .medium)
    }
    
    private func setupMenu() {
        let menu = NSMenu()
        
        // Mode selection
        let modeMenu = NSMenu()
        for mode in TimerMode.allCases {
            let item = NSMenuItem(title: mode.rawValue, action: #selector(selectMode(_:)), keyEquivalent: "")
            item.representedObject = mode
            item.state = timerEngine.mode == mode ? .on : .off
            modeMenu.addItem(item)
            modeMenuItems[mode] = item
        }
        let modeMenuItem = NSMenuItem(title: "Mode", action: nil, keyEquivalent: "")
        modeMenuItem.submenu = modeMenu
        menu.addItem(modeMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Timer presets (only visible in timer mode)
        let timerMenu = NSMenu()
        for preset in settings.timerPresets {
            let item = NSMenuItem(title: "\(preset) min", action: #selector(selectTimerPreset(_:)), keyEquivalent: "")
            item.representedObject = preset
            timerMenu.addItem(item)
        }
        timerMenu.addItem(NSMenuItem.separator())
        let customItem = NSMenuItem(title: "Custom...", action: #selector(showCustomTimerInput), keyEquivalent: "")
        timerMenu.addItem(customItem)
        
        let timerMenuItem = NSMenuItem(title: "Set Timer", action: nil, keyEquivalent: "")
        timerMenuItem.submenu = timerMenu
        menu.addItem(timerMenuItem)
        
        // Pomodoro status
        pomodoroStatusMenuItem = NSMenuItem(title: "Session 1/4 - Work", action: nil, keyEquivalent: "")
        pomodoroStatusMenuItem.isHidden = true
        menu.addItem(pomodoroStatusMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Controls
        startStopMenuItem = NSMenuItem(title: "Start", action: #selector(toggleStartStop), keyEquivalent: "s")
        startStopMenuItem.keyEquivalentModifierMask = [.command]
        menu.addItem(startStopMenuItem)
        
        let resetMenuItem = NSMenuItem(title: "Reset", action: #selector(resetTimer), keyEquivalent: "r")
        resetMenuItem.keyEquivalentModifierMask = [.command]
        menu.addItem(resetMenuItem)
        
        let skipMenuItem = NSMenuItem(title: "Skip Phase", action: #selector(skipPhase), keyEquivalent: "k")
        skipMenuItem.keyEquivalentModifierMask = [.command]
        menu.addItem(skipMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Pomodoro Settings submenu
        let pomodoroMenu = NSMenu()
        
        // Work duration options
        let workDurationMenu = NSMenu()
        for mins in [15, 20, 25, 30, 45, 50, 60] {
            let item = NSMenuItem(title: "\(mins) min", action: #selector(setWorkDuration(_:)), keyEquivalent: "")
            item.representedObject = mins
            item.state = settings.pomodoroWorkDuration == mins ? .on : .off
            workDurationMenu.addItem(item)
        }
        let workMenuItem = NSMenuItem(title: "Work Duration", action: nil, keyEquivalent: "")
        workMenuItem.submenu = workDurationMenu
        pomodoroMenu.addItem(workMenuItem)
        
        // Short break options
        let shortBreakMenu = NSMenu()
        for mins in [3, 5, 10, 15] {
            let item = NSMenuItem(title: "\(mins) min", action: #selector(setShortBreak(_:)), keyEquivalent: "")
            item.representedObject = mins
            item.state = settings.pomodoroShortBreak == mins ? .on : .off
            shortBreakMenu.addItem(item)
        }
        let shortBreakMenuItem = NSMenuItem(title: "Short Break", action: nil, keyEquivalent: "")
        shortBreakMenuItem.submenu = shortBreakMenu
        pomodoroMenu.addItem(shortBreakMenuItem)
        
        // Long break options
        let longBreakMenu = NSMenu()
        for mins in [10, 15, 20, 30] {
            let item = NSMenuItem(title: "\(mins) min", action: #selector(setLongBreak(_:)), keyEquivalent: "")
            item.representedObject = mins
            item.state = settings.pomodoroLongBreak == mins ? .on : .off
            longBreakMenu.addItem(item)
        }
        let longBreakMenuItem = NSMenuItem(title: "Long Break", action: nil, keyEquivalent: "")
        longBreakMenuItem.submenu = longBreakMenu
        pomodoroMenu.addItem(longBreakMenuItem)
        
        pomodoroMenu.addItem(NSMenuItem.separator())
        
        // Auto-start toggle
        let autoStartItem = NSMenuItem(title: "Auto-start Next", action: #selector(toggleAutoStart), keyEquivalent: "")
        autoStartItem.state = settings.autoStartNextSession ? .on : .off
        pomodoroMenu.addItem(autoStartItem)
        
        let pomodoroMenuItem = NSMenuItem(title: "Pomodoro Settings", action: nil, keyEquivalent: "")
        pomodoroMenuItem.submenu = pomodoroMenu
        menu.addItem(pomodoroMenuItem)
        
        // Appearance submenu
        let appearanceMenu = NSMenu()
        
        showSecondsMenuItem = NSMenuItem(title: "Show Seconds", action: #selector(toggleShowSeconds), keyEquivalent: "")
        showSecondsMenuItem.state = settings.showSeconds ? .on : .off
        appearanceMenu.addItem(showSecondsMenuItem)
        
        compactModeMenuItem = NSMenuItem(title: "Compact Mode", action: #selector(toggleCompactMode), keyEquivalent: "")
        compactModeMenuItem.state = settings.compactMode ? .on : .off
        appearanceMenu.addItem(compactModeMenuItem)
        
        appearanceMenu.addItem(NSMenuItem.separator())
        
        // Colors submenu
        let colorsMenu = NSMenu()
        for color in ColorTheme.solidColors {
            let item = NSMenuItem(title: color.rawValue, action: #selector(selectColor(_:)), keyEquivalent: "")
            item.representedObject = color
            item.state = settings.colorTheme == color ? .on : .off
            colorsMenu.addItem(item)
            colorMenuItems[color] = item
        }
        let colorsMenuItem = NSMenuItem(title: "Color", action: nil, keyEquivalent: "")
        colorsMenuItem.submenu = colorsMenu
        appearanceMenu.addItem(colorsMenuItem)
        
        // Gradients submenu
        let gradientsMenu = NSMenu()
        for gradient in ColorTheme.gradients {
            let item = NSMenuItem(title: gradient.rawValue, action: #selector(selectColor(_:)), keyEquivalent: "")
            item.representedObject = gradient
            item.state = settings.colorTheme == gradient ? .on : .off
            gradientsMenu.addItem(item)
            colorMenuItems[gradient] = item
        }
        let gradientsMenuItem = NSMenuItem(title: "Gradient", action: nil, keyEquivalent: "")
        gradientsMenuItem.submenu = gradientsMenu
        appearanceMenu.addItem(gradientsMenuItem)
        
        let appearanceMenuItem = NSMenuItem(title: "Appearance", action: nil, keyEquivalent: "")
        appearanceMenuItem.submenu = appearanceMenu
        menu.addItem(appearanceMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let quitMenuItem = NSMenuItem(title: "Quit Isotope", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quitMenuItem)
        
        statusItem.menu = menu
        updateMenuVisibility()
    }
    
    private func updateMenuVisibility() {
        // Update mode checkmarks
        for (mode, item) in modeMenuItems {
            item.state = timerEngine.mode == mode ? .on : .off
        }
        
        // Show/hide timer presets based on mode
        if let timerMenuItem = statusItem.menu?.item(withTitle: "Set Timer") {
            timerMenuItem.isHidden = timerEngine.mode != .timer
        }
        
        // Show/hide pomodoro status
        pomodoroStatusMenuItem.isHidden = timerEngine.mode != .pomodoro
        if timerEngine.mode == .pomodoro {
            updatePomodoroStatus()
        }
        
        // Show/hide skip phase
        if let skipItem = statusItem.menu?.item(withTitle: "Skip Phase") {
            skipItem.isHidden = timerEngine.mode != .pomodoro
        }
    }
    
    private func updatePomodoroStatus() {
        let sessionsTotal = settings.pomodoroSessionsBeforeLongBreak
        pomodoroStatusMenuItem.title = "Session \(timerEngine.pomodoroSessionNumber)/\(sessionsTotal) - \(timerEngine.pomodoroPhase.rawValue)"
    }
    
    // MARK: - Display Update
    private func updateDisplay(_ text: String) {
        guard let button = statusItem.button else { return }
        
        let theme = settings.colorTheme
        let isCompact = settings.compactMode
        
        if theme.isGradient, let (startColor, endColor) = theme.gradientColors {
            button.attributedTitle = createGradientText(text, from: startColor, to: endColor, compact: isCompact)
        } else {
            button.attributedTitle = createStyledText(text, color: theme.color, compact: isCompact)
        }
    }
    
    private func createStyledText(_ text: String, color: NSColor, compact: Bool) -> NSAttributedString {
        let fontSize: CGFloat = compact ? 10 : 14
        let font = NSFont.monospacedDigitSystemFont(ofSize: fontSize, weight: .semibold)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        if compact {
            paragraphStyle.lineSpacing = -3
            paragraphStyle.maximumLineHeight = 12
            paragraphStyle.minimumLineHeight = 12
        }
        
        var attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: color,
            .font: font,
            .paragraphStyle: paragraphStyle
        ]
        
        if compact {
            attributes[.baselineOffset] = -3
        }
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    private func createGradientText(_ text: String, from startColor: NSColor, to endColor: NSColor, compact: Bool) -> NSAttributedString {
        let fontSize: CGFloat = compact ? 10 : 14
        let font = NSFont.monospacedDigitSystemFont(ofSize: fontSize, weight: .semibold)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        if compact {
            paragraphStyle.lineSpacing = -3
            paragraphStyle.maximumLineHeight = 12
            paragraphStyle.minimumLineHeight = 12
        }
        
        var attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraphStyle
        ]
        
        if compact {
            attributes[.baselineOffset] = -3
        }
        
        let attributedString = NSMutableAttributedString(string: text, attributes: attributes)
        
        // Create gradient colors for each character (skip newlines)
        let chars = Array(text)
        let visibleChars = chars.filter { $0 != "\n" }
        let visibleCount = visibleChars.count
        guard visibleCount > 0 else { return attributedString }
        
        var visibleIndex = 0
        for (index, char) in chars.enumerated() {
            if char != "\n" {
                let fraction = CGFloat(visibleIndex) / CGFloat(max(1, visibleCount - 1))
                let color = interpolateColor(from: startColor, to: endColor, fraction: fraction)
                attributedString.addAttribute(.foregroundColor, value: color, range: NSRange(location: index, length: 1))
                visibleIndex += 1
            }
        }
        
        return attributedString
    }
    
    private func interpolateColor(from start: NSColor, to end: NSColor, fraction: CGFloat) -> NSColor {
        let f = max(0, min(1, fraction))
        
        let startRGB = start.usingColorSpace(.sRGB) ?? start
        let endRGB = end.usingColorSpace(.sRGB) ?? end
        
        let r = startRGB.redComponent + (endRGB.redComponent - startRGB.redComponent) * f
        let g = startRGB.greenComponent + (endRGB.greenComponent - startRGB.greenComponent) * f
        let b = startRGB.blueComponent + (endRGB.blueComponent - startRGB.blueComponent) * f
        
        return NSColor(red: r, green: g, blue: b, alpha: 1.0)
    }
    
    // MARK: - Actions
    @objc private func selectMode(_ sender: NSMenuItem) {
        guard let mode = sender.representedObject as? TimerMode else { return }
        timerEngine.setMode(mode)
        updateMenuVisibility()
        startStopMenuItem.title = "Start"
    }
    
    @objc private func selectTimerPreset(_ sender: NSMenuItem) {
        guard let minutes = sender.representedObject as? Int else { return }
        timerEngine.setTimerDuration(minutes: minutes)
    }
    
    @objc private func showCustomTimerInput() {
        let alert = NSAlert()
        alert.messageText = "Set Custom Timer"
        alert.informativeText = "Enter duration in minutes:"
        alert.addButton(withTitle: "Set")
        alert.addButton(withTitle: "Cancel")
        
        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 100, height: 24))
        input.stringValue = "25"
        alert.accessoryView = input
        
        if alert.runModal() == .alertFirstButtonReturn {
            if let minutes = Int(input.stringValue), minutes > 0 {
                timerEngine.setTimerDuration(minutes: minutes)
            }
        }
    }
    
    @objc private func toggleStartStop() {
        if timerEngine.isRunning {
            timerEngine.stop()
            startStopMenuItem.title = "Start"
        } else {
            timerEngine.start()
            startStopMenuItem.title = "Stop"
        }
    }
    
    @objc private func resetTimer() {
        timerEngine.reset()
        startStopMenuItem.title = "Start"
    }
    
    @objc private func skipPhase() {
        timerEngine.skipPomodoroPhase()
        updatePomodoroStatus()
    }
    
    @objc private func toggleShowSeconds() {
        settings.showSeconds.toggle()
        showSecondsMenuItem.state = settings.showSeconds ? .on : .off
        updateDisplay(timerEngine.formattedTime())
    }
    
    @objc private func toggleCompactMode() {
        settings.compactMode.toggle()
        compactModeMenuItem.state = settings.compactMode ? .on : .off
        updateStatusItemAppearance()
        updateDisplay(timerEngine.formattedTime())
    }
    
    @objc private func selectColor(_ sender: NSMenuItem) {
        guard let color = sender.representedObject as? ColorTheme else { return }
        
        // Update checkmarks
        for (theme, item) in colorMenuItems {
            item.state = theme == color ? .on : .off
        }
        
        settings.colorTheme = color
        updateDisplay(timerEngine.formattedTime())
    }
    
    @objc private func setWorkDuration(_ sender: NSMenuItem) {
        guard let minutes = sender.representedObject as? Int else { return }
        settings.pomodoroWorkDuration = minutes
    }
    
    @objc private func setShortBreak(_ sender: NSMenuItem) {
        guard let minutes = sender.representedObject as? Int else { return }
        settings.pomodoroShortBreak = minutes
    }
    
    @objc private func setLongBreak(_ sender: NSMenuItem) {
        guard let minutes = sender.representedObject as? Int else { return }
        settings.pomodoroLongBreak = minutes
    }
    
    @objc private func toggleAutoStart() {
        settings.autoStartNextSession.toggle()
    }
}

// MARK: - TimerEngineDelegate
extension AppDelegate: TimerEngineDelegate {
    func timerDidUpdate(displayText: String) {
        DispatchQueue.main.async { [weak self] in
            self?.updateDisplay(displayText)
        }
    }
    
    func timerDidComplete() {
        DispatchQueue.main.async { [weak self] in
            self?.startStopMenuItem.title = "Start"
        }
    }
    
    func pomodoroPhaseDidChange(phase: PomodoroPhase, sessionNumber: Int) {
        DispatchQueue.main.async { [weak self] in
            self?.updatePomodoroStatus()
        }
    }
}
