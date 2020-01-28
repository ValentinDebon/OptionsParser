import XCTest
@testable import OptionsParser

final class OptionsParserTests: XCTestCase {

	func testOptions() {

		let optionsParser = OptionsParser() {
			Option("a") { _ in }
			Option("b") {  }
		}

		XCTAssertEqual(optionsParser.parse(from: ["-a", "b", "-b", "c"]), ["c"])
		XCTAssertEqual(optionsParser.parse(from: ["-bab", "-b", "c"]), ["c"])
		XCTAssertEqual(optionsParser.parse(from: ["-a", "-b", "b", "c"]), ["b", "c"])
		XCTAssertEqual(optionsParser.parse(from: ["-ab", "--", "-b", "c"]), ["-b", "c"])
		XCTAssertEqual(optionsParser.parse(from: ["-a", "b", "-", "c"]), ["-", "c"])
	}

	func testLongOptions() {

		let optionsParser = OptionsParser() {
			Option("first") { _ in }
			Option("second") { }
		}

		XCTAssertEqual(optionsParser.parse(from: ["-first", "second", "-second", "third"]), ["third"])
		XCTAssertEqual(optionsParser.parse(from: ["--first", "second", "--second", "third"]), ["third"])
		XCTAssertEqual(optionsParser.parse(from: ["--first=second", "--second", "third"]), ["third"])
	}

	static var allTests = [
		("testOptions", testOptions),
		("testLongOptions", testLongOptions),
	]
}

