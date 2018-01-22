import UIKit

class SettingsViewController: BaseTableViewController {
    static let GUIDANCE_NOTIFICATION_FIRST = "GUIDANCE_NOTIFICATION_FIRST"
    static let GUIDANCE_NOTIFICATION_TIME = "GUIDANCE_NOTIFICATION_TIME"
    static let GUIDANCE_NOTIFICATION_SWITCH = "GUIDANCE_NOTIFICATION_SWITCH"
    static let GUIDANCE_CARD_COLOR = "GUIDANCE_CARD_COLOR"
    
    override var array: [TableViewWithHeader] {
        get {
            var tableViewArray = [TableViewWithHeader]()
            let tableView1 = TableViewWithHeader(
                header: "general".localOther,
                row: ["guidance_notification".localOther,
                      "guidance_card_color".localOther],
                rowDescription: ["\(SettingsViewController.describeSwitchStatus(isSwitchOn: SettingsViewController.getGuidanceNotificationSwitch()))",
                                "\(SettingsViewController.getCardColorStatus())"]
            )
            tableViewArray.append(tableView1)
            
            return tableViewArray
        }
        set {}
    }
    
    let dummyTextField: UITextField = {
        let textField = UITextField(frame: .zero)
        return textField
    }()
    
    let timePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        return picker
    }()
    
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        return dateFormatter
    }()
    
    static func describeSwitchStatus(isSwitchOn: Bool = false) -> String {
        if isSwitchOn {
            return "\("guidance_notification_summary".localOther) \(SettingsViewController.getGuidanceNotificationTime())"
        } else {
            return "notification_disabled".localOther
        }
    }
    
    // Only run this once
    static func isFirstNotification() -> Bool {
        let pref = UserDefaults.standard
        if pref.object(forKey: SettingsViewController.GUIDANCE_NOTIFICATION_FIRST) == nil {
            pref.set(true, forKey: SettingsViewController.GUIDANCE_NOTIFICATION_FIRST)
            return true
        }
        return pref.object(forKey: SettingsViewController.GUIDANCE_NOTIFICATION_FIRST) as! Bool
    }
    
    static func getGuidanceNotificationTime() -> String {
        let pref = UserDefaults.standard
        if pref.object(forKey: SettingsViewController.GUIDANCE_NOTIFICATION_TIME) == nil {
            let timeString = "8:00 AM"
            pref.set(timeString, forKey: SettingsViewController.GUIDANCE_NOTIFICATION_TIME)
            return timeString
        }
        return pref.object(forKey: SettingsViewController.GUIDANCE_NOTIFICATION_TIME) as! String
    }
    
    static func getGuidanceNotificationSwitch() -> Bool {
        let pref = UserDefaults.standard
        if pref.object(forKey: SettingsViewController.GUIDANCE_NOTIFICATION_SWITCH) == nil {
            pref.set(true, forKey: SettingsViewController.GUIDANCE_NOTIFICATION_SWITCH)
            return true
        }
        return pref.object(forKey: SettingsViewController.GUIDANCE_NOTIFICATION_SWITCH) as! Bool
    }
    
    static func isCardColorEnabled() -> Bool {
        let pref = UserDefaults.standard
        if pref.object(forKey: SettingsViewController.GUIDANCE_CARD_COLOR) == nil {
            pref.set(true, forKey: SettingsViewController.GUIDANCE_CARD_COLOR)
            return true
        }
        return pref.object(forKey: SettingsViewController.GUIDANCE_CARD_COLOR) as! Bool
    }
    
    static func getCardColorStatus() -> String {
        if SettingsViewController.isCardColorEnabled() {
            return "card_color_enabled".localOther
        } else {
            return "card_color_disabled".localOther
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDummyTextField()
        tableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: cellId)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(handleViewDidEnterForeground), name: .UIApplicationDidBecomeActive , object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidBecomeActive, object: nil)
    }
    
    @objc private func handleViewDidEnterForeground() {
        NotificationManager.sharedInstance.getAuthorizationStatus { status in
            DispatchQueue.main.async(execute: {
                if status != .notDetermined, let visibleCell = self.tableView.visibleCells.first {
                    visibleCell.accessoryView = self.setupSwitchView(0)
                }
            })
        }
    }
    
    private func setupDummyTextField() {
        view.addSubview(dummyTextField)
        dummyTextField.inputView = timePicker
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        navTitleLabel.text = "  " + "settings".localOther
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! SettingsTableViewCell
        cell.accessoryView = setupSwitchView(indexPath.row)
        cell.model = setupSettingsModel(cell, indexPath)
        return cell
    }
    
    private func setupSettingsModel(_ cell: SettingsTableViewCell, _ indexPath: IndexPath) -> SettingsTableViewModel {
        let mainText = array[indexPath.section].row[indexPath.row]
        let subText = array[indexPath.section].rowDescription![indexPath.row]
        
        return SettingsTableViewModel(mainText: mainText, subText: subText)
    }
    
    private func setupSwitchView(_ tag: Int) -> UISwitch {
        let switchView = UISwitch(frame: .zero)
        switchView.tag = tag
        
        if tag == 0 {
            NotificationManager.sharedInstance.isAuthorized(completion: { bool in
                if !bool {
                    DispatchQueue.main.async(execute: {
                        switchView.setOn(false, animated: true)
                    })
                    self.updateGuidanceNotificationSwitchOff()
                    return
                }
                DispatchQueue.main.async(execute: {
                    switchView.setOn(SettingsViewController.getGuidanceNotificationSwitch(), animated: false)
                })
            })
            
        } else if tag == 1 {
            if SettingsViewController.getCardColorStatus() == "card_color_enabled".localOther {
                switchView.setOn(true, animated: true)
            } else {
                switchView.setOn(false, animated: true)
            }
        }
        switchView.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        return switchView
    }
    
    private func updateGuidanceNotificationSwitchOff() {
        UserDefaults.standard.set(false, forKey: SettingsViewController.GUIDANCE_NOTIFICATION_SWITCH)
        updateSubViewText(indexPath: IndexPath(row: 0, section: 0))
        NotificationManager.sharedInstance.cancelAllNotifications()
    }
    
    private func updateGuidanceNotificationSwitchOn() {
        UserDefaults.standard.set(true, forKey: SettingsViewController.GUIDANCE_NOTIFICATION_SWITCH)
        updateSubViewText(indexPath: IndexPath(row: 0, section: 0))
        
        if let date = dateFormatter.date(from: SettingsViewController.getGuidanceNotificationTime()) {
            print(SettingsViewController.getGuidanceNotificationTime())
            NotificationManager.sharedInstance.schedule(date: date, repeats: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! SettingsTableViewCell
        let accessoryView = cell.accessoryView as! UISwitch
        
        if cell.mainView.text == "guidance_notification".localOther {
            if accessoryView.isOn { showTimePicker(cell: cell) }
        } else if cell.mainView.text == "guidance_card_color".localOther {
            
        }
        super.tableView(tableView, didSelectRowAt: indexPath)
    }
    
    private func showTimePicker(cell: SettingsTableViewCell) {
        setPickerTime()
        dummyTextField.inputAccessoryView = createPickerToolBar()
        dummyTextField.becomeFirstResponder()
    }
    
    private func setPickerTime() {
        if let date = dateFormatter.date(from: SettingsViewController.getGuidanceNotificationTime()) {
            timePicker.date = date
        }
    }
    
    private func createPickerToolBar() -> UIToolbar {
        let toolbar = UIToolbar()
        let doneButton = UIBarButtonItem(title: "done".localOther, style: .done, target: self, action: #selector(handlePickerDoneAction))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.backgroundColor = .lightGray
        toolbar.sizeToFit()
        toolbar.setItems([spaceButton, doneButton, spaceButton], animated: true)
        toolbar.isUserInteractionEnabled = true
        return toolbar
    }
    
    @objc private func handlePickerDoneAction() {
        let timeString = dateFormatter.string(from: timePicker.date)
        UserDefaults.standard.set(timeString, forKey: SettingsViewController.GUIDANCE_NOTIFICATION_TIME)
        updateSubViewText(indexPath: IndexPath(row: 0, section: 0))
        
        if let date = dateFormatter.date(from: SettingsViewController.getGuidanceNotificationTime()) {
            print(SettingsViewController.getGuidanceNotificationTime())
            NotificationManager.sharedInstance.schedule(date: date, repeats: true)
        }
        
        dummyTextField.resignFirstResponder()
    }
    
    @objc private func switchChanged(_ sender: UISwitch!) {
        if sender.tag == 0 {
            if sender.isOn {
                NotificationManager.sharedInstance.requestAuthorization(completion: { bool in
                    if bool {
                        self.updateGuidanceNotificationSwitchOn()
                    } else {
                        if SettingsViewController.isFirstNotification() {
                            UserDefaults.standard.set(false, forKey: SettingsViewController.GUIDANCE_NOTIFICATION_FIRST)
                        } else {
                            let cancelAction = UIAlertAction(title: "cancel".localOther, style: .default, handler: nil)
                            self.navigationController?.showAlert(title: nil, message: "please_enable_notification".localOther, actions: cancelAction, self.addNavigateToSettingsAction())
                        }
                        DispatchQueue.main.async(execute: {
                            sender.setOn(false, animated: true)
                        })
                        self.updateGuidanceNotificationSwitchOff()
                    }
                })
            } else {
                updateGuidanceNotificationSwitchOff()
            }
        } else if sender.tag == 1 {
            if sender.isOn {
                UserDefaults.standard.set(true, forKey: SettingsViewController.GUIDANCE_CARD_COLOR)
            } else {
                UserDefaults.standard.set(false, forKey: SettingsViewController.GUIDANCE_CARD_COLOR)
            }
            updateSubViewText(indexPath: IndexPath(row: 1, section: 0))
        }
    }
    
    private func addNavigateToSettingsAction() -> UIAlertAction{
        let settingsAction = UIAlertAction(title: "settings".localOther, style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: nil)
            }
        }
        return settingsAction
    }
    
    private func updateSubViewText(indexPath: IndexPath) {
        DispatchQueue.main.async(execute: {
            let cell = self.tableView.cellForRow(at: indexPath) as? SettingsTableViewCell
            
            if let cell = cell {
                cell.subView.text = self.array[indexPath.section].rowDescription![indexPath.row]
            }
        })
    }
}
