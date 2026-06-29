import UIKit

enum Colors {
    static let viewBackground = UIColor { traits in
        if traits.userInterfaceStyle == .light {
            return UIColor.systemBackground
        } else {
            return UIColor(
                red: 26.0 / 255.0,
                green: 27.0 / 255.0,
                blue: 34.0 / 255.0,
                alpha: 1.0
            )
        }
    }
    
    static let tableBackgroundColor = UIColor { (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .light {
            return UIColor.systemGray6
        } else {
            return UIColor(red: 65.0 / 255.0, green: 65.0 / 255.0, blue: 65.0 / 255.0, alpha: 0.85)
        }
    }
    
    static let blackWhiteButtonsColor = UIColor { (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .light {
            return UIColor.black
        } else {
            return UIColor.white
        }
    }
    
    static let TitleOnblackWhiteButtonsColor = UIColor { (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .light {
            return UIColor.white
        } else {
            return UIColor.black
        }
    }
}

