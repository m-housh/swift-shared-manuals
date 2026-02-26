import CasePathsCore
import Foundation
@preconcurrency import URLRouting

public enum ProjectRoute: Sendable, Routeable {
  case delete(Project.ID)
  case index
  case submit(Project.Create)
  case update(Project.ID, Project.Update)

  static let path = "project"

  public static let router = OneOf {
    Route(.case(Self.delete)) {
      Path {
        path
        Project.ID.parser()
      }
      Method.delete
    }
    Route(.case(Self.index)) {
      Path { path }
      Method.get
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
