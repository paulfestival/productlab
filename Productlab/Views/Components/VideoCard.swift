//
//  VideoCard.swift
//  Productlab
//
//  Created by Pavel Mac on 10/15/25.
//

import SwiftUI

struct VideoCard: View {
    let video: Video
    
    private let mockTags = ["лето", "солнце", "природа"]
    
    var body: some View {
        ZStack {
            AsyncImage(url: URL(string: video.previewImage)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 300, height: 550)
                        .clipped()
                default:
                    Color.gray.opacity(0.3)
                        .frame(width: 300, height: 550)
                }
            }
            .cornerRadius(24)
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.black.opacity(0.1), lineWidth: 0.5))
            .shadow(radius: 4, y: 2)
            
            VStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0.6),
                        Color.black.opacity(0.2),
                        Color.clear
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 120)
                .edgesIgnoringSafeArea(.top)
                
                Spacer()
                
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.clear,
                        Color.black.opacity(0.2),
                        Color.black.opacity(0.6)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 120)
                .edgesIgnoringSafeArea(.bottom)
            }
            VStack {
                HStack(alignment: .center, spacing: 8) {
                    ZStack(alignment: .bottom) {
                        AsyncImage(url: URL(string: video.channelAvatar)) { phase in
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
                    
                    VStack(alignment: .leading) {
                        HStack(spacing: 4) {
                            Text(video.channelName)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                            Image("mark")
                                .resizable()
                                .frame(width: 12, height: 12)
                                
                        }
                        .padding(.bottom, 10)
                        
                        Text(video.title)
                            .font(.system(size: 13))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                }
                .padding(12)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        ForEach(mockTags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    VisualEffectView(effect: UIBlurEffect(style: .systemMaterialDark))
                                        .clipShape(Capsule())
                                        .opacity(0.9)
                                )
                                
                        }
                    }
                    
                    HStack {
                        Label(video.location ?? "Испания, Мадрид", image: "map")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                        Spacer()
                        HStack(spacing: 12) {
                            Label("\(video.views)", systemImage: "eye")
                            Label("\(video.likes)", systemImage: "heart")
                        }
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
        }
        .frame(width: 300, height: 550)
        .compositingGroup()
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

