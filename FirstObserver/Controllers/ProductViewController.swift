//
//  ProductViewController.swift
//  FirstObserver
//
//  Created by Evgenyi on 9.09.22.
//

import UIKit
import MapKit
import FirebaseStorage
import FirebaseStorageUI
import FirebaseAuth
import Firebase


protocol ProductViewControllerDelegate: AnyObject {
    func allProductsToCard(completionHandler: ([PopularProduct]) -> Void)
}

class ProductViewController: UIViewController {

    
    // MARK: - Constraint outllet -
    
    @IBOutlet weak var productCVConstraintHeight: NSLayoutConstraint!
    @IBOutlet weak var topCnstrNameLabel: NSLayoutConstraint!
    @IBOutlet weak var topCnstrPriceLabel: NSLayoutConstraint!
    @IBOutlet weak var topCnstrContentButton: NSLayoutConstraint!
    @IBOutlet weak var topCnstrCartButton: NSLayoutConstraint!
    @IBOutlet weak var topCnstrDescriptionLabel: NSLayoutConstraint!
    @IBOutlet weak var topCnstrTextViewLabel: NSLayoutConstraint!
    @IBOutlet weak var topCnstrContaktLabel: NSLayoutConstraint!
    @IBOutlet weak var topCnstrTVMalls: NSLayoutConstraint!
    @IBOutlet weak var topCnstrLocationLabel: NSLayoutConstraint!
    @IBOutlet weak var topCnstrMapView: NSLayoutConstraint!
    
    
    @IBOutlet weak var heightCnstrContentButton: NSLayoutConstraint!
    @IBOutlet weak var heightCnstrCartButton: NSLayoutConstraint!
    @IBOutlet weak var heightCnstrTVMalls: NSLayoutConstraint!
    @IBOutlet weak var heightCnstrMapView: NSLayoutConstraint!
    
    @IBOutlet weak var topConstraintPageControl: NSLayoutConstraint!
    
    
    
    // MARK: - outlet object UI -
    
    
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var modelName: UILabel!
    @IBOutlet weak var productPageControl: UIPageControl!
    @IBOutlet weak var productCollectionView: UICollectionView!
    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var tableViewMalls: UITableView!
    
    @IBOutlet weak var addToCartButton: UIButton!
    @IBOutlet weak var mapViewProduct: MKMapView!
    

    
    
    var region: CLLocationDistance = 18000
//    var text = " "
    var onePercenteSAH: CGFloat!
    var frameSizeSA:CGSize!
//    var menu = Menu()
    let tapGestureRecognizer = UITapGestureRecognizer()
    var isSelectedAnnotation:Bool = false
    
    
    // MARK: -Computer property? -
    var userS: User? {
        return Auth.auth().currentUser
    }
    
    // MARK: - NewModel -
    
   var fireBaseModel:PopularProduct?
    var arrayPin:[PlacesTest] = []
    var storage:Storage!
    var isAddedToCard: Bool = false
    
    
    
    // MARK: -AddedProduct for Realtime database -
    
    private lazy var ref: DatabaseReference? = {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }

        let ref = Database.database().reference(withPath: "usersAccaunt/\(uid)/AddedProducts")
        return ref
    }()
    
    private let encoder = JSONEncoder()
//    var addedInCartProducts: [PopularProduct] = []
    
    
    
    @IBAction func didTapAddToCart(_ sender: Any) {
        
        // save product in realtime database
        saveProductFB()
        
        let bool = UserDefaults.standard.bool(forKey: "WarningKey")
        // условие должно быть !bool
        if !bool {
            performSegue(withIdentifier: "signInVC", sender: nil)
                guard let button = sender as? UIButton else {return}
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.updateButton(button: button)
            }
                
        } else {
            
            // добавляем product в папку users на firebase.
            guard let button = sender as? UIButton else {return}
            updateButton(button: button)
            
        }
    }
    
    private func saveProductFB() {
        
        guard let product = fireBaseModel, let ref = ref else { return }
        
        let productEncode = AddedProduct(product: product)
        
        do {
            let data = try encoder.encode(productEncode)
            let json = try JSONSerialization.jsonObject(with: data)
            ref.updateChildValues([product.model:json])
        } catch {
            print("an error occured", error)
        }
        
        
    }
    
