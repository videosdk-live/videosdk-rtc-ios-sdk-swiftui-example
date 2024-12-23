//
//  StartView.swift
//  VideoSDKSwiftUIExample
//
//  Created by Uday Gajera on 25/04/24.
//

import SwiftUI
import Foundation
import VideoSDKRTC
import AVFoundation

struct StartView: View {
    @State var meetingId: String
    @State var name: String
    @State private var isMicEnabled: Bool = true
    @State private var isFrontCamera: Bool = true
    @StateObject private var cameraPreview = CameraPreviewModel()
    @State private var showActionSheet = false
    @State private var audioDeviceList: [String] = []
    @State private var selectedCameraMode: AVCaptureDevice.Position = .front
    @State private var selectedAudioDevice: String?
    @State private var isNavigating = false
    @State private var isCameraEnabled: Bool = true
    
    // Colors and constants
    private let accentColor = Color(red: 0.2, green: 0.5, blue: 1.0)
    private let backgroundColor = Color(red: 0.98, green: 0.98, blue: 0.98)
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [backgroundColor, Color.white]),
                    startPoint: .top,
                    endPoint: .bottom
                ).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Text("VideoSDK")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(accentColor)
                            Text("Swift UI Quickstart")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 25)
                        
                        //Precall View and Controlls for that
                        ZStack {
                            VStack {
                                // Camera Preview
                                GeometryReader { geometry in
                                    ZStack {
                                        CameraPreviewView(session: cameraPreview.session)
                                            .frame(height: 220)
                                            .cornerRadius(16)
                                            .overlay(
                                                Group {
                                                    if !isCameraEnabled {
                                                        ZStack {
                                                            Color.black.opacity(2.0)
                                                        }
                                                        .cornerRadius(16)
                                                    }
                                                }
                                            )
                                        
                                        VStack {
                                            Spacer()
                                            
                                            // Bottom controls row
                                            HStack {
                                                // Microphone Button
                                                Button(action: {
                                                    fetchAudioDevices()
                                                    showActionSheet.toggle()
                                                }) {
                                                    Image(systemName: isMicEnabled ? "mic.fill" : "mic.slash.fill")
                                                        .foregroundColor(.white)
                                                        .padding(11)
                                                        .background(Circle().fill(Color.black.opacity(0.6)))
                                                }
                                                
                                                Spacer()
                                                if isCameraEnabled {
                                                    Button(action: {
                                                        isFrontCamera.toggle()
                                                        cameraPreview.flipCamera()
                                                        selectedCameraMode = (selectedCameraMode == .front) ? .back : .front
                                                    }) {
                                                        Image(systemName: "camera.rotate.fill")
                                                            .foregroundColor(.white)
                                                            .padding(11)
                                                            .background(Circle().fill(Color.black.opacity(0.6)))
                                                    }
                                                } else {
                                                    Color.clear
                                                        .frame(width: 44, height: 44)
                                                }
                                    
                                                Spacer()
                                                
                                                // Camera Toggle Button
                                                Button(action: {
                                                    isCameraEnabled.toggle()
                                                    if isCameraEnabled {
                                                        cameraPreview.startSession()
                                                    } else {
                                                        cameraPreview.stopSession()
                                                    }
                                                }) {
                                                    Image(systemName: isCameraEnabled ? "video.fill" : "video.slash.fill")
                                                        .foregroundColor(.white)
                                                        .padding(11)
                                                        .background(Circle().fill(Color.black.opacity(0.6)))
                                                }
                                            }
                                            .padding(.horizontal)
                                            .padding(.bottom, 5)
                                        }
                                    }
                                }
                            }
                            .padding()
                        }
                        .frame(width: 300, height: 250) // Set desired width here
                        .padding(.horizontal)

                        // Input Fields
                        VStack(spacing: 16) {
                            // Meeting ID Field
                            CustomTextField(
                                text: $meetingId,
                                placeholder: "Enter Meeting ID",
                                systemImage: "number"
                            )
                            
                            // Name Field
                            CustomTextField(
                                text: $name,
                                placeholder: "Enter Your Name",
                                systemImage: "person"
                            )
                        }
                        .padding(.horizontal)
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            if !meetingId.isEmpty {
                                NavigationLink(
                                    destination: MeetingView(
                                        meetingViewController: MeetingViewController(
                                            cameraMode: selectedCameraMode,
                                            audioDevice: selectedAudioDevice
                                        ),
                                        meetingId: meetingId,
                                        userName: name.isEmpty ? "Guest" : name
                                    )
                                    .navigationBarBackButtonHidden(true),
                                    isActive: $isNavigating
                                ) {
                                    ActionButton(title: "Join Meeting", color: accentColor)
                                }
                            }
                            
                            NavigationLink(
                                destination: MeetingView(
                                    meetingViewController: MeetingViewController(
                                        cameraMode: selectedCameraMode,
                                        audioDevice: selectedAudioDevice
                                    ),
                                    userName: name.isEmpty ? "Guest" : name
                                )
                                .navigationBarBackButtonHidden(true)
                            ) {
                                ActionButton(title: "Start Meeting", color: .indigo)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 32)
                }
            }
            .actionSheet(isPresented: $showActionSheet) {
                ActionSheet(
                    title: Text("Select Audio Device"),
                    message: Text(selectedAudioDevice ?? "No device selected"),
                    buttons: buildDeviceButtons()
                )
            }
            .onAppear {
                cameraPreview.checkPermissionsAndSetupSession()
                isCameraEnabled = false
             

            }
            .onChange(of: isNavigating) { newValue in
                if newValue {
                    cameraPreview.stopSession()
                    
                }
            }
            .onDisappear {
                cameraPreview.stopSession()
            }
        }
    }
    
    private func fetchAudioDevices() {
        audioDeviceList = VideoSDK.getAudioDevices()
    }
    
    private func buildDeviceButtons() -> [ActionSheet.Button] {
        var buttons = audioDeviceList.map { device in
            ActionSheet.Button.default(
                Text("\(device)\(selectedAudioDevice == device ? " ✓" : "")")
            ) {
                selectedAudioDevice = device
            }
        }
        buttons.append(.cancel(Text("Cancel")))
        return buttons
    }

}

#Preview {
    StartView(meetingId: "", name: "")
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
