//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by sunsetwan on 2022/5/26.
//

import SwiftUI

/// ViewModel
class EmojiArtDocument: ObservableObject {
    @Published private(set) var emojiArt: EmojiArtModel
    
    init() {
        emojiArt = EmojiArtModel()
    }
    
    var emojis: [EmojiArtModel.Emoji] { emojiArt.emojis }
    var background: EmojiArtModel.Background { emojiArt.backgrund }
    
    
    /// MARK: - Intent(s)
    
    func setBackground(_ background: EmojiArtModel.Background) {
        emojiArt.backgrund = background
    }
    
    func addEmoji(_ text: String,
                  at location: (x: Int, y: Int),
                  size: Int)
    {
        emojiArt.addEmoji(text,
                          at: location,
                          size: size)
    }
    
    func moveEmoji(_ emoji: EmojiArtModel.Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArtModel.Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            let c = CGFloat(emojiArt.emojis[index].size) * scale
            emojiArt.emojis[index].size = Int(c.rounded(.toNearestOrAwayFromZero))
        }
    }
    
}
