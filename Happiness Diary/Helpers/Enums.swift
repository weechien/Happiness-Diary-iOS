import UIKit

// System language enums
enum SystemLanguage: String {
    case Key = "language"
    case Eng = "en"
    case Chi = "zh-Hans"
}

// Firebase language selection
enum FirebaseLanguage: String {
    case Eng = "Eng"
    case Chi = "Chi"
}

// Names of setting popup items
enum SettingPopupName: String {
    case Cancel = "cancel"
    case Language = "language"
    case Settings = "settings"
    case About = "about"
    case English = "english_untranslatable"
    case Chinese = "chinese_untranslatable"
    case Logout = "logout"
    case SignIn = "sign_in_sign_up"
}

// Names of dropdown popup items
enum DropDownPopupName: String {
    case Cancel = "cancel"
    case Share = "share"
    case ShareImage = "share_image"
    case ShareGuidance = "share_guidance"
    case Copy = "copy"
    case Bookmark = "bookmark"
    case Unbookmark = "unbookmark"
}

// Guidance builder
enum GuidanceHelper: String {
    case Encouragement = "Daily Encouragement"
    case Gosho = "Daily Gosho"
    case None = "None"
    case BookmarkEncouragement = "Bookmark Encouragement"
    case BookmarkGosho = "Bookmark Gosho"
}

// Communicate from the drop down view to the main controller
enum DropDownMessage {
    case ToastError
    case ToastCopied
    case ToastBookmarked
    case ToastUnbookmarked
    case PresentView
}

// Firebase providers
enum FirebaseProvider: String {
    case Google = "google.com"
    case Facebook = "facebook.com"
    case Password = "password"
}
