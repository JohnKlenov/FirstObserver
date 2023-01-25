//
//  Helpers.swift
//  FirstObserver
//
//  Created by Evgenyi on 30.08.22.
//

import Foundation
import UIKit



extension String {
    
    func widthOfString(usingFont font:UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = (self as NSString).size(withAttributes: fontAttributes)
        return ceil(size.width)
    }
}

extension UIImage {
  func thumbnailOfSize(_ newSize: CGSize) -> UIImage? {
    let renderer = UIGraphicsImageRenderer(size: newSize)
    let thumbnail = renderer.image { _ in
      draw(in: CGRect.init(origin: CGPoint.zero, size: newSize))
    }
    return thumbnail
  }
}

extension UIStoryboard {
    static func vcById(_ id:String) -> UIViewController {
      return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: id)
    }
}

struct Screen {

    
 static var width: CGFloat {
  return UIScreen.main.bounds.width
 }

 static var height: CGFloat {
  return UIScreen.main.bounds.height
 }

 static var statusBarHeight: CGFloat {
  let viewController = UIApplication.shared.windows.first!.rootViewController
  return viewController!.view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
 }

}





    
