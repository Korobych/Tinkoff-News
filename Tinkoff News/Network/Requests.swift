//
//  Requests.swift
//  Tinkoff News
//
//  Created by Sergey Korobin on 26.12.17.
//  Copyright © 2017 SergeyKorobin. All rights reserved.
//

import Foundation

protocol RequestProtocol {
    var urlRequest: URLRequest? {get set}
}

class NewsListRequest : RequestProtocol {
    var urlRequest: URLRequest?
    init(from: Int = 0, to: Int = 20) {
        guard let url = URL(string: "https://api.tinkoff.ru/v1/news?first=\(from)&last=\(to)") else {
                print("Can't create url with current parameters...")
                return
            }
        urlRequest = URLRequest(url: url)
    }
}

class SinglePostRequest: RequestProtocol {
    var urlRequest: URLRequest?
    init(id: Int) {
        guard let url = URL(string: "https://api.tinkoff.ru/v1/news_content?id=\(id)") else {
            print("Can't create url with current parameters...")
            return
        }
        print(url)
        urlRequest = URLRequest(url: url)
    }
}
