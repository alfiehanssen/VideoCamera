//
//  VideoCameraError.swift
//  VideoCamera
//
//  Created by Alfred Hanssen on 2/25/17.
//  Copyright © 2017 Alfie Hanssen. All rights reserved.
//

import Foundation
import AVFoundation

enum VideoCameraError: Error
{
    case notAuthorized(forMediaType: String)
    case cannotSetPreset(preset: String)
    case cannotAddInput(input: AVCaptureDeviceInput)
    case cannotAddOutput(output: AVCaptureOutput)
    case misconfiguredInputs
    case inputPositionUnspecified
    case discoverySessionFoundNoEligibleDevices
}

