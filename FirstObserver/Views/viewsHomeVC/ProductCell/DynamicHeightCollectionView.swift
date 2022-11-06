//
//  DynamicHeightCollectionView.swift
//  FirstObserver
//
//  Created by Evgenyi on 29.10.22.
//

import UIKit

class DynamicHeightCollectionView: UICollectionView {

        override func layoutSubviews() {
            super.layoutSubviews()
    
            if bounds.size != intrinsicContentSize {
            self.invalidateIntrinsicContentSize()
    
            }
        }
    
        override var intrinsicContentSize: CGSize {
            return collectionViewLayout.collectionViewContentSize
        }

}
