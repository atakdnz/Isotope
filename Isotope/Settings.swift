import Foundation

class Settings {
    static let shared = Settings()
    
    private let defaults = UserDefaults.standard
    
    // MARK: - Keys
    private enum Keys {
        static let showSeconds = "showSeconds"
        static let compactMode = "compactMode"
        static let colorTheme = "colorTheme"
        static let pomodoroWorkDuration = "pomodoroWorkDuration"
        static let pomodoroShortBreak = "pomodoroShortBreak"
        static let pomodoroLongBreak = "pomodoroLongBreak"
        static let pomodoroSessionsBeforeLongBreak = "pomodoroSessionsBeforeLongBreak"
        static let autoStartNextSession = "autoStartNextSession"
    }
    
    // MARK: - Display Settings
    var showSeconds: Bool {
        get { defaults.object(forKey: Keys.showSeconds) as? Bool ?? true }
        set { defaults.set(newValue, forKey: Keys.showSeconds) }
    }
    
    var compactMode: Bool {
        get { defaults.bool(forKey: Keys.compactMode) }
        set { defaults.set(newValue, forKey: Keys.compactMode) }
    }
    
    var colorTheme: ColorTheme {
        get {
            guard let rawValue = defaults.string(forKey: Keys.colorTheme),
                  let theme = ColorTheme(rawValue: rawValue) else {
                return .white
            }
            return theme
        }
        set { defaults.set(newValue.rawValue, forKey: Keys.colorTheme) }
    }
    
    // MARK: - Pomodoro Settings
    var pomodoroWorkDuration: Int {
        get { defaults.object(forKey: Keys.pomodoroWorkDuration) as? Int ?? 25 }
        set { defaults.set(newValue, forKey: Keys.pomodoroWorkDuration) }
    }
    
    var pomodoroShortBreak: Int {
        get { defaults.object(forKey: Keys.pomodoroShortBreak) as? Int ?? 5 }
        set { defaults.set(newValue, forKey: Keys.pomodoroShortBreak) }
    }
    
    var pomodoroLongBreak: Int {
        get { defaults.object(forKey: Keys.pomodoroLongBreak) as? Int ?? 15 }
        set { defaults.set(newValue, forKey: Keys.pomodoroLongBreak) }
    }
    
    var pomodoroSessionsBeforeLongBreak: Int {
        get { defaults.object(forKey: Keys.pomodoroSessionsBeforeLongBreak) as? Int ?? 4 }
        set { defaults.set(newValue, forKey: Keys.pomodoroSessionsBeforeLongBreak) }
    }
    
    var autoStartNextSession: Bool {
        get { defaults.bool(forKey: Keys.autoStartNextSession) }
        set { defaults.set(newValue, forKey: Keys.autoStartNextSession) }
    }
    
    // MARK: - Timer Presets (in minutes)
    let timerPresets: [Int] = [5, 10, 15, 25, 30, 45, 60]
    
    private init() {}
}
