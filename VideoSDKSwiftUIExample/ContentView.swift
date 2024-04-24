//
//  ContentView.swift
//  VideoSDKSwiftUIExample
//
//  Created by Parth Asodariya on 20/04/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                    .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
                NavigationLink(destination: MeetingView()) {
                    Text("Go to Meeting View")
                        .font(.headline).foregroundColor(Color.red)
                }
            }
            .padding()
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

