//
//  PaletteEditor.swift
//  EmojiArt
//
//  Created by sunsetwan on 2022/5/31.
//

import SwiftUI

struct PaletteEditor: View {
    /// By the way, we never say Binding equal to something
    /// Bindings are always passed to us, by definition.
    /// Binding can't be private!!!
    /// A Binding, remember, is just getting and setting a value
    @Binding var palette: Palette
    
    var body: some View {
        Form {
            TextField("Name", text: $palette.name)
        }
        .frame(minWidth: 300, minHeight: 350)
    }
}

struct PaletteEditor_Previews: PreviewProvider {
    static var previews: some View {
        Text("Fix me!")
//        PaletteEditor()
            .previewLayout(.fixed(width: 300, height: 350))
    }
}
