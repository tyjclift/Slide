//
//  Menu.swift
//  Slide
//
//  Created by Valeriy Soltan on 8/19/19.
//  Copyright © 2019 Roodac. All rights reserved.
//

import UIKit

class Menu: UIViewController {
    
    // MARK: - PROPERTIES
    
    var table: UITableView!
    var delegate: HomeControllerDelegate?
    private let reuseIdentifier = "MenuOptionCell"
    
    
    // MARK: - INITIALIZATION

    override func viewDidLoad() {
        super.viewDidLoad()
        configureMenu()
    }
    
    // MARK: - CUSTOMIZATION
    
    // swipe to the left to close the menu
    lazy var closeGesture: UISwipeGestureRecognizer = {
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeToClose))
        gesture.direction = .left
        return gesture
    }()
    
    func configureMenu() {
        table = UITableView()
        table.delegate = self
        table.dataSource = self
        
        table.backgroundColor = UX.defaultColor
        table.separatorStyle = .none
        table.rowHeight = 80
        
        
        table.register(MenuCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        view.addSubview(table)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        table.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        table.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        table.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        
        view.addGestureRecognizer(closeGesture)
    }
    
    // MARK: - HANDLERS
    @objc func handleSwipeToClose() {
        delegate?.handleMenuToggle(forMenuOption: nil)
    }
}

extension Menu: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! MenuCell
        
        let menuOption = MenuOption(rawValue: indexPath.row)
        
        // use indexPath to retrieve corresponding image and desc from enum
        cell.optionText.text = menuOption?.description
        cell.iconImage.image = menuOption?.image
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let menuOption = MenuOption(rawValue: indexPath.row)
        delegate?.handleMenuToggle(forMenuOption: menuOption)
    }
}
