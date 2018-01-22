import UIKit

// Language preference 
class Language {
    
    static let sharedInstance = Language()
    
    let pref = UserDefaults.standard
    let languageKey = SystemLanguage.Key.rawValue
    let english = SystemLanguage.Eng.rawValue
    let chinese = SystemLanguage.Chi.rawValue
    
    // Check system language and set it as the default preference if there is none
    private func checkLang() {
        if pref.object(forKey: languageKey) == nil {
            if Locale.preferredLanguages[0] == chinese {
                pref.set(chinese, forKey: languageKey)
            } else {
                pref.set(english, forKey: languageKey)
            }
        }
    }
    
    // Get the language stored in preference
    func getLang() -> String {
        checkLang()
        return pref.object(forKey: languageKey) as! String
    }
    
    // Set the language
    func setLang(language: SettingPopupName) {
        if language == .English {
            if getLang() != english {
                pref.set(english, forKey: languageKey)
            }
        } else {
            if getLang() != chinese {
                pref.set(chinese, forKey: languageKey)
            }
        }
    }
}
