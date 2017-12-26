//
//  CustomNewsTableViewCell.swift
//  Tinkoff News
//
//  Created by Sergey Korobin on 26.12.17.
//  Copyright © 2017 SergeyKorobin. All rights reserved.
//

import UIKit

class CustomNewsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    
    func setupCell(title: String?, counter: Int = 0, isViewed: Bool = false) {
        postTitle.text = title
        counterLabel.text = String(counter) + " кликов"
        if isViewed {
            // Logic with fading already seen posts
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
