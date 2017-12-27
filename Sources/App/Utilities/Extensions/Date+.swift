//
//  Date+.swift
//  App
//
//  Created by Johnny Nguyen on 2017-12-25.
//

import Foundation

extension Date {
  public var dateString: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "E MMM d YYYY HH:mm:ss zzzz"
    return dateFormatter.string(from: self)
  }
}
