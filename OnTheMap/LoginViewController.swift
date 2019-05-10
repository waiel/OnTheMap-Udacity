//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Waiel Eid on 10/5/19.
//  Copyright © 2019 Waiel Eid. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
   
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var stackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidesWhenStopped = true
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }


    
    @IBAction func performLogin(_ sender: Any) {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        let username = usernameTextField.text!
        let password = passwordTextField.text!
        
        if(username.isEmpty || password.isEmpty) {
            showAlert(title: "Information Required", message: "Email and Password can not be empty!\n Please fill the required fileds to login")
            activityIndicator.stopAnimating()
            return
        }
        
        
        UdacityAPI.postLogin(email: username, password: password) { (response, error) in
            
            if let error = error {
                //self.showAlert(title: "Failed Login", message: error.localizedDescription)
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
                return
            }
            
            if let error = response!["error"] as? String {
               // self.showAlert(title: "Error", message: error)
                print(error)
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
                return
            }
            
            if  let session = response?["session"] as? [String:Any],
                let sessionid = session["id"] as? String
            {
                print(session)
                print(sessionid)
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                     self.performSegue(withIdentifier: "OnTheMapTabBar", sender: self)
                }
               
            }
            
        }
       
       activityIndicator.stopAnimating()
        
    }
    
    
    func showAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func prevenUserAcction(action: Bool){
        DispatchQueue.main.async {
            self.loginButton.isEnabled = !action
            self.usernameTextField.isUserInteractionEnabled = !action
            self.passwordTextField.isUserInteractionEnabled = !action
            
        }
    }

}



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
            let stackSize = self.stackView.frame.maxY;
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

