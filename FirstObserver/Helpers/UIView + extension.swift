//
//  UIView + extension.swift
//  FirstObserver
//
//  Created by Evgenyi on 6.01.23.
//

import Foundation
import UIKit


extension UIView {
    
    // System button отрабатывают миганием при нажатии а custom button нужно руками это делать.
    func makeSystem(_ button:UIButton) {
        
        button.addTarget(self, action: #selector(handleIn), for: [.touchDown, .touchDragInside])
        button.addTarget(self, action: #selector(handleOut), for: [.touchDragOutside, .touchUpInside, .touchUpOutside, .touchDragExit, .touchCancel])
    }
    
    @objc func handleIn() {
        UIView.animate(withDuration: 0.15) {
            self.alpha = 0.55
        }
    }
    
    @objc func handleOut() {
        UIView.animate(withDuration: 0.15) {
            self.alpha = 1
        }
    }
}
