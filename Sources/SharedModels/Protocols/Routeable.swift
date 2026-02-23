import URLRouting

public protocol Routeable {
  associatedtype Router: ParserPrinter<URLRequestData, Self>

  static var router: Router { get }
}
