//
//  SinglePostParser.swift
//  Tinkoff News
//
//  Created by Sergey Korobin on 26.12.17.
//  Copyright © 2017 SergeyKorobin. All rights reserved.
//

import Foundation

struct SinglePostModel {
    let postText: String
    let modificatedTime: Int
}

class SinglePostParser: ParserProtocol {
    
    typealias model = SinglePostModel
    
    func parse(data: Data) -> SinglePostModel? {
        do {
            
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] else {
                return nil
            }
            
            guard let checker = json["resultCode"] as? String else {
                return nil
            }
//            CHECKING FUNCTIONALITY
//            request success flag - value should be = OK
            print(checker)
//
            guard let item = json["payload"] as? [String: AnyObject] else {
                return nil
            }
            
            guard let lastModificationDate = item["lastModificationDate"] as? [String:AnyObject],
                let dateInMillisec = lastModificationDate["milliseconds"] as? Int
                else {
                    print("Post isn't modificated. -_-")
                    return nil
                }
            
            guard let content = item["content"] as? String else {
                print("Post hasn't content at all. -_-")
                return nil
            }
            
            return SinglePostModel(postText: content, modificatedTime: dateInMillisec)
        }
        catch
        {
            print("Can't get data from JSON\n\(error)")
            return nil
        }
        
    }
}
