//
//  Kyte.swift
//  kyte
//
//  Created by Kenneth Hough on 4/4/22.
//

import Foundation
import CryptoKit

class Kyte : ObservableObject {

    var endpoint:String = ""
    
    // endpoint keys
    var publicKey:String = ""
    var secretKey:String = ""
    var accountNumber:String = ""
    var identifier:String = ""
    
    // kyte session store
    var sessionToken:String = "0"
    var transactionToken:String = "0"
    var timestamp:String = ""
    var epoch:String = ""
    
    // kyte models
    var models:[String:Any] = [:]
    
    var kyteResponse = KyteModel()
    
    func getIdentityString() -> String {
        // identity string
        // PUBLIC_KEY%SESSION_TOKEN%DATE_TIME_GMT%ACCOUNT_NUMBER
        // * url encode the base64 encoded string
        let string = publicKey + "%" + sessionToken + "%" + timestamp + "%" + accountNumber
        let utf8str = string.data(using: .utf8)
        if let base64str = utf8str?.base64EncodedString()
        {
            if let identityString = base64str.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
            {
                return identityString
            }
        
            print("URL encoding failed")
            return ""
        }
        print("Base 64 encoding failed")
        return ""
    }
    
    func calculateSignature() -> String {
        // signature string
        // #1 HMAC algo = SHA256, data = transactionToken, key = secretKey
        // #2 HMAC algo = SHA256, data = identifier, key = hash#1
        // #3 HMAC algo = SHA256, data = epoch, key = hash#2
        
        // calculate hash #1
        let key1 = SymmetricKey(data: secretKey.data(using: .utf8)!)
        let hash1 = HMAC<SHA256>.authenticationCode(for: Data(transactionToken.utf8), using: key1)
        //let hash1String = Data(hash1).map { String(format: "%02hhx", $0) }.joined()
        //print(hash1String)
        // calculate hash #2
        let key2 = SymmetricKey(data: hash1)
        let hash2 = HMAC<SHA256>.authenticationCode(for: Data(identifier.utf8), using: key2)
        //let hash2String = Data(hash2).map { String(format: "%02hhx", $0) }.joined()
        //print(hash2String)
        // calculate hash #3
        let key3 = SymmetricKey(data: hash2)
        let signature = HMAC<SHA256>.authenticationCode(for: Data(epoch.utf8), using: key3)
        let signatureString = Data(signature).map { String(format: "%02hhx", $0) }.joined()
        //print(signatureString)
        
        return signatureString
    }
    
    // general request function
    func makeRequest(httpMethod: String, model: String, field: String? = nil, value: String? = nil, parameters:[String:Any]? = nil, headers:[String:String]? = nil, completion: @escaping  (_ data: Any) -> Void) {
        
        // generate endpointURL
        if (field != nil && value != nil) {
            self.endpoint += "/" + field! + "/" + value!
        }
        print("[\(httpMethod)]: \(self.endpoint)")
        let url = URL(string: self.endpoint)!
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        
        // set timestamp before calculating necessary authentication strings
        let date = Date()
        let unixtime = date.timeIntervalSince1970
        self.epoch = String(Int(floor(unixtime)))
        self.timestamp = getUTCDate(date: NSDate(timeIntervalSince1970: unixtime))
        
        // create identity and signature strings
        let identity = getIdentityString()
        let signature = calculateSignature()
        
        // add headers for the request
        request.addValue("application/json", forHTTPHeaderField: "Content-Type") // change as per server requirements
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(signature, forHTTPHeaderField: "x-kyte-signature")
        request.addValue(identity, forHTTPHeaderField: "x-kyte-identity")
        
        // if params are present, set body
        if (parameters != nil) {
            // format body
            do {
                // convert parameters to Data and assign dictionary to httpBody of request
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters!, options: .prettyPrinted)
            } catch let error {
                print(error.localizedDescription)
                return
            }
        }
        
        // make request
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
           
        //}) { data, response, error in
            
            if let error = error {
                print("Post Request Error: \(error.localizedDescription)")
                return
            }
            
