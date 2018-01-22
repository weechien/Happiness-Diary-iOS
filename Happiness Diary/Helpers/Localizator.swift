import UIKit

// Get the localized language
class Localizator {
    
    static let sharedInstance = Localizator()
    
    func getLocalizableDictionary() -> NSDictionary? {
        return getLocalizableWithLanguage(language: Language.sharedInstance.getLang())
    }
    
    func localize(key: String, string: String) -> String {
        guard let localizedString = (getLocalizableDictionary()!.value(forKey: key) as AnyObject).value(forKey: string) as? String else {
            assertionFailure("Missing translation for: \(string)")
            return ""
        }
        return localizedString
    }
    
    func getLocalizableWithLanguage(language: String) -> NSDictionary? {
        if let bundle = getBundleWithLanguage(language: language) {
            if let path = bundle.path(forResource:"Localizable", ofType: "plist") {
                return NSDictionary(contentsOfFile: path)
            }
        }
        return nil
    }
    
    func getBundleWithLanguage(language: String) -> Bundle? {
        if let mPath = Bundle.main.path(forResource: language, ofType: "lproj") {
            if let bundle = Bundle(path: mPath) {
                return bundle
            }
        }
        return nil
    }
}
