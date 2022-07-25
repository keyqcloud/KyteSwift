//
//  KyteModel.swift
//  
//
//  Created by Kenneth Hough on 7/22/22.
//

import Foundation

struct KytePageDefinition:Codable {
    let pageSize, pageTotal, pageNum, totalCount, totalFiltered: Int
    
    enum CodingKeys: String, CodingKey {
        case pageSize = "page_size"
        case pageTotal = "page_total"
        case pageNum = "page_num"
        case totalCount = "total_count"
        case totalFiltered = "total_filtered"
    }
}

struct KyteModelDefinition<T>:Codable where T : Codable {
    var data: T
    
    enum CodingKeys: String, CodingKey {
        case data
    }
}

class KyteModel<T>: ObservableObject where T : Codable {
    // pagination info
    // cannot be overriden
    final var page:KytePageDefinition?
    
    // data of type any
    var data:KyteModelDefinition<T>?
    
    func jsonDecode(jsonString:String) -> KyteModelDefinition<T>? {
        do {
            self.data = try JSONDecoder().decode(KyteModelDefinition<T>.self, from: jsonString.data(using: .utf8)!)
            return self.data
        } catch {
            print("Unable to parse JSON")
            return nil
        }
    }
}
