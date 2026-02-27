import Elementary
import ElementaryHTMX
import SharedModels
import SharedStyleguide

public struct ProjectForm: HTML, Sendable, Identifiable {

  public static var id: String { "projectForm" }

  public var id: String { Self.id }

  let project: Project?

  public init(
    project: Project? = nil
  ) {
    self.project = project
  }

  var route: String {
    SharedRoute.router.path(for: .project(.index))
      .appendingPath(project?.id)
  }

  public var body: some HTML<HTMLTag.form> {
    form(
      .class("grid grid-cols-1 gap-4"),
      project == nil
        ? .hx.post(route)
        : .hx.patch(route),
      .hx.target(id: "content"),
      .hx.swap(.innerHTML)
    ) {
      h1(.class("text-3xl font-bold pb-6 ps-2")) { "Project" }

      if let project {
        input(.class("hidden"), .name("id"), .value("\(project.id)"))
      }

      fieldset {
        legend(.class("fieldset-legend")) { "Name" }
        input(
          .class("input w-full"), .type(.text), .name("name"), .id("name"),
          .placeholder("Big Bird"), .value(project?.name),
          .required, .autofocus
        )
      }

      fieldset {
        legend(.class("fieldset-legend")) { "Address" }
        input(
          .class("input w-full"),
          .type(.text), .name("streetAddress"), .id("streetAddress"),
          .placeholder("123 Sesame St."), .value(project?.streetAddress),
          .required
        )
      }

      fieldset {
        legend(.class("fieldset-legend")) { "City" }
        input(
          .class("input w-full"),
          .type(.text), .name("city"), .id("city"),
          .placeholder("Manhattan"), .value(project?.city),
          .required
        )
      }

      fieldset {
        legend(.class("fieldset-legend")) { "State" }
        input(
          .class("input w-full"),
          .type(.text), .name("state"), .id("state"),
          .placeholder("NY"), .value(project?.state),
          .required
        )
      }

      fieldset {
        legend(.class("fieldset-legend")) { "Zip" }
        input(
          .class("input validator w-full"),
          .type(.text), .name("zipCode"), .id("zipCode"),
          .placeholder("10001"), .value(project?.zipCode),
          .minlength(5), .pattern("[0-9\\-]*"),
          .required
        )
        div(.class("validator-hint")) {
          p {
            "Enter 5 digit zip code. Numbers or '-' only"
          }
        }
      }

      SubmitButton()
        .attributes(.class("btn-block my-6"))
    }
  }

}
