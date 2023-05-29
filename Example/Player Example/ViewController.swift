//
//  Copyright © 2017 Dailymotion. All rights reserved.
//

import UIKit
import SafariServices
import DailymotionPlayerSDK

/// A structure representing a video with its associated properties.
///
/// The `Video` structure has the following properties:
/// - `id`: A string representing the unique identifier of the video.
/// - `title`: A string representing the title of the video.
/// - `thumbnailURL`: A URL representing the location of the video's thumbnail image.
///
/// The structure also includes an `init?(dictionary: [String: Any])` initializer, which tries to create a `Video` instance from a given dictionary. If the dictionary does not contain the required keys or values, the initializer returns `nil`.
struct Video {
    let id: String
    let title: String
    let thumbnailURL: URL
    
    init?(dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
              let title = dictionary["title"] as? String,
              let thumbnailURLString = dictionary["thumbnail_240_url"] as? String,
              let thumbnailURL = URL(string: thumbnailURLString) else {
            return nil
        }

        self.id = id
        self.title = title
        self.thumbnailURL = thumbnailURL
    }
}


/// Console log events are categorized into four types for better clarity and understanding.
/// Each event type is represented by a specific emoji for quick identification.
///
/// - 🧃 (Video events): Log entries related to video playback, user interactions, and other video-related events.
/// - 🎯 (Ad events): Log entries related to ads, such as ad requests, ad impressions, and ad interactions.
/// - 🔥 (Bug events): Log entries that indicate errors, crashes, or other issues that need to be addressed and resolved.
/// - 🧀 (User information): Log entries that provide information to the user about app functionality, progress, or status updates.
///
/// These event categories help developers easily identify and filter logs for efficient debugging and analysis.
class ViewController: UIViewController, DMPlayerViewControllerDelegate {
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 40
        return stackView
    }()
    private var videos: [Video] = []
    private var currentPlayingVideoIndex = 0
    private var postroll = false
    private var videoend = false
    private var videoViews: [VideoView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        fetchData { fetchedVideos in
            let convertedVideos = fetchedVideos.compactMap { Video(dictionary: $0) }
            DispatchQueue.main.async {
                self.videos = convertedVideos
                self.populateStackView(with: convertedVideos)
            }
        }
    }
    
    /// Fetches video data from the Dailymotion API and returns the result in the completion handler.
    ///
    /// - Parameters:
    ///   - completion: A closure that takes an array of dictionaries containing video information as its argument.
    ///                 Each dictionary contains keys: `id`, `thumbnail_240_url`, and `title`.
    ///
    /// Example usage:
    /// ```
    /// fetchData { videos in
    ///     for video in videos {
    ///         print(video["title"])
    ///     }
    /// }
    /// ```
    private func fetchData(completion: @escaping ([[String: Any]]) -> Void) {
        let dailymotionURL = "https://api.dailymotion.com/videos?fields=id,thumbnail_240_url,title&limit=5&owners=suaradotcom"
        
        guard let url = URL(string: dailymotionURL) else {
            print("🔥 dm: Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let videos = json["list"] as? [[String: Any]] {
                        completion(videos)
                    } else {
                        print("🔥 dm: Failed to parse JSON")
                    }
                } catch {
                    print("🔥 dm: \(error.localizedDescription)")
                }
            } else {
                print("🔥 dm: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
        
        task.resume()
    }
    
    /// Sets up the user interface by configuring the main view, scroll view, and stack view.
    ///
    /// This function is responsible for:
    /// - Setting the main view's background color to white.
    /// - Adding the scroll view as a subview of the main view and setting its constraints.
    /// - Adding the stack view as a subview of the scroll view and setting its constraints.
    /// - Ensuring that the stack view has the same width as the scroll view.
    ///
    /// By organizing the UI elements in this way, the interface can efficiently display and scroll through a dynamic list of content.
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    /// Populates the stack view with VideoView instances created from the given array of videos.
    ///
    /// - Parameter videos: An array of `Video` objects representing the videos to display in the stack view.
    ///
    /// This function does the following:
    /// - Iterates through each `Video` object in the provided `videos` array.
    /// - Creates a new `VideoView` instance for each video and sets the thumbnail image and title.
    /// - Loads the video with the provided `video.id` if the current index matches `currentPlayingVideoIndex`.
    /// - Adds the `VideoView` instance to the stack view as an arranged subview.
    /// - Sets the height, leading, and trailing constraints for the `VideoView` instance.
    ///
    /// By using this function, the interface can efficiently display multiple video views in a scrollable stack view.
    private func populateStackView(with videos: [Video]) {
        for (index, video) in videos.enumerated() {
            let videoView = VideoView()
            videoView.translatesAutoresizingMaskIntoConstraints = false
            videoView.setThumbnailImage(url: video.thumbnailURL.absoluteString)
            videoView.setTitle(text: video.title)
            videoView.setStatus(text: "--")
            videoView.setAdStatus(text: "--")
            
            if index == currentPlayingVideoIndex {
                videoView.loadVideo(withId: video.id, delegate: self)
            }
            
            stackView.addArrangedSubview(videoView)
            
            NSLayoutConstraint.activate([
                videoView.heightAnchor.constraint(equalToConstant: 240),
                videoView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
                videoView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            ])
        }
        
        // Update the stack view's spacing after adding all the VideoViews
        updateStackViewSpacing()
    }
    
    /**
     * There are 3 kind of events can be listened
     * - namedEvent
     * - errorEvent
     * - timeEvent
     *
     * In every event has `name` and `data` that we can filter. `name` is the name of the event. `data` is state that depen on
     * what the event can provide.
     */
    func player(_ player: DMPlayerViewController, didReceiveEvent event: PlayerEvent) {
        let videoView = stackView.arrangedSubviews[currentPlayingVideoIndex] as! VideoView
        
        switch event {
        case .namedEvent(let name, let data):
            if let data = data {
                print("🧀 dm: event name: \(name) and data: \(data)")
            }
            switch name {
            case "video_start":
                print("🧃 dm: the video is start now")
                videoView.setStatus(text: "Video is starting")
            case "playing":
                print("🧃 dm: the video is playing")
                videoView.setStatus(text: "Video is playing")
            case "end":
                print("🧃 dm: the video ended")
                videoView.setStatus(text: "Video ended")
                videoend = true
                if postroll == false {
                    playNextVideo()
                }
            case "pause":
                print("🧃 dm: the video paused")
                videoView.setStatus(text: "Video paused")
            case "ad_loaded":
                print("🎯 dm: ad loaded")
                
                if let data = data {
                    print("🧀 dm: position: \(data["position"] ?? "no position data")")
                    
                    videoView.setAdStatus(text: "Ad loaded, position \(data["position"] ?? "no position data")")
                    
                    if data["position"] == "postroll" {
                        postroll = true
                    }
                }
            case "ad_start":
                print("🎯 dm: ad start")
                
                if let data = data {
                    print("🧀 dm: position: \(data["position"] ?? "no position data")")
                    
                    videoView.setAdStatus(text: "Ad start, position \(data["position"] ?? "no position data")")
                }
            case "ad_end":
                print("🎯 dm: ad end")
                
                if let data = data {
                    print("🧀 dm: position: \(data["position"] ?? "no position data")")
                    
                    videoView.setAdStatus(text: "Ad ended, position \(data["position"] ?? "no position data")")
                    
                    if data["position"] == "postroll" {
                        playNextVideo()
                    }
                }
            default:
                break
            }
        case .errorEvent(let error) :
            print("🔥 dm: ", error)
//        case .timeEvent(let name, let time):
//            print("🥟 dm: ", name, time)
        default:
            break
        }
    }
    func player(_ player: DMPlayerViewController, openUrl url: URL) {}
    func playerDidInitialize(_ player: DMPlayerViewController) {}
    func player(_ player: DMPlayerViewController, didFailToInitializeWithError error: Error) {}
    
    /// Plays the next video in the list and scrolls to its position.
    ///
    /// This function checks if there is a next video available in the `videos` array by comparing
    /// `currentPlayingVideoIndex` with the total number of videos.
    ///
    /// If there is a next video:
    /// - It increments `currentPlayingVideoIndex`.
    /// - Retrieves the `Video` object for the next video.
    /// - Obtains the corresponding `VideoView` instance from the `stackView.arrangedSubviews`.
    /// - Loads the next video with the provided `nextVideo.id` and sets the delegate to `self`.
    /// - Calls `scrollToVideoPlayingPosition()` to scroll the view to the video's position.
    ///
    /// By using this function, you can easily switch to the next video in the list and automatically
    /// scroll the view to display the currently playing video.
    private func playNextVideo() {
        if currentPlayingVideoIndex + 1 < videos.count {
            currentPlayingVideoIndex += 1
            let nextVideo = videos[currentPlayingVideoIndex]
            let nextVideoView = stackView.arrangedSubviews[currentPlayingVideoIndex] as! VideoView
            nextVideoView.loadVideo(withId: nextVideo.id, delegate: self)
//            scrollToVideoPlayingPosition()
            resetVideoFlags()
        }
    }
    
    /// Scrolls the view to the currently playing video's position.
    ///
    /// This function checks if the `currentPlayingVideoIndex` is within the range of the `videos` array.
    ///
    /// If the index is within range:
    /// - It retrieves the corresponding `VideoView` instance from the `stackView.arrangedSubviews`.
    /// - Converts the `videoView`'s bounds to the coordinate system of the `scrollView`.
    /// - Sets the content offset of the `scrollView` to the origin of the converted `videoView` frame
    ///   with a smooth animation.
    ///
    /// By using this function, you can ensure that the view automatically scrolls to display the
    /// currently playing video, improving the user experience and making video navigation more convenient.
    private func scrollToVideoPlayingPosition() {
        if currentPlayingVideoIndex < videos.count {
            let videoView = stackView.arrangedSubviews[currentPlayingVideoIndex] as! VideoView
            let videoViewFrame = videoView.convert(videoView.bounds, to: scrollView)
            scrollView.setContentOffset(CGPoint(x: 0, y: videoViewFrame.origin.y), animated: true)
        }
    }

    func updateStackViewSpacing() {
        // Get all the VideoView instances from the stack view's arrangedSubviews
        let videoViews = stackView.arrangedSubviews.compactMap { $0 as? VideoView }

        // Calculate the maximum total height of the labels for all VideoViews
        let maxLabelHeight = videoViews.map { $0.totalLabelHeight() }.max() ?? 0

        // Add some padding (e.g., 20) to the maximum height to ensure proper spacing
        let dynamicSpacing = maxLabelHeight + 40

        // Update the stack view's spacing
        stackView.spacing = dynamicSpacing
    }
    
    // Create a function to reset the variables
    private func resetVideoFlags() {
        postroll = false
        videoend = false
    }

}
