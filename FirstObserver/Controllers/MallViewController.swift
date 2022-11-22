//
//  MallViewController.swift
//  FirstObserver
//
//  Created by Evgenyi on 7.11.22.
//

import UIKit
import SafariServices
import MapKit
import Firebase


protocol ChildVCDelegate: AnyObject {
    
    func goToBrandVC(pathRef: String)
}

class MallViewController: UIViewController {

    
    
    // MARK:  outlet property
    @IBOutlet weak var mallCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var brandStackView: UIStackView!
    @IBOutlet weak var mapView: CustomMapView!
    @IBOutlet weak var floorPlanButton: UIButton!
    @IBOutlet weak var webSiteButton: UIButton!
   
    // MARK: constraints from outlet
    @IBOutlet weak var heightCollectionView: NSLayoutConstraint!
    @IBOutlet weak var topCnstrPageControl: NSLayoutConstraint!
    
    // MARK: another property
    var modelImageForCV:[String] = [] {
        didSet {
            mallCollectionView.reloadData()
        }
    }
    var modelChild:[UIImage] = []
    var floorPlan: String = ""
    var webSite: String = ""
    
    let childCVC = ChildCollectionViewController(arrayBrands: [PreviewCategory]())
    
    // MARK: MapView property
    var isSelected:Bool = false
    var tapGestureRecognizer = UITapGestureRecognizer()
    
    
    // MARK: FB property
    var ref: DatabaseReference!
    var refPath: String = ""
    var arrayPin:[PlacesTest] = []
    var brandsMall: [PreviewCategory] = []
    var startMallModel:MallModel? {
        didSet {
            print("Сработал startMallModel")
            if let model = startMallModel {
                configureViews(mallModel: model)
            }
        }
    }
    
    
    // MARK: -Life cycle methods -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        let currentPin = arrayPin.filter({$0.title == refPath})
        mapView.arrayPin = currentPin
        mapView.delegateMallVC = self
        
        mallCollectionView.delegate = self
        mallCollectionView.dataSource = self
        
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .systemBrown
        pageControl.currentPageIndicatorTintColor = .black
        
        childCVC.view.translatesAutoresizingMaskIntoConstraints = false
        brandStackView.addArrangedSubview(childCVC.view)
        childCVC.delegate = self
        addChild(childCVC)
        configureTapGestureRecognizer()

    }
    
    
    
   
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ref.child("Malls/\(refPath)").observe(.value) { (snapshot) in
            
            var arrayBrands:[String] = []
            var arrayRefImage:[String] = []
            
            for item in snapshot.children {
                let child = item as! DataSnapshot
                
                switch child.key {
                
                case "brands":
                    for itemBrand in child.children {
                        let brand = itemBrand as! DataSnapshot
                        if let nameBrand = brand.value as? String {
                            arrayBrands.append(nameBrand)
                        }
                    }
                case "refImage":
                    for itemRef in child.children {
                        let ref = itemRef as! DataSnapshot
                        if let refImage = ref.value as? String {
                            arrayRefImage.append(refImage)
                        }
                    }
                    
                default:
                    break
                }
                
            }
            print("Получили MallModel")
            let mallModel = MallModel(snapshot: snapshot, refImage: arrayRefImage, brands: arrayBrands)
            self.startMallModel = mallModel
        }
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupConstraint()
    }
    
    
    // MARK: - @IBAction func -

    @IBAction func didTapFloorPlan(_ sender: Any) {
    
        self.showWebView(floorPlan)
        
    }
    
    @IBAction func didTapWebsite(_ sender: Any) {
        
        self.showWebView(webSite)
    }
    
    
    @IBAction func changePageControl(_ sender: UIPageControl) {
        
        mallCollectionView.scrollToItem(at: IndexPath(item: sender.currentPage, section: 0), at: .centeredHorizontally, animated: true)
    }
    
   
    
    
    
    // MARK: - TapGestureRecognizer -
    
    private func configureTapGestureRecognizer() {
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.addTarget(self, action: #selector(handleTapSingleRecognizer(_:)))
        mapView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func handleTapSingleRecognizer(_ gestureRecognizer: UITapGestureRecognizer) {
        
        print("Сработал handleTapSingleRecognizer")
        var countFalse = 0
        
        for annotation in mapView.annotations {
            
            if let annotationView = mapView.view(for: annotation), let annotationMarker = annotationView as? MKMarkerAnnotationView {
                
                let point = gestureRecognizer.location(in: mapView)
                print("point - \(gestureRecognizer.location(in: mapView))")
                let convertPoint = mapView.convert(point, to: annotationMarker)
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
        
        if countFalse == mapView.annotations.count, isSelected == false {
            print("Переходим на VC")
//            performSegue(withIdentifier: "goToMapVC", sender: nil)
        }
    }
    
    
    
    // MARK: - another methods -
    
    
    private func configureViews(mallModel:MallModel) {
        
        var modelBrands: [PreviewCategory] = []
        brandsMall.forEach { (previewBrands) in
            if mallModel.brands.contains(previewBrands.brand ?? "") {
                modelBrands.append(previewBrands)
                // setupChildVC(modelBrands)
            }
        }
        print("modelBrands \(modelBrands)")
        childCVC.configureChildVC(arrayBrands: modelBrands)
        
        
        self.title = mallModel.name
        modelImageForCV = mallModel.refImage
        
        if let plan = mallModel.floorPlan {
            floorPlan = plan
        } else {
            floorPlanButton.isHidden = true
        }
        
        if let web = mallModel.webSite {
            webSite = web
        } else {
            webSiteButton.isHidden = true
        }
        
        pageControl.numberOfPages = mallModel.refImage.count
        
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
        pageControl.currentPage = currentPage
    }
    
    
    // MARK: - calculate constraint -
    
    
    private func setupConstraint() {
        
        // heightCollectionView
        let guide = self.view.safeAreaLayoutGuide
        let heightSafeArea = guide.layoutFrame.height
        print("heightSafeArea - \(heightSafeArea)")
        heightCollectionView.constant = heightSafeArea*0.35
        
        // topCnstrPageControl
        let hCV = heightSafeArea*0.35
        topCnstrPageControl.constant = hCV - 30
    }
    
}




// MARK: - CollectionView -
extension MallViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return modelImageForCV.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageMallCollectionViewCell", for: indexPath) as! ImageMallCollectionViewCell
        cell.configure(mallImageRef: modelImageForCV[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddings = 10*2
        let widthCell = collectionView.frame.width - CGFloat(paddings)
        let heightCell = collectionView.frame.height - CGFloat(paddings + 10)
        return CGSize(width: widthCell, height: heightCell)
    }
    
}


// MARK: - SafariViewController -
extension UIViewController {
    func showWebView(_ urlString: String) {
       
        guard let url = URL(string: urlString) else { return }
        
        let vc = SFSafariViewController(url: url)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
}


// MARK:  - MapViewManagerDelegate -

extension MallViewController: MapViewManagerDelegate {
    func selectAnnotationView(isSelect: Bool) {
        print("func selectAnnotationView(isSelect: Bool) - \(isSelect)")
        self.isSelected = isSelect
    }
    
}


// MARK: - Navigation ChildVCDelegate  -

extension MallViewController: ChildVCDelegate {
    
    func goToBrandVC(pathRef: String) {
        
        let ref = Database.database().reference(withPath: "brands/\(pathRef)")
        let brandVC = UIStoryboard.vcById("BrandsViewController") as! BrandsViewController
        brandVC.incomingRef = ref
        brandVC.arrayPin = arrayPin
        self.navigationController?.pushViewController(brandVC, animated: true)
        
    }
    
    
    
}

