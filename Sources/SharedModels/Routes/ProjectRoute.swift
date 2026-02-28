import CasePathsCore
import Fluent
import Foundation
@preconcurrency import URLRouting

extension Project {

  public enum ViewRoute: Equatable, Sendable, Routeable {
    case delete(Project.ID)
    case detail(Project.ID)
    case index
    case page(PageRequest)
    case submit(Project.Create)
    case update(Project.ID, Project.Update)

    public static func page(page: Int, per: Int) -> Self {
      .page(.init(page: page, per: per))
    }

    static let path = "projects"

    public static let router = OneOf {
      Route(.case(Self.delete)) {
        Path {
          path
          Project.ID.parser()
        }
        Method.delete
      }
      Route(.case(Self.detail)) {
        Path {
          path
          Project.ID.parser()
        }
        Method.get
      }
      Route(.case(Self.index)) {
        Path { path }
        Method.get
      }
      Route(.case(Self.page)) {
        Path {
          path
          "page"
        }
        Method.get
        Query {
          Field("page", default: 1) { Digits() }
          Field("per", default: 25) { Digits() }
        }
        .map(.memberwise(PageRequest.init))
      }
      Route(.case(Self.submit)) {
        Path { path }
        Method.post
        Body {
          FormData {
            Field("name", .string)
            Field("streetAddress", .string)
            Field("city", .string)
            Field("state", .string)
            Field("zipCode", .string)
          }
          .map(.memberwise(Project.Create.init))
        }
      }
      Route(.case(Self.update)) {
        Path {
          path
          Project.ID.parser()
        }
        Method.patch
        Body {
          FormData {
            Optionally {
              Field("name", .string)
            }
            Optionally {
              Field("streetAddress", .string)
            }
            Optionally {
              Field("city", .string)
            }
            Optionally {
              Field("state", .string)
            }
            Optionally {
              Field("zipCode", .string)
            }
          }
          .map(.memberwise(Project.Update.init))
        }
      }
    }
  }
}

extension PageRequest: @retroactive Equatable {
  public static func == (lhs: FluentKit.PageRequest, rhs: FluentKit.PageRequest) -> Bool {
    lhs.page == rhs.page && lhs.per == rhs.per
  }
}
