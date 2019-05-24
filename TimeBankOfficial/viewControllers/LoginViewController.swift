//
//  LoginViewController.swift
//  TimeBankOfficial
//
//  Created by ChangFeiyu on 4/13/19.
//  Copyright © 2019 cis454Group12. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        email.delegate = self
        password.delegate = self
        
        //listen for keyboard event
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    deinit {
        // stop listening
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    func hideKeyboard() {
        email.resignFirstResponder()
        password.resignFirstResponder()
    }
    
    @objc func keyboardWillChange(notification: Notification) {
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification {

            //view.frame.origin.y = -keyboardRect.height
            view.frame.origin.y = -150
            
        }
        else {
        view.frame.origin.y = 0
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        email.resignFirstResponder()
        password.resignFirstResponder()
        hideKeyboard()
        return true
    }
    
    @IBAction func loginPress(_ sender: Any) {
        
        Auth.auth().signIn(withEmail: email.text!, password: password.text!) { (user, error) in
            if error == nil {
                self.performSegue(withIdentifier: "loginToHome", sender: self)
            }
            else {
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
        
    }
    }

    @IBAction func signupPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "loginToSignup", sender: self)
    }
    
    
}
