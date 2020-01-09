//
//  UIViewController+Extension.swift
//  CoreDataPerformance
//
//  Created by Gagan Vishal on 2019/12/11.
//  Copyright © 2019 Gagan Vishal. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController {
    private struct AssociatedKeys {
        static var floatingButton: UIButton?
    }

    var floatingButton: UIButton? {
        get {
            guard let value = objc_getAssociatedObject(self, &AssociatedKeys.floatingButton) as? UIButton else {return nil}
            return value
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.floatingButton, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func addFloatingButton() {
        // Customize your own floating button UI
        let button = UIButton(type: .custom)
        button.titleLabel?.textColor = .white
        button.backgroundColor = .blue
        let buttonSize = CGSize(width: 60, height: 60)
        let rect = self.view.bounds.insetBy(dx: 4 + buttonSize.width / 2, dy: 4 + buttonSize.height / 2)
        var heightToSubstract: CGFloat = 50
        if let tabBarController = self.tabBarController {
            heightToSubstract = tabBarController.tabBar.frame.size.height
        }
        button.frame = CGRect(origin: CGPoint(x: rect.maxX - 15, y: rect.maxY - heightToSubstract), size: CGSize(width: 60, height: 60))
        button.layer.cornerRadius = 30
        button.layer.borderWidth = 2.0
        button.layer.borderColor = UIColor.red.cgColor
        button.autoresizingMask = []

        self.view.addSubview(button)
        floatingButton = button
        let panner = UIPanGestureRecognizer(target: self, action: #selector(panDidFire(panner:)))
        floatingButton?.addGestureRecognizer(panner)
        snapButtonToSocket()
    }

    @objc fileprivate func panDidFire(panner: UIPanGestureRecognizer) {
        guard let floatingButton = floatingButton else {return}
        let offset = panner.translation(in: view)
        panner.setTranslation(CGPoint.zero, in: view)
        var center = floatingButton.center
        center.x += offset.x
        center.y += offset.y
        floatingButton.center = center

        if panner.state == .ended || panner.state == .cancelled {
            UIView.animate(withDuration: 0.3) {
                self.snapButtonToSocket()
            }
        }
    }

    fileprivate func snapButtonToSocket() {
        guard let floatingButton = floatingButton else {return}
        var bestSocket = CGPoint.zero
        var distanceToBestSocket = CGFloat.infinity
        let center = floatingButton.center
        for socket in sockets {
            let distance = hypot(center.x - socket.x, center.y - socket.y)
            if distance < distanceToBestSocket {
                distanceToBestSocket = distance
                bestSocket = socket
            }
        }
        floatingButton.center = bestSocket
    }

    fileprivate var sockets: [CGPoint] {
        let buttonSize = floatingButton?.bounds.size ?? CGSize(width: 0, height: 0)
        let rect = self.view.bounds.insetBy(dx: 4 + buttonSize.width / 2, dy: 4 + buttonSize.height / 2)
        var heightToSubstract: CGFloat = 50
          if let tabBarController = self.tabBarController {
            //add tabbar height
            heightToSubstract = tabBarController.tabBar.frame.size.height
          }
        let sockets: [CGPoint] = [
            CGPoint(x: rect.minX + 15, y: rect.minY + 30),
            CGPoint(x: rect.minX + 15, y: rect.maxY - heightToSubstract),
            CGPoint(x: rect.maxX - 15, y: rect.minY + 30),
            CGPoint(x: rect.maxX - 15, y: rect.maxY - heightToSubstract)
        ]
        return sockets
    }
    // Custom socket position to hold Y position and snap to horizontal edges.
    // You can snap to any coordinate on screen by setting custom socket positions.
    fileprivate var horizontalSockets: [CGPoint] {
        guard let floatingButton = floatingButton else {return []}
        let buttonSize = floatingButton.bounds.size
        let rect = self.view.bounds.insetBy(dx: 4 + buttonSize.width / 2, dy: 4 + buttonSize.height / 2)
        let y = min(rect.maxY - 50, max(rect.minY + 30, floatingButton.frame.minY + buttonSize.height / 2))
        let sockets: [CGPoint] = [
            CGPoint(x: rect.minX + 15, y: y),
            CGPoint(x: rect.maxX - 15, y: y)
        ]
        return sockets
    }
}
