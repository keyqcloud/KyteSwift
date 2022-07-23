//
//  KyteModel.swift
//  
//
//  Created by Kenneth Hough on 7/22/22.
//

import Foundation

struct ResponseDefinition:Codable {
    let responseCode: Int
    let session, uid, token, sessionPermission: String
    let txTimestamp, contentType, transaction, engineVersion: String
    let model, kytePub, kyteNum, kyteIden: String
    let accountID: String
    
    enum CodingKeys: String, CodingKey {
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

class KyteModel: ObservableObject {
    var response:ResponseDefinition?
}
