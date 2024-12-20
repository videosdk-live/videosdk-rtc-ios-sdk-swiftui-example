//
//  MeetingView.swift
//  VideoSDKSwiftUIExample
//
//  Created by Parth Asodariya on 20/04/23.
//

import SwiftUI
import VideoSDKRTC
import WebRTC

struct ParticipantContainerView: View {
    let participant: Participant
    // Add state object for camera preview
    @StateObject private var cameraPreview = CameraPreviewModel()

    @ObservedObject var meetingViewController: MeetingViewController
    
    var body: some View {
        ZStack {
            // Main participant view
            participantView(participant: participant, meetingViewController: meetingViewController)
            
            // Overlay for name and mic status
            VStack {
                Spacer()
                HStack {

                    // Participant name
                    Text(participant.displayName)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(4)
                    
                    // Mic status indicator
                    Image(systemName: meetingViewController.participantMicStatus[participant.id] ?? false ? "mic.fill" : "mic.slash.fill")
                        .foregroundColor(meetingViewController.participantMicStatus[participant.id] ?? false ? .green : .red)
                        .padding(4)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())

                    
                    Spacer()
                }
                .padding(8)
            }
        }
        // Add border, background, shadow, and rounded corners
        .background(Color.black.opacity(0.9)) // Background color
        .cornerRadius(10) // Rounded corners
        .shadow(color: Color.gray.opacity(0.7), radius: 10, x: 0, y: 5) // Shadow effect
        .overlay(
            RoundedRectangle(cornerRadius: 10) // Rounded border
                .stroke(Color.gray.opacity(0.9), lineWidth: 1)
        )

    }
    
    private func participantView(participant: Participant, meetingViewController: MeetingViewController) -> some View {
        ZStack {
            ParticipantView(participant: participant, meetingViewController: meetingViewController)
        }
    }
}

