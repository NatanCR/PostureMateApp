//
//  CoreMotionManager.swift
//  Posture
//
//  Created by Natan Camargo Rodrigues on 12/1/2025.
//

import Foundation
import CoreMotion
import UIKit

class CoreMotionManager: ObservableObject {
    
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
        motionManager.stopDeviceMotionUpdates()
        endBackgroundTask()
    }
    
    private func processMotionData(_ data: CMDeviceMotion) {
        let isStationary = isUserStationary(acceleration: data.userAcceleration)
        if isStationary {
            print("User is Stationary")
            //handleStationaryUser()
        } else {
            print("User is Moving, pausing tracking...")
            handleMovingUser()
        }
    }
    
    func isUserStationary(acceleration: CMAcceleration) -> Bool {
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
        movementCheckTimer?.invalidate() //not duplicated timers
        
        movementCheckTimer = Timer.scheduledTimer(withTimeInterval: 90, repeats: false) { [weak self] _ in
            guard let self = self else { print("⚠️ Motion manager was deallocated before reactivation. Timer stopped."); return } //TODO: deal with returning
            print("Timer starting background motion updates...")
            self.startUpdates()
        }
    }
    
//    func trackDeviceMotion(motion: CMDeviceMotion) -> (pitch: Double, roll: Double, yaw: Double)? {
//        if let attitude = motionManager.deviceMotion?.attitude {
//            let pitch = attitude.pitch * 180 / .pi // Front-to-back inclination
//            let roll = attitude.roll   * 180 / .pi // Side inclination
//            let yaw = attitude.yaw     * 180 / .pi // Rotation around the vertical axis
//            dump("Pitch: \(pitch); Roll: \(roll); Yaw: \(yaw)")
//            return (pitch, roll, yaw)
//        }
//        return nil
//    }
    
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
