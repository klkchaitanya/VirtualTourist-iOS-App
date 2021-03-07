//
//  PhotoAlbumViewController+NSFetchResultsController.swift
//  VirtualTourist
//
//  Created by Leela Krishna Chaitanya Koravi on 3/3/21.
//  Copyright © 2021 Leela Krishna Chaitanya Koravi. All rights reserved.
//

import Foundation
import CoreData

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate{
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        let FUNC_TAG = "controller didChange"
        
        switch type{
            case .insert:
                self.photoCollectionView.insertItems(at: [newIndexPath!])
                print(FUNC_TAG, "inserting items")
            case .delete:
                self.photoCollectionView.deleteItems(at: [indexPath!])
                print(FUNC_TAG, "deleting items")
            case .update:
                self.photoCollectionView.reloadItems(at: [indexPath!])
                print(FUNC_TAG, "reloading items")
        case .move:
            break
        @unknown default:
            break
        }
    }
}
