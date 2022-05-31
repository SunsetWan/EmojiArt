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
            nameSection
            addEmojisSection
        }
        .frame(minWidth: 300, minHeight: 350)
        .navigationTitle("Edit: \(palette.name)")
    }
    
    var nameSection: some View {
        Section {
            TextField("Name", text: $palette.name)
        } header: {
            Text("Name")
        }
    }
    
    @State private var emojisToAdd = ""
    var addEmojisSection: some View {
        Section {
            TextField("", text: $emojisToAdd)
                .onChange(of: emojisToAdd) { emojis in
                    addEmojis(emojis)
                }
//                .keyboardType(.webSearch)
//                .autocapitalization(<#T##style: UITextAutocapitalizationType##UITextAutocapitalizationType#>)
//                .disableAutocorrection(<#T##disable: Bool?##Bool?#>)
//                .lineLimit(<#T##number: Int?##Int?#>)
//                .textContentType(.addressCity)
        } header: {
            Text("Add Emojis")
        }
    }
    
    func addEmojis(_ newEmojis: String) {
        withAnimation {
            palette.emojis = (newEmojis + palette.emojis)
                .filter { $0.isEmoji }
            /// should also remove duplicate characters
        }
    }
    
    var removeEmojisSection: some View {
        Text("Fix me!")
    }
}

struct PaletteEditor_Previews: PreviewProvider {
    static var previews: some View {
        /// This is where **constant Bindings** really come in handy!
        PaletteEditor(palette: .constant(PaletteStore(named: "Preview").palette(at: 1)))
            .previewLayout(.fixed(width: 300, height: 350))
    }
}
