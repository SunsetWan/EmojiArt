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
    @State private var chosenPaletteIndex = 0
    
    var body: some View {
        HStack {
            paletteControlButton
            body(for: store.palette(at: chosenPaletteIndex))
        }
        .clipped()
    }
    
    var paletteControlButton: some View {
        Button {
            withAnimation {
                chosenPaletteIndex = (chosenPaletteIndex + 1) % store.palettes.count
            }
        } label: {
            Image(systemName: "paintpalette")
        }
        .font(emojiFont)
        .contextMenu{ contextMenu }
    }
    
    @ViewBuilder
    var contextMenu: some View {
        AnimatedActionButton(title: "Edit", systemImage: "pencil") {
//            editing = true
            paletteToEdit = store.palette(at: chosenPaletteIndex)
        }
        AnimatedActionButton(title: "New", systemImage: "plus") {
            store.insertPalette(named: "New", emojis: "", at: chosenPaletteIndex)
//            editing = true
            paletteToEdit = store.palette(at: chosenPaletteIndex)
        }
        AnimatedActionButton(title: "Delete", systemImage: "minus.circle") {
            chosenPaletteIndex = store.removePalette(at: chosenPaletteIndex)
        }
        gotoMenu
    }
    
    var gotoMenu: some View {
        Menu {
            ForEach(store.palettes) { palette in
                AnimatedActionButton(title: palette.name) {
                    if let index = store.palettes.index(matching: palette) {
                        chosenPaletteIndex = index
                    }
                }
            }
        } label: {
            Label("Go To", systemImage: "text.insert")
        }
    }
    
    private func body(for palette: Palette) -> some View {
        HStack {
            Text(palette.name)
                .frame(alignment: .center)
            ScrollingEmojisView(emojis: palette.emojis)
                .font(.system(size: emojiFontSize))
        }
        /// What's the trick?
        /// Lecture 12 [36: 35]
        .id(palette.id)
        .transition(rollTransition)
//        .popover(isPresented: $editing) { // or can use `sheet`
//            PaletteEditor(palette: $store.palettes[chosenPaletteIndex])
//        }
        .popover(item: $paletteToEdit) { palette in
            PaletteEditor(palette: $store.palettes[palette])
        }
    }
    
    @State private var editing = false
    @State private var paletteToEdit: Palette?
    var rollTransition: AnyTransition {
        AnyTransition.asymmetric(insertion: .offset(x: 0, y: emojiFontSize),
                                 removal: .offset(x: 0, y: -emojiFontSize))
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
