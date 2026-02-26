import URLRouting

public protocol Routeable {
  associatedtype Router: URLRouting.Router<Self>

  static var router: Router { get }
}
