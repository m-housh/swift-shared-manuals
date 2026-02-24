import Dependencies
import Foundation

public protocol NumberFormatter: Sendable {
  func callAsFunction(_ double: Double, digits: Int) -> String
}

extension DependencyValues {
  public var numberFormatter: any NumberFormatter {
    get { self[NumberFormatterKey.self] }
    set { self[NumberFormatterKey.self] = newValue }
  }
}

private struct NumberFormatterKey: DependencyKey {
  static var testValue: any NumberFormatter { LiveNumberFormatter() }
  static var liveValue: any NumberFormatter { LiveNumberFormatter() }
}

struct LiveNumberFormatter: NumberFormatter {
  private let formatter: Foundation.NumberFormatter

  init() {
    let formatter = Foundation.NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.groupingSize = 3
    formatter.groupingSeparator = ","
    self.formatter = formatter
  }

  func callAsFunction(_ double: Double, digits: Int) -> String {
    formatter.maximumFractionDigits = digits
    return formatter.string(for: double) ?? ""
  }

}
