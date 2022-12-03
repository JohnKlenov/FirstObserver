//
//  CartTableViewCell.swift
//  FirstObserver
//
//  Created by Evgenyi on 4.09.22.
//

import UIKit
import FirebaseStorage
import FirebaseStorageUI

class CartTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var cartImage: UIImageView!
    @IBOutlet weak var brandName: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var imageWidth: NSLayoutConstraint!
    var storage:Storage!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        storage = Storage.storage()
        self.containerView.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        contentView.bounds  = bounds.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0))
//        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0))
//    }
    
    func configureCell(model: PopularProduct, imageWidth: CGFloat) {
        
        if let stringRef = model.refArray.first {
            let storageRef = storage.reference(forURL: stringRef)
            cartImage.sd_setImage(with: storageRef, placeholderImage: UIImage(named: "DefaultImage"))
        }
        self.brandName.text = model.model
        self.price.text = "\(String(model.price)) BYN"
        self.imageWidth.constant = imageWidth
    }
    
    
    
}
