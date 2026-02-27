import Elementary
import ElementaryHTMX
import Fluent
import SharedModels
import SharedStyleguide
import Vapor

public struct ProjectsTable: HTML, Sendable {

  let userID: User.ID
  let projects: Page<Project>

  public init(userID: User.ID, projects: Page<Project>) {
    self.userID = userID
    self.projects = projects
  }

  public var body: some HTML<HTMLTag.div> {
    div {
      PageTitleRow {
        PageTitle { "Projects" }
        Button(.class("btn-primary"), .showModal(id: ProjectForm.id), svg: .circlePlus)
          .tooltip("Add project")
      }
      .attributes(.class("pb-6"))

      table(.class("table table-zebra")) {
        thead {
          tr {
            th { "Date" }
            th { "Name" }
            th { "Address" }
            th {}
          }
        }
        tbody {
          Rows(projects: projects)
        }
      }

      Modal {
        ProjectForm()
      }
    }
  }
}

extension ProjectsTable {
  public struct Rows: HTML, Sendable {
    let projects: Page<Project>

    public init(projects: Page<Project>) {
      self.projects = projects
    }

    func tooltipPosition(_ n: Int) -> AnchorPosition {
      if projects.metadata.page == 1 && projects.items.count == 1 {
        return .left
      } else if n == (projects.items.count - 1) {
        return .left
      } else {
        return .bottom
      }
    }

    public var body: some HTML {
      for (n, project) in projects.items.enumerated() {
        tr(.id("\(project.id)")) {
          td { DateView(project.createdAt) }
          td { "\(project.name)" }
          td { "\(project.streetAddress)" }
          td {
            div(.class("flex justify-end space-x-6")) {
              div(.class("join")) {
                Button(
                  .class("join-item btn-ghost btn-error"),
                  .hx.delete(route: SharedRoute.project(.delete(project.id))),
                  .hx.confirm("Are you sure?"),
                  .hx.target("closest tr"),
                  svg: .trash
                )
                .tooltip("Delete project", position: tooltipPosition(n))

                Button(
                  .class("join-item btn btn-success btn-ghost"),
                  .hx.get(route: SharedRoute.project(.detail(project.id))),
                  .hx.target(id: "content"),
                  .hx.swap(.innerHTML),
                  .hx.pushURL(true),
                  svg: .chevronRight
                ) 
                .tooltip("View project", position: tooltipPosition(n))
              }
            }
          }
        }
      }
      // Have a row that when revealed fetches the next page,
      // if there are more pages left.
      if projects.metadata.pageCount > projects.metadata.page {
        tr(
          .hx.get(route: SharedRoute.project(.page(.next(projects)))),
          .hx.trigger(.event(.revealed)),
          .hx.swap(.outerHTML),
          .hx.target("this"),
          .hx.indicator("next .htmx-indicator")
        ) {
          Indicator(size: .lg)
        }
      }
    }
  }
}
