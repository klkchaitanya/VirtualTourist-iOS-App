//
//  PhotoAlbumViewController+MKMapView.swift
//  VirtualTourist
//
//  Created by Leela Krishna Chaitanya Koravi on 3/3/21.
//  Copyright © 2021 Leela Krishna Chaitanya Koravi. All rights reserved.
//

import Foundation
import MapKit

extension PhotoAlbumViewController: MKMapViewDelegate{
 
    func addAnnotationToMapView() {
        photoAlbumMapView.delegate = self
        let span = MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
        let coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        photoAlbumMapView.setRegion(region, animated: true)
        photoAlbumMapView.addAnnotation(AnnotationPin(pin: pin))
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
    
    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        let reuseId = "pin"
//        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
//        
//        
//        if pinView == nil {
//            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
//            pinView!.canShowCallout = false
//            pinView!.pinTintColor = .red
//            
//        } else {
//            pinView!.annotation = annotation
//        }
//        
//        pinView?.isSelected = true
//        pinView?.isUserInteractionEnabled = false
//        return pinView
//    }
    

    
}
