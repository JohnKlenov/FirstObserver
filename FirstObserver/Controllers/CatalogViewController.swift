//
//  CatalogViewController.swift
//  FirstObserver
//
//  Created by Evgenyi on 8.08.22.
//

import UIKit

class CatalogViewController: UIViewController {
    
    

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    var modelC = [Model]()
    var heightCellCV:CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Catalog"
        collectionView.delegate = self
        collectionView.dataSource = self
        setupModel()
        
        heightCellCV = (collectionView.frame.height/3)*0.86
        print(" collectionView.frame.height - \(collectionView.frame.height)")
        print(" heightCellCV - \(String(describing: heightCellCV))")
       
    }
    
    func setupModel() {
        for _ in 0...5 {
            let model = Model(image: UIImage(named: "Icon")!)
            modelC.append(model)
        }
    }
    
}


extension CatalogViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return modelC.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CatalogCollectionViewCell", for: indexPath) as! CatalogCollectionViewCell
        cell.setupCell(image: modelC[indexPath.item].image!)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width - 20, height: heightCellCV)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToAllProductVC", sender: nil)
    }
    
}
