import Foundation
import Parsing
import Tagged

extension Tagged where RawValue == UUID {
  public static func parser<Input: Collection>() -> AnyParserPrinter<Input, Self>
  where
    Input.SubSequence == Input,
    Input.Element == UTF8.CodeUnit,
    Input: PrependableCollection
  {
    UUID.parser()
      .map(.representing(Self.self))
      .eraseToAnyParserPrinter()
  }
}
