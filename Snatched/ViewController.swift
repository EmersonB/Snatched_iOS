//
//  ViewController.swift
//  Snatched
//
//  Created by Emerson L. Berlik on 7/19/18.
//  Copyright © 2018 Emerson L. Berlik. All rights reserved.
//

import UIKit
import CoreMotion
import Alamofire

class ViewController: UIViewController {
    
    let textView = UITextView()
    var text = ""
    
    var motionManager = CMMotionManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        textView.backgroundColor = UIColor.black
        textView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        textView.textColor = UIColor.white
        textView.font = UIFont(name: "Courier New", size: 14)
        text.append("Terminal Started \n$ starting data stream \n$ format:[ax, ay, az, gx, gy, gz]")
        textView.text = text

        self.view.addSubview(self.textView)
        self.view.sendSubview(toBack: self.textView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func collectPressed(_ sender: Any) {
        startStream()
    }
    @IBAction func cancelPressed(_ sender: Any) {
        motionManager.stopGyroUpdates()
        motionManager.stopAccelerometerUpdates()
    }
    
    func startStream(){
        motionManager.gyroUpdateInterval = 0.2
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startGyroUpdates(to: OperationQueue.current!){ (data, error) in
            if let gyroData = data {
                self.motionManager.startAccelerometerUpdates(to: OperationQueue.current!){ (data, error) in
                    if let accelData = data {
                        let parameters: Parameters = [
                            "accex": accelData.acceleration.x,
                            "accey": accelData.acceleration.y,
                            "accez": accelData.acceleration.z,
                            "gyrox": gyroData.rotationRate.x,
                            "gyroy": gyroData.rotationRate.y,
                            "gyroz": gyroData.rotationRate.z,
                            "time": NSDate().timeIntervalSince1970
                            ]
                        self.text.append("\n$ ax:" + String(accelData.acceleration.x))
                        self.text.append("\n$ ay:" + String(accelData.acceleration.y))
                        self.text.append("\n$ az:" + String(accelData.acceleration.z))
                        self.text.append("\n$ gx:" + String(gyroData.rotationRate.x))
                        self.text.append("\n$ gy:" + String(gyroData.rotationRate.y))
                        self.text.append("\n$ gz:" + String(gyroData.rotationRate.z))
                        
                        self.textView.text = self.text
//                        print(parameters)
                        
                        Alamofire.request("http://ec2-18-207-187-22.compute-1.amazonaws.com:8080/api/entry/2", method: .post, parameters: parameters, encoding: URLEncoding(destination: .httpBody), headers: nil)
                    }
                }
            }
        }
    }

}

