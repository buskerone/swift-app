//
//  SWAPostTableViewCell.swift
//  swift app
//
//  Created by Carlos Knopel on 3/26/20.
//  Copyright © 2020 Carlos Knopel. All rights reserved.
//

import UIKit

class SWAPostTableViewCell: UITableViewCell, SWATableViewCellProtocol {
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var postDetailsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

extension SWAPostTableViewCell {
    typealias ConfigurableObject = SWAPost
    
    func configureCell(_ object: SWAPost) {
        guard let author = object.postAuthor else {
            return
        }
        guard let date = object.postDate else {
            return
        }
        self.postTitleLabel.text = object.postTitle
        self.postDetailsLabel.text = "\(author) \(date)"
    }
}
