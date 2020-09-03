import XCTest
@testable import QRCodeView

final class QRCodeViewTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(QRCodeView().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
