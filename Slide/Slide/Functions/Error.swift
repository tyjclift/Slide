//
//  Error.swift
//  Slide
//
//  Created by Valeriy Soltan on 6/18/19.
//  Copyright © 2019 Roodac. All rights reserved.
//

import Foundation
import UIKit

class SlidErr : UIAlertController {
    
    // creates a UIAlertController with prompts for the user
    static func textFieldError(errorTitle: String, errorMessage: String) -> UIAlertController {
        // customization
        let error = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .actionSheet)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        error.addAction(defaultAction)
        return error
    }
}

// overrides the view heirarchy to present an alert
public extension UIAlertController {
    func show() {
        let win = UIWindow(frame: UIScreen.main.bounds)
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        win.rootViewController = vc
        win.windowLevel = UIWindow.Level.alert + 1
        win.makeKeyAndVisible()
        vc.present(self, animated: true, completion: nil)
    }
}
