//
//  VisualEffectiveView.swift
//  Productlab
//
//  Created by Pavel Mac on 10/15/25.
//

import SwiftUI

struct VisualEffectView: UIViewRepresentable {
    var effect: UIBlurEffect
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: effect)
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = effect
    }
}
