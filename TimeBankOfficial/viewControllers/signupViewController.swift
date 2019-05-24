//
//  ViewController.swift
//  TimeBankOfficial
//
//  Created by ChangFeiyu on 4/13/19.
//  Copyright © 2019 cis454Group12. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

let db = Firestore.firestore()
//FirebaseApp.configure()

class signupViewController: UIViewController, UITextFieldDelegate {
    
    var gender = ""
    var ref: DocumentReference? = nil
    
    @IBOutlet weak var fullname: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var passwordConfirm: UITextField!
    @IBOutlet weak var genderImage: UIImageView!
    
    @IBAction func malePressed(_ sender: Any) {
        genderImage.image = UIImage(named: "male")
        gender = "male"
    }
    @IBAction func femalePressed(_ sender: Any) {
        genderImage.image = UIImage(named: "female")
        gender = "female"
    }
    
    
    @IBAction func signupPressed(_ sender: Any) {
    
        if (fullname.text?.isEmpty ?? true) || (email.text?.isEmpty ?? true) ||  (password.text?.isEmpty ?? true) || (passwordConfirm.text?.isEmpty ?? true){
            let alertController = UIAlertController(title: "Information missing", message: "Please fill out all boxes", preferredStyle: .alert)
            
            let defautAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            alertController.addAction(defautAction)
            self.present(alertController, animated: true, completion: nil)
        } // end of if
        
        else {
        
            if password.text != passwordConfirm.text {
                
                let alertController = UIAlertController(title: "Password Doesn't Match", message: "Please re-enter password", preferredStyle: .alert)
                
                let defautAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                alertController.addAction(defautAction)
                self.present(alertController, animated: true, completion: nil)
            } // end of if
                
            else {
                Auth.auth().createUser(withEmail: email.text!, password: password.text!) { (user, error) in
                    if error == nil {
                        
                        let user = Auth.auth().currentUser
                        
                        let docData: [String: Any] = [
                            "name": self.fullname.text!,
                            "email": self.email.text!,
                            "gender": self.gender,
                            "timeOwned": 60,
                            "profileDesription": ""
                        ]
                        db.collection("userInfo").document(user!.uid).setData(docData, merge:true) { err in
                            if let err = err {
                                print("Error writing document: \(err)")
                            } else {
                                print("Document successfully written!")
                                
                            }
                        }
                        
                        self.performSegue(withIdentifier: "signupToHome", sender: self)
                    }
                    else {
                        let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        
                        alertController.addAction(defaultAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
                
                
                } //end of else
            }//end of else
    } // end of signupPressed
    
    @IBAction func haveAccountPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "signupToLogin", sender: self)
    }
    
    override func viewDidLoad() {
        fullname.delegate = self
        password.delegate = self
        passwordConfirm.delegate = self
        email.delegate = self
        
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
        passwordConfirm.resignFirstResponder()
        fullname.resignFirstResponder()
    }
    
    @objc func keyboardWillChange(notification: Notification) {
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification {
            
            //view.frame.origin.y = -keyboardRect.height
            view.frame.origin.y = 0
            
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
}
