import UIKit
import UserNotifications

class NotificationManager: NSObject {
    static let notificationId = "notificationId"
    
    static let sharedInstance = NotificationManager()
    
    func requestAuthorization(completion: @escaping (Bool) -> ()) {
        let options: UNAuthorizationOptions =  [.alert, .sound]
        
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, error) in
            completion(granted)
        }
        
        UNUserNotificationCenter.current().delegate = self
    }
    
    func schedule(date: Date, repeats: Bool) {
        let guidance = GuidanceBuilder.sharedInstance.buildGuidance(helper: .Encouragement)
        let indexPathRow = MainGuidanceCell.getIndexPathForToday().row
        let content = UNMutableNotificationContent()
        
        if let date = guidance[indexPathRow].date, let body = guidance[indexPathRow].content, let source = guidance[indexPathRow].source {
            content.title = "daily_encouragement".localOther
            content.subtitle = date
            content.body = "\(body) \(source)"
            content.sound = .default()
        }
        
        let components = Calendar.current.dateComponents([.minute, .hour], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: NotificationManager.notificationId, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if error == nil {
                print("Notification scheduled")
            } else {
                print("Error scheduling a notification", error?.localizedDescription ?? "")
            }
        }
    }
    
    func getAllPendingNotifications(completion: @escaping ([UNNotificationRequest]?) -> ()) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            return completion(requests)
        }
    }
    
    func cancelAllNotifications() {
        getAllPendingNotifications { requests in
            if let requests = requests {
                print("Cancelled Notification")
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: requests.map { $0.identifier })
            }
        }
    }
    
    func isAuthorized(completion: @escaping (Bool) -> ()) {
        getAuthorizationStatus { status in
            switch status {
            case .notDetermined:
                completion(false)
            case .authorized:
                completion(true)
            case .denied:
                completion(false)
            }
        }
    }
    
    func getAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> ()) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                completion(.notDetermined)
            case .authorized:
                completion(.authorized)
            case .denied:
                completion(.denied)
            }
        }
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Local notification received while app is opened", notification.request.content)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Did tap on the notification", response.notification.request.content)
        completionHandler()
    }
}




