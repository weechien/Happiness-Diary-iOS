import UIKit
import FirebaseStorage

// Build the contents of the guidance
class GuidanceBuilder: NSObject {
    private var fullDEengModel: [GuidanceModel]?
    private var fullDEchiModel: [GuidanceModel]?
    private var fullDGengModel: [GuidanceModel]?
    private var fullDGchiModel: [GuidanceModel]?
    private var fullDEengDate: [String]?
    private var fullDEchiDate: [String]?
    private var fullDGengDate: [String]?
    private var fullDGchiDate: [String]?
    
    static let sharedInstance = GuidanceBuilder()
    
    func buildGuidance(helper: GuidanceHelper, ignoreLeap: Bool = false) -> [GuidanceModel] {
        var guidance = [GuidanceModel]()
        var content: Array<String>?
        var source: Any?
        var leap: Int = 0
        var lang: String = ""
        
        if helper == .None {
            return guidance
        }
        
        if (!ignoreLeap && !isLeapYear()) { leap = 1 }
        
        let path = "\(helper.rawValue)/xhdpi"
        let date = Localizator.sharedInstance.getLocalizableDictionary()?.value(forKey: "Date") as! Array<String>
        
        if helper == .Encouragement {
            content = Localizator.sharedInstance.getLocalizableDictionary()?.value(forKey: "Content_DE") as? Array<String>
            source = Array<String>(repeating: "daisaku".localOther, count: date.count)
            lang = Language.sharedInstance.getLang() == SystemLanguage.Eng.rawValue ? "/\(FirebaseLanguage.Eng.rawValue)" : "/\(FirebaseLanguage.Chi.rawValue)"
            
        } else if helper == .Gosho {
            content = Localizator.sharedInstance.getLocalizableDictionary()?.value(forKey: "Content_DG") as? Array<String>
            source = Localizator.sharedInstance.getLocalizableDictionary()?.value(forKey: "Source") as! Array<String>
            lang = ""
        }
        
        for (key, value) in date.enumerated() {
            if (key == 59 && leap == 1) { continue }
            
            let mGuidance = GuidanceModel()
            mGuidance.date = value
            
            getFirebaseImage(guidance: mGuidance, key: key, path: path, lang: lang)
            setCardBackgroundColor(guidance: mGuidance, key: key)
            
            mGuidance.content = content?[key]
            mGuidance.source = (source as! Array<String>)[key]
            mGuidance.combinedString = NSMutableAttributedString(string: "\(mGuidance.date!) \(mGuidance.content!) \(mGuidance.source!)")
            
            guidance.append(mGuidance)
        }
        return guidance
    }

    private func getFirebaseImage(guidance: GuidanceModel, key: Int, path: String, lang: String) {
        if (0 <= key && key <= 30) { // Jan
            guidance.image = "\(path + lang)/Jan/\(key).webp"
            
        } else if (31 <= key && key <= 59) { // Feb
            guidance.image = "\(path + lang)/Feb/\(key - 31).webp"
            
        } else if (60 <= key && key <= 90) { // Mar
            guidance.image = "\(path + lang)/Mar/\(key - 60).webp"
            
        } else if (91 <= key && key <= 120) { // Apr
            guidance.image = "\(path + lang)/Apr/\(key - 91).webp"
            
        } else if (121 <= key && key <= 151) { // May
            guidance.image = "\(path + lang)/May/\(key - 121).webp"
            
        } else if (152 <= key && key <= 181) { // Jun
            guidance.image = "\(path + lang)/Jun/\(key - 152).webp"
            
        } else if (182 <= key && key <= 212) { // Jul
            guidance.image = "\(path + lang)/Jul/\(key - 182).webp"
            
        } else if (213 <= key && key <= 243) { // Aug
            guidance.image = "\(path + lang)/Aug/\(key - 213).webp"
            
        } else if (244 <= key && key <= 273) { // Sep
            guidance.image = "\(path + lang)/Sep/\(key - 244).webp"
            
        } else if (274 <= key && key <= 304) { // Oct
            guidance.image = "\(path + lang)/Oct/\(key - 274).webp"
            
        } else if (305 <= key && key <= 334) { // Nov
            guidance.image = "\(path + lang)/Nov/\(key - 305).webp"
            
        } else if (335 <= key && key <= 365) { // Dec
            guidance.image = "\(path + lang)/Dec/\(key - 335).webp"
        }
    }
    
