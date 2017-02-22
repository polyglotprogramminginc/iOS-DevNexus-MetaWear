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
  
  var device: MBLMetaWear!
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    device.addObserver(self, forKeyPath: "state", options: NSKeyValueObservingOptions.new, context: nil)
    device.connectAsync().success { _ in
      NSLog("We are connected!")
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
}
