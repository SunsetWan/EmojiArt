//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by sunsetwan on 2022/5/26.
//

import SwiftUI

/// ViewModel
class EmojiArtDocument: ObservableObject {
    @Published private(set) var emojiArt: EmojiArtModel {
        didSet {
            scheduleAutosave()
            if emojiArt.backgrund != oldValue.backgrund {
                fetchBackgroundImageDataIfNecessary()
            }
        }
    }
    
    private struct Autosave {
        static let fileName = "Autosaved.emojiart"
        static var url: URL? {
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            return documentDirectory?.appendingPathComponent(fileName)
        }
        
        static let coalescingInterval: TimeInterval = 5.0
        
        private init() {}
    }
    
    private var autosaveTimer: Timer?
    private func scheduleAutosave() {
        autosaveTimer?.invalidate()
        autosaveTimer = Timer.scheduledTimer(withTimeInterval: Autosave.coalescingInterval, repeats: false) { [self] _ in
            self.autosave()
        }
    }
    
    private func autosave() {
        if let url = Autosave.url {
            save(to: url)
        }
    }
    
    private func save(to url: URL) {
        let thisFunction = "\(String(describing: self)).\(#function)"
        do {
            let data = try emojiArt.json()
            print("\(thisFunction) json = \(String(data: data, encoding: .utf8) ?? "nil")")
            try data.write(to: url)
            print("\(thisFunction) success!")
        } catch let encodingError where encodingError is EncodingError {
            print("\(thisFunction) EncodingError: \(encodingError.localizedDescription)")
        } catch let error {
            print("\(thisFunction) error = \(error)")
        }
    }
    
    init() {
        if let url = Autosave.url, let autosavedEmojiArt = try? EmojiArtModel(url: url) {
            emojiArt = autosavedEmojiArt
            fetchBackgroundImageDataIfNecessary()
        } else {
            emojiArt = EmojiArtModel()
            emojiArt.addEmoji("🐲", at: (-200, -100), size: 90)
            emojiArt.addEmoji("🦩", at: (50, 100), size: 40)
        }
    }
    
    var emojis: [EmojiArtModel.Emoji] { emojiArt.emojis }
    var background: EmojiArtModel.Background { emojiArt.backgrund }
    
    @Published var backgroundImage: UIImage?
    @Published var backgroundImageFetchStatus: BackgroundImageFetchStatus = .idle
    
    enum BackgroundImageFetchStatus {
        case idle
        case fetching
    }
    
    private func fetchBackgroundImageDataIfNecessary() {
        backgroundImage = nil
        switch emojiArt.backgrund {
        case .url(let url):
            // fetch the url
            backgroundImageFetchStatus = .fetching
            DispatchQueue.global(qos: .userInitiated).async {
                let imageData = try? Data(contentsOf: url) // this will block UI
                DispatchQueue.main.async { [weak self] in
                    if self?.emojiArt.backgrund == .url(url) {
                        self?.backgroundImageFetchStatus = .idle
                        if let imageData = imageData {
                            self?.backgroundImage = UIImage(data: imageData)
                        }
                    }
                }
            }
        case .imageData(let data):
            backgroundImage = UIImage(data: data)
        case .blank:
            break
        }
    }
    
    
    /// MARK: - Intent(s)
    
    func setBackground(_ background: EmojiArtModel.Background) {
        emojiArt.backgrund = background
        print("background set to \(background)")
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
