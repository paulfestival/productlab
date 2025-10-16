//
//  Collection.swift
//  Productlab
//
//  Created by Pavel Mac on 10/14/25.
//

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
