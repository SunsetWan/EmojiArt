//
//  PaletteManager.swift
//  EmojiArt
//
//  Created by sunsetwan on 2022/5/31.
//

import SwiftUI

struct PaletteManager: View {
    @EnvironmentObject var store: PaletteStore
    
    /// About the other keyPath,
    /// please check `EnvironmentValues` documentation
    /// can get/set
    @Environment(\.colorScheme) var colorScheme
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var editMode: EditMode = .inactive
    
    /// FIXME: this animateFont didn't work!
    /// [IMPORTANT]: Font size is not animatable by default.
    /// 🔗: https://stackoverflow.com/questions/63027193/how-can-i-animate-the-font-size-of-text-from-largetitle-to-headline
    private func animateFont(_ editMode: EditMode) -> Font {
        withAnimation(.linear(duration: 3)) {
            if editMode == .active {
                return .largeTitle
            } else {
                return .caption
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(store.palettes) { palette in
                    /// NavigationLink only work when they're inside a NavigationView
                    NavigationLink {
                        PaletteEditor(palette: $store.palettes[palette])
                    } label: {
                        VStack(alignment: .leading) {
                            Text(palette.name).font(animateFont(editMode))
                            Text(palette.emojis)
                        }
                        /// set gesture when editMode is `.active`
                        .gesture(editMode == .active ? tap : nil)
                    }
                }
                .onDelete { indexSet in // belong to `ForEach`
                    store.palettes.remove(atOffsets: indexSet)
                }
                .onMove { indexSet, newOffset in
                    store.palettes.move(fromOffsets: indexSet, toOffset: newOffset)
                }
            }
            .navigationTitle("Manage Palettes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem {
                    EditButton() // automatically track `editMode`
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    /// `presentationMode` is just a Binding var,
                    /// and why?
                    if presentationMode.wrappedValue.isPresented,
                        UIDevice.current.userInterfaceIdiom != .pad
                    {
                        Button("Close") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                
            })
//            .environment(\.colorScheme, .dark)
            .environment(\.editMode, $editMode)
        }
    }
    
    var tap: some Gesture {
        TapGesture().onEnded { _ in
            
        }
    }
}

struct PaletteManager_Previews: PreviewProvider {
    static var previews: some View {
        PaletteManager()
            .environmentObject(PaletteStore(named: "Preview"))
//            .preferredColorScheme(.light)
    }
}
