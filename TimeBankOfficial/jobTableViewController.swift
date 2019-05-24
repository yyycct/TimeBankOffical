import UIKit
import FirebaseAuth

class JobCell: UITableViewCell {

    @IBOutlet weak var setText: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var title: UILabel!
}

var myIndex = 0
var jobs = [Jobs]()

class jobTableViewController: UITableViewController {
    
    @IBOutlet var tblDemo: UITableView!
    
    var JobDetailViewController: JobDetailViewController? = nil
    //var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        jobs = []
        
    }
    
    func loadData () {
        
        let reqEmail = Auth.auth().currentUser?.email
        db.collection("jobHistory").whereField("finished", isEqualTo: false).getDocuments() {(querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in (querySnapshot?.documents)! {
                    let title = document.data()["jobTitle"] as? String ?? ""
                    let des = document.data()["jobDescription"] as? String ?? ""
                    let time = document.data()["timePromised"] as? Int
                    let requesterZipcode = document.data()["requesterZipcode"] as? String ?? ""
                    let workerZipcode = document.data()["workerZipcode"] as? String ?? ""
                    let workingTime = document.data()["workingTime"] as? String ?? ""
                    let requesterEmail = document.data()["requesterEmail"] as? String ?? ""
                    let jobID = document.documentID
                    let canceled = document.data()["canceled"] as? Bool
                    let jobTaken = document.data()["jobTaken"] as? Bool
                    
                    if (requesterEmail != reqEmail) {
                        jobs.append(Jobs(title: title, text: des, time: time!, requesterZipcode: requesterZipcode, workerZipcode: workerZipcode, workingTime: workingTime, requesterEmail: requesterEmail, jobID: jobID, canceled: canceled!, jobTaken: jobTaken!))
                    }
                }
            }
            DispatchQueue.main.async
                {
                    self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jobs.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LableCell", for: indexPath) as! JobCell
        
        
        let job = jobs[indexPath.row]
        cell.title?.text = job.title
        cell.setText?.text = job.text
        cell.time?.text = String(job.time)+"min"
        
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        myIndex = indexPath.row
        performSegue(withIdentifier: "tableToDetail", sender: self)
    }
    
}




