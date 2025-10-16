//
//  MagneticScrollView.swift
//  Productlab
//
//  Created by Pavel Mac on 10/16/25.
//

import SwiftUI
import UIKit

struct MagneticScrollView: UIViewRepresentable {
    let videos: [Video]
    let onVideoTap: (Int) -> Void
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.isPagingEnabled = false
        scrollView.decelerationRate = .fast
        scrollView.showsVerticalScrollIndicator = false
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        
        for (index, video) in videos.enumerated() {
            let hostingController = UIHostingController(rootView: VideoCard(video: video))
            hostingController.view.backgroundColor = .clear
            hostingController.view.frame = CGRect(x: 0, y: 0, width: 300, height: 550)
            
            let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
            hostingController.view.addGestureRecognizer(tapGesture)
            hostingController.view.tag = index
            
            stackView.addArrangedSubview(hostingController.view)
        }
        
        scrollView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        //
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        var parent: MagneticScrollView
        
        init(_ parent: MagneticScrollView) {
            self.parent = parent
        }
        
        func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            let cardHeight: CGFloat = 550
            let spacing: CGFloat = 20
            let totalItemHeight = cardHeight + spacing
            
            let targetOffset = targetContentOffset.pointee.y
            let index = round((targetOffset + scrollView.bounds.height / 2 - cardHeight / 2) / totalItemHeight)
            let adjustedOffset = index * totalItemHeight - (scrollView.bounds.height / 2 - cardHeight / 2)
            
            targetContentOffset.pointee.y = adjustedOffset
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            if let index = gesture.view?.tag {
                parent.onVideoTap(index)
            }
        }
    }
}


