import Foundation

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
}

extension UUID {
  public var idString: String {
    uuidString.replacing("-", with: "").replacing(" ", with: "")
  }
}
