//
//  PlayerViewModel.swift
//  Productlab
//
//  Created by Pavel Mac on 10/14/25.
//

import SwiftUI
import AVKit

final class PlayerViewModel: ObservableObject {
    @Published var player: AVPlayer?
    @Published var isLoading = false
    @Published var error: String?
    
    private let service = VideoService()
    
    @MainActor
    func loadVideo(id: Int) {
        isLoading = true
        error = nil
        
        Task {
            do {
                let url = try await service.fetchVideoURL(for: id)
                let player = AVPlayer(url: url)
                
                try await Task.sleep(nanoseconds: 100_000_000)
                
                await MainActor.run {
                    self.player = player
                    self.isLoading = false
                    player.play()
                }
                
            } catch {
                await MainActor.run {
                    self.error = "Ошибка загрузки видео: \(error.localizedDescription)"
                    self.isLoading = false
                    print("Video loading error: \(error)")
                }
            }
        }
    }
}
