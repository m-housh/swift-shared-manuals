import Elementary
import SharedModels
import Vapor

extension ViewResponse {

  /// Wraps / uses the ``ResultView`` for the given view controller response.
  ///
  /// - Parameters:
  ///   - value: The throwing closure called in order to generate the view.
  ///   - body: Create the view with the given result of the closure.
  public static func view<Success: Sendable, Failure: Error, SuccessView: HTML>(
    catching value: @escaping @Sendable () async throws(Failure) -> Success,
    @HTMLBuilder body: @escaping @Sendable (Success) -> SuccessView
  ) -> Self where SuccessView: Sendable {
    .view(body: {
      await ResultView {
        try await value()
      } onSuccess: { value in
        body(value)
      }
    })
  }

  /// Wraps / uses the ``ResultView`` for the given view controller response.
  ///
  /// - Parameters:
  ///   - value: The throwing closure called in order to generate the view.
  public static func view<Success: HTML, Failure: Error>(
    catching value: @escaping @Sendable () async throws(Failure) -> Success
  ) -> Self where Success: Sendable {
    .view(body: {
      await ResultView {
        try await value()
      }
    })
  }

  /// Wraps / uses the ``ResultView`` for the given view controller response.
  ///
  /// - Parameters:
  ///   - value: The throwing closure called in order to generate the view.
  public static func view<Failure: Error>(
    catching value: @escaping @Sendable () async throws(Failure) -> Void
  ) -> Self {
    .view(body: {
      await ResultView { try await value() }
    })
  }

}
