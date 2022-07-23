//
//  KyteSession.swift
//  kyte-swift
//
//  Created by Eric Nam on 4/20/22.
//

import Foundation

// MARK: - KyteSession
struct KyteSession: Codable {
    let responseCode: Int
    let session, token, uid, sessionPermission: String
    let txTimestamp, contentType, transaction, engineVersion: String
    let model, kytePub, kyteNum, kyteIden: String
    let accountID: String
    let data: SessionData

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
        case data
    }
}

// MARK: - DataClass
struct SessionData: Codable {
    let uid, expDate, sessionToken, txToken: String
    let createdBy: String?
    let dateCreated: String
    let modifiedBy, dateModified, deletedBy, dateDeleted: String?
    let deleted, id: String

    enum CodingKeys: String, CodingKey {
        case uid
        case expDate = "exp_date"
        case sessionToken, txToken
        case createdBy = "created_by"
        case dateCreated = "date_created"
        case modifiedBy = "modified_by"
        case dateModified = "date_modified"
        case deletedBy = "deleted_by"
        case dateDeleted = "date_deleted"
        case deleted, id
    }
}
