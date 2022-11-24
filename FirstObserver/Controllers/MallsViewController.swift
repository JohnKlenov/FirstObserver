//
//  MallViewController.swift
//  FirstObserver
//
//  Created by Evgenyi on 8.08.22.
//

import UIKit

class MallsViewController: UIViewController {
    
    @IBOutlet weak var segmentControll: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var hightCellVC: CGFloat!

    var arrayPins: [PlacesTest] = []
    var mallsModel: [PreviewCategory] = []
    var brandsModel: [PreviewCategory] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Malls"
        collectionView.delegate = self
        collectionView.dataSource = self
        
        hightCellVC = (collectionView.frame.height/3)*0.86
        
        getFetchDataHVC()
        
    }
    
    private func getFetchDataHVC() {
        
        guard let tabBarVCs = tabBarController?.viewControllers else {return}
        
        for vc in tabBarVCs {
            print("контроллеров в таб баре")
            
            if let nc = vc as? UINavigationController {
                if let homeVC = nc.topViewController as? HomeViewController {
                    print("HomeViewController найден HomeViewController найден HomeViewController найден!")
                    self.arrayPins = homeVC.arrayPin
                    if let model = homeVC.arrayInArray["malls"] as? [PreviewCategory] {
                        self.mallsModel = model
                    }
                    if let brands = homeVC.arrayInArray["brands"] as? [PreviewCategory] {
                        self.brandsModel = brands
                    }
                }
            }
        }
    }
    
}


extension MallsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mallsModel.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MallCollectionViewCell", for: indexPath) as! MallCollectionViewCell
        cell.configureCell(model: mallsModel[indexPath.item], currentFrame: CGSize(width: collectionView.frame.width - 20, height: hightCellVC))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 20, height: hightCellVC)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let mallVC = UIStoryboard.vcById("MallViewController") as? MallViewController

        if let mallVC = mallVC {
            mallVC.arrayPin = self.arrayPins
            mallVC.brandsMall = self.brandsModel
            if let refPath = mallsModel[indexPath.item].brand {
                mallVC.refPath = refPath
            }
            self.navigationController?.pushViewController(mallVC, animated: true)
        }
    }
   
}


