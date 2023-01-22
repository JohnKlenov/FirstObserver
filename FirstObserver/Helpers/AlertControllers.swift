//
//  AlertControllers.swift
//  FirstObserver
//
//  Created by Evgenyi on 16.01.23.
//

import Foundation
import UIKit


class Alertss {
    
    enum EditImageAvatar {
            case camera
            case gallery
            case deleteAvatar
        }

        static func editImageAvatar(target:UIViewController, isDeleteAction:Bool, callBack: @escaping (EditImageAvatar) -> Void ) {
            
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
                alert.overrideUserInterfaceStyle = .dark
                
                let camera = UIAlertAction(title: "Camera", style: .default) { action in
                    callBack(.camera)
                }
                
                let gallery = UIAlertAction(title: "Gallery", style: .default) { action in
                    callBack(.gallery)
                }
                
                let cancel = UIAlertAction(title: "Cancel", style: .cancel) { action in
                }
                
                let deleteAvatar = UIAlertAction(title: "Delete Avatar", style: .destructive) { action in
                    callBack(.deleteAvatar)
                }
                
                let titleAlertController = NSAttributedString(string: "Add image to avatar", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17)])
                alert.setValue(titleAlertController, forKey: "attributedTitle")
                
                
                alert.addAction(camera)
                alert.addAction(gallery)
                alert.addAction(cancel)
                
                if isDeleteAction {
                    alert.addAction(deleteAvatar)
                }
                target.present(alert, animated: true, completion: nil)
            }
            
          
        }
    
//    static var shared = Alerts()
//   class ProfileVC {
        
//    enum EditImageAvatar {
//            case camera
//            case gallery
//            case deleteAvatar
//        }
//
//        class func editImageAvatar(target:UIViewController, isDeleteAction:Bool, callBack: @escaping (EditImageAvatar) -> Void ) {
//
//            let alert = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
//            alert.overrideUserInterfaceStyle = .dark
//
//            let camera = UIAlertAction(title: "Camera", style: .default) { action in
//                callBack(.camera)
//            }
//
//            let gallery = UIAlertAction(title: "Gallery", style: .default) { action in
//                callBack(.gallery)
//            }
//
//            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { action in
//            }
//
//            let deleteAvatar = UIAlertAction(title: "Delete Avatar", style: .destructive) { action in
//                callBack(.deleteAvatar)
//            }
//
//            let titleAlertController = NSAttributedString(string: "Add image to avatar", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17)])
//            alert.setValue(titleAlertController, forKey: "attributedTitle")
//
//
//            alert.addAction(camera)
//            alert.addAction(gallery)
//            alert.addAction(cancel)
//
//            if isDeleteAction {
//                alert.addAction(deleteAvatar)
//            }
//            target.present(alert, animated: true, completion: nil)
//        }
        
        
//    }
}
