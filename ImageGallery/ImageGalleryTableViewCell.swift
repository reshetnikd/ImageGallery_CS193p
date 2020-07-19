//
//  ImageGalleryTableViewCell.swift
//  ImageGallery
//
//  Created by Dmitry Reshetnik on 19.07.2020.
//  Copyright © 2020 Dmitry Reshetnik. All rights reserved.
//

import UIKit

class ImageGalleryTableViewCell: UITableViewCell, UITextFieldDelegate {
    @IBOutlet weak var nameTextField: UITextField! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(beginEditing))
            tap.numberOfTapsRequired = 2
            addGestureRecognizer(tap)
            
            nameTextField.delegate = self
        }
    }
    
    var resignationHandler: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func beginEditing() {
        nameTextField.isEnabled = true
        nameTextField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.isEnabled = false
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        resignationHandler?()
    }

}
