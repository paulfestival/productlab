//
//  VideoService.swift
//  Productlab
//
//  Created by Pavel Mac on 10/14/25.
//

import Foundation

struct PlaylistResponse: Decodable {
    let url: String
}

final class VideoService {
    private let baseURL = "https://interesnoitochka.ru/api/v1"
    private let urlSession: URLSession
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        configuration.httpMaximumConnectionsPerHost = 6
        self.urlSession = URLSession(configuration: configuration)
    }
    
    private let cache = NSCache<NSNumber, NSURL>()
    
    func fetchRecommendations() async throws -> [Video] {
        let url = URL(string: "\(baseURL)/videos/recommendations?offset=0&limit=10&category=shorts&date_filter_type=created&sort_by=date_created&sort_order=desc")!
        do {
            let (data, networkResponse) = try await urlSession.data(from: url)
            
            if let httpResponse = networkResponse as? HTTPURLResponse {
                print("Status Code: \(httpResponse.statusCode)")
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON: \(jsonString.prefix(500))...")
            }
            
            let decoder = JSONDecoder()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            decoder.dateDecodingStrategy = .formatted(formatter)
            
            let videoResponse = try decoder.decode(VideoResponse.self, from: data)
            return videoResponse.items
            
        } catch {
            print("Decoding error: \(error)")
            throw error
        }
    }
    
    func fetchVideoURL(for id: Int) async throws -> URL {
        if let cachedURL = cache.object(forKey: NSNumber(value: id)) {
            print("Using cached URL for video \(id): \(cachedURL)")
            return cachedURL as URL
        }
        
        let apiURL = URL(string: "\(baseURL)/videos/video/\(id)/hls/playlist.m3u8")!
        print("Fetching video playlist from: \(apiURL)")
        
        do {
            let (data, response) = try await urlSession.data(from: apiURL)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Playlist Status Code: \(httpResponse.statusCode)")
            }
            
            guard let playlistContent = String(data: data, encoding: .utf8) else {
                throw URLError(.cannotDecodeContentData)
            }
            
            
            let basePlaylistURL = apiURL.deletingLastPathComponent()
            let fullPlaylistURL = basePlaylistURL.appendingPathComponent("playlist.m3u8")
            
            cache.setObject(fullPlaylistURL as NSURL, forKey: NSNumber(value: id))
            
            return fullPlaylistURL
            
        } catch {
            print("Error fetching video playlist: \(error)")
            throw error
        }
    }
}
