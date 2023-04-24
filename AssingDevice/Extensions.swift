//
//  Extensions.swift
//  AssingDevice
//
//  Created by Vardhan Chopada on 4/23/23.
//

import UIKit
import AVFoundation
import Metal


public extension AVCaptureDevice {
    
    static func cameraMegapixel() -> Double? {
        let device = AVCaptureDevice.default(for: .video)
        guard let formatDescription = device?.activeFormat.formatDescription else {
            return nil
        }
        let dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription)
        let totalPixels = Double(dimensions.width * dimensions.height)
        let megapixels = (totalPixels / 1000000.0).rounded()
        return megapixels
    }
    
    static func cameraAperture() -> Double? {
        let device = AVCaptureDevice.default(for: .video)
        guard let currentAperture = device?.lensAperture else {
            return nil
        }
        return Double(currentAperture)
    }
    
}

public extension UIDevice {

    static func hardwareModel() -> String? {
            var size = 0
            sysctlbyname("hw.machine", nil, &size, nil, 0)
            var machine = [CChar](repeating: 0, count: size)
            sysctlbyname("hw.machine", &machine, &size, nil, 0)
            return String(cString: machine)
        }

    static func getGPUInfo() -> String? {
        let device = MTLCreateSystemDefaultDevice()
        return device?.name
    }
    
    
    static func getDeviceStorageInfo() -> (TotalStorage: Double, FreeStorage: Double)? {
        do {
            let systemAttributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String)
            if let TotalStorage = systemAttributes[FileAttributeKey.systemSize] as? Int64,
                let FreeStorage = systemAttributes[FileAttributeKey.systemFreeSize] as? Int64 {
                let totalSizeInGB = Double(TotalStorage) / 1_000_000_000
                let freeSizeInGB = Double(FreeStorage) / 1_000_000_000
                return (totalSizeInGB, freeSizeInGB)
            }
        } catch {
            print("Error getting storage information: \(error)")
        }
        return nil
    }

    static func getBatteryHealth() -> Int? {

        let device = UIDevice.current
        device.isBatteryMonitoringEnabled = true
          
        if device.batteryState == .unknown {
            print("None")
            return nil
        }
        
        let batteryHealth = device.batteryLevel
        return Int(batteryHealth * 100)
    }
    
    

}

