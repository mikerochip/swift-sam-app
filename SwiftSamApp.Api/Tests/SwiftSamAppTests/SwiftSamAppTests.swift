import XCTest
import class Foundation.Bundle
@testable import AWSLambdaEvents
@testable import AWSLambdaRuntime
@testable import SwiftSamApp

final class SwiftSamAppTests: XCTestCase {
    static var allTests = [
        ("testExample", testExample),
    ]
    
    func testExample() throws {
        let event = APIGateway.V2.Request()
        let lambdaProxy = APIGatewayProxyLambda()
        let response = lambdaProxy.handle(context: context, event: event)
        XCTAssertEqual(response.body, "Hello, world!")
    }
}
