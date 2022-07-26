//
//  KyteSession.swift
//  kyte-swift
//
//  Created by Eric Nam on 4/20/22.
//

import Foundation

public class KyteSession: KyteModel<SessionData> {}

// MARK: - DataClass
public struct SessionData: Codable {
    public let uid, expDate, sessionToken, txToken: String
    public let createdBy: String?
    public let dateCreated: String
    public let modifiedBy, dateModified, deletedBy, dateDeleted: String?
    public let deleted, id: String

    public enum CodingKeys: String, CodingKey {
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
