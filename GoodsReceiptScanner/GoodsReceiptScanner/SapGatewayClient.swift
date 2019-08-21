//
//  SapApiClient.swift
//  GoodsReceiptScanner
//
//  Copyright © 2019 Michael Schermann. All rights reserved.
//

import Foundation

typealias XCSRFToken = String
typealias Endpoint = String
typealias SapQueryItems = [URLQueryItem]
typealias SapQueryItem = URLQueryItem



final class SapGatewayClient {
    
    public static let shared = SapGatewayClient()
    
    private init() { }
    
    private enum HttpMethod: String {
        case get = "GET"
        case post = "POST"
    }
    
    private var baseUrl: URLComponents {
        
        var urlComponents = URLComponents()
        urlComponents.scheme = SapGatewayClientConstants.gatewayProtocol
        urlComponents.host = SapGatewayClientConstants.baseUrl
        urlComponents.port = SapGatewayClientConstants.basePort
//      https://blogs.sap.com/2017/08/29/defaulting-odata-response-in-json-format/
        urlComponents.queryItems = [URLQueryItem(name: ConstantQueryHeaders.sapClient.rawValue,
                                                 value: ConstantQueryHeaders.sapClient.description)]
        return urlComponents
        
    }
    
    private var basicAuthHeader: String {
        
        guard let credentials = String(format: "%@:%@",
                                 SapGatewayClientConstants.user,
                                 SapGatewayClientConstants.password).data(using: String.Encoding.utf8) else {
                                    return ""
        }
        return "Basic \(credentials.base64EncodedString())"
        
    }
    
    private func getAuthorizedRequest(url: URL, using httpMethod: HttpMethod) -> URLRequest {
        
        var request = URLRequest(url: url)
        
        request.httpMethod = httpMethod.rawValue
        request.setValue(self.basicAuthHeader,
                         forHTTPHeaderField: ConfigurableQueryHeaders.authorization.rawValue)
        
        return request
        
    }
    
    private func getUrlForEndpoint(endpoint: Endpoint, using method: HttpMethod, queryItems: SapQueryItems? = nil) -> URL {
        
        var url = baseUrl
        
        if method == HttpMethod.get {
            url.queryItems?.append(URLQueryItem(name: ConstantQueryHeaders.json.rawValue,
                                                value: ConstantQueryHeaders.json.description))
        }
        
        url.path = SapGatewayClientConstants.path + endpoint
        
        if (queryItems != nil) {
            queryItems?.forEach { (item: URLQueryItem) in
                url.queryItems?.append(item)
            }
        }
        
        url.percentEncodedQuery = url.percentEncodedQuery?.replacingOccurrences(of: ",", with: "%2c").replacingOccurrences(of: "/", with: "%2F").replacingOccurrences(of: "'", with: "%27")
        
        print(url.url!)
        return url.url!
        
    }
    
    func get(endpoint: Endpoint, queryItems: SapQueryItems? = nil, completion: @escaping (SapGatewayClientResponse) -> Void) {
        
        let url = self.getUrlForEndpoint(endpoint: endpoint, using: HttpMethod.get, queryItems: queryItems)
        
        let request = self.getAuthorizedRequest(url: url, using: HttpMethod.get)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in

            if let error = error {
                completion(SapGatewayClientResponse(responseStatus: SapGatewayClientMessages.unknownError, error: error))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(SapGatewayClientResponse(responseStatus: SapGatewayClientMessages.invalidResponse))
                return
            }

            guard (200...202).contains(response.statusCode) else{
                completion(SapGatewayClientResponse(responseStatus: SapGatewayClientMessages.serverError, httpStatusCode: response.statusCode))
                return
            }
            
            if let sapMessage: String = response.allHeaderFields[ConfigurableQueryHeaders.sapMessage.rawValue] as? String {
        
                do {
                    let decoder = JSONDecoder()
                    let message:SapGatewayClientMessage = try decoder.decode(SapGatewayClientMessage.self,
                                                                from: sapMessage.data(using: String.Encoding.utf8)!)
                    completion(SapGatewayClientResponse(responseStatus: SapGatewayClientMessages.message, message: message))
                } catch let error {
                    print("\(error)")
                }
            }
            
            completion(SapGatewayClientResponse(responseStatus: SapGatewayClientMessages.success, data: data))

        }

