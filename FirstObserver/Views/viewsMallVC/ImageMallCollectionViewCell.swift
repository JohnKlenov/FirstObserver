//
//  ImageMallCollectionViewCell.swift
//  FirstObserver
//
//  Created by Evgenyi on 9.11.22.
//

import UIKit
import FirebaseStorage
import FirebaseStorageUI

class ImageMallCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var mallImageView: UIImageView!
    var storage: Storage!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 5
        storage = Storage.storage()
    }
    
    func configure(mallImageRef: String) {
        let refStorage = storage.reference(forURL: mallImageRef)
        mallImageView.sd_setImage(with: refStorage, placeholderImage: UIImage(named: "DefaultImage"))
    }
    
    
}
