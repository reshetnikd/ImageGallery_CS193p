//
//  ImageGallery.swift
//  ImageGallery
//
//  Created by Dmitry Reshetnik on 27.04.2020.
//  Copyright © 2020 Dmitry Reshetnik. All rights reserved.
//

import UIKit

struct ImageGallery: Codable {
    struct Image: Codable {
        let url: URL
        let aspectRatio: CGFloat
    }
    
    var images: [Image] = []
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    init() {
        self.images = [Image]()
    }
    
    init?(with data: Data) {
        if let newValue = try? JSONDecoder().decode(ImageGallery.self, from: data) {
            self = newValue
        } else {
            return nil
        }
    }
}
