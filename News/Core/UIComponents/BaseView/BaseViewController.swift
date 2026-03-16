//
//  BaseViewController.swift
//  News
//
//  Created by BTS.id on 02/03/26.
//

import UIKit
import Alamofire
import SwiftMessages

class BaseViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Variables
    var topConstraint: NSLayoutConstraint?
    var firstViewisCalled: Bool = false
    
    // MARK: - LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navigationController {
            navigationController.interactivePopGestureRecognizer?.delegate = self
            navigationController.interactivePopGestureRecognizer?.isEnabled = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !firstViewisCalled {
            firstViewDidLayoutSubviews()
        }
    }
    
    func firstViewDidLayoutSubviews() {
        firstViewisCalled = true
    }
    
    func showToast(with message: String?) {
        if message == ResponseError.cancelled.localizedDescription {
            return
        }
        
        if message == nil || (message?.isEmpty ?? false) { return }
        
        let view = MessageView.viewFromNib(layout: .cardView)
        
        // Only display body, without title or button
        view.configureContent(title: "", body: message!)
        view.titleLabel?.isHidden = true
        view.button?.isHidden = true
        
        // Setup font style
        view.bodyLabel?.textColor = .white
        
        // Adjust background for error
        view.configureTheme(backgroundColor: .systemRed, foregroundColor: .white)
        
        var config = SwiftMessages.defaultConfig
        config.presentationStyle = .top // Set position toast
        config.duration = .automatic
        
        SwiftMessages.show(config: config, view: view)
    }
}

extension BaseViewController {
    func keyboardObservers() {
        if topConstraint != nil {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(keyboardWillShow(notification:)),
                name: UIResponder.keyboardWillShowNotification,
                object: nil
            )
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(keyboardWillHide(notification:)),
                name: UIResponder.keyboardWillHideNotification,
                object: nil
            )
        }
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        if notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] is CGRect {
            UIView.animate(withDuration: 0.2) {
                if self.topConstraint!.constant >= 0 {
                    self.topConstraint!.constant
                    -= 150
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.2) {
            self.topConstraint!.constant = 0
            self.view.layoutIfNeeded()
        }
    }
}
