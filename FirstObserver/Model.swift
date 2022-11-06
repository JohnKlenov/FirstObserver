//
//  Model.swift
//  FirstObserver
//
//  Created by Evgenyi on 13.08.22.
//

import Foundation
import UIKit
import MapKit


class Model {
    
    var image: UIImage?
    
    init(image: UIImage) {
        self.image = image
    }
    
}

class HomeModel {
    
    var heightTableViewCell:CGFloat
    
    
    init(heightCell: CGFloat) {
        self.heightTableViewCell = heightCell
    }
    
}



// MARK: - ModelGroupsProduct -

class Mall {
    var nameMall: String
    var imageMall: [UIImage]
    var description: String
    var pin: Places
    var floorPlan: [UIImage]?

    init(nameMall: String, imageMall: [UIImage], description:String, pin: Places, floorPlan: [UIImage]?) {
        self.nameMall = nameMall
        self.imageMall = imageMall
        self.description = description
        self.pin = pin
        self.floorPlan = floorPlan
    }
}


class Group {
    
    var groups: [Group]?
    var name: String
    var product:[Product]?
    var image: UIImage
    
    init(name: String, image: UIImage, groups: [Group]?, product: [Product]?) {
        
        self.name = name
        self.image = image
        self.groups = groups
        self.product = product
    }

    
}

class Product {
    
    var name:String
    var price:Int
    var image:UIImage
    // var originContent: String?
    // var description: String
    // var contactsMall: [contactsMallModel]  contactsMallModel(imageRef:,nameRef:,title:)
    // var mapPin: [String]
    // var ref: [String]
    // Places(title: "ТЦ «Грин Сити»", locationName: "улица Притыцкого, 156/1", discipline: "Торговый центр", coordinate: CLLocationCoordinate2D(latitude: 53.908742, longitude: 27.434338), imageName: "GreenCity")
    
    
    init(name: String, price: Int, image:UIImage) {
        
        self.name = name
        self.price = price
        self.image = image
    }
}


class Menu {
    
    var groups = [Group]()
    
