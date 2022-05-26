//
//  UtilityExtensions.swift
//  EmojiArt
//
//  Created by sunsetwan on 2022/5/26.
//

import Foundation

extension Collection where Element: Identifiable {
    func index(matching element: Element) -> Self.Index? {
        firstIndex(where: { $0.id == element.id })
    }
}
