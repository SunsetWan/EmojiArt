//
//  UtilityExtensions.swift
//  EmojiArt
//
//  Created by sunsetwan on 2022/5/26.
//

import Foundation
import SwiftUI

extension Collection where Element: Identifiable {
    func index(matching element: Element) -> Self.Index? {
        firstIndex(where: { $0.id == element.id })
    }
}


extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}

extension Array where Element == NSItemProvider {
    func loadObjects<T>(ofType theType: T.Type,
                        firstOnly: Bool = false,
                        using load: @escaping (T) -> Void) -> Bool where T: NSItemProviderReading
    {
        if let provider = first(where: { $0.canLoadObject(ofClass: theType) }) {
            provider.loadObject(ofClass: theType) { object, error in
                if let value = object as? T {
                    DispatchQueue.main.async {
                        load(value)
                    }
                }
            }
            return true
        }
        return false
    }
    
    func loadObjects<T>(ofType theType: T.Type,
                        firstOnly: Bool = false,
                        using load: @escaping (T) -> Void) -> Bool where T: _ObjectiveCBridgeable, T._ObjectiveCType: NSItemProviderReading
    {
        if let provider = first(where: { $0.canLoadObject(ofClass: theType) }) {
            let _ = provider.loadObject(ofClass: theType) { object, error in
                if let value = object {
                    DispatchQueue.main.async {
                        load(value)
                    }
                }
            }
            return true
        }
        return false
    }
}

extension Character {
    var isEmoji: Bool {
        if let firstScalar = unicodeScalars.first, firstScalar.properties.isEmoji {
            return (firstScalar.value >= 0x238d || unicodeScalars.count > 1)
        } else {
            return false
        }
    }
}
