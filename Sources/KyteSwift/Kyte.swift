//
//  Kyte.swift
//  kyte
//
//  Created by Kenneth Hough on 4/4/22.
//

import Foundation
import CryptoKit

public enum KyteHTTPMethods: String {
    case POST
    case PUT
    case GET
    case DELETE
}

public class Kyte<T>: ObservableObject where T : Codable {

    public var endpoint:String
    public var publicKey:String
    public var secretKey:String
    public var accountNumber:String
    public var identifier:String
    
    public var sessionToken:String = "0"
    public var transactionToken:String = "0"
    private var timestamp:String = ""
    private var epoch:String = ""
    
    init(withEndpoint endpoint:String, publickey:String, secretkey:String, accountnumber:String, identifier:String) {
        self.endpoint = endpoint
        self.publicKey = publickey
        self.secretKey = secretkey
        self.accountNumber = accountnumber
        self.identifier = identifier
    }
    
    func getIdentityString() -> String {
        // identity string
        // PUBLIC_KEY%SESSION_TOKEN%DATE_TIME_GMT%ACCOUNT_NUMBER
        // * url encode the base64 encoded string
        let string = self.publicKey + "%" + self.sessionToken + "%" + self.timestamp + "%" + self.accountNumber
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
        let key1 = SymmetricKey(data: self.secretKey.data(using: .utf8)!)
        let hash1 = HMAC<SHA256>.authenticationCode(for: Data(self.transactionToken.utf8), using: key1)
        //let hash1String = Data(hash1).map { String(format: "%02hhx", $0) }.joined()
        //print(hash1String)
        // calculate hash #2
        let key2 = SymmetricKey(data: hash1)
        let hash2 = HMAC<SHA256>.authenticationCode(for: Data(self.identifier.utf8), using: key2)
        //let hash2String = Data(hash2).map { String(format: "%02hhx", $0) }.joined()
        //print(hash2String)
        // calculate hash #3
        let key3 = SymmetricKey(data: hash2)
        let signature = HMAC<SHA256>.authenticationCode(for: Data(self.epoch.utf8), using: key3)
        let signatureString = Data(signature).map { String(format: "%02hhx", $0) }.joined()
        //print(signatureString)
        
        return signatureString
    }
    
    // general request function
    public func makeRequest(httpMethod: KyteHTTPMethods, model: String, field: String? = nil, value: String? = nil, parameters:[String:Any]? = nil, headers:[String:String]? = nil, completion: @escaping  (_ data: Any?, _ error: KyteError?, _ sessionToken: String, _ txToken: String) -> Void) {
        
        var endpointUrl = self.endpoint + "/" + model
        // generate endpointURL
        if (field != nil && value != nil) {
            endpointUrl += "/" + field! + "/" + value!
        }
        print("[\(httpMethod.rawValue)]: \(endpointUrl)")
        let url = URL(string: endpointUrl)!
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        
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
        
        let session = URLSession.shared
        
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
            
            
            guard let apiResponse = try? JSONDecoder().decode(KyteResponseDefinition.self, from: str.data(using: .utf8)!) else {
                print("[Error] Parsing KyteResponse Code")
                return
            }
            
            if(apiResponse.responseCode == 200) {
                
                if (model == "Session") {
                    let session = KyteSession()
                    guard let sessionData = session.jsonDecode(jsonString: str) else {
                        print("[Error] unable to get session data")
                        return
                    }
                    self.sessionToken = sessionData.data.sessionToken
                    self.transactionToken = sessionData.data.txToken
                    
                    completion(sessionData, nil, sessionData.data.sessionToken, sessionData.data.txToken)
                } else {
                    
                    let modelClass = KyteModel<T>()
                    
                    guard let modelData = modelClass.jsonDecode(jsonString: str) else {
                        print("[Error] Unable to parse model \(model)")
                        return
                    }
                    
                    completion(modelData, nil, apiResponse.session, apiResponse.token)
                }
                
            } else {
                
                do{
                    let kyteError = try JSONDecoder().decode(KyteError.self, from: str.data(using: .utf8)!)
                    print("Error Msg: ", kyteError.error ?? "None Error data");
                    completion(nil, kyteError, apiResponse.session, apiResponse.token)
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
    
    func updateSession(sessionToken: String, txToken: String){
        self.sessionToken = sessionToken
        self.transactionToken = txToken
        print(" *** updateSession *** ")
        print(" self.transactionToken : ", self.transactionToken)
        print(" self.sessionToken: ",  self.sessionToken)
    }
    
    func resetSession(){
        self.sessionToken = "0"
        self.transactionToken = "0"
        print(" *** resetSession *** ")
        print(" self.transactionToken : ", self.transactionToken)
        print(" self.sessionToken: ",  self.sessionToken)
    }
}
