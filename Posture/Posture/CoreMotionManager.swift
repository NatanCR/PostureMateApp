//
//  CoreMotionManager.swift
//  Posture
//
//  Created by Natan Camargo Rodrigues on 12/1/2025.
//
//TODO: Add improvements - 5s before message ; vibration feedback ; personalized angles
import Foundation
import CoreMotion
import UIKit

class CoreMotionManager: ObservableObject {
    static let shared = CoreMotionManager()
    private let motionManager: CMMotionManager
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
    private var movementCheckTimer: Timer?
    
    init() {
        self.motionManager = CMMotionManager()
        self.motionManager.deviceMotionUpdateInterval = 1.0 // 1 update per second
    }
    
    func startUpdates() {
        registerBackgroundTask()
        
        let queue = OperationQueue()
        motionManager.startDeviceMotionUpdates(to: queue) { [weak self] (data, error) in
            guard let self = self else { return }
            print("Device motion updated")
            
            if let error = error {
                //TODO: deal with error
                dump("Motion update Error: \(error.localizedDescription)")
                return
            }
            
            if let data = data {
                print("Processing motion data...")
                self.processMotionData(data)
            }
        }
    }
    
    func stopUpdates() {
        movementCheckTimer?.invalidate()
        motionManager.stopDeviceMotionUpdates()
        endBackgroundTask()
    }
    
    private func processMotionData(_ data: CMDeviceMotion) {
        let isStationary = isUserStationary(acceleration: data.userAcceleration)
        if isStationary {
            print("User is Stationary! ⛔️")
            handleStationaryUser()
        } else {
            print("User is moving, pausing tracking... ⚠️")
            handleMovingUser()
        }
    }
    
    private func isUserStationary(acceleration: CMAcceleration) -> Bool {
        let threshold: Double = 0.02
        return abs(acceleration.x) < threshold &&
               abs(acceleration.y) < threshold &&
               abs(acceleration.z) < threshold
    }
    
    private func handleMovingUser() {
        stopUpdates()
        scheduleMotionReactivation()
    }
    
    private func scheduleMotionReactivation() { 
        movementCheckTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: false) { [weak self] _ in
            guard let self = self else { print("⚠️ Motion manager was deallocated before reactivation. Timer stopped."); return } //TODO: deal with timer returning
            print("Timer starting background motion updates...")
            self.startUpdates()
        }
    }
    
    private func handleStationaryUser() {
        guard let motion = motionManager.deviceMotion else { print("⚠️ No motion data available"); return }
        
        let angles = getDeviceAngles(motion: motion)
        
        if angles != nil {
            if let postureWarningMessage = checkPosture(pitch: angles!.pitch, roll: angles!.roll) {
                print("❌ Bad posture detected. Sending correction notification...")
                MonitorManager.shared.sendPostureNotification(message: postureWarningMessage)
            } else {
                print("✅ Good posture detected. Sending positive notification...")
                MonitorManager.shared.sendPostureNotification(message: "You posture is correct! Keep it up! 💪")
            }
        }
    }
    
    private func getDeviceAngles(motion: CMDeviceMotion) -> (pitch: Double, roll: Double, yaw: Double)? {
        let pitch = motion.attitude.pitch * 180 / .pi // Front-to-back inclination
        let roll = motion.attitude.roll   * 180 / .pi // Side inclination
        let yaw = motion.attitude.yaw     * 180 / .pi // Rotation around the vertical axis
        dump("📐 Device Angles - Pitch: \(pitch), Roll: \(roll), Yaw: \(yaw)")
        return (pitch, roll, yaw)
    }

    private func checkPosture(pitch: Double, roll: Double) -> String? {
        switch (pitch, roll) {
        case let (p, _) where p < -10:
            return "Your phone is too tilted forward! 📉"
        case let (p, _) where p > 20:
            return "Your phone is too tilted backward! 📈"
        case let (_, r) where r < -15:
            return "Your phone is tilted to the left! ⬅️"
        case let (_, r) where r > 15:
            return "Your phone is tilted to the right! ➡️"
        default:
            return nil // Returns nil if posture is correct
        }
    }
    
    private func registerBackgroundTask() {
        backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "CoreMotionBackgroundTask") {
            // End task if times finish
            UIApplication.shared.endBackgroundTask(self.backgroundTaskID)
            self.backgroundTaskID = .invalid
        }
    }
    
    private func endBackgroundTask() {
        if backgroundTaskID != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = .invalid
        }
    }
}
