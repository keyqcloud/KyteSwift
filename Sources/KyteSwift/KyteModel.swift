//
//  KyteModel.swift
//  
//
//  Created by Kenneth Hough on 7/22/22.
//

import Foundation

public struct KytePageDefinition:Codable {
    public let pageSize, pageTotal, pageNum, totalCount, totalFiltered: Int
    
    public enum CodingKeys: String, CodingKey {
        case pageSize = "page_size"
        case pageTotal = "page_total"
        case pageNum = "page_num"
        case totalCount = "total_count"
        case totalFiltered = "total_filtered"
    }
}

public struct KyteModelDefinition<T>:Codable where T : Codable {
    public var data: [T]
    
    public enum CodingKeys: String, CodingKey {
        case data
    }
}

open class KyteModel<T>: ObservableObject where T : Codable {
    // pagination info
    // cannot be overriden
    public final var page:KytePageDefinition?
    
    // data of type any
    public var data:KyteModelDefinition<T>?
    
    public func jsonDecode(jsonString:String) -> KyteModelDefinition<T>? {
        do {
            self.data = try JSONDecoder().decode(KyteModelDefinition<T>.self, from: jsonString.data(using: .utf8)!)
            return self.data
        } catch {
            print("Unable to parse JSON")
            return nil
        }
    }
}
