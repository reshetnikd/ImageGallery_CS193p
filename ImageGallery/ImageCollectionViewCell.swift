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
            setImageForCell()
        }
    }
    
    private func setImageForCell() {
        if let url = imageURL {
            imageView.image = nil
            spinner.startAnimating()
            
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
                let contents = try? Data(contentsOf: url)
                
                DispatchQueue.main.sync {
                    if let imageData = contents, url == self.imageURL {
                        let image = UIImage(data: imageData)
                        self.imageView.image = image
                        // Set color for size debugging purposes.
                        self.imageView.backgroundColor = .black
                    }
                    
                    self.spinner.stopAnimating()
                }
            }
        }
    }
    
}
