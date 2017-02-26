//
//  ViewController.swift
//  Demo-iOS
//
//  Created by Alfred Hanssen on 2/25/17.
//  Copyright © 2017 Alfie Hanssen. All rights reserved.
//

import UIKit
import AVFoundation
import VideoCamera

typealias AuthorizationClosure = (_ accessGranted: Bool) -> Void

class ViewController: UIViewController
{
    @IBOutlet weak var swapButton: UIButton!
    
    private let camera = Camera()
    
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
                
        self.authorize(mediaType: AVMediaTypeAudio) { (accessGranted) in
            guard accessGranted else
            {
                print("Go to settings and grant access to the microphone.")
                
                return
            }
            
            self.authorize(mediaType: AVMediaTypeVideo) { (accessGranted) in
                guard accessGranted else
                {
                    print("Go to settings and grant access to the camera.")
                    
                    return
                }
                
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
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Private API
    
    private func authorize(mediaType: String, completion: @escaping AuthorizationClosure)
    {
        switch AVCaptureDevice.authorizationStatus(forMediaType: mediaType)
        {
        case .authorized:
            completion(true)
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(forMediaType: mediaType, completionHandler: { (accessGranted) in
                completion(accessGranted)
            })
        case .denied, .restricted:
            completion(false)
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

