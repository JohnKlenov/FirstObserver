//
//  allProductViewController.swift
//  FirstObserver
//
//  Created by Evgenyi on 4.09.22.
//

import UIKit
import Firebase

class AllProductViewController: BrandsViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("AllProductViewController AllProductViewController AllProductViewController")
        categoryRef?.observe(.value) { (snapshot) in
            
            let garderob = PopularGarderob()
            for brand in snapshot.children {
                let brand = brand as! DataSnapshot
                let nameBrand = brand.key
                for categoryBrand in brand.children {
                    let categoryBrand = categoryBrand as! DataSnapshot
                    if categoryBrand.key == self.searchCategory {
                        let group = PopularGroup(name: nameBrand, group: nil, product: [])
                        for productCategory in categoryBrand.children {
                            let productCategory = productCategory as! DataSnapshot
                            
                            var arrayMalls = [String]()
                            var arrayRefe = [String]()
                            
                            
                            for mass in productCategory.children {
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
                            let productModel = PopularProduct(snapshot: productCategory, refArray: arrayRefe, malls: arrayMalls)
                            group.product?.append(productModel)
                            print("Append new product from AllProductViewController \(productModel.model)")
                        }
                        garderob.groups.append(group)
                        print("appenf new group AllProductViewController \(group.name)")
                    }
                }
            }
            self.popularGarderob = garderob
        }
    }
}
