//
//  MediaContainer.swift
//  Slide
//
//  Created by Valeriy Soltan on 6/24/19.
//  Copyright © 2019 Roodac. All rights reserved.
//

import Foundation

// container class that stores the media to be turned into a QR code
class EncodedMedia{
    
    // of type codable to allow for easy de/serialization
    struct Media : Codable {
        var name, phoneNumber, email : String
        
        init(name: String?, phone: String?, email: String?) {
            self.name = name!
            self.phoneNumber = phone!
            self.email = email!
        }
    }
    
    static func structToJSON(preparedData: Media?) -> String? {
        // make sure that data is being passed to the function
        if (preparedData == nil) {
            return nil
        }
    
        let jsonData = try! JSONEncoder().encode(preparedData)
        let formatString = String(data: jsonData, encoding: .utf8)!
        
        return formatString
    }
    
    // decoder function to be used by the QR reader
    static func JSONtoStruct(source: String) -> Media? {
        let jsonData = source.data(using: .utf8)!
        let userMedia : Media = try! JSONDecoder().decode(Media.self, from: jsonData)
        return userMedia
    }
}
    
    

