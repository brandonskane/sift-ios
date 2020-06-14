//
//  IndividualHostTableViewController.swift
//  Sift
//
//  Created by Brandon Kane on 6/7/20.
//  Copyright © 2020 Brandon Kane. All rights reserved.
//

import UIKit
import RealmSwift

class IndividualHostTableViewController: UITableViewController {

    var allowedApps: List<App>!
    var blockedApps: List<App>!
    var host: Host!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = host.hostname
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Apps"
        } else {
            return "Blocked Apps"
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return host.apps.count
        } else {
            return blockedApps.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "appCell", for: indexPath)

        if indexPath.section == 0 {
            cell.textLabel?.text = host.apps[indexPath.row].bundleId
        } else {
            cell.textLabel?.text = blockedApps[indexPath.row].bundleId
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        var actions: [UITableViewRowAction] = []
        
        if indexPath.section == 0 {
            let blockAction = UITableViewRowAction(style: UITableViewRowAction.Style.default, title: "Block", handler: { (action, indexPath) in
            })
            
            blockAction.backgroundColor = AppColors.deny.color
            actions.append(blockAction)
        } else {
            let unblockAction = UITableViewRowAction(style: UITableViewRowAction.Style.default, title: "Unblock", handler: { (action, indexPath) in
            })
            
            unblockAction.backgroundColor = AppColors.allow.color
            actions.append(unblockAction)
        }
        
        return actions
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
