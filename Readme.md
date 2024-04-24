# VideoSDK Example using SwiftUI

## Setup Guide

- Sign up on [VideoSDK](https://app.videosdk.live/) and visit [API Keys](https://app.videosdk.live/api-keys) section to get your API key and Secret key.

- Get familiarized with [API key and Secret key](https://docs.videosdk.live/ios/guide/video-and-audio-calling-api-sdk/signup-and-create-api)

- Get familiarized with [Token](https://docs.videosdk.live/ios/guide/video-and-audio-calling-api-sdk/server-setup)


### Prerequisites

- iOS 12.0+
- Xcode 13.0+
- Swift 5.0+
- Valid [Video SDK Account](https://app.videosdk.live/signup)

## Run the Sample App

### Step 1: Clone the sample project
   ```sh
   git clone https://github.com/videosdk-live/videosdk-rtc-ios-sdk-swiftui-example.git
   ```

### Step 2. update `AUTH_TOKEN` in the `VideoSDKSwiftUIExample/MeetingViewController.swift` file.
Generate temporary token from [Video SDK Account](https://app.videosdk.live/signup).
   ```
   var token = "Your_Token"
   ```
### Step 4. Run the project.
Run App from Xcode. Please run the app in real device for better experience because audio and video is not supported in simulator.

