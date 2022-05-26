//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by sunsetwan on 2022/5/26.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    let document = EmojiArtDocument()
    
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentView(document: document)
        }
    }
}