    init() {
        setupGroups()
    }
    
    
    func setupGroups() {
        
        //bootsGroup
        
        let p1 = Product(name: "Nike AIR FORCE White", price: 350, image: UIImage(named: "p1")!)
        let p2 = Product(name: "Nike x Carhartt WIP AIR FORCE", price: 280, image: UIImage(named: "p2")!)
        let p3 = Product(name: "Nike AIR TAILWIND 79", price: 455, image: UIImage(named: "p3")!)
        let p4 = Product(name: "Nike AIR FOAMPOSITE ONE", price: 677, image: UIImage(named: "p4")!)
        let p5 = Product(name: "Nike AIR FORCE 1 FOAMPOSITE CUP", price: 410, image: UIImage(named: "p5")!)
        let p6 = Product(name: "Nike LF1 DUCKBOOT 17", price: 473, image: UIImage(named: "p6")!)
        let p7 = Product(name: "Nike LF1 DUCKBOOT 17 Metallic", price: 355, image: UIImage(named: "p7")!)
        let p8 = Product(name: "Nike TIEMPO VETTA 17 Gold", price: 856, image: UIImage(named: "p8")!)
        
        let nike = [p1,p2,p3,p4,p5,p6,p7,p8]
//        let nikeGroup = Group(groups: nil, name: "Nike", product: nike, image: UIImage(named: "p1")!)
        let nikeGroup = Group(name: "Nke", image: UIImage(named: "p1")!, groups: nil, product: nike)
        
        
        let p9 = Product(name: "Puma CLYDE STITCHED HAN", price: 245, image: UIImage(named: "p9")!)
        let p10 = Product(name: "Puma RS-X3 SONIC COLOR", price: 743, image: UIImage(named: "p10")!)
        let p11 = Product(name: "Puma SUEDE X ALIFE", price: 833, image: UIImage(named: "p11")!)
        let p12 = Product(name: "Puma x DP COURT PLATFORM", price: 499, image: UIImage(named: "p12")!)
        let p13 = Product(name: "Puma x The Hundreds FUTURE RIDER", price: 522, image: UIImage(named: "p13")!)
        let p14 = Product(name: "Puma RS-X3 SONIC COLOR 2", price: 743, image: UIImage(named: "p14")!)
        
        let puma = [p9,p10,p11,p12,p13,p14]
        let pumaGroup = Group(name: "Puma", image: UIImage(named: "p12")!, groups: nil, product: puma)
        
        let p15 = Product(name: "Reebok CLASSIC LEATHER MID SHERPA ll", price: 387, image: UIImage(named: "p15")!)
        let p16 = Product(name: "Reebok CLUB C 85 INDOOR Baseball", price: 344, image: UIImage(named: "p16")!)
        let p17 = Product(name: "Reebok DAYTONA DMX X VAINL", price: 344, image: UIImage(named: "p17")!)
        let p18 = Product(name: "Reebok FURYLITE GM Sand", price: 270, image: UIImage(named: "p18")!)
        let p19 = Product(name: "Reebok INSTA PUMP FURY OG Smokey", price: 389, image: UIImage(named: "p19")!)
        let p20 = Product(name: "Reebok x OXXXYMIRON CLUB C 85", price: 400, image: UIImage(named: "p20")!)
        
        let reebok = [p15,p16,p17,p18,p19,p20]
        let reebokGroup = Group(name: "Reebok", image: UIImage(named: "p20")!, groups: nil, product: reebok)
        
        let p21 = Product(name: "Adidas RIVALRY RM Running", price: 899, image: UIImage(named: "p21")!)
        let p22 = Product(name: "Adidas DEERUPT RUNNER Solar", price: 467, image: UIImage(named: "p22")!)
        let p23 = Product(name: "Adidas INIKI RUNNER Solar", price: 700, image: UIImage(named: "p23")!)
        let p24 = Product(name: "Adidas PROPHERE Triple Black", price: 750, image: UIImage(named: "p24")!)
        let p25 = Product(name: "Adidas TUBULAR SHADOW Core", price: 888, image: UIImage(named: "p25")!)
        let p26 = Product(name: "Adidas ZX FLUX ADV Spring", price: 999, image: UIImage(named: "p26")!)
        
        let adidas = [p21,p22,p23,p24,p25,p26]
        let adidasGroup = Group(name: "Adidas", image: UIImage(named: "p23")!, groups: nil, product: adidas)
        
        let p27 = Product(name: "Jordan AIR JORDAN 8 RETRO TINKER", price: 1120, image: UIImage(named: "p27")!)
        let p28 = Product(name: "Jordan AIR JORDAN 11 RETRO", price: 800, image: UIImage(named: "p28")!)
        let p29 = Product(name: "Jordan AIR JORDAN XIII RETRO LOW", price: 900, image: UIImage(named: "p29")!)
        let p30 = Product(name: "Jordan AIR JORDAN RETRO 13", price: 450, image: UIImage(named: "p30")!)
        let p31 = Product(name: "Jordan AIR JORDAN 12 RETRO WOOL", price: 850, image: UIImage(named: "p31")!)
        let p32 = Product(name: "Jordan AIR JORDAN 13 RETRO", price: 345, image: UIImage(named: "p32")!)
        let p33 = Product(name: "Jordan AIR JORDAN 6 RETRO", price: 965, image: UIImage(named: "p33")!)
        
        let jordan = [p27,p28,p29,p30,p31,p32,p33]
        let jordanGroup = Group(name: "Jordan", image: UIImage(named: "p28")!, groups: nil, product: jordan)
        
        let p34 = Product(name: "New Balance CT300ATB/D", price: 1000, image: UIImage(named: "p34")!)
        let p35 = Product(name: "New Balance M576NRW/D", price: 777, image: UIImage(named: "p35")!)
        let p36 = Product(name: "New Balance M577BDB/D", price: 456, image: UIImage(named: "p36")!)
        let p37 = Product(name: "New Balance M997DSAI/D", price: 311, image: UIImage(named: "p37")!)
        let p38 = Product(name: "New Balance M998CBB/D", price: 432, image: UIImage(named: "p38")!)
        let p39 = Product(name: "New Balance ML574BCA/D", price: 955, image: UIImage(named: "p39")!)
        
        let newBalance = [p34,p35,p36,p37,p38,p39]
        let newBalanceGroup = Group(name: "NewBalance", image: UIImage(named: "p38")!, groups: nil, product: newBalance)
        
        
        let bootsGroup = Group(name: "Boots", image: UIImage(named: "p31")!, groups: [nikeGroup,pumaGroup,reebokGroup,adidasGroup,jordanGroup,newBalanceGroup], product: nil)
        
        groups.append(bootsGroup)
        
    }
    
}


//
//// MARK: - ModelAnnotation -
//
//
//
//class Places: NSObject, MKAnnotation {
//    
//    let title: String?
//    let locationName: String?
//    let discipline: String?
//    let imageName: String?
//    let coordinate: CLLocationCoordinate2D
//    
//    init(title:String?, locationName:String?, discipline:String?, coordinate: CLLocationCoordinate2D, imageName: String?) {
//        
//        self.title = title
//        self.locationName = locationName
//        self.discipline = discipline
//        self.coordinate = coordinate
//        self.imageName = imageName
//        super.init()
//    }
//    
//    var subtitle: String? {
//        return locationName
//    }
//    
//}
