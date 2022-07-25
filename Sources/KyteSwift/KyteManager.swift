//
//  KyteService.swift
//  kyte-swift
//
//  Created by Eric Nam on 5/5/22.
//

import Foundation

class KyteManager: ObservableObject {
    static let shared: KyteManager = {
        let instance = KyteManager()
        // setup code
        return instance
    }()

    // kyte session store
    private var sessionToken:String = "0"
    private var transactionToken:String = "0"
    private var uid:String = ""
    
    init() {}
    
    func destroySession(completion: ((_ data: KyteModelDefinition<SessionData>?, _ error: KyteError?) -> Void)?) {
        let kyte = Kyte<SessionData>()
        kyte.transactionToken = self.transactionToken
        kyte.sessionToken = self.sessionToken
        
        kyte.makeRequest(httpMethod: .DELETE, model: "Session", completion: { data, error, session, token in
            self.sessionToken = session
            self.transactionToken = token
            
            if let error = error {
                completion?(nil, error)
            }
            
            if let data = data {
                completion?(data, nil)
            }
        })
        self.sessionToken = "0"
        self.transactionToken = "0"
        self.uid = ""
    }
    
    func createSession(parameters:[String:Any]?, headers:[String:String]?, completion: ((_ data: KyteModelDefinition<SessionData>?, _ error: KyteError?) -> Void)?) {
        let kyte = Kyte<SessionData>()
        kyte.transactionToken = self.transactionToken
        kyte.sessionToken = self.sessionToken
        
        kyte.makeRequest(httpMethod: .POST, model: "Session", parameters: parameters, headers: headers, completion: { data, error, session, token in
            self.sessionToken = session
            self.transactionToken = token
            
            if let error = error {
                completion?(nil, error)
            }
            
            if let data = data {
                self.uid = data.data.uid
                
                completion?(data, nil)
            }
        })
    }
    
    func post<T:Codable>(_ modelDef: T.Type, method: KyteHTTPMethods, model:String, parameters:[String:Any]?, headers:[String:String]?, completion: @escaping  (_ data: KyteModelDefinition<T>?, _ error: KyteError?) -> Void) {
        self.request(T.self, method: .POST, model: model, parameters: parameters, headers: headers, completion:{ data, error in completion(data, error)} )
    }
    func update<T:Codable>(_ modelDef: T.Type, method: KyteHTTPMethods, model:String, field: String?, value: String?, parameters:[String:Any]?, headers:[String:String]?, completion: @escaping  (_ data: KyteModelDefinition<T>?, _ error: KyteError?) -> Void) {
        self.request(T.self, method: .PUT, model: model, field: field, value: value, parameters: parameters, headers: headers, completion:{ data, error in completion(data, error)} )
    }
    func get<T:Codable>(_ modelDef: T.Type, method: KyteHTTPMethods, model:String, headers:[String:String]?, completion: @escaping  (_ data: KyteModelDefinition<T>?, _ error: KyteError?) -> Void) {
        self.request(T.self, method: .GET, model: model, field: nil, value: nil, headers: headers, completion:{ data, error in completion(data, error)} )
    }
    func delete<T:Codable>(_ modelDef: T.Type, method: KyteHTTPMethods, model:String, field: String?, value: String?, headers:[String:String]?, completion: @escaping  (_ data: KyteModelDefinition<T>?, _ error: KyteError?) -> Void) {
        self.request(T.self, method: .DELETE, model: model, field: field, value: value, headers: headers, completion:{ data, error in completion(data, error)} )
    }
    
    func request<T:Codable>(_ modelDef: T.Type, method: KyteHTTPMethods, model:String, field:String? = nil, value:String? = nil, parameters:[String:Any]? = nil, headers:[String:String]? = nil, completion: @escaping  (_ data: KyteModelDefinition<T>?, _ error: KyteError?) -> Void) {
        let kyte = Kyte<T>()
        kyte.transactionToken = self.transactionToken
        kyte.sessionToken = self.sessionToken
        
        kyte.makeRequest(httpMethod: method, model: model, field: field, value: value, parameters: parameters, headers: headers, completion: { data, error, session, token in
            self.sessionToken = session
            self.transactionToken = token
            
            if let error = error {
                completion(nil, error)
            }
            
            if let data = data {
                completion(data, nil)
            }
        })
    }
    
    func getUserId() -> String {
        return self.uid
    }
}
