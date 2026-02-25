import Elementary

extension HTMLAttribute where Tag == HTMLTag.button {
  public static func showModal(id: String) -> Self {
    .on(.click, "\(id).showModal()")
  }
}
