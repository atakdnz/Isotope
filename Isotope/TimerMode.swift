import Foundation

enum TimerMode: String, CaseIterable {
    case stopwatch = "Stopwatch"
    case timer = "Timer"
    case pomodoro = "Pomodoro"
}

enum PomodoroPhase: String {
    case work = "Work"
    case shortBreak = "Break"
    case longBreak = "Long Break"
}
