//
//  VideoContainerView.swift
//  Productlab
//
//  Created by Pavel Mac on 10/15/25.
//

import SwiftUI
import AVKit

final class VideoContainerView: UIView {
    private var playerLayer: AVPlayerLayer?
    private let placeholder: UIImageView = {
        let img = UIImageView(image: UIImage(systemName: "play.fill"))
        img.tintColor = .white
        img.contentMode = .scaleAspectFit
        return img
    }()
    
    var player: AVPlayer? {
        didSet {
            playerLayer?.player = player
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .black
        addSubview(placeholder)
        placeholder.frame = bounds
        placeholder.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let layer = AVPlayerLayer()
        layer.videoGravity = .resizeAspectFill
        layer.frame = bounds
        self.layer.addSublayer(layer)
        playerLayer = layer
    }
    
    func updatePlayer(_ player: AVPlayer) {
        placeholder.isHidden = true
        self.player = player
        setNeedsLayout()
    }
    
    func showPlaceholder() {
        player = nil
        placeholder.isHidden = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
        placeholder.frame = bounds
    }
}
