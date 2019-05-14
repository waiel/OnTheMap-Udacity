//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Waiel Eid on 10/5/19.
//  Copyright © 2019 Waiel Eid. All rights reserved.
//

import Foundation
import MapKit


class  MapViewController: UIViewController  {
    
    // MARK: - Variables defined
    var studentsLocations : [StudentLocation]! {
        return Globals.shared.studentsLocations
    }
    @IBOutlet weak var mapView: MKMapView!
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       // Map delegation
        mapView.delegate = self
        // check if studentlocaiton is loaded
        if (studentsLocations == nil){
            reloadStudentsLocations(self)
        }else{
            DispatchQueue.main.async {
               self.updateAnnotation()
            }
        }
    }

    // MARK: IBActions
    //logoutbutton
    @IBAction func logout(_ sender: Any) {
        UdacityAPI.postLogout { (error) in
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
                return
            }
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    // reload button pressed
    @IBAction func reload(_ sender: Any) {
        self.reloadStudentsLocations(sender)
    }

    // Add locaiton button
    @IBAction func addPinClicked(_ sender: Any) {
        // check if user posted before
        if UserDefaults.standard.value(forKey: "studentLocation") != nil{
            let alert = UIAlertController(title: "Notice", message: "You Already Posted a location. Would you like to overwide it?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Overwrite", style: .default, handler: { (action) in
                self.performSegue(withIdentifier: "AddNewPin", sender: self)
            }))
            alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else{
            self.performSegue(withIdentifier: "AddNewPin", sender: self)
        }
    }
    
    
    // update map with annotations
    func updateAnnotation(){
        var annotations = [MKPointAnnotation]()
        // check if student location was loded
        if(studentsLocations != nil){
            for studentLocation in studentsLocations {
                let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(studentLocation.latitude ?? 0), longitude: CLLocationDegrees(studentLocation.longitude ?? 0))
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = (studentLocation.firstName)! + " " + (studentLocation.lastName)!
                annotation.subtitle = studentLocation.mediaURL ?? ""
                // add annotation if not added before
                if !mapView.annotations.contains(where: {$0.title == annotation.title}){
                    annotations.append(annotation)
                }
            }
        }
        else{
            reload(self)
        }
        // add the anotations to the map
        mapView.addAnnotations(annotations)
    }
    
    // reload the student locaitons collection
    func reloadStudentsLocations(_ sender: Any) {
            // get the student locations from API
            UdacityAPI.getStudentsLocaiton { (studentsLocations, error) in
                // if error recived
                if let error = error {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                    return
                }
                
            }
        DispatchQueue.main.async {
            self.updateAnnotation()
        }
        
    }
}

    // MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
   
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    
     func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            pinView!.canShowCallout = true
            pinView!.tintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }else{
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
     func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView{
            let app = UIApplication.shared
            guard let toOpen = view.annotation?.subtitle!,
                let url = URL(string: toOpen) else {
                    return
            }
            app.open(url, options: [:], completionHandler: nil)
            
        }
    }
}
