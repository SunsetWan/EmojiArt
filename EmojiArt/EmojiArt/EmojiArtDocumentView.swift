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
            PaletteChooser(emojiFontSize: defaultEmojiFontSize)
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
            /// Note: never putting more than one `.gesture` on any one View simultaneously!
            .gesture(panGesture().simultaneously(with: zoomGesture()))
            .alert(item: $alertToShow) { alertToShow in
                alertToShow.alert()
            }
            .onChange(of: document.backgroundImageFetchStatus) { status in
                switch status {
                case .failed(let url):
                    showBackgroundImageFetchFailedAlert(url)
                default:
                    break
                }
            }
        }
    }
    
    @State private var alertToShow: IdentifiableAlert?
    private func showBackgroundImageFetchFailedAlert(_ url: URL) {
        alertToShow = IdentifiableAlert(id: "fetch failed" + url.absoluteString,
                                        alert: {
            Alert(
                title: Text("Background Image Fetch"),
                message: Text("Couldn't load image from \(url)"),
                dismissButton: .cancel(Text("OK"))
            )
        })
    }
    
    @State private var steadyStatePanOffset: CGSize = .zero
    @GestureState private var gesturePanOffset: CGSize = .zero
    
    private var panOffset: CGSize {
        (steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset, body: { latestDragGestureValue, gesturePanOffsetInOut, _ in
                    gesturePanOffsetInOut = latestDragGestureValue.translation / zoomScale
            })
            .onEnded { finalDragGestureValue in
                steadyStatePanOffset = steadyStatePanOffset + (finalDragGestureValue.translation / zoomScale)
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
            steadyStatePanOffset = .zero
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
        let location = CGPoint(
            x: (location.x - panOffset.width - center.x) / zoomScale,
            y: (location.y - panOffset.height - center.y) / zoomScale
        )
        
        return (Int(location.x), Int(location.y))
    }
    
    private func convertFromEmojiCoordinates(_ location: (x: Int, y: Int),
                                             in geometry: GeometryProxy) -> CGPoint
    {
        let center = geometry.frame(in: .local).center
        return CGPoint(
            x: center.x + CGFloat(location.x) * zoomScale + panOffset.width,
            y: center.y + CGFloat(location.y) * zoomScale + panOffset.height
        )
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











struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(document: EmojiArtDocument())
    }
}
