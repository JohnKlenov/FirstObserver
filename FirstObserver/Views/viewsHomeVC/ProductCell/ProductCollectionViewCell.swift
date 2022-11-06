//
//  ProductCollectionViewCell.swift
//  FirstObserver
//
//  Created by Evgenyi on 18.08.22.
//

import UIKit
import FirebaseStorage
import FirebaseStorageUI

class ProductCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    var storage: Storage!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 5
        storage = Storage.storage()
    }
    
   

    
    func setupCell(_ model:PopularProduct) {
        
//        print("setupCell \(model.malls)")
//        print("setupCell \(model.model)")
//        print("setupCell \(model.price)")
        if let firstRef = model.refArray.first {
//            print("if let firstRef = model.refArray.first")
            let urlRef = storage.reference(forURL: firstRef)
            self.imageView.sd_setImage(with: urlRef, placeholderImage: UIImage(named: "DefaultImage"))
        }
       
    }
}
