//
//  ViewController.swift
//  WordCount
//
//  Created by Dawand Sulaiman on 06/05/2017.
//  Copyright © 2017 StAndrews. All rights reserved.
//

import UIKit
import MobileCloud
import MultipeerConnectivity

class TextSearchViewController: UIViewController,UITextFieldDelegate {
    
    let mc = MobileCloud.MCInstance
    
    @IBOutlet var myNameLabel: UILabel!
    @IBOutlet var textSearchField: UITextField!
    
    @IBOutlet var searchCloudlet: UIButton!
    
    @IBOutlet var searchCloud: UIButton!
    
    @IBOutlet var logTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initiateMobileCloud(textSearchField.text!)
        
        // log any info from text search jobs to our textbox
        SwiftEventBus.onMainThread(self, name: "text search log") { result in
            let format: String = result.object as! String
            self.searchLog(format)
        }
        
        textSearchField.delegate = self
        myNameLabel.text = mc.PeerName
    }
    
    override func viewDidAppear(_ animated: Bool) {
    //    searchCloudlet.isEnabled = isCloudletConnected
    //    searchCloud.isEnabled = isCloudConnected
    }
    
    @IBAction func sendExecutionData(_ sender: Any) {
        mc.sendExecutionData()
    }
    
    func initiateMobileCloud(_ searchTermSent: String) {
        
        // set the job
        mc.setJob(job: TSJob())
        
        // set the search term
        (mc.getJob() as! TSJob).searchTerm = searchTermSent
    }
    
    @IBAction func startBtn(_ sender: Any) {
        
        debugPrint("task started!")
        
        if(textSearchField.text != nil && (textSearchField.text?.characters.count)! > 0) {
            textSearchField.resignFirstResponder()
            searchLocal()
        }
    }
    
    func searchLocal(){
        initiateMobileCloud(textSearchField.text!)
        // start executing
        mc.execute(type: OffloadingType.local)
        textSearchField.resignFirstResponder()
    }
    
    @IBAction func searchCloudlet(_ sender: Any) {
        
        mc.setCloudletJob(job: TSCloudletJob())
        (mc.getCloudletJob() as! TSCloudletJob).searchTerm = textSearchField.text!
        
        mc.execute(type:OffloadingType.cloudlet)
        
        textSearchField.resignFirstResponder()

    }
    
    @IBAction func searchCloud(_ sender: Any) {
        // TODO: FIX THIS TO REFLECT CLOUD CLASS
        searchCloudlet(self)
        
        textSearchField.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchLog(_ format: String, writeToDebugLog:Bool = false, clearLog: Bool = false) {
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
}
