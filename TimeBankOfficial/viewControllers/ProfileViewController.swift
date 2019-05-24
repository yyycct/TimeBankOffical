import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import Foundation

class ProfileViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var timeOwned: UILabel!
    @IBOutlet weak var profileDescription: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileDescription.delegate = self
        
        let user = Auth.auth().currentUser
        let docRef = db.collection("userInfo").document(user!.uid)
        docRef.getDocument { QuerySnapshot, Error in
            guard let snapshot = QuerySnapshot else {
                print("Error retreiving snapshots \(Error!)")
                return
            }
            let uName = snapshot["name"] as? String ?? ""
            self.name.text = uName
            let uEmail = snapshot["email"] as? String ?? ""
            self.email.text = uEmail
            let uGender = snapshot["gender"] as? String ?? ""
            if (uGender == "male") {
                self.profileImage.image = UIImage(named: "male")
            }
            else if (uGender == "female") {
                self.profileImage.image = UIImage(named: "female")
            }
            else{
                self.profileImage.image = UIImage(named: "myApp")
            }
            let uTimeOwned = snapshot["timeOwned"] as! Int
            self.timeOwned.text = ("Time Owns:  \(String(describing: uTimeOwned)) mins")
            self.profileDescription.text = snapshot["profileDescription"] as? String ?? ""
        }
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    } // end of viewDidLoad
    
    deinit {
        // stop listening
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    func hideKeyboard() {
        profileDescription.resignFirstResponder()
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
    
    @IBAction func signOutPressed(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
        performSegue(withIdentifier: "logout", sender: self)
    }
    
    
    @IBAction func submitPressed(_ sender: Any) {
        let user = Auth.auth().currentUser
        let docRef = db.collection("userInfo").document(user!.uid)
        let docData: [String: Any] = ["profileDescription":profileDescription.text]
        docRef.setData(docData, merge:true) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
                let alertController = UIAlertController(title: "Done!", message: "Profile Description submitted!!", preferredStyle: .alert)
                
                let defautAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                alertController.addAction(defautAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        profileDescription.resignFirstResponder()
        hideKeyboard()
        return true
    }
}
