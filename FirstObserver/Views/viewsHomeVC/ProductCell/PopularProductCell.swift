//
//  PopularProductCell.swift
//  FirstObserver
//
//  Created by Evgenyi on 11.08.22.
//

import UIKit

class PopularProductCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var model = [PopularProduct]()
    let countCell = 2
    let offset:CGFloat = 2.0
    weak var delegate: ViewsHomeVCNavigationDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        self.setArray()
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
//    func setArray() {
//
//        let image = UIImage(named: "Icon")
//        guard let im = image else {return}
//        let mod = Model(image: im)
//
//        for _ in 0...15 {
//            self.model.append(mod)
//        }
//    }
    
    func configureCell(arrayProduct: [PopularProduct]) {
        self.model = arrayProduct
    }
    
   

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension PopularProductCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCollectionViewCell", for: indexPath) as! ProductCollectionViewCell
        cell.setupCell(model[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let frameCollection = collectionView.frame
        
        
        
    
        let widthCollectionCell = frameCollection.width/CGFloat(countCell)
        let heightCollectionCell = frameCollection.width/CGFloat(countCell)
        
//        let spacing = CGFloat((countCell + 1)) * offset / CGFloat(countCell)
//
//        return CGSize(width: widthCollectionCell - spacing, height: heightCollectionCell - (offset*2))
        return CGSize(width: widthCollectionCell - 15, height: heightCollectionCell)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        delegate?.destinationVC(indexPath: indexPath.row, forCell: .popularProductCell, refPath: "")
    }
    
    
}
