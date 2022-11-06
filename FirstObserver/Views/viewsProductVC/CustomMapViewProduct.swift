//
//  CustomMapViewProduct.swift
//  FirstObserver
//
//  Created by Evgenyi on 20.09.22.
//

/*
// Only override draw() if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
override func draw(_ rect: CGRect) {
    // Drawing code
}
*/

import UIKit
import MapKit

class CustomMapViewProduct: MKMapView {
    
    var annotation = [MKPointAnnotation]()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        let green = MKPointAnnotation()
               green.title = "ТЦ «Грин Сити»"
               green.subtitle = "улица Притыцкого, 156/1"
               let greenCoordinate = CLLocationCoordinate2D(latitude: 53.908742, longitude: 27.434338)
               green.coordinate = greenCoordinate
               annotation.append(green)
       
               let galleria = MKPointAnnotation()
               galleria.title = "ТЦ «Galleria Minsk»"
               galleria.subtitle = "просп. Победителей, 9"
               let galleriaCoordinate = CLLocationCoordinate2D(latitude: 53.908423, longitude: 27.548857)
               galleria.coordinate = galleriaCoordinate
               annotation.append(galleria)
       
               self.showAnnotations(annotations, animated: true)
    }

//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        let green = MKPointAnnotation()
//        green.title = "ТЦ «Грин Сити»"
//        green.subtitle = "улица Притыцкого, 156/1"
//        let greenCoordinate = CLLocationCoordinate2D(latitude: 53.908742, longitude: 27.434338)
//        green.coordinate = greenCoordinate
//        annotation.append(green)
//
//        let galleria = MKPointAnnotation()
//        galleria.title = "ТЦ «Galleria Minsk»"
//        galleria.subtitle = "просп. Победителей, 9"
//        let galleriaCoordinate = CLLocationCoordinate2D(latitude: 53.908423, longitude: 27.548857)
//        galleria.coordinate = galleriaCoordinate
//        annotation.append(galleria)
//
//        self.showAnnotations(annotations, animated: true)
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        fatalError("init(coder:) has not been implemented")
//    }
    
}



