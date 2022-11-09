//
//  MallViewController.swift
//  FirstObserver
//
//  Created by Evgenyi on 7.11.22.
//

import UIKit

class MallViewController: UIViewController {

    
    
    // MARK: - outlet property -
    @IBOutlet weak var mallCollectionView: UICollectionView!
    
    // MARK: - constraints from outlet -
    
    @IBOutlet weak var heightCollectionView: NSLayoutConstraint!
    
    
    // MARK: - another property -
    
    var testModel:[UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "GreenCity"
        testModel = (0..<4).map{UIImage(named: String($0))!}
        mallCollectionView.delegate = self
        mallCollectionView.dataSource = self

        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupConstraint()
    }
    
    
    // MARK: - calculate constraint -
    
    
    private func setupConstraint() {
        let guide = self.view.safeAreaLayoutGuide
        let heightSafeArea = guide.layoutFrame.height
        print("heightSafeArea - \(heightSafeArea)")
        heightCollectionView.constant = heightSafeArea*0.35
    }
    
}

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
