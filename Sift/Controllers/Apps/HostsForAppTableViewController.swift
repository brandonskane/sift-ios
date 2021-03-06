//
//  HostsForAppTableViewController.swift
//  Sift
//
//  Created by Brandon Kane on 6/7/20.
//  Copyright © 2020 Brandon Kane. All rights reserved.
//

import UIKit
import RealmSwift

class HostsForAppTableViewController: UITableViewController {
    
    var notificationToken: NotificationToken? = nil
    var realm : Realm!
    var results: List<Host>!
    var bundleId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    func configure() {
        realm = try! Realm()
        let app = realm.objects(App.self).filter("bundleId = '\(bundleId!)'").first!
        results = app.hosts
        title = app.commonName
        
        notificationToken = results.observe { [weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.tableView else { return }
            switch changes {
            case .initial:
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                tableView.beginUpdates()
                tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                     with: .automatic)
                tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.endUpdates()
            case .error(let error):
                fatalError("\(error)")
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "hostCell", for: indexPath)

        cell.textLabel?.text = results[indexPath.row].hostname
        cell.detailTextLabel?.text = results[indexPath.row].isAllowed ? "✅" : "❌"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let host = results[indexPath.row]

        if host.isAllowed {
            let blockAction = UIContextualAction(style: .normal, title: "Block", handler: { (action, view, success) in
                Database.shared.markHostAsBlocked(host: host)
                Database.shared.markHostAsEvaulated(host: host)
                success(true)
            })

            blockAction.backgroundColor = AppColors.deny.color

            let evaluateAction = UIContextualAction(style: .normal, title: "Evaulate", handler: { (action, view, success) in
                Database.shared.markHostAsEvaulated(host: host)
                success(true)
            })

            evaluateAction.backgroundColor = AppColors.allow.color

            return UISwipeActionsConfiguration(actions: [blockAction, evaluateAction])

        } else {
            let unblockAction = UIContextualAction(style: .normal, title: "Unblock", handler: { (action, view, success) in
                Database.shared.markHostAsUnblocked(host: host)
                success(true)
            })
            unblockAction.backgroundColor = AppColors.allow.color
            return UISwipeActionsConfiguration(actions: [unblockAction])
        }
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
