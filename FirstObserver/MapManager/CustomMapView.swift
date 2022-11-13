//
//  MapViewManager.swift
//  FirstObserver
//
//  Created by Evgenyi on 13.11.22.
//

import UIKit
import MapKit

protocol MapViewManagerDelegate: AnyObject {
    func selectAnnotationView(isSelect: Bool)
}

class CustomMapView: MKMapView {

    
    var regionMap: CLLocationDistance = 18000
    var arrayPin:[PlacesTest] = [] {
        didSet {
            addAnnotations(arrayPin)
        }
    }
    weak var delegateMallVC: MapViewManagerDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        delegate = self
        calculateRegion()
        isZoomEnabled = false
        isScrollEnabled = false
        isPitchEnabled = false
        isRotateEnabled = false
        
        let initialLocation = CLLocation(latitude: 53.903318, longitude: 27.560448)
        self.centerLocation(initialLocation, regionRadius: regionMap)
        
    }
    
    
    private func calculateRegion() {
        
        // 3.88 это 1% от т екущей ширины на storyboard
        let percentWidth = 100 - self.frame.size.width/3.88
        // если > 0 нужно не увеличивать а уменьшать newRegion
        guard percentWidth > 0 else { return }
        let plusPercent:Double = Double(Int(percentWidth))/100
        print(" plusPercent - \(plusPercent)")
        let newRegion = Int(18000*plusPercent*10)
        
        regionMap = CLLocationDistance(newRegion)
    }
    
    
}


extension CustomMapView: MKMapViewDelegate {
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard let annotation = annotation as? PlacesTest else { return nil }
        let identifier = "places"
        let view: MKMarkerAnnotationView
        
        if let dequeueView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            dequeueView.annotation = annotation
            view = dequeueView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.glyphTintColor = .black
            view.markerTintColor = .red
            
            if let image = annotation.image {
//                let fullSizeImage = UIImage(named: imageName)!
                let fullSizeImage = image
                let imageViewMall = UIImageView(image: fullSizeImage.thumbnailOfSize(CGSize(width: 60, height: 40)))
                view.leftCalloutAccessoryView = imageViewMall
                view.leftCalloutAccessoryView?.contentMode = .scaleAspectFit
            } else {
                view.leftCalloutAccessoryView = UIView()
            }
        }
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        delegateMallVC?.selectAnnotationView(isSelect: true)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        delegateMallVC?.selectAnnotationView(isSelect: false)
    }
}
