//
//  PhotoCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Leela Krishna Chaitanya Koravi on 3/1/21.
//  Copyright © 2021 Leela Krishna Chaitanya Koravi. All rights reserved.
//

import Foundation
import UIKit

class PhotoCollectionViewCell: UICollectionViewCell{
    
    @IBOutlet weak var photoCollectionViewCellImageView: UIImageView!
    @IBOutlet weak var photoCollectionViewCellActivityIndicator: UIActivityIndicatorView!
    
    
    func setImageView(image: UIImage){
        photoCollectionViewCellImageView.image = image
    }
}
