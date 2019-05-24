import Foundation
import UIKit

class Job {
    var title: String
    var des: String
    var time: Int
    
    init?(title: String, des: String, time: Int) {
        guard !title.isEmpty else {
            return nil
        }
        
        guard !des.isEmpty else {
            return nil
        }
        
        guard time>=0 else {
            return nil
        }
        
        self.title = title
        self.des = des
        self.time = time
    }
}
