import Dependencies
import Elementary
import Foundation
import SharedModels

/// Display a date using the DateFormatter dependency.
public struct DateView: HTML, Sendable {
  @Dependency(\.dateFormatter) var dateFormatter
  private let date: Date

  public init(_ date: Date) {
    self.date = date
  }

  public var body: some HTML<HTMLTag.span> {
    span { dateFormatter(date) }
  }
}
