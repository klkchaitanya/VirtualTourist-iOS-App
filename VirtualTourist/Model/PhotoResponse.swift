//
//  PhotoResponse.swift
//  VirtualTourist
//
//  Created by Leela Krishna Chaitanya Koravi on 2/28/21.
//  Copyright © 2021 Leela Krishna Chaitanya Koravi. All rights reserved.
//

import Foundation
import UIKit

struct PhotoStruct: Codable{
    //var photoImage: UIImage?
    let id, owner, secret, server: String
    let farm: Int
    let title: String
    let ispublic, isfriend, isfamily: Int
    let url_m: String
}


struct PhotoResponse: Codable {
    let photos: Photos
    let stat: String
}

struct Photos: Codable {
    let page, pages, perpage: Int
    let total: String
    let photo: [PhotoStruct]
}
