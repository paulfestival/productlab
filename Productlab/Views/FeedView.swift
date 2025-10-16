//
//  FeedView.swift
//  Productlab
//
//  Created by Pavel Mac on 10/14/25.
//

import SwiftUI

struct FeedView: View {
    @StateObject var vm = FeedViewModel()
    @State private var selectedTab = 0
    @State private var selectedVideoId: Int? = nil
    @State private var activeCardIndex: Int = 0
    @State private var isFirstAppear: Bool = true
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    if vm.isLoading {
                        ProgressView("Загрузка...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let error = vm.errormessage {
                        Text(error)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        MagneticScrollView(videos: vm.videos) { index in
                            selectedVideoId = vm.videos[index].id
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .background(Color.black.edgesIgnoringSafeArea(.all))
                
                GlassBottomBar()
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
            .background(
                NavigationLink(
                       destination: PlayerView(videos: vm.videos, initialIndex: activeCardIndex),
                       isActive: Binding(
                           get: { selectedVideoId != nil },
                           set: { if !$0 { selectedVideoId = nil } }
                       ),
                       label: { EmptyView() }
                   )
            )
        }
        .task {
            await vm.loadVideos()
        }
    }
}