//    private func getaddedToCardProducts(completionHandler: ([PopularProduct]) -> Void) {
//
//        let firstNC = navigationController?.viewControllers.first
//        print("firstNC firstNC firstNC - \(firstNC)")
//        if let tabBarVCs = firstNC?.tabBarController?.viewControllers {
//            tabBarVCs.forEach { (vc) in
//                if let nc = vc as? UINavigationController {
//                    if let homeVC = nc.viewControllers.first as? HomeViewController {
//                        print("Get HomeViewController")
//                        completionHandler(homeVC.addedToCardProducts)
////                        self.addedInCartProducts = homeVC.addedToCardProducts
////                        print("ProductViewController - \(addedInCartProducts)")
//                    }
//                }
//            }
//        }
//    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        getaddedToCardProducts()
        UserDefaults.standard.set(false, forKey: "WarningKey")
        
        configureButton()
        
        storage = Storage.storage()

        // configure outlet
        addToCartButton.setImage(UIImage(systemName: "cart"), for: .normal)
        addToCartButton.semanticContentAttribute = .forceRightToLeft
        
        modelName.text = fireBaseModel?.model
        price.text = fireBaseModel?.price
        descriptionText.text = fireBaseModel?.description
        
        self.view.bringSubviewToFront(self.view)
        
        productPageControl.numberOfPages = fireBaseModel?.refArray.count ?? 1
        productPageControl.currentPage = 0
        productPageControl.pageIndicatorTintColor = .systemBrown
        productPageControl.currentPageIndicatorTintColor = .black
        
        self.tabBarController?.tabBar.isHidden = true

        productCollectionView.delegate = self
        productCollectionView.dataSource = self
        
        tableViewMalls.delegate = self
        tableViewMalls.dataSource = self
        
        // адаптируем regionRadius для mapView (что бы город влезал в mapView ProductVC на всех устройствах)
        colculateRegion()
        
        setupPin(region, arrayPin: arrayPin)
        configureTapGestureRecognizer()
