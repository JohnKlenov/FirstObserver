//
//  ShopingMallCell.swift
//  FirstObserver
//
//  Created by Evgenyi on 11.08.22.
//

import UIKit


class ShopingMallCell: UITableViewCell {

    @IBOutlet weak var shopingCollectionView: UICollectionView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var model = [PreviewCategory]()
    weak var delegate: ViewsHomeVCNavigationDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        self.setArray()
        self.shopingCollectionView.delegate = self
        self.shopingCollectionView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(arrayMalls: [PreviewCategory]) {
        self.model = arrayMalls
    }
    
//    func setArray() {
//
//        let imageSecond = UIImage(named: "Icon")
//        guard let im = imageSecond else {return}
//        let mod = Model(image: im)
//
//        for _ in 0...5 {
//            model.append(mod)
//        }
//    }

}

extension ShopingMallCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return model.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShopingCollectionViewCell", for: indexPath) as! ShopingCollectionViewCell
        
        cell.setupCell(model[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frameCollection = collectionView.frame
        let widthCell = frameCollection.width * 0.8
        let heightCell = frameCollection.height * 0.85
        
//        let spacingTop = (frameCollection.height - heightCell)/2
//        print(" Отступ сверху Магазины - \(spacingTop)")
        return CGSize(width: widthCell, height: heightCell)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let mall = model[indexPath.item].brand {
            delegate?.destinationVC(indexPath: indexPath.item, forCell: .shopingMall, refPath: mall)
        }
    }
    
}
