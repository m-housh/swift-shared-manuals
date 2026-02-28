import Dependencies
import DependenciesMacros
import Fluent
import Foundation
import SharedModels
import Validations

extension SharedDatabase.Projects: TestDependencyKey {
  public static let testValue = Self()

  public static func live(database: any Database) -> Self {
    .init(
      create: { userID, request in
        let model = request.toModel(userID: userID)
        try await model.validateAndSave(on: database)
        return try model.toDTO()
      },
      delete: { id in
        guard let model = try await ProjectModel.find(id, on: database) else {
          throw NotFoundError()
        }
        try await model.delete(on: database)
      },
      get: { id in
        try await ProjectModel.find(id, on: database).map { try $0.toDTO() }
      },
      fetch: { userID, request in
        try await ProjectModel.query(on: database)
          .sort(\.$createdAt, .descending)
          .with(\.$user)
          .filter(\.$user.$id == userID.rawValue)
          .paginate(request)
          .map { try $0.toDTO() }
      },
      update: { id, updates in
        guard let model = try await ProjectModel.find(id, on: database) else {
          throw NotFoundError()
        }
        model.applyUpdates(updates)
        if model.hasChanges {
          try await model.validateAndSave(on: database)
        }
        return try model.toDTO()
      }
    )
  }
}

extension Project.Create {

  func toModel(userID: User.ID) -> ProjectModel {
    return .init(
      name: name,
      streetAddress: streetAddress,
      city: city,
      state: state,
      zipCode: zipCode,
      userID: userID
    )
  }

}

extension Project {
  struct Migrate: AsyncMigration {
    let name = "CreateProject"

    func prepare(on database: any Database) async throws {
      try await database.schema(ProjectModel.schema)
        .id()
        .field("name", .string, .required)
        .field("streetAddress", .string, .required)
        .field("city", .string, .required)
        .field("state", .string, .required)
        .field("zipCode", .string, .required)
        .field("createdAt", .string)
        .field("updatedAt", .string)
        .field("userID", .uuid, .required, .references(UserModel.schema, "id", onDelete: .cascade))
        .unique(on: "userID", "name")
        .create()
    }

    func revert(on database: any Database) async throws {
      try await database.schema(ProjectModel.schema).delete()
    }
  }
}

// The Database model.
final class ProjectModel: Model, @unchecked Sendable {

  static let schema = "project"

  @ID(key: .id)
  var id: UUID?

  @Field(key: "name")
  var name: String

  @Field(key: "streetAddress")
  var streetAddress: String

  @Field(key: "city")
  var city: String

  @Field(key: "state")
  var state: String

  @Field(key: "zipCode")
  var zipCode: String

  @Timestamp(key: "createdAt", on: .create, format: .iso8601)
  var createdAt: Date?

  @Timestamp(key: "updatedAt", on: .update, format: .iso8601)
  var updatedAt: Date?

  @Parent(key: "userID")
  var user: UserModel

  init() {}

  init(
    id: UUID? = nil,
    name: String,
    streetAddress: String,
    city: String,
    state: String,
    zipCode: String,
    userID: User.ID,
    createdAt: Date? = nil,
    updatedAt: Date? = nil
  ) {
    self.id = id
    self.name = name
    self.streetAddress = streetAddress
    self.city = city
    self.state = state
    self.zipCode = zipCode
    $user.id = userID.rawValue
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }

  func toDTO() throws -> Project {
    try .init(
      id: .init(rawValue: requireID()),
      name: name,
      streetAddress: streetAddress,
      city: city,
      state: state,
      zipCode: zipCode,
      createdAt: createdAt!,
      updatedAt: updatedAt!
    )
  }

  func applyUpdates(_ updates: Project.Update) {
    if let name = updates.name, name != self.name {
      self.name = name
    }
    if let streetAddress = updates.streetAddress, streetAddress != self.streetAddress {
      self.streetAddress = streetAddress
    }
    if let city = updates.city, city != self.city {
      self.city = city
    }
    if let state = updates.state, state != self.state {
      self.state = state
    }
    if let zipCode = updates.zipCode, zipCode != self.zipCode {
      self.zipCode = zipCode
    }
  }
}

extension ProjectModel: Validatable {

  var body: some Validation<ProjectModel> {
    Validator.accumulating {
      Validator.validate(\.name, with: .notEmpty())
        .errorLabel("Name", inline: true)

      Validator.validate(\.streetAddress, with: .notEmpty())
        .errorLabel("Address", inline: true)

      Validator.validate(\.city, with: .notEmpty())
        .errorLabel("City", inline: true)

      Validator.validate(\.state, with: .notEmpty())
        .errorLabel("State", inline: true)

      Validator.validate(\.zipCode, with: .notEmpty())
        .errorLabel("Zip", inline: true)
    }
  }
}
