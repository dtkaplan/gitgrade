library(shiny)
library(gitfiles)

shinyUI(fluidPage(

  # Application title
  titlePanel("Grading papers from git"),

  # Sidebar with a slider input for number of bins
#  verticalLayout(fluid = TRUE,

  fluidRow(
      column(4, selectizeInput("which_file", "File displayed:",
                     choices = format_file_names(COMMIT_LOG))),
      column(3, selectizeInput("which_assignment", "Select assignments:", multiple=TRUE,
                  choices = ASSIGNMENTS$assignment)),
      column(3, selectizeInput("which_student", multiple = TRUE,
                  "or select student:",
                  choices = STUDENTS$github_id))
  ),
  fluidRow(
     column(1,
            radioButtons("display_type", "Type:",
                   choices = c("rmd", "html", "r"), inline = TRUE)),
     column(4, "score:", textOutput("previous_score", inline = TRUE),
      actionButton("score_0", "0"),
      actionButton("score_1", "1"),
      actionButton("score_2", "2"),
      actionButton("score_3", "3"),
      actionButton("score_4", "4"),
      actionButton("score_5", "5")),
      # Comment text entry area
      column(6, tags$textarea(id = 'comment',
                    placeholder = 'Comments for student:', cols = 100, rows = 2, ""))
  ),

      wellPanel(id = "scroll_display",
                style = "overflow-y:scroll; max-height: 600px",
                htmlOutput("file_display")
                )
    )

#)
)
