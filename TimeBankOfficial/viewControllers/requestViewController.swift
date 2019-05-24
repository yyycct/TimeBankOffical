import UIKit
import Firebase
import FirebaseAuth
import CoreLocation

class requestViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var jobTitleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var timeToOfferTextField: UITextField!
    @IBOutlet weak var jobDateAndTimeTextField: UITextField!
    @IBOutlet weak var zipcode: UITextField!
    
    let db = Firestore.firestore()
    var jobID: Int = 0
    var requesterName: String = ""
    let datePicker = UIDatePicker()
    var locationManager:CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showDatePicker()
        
        jobDateAndTimeTextField?.inputView = datePicker
        
        jobTitleTextField?.delegate = self
        descriptionTextView?.delegate = self
        zipcode?.delegate = self
        timeToOfferTextField?.delegate = self
        jobDateAndTimeTextField?.delegate = self
        
        //listen for keyboard event
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation :CLLocation = locations[0] as CLLocation
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
            if (error != nil){
                print("error in reverseGeocode")
            }
            let placemark = placemarks! as [CLPlacemark]
            if placemark.count>0{
                let placemark = placemarks![0]
                self.zipcode.text = " \(placemark.postalCode!)"
            }
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
    
    
    func showDatePicker() {
        datePicker.datePickerMode = .dateAndTime
        
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        
        toolbar.setItems([doneButton], animated: false)
        
        jobDateAndTimeTextField?.inputAccessoryView = toolbar
        jobDateAndTimeTextField?.inputView = datePicker
    }
    
    @objc func donedatePicker(){
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy, hh:mma"
        jobDateAndTimeTextField?.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    @IBAction func useCurrentLocationPressed(_ sender: Any) {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.startUpdatingLocation()
        }
    }
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        let user = Auth.auth().currentUser
        
        self.db.collection("userInfo").document(user!.uid).getDocument { QuerySnapshot, Error in
            guard let snapshot = QuerySnapshot else {
                print("Error retreiving snapshots \(Error!)")
                return
            }
            
            let timeHave = (snapshot["timeOwned"] as? Int)!
            //self.descriptionTextView.text = self.requesterName
        
            if (self.jobTitleTextField.text?.isEmpty ?? true) || (self.descriptionTextView.text?.isEmpty ?? true) || (self.zipcode.text?.isEmpty ?? true) || (self.timeToOfferTextField.text?.isEmpty ?? true) || (self.jobDateAndTimeTextField.text?.isEmpty ?? true) {
            
            let alertController = UIAlertController(title: "Information missing", message: "Please fill out all boxes", preferredStyle: .alert)
            
            let defautAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            alertController.addAction(defautAction)
            self.present(alertController, animated: true, completion: nil)
            
        } // end of if
        else if ((Int(self.timeToOfferTextField.text!)!) > (timeHave)) {
            
            let alertController = UIAlertController(title: "Not enougn time in bank", message: "Please reconsider", preferredStyle: .alert)
            let defautAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            alertController.addAction(defautAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            let docRef = self.db.collection("jobID").document("ID")
            docRef.getDocument { QuerySnapshot, Error in
                guard let snapshot = QuerySnapshot else {
                    print("Error retreiving snapshots \(Error!)")
                    return
                }
                if let JobID = snapshot["ID"] as? Int {
                    //db.collection("jobHistory").document(self.JobID)
                    
                    let new=JobID+1
                    docRef.setData(["ID":(new)])
                    
                    //self.jobTitleTextField.text = String(new)
                    self.jobID = new
                }
                
                let formatter : DateFormatter = DateFormatter()
                formatter.dateFormat = "d/M/yy"
                let currentDate : String = formatter.string(from:  NSDate.init(timeIntervalSinceNow: 0) as Date)
                
                let user = Auth.auth().currentUser
                self.db.collection("userInfo").document(user!.uid).getDocument { QuerySnapshot, Error in
                    guard QuerySnapshot != nil else {
                        print("Error retreiving snapshots \(Error!)")
                        return
                    }
                    self.requesterName = snapshot["name"] as? String ?? ""
                    //self.descriptionTextView.text = self.requesterName
                }
                
                let docRef1 = self.db.collection("userInfo").document(user!.uid)
                
                docRef1.getDocument() {(querySnapshot, err) in
                    
                    let requesterTime = querySnapshot!["timeOwned"] as! Int
                    let timeNow = (requesterTime - Int(self.timeToOfferTextField.text!)!)
                    docRef.setData(["timeOwned": timeNow], merge: true)
                }
                
                let offeredTime = Int(self.timeToOfferTextField.text!)
                
                
                let docData: [String: Any] = [
                    "datePosted": currentDate,
                    "finished": false,
                    "currentLat": 0.0,
                    "currentLong": 0.0,
                    "jobDescription": self.descriptionTextView!.text,
                    "jobTitle": self.jobTitleTextField!.text ?? String(),
                    "requesterEmail": user!.email ?? String(),
                    "requesterZipcode": self.zipcode!.text as Any,
                    "requesterName": self.requesterName,
                    "timePromised": offeredTime as Any,
                    "workerEmail": "",
                    "workerName": "",
                    "workingTime": self.jobDateAndTimeTextField!.text as Any,
                    "jobTaken": false,
                    "needApproval": false,
                    "approved": false,
                    "canceled": false
                ]
                
                self.db.collection("jobHistory").document(String(self.jobID)).setData(docData, merge:true) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                        
                    }
                }
                let zipcode = self.zipcode?.text
                self.getLocationFromPostalCode(zipcode: zipcode!)
        
        }
        
        self.performSegue(withIdentifier: "requestToConfirmation", sender: self)
            } //end of else
        }
    }// end of submitPressed
    
    
    
    deinit {
        // stop listening
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    func hideKeyboard() {
        jobTitleTextField.resignFirstResponder()
        descriptionTextView.resignFirstResponder()
        zipcode.resignFirstResponder()
        timeToOfferTextField.resignFirstResponder()
        jobDateAndTimeTextField.resignFirstResponder()
    }
    
    @objc func keyboardWillChange(notification: Notification) {
        //        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
        //            return
        //        }
        
        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification {
            
            //view.frame.origin.y = -keyboardRect.height
            view.frame.origin.y = -80
            
        }
        else {
            view.frame.origin.y = 0
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        jobTitleTextField.resignFirstResponder()
        descriptionTextView.resignFirstResponder()
        zipcode.resignFirstResponder()
        timeToOfferTextField.resignFirstResponder()
        jobDateAndTimeTextField.resignFirstResponder()
        hideKeyboard()
        return true
    }
    
    var getLocationFromPostalCode:CLLocationManager!
    
    func getLocationFromPostalCode(zipcode: String){
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(zipcode) {
            (placemarks, error) -> Void in
            
            if let placemark = placemarks?[0] {
                //                if placemark.postalCode == zipcode{
                let currentLat=(placemark.location?.coordinate.latitude)!
                let currentLong=(placemark.location?.coordinate.longitude)!
                self.db.collection("jobHistory").document(String(self.jobID)).setData(["currentLat": currentLat, "currentLong": currentLong], merge: true)

            }
        }
    }
    
}

