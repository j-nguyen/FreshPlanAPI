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
	
	func generatePlaceholder() -> String {
		// TODO : Fix this stupid guard statement soon
		let firstLetter = self.characters.first!
		return "https://via.placeholder.com/300?text=\(firstLetter)"
	}
}
