//
//  ViewController.swift
//  VoiceOnly
//
//  Created by Wangchou Lu on H30/04/14.
//  Copyright © 平成30年 Lu, WangChou. All rights reserved.
//

import UIKit

var isDev = false



class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // AudioController.shared.start()
        
        let myGroup = DispatchGroup()
        let myQueue = DispatchQueue(label: "for Sync/Blocking version of async functions")
        
        func waitConcurrentJobs() {
            myGroup.wait()
        }
        
        // original function (async version)
        func download(_ something: String, _ seconds: UInt32 = 1, completionHandler: @escaping ()->Void = {}) {
            print("Downloading \(something)")
            DispatchQueue.global().async {
                sleep(seconds)
                print("\(something) is downloaded")
                completionHandler()
            }
        }
        
        // wrapped function (synced version)
        // Warning:
        // It blocks current thead !!!
        // Do not call it on main thread
        func downloadSync(
            _ something: String,
            _ seconds: UInt32 = 1,
            isConcurrent: Bool = false
            ){
            myGroup.enter()
            download(something, seconds) { myGroup.leave() }
            if !isConcurrent {
                myGroup.wait()
            }
        }
        
        // after wrapping async function to sync version
        // now it really looks like ES8 async/await
        myQueue.async {
            downloadSync("A")
            downloadSync("B", isConcurrent: true)
            downloadSync("C", isConcurrent: true)
            downloadSync("D", 4, isConcurrent: true)
            waitConcurrentJobs()
            downloadSync("E")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


