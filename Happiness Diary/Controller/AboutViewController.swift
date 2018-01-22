import UIKit
import MessageUI
import AcknowList

class AboutViewController: BaseTableViewController, MFMailComposeViewControllerDelegate {
    var emojiCounter = 0
    
    override var array: [TableViewWithHeader] {
        get {
            var tableViewArray = [TableViewWithHeader]()
            
            let tableView1 = TableViewWithHeader(
                header: "app_version".localOther,
                row: ["1.0.0"],
                rowDescription: nil)
            
            let tableView2 = TableViewWithHeader(
                header: "legal_information".localOther,
                row: ["terms_of_service".localOther,
                      "privacy_policy".localOther],
                rowDescription: nil)
            
            let tableView3 = TableViewWithHeader(
                header: "contact_us".localOther,
                row: ["happinezzdiary@gmail.com"],
                rowDescription: nil)
            
            let tableView4 = TableViewWithHeader(
                header: "credits".localOther,
                row: ["open_source_licenses".localOther],
                rowDescription: nil)
            
            tableViewArray.append(tableView1)
            tableViewArray.append(tableView2)
            tableViewArray.append(tableView3)
            tableViewArray.append(tableView4)
            
            return tableViewArray
        }
        set {}
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        navTitleLabel.text = "  " + "about".localOther
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        switch indexPath {
        case [0, 0]:
            navigationController?.showToast(message: printEmoji())
        case [1, 0]:
            launchUrl(url: "https://diary-of-happiness.firebaseapp.com/ToS/")
        case [1, 1]:
            launchUrl(url: "https://diary-of-happiness.firebaseapp.com/PrivacyPolicy/")
        case [2, 0]:
            sendEmail()
        case [3, 0]:
            let path = Bundle.main.path(forResource: "Pods-Happiness Diary-acknowledgements", ofType: "plist")
            let viewController = AcknowListViewController(acknowledgementsPlistPath: path)
            navigationController?.pushViewController(viewController, animated: true)
        default:
            print("Default")
        }
    }
    
    private func printEmoji() -> String {
        switch emojiCounter {
        case 0:
            emojiCounter = 1
            return "\u{1F623}"
        case 1:
            emojiCounter = 2
            return "\u{1F614}"
        case 2:
            emojiCounter = 3
            return "\u{1F612}"
        case 3:
            emojiCounter = 4
            return "\u{1F627}"
        case 4:
            emojiCounter = 5
            return "\u{1F62F}"
        case 5:
            emojiCounter = 6
            return "\u{1F62C}"
        case 6:
            emojiCounter = 7
            return "\u{1F60C}"
        case 7:
            emojiCounter = 8
            return "\u{1F604}"
        case 8:
            emojiCounter = 9
            return "\u{1F606}"
        case 9:
            emojiCounter = 0
            return "\u{1F60D}"
        default:
            return "Default"
        }
    }
    
    private func launchUrl(url: String) {
        if let url = URL(string: url) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    private func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["happinezzdiary@gmail.com"])
            mail.setSubject("hello_happiness_diary".localOther)
            
            present(mail, animated: true)
        } else {
            navigationController?.showDefaultAlert(message: "could_not_send_email".localOther)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
