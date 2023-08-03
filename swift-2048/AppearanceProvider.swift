import UIKit

protocol AppearanceProviderProtocol: class {
  func tileColor(_ value: Int) -> UIColor
  func numberColor(_ value: Int) -> UIColor
  func fontForNumbers() -> UIFont
}

class AppearanceProvider: AppearanceProviderProtocol {

  // Provide a tile color for a given value
  func tileColor(_ value: Int) -> UIColor {
    switch value {
    case 1:
      return UIColor(red: 204.0/255.0, green: 209.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    case 2,3:
      return UIColor(red: 102.0/255.0, green: 178.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    case 5,8:
        return UIColor(red: 51.0/255.0, green: 51.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    case 13,21:
        return UIColor(red: 127.0/255.0, green: 0.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    case 34,55:
      return UIColor(red: 204.0/255.0, green: 0.0/255.0, blue: 204.0/255.0, alpha: 1.0)
    case 89,144,233:
      return UIColor(red: 153.0/255.0, green: 0.0/255.0, blue: 153.0/255.0, alpha: 1.0)
    case 377,610,987:
      return UIColor(red: 153.0/255.0, green: 0.0/255.0, blue: 76.0/255.0, alpha: 1.0)
    default:
      return UIColor.white
    }
  }

  // Provide a numeral color for a given value
  func numberColor(_ value: Int) -> UIColor {
      return UIColor.white
    
  }

  // Provide the font to be used on the number tiles
  func fontForNumbers() -> UIFont {
    if let font = UIFont(name: "HelveticaNeue-Bold", size: 20) {
      return font
    }
    return UIFont.systemFont(ofSize: 20)
  }
}
