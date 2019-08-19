//
//  MenuOption.swift
//  Slide
//
//  Created by Valeriy Soltan on 8/19/19.
//  Copyright © 2019 Roodac. All rights reserved.
//

import UIKit

enum MenuOption: Int, CustomStringConvertible {
    case Profile
    case Accounts
    case Logout
    
    var description : String {
        switch self {
            case .Profile: return "Profile"
            case .Accounts: return "Accounts"
            case .Logout: return "Logout"
        }
    }
    
    var image: UIImage {
        switch self {
        case .Profile:
            return #imageLiteral(resourceName: "Checkbox")
        case .Accounts:
            return #imageLiteral(resourceName: "addNew")
        case .Logout:
            return #imageLiteral(resourceName: "UnCheckbox")
        }
    }
}
