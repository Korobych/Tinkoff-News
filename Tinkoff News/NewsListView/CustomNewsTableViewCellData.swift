//
//  CustomNewsTableViewCellData.swift
//  Tinkoff News
//
//  Created by Sergey Korobin on 26.12.17.
//  Copyright © 2017 SergeyKorobin. All rights reserved.
//

import Foundation

protocol NewsListCellProtocol: class{
    var id: Int? {get set}
    var title: String? {get set}
    var content: String? {get set}
    var publicationDate: String? {get set}
    var counter: Int? {get set}
    var isViewed: Bool {get set}
}

class CustomNewsTableViewCellData : NewsListCellProtocol{
    var id: Int?
    var title: String?
    var content: String?
    var publicationDate: String?
    var counter: Int?
    var isViewed: Bool
    
    init(id: Int?, title: String?, content: String?, publicationDate: Int?, counter: Int? = 0, isViewed: Bool = false)
    {
        self.id = id
        self.title = title
        self.content = content
        self.counter = counter
        self.isViewed = isViewed
        
        if let publicationDate = publicationDate {
            self.publicationDate = publicationDate.makeMilisecToDate(timeInMillisec: publicationDate)
        }
        else
        {
            let date = "Date not stayed"
            self.publicationDate = date
        }
    }
}

extension Int{
    func makeMilisecToDate(timeInMillisec: Int) -> String
    {
        let timeInterval = Date(timeIntervalSince1970: (TimeInterval(timeInMillisec / 1000)))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
        return dateFormatter.string(from: timeInterval)
    }
}
