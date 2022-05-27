//
//  EmojiArtModel.Background.swift
//  EmojiArt
//
//  Created by sunsetwan on 2022/5/26.
//

import Foundation

extension EmojiArtModel {
    /// 🔗：https://sarunw.com/posts/codable-synthesis-for-enums-with-associated-values-in-swift/
    enum Background: Equatable, Codable {
        case blank
        case url(URL)
        case imageData(Data)
        
        private enum CodingKeys: String, CodingKey {
            case blank
            case url = "theURL"
            case imageData
        }
        
        var url: URL? {
            switch self {
            case .url(let url): return url
            default: return nil
            }
        }
        
        var imageData: Data? {
            switch self {
            case .imageData(let data): return data
            default: return nil
            }
        }
    }
}
