//
//  FeedViewModel.swift
//  Productlab
//
//  Created by Pavel Mac on 10/14/25.
//

import SwiftUI

@MainActor
final class FeedViewModel: ObservableObject {
    @Published var videos: [Video] = []
    @Published var isLoading = false
    @Published var errormessage: String?
    
    private let service = VideoService()
    
    func loadVideos() async {
        isLoading = true
        defer {
            isLoading = false
        }
        
        do {
            let videos = try await service.fetchRecommendations()
            await MainActor.run {
                self.videos = videos
                self.errormessage = nil
            }
        } catch {
            await MainActor.run {
                self.errormessage = "Ошибка загрузки: \(error.localizedDescription)"
                print("Detailed error: \(error)")
            }
        }
    }
}
