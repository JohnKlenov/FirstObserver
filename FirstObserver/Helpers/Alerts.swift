//
//  Alerts.swift
//  FirstObserver
//
//  Created by Evgenyi on 15.12.22.
//

import Foundation
import UIKit



extension UIViewController {
    
    func sendPasswordReset(title:String, placeholder: String, completionHandler: @escaping (String) -> Void) {
        
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        let alertOK = UIAlertAction(title: "OK", style: .default) { (action) in
            
            let textField = alertController.textFields?.first
            guard let text = textField?.text else {return}
            completionHandler(text)
        }
        
        let alertCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            ///
        }
        
        alertController.addAction(alertOK)
        alertController.addAction(alertCancel)
        alertController.addTextField { (textField) in
            textField.placeholder = placeholder
        }
        
        present(alertController, animated: true, completion: nil)
    }
}
