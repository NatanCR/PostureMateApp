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
}
