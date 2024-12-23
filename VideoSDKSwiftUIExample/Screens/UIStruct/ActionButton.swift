//
//  ActionButton.swift
//  VideoSDKSwiftUIExample
//
//  Created by Deep Bhupatkar on 20/12/24.
//


import SwiftUI
struct ActionButton: View {
    let title: String
    let color: Color
    
    var body: some View {
        HStack {
            Spacer()
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color)
                .shadow(color: color.opacity(0.3), radius: 5, x: 0, y: 2)
        )
    }
}
