//
//  KyteService.swift
//  kyte-swift
//
//  Created by Eric Nam on 5/5/22.
//

import Foundation

public class KyteManager: ObservableObject {
    public static let shared: KyteManager = {
        let instance = KyteManager()
        // setup code
        return instance
    }()

    public var endpoint:String?
    public var publicKey:String?
    public var secretKey:String?
    public var accountNumber:String?
    public var identifier:String?
    
    var _endpoint:String {
        return Bundle.main.object(forInfoDictionaryKey: "KyteEndpointUrl") as? String ?? ""
    }
    
    // endpoint keys
    var _publicKey:String {
        return Bundle.main.object(forInfoDictionaryKey: "KytePublicKey") as? String ?? ""
    }
    var _secretKey:String {
        return Bundle.main.object(forInfoDictionaryKey: "KyteSecretKey") as? String ?? ""
    }
    var _accountNumber:String {
        return Bundle.main.object(forInfoDictionaryKey: "KyteAccountNumber") as? String ?? ""
    }
    var _identifier:String {
        return Bundle.main.object(forInfoDictionaryKey: "KyteIdentifier") as? String ?? ""
    }
    
    // kyte session store
    private var sessionToken:String = "0"
    private var transactionToken:String = "0"
    private var uid:String = ""
    
    init() {}
    
    public func destroySession(completion: ((_ data: KyteSessionDataWrapper?, _ error: KyteError?) -> Void)?) {
        let kyte = Kyte<SessionData>(withEndpoint: self.endpoint ?? self._endpoint, publickey: self.publicKey ?? self._publicKey, secretkey: self.secretKey ?? self._secretKey, accountnumber: self.accountNumber ?? self._accountNumber, identifier: self.identifier ?? self._identifier)
        kyte.transactionToken = self.transactionToken
        kyte.sessionToken = self.sessionToken
        
        kyte.makeRequest(httpMethod: .DELETE, model: "Session", completion: { data, error, session, token in
            self.sessionToken = session
            self.transactionToken = token
            
            if let error = error {
                completion?(nil, error)
            }
            
            if let data = data as? KyteSessionDataWrapper {
                completion?(data, nil)
            }
        })
        self.sessionToken = "0"
        self.transactionToken = "0"
        self.uid = ""
    }
    
    public func createSession(parameters:[String:Any]?, headers:[String:String]? = nil, completion: ((_ data: KyteSessionDataWrapper?, _ error: KyteError?) -> Void)?) {
        let kyte = Kyte<SessionData>(withEndpoint: self.endpoint ?? self._endpoint, publickey: self.publicKey ?? self._publicKey, secretkey: self.secretKey ?? self._secretKey, accountnumber: self.accountNumber ?? self._accountNumber, identifier: self.identifier ?? self._identifier)
        kyte.transactionToken = self.transactionToken
        kyte.sessionToken = self.sessionToken
        
        kyte.makeRequest(httpMethod: .POST, model: "Session", parameters: parameters, headers: headers, completion: { data, error, session, token in
            self.sessionToken = session
            self.transactionToken = token
            
            if let error = error {
                completion?(nil, error)
            }
            
            if let data = data as? KyteSessionDataWrapper {
                self.uid = data.data.uid
                
                completion?(data, nil)
            }
        })
    }
    
    public func post<T:Codable>(_ modelDef: T.Type, model:String, parameters:[String:Any]?, headers:[String:String]? = nil, completion: @escaping  (_ data: KyteModelDefinition<T>?, _ error: KyteError?) -> Void) {
        self.request(T.self, method: .POST, model: model, parameters: parameters, headers: headers, completion:{ data, error in completion(data, error)} )
    }
    public func update<T:Codable>(_ modelDef: T.Type, model:String, field: String?, value: String?, parameters:[String:Any]?, headers:[String:String]? = nil, completion: @escaping  (_ data: KyteModelDefinition<T>?, _ error: KyteError?) -> Void) {
        self.request(T.self, method: .PUT, model: model, field: field, value: value, parameters: parameters, headers: headers, completion:{ data, error in completion(data, error)} )
    }
    public func get<T:Codable>(_ modelDef: T.Type, model:String, field: String?, value: String?, headers:[String:String]? = nil, completion: @escaping  (_ data: KyteModelDefinition<T>?, _ error: KyteError?) -> Void) {
        self.request(T.self, method: .GET, model: model, field: field, value: value, headers: headers, completion:{ data, error in completion(data, error)} )
    }
    public func delete<T:Codable>(_ modelDef: T.Type, model:String, field: String?, value: String?, headers:[String:String]? = nil, completion: @escaping  (_ data: KyteModelDefinition<T>?, _ error: KyteError?) -> Void) {
        self.request(T.self, method: .DELETE, model: model, field: field, value: value, headers: headers, completion:{ data, error in completion(data, error)} )
    }
    
    public func request<T:Codable>(_ modelDef: T.Type, method: KyteHTTPMethods, model:String, field:String? = nil, value:String? = nil, parameters:[String:Any]? = nil, headers:[String:String]? = nil, completion: @escaping  (_ data: KyteModelDefinition<T>?, _ error: KyteError?) -> Void) {
        let kyte = Kyte<T>(withEndpoint: self.endpoint ?? self._endpoint, publickey: self.publicKey ?? self._publicKey, secretkey: self.secretKey ?? self._secretKey, accountnumber: self.accountNumber ?? self._accountNumber, identifier: self.identifier ?? self._identifier)
        kyte.transactionToken = self.transactionToken
        kyte.sessionToken = self.sessionToken
        
        kyte.makeRequest(httpMethod: method, model: model, field: field, value: value, parameters: parameters, headers: headers, completion: { data, error, session, token in
            self.sessionToken = session
            self.transactionToken = token
            
            if let error = error {
                completion(nil, error)
            }
            
            if let data = data as? KyteModelDefinition<T> {
                completion(data, nil)
            }
        })
    }
    
    public func getUserId() -> String {
        return self.uid
    }
}
