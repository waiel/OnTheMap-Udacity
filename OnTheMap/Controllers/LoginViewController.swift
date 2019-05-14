//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Waiel Eid on 10/5/19.
//  Copyright © 2019 Waiel Eid. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: - Variables Defined
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var SignupButton: UIButton!
    @IBOutlet weak var signupStackView: UIStackView!
    
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }


        // MARK: - Login Action
    @IBAction func performLogin(_ sender: Any) {
        
        LoadingOverlay.shared.showOverlay(view: UIApplication.shared.keyWindow!)
        let username = usernameTextField.text!
        let password = passwordTextField.text!
        
        if username.isEmpty || password.isEmpty {
            LoadingOverlay.shared.hideOverlayView()
            self.showAlert(title: "Information Required", message: "Email and Password can not be empty!\n Please fill the required fileds to login")
            return
        }
        
        // send login request through API
        UdacityAPI.postLogin(email: username, password: password) { (response, error) in
            
            if let error = error {
                self.showAlert(title: "Failed Login", message: error.localizedDescription)
                LoadingOverlay.shared.hideOverlayView()
                return
            }

            // if a respond recived with error codes stop
            if let error = response?["error"] as? String {
               LoadingOverlay.shared.hideOverlayView()
               self.showAlert(title: "Error", message: error)
               return
            }

            // logedin
            if  let session = response?["session"] as? [String:Any],
                let account = response?["account"] as? [String:Any]
            {
                // store information recived
                Globals.shared.curentStudent?.sessionId = (session["id"] as? String)!
                Globals.shared.curentStudent?.key = (account["key"] as? String)!
                // set a first and last name
                Globals.shared.curentStudent?.firstName = "Waiel"
                Globals.shared.curentStudent?.lastName = "Eid"
                LoadingOverlay.shared.hideOverlayView()
                    DispatchQueue.main.async {
                        // show other view controller
                        self.performSegue(withIdentifier: "performLogin", sender: self)
                }
               
            }
            
        }
        
    }
    
    //signup buttton
    @IBAction func signUp(_ sender: Any) {
        let app = UIApplication.shared
        let toOpen = "https://auth.udacity.com/sign-up"
        guard let url = URL(string: toOpen) else {
                return
        }
        app.open(url, options: [:], completionHandler: nil)
    }
}


    // MARK: - Keyboard Extentions
extension LoginViewController: UITextFieldDelegate {
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
        if usernameTextField.isEditing || passwordTextField.isEditing{
            let stackSize = self.stackView.frame.maxY - self.signupStackView.frame.height - 60;
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

