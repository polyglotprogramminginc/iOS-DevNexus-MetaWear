//
//  MainTableViewController.swift
//  ios-DevNexus
//
//  Created by Marlene Jaeckel.
//  Copyright © 2017 Polyglot Programming. All rights reserved.
//

import Foundation
import MetaWear

class MainTableViewController: UITableViewController, ScanTableViewControllerDelegate {
  var devices: [MBLMetaWear]?
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated);
    
    MBLMetaWearManager.shared().retrieveSavedMetaWearsAsync().success { (array) in
      if let deviceArray = array as? [MBLMetaWear] {
        if deviceArray.count > 0 {
          self.devices = deviceArray
        } else {
          self.devices = nil
        }
      } else {
        self.devices = nil
      }
      self.tableView.reloadData()
    }
  }
  
  func scanTableViewController(_ controller: ScanTableViewController, didSelectDevice device: MBLMetaWear) {
    device.rememberDevice()
    
    _ = navigationController?.popViewController(animated: true)
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let count = devices?.count {
      return count
    }
    return 1
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var cell: UITableViewCell!
    if devices == nil {
      cell = tableView.dequeueReusableCell(withIdentifier: "NoDeviceCell", for: indexPath)
    } else {
      cell = tableView.dequeueReusableCell(withIdentifier: "MetaWearCell", for: indexPath)
      if let currentCell = devices?[indexPath.row] {
        let name = cell.viewWithTag(1) as! UILabel
        name.text = currentCell.name
        
        let uuid = cell.viewWithTag(2) as! UILabel
        uuid.text = currentCell.identifier.uuidString
      }
    }
    return cell
  }
  
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    if let currentCell = devices?[indexPath.row] {
      performSegue(withIdentifier: "ViewDevice", sender: currentCell)
    } else {
      performSegue(withIdentifier: "AddNewDevice", sender: nil)
    }
  }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return devices != nil
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      if let currentCell = devices?[indexPath.row] {
        currentCell.forgetDevice()
        devices?.remove(at: indexPath.row)
        
        if devices?.count != 0 {
          tableView.deleteRows(at: [indexPath], with: .automatic)
        } else {
          devices = nil
          tableView.reloadRows(at: [indexPath], with: .automatic)
        }
      }
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let scanController = segue.destination as? ScanTableViewController {
      scanController.delegate = self
    } else if let deviceController = segue.destination as? DeviceViewController {
      deviceController.device = sender as! MBLMetaWear
    }
  }
}

