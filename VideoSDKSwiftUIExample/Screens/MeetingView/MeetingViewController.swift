//
//  MeetingViewController.swift
//  VideoSDKSwiftUIExample
//
//  Created by Parth Asodariya on 21/04/23.
//

import Foundation
import VideoSDKRTC
import WebRTC
import SwiftUI

class MeetingViewController: ObservableObject {
    
    var token = "Your_Token"
    var meetingId: String = ""
    var name: String = ""
    var cameraMode: AVCaptureDevice.Position
    var audioDevice: String?

    @Published var meeting: Meeting? = nil
    @Published var localParticipantView: VideoView? = nil
    @Published var participants: [Participant] = []
    @Published var meetingID: String = ""
    @Published var participantVideoTracks: [String: RTCVideoTrack] = [:]
    @Published var participantMic : Bool = false
    @Published var participantMicStatus: [String: Bool] = [:]

    init(cameraMode: AVCaptureDevice.Position , audioDevice: String?) {
         self.cameraMode = cameraMode
         self.audioDevice = audioDevice
     }


    func initializeMeeting(meetingId: String, userName: String) {
        // Initialize the meeting
        var videoMediaTrack = try? VideoSDK.createCameraVideoTrack(
            encoderConfig: .h720p_w1280p,
            facingMode: cameraMode,
            multiStream: false
        )
        meeting = VideoSDK.initMeeting(
            meetingId: meetingId,
            participantName: userName,
            micEnabled: true,
            webcamEnabled: true,
            customCameraVideoStream: videoMediaTrack
//            multiStream: true

        )
        // Add event listeners and join the meeting
        meeting?.addEventListener(self)
        meeting?.join()

    }
    
    func forPrecallAudioDeviceSetup()
    {
        if let audio = audioDevice {
            meeting?.changeMic(selectedDevice: audio)
        }
    }

}

extension MeetingViewController: MeetingEventListener {
    func onMeetingJoined() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.forPrecallAudioDeviceSetup()
        }
        guard let localParticipant = self.meeting?.localParticipant else { return }
        
        // add to list
        participants.append(localParticipant)
        
        // add event listener
        localParticipant.addEventListener(self)
        
        localParticipant.setQuality(.high)

    }
    
    func onParticipantJoined(_ participant: Participant) {
        
        participants.append(participant)
        
        // add listener
        participant.addEventListener(self)
        
        participant.setQuality(.high)
    }
    
    func onParticipantLeft(_ participant: Participant) {
        participants = participants.filter({ $0.id != participant.id })
    }
    
    func onMeetingLeft() {

        meeting?.localParticipant.removeEventListener(self)
        meeting?.removeEventListener(self)
        participants.removeAll()
    }
    func onMeetingStateChanged(meetingState: MeetingState) {
        switch meetingState {

        case .CLOSED:
            participants.removeAll()
            
        default:
            print("")
        }
    }
}

extension MeetingViewController: ParticipantEventListener {
    func onStreamEnabled(_ stream: MediaStream, forParticipant participant: Participant) {
        if let track = stream.track as? RTCVideoTrack {
            DispatchQueue.main.async {
                if case .state(let mediaKind) = stream.kind, mediaKind == .video {
                    self.participantVideoTracks[participant.id] = track
                }
            }
        }
        
        if case .state(let mediaKind) = stream.kind, mediaKind == .audio {
            self.participantMicStatus[participant.id] = true // Mic enabled
        }
    }

    func onStreamDisabled(_ stream: MediaStream, forParticipant participant: Participant) {
        DispatchQueue.main.async {
            if case .state(let mediaKind) = stream.kind, mediaKind == .video {
                self.participantVideoTracks.removeValue(forKey: participant.id)
            }
        }
        if case .state(let mediaKind) = stream.kind, mediaKind == .audio {
            // Update microphone state for this participant
            self.participantMicStatus[participant.id] = false // Mic disabled

        }
    }
}

extension MeetingViewController {
    
    func joinRoom(userName: String) {
        
        let urlString = "https://api.videosdk.live/v2/rooms"
        let session = URLSession.shared
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(self.token, forHTTPHeaderField: "Authorization")
        
        session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
         
            if let data = data, let utf8Text = String(data: data, encoding: .utf8)
            {
                do{
                    let dataArray = try JSONDecoder().decode(RoomsStruct.self,from: data)
                    DispatchQueue.main.async {
                        print(dataArray.roomID)
                        self.meetingID = dataArray.roomID!
                        self.joinMeeting(meetingId: dataArray.roomID!, userName: userName)
                    }
                    print(dataArray)
                } catch {
                    print(error)
                }
            }
        }
        ).resume()
    }
    
    func joinMeeting(meetingId: String, userName: String) {

        
        if !token.isEmpty {
            // use provided token for the meeting
            self.meetingID = meetingId
            self.initializeMeeting(meetingId: meetingId, userName: userName)
        }
        else {
            // show error popup
//            showAlert(title: "Auth Token Required", message: "Please provide auth token to start the meeting.")
            print("Auth token required")
            
        }
    }
}

