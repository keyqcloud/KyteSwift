import XCTest
@testable import KyteSwift

final class KyteSwiftTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
        let k = KyteManager.shared
        k.endpoint = "https://kyte-example-api.stratis-troika.com"
        k.secretKey = "8da91895cc9341456f56e0fe21cb089ad883f421"
        k.publicKey = "130f66286613c6f472ccd26ceb147fe2e854402a"
        k.accountNumber = "6e068c8f6c259510ff59"
        k.identifier = "62e1b4bda2d07"
        
        k.createSession(parameters: ["email":"info@keyqcloud.com","password":"2*pQ6`,p~~_e7"], headers: nil, completion: {
            data, error in
            XCTAssertNotNil(data)
            XCTAssertNil(error)
            print("successful login")
        })
//        XCTAssertEqual(KyteSwift().text, "Hello, World!")
    }
}
