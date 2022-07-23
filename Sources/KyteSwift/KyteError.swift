//
//  KyteError.swift
//  kyte-swift
//
//  Created by Eric Nam on 4/22/22.
//

import Foundation

struct KyteError: Codable {
    let responseCode: Int?
    let txTimestamp, contentType, transaction, engineVersion: String?
    let model, kytePub, kyteNum, kyteIden: String?
    let accountID, error: String?

    enum CodingKeys: String, CodingKey {
      case responseCode = "response_code"
      case txTimestamp
      case contentType = "CONTENT_TYPE"
      case transaction
      case engineVersion = "engine_version"
      case model
      case kytePub = "kyte_pub"
      case kyteNum = "kyte_num"
      case kyteIden = "kyte_iden"
      case accountID = "account_id"
      case error
    }
}
