//
//  BrandsCollectionViewCell.swift
//  FirstObserver
//
//  Created by Evgenyi on 18.08.22.
//

import UIKit
import FirebaseStorage
import FirebaseStorageUI

class BrandsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    var storage: Storage!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        storage = Storage.storage()
        self.layer.cornerRadius = 5
    }
    
    func setupCell(_ model:PreviewCategory) {
        let refStorage = storage.reference(forURL: model.refImage)
        imageView.sd_setImage(with: refStorage, placeholderImage: UIImage(named: "DefaultImage"))
    }
    
}
