import Foundation
import Tagged

extension String {
  public func appendingPath(_ path: String) -> String {
    guard path.starts(with: "/") else {
      return "\(self)/\(path)"
    }
    return "\(self)\(path)"
  }

  public func appendingPath(_ uuid: UUID?) -> String {
    guard let uuid else { return self }
    return appendingPath(uuid.uuidString)
  }

  public func appendingPath<T>(_ uuid: Tagged<T, UUID>?) -> String {
    guard let uuid else { return self }
    return appendingPath(uuid.rawValue.uuidString)
  }
}

extension UUID {
  public var idString: String {
    uuidString.replacing("-", with: "").replacing(" ", with: "")
  }
}
