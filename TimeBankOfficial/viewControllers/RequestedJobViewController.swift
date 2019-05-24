import UIKit

class RequestedJobViewController: UIViewController {

    @IBOutlet weak var tit: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var des: UILabel!
    @IBOutlet weak var workerEmail: UILabel!
    @IBOutlet weak var workingTime: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var approveButton: UIButton!
    @IBOutlet weak var disapproveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tit?.text = requestedJobs[requestIndex].title
        self.time?.text = "Time worth: " + String(requestedJobs[requestIndex].time) + "mins"
        self.workerEmail?.text = "Worker's email: " + requestedJobs[requestIndex].workerEmail
        self.workingTime?.text = "Working time: " + requestedJobs[requestIndex].workingTime
        // Do any additional setup after loading the view.
        //self.des?.text = requestedJobs[requestIndex].des
        let theWorkerEmail = requestedJobs[requestIndex].workerEmail
        db.collection("userInfo").whereField("email", isEqualTo: theWorkerEmail).getDocuments() {(querySnapshot, err) in
            for document in (querySnapshot?.documents)! {
                let descri = document.data()["profileDescription"] as? String
                self.des?.text = descri
            }
        }
        
        let finished = requestedJobs[requestIndex].finished
        let needApproval = requestedJobs[requestIndex].needApproval
        let approved = requestedJobs[requestIndex].approved
        let canceled = requestedJobs[requestIndex].canceled
        let taken = requestedJobs[requestIndex].jobTaken
        
        if (taken == false)
        {
            self.status?.text = "Job is not yet taken"
            approveButton.isHidden = true
            disapproveButton.isHidden = true
            cancelButton.isHidden = false
        }
        else if (needApproval == true)
        {
                self.status?.text = "Need Approval"
                approveButton.isHidden = false
                disapproveButton.isHidden = false
                cancelButton.isHidden = false
            
        }
        else {
            if (canceled == true)
            {
                self.status?.text = "Canceled"
                approveButton.isHidden = true
                disapproveButton.isHidden = true
                cancelButton.isHidden = true
            }
            else {
                if (finished==true) {
                    self.status.text? = "Job Finished!!"
                    approveButton.isHidden = true
                    disapproveButton.isHidden = true
                    cancelButton.isHidden = true
                }
                else if (approved == true)
                    {
                        self.status?.text = "Approved!"
                        approveButton.isHidden = true
                        disapproveButton.isHidden = true
                        cancelButton.isHidden = true
                    }
                else if (approved == false)
                {
                    self.status?.text = "Disapproved"
                    approveButton.isHidden = true
                    disapproveButton.isHidden = true
                    cancelButton.isHidden = true
                }
            }
        }
        
    }
    @IBAction func Disapprove(_ sender: Any) {
        db.collection("jobHistory").document(requestedJobs[requestIndex].jobID).setData(["approved": false, "needApproval": false], merge:true)

        status.text! = "Disapproved"
        approveButton.isHidden = true
        disapproveButton.isHidden = true
        cancelButton.isHidden = true
    }
    @IBAction func approve(_ sender: Any) {
        db.collection("jobHistory").document(requestedJobs[requestIndex].jobID).setData(["needApproval": false, "approved": true], merge:true)
        
        status.text! = "Approved!"
        approveButton.isHidden = true
        disapproveButton.isHidden = true
        cancelButton.isHidden = true
    }
    
    @IBAction func cancelJob(_ sender: Any) {
        db.collection("jobHistory").document(requestedJobs[requestIndex].jobID).setData(["canceled": true, "needApproveal": false, "jobTaken": true], merge:true)
        
        let userEmail = requestedJobs[requestIndex].requesterEmail
        db.collection("userInfo").whereField("email", isEqualTo: userEmail).getDocuments() {(querySnapshot, err) in
            for document in (querySnapshot?.documents)! {
                let requesterTime = document.data()["timeOwned"] as! Int
                let userID = document.documentID
                
                let timeNow = (requesterTime + requestedJobs[requestIndex].time)
                db.collection("userInfo").document(userID).setData(["timeOwned": timeNow], merge: true)
            }
        }
        
        status.text! = "Job Canceled"
        approveButton.isHidden = true
        disapproveButton.isHidden = true
        cancelButton.isHidden = true
    }
    
    
}
