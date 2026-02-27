import Elementary

public struct Button<Content: HTML>: HTML {
  private let attributes: [HTMLAttribute<HTMLTag.button>]
  private let _body: Content

  public init(
    attributes: [HTMLAttribute<HTMLTag.button>],
    @HTMLBuilder body: () -> Content
  ) {
    self.attributes = attributes
    self._body = body()
  }

  public init(
    attributes: HTMLAttribute<HTMLTag.button>...,
    @HTMLBuilder body: () -> Content
  ) {
    self.init(attributes: attributes, body: body)
  }

  public var body: some HTML<HTMLTag.button> {
    button(.class("btn")) {
      _body
    }
    .attributes(contentsOf: attributes)
  }
}

extension Button: Sendable where Content: Sendable {}

extension Button where Content == SVG {

  public init(
    _ attributes: HTMLAttribute<HTMLTag.button>...,
    svg: SVG.Key
  ) {
    self.init(attributes: attributes) { SVG(svg) }
  }
}
