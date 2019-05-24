//
//  WorkedDetailViewController.swift
//  TimeBankOfficial
//
//  Created by ChangFeiyu on 4/30/19.
//  Copyright © 2019 cis454Group12. All rights reserved.
//

import UIKit

class WorkedDetailViewController: UIViewController {
    @IBOutlet weak var tit: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var des: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var workTime: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var finishedButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tit?.text = workedJobs[workedIndex].title
        self.time?.text = "Time worth: " + String(workedJobs[workedIndex].time) + "mins"
        self.des?.text = workedJobs[workedIndex].des
        self.email?.text = "Requester's email: " + workedJobs[workedIndex].requesterEmail
        self.workTime?.text = "Working time: " + workedJobs[workedIndex].workingTime
        // Do any additional setup after loading the view.
        db.collection("jobHistory").document(workedJobs[workedIndex].jobID).getDocument() {(querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                let needApproval = querySnapshot!["needApproval"] as! Bool
                let finished = querySnapshot!["finished"] as! Bool
                let Approved = querySnapshot!["approved"] as! Bool
                let canceled = querySnapshot!["canceled"] as! Bool
                
                if (needApproval == true)
                {
                    self.status?.text = "Need Approval"
                    self.finishedButton.isHidden = true
                }
                else {
                    if (canceled == true)
                    {
                        self.status?.text = "Canceled"
                        self.finishedButton.isHidden = true
                    }
                    else if (Approved == true)
                    {
                        if (finished==true) {
                            self.status?.text = "Job Finished!!"
                            self.finishedButton.isHidden = true
                        }
                        else {
                            self.status?.text = "Approved!"
                            self.finishedButton.isHidden = false
                        }
                    }
                    else if (Approved == false)
                    {
                        self.status?.text = "Disapproved, sorry"
                        self.finishedButton.isHidden = true
                    }
                }
                
                
                
            }
    }
    }
    

    @IBAction func finishedPressed(_ sender: Any) {
        
        //get the job ID
        let jobID = workedJobs[workedIndex].jobID
        
        let timePromisted = workedJobs[workedIndex].time
        
        if status.text != "Job Finished!!" {
        
        //get requester's email then subtract the time this user owned to the promised time
        let userEmail = workedJobs[workedIndex].requesterEmail
        db.collection("userInfo").whereField("email", isEqualTo: userEmail).getDocuments() {(querySnapshot, err) in
                for document in (querySnapshot?.documents)! {
                    let requesterTime = document.data()["timeOwned"] as! Int
                    let userID = document.documentID
                    let docRef = db.collection("userInfo").document(userID)
                    
                    db.collection("jobHistory").document(jobID).setData(["finished": true], merge: true)
                    
                    let timeNow = (requesterTime - timePromisted)
                    docRef.setData(["timeOwned": timeNow], merge: true)
            }
        }
        
        //get worker's email add time to the worker's account
        let workerEmail = workedJobs[workedIndex].workerEmail
        db.collection("userInfo").whereField("email", isEqualTo: workerEmail).getDocuments() {(querySnapshot, err) in
            for document in (querySnapshot?.documents)! {
                let workerTime = document.data()["timeOwned"] as! Int
                let userID = document.documentID
                let timeNow = (workerTime + timePromisted)
                db.collection("userInfo").document(userID).setData(["timeOwned": timeNow], merge: true)
            }
        }
        }
        
        status!.text = "Job Finished!!"
    }
    
}
