//
//  ViewController.swift
//  VideoCamera
//
//  Created by Alfred Hanssen on 2/25/17.
//  Copyright © 2017 Alfie Hanssen. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController
{
    @IBOutlet weak var swapButton: UIButton!
    
    private let camera = VideoCamera()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    
        guard let previewLayer = AVCaptureVideoPreviewLayer(session: self.camera.captureSession) else
        {
            assertionFailure("Unable to create preview layer.")
            
            return
        }
        
        previewLayer.frame = self.view.bounds
        self.view.layer.insertSublayer(previewLayer, at: 0)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        // TODO: Handle authorization better.
        
        self.authorize(mediaType: AVMediaTypeAudio)
        self.authorize(mediaType: AVMediaTypeVideo)
        
        // TODO: Don't prepare more than once.
    
        self.camera.prepare(initialCameraPosition: .back) { (result) in
            switch result
            {
            case .success:
                self.camera.startRunning()
                
            case .failure(error: let error):
                print(error)
            }
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Private API
    
    private func authorize(mediaType: String)
    {
        switch AVCaptureDevice.authorizationStatus(forMediaType: mediaType)
        {
        case .authorized:
            break
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(forMediaType: mediaType, completionHandler: { (accessGranted) in
                if !accessGranted
                {
                    print("Go to settings and authorize \(mediaType).")
                }
            })
        case .denied, .restricted:
            print("Go to settings and authorize \(mediaType).")
        }
    }
    
    // MARK: - Actions
    
    @IBAction func didTapSwap(sender: UIButton)
    {
        self.camera.toggleCameraPosition { (result) in
            switch result
            {
            case .success:
                break
                
            case .failure(error: let error):
                print(error)
            }
        }
    }
}

