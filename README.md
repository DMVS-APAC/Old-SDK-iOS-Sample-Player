# Old SDK Sample Project

This is a clone of this [old sdk](https://github.com/dailymotion/dailymotion-swift-player-sdk-ios) repository.

This is a sample project demonstrating the usage of Dailymotion Player SDK in a UIKit application. Setup

1. Clone this repository to your local machine.
2. Open the project in Xcode.
3. If necessary, change the Bundle Identifier and Team under the target's General settings to match your Apple Developer account.

To start, open this project from XCode from `Example` directory. Then just run it. It will show you a simple app with video list.

## Debugging

We provide logs for you to debug the player under the ViewController. We have 3 things to debug, from the player, from the video, and from the ad

## Understanding the code

The main class is ViewController, which sets up and manages the Dailymotion player. VideoView is a custom UIView subclass that loads and displays the video player.

VideoView contains a DMPlayerView instance. This instance is created by the loadVideo(withId id: String) function, which calls DMPlayerViewController(). The video is played when the player view is successfully created.
