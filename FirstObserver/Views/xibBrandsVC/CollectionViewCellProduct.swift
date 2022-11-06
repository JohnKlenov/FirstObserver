//
//  CollectionViewCellProduct.swift
//  FirstObserver
//
//  Created by Evgenyi on 30.08.22.
//

import UIKit
import FirebaseStorage
import FirebaseStorageUI

class CollectionViewCellProduct: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
   
    @IBOutlet weak var nameProduct: UILabel!
    @IBOutlet weak var priceProduct: UILabel!
    var storage:Storage!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        storage = Storage.storage()
    }
    
    func setupCVProductCell(product:PopularProduct) {
        
//        self.imageView.image = product.image
        self.nameProduct.text = product.model
        self.priceProduct.text = product.price
        let refURL = storage.reference(forURL: product.refArray.first ?? "")
        imageView.sd_setImage(with: refURL, placeholderImage: UIImage(named: "DefaultImage"))
    }

}
