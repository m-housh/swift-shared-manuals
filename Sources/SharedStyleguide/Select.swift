import Elementary
import Foundation

/// Represents a select field.
///
/// > NOTE: This relies on `DaisyUI` for css, also does not add the 'select' class
///         as it is often added to the label of the field.
public struct Select<Label: HTML, Element>: HTML {

  private let items: [Element]
  private let makeLabel: @Sendable (Element) -> Label
  private let placeholder: String?
  private let isSelected: @Sendable (Element) -> Bool
  private let value: @Sendable (Element) -> String

  public init(
    _ items: [Element],
    placeholder: String? = nil,
    value: @escaping @Sendable (Element) -> String,
    selected isSelected: @escaping @Sendable (Element) -> Bool = { _ in false },
    @HTMLBuilder makeLabel: @escaping @Sendable (Element) -> Label
  ) {
    self.items = items
    self.placeholder = placeholder
    self.value = value
    self.isSelected = isSelected
    self.makeLabel = makeLabel
  }

  public var body: some HTML<HTMLTag.select> {
    select {
      if let placeholder {
        option(.selected, .disabled) { placeholder }
      }
      // ForEach(items) { item in
      for item in items {
        option(.value(value(item))) {
          makeLabel(item)
        }
        .attributes(.selected, when: isSelected(item))
      }
    }
  }
}

extension Select: Sendable where Label: Sendable, Element: Sendable {}

extension Select where Label == HTMLText, Element: Sendable {
  public init(
    _ items: [Element],
    placeholder: String? = nil,
    value: @escaping @Sendable (Element) -> String,
    selected isSelected: @escaping @Sendable (Element) -> Bool = { _ in false },
    label: @escaping @Sendable (Element) -> String
  ) {
    self.init(
      items,
      placeholder: placeholder,
      value: value,
      selected: isSelected
    ) { item in
      HTMLText(label(item))
    }
  }

  public init(
    _ items: [Element],
    placeholder: String? = nil,
    value: @escaping @Sendable (Element) -> String,
    selected isSelected: @escaping @Sendable (Element) -> Bool = { _ in false },
    label keyPath: KeyPath<Element, String>
  ) {
    self.init(
      items,
      placeholder: placeholder,
      value: value,
      selected: isSelected,
      label: { $0[keyPath: keyPath] }
    )
  }
}

extension KeyPath: @retroactive @unchecked Sendable where Root: Sendable, Value: Sendable {}
