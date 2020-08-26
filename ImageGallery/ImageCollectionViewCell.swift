//
//  ImageCollectionViewCell.swift
//  ImageGallery
//
//  Created by Dmitry Reshetnik on 30.04.2020.
//  Copyright © 2020 Dmitry Reshetnik. All rights reserved.
//

import UIKit

let cache: URLCache = URLCache.shared

/*
let cache: URLCache = URLCache(
    memoryCapacity: 5 * 1024 * 1024,
    diskCapacity: 30 * 1024 * 1024,
    diskPath: nil
)
 */

class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var imageURL: URL? {
        didSet {
            setImageForCell()
        }
    }
    
    private func setImageForCell() {
        guard let url = imageURL else { return }
        let request: URLRequest = URLRequest(url: url)
        imageView.image = nil
        spinner.startAnimating()
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
            if let data = cache.cachedResponse(for: request)?.data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.imageView?.image = image
                    self.spinner?.stopAnimating()
                }
            } else {
                URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                    if let data = data, let response = response {
                        if ((response as? HTTPURLResponse)?.statusCode ?? 500) < 300 {
                            if let image = UIImage(data: data), url == self.imageURL {
                                let cachedData = CachedURLResponse(response: response, data: data)
                                cache.storeCachedResponse(cachedData, for: request)
                                DispatchQueue.main.async {
                                    self.imageView?.image = image
                                    self.spinner?.stopAnimating()
                                }
                            } else {
                                print("Error loading image.")
                                self.spinner?.stopAnimating()
                            }
                        }
                    }
                    }).resume()
            }
        }
        spinner?.stopAnimating()
    }
    
}
