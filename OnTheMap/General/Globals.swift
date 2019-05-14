//
//  Globals.swift
//  OnTheMap
//
//  Created by Waiel Eid on 10/5/19.
//  Copyright © 2019 Waiel Eid. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

// a global class for shared variables and functions
class Globals {
// MARK: - variables defined
    struct Auth {
        var sessionId = ""
        var firstName = ""
        var lastName  = ""
        var objectId = ""
        var key = ""
    }
    // initate the class
    static let shared = Globals()
    
    var studentsLocations: [StudentLocation]?
    
    var curentStudent: Auth?
}

extension UIViewController {
    // fuve controller for
    func showAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }

}


// MARK: - LoadingOverlay Class
// a class for showing the animated activity indicator
// Code credit to Lucho : https://stackoverflow.com/questions/27960556/loading-an-overlay-when-running-long-tasks-in-ios
public class LoadingOverlay{
    
    var overlayView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    var bgView = UIView()
    
    class var shared: LoadingOverlay {
        struct Static {
            static let instance: LoadingOverlay = LoadingOverlay()
        }
        return Static.instance
    }
    // show the activity indicator
    public func showOverlay(view: UIView) {
        
        bgView.frame = view.frame
        bgView.backgroundColor = UIColor.gray
        bgView.addSubview(overlayView)
        bgView.autoresizingMask = [.flexibleLeftMargin,.flexibleTopMargin,.flexibleRightMargin,.flexibleBottomMargin,.flexibleHeight, .flexibleWidth]
        overlayView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        overlayView.center = view.center
        overlayView.autoresizingMask = [.flexibleLeftMargin,.flexibleTopMargin,.flexibleRightMargin,.flexibleBottomMargin]
        overlayView.backgroundColor = UIColor.black
        overlayView.clipsToBounds = true
        overlayView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicator.style = .whiteLarge
        activityIndicator.center = CGPoint(x: overlayView.bounds.width / 2, y: overlayView.bounds.height / 2)
        
        overlayView.addSubview(activityIndicator)
        view.addSubview(bgView)
        self.activityIndicator.startAnimating()
        
    }
    // hide the activity indicator
    public func hideOverlayView() {
        activityIndicator.stopAnimating()
        bgView.removeFromSuperview()
    }
}
