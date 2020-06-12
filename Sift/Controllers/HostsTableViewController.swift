//
//  HostsTableViewController.swift
//  Sift
//
//  Created by Brandon Kane on 6/7/20.
//  Copyright © 2020 Brandon Kane. All rights reserved.
//

import UIKit
import RealmSwift
import NetworkExtension

class HostsTableViewController: UITableViewController {
    
    enum Filter {
        case evaluated, unevaluated, blocked, unblocked, apps
    }

    var notificationToken: NotificationToken? = nil
    
    var realm : Realm!
    var results: Results<Host>!
    var evaluatedOnly = false
    
    @IBOutlet var filterEnabledSwitch: UISwitch! {
        didSet {
            NEFilterManager.shared().loadFromPreferences { error in
                if let _ = error {
                    self.filterEnabledSwitch.isOn = false
                    return
                }
                self.filterEnabledSwitch.isOn = NEFilterManager.shared().isEnabled
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkForOnboarding()
        navigationController?.navigationBar.prefersLargeTitles = true
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        filterEnabledSwitch.isOn = NEFilterManager.shared().isEnabled
    }
    
    func configure() {
        realm = try! Realm()
        results = realm.objects(Host.self)
        if evaluatedOnly {
            results = results.filter("evaulated = true")
        }
        
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
    
    deinit {
        notificationToken?.invalidate()
    }
    
    func updateFilter() {
        notificationToken?.invalidate()
        evaluatedOnly = !evaluatedOnly
        configure()
        shareSheet()
    }
    
    func filterOptions() {
        let actionSheet = UIAlertController(title: "Filter", message: "Filter Options", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Evaluated", style: .default, handler: { (action) in
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Blocked", style: .default, handler: { (alert) in
            
        }))
    }
    
    func shareSheet() {
        let defaultRealm = FileManager.default
        .containerURL(forSecurityApplicationGroupIdentifier: Constants.appGroupIdentifier)!
        .appendingPathComponent("data/default.realm")

        let activityViewController = UIActivityViewController(activityItems: [defaultRealm] , applicationActivities: nil)

        DispatchQueue.main.async {
            self.present(activityViewController, animated: true, completion: nil)
        }            
    }
    
    @IBAction func updateFilter(_ sender: Any) {
        updateFilter()
    }
    

    @IBAction func filterToggle(_ sender: UISwitch) {
        sender.isOn ? enable() : disable()
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        let host = results[indexPath.row]
        cell.textLabel?.text = host.hostname
        let allowedString = host.isAllowed ? "✅" : "❌"
        let evaluatedStrig = host.evaulated ? "👍" : "🤷🏻‍♂️"
        let category = host.category != nil ? host.category! : "-"
        let appsCounted = host.apps.count > 0 ? " -- A: \(host.apps.count)" : ""
        cell.detailTextLabel?.text = "\(allowedString) -- \(evaluatedStrig) -- \(category)\(appsCounted)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let host = results[indexPath.row]
//        guard !host.allowedApps.isEmpty && host.blockedApps.isEmpty else { return(print("No Apps")) }
        guard !host.apps.isEmpty else { return (print("no apps"))}
        performSegue(withIdentifier: "showAppsForHost", sender: self)
    }
    
//    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let host = results[indexPath.row]
//
//        if host.isAllowed {
//            let blockAction = UIContextualAction(style: .normal, title: "Block", handler: { (action, view, success) in
//                Database.shared.markHostAsBlocked(host: host)
//                Database.shared.markHostAsEvaulated(host: host)
//            })
//
//            blockAction.backgroundColor = AppColors.deny.color
//
//            let evaluateAction = UIContextualAction(style: .normal, title: "Evaulate", handler: { (action, view, success) in
//                Database.shared.markHostAsEvaulated(host: host)
//            })
//
//            evaluateAction.backgroundColor = AppColors.allow.color
//
//            return UISwipeActionsConfiguration(actions: [blockAction, evaluateAction])
//
//        } else {
//            let unblockAction = UIContextualAction(style: .normal, title: "Unblock", handler: { (action, view, success) in
//                Database.shared.markHostAsUnblocked(host: host)
//            })
//            unblockAction.backgroundColor = AppColors.allow.color
//            return UISwipeActionsConfiguration(actions: [unblockAction])
//        }
//
//    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let host = results[indexPath.row]

        var actions: [UITableViewRowAction] = []

        if host.isAllowed {
            let blockAction = UITableViewRowAction(style: UITableViewRowAction.Style.default, title: "Block", handler: { (action, indexPath) in
                Database.shared.markHostAsBlocked(host: host)
//                Database.shared.markHostAsEvaulated(host: host)
            })

            blockAction.backgroundColor = AppColors.deny.color
            actions.append(blockAction)

            let evaulateAction = UITableViewRowAction(style: UITableViewRowAction.Style.default, title: "Evaulate", handler: { (action, indexPath) in
                Database.shared.markHostAsEvaulated(host: host)
            })

            evaulateAction.backgroundColor = AppColors.allow.color
            actions.append(evaulateAction)
        } else {
            let unblockAction = UITableViewRowAction(style: UITableViewRowAction.Style.default, title: "Unblock", handler: { (action, indexPath) in
                Database.shared.markHostAsUnblocked(host: host)
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


    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAppsForHost" {
            let destinationController = segue.destination as! IndividualHostTableViewController
            
            let host = results[tableView.indexPathForSelectedRow!.row]
            destinationController.allowedApps = host.allowedApps
            destinationController.blockedApps = host.blockedApps
            destinationController.host = host
        }
    }

}

extension HostsTableViewController {
    
    func checkForOnboarding() {
        if !UserDefaults.standard.bool(forKey: Constants.onboardingKey) {
            showOnboarding()
        }
    }
    
    func showOnboarding() {
        DispatchQueue.main.async {
            let onboardingController = Storyboard.Onboarding.instantiateInitialViewController()!
            self.present(onboardingController, animated: true, completion: nil)
        }
    }
    
    func enable() {
        if NEFilterManager.shared().providerConfiguration == nil {
            let newConfiguration = NEFilterProviderConfiguration()
            newConfiguration.username = "Sift"
            newConfiguration.organization = "Sift App"
            newConfiguration.filterBrowsers = true
            newConfiguration.filterSockets = true
            NEFilterManager.shared().providerConfiguration = newConfiguration
        }

        NEFilterManager.shared().isEnabled = true
        NEFilterManager.shared().saveToPreferences { error in
            if let err = error {
                self.showWarning(title: "Error Enabling Filter", body: "\(err)")
            }
        }
    }
    
    func disable() {
        NEFilterManager.shared().isEnabled = false
        NEFilterManager.shared().saveToPreferences { error in
            if let err = error {
                self.showWarning(title: "Error Disabling Filter", body: "\(err)")
            }
        }
    }
}
