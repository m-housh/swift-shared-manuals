import Elementary

extension HTML {

  /// Adds a tooltip to an item.
  ///
  /// NOTE: This depends on `DaisyUI` as css.
  public func tooltip(
    _ tooltip: String,
    position: AnchorPosition = .default
  ) -> Tooltip<Self> {
    Tooltip(tooltip, position: position) {
      self
    }
  }
}

/// Adds a tooltip to an item.
///
/// NOTE: This depends on `DaisyUI` as css.
public struct Tooltip<Inner: HTML>: HTML {

  private let inner: Inner
  private let position: AnchorPosition
  private let tooltip: String

  public init(
    _ tooltip: String,
    position: AnchorPosition = .default,
    @HTMLBuilder body: () -> Inner
  ) {
    self.inner = body()
    self.position = position
    self.tooltip = tooltip
  }

  public var body: some HTML<HTMLTag.div> {
    div(
      .class("tooltip tooltip-\(position.rawValue)"),
      .data("tip", value: tooltip)
    ) {
      inner
    }
  }
}

extension Tooltip: Sendable where Inner: Sendable {}
