//
//  ScanTableViewController.swift
//  ios-DevNexus
//
//  Created by Marlene Jaeckel.
//  Copyright © 2017 Polyglot Programming. All rights reserved.
//

import Foundation
import MetaWear
import MBProgressHUD

protocol ScanTableViewControllerDelegate {
  func scanTableViewController(_ controller: ScanTableViewController, didSelectDevice device: MBLMetaWear)
}

class ScanTableViewController: UITableViewController {
  var delegate: ScanTableViewControllerDelegate?
  var devices: [MBLMetaWear]?
  var selected: MBLMetaWear?
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated);
    
    MBLMetaWearManager.shared().startScan(forMetaWearsAllowDuplicates: true) { array in
      self.devices = array as? [MBLMetaWear]
      self.tableView.reloadData()
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    MBLMetaWearManager.shared().stopScan()
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let count = devices?.count {
      return count
    }
    return 0
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "MetaWearCell", for: indexPath)
    
    if let currentCell = devices?[indexPath.row] {
      let name = cell.viewWithTag(1) as! UILabel
      name.text = currentCell.name
      
      let uuid = cell.viewWithTag(2) as! UILabel
      uuid.text = currentCell.identifier.uuidString
      
      if let rssiNumber = currentCell.discoveryTimeRSSI {
        let rssi = cell.viewWithTag(3) as! UILabel
        rssi.text = rssiNumber.stringValue
      }
    }
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    if let selected = devices?[indexPath.row] {
      let hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
      hud.label.text = "Connecting..."
      
      self.selected = selected
      selected.connect(withTimeoutAsync: 15).success { _ in
        hud.hide(animated: true)
        selected.led?.flashColorAsync(UIColor.green, withIntensity: 1.0)
        
        let alert = UIAlertController(title: "Confirm Device", message: "Do you see a blinking green LED on the MetaWear?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction) -> Void in
          selected.led?.setLEDOnAsync(false, withOptions: 1)
          selected.disconnectAsync()
        }))
        alert.addAction(UIAlertAction(title: "Yes!", style: .default, handler: { (action: UIAlertAction) -> Void in
          selected.led?.setLEDOnAsync(false, withOptions: 1)
          selected.disconnectAsync()
          if let delegate = self.delegate {
            delegate.scanTableViewController(self, didSelectDevice: selected)
          }
        }))
        self.present(alert, animated: true, completion: nil)
        }.failure { error in
          hud.label.text = error.localizedDescription
          hud.hide(animated: true, afterDelay: 2.0)
      }
    }
  }
}