//        configurationButton()
        
    }
    
    private func configureButton() {
        if isAddedToCard {
            addToCartButton.isUserInteractionEnabled = false
            addToCartButton.alpha = 0.8
        }
    }
    
    private func updateButton(button:UIButton) {
        button.setTitle("added to cart", for: .normal)
        button.setImage(UIImage(systemName: "cart.fill"), for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        UIView.animate(withDuration: 0.1) {
            button.alpha = 0.8
        } completion: { bool in
            button.isUserInteractionEnabled = false
        }
    }
    
    func configurationButton() {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .black
        config.cornerStyle = .medium
        let hendler: UIButton.ConfigurationUpdateHandler = { button in
            switch button.state {
            case [.selected, .highlighted]:
                button.configuration?.title = "highlighted selected"
            case .selected:
                button.configuration?.title = "selected"
            case .highlighted:
                button.configuration?.title = "added to cart"
                button.isEnabled = false
            case .disabled:
                button.configuration?.title = "added to cart"
            case .normal:
                button.configuration?.title = "addToCartNormal"
            default:
                print("default")
            }

        }
        
        addToCartButton.configurationUpdateHandler = hendler
        addToCartButton.configuration = config
    }
    
    
    func colculateRegion() {
        // 3.88 это 1% от т екущей ширины на storyboard
        let percentWidth = 100 - mapViewProduct.frame.size.width/3.88
        // если > 0 нужно не увеличивать а уменьшать newRegion
        guard percentWidth > 0 else { return }
        let plusPercent:Double = Double(Int(percentWidth))/100
        print(" plusPercent - \(plusPercent)")
        let newRegion = Int(18000*plusPercent*10)
        
        region = CLLocationDistance(newRegion)
    }
    
    
//    private func getImagefromStorage(refImage:String, completionHandler: @escaping (UIImage) -> Void) {
//        let ref = storage.reference(forURL: refImage)
//        let megaBite = Int64(1*1024*1024)
//        ref.getData(maxSize: megaBite) { (data, error) in
//            guard let imageData = data else {
//                let defaultImage = UIImage(named: "DefaultImage")!
//                completionHandler(defaultImage)
//                return
//            }
//            if let image = UIImage(data: imageData) {
//                completionHandler(image)
//            }
//        }
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear - mapViewProduct.frame.size - \(mapViewProduct.frame.size)")
        
//        var arrayPlaces:[PlacesFB] = []
//        var arrayPin:[PlacesTest] = []
//
//        ref.observe(.value) { [weak self] (snapshot) in
//            for place in snapshot.children {
//                let place = place as! DataSnapshot
//                let model = PlacesFB(snapshot: place)
//                if let fireBaseModel = self?.fireBaseModel {
//                    if fireBaseModel.malls.contains(model.name) {
//                        arrayPlaces.append(model)
//                        // вызываем метод
//                        self?.getImagefromStorage(refImage: model.refImage) { image in
//                            let pin = PlacesTest(title: model.name, locationName: model.address, discipline: "Торговый центр", coordinate: CLLocationCoordinate2D(latitude: model.latitude, longitude: model.longitude), image: image)
//                            arrayPin.append(pin)
//                        }
//
//                    }
//                }
//            }
//            self?.arrayPlaces = arrayPlaces
////            self?.arrayPin = arrayPin
//            self?.setupPin(self!.region, arrayPin: arrayPin)
//            self?.tableViewMalls.reloadData()
//
//        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear - mapViewProduct.frame.size - \(mapViewProduct.frame.size)")
    }
    
    
    func configureTapGestureRecognizer() {
        tapGestureRecognizer.addTarget(self, action: #selector(handleTapSingleRecognizer(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        mapViewProduct.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
//    annotationView.point(inside: point, with: nil)
    @objc func handleTapSingleRecognizer(_ gestureRecognizer: UITapGestureRecognizer) {
        
        print("Сработал handleTapSingleRecognizer")
        var countFalse = 0
       
        for annotation in mapViewProduct.annotations {
            
            if let annotationView = mapViewProduct.view(for: annotation), let annotationMarker = annotationView as? MKMarkerAnnotationView {

                let point = gestureRecognizer.location(in: mapViewProduct)
                print("point - \(gestureRecognizer.location(in: mapViewProduct))")
                let convertPoint = mapViewProduct.convert(point, to: annotationMarker)
                print("convertPoint - \(convertPoint)")
                if annotationMarker.point(inside: convertPoint, with: nil) {
                    print("поппали")
                } else {
                    print("не попали")
                    countFalse+=1
                }
                print("\(annotationMarker.frame.size)")
            }
            
        }

        if countFalse == mapViewProduct.annotations.count, isSelectedAnnotation == false {
            print("Переходим на VC")
            performSegue(withIdentifier: "goToMapVC", sender: arrayPin)
        }
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }

    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        onePercenteHeight()
        percentConstraint()
        setupCnstrPageControl()
    }
    

    
    // по нажатию на pageControl пролистываем collectionViewCell
    
    @IBAction func changePageControl(_ sender: UIPageControl) {
        print("changePageControl - currentPage \(sender.currentPage)")
        
        productCollectionView.scrollToItem(at: IndexPath(item: sender.currentPage, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToMapVC", let arrayPin = sender as? [PlacesTest] {
            let destination = segue.destination as! MapViewController
            destination.arrayPin = arrayPin
        }
        
        if segue.identifier == "signInVC" {
            let destination = segue.destination as! SignInViewController
            destination.productDelegate = self
        }
    }
    
    
    func setupPin(_ region:CLLocationDistance, arrayPin: [PlacesTest]) {
        
        
        mapViewProduct.delegate = self

        mapViewProduct.isZoomEnabled = false
        mapViewProduct.isScrollEnabled = false
        mapViewProduct.isPitchEnabled = false
        mapViewProduct.isRotateEnabled = false
//
        
        let initialLocation = CLLocation(latitude: 53.903318, longitude: 27.560448)
        mapViewProduct.centerLocation(initialLocation, regionRadius: region)
//        mapViewProduct.centerLocation(initialLocation)
        
//        let green = Places(title: "ТЦ «Грин Сити»", locationName: "улица Притыцкого, 156/1", discipline: "Торговый центр", coordinate: CLLocationCoordinate2D(latitude: 53.908742, longitude: 27.434338), imageName: "GreenCity")
//        let galleria = Places(title: "ТЦ «Galleria Minsk»", locationName: "просп. Победителей, 9", discipline: "Торговый центр", coordinate: CLLocationCoordinate2D(latitude: 53.908423, longitude: 27.548857), imageName: "GalleriaMinsk")
//
//        let dana = Places(title: "ТЦ «Dana Mall»", locationName: "Минск, ул. Петра Мстиславца, 11", discipline: "Торговый центр", coordinate: CLLocationCoordinate2D(latitude: 53.933346, longitude: 27.650836), imageName: "DanaMall")
        
        // [green,galleria, dana]
        
        mapViewProduct.addAnnotations(arrayPin)
    }


    
    
    // MARK:  - Calculate constraint -
    
    
    private func onePercenteHeight() {
        
        let guide = view.safeAreaLayoutGuide
        frameSizeSA = guide.layoutFrame.size
        let heightSafeArea = frameSizeSA.height
        onePercenteSAH = heightSafeArea/100
    }
    
    private func percentConstraint() {
        
        productCVConstraintHeight.constant = frameSizeSA.height/2
        
        let thirty:CGFloat = 30/8.48
        let eight:CGFloat = 1
        let twenty:CGFloat = 20/8.48
        let heightTVMall:CGFloat = CGFloat(arrayPin.count)*50
        let threeHundredEightyEight:CGFloat = 388/8.48
        
        topCnstrNameLabel.constant = thirty*onePercenteSAH
        topCnstrPriceLabel.constant = eight*onePercenteSAH
        topCnstrContentButton.constant = thirty*onePercenteSAH
        topCnstrCartButton.constant = eight*onePercenteSAH
        topCnstrDescriptionLabel.constant = thirty*onePercenteSAH
        topCnstrTextViewLabel.constant = twenty*onePercenteSAH
        topCnstrContaktLabel.constant = thirty*onePercenteSAH
        
        topCnstrTVMalls.constant = thirty*onePercenteSAH
        heightCnstrTVMalls.constant = heightTVMall
        
        topCnstrLocationLabel.constant = thirty*onePercenteSAH
        topCnstrMapView.constant = thirty*onePercenteSAH
        heightCnstrMapView.constant = threeHundredEightyEight*onePercenteSAH
    }
    
    private func setupCnstrPageControl() {
        
        let hCnstrPageControl = frameSizeSA.height/2 - 20 - productPageControl.frame.height - 10
        topConstraintPageControl.constant = hCnstrPageControl
        
    }

}







// MARK: - CollectionView Methods -

extension ProductViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fireBaseModel?.refArray.count ?? 0
    }
