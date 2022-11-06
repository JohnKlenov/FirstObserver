//
//  ShopingCollectionViewCell.swift
//  FirstObserver
//
//  Created by Evgenyi on 13.08.22.
//

import UIKit
import FirebaseStorage
import FirebaseStorageUI

class ShopingCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageMall: UIImageView!
    var storage: Storage!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 5
        storage = Storage.storage()
    }
    
    func setupCell(_ model: PreviewCategory) {
        // при конфигурации cells не все image успевают подгрузится из сети и когда пропадает инет image в коллекции с default image
        // если сеть есть то они прогрузятся при нажатии на них
//        placeholderImage - Изображение для отображения во время загрузки.
        let refStorage = storage.reference(forURL: model.refImage)
        imageMall.sd_setImage(with: refStorage, placeholderImage: UIImage(named: "DefaultImage"))
    }
}
