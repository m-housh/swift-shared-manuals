import Elementary
import Foundation
import Tagged

extension HTMLAttribute where Tag == HTMLTag.input {

  /// Set the value of an input to the given string, if it exists.
  public static func value(_ string: String?) -> Self {
    value(string ?? "")
  }

  /// Set the value of an input to the given double, if it exists.
  public static func value(_ double: Double?) -> Self {
    value(double.map { "\($0)" })
  }

  /// Set the value of an input to the given int, if it exists.
  public static func value(_ int: Int?) -> Self {
    value(int.map { Double($0) })
  }

  /// Set the value of an input to the given uuid, if it exists.
  public static func value(_ uuid: UUID?) -> Self {
    value(uuid.map { $0.uuidString })
  }

  public static func value<T>(_ uuid: Tagged<T, UUID>?) -> Self {
    value(uuid?.rawValue)
  }

  public static func max(_ value: String) -> Self {
    .init(name: "max", value: value)
  }

  /// Set the maximum value for an input.
  public static func max(_ value: Double) -> Self {
    max("\(value)")
  }

  /// Set the maximum value for an input.
  public static func max(_ value: Int) -> Self {
    max(Double(value))
  }

  /// Set the minimum value for an input.
  public static func min(_ value: String) -> Self {
    .init(name: "min", value: value)
  }

  /// Set the minimum value for an input.
  public static func min(_ value: Double) -> Self {
    min("\(value)")
  }

  /// Set the minimum value for an input.
  public static func min(_ value: Int) -> Self {
    min(Double(value))
  }

  /// Set the step attribute for an input.
  public static func step(_ value: Double) -> Self {
    .init(name: "step", value: "\(value)")
  }

  /// Set the step attribute for an input.
  public static func step(_ value: Int) -> Self {
    step(Double(value))
  }

  /// Set the minimum length for an input.
  public static func minlength(_ value: Int) -> Self {
    .init(name: "minlength", value: "\(value)")
  }

  /// Helper that requies an input field to match a given regex pattern.
  ///
  /// NOTE: This is used with `DaisyUI` validators.
  public static func pattern(_ value: String) -> Self {
    .init(name: "pattern", value: value)
  }

  /// Helper that requies an input field to match a given regex pattern.
  ///
  /// NOTE: This is used with `DaisyUI` validators.
  public static func pattern(_ type: PatternType) -> Self {
    pattern(type.value)
  }
}

/// Represents regex patterns used for validating input fields.
public enum PatternType: String, Sendable, CaseIterable {
  /// Password pattern that requires more than 8 characters,
  /// a lower case letter, upper case letter, and a number.
  case password

  /// A username pattern that only allows letters, numbers, or dashes.
  case username

  var value: String {
    switch self {
    case .password:
      return "(?=.*\\d)(?=.*[a-z])(?=.*[A-Z]).{8,}"
    case .username:
      return "[A-Za-z][A-Za-z0-9\\-]*"
    }
  }
}
