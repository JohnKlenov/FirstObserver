//
//  ModelFB.swift
//  FirstObserver
//
//  Created by Evgenyi on 27.10.22.
//

import Foundation
import FirebaseDatabase
import MapKit




// MARK: - ModelAnnotation -



class Places: NSObject, MKAnnotation {
    
    let title: String?
    let locationName: String?
    let discipline: String?
    let imageName: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title:String?, locationName:String?, discipline:String?, coordinate: CLLocationCoordinate2D, imageName: String?) {
        
        self.title = title
        self.locationName = locationName
        self.discipline = discipline
        self.coordinate = coordinate
        self.imageName = imageName
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
    
}

class PlacesTest: NSObject, MKAnnotation {
    
    let title: String?
    let locationName: String?
    let discipline: String?
    let image: UIImage?
    let coordinate: CLLocationCoordinate2D
    
    init(title:String?, locationName:String?, discipline:String?, coordinate: CLLocationCoordinate2D, image: UIImage?) {
        
        self.title = title
        self.locationName = locationName
        self.discipline = discipline
        self.coordinate = coordinate
        self.image = image
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
    
}



class PlacesFB {
    
    let name:String
    let refImage:String
    let address:String
    let latitude:Double
    let longitude:Double
    
    init(snapshot: DataSnapshot) {
        
        let snapshotValue = snapshot.value as! [String:AnyObject]
        self.name = snapshotValue["name"] as! String
        self.address = snapshotValue["address"] as! String
        self.refImage = snapshotValue["refImage"] as! String
        self.latitude = snapshotValue["latitude"] as! Double
        self.longitude = snapshotValue["longitude"] as! Double
    }
}



class PreviewCategory {
    
    let brand: String?
    let refImage: String
    
    init(snapshot: DataSnapshot) {
        
        let snapshotValue = snapshot.value as! [String: AnyObject]
        let brand = snapshotValue["brand"] as? String ?? snapshotValue["name"] as? String
        let refImage = snapshotValue["refImage"] as! String
        
        self.brand = brand
        self.refImage = refImage
    }
}

class MallModel {
    
    var brands: [String]
    var description: String
    var floorPlan: String?
    var infocenter: String
    var name: String
    var refImage: [String]
    var webSite: String?
    
    init(snapshot: DataSnapshot, refImage: [String], brands: [String]) {
        
        let snapshotValue = snapshot.value as! [String:AnyObject]
        self.brands = brands
        self.description = snapshotValue["description"] as! String
        self.floorPlan = snapshotValue["floorPlan"] as? String
        self.infocenter = snapshotValue["infocenter"] as! String
        self.name = snapshotValue["name"] as! String
        self.refImage = refImage
        self.webSite = snapshotValue["www"] as? String
    }
}

class AddedProduct: Encodable {
    
    let model: String
    let description: String
    let price: String
    let refImage: [String]
    let malls: [String]
    
    init(product: PopularProduct) {
        self.model = product.model
        self.description = product.description
        self.price = product.price
        self.refImage = product.refArray
        self.malls = product.malls
    }
}

class PopularProduct {
    
    let model: String
    let description: String
    let price: String
    let refArray: [String]
    let malls: [String]
    let refProduct: DatabaseReference
    
    init(snapshot: DataSnapshot, refArray: [String], malls: [String]) {
        
        let snapshotValue = snapshot.value as! [String:AnyObject]
        
        self.model = snapshotValue["model"] as! String
        self.description = snapshotValue["description"] as! String
        self.price = snapshotValue["price"] as! String
        self.refArray = refArray
        self.malls = malls
        self.refProduct = snapshot.ref
    }
}

class PopularGroup {
    
    var name: String
    var group: [PopularGroup]?
    var product: [PopularProduct]?
    
    init(name: String, group: [PopularGroup]?, product: [PopularProduct]?) {
        self.name = name
        self.group = group
        self.product = product
    }
}


class PopularGarderob {
    
    var groups = [PopularGroup]()
    
}





//class HomeModel {
//    
//    let malls: [PreviewCategory]?
//    let brands: [PreviewCategory]?
//    let popularProduct: [PopularProduct]?
//    
//    
//}

//class Listig {
//
//    func anythereViewWillApeare() {
//
//        var number = 0
//        var arrayInArray = [[String]]() {
//            didSet {
//                number += 1
//                if number == 3 {
//                    // self.array = arrayInArray
//                    // self.tableView.reloadData()
//                }
//            }
//        }
//
//
//        ref.observe {
//
//
//        }
//
//        ref2.observe {
//
//
//        }
//
//        ref3.observe {
//
//
//        }
//    }
//
//}



