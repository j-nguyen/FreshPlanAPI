//
//  RouteTests.swift
//  AppTests
//
//  Created by Johnny Nguyen on 2017-10-05.
//

import XCTest
import Foundation
import Testing
import HTTP
@testable import Vapor
@testable import App

/// This file shows an example of testing
/// routes through the Droplet.

class RouteTests: TestCase {
	let drop = try! Droplet.testable()
	
	func testHello() throws {
		XCTAssert(true)
	}
	
}

// MARK: Manifest

extension RouteTests {
	/// This is a requirement for XCTest on Linux
	/// to function properly.
	/// See ./Tests/LinuxMain.swift for examples
	static let allTests = [
		("testHello", testHello)
	]
}
