//
//  VideoCamera.swift
//  VideoCamera
//
//  Created by Alfred Hanssen on 2/25/17.
//  Copyright © 2017 Alfie Hanssen. All rights reserved.
//

import Foundation
import AVFoundation

protocol VideoCameraDelegate: class
{
    func captureOutputDidDrop(sampleBuffer: CMSampleBuffer)
    func captureOutputDidOutput(sampleBuffer: CMSampleBuffer)
}

class VideoCamera: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate
{
    let captureSession = AVCaptureSession()

    weak var delegate: VideoCameraDelegate?
    
    private var frontCameraInput: AVCaptureDeviceInput!
    private var backCameraInput: AVCaptureDeviceInput!

    private static let CaptureSessionQueue = DispatchQueue(label: "com.videocamera.capturesessionqueue", qos: .default) // TODO: Proper qos?
    private static let VideoDataOutputQueue = DispatchQueue(label: "com.videocamera.videodataoutputqueue", qos: .default) // TODO: Proper qos?
    
    override init()
    {
        super.init()
        
        self.addObservers()
    }
    
    deinit
    {
        self.removeObservers()
        self.stopRunning() // TODO: Will dispatching async in this function mean dispatching to a deallocated queue?
    }
    
    // MARK: - Public API

    func prepare(initialCameraPosition: AVCaptureDevicePosition, completion: @escaping ResultClosure)
    {
        __dispatch_assert_queue(DispatchQueue.main)
        
        VideoCamera.CaptureSessionQueue.async { [weak self] in
            guard let strongSelf = self else
            {
                return
            }
            
            do
            {
                try strongSelf.prepare(initialCameraPosition: initialCameraPosition)
                
                DispatchQueue.main.async {
                    completion(Result.success)
                }
            }
            catch let error
            {
                DispatchQueue.main.async {
                    completion(Result.failure(error: error))
                }
            }
        }
    }
    
    func startRunning()
    {
        __dispatch_assert_queue(DispatchQueue.main)
        
        VideoCamera.CaptureSessionQueue.async { [weak self] in
            guard let strongSelf = self else
            {
                return
            }
            
            guard !strongSelf.captureSession.isRunning else
            {
                return
            }
            
            strongSelf.captureSession.startRunning()
        }
    }

    func stopRunning()
    {
        __dispatch_assert_queue(DispatchQueue.main)
        
        VideoCamera.CaptureSessionQueue.async { [weak self] in
            guard let strongSelf = self else
            {
                return
            }
            
            guard strongSelf.captureSession.isRunning else
            {
                return
            }
            
            strongSelf.captureSession.stopRunning()
        }
    }
    
    func toggleCameraPosition(completion: @escaping ResultClosure)
    {
        __dispatch_assert_queue(DispatchQueue.main)
        
        VideoCamera.CaptureSessionQueue.async { [weak self] in
            guard let strongSelf = self else
            {
                return
            }
            
            do
            {
                if strongSelf.captureSession.containsInput(input: strongSelf.frontCameraInput)
                {
                    try strongSelf.activateCamera(position: .back)
                }
                else if strongSelf.captureSession.containsInput(input: strongSelf.backCameraInput)
                {
                    try strongSelf.activateCamera(position: .front)
                }
                else
                {
                    assertionFailure("Capture session inputs are misconfigured.")
                    throw VideoCameraError.misconfiguredInputs
                }
            }
            catch let error
            {
                DispatchQueue.main.async {
                    completion(Result.failure(error: error))
                }
            }
        }
    }
    
    // MARK: - Private API
    
    private func prepare(initialCameraPosition: AVCaptureDevicePosition) throws
    {
        __dispatch_assert_queue(VideoCamera.CaptureSessionQueue)
        
        let typeAudio = AVMediaTypeAudio
        guard AVCaptureDevice.authorizationStatus(forMediaType: typeAudio) == .authorized else
        {
            throw VideoCameraError.notAuthorized(forMediaType: typeAudio)
        }

        let typeVideo = AVMediaTypeVideo
        guard AVCaptureDevice.authorizationStatus(forMediaType: typeVideo) == .authorized else
        {
            throw VideoCameraError.notAuthorized(forMediaType: typeVideo)
        }
        
        self.captureSession.beginConfiguration()
        defer
        {
            self.captureSession.commitConfiguration()
        }

        try self.captureSession.setPreset(preset: AVCaptureSessionPresetHigh)
        
        let microphoneInput = try AVCaptureDeviceInput.micorphoneInput()
        try self.captureSession.addInput(input: microphoneInput)
        
        self.frontCameraInput = try AVCaptureDeviceInput.frontCameraInput()
        self.backCameraInput = try AVCaptureDeviceInput.backCameraInput()
        try self.activateCamera(position: initialCameraPosition)
        
        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.videoSettings = nil
        videoDataOutput.setSampleBufferDelegate(self, queue: VideoCamera.VideoDataOutputQueue)
        try self.captureSession.addOutput(output: videoDataOutput)
    }
    
    private func activateCamera(position: AVCaptureDevicePosition) throws
    {
        __dispatch_assert_queue(VideoCamera.CaptureSessionQueue)
        
        self.captureSession.beginConfiguration()
        defer
        {
            self.captureSession.commitConfiguration()
        }
        
        switch position
        {
        case .front:
            try self.captureSession.swapInputs(remove: self.backCameraInput, add: self.frontCameraInput)
        
        case .back:
            try self.captureSession.swapInputs(remove: self.frontCameraInput, add: self.backCameraInput)
            
        case .unspecified:
            assertionFailure("Attempt to switch to .unspecified device position.")
            throw VideoCameraError.inputPositionUnspecified
        }
    }

    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didDrop sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!)
    {
        VideoCamera.VideoDataOutputQueue.async { [weak self] in
            self?.delegate?.captureOutputDidDrop(sampleBuffer: sampleBuffer)
        }
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!)
    {
        VideoCamera.VideoDataOutputQueue.async { [weak self] in
            self?.delegate?.captureOutputDidOutput(sampleBuffer: sampleBuffer)
        }
    }
}

// TODO: Should this be a class instead of an extension?
extension VideoCamera
{
    // MARK: - Observers

    fileprivate func addObservers()
    {
        __dispatch_assert_queue(DispatchQueue.main) // TODO: We don't know that this is going to be invoked on the main thread.
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(VideoCamera.captureSessionRuntimeError(notification:)),
                                               name: .AVCaptureSessionRuntimeError,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(VideoCamera.captureSessionWasInterrupted(notification:)),
                                               name: .AVCaptureSessionWasInterrupted,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(VideoCamera.captureSessionInterruptionEnded(notification:)),
                                               name: .AVCaptureSessionInterruptionEnded,
                                               object: nil)
    }
    
    fileprivate func removeObservers()
    {
        __dispatch_assert_queue(DispatchQueue.main)
        
        NotificationCenter.default.removeObserver(self, name: .AVCaptureSessionRuntimeError, object: nil)
        NotificationCenter.default.removeObserver(self, name: .AVCaptureSessionWasInterrupted, object: nil)
        NotificationCenter.default.removeObserver(self, name: .AVCaptureSessionInterruptionEnded, object: nil)
    }
    
    func captureSessionRuntimeError(notification: Notification)
    {
        print("capture session runtime error")
    }
    
    // TODO: What happens if authorization is revoked mid capture?
    func captureSessionWasInterrupted(notification: Notification)
    {
        print("capture session was interrupted")
    }
    
    func captureSessionInterruptionEnded(notification: Notification)
    {
        print("capture session interruption ended")
    }
}

