import Elementary

/// Represents a modal dialog.
///
/// > NOTE: This depends on `DaisyUI` for css.
public struct Modal<Inner: HTML>: HTML {
  private let boxAttributes: [HTMLAttribute<HTMLTag.div>]
  private let displayCloseButton: Bool
  private let id: String
  private let inner: Inner
  private let isOpen: Bool

  init(
    id: String,
    open isOpen: Bool = false,
    displayCloseButton: Bool = true,
    boxAttributes: [HTMLAttribute<HTMLTag.div>] = [],
    body: Inner
  ) {
    self.boxAttributes = boxAttributes
    self.displayCloseButton = displayCloseButton
    self.id = id
    self.inner = body
    self.isOpen = isOpen
  }

  public init(
    id: String,
    open isOpen: Bool = false,
    displayCloseButton: Bool = true,
    attributes boxAttributes: [HTMLAttribute<HTMLTag.div>],
    @HTMLBuilder body: () -> Inner
  ) {
    self.init(
      id: id,
      open: isOpen,
      displayCloseButton: displayCloseButton,
      boxAttributes: boxAttributes,
      body: body()
    )
  }

  public init(
    id: String,
    open isOpen: Bool = false,
    displayCloseButton: Bool = true,
    attributes boxAttributes: HTMLAttribute<HTMLTag.div>...,
    @HTMLBuilder body: () -> Inner
  ) {
    self.init(
      id: id,
      open: isOpen,
      displayCloseButton: displayCloseButton,
      boxAttributes: boxAttributes,
      body: body()
    )
  }

  public var body: some HTML<HTMLTag.dialog> {
    dialog(.id(id), .class("modal")) {
      div(.class("modal-box")) {
        if displayCloseButton {
          button(
            .class("btn btn-sm btn-circle btn-ghost absolute right-2 top-2"),
            .on(.click, "\(id).close();")
          ) {
            SVG(.close)
          }
        }
        inner
      }
      .attributes(contentsOf: boxAttributes)
    }
    .attributes(.class("modal-open"), when: isOpen)
  }

}

extension Modal: Sendable where Inner: Sendable {}

extension Modal where Inner: Identifiable, Inner.ID == String {

  public init(
    open isOpen: Bool = false,
    displayCloseButton: Bool = true,
    attributes boxAttributes: HTMLAttribute<HTMLTag.div>...,
    @HTMLBuilder body: () -> Inner
  ) {
    let body = body()
    self.init(
      id: body.id,
      open: isOpen,
      displayCloseButton: displayCloseButton,
      boxAttributes: boxAttributes,
      body: body
    )
  }
}
