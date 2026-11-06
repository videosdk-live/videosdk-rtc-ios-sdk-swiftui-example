//
//  MeetingViewController.swift
//  VideoSDKSwiftUIExample
//
//  Created by Parth Asodariya on 21/04/23.
//

import Foundation
import SwiftUI
import VideoSDKRTC

class MeetingViewController: ObservableObject {

    var token = "Your_Token"
    var meetingId: String = ""
    var name: String = ""

    @Published var meeting: Room? = nil
    @Published var localParticipantView: VideoView? = nil
    @Published var videoTrack: RTCVideoTrack?
    @Published var participants: [Participant] = []
    @Published var meetingID: String = ""

    func initializeMeeting(meetingId: String, userName: String) {

        Task { @MainActor in
            let videoTrack = try? await VideoSDK.createCameraVideoTrack(
                encoderConfig: .h720p_w1280p,
                facingMode: .front,
                multiStream: true,
                maxLayer: .MAX_LAYER_3,
                bitrateMode: .HIGH_QUALITY,
                codec: .VP8
            )

            meeting = try? VideoSDK.createRoom(
                roomId: meetingId,
                token: token,
                participantName: userName,
                micEnabled: true,
                camEnabled: true,
                mode: .SEND_AND_RECV,
                customCameraTrack: videoTrack,
                signalingBaseUrl: nil,
                preferredProtocol: .UDP_OVER_TCP
            )

            meeting?.addEventListener(self)

            try? await meeting?.join()
        }
    }

}

extension MeetingViewController: RoomEventListener {
    func onRoomJoined() {

        guard let localParticipant = self.meeting?.localParticipant else {
            return
        }

        // add to list
        participants.append(localParticipant)

        // add event listener
        localParticipant.addEventListener(self)
    }

    func onParticipantJoined(_ participant: Participant) {

        participants.append(participant)

        // add listener
        participant.addEventListener(self)

        //        participant.setQuality(.high)
    }

    func onParticipantLeft(_ participant: Participant, reason: LeaveReason) {
        participants = participants.filter({ $0.id != participant.id })
    }

    func onRoomLeft(reason: LeaveReason) {
        meeting?.localParticipant.removeEventListener(self)
        meeting?.removeAllEventListeners()
        participants.removeAll()
        meeting = nil
        videoTrack = nil
        localParticipantView = nil
    }

    func onRoomStateChanged(roomState: RoomState) {
        switch roomState {

        case .DISCONNECTED:
            participants.removeAll()

        default:
            print("")
        }
    }

    func onQualityLimitation(
        type: VideoSDKRTC.QualityLimitationType,
        state: VideoSDKRTC.QualityLimitationState,
        timestamp: Int
    ) {

    }

}

extension MeetingViewController: ParticipantEventListener {
    
    func onAgentMetrics(_ metrics: [String : Any], forParticipant participant: Participant) {
        print("Agent Participant Metrics: \(metrics)")
    }
    
    func onStreamEnabled(
        _ stream: RTCStream,
        forParticipant participant: Participant
    ) {

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

    func onStreamDisabled(
        _ stream: RTCStream,
        forParticipant participant: Participant
    ) {

        if participant.isLocal {

            if stream.track as? RTCVideoTrack != nil {
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

        session.dataTask(
            with: request,
            completionHandler: {
                (data: Data?, response: URLResponse?, error: Error?) in

                if let data = data,
                    let utf8Text = String(data: data, encoding: .utf8)
                {
                    print("UTF =>=>\(utf8Text)")  // original server data as UTF8 string
                    do {
                        let dataArray = try JSONDecoder().decode(
                            RoomsStruct.self,
                            from: data
                        )
                        DispatchQueue.main.async {
                            print(dataArray.roomID ?? "")
                            self.meetingID = dataArray.roomID!
                            self.joinMeeting(
                                meetingId: dataArray.roomID!,
                                userName: userName
                            )
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
        } else {
            // show error popup
            // showAlert(title: "Auth Token Required", message: "Please provide auth token to start the meeting.")
            print("Auth token required")

        }
    }
}
