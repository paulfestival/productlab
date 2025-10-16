//
//  VideoCacheManager.swift
//  Productlab
//
//  Created by Pavel Mac on 10/15/25.
//

import Foundation
import AVKit

final class VideoCacheManager {
    static let shared = VideoCacheManager()
    private let cache = NSCache<NSNumber, AVPlayer>()
    private var loadingTasks: [Int: Task<Void, Never>] = [:]
    
    private init() {
        cache.countLimit = 5
    }
    
    func getPlayer(for videoId: Int) -> AVPlayer? {
        return cache.object(forKey: NSNumber(value: videoId))
    }
    
    func preloadVideo(for video: Video, completion: ((AVPlayer?) -> Void)? = nil) {
        loadingTasks[video.id]?.cancel()
        
        let task = Task {
            do {
                let url = try await VideoService().fetchVideoURL(for: video.id)
                let player = AVPlayer(url: url)
                player.volume = 0 
                
                await MainActor.run {
                    cache.setObject(player, forKey: NSNumber(value: video.id))
                    completion?(player)
                }
            } catch {
                print("Preload error for video \(video.id): \(error)")
                completion?(nil)
            }
        }
        
        loadingTasks[video.id] = task
    }
    
    func cancelPreload(for videoId: Int) {
        loadingTasks[videoId]?.cancel()
        loadingTasks[videoId] = nil
    }
    
    func clearCache() {
        cache.removeAllObjects()
        loadingTasks.values.forEach { $0.cancel() }
        loadingTasks.removeAll()
    }
}
