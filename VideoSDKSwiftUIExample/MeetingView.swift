//
//  MeetingView.swift
//  VideoSDKSwiftUIExample
//
//  Created by Parth Asodariya on 20/04/23.
//

import SwiftUI
import VideoSDKRTC
import WebRTC


struct MeetingView: View{
    
    @ObservedObject var meetingViewController = MeetingViewController()
    
    var body: some View {
        VStack {
            if meetingViewController.participants.count == 0 {
                Text("Meeting Initializing")
            } else {
                VStack(spacing: 20) {
                    Text("Meeting ID: \(meetingViewController.meetingID)")
                    List {
                        ForEach(meetingViewController.participants.indices, id: \.self) { index in
                            ParticipantView(track: meetingViewController.participants[index].streams.first(where: { $1.kind == .state(value: .video) })?.value.track as? RTCVideoTrack).frame(height: 300)
                        }
                    }
                }
            }
        }.onAppear() {
            
            /// MARK :- configuring the videoSDK
            VideoSDK.config(token: meetingViewController.token)
            meetingViewController.joinRoom()
            /// Initializing the meeting
//            meetingViewController.initializeMeeting()
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
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 300)
        
        return view
    }()
    
    init(track: RTCVideoTrack?) {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 300))
        backgroundColor = .clear
        DispatchQueue.main.async {
            self.addSubview(self.videoView)
            self.bringSubviewToFront(self.videoView)
            track?.add(self.videoView)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// ParticipantView for showing and hiding VideoView
struct ParticipantView: UIViewRepresentable {
    var track: RTCVideoTrack?
    
    func makeUIView(context: Context) -> VideoView {
        let view = VideoView(track: track)
        view.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        return view
    }
    
    func updateUIView(_ uiView: VideoView, context: Context) {
        print("ui updated")
        if track != nil {
            track?.add(uiView.videoView)
        } else {
            track?.remove(uiView.videoView)
        }
    }
}


