//
//  MallCollectionViewCell.swift
//  FirstObserver
//
//  Created by Evgenyi on 7.11.22.
//

import UIKit

class MallCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var imageMall: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 10
    }
    
    func configureCell(model: String) {
        let image = UIImage(named: "Icon")
        imageMall.image = image
        print("Target mall - \(model)")
    }
    
}
