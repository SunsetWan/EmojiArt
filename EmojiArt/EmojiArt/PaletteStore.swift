//
//  PaletteStore.swift
//  EmojiArt
//
//  Created by sunsetwan on 2022/5/29.
//

import SwiftUI

/// Model
struct Palette: Identifiable, Codable, Hashable {
    let id: Int
    var name: String
    var emojis: String
    
    fileprivate init(id: Int, name: String, emojis: String) {
        self.id = id
        self.name = name
        self.emojis = emojis
    }
}

/// ViewModel
class PaletteStore: ObservableObject {
    let name: String
    
    @Published var palettes = [Palette]() {
        didSet {
            storeInUserDefaults()
        }
    }
    
    private var userDefaultsKey: String {
        "PaletteStore" + name
    }
    private func storeInUserDefaults() {
        UserDefaults.standard.set(try? JSONEncoder().encode(palettes),
                                  forKey: userDefaultsKey)
    }
    
    private func restoreFromUserDefaults() {
        if let jsonData = UserDefaults.standard.data(forKey: userDefaultsKey),
            let decodedPalettes = try? JSONDecoder().decode([Palette].self, from: jsonData)  {
            palettes = decodedPalettes
        }
    }
    
    init(named name: String) {
        self.name = name
        restoreFromUserDefaults()
        if palettes.isEmpty {
            print("Using built-in palettes")
            insertPalette(named: "all", emojis: "🤡👐🙌👹👽👺🎃😼🧠👣👀🗣🫀🫁🫂👩‍🦳👱‍♂️👶🧔‍♀️👮‍♀️👮👷‍♀️💂‍♀️👩‍⚕️🕵️👩‍🎓👨‍🍳👨‍🎤👩‍🏭🐧🐵🐥🐣🐒🐸🦊🐼🦐🐟🦭🦈🐆🦧🌵")
            insertPalette(named: "faces", emojis: "🤯😳🥵🥶😶‍🌫️")
            insertPalette(named: "joker", emojis: "👺🤡💩👻💀")
            insertPalette(named: "cars", emojis: "🚗🚕🚙🚌🚎🚐🚒🚑🚓🏎🛻🚚🚛🚜")
            insertPalette(named: "sports", emojis: "⚽️🏀🏈⚾️🥎🎱🥏🏉🏐🎾")
        } else {
            print("Successfully loaded palettds from UserDefaults: \(palettes)")
        }
    }
    
    /// MARK: - Intent
    
    func palette(at index: Int) -> Palette {
        let safeIndex = min(max(index, 0), palettes.count - 1)
        return palettes[safeIndex]
    }
    
    @discardableResult
    func removePalette(at index: Int) -> Int {
        if palettes.count > 1, palettes.indices.contains(index) {
            palettes.remove(at: index)
        }
        return index % palettes.count
    }
    
    func insertPalette(named name: String,
                       emojis: String? = nil,
                       at index: Int = 0)
    {
        let unique = (palettes.max(by: { $0.id < $1.id })?.id ?? 0 ) + 1
        let palette = Palette(id: unique,
                              name: name,
                              emojis: emojis ?? "")
        let safeIndex = min(max(index, 0), palettes.count)
        palettes.insert(palette, at: safeIndex)
    }
}
