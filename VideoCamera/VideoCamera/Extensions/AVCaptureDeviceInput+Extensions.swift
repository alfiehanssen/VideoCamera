//
//  AVCaptureDeviceInput+Extensions.swift
//  VideoCamera
//
//  Created by Alfred Hanssen on 2/25/17.
//  Copyright © 2017 Alfie Hanssen. All rights reserved.
//

import Foundation
import AVFoundation

extension AVCaptureDeviceInput
{
    static func micorphoneInput() throws -> AVCaptureDeviceInput
    {
        let device = try AVCaptureDevice.microphone()
        let input = try AVCaptureDeviceInput(device: device)
        
        return input
    }

    static func frontCameraInput() throws -> AVCaptureDeviceInput
    {
        let device = try AVCaptureDevice.frontCamera()
        let input = try AVCaptureDeviceInput(device: device)
        
        return input
    }

    static func backCameraInput() throws -> AVCaptureDeviceInput
    {
        let device = try AVCaptureDevice.backCamera()
        let input = try AVCaptureDeviceInput(device: device)
        
        return input
    }
}
