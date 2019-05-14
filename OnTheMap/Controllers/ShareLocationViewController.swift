//
//  ShareLocationViewController.swift
//  OnTheMap
//
//  Created by Waiel Eid on 11/5/19.
//  Copyright © 2019 Waiel Eid. All rights reserved.
//

import Foundation

import CoreLocation
import MapKit


class ShareLocationViewController: UIViewController {
     
    // MARK: - variables defined
    var locationCoordinate: CLLocationCoordinate2D!
    var locationName: String!
    var mediaURL: String!
   
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        // set the annotation on the map
        let annotation = MKPointAnnotation()
        annotation.coordinate = self.locationCoordinate
        mapView.addAnnotation(annotation)
        // set the view
        let viewRegion = MKCoordinateRegion(center: locationCoordinate!, latitudinalMeters: 200, longitudinalMeters: 200)
        mapView.setRegion(viewRegion, animated: false)
        
    }
    // MARK: - IBActios
    //submit button
    @IBAction func SubmitLocation(_ sender: Any) {
        LoadingOverlay.shared.showOverlay(view: UIApplication.shared.keyWindow!)
        // Send new locaiton through API
        UdacityAPI.postStudentLocation(link: mediaURL ?? "", locations: self.locationCoordinate, locationName: self.locationName) { (error) in
            if let error = error{
                print(error.localizedDescription)
                LoadingOverlay.shared.hideOverlayView()
                self.showAlert(title: "Error", message: error.localizedDescription)
                return
            }
            //save the location sent in the user defaults
            UserDefaults.standard.set(self.locationName, forKey: "studentLocation")
            DispatchQueue.main.async {
                LoadingOverlay.shared.hideOverlayView()
                self.parent!.dismiss(animated: true, completion: nil)
            }
        }
    }
    
}
// MARK: - Map Delegate function
extension ShareLocationViewController: MKMapViewDelegate{
    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pid") as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation
                , reuseIdentifier: "pid")
            pinView!.canShowCallout = true
            pinView!.tintColor = .blue
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }else{
            pinView!.annotation = annotation
        }
        return pinView
    }
}
