//
//  ImageMallCollectionViewCell.swift
//  FirstObserver
//
//  Created by Evgenyi on 9.11.22.
//

import UIKit

class ImageMallCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var mallImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 5
    }
    
    func configure(mallImage: UIImage) {
        mallImageView.image = mallImage
    }
    
    
}
