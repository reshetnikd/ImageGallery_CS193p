//
//  ImageCollectionViewCell.swift
//  ImageGallery
//
//  Created by Dmitry Reshetnik on 30.04.2020.
//  Copyright © 2020 Dmitry Reshetnik. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var imageURL: URL? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        if let url = imageURL {
            imageView.image = nil
            spinner.startAnimating()
            
            let contents = try? Data(contentsOf: url)
            
            if let imageData = contents {
                let image = UIImage(data: imageData)
                imageView.image = image
                // Set color for size debugging purposes.
                imageView.backgroundColor = .black
            }
            
            spinner.stopAnimating()
        }
    }
    
}
