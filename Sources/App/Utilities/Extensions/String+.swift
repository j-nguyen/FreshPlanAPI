//
//  String+.swift
//  App
//
//  Created by Johnny Nguyen on 2017-10-05.
//

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
}
