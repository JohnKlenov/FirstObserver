//
//  ChildCollectionViewController.swift
//  FirstObserver
//
//  Created by Evgenyi on 10.11.22.
//

import UIKit
import FirebaseStorage
import FirebaseStorageUI


class ChildCollectionViewController: UICollectionViewController {
    
    var arrayBrands:[PreviewCategory] = []
    private static let reuseIdentifier = "Cell"
    var heightCnstrCollectionView: NSLayoutConstraint!
    weak var delegate: ChildVCDelegate?
    
    init(arrayBrands: [PreviewCategory]) {
        self.arrayBrands = arrayBrands
        let layout = UICollectionViewFlowLayout()
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        
        self.collectionView!.register(BrandInMallCollectionViewCell.self, forCellWithReuseIdentifier: Self.reuseIdentifier)
        heightCnstrCollectionView = collectionView.heightAnchor.constraint(equalToConstant: 50)
        heightCnstrCollectionView.isActive = true
        collectionView.isScrollEnabled = false
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        heightCnstrCollectionView.constant = collectionViewLayout.collectionViewContentSize.height
    }
    
    func configureChildVC(arrayBrands: [PreviewCategory]) {
        self.arrayBrands = arrayBrands
        collectionView.reloadData()
        
    }

    // MARK: UICollectionViewDataSource

    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return arrayBrands.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.reuseIdentifier, for: indexPath) as! BrandInMallCollectionViewCell
        cell.setupCell(brand: arrayBrands[indexPath.item])
        return cell
    }

   
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = arrayBrands[indexPath.item]
        delegate?.goToBrandVC(pathRef: category.brand ?? "")
    }

   

}

// MARK: UICollectionViewDelegateFlowLayout

extension ChildCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let currentItem = 2
        let paddingWidth = 12*(currentItem+1)
        let availableWidth = collectionView.frame.width - CGFloat(paddingWidth)
        let widthItem = availableWidth/CGFloat(currentItem)
        return CGSize(width: widthItem, height: widthItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
}


class BrandInMallCollectionViewCell: UICollectionViewCell {
    
    var imageViewBrand: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    var storage:Storage!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageViewBrand)
        NSLayoutConstraint.activate([imageViewBrand.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10), imageViewBrand.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10), imageViewBrand.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10), imageViewBrand.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)])
//        contentView.backgroundColor = .gray
//        contentView.layer.cornerRadius = 8
        backgroundView = UIView(frame: .zero)
        backgroundView?.backgroundColor = .lightGray
        backgroundView?.layer.cornerRadius = 8
        storage = Storage.storage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell(brand: PreviewCategory) {
        let refStorage = storage.reference(forURL: brand.refImage)
        imageViewBrand.sd_setImage(with: refStorage, placeholderImage: UIImage(named: "DefaultImage"))
        
    }
    
}
