//
//  NewsListParser.swift
//  Tinkoff News
//
//  Created by Sergey Korobin on 26.12.17.
//  Copyright © 2017 SergeyKorobin. All rights reserved.
//

import Foundation

protocol ParserProtocol {
    associatedtype Model
    func parse(data: Data) -> Model?
}

struct NewsListModel {
    let id: Int
    let text: String
    let publicationDate: Int
}

class NewsListParser: ParserProtocol {
    
    typealias model = [NewsListModel]
    var newsStorage : [NewsListModel] = []
    func parse(data: Data) -> [NewsListModel]? {
        do {
            
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] else {
                return nil
            }
            
            guard let items = json["payload"] as? [[String: AnyObject]] else {
                return nil
            }
            
            for item in items {
                guard let id = item["id"] as? String else {
                    print("Post hasn't id. -_-")
                    continue
                }
                guard let text = item["text"] as? String else {
                    print("Post hasn't main text. -_-")
                    continue
                }
                guard let publicationDate = item["publicationDate"] as? [String:AnyObject],
                let dateInMillisec = publicationDate["milliseconds"] as? Int
                    else {
                    print("Post hasn't publication date. -_-")
                    continue
                }
                guard let newID = Int(id) else { return nil }
                newsStorage.append(NewsListModel(id: newID, text: text, publicationDate: dateInMillisec))
            }
            
            return newsStorage
            
        } catch {
            print("Can't get data from JSON\n\(error)")
            return nil
        }
    }
}
