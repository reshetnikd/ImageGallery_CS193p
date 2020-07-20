//
//  ImageGallery.swift
//  ImageGallery
//
//  Created by Dmitry Reshetnik on 27.04.2020.
//  Copyright © 2020 Dmitry Reshetnik. All rights reserved.
//

import UIKit

class ImageGallery: Codable {
    struct Image: Codable {
        let url: URL
        let aspectRatio: CGFloat
    }
    
    var name: String
    var images: [Image] = []
    
    init(name: String) {
        self.name = name
    }
}
