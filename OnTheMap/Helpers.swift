//
//  helpers.swift
//  OnTheMap
//
//  Created by Waiel Eid on 10/5/19.
//  Copyright © 2019 Waiel Eid. All rights reserved.
//

import Foundation
import UIKit

class Helpers {
    
    
    func showAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        alert.present(alert, animated: true, completion: nil)
    }

    
    func showAlertAction(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Overwrite", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        alert.present(alert, animated: true, completion: nil)
    }

}
