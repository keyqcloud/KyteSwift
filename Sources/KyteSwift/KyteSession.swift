//
//  KyteSession.swift
//  kyte-swift
//
//  Created by Eric Nam on 4/20/22.
//

import Foundation

class KyteSession: KyteModel<SessionData> {}

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
