//
//  EmojiArtModel.swift
//  EmojiArt
//
//  Created by sunsetwan on 2022/5/26.
//

import Foundation

struct EmojiArtModel {
    var backgrund: Background = .blank
    var emojis = [Emoji]()
    
    struct Emoji: Identifiable, Hashable {
        fileprivate init(text: String,
                         x: Int,
                         y: Int,
                         size: Int,
                         id: Int)
        {
            self.text = text
            self.x = x
            self.y = y
            self.size = size
            self.id = id
        }
        
        let text: String
        var x: Int // offset from the center
        var y: Int // offset from the center
        var size: Int
        let id: Int
    }
    
    private var uniqueEmojiId = 0
    
    init() {}
    
    mutating func addEmoji(_ text: String,
                  at location: (x: Int, y: Int),
                  size: Int)
    {
        uniqueEmojiId += 1
        emojis.append(Emoji(text: text,
                            x: location.x,
                            y: location.y,
                            size: size,
                            id: uniqueEmojiId))
    }
}
