//
//  ViewController.swift
//  Slide
//
//  Created by Sam Lee on 6/5/19.
//  Copyright © 2019 Roodac. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var linkField: UITextField!
    @IBOutlet weak var QRView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // creates a qr code based on the passed String to the linkField
    @IBAction func generate(_ sender: Any) {
    let img = GenerateQR.generateQRCode(from: linkField.text!)
        QRView.image = img
    }
}

