
import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

var workedJobs: [WorkedJob] = []
var workedIndex = 0

class JobWorkedCell: UITableViewCell {
    
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var redDot: UIImageView!
}

class jobWorkedTableViewController: UITableViewController {
    
    
    func loadData () {
        let email = Auth.auth().currentUser?.email
        db.collection("jobHistory").whereField("workerEmail", isEqualTo: (email as Any)).getDocuments() {(querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in (querySnapshot?.documents)! {
                    let title = document.data()["jobTitle"] as? String
                    let time = document.data()["timePromised"] as? Int
                    let des = document.data()["jobDescription"] as? String
                    let workingTime = document.data()["workingTime"] as? String
                    let requesterEmail = document.data()["requesterEmail"] as? String
                    let jobID = document.documentID
                    let workerEmail = document.data()["workerEmail"] as? String
                    let finished = document.data()["finished"] as! Bool
                    
                    let approved = document.data()["approved"] as! Bool
                    
                    let needapproval = document.data()["needApproval"] as! Bool
                    
                    let canceled = document.data()["canceled"] as! Bool
                    let taken = document.data()["jobTaken"] as! Bool
                    
                    workedJobs.append(WorkedJob(title: title!, des: des!, time: time!, requesterEmail: requesterEmail!, workerEmail: workerEmail!, workingTime: workingTime!, jobID: jobID, finished: finished, needApproval: needapproval, approved: approved, canceled: canceled, jobTaken: taken))
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
        workedJobs = []
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        // MARK: - Table view data source
    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workedJobs.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkCell", for: indexPath) as! JobWorkedCell
        
        
        let job = workedJobs[indexPath.row]
        cell.title?.text = job.title
        cell.time?.text = String(job.time)+"min"
        if (job.approved == true){
            if (job.finished == false){
                cell.redDot.isHidden = false}
            else{
                cell.redDot.isHidden = true
            }
        }
        else {
            cell.redDot.isHidden = true
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        workedIndex = indexPath.row
        performSegue(withIdentifier: "workedToDetail", sender: self)
    }
}