        task.resume()
        
    }
    
    private enum SapGatewayEndpoints: String {
        case token = "/MMIM_GR4PO_DL_SRV/"
    }
    
    private func getXCSRFToken(completion: @escaping (XCSRFTokenResponse) -> Void) {
        
        let url = self.getUrlForEndpoint(endpoint: SapGatewayEndpoints.token.rawValue, using: HttpMethod.get)
        
        var request = self.getAuthorizedRequest(url: url, using: HttpMethod.get)
        
        request.setValue(ConstantQueryHeaders.xcsrTokenFetch.description,
                         forHTTPHeaderField: ConstantQueryHeaders.xcsrTokenFetch.rawValue)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                completion(XCSRFTokenResponse(responseStatus: SapGatewayClientMessages.unknownError, error: error))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(XCSRFTokenResponse(responseStatus: SapGatewayClientMessages.invalidResponse))
                return
            }
            
            guard (200...202).contains(response.statusCode) else{
                completion(XCSRFTokenResponse(responseStatus: SapGatewayClientMessages.invalidResponse, httpStatusCode: response.statusCode))
                return
            }
            
            guard let xcsrfToken: XCSRFToken = response.allHeaderFields[ConfigurableQueryHeaders.receivedXcsrfToken.rawValue] as? XCSRFToken else {
                completion(XCSRFTokenResponse(responseStatus: SapGatewayClientMessages.noTokenReceived))
                return
            }
            
            completion(XCSRFTokenResponse(responseStatus: SapGatewayClientMessages.tokenReceived, token: xcsrfToken))
            
        }
        
        task.resume()

    }
    
    
    func post(endpoint: Endpoint, queryItems: SapQueryItems? = nil, payload: Data, completion: @escaping (SapGatewayClientResponse) -> Void) {
        
        let url = self.getUrlForEndpoint(endpoint:endpoint, using: HttpMethod.post)
        
        var request = self.getAuthorizedRequest(url: url, using: HttpMethod.post)
        
        self.getXCSRFToken { (tokenResponse: XCSRFTokenResponse) in
            
            guard let token: XCSRFToken = tokenResponse.token else {
                completion(SapGatewayClientResponse(responseStatus: SapGatewayClientMessages.noTokenReceived))
                return
            }
            
            request.setValue(token, forHTTPHeaderField: ConfigurableQueryHeaders.receivedXcsrfToken.rawValue)
            request.setValue(ConstantQueryHeaders.jsonContentType.description,
                             forHTTPHeaderField: ConstantQueryHeaders.jsonContentType.rawValue)
            
//          https://blogs.sap.com/2017/08/29/defaulting-odata-response-in-json-format/
            request.setValue(ConstantQueryHeaders.acceptJson.description, forHTTPHeaderField: ConstantQueryHeaders.acceptJson.rawValue)
            
            request.httpBody = payload
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                if let error = error {
                    print(error)
                    completion(SapGatewayClientResponse(responseStatus: SapGatewayClientMessages.unknownError, error: error))
                    return
                }
                
                guard let response = response as? HTTPURLResponse, (200...202).contains(response.statusCode) else {
                    print("strange reponse code")
                    completion(SapGatewayClientResponse(responseStatus: SapGatewayClientMessages.serverError, data: data))
                    return
                }
                
                guard let sapMessage: String = response.allHeaderFields[ConfigurableQueryHeaders.sapMessage.rawValue] as? String else {
                    print("sap-message")
                    completion(SapGatewayClientResponse(responseStatus: SapGatewayClientMessages.notPosted))
                    return
                }
                
                do {
                    
                    let decoder = JSONDecoder()
                    let message: SapGatewayClientMessage = try decoder.decode(SapGatewayClientMessage.self, from: sapMessage.data(using: String.Encoding.utf8)!)
                    
                    print(message.message)
                    completion(SapGatewayClientResponse(responseStatus: SapGatewayClientMessages.message, message: message))
                    
                }
                catch let error {
                    completion(SapGatewayClientResponse(responseStatus: SapGatewayClientMessages.messageError, error: error))
                }
            
            }
            task.resume()

            
        }
        
    }
    
}

enum ConstantQueryHeaders: String, CustomStringConvertible {
    
    var description: String {
        switch self {
        case .sapClient: return SapGatewayClientConstants.sapClient
        case .json: return "json"
        case .xcsrTokenFetch: return "Fetch"
        case .jsonContentType: return "application/json"
        case .acceptJson: return "application/json"
        }
    }
    
    case sapClient = "sap-client"
    case json = "$format"
    case xcsrTokenFetch = "x-csrf-token"
    case jsonContentType = "Content-Type"
    case acceptJson = "Accept"

    
}

enum ConfigurableQueryHeaders: String {
    case authorization = "Authorization"
    case receivedXcsrfToken = "x-csrf-token"
    case sapMessage = "sap-message"
}

enum SapQueryItemKeys: String {
    case expand = "$expand"
    case filter = "$filter"
}

enum SapGatewayClientMessages:String {
    case success = "Successful Response"
    case message = "SAP Message received"
    case messageError = "No SAP Message received"
    case serverError = "Server Error"
    case unknownError = "Unknown Error"
    case invalidResponse = "Invalid Response"
    case noTokenReceived = "No Token Received"
    case tokenReceived = "Token Received"
    case notPosted = "No Posted"
}
