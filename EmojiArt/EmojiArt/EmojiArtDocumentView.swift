//
//  ContentView.swift
//  EmojiArt
//
//  Created by sunsetwan on 2022/5/26.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    
    let defaultEmojiFontSize: CGFloat = 40
    
    var body: some View {
        VStack(spacing: 0) {
            documentBody
            palette
        }
    }
    
    var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white.overlay(
                    OptionalImage(uiImage: document.backgroundImage)
                        .scaleEffect(zoomScale)
                        .position(convertFromEmojiCoordinates((0, 0), in: geometry))
                )
                .gesture(doubleTapToZoom(in: geometry.size))
                if document.backgroundImageFetchStatus == .fetching {
                    ProgressView()
                        .scaleEffect(2)
                } else {
                    ForEach(document.emojis) { emoji in
                        Text(emoji.text)
                            .font(.system(size: fontSize(for: emoji)))
                            .scaleEffect(zoomScale)
                            .position(position(for: emoji, in: geometry))
                    }
                }
            }
            .clipped()
            .onDrop(of: [.plainText, .url, .image], isTargeted: nil) { providers, location in
                drop(providers: providers,
                     at: location,
                     in: geometry)
            }
            .gesture(zoomGesture())
        }
    }
        
    @State private var steadyStateZoomScale: CGFloat = 1
    
    /// You can store whatever information you need for your View to update during the gesture
    /// For example, during a drag, maybe you store how far the finger has moved
    /// **IMPORTANT**: this var will always return to `starting value` when the gesture ends
    @GestureState private var gestureZoomScale: CGFloat = 1 // 1 is `starting value`
    
    private var zoomScale: CGFloat {
        steadyStateZoomScale * gestureZoomScale
    }
    
    /// Note: when you're designing Gesture code,
    /// the most important thing is to understand
    /// what state is actually changing while the gesture is in flight!
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale, body: { latestGestureScale, ourGestureStateInOut, _ in
                // This is the **ONLY** place you can change your @GestureState!
                ourGestureStateInOut = latestGestureScale
            })
            .onEnded { gestureScaleAtEnd in
                steadyStateZoomScale *= gestureScaleAtEnd
            }
    }
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation {
                    zoomToFit(document.backgroundImage, in: size)
                }
            }
    }

    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image,
            image.size.width > 0,
            image.size.height > 0,
            size.width > 0,
            size.height > 0
        {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            steadyStateZoomScale = min(hZoom, vZoom)
        }
    }
    
    private func drop(providers: [NSItemProvider],
                      at location: CGPoint,
                      in geometry: GeometryProxy) -> Bool
    {
        var found = providers.loadObjects(ofType: URL.self) { url in
            document.setBackground(.url(url.imageURL))
        }
        
        if !found {
            found = providers.loadObjects(ofType: UIImage.self) { image in
                if let data = image.jpegData(compressionQuality: 1.0) {
                    document.setBackground(.imageData(data))
                }
            }
        }
        
        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                if let emoji = string.first, emoji.isEmoji {
                    document.addEmoji(String(emoji),
                                      at: convertToEmojiCoordinates(location, in: geometry),
                                      size: Int(defaultEmojiFontSize / zoomScale))
                }
            }
        }
        
        return found
    }
    
    private func position(for emoji: EmojiArtModel.Emoji,
                          in geometry: GeometryProxy) -> CGPoint
    {
        convertFromEmojiCoordinates((emoji.x, emoji.y), in: geometry)
    }
    
    private func convertToEmojiCoordinates(_ location: CGPoint,
                                           in geometry: GeometryProxy) -> (x: Int, y: Int)
    {
        let center = geometry.frame(in: .local).center
        let location = CGPoint(x: (location.x - center.x) / zoomScale,
                               y: (location.y - center.y) / zoomScale)
        
        return (Int(location.x), Int(location.y))
    }
    
    private func convertFromEmojiCoordinates(_ location: (x: Int, y: Int),
                                             in geometry: GeometryProxy) -> CGPoint
    {
        let center = geometry.frame(in: .local).center
        return CGPoint(x: center.x + CGFloat(location.x) * zoomScale,
                       y: center.y + CGFloat(location.y) * zoomScale)
    }
    
    
    private func fontSize(for emoji: EmojiArtModel.Emoji) -> CGFloat {
        CGFloat(emoji.size)
    }
    
    var palette: some View {
        ScrollingEmojisView(emojis: testEmojis)
            .font(.system(size: defaultEmojiFontSize))
    }
    
    let testEmojis = "🤡👐🙌👹👽👺🎃😼🧠👣👀🗣🫀🫁🫂👩‍🦳👱‍♂️👶🧔‍♀️👮‍♀️👮👷‍♀️💂‍♀️👩‍⚕️🕵️👩‍🎓👨‍🍳👨‍🎤👩‍🏭🐧🐵🐥🐣🐒🐸🦊🐼🦐🐟🦭🦈🐆🦧🌵"
}


struct ScrollingEmojisView: View {
    let emojis: String
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(emojis.map { String($0) }, id: \.self) { emoji in
                    Text(emoji)
                        .onDrag {
                            NSItemProvider(object: emoji as NSString)
                        }
                }
            }
        }
    }
}








struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(document: EmojiArtDocument())
    }
}
