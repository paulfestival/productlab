//
//  GlassBottomBar.swift
//  Productlab
//
//  Created by Pavel Mac on 10/15/25.
//

import SwiftUI

struct GlassBottomBar: View {
    @State private var selectedTab = 0
    
    var body: some View {
        HStack(spacing: 0) {
            Button(action: { selectedTab = 0 }) {
                VStack(spacing: 4) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 24))
                        .foregroundColor(selectedTab == 0 ? .white : .gray)
                    
                }
            }
            .frame(maxWidth: .infinity)
            
            Button(action: { selectedTab = 1 }) {
                VStack(spacing: 4) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 24))
                        .foregroundColor(selectedTab == 1 ? .white : .gray)
                    
                }
            }
            .frame(maxWidth: .infinity)
            
            Button(action: { selectedTab = 2 }) {
                Image(systemName: "plus")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
                    .padding(12)
                    .background(Circle().fill(Color.white))
            }
            .frame(maxWidth: .infinity)
            
            Button(action: { selectedTab = 3 }) {
                VStack(spacing: 4) {
                    Image(systemName: "ellipsis.message.fill")
                        .font(.system(size: 24))
                        .foregroundColor(selectedTab == 3 ? .white : .gray)
                   
                }
            }
            .frame(maxWidth: .infinity)
            
            Button(action: { selectedTab = 4 }) {
                AsyncImage(url: URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSKZw9x5eFbBNp3EbP7n6IPpZz3jiv-pw3MQQ&s")) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 30, height: 30)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 10)
        .background(
            VisualEffectView(effect: UIBlurEffect(style: .systemMaterialDark))
                .clipShape(RoundedRectangle(cornerRadius: 35))
                .opacity(0.9)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 35)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .frame(height: 70)
        
    }
}