//    menu.groups[0].groups?[1].product?.count ?? 0
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductVCCollectionViewCell", for: indexPath) as! ProductVCCollectionViewCell
        
//        guard let product = menu.groups[0].groups?[1].product?[indexPath.row] else { return UICollectionViewCell() }
        
//        cell.setupCell(image: product.image)
        
        guard let refImage = fireBaseModel?.refArray[indexPath.row] else { return UICollectionViewCell() }
        cell.setupCell(refImage: refImage)
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 40, height: collectionView.frame.height - 40)
    }
    
    // меняем currentPage когда мы пролеснули свайпом collectionViewCell
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        let currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
        productPageControl.currentPage = currentPage

    }

}


// MARK: - TableView Methods -

extension ProductViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayPin.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewMalls", for: indexPath)
        var contentCell = cell.defaultContentConfiguration()
        contentCell.text = arrayPin[indexPath.row].title
        contentCell.image = arrayPin[indexPath.row].image
        cell.contentConfiguration = contentCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        let string = mallsArray[indexPath.row]
//        performSegue(withIdentifier: "goToContatctsMall", sender: string)
//        performSegue(withIdentifier: "goToMapVC", sender: nil)
    }
    
}



// MARK: - MKMapView -


extension MKMapView {

    func centerLocation(_ location: CLLocation, regionRadius: CLLocationDistance) {
        print("centerLocation centerLocation centerLocation \(regionRadius)")
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    
    }
}

extension ProductViewController: MKMapViewDelegate {
    
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
        isSelectedAnnotation = true
        print("сработал didSelect MKAnnotationView")
    }

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        isSelectedAnnotation = false
        print("didDeselect MKAnnotationView")
    }

}

extension ProductViewController: ProductViewControllerDelegate {
  
    func allProductsToCard(completionHandler: ([PopularProduct]) -> Void) {
        

            let firstNC = navigationController?.viewControllers.first
        print("firstNC firstNC firstNC - \(String(describing: firstNC))")
            if let tabBarVCs = firstNC?.tabBarController?.viewControllers {
                tabBarVCs.forEach { (vc) in
                    if let nc = vc as? UINavigationController {
                        if let homeVC = nc.viewControllers.first as? HomeViewController {
                            print("Get HomeViewController")
                            completionHandler(homeVC.addedToCardProducts)
                        }
                    }
                }
            }
        }
    
    
    
    
}




