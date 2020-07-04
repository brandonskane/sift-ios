//
//  AppTableViewCell.swift
//  Sift
//
//  Created by Brandon Kane on 6/11/20.
//  Copyright © 2020 Brandon Kane. All rights reserved.
//

import UIKit

class AppTableViewCell: UITableViewCell {

    @IBOutlet var appImage: UIImageView!
    @IBOutlet var mainLabel: UILabel!
    @IBOutlet var subLabel: UILabel!
    @IBOutlet var hostCountLabel: UILabel!
    @IBOutlet var seenIndicatorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        appImage.layer.cornerRadius = appImage.frame.size.width / 2
        appImage.clipsToBounds = true
        
        seenIndicatorView.layer.cornerRadius = seenIndicatorView.frame.size.width/2
        seenIndicatorView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCellFor(app: App) {
        mainLabel.text = app.commonName
        subLabel.text = app.bundleId
        seenIndicatorView.backgroundColor = !app.seen ? AppColors.highlight.color : nil
        hostCountLabel.text = "Hosts: \(app.hosts.count)"

        let url = URL(string: "https://logo.clearbit.com/\(app.commonName).com")
        appImage.kf.setImage(with: url)
        
        appImage.kf.setImage(with: url) { (result) in
            switch result {
            case .success(let value):
                print("Task done for: \(value.source.url?.absoluteString ?? "")")
            case .failure(_):
                self.appImage.kf.setImage(with: URL(string: "https://ui-avatars.com/api/?name=\(app.commonName).com"))
            }
        }
    }

}