            // ensure there is valid response code returned from this HTTP response
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...599).contains(httpResponse.statusCode)
            else {
                print("Invalid Response received from the server")
                return
            }
            
            // ensure there is data returned
            guard let responseData = data else {
                print("nil Data received from the server")
                return
            }
            
            let str = String(decoding: responseData, as: UTF8.self)
            
            // output JSON string to console
            print("")
            print("//////////////////////////////////////////")
            print(str)
            print("//////////////////////////////////////////")
            print("")
            
            
            guard let responseCode = try? JSONDecoder().decode(KyteModel.ResponseDefinition.self, from: str.data(using: .utf8)!) else {
                print("[Error] Parsing KyteResponse Code")
                return
            }
            
            self.kyteResponse.response = responseCode
            
            if(self.kyteResponse.response!.responseCode == 200){
                
                // retrieve session and transaction tokens
                self.updateSession(sessionToken: self.kyteResponse.response?.session ?? "0", txToken: self.kyteResponse.response?.token ?? "0")
                
                if(model == "Session"){
        
                    do {
                        let kyteSession = try JSONDecoder().decode(KyteSession.self, from: str.data(using: .utf8)!)
                        
                        completion(kyteSession)
                        //onCompletion(json, error as NSError?)

                    } catch {
                        print(model)
                        print(error)
                    }
            
                    
                } else {
                    
                    do {
                        
//                        guard let modelClass = NSClassFromString(model) as? KyteModelData? else {
//                            print("[Error] Model not defined")
//                            return
//                        }
                        
                        let modelType = self.models[model]
                        
                        guard let modelClass = NSClassFromString(model) as? KyteModelData else {
                            print("[Error] Model not defined")
                            return
                        }
                        
//                        guard let modelType = self.models[model] else {
//                            print("[Error] Model type not defined")
//                            return
//                        }
                        
//                        let modelType = type(of: self.models[model])
                        
//                        if (modelClass is KyteModelData.Type) {
//                            let response = try modelClass.jsonDecode(jsonString: str)
//                            completion(response)
//                        }
                        
                    } catch {
                        print(model)
                        print(error)
                    }
                    
                }
                
            }else{
                
                do{
                    let kyteError = try JSONDecoder().decode(KyteError.self, from: str.data(using: .utf8)!)
                    print("Error Msg: ", kyteError.error ?? "None Error data");
                    completion(kyteError)
                } catch{
                    print("[Error] Parsing Error data")
                }
                    
                
            }
            
            return
            
        })
        
        // perform the task
        task.resume()
    }
    
    func getAccountId() -> String {
        return ""
        //return self.kyteData?.kyteIden ?? ""
    }
    
    func getUTCDate(date: NSDate) -> String {
        let dateFormatter  = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.locale = Locale(identifier: "en-US")
        return dateFormatter.string(from: date as Date)
    }
    
    func post(model: String, parameters:[String:Any], completion:  @escaping (Any) -> Void) {
        makeRequest(httpMethod: "POST", model: model, parameters: parameters, completion: completion)
    }
    
    func put(model: String, field: String? = nil, value: String? = nil, parameters:[String:Any], completion: @escaping (Any) -> Void) {
        makeRequest(httpMethod: "PUT", model: model, field: field, value: value, parameters: parameters, completion: completion)
    }
    
    func get(model: String, field: String? = nil, value: String? = nil, completion: @escaping (Any) -> Void) {
        makeRequest(httpMethod: "GET", model: model, field: field, value: value, completion: completion)
    }
    
    func delete(model: String, field: String, value: String, completion: @escaping (Any) -> Void) {
        makeRequest(httpMethod: "DELETE", model: model, field: field, value: value, completion: completion)
    }
    
    func updateSession(sessionToken: String, txToken: String){
        self.sessionToken = sessionToken
        self.transactionToken = txToken
        print(" *** updateSession *** ")
        print(" self.transactionToken : ", self.transactionToken)
        print(" self.sessionToken: ",  self.sessionToken)
    }
}
