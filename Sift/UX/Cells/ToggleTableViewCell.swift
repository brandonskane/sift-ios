//
//  ToggleTableViewCell.swift
//  Sift
//
//  Created by Brandon Kane on 6/14/20.
//  Copyright © 2020 Brandon Kane. All rights reserved.
//

import UIKit

protocol ToggleTableViewCellProtocol: class {
    func didToggle(enabled: Bool)
}

class ToggleTableViewCell: UITableViewCell {

    @IBOutlet var toggleSwitch: UISwitch!
    @IBOutlet var toggleLabel: UILabel!
    
    weak var delegate: ToggleTableViewCellProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
        
    func configureCell(label: String, enabled: Bool? = nil) {
        if let enabled = enabled {
            toggleSwitch.isHidden = false
            toggleSwitch.isOn = enabled
            toggleLabel.textColor = .black
            selectionStyle = .none
        } else {
            toggleSwitch.isHidden = true
            toggleLabel.textColor = .blue
            selectionStyle = .default
        }
        
        toggleLabel.text = label
    }
    
    @IBAction func didToggleSwitch(_ sender: UISwitch) {
        delegate?.didToggle(enabled: sender.isOn)
    }
}
