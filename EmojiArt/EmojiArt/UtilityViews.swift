//
//  UtilityViews.swift
//  EmojiArt
//
//  Created by sunsetwan on 2022/5/26.
//

import Foundation
import SwiftUI

struct OptionalImage: View {
    var uiImage: UIImage?
    
    var body: some View {
        if let image = uiImage {
            Image(uiImage: image)
        }
    }
}
