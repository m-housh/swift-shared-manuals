import Elementary
import ElementaryHTMX
import SharedModels
import SharedStyleguide

public struct ProjectDetail: HTML, Sendable {
  private let project: Project

  public init(project: Project) {
    self.project = project
  }

  public var body: some HTML<HTMLTag.div> {
    div {
      PageTitleRow {
        PageTitle { "Project" }

        Button(
          .class("btn-primary"),
          .showModal(id: ProjectForm.id),
          svg: .squarePen
        )
        .tooltip("Edit project", position: .left)

      }

      table(.class("table table-zebra text-lg")) {
        tbody {
          tr {
            td(.class("label font-bold")) { "Name" }
            td {
              div(.class("flex justify-end")) {
                project.name
              }
            }
          }
          tr {
            td(.class("label font-bold")) { "Street Address" }
            td {
              div(.class("flex justify-end")) {
                project.streetAddress
              }
            }
          }
          tr {
            td(.class("label font-bold")) { "City" }
            td {
              div(.class("flex justify-end")) {
                project.city
              }
            }
          }
          tr {
            td(.class("label font-bold")) { "State" }
            td {
              div(.class("flex justify-end")) {
                project.state
              }
            }
          }
          tr {
            td(.class("label font-bold")) { "Zip" }
            td {
              div(.class("flex justify-end")) {
                project.zipCode
              }
            }
          }
        }
      }

      Modal {
        ProjectForm(project: project)
      }
    }
  }

}
