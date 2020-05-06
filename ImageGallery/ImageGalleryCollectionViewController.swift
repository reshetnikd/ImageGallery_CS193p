//
//  ImageGalleryCollectionViewController.swift
//  ImageGallery
//
//  Created by Dmitry Reshetnik on 27.04.2020.
//  Copyright © 2020 Dmitry Reshetnik. All rights reserved.
//

import UIKit

//private let reuseIdentifier = "Cell"

class ImageGalleryCollectionViewController: UICollectionViewController, UICollectionViewDragDelegate, UICollectionViewDropDelegate, UICollectionViewDelegateFlowLayout {
    var gallery = ImageGallery(name: "Untitled")
    
    var flowLayout: UICollectionViewFlowLayout? {
        return collectionView.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    var scale: CGFloat = 1 {
        didSet {
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create model instance for debugging purposes.
        gallery.images = [
            ImageGallery.Image(url: URL(string: "https://images.unsplash.com/photo-1494548162494-384bba4ab999?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80")!, aspectRatio: 0.625),
            ImageGallery.Image(url: URL(string: "https://images.unsplash.com/photo-1533387520709-752d83de3630?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=668&q=80")!, aspectRatio: 0.75),
            ImageGallery.Image(url: URL(string: "https://images.unsplash.com/7/tuscany.jpg?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjExMDk0fQ&auto=format&fit=crop&w=1651&q=80")!, aspectRatio: 1.4)
        ]

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        // self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        collectionView.dragInteractionEnabled = true
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
    }
    
    // MARK: Drag and Drop
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return []
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        
    }

    // MARK: Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == "Show Image" {
            if let cell = sender as? ImageCollectionViewCell {
                if let imageViewController = segue.destination.contents as? ImageViewController {
                    imageViewController.imageURL = cell.imageURL
                }
            }
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gallery.images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Image Cell", for: indexPath)
    
        // Configure the cell
        if let imageCell = cell as? ImageCollectionViewCell {
            imageCell.imageURL = gallery.images[indexPath.item].url
        }
    
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    @IBAction func zoom(_ sender: UIPinchGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.changed {
            scale *= sender.scale
            sender.scale = 1.0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let width = flowLayout?.itemSize.width {
            return CGSize(width: width * scale, height: width * scale / gallery.images[indexPath.item].aspectRatio)
        } else {
            return CGSize.zero
        }
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
