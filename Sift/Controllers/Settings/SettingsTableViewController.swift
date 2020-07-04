//
//  SettingsTableViewController.swift
//  Sift
//
//  Created by Brandon Kane on 6/14/20.
//  Copyright © 2020 Brandon Kane. All rights reserved.
//

import UIKit
import MobileCoreServices

class SettingsTableViewController: UITableViewController {
    
    enum SettingsFilter: Int {
        case substringMatching
        case captureModeOnly
        
        var settingTitle: String {
            switch self {
            case .substringMatching: return "Substring Match"
            case .captureModeOnly: return "Capture Mode Only"
            }
        }
        
        static var section: Int { return 0 }
        static var count: Int { return 2 }
        static var title: String { return "Filter Settings" }
    }
    
    enum OneTimeOperation: Int {
        case remove
        
        var settingTitle: String {
            switch self {
            case .remove: return "Remove"
            }
        }
            
        static var section: Int { return 1 }
        static var count: Int { return 1 }
        static var title: String { return "One Time Operations" }
    }
    
    enum DatabaseSetting: Int {
        case shareDatabase
        case restoreDatabase
        
        var settingTitle: String {
            switch self {
            case .shareDatabase: return "Save Database"
            case .restoreDatabase: return "Load Database"
            }
        }
        
        static var section: Int { return 2 }
        static var count: Int { return 2 }
        static var title: String { return "Database" }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func registerCell() {
        let cell = UINib(nibName: "ToggleTableViewCell",
                            bundle: nil)
        self.tableView.register(cell,
                                forCellReuseIdentifier: "ToggleTableViewCell")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case SettingsFilter.section:
            return SettingsFilter.title
        case OneTimeOperation.section:
            return OneTimeOperation.title
        case DatabaseSetting.section:
            return DatabaseSetting.title
        default:
            fatalError()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SettingsFilter.section:
            return SettingsFilter.count
        case OneTimeOperation.section:
            return OneTimeOperation.count
        case DatabaseSetting.section:
            return DatabaseSetting.count
        default:
            fatalError()
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToggleTableViewCell", for: indexPath) as! ToggleTableViewCell
        switch indexPath.section {
        case SettingsFilter.section:
            let setting = SettingsFilter(rawValue: indexPath.row)!
            cell.configureCell(label: setting.settingTitle, enabled: true)
            cell.delegate = self
            return cell
        case OneTimeOperation.section:
            let setting = OneTimeOperation(rawValue: indexPath.row)!
            cell.configureCell(label: setting.settingTitle, enabled: true)
            cell.delegate = self
            return cell
        case DatabaseSetting.section:
            let setting = DatabaseSetting(rawValue: indexPath.row)!
            cell.configureCell(label: setting.settingTitle)
            cell.delegate = self
            return cell
        default:
            fatalError()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.section == DatabaseSetting.section else { return }
        switch indexPath.row {
        case DatabaseSetting.shareDatabase.rawValue:
            shareSheet()
        case DatabaseSetting.restoreDatabase.rawValue:
            importFile()
        default: break
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

extension SettingsTableViewController {
    func shareSheet() {
        let defaultRealm = FileManager.default
        .containerURL(forSecurityApplicationGroupIdentifier: Constants.appGroupIdentifier)!
        .appendingPathComponent("data/default.realm")

        let activityViewController = UIActivityViewController(activityItems: [defaultRealm],
                                                              applicationActivities: nil)

        present(activityViewController, animated: true, completion: nil)
    }
    
    func importFile() {
        let documentPickerController = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .import)
        
        documentPickerController.delegate = self
        present(documentPickerController, animated: true, completion: nil)
    }
}

extension SettingsTableViewController: ToggleTableViewCellProtocol {
    func didToggle(enabled: Bool) {
        
    }
}

extension SettingsTableViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        print("selected file url \(url)")
    }
}
