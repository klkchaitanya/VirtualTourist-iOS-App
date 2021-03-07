//
//  PhotoAlbumViewController+CollectionView.swift
//  VirtualTourist
//
//  Created by Leela Krishna Chaitanya Koravi on 3/2/21.
//  Copyright © 2021 Leela Krishna Chaitanya Koravi. All rights reserved.
//

import Foundation
import UIKit

extension PhotoAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    
    func setupCollectionView(){
        var FUNC_TAG = "loadPhotosInCollectionView"
        print(TAG, FUNC_TAG)
        
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        photoCollectionView.allowsMultipleSelection = true
        
        if let flowLayout = photoCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let space:CGFloat = 3.0
            let dimension = (view.frame.size.width - (2 * space)) / 3.0
            flowLayout.minimumInteritemSpacing = space
            flowLayout.minimumLineSpacing = space
            flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = fetchedResultsController.sections?[section].numberOfObjects ?? 0
        if(count == 0){
            let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: collectionView.frame.width, height: collectionView.frame.height))
            label.numberOfLines = 1
            label.textAlignment = .center
            label.text = "No Images found!"
            collectionView.backgroundView = label
        }else{
            collectionView.backgroundView = nil
        }
        
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let FUNC_TAG = "collectionView - cellForItemAt"
        //print(FUNC_TAG)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath as IndexPath) as! PhotoCollectionViewCell
        
        guard !(self.fetchedResultsController.fetchedObjects?.isEmpty)! else {
            print("images are already present.")
            return cell
        }
        
        // fetch core data
        let photo = self.fetchedResultsController.object(at: indexPath)
        if photo.photoData == nil {
            //print(FUNC_TAG, "photo.photoData is nil")
            //newCollectionButton.isEnabled = false
            DispatchQueue.global(qos: .background).async {
                if let imageData = try? Data(contentsOf: photo.photoUrl!) {
                    DispatchQueue.main.async {
                        photo.photoData = imageData
                        do {
                            try self.dataController.viewContext.save()
                        }
                        catch {
                            print("error in saving image data")
                        }
                        
                        let image = UIImage(data: imageData)!
                        cell.setImageView(image: image)
                        cell.photoCollectionViewCellActivityIndicator.startAnimating()
                        cell.photoCollectionViewCellActivityIndicator.isHidden = false
                        
                    }
                }
            }
        } else {
            //print(FUNC_TAG, "photo.photoData is NOT nil")
            if let imageData = photo.photoData {
                print(FUNC_TAG, indexPath, photo.photo_to_pin!.name!)
                let image = UIImage(data: imageData)!
                cell.setImageView(image: image)
                cell.photoCollectionViewCellActivityIndicator.stopAnimating()
                cell.photoCollectionViewCellActivityIndicator.isHidden = true
            }
        }
        //newCollectionButton.isEnabled = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Did select item at: ", indexPath)
        let selectedImageToRemove = fetchedResultsController.object(at: indexPath)
        let imageId = selectedImageToRemove.photoId
        if let selectedImages = fetchedResultsController.fetchedObjects {
            for image in selectedImages {
                if image.photoId == imageId {
                    print("Found image-id match to delete")
                    dataController.viewContext.delete(image)
                    do {
                        try? dataController.viewContext.save()
                    } catch {
                        print("Unable to remove the photo")
                    }
                }
            }
        }
    }
    
    

}
