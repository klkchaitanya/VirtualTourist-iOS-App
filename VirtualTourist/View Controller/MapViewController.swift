//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Leela Krishna Chaitanya Koravi on 2/27/21.
//  Copyright © 2021 Leela Krishna Chaitanya Koravi. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate{
    
    var TAG = "MapViewController"
    @IBOutlet weak var mapView: MKMapView!
    var dataController: DataController!
    var pinFetchedResultsController: NSFetchedResultsController<Pin>!

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupPinFetchedResultsController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //resetMapView()
        resetMapView2()
    }
    
    func setupPinFetchedResultsController(){
        
        let request: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        pinFetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                                 managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        pinFetchedResultsController.delegate = self
        do {
            try pinFetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    
    func resetMapView() {
        var FUNC_TAG = "resetMapView"
        print(TAG, FUNC_TAG)
        
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        // fetch all pins
        let request: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        dataController.viewContext.perform {
            do {
            let pins = try self.dataController.viewContext.fetch(request)
            for p in pins{
                print(p.name, " ", p.creationDate, " ", p.latitude, " ", p.latitude)
                self.mapView.addAnnotation(AnnotationPin(pin: p))
                }
            //self.mapView.addAnnotations(pins.map { pin in AnnotationPin(pin: pin) })
            }
            catch {
                print("Error fetching Pins: \(error)")
            }
        }
        
        //TEST Fetching all photos and their count...
        let fetchRequestTemp:NSFetchRequest<Photo> = Photo.fetchRequest()
        do {
            let allPhotos = try self.dataController.viewContext.fetch(fetchRequestTemp)
            print(TAG, FUNC_TAG, " Total photos in db: ", allPhotos.count)
        }
        catch {
            print(TAG, FUNC_TAG, " Error fetching all photos: \(error)")
        }
    }
    
    func resetMapView2(){
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        // fetch all pins
        let request: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        do {
            try pinFetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        
        let pins = pinFetchedResultsController.fetchedObjects!
        for p in pins{
            print(p.name, " ", p.creationDate, " ", p.latitude, " ", p.latitude)
            self.mapView.addAnnotation(AnnotationPin(pin: p))
        }
        
    }
    
    //on Long press
    @IBAction func longPressOnMap(_ sender: UILongPressGestureRecognizer) {
        let FUNC_TAG = "longPressOnMap"
        if(sender.state == .began){
            print("long press on map began")
        }else if(sender.state == .ended){
            let locationCoordinate = mapView.convert(sender.location(in: mapView), toCoordinateFrom: mapView)
            print("long press ended. locationCoordinate: ", locationCoordinate)
            saveLocationPin(locationCoordinate: locationCoordinate)
        }
    }
    

    func saveLocationPin(locationCoordinate:CLLocationCoordinate2D){
        let location = CLLocation(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude)
        //let annotation = MKPointAnnotation()
        CLGeocoder().reverseGeocodeLocation(location) {
            (placemarks, error) in
            guard let placemark = placemarks?.first else { return }
            let locationPin = Pin(context: self.dataController.viewContext)
            locationPin.name = placemark.name
            locationPin.creationDate = Date()
            locationPin.latitude = locationCoordinate.latitude
            locationPin.longitude = locationCoordinate.longitude
            locationPin.pages = 0
            
            try? self.dataController.viewContext.save()
            let annotationPin = AnnotationPin(pin: locationPin)
            self.mapView.addAnnotation(annotationPin)
            print("Added pin to map")
            
        }
    }
    
    //On Tap
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("didSelect")
        mapView.deselectAnnotation(view.annotation, animated: false)
        guard let _ = view.annotation else {
            return
        }
        if let annotation = view.annotation as? MKPointAnnotation {
            do {
                //                let predicate = NSPredicate(format: "longitude = %@ AND latitude = %@", argumentArray: [annotation.coordinate.longitude, annotation.coordinate.latitude])
                
                let latitudePredicate = NSPredicate(format: "latitude == %lf", annotation.coordinate.latitude)
                let longitudePredicate = NSPredicate(format: "longitude == %lf", annotation.coordinate.longitude)
                let namePredicate = NSPredicate(format: "name == %@", annotation.title!)
                
                let predicates = NSCompoundPredicate(andPredicateWithSubpredicates:
                    [latitudePredicate, longitudePredicate, namePredicate])
                let pinData = try dataController.fetchLocation(predicates)!
                print("Pin Query result: ", pinData.name)
                let annotationPin = AnnotationPin(pin: pinData)
                
                self.performSegue(withIdentifier: "MapToAlbumSegue", sender: annotationPin)
            } catch {
                print("There was an error fetching the location pin and calling Album view!!")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let FUNC_TAG = "prepare for segue"
        
        guard let photoAlbumViewController = segue.destination as? PhotoAlbumViewController else{return}
        let pinAnnotation: AnnotationPin = sender as! AnnotationPin
        photoAlbumViewController.pin = pinAnnotation.pin
        photoAlbumViewController.title = pinAnnotation.pin.name
        print(TAG, FUNC_TAG, "Segue pin: ", pinAnnotation.pin.name)
        photoAlbumViewController.dataController = dataController

    }

    class AnnotationPin: MKPointAnnotation {
        var pin: Pin
        init(pin: Pin){
            self.pin = pin
            super.init()
            self.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
            self.title = pin.name
        }
    }
    
}
