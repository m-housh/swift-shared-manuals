import Elementary

/// Represents an svg image.
///
/// > NOTE: This is typically extend with a static implementation for the given
/// svg.
public struct SVG: HTML, Sendable {
  private let svg: String

  public init(_ svg: String) {
    self.svg = svg
  }

  public var body: some HTML {
    HTMLRaw(svg)
  }
}

extension SVG {
  public static let close = Self(
    """
    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-x-icon lucide-x"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>
    """
  )
}
