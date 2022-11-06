//
//  GroupCell.swift
//  FirstObserver
//
//  Created by Evgenyi on 30.08.22.
//

import UIKit

class GroupCell: UICollectionViewCell {
    
    
    @IBOutlet weak var groupNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupCell(groupName:String, isSelected: Bool) {
        groupNameLabel.text = groupName
        
        if isSelected {
            groupNameLabel.textColor = .orange
        } else {
            groupNameLabel.textColor = .black
        }
    }

}
