//
//  RequestSender.swift
//  Tinkoff News
//
//  Created by Sergey Korobin on 26.12.17.
//  Copyright © 2017 SergeyKorobin. All rights reserved.
//

import Foundation

enum Result<T> {
    case success(T)
    case error(String)
}

protocol RequestSenderProtocol {
    func send<Model, Parser>(config: RequestConfig<Model, Parser>, completionHandler: @escaping (Result<Model>) -> Void )
}

class RequestSender: RequestSenderProtocol {
    
    let session = URLSession.shared
    let queue: DispatchQoS.QoSClass = .userInitiated
    var async: Bool
    
    init() {
        self.async = true
    }
    
    
    func send<ModelType, Parser>(config: RequestConfig<ModelType, Parser>, completionHandler: @escaping (Result<ModelType>) -> Void) {
        
        guard let urlRequest = config.request.urlRequest else {
            completionHandler(Result.error("URL string can't be parsed to URL"))
            return
        }
        
        let task = session.dataTask(with: urlRequest) { (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                completionHandler(Result.error(error.localizedDescription))
                return
            }
            guard let data = data, let parsedModel = config.parser.parse(data: data) else {
                completionHandler(Result.error("Received data can not be parsed"))
                return
            }
            
            completionHandler(Result.success(parsedModel))
        }
        
        if async == true {
            let queue = self.queue
            DispatchQueue.global(qos: queue).async {
                task.resume()
            }
        }
    }
}
