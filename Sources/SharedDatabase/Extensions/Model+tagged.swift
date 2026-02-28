import Fluent
import Tagged

extension Model {

  static func find<T>(
    _ id: Tagged<T, IDValue>,
    on database: any Database
  ) async throws -> Self? {
    try await find(id.rawValue, on: database)
  }
}
