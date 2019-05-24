
import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

var requestedJobs: [WorkedJob] = []
var requestIndex = 0

class JobRequestCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var redDot: UIImageView!
}
class jobRequestedTableViewController: UITableViewController {
    
    func loadData () {
        let email = Auth.auth().currentUser?.email
        db.collection("jobHistory").whereField("requesterEmail", isEqualTo: (email as Any)).getDocuments() {(querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in (querySnapshot?.documents)! {
                    let title = document.data()["jobTitle"] as? String
                    let time = document.data()["timePromised"] as? Int
                    let status = document.data()["finished"] as! Bool
                    //let des = document.data()["jobDescription"] as? String
                    let workingTime = document.data()["workingTime"] as? String
                    let requesterEmail = document.data()["requesterEmail"] as? String
                    let jobID = document.documentID
                    let workerEmail = document.data()["workerEmail"] as? String
                    let approved = document.data()["approved"] as! Bool
                    
                    let needapproval = document.data()["needApproval"] as! Bool
                    let canceled = document.data()["canceled"] as? Bool
                    let des = document.data()["jobDescription"] as? String
                    let taken = document.data()["jobTaken"] as! Bool
                    
//                    db.collection("userInfo").whereField("requesterEmail", isEqualTo: (email as Any)).getDocuments() {(querySnapshot, err) in
//                        if let err = err {
//                            print("Error getting documents: \(err)")
//                        } else {
//                            for document in (querySnapshot?.documents)! {
//                                let workerDes = document.data()["profileDescription"] as? String
//
                    requestedJobs.append(WorkedJob(title: title!, des: des!, time: time!, requesterEmail: requesterEmail!, workerEmail: workerEmail!, workingTime: workingTime!, jobID: jobID, finished: status, needApproval: needapproval, approved: approved, canceled: canceled!, jobTaken: taken))
                    
                
                
                }
            }
            DispatchQueue.main.async
                {
                    self.tableView.reloadData()
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        requestedJobs = []
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        // MARK: - Table view data source
    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requestedJobs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath) as! JobRequestCell
        
        
        let job = requestedJobs[indexPath.row]
        cell.title?.text = job.title
        
        if (job.jobTaken == false)
        {
            cell.status?.text = "Not yet taken"
            cell.redDot.isHidden = true
        }
        else {
            if (job.needApproval == true) {
                cell.status?.text = "Need Approval"
                cell.redDot.isHidden = false
            }
            else{
                if (job.finished == true)
                {
                    cell.status?.text = "Done!"
                    cell.redDot.isHidden = true
                }
                else
                {
                    cell.status?.text = "Approved, waiting....."
                    cell.redDot.isHidden = true
                }
            }
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        requestIndex = indexPath.row
        performSegue(withIdentifier: "requestedToDetail", sender: self)
    }
    
}
