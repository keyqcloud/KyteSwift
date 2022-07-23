//
//  KyteModelData.swift
//  
//
//  Created by Kenneth Hough on 7/22/22.
//

import Foundation

class KyteModelData<T>: ObservableObject where T : Codable {
    struct PageDefinition:Codable {
        let pageSize, pageTotal, pageNum, totalCount, totalFiltered: Int
        
        enum CodingKeys: String, CodingKey {
            case pageSize = "page_size"
            case pageTotal = "page_total"
            case pageNum = "page_num"
            case totalCount = "total_count"
            case totalFiltered = "total_filtered"
        }
    }

    struct Definition<T>:Codable where T : Codable {
        var data: T
        
        enum CodingKeys: String, CodingKey {
            case data
        }
    }
    
    // pagination info
    // cannot be overriden
    final var page:PageDefinition?
    
    // data of type any
    var data:Definition<T>?
    
    func jsonDecode(jsonString:String) -> Definition<T>? {
        do {
            self.data = try JSONDecoder().decode(Definition<T>.self, from: jsonString.data(using: .utf8)!)
            return self.data
        } catch {
            print("Unable to parse JSON")
            return nil
        }
    }
}