    private func setCardBackgroundColor(guidance: GuidanceModel, key: Int) {
        let isColorEnabled = SettingsViewController.isCardColorEnabled()
        
        if (0 <= key && key <= 30) { // Jan
            guidance.backgroundColor = isColorEnabled ? .rgb(red: 240, green: 248, blue: 255) : .white
            
        } else if (31 <= key && key <= 59) { // Feb
            guidance.backgroundColor = isColorEnabled ? .rgb(red: 255, green: 233, blue: 233) : .white

        } else if (60 <= key && key <= 90) { // Mar
            guidance.backgroundColor = isColorEnabled ? .rgb(red: 238, green: 238, blue: 238) : .white

        } else if (91 <= key && key <= 120) { // Apr
            guidance.backgroundColor = isColorEnabled ? .rgb(red: 222, green: 255, blue: 219) : .white

        } else if (121 <= key && key <= 151) { // May
            guidance.backgroundColor = isColorEnabled ? .rgb(red: 245, green: 245, blue: 220) : .white

        } else if (152 <= key && key <= 181) { // Jun
            guidance.backgroundColor = isColorEnabled ? .rgb(red: 243, green: 225, blue: 203) : .white

        } else if (182 <= key && key <= 212) { // Jul
            guidance.backgroundColor = isColorEnabled ? .rgb(red: 228, green: 238, blue: 245) : .white

        } else if (213 <= key && key <= 243) { // Aug
            guidance.backgroundColor = isColorEnabled ? .rgb(red: 215, green: 187, blue: 187) : .white

        } else if (244 <= key && key <= 273) { // Sep
            guidance.backgroundColor = isColorEnabled ? .rgb(red: 236, green: 218, blue: 236) : .white

        } else if (274 <= key && key <= 304) { // Oct
            guidance.backgroundColor = isColorEnabled ? .rgb(red: 250, green: 235, blue: 215) : .white

        } else if (305 <= key && key <= 334) { // Nov
            guidance.backgroundColor = isColorEnabled ? .rgb(red: 253, green: 247, blue: 231) : .white

        } else if (335 <= key && key <= 365) { // Dec
            guidance.backgroundColor = isColorEnabled ? .rgb(red: 237, green: 221, blue: 221) : .white
        }
    }
    
    func sortBookmark(communicator: DropDownCommunicator) {
        let language = Language.sharedInstance.getLang()
        
        if language == SystemLanguage.Eng.rawValue {
            if let DEeng = communicator.bookmarkDEeng, let DGeng = communicator.bookmarkDGeng {
                let sortedDates = sortBasedOnDate(encouragement: DEeng, gosho: DGeng)
                communicator.bookmarkDEeng = sortedDates.0
                communicator.bookmarkDGeng = sortedDates.1
            }
        } else {
            if let DEchi = communicator.bookmarkDEchi, let DGchi = communicator.bookmarkDGchi {
                let sortedDates = sortBasedOnDate(encouragement: DEchi, gosho: DGchi)
                communicator.bookmarkDEchi = sortedDates.0
                communicator.bookmarkDGchi = sortedDates.1
            }
        }
    }
    
    private func sortBasedOnDate(encouragement: [String], gosho: [String]) -> ([String], [String]) {
        let array = [encouragement, gosho]
        var returnArray = [[String]]()
        let fullDateDE = getModels(.BookmarkEncouragement).1
        let fullDateDG = getModels(.BookmarkGosho).1
        
        
        for (key, stringArray) in array.enumerated() {
            let fullDate = key == 0 ? fullDateDE : fullDateDG
            let sorted = stringArray.sorted {
                let date1 = $0.getSubString(start: 7, end: $0.count)
                let date2 = $1.getSubString(start: 7, end: $1.count)

                let index1 = getIndexOfItem(date: date1, fullDate: fullDate)
                let index2 = getIndexOfItem(date: date2, fullDate: fullDate)
                
                return index1 < index2
            }
            returnArray.append(sorted)
        }
        return (returnArray[0], returnArray[1])
    }
    
    // Get a list of bookmarked guidance and return them in an array of guidance model objects
    func buildGuidanceBookmark(guidanceType: GuidanceHelper, bookmarkedDates: [String]) -> [GuidanceModel] {
        var guidance = [GuidanceModel]()
        let models = getModels(guidanceType)
        let fullGuidance = models.0
        let fullDate = models.1

        for date in bookmarkedDates {
            let mDate = date.getSubString(start: 7, end: date.count)
            let index = getIndexOfItem(date: mDate, fullDate: fullDate)
            if index != -1 {
                guidance.append(fullGuidance[index])
            }
        }
        return guidance
    }
    
    // Get the guidance and date model properties and create the models if nil
    private func getModels(_ bookmarkType: GuidanceHelper) -> ([GuidanceModel], [String]) {
        let language = Language.sharedInstance.getLang()
        var fullModel: [GuidanceModel]?
        var fullDate: [String]?
        var baseType: GuidanceHelper?
        
        if bookmarkType == .BookmarkEncouragement {
            baseType = .Encouragement
            fullModel = language == SystemLanguage.Eng.rawValue ? fullDEengModel : fullDEchiModel
            fullDate = language == SystemLanguage.Eng.rawValue ? fullDEengDate : fullDEchiDate
        } else if bookmarkType == .BookmarkGosho {
            baseType = .Gosho
            fullModel = language == SystemLanguage.Eng.rawValue ? fullDGengModel : fullDGchiModel
            fullDate = language == SystemLanguage.Eng.rawValue ? fullDGengDate : fullDGchiDate
        }
        
        if fullModel == nil && fullDate == nil {
            fullModel = buildGuidance(helper: baseType!, ignoreLeap: true)
            fullDate = extractDatesFromModel(fullModel: fullModel!)
        }
        return (fullModel!, fullDate!)
    }
    
    private func extractDatesFromModel(fullModel: [GuidanceModel]) -> [String] {
        var string = [String]()
        
        for item in fullModel {
            guard let date = item.date else { continue }
            string.append(date)
        }
        return string
    }
    
    private func getIndexOfItem(date: String, fullDate: [String]) -> Int {
        if let index = fullDate.index(of: date) {
            return index
        }
        return -1
    }
    
    private func isLeapYear(_ date: Date = Date()) -> Bool {
        let calendar = NSCalendar.current
        let components = calendar.dateComponents([.year], from: date)
        
        let year = components.year
        return (year! % 4 == 0) && (year! % 100 != 0) || (year! % 400 == 0)
    }
}
