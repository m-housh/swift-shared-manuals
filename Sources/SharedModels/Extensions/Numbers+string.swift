import Dependencies
import Foundation

extension Double {
  public func string(digits: Int = 2) -> String {
    @Dependency(\.numberFormatter) var formatter
    return formatter(self, digits: digits)
  }
}

extension Int {
  public func string() -> String {
    @Dependency(\.numberFormatter) var formatter
    return formatter(Double(self), digits: 0)
  }
}
