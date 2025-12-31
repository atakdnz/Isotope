import Cocoa

protocol TimerEngineDelegate: AnyObject {
    func timerDidUpdate(displayText: String)
    func timerDidComplete()
    func pomodoroPhaseDidChange(phase: PomodoroPhase, sessionNumber: Int)
}

class TimerEngine {
    weak var delegate: TimerEngineDelegate?
    
    private var timer: Timer?
    private var startTime: Date?
    private var accumulatedTime: TimeInterval = 0
    private var targetDuration: TimeInterval = 0
    
    // MARK: - State
    private(set) var mode: TimerMode = .stopwatch
    private(set) var isRunning: Bool = false
    
    // Pomodoro state
    private(set) var pomodoroPhase: PomodoroPhase = .work
    private(set) var pomodoroSessionNumber: Int = 1
    
    private let settings = Settings.shared
    
    // MARK: - Computed Properties
    var elapsedTime: TimeInterval {
        if let startTime = startTime {
            return accumulatedTime + Date().timeIntervalSince(startTime)
        }
        return accumulatedTime
    }
    
    var remainingTime: TimeInterval {
        return max(0, targetDuration - elapsedTime)
    }
    
    // MARK: - Public Methods
    func setMode(_ newMode: TimerMode) {
        stop()
        reset()
        mode = newMode
        
        if mode == .pomodoro {
            pomodoroPhase = .work
            pomodoroSessionNumber = 1
            targetDuration = TimeInterval(settings.pomodoroWorkDuration * 60)
        }
        
        updateDisplay()
    }
    
    func setTimerDuration(minutes: Int) {
        guard mode == .timer else { return }
        stop()
        accumulatedTime = 0
        targetDuration = TimeInterval(minutes * 60)
        updateDisplay()
    }
    
    func start() {
        guard !isRunning else { return }
        isRunning = true
        startTime = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.current.add(timer!, forMode: .common)
        tick()
    }
    
    func stop() {
        guard isRunning else { return }
        isRunning = false
        accumulatedTime = elapsedTime
        startTime = nil
        timer?.invalidate()
        timer = nil
    }
    
    func reset() {
        stop()
        accumulatedTime = 0
        
        if mode == .pomodoro {
            pomodoroPhase = .work
            pomodoroSessionNumber = 1
            targetDuration = TimeInterval(settings.pomodoroWorkDuration * 60)
        } else if mode == .timer {
            // Keep target duration, just reset elapsed
        }
        
        updateDisplay()
    }
    
    func skipPomodoroPhase() {
        guard mode == .pomodoro else { return }
        advancePomodoroPhase()
    }
    
    // MARK: - Private Methods
    private func tick() {
        updateDisplay()
        
        // Check for timer completion
        if mode == .timer || mode == .pomodoro {
            if remainingTime <= 0 {
                handleCompletion()
            }
        }
    }
    
    private func updateDisplay() {
        let displayText = formattedTime()
        delegate?.timerDidUpdate(displayText: displayText)
    }
    
    private func handleCompletion() {
        stop()
        delegate?.timerDidComplete()
        sendNotification()
        
        if mode == .pomodoro {
            advancePomodoroPhase()
            
            if settings.autoStartNextSession {
                start()
            }
        }
    }
    
    private func advancePomodoroPhase() {
        accumulatedTime = 0
        
        switch pomodoroPhase {
        case .work:
            // Check if we need a long break
            if pomodoroSessionNumber >= settings.pomodoroSessionsBeforeLongBreak {
                pomodoroPhase = .longBreak
                targetDuration = TimeInterval(settings.pomodoroLongBreak * 60)
            } else {
                pomodoroPhase = .shortBreak
                targetDuration = TimeInterval(settings.pomodoroShortBreak * 60)
            }
            
        case .shortBreak:
            pomodoroPhase = .work
            pomodoroSessionNumber += 1
            targetDuration = TimeInterval(settings.pomodoroWorkDuration * 60)
            
        case .longBreak:
            pomodoroPhase = .work
            pomodoroSessionNumber = 1
            targetDuration = TimeInterval(settings.pomodoroWorkDuration * 60)
        }
        
        delegate?.pomodoroPhaseDidChange(phase: pomodoroPhase, sessionNumber: pomodoroSessionNumber)
        updateDisplay()
    }
    
    private func sendNotification() {
        let notification = NSUserNotification()
        
        switch mode {
        case .timer:
            notification.title = "Timer Complete"
            notification.informativeText = "Your timer has finished!"
        case .pomodoro:
            switch pomodoroPhase {
            case .work:
                notification.title = "Work Session Complete"
                notification.informativeText = "Time for a break!"
            case .shortBreak, .longBreak:
                notification.title = "Break Over"
                notification.informativeText = "Ready to focus?"
            }
        case .stopwatch:
            break
        }
        
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    func formattedTime() -> String {
        let time: TimeInterval
        
        switch mode {
        case .stopwatch:
            time = elapsedTime
        case .timer, .pomodoro:
            time = remainingTime
        }
        
        let totalSeconds = Int(time)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if settings.compactMode {
            // Compact stacked mode: minutes on top, seconds below
            if hours > 0 {
                return "\(hours)h\n\(minutes)m"
            } else {
                return String(format: "%02d\n%02d", minutes, seconds)
            }
        } else if settings.showSeconds {
            if hours > 0 {
                return String(format: "%d:%02d:%02d", hours, minutes, seconds)
            } else {
                return String(format: "%02d:%02d", minutes, seconds)
            }
        } else {
            if hours > 0 {
                return String(format: "%d:%02d", hours, minutes)
            } else {
                return String(format: "%d:%02d", minutes, seconds)
            }
        }
    }
}
