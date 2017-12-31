import UIKit

class SettingPopupModel: NSObject {
    let name: SettingPopupName
    let imageName: String
    
    init(name: SettingPopupName, imageName: String) {
        self.name = name
        self.imageName = imageName
    }
}

class DropdownPopupModel: NSObject {
    let name: DropDownPopupName
    let imageName: String
    
    init(name: DropDownPopupName, imageName: String) {
        self.name = name
        self.imageName = imageName
    }
}
