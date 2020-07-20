//
//  GarbageView.swift
//  ImageGallery
//
//  Created by Dmitry Reshetnik on 20.07.2020.
//  Copyright © 2020 Dmitry Reshetnik. All rights reserved.
//

import UIKit

class GarbageView: UIView, UIDropInteractionDelegate {
    var garbageViewDidChanged: (() -> Void)?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.subviews.count > 0 {
            self.subviews[0].frame = CGRect(x: bounds.width - bounds.height, y: 0, width: bounds.width, height: bounds.height)
        }
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    // MARK: - UIDropInteractionDelegate
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: UIImage.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        if session.localDragSession != nil {
            return UIDropProposal(operation: UIDropOperation.copy)
        } else {
            return UIDropProposal(operation: UIDropOperation.forbidden)
        }
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: UIImage.self) { (provider) in
            if let collection = session.localDragSession?.localContext as? UICollectionView {
                if let images = (collection.dataSource as? ImageGalleryCollectionViewController)?.gallery.images {
                    if let items = session.localDragSession?.items {
                        var indexPaths = [IndexPath]()
                        var indices = [Int]()
                        
                        for item in items {
                            if let indexPath = item.localObject as? IndexPath {
                                let index = indexPath.item
                                indices += [index]
                                indexPaths += [indexPath]
                            }
                        }
                        
                        collection.performBatchUpdates({
                            collection.deleteItems(at: indexPaths)
                            (collection.dataSource as? ImageGalleryCollectionViewController)?.gallery.images = images.enumerated().filter { !indices.contains($0.offset) }.map { $0.element }
                        })
                        
                        self.garbageViewDidChanged?()
                    }
                }
            }
        }
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, previewForDropping item: UIDragItem, withDefault defaultPreview: UITargetedDragPreview) -> UITargetedDragPreview? {
        let target = UIDragPreviewTarget(container: self, center: CGPoint(x: bounds.width - bounds.height * 1 / 2, y: bounds.height * 1 / 2), transform: CGAffineTransform(scaleX: 0.1, y: 0.1))
        
        return defaultPreview.retargetedPreview(with: target)
    }
    
    private func setup() {
        let dropInteraction = UIDropInteraction(delegate: self)
        addInteraction(dropInteraction)
        
        backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        
        let trashImage = UIImage(systemName: "trash")
        let button = UIButton()
        button.setImage(trashImage, for: UIControl.State.normal)
        self.addSubview(button)
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
