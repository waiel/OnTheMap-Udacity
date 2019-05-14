//
//  newLocationViewController.swift
//  OnTheMap
//
//  Created by Waiel Eid on 11/5/19.
//  Copyright © 2019 Waiel Eid. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class newLocationViewController: UIViewController {
    // MARK: - defined vairables
    var locationCoordinate : CLLocationCoordinate2D!
    var locationName: String!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var FindButton: UIButton!
    @IBOutlet weak var mediaURLTextField: UITextField!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
   
    // send values to share view controllers
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // if segue is the intented one
        if segue.identifier == "pintoshareview" {
            let viewController = segue.destination as! ShareLocationViewController
            viewController.locationCoordinate = locationCoordinate
            viewController.locationName  = locationName
            viewController.mediaURL  = mediaURLTextField.text
        }
    }
    
    // cancel button
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // find locaiton clicked
    @IBAction func findLocation(_ sender: Any) {
        LoadingOverlay.shared.showOverlay(view: UIApplication.shared.keyWindow!)
       
         guard let locationName = locationTextField.text?.trimmingCharacters(in: .whitespaces), !locationName.isEmpty
            else{
                LoadingOverlay.shared.hideOverlayView()
                showAlert(title: "Warning", message: "Please provide a correct location name")
                
            return
        }
        // get cordination from city name
        getCoordinateForCity(location: locationName) { (locationCoordinate, error) in
            if error != nil {
                LoadingOverlay.shared.hideOverlayView()
                self.showAlert(title: "Error", message: "Unable to find the location provided")
                return
            }
            //set the variables and show on the share locaiton map view
            self.locationCoordinate = locationCoordinate
            self.locationName = locationName
            LoadingOverlay.shared.hideOverlayView()
            self.performSegue(withIdentifier: "pintoshareview", sender: self.presentedViewController)
        }
    }
    
    // Get cordination for a sepecified city
    func getCoordinateForCity(location: String, completion: @escaping(_ coordinate: CLLocationCoordinate2D?, _ error: Error?) -> () ) {
        CLGeocoder().geocodeAddressString(location) { placemarks, error in
            completion(placemarks?.first?.location?.coordinate, error)
        }
    }
}

    // MARK: - Keyboard Delegations
extension newLocationViewController: UITextFieldDelegate {
    //hide keyboard when return pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //setup keyboard notification
    func subscribeToKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //remove keyboard notificaiton
    func unsubscribeFromKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //get the keyboard layout height
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    
    @objc func keyboardWillShow(_ notification: Notification) {
        //reaise keyboard for text editing
        if locationTextField.isEditing || mediaURLTextField.isEditing{
            let stackSize = self.stackView.frame.maxY - self.imageView.frame.height - 16;
            let keyboardSize = self.view.frame.height - getKeyboardHeight(notification)
            let offset = stackSize - keyboardSize
            if offset < 0 {
                return
            }
            view.frame.origin.y -= offset
        }
    }
    
    // When hiding return to original state
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
}

