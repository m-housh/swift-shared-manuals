import Dependencies
import Elementary
import Foundation
import SharedModels

/// Displays a number using the `NumberFormatter` dependency to format
/// the number.
public struct NumberView: HTML, Sendable {
  @Dependency(\.numberFormatter) var numberFormatter
  private let number: Double
  private let digits: Int

  public init(_ double: Double, digits: Int = 2) {
    self.number = double
    self.digits = digits
  }

  public init(_ int: Int) {
    self.init(Double(int), digits: 0)
  }

  public var body: some HTML<HTMLTag.span> {
    span { numberFormatter(number, digits: digits) }
  }

}