struct MeetingView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var meetingViewController: MeetingViewController
    
    @State var meetingId: String?
    @State var userName: String?
    @State var isUnMute: Bool = true
    @State var camEnabled: Bool = true
    @State var isScreenShare: Bool = false
    
    var body: some View {
        VStack {
            if meetingViewController.participants.count == 0 {
                Text("Meeting Initializing")
            } else {
                VStack {
                    Text("Meeting ID: \(meetingViewController.meetingID)")
                        .padding(.vertical)
                    
                    GeometryReader { geometry in
                        VStack(spacing: 0) {
                            let totalParticipants = meetingViewController.participants.count
                            
                            switch totalParticipants {
                            case 1:
                                ParticipantContainerView(
                                    participant: meetingViewController.participants[0],
                                    meetingViewController: meetingViewController
                                )
                                .frame(width: geometry.size.width, height: geometry.size.height)

                            case 2:
                                VStack(spacing: 0) {
                                    ForEach(0..<2) { index in
                                        ParticipantContainerView(
                                            participant: meetingViewController.participants[index],
                                            meetingViewController: meetingViewController
                                        )
                                        .frame(width: geometry.size.width, height: geometry.size.height / 2)
                                    }
                                }
                            
                            case 3:
                                VStack(spacing: 0) {
                                    HStack(spacing: 0) {
                                        ForEach(0..<2) { index in
                                            ParticipantContainerView(
                                                participant: meetingViewController.participants[index],
                                                meetingViewController: meetingViewController
                                            )
                                            .frame(width: geometry.size.width / 2, height: geometry.size.height / 2)
                                        }
                                    }
                                    ParticipantContainerView(
                                        participant: meetingViewController.participants[2],
                                        meetingViewController: meetingViewController
                                    )
                                    .frame(width: geometry.size.width, height: geometry.size.height / 2)
                                }
                                
                            case 4:
                                VStack(spacing: 0) {
                                    HStack(spacing: 0) {
                                        ForEach(0..<2) { index in
                                            ParticipantContainerView(
                                                participant: meetingViewController.participants[index],
                                                meetingViewController: meetingViewController
                                            )
                                            .frame(width: geometry.size.width / 2, height: geometry.size.height / 2)
                                        }
                                    }
                                    HStack(spacing: 0) {
                                        ForEach(2..<4) { index in
                                            ParticipantContainerView(
                                                participant: meetingViewController.participants[index],
                                                meetingViewController: meetingViewController
                                            )
                                            .frame(width: geometry.size.width / 2, height: geometry.size.height / 2)
                                        }
                                    }
                                }
                            
                            case 5:
                                VStack(spacing: 0) {
                                    HStack(spacing: 0) {
                                        ForEach(0..<2) { index in
                                            ParticipantContainerView(
                                                participant: meetingViewController.participants[index],
                                                meetingViewController: meetingViewController
                                            )
                                            .frame(width: geometry.size.width / 2, height: geometry.size.height / 3)
                                        }
                                    }
                                    ParticipantContainerView(
                                        participant: meetingViewController.participants[2],
                                        meetingViewController: meetingViewController
                                    )
                                    .frame(width: geometry.size.width, height: geometry.size.height / 3)
                                    HStack(spacing: 0) {
                                        ForEach(3..<5) { index in
                                            ParticipantContainerView(
                                                participant: meetingViewController.participants[index],
                                                meetingViewController: meetingViewController
                                            )
                                            .frame(width: geometry.size.width / 2, height: geometry.size.height / 3)
                                        }
                                    }
                                }
                                
                            default:
                                ScrollView {
                                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 0) {
                                        ForEach(meetingViewController.participants.indices, id: \.self) { index in
                                            ParticipantContainerView(
                                                participant: meetingViewController.participants[index],
                                                meetingViewController: meetingViewController
                                            )
                                            .frame(height: geometry.size.height / 3)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Control buttons
                    VStack {
                        HStack(spacing: 15) {
                            Button {
                                isUnMute.toggle()
                                isUnMute ? meetingViewController.meeting?.unmuteMic(): meetingViewController.meeting?.muteMic()
                                
                            } label: {
                                Text("Toggle Mic")
                                    .foregroundStyle(Color.white)
                                    .font(.caption)
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 25).fill(Color.blue))
                            }
                            
                            Button {
                                camEnabled.toggle()
                                camEnabled ? meetingViewController.meeting?.enableWebcam() : meetingViewController.meeting?.disableWebcam()
                            } label: {
                                Text("Toggle WebCam")
                                    .foregroundStyle(Color.white)
                                    .font(.caption)
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 25).fill(Color.blue))
                            }
                        }
                        
                        HStack {
                            Button {
                                isScreenShare.toggle()
                                Task {
                                    if isScreenShare {
                                        await meetingViewController.meeting?.enableScreenShare()
                                    } else {
                                        await meetingViewController.meeting?.disableScreenShare()
                                    }
                                }
                            } label: {
                                Text("Toggle ScreenShare")
                                    .foregroundStyle(Color.white)
                                    .font(.caption)
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 25).fill(Color.blue))
                            }
                            
                            Button {
                                meetingViewController.meeting?.end()
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                Text("End Call")
                                    .foregroundStyle(Color.white)
                                    .font(.caption)
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 25).fill(Color.red))
                            }
                            
                            Button {
                                meetingViewController.meeting?.leave()
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                Text("leave Call")
                                    .foregroundStyle(Color.white)
                                    .font(.caption)
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 25).fill(Color.indigo))
                            }
                        }
                        .padding(.bottom)
                    }
                }
            }
        }
        .onAppear {
            VideoSDK.config(token: meetingViewController.token)
            if let meetingId = meetingId, !meetingId.isEmpty {
                meetingViewController.joinMeeting(meetingId: meetingId, userName: userName!)
            } else {
                meetingViewController.joinRoom(userName: userName!)
            }
        }
    }
}

/// VideoView for participant's video
class VideoView: UIView {
    var videoView: RTCMTLVideoView = {
        let view = RTCMTLVideoView()
        view.videoContentMode = .scaleAspectFill
        view.backgroundColor = UIColor.black
        view.clipsToBounds = true
        view.transform = CGAffineTransform(scaleX: 1, y: 1)

        return view
    }()
    
    init(track: RTCVideoTrack?, frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        
        // Set videoView frame to match parent view
        videoView.frame = bounds
        
        DispatchQueue.main.async {
            self.addSubview(self.videoView)
            self.bringSubviewToFront(self.videoView)
            track?.add(self.videoView)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Update videoView frame when parent view size changes
        videoView.frame = bounds
    }
}

/// ParticipantView for showing and hiding VideoView
struct ParticipantView: View {
    let participant: Participant
    @ObservedObject var meetingViewController: MeetingViewController
    
    var body: some View {
        ZStack {
            if let track = meetingViewController.participantVideoTracks[participant.id] {
                VideoStreamView(track: track)
            } else {
                Color.white.opacity(1.0)
                Text("No media")
            }
        }
    }
}

struct VideoStreamView: UIViewRepresentable {
    let track: RTCVideoTrack
    
    func makeUIView(context: Context) -> VideoView {
        let view = VideoView(track: track, frame: .zero)
        return view
    }
    
    func updateUIView(_ uiView: VideoView, context: Context) {
        track.add(uiView.videoView)
    }
}
