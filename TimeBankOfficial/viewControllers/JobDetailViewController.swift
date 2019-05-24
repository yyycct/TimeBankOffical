import UIKit
import CoreLocation
import Firebase
import FirebaseAuth
import MapKit

class JobDetailViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var job: UILabel!
    @IBOutlet weak var des: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var workingTime: UILabel!
    @IBOutlet weak var estDistance: UILabel!
    @IBOutlet weak var currentZipcode: UITextField!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var taken: UILabel!
    
    var locationManager:CLLocationManager!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.job?.text = jobs[myIndex].title
        self.des?.text = jobs[myIndex].text
        self.time?.text = String(jobs[myIndex].time) + " min"
        self.email?.text = "Requester's email: "+jobs[myIndex].requesterEmail
        self.workingTime?.text = "Working time: "+jobs[myIndex].workingTime

        if jobs[myIndex].jobTaken == true{
            self.acceptButton.isHidden = true
            self.taken.text = "Job is already taken"
        }
        else {
            self.acceptButton.isHidden = false
            self.taken.isHidden = true
        }
    }
    
    var getLocationFromPostalCode:CLLocationManager!
    
    func getLocationFromPostalCode(zipcode: String){
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(zipcode) {
            (placemarks, error) -> Void in
            
            if let placemark = placemarks?[0] {
                
                let workerLat=(placemark.location?.coordinate.latitude)!
                let workerLong=(placemark.location?.coordinate.longitude)!

                db.collection("jobHistory").document(jobs[myIndex].jobID).getDocument() { (QuerySnapshot, Error) in
                    
                    guard let snapshot = QuerySnapshot else { print("Error retreiving snapshots \(Error!)")
                        return
                    }
                    let currentLat = snapshot["currentLat"]
                    let currentLong = snapshot["currentLong"]
                    
                    let locCurrent = CLLocation(latitude: currentLat as! CLLocationDegrees, longitude: currentLong as! CLLocationDegrees)
                    let locWorker = CLLocation(latitude: workerLat, longitude: workerLong)
                    
                    let distance = locCurrent.distance(from: locWorker)
                    
                    //self.estDistance.text = "lat1: \(currentLat) long1: \(currentLong), lat2: \(workerLat) long2: \(workerLong) "
                    self.estDistance.text =  String(Int(distance/1000))+"km"
                    }
                    
                }
                

            }
        }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //let zipcode  = ""
        let userLocation :CLLocation = locations[0] as CLLocation
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
            if (error != nil){
                print("error in reverseGeocode")
            }
            let placemark = placemarks! as [CLPlacemark]
            if placemark.count>0{
                let placemark = placemarks![0]
                self.currentZipcode.text = " \(placemark.postalCode!)"
                
            }
        }

    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
    
    
    @IBAction func calculatePressed(_ sender: Any) {
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.startUpdatingLocation()
        }
        
//        let currentZip = currentZipcode.text!
        let workerZip = currentZipcode.text
        
        getLocationFromPostalCode(zipcode: workerZip!)
        
    }
    
    @IBAction func acceptPressed(_ sender: Any) {
        let workerEmail = Auth.auth().currentUser?.email
        
        db.collection("userInfo").whereField("email", isEqualTo: workerEmail as Any).getDocuments() {(querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in (querySnapshot?.documents)! {
                    let workerName = document.data()["name"] as? String ?? ""
                    db.collection("jobHistory").document(jobs[myIndex].jobID).setData(["jobTaken": true, "workerEmail": workerEmail!, "workerName": workerName, "needApproval": true], merge: true)
                }
            }
        }
        
//        jobs.remove(at: myIndex)
//        myIndex = 0
        performSegue(withIdentifier: "detailToAccept", sender: self)
        
        acceptButton.isHidden = true
        }
    
}
