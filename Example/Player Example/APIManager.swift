//
//  APIManager.swift
//  Player Example
//
//  Created by Yudhi SATRIO on 13/04/23.
//  Copyright © 2023 Dailymotion. All rights reserved.
//

import Foundation

class APIManager {
    
    func fetchVideos(completion: @escaping ([[String: Any]]?, Error?) -> Void) {
        let url = "https://api.dailymotion.com/videos?fields=id,title,thumbnail_240_url&sort=recent&limit=10&owners=isatrio"
        let request = URLRequest(url: URL(string: url)!)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let videos = json["list"] as? [[String: Any]] {
                        completion(videos, nil)
                    }
                } catch {
                    completion(nil, error)
                }
            }
        }.resume()
    }
}
