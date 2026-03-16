//
//  UINavigationController+Ext.swift
//  News
//
//  Created by BTS.id on 02/03/26.
//

import UIKit

extension UINavigationController {
    func navigationBarApperance(color: UIColor? = nil) {
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = color
        appearance.shadowColor = .clear
        
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.isTranslucent = true
        
        self.navigationBar.standardAppearance = appearance
        self.navigationBar.compactAppearance = appearance
        self.navigationBar.scrollEdgeAppearance = appearance
    }
    
    func hideNavigationBar() {
        self.setNavigationBarHidden(true, animated: false)
    }
}

extension UINavigationController {
    func getViewController<T: UIViewController>(ofClass: T.Type) -> UIViewController? {
        return self.viewControllers.first(where: { $0 is T })
    }
    
    func containsViewController(ofKind kind: AnyClass) -> Bool {
        return self.viewControllers.contains(where: { $0.isKind(of: kind) })
    }
    
    func popToViewController<T: UIViewController>(of type: T.Type, animated: Bool) {
        guard let viewController = getViewController(ofClass: type) else { return }
        
        self.popToViewController(viewController, animated: animated)
    }
}
