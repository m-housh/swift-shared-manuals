import Elementary
import Foundation

/// Represents a select field.
///
/// > NOTE: This relies on `DaisyUI` for css, also does not add the 'select' class
///         as it is often added to the label of the field.
public struct Select<Label: HTML, Element: Sendable>: HTML {

  enum SelectInput<E>: Sendable where E: Sendable {
    case array([E])
    case dict([String: [E]])
  }

  private let items: SelectInput<Element>
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
    self.items = .array(items)
    self.placeholder = placeholder
    self.value = value
    self.isSelected = isSelected
    self.makeLabel = makeLabel
  }

  public init(
    _ items: [String: [Element]],
    placeholder: String? = nil,
    value: @escaping @Sendable (Element) -> String,
    selected isSelected: @escaping @Sendable (Element) -> Bool = { _ in false },
    @HTMLBuilder makeLabel: @escaping @Sendable (Element) -> Label
  ) {
    self.items = .dict(items)
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
      switch items {
      case .array(let items):
        for item in items {
          option(.value(value(item))) { makeLabel(item) }
            .attributes(.selected, when: isSelected(item))
        }
      case .dict(let dict):
        for (key, items) in dict {
          option(.disabled) { key }
          for item in items {
            option(.value(value(item))) { makeLabel(item) }
              .attributes(.selected, when: isSelected(item))
          }
        }
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
