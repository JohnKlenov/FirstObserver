//
//  CatalogCollectionViewCell.swift
//  FirstObserver
//
//  Created by Evgenyi on 2.09.22.
//

import UIKit
import FirebaseStorage
import FirebaseStorageUI

class CatalogCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var nameCategory: UILabel!
    @IBOutlet weak var imageCatalog: UIImageView!
    var storage: Storage!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 10
        storage = Storage.storage()
        print("CatalogCollectionViewCell frameCell = \(self.frame)")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if let layers = imageCatalog.layer.sublayers {
            for layerGradient in layers {
                layerGradient.removeFromSuperlayer()
            }
        }
    }
    
    private func addGradientOverlay(correntFrame: CGSize) {
        let gradientLayer = CAGradientLayer()

        gradientLayer.frame.size = correntFrame
        let overlayColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        gradientLayer.colors = [overlayColor.cgColor, overlayColor.cgColor]
        self.imageCatalog.layer.addSublayer(gradientLayer)
    }
    
    func setupCell(model: PreviewCategory, currentFrame: CGSize) {
       
        let storageRef = storage.reference(forURL: model.refImage)
        imageCatalog.sd_setImage(with: storageRef, placeholderImage: UIImage(named: "DefaultImage"))
        nameCategory.text = model.brand
        addGradientOverlay(correntFrame: currentFrame)
    }
    
}
