//
//  AVCaptureDevice+Extensions.swift
//  VideoCamera
//
//  Created by Alfred Hanssen on 2/25/17.
//  Copyright © 2017 Alfie Hanssen. All rights reserved.
//

import Foundation
import AVFoundation

extension AVCaptureDevice
{
    private static let AudioDeviceTypes: [AVCaptureDeviceType] = [.builtInMicrophone]
    private static let VideoDeviceTypes: [AVCaptureDeviceType] = [.builtInDuoCamera, .builtInTelephotoCamera, .builtInWideAngleCamera]
    // TODO: Will more than one device ever be returned if we always specify a camera position? e.g. front / back.
    
    static func microphone() throws -> AVCaptureDevice
    {
        return try AVCaptureDevice.device(deviceTypes: AVCaptureDevice.AudioDeviceTypes, mediaType: AVMediaTypeAudio, position: .unspecified)
    }

    static func frontCamera() throws -> AVCaptureDevice
    {
        return try AVCaptureDevice.device(deviceTypes: AVCaptureDevice.VideoDeviceTypes, mediaType: AVMediaTypeVideo, position: .front)
    }

    static func backCamera() throws -> AVCaptureDevice
    {
        return try AVCaptureDevice.device(deviceTypes: AVCaptureDevice.VideoDeviceTypes, mediaType: AVMediaTypeVideo, position: .back)
    }

    private static func device(deviceTypes: [AVCaptureDeviceType], mediaType: String, position: AVCaptureDevicePosition) throws -> AVCaptureDevice
    {
        let discoverySession = AVCaptureDeviceDiscoverySession(deviceTypes: deviceTypes, mediaType: mediaType, position: position)
        
        guard let device = discoverySession?.devices.first else
        {
            throw VideoCameraError.discoverySessionFoundNoEligibleDevices
        }
        
        return device
    }
}
