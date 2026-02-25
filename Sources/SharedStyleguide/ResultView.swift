import Elementary
import Foundation

/// A helper view used when calling throwing functions in order to produce a valid view.
///
/// This allows the caller to handle / display the error as an `HTML` view if the function
/// producing the actual view fails.
///
public struct ResultView<Success: Sendable, Failure: Error, SuccessView: HTML>: HTML {

  private let result: Result<Success, Failure>
  private let successView: @Sendable (Success) -> SuccessView
  private let describeError: @Sendable (Failure) -> String

  init(
    result: Result<Success, Failure>,
    onSuccess successView: @escaping @Sendable (Success) -> SuccessView,
    onFailure describeError: @escaping @Sendable (Failure) -> String
  ) {
    self.result = result
    self.successView = successView
    self.describeError = describeError
  }

  public var body: some HTML {
    switch result {
    case .success(let view):
      successView(view)
    case .failure(let error):
      div {
        h1(.class("text-xl text-error font-bold")) {
          "Oops: Error"
        }
        p { describeError(error) }
      }
    }
  }
}

extension ResultView: Sendable where SuccessView: Sendable, Failure: Sendable {}

extension ResultView where Success: Sendable, SuccessView: Sendable {

  public init(
    catching value: @escaping @Sendable () async throws(Failure) -> Success,
    onSuccess successView: @escaping @Sendable (Success) -> SuccessView,
    onFailure describeError: @escaping @Sendable (Failure) -> String = { $0.localizedDescription }
  ) async {
    self.init(
      result: await Result(catching: value),
      onSuccess: { successView($0) },
      onFailure: describeError
    )
  }
}

extension ResultView where Success: HTML, SuccessView == Success {

  public init(
    catching value: @escaping @Sendable () async throws(Failure) -> SuccessView,
    onFailure describeError: @escaping @Sendable (Failure) -> String = { $0.localizedDescription }
  ) async {
    self.init(
      result: await Result(catching: value),
      onSuccess: { $0 },
      onFailure: describeError
    )
  }
}

extension ResultView where Success == Void, SuccessView == EmptyHTML {
  public init(
    catching value: @escaping @Sendable () async throws(Failure) -> Void,
    onFailure describeError: @escaping @Sendable (Failure) -> String = { $0.localizedDescription }
  ) async {
    self.init(
      result: await Result(catching: value),
      onSuccess: { EmptyHTML() },
      onFailure: describeError
    )
  }
}
