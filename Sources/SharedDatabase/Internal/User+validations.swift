import Foundation
import SharedModels
import Validations

// Declaring this in seperate file because some Vapor imports
// have same name's and this was easiest solution.
extension User.Create: Validatable {
  public var body: some Validation<Self> {
    Validator.accumulating {
      Validator.validate(\.email, with: .email())
        .errorLabel("Email", inline: true)

      Validator.validate(\.password.count, with: .greaterThanOrEquals(8))
        .errorLabel("Password Count", inline: true)

      Validator.validate(\.confirmPassword, with: .equals(password))
        .mapError(ConfirmPasswordError())
        .errorLabel("Confirm Password", inline: true)
    }
  }
}

/// Need a custom error, or it risks exposing passwords in the error view.
private struct ConfirmPasswordError: Error, LocalizedError {
  var errorDescription: String? {
    NSLocalizedString("Passwords do not match.", comment: "Confirm password error")
  }
}
