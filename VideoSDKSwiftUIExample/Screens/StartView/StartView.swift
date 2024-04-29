//
//  StartView.swift
//  VideoSDKSwiftUIExample
//
//  Created by Uday Gajera on 25/04/24.
//

import SwiftUI

struct StartView: View {
    
    @State var meetingId: String
    @State var name: String
    
    var body: some View {
        
            NavigationView {
                
                VStack {
                    
                    Text("VideoSDK")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Swift UI Quickstart")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .padding(.bottom)
                        .padding(.bottom)
                        .padding(.bottom)
                    
                    TextField("Enter MeetingId", text: $meetingId)
                        .foregroundColor(Color.black)
                        .autocorrectionDisabled()
                        .font(.headline)
                        .overlay(
                        Image(systemName: "xmark.circle.fill")
                            .padding()
                            .offset(x: 10)
                            .foregroundColor(Color.gray)
                            .opacity(meetingId.isEmpty ? 0.0 : 1.0)
                            .onTapGesture {
                                UIApplication.shared.endEditing()
                                meetingId = ""
                            }
                        , alignment: .trailing)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.secondary.opacity(0.5))
                                .shadow(color: Color.gray.opacity(0.10), radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/))
                        .padding(.leading)
                        .padding(.trailing)
                    
                    Text("Enter Meeting Id to join an existing meeting")
                    
                    TextField("Enter Your Name", text: $name)
                        .foregroundColor(Color.black)
                        .autocorrectionDisabled()
                        .font(.headline)
                        .overlay(
                        Image(systemName: "xmark.circle.fill")
                            .padding()
                            .offset(x: 10)
                            .foregroundColor(Color.gray)
                            .opacity(name.isEmpty ? 0.0 : 1.0)
                            .onTapGesture {
                                UIApplication.shared.endEditing()
                                name = ""
                            }
                        , alignment: .trailing)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.secondary.opacity(0.5))
                                .shadow(color: Color.gray.opacity(0.10), radius: 10))
                        .padding()
                    
                    if meetingId.isEmpty == false {
                        NavigationLink(destination:{
                            if meetingId.isEmpty == false {
                                MeetingView(meetingId: self.meetingId, userName: name ?? "Guest")
                                    .navigationBarBackButtonHidden(true)
                            } else {
                            }
                        }) {
                            Text("Join Meeting")
                                .foregroundColor(Color.white)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 25.0)
                                        .fill(Color.blue))                    }
                    }
                    
                    NavigationLink(destination: MeetingView(userName: name ?? "Guest")
                        .navigationBarBackButtonHidden(true)) {
                        Text("Start Meeting")
                            .foregroundColor(Color.white)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 25.0)
                                    .fill(Color.blue))                    }
                }
            }
                
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
