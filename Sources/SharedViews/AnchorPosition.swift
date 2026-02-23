/// Represents an element position, used in some views.
public enum AnchorPosition: String, CaseIterable, Sendable {
  case left
  case right
  case top
  case bottom

  public static let `default` = Self.left
}
