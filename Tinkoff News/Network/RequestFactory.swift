//
//  RequestFactory.swift
//  Tinkoff News
//
//  Created by Sergey Korobin on 26.12.17.
//  Copyright © 2017 SergeyKorobin. All rights reserved.
//

import Foundation

// Struct of RequestConfigurator
struct RequestConfig<Model, Parser: ParserProtocol> where Parser.Model == Model {
    let request: RequestProtocol
    let parser: Parser
}

class RequestsFactory {
    
    struct GetNewsFromAPI {
        //configuration to get list of news
        static func NewsListConfig(from: Int = 0, to: Int = 20) -> RequestConfig<[NewsListModel], NewsListParser> {
            return RequestConfig(request: NewsListRequest(from: from, to: to), parser: NewsListParser())
        }
        // configuration to get a single news post
        static func SinglePostConfig(id: Int) -> RequestConfig<SinglePostModel, SinglePostParser> {
            return RequestConfig(
                request: SinglePostRequest(id: id), parser: SinglePostParser())
        }
    }
}
