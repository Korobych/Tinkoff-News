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
        counterLabel.text = String(counter)
        if isViewed {
            // Logic with fading already seen posts
            UIView.animate(withDuration: 0.5, animations: {
                self.postTitle.alpha = 0.3
            })
        }
        else{
            self.postTitle.alpha = 1
        }
    }
}
