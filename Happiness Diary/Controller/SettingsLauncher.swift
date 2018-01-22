import UIKit
import Firebase

protocol SettingsLauncherDelegate: class {
    func showControllerForSetting(_ setting: SettingPopupModel)
    func presentLoginController()
    func refreshLanguage()
}

class SettingsLauncher: BaseLauncher {
    
    weak var delegate: SettingsLauncherDelegate?
    
    lazy var languageSettings: [SettingPopupModel] = {
        let english = SettingPopupModel(name: .English, imageName: "ic_eng")
        let chinese = SettingPopupModel(name: .Chinese, imageName: "ic_chi")
        let cancel = SettingPopupModel(name: .Cancel, imageName: "ic_cancel")

        return [english, chinese, cancel]
    }()
    
    override func showItems() {
        popupItems = setupDefaultSettings()
        collectionView.reloadData()
        super.showItems()
    }
    
    private func setupDefaultSettings() -> [SettingPopupModel] {
        let language = SettingPopupModel(name: .Language, imageName: "ic_language")
        let about = SettingPopupModel(name: .About, imageName: "ic_info")
        let settings = SettingPopupModel(name: .Settings, imageName: "ic_settings")
        let logout = LoginController.isGuest() ? SettingPopupModel(name: .SignIn, imageName: "ic_logout") : SettingPopupModel(name: .Logout, imageName: "ic_logout")
        let cancel = SettingPopupModel(name: .Cancel, imageName: "ic_cancel")
        
        return [language, about, settings, logout, cancel]
    }
    
    override func dismissCollectionView(_ item: AnyObject?) {
        super.dismissCollectionView(item)
        
        if let mItem = item as? SettingPopupModel, mItem.name == .Language {
            self.animateBlackViewOut(alpha: 0.5)
        } else {
            self.animateBlackViewOut(alpha: 0)
        }
    }
 
    // Called after dismissCollectionView
    override func dismissCompleted(_ item: AnyObject?) {
        super.dismissCompleted(item)
        
        if let setting = item as? SettingPopupModel {
            switch (setting.name) {
            case .Settings: delegate?.showControllerForSetting(setting)
            case .Language: showLanguageSettings()
            case .English: changeLanguage(language: .English)
            case .Chinese: changeLanguage(language: .Chinese)
            case .About: delegate?.showControllerForSetting(setting)
            case .Logout: signOutOfFirebase()
            case .SignIn: signOutOfFirebase()
            case .Cancel: break
            }
        }
    }
    
    private func signOutOfFirebase() {
        do {
            if Auth.auth().currentUser != nil {
                try Auth.auth().signOut()
            } else {
                UserDefaults.standard.set(false, forKey: LoginController.GUEST_LOGIN)
                delegate?.presentLoginController()
            }
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    private func showLanguageSettings() {
        popupItems = languageSettings
        collectionView.reloadData()
        animateIn()
    }
    
    private func changeLanguage(language: SettingPopupName) {
        let systemlanguage = Language.sharedInstance.getLang() == SystemLanguage.Eng.rawValue ? SettingPopupName.English : SettingPopupName.Chinese
        
        if language == systemlanguage {
            return
        }
        Language.sharedInstance.setLang(language: language)
        delegate?.refreshLanguage()
    }
}
