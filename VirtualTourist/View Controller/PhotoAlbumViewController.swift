//
//  PhotoAlbumView.swift
//  VirtualTourist
//
//  Created by Leela Krishna Chaitanya Koravi on 3/1/21.
//  Copyright © 2021 Leela Krishna Chaitanya Koravi. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController{
    
    @IBOutlet weak var photoAlbumMapView: MKMapView!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIButton!
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var pin: Pin!

    @IBOutlet weak var photoCollectionViewActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    var backgroundText = "No images found!"
    
    var TAG = "PhotoAlbumViewController"
    

    override func viewDidLoad() {
        let FUNC_TAG = "viewDidLoad"
        super.viewDidLoad()
        print(TAG, FUNC_TAG)
        
        guard let pin = pin else {
            showAlert(title: "Incorrent Pin data. Cannot load album..", message: "Try Again!!")
            fatalError("No pin")
        }
        
        print(TAG, FUNC_TAG, "Pin:" , pin)
        setupCollectionView()
        setupFetchedResultsController()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addAnnotationToMapView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let FUNC_TAG = "viewWillDisappear"
        super.viewWillDisappear(animated)
        print(TAG, FUNC_TAG)
        fetchedResultsController = nil
        photoCollectionView.dataSource = nil
    }
    
    func setupFetchedResultsController() {
        var FUNC_TAG = "setupFetchedResultsController"
        print(TAG, FUNC_TAG, " Fetching photos of pin location: "+pin.name!)
        
        //TEST Fetching all photos and their count...
//        let fetchRequestTemp:NSFetchRequest<Photo> = Photo.fetchRequest()
//        do {
//            let allPhotos = try self.dataController.viewContext.fetch(fetchRequestTemp)
//            //print("Total photos in db: ", allPhotos.count)
//        }
//        catch {
//            print("Error fetching all photos: \(error)")
//        }
        
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        
        if let p = pin {
            let predicate = NSPredicate(format: "photo_to_pin == %@", argumentArray: [p])
            fetchRequest.predicate = predicate
            print(FUNC_TAG, " Pin found. \(p.name) \(p.creationDate) \(p.latitude) \(p.longitude)")
        }
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext:dataController.viewContext,
                                                              sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        print(FUNC_TAG , "Fetched Objects count: ",fetchedResultsController.fetchedObjects?.count ?? 0)

        guard (fetchedResultsController.fetchedObjects?.isEmpty)! else {
            //photoCollectionViewActivityIndicator.isHidden = true
            //photoCollectionViewActivityIndicator.stopAnimating()
            //photoCollectionView.backgroundView = nil
            print(FUNC_TAG, "Images already exist in database. Not re-downloading from Flickr")
            return
        }
        print(FUNC_TAG, "Images not exist in database. Downloading from Flickr...")
        getPhotosFromFilckr(latitude: pin.latitude, longitude: pin.longitude)
    }
    

    func getPhotosFromFilckr(latitude: Double, longitude: Double){
        let FUNC_TAG = "getPhotosFromFilckr"
        
        let pagesCount = Int(self.pin.pages)
        FlickrClient.getPhotos(latitude: latitude, longitude: longitude, pageCount: pagesCount){
            (photos, totalPages, error) in
            if photos.count > 0 {
                if (pagesCount == 0) {
                    self.pin.pages = Int64(totalPages)
                }
                
                print(FUNC_TAG, "Length: ", photos.count)
                //print(FUNC_TAG, photos)
                for photoItem in photos{
                    let photo = Photo(context: self.dataController.viewContext)
                    photo.photoUrl = URL(string: photoItem.url_m)
                    photo.photoData = nil
                    photo.photoId = UUID().uuidString
                    photo.creationDate = Date()
                    photo.photo_to_pin = self.pin
                    do {
                        try? self.dataController.viewContext.save()
                    } catch {
                        print("Problem saving photo!")
                    }
                }
            }else{
                print(error)
            }
        }
        backgroundText = "No images found!"
        updateUI(newCollectionButtonStatus: true)
    }
    
    @IBAction func clearDBAndLoadNewImages(_ sender: Any) {
        let FUNC_TAG = "clearDBAndLoadNewImages"
        print(FUNC_TAG)
        
        backgroundText = "Downloading images..Please wait!"
        updateUI(newCollectionButtonStatus: false)
        guard let images = fetchedResultsController.fetchedObjects else { return }
        if(images.count>0){
        for image in images {
            //print(FUNC_TAG, " Deleting image: ", image)
            dataController.viewContext.delete(image)
            do {
                try dataController.viewContext.save()
            } catch {
                print("Problem deleting the images")
            }
        }
        }
        print("Cleared all images from db")
        setupFetchedResultsController()
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func showAlert(title: String, message: String){
        print(title, " ", message)
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    func updateUI( newCollectionButtonStatus: Bool){
        newCollectionButton.isEnabled = newCollectionButtonStatus
    }
    
    func updateBackgroundView(enable: Bool, text: String){
        if(enable){
            let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: photoCollectionView.frame.width, height: photoCollectionView.frame.height))
            label.numberOfLines = 2
            label.textAlignment = .center
            label.text = text
            photoCollectionView.backgroundView = label
        }else{
            photoCollectionView.backgroundView = nil
        }
    }
    

    
}
