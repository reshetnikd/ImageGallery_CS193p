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
    var gallery: ImageGallery = ImageGallery() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var flowLayout: UICollectionViewFlowLayout? {
        return collectionView.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    var scale: CGFloat = 1 {
        didSet {
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    var thumbnailImage: UIImageView? {
        return (self.collectionView!.cellForItem(at: IndexPath(item: 0, section: 0)) as? ImageCollectionViewCell)?.imageView
    }
    
    var garbadgeView: GarbageView = GarbageView()
    var document: ImageGalleryDocument?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        // self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        collectionView.dragInteractionEnabled = true
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        collectionView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(zoom(_:))))
//        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let navigationBounds = navigationController?.navigationBar.bounds {
            garbadgeView.garbageViewDidChanged = { [weak self] in
                self?.documentChanged()
            }
            garbadgeView.frame = CGRect(x: navigationBounds.width * 0.6, y: 0.0, width: navigationBounds.width * 0.4, height: navigationBounds.height)
            
            let barButton = UIBarButtonItem(customView: garbadgeView)
            navigationItem.rightBarButtonItem = barButton
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        document?.open(completionHandler: { (success) in
            if success {
                self.title = self.document?.localizedName
                self.gallery = self.document?.imageGallery ?? ImageGallery()
            }
        })
    }
    
    // MARK: - UIDocumentBrowser
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        if document?.imageGallery != nil {
            if let thumbnail = thumbnailImage?.snapshot {
                document?.thumbnail = thumbnail
            }
        }
        
        dismiss(animated: true) {
            self.document?.close()
        }
    }
    
    func documentChanged() {
        document?.imageGallery = gallery
        
        if document?.imageGallery != nil {
            document?.updateChangeCount(UIDocument.ChangeKind.done)
        }
    }
    
    // MARK: - UICollectionViewDragDelegate
    
    private func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        if let item = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell, let image = item.imageView.image {
            let provider = NSItemProvider(object: image)
            let dragItem = UIDragItem(itemProvider: provider)
            dragItem.localObject = indexPath // gallery.images[indexPath.item]
            return [dragItem]
        } else {
            return []
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
    // MARK: - UICollectionViewDropDelegate
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        if collectionView.hasActiveDrag {
            return session.canLoadObjects(ofClass: UIImage.self)
        } else {
            return session.canLoadObjects(ofClass: UIImage.self) && session.canLoadObjects(ofClass: NSURL.self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(operation: UIDropOperation.move, intent: UICollectionViewDropProposal.Intent.insertAtDestinationIndexPath)
        } else {
            return UICollectionViewDropProposal(operation: UIDropOperation.copy, intent: UICollectionViewDropProposal.Intent.insertAtDestinationIndexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath {
                // Perform drop local.
                if let image = item.dragItem.localObject as? ImageGallery.Image {
                    collectionView.performBatchUpdates({
                        gallery.images.remove(at: sourceIndexPath.item)
                        gallery.images.insert(image, at: destinationIndexPath.item)
                        collectionView.deleteItems(at: [sourceIndexPath])
                        collectionView.insertItems(at: [destinationIndexPath])
                    }, completion: nil)
                    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                    self.documentChanged()
                }
            } else {
                // Perform drop from other app.
                let placeholderContext = coordinator.drop(item.dragItem, to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: "Drop Placeholder Cell"))
                
                var imageURLLocal: URL?
                var aspectRatioLocal: CGFloat?
                
                // Load UIImage.
                item.dragItem.itemProvider.loadObject(ofClass: UIImage.self) { (provider, error) in
                    DispatchQueue.main.async {
                        if let image = provider as? UIImage {
                            aspectRatioLocal = image.size.width / image.size.height
                        }
                    }
                }
                // Load URL.
                item.dragItem.itemProvider.loadObject(ofClass: NSURL.self) { (provider, error) in
                    DispatchQueue.main.async {
                        if let url = provider as? URL {
                            imageURLLocal = url.imageURL
                        }
                        if imageURLLocal != nil, aspectRatioLocal != nil {
                            placeholderContext.commitInsertion { (insertionIndexPath) in
                                self.gallery.images.insert(ImageGallery.Image(url: imageURLLocal!, aspectRatio: aspectRatioLocal!), at: insertionIndexPath.item)
                            }
                            self.documentChanged()
                        } else {
                            placeholderContext.deletePlaceholder()
                        }
                    }
                }
            }
        }
    }

    // MARK: - Navigation

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

    // MARK: - UICollectionViewDataSource

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
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
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

    // MARK: - UICollectionViewDelegate

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
