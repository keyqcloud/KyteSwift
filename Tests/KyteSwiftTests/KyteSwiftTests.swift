import XCTest
@testable import KyteSwift

let k = KyteManager.shared

struct ExampleToDo: Codable {
    public let subject: String
    
    public enum CodingKeys: String, CodingKey {
        case subject
    }
}

final class KyteSwiftTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        k.endpoint = "https://kyte-example-api.stratis-troika.com"
        k.secretKey = "8da91895cc9341456f56e0fe21cb089ad883f421"
        k.publicKey = "130f66286613c6f472ccd26ceb147fe2e854402a"
        k.accountNumber = "6e068c8f6c259510ff59"
        k.identifier = "62e1b4bda2d07"
    }
    
    func testLogin() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        k.createSession(parameters: ["email":"info@keyqcloud.com","password":"2*pQ6`,p~~_e7"], headers: nil, completion: {
            data, error in
            XCTAssertNotNil(data)
            XCTAssertNil(error)
            print("successful login")
        })
    }
    
    func testPost() throws {
        k.createSession(parameters: ["email":"info@keyqcloud.com","password":"2*pQ6`,p~~_e7"], headers: nil, completion: {
            data, error in
            
            k.post(ExampleToDo.self, model: "ToDo", parameters: ["subject":"test todo","description":"test todo item"], completion: {
                data, error in
                XCTAssertNotNil(data)
                XCTAssertNil(error)
            })
        })
    }
    
    func testPublicToDo() throws {
        k.get(ExampleToDo.self, model: "PublicToDo", field: nil, value: nil, completion: {
            data, error in
            XCTAssertNotNil(data)
            XCTAssertNil(error)
        })
    }
    
    
}
