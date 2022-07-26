//
//  KyteSession.swift
//  kyte-swift
//
//  Created by Eric Nam on 4/20/22.
//

import Foundation

public class KyteSession: Codable {
    public var data:KyteSessionDataWrapper?
    
    public func jsonDecode(jsonString:String) -> KyteSessionDataWrapper? {
        do {
            self.data = try JSONDecoder().decode(KyteSessionDataWrapper.self, from: jsonString.data(using: .utf8)!)
            return self.data
        } catch {
            print("Unable to parse JSON")
            return nil
        }
    }
}

public struct KyteSessionDataWrapper: Codable {
    public var data: SessionData
    
    public enum CodingKeys: String, CodingKey {
        case data
    }
}

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
