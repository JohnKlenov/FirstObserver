//
//  CatalogCollectionViewCell.swift
//  FirstObserver
//
//  Created by Evgenyi on 2.09.22.
//

import UIKit

class CatalogCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageCatalog: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 10
        print("CatalogCollectionViewCell frameCell = \(self.frame)")
    }
    
    func setupCell(image: UIImage) {
        
        self.imageCatalog.image = image
    }
    
}
