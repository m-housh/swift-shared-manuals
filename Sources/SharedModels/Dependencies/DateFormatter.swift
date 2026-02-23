import Dependencies
import Foundation

public protocol DateFormatter: Sendable {
  func callAsFunction(_ date: Date) -> String
}

extension DependencyValues {
  public var dateFormatter: any DateFormatter {
    get { self[DateFormatterKey.self] }
    set { self[DateFormatterKey.self] = newValue }
  }
}

private enum DateFormatterKey: DependencyKey {
  static var liveValue: any DateFormatter { LiveDateFormatter() }
}

private struct LiveDateFormatter: DateFormatter {
  private let formatter: Foundation.DateFormatter

  init() {
    let formatter = Foundation.DateFormatter()
    formatter.dateFormat = "MM/dd/yyyy"
    self.formatter = formatter
  }

  func callAsFunction(_ date: Date) -> String {
    return formatter.string(from: date)
  }
}
