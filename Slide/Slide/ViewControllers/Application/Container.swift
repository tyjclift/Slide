//
//  Container.swift
//  Slide
//
//  Created by Valeriy Soltan on 8/19/19.
//  Copyright © 2019 Roodac. All rights reserved.
//

import UIKit

class Container: UIViewController {
    
    // MARK: - PROPERTIES
    var viewToAnimate: UIViewController!
    var sideMenu: Menu!
    var isHidden = true
    
    // MARK: - INITIALIZATIONS
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHomeController()
    }
    
    // MARK: - CONFIGURATIONS
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func configureHomeController() {
        let home = Home()
        home.delegate = self
        
        // embed the home view in a navigation controller
        viewToAnimate = UINavigationController(rootViewController: home)
        
        view.addSubview(viewToAnimate.view)
        addChild(viewToAnimate)
        viewToAnimate.didMove(toParent: self)
    }
    
    func configureMenuController() {
        // only creates the menu on startup
        if (sideMenu == nil) {
            sideMenu = Menu()
            sideMenu.delegate = self
            view.insertSubview(sideMenu.view, at: 0)
            addChild(sideMenu)
            sideMenu.didMove(toParent: self)
        }
    }
    
    func showMenu(hidden: Bool) {
        if !(hidden) {
            // show menu
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.viewToAnimate.view.frame.origin.x = self.viewToAnimate.view.frame.width - 80
            }, completion: nil)
        } else {
            // hide menu
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.viewToAnimate.view.frame.origin.x = 0
            }, completion: nil)
        }
    }
    
    func didSelectMenuOtion(withIdentifier identifier: MenuOption) {
        switch identifier {
        case .Profile:
            print("ello")
        case .Accounts:
            print("yoit")
        case .Logout:
            print("logged out!")
        }
    }
}

extension Container: HomeControllerDelegate {
    func handleMenuToggle(forMenuOption menuOption: MenuOption?) {
        
        if (menuOption != nil) {
            didSelectMenuOtion(withIdentifier: menuOption!)
        } else {
            if isHidden {
                configureMenuController()
            }
            
            isHidden.toggle()
            showMenu(hidden: isHidden)
        }
    }
}
