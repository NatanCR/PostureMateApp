//
//  CoreMotionManager.swift
//  Posture
//
//  Created by Natan Camargo Rodrigues on 12/1/2025.
//

import Foundation
import CoreMotion

class CoreMotionManager: ObservableObject {
    
    private let motionManager: CMMotionManager
    
    init() {
        self.motionManager = CMMotionManager()
    }
    
    func startUpdates() {
        motionManager.startDeviceMotionUpdates()
    }
    
    func stopUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
    
    func trackUserAcceleration() -> Bool {
        if let acceleration = motionManager.deviceMotion?.userAcceleration {
            let threshold: Double = 0.02
            let isStationary = abs(acceleration.x) < threshold &&
                               abs(acceleration.y) < threshold &&
                               abs(acceleration.z) < threshold
            if isStationary {
                dump("User is stationary")
                dump(acceleration)
                return true
            }
        }
        return false
    }
    
    func trackDeviceMotion() -> (pitch: Double, roll: Double, yaw: Double)? {
        if let attitude = motionManager.deviceMotion?.attitude {
            let pitch = attitude.pitch * 180 / .pi // Front-to-back inclination
            let roll = attitude.roll   * 180 / .pi // Side inclination
            let yaw = attitude.yaw     * 180 / .pi // Rotation around the vertical axis
            dump("Pitch: \(pitch); Roll: \(roll); Yaw: \(yaw)")
            return (pitch, roll, yaw)
        }
        return nil
    }
}
