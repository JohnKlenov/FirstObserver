//
//  BrandsViewController.swift
//  FirstObserver
//
//  Created by Evgenyi on 27.08.22.
//

import UIKit
import Firebase



class BrandsViewController: UIViewController {
    

    var heightCollectionView:CGFloat!
    var selectedGroup:PopularGroup? {
        didSet {
            if let selectedGroup = self.selectedGroup {
                self.title = selectedGroup.name
            }
        }
    }
    
    
    @IBOutlet weak var groupsCollectionView: UICollectionView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var heightGroupsCV: NSLayoutConstraint!
    
    
    // MARK: - FirebaseProperty -
    
    var incomingRef: DatabaseReference?
    var searchCategory: String?
    var categoryRef: DatabaseReference?
    var popularGarderob: PopularGarderob? {
        didSet {
            if let group = popularGarderob?.groups.first, let groups = popularGarderob?.groups, groups.count > 0 {
                selectedGroup = group
            } else {
                self.title = "Brand"
            }
            groupsCollectionView.reloadData()
            collectionView.reloadData()
            print(popularGarderob?.groups.first?.name ?? "popularGarderob nil")
        }
    }
    var arrayPin: [PlacesTest] = []
    var addedToCartProducts: [PopularProduct] = [] {
        didSet {
            print("#######################################################")
            print("\(self.addedToCartProducts)")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let nibGroup = UINib(nibName: "GroupCell", bundle: nil)
        groupsCollectionView.register(nibGroup, forCellWithReuseIdentifier: "GroupCell")
        groupsCollectionView.delegate = self
        groupsCollectionView.dataSource = self
        
        let nibProduct = UINib(nibName: "ProductCell", bundle: nil)
        collectionView.register(nibProduct, forCellWithReuseIdentifier: "ProductCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
        
//        if let group = menu.groups.first?.groups, group.count > 0 {
//            selectedGroup = group.first
//        } else {
//            selectedGroup = menu.groups.first
//        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("BrandsViewController BrandsViewController BrandsViewController")
        
        getFetchDataHVC()
        
        incomingRef?.observe(.value){ (snapshot) in
            
            let garderob = PopularGarderob()
            for item in snapshot.children {
                let itemCategory = item as! DataSnapshot
                print("BrandsViewController \(itemCategory.key)")
                let group = PopularGroup(name: itemCategory.key, group: nil, product: [])
                for item in itemCategory.children {
                    let product = item as! DataSnapshot
                    print(product.key)
                    
                    var arrayMalls = [String]()
                    var arrayRefe = [String]()
                    
                    
                    for mass in product.children {
                        let item = mass as! DataSnapshot
                        
                        switch item.key {
                        case "malls":
                            for it in item.children {
                                let item = it as! DataSnapshot
                                if let refDictionary = item.value as? String {
                                    arrayMalls.append(refDictionary)
                                }
                            }
                            
                        case "refImage":
                            for it in item.children {
                                let item = it as! DataSnapshot
                                if let refDictionary = item.value as? String {
                                    arrayRefe.append(refDictionary)
                                }
                            }
                        default:
                            break
                        }
                        
                    }
                    let productModel = PopularProduct(snapshot: product, refArray: arrayRefe, malls: arrayMalls)
                    group.product?.append(productModel)
                    print("Append new product BrandsViewController\(productModel.model)")
                    
                }
                garderob.groups.append(group)
                print("appenf new group BrandsViewController\(group.name)")
            }
            self.popularGarderob = garderob
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        let guide = self.view.safeAreaLayoutGuide
        let heightSafeArea = guide.layoutFrame.size.height
        let xProcent = heightSafeArea/100 * 10
        heightCollectionView = heightSafeArea - xProcent
        self.heightGroupsCV.constant = xProcent

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        let guide = self.view.safeAreaLayoutGuide
//        let heightSafeArea = guide.layoutFrame.size.height
//        print(" Высота safe Area - \(heightSafeArea)")
//        print("Высота frame collectionView - \(String(format: "%.2f" , collectionView.frame.height))")
//        print("Высота frame groupsCollectionView - \(String(format: "%.2f" , groupsCollectionView.frame.height))")
//        print("Высота NB - \(self.navigationController?.navigationBar.frame.height)")
//        print("Высота View - \(self.view.frame.height)")
//        print(" Высота TB -\(self.tabBarController?.tabBar.frame.height)")
//        print("Высота statusBar - \(Screen.statusBarHeight)")
        
    }
    
    // Если свайпом листаем collectionView - премещаем selectedGroup в groupsCollectionView и меняем titleVC
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView == collectionView {
            let cells = collectionView.visibleCells
            
            if let cell = cells.first, let indexPath = collectionView.indexPath(for: cell) {
//                selectedGroup = menu.groups.first?.groups?[indexPath.item]
                selectedGroup = popularGarderob?.groups[indexPath.item]
                groupsCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                groupsCollectionView.reloadData()
            }
        }
    }
    
    
    private func getFetchDataHVC() {
        
        guard let tabBarVCs = tabBarController?.viewControllers else { return }
        for vc in tabBarVCs {
            if let nc = vc as? UINavigationController {
                if let homeVC = nc.viewControllers.first as? HomeViewController {
                    self.addedToCartProducts = homeVC.addedToCardProducts
                }
            }
        }
    }
    

}


extension BrandsViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return popularGarderob?.groups.count ?? 0
//        menu.groups.first?.groups?.count ?? 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == groupsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupCell", for: indexPath) as! GroupCell
//            let groupName = menu.groups.first?.groups?[indexPath.item].name
            let groupName = popularGarderob?.groups[indexPath.item].name
            let boolName = groupName == selectedGroup?.name
            cell.setupCell(groupName: groupName!, isSelected: boolName)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCell
            cell.delegate = self
//            let product = menu.groups.first?.groups?[indexPath.item].product
            let product = popularGarderob?.groups[indexPath.item].product
            cell.setupCell(product: product!)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == groupsCollectionView {
            //            let groupName = menu.groups.first!.groups![indexPath.item].name
            let groupName = popularGarderob?.groups[indexPath.item].name ?? ""
            let width = groupName.widthOfString(usingFont: UIFont.systemFont(ofSize: 17))
            return CGSize(width: width + 20, height: collectionView.frame.height)
        } else {
            return CGSize(width: UIScreen.main.bounds.width - 10, height: heightCollectionView)
        }
    }
    
    
    // между cell 10 теперь отступы(справо и лева)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    // что бы центровка не сбивалась выставим отступы и вычтим их из UIScreen.main.bounds.width - 10
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    
        if collectionView == groupsCollectionView {
            
//            selectedGroup = menu.groups.first?.groups?[indexPath.item]
            selectedGroup = popularGarderob?.groups[indexPath.item]
            groupsCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            groupsCollectionView.reloadData()
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    
    
}

extension BrandsViewController: ProductCellDelegtate {
    
    func giveModel(model: PopularProduct) {
        
        let productVC = UIStoryboard.vcById("ProductViewController") as! ProductViewController
        
        var placesArray: [PlacesTest] = []
        let malls = model.malls
        
        arrayPin.forEach { (places) in
            if malls.contains(places.title ?? "") {
                placesArray.append(places)
            }
        }
        
        addedToCartProducts.forEach { (addedProduct) in
           
            if addedProduct.model == model.model {
                productVC.isAddedToCard = true
            }
        }
        
        productVC.arrayPin = placesArray
        productVC.fireBaseModel = model
        self.navigationController?.pushViewController(productVC, animated: true)
    }
    
    
    
}
