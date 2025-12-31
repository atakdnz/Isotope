import Cocoa

enum ColorTheme: String, CaseIterable {
    // Solid colors
    case white = "White"
    case red = "Red"
    case green = "Green"
    case blue = "Blue"
    case orange = "Orange"
    case purple = "Purple"
    case pink = "Pink"
    case yellow = "Yellow"
    case cyan = "Cyan"
    
    // Gradients
    case gradientSunset = "Sunset"
    case gradientOcean = "Ocean"
    case gradientForest = "Forest"
    case gradientNeon = "Neon"
    case gradientFire = "Fire"
    case gradientMint = "Mint"
    case gradientGold = "Gold"
    case gradientLavender = "Lavender"
    case gradientRainbow = "Rainbow"
    case gradientAurora = "Aurora"
    
    var isGradient: Bool {
        switch self {
        case .gradientSunset, .gradientOcean, .gradientForest, .gradientNeon,
             .gradientFire, .gradientMint, .gradientGold, .gradientLavender,
             .gradientRainbow, .gradientAurora:
            return true
        default:
            return false
        }
    }
    
    var color: NSColor {
        switch self {
        case .white: return .white
        case .red: return NSColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0)
        case .green: return NSColor(red: 0.3, green: 0.85, blue: 0.4, alpha: 1.0)
        case .blue: return NSColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 1.0)
        case .orange: return NSColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0)
        case .purple: return NSColor(red: 0.7, green: 0.4, blue: 1.0, alpha: 1.0)
        case .pink: return NSColor(red: 1.0, green: 0.4, blue: 0.6, alpha: 1.0)
        case .yellow: return NSColor(red: 1.0, green: 0.85, blue: 0.2, alpha: 1.0)
        case .cyan: return NSColor(red: 0.2, green: 0.9, blue: 0.9, alpha: 1.0)
        default: return .white
        }
    }
    
    var gradientColors: (NSColor, NSColor)? {
        switch self {
        case .gradientSunset:
            return (NSColor(red: 1.0, green: 0.5, blue: 0.2, alpha: 1.0),
                    NSColor(red: 1.0, green: 0.3, blue: 0.5, alpha: 1.0))
        case .gradientOcean:
            return (NSColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 1.0),
                    NSColor(red: 0.2, green: 0.8, blue: 0.9, alpha: 1.0))
        case .gradientForest:
            return (NSColor(red: 0.2, green: 0.7, blue: 0.4, alpha: 1.0),
                    NSColor(red: 0.1, green: 0.8, blue: 0.7, alpha: 1.0))
        case .gradientNeon:
            return (NSColor(red: 1.0, green: 0.2, blue: 0.6, alpha: 1.0),
                    NSColor(red: 0.6, green: 0.2, blue: 1.0, alpha: 1.0))
        case .gradientFire:
            return (NSColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0),
                    NSColor(red: 1.0, green: 0.2, blue: 0.1, alpha: 1.0))
        case .gradientMint:
            return (NSColor(red: 0.4, green: 1.0, blue: 0.8, alpha: 1.0),
                    NSColor(red: 0.2, green: 0.8, blue: 0.6, alpha: 1.0))
        case .gradientGold:
            return (NSColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 1.0),
                    NSColor(red: 0.9, green: 0.6, blue: 0.2, alpha: 1.0))
        case .gradientLavender:
            return (NSColor(red: 0.7, green: 0.5, blue: 1.0, alpha: 1.0),
                    NSColor(red: 0.9, green: 0.6, blue: 0.9, alpha: 1.0))
        case .gradientRainbow:
            return (NSColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0),
                    NSColor(red: 0.3, green: 0.5, blue: 1.0, alpha: 1.0))
        case .gradientAurora:
            return (NSColor(red: 0.2, green: 1.0, blue: 0.6, alpha: 1.0),
                    NSColor(red: 0.4, green: 0.2, blue: 1.0, alpha: 1.0))
        default:
            return nil
        }
    }
    
    static var solidColors: [ColorTheme] {
        [.white, .red, .green, .blue, .orange, .purple, .pink, .yellow, .cyan]
    }
    
    static var gradients: [ColorTheme] {
        [.gradientSunset, .gradientOcean, .gradientForest, .gradientNeon,
         .gradientFire, .gradientMint, .gradientGold, .gradientLavender,
         .gradientRainbow, .gradientAurora]
    }
}
