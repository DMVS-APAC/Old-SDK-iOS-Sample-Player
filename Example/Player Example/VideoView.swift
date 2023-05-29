//
//  VideoView.swift
//  Player Example
//
//  Created by Yudhi SATRIO on 13/04/23.
//  Copyright © 2023 Dailymotion. All rights reserved.
//

import Foundation
import UIKit
import SafariServices
import DailymotionPlayerSDK

class VideoView: UIView {
    
    // Declare your subviews here
    private let thumbnailImageView = UIImageView()
    private let titleLabel = UILabel()
    private let statusLabel = UILabel()
    private let adStatusLabel = UILabel()
    private(set) var playerViewController: DMPlayerViewController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        // Configure titleLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .light)

        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.numberOfLines = 0
        statusLabel.textAlignment = .left
        statusLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        statusLabel.textColor = .brown

        adStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        adStatusLabel.numberOfLines = 0
        adStatusLabel.textAlignment = .left
        adStatusLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        adStatusLabel.textColor = .magenta


        // Configure thumbnailImageView
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.isUserInteractionEnabled = true
        self.isUserInteractionEnabled = true
        
        // Create a vertical stack view for the labels
        let labelsStackView = UIStackView()
        labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        labelsStackView.axis = .vertical
        labelsStackView.distribution = .fill
        labelsStackView.spacing = 8

        labelsStackView.addArrangedSubview(titleLabel)
        labelsStackView.addArrangedSubview(statusLabel)
        labelsStackView.addArrangedSubview(adStatusLabel)



        // Add subviews to the main view
        addSubview(thumbnailImageView)
        addSubview(labelsStackView)
        
        // Add constraints to position the subviews
        NSLayoutConstraint.activate([
            thumbnailImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            thumbnailImageView.topAnchor.constraint(equalTo: topAnchor),
            thumbnailImageView.widthAnchor.constraint(equalTo: thumbnailImageView.heightAnchor, multiplier: 16/9),
            
            labelsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            labelsStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            labelsStackView.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: 8),
            labelsStackView.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor)
        ])
        
    }
    
    func loadVideo(withId id: String, delegate: DMPlayerViewControllerDelegate? = nil) {
        let parameters: [String: Any] = [
            "fullscreen-action": "trigger_event",
            "sharing-action": "trigger_event",
//            "autoplay": true,
            "mute": true
        ]
        
        playerViewController = DMPlayerViewController(parameters: parameters, allowPiP: false)
        playerViewController?.delegate = delegate
        playerViewController?.load(videoId: id)
        
        if let playerView = playerViewController?.view {
            playerView.frame = thumbnailImageView.bounds
            thumbnailImageView.addSubview(playerView)
        }
        
    }
    
    func totalLabelHeight() -> CGFloat {
        let titleHeight = titleLabel.intrinsicContentSize.height
        let statusHeight = statusLabel.intrinsicContentSize.height
        let adStatusHeight = adStatusLabel.intrinsicContentSize.height
        let totalHeight = titleHeight + statusHeight + adStatusHeight
        return totalHeight
    }
    
    func setThumbnailImage(url: String?) {
        guard let urlString = url, let imageUrl = URL(string: urlString) else { return }
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: imageUrl) {
                DispatchQueue.main.async {
                    self.thumbnailImageView.image = UIImage(data: data)
                }
            }
        }
    }

    func setTitle(text: String?) {
        titleLabel.text = text
    }
    
    func setStatus(text: String?) {
        statusLabel.text = "Video status: " + (text ?? "N/A")
    }
    
    func setAdStatus(text: String?) {
        adStatusLabel.text = "Ad status: " + (text ?? "N/A")
    }
}

extension VideoView: DMPlayerViewControllerDelegate {
    func player(_ player: DMPlayerViewController, didReceiveEvent event: PlayerEvent) {
        // Handle player events if needed
    }
    
    func player(_ player: DMPlayerViewController, openUrl url: URL) {
//        let controller = SFSafariViewController(url: url)
//        present(controller, animated: true, completion: nil)
    }
    
    func playerDidInitialize(_ player: DMPlayerViewController) {
    }
    
    func player(_ player: DMPlayerViewController, didFailToInitializeWithError error: Error) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
//        present(alertController, animated: true)
    }
}


