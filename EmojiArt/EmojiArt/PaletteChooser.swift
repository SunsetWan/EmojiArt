//
//  PaletteChooser.swift
//  EmojiArt
//
//  Created by sunsetwan on 2022/5/30.
//

import SwiftUI

struct PaletteChooser: View {
    var emojiFontSize: CGFloat = 40
    var emojiFont: Font { .system(size: emojiFontSize) }
    
    @EnvironmentObject var store: PaletteStore
    
    var body: some View {
        let palette = store.palette(at: 3)
        HStack {
            Text(palette.name)
            ScrollingEmojisView(emojis: palette.emojis)
                .font(.system(size: emojiFontSize))
        }
    }
}


struct ScrollingEmojisView: View {
    let emojis: String
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(emojis.map { String($0) }, id: \.self) { emoji in
                    Text(emoji)
                        .frame(alignment: .center)
                        .onDrag {
                            NSItemProvider(object: emoji as NSString)
                        }
                }
            }
            
        }
    }
}

struct PaletteChooser_Previews: PreviewProvider {
    static var previews: some View {
        PaletteChooser()
    }
}
