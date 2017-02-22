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
  @IBOutlet weak var xAxis: UILabel!
  @IBOutlet weak var yAxis: UILabel!
  @IBOutlet weak var zAxis: UILabel!
  @IBOutlet weak var readThermistor: UIButton!
  @IBOutlet weak var clearThermistor: UIButton!
  @IBOutlet weak var temperature: UILabel!
  
  var device: MBLMetaWear!
  
  var accelerometerMMA8452Q: MBLAccelerometerMMA8452Q!
  var stepEvent: MBLEvent<MBLAccelerometerData>!
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    device.addObserver(self, forKeyPath: "state", options: NSKeyValueObservingOptions.new, context: nil)
    device.connectAsync().success { _ in
      NSLog("We are connected!")
    }
    
    if device.accelerometer is MBLAccelerometerMMA8452Q {
      accelerometerMMA8452Q = device.accelerometer as! MBLAccelerometerMMA8452Q
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
    self.startAccelerometer.isEnabled = false
    self.stopAccelerometer.isEnabled = true
    
    if ((accelerometerMMA8452Q) != nil) {
      accelerometerMMA8452Q.sampleFrequency = 100
      accelerometerMMA8452Q.fullScaleRange = MBLAccelerometerRange.range4G
      accelerometerMMA8452Q.highPassCutoffFreq = MBLAccelerometerCutoffFreq.higheset
      accelerometerMMA8452Q.highPassFilter = true
      accelerometerMMA8452Q.lowNoise = true
      
      self.stepEvent = accelerometerMMA8452Q.dataReadyEvent
      stepEvent.startNotificationsAsync {(data: MBLAccelerometerData?, error: Error?) -> Void in
        if let axisData = data {
          NSLog("X = %f, Y = %f, Z = %f", axisData.x, axisData.y, axisData.z)
          self.xAxis.text = NSString(format:"%d", axisData.x) as String
          self.yAxis.text = NSString(format:"%d", axisData.y) as String
          self.zAxis.text = NSString(format:"%d", axisData.z) as String
        }
      }
    }
  }
  
  @IBAction func stopAccelerometer(sender: UIButton) {
    stepEvent.stopNotificationsAsync()
    self.xAxis.text = "---"
    self.yAxis.text = "---"
    self.zAxis.text = "---"
  }
  
  @IBAction func readTemperature(sender: UIButton) {
    let selected = device.temperature!.onDieThermistor
    selected.readAsync().success { result in
      NSLog("Temperature = %f", result.value.floatValue)
      self.temperature.text = result.value.stringValue.appending("°C")
    }
  }
  
  @IBAction func clearTemperature(sender: UIButton) {
    self.temperature.text = "---°C"
  }
}
