//
//  KyteModel.swift
//  
//
//  Created by Kenneth Hough on 7/22/22.
//

import Foundation

public struct KyteResponseDefinition:Codable {
    public let responseCode: Int
    public let session, uid, token, sessionPermission: String
    public let txTimestamp, contentType, transaction, engineVersion: String
    public let model, kytePub, kyteNum, kyteIden: String
    public let accountID: String
    
    public enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case session, token, uid, sessionPermission, txTimestamp
        case contentType = "CONTENT_TYPE"
        case transaction
        case engineVersion = "engine_version"
        case model
        case kytePub = "kyte_pub"
        case kyteNum = "kyte_num"
        case kyteIden = "kyte_iden"
        case accountID = "account_id"
    }
}
