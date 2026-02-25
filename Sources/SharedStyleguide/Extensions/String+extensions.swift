import Foundation

extension String {
  public func appendingPath(_ path: String) -> String {
    guard path.starts(with: "/") else {
      return "\(self)/\(path)"
    }
    return "\(self)\(path)"
  }
}

extension UUID {
  public var idString: String {
    uuidString.replacing("-", with: "").replacing(" ", with: "")
  }
}
