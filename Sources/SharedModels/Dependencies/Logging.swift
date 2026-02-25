import Dependencies
@_exported import Logging

extension DependencyValues {
  public var logger: Logger {
    get { self[LoggingKey.self] }
    set { self[LoggingKey.self] = newValue }
  }
}

private enum LoggingKey: TestDependencyKey {
  static var testValue: Logger {
    Logger(label: "test-logger")
  }
}
