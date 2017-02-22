//
//  DeviceViewController.swift
//  ios-DevNexus
//
//  Created by Marlene Jaeckel.
//  Copyright © 2017 Polyglot Programming. All rights reserved.
//

import Foundation
import UIKit
import MetaWear

class DeviceViewController: UIViewController {
  @IBOutlet weak var deviceStatus: UILabel!
  @IBOutlet weak var startAccelerometer: UIButton!
  @IBOutlet weak var stopAccelerometer: UIButton!
  @IBOutlet weak var stepCount: UILabel!
  
  var device: MBLMetaWear!
  
  var accelerometerBMI160: MBLAccelerometerBMI160!
  var stepEvent: MBLEvent<MBLNumericData>!
  var accelerometerData: NSMutableArray = NSMutableArray(capacity: 1000)
  var steps: Int = 0
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    device.addObserver(self, forKeyPath: "state", options: NSKeyValueObservingOptions.new, context: nil)
    device.connectAsync().success { _ in
      NSLog("We are connected!")
    }
    
    if device.accelerometer is MBLAccelerometerBMI160 {
      accelerometerBMI160 = device.accelerometer as! MBLAccelerometerBMI160
      accelerometerBMI160.sampleFrequency = 100
      accelerometerBMI160.fullScaleRange = MBLAccelerometerBoschRange.range4G
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    device.removeObserver(self, forKeyPath: "state")
    device.disconnectAsync()
  }
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    OperationQueue.main.addOperation {
      switch (self.device.state) {
      case .connected:
        self.deviceStatus.text = "Connected"
      case .connecting:
        self.deviceStatus.text = "Connecting"
      case .disconnected:
        self.deviceStatus.text = "Disconnected"
      case .disconnecting:
        self.deviceStatus.text = "Disconnecting"
      case .discovery:
        self.deviceStatus.text = "Discovery"
      }
    }
  }
  
  @IBAction func startAccelerometer(sender: UIButton) {
    if accelerometerBMI160 != nil {
      self.stepEvent = accelerometerBMI160.stepEvent
      stepEvent.startNotificationsAsync {(data: AnyObject?, error: Error?) -> Void in
        if let steps = data as? MBLNumericData {
          self.accelerometerData.add(steps)
          self.steps += 1
          NSLog("Total steps taken: %d", self.steps)
          self.stepCount.text = NSString(format: "%d", self.steps) as String
        }
      }
    }
  }
  
  @IBAction func stopAccelerometer(sender: UIButton) {
    stepEvent.stopNotificationsAsync()
    self.stepCount.text = "---"
  }
}
