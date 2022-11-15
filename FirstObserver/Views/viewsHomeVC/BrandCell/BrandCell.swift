//
//  BrandCell.swift
//  FirstObserver
//
//  Created by Evgenyi on 11.08.22.
//

import UIKit

//protocol HomeViewControllerDelegate {
//    func goToBrandsVC(_ indexPath: Int)
//}

class BrandCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var model = [PreviewCategory]()
    weak var delegate: ViewsHomeVCNavigationDelegate?
//    var delegate: HomeViewControllerDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        self.setArray()
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    func configureCell(arrayBrands: [PreviewCategory]) {
        self.model = arrayBrands
    }
    
//    func setArray() {
//
//        let image = UIImage(named: "Icon")
//        guard let im = image else {return}
//        let mod = Model(image: im)
//        for _ in 0...10 {
//            self.model.append(mod)
//        }
//    }
}

extension BrandCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BrandsCollectionViewCell", for: indexPath) as! BrandsCollectionViewCell
        cell.setupCell(model[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let frameCollection = collectionView.frame
        let height = frameCollection.height * 0.75
        let width = frameCollection.height * 0.75
//        let spacingTop = (frameCollection.height - height)/2
//        print(" Отступ сверху Брэнд - \(spacingTop)")
        return CGSize(width: height, height: width)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.destinationVC(indexPath: indexPath.row, forCell: .brandCell, refPath: model[indexPath.row].brand ?? "")
//        delegate?.goToBrandsVC(indexPath.row)
    }
    
    
}


