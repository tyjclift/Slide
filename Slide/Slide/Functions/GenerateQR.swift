//
//  QR.swift
//  Slide
//
//  Created by Valeriy Soltan on 6/13/19.
//  Copyright © 2019 Roodac. All rights reserved.
//

import UIKit
import Foundation

class GenerateQR {
    static func generateQRCode(from string: String?) -> UIImage? {
        
        // retrieves data from string and encodes it into ascii
        guard let data = string!.data(using: String.Encoding.ascii) else {
            // makes sure that some data is being passed to the generator
            print("no data passed to filter")
            return nil
        }
        
        // creates a filter and applies it to the data
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            
            // scaling transformation to fit any screen
            let transform = CGAffineTransform(scaleX: 100, y: 100)
            
            // image is rendered after transformation is applied
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        // error occured
        return nil
    }
}
