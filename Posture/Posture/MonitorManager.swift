//
//  MonitorManager.swift
//  Posture
//
//  Created by Natan Camargo Rodrigues on 2/2/2025.
//

//Register system notifications
//Ask permissions for user
//Call CoreMotionManager

import Foundation
import UIKit
import UserNotifications

class MonitorManager {
    static let shared = MonitorManager() //singleton for global access
    
    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(screenDidTurnOn), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(screenDidTurnOff), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    @objc private func screenDidTurnOn() {
        print("🔆 Screen turned ON (Registered in MonitorManager)")
        CoreMotionManager.shared.startUpdates()
    }
    
    @objc private func screenDidTurnOff() {
        print("🌑 Screen turned OFF! (Registered in MonitorManager)")
        CoreMotionManager.shared.stopUpdates()
    }
    
    func sendPostureNotification(message: String) {
        let content = UNMutableNotificationContent()
        content.title = "Posture Alert!"
        content.body = message
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                dump("❌ Notification Error: \(error.localizedDescription)")
            } else {
                dump("🔔 Notification Sent: \(message)")
            }
        }
    }
}
