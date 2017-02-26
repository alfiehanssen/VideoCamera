//
//  AVCaptureSession+Extensions.swift
//  VideoCamera
//
//  Created by Alfred Hanssen on 2/25/17.
//  Copyright © 2017 Alfie Hanssen. All rights reserved.
//

import Foundation
import AVFoundation

extension AVCaptureSession
{
    func setPreset(preset: String) throws
    {
        guard self.canSetSessionPreset(preset) else
        {
            throw VideoCameraError.cannotSetPreset(preset: preset)
        }
        
        self.sessionPreset = preset
    }
    
    func containsInput(input: AVCaptureDeviceInput) -> Bool
    {
        return self.inputs.contains(where: { (currentInput) -> Bool in
            return (currentInput as? AVCaptureDeviceInput) == input
        })
    }
    
    func addInput(input: AVCaptureDeviceInput) throws
    {
        guard self.canAddInput(input) else
        {
            throw VideoCameraError.cannotAddInput(input: input)
        }
        
        self.addInput(input)
    }
    
    func addOutput(output: AVCaptureOutput) throws
    {
        guard self.canAddOutput(output) else
        {
            throw VideoCameraError.cannotAddOutput(output: output)
        }
        
        self.addOutput(output)
    }
    
    func swapInputs(remove: AVCaptureDeviceInput, add: AVCaptureDeviceInput) throws
    {
        self.removeInput(remove)
        try self.addInput(input: add)
    }
}
