//
//  NetworkingService.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/6/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation
import Alamofire


internal protocol NetworkingService {

    var sessionManager: SessionManager { get }
    var baseURL: URL { get }

    func buildURL(handle: String?, path: String?, extra: String?, queryItems: [URLQueryItem]?, security: Security?) -> URL?
}

extension NetworkingService {

    func buildURL(handle: String? = nil,
                  path: String? = nil,
                  extra: String? = nil,
                  queryItems: [URLQueryItem]? = nil,
                  security: Security? = nil) -> URL? {

        var url = baseURL

        if let path = path {
            url.appendPathComponent(path)
        }

        if let handle = handle {
            url.appendPathComponent(handle)
        }

        if let extra = extra {
            url.appendPathComponent(extra)
        }

        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }

        urlComponents.queryItems = queryItems

        if let security = security {
            if urlComponents.queryItems == nil {
                urlComponents.queryItems = []
            }

            urlComponents.queryItems?.append(URLQueryItem(name: "policy", value: security.encodedPolicy))
            urlComponents.queryItems?.append(URLQueryItem(name: "signature", value: security.signature))
        }

        return try? urlComponents.asURL()
    }

    func request(url: URL, method: HTTPMethod, parameters: [String: Any]? = nil, headers: HTTPHeaders? = nil) -> DataRequest? {

        return sessionManager.request(url, method: method, parameters: parameters, headers: headers)
    }
}
