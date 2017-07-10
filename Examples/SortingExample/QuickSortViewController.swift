//
//  QuickSortViewController.swift
//  MCExamples
//
//  Created by Dawand Sulaiman on 19/06/2017.
//  Copyright © 2017 StAndrews. All rights reserved.
//

import UIKit
import MobileCloud

class QuickSortViewController: UIViewController {

    let mc = MobileCloud.MCInstance
    
    @IBOutlet var logTextView: UITextView!
    
    @IBOutlet var myName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myName.text = mc.PeerName
        
        SwiftEventBus.onMainThread(self, name: "quick sort log") { result in
            let format: String = result.object as! String
            self.quickSortLog(format)
        }

        // Do any additional setup after loading the view.
    }

    @IBAction func sortBtnTapped(_ sender: Any) {
        
        initiateMobileCloud()
    }

    func initiateMobileCloud() {
        // set the job
        mc.setJob(job: QSJob())
        // set the search term
    //    (MobileCloud.MCInstance.getJob() as! TSJob).searchTerm = searchTerm
        // start executing
       mc.execute(type: OffloadingType.local)
    }

    func quickSortLog(_ format: String, writeToDebugLog:Bool = false, clearLog: Bool = false) {
        DispatchQueue.main.async {
            if(clearLog) {
                self.logTextView.text = ""
            }
            
            let dateFormater = DateFormatter()
            dateFormater.dateFormat = DateFormatter.dateFormat(fromTemplate: "HH:mm:ss.SSS", options: 0, locale:  Locale.current)
            let currentTimestamp:String = dateFormater.string(from: Date());
            DispatchQueue.main.async {
                self.logTextView.text.append(currentTimestamp + " " + format + "\n")
                self.logTextView.scrollRangeToVisible(NSMakeRange(self.logTextView.text.characters.count - 1, 1));
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
