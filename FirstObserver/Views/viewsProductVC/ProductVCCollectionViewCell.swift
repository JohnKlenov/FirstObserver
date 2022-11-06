//
//  ProductVCCollectionViewCell.swift
//  FirstObserver
//
//  Created by Evgenyi on 12.09.22.
//

import UIKit
import FirebaseStorage
import FirebaseStorageUI



class ProductVCCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageProductVC: UIImageView!
    var storage:Storage!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        storage = Storage.storage()
    }

    
//    func setupCell(image: UIImage) {
//        self.imageProductVC.image = image
//    }
    func setupCell(refImage: String) {
        let refStorage = storage.reference(forURL: refImage)
        imageProductVC.sd_setImage(with: refStorage, placeholderImage: UIImage(named: "DefaultImage"))
    }
    
}
