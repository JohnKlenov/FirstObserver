//
//  MapViewController.swift
//  FirstObserver
//
//  Created by Evgenyi on 17.09.22.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    // Объект, который вы используете для мониторинга местоположения, в вашем приложении.
    let locationManager = CLLocationManager()
    var arrayPin: [PlacesTest] = []
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        mapView.delegate = self
        let initialLocation = CLLocation(latitude: 53.903318, longitude: 27.560448)
        mapView.centerLocationMVC(initialLocation)
        
        setupZoomLimit()
        
//        let greenMVC = Places(title: "ТЦ «Грин Сити»", locationName: "улица Притыцкого, 156/1", discipline: "Торговый центр", coordinate: CLLocationCoordinate2D(latitude: 53.908742, longitude: 27.434338), imageName: "GreenCity")
//        let galleriaMVC = Places(title: "ТЦ «Galleria Minsk»", locationName: "просп. Победителей, 9", discipline: "Торговый центр", coordinate: CLLocationCoordinate2D(latitude: 53.908423, longitude: 27.548857), imageName: "GalleriaMinsk")
//
//        let danaMVC = Places(title: "ТЦ «Dana Mall»", locationName: "Минск, ул. Петра Мстиславца, 11", discipline: "Торговый центр", coordinate: CLLocationCoordinate2D(latitude: 53.933346, longitude: 27.650836), imageName: "DanaMall")
//        mapView.addAnnotations([greenMVC, galleriaMVC, danaMVC])
        
        mapView.addAnnotations(arrayPin)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationEnabled()
        
    }
    
    
    // включена ли у нас служба геолокации на устройстве если true то включена.
    private func checkLocationEnabled() {
        
        if CLLocationManager.locationServicesEnabled() {
            
            setupManager()
            checkAuthorization()
            
            // включили geolocation, вернулись в App сработал func sceneDidBecomeActive(_ scene: UIScene)
            // если мы отменили Alert и не пошли в Settings - SceneDelegate.flag = true
            // И если мы перейдем в другую App а затем вернемся в эту сработает func sceneDidBecomeActive(_ scene: UIScene) ????
        } else {
            SceneDelegate.flag = true
            SceneDelegate.mapVC = self
            showAlertLocation(title: "Location service turned off!", message: "Wanna turn on?", url: URL(string: "App-Prefs:root=LOCATION_SERVICES"))
        }
    }
    
    
    func setupManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    
    // получить разрешение пользователя на использование его место положения в Application
    func checkAuthorization() {
        
        let autorizationStatus: CLAuthorizationStatus
        
        if #available(iOS 14, *) {
            print("curent iOS >= iOS 14")
            autorizationStatus = locationManager.authorizationStatus
        } else {
            autorizationStatus = CLLocationManager.authorizationStatus()
        }
        
        switch autorizationStatus {
            
        case .notDetermined:
            print(".notDetermined")
            // вызываем запрос на разрешение использовать место положения user в Application
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .denied:
            showAlertLocation(title: "Вы запретили использования местоположения в приложении", message: "Хотите это изменить?", url: URL(string: UIApplication.openSettingsURLString))
        case .authorizedAlways:
            // ????
            break
        case .authorizedWhenInUse:
            print(".authorizedWhenInUse - разрешить в момент использования")
            mapView.showsUserLocation = true
//            locationManager.requestLocation()
            //  .requestLocation() это метод который один раз запрашивает геопозицию пользователя.
//            locationManager.startUpdatingLocation()
        @unknown default:
            print("@unknown default")
            break
        }
    }
    
    
    private func showAlertLocation(title: String, message: String?, url: URL?) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let settingAction = UIAlertAction(title: "Setting", style: .default) { (alert) in
            if let url = url {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(settingAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    // Сделаем так что бы мы камеру могли за зумить на расстояние города и не больше и не меньше 1 км.
    
    func setupZoomLimit() {
        
        let cameraCentre =  CLLocation(latitude: 53.903318, longitude: 27.560448)
        let region = MKCoordinateRegion(center: cameraCentre.coordinate, latitudinalMeters: 22000, longitudinalMeters: 22000)
        mapView.setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: region), animated: true)
        
        let zoomLimit = MKMapView.CameraZoomRange(minCenterCoordinateDistance: 1000, maxCenterCoordinateDistance: 100000)
        mapView.setCameraZoomRange(zoomLimit, animated: true)
    }

   

}

extension MapViewController: CLLocationManagerDelegate, MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? Places else {return nil}
        let identifier = "placesMVC"
        let view: MKMarkerAnnotationView
        
        if let dequeueView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            dequeueView.annotation = annotation
            view = dequeueView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.glyphTintColor = .black
            view.markerTintColor = .red
            
            if let imageName = annotation.imageName {
                let fullSizeImage = UIImage(named: imageName)!
                let imageViewMall = UIImageView(image: fullSizeImage.thumbnailOfSize(CGSize(width: 60, height: 40)))
                view.leftCalloutAccessoryView = imageViewMall
                view.leftCalloutAccessoryView?.contentMode = .scaleAspectFit
            } else {
                view.leftCalloutAccessoryView = UIView()
            }
        }
        return view
    }
    
    
    
    // если user поменял авторизацию у нас опять все сломается и нам нужно вызвать checkAuthorization()
    // если ты в момент использования App зашёл в settings и нажал запретить использовать геолокацию в этом App
    // сработает метод didChangeAuthorization и мы опять вызовем  checkAutorization()
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkAuthorization()
    }
}


extension MKMapView {
    
// центрируем камеру
    func centerLocationMVC(_ location: CLLocation, regionRadius: CLLocationDistance = 22000) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}










// когда у нас координаты обновляются мы карту будем двигать. Следить за пользователям.
//  видимую площадь в 1 км.
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let location = locations.last?.coordinate {
//            let region = MKCoordinateRegion(center: location, latitudinalMeters: 1000, longitudinalMeters: 1000)
//            mapView.setRegion(region, animated: true)
//        }
//    }
