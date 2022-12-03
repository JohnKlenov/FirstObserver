//
//  ViewController.swift
//  FirstObserver
//
//  Created by Evgenyi on 8.08.22.
//

import UIKit
import Firebase
import FirebaseAuth

class CartViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var model: [Product]!
    var heightCell: CGFloat!
    var imageWidth: CGFloat!
    var arrayPlaces: [PlacesTest] = []
    
//    private lazy var ref: DatabaseReference? = {
//        guard let uid = Auth.auth().currentUser?.uid else { return nil }
//        let ref = Database.database().reference(withPath: "usersAccaunt/\(uid)/AddedProducts")
//        return ref
//    }()
    
    var addedInCartProducts: [PopularProduct] = []
//    {
//        didSet {
//            tableView.reloadData()
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Cart"
        
        heightCell = self.tableView.frame.height/7
        imageWidth = heightCell - 30
        let nib = UINib(nibName: "CartTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "CartTableViewCell")
        
        
        setupHeaderView()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getFetchDataHVC()
        
//        ref?.observe(.value) { (snapshot) in
//
//            var arrayProduct = [PopularProduct]()
//
//            for item in snapshot.children {
//                let addedProduct = item as! DataSnapshot
//
//                var arrayMalls = [String]()
//                var arrayRefe = [String]()
//                for childItem in addedProduct.children {
//                    let childItem = childItem as! DataSnapshot
//                    switch childItem.key {
//                    case "malls":
//                        for it in childItem.children {
//                            let item = it as! DataSnapshot
//                            if let refDictionary = item.value as? String {
//                                arrayMalls.append(refDictionary)
//                            }
//                        }
//                    case "refArray":
//                        for it in childItem.children {
//                            let item = it as! DataSnapshot
//                            if let refDictionary = item.value as? String {
//                                arrayRefe.append(refDictionary)
//                            }
//                        }
//                    default:
//                        break
//                    }
//                }
//                //
//                let product = PopularProduct(snapshot: addedProduct, refArray: arrayRefe, malls: arrayMalls)
//                arrayProduct.append(product)
//            }
//            self.addedInCartProducts = arrayProduct
//            self.tableView.reloadData()
//        }
    }
    
    
    
    func setupHeaderView() {
        
        let headView = UIView.init(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width , height: 5))
        headView.backgroundColor = .white
        tableView.tableHeaderView = headView
    }
    
    private func getFetchDataHVC() {
        
        guard let tabBarVCs = tabBarController?.viewControllers else { return }
        tabBarVCs.forEach { (vc) in
            if let nc = vc as? UINavigationController {
                if let homeVC = nc.topViewController as? HomeViewController {
                    self.arrayPlaces = homeVC.arrayPin
                    self.addedInCartProducts = homeVC.addedToCardProducts
                    tableView.reloadData()
                }
            }
        }
    }
    
}


extension CartViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addedInCartProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartTableViewCell", for: indexPath) as! CartTableViewCell
        cell.configureCell(model: addedInCartProducts[indexPath.row], imageWidth: imageWidth)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightCell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let product = addedInCartProducts[indexPath.row]
            product.refProduct.removeValue()
            addedInCartProducts.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
//            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        var placesArray: [PlacesTest] = []
        let product = addedInCartProducts[indexPath.row]
        let malls = product.malls
        
        arrayPlaces.forEach { (places) in
            if malls.contains(places.title ?? "") {
                placesArray.append(places)
            }
        }
        
        let productVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProductViewController") as! ProductViewController
        
        addedInCartProducts.forEach { (addedProduct) in
            if addedProduct.model == product.model {
                productVC.isAddedToCard = true
            }
        }
        
        productVC.arrayPin = placesArray
        productVC.fireBaseModel = product
        self.navigationController?.pushViewController(productVC, animated: true)
    }
    
}

