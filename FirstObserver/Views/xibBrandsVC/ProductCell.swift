//
//  ProductCell.swift
//  FirstObserver
//
//  Created by Evgenyi on 30.08.22.
//

import UIKit

protocol ProductCellDelegtate: AnyObject {
    func giveModel(model: PopularProduct)
}

class ProductCell: UICollectionViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var product = [PopularProduct]()
    weak var delegate: ProductCellDelegtate?
   
    let countCell = 2
    let offset:CGFloat = 2.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        let nibCellProduct = UINib(nibName: "CollectionViewCellProduct", bundle: nil)
        collectionView.register(nibCellProduct, forCellWithReuseIdentifier: "CollectionViewCellProduct")
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
    }
    

    func setupCell(product: [PopularProduct]) {
        self.product = product
        self.collectionView.reloadData()
    }
}




extension ProductCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return product.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCellProduct", for: indexPath) as! CollectionViewCellProduct
        let product = product[indexPath.item]
        cell.setupCVProductCell(product: product)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let collectionFrame = collectionView.frame
        
        
        let widthCell = collectionFrame.width/CGFloat(countCell)
        let heightCell = collectionFrame.width/CGFloat(countCell)
        
        return CGSize(width: widthCell - 15, height: heightCell)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let product = product[indexPath.item]
        delegate?.giveModel(model: product)
        
    }

}

