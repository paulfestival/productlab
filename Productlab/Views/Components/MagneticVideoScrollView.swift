//
//  MagneticVideoScrollView.swift
//  Productlab
//
//  Created by Pavel Mac on 10/15/25.
//

import SwiftUI
import AVKit

struct MagneticVideoScrollView: UIViewRepresentable {
    let videos: [Video]
    @Binding var currentIndex: Int
    let videoHeight: CGFloat
    @Binding var players: [Int: AVPlayer]
    @Binding var isPlaying: Bool
    var onIndexChange: ((Int) -> Void)?
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.isPagingEnabled = false
        scrollView.decelerationRate = .fast
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .black
        scrollView.contentInsetAdjustmentBehavior = .never
        
        let containerView = UIView()
        scrollView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        for (index, _) in videos.enumerated() {
            let videoContainer = VideoContainerView()
            videoContainer.tag = index
            videoContainer.frame = CGRect(
                x: 0,
                y: CGFloat(index) * videoHeight,
                width: UIScreen.main.bounds.width,
                height: videoHeight
            )
            containerView.addSubview(videoContainer)
        }
        
        containerView.frame = CGRect(
            x: 0,
            y: 0,
            width: UIScreen.main.bounds.width,
            height: CGFloat(videos.count) * videoHeight
        )
        
        scrollView.contentSize = CGSize(
            width: UIScreen.main.bounds.width,
            height: CGFloat(videos.count) * videoHeight
        )
        
        DispatchQueue.main.async {
            scrollView.setContentOffset(
                CGPoint(x: 0, y: CGFloat(self.currentIndex) * self.videoHeight),
                animated: false
            )
        }
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        guard let containerView = uiView.subviews.first else { return }
        
        for case let videoContainer as VideoContainerView in containerView.subviews {
            let index = videoContainer.tag
            if let player = players[index] {
                videoContainer.updatePlayer(player)
            } else {
                videoContainer.showPlaceholder()
            }
        }
        
        let contentHeight = CGFloat(videos.count) * videoHeight
        if uiView.contentSize.height != contentHeight {
            uiView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: contentHeight)
            
            for case let videoContainer as VideoContainerView in containerView.subviews {
                let index = videoContainer.tag
                videoContainer.frame = CGRect(
                    x: 0,
                    y: CGFloat(index) * videoHeight,
                    width: UIScreen.main.bounds.width,
                    height: videoHeight
                )
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        var parent: MagneticVideoScrollView
        private var lastIndex: Int = -1
        
        init(_ parent: MagneticVideoScrollView) {
            self.parent = parent
        }
        
        func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            let targetOffset = targetContentOffset.pointee.y
            let index = round(targetOffset / parent.videoHeight)
            let adjustedOffset = index * parent.videoHeight
            
            targetContentOffset.pointee.y = adjustedOffset
            
            let newIndex = Int(index)
            if newIndex != parent.currentIndex {
                parent.currentIndex = newIndex
                parent.onIndexChange?(newIndex)
            }
        }
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            let index = Int(round(scrollView.contentOffset.y / parent.videoHeight))
            updateCurrentIndex(index)
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let currentOffset = scrollView.contentOffset.y
            let index = Int(round(currentOffset / parent.videoHeight))
            
            if index != lastIndex {
                updateCurrentIndex(index)
            }
        }
        
        private func updateCurrentIndex(_ index: Int) {
            guard index >= 0 && index < parent.videos.count else { return }
            
            if index != lastIndex {
                lastIndex = index
                parent.currentIndex = index
                parent.onIndexChange?(index)
            }
        }
    }
}
