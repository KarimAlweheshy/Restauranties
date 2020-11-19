import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(api_restaurantiesTests.allTests),
    ]
}
#endif
