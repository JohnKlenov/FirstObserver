//
//  ContaktMallViewController.swift
//  FirstObserver
//
//  Created by Evgenyi on 17.09.22.
//

import UIKit

class ContaktMallViewController: UIViewController {
    
    let label: UILabel = {
        let label = UILabel()
        label.text = "Mall"
        label.backgroundColor = .brown
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(label)
        configureLayoutSubview()
        
    }
    
    private func configureLayoutSubview() {
        
        label.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0).isActive = true
        label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
    }
    
}
