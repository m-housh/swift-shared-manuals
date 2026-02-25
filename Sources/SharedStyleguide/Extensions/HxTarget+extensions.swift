import Elementary
import ElementaryHTMX

extension HTMLAttribute.hx {

  /// Convenience for creating the proper selector for a given id.
  public static func target(id: String) -> HTMLAttribute {
    guard !id.starts(with: "#") else {
      return target(id)
    }
    return target("#\(id)")
  }

}
