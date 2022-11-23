//
//  MallCollectionViewCell.swift
//  FirstObserver
//
//  Created by Evgenyi on 7.11.22.
//

import UIKit
import FirebaseStorage
import FirebaseStorageUI

class MallCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var nameMall: UILabel!
    @IBOutlet weak var imageMall: UIImageView!
    var storage: Storage!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        storage = Storage.storage()
        self.layer.cornerRadius = 10
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        if let layers = imageMall.layer.sublayers {
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
        self.imageMall.layer.addSublayer(gradientLayer)
    }
    
    func configureCell(model: PreviewCategory, currentFrame: CGSize) {

        let refURL = storage.reference(forURL: model.refImage)
        imageMall.sd_setImage(with: refURL, placeholderImage: UIImage(named: "DefaultImage"))
        nameMall.text = model.brand
        addGradientOverlay(correntFrame: currentFrame)
    }
    
}
