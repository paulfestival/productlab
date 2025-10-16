//
//  PlayerView.swift
//  Productlab
//
//  Created by Pavel Mac on 10/14/25.
//

import SwiftUI
import AVKit

struct PlayerView: View {
    let videos: [Video]
    let initialIndex: Int
    @State private var currentIndex: Int = 0
    @State private var players: [Int: AVPlayer] = [:]
    @State private var isLoading = true
    @State private var error: Error?
    @State private var showControls = false
    @State private var commentText = ""
    @State private var isPlaying = false
    @State private var showPlayPauseButton = false
    @State private var showDetailsOverlay = false
    @State private var backgroundColor: Color = .black
    @State private var isShowingReactions = false
    @Environment(\.presentationMode) var presentationMode
    
    let timer = Timer.publish(every: 2.5, on: .main, in: .common).autoconnect()
    
    init(videos: [Video], initialIndex: Int = 0) {
        self.videos = videos
        self.initialIndex = initialIndex
        self._currentIndex = State(initialValue: initialIndex)
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                let videoHeight = geometry.size.height
                
                MagneticVideoScrollView(
                    videos: videos,
                    currentIndex: $currentIndex,
                    videoHeight: videoHeight,
                    players: $players,
                    isPlaying: $isPlaying,
                    onIndexChange: { newIndex in
                        handleIndexChange(newIndex)
                    }
                )
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .edgesIgnoringSafeArea(.all)
            
            videoOverlayUI()
            
            if isLoading {
                ProgressView("Загрузка...")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.7))
            }
        }
        .background(Color.black)
        .navigationBarHidden(true)
        .onTapGesture(perform: handleTap)
        .onAppear(perform: onAppear)
        .onDisappear(perform: onDisappear)
        
    }
    
    private func onAppear() {
        AudioSessionManager.shared.activateAudioSession()
        loadInitialVideos()
    }
    
    private func handleTap() {
        withAnimation {
            togglePlayPause()
            showPlayPauseButton = true
            isShowingReactions.toggle()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showPlayPauseButton = false
                }
            }
        }
    }
    
    private func onDisappear() {
        players.values.forEach { player in
            player.pause()
            player.volume = 0
        }
        VideoCacheManager.shared.clearCache()
        AudioSessionManager.shared.deactivateAudioSession()
    }
    
    private func loadInitialVideos() {
        isLoading = true
        
        Task {
            let indicesToLoad = [currentIndex - 1, currentIndex, currentIndex + 1]
                .filter { $0 >= 0 && $0 < videos.count }
            
            for index in indicesToLoad {
                await loadVideo(for: videos[index], index: index)
            }
            
            if let currentPlayer = players[currentIndex] {
                currentPlayer.volume = 1.0
            }
            
            isLoading = false
        }
    }
    
    private func handleIndexChange(_ newIndex: Int) {
        updateVideoPlayback(for: newIndex)
        preloadAdjacentVideos(from: newIndex)
    }
    
    private func preloadAdjacentVideos(from index: Int) {
        let indicesToLoad = [index - 1, index + 1]
            .filter { $0 >= 0 && $0 < videos.count }
            .filter { !players.keys.contains($0) }
        
        for index in indicesToLoad {
            Task {
                await loadVideo(for: videos[index], index: index)
            }
        }
    }
    
    private func loadVideo(for video: Video, index: Int) async {
        if let cachedPlayer = VideoCacheManager.shared.getPlayer(for: video.id) {
            await MainActor.run {
                players[index] = cachedPlayer
                cachedPlayer.volume = 0
                
                if index == currentIndex {
                    cachedPlayer.play()
                    cachedPlayer.volume = 1.0
                    isPlaying = true
                }
            }
            return
        }
        
        do {
            let url = try await VideoService().fetchVideoURL(for: video.id)
            let player = AVPlayer(url: url)
            player.volume = 0
            
            await MainActor.run {
                players[index] = player
                VideoCacheManager.shared.preloadVideo(for: video)
                
                if index == currentIndex {
                    player.play()
                    player.volume = 1.0
                    isPlaying = true
                }
            }
        } catch {
            print("Error loading video \(video.id): \(error)")
        }
    }
    
    private func updateVideoPlayback(for newIndex: Int) {
        for (index, player) in players {
            if index == newIndex {
                player.play()
                player.volume = 1.0
            } else {
                player.pause()
                player.volume = 0
            }
        }
        
        isPlaying = true
        currentIndex = newIndex
    }
    
    private func togglePlayPause() {
        guard let currentPlayer = players[currentIndex] else { return }
        
        if isPlaying {
            currentPlayer.pause()
            isPlaying = false
        } else {
            currentPlayer.play()
            isPlaying = true
        }
    }
    
    private func videoOverlayUI() -> some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .black.opacity(0.95), location: 0.0),
                        .init(color: .black.opacity(0.85), location: 0.2),
                        .init(color: .black.opacity(0.7), location: 0.4),
                        .init(color: .black.opacity(0.4), location: 0.7),
                        .init(color: .clear, location: 1.0)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 400)
                
                Color.clear
                    .frame(maxHeight: .infinity)
                
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .clear, location: 0.0),
                        .init(color: .black.opacity(0.4), location: 0.2),
                        .init(color: .black.opacity(0.7), location: 0.4),
                        .init(color: .black.opacity(0.85), location: 0.7),
                        .init(color: .black.opacity(0.95), location: 1.0)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 400)
            }
            .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 0) {
                controlsOverlay()
                
                detailsOverlay()
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 8) {
                    tagsAndReactionsView()
                    commentInputView()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
        }
    }
    
    private func reactionButton(emoji: String, count: String) -> some View {
        HStack{
            Text(emoji)
                .font(.system(size: 20))
            Text(count)
                .font(.system(size: 14))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            VisualEffectView(effect: UIBlurEffect(style: .systemMaterialDark))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .opacity(0.9)
        )
    }
    
    
    private func tagsAndReactionsView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            
            HStack {
                Image(systemName: "person.2.fill")
                Text("Друзья смотрят: @pavel @anna @michail")
            }
            .font(.system(size: 14))
            .foregroundColor(.white)
            
            HStack {
                Text("")
                Image(systemName: "play.fill")
                Text("14k смотрят эфир")
            }
            .font(.system(size: 14))
            .foregroundColor(.white)
            
            HStack {
                Image("map.circle")
                    .frame(width: 27, height: 27)
                    .foregroundColor(.white)
                Text("Madrid")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white)
                Image(systemName: "arrow.up.circle.fill")
                    .foregroundColor(.green)
                    .frame(width: 10, height: 10)
                
                HStack {
                    Image(systemName: "film")
                    Text("(12)")
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(
                    VisualEffectView(effect: UIBlurEffect(style: .systemMaterialDark))
                        .clipShape(Capsule())
                        .opacity(0.9)
                )
            }
            
            HStack(spacing: 8) {
                Text("#лето")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        VisualEffectView(effect: UIBlurEffect(style: .systemMaterialDark))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .opacity(0.9)
                    )
                
                Text("#солнце")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        VisualEffectView(effect: UIBlurEffect(style: .systemMaterialDark))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .opacity(0.9)
                    )
                
                Text("#лето")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        VisualEffectView(effect: UIBlurEffect(style: .systemMaterialDark))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .opacity(0.9)
                    )
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    reactionButton(emoji: "😍", count: "10k")
                    reactionButton(emoji: "❤️", count: "100k")
                    reactionButton(emoji: "🙈", count: "5k")
                    reactionButton(emoji: "👍", count: "300k")
                    reactionButton(emoji: "☺️", count: "567")
                }
                .padding(.horizontal, 16)
            }
            .frame(height: 50)
        }
    }
    private func commentInputView() -> some View {
        HStack {
            TextField("Добавить комментарий", text: $commentText)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(.white)
                .padding(.horizontal)
            
            Button(action: {
                print("Комментарий отправлен: \(commentText)")
                commentText = ""
            }) {
                Image("plane")
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
                    .padding(.trailing, 8)
            }
        }
        .padding(.vertical, 13)
        .background(
            VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .opacity(0.9)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .frame(height: 50)
        .padding(.horizontal, 16)
        .padding(.bottom, 20)
    }
    
    private func detailsOverlay() -> some View {
        VStack {
            HStack(alignment: .center, spacing: 8) {
                ZStack(alignment: .bottom) {
                    AsyncImage(url: URL(string: videos[safe: currentIndex]?.channelAvatar ?? "")) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFit()
                        } else {
                            Color.gray.opacity(0.3)
                        }
                    }
                    .frame(width: 70, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white, lineWidth: 1.5)
                    )
                    
                    Text("Live")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.red)
                        .cornerRadius(8)
                        .offset(x: 6, y: 6)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(videos[safe: currentIndex]?.channelName ?? "")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                        Image("mark")
                            .resizable()
                            .frame(width: 12, height: 12)
                            .foregroundColor(.blue)
                    }
                    Label( "Испания, Мадрид", image: "map")
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                    
                    Text(videos[safe: currentIndex]?.title ?? "")
                        .font(.system(size: 13))
                        .foregroundColor(.white)
                        .lineLimit(2)
                }
            }
            .padding(12)
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }
    
    private func controlsOverlay() -> some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
            }
            .frame(width: 40, height: 40)
            
            Spacer()
            
            Button(action: {
                print("Отправить")
            }) {
                Image(systemName: "arrowshape.turn.up.right.fill")
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
            }
            .frame(width: 40, height: 40)
        }
        .padding(.horizontal, 16)
    }
    
}

