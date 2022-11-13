//
//  MallViewController.swift
//  FirstObserver
//
//  Created by Evgenyi on 7.11.22.
//

import UIKit
import SafariServices
import MapKit

class MallViewController: UIViewController {

    
    
    // MARK:  outlet property
    @IBOutlet weak var mallCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var brandStackView: UIStackView!
    @IBOutlet weak var mapView: CustomMapView!
    
    // MARK: constraints from outlet
    @IBOutlet weak var heightCollectionView: NSLayoutConstraint!
    @IBOutlet weak var topCnstrPageControl: NSLayoutConstraint!
    
    // MARK: another property
    var testModel:[UIImage] = []
    var modelChild:[UIImage] = []
    
    
    // MARK: MapView property
    var arrayPin:[PlacesTest] = []
    var isSelected:Bool = false
    var tapGestureRecognizer = UITapGestureRecognizer()
    
    
    
    // MARK: -Life cycle methods -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.arrayPin = arrayPin
        mapView.delegateMallVC = self
        
        self.title = "GreenCity"
        testModel = (0..<4).map{UIImage(named: String($0))!}
        (0...4).forEach({ _ in
            self.modelChild.append(UIImage(named: "Icon")!)
        })
        
        mallCollectionView.delegate = self
        mallCollectionView.dataSource = self

        pageControl.numberOfPages = testModel.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .systemBrown
        pageControl.currentPageIndicatorTintColor = .black
        
        let childCVC = ChildCollectionViewController(arrayImage: modelChild)
        childCVC.view.translatesAutoresizingMaskIntoConstraints = false
        brandStackView.addArrangedSubview(childCVC.view)
        addChild(childCVC)
        
        configureTapGestureRecognizer()

    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupConstraint()
    }
    
    
    // MARK: - @IBAction func -

    @IBAction func didTapFloorPlan(_ sender: Any) {
    
        self.showWebView("https://dana-mall.com/plan-trcz.html")
        
    }
    
    @IBAction func didTapWebsite(_ sender: Any) {
        
        self.showWebView("https://dana-mall.com/")
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
        return testModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageMallCollectionViewCell", for: indexPath) as! ImageMallCollectionViewCell
        cell.configure(mallImage: testModel[indexPath.item])
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


