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

struct AnimatedActionButton: View {
    var title: String?
    var systemImage: String?
    let action: () -> Void
    
    var body: some View {
        Button {
            withAnimation {
                action()
            }
        } label: {
            if title != nil && systemImage != nil {
                Label(title!, systemImage: systemImage!)
            } else if title != nil {
                Text(title!)
            } else if systemImage != nil {
                Image(systemName: systemImage!)
            }
        }
    }
}
