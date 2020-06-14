//
//  AppsTableViewController.swift
//  Sift
//
//  Created by Brandon Kane on 6/7/20.
//  Copyright © 2020 Brandon Kane. All rights reserved.
//

import UIKit
import RealmSwift
import Kingfisher

class AppsTableViewController: UITableViewController {
    
    let searchController = UISearchController(searchResultsController: nil)
    var notificationToken: NotificationToken? = nil
    
    var realm : Realm!
    var results: Results<App>!
    var predicate: NSPredicate?

    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        navigationItem.searchController = searchController
        navigationController?.navigationBar.prefersLargeTitles = true
        configure()
    }
    
    func configure() {
        realm = try! Realm()
        results = realm.objects(App.self).sorted(byKeyPath: "commonName", ascending: true)
        
        if let predicate = predicate {
            results = results.filter(predicate)
        }
        
        notificationToken = results.observe { [weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.tableView else { return }
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the UITableView
                tableView.beginUpdates()
                // Always apply updates in the following order: deletions, insertions, then modifications.
                // Handling insertions before deletions may result in unexpected behavior.
                tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                     with: .automatic)
                tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.endUpdates()
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "appCell", for: indexPath) as! AppTableViewCell

        let app = results[indexPath.row]
        cell.configureCellFor(app: app)
        
        return cell
    }
    
        override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

            let app = results[indexPath.row]

            var actions: [UITableViewRowAction] = []
            
            let edit = UITableViewRowAction(style: UITableViewRowAction.Style.default, title: "Edit Common Name", handler: { (action, indexPath) in
                
                let alertController =  UIAlertController(title: "Update Common Name", message: "Update the common name for this application", preferredStyle: .alert)
                
                alertController.addTextField { (textField : UITextField!) -> Void in
                    textField.placeholder = "New Common Name"
                }
                
                alertController.addAction(UIAlertAction(title: "Reset", style: .default, handler: { (alert) in
                    Database.shared.updateCommonNameFor(app: app)
                }))
                
                alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: { (alert) in
                    let text = alertController.textFields![0].text!
                    Database.shared.updateCommonNameFor(app: app, commonName: text)
                    
                }))
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
            })

            edit.backgroundColor = AppColors.allow.color
            actions.append(edit)

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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "hostsForApp" {
            let destinationController = segue.destination as! HostsForAppTableViewController
            let app = results[tableView.indexPathForSelectedRow!.row]
            destinationController.bundleId = app.bundleId
        }
    }
    

}

extension AppsTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, text.count > 0 {
            predicate = NSPredicate(format: "bundleId contains '\(text.lowercased())'")
            updateFilter()
        } else {
            predicate = nil
            updateFilter()
        }
    }
    
    func updateFilter() {
        notificationToken?.invalidate()
        configure()
    }
}
