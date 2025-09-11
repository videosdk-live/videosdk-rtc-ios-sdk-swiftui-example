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
    
    @Published var meeting: Meeting? = nil
    @Published var localParticipantView: VideoView? = nil
    @Published var videoTrack: RTCVideoTrack?
    @Published var participants: [Participant] = []
    @Published var meetingID: String = ""
    
    
    func initializeMeeting(meetingId: String, userName: String) {
        meeting = VideoSDK.initMeeting(
            meetingId: meetingId,
            participantName: userName,
            micEnabled: true,
            webcamEnabled: true
        )
        
        meeting?.addEventListener(self)
      
        meeting?.join()
    }
    
}

extension MeetingViewController: MeetingEventListener {
    func onMeetingJoined() {
        
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
        
        
    }
    func onMeetingStateChanged(meetingState: MeetingState) {
        switch meetingState {

        case .DISCONNECTED:
            participants.removeAll()
            
        default:
            print("")
        }
    }
}

extension MeetingViewController: ParticipantEventListener {
    func onStreamEnabled(_ stream: MediaStream, forParticipant participant: Participant) {
        
        if participant.isLocal && stream.kind == .share {
            return
        }
        
        if participant.isLocal {
            if let track = stream.track as? RTCVideoTrack {
                DispatchQueue.main.async {
                    self.videoTrack = track
                }
            }
        } else {
            if let track = stream.track as? RTCVideoTrack {
                DispatchQueue.main.async {
                    self.videoTrack = track
                }
            }
        }
    }
    
    func onStreamDisabled(_ stream: MediaStream, forParticipant participant: Participant) {
        
        if participant.isLocal {
            
            if let _ = stream.track as? RTCVideoTrack {
                DispatchQueue.main.async {
                    self.videoTrack = nil
                }
            }
        } else {
            self.videoTrack = nil
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
                print("UTF =>=>\(utf8Text)") // original server data as UTF8 string
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

