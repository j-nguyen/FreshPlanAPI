//
//  String+.swift
//  App
//
//  Created by Johnny Nguyen on 2017-10-06.
//

import Foundation

extension String {
	static func format(_ file: String,  _ args: Any...) -> String {
		var index = 0
		var result = file
		while (result.contains("%@")) {
			let range = result.range(of: "%@")
			result = result.replacingOccurrences(of: "%@", with: "\(args[index])", options: .literal, range: range)
			index += 1
		}
		return result
	}
	
	func generatePlaceholder() throws -> String {
    guard let firstLetter = first else { throw Abort.notFound }
		return "https://via.placeholder.com/300?text=\(firstLetter)"
	}
}
