//
//  Image.swift
//  Productlab
//
//  Created by Pavel Mac on 10/14/25.
//

import SwiftUI

extension Image {
    @MainActor func asUIImage() -> UIImage {
        let renderer = ImageRenderer(content: self)
        return renderer.uiImage ?? UIImage()
    }
}
