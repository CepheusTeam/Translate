//
//  Poppable.swift
//  Protocol Oriented Programming View in Swift 3
//
//  Created by sunny on 2017/5/14.
//  Copyright © 2017年 CepheusSun. All rights reserved.
//

import UIKit

protocol Poppable {}

extension Poppable where Self: UIView {
    func pop() {
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: .curveEaseIn,
                       animations: { self.alpha = 1.0 }) { (animationCompleted) in
                        if animationCompleted == true {
                            UIView.animate(withDuration: 0.3,
                                           delay: 2.0,
                                           options: .curveEaseOut,
                                           animations: { self.alpha = 0.0 },
                                           completion: nil)
                        }
        }
    }
}
