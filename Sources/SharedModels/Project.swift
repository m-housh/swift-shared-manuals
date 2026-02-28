import Dependencies
import Foundation
import Tagged

/// Represents a single duct design project / system.
///
/// Holds items such as project name and address.
public struct Project: Codable, Equatable, Identifiable, Sendable {

  /// The unique ID of the project.
  public let id: Tagged<Self, UUID>

  /// The name of the project.
  public let name: String

  /// The street address of the project.
  public let streetAddress: String

  /// The city of the project.
  public let city: String

  /// The state of the project.
  public let state: String

  /// The zip code of the project.
  public let zipCode: String

  /// When the project was created in the database.
  public let createdAt: Date

  /// When the project was updated in the database.
  public let updatedAt: Date

  public init(
    id: Tagged<Self, UUID>,
    name: String,
    streetAddress: String,
    city: String,
    state: String,
    zipCode: String,
    sensibleHeatRatio: Double? = nil,
    createdAt: Date,
    updatedAt: Date
  ) {
    self.id = id
    self.name = name
    self.streetAddress = streetAddress
    self.city = city
    self.state = state
    self.zipCode = zipCode
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
}

extension Project {
  /// Represents the data needed to create a new project.
  public struct Create: Codable, Equatable, Sendable {

    /// The name of the project.
    public let name: String
    /// The street address of the project.
    public let streetAddress: String
    /// The city of the project.
    public let city: String
    /// The state of the project.
    public let state: String
    /// The zip code of the project.
    public let zipCode: String

    public init(
      name: String,
      streetAddress: String,
      city: String,
      state: String,
      zipCode: String,
    ) {
      self.name = name
      self.streetAddress = streetAddress
      self.city = city
      self.state = state
      self.zipCode = zipCode
    }
  }

  /// Represents fields that can be updated for a project that has already been created.
  ///
  /// Only fields that are supplied get updated in the database.
  public struct Update: Codable, Equatable, Sendable {

    /// The name of the project.
    public let name: String?
    /// The street address of the project.
    public let streetAddress: String?
    /// The city of the project.
    public let city: String?
    /// The state of the project.
    public let state: String?
    /// The zip code of the project.
    public let zipCode: String?

    public init(
      name: String? = nil,
      streetAddress: String? = nil,
      city: String? = nil,
      state: String? = nil,
      zipCode: String? = nil,
    ) {
      self.name = name
      self.streetAddress = streetAddress
      self.city = city
      self.state = state
      self.zipCode = zipCode
    }
  }
}
