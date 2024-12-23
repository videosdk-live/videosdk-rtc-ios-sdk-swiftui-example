//
//  CameraPreviewModel.swift
//  VideoSDKSwiftUIExample
//
//  Created by Deep Bhupatkar on 20/12/24.
//


import Foundation
import AVFoundation

class CameraPreviewModel: ObservableObject {
    @Published var session = AVCaptureSession()
    private var videoDeviceInput: AVCaptureDeviceInput?
    private var currentCameraPosition: AVCaptureDevice.Position = .front // Track the current camera position

    func checkPermissionsAndSetupSession() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCaptureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.setupCaptureSession()
                    }
                }
            }
        default:
            print("Camera access denied or restricted.")
        }
    }

    private func setupCaptureSession() {
        session.beginConfiguration()
        
        // Video setup
        let videoPosition: AVCaptureDevice.Position = currentCameraPosition
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                        for: .video,
                                                        position: videoPosition) else {
            session.commitConfiguration()
            return
        }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
                self.videoDeviceInput = videoInput
            } else {
            }
        } catch {
        }
        
        session.commitConfiguration()
    }

    func flipCamera() {
        guard let currentInput = videoDeviceInput else { return }
        
        // Toggle between front and back camera
        currentCameraPosition = currentCameraPosition == .front ? .back : .front
        
        let newPosition: AVCaptureDevice.Position = currentCameraPosition
        guard let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                      for: .video,
                                                      position: newPosition) else {
            return
        }
        
        session.beginConfiguration()
        session.removeInput(currentInput)
        
        do {
            let newVideoInput = try AVCaptureDeviceInput(device: newDevice)
            if session.canAddInput(newVideoInput) {
                session.addInput(newVideoInput)
                self.videoDeviceInput = newVideoInput
            } else {
            }
        } catch {
        }
        
        session.commitConfiguration()
    }

    func startSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
        }
    }

    func stopSession() {
        DispatchQueue.main.async { [weak self] in
            if let session = self?.session, session.isRunning {
                session.stopRunning()
            } else {
            }
        }
    }
}

